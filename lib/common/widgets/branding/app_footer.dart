import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../extensions/context_extensions.dart';
import 'app_logo.dart';

/// Slim brand strip shown at the end of page scroll on expanded layouts.
///
/// Returns [SizedBox.shrink] on compact/medium so floating nav stays clear.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  /// Sliver form for [CustomScrollView] pages.
  static Widget sliver(BuildContext context) {
    if (!context.isExpanded) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return const SliverToBoxAdapter(child: AppFooter());
  }

  @override
  Widget build(BuildContext context) {
    if (!context.isExpanded) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                const AppLogo(height: 32, enableHomeNavigation: true),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    'Discover and compare paddles',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
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
