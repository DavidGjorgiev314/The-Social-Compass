import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../phone_shell/presentation/widgets/app_frame.dart';
import 'widgets/feed_view.dart';
import 'widgets/inbox_view.dart';

class PixelgramApp extends StatefulWidget {
  const PixelgramApp({super.key});

  @override
  State<PixelgramApp> createState() => _PixelgramAppState();
}

class _PixelgramAppState extends State<PixelgramApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      child: Column(
        children: [
          _header(),
          const Divider(height: 1, color: AppColors.hairline),
          Expanded(child: _tab == 0 ? const FeedView() : const InboxView()),
          _bottomNav(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: AppColors.pixelgramBrand)
                    .createShader(b),
            child: const Text(
              'Pixelgram',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined),
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.osSurface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: IconButton(
                  onPressed: () => setState(() => _tab = i),
                  icon: Icon(
                    _tab == i ? items[i].$1 : items[i].$2,
                    color: _tab == i
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
