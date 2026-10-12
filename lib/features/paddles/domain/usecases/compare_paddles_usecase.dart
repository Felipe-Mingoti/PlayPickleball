import '../entities/paddle.dart';
import '../value_objects/comparison_selection.dart';
import '../value_objects/paddle_weight.dart';

enum ComparisonAttribute {
  price,
  shape,
  faceMaterial,
  coreThickness,
  weight,
  swingWeight,
  twistWeight,
  length,
  width,
  handleLength,
  grip,
  power,
  control,
  spin,
  pop,
  releaseYear,
  inStock,
}

class ComparisonSpecRow {
  const ComparisonSpecRow({
    required this.attribute,
    required this.label,
    required this.category,
    required this.values,
    required this.differs,
  });

  final ComparisonAttribute attribute;
  final String label;
  final String category;
  final List<String> values;
  final bool differs;
}

class ComparisonResult {
  const ComparisonResult({
    required this.paddles,
    required this.unknownIds,
    required this.rows,
  });

  final List<Paddle> paddles;
  final List<String> unknownIds;
  final List<ComparisonSpecRow> rows;

  bool get hasUnknownIds => unknownIds.isNotEmpty;
}

class ComparePaddlesUseCase {
  const ComparePaddlesUseCase();

  ComparisonResult call({
    required ComparisonSelection selection,
    required List<Paddle> paddles,
  }) {
    final byId = {for (final paddle in paddles) paddle.id: paddle};
    final resolved = <Paddle>[];
    final unknown = <String>[];

    for (final id in selection.ids) {
      final paddle = byId[id];
      if (paddle == null) {
        unknown.add(id);
      } else {
        resolved.add(paddle);
      }
    }

    final rows = resolved.isEmpty
        ? const <ComparisonSpecRow>[]
        : _buildRows(resolved);

    return ComparisonResult(
      paddles: resolved,
      unknownIds: unknown,
      rows: rows,
    );
  }

