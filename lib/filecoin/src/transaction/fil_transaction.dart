import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';

/// Filecoin transaction methods
enum FilecoinMethod {
  send(0),
  exec(2),
  invokeEvm(3844450837);

  const FilecoinMethod(this.value);
  final int value;
}

/// Filecoin transaction representation
class FilecoinTransaction {
  /// Transaction version (always 0 for now)
  final int version;

  /// Recipient address
  final FilecoinAddress to;

  /// Sender address
  final FilecoinAddress from;

  /// Transaction nonce
  final int nonce;

  /// Transaction value in attoFIL
  final BigInt value;

  /// Gas settings
  final int gasLimit;
  final BigInt gasFeeCap;
  final BigInt gasPremium;

  /// Transaction method
  final FilecoinMethod method;

  /// Transaction parameters
  final List<int> params;

  /// CID prefix for Filecoin transactions
  /// CIDv1 + CBOR codec (0x71) + Blake2b-256 multihash (0xa0e40220)
  static const List<int> _cidPrefix = [
    0x01, // CIDv1
    0x71, // CBOR codec
    0xa0, 0xe4, 0x02, // Blake2b-256 multihash
    0x20, // 32 bytes
  ];

  const FilecoinTransaction({
    this.version = 0,
    required this.to,
    required this.from,
    required this.nonce,
    required this.value,
    required this.gasLimit,
    required this.gasFeeCap,
    required this.gasPremium,
    this.method = FilecoinMethod.send,
    this.params = const [],
  });

  /// Encode BigInt according to Filecoin specification
  /// Returns empty list for zero, otherwise [0x00, ...bytes] for positive numbers (big-endian)
  /// Matches iso-filecoin Token.toBytes() implementation
  static List<int> _encodeFilecoinBigInt(BigInt value) {
    if (value == BigInt.zero) {
      return [];
    }

    if (value < BigInt.zero) {
      throw ArgumentError('Negative values not supported');
    }

    // Sign byte: 0x00 = positive, 0x01 = negative
    final signByte = [0x00];

    // Convert BigInt to bytes (big-endian, matching iso-filecoin)
    var hex = value.toRadixString(16);
    if (hex.length % 2 != 0) {
      hex = '0$hex'; // Pad with leading zero if odd length
    }

    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }

    return [...signByte, ...bytes];
  }

  /// Encode unsigned integer in CBOR format
  static List<int> _encodeCborUint(int value) {
    if (value < 24) {
      return [value];
    } else if (value <= 0xFF) {
      return [24, value];
    } else if (value <= 0xFFFF) {
      return [25, value >> 8, value & 0xFF];
    } else if (value <= 0xFFFFFFFF) {
      return [26, (value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF];
    } else {
      return [
        27,
        (value >> 56) & 0xFF,
        (value >> 48) & 0xFF,
        (value >> 40) & 0xFF,
        (value >> 32) & 0xFF,
        (value >> 24) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF
      ];
    }
  }

  /// Encode bytes in CBOR format
  static List<int> _encodeCborBytes(List<int> bytes) {
    final result = <int>[];
    final len = bytes.length;

    if (len < 24) {
      result.add(0x40 | len);
    } else if (len <= 0xFF) {
      result.addAll([0x58, len]);
    } else if (len <= 0xFFFF) {
      result.addAll([0x59, len >> 8, len & 0xFF]);
    } else {
      result.addAll([0x5A, (len >> 24) & 0xFF, (len >> 16) & 0xFF, (len >> 8) & 0xFF, len & 0xFF]);
    }

    result.addAll(bytes);
    return result;
  }

  /// Get CBOR-encoded message bytes for signing
  /// Encodes as: [version, to, from, nonce, value, gasLimit, gasFeeCap, gasPremium, method, params]
  List<int> getMessageBytes() {
    final result = <int>[];

    // Array header (10 items)
    result.add(0x80 | 10);

    // 1. Version (uint)
    result.addAll(_encodeCborUint(version));

    // 2. To address (bytes)
    result.addAll(_encodeCborBytes(to.toBytes()));

    // 3. From address (bytes)
    result.addAll(_encodeCborBytes(from.toBytes()));

    // 4. Nonce (uint)
    result.addAll(_encodeCborUint(nonce));

    // 5. Value (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(_encodeFilecoinBigInt(value)));

    // 6. Gas limit (int - can be negative)
    if (gasLimit >= 0) {
      result.addAll(_encodeCborUint(gasLimit));
    } else {
      // Negative int: major type 1
      final absValue = gasLimit.abs() - 1;
      if (absValue < 24) {
        result.add(0x20 | absValue);
      } else if (absValue <= 0xFF) {
        result.addAll([0x38, absValue]);
      } else if (absValue <= 0xFFFF) {
        result.addAll([0x39, absValue >> 8, absValue & 0xFF]);
      } else {
        result.addAll([0x3A, (absValue >> 24) & 0xFF, (absValue >> 16) & 0xFF, (absValue >> 8) & 0xFF, absValue & 0xFF]);
      }
    }

    // 7. Gas fee cap (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(_encodeFilecoinBigInt(gasFeeCap)));

    // 8. Gas premium (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(_encodeFilecoinBigInt(gasPremium)));

    // 9. Method (uint)
    result.addAll(_encodeCborUint(method.value));

    // 10. Params (bytes)
    result.addAll(_encodeCborBytes(params));

    return result;
  }

  /// Get CID (Content Identifier) for the transaction
  /// CID = prefix + Blake2b-256(CBOR-encoded message)
  List<int> getCid() {
    final messageBytes = getMessageBytes();
    final hash = QuickCrypto.blake2b256Hash(messageBytes);
    return [..._cidPrefix, ...hash];
  }

  /// Create transaction for simple transfer
  factory FilecoinTransaction.transfer({
    required FilecoinAddress to,
    required FilecoinAddress from,
    required int nonce,
    required BigInt value,
    required int gasLimit,
    required BigInt gasFeeCap,
    required BigInt gasPremium,
  }) {
    // Use InvokeEVM method when sending to delegated address (Ethereum-compatible)
    // This matches wallet-core behavior
    final method = to.type == FilecoinAddressType.delegated
        ? FilecoinMethod.invokeEvm
        : FilecoinMethod.send;

    return FilecoinTransaction(
      to: to,
      from: from,
      nonce: nonce,
      value: value,
      gasLimit: gasLimit,
      gasFeeCap: gasFeeCap,
      gasPremium: gasPremium,
      method: method,
      params: [],
    );
  }

  /// Convert to JSON for RPC calls
  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'To': to.toAddress(),
      'From': from.toAddress(),
      'Nonce': nonce,
      'Value': value.toString(),
      'GasLimit': gasLimit,
      'GasFeeCap': gasFeeCap.toString(),
      'GasPremium': gasPremium.toString(),
      'Method': method.value,
      // Params must be empty string ("") not null, matching iso-filecoin
      'Params': params.isEmpty ? '' : BytesUtils.toHexString(params, prefix: '0x'),
    };
  }

  @override
  String toString() {
    return 'FilecoinTransaction(to: $to, from: $from, value: $value, nonce: $nonce)';
  }
}