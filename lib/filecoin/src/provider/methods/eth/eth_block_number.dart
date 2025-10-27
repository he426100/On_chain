import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get the current block number
/// This is equivalent to Ethereum's eth_blockNumber
/// [Filecoin.EthBlockNumber](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
class FilecoinRequestEthBlockNumber extends FilecoinRequest<String, String> {
  FilecoinRequestEthBlockNumber();

  @override
  String get method => 'Filecoin.EthBlockNumber';

  @override
  List<dynamic> toJson() => [];
}

