import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/models/access_list.dart';
import 'package:on_chain/conflux/src/transaction/transaction_type.dart';
import 'package:on_chain/conflux/src/rlp/rlp.dart';

/// Internal RLP encoding (copied from Ethereum RLP encoder to bypass type restrictions).
List<int> _rlpEncode(dynamic object) {
  return _rlpEncodeInternal(object);
}

/// Encodes an integer value into bytes for RLP.
List<int> _rlpEncodeArray(int value) {
  final result = <int>[];
  while (value != 0) {
    result.insert(0, value & 0xff);
    value >>= 8;
  }
  return result;
}

/// Recursive RLP encoding.
List<int> _rlpEncodeInternal(List<dynamic> object) {
  if (object is! List<int>) {
    final payload = <int>[];
    for (final child in object) {
      payload.addAll(_rlpEncodeInternal(child));
    }

    if (payload.length <= 55) {
      payload.insert(0, 0xc0 + payload.length);
      return payload;
    }

    final length = _rlpEncodeArray(payload.length);
    length.insert(0, 0xf7 + length.length);
    return [...length, ...payload];
  }

  final data = List<int>.from(object, growable: true);

  if (data.length == 1 && data[0] <= 0x7f) {
    return data;
  } else if (data.length <= 55) {
    data.insert(0, 0x80 + data.length);
    return data;
  }

  final length = _rlpEncodeArray(data.length);
  length.insert(0, 0xb7 + length.length);

  return [...length, ...data];
}

/// Type prefixes for Conflux transactions (matches js-conflux-sdk).
/// Format: "cfx" + type byte
class _CFXTransactionPrefix {
  static const List<int> eip2930 = [0x63, 0x66, 0x78, 0x01]; // "cfx\x01"
  static const List<int> eip1559 = [0x63, 0x66, 0x78, 0x02]; // "cfx\x02"
}

/// Represents a Conflux Core Space transaction.
/// 
/// Supports three transaction types:
/// - Legacy: Original transaction format with gasPrice
/// - EIP-2930: Adds access lists for gas optimization
/// - EIP-1559: Dynamic fee pricing with maxFeePerGas and maxPriorityFeePerGas
/// 
/// Core Space transactions have additional fields compared to Ethereum:
/// - storageLimit: Maximum storage to be collateralized
/// - epochHeight: Target epoch height for the transaction
class CFXTransaction {
  CFXTransaction({
    this.type = CFXTransactionType.legacy,
    required this.nonce,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    required this.gas,
    this.to,
    required this.value,
    required this.storageLimit,
    required this.epochHeight,
    required this.chainId,
    this.data = const [],
    this.accessList,
    this.v,
    this.r,
    this.s,
  }) {
    // Validate transaction parameters based on type
    if (type == CFXTransactionType.legacy) {
      if (gasPrice == null) {
        throw InvalidConfluxTransactionException(
          'Legacy transaction requires gasPrice',
        );
      }
      if (maxFeePerGas != null || maxPriorityFeePerGas != null) {
        throw InvalidConfluxTransactionException(
          'Legacy transaction cannot have maxFeePerGas or maxPriorityFeePerGas',
        );
      }
      if (accessList != null) {
        throw InvalidConfluxTransactionException(
          'Legacy transaction cannot have accessList',
        );
      }
    } else if (type == CFXTransactionType.eip2930) {
      if (gasPrice == null) {
        throw InvalidConfluxTransactionException(
          'EIP-2930 transaction requires gasPrice',
        );
      }
      if (maxFeePerGas != null || maxPriorityFeePerGas != null) {
        throw InvalidConfluxTransactionException(
          'EIP-2930 transaction cannot have maxFeePerGas or maxPriorityFeePerGas',
        );
      }
    } else if (type == CFXTransactionType.eip1559) {
      if (maxFeePerGas == null || maxPriorityFeePerGas == null) {
        throw InvalidConfluxTransactionException(
          'EIP-1559 transaction requires maxFeePerGas and maxPriorityFeePerGas',
        );
      }
      if (gasPrice != null) {
        throw InvalidConfluxTransactionException(
          'EIP-1559 transaction cannot have gasPrice',
        );
      }
    }
  }

