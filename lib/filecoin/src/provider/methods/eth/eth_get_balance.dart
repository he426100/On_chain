import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get the balance of an Ethereum address using Ethereum JSON-RPC
/// This is equivalent to Ethereum's eth_getBalance
/// [Filecoin.EthGetBalance](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
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

