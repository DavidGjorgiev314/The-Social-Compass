import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration appLaunch = Duration(milliseconds: 460);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve spring = Curves.elasticOut;
}
