import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../data/repositories/game_state_repository.dart';
import '../../../models/game_state.dart';
import '../../../models/history_entry.dart';
import '../../../models/profile_choices.dart';
import '../../../models/stored_message.dart';
import '../../auth/application/auth_providers.dart';
import '../../narrative/application/story_beats.dart';
import '../../narrative/data/story_graph.dart';
import '../../narrative/domain/narrative_engine.dart';
import '../../narrative/domain/story_models.dart';
import '../../narrative/domain/story_step.dart';
import '../../phone_shell/application/shell_controller.dart';
import '../../phone_shell/domain/os_notification.dart';
import '../../phone_shell/domain/phone_app.dart';

const String kFirstStoryNodeId = 'D1_START';

const String flagProfilePublic = 'profile_public';
const String flagProfileRealPhoto = 'profile_real_photo';
const String flagProfileRealName = 'profile_real_name';

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

class GameController extends AsyncNotifier<GameState> {
  static const NarrativeEngine _engine = NarrativeEngine();

  GameStateRepository get _repo => ref.read(gameStateRepositoryProvider);

  @override
  Future<GameState> build() async {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) {
      throw StateError('Cannot load game state while signed out.');
    }
    final existing = await _repo.load(uid);
    if (existing != null) {
      final delivered = _ensureDelivered(existing);
      if (!identical(delivered, existing)) await _repo.save(uid, delivered);
      return delivered;
    }

