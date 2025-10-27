import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Execute a read-only smart contract call using Ethereum JSON-RPC
/// This is equivalent to Ethereum's eth_call
/// [Filecoin.EthCall](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/fil-addr/)
class FilecoinRequestEthCall extends FilecoinRequest<String, String> {
  FilecoinRequestEthCall({
    required this.to,
    required this.data,
    this.from,
    this.gas,
    this.gasPrice,
    this.value,
  });

  /// Contract address to call
  final String to;

  /// Encoded function call data (0x-prefixed hex string)
  final String data;

  /// Optional sender address
  final String? from;

  /// Optional gas limit
  final String? gas;

  /// Optional gas price
  final String? gasPrice;

  /// Optional value to send (in attoFIL)
  final String? value;

  @override
  String get method => 'Filecoin.EthCall';

  @override
  List<dynamic> toJson() {
    final callObject = <String, dynamic>{
      'to': to,
      'data': data,
    };

    if (from != null) callObject['from'] = from;
    if (gas != null) callObject['gas'] = gas;
    if (gasPrice != null) callObject['gasPrice'] = gasPrice;
    if (value != null) callObject['value'] = value;

    // Second parameter is block number/tag - using 'latest'
    return [callObject, 'latest'];
  }
}