  /// The transaction type (legacy, EIP-2930, or EIP-1559).
  final CFXTransactionType type;

  /// The transaction nonce.
  final BigInt nonce;

  /// The gas price in Drip (10^-18 CFX) for Legacy and EIP-2930 transactions.
  final BigInt? gasPrice;

  /// Maximum fee per gas for EIP-1559 transactions.
  final BigInt? maxFeePerGas;

  /// Maximum priority fee per gas (tip) for EIP-1559 transactions.
  final BigInt? maxPriorityFeePerGas;

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

  /// The access list for EIP-2930 and EIP-1559 transactions.
  final AccessList? accessList;

  /// The signature v value.
  final int? v;

  /// The signature r value.
  final List<int>? r;

  /// The signature s value.
  final List<int>? s;

  /// Checks if this transaction is signed.
  bool get isSigned => v != null && r != null && s != null;

  /// Returns the type prefix for this transaction type.
  List<int> _getTypePrefix() {
    switch (type) {
      case CFXTransactionType.eip2930:
        return _CFXTransactionPrefix.eip2930;
      case CFXTransactionType.eip1559:
        return _CFXTransactionPrefix.eip1559;
      case CFXTransactionType.legacy:
        return [];
      default:
        throw InvalidConfluxTransactionException('Unknown transaction type');
    }
  }

