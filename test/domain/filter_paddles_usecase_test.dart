import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/domain/entities/paddle.dart';
import 'package:play_pickleball/features/paddles/domain/usecases/filter_paddles_usecase.dart';

import '../helpers/paddle_fixtures.dart';

void main() {
  const useCase = FilterPaddlesUseCase();
  final paddles = [
    makePaddle(
      id: 'a',
      brand: 'Apex Court',
      name: 'Summit',
      priceUsd: 249.99,
      shape: PaddleShape.elongated,
      control: 8,
    ),
    makePaddle(
      id: 'b',
      brand: 'Dinkworks',
      name: 'Soft Touch',
      priceUsd: 89.99,
      shape: PaddleShape.standard,
      control: 9,
      inStock: false,
    ),
    makePaddle(
      id: 'c',
      brand: 'Apex Court',
      name: 'Basecamp',
      priceUsd: null,
      shape: PaddleShape.standard,
      control: 5,
    ),
  ];

  test('filters by search brand or name', () {
    final result = useCase(
      paddles: paddles,
      params: const PaddleFilterParams(query: 'apex'),
    );
    expect(result.map((p) => p.id), ['c', 'a']);
  });

  test('filters by shape and excludes null prices for price ranges', () {
    final result = useCase(
      paddles: paddles,
      params: const PaddleFilterParams(
        shape: PaddleShape.standard,
        priceRange: PriceRangeFilter.under100,
      ),
    );
    expect(result.map((p) => p.id), ['b']);
  });

  test('sorts by control descending and null prices last for price sort', () {
    final byControl = useCase(
      paddles: paddles,
      params: const PaddleFilterParams(sort: PaddleSortOption.controlDesc),
    );
    expect(byControl.map((p) => p.id), ['b', 'a', 'c']);

    final byPrice = useCase(
      paddles: paddles,
      params: const PaddleFilterParams(sort: PaddleSortOption.priceAsc),
    );
    expect(byPrice.map((p) => p.id), ['b', 'a', 'c']);
  });

  test('in-stock filter works', () {
    final result = useCase(
      paddles: paddles,
      params: const PaddleFilterParams(inStockOnly: true),
    );
    expect(result.map((p) => p.id), ['c', 'a']);
  });
}
