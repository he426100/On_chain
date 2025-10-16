import 'dart:convert' show base64;
import '../address/fil_address.dart';
import '../token/fil_token.dart';
import '../utils/fil_utils.dart';

/// Filecoin message for transactions
/// Supports validation, preparation, and Lotus format conversion
class FilecoinMessage {
  /// Transaction version (always 0)
  final int version;

  /// Recipient address
  final String to;

  /// Sender address
  final String from;

  /// Transaction nonce
  final int nonce;

  /// Transaction value in attoFIL (as string)
  final String value;

  /// Gas limit
  final int gasLimit;

  /// Gas fee cap (in attoFIL as string)
  final String gasFeeCap;

  /// Gas premium (in attoFIL as string)
  final String gasPremium;

  /// Method number
  final int method;

  /// Parameters (base64 encoded)
  final String params;

  /// Cached serialized bytes
  List<int>? _cachedBytes;

  /// Cached CID bytes
  List<int>? _cachedCidBytes;

  FilecoinMessage({
    this.version = 0,
    required this.to,
    required this.from,
    this.nonce = 0,
    required this.value,
    this.gasLimit = 0,
    this.gasFeeCap = '0',
    this.gasPremium = '0',
    this.method = 0,
    this.params = '',
  }) {
    _validate();
  }

  /// Validate message fields
  void _validate() {
    // Validate addresses
    if (!FilecoinAddress.isValidAddress(to)) {
      throw ArgumentError('Invalid "to" address: $to');
    }
    if (!FilecoinAddress.isValidAddress(from)) {
      throw ArgumentError('Invalid "from" address: $from');
    }

    // Validate value is not negative
    final valueBigInt = BigInt.tryParse(value);
    if (valueBigInt == null) {
      throw ArgumentError('Invalid value: $value must be a valid number');
    }
    if (valueBigInt.isNegative) {
      throw ArgumentError('Value must not be negative: $value');
    }

    // Validate nonce
    if (nonce < 0) {
      throw ArgumentError('Nonce must be non-negative: $nonce');
    }

    // Validate gas parameters
    if (gasLimit < 0) {
      throw ArgumentError('Gas limit must be non-negative: $gasLimit');
    }
  }

  /// Create message from Lotus format
  factory FilecoinMessage.fromLotus(Map<String, dynamic> json) {
    return FilecoinMessage(
      version: json['Version'] as int,
      to: json['To'] as String,
      from: json['From'] as String,
      nonce: json['Nonce'] as int,
      value: json['Value'] as String,
      gasLimit: json['GasLimit'] as int,
      gasFeeCap: json['GasFeeCap'] as String,
      gasPremium: json['GasPremium'] as String,
      method: json['Method'] as int,
      params: json['Params'] as String? ?? '',
    );
  }

  /// Convert to Lotus format
  Map<String, dynamic> toLotus() {
    return {
      'Version': version,
      'To': to,
      'From': from,
      'Nonce': nonce,
      'Value': value,
      'GasLimit': gasLimit,
      'GasFeeCap': gasFeeCap,
      'GasPremium': gasPremium,
      'Method': method,
      'Params': params.isEmpty ? '' : params,
    };
  }

  /// Prepare message for signing with nonce and gas estimation
  /// This method will update nonce and gas parameters if they are zero/empty
  ///
  /// Note: RPC integration requires the provider to support:
  /// - MpoolGetNonce for nonce retrieval
  /// - GasEstimateMessageGas for gas estimation
  Future<FilecoinMessage> prepare(dynamic rpc) async {
    // Parse addresses
    final toAddress = FilecoinAddress.fromString(to);
    final fromAddress = FilecoinAddress.fromString(from);

    // Check if recipient is ID mask address (not supported)
    if (FilecoinUtils.isIdMaskAddress(to)) {
      throw ArgumentError('ID mask addresses are not supported for recipient');
    }

    // Change method to InvokeEVM for delegated addresses with method 0
    // This prevents losing funds on bare value sends to 0x addresses
    // @see https://docs.filecoin.io/smart-contracts/filecoin-evm-runtime/difference-with-ethereum#bare-value-sends
    var adjustedMethod = method;
    if (toAddress.type == FilecoinAddressType.delegated && method == 0) {
      adjustedMethod = 3844450837; // InvokeEVM
    }

    var adjustedNonce = nonce;
    var adjustedGasLimit = gasLimit;
    var adjustedGasFeeCap = gasFeeCap;
    var adjustedGasPremium = gasPremium;

    // TODO: Integrate with RPC provider for nonce and gas estimation
    // This requires implementing the following RPC methods:
    // 1. rpc.nonce(from) - Get next nonce for sender
    // 2. rpc.gasEstimate(msg) - Estimate gas parameters
    //
    // For now, users must provide these values manually

    return FilecoinMessage(
      version: version,
      to: toAddress.toAddress(),
      from: fromAddress.toAddress(),
      nonce: adjustedNonce,
      value: value,
      gasLimit: adjustedGasLimit,
      gasFeeCap: adjustedGasFeeCap,
      gasPremium: adjustedGasPremium,
      method: adjustedMethod,
      params: params,
    );
  }

