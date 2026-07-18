import 'package:flutter/material.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class Composer extends StatelessWidget {
  const Composer({
    super.key,
    required this.text,
    required this.isTyping,
    required this.onSkip,
  });

  final String text;
  final bool isTyping;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = text.isEmpty && !isTyping;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      color: AppColors.osSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isTyping ? onSkip : null,
              child: Container(
                constraints: const BoxConstraints(minHeight: 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.osSurfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: showPlaceholder
                    ? const Text(
                        'Message...',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (isTyping) const _BlinkingCursor(),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SendButton(
            active: isTyping,
            onTap: () {
              if (isTyping) {
                Haptics.tap();
                onSkip();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.accent : AppColors.osSurfaceRaised,
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: active ? Colors.white : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _controller.value < 0.5 ? 1 : 0,
          child: Container(
            width: 2,
            height: 18,
            margin: const EdgeInsets.only(left: 2),
            color: AppColors.accent,
          ),
        );
      },
    );
  }
}
