import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get storage at a specific position of an address
/// This is equivalent to Ethereum's eth_getStorageAt
/// [Filecoin.EthGetStorageAt](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
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

