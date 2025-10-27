import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Estimate gas premium for a message
/// [Filecoin.GasEstimateGasPremium](https://lotus.filecoin.io/reference/lotus/gas/)
class FilecoinRequestEstimateGasPremium extends FilecoinRequest<String, dynamic> {
  FilecoinRequestEstimateGasPremium(this.nblocksincl, this.sender, this.gasLimit, this.tipSetKey);

  final int nblocksincl;
  final String sender;
  final int gasLimit;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateGasPremium;

  @override
  List<dynamic> toJson() => [nblocksincl, sender, gasLimit, tipSetKey];
}

