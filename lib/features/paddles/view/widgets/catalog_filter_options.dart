import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/usecases/filter_paddles_usecase.dart';

const catalogFilterShapes = <PaddleShape>[
  PaddleShape.standard,
  PaddleShape.elongated,
  PaddleShape.hybrid,
  PaddleShape.widebody,
];

enum CatalogFilterKind { shape, price, inStock }

String priceRangeLabel(PriceRangeFilter range) {
  return switch (range) {
    PriceRangeFilter.all => 'All',
    PriceRangeFilter.under100 => r'Under $100',
    PriceRangeFilter.between100And175 => r'$100–$175',
    PriceRangeFilter.over175 => r'$175+',
  };
}

String shapeFilterCardLabel(PaddleShape? shape) {
  if (shape == null) return 'Shape';
  return 'Shape · ${shape.label}';
}

String priceFilterCardLabel(PriceRangeFilter range) {
  if (range == PriceRangeFilter.all) return 'Price';
  return 'Price · ${priceRangeLabel(range)}';
}

class CatalogFilterOptionTile extends StatelessWidget {
  const CatalogFilterOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              IgnorePointer(
                child: Checkbox(value: selected, onChanged: (_) {}),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected ? colors.primary : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogFilterSection extends StatelessWidget {
  const CatalogFilterSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        ...children,
      ],
    );
  }
}

List<Widget> shapeFilterTiles({
  required PaddleShape? selected,
  required ValueChanged<PaddleShape?> onSelected,
}) {
  return [
    CatalogFilterOptionTile(
      label: 'All',
      selected: selected == null,
      onSelected: () => onSelected(null),
    ),
    for (final shape in catalogFilterShapes)
      CatalogFilterOptionTile(
        label: shape.label,
        selected: selected == shape,
        onSelected: () => onSelected(shape),
      ),
  ];
}

List<Widget> priceFilterTiles({
  required PriceRangeFilter selected,
  required ValueChanged<PriceRangeFilter> onSelected,
}) {
  return [
    for (final range in PriceRangeFilter.values)
      CatalogFilterOptionTile(
        label: priceRangeLabel(range),
        selected: selected == range,
        onSelected: () => onSelected(range),
      ),
  ];
}
