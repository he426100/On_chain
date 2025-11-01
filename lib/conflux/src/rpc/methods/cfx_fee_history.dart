import 'package:on_chain/conflux/src/models/fee_history.dart' as models;
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns historical gas price and priority fee information.
/// 
/// Example:
/// ```dart
/// final feeHistory = await provider.request(
///   CFXRequestFeeHistory(
///     epochCount: 10,
///     newestEpoch: EpochNumber.latestState,
///     rewardPercentiles: [25, 50, 75],
///   ),
/// );
/// ```
class CFXRequestFeeHistory extends CFXRequest<models.CFXFeeHistory, Map<String, dynamic>> {
  CFXRequestFeeHistory({
    required this.epochCount,
    required this.newestEpoch,
    this.rewardPercentiles,
  });

  /// Number of epochs to return fee data for.
  final int epochCount;

  /// The newest epoch to include in the result.
  final EpochNumber newestEpoch;

  /// Array of percentiles (0-100) to calculate for priority fees.
  final List<int>? rewardPercentiles;

  @override
  String get method => 'cfx_feeHistory';

  @override
  List<dynamic> toJson() {
    return [
      '0x${epochCount.toRadixString(16)}',
      newestEpoch.toString(),
      if (rewardPercentiles != null) rewardPercentiles,
    ];
  }

  @override
  models.CFXFeeHistory onResonse(result) {
    return models.CFXFeeHistory.fromJson(result);
  }
}

