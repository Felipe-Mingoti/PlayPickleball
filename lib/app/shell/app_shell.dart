import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/layouts/responsive_layout.dart';
import '../../common/widgets/branding/app_logo.dart';
import '../../features/paddles/domain/value_objects/comparison_selection.dart';
import '../../features/paddles/view/providers/comparison_providers.dart';
import '../../features/paddles/view/widgets/compare_selection_bar.dart';
import '../router/route_paths.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_mode_controller.dart';

/// Vertical space taken by the floating nav chrome, excluding device safe area.
const double _kFloatingNavClearance = 88;

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = selectionFromContext(context);
    final location = GoRouterState.of(context).uri.path;
    final themeMode = ref.watch(themeModeControllerProvider);
    final platformBright = MediaQuery.platformBrightnessOf(context);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBright == Brightness.dark);
    final isExpanded =
        ResponsiveLayout.breakpointOf(context) == AppBreakpoint.expanded;
    final showFloatingNav = !isExpanded;
    final catalogSelected =
        location.startsWith(RoutePaths.paddles) &&
        !location.contains('/compare');
    final compareSelected = location.startsWith(RoutePaths.compare);

    final media = MediaQuery.of(context);
    final body = showFloatingNav
        ? MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                bottom: media.padding.bottom + _kFloatingNavClearance,
              ),
            ),
            child: child,
          )
        : child;

    return Scaffold(
      extendBody: showFloatingNav,
      appBar: AppBar(
        title: const AppLogo(height: 28, enableHomeNavigation: true),
        actions: [
          if (isExpanded) ...[
            _NavButton(
              label: 'Catalog',
              selected: catalogSelected,
              onPressed: () => context.router.goCatalog(selection: selection),
            ),
            _NavButton(
              label: selection.isEmpty
                  ? 'Compare'
                  : 'Compare (${selection.count})',
              selected: compareSelected,
              onPressed: () => context.router.goCompare(selection: selection),
            ),
          ],
          IconButton(
            tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
            onPressed: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .toggle(platformBright);
            },
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      bottomNavigationBar: _ShellBottomChrome(
        selection: selection,
        showFloatingNav: showFloatingNav,
        catalogSelected: catalogSelected,
        compareSelected: compareSelected,
        onCatalog: () => context.router.goCatalog(selection: selection),
        onCompare: () => context.router.goCompare(selection: selection),
      ),
    );
  }
}

class _ShellBottomChrome extends StatelessWidget {
  const _ShellBottomChrome({
    required this.selection,
    required this.showFloatingNav,
    required this.catalogSelected,
    required this.compareSelected,
    required this.onCatalog,
    required this.onCompare,
  });

  final ComparisonSelection selection;
  final bool showFloatingNav;
  final bool catalogSelected;
  final bool compareSelected;
  final VoidCallback onCatalog;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selection.isNotEmpty;
    if (!hasSelection && !showFloatingNav) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSelection)
          CompareSelectionBar(
            selection: selection,
            applyBottomSafeArea: !showFloatingNav,
          ),
        if (showFloatingNav)
          _FloatingNavBar(
            selection: selection,
            catalogSelected: catalogSelected,
            compareSelected: compareSelected,
            onCatalog: onCatalog,
            onCompare: onCompare,
          ),
      ],
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selection,
    required this.catalogSelected,
    required this.compareSelected,
    required this.onCatalog,
    required this.onCompare,
  });

  final ComparisonSelection selection;
  final bool catalogSelected;
  final bool compareSelected;
  final VoidCallback onCatalog;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Material(
          elevation: 0,
          color: colors.surface.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: colors.outline.withValues(alpha: 0.45)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FloatingNavItem(
                    icon: Icons.grid_view_outlined,
                    label: 'Catalog',
                    selected: catalogSelected,
                    onPressed: onCatalog,
                  ),
                ),
                Expanded(
                  child: _FloatingNavItem(
                    icon: Icons.compare_arrows,
                    label: selection.isEmpty
                        ? 'Compare'
                        : 'Compare (${selection.count})',
                    selected: compareSelected,
                    onPressed: onCompare,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.primary : colors.onSurfaceVariant;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected ? colors.primary : colors.onSurface,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
