import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the balance of the account of given address.
/// 
/// Example:
/// ```dart
/// final balance = await provider.request(
///   CFXGetBalance(
///     address: 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// ```
class CFXGetBalance extends CFXRequest<BigInt, String> {
  CFXGetBalance({
    required this.address,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The address to check balance for (Base32 format).
  final String address;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_getBalance';

  @override
  List<dynamic> toJson() => [address, epochNumber.toString()];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

