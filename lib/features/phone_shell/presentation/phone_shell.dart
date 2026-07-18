import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../domain/os_notification.dart';
import '../domain/phone_app.dart';
import '../application/shell_controller.dart';
import 'app_registry.dart';
import 'home_screen.dart';
import 'lock_screen.dart';
import 'widgets/notification_banner.dart';

class PhoneShell extends ConsumerStatefulWidget {
  const PhoneShell({super.key});

  @override
  ConsumerState<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends ConsumerState<PhoneShell>
    with TickerProviderStateMixin {
  late final AnimationController _appController = AnimationController(
    vsync: this,
    duration: AppMotion.appLaunch,
  );

  PhoneApp? _currentApp;
  Alignment _origin = Alignment.center;

  @override
  void initState() {
    super.initState();
    _appController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _currentApp = null);
      }
    });
  }

  @override
  void dispose() {
    _appController.dispose();
    super.dispose();
  }

  void _syncApp(String? openAppId) {
    if (openAppId == null) {
      _appController.reverse();
      return;
    }
    final apps = ref.read(shellControllerProvider).apps;
    final matches = apps.where((a) => a.id == openAppId);
    if (matches.isEmpty) return;
    final app = matches.first;
    setState(() {
      _currentApp = app;
      _origin = ref.read(shellControllerProvider).launchOrigin;
    });
    _appController.forward();
  }

  void _handleBannerTap(OsNotification banner) {
    final controller = ref.read(shellControllerProvider.notifier);
    controller.unlock();
    controller.openApp(banner.appId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shellControllerProvider.select((s) => s.openAppId),
        (_, next) => _syncApp(next));
    final isLocked = ref.watch(shellControllerProvider.select((s) => s.isLocked));

    return Scaffold(
      backgroundColor: AppColors.osBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: HomeScreen()),
          if (_currentApp != null) _buildAppLayer(_currentApp!),
          _buildLockLayer(isLocked),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationBannerHost(onTapBanner: _handleBannerTap),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLayer(PhoneApp app) {
    final curved = CurvedAnimation(
      parent: _appController,
      curve: AppMotion.decelerate,
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) {
          final t = curved.value;
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.2 + 0.8 * t,
              alignment: _origin,
              child: child,
            ),
          );
        },
        child: buildAppScreen(app),
      ),
    );
  }

  Widget _buildLockLayer(bool isLocked) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isLocked,
        child: AnimatedSwitcher(
          duration: AppMotion.medium,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: isLocked
              ? const LockScreen(key: ValueKey('lock'))
              : const SizedBox.shrink(key: ValueKey('unlocked')),
        ),
      ),
    );
  }
}
