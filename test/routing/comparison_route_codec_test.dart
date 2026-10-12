import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/app/router/comparison_route_codec.dart';

void main() {
  group('ComparisonRouteCodec', () {
    test('parses ids from query and enforces limits', () {
      final selection = ComparisonRouteCodec.parse(
        Uri.parse('/compare?ids=a,b,a,c,d'),
      );
      expect(selection.ids, ['a', 'b', 'c']);
    });

    test('handles empty and malformed query', () {
      expect(
        ComparisonRouteCodec.parse(Uri.parse('/paddles')).isEmpty,
        isTrue,
      );
      expect(
        ComparisonRouteCodec.parse(Uri.parse('/paddles?ids=,,')).isEmpty,
        isTrue,
      );
    });

    test('preserves selection when rewriting a path', () {
      final selection = ComparisonRouteCodec.parse(
        Uri.parse('/paddles?ids=a,b'),
      );
      final next = ComparisonRouteCodec.withSelection(
        Uri.parse('/paddles/paddle-c'),
        selection,
      );
      expect(next.path, '/paddles/paddle-c');
      expect(next.queryParameters['ids'], 'a,b');
    });

    test('serializes empty selection by removing ids', () {
      final next = ComparisonRouteCodec.withSelection(
        Uri.parse('/compare?ids=a'),
        ComparisonRouteCodec.parse(Uri.parse('/compare')),
      );
      expect(next.queryParameters.containsKey('ids'), isFalse);
    });
  });
}
