class WeightModel {
  const WeightModel({this.value, this.unit});

  final num? value;
  final String? unit;

  factory WeightModel.fromJson(Object? json) {
    if (json is! Map) return const WeightModel();
    return WeightModel(
      value: _asNum(json['value']),
      unit: _asString(json['unit']),
    );
  }
}

class DimensionsModel {
  const DimensionsModel({this.length, this.width, this.handleLength});

  final num? length;
  final num? width;
  final num? handleLength;

  factory DimensionsModel.fromJson(Object? json) {
    if (json is! Map) return const DimensionsModel();
    return DimensionsModel(
      length: _asNum(json['length']),
      width: _asNum(json['width']),
      handleLength: _asNum(json['handleLength']),
    );
  }
}

class RatingsModel {
  const RatingsModel({this.power, this.control, this.spin, this.pop});

  final int? power;
  final int? control;
  final int? spin;
  final int? pop;

  factory RatingsModel.fromJson(Object? json) {
    if (json is! Map) return const RatingsModel();
    return RatingsModel(
      power: _asInt(json['power']),
      control: _asInt(json['control']),
      spin: _asInt(json['spin']),
      pop: _asInt(json['pop']),
    );
  }
}

class PaddleModel {
  const PaddleModel({
    required this.id,
    required this.brand,
    required this.name,
    this.releaseYear,
    this.priceUsd,
    this.inStock,
    this.shape,
    this.faceMaterial,
    this.coreThicknessMm,
    this.weight,
    this.swingWeight,
    this.twistWeight,
    this.dimensions,
    this.gripCircumferenceIn,
    this.ratings,
    this.imagePath,
    this.description,
  });

  final String id;
  final String brand;
  final String name;
  final int? releaseYear;
  final double? priceUsd;
  final bool? inStock;
  final String? shape;
  final String? faceMaterial;
  final int? coreThicknessMm;
  final WeightModel? weight;
  final int? swingWeight;
  final double? twistWeight;
  final DimensionsModel? dimensions;
  final double? gripCircumferenceIn;
  final RatingsModel? ratings;
  final String? imagePath;
  final String? description;

  /// Returns null when identity fields are missing.
  static PaddleModel? tryParse(Object? json) {
    if (json is! Map) return null;
    final id = _asString(json['id']);
    final brand = _asString(json['brand']);
    final name = _asString(json['name']);
    if (id == null || id.isEmpty || brand == null || brand.isEmpty || name == null || name.isEmpty) {
      return null;
    }

    WeightModel? weight;
    try {
      weight = WeightModel.fromJson(json['weight']);
    } catch (_) {
      weight = null;
    }

    DimensionsModel? dimensions;
    try {
      dimensions = DimensionsModel.fromJson(json['dimensionsIn']);
    } catch (_) {
      dimensions = null;
    }

    RatingsModel? ratings;
    try {
      ratings = RatingsModel.fromJson(json['ratings']);
    } catch (_) {
      ratings = null;
    }

    return PaddleModel(
      id: id,
      brand: brand,
      name: name,
      releaseYear: _asInt(json['releaseYear']),
      priceUsd: _asDouble(json['priceUsd']),
      inStock: json['inStock'] is bool ? json['inStock'] as bool : null,
      shape: _asString(json['shape']),
      faceMaterial: _asString(json['faceMaterial']),
      coreThicknessMm: _asInt(json['coreThicknessMm']),
      weight: weight,
      swingWeight: _asInt(json['swingWeight']),
      twistWeight: _asDouble(json['twistWeight']),
      dimensions: dimensions,
      gripCircumferenceIn: _asDouble(json['gripCircumferenceIn']),
      ratings: ratings,
      imagePath: _asString(json['imagePath']),
      description: _asString(json['description']),
    );
  }
}

num? _asNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _asInt(Object? value) => _asNum(value)?.round();

double? _asDouble(Object? value) => _asNum(value)?.toDouble();

String? _asString(Object? value) {
  if (value is String) return value;
  if (value == null) return null;
  return value.toString();
}
