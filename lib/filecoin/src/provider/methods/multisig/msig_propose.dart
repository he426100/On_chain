import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Propose a multisig message
/// [Filecoin.MsigPropose](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigPropose({
    required this.multisig,
    required this.to,
    required this.value,
    required this.from,
    required this.methodNum,
    required this.params,
  });

  /// Multisig wallet address
  final String multisig;

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the proposal from
  final String from;

  /// Method number to call
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigPropose;

  @override
  List<dynamic> toJson() => [multisig, to, value, from, methodNum, params];
}

