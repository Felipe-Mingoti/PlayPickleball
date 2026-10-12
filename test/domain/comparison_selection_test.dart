import 'package:flutter_test/flutter_test.dart';
import 'package:play_pickleball/features/paddles/domain/value_objects/comparison_selection.dart';

void main() {
  group('ComparisonSelection', () {
    test('fromIds trims, drops empties, dedupes, and caps at three', () {
      final selection = ComparisonSelection.fromIds([
        ' a ',
        '',
        'b',
        'a',
        'c',
        'd',
      ]);
      expect(selection.ids, ['a', 'b', 'c']);
      expect(selection.isFull, isTrue);
    });

    test('fromQuery parses comma-separated ids', () {
      final selection = ComparisonSelection.fromQuery('a,b,a,c');
      expect(selection.ids, ['a', 'b', 'c']);
    });

    test('add preserves order and rejects duplicates', () {
      var selection = ComparisonSelection.empty;
      final first = selection.add('a');
      expect(first.result, ComparisonAddResult.added);
      selection = first.selection;

      final duplicate = selection.add('a');
      expect(duplicate.result, ComparisonAddResult.duplicate);
      expect(duplicate.selection.ids, ['a']);
    });

    test('add refuses a fourth paddle without replacing', () {
      final selection = ComparisonSelection.fromIds(['a', 'b', 'c']);
      final result = selection.add('d');
      expect(result.result, ComparisonAddResult.limitReached);
      expect(result.selection.ids, ['a', 'b', 'c']);
    });

    test('remove drops a single id and preserves order', () {
      final selection = ComparisonSelection.fromIds(['a', 'b', 'c']).remove('b');
      expect(selection.ids, ['a', 'c']);
      expect(selection.canCompare, isTrue);
    });
  });
}
