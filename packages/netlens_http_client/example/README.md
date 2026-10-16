# NetLens for HttpClient from dart:io example

```dart
import 'dart:io';
import 'package:netlens/netlens.dart';
import 'package:netlens_http_client/netlens_http_client.dart';

final netLens = NetLens();
final adapter = NetLensHttpClientAdapter();
netLens.addAdapter(adapter);

HttpClient()
    .getUrl(Uri.parse('https://api.example.com/users'))
    .interceptWithNetLens(adapter);
```

A complete app is in
[examples/netlens_http_client](https://github.com/Hamza-Shewa/alice/tree/master/examples/netlens_http_client).
