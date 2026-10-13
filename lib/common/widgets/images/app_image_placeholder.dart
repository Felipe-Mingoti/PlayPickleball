import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({super.key, this.label = 'Image unavailable'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_tennis,
                size: 36,
                color: colors.onSurfaceVariant,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
