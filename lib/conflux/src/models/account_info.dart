import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/utils/utils/number_utils.dart';

/// Represents detailed information about a Conflux account.
/// 
/// This includes balance, nonce, code hash, staking balance, and storage collateral.
class CFXAccountInfo {
  /// The account's balance in Drip (1 CFX = 10^18 Drip).
  final BigInt balance;

  /// The nonce of the account (number of transactions sent).
  final BigInt nonce;

  /// The hash of the contract code (null for non-contract accounts).
  final String codeHash;

  /// The staking balance of the account.
  final BigInt stakingBalance;

  /// The storage collateral locked for this account.
  final BigInt collateralForStorage;

  /// The accumulated interest return.
  final BigInt accumulatedInterestReturn;

  /// The admin address for contract accounts.
  final String admin;

  const CFXAccountInfo({
    required this.balance,
    required this.nonce,
    required this.codeHash,
    required this.stakingBalance,
    required this.collateralForStorage,
    required this.accumulatedInterestReturn,
    required this.admin,
  });

  /// Creates a [CFXAccountInfo] from a JSON map.
  factory CFXAccountInfo.fromJson(Map<String, dynamic> json) {
    return CFXAccountInfo(
      balance: BigintUtils.parse(json['balance']),
      nonce: BigintUtils.parse(json['nonce']),
      codeHash: json['codeHash'],
      stakingBalance: BigintUtils.parse(json['stakingBalance']),
      collateralForStorage: BigintUtils.parse(json['collateralForStorage']),
      accumulatedInterestReturn: BigintUtils.parse(json['accumulatedInterestReturn']),
      admin: json['admin'],
    );
  }

  /// Checks if this is a contract account.
  bool get isContract => codeHash != '0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470';

  /// Checks if this account has staked CFX.
  bool get hasStake => stakingBalance > BigInt.zero;

  /// Converts this account info to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'balance': '0x${balance.toRadixString(16)}',
      'nonce': '0x${nonce.toRadixString(16)}',
      'codeHash': codeHash,
      'stakingBalance': '0x${stakingBalance.toRadixString(16)}',
      'collateralForStorage': '0x${collateralForStorage.toRadixString(16)}',
      'accumulatedInterestReturn': '0x${accumulatedInterestReturn.toRadixString(16)}',
      'admin': admin,
    };
  }

  @override
  String toString() {
    return 'CFXAccountInfo{balance: $balance, nonce: $nonce, stakingBalance: $stakingBalance, isContract: $isContract}';
  }
}

/// Represents the status of a Conflux node.
class CFXStatus {
  /// The best block hash.
  final String bestHash;

  /// The current chain ID.
  final int chainId;

  /// The current epoch number.
  final int epochNumber;

  /// The latest checkpoint.
  final int latestCheckpoint;

  /// The latest confirmed epoch number.
  final int latestConfirmed;

  /// The latest state epoch number.
  final int latestState;

  /// The latest finalized epoch number.
  final int? latestFinalized;

  /// The block number of the current epoch.
  final int? blockNumber;

  /// Whether the node is in catch-up mode.
  final bool? pendingTxNumber;

  const CFXStatus({
    required this.bestHash,
    required this.chainId,
    required this.epochNumber,
    required this.latestCheckpoint,
    required this.latestConfirmed,
    required this.latestState,
    this.latestFinalized,
    this.blockNumber,
    this.pendingTxNumber,
  });

  /// Creates a [CFXStatus] from a JSON map.
  factory CFXStatus.fromJson(Map<String, dynamic> json) {
    return CFXStatus(
      bestHash: json['bestHash'],
      chainId: PluginIntUtils.hexToInt(json['chainId']),
      epochNumber: PluginIntUtils.hexToInt(json['epochNumber']),
      latestCheckpoint: PluginIntUtils.hexToInt(json['latestCheckpoint']),
      latestConfirmed: PluginIntUtils.hexToInt(json['latestConfirmed']),
      latestState: PluginIntUtils.hexToInt(json['latestState']),
      latestFinalized: json['latestFinalized'] != null
          ? PluginIntUtils.hexToInt(json['latestFinalized'])
          : null,
      blockNumber: json['blockNumber'] != null
          ? PluginIntUtils.hexToInt(json['blockNumber'])
          : null,
      pendingTxNumber: json['pendingTxNumber'],
    );
  }

  /// Converts this status to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'bestHash': bestHash,
      'chainId': '0x${chainId.toRadixString(16)}',
      'epochNumber': '0x${epochNumber.toRadixString(16)}',
      'latestCheckpoint': '0x${latestCheckpoint.toRadixString(16)}',
      'latestConfirmed': '0x${latestConfirmed.toRadixString(16)}',
      'latestState': '0x${latestState.toRadixString(16)}',
      if (latestFinalized != null) 'latestFinalized': '0x${latestFinalized!.toRadixString(16)}',
      if (blockNumber != null) 'blockNumber': '0x${blockNumber!.toRadixString(16)}',
      if (pendingTxNumber != null) 'pendingTxNumber': pendingTxNumber,
    };
  }

  @override
  String toString() {
    return 'CFXStatus{chainId: $chainId, epochNumber: $epochNumber, bestHash: $bestHash}';
  }
}

