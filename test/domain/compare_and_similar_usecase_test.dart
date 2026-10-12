import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/domain/entities/paddle.dart';
import 'package:play_pickleball/features/paddles/domain/usecases/compare_paddles_usecase.dart';
import 'package:play_pickleball/features/paddles/domain/usecases/find_similar_paddles_usecase.dart';
import 'package:play_pickleball/features/paddles/domain/value_objects/comparison_selection.dart';
import 'package:play_pickleball/features/paddles/domain/value_objects/paddle_weight.dart';

import '../helpers/paddle_fixtures.dart';

void main() {
  group('ComparePaddlesUseCase', () {
    const useCase = ComparePaddlesUseCase();

    test('preserves order and reports unknown ids', () {
      final paddles = [
        makePaddle(id: 'a', priceUsd: 100),
        makePaddle(id: 'b', priceUsd: 120),
      ];
      final result = useCase(
        selection: ComparisonSelection.fromIds(['b', 'missing', 'a']),
        paddles: paddles,
      );
      expect(result.paddles.map((p) => p.id), ['b', 'a']);
      expect(result.unknownIds, ['missing']);
      expect(result.rows, isNotEmpty);
    });

    test('marks differing attributes including missing values', () {
      final paddles = [
        makePaddle(id: 'a', priceUsd: 100, spin: 8),
        makePaddle(id: 'b', priceUsd: 100, spin: null),
      ];
      final result = useCase(
        selection: ComparisonSelection.fromIds(['a', 'b']),
        paddles: paddles,
      );
      final spin = result.rows.firstWhere(
        (row) => row.attribute == ComparisonAttribute.spin,
      );
      expect(spin.differs, isTrue);
      expect(spin.values, ['8', 'Not available']);
    });
  });

  group('FindSimilarPaddlesUseCase', () {
    const useCase = FindSimilarPaddlesUseCase(limit: 4);

    test('excludes selected paddle and ranks deterministically', () {
      final selected = makePaddle(
        id: 'selected',
        shape: PaddleShape.elongated,
        priceUsd: 200,
        control: 8,
        weight: PaddleWeight.tryParse(value: 8.0, unit: 'oz'),
      );
      final paddles = [
        selected,
        makePaddle(
          id: 'close',
          shape: PaddleShape.elongated,
          priceUsd: 210,
          control: 8,
          weight: PaddleWeight.tryParse(value: 8.1, unit: 'oz'),
        ),
        makePaddle(
          id: 'far',
          shape: PaddleShape.widebody,
          priceUsd: 80,
          control: 4,
          weight: PaddleWeight.tryParse(value: 7.0, unit: 'oz'),
        ),
        makePaddle(
          id: 'mid',
          shape: PaddleShape.elongated,
          priceUsd: 260,
          control: 7,
          weight: PaddleWeight.tryParse(value: 8.4, unit: 'oz'),
        ),
      ];

      final result = useCase(selected: selected, paddles: paddles);
      expect(result.map((p) => p.id).contains('selected'), isFalse);
      expect(result.first.id, 'close');
      expect(result.length, lessThanOrEqualTo(4));
    });
  });
}
