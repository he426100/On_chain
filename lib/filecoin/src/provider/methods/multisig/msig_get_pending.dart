import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get pending transactions for a multisig wallet
/// [Filecoin.MsigGetPending](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigGetPending
    extends FilecoinRequest<List<dynamic>, List<dynamic>> {
  FilecoinRequestMsigGetPending(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.msigGetPending;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

