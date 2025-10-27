import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Cancel a previously-proposed multisig message
/// [Filecoin.MsigCancel](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCancel({
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
  String get method => FilecoinMethods.msigCancel;

  @override
  List<dynamic> toJson() => [multisig, txnId, proposer];
}

