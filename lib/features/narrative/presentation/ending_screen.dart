import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/game_stats.dart';
import '../../game/application/game_controller.dart';
import '../domain/ending.dart';

class EndingScreen extends ConsumerWidget {
  const EndingScreen({super.key, required this.ending});

  final Ending ending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gameControllerProvider).asData?.value.stats ??
        const GameStats();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.lockWallpaper,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'YOUR WEEK ENDED',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ending.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 150.ms).scaleXY(
                      begin: 0.9,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  ending.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: AppSpacing.xxl),
                _StatBar(label: 'Friendship', value: stats.friendship, color: AppColors.accentSecondary),
                _StatBar(label: 'Trust', value: stats.trust, color: AppColors.accent),
                _StatBar(label: 'Awareness', value: stats.awareness, color: AppColors.mint),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Haptics.medium();
                      await ref.read(gameControllerProvider.notifier).resetGame();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    },
                    child: const Text('Play again'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Back to phone'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$value',
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => LinearProgressIndicator(
                value: t,
                minHeight: 8,
                backgroundColor: AppColors.osSurfaceHigh,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
