import 'package:flutter/material.dart';

import '../../domain/pixelgram_models.dart';

class PixelAvatar extends StatelessWidget {
  const PixelAvatar({super.key, required this.avatar, this.radius = 20, this.ring = false});

  final Avatar avatar;
  final double radius;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final inner = CircleAvatar(
      radius: radius,
      backgroundColor: avatar.color,
      backgroundImage: avatar.asset != null ? AssetImage(avatar.asset!) : null,
      child: avatar.asset == null
          ? Text(
              avatar.initial,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );

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
}
