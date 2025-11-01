import 'package:on_chain/conflux/src/models/block.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns information about a block by hash.
/// 
/// Example:
/// ```dart
/// final block = await provider.request(
///   CFXGetBlockByHash(
///     blockHash: '0x...',
///     includeTransactions: false,
///   ),
/// );
/// ```
class CFXGetBlockByHash extends CFXRequest<CFXBlock?, Map<String, dynamic>?> {
  CFXGetBlockByHash({
    required this.blockHash,
    this.includeTransactions = false,
  });

  /// The hash of the block.
  final String blockHash;

  /// If true, returns full transaction objects. If false, returns only transaction hashes.
  final bool includeTransactions;

  @override
  String get method => 'cfx_getBlockByHash';

  @override
  List<dynamic> toJson() => [blockHash, includeTransactions];

  @override
  CFXBlock? onResonse(result) {
    if (result == null) return null;
    return CFXBlock.fromJson(result);
  }
}

