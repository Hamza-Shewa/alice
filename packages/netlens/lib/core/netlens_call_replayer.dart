import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_replay_request.dart';

/// Implemented by adapters which can send a caught call again with their own
/// HTTP client. The new call goes through the adapter, so it is caught by
/// NetLens like any other call.
abstract interface class NetLensCallReplayer {
  /// Returns true when [call] was made by the client of this adapter.
  bool canReplay(NetLensHttpCall call);

  /// Sends [request]. Completes when the response or the error was received.
  Future<void> replay(NetLensReplayRequest request);
}