  /// Encodes the transaction for signing (without signature fields).
  List<int> encodeForSigning() {
    final List<dynamic> encoded;

    if (type == CFXTransactionType.legacy) {
      // Legacy: [nonce, gasPrice, gas, to, value, storageLimit, epochHeight, chainId, data]
      encoded = [
        _encodeValue(nonce),
        _encodeValue(gasPrice!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
      ];
    } else if (type == CFXTransactionType.eip2930) {
      // EIP-2930: [nonce, gasPrice, gas, to, value, storageLimit, epochHeight, chainId, data, accessList]
      final accessListEncoded = accessList != null ? accessList!.serialize() : <List<dynamic>>[];
      encoded = [
        _encodeValue(nonce),
        _encodeValue(gasPrice!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
        accessListEncoded,
      ];
    } else {
      // EIP-1559: [nonce, maxPriorityFeePerGas, maxFeePerGas, gas, to, value, storageLimit, epochHeight, chainId, data, accessList]
      final accessListEncoded = accessList != null ? accessList!.serialize() : <List<dynamic>>[];
      encoded = [
        _encodeValue(nonce),
        _encodeValue(maxPriorityFeePerGas!),
        _encodeValue(maxFeePerGas!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
        accessListEncoded,
      ];
    }

    final rlpEncoded = _rlpEncode(encoded);
    final prefix = _getTypePrefix();
    return prefix.isEmpty ? rlpEncoded : [...prefix, ...rlpEncoded];
  }

  /// Encodes the transaction with signature.
  List<int> serialize() {
    if (!isSigned) {
      throw InvalidConfluxTransactionException(
        'Cannot serialize unsigned transaction',
      );
    }

    List<dynamic> encoded;

    if (type == CFXTransactionType.legacy) {
      // Legacy: [[nonce, gasPrice, gas, to, value, storageLimit, epochHeight, chainId, data], v, r, s] (nested structure)
      // This matches js-conflux-sdk implementation
      final fields = [
        _encodeValue(nonce),
        _encodeValue(gasPrice!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
      ];
      // v must be encoded correctly: 0 -> [], 1 -> [1], etc. (no leading zeros)
      final vEncoded = v! == 0 ? <int>[] : <int>[v!];
      encoded = [fields, vEncoded, r!, s!];
    } else if (type == CFXTransactionType.eip2930) {
      // EIP-2930: [[fields, accessList], v, r, s] (nested structure)
      final accessListEncoded = accessList != null ? accessList!.serialize() : <List<dynamic>>[];
      final fields = [
        _encodeValue(nonce),
        _encodeValue(gasPrice!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
        accessListEncoded,
      ];
      // v must be encoded correctly: 0 -> [], 1 -> [1], etc. (no leading zeros)
      final vEncoded = v! == 0 ? <int>[] : <int>[v!];
      encoded = [fields, vEncoded, r!, s!];
    } else {
      // EIP-1559: [[fields, accessList], v, r, s] (nested structure)
      final accessListEncoded = accessList != null ? accessList!.serialize() : <List<dynamic>>[];
      final fields = [
        _encodeValue(nonce),
        _encodeValue(maxPriorityFeePerGas!),
        _encodeValue(maxFeePerGas!),
        _encodeValue(gas),
        to != null ? BytesUtils.fromHexString(to!.hexAddress) : <int>[],
        _encodeValue(value),
        _encodeValue(storageLimit),
        _encodeValue(epochHeight),
        _encodeValue(chainId),
        data,
        accessListEncoded,
      ];
      // v must be encoded correctly: 0 -> [], 1 -> [1], etc. (no leading zeros)
      final vEncoded = v! == 0 ? <int>[] : <int>[v!];
      encoded = [fields, vEncoded, r!, s!];
    }

    final rlpEncoded = _rlpEncode(encoded);
    final prefix = _getTypePrefix();
    return prefix.isEmpty ? rlpEncoded : [...prefix, ...rlpEncoded];
  }

  /// Calculates the transaction hash (Keccak256 of RLP-encoded tx).
  List<int> getTransactionHash() {
    final encoded = serialize();
    return QuickCrypto.keccack256Hash(encoded);
  }

  /// Returns the transaction hash as a hex string.
  String getTransactionHashHex() {
    return '0x${BytesUtils.toHexString(getTransactionHash())}';
  }

  /// Creates a copy of this transaction with optional modifications.
  CFXTransaction copyWith({
    CFXTransactionType? type,
    BigInt? nonce,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    BigInt? gas,
    CFXAddress? to,
    BigInt? value,
    BigInt? storageLimit,
    BigInt? epochHeight,
    BigInt? chainId,
    List<int>? data,
    AccessList? accessList,
    int? v,
    List<int>? r,
    List<int>? s,
  }) {
    return CFXTransaction(
      type: type ?? this.type,
      nonce: nonce ?? this.nonce,
      gasPrice: gasPrice ?? this.gasPrice,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
      gas: gas ?? this.gas,
      to: to ?? this.to,
      value: value ?? this.value,
      storageLimit: storageLimit ?? this.storageLimit,
      epochHeight: epochHeight ?? this.epochHeight,
      chainId: chainId ?? this.chainId,
      data: data ?? this.data,
      accessList: accessList ?? this.accessList,
      v: v ?? this.v,
      r: r ?? this.r,
      s: s ?? this.s,
    );
  }

  /// Decodes a transaction from raw hex string or bytes.
  factory CFXTransaction.fromRawTransaction(dynamic raw) {
    final List<int> bytes;
    if (raw is String) {
      bytes = BytesUtils.fromHexString(raw);
    } else if (raw is List<int>) {
      bytes = raw;
    } else {
      throw InvalidConfluxTransactionException(
        'Invalid raw transaction type: expected String or List<int>',
      );
    }

    // Check for type prefix
    if (bytes.length >= 4) {
      final prefix = bytes.sublist(0, 4);
      if (_listEquals(prefix, _CFXTransactionPrefix.eip2930)) {
        return _decode2930(bytes.sublist(4));
      } else if (_listEquals(prefix, _CFXTransactionPrefix.eip1559)) {
        return _decode1559(bytes.sublist(4));
      }
    }

    // Default to legacy
    return _decodeLegacy(bytes);
  }

  /// Decodes a Legacy transaction from RLP-encoded bytes.
  factory CFXTransaction.fromRlp(List<int> rlpBytes) {
    return _decodeLegacy(rlpBytes);
  }

  /// Helper to compare two lists.
  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Decodes a Legacy transaction.
  /// Format: [[nonce, gasPrice, gas, to, value, storageLimit, epochHeight, chainId, data], v, r, s]
  static CFXTransaction _decodeLegacy(List<int> bytes) {
    final decodedList = RLPDecoder.decode(bytes);

    if (decodedList.isEmpty) {
      throw InvalidConfluxTransactionException('Empty RLP data');
    }

    if (decodedList.length < 2) {
      throw InvalidConfluxTransactionException(
        'Invalid transaction: insufficient fields',
      );
    }

    // First element is the fields array
    final fields = decodedList[0] as List;

    if (fields.length < 9) {
      throw InvalidConfluxTransactionException(
        'Invalid transaction: insufficient fields in unsigned part',
      );
    }

    final nonce = _decodeValue(fields[0]);
    final gasPrice = _decodeValue(fields[1]);
    final gas = _decodeValue(fields[2]);
    final toBytes = fields[3] as List<int>;
    final value = _decodeValue(fields[4]);
    final storageLimit = _decodeValue(fields[5]);
    final epochHeight = _decodeValue(fields[6]);
    final chainId = _decodeValue(fields[7]);
    final data = List<int>.from(fields[8]);

    CFXAddress? to;
    if (toBytes.isNotEmpty) {
      final hexAddress = '0x${BytesUtils.toHexString(toBytes)}';
      to = CFXAddress.fromHex(hexAddress, chainId.toInt());
    }

    // Check if signed
    int? v;
    List<int>? r;
    List<int>? s;

    if (decodedList.length >= 4) {
      final vBytes = decodedList[1] as List<int>;
      // RLP: 空字节数组表示整数0，因此 [] -> 0, [v] -> v
      v = vBytes.isNotEmpty ? vBytes[0] : 0;
      r = List<int>.from(decodedList[2]);
      s = List<int>.from(decodedList[3]);
    }

    return CFXTransaction(
      type: CFXTransactionType.legacy,
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

  /// Decodes an EIP-2930 transaction.
  static CFXTransaction _decode2930(List<int> bytes) {
    final decodedList = RLPDecoder.decode(bytes);

    if (decodedList.length < 2) {
      throw InvalidConfluxTransactionException(
        'Invalid EIP-2930 transaction structure',
      );
    }

    final fields = decodedList[0] as List;

    if (fields.length < 10) {
      throw InvalidConfluxTransactionException(
        'Invalid EIP-2930 transaction: insufficient fields',
      );
    }

    final nonce = _decodeValue(fields[0]);
    final gasPrice = _decodeValue(fields[1]);
    final gas = _decodeValue(fields[2]);
    final toBytes = fields[3] as List<int>;
    final value = _decodeValue(fields[4]);
    final storageLimit = _decodeValue(fields[5]);
    final epochHeight = _decodeValue(fields[6]);
    final chainId = _decodeValue(fields[7]);
    final data = List<int>.from(fields[8]);
    final accessListData = fields[9] as List;

    CFXAddress? to;
    if (toBytes.isNotEmpty) {
      final hexAddress = '0x${BytesUtils.toHexString(toBytes)}';
      to = CFXAddress.fromHex(hexAddress, chainId.toInt());
    }

    // Decode access list
    AccessList? accessList;
    if (accessListData.isNotEmpty) {
      accessList = accessListData
          .map((e) => AccessListEntry.fromSerialized(e as List))
          .toList();
    }

    // Check if signed
    int? v;
    List<int>? r;
    List<int>? s;

    if (decodedList.length >= 4) {
      final vBytes = decodedList[1] as List<int>;
      // RLP: 空字节数组表示整数0，因此 [] -> 0, [v] -> v
      v = vBytes.isNotEmpty ? vBytes[0] : 0;
      r = List<int>.from(decodedList[2]);
      s = List<int>.from(decodedList[3]);
    }

    return CFXTransaction(
      type: CFXTransactionType.eip2930,
      nonce: nonce,
      gasPrice: gasPrice,
      gas: gas,
      to: to,
      value: value,
      storageLimit: storageLimit,
      epochHeight: epochHeight,
      chainId: chainId,
      data: data,
      accessList: accessList,
      v: v,
      r: r,
      s: s,
    );
  }

  /// Decodes an EIP-1559 transaction.
  static CFXTransaction _decode1559(List<int> bytes) {
    final decodedList = RLPDecoder.decode(bytes);

    if (decodedList.length < 2) {
      throw InvalidConfluxTransactionException(
        'Invalid EIP-1559 transaction structure',
      );
    }

    final fields = decodedList[0] as List;

    if (fields.length < 11) {
      throw InvalidConfluxTransactionException(
        'Invalid EIP-1559 transaction: insufficient fields',
      );
    }

    final nonce = _decodeValue(fields[0]);
    final maxPriorityFeePerGas = _decodeValue(fields[1]);
    final maxFeePerGas = _decodeValue(fields[2]);
    final gas = _decodeValue(fields[3]);
    final toBytes = fields[4] as List<int>;
    final value = _decodeValue(fields[5]);
    final storageLimit = _decodeValue(fields[6]);
    final epochHeight = _decodeValue(fields[7]);
    final chainId = _decodeValue(fields[8]);
    final data = List<int>.from(fields[9]);
    final accessListData = fields[10] as List;

    CFXAddress? to;
    if (toBytes.isNotEmpty) {
      final hexAddress = '0x${BytesUtils.toHexString(toBytes)}';
      to = CFXAddress.fromHex(hexAddress, chainId.toInt());
    }

    // Decode access list
    AccessList? accessList;
    if (accessListData.isNotEmpty) {
      accessList = accessListData
          .map((e) => AccessListEntry.fromSerialized(e as List))
          .toList();
    }

    // Check if signed
    int? v;
    List<int>? r;
    List<int>? s;

    if (decodedList.length >= 4) {
      final vBytes = decodedList[1] as List<int>;
      // RLP: 空字节数组表示整数0，因此 [] -> 0, [v] -> v
      v = vBytes.isNotEmpty ? vBytes[0] : 0;
      r = List<int>.from(decodedList[2]);
      s = List<int>.from(decodedList[3]);
    }

    return CFXTransaction(
      type: CFXTransactionType.eip1559,
      nonce: nonce,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      gas: gas,
      to: to,
      value: value,
      storageLimit: storageLimit,
      epochHeight: epochHeight,
      chainId: chainId,
      data: data,
      accessList: accessList,
      v: v,
      r: r,
      s: s,
    );
  }

  /// Helper method to encode BigInt values.
  static List<int> _encodeValue(BigInt value) {
    if (value == BigInt.zero) return [];
    final bytes =
        BigintUtils.toBytes(value, length: BigintUtils.bitlengthInBytes(value));
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
    final json = {
      'type': type.value,
      'nonce': '0x${nonce.toRadixString(16)}',
      'gas': '0x${gas.toRadixString(16)}',
      'to': to?.toBase32(),
      'value': '0x${value.toRadixString(16)}',
      'storageLimit': '0x${storageLimit.toRadixString(16)}',
      'epochHeight': '0x${epochHeight.toRadixString(16)}',
      'chainId': '0x${chainId.toRadixString(16)}',
      'data': '0x${BytesUtils.toHexString(data)}',
    };

    if (gasPrice != null) {
      json['gasPrice'] = '0x${gasPrice!.toRadixString(16)}';
    }
    if (maxFeePerGas != null) {
      json['maxFeePerGas'] = '0x${maxFeePerGas!.toRadixString(16)}';
    }
    if (maxPriorityFeePerGas != null) {
      json['maxPriorityFeePerGas'] =
          '0x${maxPriorityFeePerGas!.toRadixString(16)}';
    }
    if (accessList != null && accessList!.isNotEmpty) {
      json['accessList'] = accessList!.toJson();
    }
    if (isSigned) {
      json['v'] = v;
      json['r'] = '0x${BytesUtils.toHexString(r!)}';
      json['s'] = '0x${BytesUtils.toHexString(s!)}';
    }

    return json;
  }

  @override
  String toString() => toJson().toString();
}
