enum ComparisonAddResult { added, duplicate, limitReached }

/// Immutable ordered selection of paddle IDs for comparison.
class ComparisonSelection {
  const ComparisonSelection(this.ids);

  static const int maxSelection = 3;

  static const ComparisonSelection empty = ComparisonSelection([]);

  final List<String> ids;

  int get count => ids.length;

  bool get isEmpty => ids.isEmpty;

  bool get isNotEmpty => ids.isNotEmpty;

  bool get canCompare => ids.length >= 2;

  bool get isFull => ids.length >= maxSelection;

  bool contains(String id) => ids.contains(id);

  /// Parses URL/query ids: trim, drop empties, keep first occurrence, cap at 3.
  factory ComparisonSelection.fromIds(Iterable<String> rawIds) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final raw in rawIds) {
      final id = raw.trim();
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      ordered.add(id);
      if (ordered.length >= maxSelection) break;
    }
    return ComparisonSelection(List.unmodifiable(ordered));
  }

  factory ComparisonSelection.fromQuery(String? query) {
    if (query == null || query.trim().isEmpty) return empty;
    return ComparisonSelection.fromIds(query.split(','));
  }

  String toQuery() => ids.join(',');

  ({ComparisonSelection selection, ComparisonAddResult result}) add(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) {
      return (selection: this, result: ComparisonAddResult.duplicate);
    }
    if (contains(trimmed)) {
      return (selection: this, result: ComparisonAddResult.duplicate);
    }
    if (isFull) {
      return (selection: this, result: ComparisonAddResult.limitReached);
    }
    return (
      selection: ComparisonSelection(List.unmodifiable([...ids, trimmed])),
      result: ComparisonAddResult.added,
    );
  }

  ComparisonSelection remove(String id) {
    if (!contains(id)) return this;
    return ComparisonSelection(
      List.unmodifiable(ids.where((item) => item != id)),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! ComparisonSelection) return false;
    if (identical(this, other)) return true;
    if (ids.length != other.ids.length) return false;
    for (var i = 0; i < ids.length; i++) {
      if (ids[i] != other.ids[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(ids);

  @override
  String toString() => 'ComparisonSelection($ids)';
}
