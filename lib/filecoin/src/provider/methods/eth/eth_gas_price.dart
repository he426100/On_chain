import 'package:on_chain/filecoin/src/provider/core/request.dart';

/// Get the current gas price
/// This is equivalent to Ethereum's eth_gasPrice
/// [Filecoin.EthGasPrice](https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/)
class FilecoinRequestEthGasPrice extends FilecoinRequest<String, String> {
  FilecoinRequestEthGasPrice();

  @override
  String get method => 'Filecoin.EthGasPrice';

  @override
  List<dynamic> toJson() => [];
}

