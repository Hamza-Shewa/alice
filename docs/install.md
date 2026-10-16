# How to install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  netlens: ^1.0.0
```

2. Choose adapter based on your HTTP client. **pubspec.yaml** file:

### Dio

```yaml
dependencies:
  netlens_dio: ^1.0.0
```

### Chopper

```yaml
dependencies:
  netlens_chopper: ^1.0.0
```

### Http

```yaml
dependencies:
  netlens_http: ^1.0.0
```

### Http Client

```yaml
dependencies:
  netlens_http_client: ^1.0.0
```

3. Choose optional database:

### Objectbox

```yaml
dependencies:
  objectbox: any
  netlens_objectbox: ^1.0.0
```

4. Run `get` command:

```bash
$ flutter pub get
```