import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get the number of transactions sent from an address
/// This is equivalent to Ethereum's eth_getTransactionCount
/// [Filecoin.EthGetTransactionCount](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
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

