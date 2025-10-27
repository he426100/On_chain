import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Propose swapping two signers in the multisig
/// [Filecoin.MsigSwapPropose](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigSwapPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapPropose({
    required this.multisig,
    required this.from,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapPropose;

  @override
  List<dynamic> toJson() => [multisig, from, oldSigner, newSigner];
}