  List<ComparisonSpecRow> _buildRows(List<Paddle> paddles) {
    String text(String? value) =>
        (value == null || value.trim().isEmpty) ? 'Not available' : value;

    String price(double? value) {
      if (value == null) return 'Not available';
      return '\$${value.toStringAsFixed(2)}';
    }

    String weight(PaddleWeight? value) {
      if (value == null) return 'Not available';
      final original = value.originalLabel;
      return original == null
          ? value.displayOz
          : '${value.displayOz} ($original)';
    }

    String number(num? value, {int fractionDigits = 0, String suffix = ''}) {
      if (value == null) return 'Not available';
      final formatted = fractionDigits == 0
          ? value.round().toString()
          : value.toStringAsFixed(fractionDigits);
      return '$formatted$suffix';
    }

    bool differs(List<Object?> values, bool Function(Object?, Object?) equals) {
      for (var i = 1; i < values.length; i++) {
        if (!equals(values[0], values[i])) return true;
      }
      return false;
    }

    bool eqNullableNum(Object? a, Object? b, int scale) {
      if (a == null && b == null) return true;
      if (a == null || b == null) return false;
      final left = ((a as num) * scale).round();
      final right = ((b as num) * scale).round();
      return left == right;
    }

    bool eqString(Object? a, Object? b) {
      final left = (a as String?)?.trim().toLowerCase();
      final right = (b as String?)?.trim().toLowerCase();
      return left == right;
    }

    bool eqWeight(Object? a, Object? b) {
      if (a == null && b == null) return true;
      if (a is! PaddleWeight || b is! PaddleWeight) return false;
      return a.equalsForCompare(b);
    }

    ComparisonSpecRow row({
      required ComparisonAttribute attribute,
      required String label,
      required String category,
      required List<String> display,
      required List<Object?> raw,
      required bool Function(Object?, Object?) equals,
    }) {
      return ComparisonSpecRow(
        attribute: attribute,
        label: label,
        category: category,
        values: display,
        differs: differs(raw, equals),
      );
    }

    return [
      row(
        attribute: ComparisonAttribute.price,
        label: 'Price',
        category: 'General',
        display: paddles.map((p) => price(p.priceUsd)).toList(),
        raw: paddles.map((p) => p.priceUsd).toList(),
        equals: (a, b) => eqNullableNum(a, b, 100),
      ),
      row(
        attribute: ComparisonAttribute.shape,
        label: 'Shape',
        category: 'General',
        display: paddles.map((p) => p.shape.label).toList(),
        raw: paddles.map((p) => p.shape.name).toList(),
        equals: eqString,
      ),
      row(
        attribute: ComparisonAttribute.releaseYear,
        label: 'Release year',
        category: 'General',
        display: paddles.map((p) => p.releaseYear.toString()).toList(),
        raw: paddles.map((p) => p.releaseYear).toList(),
        equals: (a, b) => a == b,
      ),
      row(
        attribute: ComparisonAttribute.inStock,
        label: 'Availability',
        category: 'General',
        display: paddles.map((p) => p.inStock ? 'In stock' : 'Out of stock').toList(),
        raw: paddles.map((p) => p.inStock).toList(),
        equals: (a, b) => a == b,
      ),
      row(
        attribute: ComparisonAttribute.length,
        label: 'Length',
        category: 'Dimensions',
        display: paddles
            .map((p) => number(p.dimensions.lengthIn, fractionDigits: 2, suffix: ' in'))
            .toList(),
        raw: paddles.map((p) => p.dimensions.lengthIn).toList(),
        equals: (a, b) => eqNullableNum(a, b, 100),
      ),
      row(
        attribute: ComparisonAttribute.width,
        label: 'Width',
        category: 'Dimensions',
        display: paddles
            .map((p) => number(p.dimensions.widthIn, fractionDigits: 2, suffix: ' in'))
            .toList(),
        raw: paddles.map((p) => p.dimensions.widthIn).toList(),
        equals: (a, b) => eqNullableNum(a, b, 100),
      ),
      row(
        attribute: ComparisonAttribute.handleLength,
        label: 'Handle length',
        category: 'Dimensions',
        display: paddles
            .map(
              (p) => number(
                p.dimensions.handleLengthIn,
                fractionDigits: 2,
                suffix: ' in',
              ),
            )
            .toList(),
        raw: paddles.map((p) => p.dimensions.handleLengthIn).toList(),
        equals: (a, b) => eqNullableNum(a, b, 100),
      ),
      row(
        attribute: ComparisonAttribute.grip,
        label: 'Grip circumference',
        category: 'Dimensions',
        display: paddles
            .map(
              (p) => number(p.gripCircumferenceIn, fractionDigits: 3, suffix: ' in'),
            )
            .toList(),
        raw: paddles.map((p) => p.gripCircumferenceIn).toList(),
        equals: (a, b) => eqNullableNum(a, b, 1000),
      ),
      row(
        attribute: ComparisonAttribute.weight,
        label: 'Weight',
        category: 'Construction',
        display: paddles.map((p) => weight(p.weight)).toList(),
        raw: paddles.map((p) => p.weight).toList(),
        equals: eqWeight,
      ),
      row(
        attribute: ComparisonAttribute.coreThickness,
        label: 'Core thickness',
        category: 'Construction',
        display: paddles.map((p) => '${p.coreThicknessMm} mm').toList(),
        raw: paddles.map((p) => p.coreThicknessMm).toList(),
        equals: (a, b) => a == b,
      ),
      row(
        attribute: ComparisonAttribute.faceMaterial,
        label: 'Face material',
        category: 'Construction',
        display: paddles.map((p) => text(p.faceMaterial)).toList(),
        raw: paddles.map((p) => p.faceMaterial).toList(),
        equals: eqString,
      ),
      row(
        attribute: ComparisonAttribute.swingWeight,
        label: 'Swing weight',
        category: 'Performance',
        display: paddles.map((p) => number(p.swingWeight)).toList(),
        raw: paddles.map((p) => p.swingWeight).toList(),
        equals: (a, b) => eqNullableNum(a, b, 1),
      ),
      row(
        attribute: ComparisonAttribute.twistWeight,
        label: 'Twist weight',
        category: 'Performance',
        display:
            paddles.map((p) => number(p.twistWeight, fractionDigits: 1)).toList(),
        raw: paddles.map((p) => p.twistWeight).toList(),
        equals: (a, b) => eqNullableNum(a, b, 10),
      ),
      row(
        attribute: ComparisonAttribute.power,
        label: 'Power',
        category: 'Performance',
        display: paddles.map((p) => p.ratings.power.toString()).toList(),
        raw: paddles.map((p) => p.ratings.power).toList(),
        equals: (a, b) => a == b,
      ),
      row(
        attribute: ComparisonAttribute.control,
        label: 'Control',
        category: 'Performance',
        display: paddles.map((p) => p.ratings.control.toString()).toList(),
        raw: paddles.map((p) => p.ratings.control).toList(),
        equals: (a, b) => a == b,
      ),
      row(
        attribute: ComparisonAttribute.spin,
        label: 'Spin',
        category: 'Performance',
        display: paddles.map((p) => number(p.ratings.spin)).toList(),
        raw: paddles.map((p) => p.ratings.spin).toList(),
        equals: (a, b) => eqNullableNum(a, b, 1),
      ),
      row(
        attribute: ComparisonAttribute.pop,
        label: 'Pop',
        category: 'Performance',
        display: paddles.map((p) => p.ratings.pop.toString()).toList(),
        raw: paddles.map((p) => p.ratings.pop).toList(),
        equals: (a, b) => a == b,
      ),
    ];
  }
}
