import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/shell_controller.dart';
import '../../domain/os_notification.dart';

/// A notification banner intended to sit on top of a pushed full-screen route
/// (e.g. an open conversation), so message notifications can drop in while the
/// player is still sitting in a finished chat — just like the OS banner does on
/// the home screen.
///
/// Purely visual: the global [NotificationBannerHost] inside the phone shell is
/// still mounted underneath and owns the sound + auto-dismiss timer, so this
/// widget must not re-arm either.
class RouteNotificationBanner extends ConsumerWidget {
  const RouteNotificationBanner({super.key, required this.onTapBanner});

  final void Function(OsNotification banner) onTapBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(
      shellControllerProvider.select((s) => s.banners),
    );
    final banner = banners.isEmpty ? null : banners.last;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1.4),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: banner == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : _Banner(
                  key: ValueKey('route_${banner.id}'),
                  banner: banner,
                  onTap: () {
                    Haptics.tap();
                    ref
                        .read(shellControllerProvider.notifier)
                        .dismissNotification(banner.id);
                    onTapBanner(banner);
                  },
                  onDismiss: () => ref
                      .read(shellControllerProvider.notifier)
                      .dismissNotification(banner.id),
                ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    super.key,
    required this.banner,
    required this.onTap,
    required this.onDismiss,
  });

  final OsNotification banner;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -100) onDismiss();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.osSurfaceHigh.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: banner.accent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(banner.icon, color: Colors.white, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    banner.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
