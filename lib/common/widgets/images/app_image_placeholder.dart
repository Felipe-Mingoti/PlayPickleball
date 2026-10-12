import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    this.label = 'Image unavailable',
    this.aspectRatio = 3 / 4,
  });

  final String label;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_tennis,
                  size: 36,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
