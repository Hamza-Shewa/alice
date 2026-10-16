# NetLens for http example

```dart
import 'package:http/http.dart' as http;
import 'package:netlens/netlens.dart';
import 'package:netlens_http/netlens_http.dart';

final netLens = NetLens();
final adapter = NetLensHttpAdapter();
netLens.addAdapter(adapter);

http
    .get(Uri.parse('https://api.example.com/users'))
    .interceptWithNetLens(adapter);
```

A complete app is in
[examples/netlens_http](https://github.com/Hamza-Shewa/alice/tree/master/examples/netlens_http).
