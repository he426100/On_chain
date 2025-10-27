import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateGetActor returns the indicated actor's nonce and balance
/// [Filecoin.StateGetActor](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateGetActor extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestStateGetActor(this.address, {this.tipSetKey});

  /// The address of the actor to query
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateGetActor;

  @override
  List<dynamic> toJson() => [address, tipSetKey];
}

