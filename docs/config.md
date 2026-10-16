## Configuration

1. Create NetLens instance:

```dart

NetLens netLens = NetLens();
```

2. Add navigator key to your application:

```dart
MaterialApp(navigatorKey: netLens.getNavigatorKey(), home: ...);
```

You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in NetLens:

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguration(navigatorKey: yourNavigatorKeyHere));
```

If you need to pass navigatorKey lazily, you can use:

```dart
netLens.setNavigatorKey(yourNavigatorKeyHere);
```

This is minimal configuration required to run NetLens. Can set optional settings in NetLens constructor,
which are presented below. If you don't want to change anything, you can move to Http clients
configuration.

### NetLens configuration

You can pass optional `NetLensConfiguration` parameter to `NetLens` instance.

You can set `showNotification` in NetLens constructor to show notification. Clicking on this
notification will open inspector.

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguration(showNotification: true));
```

You can set `showInspectorOnShake` in NetLens constructor to open inspector by shaking your device (
default disabled):

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguation(showInspectorOnShake: true));
```

If you want to pass another notification icon, you can use `notificationIcon` parameter. Default
value is @mipmap/ic_launcher.

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguration(notificationIcon: "myNotificationIconResourceName"));
```

If you want to change the Directionality of NetLens, you can use the `directionality` parameter. If
the parameter is set to null, the Directionality of the app will be used.

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguration(directionality: TextDirection.ltr));
```

If you want to hide share button, you can use `showShareButton` parameter.

```dart

NetLens netLens = NetLens(configuration: NetLensConfiguration(showShareButton: false));
```

### Sensitive values

NetLens hides credentials in the inspector and masks them in everything which
leaves the app: shared calls, saved files, copied calls, cURL commands and HAR
exports. By default it covers common headers (`Authorization`, `Cookie`,
`Set-Cookie`, `X-Api-Key` and others), JSON body and form fields (`password`,
`token`, `access_token`, `refresh_token`, `client_secret` and others) and query
parameters (`token`, `api_key`, `signature` and others). In the call details,
the eye button shows the hidden values on screen.

Use your own names, matched without case at any depth of a JSON body:

```dart
NetLens netLens = NetLens(
  configuration: NetLensConfiguration(
    redaction: NetLensRedaction(
      headers: {...NetLensRedaction.defaultHeaders, 'x-session'},
      bodyFields: {...NetLensRedaction.defaultBodyFields, 'pin'},
      mask: '[hidden]',
    ),
  ),
);
```

Turn it off with `NetLensRedaction.none`:

```dart
NetLens netLens = NetLens(configuration: NetLensConfiguration(redaction: NetLensRedaction.none));
```

