import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/usecases/filter_paddles_usecase.dart';
import '../controllers/catalog_controller.dart';
import 'catalog_filter_options.dart';
import 'catalog_sort_menu.dart';

class CatalogFilterBar extends ConsumerStatefulWidget {
  const CatalogFilterBar({super.key});

  @override
  ConsumerState<CatalogFilterBar> createState() => _CatalogFilterBarState();
}

class _CatalogFilterBarState extends ConsumerState<CatalogFilterBar> {
  CatalogFilterKind? _open;

  void _toggle(CatalogFilterKind kind) {
    setState(() => _open = _open == kind ? null : kind);
  }

  void _selectShape(PaddleShape? shape) {
    final current = ref.read(catalogControllerProvider);
    final next = current.shape == shape ? null : shape;
    ref
        .read(catalogControllerProvider.notifier)
        .applyFilters(
          shape: next,
          priceRange: current.priceRange,
          inStockOnly: current.inStockOnly,
        );
  }

  void _selectPrice(PriceRangeFilter range) {
    final current = ref.read(catalogControllerProvider);
    final next = current.priceRange == range ? PriceRangeFilter.all : range;
    ref
        .read(catalogControllerProvider.notifier)
        .applyFilters(
          shape: current.shape,
          priceRange: next,
          inStockOnly: current.inStockOnly,
        );
  }

  void _selectInStock(bool value) {
    final current = ref.read(catalogControllerProvider);
    ref
        .read(catalogControllerProvider.notifier)
        .applyFilters(
          shape: current.shape,
          priceRange: current.priceRange,
          inStockOnly: value,
        );
  }

  void _clear() {
    ref.read(catalogControllerProvider.notifier).clearFilters();
    setState(() => _open = null);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(catalogControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return TapRegion(
      onTapOutside: (_) {
        if (_open == null) return;
        setState(() => _open = null);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _FilterCard(
                      label: shapeFilterCardLabel(filters.shape),
                      selected: filters.shape != null,
                      expanded: _open == CatalogFilterKind.shape,
                      onTap: () => _toggle(CatalogFilterKind.shape),
                    ),
                    _FilterCard(
                      label: priceFilterCardLabel(filters.priceRange),
                      selected: filters.priceRange != PriceRangeFilter.all,
                      expanded: _open == CatalogFilterKind.price,
                      onTap: () => _toggle(CatalogFilterKind.price),
                    ),
                    _FilterCard(
                      label: 'In stock only',
                      selected: filters.inStockOnly,
                      expanded: _open == CatalogFilterKind.inStock,
                      onTap: () => _toggle(CatalogFilterKind.inStock),
                    ),
                    if (filters.hasActiveFilters)
                      _FilterCard(
                        label: 'Clear filters',
                        icon: Icons.close,
                        onTap: _clear,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const CatalogSortMenu(),
            ],
          ),
          if (_open != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: colors.surface,
              elevation: 3,
              shadowColor: colors.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: _openPanel(filters),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _openPanel(PaddleFilterParams filters) {
    return switch (_open) {
      CatalogFilterKind.shape => CatalogFilterSection(
        title: 'Shape',
        children: shapeFilterTiles(
          selected: filters.shape,
          onSelected: _selectShape,
        ),
      ),
      CatalogFilterKind.price => CatalogFilterSection(
        title: 'Price',
        children: priceFilterTiles(
          selected: filters.priceRange,
          onSelected: _selectPrice,
        ),
      ),
      CatalogFilterKind.inStock => CatalogFilterSection(
        title: 'In stock only',
        children: [
          CatalogFilterOptionTile(
            label: 'In stock only',
            selected: filters.inStockOnly,
            onSelected: () => _selectInStock(!filters.inStockOnly),
          ),
        ],
      ),
      null => const SizedBox.shrink(),
    };
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.expanded = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantics = Theme.of(context).extension<AppSemanticColors>();
    final foreground = selected ? colors.primary : colors.onSurface;
    return Material(
      color: selected
          ? (semantics?.filterSelected ?? colors.primary.withValues(alpha: 0.08))
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: foreground),
              ),
              if (icon == null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: foreground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
