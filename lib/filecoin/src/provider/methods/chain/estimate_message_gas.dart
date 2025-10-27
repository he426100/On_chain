import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Estimate gas for a message - fills in all unset gas fields
/// [Filecoin.GasEstimateMessageGas](https://lotus.filecoin.io/reference/lotus/gas/)
class FilecoinRequestEstimateMessageGas extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestEstimateMessageGas(this.message, this.spec, this.tipSetKey);

  final Map<String, dynamic> message;
  final Map<String, dynamic>? spec;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateMessageGas;

  @override
  List<dynamic> toJson() => [message, spec, tipSetKey];
}

