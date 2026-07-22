import 'package:flutter/material.dart';

import '../domain/gallery_photo.dart';

/// The player's camera roll. Personal shots (selfies, home) are flagged
/// [isPrivate] so the story can react to what actually gets shared and with
/// whom.
///
/// Assets reuse existing bundled images so everything renders out of the box;
/// drop dedicated images into assets/images/gallery/ and swap the paths to
/// customise.
List<GalleryPhoto> buildGallery() => const [
      GalleryPhoto(
        id: 'g_selfie',
        label: 'me, today',
        asset: 'assets/images/avatars/maya.jpg',
        gradient: [Color(0xFFFF9A8B), Color(0xFFFF6B9A)],
        isPrivate: true,
        caption: 'me 🙂',
      ),
      GalleryPhoto(
        id: 'g_home',
        label: 'back home w/ Kai',
        asset: 'assets/images/avatars/kai.jpg',
        gradient: [Color(0xFF9B8CFF), Color(0xFF6C5CE7)],
        isPrivate: true,
        caption: 'me and my best friend 💛',
      ),
      GalleryPhoto(
        id: 'g_sketch',
        label: 'my sketchbook',
        asset: 'assets/images/feed/feed_nadia.jpg',
        gradient: [Color(0xFF43E0B8), Color(0xFF8E7BFF)],
        caption: 'been drawing again 🎨',
      ),
      GalleryPhoto(
        id: 'g_coffee',
        label: 'campus coffee',
        asset: 'assets/images/feed/feed_ava.jpg',
        gradient: [Color(0xFFFFD36E), Color(0xFFFF9F45)],
        caption: 'best latte on campus ☕',
      ),
      GalleryPhoto(
        id: 'g_skate',
        label: 'sunset by the library',
        asset: 'assets/images/feed/feed_leo.jpg',
        gradient: [Color(0xFF5AC8FA), Color(0xFF3E7BFA)],
        caption: 'this view though',
      ),
      GalleryPhoto(
        id: 'g_notes',
        label: 'econ notes',
        asset: 'assets/images/feed/feed_campus.jpg',
        gradient: [Color(0xFF2C9C8A), Color(0xFF1F6E8C)],
        caption: 'notes from today',
      ),
    ];
