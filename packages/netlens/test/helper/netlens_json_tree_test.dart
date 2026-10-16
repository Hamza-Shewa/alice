import 'package:netlens/helper/netlens_json_tree.dart';
import 'package:test/test.dart';

void main() {
  final Map<String, dynamic> json = {
    'data': {
      'user': {'name': 'NetLens', 'age': 30},
      'tags': ['a', 'b'],
    },
    'odd key': true,
  };

  group('NetLensJsonTree', () {
    test('decodes maps, lists and JSON strings only', () {
      expect(NetLensJsonTree.tryDecode('{"a": 1}'), {'a': 1});
      expect(NetLensJsonTree.tryDecode([1]), [1]);
      expect(NetLensJsonTree.tryDecode('"text"'), null);
      expect(NetLensJsonTree.tryDecode('{broken'), null);
      expect(NetLensJsonTree.tryDecode(42), null);
    });

    test('builds paths', () {
      expect(NetLensJsonTree.childPath(r'$', 'data'), r'$.data');
      expect(NetLensJsonTree.childPath(r'$.tags', 0), r'$.tags[0]');
      expect(NetLensJsonTree.childPath(r'$', 'odd key'), r'$["odd key"]');
    });

    test('shows children of expanded containers only', () {
      expect(NetLensJsonTree.visibleRows(json, {}).map((row) => row.path), [
        r'$.data',
        r'$["odd key"]',
      ]);
      final List<NetLensJsonRow> rows = NetLensJsonTree.visibleRows(json, {
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
      expect(NetLensJsonTree.initiallyExpanded(json), {r'$.data'});
      expect(NetLensJsonTree.allContainers(json), {
        r'$.data',
        r'$.data.user',
        r'$.data.tags',
      });
    });

    test('finds keys and values and the containers holding them', () {
      final Set<String> matches = NetLensJsonTree.search(json, 'NETLENS');
      expect(matches, {r'$.data.user.name'});
      expect(NetLensJsonTree.ancestorsOf(json, matches), {
        r'$.data',
        r'$.data.user',
      });
      expect(NetLensJsonTree.search(json, 'tags'), {r'$.data.tags'});
      expect(NetLensJsonTree.search(json, ' '), isEmpty);
    });

    test('formats values to copy', () {
      expect(NetLensJsonTree.copyText('text'), 'text');
      expect(NetLensJsonTree.copyText(30), '30');
      expect(NetLensJsonTree.copyText(['a']), '[\n  "a"\n]');
    });
  });
}
