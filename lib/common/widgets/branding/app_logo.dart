import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../features/paddles/view/providers/comparison_providers.dart';

/// Horizontal Play Pickleball wordmark.
///
/// The asset uses a dark charcoal wordmark, so dark theme wraps it in a light
/// pill for contrast without purple-washing the chrome.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 28,
    this.onTap,
    this.enableHomeNavigation = false,
  });

  final double height;
  final VoidCallback? onTap;
  final bool enableHomeNavigation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = Image.asset(
      AssetPaths.brandLogoHorizontal,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Play Pickleball',
    );

    final framed = isDark
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(height * 0.35),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: height * 0.45,
                vertical: height * 0.22,
              ),
              child: logo,
            ),
          )
        : logo;

    final handleTap = onTap ??
        (enableHomeNavigation
            ? () {
                final router = GoRouter.of(context);
                router.goCatalog(selection: router.readSelection());
              }
            : null);

    if (handleTap == null) return framed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: handleTap,
        behavior: HitTestBehavior.opaque,
        child: framed,
      ),
    );
  }
}
