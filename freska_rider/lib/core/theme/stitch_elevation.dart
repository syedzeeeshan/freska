import 'package:flutter/material.dart';

class StitchElevation {
  static const List<BoxShadow> level0 = [];

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x24000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x30000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  static const List<BoxShadow> emeraldGlow = [
    BoxShadow(
      color: Color(0x40059669),
      offset: Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 2,
    ),
  ];
}
