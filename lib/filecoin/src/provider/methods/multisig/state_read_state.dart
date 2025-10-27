import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Read state of an actor (used for multisig wallet state)
/// [Filecoin.StateReadState](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateReadState
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestStateReadState(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateReadState;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

