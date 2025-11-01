import 'package:on_chain/conflux/src/models/account_info.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns detailed information about an account.
/// 
/// Example:
/// ```dart
/// final account = await provider.request(
///   CFXGetAccount(
///     address: 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// ```
class CFXGetAccount extends CFXRequest<CFXAccountInfo, Map<String, dynamic>> {
  CFXGetAccount({
    required this.address,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The address to get account info for (Base32 format).
  final String address;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_getAccount';

  @override
  List<dynamic> toJson() => [address, epochNumber.toString()];

  @override
  CFXAccountInfo onResonse(result) {
    return CFXAccountInfo.fromJson(result);
  }
}

