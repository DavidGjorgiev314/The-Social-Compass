import 'package:flutter/material.dart';

import 'asset_photo.dart';

class RoundPhoto extends StatelessWidget {
  const RoundPhoto({
    super.key,
    required this.asset,
    required this.color,
    required this.initial,
    this.radius = 16,
  });

  final String? asset;
  final Color color;
  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    if (asset != null) {
      return ClipOval(
        child: resilientAsset(
          asset!,
          width: diameter,
          height: diameter,
          fallback: _initial(diameter),
        ),
      );
    }
    return _initial(diameter);
  }

  Widget _initial(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
