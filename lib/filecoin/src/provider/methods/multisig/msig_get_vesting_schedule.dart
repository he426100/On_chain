import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get vesting schedule for a multisig wallet
/// [Filecoin.MsigGetVestingSchedule](https://lotus.filecoin.io/reference/lotus/msig/)
class FilecoinRequestMsigGetVestingSchedule
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigGetVestingSchedule(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.msigGetVestingSchedule;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

