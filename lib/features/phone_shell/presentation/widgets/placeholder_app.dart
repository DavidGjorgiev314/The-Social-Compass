import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/phone_app.dart';
import 'app_frame.dart';

class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key, required this.app});

  final PhoneApp app;

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: app.gradient),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(app.icon, color: Colors.white, size: 38),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                app.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Nothing to see here right now.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
