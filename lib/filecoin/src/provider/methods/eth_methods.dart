import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Filecoin Ethereum-compatible RPC methods
/// These methods are part of the Filecoin EVM runtime (FEVM)
/// See: https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime
///
/// Filecoin supports Ethereum JSON-RPC API with method aliases:
/// eth_call -> Filecoin.EthCall
/// eth_getBalance -> Filecoin.EthGetBalance
/// etc.

/// Execute a read-only smart contract call using Ethereum JSON-RPC
/// This is equivalent to Ethereum's eth_call
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

/// Get the balance of an Ethereum address using Ethereum JSON-RPC
/// This is equivalent to Ethereum's eth_getBalance
class FilecoinRequestEthGetBalance extends FilecoinRequest<String, String> {
  FilecoinRequestEthGetBalance(this.address, [this.blockTag = 'latest']);

  /// Ethereum address (0x-prefixed)
  final String address;

  /// Block number or tag (latest, earliest, pending)
  final String blockTag;

  @override
  String get method => 'Filecoin.EthGetBalance';

  @override
  List<dynamic> toJson() => [address, blockTag];
}

/// Get the number of transactions sent from an address
/// This is equivalent to Ethereum's eth_getTransactionCount
class FilecoinRequestEthGetTransactionCount extends FilecoinRequest<String, String> {
  FilecoinRequestEthGetTransactionCount(this.address, [this.blockTag = 'latest']);

  /// Ethereum address (0x-prefixed)
  final String address;

  /// Block number or tag (latest, earliest, pending)
  final String blockTag;

  @override
  String get method => 'Filecoin.EthGetTransactionCount';

  @override
  List<dynamic> toJson() => [address, blockTag];
}

/// Get code at a given address
/// This is equivalent to Ethereum's eth_getCode
class FilecoinRequestEthGetCode extends FilecoinRequest<String, String> {
  FilecoinRequestEthGetCode(this.address, [this.blockTag = 'latest']);

  /// Ethereum address (0x-prefixed)
  final String address;

  /// Block number or tag (latest, earliest, pending)
  final String blockTag;

  @override
  String get method => 'Filecoin.EthGetCode';

  @override
  List<dynamic> toJson() => [address, blockTag];
}

/// Get storage at a specific position of an address
/// This is equivalent to Ethereum's eth_getStorageAt
class FilecoinRequestEthGetStorageAt extends FilecoinRequest<String, String> {
  FilecoinRequestEthGetStorageAt(this.address, this.position, [this.blockTag = 'latest']);

  /// Ethereum address (0x-prefixed)
  final String address;

  /// Storage position (0x-prefixed hex)
  final String position;

  /// Block number or tag (latest, earliest, pending)
  final String blockTag;

  @override
  String get method => 'Filecoin.EthGetStorageAt';

  @override
  List<dynamic> toJson() => [address, position, blockTag];
}

/// Estimate gas needed for a transaction
/// This is equivalent to Ethereum's eth_estimateGas
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

/// Get the current chain ID
/// This is equivalent to Ethereum's eth_chainId
class FilecoinRequestEthChainId extends FilecoinRequest<String, String> {
  FilecoinRequestEthChainId();

  @override
  String get method => 'Filecoin.EthChainId';

  @override
  List<dynamic> toJson() => [];
}

/// Get the current block number
/// This is equivalent to Ethereum's eth_blockNumber
class FilecoinRequestEthBlockNumber extends FilecoinRequest<String, String> {
  FilecoinRequestEthBlockNumber();

  @override
  String get method => 'Filecoin.EthBlockNumber';

  @override
  List<dynamic> toJson() => [];
}

/// Get the current gas price
/// This is equivalent to Ethereum's eth_gasPrice
class FilecoinRequestEthGasPrice extends FilecoinRequest<String, String> {
  FilecoinRequestEthGasPrice();

  @override
  String get method => 'Filecoin.EthGasPrice';

  @override
  List<dynamic> toJson() => [];
}
