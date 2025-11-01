import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/models/sponsor_info.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Checks if a user's balance is sufficient for a transaction,
/// taking sponsor information into account.
/// 
/// Example:
/// ```dart
/// final check = await provider.request(
///   CFXCheckBalanceAgainstTransaction(
///     accountAddress: 'cfx:...',
///     contractAddress: 'cfx:...',
///     gasLimit: '0x5208',
///     gasPrice: '0x1',
///     storageLimit: '0x0',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// 
/// if (!check.isBalanceEnough) {
///   print('Insufficient balance!');
/// }
/// if (!check.willPayTxFee) {
///   print('Transaction fee will be sponsored');
/// }
/// ```
class CFXCheckBalanceAgainstTransaction
    extends CFXRequest<BalanceCheck, Map<String, dynamic>> {
  CFXCheckBalanceAgainstTransaction({
    required this.accountAddress,
    required this.contractAddress,
    required this.gasLimit,
    required this.gasPrice,
    required this.storageLimit,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The user's address (Base32 format).
  final String accountAddress;

  /// The contract address (Base32 format).
  final String contractAddress;

  /// The gas limit (hex string).
  final String gasLimit;

  /// The gas price (hex string).
  final String gasPrice;

  /// The storage limit (hex string).
  final String storageLimit;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_checkBalanceAgainstTransaction';

  @override
  List<dynamic> toJson() => [
        accountAddress,
        contractAddress,
        gasLimit,
        gasPrice,
        storageLimit,
        epochNumber.toString(),
      ];

  @override
  BalanceCheck onResonse(result) {
    return BalanceCheck.fromJson(Map<String, dynamic>.from(result));
  }
}

