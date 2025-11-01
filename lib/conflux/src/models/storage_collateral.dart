import 'package:blockchain_utils/blockchain_utils.dart';

/// Represents storage collateral information in Conflux.
/// 
/// Conflux requires storage collateral for storing data on-chain.
class StorageCollateral {
  const StorageCollateral({
    required this.storageCollateralized,
    required this.storageLimit,
    required this.storageReleased,
  });

  /// The amount of storage collateralized (in Drip).
  final BigInt storageCollateralized;

  /// The storage limit set for the transaction (in bytes).
  final BigInt storageLimit;

  /// The amount of storage released (in Drip).
  final BigInt storageReleased;

  /// Parses from JSON.
  factory StorageCollateral.fromJson(Map<String, dynamic> json) {
    return StorageCollateral(
      storageCollateralized: BigintUtils.parse(json['storageCollateralized']),
      storageLimit: BigintUtils.parse(json['storageLimit']),
      storageReleased: BigintUtils.tryParse(json['storageReleased']) ?? BigInt.zero,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'storageCollateralized': '0x${storageCollateralized.toRadixString(16)}',
      'storageLimit': '0x${storageLimit.toRadixString(16)}',
      'storageReleased': '0x${storageReleased.toRadixString(16)}',
    };
  }

  @override
  String toString() => toJson().toString();
}

/// Represents the result of gas and collateral estimation.
class GasAndCollateralEstimation {
  const GasAndCollateralEstimation({
    required this.gasLimit,
    required this.gasUsed,
    required this.storageCollateralized,
  });

  /// The gas limit.
  final BigInt gasLimit;

  /// The gas used.
  final BigInt gasUsed;

  /// The storage collateralized.
  final BigInt storageCollateralized;

  /// Parses from JSON.
  factory GasAndCollateralEstimation.fromJson(Map<String, dynamic> json) {
    return GasAndCollateralEstimation(
      gasLimit: BigintUtils.parse(json['gasLimit']),
      gasUsed: BigintUtils.parse(json['gasUsed']),
      storageCollateralized: BigintUtils.parse(json['storageCollateralized']),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'gasLimit': '0x${gasLimit.toRadixString(16)}',
      'gasUsed': '0x${gasUsed.toRadixString(16)}',
      'storageCollateralized': '0x${storageCollateralized.toRadixString(16)}',
    };
  }

  @override
  String toString() => toJson().toString();
}

