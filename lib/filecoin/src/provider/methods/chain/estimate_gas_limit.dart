import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Estimate gas limit for a message
/// [Filecoin.GasEstimateGasLimit](https://lotus.filecoin.io/reference/lotus/gas/)
class FilecoinRequestEstimateGasLimit extends FilecoinRequest<int, dynamic> {
  FilecoinRequestEstimateGasLimit(this.message, this.tipSetKey);

  final Map<String, dynamic> message;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateGasLimit;

  @override
  List<dynamic> toJson() => [message, tipSetKey];
}

