import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../onboarding/presentation/onboarding_flow.dart';
import '../../phone_shell/presentation/phone_shell.dart';
import '../application/game_controller.dart';

class GameGate extends ConsumerWidget {
  const GameGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);

    return game.when(
      loading: () => const _Splash(),
      error: (error, _) => _ErrorView(message: '$error'),
      data: (state) =>
          state.profile.completed ? const PhoneShell() : const OnboardingFlow(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.osBackground,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.osBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.textTertiary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Couldn\'t load your progress.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
