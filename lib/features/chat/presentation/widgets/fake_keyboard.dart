import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FakeKeyboard extends StatelessWidget {
  const FakeKeyboard({super.key});

  static const _row1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _row2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  static const _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.osSurface,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _KeyRowWidget(
              children: [for (final k in _row1) _LetterKey(k)],
            ),
            const SizedBox(height: 8),
            _KeyRowWidget(
              children: [
                const Spacer(flex: 1),
                for (final k in _row2) _LetterKey(k),
                const Spacer(flex: 1),
              ],
            ),
            const SizedBox(height: 8),
            _KeyRowWidget(
              children: [
                const _SpecialKey(icon: Icons.keyboard_capslock_rounded, flex: 3),
                for (final k in _row3) _LetterKey(k),
                const _SpecialKey(icon: Icons.backspace_outlined, flex: 3),
              ],
            ),
            const SizedBox(height: 8),
            _KeyRowWidget(
              children: const [
                _SpecialKey(label: '123', flex: 4),
                _LetterKey(','),
                _SpecialKey(label: 'space', flex: 12),
                _LetterKey('.'),
                _SpecialKey(label: 'return', flex: 4, accent: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyRowWidget extends StatelessWidget {
  const _KeyRowWidget({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 42, child: Row(children: children));
  }
}

class _LetterKey extends StatelessWidget {
  const _LetterKey(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.osSurfaceHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SpecialKey extends StatelessWidget {
  const _SpecialKey({this.label, this.icon, required this.flex, this.accent = false});

  final String? label;
  final IconData? icon;
  final int flex;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent ? AppColors.accent : AppColors.osSurfaceRaised,
          borderRadius: BorderRadius.circular(6),
        ),
        child: icon != null
            ? Icon(icon, size: 19, color: AppColors.textPrimary)
            : Text(
                label ?? '',
                style: TextStyle(
                  color: accent ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
