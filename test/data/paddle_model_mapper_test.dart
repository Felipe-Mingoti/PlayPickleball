import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/data/mappers/paddle_mapper.dart';
import 'package:play_pickleball/features/paddles/data/models/paddle_model.dart';
import 'package:play_pickleball/features/paddles/domain/entities/paddle.dart';

void main() {
  const mapper = PaddleMapper();

  test('parses a complete paddle and normalizes grams', () {
    final model = PaddleModel.tryParse({
      'id': 'sample',
      'brand': 'Brand',
      'name': 'Model',
      'releaseYear': 2025,
      'priceUsd': 199.0,
      'inStock': true,
      'shape': 'elongated',
      'faceMaterial': 'raw carbon',
      'coreThicknessMm': 16,
      'weight': {'value': 226.796, 'unit': 'g'},
      'swingWeight': 110,
      'twistWeight': 6.5,
      'dimensionsIn': {'length': 16.5, 'width': 7.5, 'handleLength': 5.5},
      'gripCircumferenceIn': 4.25,
      'ratings': {'power': 7, 'control': 8, 'spin': 9, 'pop': 6},
      'imagePath': 'assets/images/paddles/sample.png',
      'description': 'Nice',
    })!;

    final entity = mapper.toEntity(model)!;
    expect(entity.shape, PaddleShape.elongated);
    expect(entity.weight!.ounces, closeTo(8.0, 0.001));
    expect(entity.imagePath, 'assets/images/paddles/sample.png');
  });

  test('skips paddles missing identity and tolerates optional gaps', () {
    expect(PaddleModel.tryParse({'brand': 'x', 'name': 'y'}), isNull);

    final model = PaddleModel.tryParse({
      'id': 'sample',
      'brand': 'Brand',
      'name': 'Model',
      'releaseYear': 2025,
      'priceUsd': null,
      'inStock': true,
      'shape': 'standard',
      'faceMaterial': 'carbon fiber',
      'coreThicknessMm': 16,
      'weight': {'value': 8.0, 'unit': 'oz'},
      'swingWeight': null,
      'dimensionsIn': {'length': 16, 'width': 8, 'handleLength': 5},
      'gripCircumferenceIn': 4.25,
      'ratings': {'power': 7, 'control': 8, 'pop': 6},
      'imagePath': null,
      'description': '',
    })!;

    final entity = mapper.toEntity(model)!;
    expect(entity.priceUsd, isNull);
    expect(entity.swingWeight, isNull);
    expect(entity.twistWeight, isNull);
    expect(entity.ratings.spin, isNull);
    expect(entity.imagePath, isNull);
  });

  test('rejects invalid image paths without failing the paddle', () {
    final model = PaddleModel.tryParse({
      'id': 'sample',
      'brand': 'Brand',
      'name': 'Model',
      'releaseYear': 2025,
      'inStock': true,
      'shape': 'standard',
      'faceMaterial': 'carbon',
      'coreThicknessMm': 14,
      'weight': {'value': 8, 'unit': 'oz'},
      'dimensionsIn': {'length': 16, 'width': 8, 'handleLength': 5},
      'gripCircumferenceIn': 4.25,
      'ratings': {'power': 7, 'control': 8, 'pop': 6},
      'imagePath': 'https://example.com/x.png',
    })!;
    expect(mapper.toEntity(model)!.imagePath, isNull);
  });
}
