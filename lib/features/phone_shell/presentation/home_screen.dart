import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/phone_app.dart';
import '../application/shell_controller.dart';
import 'widgets/app_icon.dart';
import 'widgets/status_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(shellControllerProvider.select((s) => s.apps));
    final dockApps = apps.where((a) => a.id == PhoneApps.pixelgram).toList();
    final gridApps = apps.where((a) => a.id != PhoneApps.pixelgram).toList();

    void launch(PhoneApp app, Alignment origin) {
      Haptics.light();
      ref.read(shellControllerProvider.notifier).openApp(app.id, origin: origin);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.homeWallpaper,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.xl,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.78,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < gridApps.length; i++)
                      AppIcon(app: gridApps[i], onLaunch: launch)
                          .animate()
                          .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                          .scaleXY(begin: 0.85, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
            _Dock(apps: dockApps, onLaunch: launch),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock({required this.apps, required this.onLaunch});

  final List<PhoneApp> apps;
  final void Function(PhoneApp, Alignment) onLaunch;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final app in apps)
            AppIcon(app: app, onLaunch: onLaunch, showLabel: false),
        ],
      ),
    );
  }
}
