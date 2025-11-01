import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the bytecode of a smart contract.
/// 
/// Example:
/// ```dart
/// final bytecode = await provider.request(
///   CFXGetCode(
///     address: 'cfx:...',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// ```
class CFXGetCode extends CFXRequest<String, Map<String, dynamic>> {
  CFXGetCode({
    required this.address,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The contract address (Base32 format).
  final String address;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_getCode';

  @override
  List<dynamic> toJson() => [address, epochNumber.toString()];

  @override
  String onResonse(result) {
    return result.toString();
  }
}

