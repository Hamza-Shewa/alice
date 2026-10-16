## Configuration

1. Create Alice instance:

```dart

Alice alice = Alice();
```

2. Add navigator key to your application:

```dart
MaterialApp(navigatorKey: alice.getNavigatorKey(), home: ...);
```

You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in Alice:

```dart

Alice alice = Alice(configuration: AliceConfiguration(navigatorKey: yourNavigatorKeyHere));
```

If you need to pass navigatorKey lazily, you can use:

```dart
alice.setNavigatorKey(yourNavigatorKeyHere);
```

This is minimal configuration required to run Alice. Can set optional settings in Alice constructor,
which are presented below. If you don't want to change anything, you can move to Http clients
configuration.

### Alice configuration

You can pass optional `AliceConfiguration` parameter to `Alice` instance.

You can set `showNotification` in Alice constructor to show notification. Clicking on this
notification will open inspector.

```dart

Alice alice = Alice(configuration: AliceConfiguration(showNotification: true));
```

You can set `showInspectorOnShake` in Alice constructor to open inspector by shaking your device (
default disabled):

```dart

Alice alice = Alice(configuration: AliceConfiguation(showInspectorOnShake: true));
```

If you want to pass another notification icon, you can use `notificationIcon` parameter. Default
value is @mipmap/ic_launcher.

```dart

Alice alice = Alice(configuration: AliceConfiguration(notificationIcon: "myNotificationIconResourceName"));
```

If you want to change the Directionality of Alice, you can use the `directionality` parameter. If
the parameter is set to null, the Directionality of the app will be used.

```dart

Alice alice = Alice(configuration: AliceConfiguration(directionality: TextDirection.ltr));
```

If you want to hide share button, you can use `showShareButton` parameter.

```dart

Alice alice = Alice(configuration: AliceConfiguration(showShareButton: false));
```

### Sensitive values

Alice hides credentials in the inspector and masks them in everything which
leaves the app: shared calls, saved files, copied calls, cURL commands and HAR
exports. By default it covers common headers (`Authorization`, `Cookie`,
`Set-Cookie`, `X-Api-Key` and others), JSON body and form fields (`password`,
`token`, `access_token`, `refresh_token`, `client_secret` and others) and query
parameters (`token`, `api_key`, `signature` and others). In the call details,
the eye button shows the hidden values on screen.

Use your own names, matched without case at any depth of a JSON body:

```dart
Alice alice = Alice(
  configuration: AliceConfiguration(
    redaction: AliceRedaction(
      headers: {...AliceRedaction.defaultHeaders, 'x-session'},
      bodyFields: {...AliceRedaction.defaultBodyFields, 'pin'},
      mask: '[hidden]',
    ),
  ),
);
```

Turn it off with `AliceRedaction.none`:

```dart
Alice alice = Alice(configuration: AliceConfiguration(redaction: AliceRedaction.none));
```

