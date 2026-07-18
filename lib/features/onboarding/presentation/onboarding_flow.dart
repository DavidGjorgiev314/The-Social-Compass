import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/haptics/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/profile_choices.dart';
import '../../game/application/game_controller.dart';
import '../../phone_shell/presentation/widgets/status_bar.dart';
import 'widgets/choice_card.dart';

const List<Color> _avatarPalette = [
  AppColors.accent,
  AppColors.accentSecondary,
  AppColors.mint,
  AppColors.warning,
  Color(0xFF9B8CFF),
];

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _nameController = TextEditingController();
  int _step = 0;
  bool _submitting = false;

  NameChoice? _nameChoice;
  PhotoChoice? _photoChoice;
  int _avatarIndex = 0;
  ProfileVisibility? _visibility;

  static const int _lastStep = 3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _nameChoice != null && _nameController.text.trim().isNotEmpty;
      case 1:
        return _photoChoice != null;
      case 2:
        return _visibility != null;
      default:
        return true;
    }
  }

  void _next() {
    if (_step < _lastStep) {
      Haptics.tap();
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      Haptics.tap();
      setState(() => _step--);
    }
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    Haptics.medium();
    final profile = ProfileChoices(
      displayName: _nameController.text.trim(),
      nameChoice: _nameChoice!,
      photoChoice: _photoChoice!,
      avatarId: _photoChoice == PhotoChoice.avatar
          ? 'avatar_$_avatarIndex'
          : 'photo',
      visibility: _visibility!,
      completed: true,
    );
    await ref.read(gameControllerProvider.notifier).completeProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.lockWallpaper,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const StatusBar(),
              _progressBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(_lastStep + 1, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.osSurfaceHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _nameStep();
      case 1:
        return _photoStep();
      case 2:
        return _visibilityStep();
      default:
        return _confirmStep();
    }
  }

  Widget _stepScaffold({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }

  Widget _nameStep() {
    return _stepScaffold(
      title: 'What should people call you?',
      subtitle: 'This is how you\'ll show up across Pixelgram.',
      children: [
        ChoiceCard(
          title: 'Use my real name',
          pro: 'People from class recognize you right away.',
          con: 'Anyone can find and identify the real you offline.',
          selected: _nameChoice == NameChoice.real,
          onTap: () => setState(() => _nameChoice = NameChoice.real),
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceCard(
          title: 'Use a nickname',
          pro: 'Harder for strangers to track down who you really are.',
          con: 'Fewer people know it\'s you at first.',
          selected: _nameChoice == NameChoice.alias,
          onTap: () => setState(() => _nameChoice = NameChoice.alias),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.osSurface,
            hintText: _nameChoice == NameChoice.alias
                ? 'Pick a nickname'
                : 'Enter your name',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoStep() {
    return _stepScaffold(
      title: 'Set your profile picture',
      subtitle: 'Your face, or something that stands in for it.',
      children: [
        ChoiceCard(
          title: 'Use a real photo',
          pro: 'Feels authentic, so more people follow back.',
          con: 'Invites attention from people you didn\'t ask for.',
          selected: _photoChoice == PhotoChoice.photo,
          onTap: () => setState(() => _photoChoice = PhotoChoice.photo),
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceCard(
          title: 'Use an avatar',
          pro: 'Keeps your actual face private.',
          con: 'Some people trust a real face more.',
          selected: _photoChoice == PhotoChoice.avatar,
          onTap: () => setState(() => _photoChoice = PhotoChoice.avatar),
        ),
        if (_photoChoice == PhotoChoice.avatar) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Pick an avatar',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_avatarPalette.length, (i) {
              final selected = _avatarIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _avatarIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.accent : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: _avatarPalette[i],
                    child: const Icon(Icons.person_rounded, color: Colors.white),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _visibilityStep() {
    return _stepScaffold(
      title: 'Who can see your profile?',
      subtitle: 'You can change this later, but first impressions spread fast.',
      children: [
        ChoiceCard(
          title: 'Public',
          pro: 'Maximum reach. Friend requests roll in fast.',
          con: 'Anyone can DM you, including people you don\'t know.',
          selected: _visibility == ProfileVisibility.public,
          onTap: () => setState(() => _visibility = ProfileVisibility.public),
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceCard(
          title: 'Private',
          pro: 'You approve who follows and messages you.',
          con: 'Your circle grows more slowly.',
          selected: _visibility == ProfileVisibility.private,
          onTap: () => setState(() => _visibility = ProfileVisibility.private),
        ),
      ],
    );
  }

  Widget _confirmStep() {
    final photo = _photoChoice == PhotoChoice.avatar
        ? 'Avatar'
        : 'Real photo';
    return _stepScaffold(
      title: 'Looks good?',
      subtitle: 'Here\'s how you\'ll enter Pixelgram.',
      children: [
        _summaryRow('Name', _nameController.text.trim()),
        _summaryRow(
          'Shown as',
          _nameChoice == NameChoice.real ? 'Real name' : 'Nickname',
        ),
        _summaryRow('Picture', photo),
        _summaryRow(
          'Profile',
          _visibility == ProfileVisibility.public ? 'Public' : 'Private',
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.osSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
          const Spacer(),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms);
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _submitting ? null : _back,
              child: const Text('Back'),
            ),
          const Spacer(),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: (_canAdvance && !_submitting) ? _next : null,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(_step == _lastStep ? 'Enter Pixelgram' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
