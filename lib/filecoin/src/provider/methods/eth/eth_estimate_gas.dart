import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Estimate gas needed for a transaction
/// This is equivalent to Ethereum's eth_estimateGas
/// [Filecoin.EthEstimateGas](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
class FilecoinRequestEthEstimateGas extends FilecoinRequest<String, String> {
  FilecoinRequestEthEstimateGas({
    required this.to,
    this.from,
    this.gas,
    this.gasPrice,
    this.value,
    this.data,
  });

  /// Recipient address
  final String to;

  /// Optional sender address
  final String? from;

  /// Optional gas limit
  final String? gas;

  /// Optional gas price
  final String? gasPrice;

  /// Optional value to send
  final String? value;

  /// Optional transaction data
  final String? data;

  @override
  String get method => 'Filecoin.EthEstimateGas';

  @override
  List<dynamic> toJson() {
    final txObject = <String, dynamic>{
      'to': to,
    };

    if (from != null) txObject['from'] = from;
    if (gas != null) txObject['gas'] = gas;
    if (gasPrice != null) txObject['gasPrice'] = gasPrice;
    if (value != null) txObject['value'] = value;
    if (data != null) txObject['data'] = data;

    return [txObject];
  }
}

