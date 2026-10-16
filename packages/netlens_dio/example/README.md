# NetLens for Dio example

```dart
import 'package:dio/dio.dart';
import 'package:netlens/netlens.dart';
import 'package:netlens_dio/netlens_dio.dart';

final netLens = NetLens();
final adapter = NetLensDioAdapter();
netLens.addAdapter(adapter);

final dio = Dio()..interceptors.add(adapter);

// Optional: resend calls with this Dio, so they keep its options and interceptors.
adapter.replayClient = dio;
```

A complete app is in
[examples/netlens_dio](https://github.com/Hamza-Shewa/alice/tree/master/examples/netlens_dio).
