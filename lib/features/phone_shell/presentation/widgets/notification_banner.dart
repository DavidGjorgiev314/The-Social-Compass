import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/os_notification.dart';
import '../../application/shell_controller.dart';

class NotificationBannerHost extends ConsumerStatefulWidget {
  const NotificationBannerHost({super.key, this.onTapBanner});

  final void Function(OsNotification notification)? onTapBanner;

  @override
  ConsumerState<NotificationBannerHost> createState() =>
      _NotificationBannerHostState();
}

class _NotificationBannerHostState
    extends ConsumerState<NotificationBannerHost> {
  String? _shownId;
  Timer? _autoDismiss;

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }

  void _armTimer(OsNotification banner) {
    if (_shownId == banner.id) return;
    _shownId = banner.id;
    _autoDismiss?.cancel();
    Haptics.light();
    _autoDismiss = Timer(const Duration(seconds: 5), () {
      ref.read(shellControllerProvider.notifier).dismissNotification(banner.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(
      shellControllerProvider.select((s) => s.banners),
    );
    final banner = banners.isEmpty ? null : banners.last;

    if (banner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _armTimer(banner));
    } else {
      _shownId = null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 340),
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
                  key: ValueKey(banner.id),
                  banner: banner,
                  onTap: () {
                    _autoDismiss?.cancel();
                    Haptics.tap();
                    ref
                        .read(shellControllerProvider.notifier)
                        .dismissNotification(banner.id);
                    widget.onTapBanner?.call(banner);
                  },
                  onDismiss: () {
                    _autoDismiss?.cancel();
                    ref
                        .read(shellControllerProvider.notifier)
                        .dismissNotification(banner.id);
                  },
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
          color: AppColors.osSurfaceHigh.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
