import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the current epoch number.
/// 
/// Example:
/// ```dart
/// final epochNumber = await provider.request(
///   CFXEpochNumber(epochTag: EpochNumber.latestMined),
/// );
/// ```
class CFXEpochNumber extends CFXRequest<BigInt, String> {
  CFXEpochNumber({this.epochTag = EpochNumber.latestMined});

  /// The epoch tag to query.
  final EpochNumber epochTag;

  @override
  String get method => 'cfx_epochNumber';

  @override
  List<dynamic> toJson() => [epochTag.toString()];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

