## Other usages

## Show inspector manually

You may need that if you won't use shake or notification:

```dart
alice.showInspector();
```

## Flutter logs

If you want to log Flutter logs in Alice, you may use these methods:

```dart
alice.addLog(log);

alice.addLogs(logList);
```


## Inspector state

Check current inspector state (opened/closed) with:

```dart
alice.isInspectorOpened();
```

## Filters and search

The search in the calls list looks in URLs, methods, status codes, GraphQL
operations, headers and bodies. Chips above the list filter calls by status
(2xx, 3xx, 4xx, 5xx, failed, pending), by method and by host.

## JSON viewer

JSON bodies open in a collapsible tree. You can expand or collapse all nodes,
search keys and values, and tap a value to copy it or its path, for example
`$.data.items[0].id`. The Raw button shows the formatted text.

## HAR export

The menu of the calls list has Export HAR. It saves all calls as a HAR 1.2
file and opens the share sheet, so the file can be opened in Chrome DevTools,
Proxyman, Charles or any other tool which reads HAR. Sensitive values are
masked.

## GraphQL

Calls with a GraphQL body (a JSON body with a `query`, or a GET with a `query`
parameter) show their operation, for example `query GetUser`, instead of the
endpoint. A response with an `errors` list is marked, because GraphQL servers
usually report errors with status 200.

## Timeline and slowest endpoints

Timeline in the menu of the calls list shows the latest calls as bars on a
time axis, so calls which run at the same time and slow calls stand out. The
stats page lists the slowest endpoints with median (p50), 95th percentile
(p95) and longest time. IDs in paths are grouped, so `/users/1` and
`/users/2` count as `/users/{id}`.

