import 'package:flutter/services.dart';

class Haptics {
  Haptics._();

  static void tap() => HapticFeedback.selectionClick();

  static void light() => HapticFeedback.lightImpact();

  static void medium() => HapticFeedback.mediumImpact();

  static void heavy() => HapticFeedback.heavyImpact();

  static void success() => HapticFeedback.lightImpact();

  static void warning() => HapticFeedback.vibrate();
}
