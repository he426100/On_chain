import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get available balance for a multisig wallet
/// [Filecoin.MsigGetAvailableBalance](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigGetAvailableBalance
    extends FilecoinRequest<String, dynamic> {
  FilecoinRequestMsigGetAvailableBalance(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.msigGetAvailableBalance;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

