import 'package:flutter/material.dart';

import '../../../../core/widgets/asset_photo.dart';
import '../../domain/pixelgram_models.dart';

class PixelAvatar extends StatelessWidget {
  const PixelAvatar({super.key, required this.avatar, this.radius = 20, this.ring = false});

  final Avatar avatar;
  final double radius;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;

    Widget inner = _initial(diameter);
    if (avatar.asset != null) {
      inner = ClipOval(
        child: resilientAsset(
          avatar.asset!,
          width: diameter,
          height: diameter,
          fallback: _initial(diameter),
        ),
      );
    }

    if (!ring) return inner;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFA7E1E), Color(0xFFD62976), Color(0xFF962FBF)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF05070C),
        ),
        child: inner,
      ),
    );
  }

  Widget _initial(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatar.color, shape: BoxShape.circle),
      child: Text(
        avatar.initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
