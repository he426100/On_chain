import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get code at a given address
/// This is equivalent to Ethereum's eth_getCode
/// [Filecoin.EthGetCode](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
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

