import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get vested amount for a multisig wallet
/// [Filecoin.MsigGetVested](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigGetVested extends FilecoinRequest<String, dynamic> {
  FilecoinRequestMsigGetVested(this.address, this.startTipSetKey, this.endTipSetKey);

  final String address;
  final List<Map<String, dynamic>> startTipSetKey;
  final List<Map<String, dynamic>> endTipSetKey;

  @override
  String get method => FilecoinMethods.msigGetVested;

  @override
  List<dynamic> toJson() => [address, startTipSetKey, endTipSetKey];
}

