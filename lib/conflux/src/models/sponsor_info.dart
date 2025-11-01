import 'package:blockchain_utils/blockchain_utils.dart';

/// Represents sponsor information for a Conflux contract.
/// 
/// In Conflux, contracts can be sponsored to pay for gas and storage costs.
class SponsorInfo {
  const SponsorInfo({
    required this.sponsorForGas,
    required this.sponsorForCollateral,
    required this.sponsorGasBound,
    required this.sponsorBalanceForGas,
    required this.sponsorBalanceForCollateral,
  });

  /// The address sponsoring gas fees (or null address if no sponsor).
  final String sponsorForGas;

  /// The address sponsoring storage collateral (or null address if no sponsor).
  final String sponsorForCollateral;

  /// The maximum gas that can be sponsored per transaction.
  final BigInt sponsorGasBound;

  /// The sponsor's balance for gas fees.
  final BigInt sponsorBalanceForGas;

  /// The sponsor's balance for storage collateral.
  final BigInt sponsorBalanceForCollateral;

  /// Checks if gas is sponsored.
  bool get hasGasSponsor =>
      sponsorForGas != '0x0000000000000000000000000000000000000000';

  /// Checks if storage collateral is sponsored.
  bool get hasCollateralSponsor =>
      sponsorForCollateral != '0x0000000000000000000000000000000000000000';

  /// Parses from JSON.
  factory SponsorInfo.fromJson(Map<String, dynamic> json) {
    return SponsorInfo(
      sponsorForGas: json['sponsorForGas'] as String,
      sponsorForCollateral: json['sponsorForCollateral'] as String,
      sponsorGasBound: BigintUtils.parse(json['sponsorGasBound']),
      sponsorBalanceForGas: BigintUtils.parse(json['sponsorBalanceForGas']),
      sponsorBalanceForCollateral: BigintUtils.parse(json['sponsorBalanceForCollateral']),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'sponsorForGas': sponsorForGas,
      'sponsorForCollateral': sponsorForCollateral,
      'sponsorGasBound': '0x${sponsorGasBound.toRadixString(16)}',
      'sponsorBalanceForGas': '0x${sponsorBalanceForGas.toRadixString(16)}',
      'sponsorBalanceForCollateral': '0x${sponsorBalanceForCollateral.toRadixString(16)}',
    };
  }

  @override
  String toString() => toJson().toString();
}

/// Represents the result of checking balance against a transaction.
class BalanceCheck {
  const BalanceCheck({
    required this.isBalanceEnough,
    required this.willPayCollateral,
    required this.willPayTxFee,
  });

  /// Whether the balance is sufficient for the transaction.
  final bool isBalanceEnough;

  /// Whether the user will pay for storage collateral (not sponsored).
  final bool willPayCollateral;

  /// Whether the user will pay for transaction fees (not sponsored).
  final bool willPayTxFee;

  /// Parses from JSON.
  factory BalanceCheck.fromJson(Map<String, dynamic> json) {
    return BalanceCheck(
      isBalanceEnough: json['isBalanceEnough'] as bool,
      willPayCollateral: json['willPayCollateral'] as bool,
      willPayTxFee: json['willPayTxFee'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'isBalanceEnough': isBalanceEnough,
      'willPayCollateral': willPayCollateral,
      'willPayTxFee': willPayTxFee,
    };
  }

  @override
  String toString() => toJson().toString();
}

