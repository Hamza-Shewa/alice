import 'dart:convert';
import 'dart:io';

import 'package:netlens/netlens.dart';
import 'package:netlens/model/netlens_configuration.dart';
import 'package:netlens_http_client/netlens_http_client_adapter.dart';
import 'package:netlens_http_client/netlens_http_client_extensions.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final HttpClient _httpClient = HttpClient();

  late final NetLensHttpClientAdapter _httpClientAdapter =
      NetLensHttpClientAdapter();

  final configuration = NetLensConfiguration();
  late final NetLens _netLens = NetLens(configuration: configuration)
    ..addAdapter(_httpClientAdapter);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _netLens.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('NetLens + HTTP Client - Example')),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to example of NetLens Http Inspector.'
                ' Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runHttpHttpClientRequests,
                child: const Text('Run HttpClient Requests'),
              ),
              const SizedBox(height: 8),
              const Text(
                'After clicking on buttons above, you should receive'
                ' notification. Click on it to show inspector. You can '
                'also shake your device or click button below.',
              ),
              ElevatedButton(
                onPressed: _runHttpInspector,
                child: const Text('Run HTTP Inspector'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runHttpHttpClientRequests() {
    final Map<String, dynamic> body = {
      'title': 'foo',
      'body': 'bar',
      'userId': '1',
    };

    _httpClient
        .getUrl(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .interceptWithNetLens(_httpClientAdapter);

    _httpClient
        .postUrl(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .interceptWithNetLens(_httpClientAdapter, body: body, headers: {});

    _httpClient
        .putUrl(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .interceptWithNetLens(_httpClientAdapter, body: body);

    _httpClient
        .getUrl(Uri.https('jsonplaceholder.typicode.com', '/test/test/'))
        .interceptWithNetLens(_httpClientAdapter);

    _httpClient
        .postUrl(Uri.https('jsonplaceholder.typicode.com', '/posts'))
        .then((HttpClientRequest request) async {
          _httpClientAdapter.onRequest(request, body: body);

          request.write(body);

          final HttpClientResponse httpResponse = await request.close();

          final String responseBody =
              await utf8.decoder.bind(httpResponse).join();

          _httpClientAdapter.onResponse(
            httpResponse,
            request,
            body: responseBody,
          );
        });

    _httpClient
        .putUrl(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .then((HttpClientRequest request) async {
          _httpClientAdapter.onRequest(request, body: body);

          request.write(body);

          final HttpClientResponse httpResponse = await request.close();

          final String responseBody =
              await utf8.decoder.bind(httpResponse).join();

          _httpClientAdapter.onResponse(
            httpResponse,
            request,
            body: responseBody,
          );
        });

    _httpClient
        .patchUrl(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .then((HttpClientRequest request) async {
          _httpClientAdapter.onRequest(request, body: body);

          request.write(body);

          final HttpClientResponse httpResponse = await request.close();
          final String responseBody =
              await utf8.decoder.bind(httpResponse).join();

          _httpClientAdapter.onResponse(
            httpResponse,
            request,
            body: responseBody,
          );
        });

    _httpClient
        .deleteUrl(Uri.https('jsonplaceholder.typicode.com', '/posts/1'))
        .then((HttpClientRequest request) async {
          _httpClientAdapter.onRequest(request);

          final HttpClientResponse httpResponse = await request.close();

          final String responseBody =
              await utf8.decoder.bind(httpResponse).join();

          _httpClientAdapter.onResponse(
            httpResponse,
            request,
            body: responseBody,
          );
        });

    _httpClient
        .getUrl(Uri.https('jsonplaceholder.typicode.com', '/test/test/'))
        .then((HttpClientRequest request) async {
          _httpClientAdapter.onRequest(request);

          final HttpClientResponse httpResponse = await request.close();

          final String responseBody =
              await utf8.decoder.bind(httpResponse).join();

          _httpClientAdapter.onResponse(
            httpResponse,
            request,
            body: responseBody,
          );
        });
  }

  void _runHttpInspector() {
    _netLens.showInspector();
  }
}
