import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/chat_models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.showName});

  final ChatMessage message;
  final bool showName;

  @override
  Widget build(BuildContext context) {
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
              gradient: isMe
                  ? const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF3E7BFA)],
                    )
                  : null,
              color: isMe ? null : AppColors.osSurfaceHigh,
              borderRadius: radius,
            ),
            child: Text(
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
}
