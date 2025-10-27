import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateListMessages looks back and returns all messages with a matching to or from address,
/// stopping at the given height
/// [Filecoin.StateListMessages](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateListMessages extends FilecoinRequest<List<Map<String, dynamic>>, List<dynamic>> {
  FilecoinRequestStateListMessages({this.to, this.from, this.tipSetKey, required this.toHeight});

  /// Filter by 'to' address (optional)
  final String? to;

  /// Filter by 'from' address (optional)
  final String? from;

  /// Optional tipset key to start search from (null means start from chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  /// Epoch height to stop at
  final int toHeight;

  @override
  String get method => FilecoinMethods.stateListMessages;

  @override
  List<dynamic> toJson() {
    final match = <String, dynamic>{};
    if (to != null) match['To'] = to;
    if (from != null) match['From'] = from;

    return [match, tipSetKey, toHeight];
  }
}

