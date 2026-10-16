# NetLens

[![pub package](https://img.shields.io/pub/v/netlens.svg)](https://pub.dev/packages/netlens)
[![pub package](https://img.shields.io/pub/v/netlens_dio.svg?label=netlens_dio)](https://pub.dev/packages/netlens_dio)
[![pub package](https://img.shields.io/pub/v/netlens_chopper.svg?label=netlens_chopper)](https://pub.dev/packages/netlens_chopper)
[![pub package](https://img.shields.io/pub/v/netlens_http.svg?label=netlens_http)](https://pub.dev/packages/netlens_http)
[![pub package](https://img.shields.io/pub/v/netlens_http_client.svg?label=netlens_http_client)](https://pub.dev/packages/netlens_http_client)
[![pub package](https://img.shields.io/pub/v/netlens_objectbox.svg?label=netlens_objectbox)](https://pub.dev/packages/netlens_objectbox)
[![platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/Hamza-Shewa/alice)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

NetLens is an in-app HTTP inspector for Flutter. It catches the requests and
responses your app makes and lets you look through them, filter them, export
them and send them again, right on the device.

**Supported HTTP clients:**

| Client | Package |
| --- | --- |
| Dio | [netlens_dio](https://pub.dev/packages/netlens_dio) |
| http | [netlens_http](https://pub.dev/packages/netlens_http) |
| HttpClient from dart:io | [netlens_http_client](https://pub.dev/packages/netlens_http_client) |
| Chopper | [netlens_chopper](https://pub.dev/packages/netlens_chopper) |
| Any other client | `NetLensAdapter` from [netlens](https://pub.dev/packages/netlens) |

Calls are kept in memory by default, or in a database with
[netlens_objectbox](https://pub.dev/packages/netlens_objectbox).

**Features:**

- Detailed request and response logs for every call
- Inspector UI with statistics, notifications and shake to open
- Search in URLs, headers and bodies, with quick filters by status, method and host
- Sensitive headers, cookies and fields hidden in the inspector and masked in exports
- Edit and resend a call (Dio, http and HttpClient)
- Collapsible JSON viewer with search
- Export to a log file or to HAR for Chrome DevTools, Proxyman or Charles
- GraphQL operation names and errors
- Timeline of calls and slowest endpoints
- Flutter and Android logs

## Quick start

```yaml
dependencies:
  netlens: ^1.0.0
  netlens_dio: ^1.0.0
```

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

## Documentation

You can find the documentation
[here](https://github.com/Hamza-Shewa/alice/tree/master/docs).

## Credits

NetLens is a fork of [Alice](https://github.com/jhomlala/alice) by Jakub
Homlala and its contributors, licensed under the Apache License 2.0. See
[NOTICE](https://github.com/Hamza-Shewa/alice/blob/master/NOTICE) for details.
Alice itself was inspired by [Chuck](https://github.com/jgilfelt/chuck) and
[Chucker](https://github.com/ChuckerTeam/chucker).
