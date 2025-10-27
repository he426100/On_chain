import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Approve a previously-proposed multisig message with transaction hash
/// [Filecoin.MsigApproveTxnHash](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigApproveTxnHash
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigApproveTxnHash({
    required this.multisig,
    required this.txnId,
    required this.proposer,
    required this.to,
    required this.value,
    required this.from,
    required this.methodNum,
    required this.params,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the approval from
  final String from;

  /// Method number
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigApproveTxnHash;

  @override
  List<dynamic> toJson() =>
      [multisig, txnId, proposer, to, value, from, methodNum, params];
}

