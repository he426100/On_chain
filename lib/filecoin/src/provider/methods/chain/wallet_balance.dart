import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get balance of an address
/// [Filecoin.WalletBalance](https://lotus.filecoin.io/reference/lotus/wallet/)
class FilecoinRequestWalletBalance extends FilecoinRequest<String, dynamic> {
  FilecoinRequestWalletBalance(this.address);

  final String address;

  @override
  String get method => FilecoinMethods.walletBalance;

  @override
  List<dynamic> toJson() => [address];
}

