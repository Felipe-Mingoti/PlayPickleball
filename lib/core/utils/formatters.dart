/// Presentation helpers that are not paddle-specific business rules.
abstract final class Formatters {
  static String priceUsd(double? value) {
    if (value == null) return 'Not available';
    final fixed = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '\$$fixed';
  }

  static String inches(double? value) {
    if (value == null) return 'Not available';
    return '${_trimTrailingZeros(value.toStringAsFixed(2))} in';
  }

  static String millimeters(int? value) {
    if (value == null) return 'Not available';
    return '$value mm';
  }

  static String unavailable(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not available';
    return value;
  }

  static String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;
    return value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
