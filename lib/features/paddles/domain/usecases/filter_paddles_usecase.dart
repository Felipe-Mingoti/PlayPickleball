import '../entities/paddle.dart';

enum PaddleSortOption { nameAsc, priceAsc, priceDesc, controlDesc }

enum PriceRangeFilter { all, under100, between100And175, over175 }

class PaddleFilterParams {
  const PaddleFilterParams({
    this.query = '',
    this.shape,
    this.priceRange = PriceRangeFilter.all,
    this.inStockOnly = false,
    this.sort = PaddleSortOption.nameAsc,
  });

  final String query;
  final PaddleShape? shape;
  final PriceRangeFilter priceRange;
  final bool inStockOnly;
  final PaddleSortOption sort;

  bool get hasActiveFilters =>
      shape != null || priceRange != PriceRangeFilter.all || inStockOnly;

  PaddleFilterParams copyWith({
    String? query,
    PaddleShape? shape,
    bool clearShape = false,
    PriceRangeFilter? priceRange,
    bool? inStockOnly,
    PaddleSortOption? sort,
  }) {
    return PaddleFilterParams(
      query: query ?? this.query,
      shape: clearShape ? null : (shape ?? this.shape),
      priceRange: priceRange ?? this.priceRange,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sort: sort ?? this.sort,
    );
  }
}

class FilterPaddlesUseCase {
  const FilterPaddlesUseCase();

  List<Paddle> call({
    required List<Paddle> paddles,
    required PaddleFilterParams params,
  }) {
    final query = params.query.trim().toLowerCase();
    final filtered = paddles.where((paddle) {
      if (query.isNotEmpty) {
        final haystack = '${paddle.brand} ${paddle.name}'.toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      if (params.shape != null && paddle.shape != params.shape) {
        return false;
      }
      if (params.inStockOnly && !paddle.inStock) return false;
      if (!_matchesPriceRange(paddle.priceUsd, params.priceRange)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (params.sort) {
        case PaddleSortOption.nameAsc:
          final byBrand = a.brand.compareTo(b.brand);
          if (byBrand != 0) return byBrand;
          return a.name.compareTo(b.name);
        case PaddleSortOption.priceAsc:
          return _compareNullablePrice(a.priceUsd, b.priceUsd, ascending: true);
        case PaddleSortOption.priceDesc:
          return _compareNullablePrice(
            a.priceUsd,
            b.priceUsd,
            ascending: false,
          );
        case PaddleSortOption.controlDesc:
          final byControl = b.ratings.control.compareTo(a.ratings.control);
          if (byControl != 0) return byControl;
          return a.id.compareTo(b.id);
      }
    });

    return filtered;
  }

  bool _matchesPriceRange(double? price, PriceRangeFilter range) {
    if (range == PriceRangeFilter.all) return true;
    if (price == null) return false;
    return switch (range) {
      PriceRangeFilter.all => true,
      PriceRangeFilter.under100 => price < 100,
      PriceRangeFilter.between100And175 => price >= 100 && price <= 175,
      PriceRangeFilter.over175 => price > 175,
    };
  }

  int _compareNullablePrice(double? a, double? b, {required bool ascending}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }
}
