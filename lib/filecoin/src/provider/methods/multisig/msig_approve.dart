import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Approve a previously-proposed multisig message by transaction ID
/// [Filecoin.MsigApprove](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigApprove({
    required this.multisig,
    required this.txnId,
    required this.proposer,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  @override
  String get method => FilecoinMethods.msigApprove;

  @override
  List<dynamic> toJson() => [multisig, txnId, proposer];
}

