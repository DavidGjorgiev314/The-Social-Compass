import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

Future<void> showLockout(BuildContext context, int seconds) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: true,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => LockoutScreen(seconds: seconds),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class LockoutScreen extends StatefulWidget {
  const LockoutScreen({super.key, required this.seconds});

  final int seconds;

  @override
  State<LockoutScreen> createState() => _LockoutScreenState();
}

class _LockoutScreenState extends State<LockoutScreen> {
  late int _remaining = widget.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Haptics.warning();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        Haptics.medium();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF120608),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 72,
                  color: AppColors.danger,
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 1, end: 1.12, duration: 700.ms),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'DEVICE LOCKED',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'That link was a scam. Your phone froze up while it tried '
                  'to do something in the background.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '$_remaining',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'seconds',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
