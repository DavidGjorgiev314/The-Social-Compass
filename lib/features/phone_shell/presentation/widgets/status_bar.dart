import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/clock_provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key, this.brightText = true});

  final bool brightText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).asData?.value ?? DateTime.now();
    final color = brightText ? AppColors.textPrimary : AppColors.osBackground;

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 18, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formatClock(now),
              style: AppTypography.statusBar.copyWith(color: color),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Icon(Icons.wifi_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                _Battery(color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '82',
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 24,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.5),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                width: 15,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
