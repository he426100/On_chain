import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateAccountKey returns the public key address of the given ID address
/// [Filecoin.StateAccountKey](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateAccountKey extends FilecoinRequest<String, dynamic> {
  FilecoinRequestStateAccountKey(this.address, {this.tipSetKey});

  /// The ID address to convert (e.g., "f0123")
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateAccountKey;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

