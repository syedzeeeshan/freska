import 'package:flutter/material.dart';

/// Freska Design System — Elevation & Shadows
class FreskaElevation {
  FreskaElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x22000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x44000000),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glowEmerald = [
    BoxShadow(
      color: Color(0x3300C853),
      offset: Offset(0, 2),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> glowAmber = [
    BoxShadow(
      color: Color(0x33FF6D00),
      offset: Offset(0, 2),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];
}
