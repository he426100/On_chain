import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Propose adding a signer to the multisig
/// [Filecoin.MsigAddPropose](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigAddPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddPropose({
    required this.multisig,
    required this.from,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddPropose;

  @override
  List<dynamic> toJson() => [multisig, from, newSigner, increase];
}

