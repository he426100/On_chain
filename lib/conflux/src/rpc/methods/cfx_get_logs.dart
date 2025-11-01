import 'package:on_chain/conflux/src/models/log.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns logs matching the filter.
/// 
/// Example:
/// ```dart
/// final logs = await provider.request(
///   CFXGetLogs(
///     address: 'cfx:...',
///     fromEpoch: EpochNumber.latestState,
///     toEpoch: EpochNumber.latestState,
///     topics: [
///       ['0x...'], // topic0
///     ],
///   ),
/// );
/// ```
class CFXGetLogs extends CFXRequest<List<CFXLog>, List> {
  CFXGetLogs({
    this.address,
    this.fromEpoch,
    this.toEpoch,
    this.blockHashes,
    this.topics,
    this.limit,
  });

  /// Address or a list of addresses to filter logs.
  final dynamic address;

  /// The epoch to start searching for logs (inclusive).
  final EpochNumber? fromEpoch;

  /// The epoch to stop searching for logs (inclusive).
  final EpochNumber? toEpoch;

  /// Array of block hashes to search for logs (alternative to epoch range).
  final List<String>? blockHashes;

  /// Array of topic filters. Each position can be a single topic or an array of topics.
  final List<dynamic>? topics;

  /// Maximum number of logs to return.
  final int? limit;

  @override
  String get method => 'cfx_getLogs';

  @override
  List<dynamic> toJson() {
    final filter = <String, dynamic>{};

    if (address != null) filter['address'] = address;
    if (fromEpoch != null) filter['fromEpoch'] = fromEpoch.toString();
    if (toEpoch != null) filter['toEpoch'] = toEpoch.toString();
    if (blockHashes != null) filter['blockHashes'] = blockHashes;
    if (topics != null) filter['topics'] = topics;
    if (limit != null) filter['limit'] = '0x${limit!.toRadixString(16)}';

    return [filter];
  }

  @override
  List<CFXLog> onResonse(result) {
    return result.map<CFXLog>((log) => CFXLog.fromJson(log)).toList();
  }
}

