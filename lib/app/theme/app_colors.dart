import 'package:flutter/material.dart';

/// Brand color tokens for light and dark themes.
abstract final class AppColors {
  // --- Light ---
  static const Color lightBackground = Color(0xFFF5F5FE);
  static const Color lightInk = Color(0xFF37363C);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF6B46E6);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF9772EB);
  static const Color lightOnSecondary = Color(0xFF1F1248);
  static const Color lightMuted = Color(0xFF7F7E86);
  static const Color lightSecondaryText = Color(0xFF5F5C69);
  static const Color lightOutline = Color(0xFFDCD9F1);
  static const Color lightHighlight = Color(0x1F6B46E6);
  static const Color lightSurfaceVariant = Color(0xFFF0EEFB);
  static const Color lightLink = Color(0xFF6B46E6);
  static const Color lightSuccess = Color(0xFF247A57);
  static const Color lightWarning = Color(0xFFB46A1F);
  static const Color lightError = Color(0xFFB3261E);

  static const Color lightCompareAdded = Color(0xFF6B46E6);
  static const Color lightCompareDifference = Color(0xFFD9CCFB);
  static const Color lightPriceBadge = Color(0xFFF0EEFB);
  static const Color lightSpecHighlight = Color(0x149772EB);
  static const Color lightFilterSelected = Color(0xFFECE5FF);

  // --- Dark ---
  static const Color darkBackground = Color(0xFF12111A);
  static const Color darkInk = Color(0xFFF4F2FF);
  static const Color darkSurface = Color(0xFF1B1926);
  static const Color darkPrimary = Color(0xFF9C84F4);
  static const Color darkOnPrimary = Color(0xFF1F1248);
  static const Color darkSecondary = Color(0xFFC2B0FF);
  static const Color darkOnSecondary = Color(0xFF25174D);
  static const Color darkMuted = Color(0xFFB6B1C7);
  static const Color darkOutline = Color(0xFF3A3650);
  static const Color darkHighlight = Color(0x339C84F4);
  static const Color darkSurfaceVariant = Color(0xFF262235);
  static const Color darkLink = Color(0xFFB9A7FF);
  static const Color darkSuccess = Color(0xFF6FD1A3);
  static const Color darkWarning = Color(0xFFFFBC70);
  static const Color darkError = Color(0xFFFF8A80);

  static const Color darkCompareAdded = Color(0xFF9C84F4);
  static const Color darkCompareDifference = Color(0x339C84F4);
  static const Color darkPriceBadge = Color(0xFF322651);
  static const Color darkSpecHighlight = Color(0x263A2D68);
  static const Color darkFilterSelected = Color(0xFF322651);
}
