import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_replay_request.dart';

/// Implemented by adapters which can send a caught call again with their own
/// HTTP client. The new call goes through the adapter, so it is caught by
/// Alice like any other call.
abstract interface class AliceCallReplayer {
  /// Returns true when [call] was made by the client of this adapter.
  bool canReplay(AliceHttpCall call);

  /// Sends [request]. Completes when the response or the error was received.
  Future<void> replay(AliceReplayRequest request);
}
