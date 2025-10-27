import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Propose the removal of a signer from the multisig
/// [Filecoin.MsigRemoveSigner](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigRemoveSigner
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigRemoveSigner({
    required this.multisig,
    required this.from,
    required this.toRemove,
    required this.decrease,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to remove as a signer
  final String toRemove;

  /// Whether to decrease the required approvals
  final bool decrease;

  @override
  String get method => FilecoinMethods.msigRemoveSigner;

  @override
  List<dynamic> toJson() => [multisig, from, toRemove, decrease];
}

