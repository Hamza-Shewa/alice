# NetLens example

```dart
import 'package:dio/dio.dart';
import 'package:netlens/netlens.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens_dio/netlens_dio.dart';

final netLens = NetLens(
  configuration: NetLensConfiguration(showInspectorOnShake: true),
);
final dioAdapter = NetLensDioAdapter();
netLens.addAdapter(dioAdapter);

final dio = Dio()..interceptors.add(dioAdapter);

MaterialApp(
  navigatorKey: netLens.getNavigatorKey(),
  // ...
);
```

A complete app is in
[examples/netlens](https://github.com/Hamza-Shewa/alice/tree/master/examples/netlens).
