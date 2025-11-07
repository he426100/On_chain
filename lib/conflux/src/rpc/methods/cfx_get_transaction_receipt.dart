import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the receipt of a transaction by transaction hash.
/// 
/// Returns null if the transaction is pending or doesn't exist.
/// 
/// Example:
/// ```dart
/// final receipt = await provider.request(
///   CFXGetTransactionReceipt(transactionHash: '0x...'),
/// );
/// 
/// if (receipt != null) {
///   final status = receipt['outcomeStatus'];
///   print('Transaction status: $status'); // 0 = success, 1 = failed
/// }
/// ```
class CFXGetTransactionReceipt
    extends CFXRequest<Map<String, dynamic>?, Map<String, dynamic>> {
  CFXGetTransactionReceipt({required this.transactionHash});

  /// The transaction hash.
  final String transactionHash;

  @override
  String get method => 'cfx_getTransactionReceipt';

  @override
  List<dynamic> toJson() => [transactionHash];

  @override
  Map<String, dynamic>? onResonse(result) {
    // RPC returns null for pending or non-existent transactions
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }
}

