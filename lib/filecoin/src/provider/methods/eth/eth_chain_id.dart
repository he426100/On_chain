import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get the current chain ID
/// This is equivalent to Ethereum's eth_chainId
/// [Filecoin.EthChainId](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
class FilecoinRequestEthChainId extends FilecoinRequest<String, String> {
  FilecoinRequestEthChainId();

  @override
  String get method => 'Filecoin.EthChainId';

  @override
  List<dynamic> toJson() => [];
}

