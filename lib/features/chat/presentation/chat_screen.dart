import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/round_photo.dart';
import '../../phone_shell/presentation/widgets/status_bar.dart';
import '../application/chat_controller.dart';
import '../domain/chat_models.dart';
import 'widgets/composer.dart';
import 'widgets/fake_keyboard.dart';
import 'widgets/message_bubble.dart';
import 'widgets/reply_options.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.title,
    required this.script,
    this.seed = const [],
    this.accent = AppColors.accent,
    this.avatarAsset,
  });

  final String title;
  final List<ChatBeat> script;
  final List<ChatMessage> seed;
  final Color accent;
  final String? avatarAsset;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController(script: widget.script, seed: widget.seed);
    _controller.addListener(_scrollToBottom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
      _scrollToBottom();
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
          RoundPhoto(
            asset: widget.avatarAsset,
            color: widget.accent,
            initial: widget.title.isNotEmpty
                ? widget.title[0].toUpperCase()
                : '?',
            radius: 16,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            widget.title,
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
