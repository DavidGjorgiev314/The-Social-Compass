import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../data/repositories/game_state_repository.dart';
import '../../../models/game_state.dart';
import '../../../models/history_entry.dart';
import '../../../models/profile_choices.dart';
import '../../auth/application/auth_providers.dart';
import '../../narrative/domain/narrative_engine.dart';
import '../../narrative/domain/story_models.dart';

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
    if (existing != null) return existing;

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
    await _persist(next);
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
