import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/paddle.dart';
import '../../domain/usecases/filter_paddles_usecase.dart';

part 'catalog_controller.g.dart';

@riverpod
class CatalogController extends _$CatalogController {
  @override
  PaddleFilterParams build() => const PaddleFilterParams();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setShape(PaddleShape? shape) {
    if (shape == null) {
      state = state.copyWith(clearShape: true);
    } else {
      state = state.copyWith(shape: shape);
    }
  }

  void setPriceRange(PriceRangeFilter range) {
    state = state.copyWith(priceRange: range);
  }

  void setInStockOnly(bool value) {
    state = state.copyWith(inStockOnly: value);
  }

  void setSort(PaddleSortOption sort) {
    state = state.copyWith(sort: sort);
  }

  void applyFilters({
    PaddleShape? shape,
    required PriceRangeFilter priceRange,
    required bool inStockOnly,
  }) {
    state = state.copyWith(
      shape: shape,
      clearShape: shape == null,
      priceRange: priceRange,
      inStockOnly: inStockOnly,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      clearShape: true,
      priceRange: PriceRangeFilter.all,
      inStockOnly: false,
    );
  }
}
