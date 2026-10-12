import '../value_objects/paddle_weight.dart';

enum PaddleShape {
  standard,
  elongated,
  hybrid,
  widebody,
  unknown;

  static PaddleShape fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'standard':
        return PaddleShape.standard;
      case 'elongated':
        return PaddleShape.elongated;
      case 'hybrid':
        return PaddleShape.hybrid;
      case 'widebody':
        return PaddleShape.widebody;
      default:
        return PaddleShape.unknown;
    }
  }

  String get label => switch (this) {
        PaddleShape.standard => 'Standard',
        PaddleShape.elongated => 'Elongated',
        PaddleShape.hybrid => 'Hybrid',
        PaddleShape.widebody => 'Widebody',
        PaddleShape.unknown => 'Unknown',
      };
}

class PaddleDimensions {
  const PaddleDimensions({
    required this.lengthIn,
    required this.widthIn,
    required this.handleLengthIn,
  });

  final double lengthIn;
  final double widthIn;
  final double handleLengthIn;
}

class PaddleRatings {
  const PaddleRatings({
    required this.power,
    required this.control,
    required this.pop,
    this.spin,
  });

  final int power;
  final int control;
  final int pop;
  final int? spin;
}

class Paddle {
  const Paddle({
    required this.id,
    required this.brand,
    required this.name,
    required this.releaseYear,
    required this.priceUsd,
    required this.inStock,
    required this.shape,
    required this.faceMaterial,
    required this.coreThicknessMm,
    required this.weight,
    required this.swingWeight,
    required this.twistWeight,
    required this.dimensions,
    required this.gripCircumferenceIn,
    required this.ratings,
    required this.imagePath,
    required this.description,
  });

  final String id;
  final String brand;
  final String name;
  final int releaseYear;
  final double? priceUsd;
  final bool inStock;
  final PaddleShape shape;
  final String faceMaterial;
  final int coreThicknessMm;
  final PaddleWeight? weight;
  final int? swingWeight;
  final double? twistWeight;
  final PaddleDimensions dimensions;
  final double gripCircumferenceIn;
  final PaddleRatings ratings;
  final String? imagePath;
  final String description;

  String get displayName => '$brand $name';
}
