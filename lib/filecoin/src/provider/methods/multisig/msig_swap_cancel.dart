import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Cancel a previously proposed SwapSigner message
/// [Filecoin.MsigSwapCancel](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigSwapCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapCancel({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the cancellation from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapCancel;

  @override
  List<dynamic> toJson() => [multisig, from, txnId, oldSigner, newSigner];
}

