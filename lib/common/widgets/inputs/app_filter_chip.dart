import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: true,
      selectedColor: semantics.filterSelected,
      checkmarkColor: colors.primary,
      side: BorderSide(
        color: selected ? colors.primary.withValues(alpha: 0.45) : colors.outline,
      ),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? colors.primary : colors.onSurface,
          ),
    );
  }
}
