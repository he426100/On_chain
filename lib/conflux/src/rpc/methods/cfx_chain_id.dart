import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the chain ID of the current network.
/// 
/// Example:
/// ```dart
/// final chainId = await provider.request(CFXChainId());
/// print('Chain ID: $chainId'); // 1029 for mainnet, 1 for testnet
/// ```
class CFXChainId extends CFXRequest<BigInt, String> {
  const CFXChainId();

  @override
  String get method => 'cfx_chainId';

  @override
  List<dynamic> toJson() => [];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

/// Returns the network ID.
/// 
/// Alias for `cfx_netVersion`.
class CFXNetVersion extends CFXRequest<BigInt, String> {
  const CFXNetVersion();

  @override
  String get method => 'cfx_netVersion';

  @override
  List<dynamic> toJson() => [];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

