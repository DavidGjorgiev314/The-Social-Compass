import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/asset_photo.dart';
import '../../domain/chat_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.showName});

  final ChatMessage message;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    if (message.memory) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentSecondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: AppColors.accentSecondary.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.push_pin_rounded,
                  size: 13, color: AppColors.accentSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.accentSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 260.ms).scaleXY(begin: 0.92);
    }

    if (message.system) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.osSurface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ).animate().fadeIn(duration: 240.ms);
    }

    final isMe = message.fromPlayer;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(isMe ? AppRadius.lg : AppRadius.xs),
      bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.lg),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !isMe)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                bottom: AppSpacing.xxs,
              ),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md - 2,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            decoration: BoxDecoration(
              gradient: isMe && message.imageAsset == null
                  ? const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF3E7BFA)],
                    )
                  : null,
              color: message.imageAsset != null
                  ? Colors.transparent
                  : (isMe ? null : AppColors.osSurfaceHigh),
              borderRadius: radius,
            ),
            child: message.imageAsset != null
                ? _photo(context, radius)
                : Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic)
        .scaleXY(begin: 0.96, curve: Curves.easeOutCubic);
  }

  Widget _photo(BuildContext context, BorderRadius radius) {
    final width = MediaQuery.of(context).size.width * 0.52;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: resilientAsset(
        message.imageAsset!,
        width: width,
        height: width * 1.15,
        cacheWidth: 720,
        fallback: Container(
          width: width,
          height: width * 1.15,
          color: AppColors.osSurfaceHigh,
          alignment: Alignment.center,
          child: const Icon(Icons.image_rounded,
              color: AppColors.textTertiary, size: 40),
        ),
      ),
    );
  }
}
