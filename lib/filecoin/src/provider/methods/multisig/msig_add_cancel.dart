import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Cancel a previously proposed AddSigner message
/// [Filecoin.MsigAddCancel](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigAddCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddCancel({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the cancellation from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddCancel;

  @override
  List<dynamic> toJson() => [multisig, from, txnId, newSigner, increase];
}

