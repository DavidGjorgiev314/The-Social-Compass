import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/phone_app.dart';

class AppIcon extends StatefulWidget {
  const AppIcon({
    super.key,
    required this.app,
    required this.onLaunch,
    this.showLabel = true,
  });

  final PhoneApp app;
  final void Function(PhoneApp app, Alignment origin) onLaunch;
  final bool showLabel;

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  final GlobalKey _iconKey = GlobalKey();
  bool _pressed = false;

  Alignment _resolveOrigin() {
    final box = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    final screen = MediaQuery.of(context).size;
    if (box == null) return Alignment.center;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final dx = (center.dx / screen.width) * 2 - 1;
    final dy = (center.dy / screen.height) * 2 - 1;
    return Alignment(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: app.enabled ? () => widget.onLaunch(app, _resolveOrigin()) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: _iconKey,
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: app.gradient,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.appIcon),
                    boxShadow: [
                      BoxShadow(
                        color: app.gradient.last.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(app.icon, color: Colors.white, size: 30),
                ),
                if (app.badgeCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: _Badge(count: app.badgeCount),
                  ),
              ],
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                app.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.osBackground, width: 2),
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
