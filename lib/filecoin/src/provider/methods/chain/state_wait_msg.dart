import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateWaitMsg looks back in the chain for a message. If not found, it blocks
/// until the message arrives on chain, and gets to the indicated confidence depth
/// [Filecoin.StateWaitMsg](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateWaitMsg extends FilecoinRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  FilecoinRequestStateWaitMsg(this.messageCid, {this.confidence = 2, this.lookbackLimit = 100, this.allowReplaced = true});

  /// The CID of the message to wait for
  final Map<String, dynamic> messageCid;

  /// Number of confirmations to wait for (default: 2)
  final int confidence;

  /// Number of epochs to look back (default: 100)
  final int lookbackLimit;

  /// Allow replaced messages (default: true)
  final bool allowReplaced;

  @override
  String get method => FilecoinMethods.stateWaitMsg;

  @override
  List<dynamic> toJson() => [messageCid, confidence, lookbackLimit, allowReplaced];
}

