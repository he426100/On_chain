import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/utils/utils/number_utils.dart';

/// Represents a Conflux block header with all relevant fields.
/// 
/// Conflux blocks use epoch-based consensus and have unique fields
/// like refereeHashes, custom, and posReference.
class CFXBlock {
  /// Whether the block was executed adaptively (Conflux-specific).
  final bool? adaptive;

  /// The blame value (used in consensus).
  final int? blame;

  /// The block hash (null for pending blocks).
  final String? hash;

  /// The parent block hash.
  final String parentHash;

  /// The block height (number).
  final int height;

  /// The address of the miner who mined this block.
  final String miner;

  /// Deferred state root hash.
  final String deferredStateRoot;

  /// Deferred receipts root hash.
  final String deferredReceiptsRoot;

  /// Deferred logs bloom filter.
  final String deferredLogsBloomHash;

  /// The timestamp of when the block was mined (Unix timestamp in seconds).
  final int timestamp;

  /// The difficulty of this block.
  final BigInt difficulty;

  /// Whether this block is in the pivot chain.
  final bool? powQuality;

  /// Referee block hashes (blocks referenced by this block).
  final List<String> refereeHashes;

  /// The gas limit for this block.
  final BigInt gasLimit;

  /// The actual gas used in this block.
  final BigInt? gasUsed;

  /// Array of transaction hashes or full transaction objects.
  final List<dynamic> transactions;

  /// The size of this block in bytes.
  final int size;

  /// Custom data field (Conflux-specific).
  final List<int>? custom;

  /// The nonce used in block mining.
  final String nonce;

  /// PoS reference (used in hybrid PoW+PoS consensus).
  final String? posReference;

  /// The epoch number of this block.
  final int? epochNumber;

  /// The block number in the total order.
  final int? blockNumber;

  const CFXBlock({
    this.adaptive,
    this.blame,
    this.hash,
    required this.parentHash,
    required this.height,
    required this.miner,
    required this.deferredStateRoot,
    required this.deferredReceiptsRoot,
    required this.deferredLogsBloomHash,
    required this.timestamp,
    required this.difficulty,
    this.powQuality,
    required this.refereeHashes,
    required this.gasLimit,
    this.gasUsed,
    required this.transactions,
    required this.size,
    this.custom,
    required this.nonce,
    this.posReference,
    this.epochNumber,
    this.blockNumber,
  });

  /// Creates a [CFXBlock] from a JSON map.
  factory CFXBlock.fromJson(Map<String, dynamic> json) {
    return CFXBlock(
      adaptive: json['adaptive'],
      blame: json['blame'] != null ? PluginIntUtils.hexToInt(json['blame']) : null,
      hash: json['hash'],
      parentHash: json['parentHash'],
      height: PluginIntUtils.hexToInt(json['height']),
      miner: json['miner'],
      deferredStateRoot: json['deferredStateRoot'],
      deferredReceiptsRoot: json['deferredReceiptsRoot'],
      deferredLogsBloomHash: json['deferredLogsBloomHash'],
      timestamp: PluginIntUtils.hexToInt(json['timestamp']),
      difficulty: BigintUtils.parse(json['difficulty']),
      powQuality: json['powQuality'],
      refereeHashes: (json['refereeHashes'] as List).cast<String>(),
      gasLimit: BigintUtils.parse(json['gasLimit']),
      gasUsed: json['gasUsed'] != null
          ? BigintUtils.parse(json['gasUsed'])
          : null,
      transactions: json['transactions'] as List,
      size: PluginIntUtils.hexToInt(json['size']),
      custom: json['custom'] != null ? (json['custom'] as List).cast<int>() : null,
      nonce: json['nonce'],
      posReference: json['posReference'],
      epochNumber: json['epochNumber'] != null
          ? PluginIntUtils.hexToInt(json['epochNumber'])
          : null,
      blockNumber: json['blockNumber'] != null
          ? PluginIntUtils.hexToInt(json['blockNumber'])
          : null,
    );
  }

  /// Converts this block to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (adaptive != null) 'adaptive': adaptive,
      if (blame != null) 'blame': '0x${blame!.toRadixString(16)}',
      if (hash != null) 'hash': hash,
      'parentHash': parentHash,
      'height': '0x${height.toRadixString(16)}',
      'miner': miner,
      'deferredStateRoot': deferredStateRoot,
      'deferredReceiptsRoot': deferredReceiptsRoot,
      'deferredLogsBloomHash': deferredLogsBloomHash,
      'timestamp': '0x${timestamp.toRadixString(16)}',
      'difficulty': '0x${difficulty.toRadixString(16)}',
      if (powQuality != null) 'powQuality': powQuality,
      'refereeHashes': refereeHashes,
      'gasLimit': '0x${gasLimit.toRadixString(16)}',
      if (gasUsed != null) 'gasUsed': '0x${gasUsed!.toRadixString(16)}',
      'transactions': transactions,
      'size': '0x${size.toRadixString(16)}',
      if (custom != null) 'custom': custom,
      'nonce': nonce,
      if (posReference != null) 'posReference': posReference,
      if (epochNumber != null) 'epochNumber': '0x${epochNumber!.toRadixString(16)}',
      if (blockNumber != null) 'blockNumber': '0x${blockNumber!.toRadixString(16)}',
    };
  }

  @override
  String toString() {
    return 'CFXBlock{hash: $hash, height: $height, epochNumber: $epochNumber, miner: $miner, transactions: ${transactions.length}}';
  }
}

