import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/models/epoch_number.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the next nonce that should be used by the given address.
/// 
/// This is different from `cfx_getNextUsableNonce` in that it doesn't
/// consider pending transactions.
class CFXGetNextNonce extends CFXRequest<BigInt, Map<String, dynamic>> {
  CFXGetNextNonce({
    required this.address,
    this.epochNumber = EpochNumber.latestState,
  });

  /// The address to get nonce for (Base32 format).
  final String address;

  /// The epoch number or tag.
  final EpochNumber epochNumber;

  @override
  String get method => 'cfx_getNextNonce';

  @override
  List<dynamic> toJson() => [address, epochNumber.toString()];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

/// Returns the next usable nonce for the account.
/// 
/// This includes pending transactions in the transaction pool.
class CFXGetNextUsableNonce extends CFXRequest<BigInt, Map<String, dynamic>> {
  CFXGetNextUsableNonce({required this.address});

  /// The address to get nonce for (Base32 format).
  final String address;

  @override
  String get method => 'cfx_getNextUsableNonce';

  @override
  List<dynamic> toJson() => [address];

  @override
  BigInt onResonse(result) {
    return BigintUtils.parse(result);
  }
}