    final initial = GameState.initial();
    await _repo.save(uid, initial);
    return initial;
  }

  GameState? get _current => state.asData?.value;

  Future<void> _persist(GameState next, {HistoryEntry? history}) async {
    state = AsyncData(next);
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await _repo.save(uid, next);
    if (history != null) await _repo.appendHistory(uid, history);
  }

  Future<void> completeProfile(ProfileChoices profile) async {
    final current = _current;
    if (current == null) return;

    final next = current.copyWith(
      profile: profile.copyWith(completed: true),
      flags: {
        ...current.flags,
        flagProfilePublic: profile.isPublic,
        flagProfileRealPhoto: profile.usesRealPhoto,
        flagProfileRealName: profile.usesRealName,
      },
      day: 1,
      currentNodeId: kFirstStoryNodeId,
      updatedAt: DateTime.now(),
    );
    await _persist(_ensureDelivered(next));
  }

  // ── Story delivery ──────────────────────────────────────────────

  Future<void> openConversation(String conversationId) async {
    final current = _current;
    if (current == null) return;
    if (current.unread[conversationId] == false) return;
    await _persist(current.copyWith(
      unread: {...current.unread, conversationId: false},
    ));
  }

  Future<StoryStep> applyStoryChoice(
    StoryChoice choice,
    String viewingConversation,
  ) async {
    var s = _current;
    if (s == null) return const StoryPaused();
    final node = storyNode(s.currentNodeId);
    if (node == null) return const StoryPaused();

    final conv = node.conversationId ?? '';
    final isAction = node.kind == NodeKind.phishing ||
        choice.text.trim().startsWith('(') ||
        choice.isAction;

    s = _append(
      s,
      conv,
      StoredMessage(
        text: isAction ? '✓ ${_stripParens(choice.text)}' : choice.text,
        senderId: 'player',
        senderName: 'You',
        fromPlayer: !isAction,
        nodeId: node.id,
        system: isAction,
      ),
    );
    s = s.copyWith(
      stats: choice.delta.applyTo(s.stats),
      flags: {...s.flags, ...choice.setFlags},
    );

    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      unawaited(_repo.appendHistory(
        uid,
        HistoryEntry(
          nodeId: node.id,
          choiceId: choice.id,
          statsAfter: {
            'friendship': s.stats.friendship,
            'trust': s.stats.trust,
            'awareness': s.stats.awareness,
          },
          at: DateTime.now(),
        ),
      ));
    }

    return _resolveFrom(s, choice.nextNodeId, viewingConversation);
  }

  // Called from a chat screen's dispose: if the story has advanced to a
  // different, not-yet-delivered conversation, deliver it after a delay.
  void scheduleDeliveryOnExit(String viewingConversation) {
    final s = _current;
    if (s == null) return;
    final node = storyNode(s.currentNodeId);
    if (node == null ||
        (node.kind != NodeKind.chat && node.kind != NodeKind.phishing)) {
      return;
    }
    final conv = node.conversationId ?? '';
    if (conv == viewingConversation) return;
    if (s.thread(conv).any((m) => m.nodeId == node.id)) return;
    scheduleDelivery(conv);
  }

  Future<StoryStep> continueStory(
    String fromNodeId,
    String viewingConversation,
  ) async {
    final s = _current;
    if (s == null) return const StoryPaused();
    return _resolveFrom(s, fromNodeId, viewingConversation);
  }

  Future<StoryStep> _resolveFrom(
    GameState start,
    String startId,
    String fromConversation,
  ) async {
    var s = start;
    var id = startId;
    var guard = 0;

    loop:
    while (guard++ < 100) {
      final node = storyNode(id);
      if (node == null) {
        await _persist(s.copyWith(currentNodeId: id));
        return const StoryPaused();
      }

      switch (node.kind) {
        case NodeKind.ending:
          await _persist(s.copyWith(currentNodeId: node.id));
          return const StoryEnded();
        case NodeKind.router:
          final target = node.resolveRoute((c) => c.matches(s));
          if (target == null) {
            await _persist(s.copyWith(currentNodeId: node.id));
            return const StoryPaused();
          }
          id = target;
          continue loop;
        case NodeKind.event:
          if (node.lockoutSeconds != null) {
            await _persist(s.copyWith(currentNodeId: node.id));
            return StoryLockout(node.lockoutSeconds!, node.autoNextNodeId ?? '');
          }
          if (node.autoNextNodeId == null) {
            await _persist(s.copyWith(currentNodeId: node.id));
            return const StoryPaused();
          }
          id = node.autoNextNodeId!;
          continue loop;
        case NodeKind.dayBreak:
          if (node.autoNextNodeId == null) {
            await _persist(s.copyWith(currentNodeId: node.id));
            return const StoryPaused();
          }
          id = node.autoNextNodeId!;
          continue loop;
        case NodeKind.chat:
        case NodeKind.phishing:
          final conv = node.conversationId ?? '';
          final same = conv == fromConversation;
          if (same) {
            s = _deliverNode(s, node)
                .copyWith(currentNodeId: node.id, day: node.day);
          } else {
            // Deliver later, after the player leaves the current chat.
            s = s.copyWith(currentNodeId: node.id, day: node.day);
          }
          await _persist(s);
          return StoryArrived(conv, sameConversation: same);
      }
    }
    return const StoryPaused();
  }

  GameState _ensureDelivered(GameState s) {
    final node = storyNode(s.currentNodeId);
    if (node == null ||
        (node.kind != NodeKind.chat && node.kind != NodeKind.phishing)) {
      return s;
    }
    final conv = node.conversationId ?? '';
    if (s.thread(conv).any((m) => m.nodeId == node.id)) return s;
    return _deliverNode(s, node);
  }

  GameState _deliverNode(GameState s, StoryNode node) {
    final conv = node.conversationId ?? '';
    final messages = [
      ...s.thread(conv),
      for (final line in node.lines)
        StoredMessage(
          text: line.text,
          senderId: line.senderId,
          senderName: line.senderName,
          fromPlayer: false,
          nodeId: node.id,
        ),
    ];
    return s.copyWith(
      threads: {...s.threads, conv: messages},
      unread: {...s.unread, conv: true},
    );
  }

  GameState _append(GameState s, String conv, StoredMessage message) {
    return s.copyWith(
      threads: {
        ...s.threads,
        conv: [...s.thread(conv), message],
      },
    );
  }

  String _stripParens(String text) {
    final t = text.trim();
    if (t.startsWith('(') && t.endsWith(')')) {
      return t.substring(1, t.length - 1);
    }
    return t;
  }

  // Called when the player leaves a chat and the story has moved on to a
  // different conversation: after a delay the new messages are delivered into
  // their thread and a notification banner (whose arrival plays the sound) is
  // shown.
  void scheduleDelivery(String conversationId) {
    Timer(
      const Duration(seconds: 2),
      () => deliverPendingConversation(conversationId),
    );
  }

  Future<void> deliverPendingConversation(String conversationId) async {
    try {
      final s = _current;
      if (s == null || ref.read(currentUidProvider) == null) return;
      final node = storyNode(s.currentNodeId);
      if (node == null || node.conversationId != conversationId) return;
      if (s.thread(conversationId).any((m) => m.nodeId == node.id)) return;

      await _persist(_deliverNode(s, node));

      final first = node.lines.isNotEmpty ? node.lines.first : null;
      ref.read(shellControllerProvider.notifier).pushNotification(
            OsNotification(
              id: '${node.id}_${DateTime.now().millisecondsSinceEpoch}',
              appId: PhoneApps.pixelgram,
              title: first?.senderName ?? channelName(conversationId),
              body: first?.text ?? 'New message',
              icon: Icons.chat_bubble_rounded,
              accent: channelAvatar(conversationId).color,
            ),
          );
    } catch (_) {
      // Container disposed or shell unavailable; skip.
    }
  }

  Future<void> applyChoice(StoryNode node, StoryChoice choice) async {
    final current = _current;
    if (current == null) return;

    final next = _engine.applyChoice(current, choice);
    final history = HistoryEntry(
      nodeId: node.id,
      choiceId: choice.id,
      statsAfter: {
        'friendship': next.stats.friendship,
        'trust': next.stats.trust,
        'awareness': next.stats.awareness,
      },
      at: DateTime.now(),
    );
    await _persist(next, history: history);
  }

  Future<void> goTo(String nodeId, {int? day}) async {
    final current = _current;
    if (current == null) return;
    await _persist(
      current.copyWith(
        currentNodeId: nodeId,
        day: day ?? current.day,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> resetGame() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await _repo.delete(uid);
    final fresh = GameState.initial();
    await _repo.save(uid, fresh);
    state = AsyncData(fresh);
  }

  Future<void> unlockEnding(String endingId) async {
    final current = _current;
    if (current == null) return;
    final unlocked = {...current.endingsUnlocked, endingId}.toList();
    await _persist(
      current.copyWith(
        endingsUnlocked: unlocked,
        currentEnding: endingId,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

final gameControllerProvider =
    AsyncNotifierProvider<GameController, GameState>(GameController.new);
