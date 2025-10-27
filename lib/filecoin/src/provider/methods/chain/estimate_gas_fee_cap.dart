import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Estimate gas fee cap for a message
/// [Filecoin.GasEstimateFeeCap](https://lotus.filecoin.io/reference/lotus/gas/)
class FilecoinRequestEstimateGasFeeCap extends FilecoinRequest<String, dynamic> {
  FilecoinRequestEstimateGasFeeCap(this.message, this.maxQueueBlks, this.tipSetKey);

  final Map<String, dynamic> message;
  final int maxQueueBlks;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateFeeCap;

  @override
  List<dynamic> toJson() => [message, maxQueueBlks, tipSetKey];
}

