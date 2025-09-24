import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';

/// Filecoin transaction methods
enum FilecoinMethod {
  send(0),
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

  /// Get message bytes for signing (simplified version)
  List<int> getMessageBytes() {
    // Create a simple serialization for signing
    final buffer = <int>[];

    // Add version
    buffer.addAll(_encodeInt(version));

    // Add addresses
    buffer.addAll(to.toBytes());
    buffer.addAll(from.toBytes());

    // Add nonce
    buffer.addAll(_encodeInt(nonce));

    // Add value
    buffer.addAll(_encodeBigInt(value));

    // Add gas settings
    buffer.addAll(_encodeInt(gasLimit));
    buffer.addAll(_encodeBigInt(gasFeeCap));
    buffer.addAll(_encodeBigInt(gasPremium));

    // Add method
    buffer.addAll(_encodeInt(method.value));

    // Add params
    buffer.addAll(params);

    return buffer;
  }

  /// Get CID (Content Identifier) for the transaction
  List<int> getCid() {
    final messageBytes = getMessageBytes();
    return QuickCrypto.blake2b256Hash(messageBytes);
  }

  /// Encode integer as bytes (little endian)
  static List<int> _encodeInt(int value) {
    final bytes = <int>[];
    bytes.add(value & 0xFF);
    bytes.add((value >> 8) & 0xFF);
    bytes.add((value >> 16) & 0xFF);
    bytes.add((value >> 24) & 0xFF);
    return bytes;
  }

  /// Encode BigInt as bytes (big endian)
  static List<int> _encodeBigInt(BigInt value) {
    if (value == BigInt.zero) return [0];

    final bytes = <int>[];
    var temp = value;

    while (temp > BigInt.zero) {
      bytes.insert(0, (temp & BigInt.from(0xFF)).toInt());
      temp = temp >> 8;
    }

    return bytes;
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
    return FilecoinTransaction(
      to: to,
      from: from,
      nonce: nonce,
      value: value,
      gasLimit: gasLimit,
      gasFeeCap: gasFeeCap,
      gasPremium: gasPremium,
      method: FilecoinMethod.send,
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
      'Params': params.isEmpty ? null : BytesUtils.toHexString(params, prefix: '0x'),
    };
  }

  @override
  String toString() {
    return 'FilecoinTransaction(to: $to, from: $from, value: $value, nonce: $nonce)';
  }
}