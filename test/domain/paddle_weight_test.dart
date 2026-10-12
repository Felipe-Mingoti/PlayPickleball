import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/domain/value_objects/paddle_weight.dart';

void main() {
  group('PaddleWeight', () {
    test('normalizes ounces', () {
      final weight = PaddleWeight.tryParse(value: 8.0, unit: 'oz')!;
      expect(weight.ounces, 8.0);
      expect(weight.displayOz, '8.0 oz');
      expect(weight.originalLabel, isNull);
    });

    test('normalizes grams to ounces', () {
      final weight = PaddleWeight.tryParse(value: 226.796, unit: 'g')!;
      expect(weight.ounces, closeTo(8.0, 0.001));
      expect(weight.displayOz, '8.0 oz');
      expect(weight.originalLabel, '226.8 g');
    });

    test('returns null for missing or unknown units', () {
      expect(PaddleWeight.tryParse(value: null, unit: 'oz'), isNull);
      expect(PaddleWeight.tryParse(value: 8, unit: null), isNull);
      expect(PaddleWeight.tryParse(value: 8, unit: 'lb'), isNull);
    });

    test('compare equality uses 0.1 oz precision', () {
      final a = PaddleWeight.tryParse(value: 8.04, unit: 'oz')!;
      final b = PaddleWeight.tryParse(value: 8.05, unit: 'oz')!;
      final c = PaddleWeight.tryParse(value: 8.16, unit: 'oz')!;
      expect(a.equalsForCompare(b), isTrue);
      expect(a.equalsForCompare(c), isFalse);
      expect(a.equalsForCompare(null), isFalse);
    });
  });
}
