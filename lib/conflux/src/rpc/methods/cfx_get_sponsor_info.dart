import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/models/sponsor_info.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns sponsor information of a contract.
/// 
/// In Conflux, contracts can be sponsored to pay for transaction fees
/// and storage collateral on behalf of users.
/// 
/// Example:
/// ```dart
/// final sponsorInfo = await provider.request(
///   CFXGetSponsorInfo(
///     address: 'cfx:...',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// 
/// if (sponsorInfo.hasGasSponsor) {
///   print('Gas is sponsored!');
///   print('Sponsor gas bound: ${sponsorInfo.sponsorGasBound}');
/// }
/// ```
class CFXGetSponsorInfo extends CFXRequest<SponsorInfo, Map<String, dynamic>> {
  CFXGetSponsorInfo({
    required this.address,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The contract address (Base32 format).
  final String address;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_getSponsorInfo';

  @override
  List<dynamic> toJson() => [address, epochNumber.toString()];

  @override
  SponsorInfo onResonse(result) {
    return SponsorInfo.fromJson(Map<String, dynamic>.from(result));
  }
}

