# NetLens for Chopper example

```dart
import 'package:chopper/chopper.dart';
import 'package:netlens/netlens.dart';
import 'package:netlens_chopper/netlens_chopper.dart';

final netLens = NetLens();
final adapter = NetLensChopperAdapter();
netLens.addAdapter(adapter);

final chopper = ChopperClient(interceptors: [adapter]);
```

A complete app is in
[examples/netlens_chopper](https://github.com/Hamza-Shewa/alice/tree/master/examples/netlens_chopper).
