import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Read state of an actor (used for multisig wallet state)
class FilecoinRequestStateReadState
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestStateReadState(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateReadState;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

/// Get pending transactions for a multisig wallet
class FilecoinRequestMsigGetPending
    extends FilecoinRequest<List<dynamic>, List<dynamic>> {
  FilecoinRequestMsigGetPending(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.msigGetPending;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

/// Get available balance for a multisig wallet
class FilecoinRequestMsigGetAvailableBalance
    extends FilecoinRequest<String, dynamic> {
  FilecoinRequestMsigGetAvailableBalance(this.address, this.tipSetKey);

  final String address;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.msigGetAvailableBalance;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

/// Get vested amount for a multisig wallet
class FilecoinRequestMsigGetVested extends FilecoinRequest<String, dynamic> {
  FilecoinRequestMsigGetVested(this.address, this.startEpoch, this.endEpoch);

  final String address;
  final int startEpoch;
  final int endEpoch;

  @override
  String get method => FilecoinMethods.msigGetVested;

  @override
  List<dynamic> toJson() => [address, startEpoch, endEpoch];
}
