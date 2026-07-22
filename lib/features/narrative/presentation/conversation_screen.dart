import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/round_photo.dart';
import '../../../models/game_state.dart';
import '../../../models/stored_message.dart';
import '../../chat/application/chat_controller.dart';
import '../../chat/domain/chat_models.dart';
import '../../chat/presentation/widgets/composer.dart';
import '../../chat/presentation/widgets/fake_keyboard.dart';
import '../../chat/presentation/widgets/message_bubble.dart';
import '../../chat/presentation/widgets/reply_options.dart';
import '../../chat/presentation/widgets/typing_indicator.dart';
import '../../game/application/game_controller.dart';
import '../../phishing/presentation/lockout_screen.dart';
import '../../phone_shell/application/shell_controller.dart';
import '../../phone_shell/domain/os_notification.dart';
import '../../phone_shell/domain/phone_app.dart';
import '../../phone_shell/presentation/widgets/route_notification_banner.dart';
import '../../phone_shell/presentation/widgets/status_bar.dart';
import '../application/story_beats.dart';
import '../data/story_graph.dart';
import '../domain/ending.dart';
import '../domain/narrative_engine.dart';
import '../domain/story_models.dart';
import '../domain/story_step.dart';
import 'ending_screen.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  static const NarrativeEngine _engine = NarrativeEngine();

  late final ChatController _controller;
  late final GameController _game;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _game = ref.read(gameControllerProvider.notifier);
    final state = ref.read(gameControllerProvider).asData?.value;
    final conv = widget.conversationId;

    final messages = state?.thread(conv) ?? const [];
    final wasUnread = state?.isUnread(conv) ?? false;
    final node = state != null ? storyNode(state.currentNodeId) : null;
    final pendingHere = node != null &&
        node.conversationId == conv &&
        (node.kind == NodeKind.chat ||
            node.kind == NodeKind.phishing ||
            node.kind == NodeKind.photoRequest);

    final seed = <ChatMessage>[];
    final script = <ChatBeat>[];

    if (pendingHere && wasUnread) {
      for (final m in messages) {
        if (m.nodeId != node.id) seed.add(_toChatMessage(m));
      }
      for (final line in node.lines) {
        script.add(NpcLine(
          senderId: line.senderId,
          senderName: line.senderName,
          text: line.text,
        ));
      }
      script.addAll(_choiceBeats(node, state!));
    } else {
      for (final m in messages) {
        seed.add(_toChatMessage(m));
      }
      if (pendingHere) script.addAll(_choiceBeats(node, state!));
    }

    _controller = ChatController(
      script: script,
      seed: seed,
      onChoiceSelected: (option) => _handleChoice(option),
    );
    _controller.addListener(_scrollToBottom);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
      _scrollToBottom();
      ref.read(gameControllerProvider.notifier).openConversation(conv);
    });
  }

  @override
  void dispose() {
    _game.scheduleDeliveryOnExit(widget.conversationId);
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  ChatMessage _toChatMessage(StoredMessage m) => ChatMessage(
        id: 'seed_${m.nodeId}_${m.text.hashCode}_${m.imageAsset ?? ''}',
        text: m.text,
        senderId: m.senderId,
        senderName: m.senderName,
        fromPlayer: m.fromPlayer,
        system: m.system,
        memory: m.memory,
        imageAsset: m.imageAsset,
      );

  List<ChatBeat> _choiceBeats(StoryNode node, GameState state) {
    final visible = _engine.visibleChoices(node, state);
    if (visible.isEmpty) return const [];
    return [
      PlayerChoice(
        options: [
          for (final c in visible)
            ReplyOption(
              id: c.id,
              text: c.text,
              isAction: c.isAction ||
                  c.opensGallery ||
                  node.kind == NodeKind.phishing ||
                  c.text.trim().startsWith('('),
            ),
        ],
      ),
    ];
  }

  Future<void> _handleChoice(ReplyOption option) async {
    final state = ref.read(gameControllerProvider).asData?.value;
    if (state == null) return;
    final node = storyNode(state.currentNodeId);
    if (node == null) return;
    final choice = node.choices.firstWhere((c) => c.id == option.id);
    final step = await ref
        .read(gameControllerProvider.notifier)
        .applyStoryChoice(choice, widget.conversationId);
    if (choice.memory != null) {
      _controller.enqueue([MemoryLine(text: choice.memory!)]);
    }
    await _handleStep(step);
  }

  Future<void> _handleStep(StoryStep step) async {
    switch (step) {
      case StoryArrived(:final sameConversation):
        if (sameConversation) {
          final state = ref.read(gameControllerProvider).asData?.value;
          final node = state != null ? storyNode(state.currentNodeId) : null;
          if (node != null && state != null) {
            _controller.enqueue([
              for (final line in node.lines)
                NpcLine(
                  senderId: line.senderId,
                  senderName: line.senderName,
                  text: line.text,
                ),
              ..._choiceBeats(node, state),
            ]);
          }
          _game.openConversation(widget.conversationId);
        }
      // Different conversation: delivery is scheduled on exit (dispose).
      case StoryLockout(:final seconds, :final nextNodeId):
        if (!mounted) return;
        await showLockout(context, seconds);
        final next = await ref
            .read(gameControllerProvider.notifier)
            .continueStory(nextNodeId, widget.conversationId);
        await _handleStep(next);
      case StoryEnded():
        final state = ref.read(gameControllerProvider).asData?.value;
        if (state == null) return;
        final ending = resolveEnding(state);
        await ref.read(gameControllerProvider.notifier).unlockEnding(ending.id);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => EndingScreen(ending: ending)),
        );
      case StoryOpenGallery():
        // Leave the chat and open the Gallery so the player can pick a photo.
        if (!mounted) return;
        Navigator.of(context).maybePop();
        ref.read(shellControllerProvider.notifier).openApp(PhoneApps.photos);
      case StoryPaused():
        _controller.enqueue(const [
          SystemLine(text: 'To be continued — more of the week is coming soon.'),
        ]);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatar = channelAvatar(widget.conversationId);
    final title = channelName(widget.conversationId);

    return Scaffold(
      backgroundColor: AppColors.osBackground,
      body: Stack(
        children: [
          Positioned.fill(child: _buildChat(title, avatar)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RouteNotificationBanner(onTapBanner: _openFromBanner),
          ),
        ],
      ),
    );
  }

  void _openFromBanner(OsNotification banner) {
    final target = banner.route;
    if (target == null || target == widget.conversationId) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(conversationId: target),
      ),
    );
  }

  Widget _buildChat(
    String title,
    ({String? asset, Color color, String initial}) avatar,
  ) {
    return ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          return Column(
            children: [
              const StatusBar(),
              _header(context, title, avatar),
              Expanded(
                child: GestureDetector(
                  onTap: state.playerTyping ? _controller.skipTyping : null,
                  behavior: HitTestBehavior.opaque,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    itemCount:
                        state.messages.length + (state.npcTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: TypingIndicator(),
                        );
                      }
                      final message = state.messages[index];
                      final prev =
                          index > 0 ? state.messages[index - 1] : null;
                      final showName = !message.fromPlayer &&
                          !message.system &&
                          (prev == null || prev.senderId != message.senderId);
                      return MessageBubble(
                        key: ValueKey('${message.id}_$index'),
                        message: message,
                        showName: showName,
                      );
                    },
                  ),
                ),
              ),
              if (state.awaitingChoice)
                ReplyOptions(
                  options: state.options,
                  onSelected: _controller.choose,
                ),
              Composer(
                text: state.composerText,
                isTyping: state.playerTyping,
                onSkip: _controller.skipTyping,
              ),
              const FakeKeyboard(),
            ],
          );
        });
  }

  Widget _header(
    BuildContext context,
    String title,
    ({String? asset, Color color, String initial}) avatar,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.osSurface,
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.textPrimary,
          ),
          RoundPhoto(
            asset: avatar.asset,
            color: avatar.color,
            initial: avatar.initial,
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
