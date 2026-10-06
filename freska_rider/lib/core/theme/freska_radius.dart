import 'package:flutter/material.dart';

/// Freska Design System — Corner Radius Tokens
///
/// Restrained, functional radii avoiding oversized bubbly corners.
class FreskaRadius {
  FreskaRadius._();

  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 18.0;
  static const double pill = 999.0;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
}
