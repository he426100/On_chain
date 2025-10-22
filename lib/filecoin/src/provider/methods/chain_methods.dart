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

/// Estimate gas fee cap for a message
class FilecoinRequestEstimateGasFeeCap extends FilecoinRequest<String, dynamic> {
  FilecoinRequestEstimateGasFeeCap(this.message, this.maxQueueBlks, this.tipSetKey);

  final Map<String, dynamic> message;
  final int maxQueueBlks;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateFeeCap;

  @override
  List<dynamic> toJson() => [message, maxQueueBlks, tipSetKey];
}

/// Estimate gas premium for a message
class FilecoinRequestEstimateGasPremium extends FilecoinRequest<String, dynamic> {
  FilecoinRequestEstimateGasPremium(this.nblocksincl, this.sender, this.gasLimit, this.tipSetKey);

  final int nblocksincl;
  final String sender;
  final int gasLimit;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateGasPremium;

  @override
  List<dynamic> toJson() => [nblocksincl, sender, gasLimit, tipSetKey];
}

/// Estimate gas for a message - fills in all unset gas fields
class FilecoinRequestEstimateMessageGas extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestEstimateMessageGas(this.message, this.spec, this.tipSetKey);

  final Map<String, dynamic> message;
  final Map<String, dynamic>? spec;
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.gasEstimateMessageGas;

  @override
  List<dynamic> toJson() => [message, spec, tipSetKey];
}

/// Get version information
class FilecoinRequestVersion extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestVersion();

  @override
  String get method => FilecoinMethods.version;

  @override
  List<dynamic> toJson() => [];
}

/// StateSearchMsg looks back up to limit epochs in the chain for a message,
/// and returns its receipt and the tipset where it was executed
class FilecoinRequestStateSearchMsg extends FilecoinRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  FilecoinRequestStateSearchMsg(this.messageCid, {this.tipSetKey, this.lookbackLimit = 100, this.allowReplaced = true});

  /// The CID of the message to search for
  final Map<String, dynamic> messageCid;

  /// Optional tipset key to start search from (null means start from chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  /// Number of epochs to look back (default: 100)
  final int lookbackLimit;

  /// Allow replaced messages (default: true)
  final bool allowReplaced;

  @override
  String get method => FilecoinMethods.stateSearchMsg;

  @override
  List<dynamic> toJson() => [tipSetKey, messageCid, lookbackLimit, allowReplaced];
}

/// StateWaitMsg looks back in the chain for a message. If not found, it blocks
/// until the message arrives on chain, and gets to the indicated confidence depth
class FilecoinRequestStateWaitMsg extends FilecoinRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  FilecoinRequestStateWaitMsg(this.messageCid, {this.confidence = 2, this.lookbackLimit = 100, this.allowReplaced = true});

  /// The CID of the message to wait for
  final Map<String, dynamic> messageCid;

  /// Number of confirmations to wait for (default: 2)
  final int confidence;

  /// Number of epochs to look back (default: 100)
  final int lookbackLimit;

  /// Allow replaced messages (default: true)
  final bool allowReplaced;

  @override
  String get method => FilecoinMethods.stateWaitMsg;

  @override
  List<dynamic> toJson() => [messageCid, confidence, lookbackLimit, allowReplaced];
}

/// StateGetActor returns the indicated actor's nonce and balance
class FilecoinRequestStateGetActor extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestStateGetActor(this.address, {this.tipSetKey});

  /// The address of the actor to query
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateGetActor;

  @override
  List<dynamic> toJson() => [address, tipSetKey];
}

/// StateListMessages looks back and returns all messages with a matching to or from address,
/// stopping at the given height
class FilecoinRequestStateListMessages extends FilecoinRequest<List<Map<String, dynamic>>, List<dynamic>> {
  FilecoinRequestStateListMessages({this.to, this.from, this.tipSetKey, required this.toHeight});

  /// Filter by 'to' address (optional)
  final String? to;

  /// Filter by 'from' address (optional)
  final String? from;

  /// Optional tipset key to start search from (null means start from chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  /// Epoch height to stop at
  final int toHeight;

  @override
  String get method => FilecoinMethods.stateListMessages;

  @override
  List<dynamic> toJson() {
    final match = <String, dynamic>{};
    if (to != null) match['To'] = to;
    if (from != null) match['From'] = from;

    return [match, tipSetKey, toHeight];
  }
}

/// StateAccountKey returns the public key address of the given ID address
class FilecoinRequestStateAccountKey extends FilecoinRequest<String, dynamic> {
  FilecoinRequestStateAccountKey(this.address, {this.tipSetKey});

  /// The ID address to convert (e.g., "f0123")
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateAccountKey;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}

/// StateLookupID retrieves the ID address of the given address
class FilecoinRequestStateLookupID extends FilecoinRequest<String, dynamic> {
  FilecoinRequestStateLookupID(this.address, {this.tipSetKey});

  /// The address to convert to ID address
  final String address;

  /// Optional tipset key (null means use chain head)
  final List<Map<String, dynamic>>? tipSetKey;

  @override
  String get method => FilecoinMethods.stateLookupID;

  @override
  List<dynamic> toJson() => [address, tipSetKey ?? []];
}