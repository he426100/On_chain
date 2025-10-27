import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Create a multisig wallet
/// [Filecoin.MsigCreate](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigCreate
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCreate({
    required this.required,
    required this.signers,
    required this.unlockDuration,
    required this.value,
    required this.from,
    required this.initialBalance,
  });

  /// Number of required approvals
  final int required;

  /// List of signer addresses
  final List<String> signers;

  /// Unlock duration in epochs
  final int unlockDuration;

  /// Value to send with the message
  final String value;

  /// Address to send the message from
  final String from;

  /// Initial balance for the multisig wallet
  final String initialBalance;

  @override
  String get method => FilecoinMethods.msigCreate;

  @override
  List<dynamic> toJson() =>
      [required, signers, unlockDuration, value, from, initialBalance];
}

