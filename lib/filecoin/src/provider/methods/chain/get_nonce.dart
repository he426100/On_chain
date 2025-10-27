import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get nonce for an address from the message pool
/// [Filecoin.MpoolGetNonce](https://lotus.filecoin.io/reference/lotus/mpool/)
class FilecoinRequestGetNonce extends FilecoinRequest<int, dynamic> {
  FilecoinRequestGetNonce(this.address);

  final String address;

  @override
  String get method => FilecoinMethods.mpoolGetNonce;

  @override
  List<dynamic> toJson() => [address];
}

