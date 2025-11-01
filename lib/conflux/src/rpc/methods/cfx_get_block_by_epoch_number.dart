import 'package:on_chain/conflux/src/models/block.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns information about a block by epoch number.
/// 
/// Example:
/// ```dart
/// final block = await provider.request(
///   CFXGetBlockByEpochNumber(
///     epochNumber: EpochNumber.latestState,
///     includeTransactions: false,
///   ),
/// );
/// ```
class CFXGetBlockByEpochNumber extends CFXRequest<CFXBlock?, Map<String, dynamic>?> {
  CFXGetBlockByEpochNumber({
    required this.epochNumber,
    this.includeTransactions = false,
  });

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  /// If true, returns full transaction objects. If false, returns only transaction hashes.
  final bool includeTransactions;

  @override
  String get method => 'cfx_getBlockByEpochNumber';

  @override
  List<dynamic> toJson() => [epochNumber.toString(), includeTransactions];

  @override
  CFXBlock? onResonse(result) {
    if (result == null) return null;
    return CFXBlock.fromJson(result);
  }
}

