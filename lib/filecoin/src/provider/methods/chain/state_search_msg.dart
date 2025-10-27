import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateSearchMsg looks back up to limit epochs in the chain for a message,
/// and returns its receipt and the tipset where it was executed
/// [Filecoin.StateSearchMsg](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateSearchMsg extends FilecoinRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  FilecoinRequestStateSearchMsg(this.messageCid, {this.tipSetKey, this.lookbackLimit = 100, this.allowReplaced = true});

  /// The CID of the message to search for
  final Map<String, dynamic> messageCid;

  /// Optional tipset key to start search from (null means start from chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  /// Number of epochs to look back (default: 100)
  final int lookbackLimit;

  /// Allow replaced messages (default: true)
  final bool allowReplaced;

  @override
  String get method => FilecoinMethods.stateSearchMsg;

  @override
  List<dynamic> toJson() => [tipSetKey, messageCid, lookbackLimit, allowReplaced];
}

