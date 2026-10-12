import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightInk,
      onSurfaceVariant: AppColors.lightSecondaryText,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      outline: AppColors.lightOutline,
      error: AppColors.lightError,
      onError: Colors.white,
    );

    return _build(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      ink: AppColors.lightInk,
      surface: AppColors.lightSurface,
      outline: AppColors.lightOutline,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      filterSelected: AppColors.lightFilterSelected,
      semantics: const AppSemanticColors(
        compareAdded: AppColors.lightCompareAdded,
        compareDifference: AppColors.lightCompareDifference,
        priceBadge: AppColors.lightPriceBadge,
        specHighlight: AppColors.lightSpecHighlight,
        filterSelected: AppColors.lightFilterSelected,
        surfaceVariant: AppColors.lightSurfaceVariant,
        link: AppColors.lightLink,
        success: AppColors.lightSuccess,
        warning: AppColors.lightWarning,
        secondaryText: AppColors.lightSecondaryText,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkInk,
      onSurfaceVariant: AppColors.darkMuted,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline: AppColors.darkOutline,
      error: AppColors.darkError,
      onError: AppColors.darkOnPrimary,
    );

    return _build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      ink: AppColors.darkInk,
      surface: AppColors.darkSurface,
      outline: AppColors.darkOutline,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      filterSelected: AppColors.darkFilterSelected,
      semantics: const AppSemanticColors(
        compareAdded: AppColors.darkCompareAdded,
        compareDifference: AppColors.darkCompareDifference,
        priceBadge: AppColors.darkPriceBadge,
        specHighlight: AppColors.darkSpecHighlight,
        filterSelected: AppColors.darkFilterSelected,
        surfaceVariant: AppColors.darkSurfaceVariant,
        link: AppColors.darkLink,
        success: AppColors.darkSuccess,
        warning: AppColors.darkWarning,
        secondaryText: AppColors.darkMuted,
      ),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color ink,
    required Color surface,
    required Color outline,
    required Color primary,
    required Color onPrimary,
    required Color filterSelected,
    required AppSemanticColors semantics,
  }) {
    final shape12 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final shape16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: AppTypography.textTheme(ink),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: filterSelected,
        side: BorderSide(color: outline),
        labelStyle: TextStyle(color: ink),
        secondaryLabelStyle: TextStyle(color: primary),
        checkmarkColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: outline.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: shape12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: outline.withValues(alpha: 0.5),
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          shape: shape12,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.55)),
          shape: shape12,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: filterSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: shape16,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightInk,
        contentTextStyle: TextStyle(
          color: brightness == Brightness.dark
              ? AppColors.darkInk
              : AppColors.lightSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: shape12,
      ),
      dividerTheme: DividerThemeData(color: outline),
      extensions: [semantics],
    );
  }
}

/// Semantic brand colors that are not (or not fully) covered by [ColorScheme].
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.compareAdded,
    required this.compareDifference,
    required this.priceBadge,
    required this.specHighlight,
    required this.filterSelected,
    required this.surfaceVariant,
    required this.link,
    required this.success,
    required this.warning,
    required this.secondaryText,
  });

  final Color compareAdded;
  final Color compareDifference;
  final Color priceBadge;
  final Color specHighlight;
  final Color filterSelected;
  final Color surfaceVariant;
  final Color link;
  final Color success;
  final Color warning;
  final Color secondaryText;

  /// Back-compat alias used by comparison difference highlighting.
  Color get difference => compareDifference;

  @override
  AppSemanticColors copyWith({
    Color? compareAdded,
    Color? compareDifference,
    Color? priceBadge,
    Color? specHighlight,
    Color? filterSelected,
    Color? surfaceVariant,
    Color? link,
    Color? success,
    Color? warning,
    Color? secondaryText,
  }) {
    return AppSemanticColors(
      compareAdded: compareAdded ?? this.compareAdded,
      compareDifference: compareDifference ?? this.compareDifference,
      priceBadge: priceBadge ?? this.priceBadge,
      specHighlight: specHighlight ?? this.specHighlight,
      filterSelected: filterSelected ?? this.filterSelected,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      link: link ?? this.link,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      secondaryText: secondaryText ?? this.secondaryText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      compareAdded: Color.lerp(compareAdded, other.compareAdded, t)!,
      compareDifference:
          Color.lerp(compareDifference, other.compareDifference, t)!,
      priceBadge: Color.lerp(priceBadge, other.priceBadge, t)!,
      specHighlight: Color.lerp(specHighlight, other.specHighlight, t)!,
      filterSelected: Color.lerp(filterSelected, other.filterSelected, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      link: Color.lerp(link, other.link, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
    );
  }
}
