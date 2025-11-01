import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns transaction information by transaction hash.
/// 
/// Example:
/// ```dart
/// final tx = await provider.request(
///   CFXGetTransactionByHash(transactionHash: '0x...'),
/// );
/// ```
class CFXGetTransactionByHash
    extends CFXRequest<Map<String, dynamic>?, Map<String, dynamic>> {
  CFXGetTransactionByHash({required this.transactionHash});

  /// The transaction hash.
  final String transactionHash;

  @override
  String get method => 'cfx_getTransactionByHash';

  @override
  List<dynamic> toJson() => [transactionHash];

  @override
  Map<String, dynamic>? onResonse(result) {
    return Map<String, dynamic>.from(result);
  }
}

