import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/extensions/context_extensions.dart';

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.label,
    required this.values,
    required this.differs,
    required this.highlightDifferences,
    required this.labelWidth,
    required this.columnWidth,
    this.alternating = false,
    this.isHeader = false,
  });

  final String label;
  final List<String> values;
  final bool differs;
  final bool highlightDifferences;
  final double labelWidth;
  final double columnWidth;
  final bool alternating;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlight = highlightDifferences && differs;
    final background = highlight
        ? context.semanticColors.compareDifference
        : alternating
            ? colors.surfaceContainerHighest.withValues(alpha: 0.25)
            : Colors.transparent;

    final style = isHeader
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;

    return ColoredBox(
      color: background,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: labelWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: style?.copyWith(
                      color: isHeader
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                      fontWeight: isHeader ? FontWeight.w700 : null,
                    ),
                  ),
                ),
              ),
            ),
            for (final value in values)
              SizedBox(
                width: columnWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: style),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
