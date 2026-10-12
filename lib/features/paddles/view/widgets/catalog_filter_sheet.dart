import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../domain/entities/paddle.dart';
import '../../domain/usecases/filter_paddles_usecase.dart';
import '../controllers/catalog_controller.dart';
import 'catalog_filter_options.dart';

Future<void> showCatalogFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => const CatalogFilterSheet(),
  );
}

class CatalogFilterMenuButton extends StatelessWidget {
  const CatalogFilterMenuButton({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AspectRatio(
      aspectRatio: 1,
      child: IconButton(
        tooltip: 'Filters',
        onPressed: onPressed,
        icon: Icon(Icons.menu, color: primary),
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
          foregroundColor: primary,
          backgroundColor: primary.withValues(alpha: selected ? 0.16 : 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primary),
          ),
        ),
      ),
    );
  }
}

class CatalogFilterSheet extends ConsumerStatefulWidget {
  const CatalogFilterSheet({super.key});

  @override
  ConsumerState<CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends ConsumerState<CatalogFilterSheet> {
  late PaddleShape? _shape;
  late PriceRangeFilter _priceRange;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(catalogControllerProvider);
    _shape = filters.shape;
    _priceRange = filters.priceRange;
    _inStockOnly = filters.inStockOnly;
  }

  void _selectShape(PaddleShape? shape) {
    setState(() => _shape = _shape == shape ? null : shape);
  }

  void _selectPrice(PriceRangeFilter range) {
    setState(() {
      _priceRange = _priceRange == range ? PriceRangeFilter.all : range;
    });
  }

  void _save() {
    ref
        .read(catalogControllerProvider.notifier)
        .applyFilters(
          shape: _shape,
          priceRange: _priceRange,
          inStockOnly: _inStockOnly,
        );
    Navigator.of(context).pop();
  }

  void _clear() {
    ref.read(catalogControllerProvider.notifier).clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final applied = ref.watch(catalogControllerProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            CatalogFilterSection(
              title: 'Shape',
              children: shapeFilterTiles(
                selected: _shape,
                onSelected: _selectShape,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CatalogFilterSection(
              title: 'Price',
              children: priceFilterTiles(
                selected: _priceRange,
                onSelected: _selectPrice,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CatalogFilterOptionTile(
              label: 'In stock only',
              selected: _inStockOnly,
              onSelected: () => setState(() => _inStockOnly = !_inStockOnly),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Save filters', expanded: true, onPressed: _save),
            if (applied.hasActiveFilters) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Clear filters',
                variant: AppButtonVariant.secondary,
                expanded: true,
                onPressed: _clear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
