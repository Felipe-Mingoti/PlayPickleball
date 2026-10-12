import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/filter_paddles_usecase.dart';
import '../controllers/catalog_controller.dart';

class CatalogSortMenu extends ConsumerWidget {
  const CatalogSortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(catalogControllerProvider).sort;
    return DropdownButtonHideUnderline(
      child: DropdownButton<PaddleSortOption>(
        value: sort,
        onChanged: (value) {
          if (value == null) return;
          ref.read(catalogControllerProvider.notifier).setSort(value);
        },
        items: const [
          DropdownMenuItem(
            value: PaddleSortOption.nameAsc,
            child: Text('Sort: Name'),
          ),
          DropdownMenuItem(
            value: PaddleSortOption.priceAsc,
            child: Text('Sort: Price ↑'),
          ),
          DropdownMenuItem(
            value: PaddleSortOption.priceDesc,
            child: Text('Sort: Price ↓'),
          ),
          DropdownMenuItem(
            value: PaddleSortOption.controlDesc,
            child: Text('Sort: Control'),
          ),
        ],
      ),
    );
  }
}
