import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.osSurfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.xs),
            bottomRight: Radius.circular(AppRadius.lg),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            );
          },
        ),
      ),
    );
  }

  Widget _dot(int index) {
    final phase = (_controller.value + index * 0.2) % 1.0;
    final t = (phase < 0.5 ? phase : 1 - phase) * 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Transform.translate(
        offset: Offset(0, -3 * t),
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.5 + 0.5 * t),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
