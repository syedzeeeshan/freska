import 'package:flutter/animation.dart';

/// Freska Design System — Motion & Timing Curves
class FreskaMotion {
  FreskaMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration deliberate = Duration(milliseconds: 450);

  static const Curve standardCurve = Curves.easeInOutCubicEmphasized;
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}
