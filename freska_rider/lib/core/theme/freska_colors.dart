import 'package:flutter/material.dart';

/// FRESKA TACTILE SYSTEM — MASTER RIDER PALETTE
class FreskaColors {
  FreskaColors._();

  // Core Brand Hues
  static const Color brandPrimary = Color(0xFFE87532); // Warm Freska Orange
  static const Color brandSecondary = Color(0xFF4FAF7B); // Fresh Green
  static const Color brandAccent = Color(0xFF5D93B8); // Navigation Blue
  static const Color brandColdChain = Color(0xFF66B8C9); // Cold-Chain Cyan

  // Foundation Surfaces
  static const Color bgDarkest = Color(0xFF111315); // Obsidian Canvas
  static const Color bgSurface = Color(0xFF22272D); // Tactile Slate Card
  static const Color bgElevated = Color(0xFF2A3036); // Raised Action Tile
  static const Color bgSubtle = Color(0xFF343A40); // 1px Subtle Border
  static const Color bgInset = Color(0xFF0D0F11); // Inset Surface

  // Light Mode Fallback
  static const Color bgLight = Color(0xFFF7F9FA);
  static const Color bgLightSurface = Color(0xFFFFFFFF);
  static const Color bgLightElevated = Color(0xFFEEF2F6);

  // Status & Telemetry
  static const Color statusOnline = Color(0xFF4FAF7B); // Fresh Green Online
  static const Color statusOffline = Color(0xFF7F858A); // Muted Offline
  static const Color statusBusy = Color(0xFFD99A3D); // Amber Busy
  static const Color statusError = Color(0xFFD85C5C); // Emergency / Error
  static const Color statusWarning = Color(0xFFD99A3D);
  static const Color statusInfo = Color(0xFF5D93B8);

  // Typography
  static const Color textPrimary = Color(0xFFF4F1EA);
  static const Color textSecondary = Color(0xFFB8B7B2);
  static const Color textMuted = Color(0xFF7F858A);
  static const Color textInverse = Color(0xFF111315);

  // Role Theme Color Accents
  static const Color customerAccent = Color(0xFFE87532);
  static const Color customerSecondary = Color(0xFF4FAF7B);
  static const Color vendorAccent = Color(0xFFE87532);
  static const Color vendorSecondary = Color(0xFF4FAF7B);
  static const Color riderAccent = Color(0xFFE87532);
  static const Color riderSecondary = Color(0xFF4FAF7B);
}
