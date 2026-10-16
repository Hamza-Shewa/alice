import 'package:netlens/core/netlens_core.dart';

/// Adapter mixin which is used in http client adapters.
mixin NetLensAdapter {
  late final NetLensCore netLensCore;

  /// Injects [NetLensCore] into adapter.
  void injectCore(NetLensCore netLensCore) => this.netLensCore = netLensCore;
}
