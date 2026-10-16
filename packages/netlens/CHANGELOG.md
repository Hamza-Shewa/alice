# 1.0.0

* First release of NetLens, a fork of [Alice](https://github.com/jhomlala/alice) 1.0.0 under a new name.
* Hides sensitive headers, cookies, query parameters and body fields in the inspector and masks them in shared and saved calls. Configure it with `NetLensConfiguration.redaction`.
* Adds quick filters by status group, method and host, and searches headers, bodies, errors and GraphQL operation names.
* Adds edit and resend for adapters that implement `NetLensCallReplayer`.
* Adds a collapsible JSON viewer with search, copy value and copy path.
* Adds HAR 1.2 export for Chrome DevTools, Proxyman and Charles.
* Shows GraphQL operation types, names, batches and errors.
* Adds a timeline of calls and the slowest endpoints in statistics.
