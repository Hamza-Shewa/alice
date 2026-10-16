# How to use

## Dio

```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Dio Adapter
AliceDioAdapter aliceDioAdapter = AliceDioAdapter();

/// Add adapter to Alice
alice.addAdapter(aliceDioAdapter);

/// Create Dio instance
Dio dio = Dio();

/// Add interceptor to Dio
dio.interceptors.add(aliceDioAdapter);

/// Optional: resend calls from Alice with this Dio, so they use its base
/// options, interceptors and HTTP client adapter. Without it, a plain Dio is
/// used.
aliceDioAdapter.replayClient = dio;

```

## Chopper
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Chopper Adapter
AliceChopperAdapter aliceChopperAdapter = AliceChopperAdapter();

///Add adapter to Alice
alice.addAdapter(aliceChopperAdapter);

/// Create chopper client
ChopperClient chopperClient = ChopperClient(
    interceptors: [_aliceChopperAdapter],
);

```


## HTTP
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Http Adapter
AliceHttpAdapter aliceHttpAdapter = AliceHttpAdapter();

///Add adapter to Alice
alice.addAdapter(aliceHttpAdapter);
```

Use extension to intercept HTTP call:
```dart
http
    .post(Uri.tryParse('https://api.com')!, body: body)
    .interceptWithAlice(aliceHttpAdapter, body: body);
```

Use adapter to handle HTTP call:
```dart
http
    .put(Uri.tryParse('https://api.com')!, body: body)
    .then((response) {
      aliceHttpAdapter.onResponse(response, body: body);
    });
```

## HTTP Client
```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Http Adapter
AliceHttpClientAdapter aliceHttpClientAdapter = AliceHttpClientAdapter();

///Add adapter to Alice
alice.addAdapter(aliceHttpClientAdapter);

/// Http Client instance
HttpClient httpClient = HttpClient();
```

Use extension to intercept HTTP call:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com'))
    .interceptWithAlice(aliceHttpClientAdapter);
```

Use adapter to handle HTTP call:
```dart
httpClient
    .getUrl(Uri.parse('https://api.com'))
    .then((request) async {
      aliceHttpClientAdapter.onRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      aliceHttpClientAdapter.onResponse(httpResponse, request, body: responseBody);
});
```

## Edit and resend

Calls made by Dio, the http package and `HttpClient` can be sent again from
the call details: the resend button opens an editor with the method, URL,
headers and body of the call. The new call is caught by Alice like any other.
The editor starts from the real values, also when the inspector hides
sensitive ones. Form data can't be resent, because Alice keeps only the names
and sizes of form fields and files.

`AliceHttpAdapter` and `AliceHttpClientAdapter` take an optional
`replayClient`, when calls must be resent with a configured client.

An adapter of another client can support it by implementing
`AliceCallReplayer`:

```dart
class MyAdapter with AliceAdapter implements AliceCallReplayer {
  @override
  bool canReplay(AliceHttpCall call) => call.client == 'MyClient';

  @override
  Future<void> replay(AliceReplayRequest request) async {
    // Send request.method, request.url, request.headers and request.body
    // with your client, and report the call to Alice as usual.
  }
}
```

## ObjectBox

Setting up ObjectBox with Alice is simple, however, there are a few crucial steps which need to be followed.

```dart
Future<void> main() async {
  /// This is required so ObjectBox can get the application directory
  /// to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize [AliceObjectBoxStore] before running the app.
  final AliceObjectBoxStore store =
      await AliceObjectBoxStore.create(persistent: false);

  /// Pass [AliceObjectBoxStore] to the app
  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.store,
  });

  final AliceObjectBoxStore store;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
    /// Pass [AliceObjectBox] to the [Alice] constructor
    aliceStorage: AliceObjectBox(
      store: widget.store,
      maxCallsCount: 1000,
    ),
  );

  // your custom stuff...
}
```
