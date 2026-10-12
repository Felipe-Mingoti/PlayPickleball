import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../layouts/responsive_layout.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppSemanticColors get semanticColors =>
      theme.extension<AppSemanticColors>() ??
      const AppSemanticColors(
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
      );

  /// Alias for difference highlighting (compare table).
  AppSemanticColors get highlightColors => semanticColors;

  bool get isCompact =>
      MediaQuery.sizeOf(this).width < ResponsiveBreakpoints.medium;

  bool get isExpanded =>
      MediaQuery.sizeOf(this).width >= ResponsiveBreakpoints.expanded;

  EdgeInsets get pagePadding {
    final bottomInset = MediaQuery.paddingOf(this).bottom;
    return EdgeInsets.fromLTRB(
      isCompact ? AppSpacing.lg : AppSpacing.xl,
      AppSpacing.lg,
      isCompact ? AppSpacing.lg : AppSpacing.xl,
      AppSpacing.lg + bottomInset,
    );
  }
}
