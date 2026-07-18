import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../application/clock_provider.dart';
import '../application/shell_controller.dart';
import 'widgets/status_bar.dart';

class LockScreen extends ConsumerWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();

    void unlock() {
      Haptics.medium();
      ref.read(shellControllerProvider.notifier).unlock();
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -120) unlock();
      },
      onTap: unlock,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.lockWallpaper,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const StatusBar(),
              const SizedBox(height: 36),
              Icon(
                Icons.lock_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                size: 26,
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              Text(formatClockPeriod(now), style: _period),
              Text(formatClock(now), style: AppTypography.clock),
              const SizedBox(height: 4),
              Text(
                formatLockDate(now),
                style: AppTypography.statusBar.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              _UnlockHint(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  static const TextStyle _period = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
  );
}

class _UnlockHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Swipe up to open',
          style: AppTypography.statusBar.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -8, duration: 1100.ms, curve: Curves.easeInOut)
        .fadeIn();
  }
}
