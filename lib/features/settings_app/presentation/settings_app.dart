import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../../game/application/game_controller.dart';
import '../../phone_shell/presentation/widgets/app_frame.dart';

class SettingsApp extends ConsumerWidget {
  const SettingsApp({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    Haptics.warning();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.osSurfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Start a new game?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This wipes your current progress — stats, choices, and story '
          'position — and takes you back to profile setup. Endings you\'ve '
          'seen are cleared too.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(gameControllerProvider.notifier).resetGame();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppFrame(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const _SectionLabel('Privacy & Safety'),
          const _SettingsRow(Icons.lock_outline_rounded, 'Privacy', AppColors.accent),
          const _SettingsRow(Icons.shield_outlined, 'Security', AppColors.mint),
          const _SettingsRow(
              Icons.notifications_none_rounded, 'Notifications', AppColors.warning),
          const _SectionLabel('Account'),
          const _SettingsRow(
              Icons.person_outline_rounded, 'Profile', AppColors.accentSecondary),
          const _SettingsRow(Icons.help_outline_rounded, 'Help', AppColors.textTertiary),
          const _SectionLabel('Playtesting'),
          _ActionRow(
            icon: Icons.restart_alt_rounded,
            label: 'Start new game',
            tint: AppColors.danger,
            onTap: () => _confirmReset(context, ref),
          ),
          _ActionRow(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            tint: AppColors.textSecondary,
            onTap: () {
              Haptics.tap();
              ref.read(signInControllerProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.icon, this.label, this.tint);

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: _iconBox(icon, tint),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _iconBox(icon, tint),
      title: Text(
        label,
        style: TextStyle(color: tint, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Widget _iconBox(IconData icon, Color tint) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}
