import 'package:play_pickleball/features/paddles/domain/entities/paddle.dart';
import 'package:play_pickleball/features/paddles/domain/value_objects/paddle_weight.dart';

Paddle makePaddle({
  required String id,
  String brand = 'Brand',
  String name = 'Name',
  int releaseYear = 2025,
  double? priceUsd = 150,
  bool inStock = true,
  PaddleShape shape = PaddleShape.standard,
  String faceMaterial = 'raw carbon',
  int coreThicknessMm = 16,
  PaddleWeight? weight,
  int? swingWeight = 110,
  double? twistWeight = 6.5,
  double lengthIn = 16,
  double widthIn = 8,
  double handleLengthIn = 5.25,
  double gripCircumferenceIn = 4.25,
  int power = 7,
  int control = 8,
  int? spin = 8,
  int pop = 6,
  String? imagePath,
  String description = 'A paddle',
}) {
  return Paddle(
    id: id,
    brand: brand,
    name: name,
    releaseYear: releaseYear,
    priceUsd: priceUsd,
    inStock: inStock,
    shape: shape,
    faceMaterial: faceMaterial,
    coreThicknessMm: coreThicknessMm,
    weight: weight ??
        PaddleWeight.tryParse(value: 8.0, unit: 'oz')!,
    swingWeight: swingWeight,
    twistWeight: twistWeight,
    dimensions: PaddleDimensions(
      lengthIn: lengthIn,
      widthIn: widthIn,
      handleLengthIn: handleLengthIn,
    ),
    gripCircumferenceIn: gripCircumferenceIn,
    ratings: PaddleRatings(
      power: power,
      control: control,
      spin: spin,
      pop: pop,
    ),
    imagePath: imagePath,
    description: description,
  );
}
