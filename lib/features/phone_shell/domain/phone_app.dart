import 'package:flutter/material.dart';

class PhoneApp {
  const PhoneApp({
    required this.id,
    required this.label,
    required this.icon,
    required this.gradient,
    this.badgeCount = 0,
    this.enabled = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final int badgeCount;
  final bool enabled;

  PhoneApp copyWith({int? badgeCount, bool? enabled}) {
    return PhoneApp(
      id: id,
      label: label,
      icon: icon,
      gradient: gradient,
      badgeCount: badgeCount ?? this.badgeCount,
      enabled: enabled ?? this.enabled,
    );
  }
}

class PhoneApps {
  PhoneApps._();

  static const String pixelgram = 'pixelgram';
  static const String settings = 'settings';
  static const String camera = 'camera';
  static const String photos = 'photos';
  static const String clock = 'clock';
  static const String notes = 'notes';
}
