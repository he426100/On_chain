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
  FilecoinRequestMsigGetVested(this.address, this.startTipSetKey, this.endTipSetKey);

  final String address;
  final List<Map<String, dynamic>> startTipSetKey;
  final List<Map<String, dynamic>> endTipSetKey;

  @override
  String get method => FilecoinMethods.msigGetVested;

  @override
  List<dynamic> toJson() => [address, startTipSetKey, endTipSetKey];
}

/// Get vesting schedule for a multisig wallet
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

/// Create a multisig wallet
class FilecoinRequestMsigCreate
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCreate({
    required this.required,
    required this.signers,
    required this.unlockDuration,
    required this.value,
    required this.from,
    required this.initialBalance,
  });

  /// Number of required approvals
  final int required;

  /// List of signer addresses
  final List<String> signers;

  /// Unlock duration in epochs
  final int unlockDuration;

  /// Value to send with the message
  final String value;

  /// Address to send the message from
  final String from;

  /// Initial balance for the multisig wallet
  final String initialBalance;

  @override
  String get method => FilecoinMethods.msigCreate;

  @override
  List<dynamic> toJson() =>
      [required, signers, unlockDuration, value, from, initialBalance];
}

/// Propose a multisig message
class FilecoinRequestMsigPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigPropose({
    required this.multisig,
    required this.to,
    required this.value,
    required this.from,
    required this.methodNum,
    required this.params,
  });

  /// Multisig wallet address
  final String multisig;

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the proposal from
  final String from;

  /// Method number to call
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigPropose;

  @override
  List<dynamic> toJson() => [multisig, to, value, from, methodNum, params];
}

/// Approve a previously-proposed multisig message by transaction ID
class FilecoinRequestMsigApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigApprove({
    required this.multisig,
    required this.txnId,
    required this.proposer,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  @override
  String get method => FilecoinMethods.msigApprove;

  @override
  List<dynamic> toJson() => [multisig, txnId, proposer];
}

/// Approve a previously-proposed multisig message with transaction hash
class FilecoinRequestMsigApproveTxnHash
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigApproveTxnHash({
    required this.multisig,
    required this.txnId,
    required this.proposer,
    required this.to,
    required this.value,
    required this.from,
    required this.methodNum,
    required this.params,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the approval from
  final String from;

  /// Method number
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigApproveTxnHash;

  @override
  List<dynamic> toJson() =>
      [multisig, txnId, proposer, to, value, from, methodNum, params];
}

/// Cancel a previously-proposed multisig message
class FilecoinRequestMsigCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCancel({
    required this.multisig,
    required this.txnId,
    required this.proposer,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  @override
  String get method => FilecoinMethods.msigCancel;

  @override
  List<dynamic> toJson() => [multisig, txnId, proposer];
}

/// Cancel a previously-proposed multisig message with transaction hash
class FilecoinRequestMsigCancelTxnHash
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigCancelTxnHash({
    required this.multisig,
    required this.txnId,
    required this.to,
    required this.value,
    required this.from,
    required this.methodNum,
    required this.params,
  });

  /// Multisig wallet address
  final String multisig;

  /// Transaction ID
  final int txnId;

  /// Destination address
  final String to;

  /// Value to send
  final String value;

  /// Address to send the cancellation from
  final String from;

  /// Method number
  final int methodNum;

  /// Method parameters (base64 encoded)
  final String params;

  @override
  String get method => FilecoinMethods.msigCancelTxnHash;

  @override
  List<dynamic> toJson() =>
      [multisig, txnId, to, value, from, methodNum, params];
}

/// Propose adding a signer to the multisig
class FilecoinRequestMsigAddPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddPropose({
    required this.multisig,
    required this.from,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddPropose;

  @override
  List<dynamic> toJson() => [multisig, from, newSigner, increase];
}

/// Approve a previously proposed AddSigner message
class FilecoinRequestMsigAddApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddApprove({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.proposer,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the approval from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddApprove;

  @override
  List<dynamic> toJson() =>
      [multisig, from, txnId, proposer, newSigner, increase];
}

/// Cancel a previously proposed AddSigner message
class FilecoinRequestMsigAddCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigAddCancel({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.newSigner,
    required this.increase,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the cancellation from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address to add as a signer
  final String newSigner;

  /// Whether to increase the required approvals
  final bool increase;

  @override
  String get method => FilecoinMethods.msigAddCancel;

  @override
  List<dynamic> toJson() => [multisig, from, txnId, newSigner, increase];
}

/// Propose swapping two signers in the multisig
class FilecoinRequestMsigSwapPropose
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapPropose({
    required this.multisig,
    required this.from,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapPropose;

  @override
  List<dynamic> toJson() => [multisig, from, oldSigner, newSigner];
}

/// Approve a previously proposed SwapSigner message
class FilecoinRequestMsigSwapApprove
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapApprove({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.proposer,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the approval from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address of the proposer
  final String proposer;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapApprove;

  @override
  List<dynamic> toJson() =>
      [multisig, from, txnId, proposer, oldSigner, newSigner];
}

/// Cancel a previously proposed SwapSigner message
class FilecoinRequestMsigSwapCancel
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigSwapCancel({
    required this.multisig,
    required this.from,
    required this.txnId,
    required this.oldSigner,
    required this.newSigner,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the cancellation from
  final String from;

  /// Transaction ID
  final int txnId;

  /// Address to remove
  final String oldSigner;

  /// Address to add
  final String newSigner;

  @override
  String get method => FilecoinMethods.msigSwapCancel;

  @override
  List<dynamic> toJson() => [multisig, from, txnId, oldSigner, newSigner];
}

/// Propose the removal of a signer from the multisig
class FilecoinRequestMsigRemoveSigner
    extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMsigRemoveSigner({
    required this.multisig,
    required this.from,
    required this.toRemove,
    required this.decrease,
  });

  /// Multisig wallet address
  final String multisig;

  /// Address to send the proposal from
  final String from;

  /// Address to remove as a signer
  final String toRemove;

  /// Whether to decrease the required approvals
  final bool decrease;

  @override
  String get method => FilecoinMethods.msigRemoveSigner;

  @override
  List<dynamic> toJson() => [multisig, from, toRemove, decrease];
}
