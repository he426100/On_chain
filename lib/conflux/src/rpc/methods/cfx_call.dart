import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Executes a call request immediately without creating a transaction.
/// 
/// This is used for read-only contract calls.
/// 
/// Example:
/// ```dart
/// final result = await provider.request(
///   CFXCall(
///     transaction: {
///       'to': 'cfx:...',
///       'data': '0x...', // encoded function call
///     },
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// ```
class CFXCall extends CFXRequest<String, Map<String, dynamic>> {
  CFXCall({
    required this.transaction,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The transaction call object.
  final Map<String, dynamic> transaction;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_call';

  @override
  List<dynamic> toJson() => [transaction, epochNumber.toString()];

  @override
  String onResonse(result) {
    return result.toString();
  }
}

