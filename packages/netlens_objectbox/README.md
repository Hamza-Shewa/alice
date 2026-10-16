# NetLens ObjectBox

[![pub package](https://img.shields.io/pub/v/netlens_objectbox.svg)](https://pub.dev/packages/netlens_objectbox)

Keeps the calls caught by [NetLens](https://pub.dev/packages/netlens), the in-app
HTTP inspector for Flutter, in an ObjectBox database instead of memory.

## Install

```yaml
dependencies:
  netlens: ^1.0.0
  netlens_objectbox: ^1.0.0
```

## Use

```dart
WidgetsFlutterBinding.ensureInitialized();
final store = await NetLensObjectBoxStore.create();

final netLens = NetLens(
  configuration: NetLensConfiguration(
    storage: NetLensObjectBox(store: store, maxCallsCount: 1000),
  ),
);
```

## Documentation

You can find the documentation [here](https://github.com/Hamza-Shewa/alice/tree/master/docs).

## Credits

NetLens is a fork of [Alice](https://github.com/jhomlala/alice) by Jakub
Homlala and its contributors, licensed under the Apache License 2.0.
