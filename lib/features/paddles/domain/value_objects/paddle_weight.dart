/// Canonical paddle weight stored in ounces.
class PaddleWeight {
  const PaddleWeight._({
    required this.ounces,
    required this.originalValue,
    required this.originalUnit,
  });

  static const double gramsPerOunce = 28.3495;

  final double ounces;
  final double originalValue;
  final String originalUnit;

  static PaddleWeight? tryParse({
    required num? value,
    required String? unit,
  }) {
    if (value == null || unit == null) return null;
    final normalized = unit.trim().toLowerCase();
    if (normalized == 'oz' || normalized == 'ounce' || normalized == 'ounces') {
      return PaddleWeight._(
        ounces: value.toDouble(),
        originalValue: value.toDouble(),
        originalUnit: 'oz',
      );
    }
    if (normalized == 'g' || normalized == 'gram' || normalized == 'grams') {
      return PaddleWeight._(
        ounces: value.toDouble() / gramsPerOunce,
        originalValue: value.toDouble(),
        originalUnit: 'g',
      );
    }
    return null;
  }

  String get displayOz => '${ounces.toStringAsFixed(1)} oz';

  String? get originalLabel {
    if (originalUnit == 'oz') return null;
    final value = originalValue == originalValue.roundToDouble()
        ? originalValue.toStringAsFixed(0)
        : originalValue.toStringAsFixed(1);
    return '$value $originalUnit';
  }

  /// Equality for comparison highlighting (0.1 oz precision).
  bool equalsForCompare(PaddleWeight? other) {
    if (other == null) return false;
    return (ounces - other.ounces).abs() < 0.05;
  }

  @override
  bool operator ==(Object other) {
    return other is PaddleWeight &&
        ounces == other.ounces &&
        originalValue == other.originalValue &&
        originalUnit == other.originalUnit;
  }

  @override
  int get hashCode => Object.hash(ounces, originalValue, originalUnit);
}
