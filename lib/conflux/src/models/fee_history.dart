import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/utils/utils/number_utils.dart';

/// Represents fee history data for Conflux.
/// 
/// This includes historical gas price information and priority fees
/// for EIP-1559 style transactions.
class CFXFeeHistory {
  /// Lowest epoch number in the result.
  final int oldestEpoch;

  /// Array of base fees per gas for each epoch in the result.
  /// Null if EIP-1559 is not enabled.
  final List<BigInt>? baseFeePerGas;

  /// Array of gas used ratios for each epoch.
  final List<double> gasUsedRatio;

  /// Array of effective priority fees per gas for each epoch.
  /// Each element is an array of percentile values.
  final List<List<BigInt>>? reward;

  const CFXFeeHistory({
    required this.oldestEpoch,
    this.baseFeePerGas,
    required this.gasUsedRatio,
    this.reward,
  });

  /// Creates a [CFXFeeHistory] from a JSON map.
  factory CFXFeeHistory.fromJson(Map<String, dynamic> json) {
    final baseFeePerGas = json['baseFeePerGas'] != null
        ? (json['baseFeePerGas'] as List)
            .map((e) => BigintUtils.parse(e))
            .toList()
        : null;

    final gasUsedRatio = (json['gasUsedRatio'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    final reward = json['reward'] != null
        ? (json['reward'] as List)
            .map((arr) => (arr as List)
                .map((e) => BigintUtils.parse(e))
                .toList())
            .toList()
        : null;

    return CFXFeeHistory(
      oldestEpoch: PluginIntUtils.hexToInt(json['oldestEpoch']),
      baseFeePerGas: baseFeePerGas,
      gasUsedRatio: gasUsedRatio,
      reward: reward,
    );
  }

  /// Converts this fee history to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'oldestEpoch': '0x${oldestEpoch.toRadixString(16)}',
      if (baseFeePerGas != null)
        'baseFeePerGas': baseFeePerGas!.map((e) => '0x${e.toRadixString(16)}').toList(),
      'gasUsedRatio': gasUsedRatio,
      if (reward != null)
        'reward': reward!.map((arr) => arr.map((e) => '0x${e.toRadixString(16)}').toList()).toList(),
    };
  }

  @override
  String toString() {
    return 'CFXFeeHistory{oldestEpoch: $oldestEpoch, gasUsedRatio: ${gasUsedRatio.length} epochs}';
  }
}

/// Represents gas and collateral estimation for a transaction.
class CFXEstimate {
  /// The estimated gas limit required.
  final BigInt gasLimit;

  /// The estimated gas used.
  final BigInt gasUsed;

  /// The estimated storage collateral required (in Drip).
  final BigInt storageCollateralized;

  const CFXEstimate({
    required this.gasLimit,
    required this.gasUsed,
    required this.storageCollateralized,
  });

  /// Creates a [CFXEstimate] from a JSON map.
  factory CFXEstimate.fromJson(Map<String, dynamic> json) {
    return CFXEstimate(
      gasLimit: BigintUtils.parse(json['gasLimit']),
      gasUsed: BigintUtils.parse(json['gasUsed']),
      storageCollateralized: BigintUtils.parse(json['storageCollateralized']),
    );
  }

  /// Converts this estimate to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'gasLimit': '0x${gasLimit.toRadixString(16)}',
      'gasUsed': '0x${gasUsed.toRadixString(16)}',
      'storageCollateralized': '0x${storageCollateralized.toRadixString(16)}',
    };
  }

  @override
  String toString() {
    return 'CFXEstimate{gasLimit: $gasLimit, gasUsed: $gasUsed, storageCollateralized: $storageCollateralized}';
  }
}

