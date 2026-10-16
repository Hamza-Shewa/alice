import 'dart:io' show Directory;

import 'package:netlens_objectbox/model/cached_netlens_http_call.dart';
import 'package:netlens_objectbox/objectbox.g.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Implementation of store for ObjectBox.
class NetLensObjectBoxStore {
  NetLensObjectBoxStore._create(this._store, {bool persistent = true}) {
    /// Initialize all the boxes here
    httpCalls = Box<CachedNetLensHttpCall>(_store);

    if (!persistent) {
      clear();
    }
  }

  /// Create an instance of [NetLensObjectBoxStore] to use throughout the app.
  static Future<NetLensObjectBoxStore> create({
    Store? store,
    bool persistent = true,
  }) async {
    final String storeDirectoryPath = path.join(
      (await getApplicationDocumentsDirectory()).path,
      Store.defaultDirectoryPath,
      "netLens",
    );

    final Directory storeDirectory = Directory(storeDirectoryPath);
    if (!await storeDirectory.exists()) {
      await storeDirectory.create(recursive: true);
    }

    store ??=
        Store.isOpen(storeDirectoryPath)
            ? Store.attach(getObjectBoxModel(), storeDirectoryPath)
            : await openStore(directory: storeDirectoryPath);

    return NetLensObjectBoxStore._create(store, persistent: persistent);
  }

  late final Store _store;

  /// Box to store [CachedNetLensHttpCall] objects.
  late final Box<CachedNetLensHttpCall> httpCalls;

  late final Map<Type, Box> _boxes = {CachedNetLensHttpCall: httpCalls};

  /// This will remove all the items from all the boxes
  void clear() {
    for (final Box box in _boxes.values) {
      box.removeAll();
    }
  }
}
