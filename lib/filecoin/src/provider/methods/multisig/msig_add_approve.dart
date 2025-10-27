import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Approve a previously proposed AddSigner message
/// [Filecoin.MsigAddApprove](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigAddApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddApprove({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.proposer,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the approval from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddApprove;

  @override
  List<dynamic> toJson() =>
      [multisig, from, txnId, proposer, newSigner, increase];
}

