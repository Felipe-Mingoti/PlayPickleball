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
    this.isHeader = false,
    this.pinned = false,
    this.onPinToggle,
  });

  final String label;
  final List<String> values;
  final bool differs;
  final bool highlightDifferences;
  final double labelWidth;
  final double columnWidth;
  final bool isHeader;
  final bool pinned;
  final VoidCallback? onPinToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlight = highlightDifferences && differs;
    final background = highlight
        ? context.semanticColors.compareDifference
        : context.semanticColors.surfaceVariant;

    final style = isHeader
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;

    final labelStyle = style?.copyWith(
      color: isHeader ? colors.onSurface : colors.onSurfaceVariant,
      fontWeight: isHeader ? FontWeight.w700 : null,
    );

    final row = ColoredBox(
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
                  child: onPinToggle == null
                      ? Text(label, style: labelStyle)
                      : Row(
                          children: [
                            Icon(
                              pinned ? Icons.push_pin : Icons.push_pin_outlined,
                              size: 18,
                              color: pinned
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(child: Text(label, style: labelStyle)),
                          ],
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

    if (onPinToggle == null) return row;

    return Semantics(
      button: true,
      label: pinned ? 'Unpin $label' : 'Pin $label',
      child: InkWell(
        onTap: onPinToggle,
        child: ExcludeSemantics(child: row),
      ),
    );
  }
}
