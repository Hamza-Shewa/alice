import 'package:alice/helper/alice_json_tree.dart';
import 'package:test/test.dart';

void main() {
  final Map<String, dynamic> json = {
    'data': {
      'user': {'name': 'Alice', 'age': 30},
      'tags': ['a', 'b'],
    },
    'odd key': true,
  };

  group('AliceJsonTree', () {
    test('decodes maps, lists and JSON strings only', () {
      expect(AliceJsonTree.tryDecode('{"a": 1}'), {'a': 1});
      expect(AliceJsonTree.tryDecode([1]), [1]);
      expect(AliceJsonTree.tryDecode('"text"'), null);
      expect(AliceJsonTree.tryDecode('{broken'), null);
      expect(AliceJsonTree.tryDecode(42), null);
    });

    test('builds paths', () {
      expect(AliceJsonTree.childPath(r'$', 'data'), r'$.data');
      expect(AliceJsonTree.childPath(r'$.tags', 0), r'$.tags[0]');
      expect(AliceJsonTree.childPath(r'$', 'odd key'), r'$["odd key"]');
    });

    test('shows children of expanded containers only', () {
      expect(AliceJsonTree.visibleRows(json, {}).map((row) => row.path), [
        r'$.data',
        r'$["odd key"]',
      ]);
      final List<AliceJsonRow> rows = AliceJsonTree.visibleRows(json, {
        r'$.data',
        r'$.data.tags',
      });
      expect(rows.map((row) => row.path), [
        r'$.data',
        r'$.data.user',
        r'$.data.tags',
        r'$.data.tags[0]',
        r'$.data.tags[1]',
        r'$["odd key"]',
      ]);
      expect(rows[1].depth, 1);
      expect(rows[1].childCount, 2);
      expect(rows[3].isMapEntry, false);
    });

    test('expands the first level and every container on request', () {
      expect(AliceJsonTree.initiallyExpanded(json), {r'$.data'});
      expect(AliceJsonTree.allContainers(json), {
        r'$.data',
        r'$.data.user',
        r'$.data.tags',
      });
    });

    test('finds keys and values and the containers holding them', () {
      final Set<String> matches = AliceJsonTree.search(json, 'ALICE');
      expect(matches, {r'$.data.user.name'});
      expect(AliceJsonTree.ancestorsOf(json, matches), {
        r'$.data',
        r'$.data.user',
      });
      expect(AliceJsonTree.search(json, 'tags'), {r'$.data.tags'});
      expect(AliceJsonTree.search(json, ' '), isEmpty);
    });

    test('formats values to copy', () {
      expect(AliceJsonTree.copyText('text'), 'text');
      expect(AliceJsonTree.copyText(30), '30');
      expect(AliceJsonTree.copyText(['a']), '[\n  "a"\n]');
    });
  });
}
