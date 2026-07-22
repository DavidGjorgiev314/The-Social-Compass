import 'package:flutter/material.dart';

/// A photo in the player's phone Gallery.
class GalleryPhoto {
  const GalleryPhoto({
    required this.id,
    required this.label,
    required this.asset,
    required this.gradient,
    this.isPrivate = false,
    this.caption = '',
  });

  final String id;
  final String label;

  /// Image asset. Falls back to [gradient] if the asset is missing.
  final String asset;
  final List<Color> gradient;

  /// Personal / private photo (selfies, photos of you, home). Sharing these
  /// with a stranger carries a cost.
  final bool isPrivate;

  /// Optional caption sent alongside the photo.
  final String caption;
}