  /// Serialize message using CBOR encoding
  /// Message format: [version, to, from, nonce, value, gasLimit, gasFeeCap, gasPremium, method, params]
  List<int> serialize() {
    if (_cachedBytes != null) {
      return _cachedBytes!;
    }

    final toAddress = FilecoinAddress.fromString(to);
    final fromAddress = FilecoinAddress.fromString(from);
    final valueToken = FilecoinToken.fromAttoFILString(value);
    final gasFeeCapToken = FilecoinToken.fromAttoFILString(gasFeeCap);
    final gasPremiumToken = FilecoinToken.fromAttoFILString(gasPremium);

    final paramsBytes = params.isEmpty ? <int>[] : base64.decode(params);

    // Manually construct CBOR array with 10 items
    final result = <int>[];

    // Array header (10 items)
    result.add(0x8a);

    // 1. Version (uint)
    result.addAll(_encodeCborUint(version));

    // 2. To address (bytes)
    result.addAll(_encodeCborBytes(toAddress.toBytes()));

    // 3. From address (bytes)
    result.addAll(_encodeCborBytes(fromAddress.toBytes()));

    // 4. Nonce (uint)
    result.addAll(_encodeCborUint(nonce));

    // 5. Value (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(valueToken.toBytes()));

    // 6. Gas limit (uint)
    result.addAll(_encodeCborUint(gasLimit));

    // 7. Gas fee cap (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(gasFeeCapToken.toBytes()));

    // 8. Gas premium (bytes - Filecoin BigInt)
    result.addAll(_encodeCborBytes(gasPremiumToken.toBytes()));

    // 9. Method (uint)
    result.addAll(_encodeCborUint(method));

    // 10. Params (bytes)
    result.addAll(_encodeCborBytes(paramsBytes));

    _cachedBytes = result;
    return result;
  }

  /// Get CID (Content Identifier) for the message
  /// CID = CIDv1 + dag-cbor + Blake2b-256(serialized_message)
  List<int> cidBytes() {
    if (_cachedCidBytes != null) {
      return _cachedCidBytes!;
    }
    _cachedCidBytes = FilecoinUtils.lotusCid(serialize());
    return _cachedCidBytes!;
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
      return [
        26,
        (value >> 24) & 0xFF,
        (value >> 16) & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ];
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
        value & 0xFF,
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
      result.addAll([
        0x5A,
        (len >> 24) & 0xFF,
        (len >> 16) & 0xFF,
        (len >> 8) & 0xFF,
        len & 0xFF,
      ]);
    }

    result.addAll(bytes);
    return result;
  }

  /// Create a copy of the message with updated fields
  FilecoinMessage copyWith({
    int? version,
    String? to,
    String? from,
    int? nonce,
    String? value,
    int? gasLimit,
    String? gasFeeCap,
    String? gasPremium,
    int? method,
    String? params,
  }) {
    return FilecoinMessage(
      version: version ?? this.version,
      to: to ?? this.to,
      from: from ?? this.from,
      nonce: nonce ?? this.nonce,
      value: value ?? this.value,
      gasLimit: gasLimit ?? this.gasLimit,
      gasFeeCap: gasFeeCap ?? this.gasFeeCap,
      gasPremium: gasPremium ?? this.gasPremium,
      method: method ?? this.method,
      params: params ?? this.params,
    );
  }

  @override
  String toString() {
    return 'FilecoinMessage(from: $from, to: $to, value: $value, nonce: $nonce)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilecoinMessage &&
        other.version == version &&
        other.to == to &&
        other.from == from &&
        other.nonce == nonce &&
        other.value == value &&
        other.gasLimit == gasLimit &&
        other.gasFeeCap == gasFeeCap &&
        other.gasPremium == gasPremium &&
        other.method == method &&
        other.params == params;
  }

  @override
  int get hashCode {
    return Object.hash(
      version,
      to,
      from,
      nonce,
      value,
      gasLimit,
      gasFeeCap,
      gasPremium,
      method,
      params,
    );
  }
}
