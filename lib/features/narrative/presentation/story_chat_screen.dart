import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../chat/application/chat_controller.dart';
import '../../chat/domain/chat_models.dart';
import '../../chat/presentation/widgets/composer.dart';
import '../../chat/presentation/widgets/fake_keyboard.dart';
import '../../chat/presentation/widgets/message_bubble.dart';
import '../../chat/presentation/widgets/reply_options.dart';
import '../../chat/presentation/widgets/typing_indicator.dart';
import '../../game/application/game_controller.dart';
import '../../phone_shell/presentation/widgets/status_bar.dart';
import '../../phishing/presentation/lockout_screen.dart';
import '../application/story_beats.dart';
import '../data/story_graph.dart';
import '../domain/ending.dart';
import '../domain/narrative_engine.dart';
import '../domain/story_models.dart';
import 'ending_screen.dart';

class StoryChatScreen extends ConsumerStatefulWidget {
  const StoryChatScreen({super.key});

  @override
  ConsumerState<StoryChatScreen> createState() => _StoryChatScreenState();
}

class _StoryChatScreenState extends ConsumerState<StoryChatScreen> {
  static const NarrativeEngine _engine = NarrativeEngine();

  late final ChatController _controller;
  final ScrollController _scroll = ScrollController();

  StoryNode? _currentNode;
  String _channel = 'Pixelgram';

  @override
  void initState() {
    super.initState();
    _controller = ChatController(script: const [], onChoiceSelected: _onChoice);
    _controller.addListener(_scrollToBottom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
      final startId = ref.read(gameControllerProvider).asData?.value.currentNodeId;
      if (startId != null) _advanceFrom(startId, previousConversation: null);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
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

  Future<void> _onChoice(ReplyOption option) async {
    final node = _currentNode;
    if (node == null) return;
    final choice = node.choices.firstWhere((c) => c.id == option.id);
    await ref.read(gameControllerProvider.notifier).applyChoice(node, choice);
    await _advanceFrom(choice.nextNodeId, previousConversation: node.conversationId);
  }

  Future<void> _advanceFrom(
    String nodeId, {
    required String? previousConversation,
  }) async {
    var id = nodeId;
    var prevConversation = previousConversation;

    while (true) {
      final node = storyNode(id);
      if (node == null) {
        _controller.enqueue(const [
          SystemLine(text: 'To be continued — more of the week is coming soon.'),
        ]);
        return;
      }

      if (node.kind == NodeKind.ending) {
        await _resolveEnding();
        return;
      }

      if (node.kind == NodeKind.router) {
        final state = ref.read(gameControllerProvider).asData?.value;
        final target =
            node.resolveRoute((c) => state != null && c.matches(state));
        if (target == null) {
          _controller.enqueue(const [
            SystemLine(text: 'To be continued — more of the week is coming soon.'),
          ]);
          return;
        }
        id = target;
        continue;
      }

      if (node.kind == NodeKind.event) {
        if (node.autoNextNodeId == null) {
          await ref.read(gameControllerProvider.notifier).goTo(node.id, day: node.day);
          _controller.enqueue(const [
            SystemLine(text: 'To be continued — more of the week is coming soon.'),
          ]);
          return;
        }
        if (node.lockoutSeconds != null && mounted) {
          await showLockout(context, node.lockoutSeconds!);
          _controller.enqueue(const [
            SystemLine(text: 'Phone unlocked. That was close.'),
          ]);
        }
        id = node.autoNextNodeId!;
        continue;
      }

      if (node.kind == NodeKind.dayBreak) {
        _controller.enqueue([SystemLine(text: '— End of Day ${node.day} —')]);
        if (node.autoNextNodeId == null) return;
        id = node.autoNextNodeId!;
        continue;
      }

      final state = ref.read(gameControllerProvider).asData?.value;
      if (state == null) return;
      await ref.read(gameControllerProvider.notifier).goTo(node.id, day: node.day);

      final visible = _engine.visibleChoices(node, state);
      final changedChannel = node.conversationId != prevConversation;
      _controller.enqueue(
        beatsForNode(node, visible, withChannelNote: changedChannel),
      );
      setState(() {
        _currentNode = node;
        _channel = channelName(node.conversationId);
      });
      return;
    }
  }

  Future<void> _resolveEnding() async {
    final state = ref.read(gameControllerProvider).asData?.value;
    if (state == null) return;
    final ending = resolveEnding(state);
    await ref.read(gameControllerProvider.notifier).unlockEnding(ending.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => EndingScreen(ending: ending)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.osBackground,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          return Column(
            children: [
              const StatusBar(),
              _header(context),
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
                        key: ValueKey(message.id),
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
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
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
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.forum_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _channel,
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
