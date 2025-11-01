import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/models/storage_collateral.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Estimates gas and storage collateral for a transaction.
/// 
/// Example:
/// ```dart
/// final estimation = await provider.request(
///   CFXEstimateGasAndCollateral(
///     transaction: {
///       'from': 'cfx:...',
///       'to': 'cfx:...',
///       'value': '0x1',
///       'data': '0x',
///     },
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// 
/// print('Gas limit: ${estimation.gasLimit}');
/// print('Storage collateralized: ${estimation.storageCollateralized}');
/// ```
class CFXEstimateGasAndCollateral
    extends CFXRequest<GasAndCollateralEstimation, Map<String, dynamic>> {
  CFXEstimateGasAndCollateral({
    required this.transaction,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The transaction object to estimate.
  final Map<String, dynamic> transaction;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_estimateGasAndCollateral';

  @override
  List<dynamic> toJson() => [transaction, epochNumber.toString()];

  @override
  GasAndCollateralEstimation onResonse(result) {
    return GasAndCollateralEstimation.fromJson(
      Map<String, dynamic>.from(result),
    );
  }
}

