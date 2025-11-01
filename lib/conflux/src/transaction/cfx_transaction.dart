import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/rlp/rlp.dart';
import 'package:on_chain/ethereum/ethereum.dart';

/// Represents a Conflux Core Space transaction.
/// 
/// Core Space transactions have additional fields compared to Ethereum:
/// - storageLimit: Maximum storage to be collateralized
/// - epochHeight: Target epoch height for the transaction
class CFXTransaction {
  CFXTransaction({
    required this.nonce,
    required this.gasPrice,
    required this.gas,
    this.to,
    required this.value,
    required this.storageLimit,
    required this.epochHeight,
    required this.chainId,
    this.data = const [],
    this.v,
    this.r,
    this.s,
  });

  /// The transaction nonce.
  final BigInt nonce;

  /// The gas price in Drip (10^-18 CFX).
  final BigInt gasPrice;

  /// The gas limit.
  final BigInt gas;

  /// The recipient address (null for contract creation).
  final CFXAddress? to;

  /// The value to transfer in Drip.
  final BigInt value;

  /// The maximum storage to collateralize in bytes.
  final BigInt storageLimit;

  /// The target epoch height.
  final BigInt epochHeight;

  /// The chain ID.
  final BigInt chainId;

  /// The transaction data/input.
  final List<int> data;

  /// The signature v value.
  final int? v;

  /// The signature r value.
  final List<int>? r;

  /// The signature s value.
  final List<int>? s;

  /// Checks if this transaction is signed.
  bool get isSigned => v != null && r != null && s != null;

  /// Encodes the transaction for signing (without signature fields).
  List<int> encodeForSigning() {
    final encoded = [
      _encodeValue(nonce),
      _encodeValue(gasPrice),
      _encodeValue(gas),
      to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
      _encodeValue(value),
      _encodeValue(storageLimit),
      _encodeValue(epochHeight),
      _encodeValue(chainId),
      data,
    ];

    return RLPEncoder.encode(encoded);
  }

  /// Encodes the transaction with signature.
  List<int> serialize() {
    if (!isSigned) {
      throw InvalidConfluxTransactionException(
        'Cannot serialize unsigned transaction',
      );
    }

    final encoded = [
      _encodeValue(nonce),
      _encodeValue(gasPrice),
      _encodeValue(gas),
      to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
      _encodeValue(value),
      _encodeValue(storageLimit),
      _encodeValue(epochHeight),
      _encodeValue(chainId),
      data,
      <int>[v!],
      r!,
      s!,
    ];

    return RLPEncoder.encode(encoded);
  }

  /// Calculates the transaction hash (Keccak256 of RLP-encoded tx).
  List<int> getTransactionHash() {
    final encoded = serialize();
    // Use blockchain_utils QuickCrypto keccack256Hash (note: double 'c')
    return QuickCrypto.keccack256Hash(encoded);
  }

  /// Returns the transaction hash as a hex string.
  String getTransactionHashHex() {
    return '0x${BytesUtils.toHexString(getTransactionHash())}';
  }

  /// Creates a copy of this transaction with optional modifications.
  CFXTransaction copyWith({
    BigInt? nonce,
    BigInt? gasPrice,
    BigInt? gas,
    CFXAddress? to,
    BigInt? value,
    BigInt? storageLimit,
    BigInt? epochHeight,
    BigInt? chainId,
    List<int>? data,
    int? v,
    List<int>? r,
    List<int>? s,
  }) {
    return CFXTransaction(
      nonce: nonce ?? this.nonce,
      gasPrice: gasPrice ?? this.gasPrice,
      gas: gas ?? this.gas,
      to: to ?? this.to,
      value: value ?? this.value,
      storageLimit: storageLimit ?? this.storageLimit,
      epochHeight: epochHeight ?? this.epochHeight,
      chainId: chainId ?? this.chainId,
      data: data ?? this.data,
      v: v ?? this.v,
      r: r ?? this.r,
      s: s ?? this.s,
    );
  }

  /// Decodes a transaction from RLP-encoded bytes.
  factory CFXTransaction.fromRlp(List<int> rlpBytes) {
    // RLPDecoder.decode returns List<dynamic> for transaction data
    final decodedList = RLPDecoder.decode(rlpBytes);
    
    if (decodedList.isEmpty) {
      throw InvalidConfluxTransactionException('Empty RLP data');
    }

    if (decodedList.length < 9) {
      throw InvalidConfluxTransactionException(
        'Invalid transaction: insufficient fields',
      );
    }

    final nonce = _decodeValue(decodedList[0]);
    final gasPrice = _decodeValue(decodedList[1]);
    final gas = _decodeValue(decodedList[2]);
    final toBytes = decodedList[3] as List<int>;
    final value = _decodeValue(decodedList[4]);
    final storageLimit = _decodeValue(decodedList[5]);
    final epochHeight = _decodeValue(decodedList[6]);
    final chainId = _decodeValue(decodedList[7]);
    final data = decodedList[8] as List<int>;

    CFXAddress? to;
    if (toBytes.isNotEmpty) {
      final hexAddress = '0x${BytesUtils.toHexString(toBytes)}';
      // We need network ID to construct CFXAddress, use chainId as approximation
      to = CFXAddress.fromHex(hexAddress, chainId.toInt());
    }

    // Check if signed
    int? v;
    List<int>? r;
    List<int>? s;

    if (decodedList.length >= 12) {
      final vBytes = decodedList[9] as List<int>;
      v = vBytes.isNotEmpty ? vBytes[0] : null;
      r = decodedList[10] as List<int>;
      s = decodedList[11] as List<int>;
    }

    return CFXTransaction(
      nonce: nonce,
      gasPrice: gasPrice,
      gas: gas,
      to: to,
      value: value,
      storageLimit: storageLimit,
      epochHeight: epochHeight,
      chainId: chainId,
      data: data,
      v: v,
      r: r,
      s: s,
    );
  }

  /// Helper method to encode BigInt values.
  static List<int> _encodeValue(BigInt value) {
    if (value == BigInt.zero) return [];
    final bytes = BigintUtils.toBytes(value, length: BigintUtils.bitlengthInBytes(value));
    // Remove leading zeros
    int start = 0;
    while (start < bytes.length && bytes[start] == 0) {
      start++;
    }
    return bytes.sublist(start);
  }

  /// Helper method to decode BigInt values.
  static BigInt _decodeValue(dynamic value) {
    if (value is List) {
      final bytes = List<int>.from(value);
      if (bytes.isEmpty) return BigInt.zero;
      return BigintUtils.fromBytes(bytes);
    }
    throw InvalidConfluxTransactionException('Invalid encoded value type');
  }

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'nonce': '0x${nonce.toRadixString(16)}',
      'gasPrice': '0x${gasPrice.toRadixString(16)}',
      'gas': '0x${gas.toRadixString(16)}',
      'to': to?.toBase32(),
      'value': '0x${value.toRadixString(16)}',
      'storageLimit': '0x${storageLimit.toRadixString(16)}',
      'epochHeight': '0x${epochHeight.toRadixString(16)}',
      'chainId': '0x${chainId.toRadixString(16)}',
      'data': '0x${BytesUtils.toHexString(data)}',
      if (isSigned) ...{
        'v': v,
        'r': '0x${BytesUtils.toHexString(r!)}',
        's': '0x${BytesUtils.toHexString(s!)}',
      },
    };
  }

  @override
  String toString() => toJson().toString();
}

