import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Approve a previously proposed SwapSigner message
/// [Filecoin.MsigSwapApprove](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigSwapApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapApprove({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.proposer,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the approval from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapApprove;

  @override
  List<dynamic> toJson() =>
      [multisig, from, txnId, proposer, oldSigner, newSigner];
}

