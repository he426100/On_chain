import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get the current head of the chain
class FilecoinRequestChainHead extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestChainHead();

  @override
  String get method => FilecoinMethods.chainHead;

  @override
  List<dynamic> toJson() => [];
}

/// Get nonce for an address from the message pool
class FilecoinRequestGetNonce extends FilecoinRequest<int, dynamic> {
  FilecoinRequestGetNonce(this.address);

  final String address;

  @override
  String get method => FilecoinMethods.mpoolGetNonce;

  @override
  List<dynamic> toJson() => [address];
}

/// Push a signed message to the message pool
class FilecoinRequestMpoolPush extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMpoolPush(this.signedMessage);

  final Map<String, dynamic> signedMessage;

  @override
  String get method => FilecoinMethods.mpoolPush;

  @override
  List<dynamic> toJson() => [signedMessage];
}

/// Get balance of an address
class FilecoinRequestWalletBalance extends FilecoinRequest<String, dynamic> {
  FilecoinRequestWalletBalance(this.address);

  final String address;

  @override
  String get method => FilecoinMethods.walletBalance;

  @override
  List<dynamic> toJson() => [address];
}

/// Estimate gas limit for a message
class FilecoinRequestEstimateGasLimit extends FilecoinRequest<int, dynamic> {
  FilecoinRequestEstimateGasLimit(this.message, this.tipSetKey);

  final Map<String, dynamic> message;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateGasLimit;

  @override
  List<dynamic> toJson() => [message, tipSetKey];
}

/// Get version information
class FilecoinRequestVersion extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestVersion();

  @override
  String get method => FilecoinMethods.version;

  @override
  List<dynamic> toJson() => [];
}