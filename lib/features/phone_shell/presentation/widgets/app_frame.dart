import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/shell_controller.dart';
import 'status_bar.dart';

class AppFrame extends ConsumerWidget {
  const AppFrame({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.osBackground,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void close() {
      Haptics.light();
      ref.read(shellControllerProvider.notifier).closeApp();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: Container(
        color: backgroundColor,
        child: Column(
          children: [
            const StatusBar(),
            Expanded(child: child),
            _HomeIndicator(onClose: close),
          ],
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClose,
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -80) onClose();
      },
      child: SafeArea(
        top: false,
        child: Container(
          height: 24,
          alignment: Alignment.center,
          child: Container(
            width: 130,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
