import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// StateLookupID retrieves the ID address of the given address
/// [Filecoin.StateLookupID](https://lotus.filecoin.io/reference/lotus/state/)
class FilecoinRequestStateLookupID extends FilecoinRequest<String, dynamic> {
  FilecoinRequestStateLookupID(this.address, {this.tipSetKey});

  /// The address to convert to ID address
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateLookupID;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

