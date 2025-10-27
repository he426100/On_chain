import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Cancel a previously-proposed multisig message with transaction hash
/// [Filecoin.MsigCancelTxnHash](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigCancelTxnHash
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCancelTxnHash({
    required this.multisig,
    required this.txnId,
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

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the cancellation from
  final String from;

  /// Method number
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigCancelTxnHash;

  @override
  List<dynamic> toJson() =>
      [multisig, txnId, to, value, from, methodNum, params];
}

