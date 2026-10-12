import '../../features/paddles/domain/value_objects/comparison_selection.dart';
import 'route_paths.dart';

/// Serializes comparison selection into and out of URL query parameters.
abstract final class ComparisonRouteCodec {
  static ComparisonSelection parse(Uri uri) {
    final values = uri.queryParametersAll[RoutePaths.idsQueryKey];
    if (values == null || values.isEmpty) {
      return ComparisonSelection.fromQuery(
        uri.queryParameters[RoutePaths.idsQueryKey],
      );
    }
    final flattened = <String>[];
    for (final value in values) {
      flattened.addAll(value.split(','));
    }
    return ComparisonSelection.fromIds(flattened);
  }

  static Map<String, String> toQuery(ComparisonSelection selection) {
    if (selection.isEmpty) return const {};
    return {RoutePaths.idsQueryKey: selection.toQuery()};
  }

  static Uri withSelection(Uri uri, ComparisonSelection selection) {
    final params = Map<String, String>.from(uri.queryParameters);
    params.remove(RoutePaths.idsQueryKey);
    if (selection.isNotEmpty) {
      params[RoutePaths.idsQueryKey] = selection.toQuery();
    }
    // An empty map clears the query; null would leave the previous query.
    return uri.replace(queryParameters: params);
  }
}
