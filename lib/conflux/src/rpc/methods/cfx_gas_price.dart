import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the current gas price in Drip.
/// 
/// Example:
/// ```dart
/// final gasPrice = await provider.request(CFXGasPrice());
/// print('Gas price: $gasPrice Drip');
/// ```
class CFXGasPrice extends CFXRequest<BigInt, Map<String, dynamic>> {
  const CFXGasPrice();

  @override
  String get method => 'cfx_gasPrice';

  @override
  List<dynamic> toJson() => [];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

