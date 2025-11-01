import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the current max priority fee per gas (in Drip).
/// 
/// This is used for EIP-1559 style transactions to determine
/// the priority fee to offer miners.
/// 
/// Example:
/// ```dart
/// final maxPriorityFee = await provider.request(
///   CFXMaxPriorityFeePerGas(),
/// );
/// print('Max priority fee: $maxPriorityFee Drip');
/// ```
class CFXMaxPriorityFeePerGas extends CFXRequest<BigInt, String> {
  CFXMaxPriorityFeePerGas();

  @override
  String get method => 'cfx_maxPriorityFeePerGas';

  @override
  List<dynamic> toJson() => [];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

