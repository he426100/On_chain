import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/cip23/cip23_typed_data.dart';
import 'package:on_chain/conflux/src/cip23/cip23_type_field.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';

/// Encoder for CIP-23 typed structured data.
///
/// Implements the CIP-23 specification for hashing and signing typed data.
/// Reference: https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-23.md
class CIP23Encoder {
  const CIP23Encoder._();

  /// Encodes a type definition according to CIP-23 specification.
  ///
  /// Example: "Mail(address from,address to,string contents)"
  /// If the struct references other structs, they are sorted and appended.
  static String encodeType(
    String primaryType,
    Map<String, List<CIP23TypeField>> types,
  ) {
    // Find all referenced types
    final referencedTypes = <String>{};
    _findReferencedTypes(primaryType, types, referencedTypes);

    // Remove primary type from referenced types
    referencedTypes.remove(primaryType);

    // Build type string: primaryType + sorted referenced types
    final buffer = StringBuffer();
    buffer.write(_encodeTypeSignature(primaryType, types));

    // Sort and append referenced types
    final sortedRefs = referencedTypes.toList()..sort();
    for (final refType in sortedRefs) {
      buffer.write(_encodeTypeSignature(refType, types));
    }

    return buffer.toString();
  }

  /// Finds all types referenced by a given type
  static void _findReferencedTypes(
    String typeName,
    Map<String, List<CIP23TypeField>> types,
    Set<String> referenced,
  ) {
    if (!types.containsKey(typeName)) return;
    if (referenced.contains(typeName)) return;

    referenced.add(typeName);

    final fields = types[typeName]!;
    for (final field in fields) {
      // Check if field type is a struct (not atomic or dynamic type)
      if (types.containsKey(field.type)) {
        _findReferencedTypes(field.type, types, referenced);
      } else if (field.type.endsWith('[]')) {
        // Array of structs
        final baseType = field.type.substring(0, field.type.length - 2);
        if (types.containsKey(baseType)) {
          _findReferencedTypes(baseType, types, referenced);
        }
      } else if (field.type.contains('[') && field.type.endsWith(']')) {
        // Fixed-size array
        final baseType = field.type.substring(0, field.type.indexOf('['));
        if (types.containsKey(baseType)) {
          _findReferencedTypes(baseType, types, referenced);
        }
      }
    }
  }

  /// Encodes a single type signature
  static String _encodeTypeSignature(
    String typeName,
    Map<String, List<CIP23TypeField>> types,
  ) {
    final fields = types[typeName];
    if (fields == null) {
      throw ConfluxCIP23Exception('Type "$typeName" not found in types');
    }

    final fieldStrings =
        fields.map((field) => '${field.type} ${field.name}').join(',');
    return '$typeName($fieldStrings)';
  }

  /// Calculates the type hash for a given type
  static List<int> typeHash(
    String typeName,
    Map<String, List<CIP23TypeField>> types,
  ) {
    final typeString = encodeType(typeName, types);
    return QuickCrypto.keccack256Hash(StringUtils.encode(typeString));
  }

  /// Encodes a value according to CIP-23 encoding rules
  static List<int> encodeValue(
    String type,
    dynamic value,
    Map<String, List<CIP23TypeField>> types,
  ) {
    // Handle null values
    if (value == null) {
      return List<int>.filled(32, 0);
    }

    // Handle atomic types
    if (type.startsWith('uint') || type.startsWith('int')) {
      return _encodeInteger(type, value);
    } else if (type == 'bool') {
      return _encodeBool(value);
    } else if (type == 'address') {
      return _encodeAddress(value);
    } else if (type.startsWith('bytes') && type != 'bytes') {
      // Fixed-size bytes (bytes1 to bytes32)
      return _encodeFixedBytes(type, value);
    } else if (type == 'bytes' || type == 'string') {
      // Dynamic types - hash the value
      return _encodeDynamic(value);
    } else if (type.endsWith('[]')) {
      // Dynamic array
      return _encodeArray(type.substring(0, type.length - 2), value, types);
    } else if (type.contains('[') && type.endsWith(']')) {
      // Fixed-size array
      final baseType = type.substring(0, type.indexOf('['));
      return _encodeArray(baseType, value, types);
    } else if (types.containsKey(type)) {
      // Struct type - recursively hash
      return hashStruct(type, value as Map<String, dynamic>, types);
    }

    throw ConfluxCIP23Exception('Unknown type: $type');
  }

  /// Encodes an integer value
  static List<int> _encodeInteger(String type, dynamic value) {
    BigInt bigIntValue;

    if (value is BigInt) {
      bigIntValue = value;
    } else if (value is int) {
      bigIntValue = BigInt.from(value);
    } else if (value is String) {
      // Handle hex strings
      if (value.startsWith('0x')) {
        bigIntValue = BigInt.parse(value.substring(2), radix: 16);
      } else {
        bigIntValue = BigInt.parse(value);
      }
    } else {
      throw ConfluxCIP23Exception('Invalid integer value: $value');
    }

    // Convert to 32-byte big-endian
    return BigintUtils.toBytes(bigIntValue, length: 32, order: Endian.big);
  }

  /// Encodes a boolean value
  static List<int> _encodeBool(dynamic value) {
    final boolValue = value is bool ? value : (value.toString().toLowerCase() == 'true');
    return [...List<int>.filled(31, 0), boolValue ? 1 : 0];
  }

  /// Encodes an address value (converts Base32 to hex if needed)
  static List<int> _encodeAddress(dynamic value) {
    String hexAddress;

    if (value is String) {
      if (value.startsWith('cfx:') || value.startsWith('cfxtest:')) {
        // Convert Base32 to hex
        final cfxAddress = CFXAddress(value);
        hexAddress = cfxAddress.toHex();
      } else {
        hexAddress = value;
      }
    } else {
      throw ConfluxCIP23Exception('Invalid address value: $value');
    }

    // Remove 0x prefix if present
    if (hexAddress.startsWith('0x')) {
      hexAddress = hexAddress.substring(2);
    }

    // Pad to 32 bytes (20-byte address right-aligned)
    final addressBytes = BytesUtils.fromHexString(hexAddress);
    return [...List<int>.filled(12, 0), ...addressBytes];
  }

  /// Encodes fixed-size bytes
  static List<int> _encodeFixedBytes(String type, dynamic value) {
    List<int> bytes;

    if (value is String) {
      if (value.startsWith('0x')) {
        bytes = BytesUtils.fromHexString(value.substring(2));
      } else {
        bytes = BytesUtils.fromHexString(value);
      }
    } else if (value is List<int>) {
      bytes = value;
    } else {
      throw ConfluxCIP23Exception('Invalid bytes value: $value');
    }

    // Pad to 32 bytes (right-padded with zeros)
    if (bytes.length > 32) {
      throw ConfluxCIP23Exception('Bytes value too long: ${bytes.length}');
    }

    return bytes + List<int>.filled(32 - bytes.length, 0);
  }

  /// Encodes dynamic types (bytes and string) as keccak256 hash
  static List<int> _encodeDynamic(dynamic value) {
    List<int> bytes;

    if (value is String) {
      if (value.startsWith('0x')) {
        bytes = BytesUtils.fromHexString(value.substring(2));
      } else {
        bytes = StringUtils.encode(value);
      }
    } else if (value is List<int>) {
      bytes = value;
    } else {
      throw ConfluxCIP23Exception('Invalid dynamic value: $value');
    }

    return QuickCrypto.keccack256Hash(bytes);
  }

  /// Encodes an array
  static List<int> _encodeArray(
    String baseType,
    dynamic value,
    Map<String, List<CIP23TypeField>> types,
  ) {
    if (value is! List) {
      throw ConfluxCIP23Exception('Array value must be a List');
    }

    final encodedValues = <int>[];
    for (final item in value) {
      encodedValues.addAll(encodeValue(baseType, item, types));
    }

    return QuickCrypto.keccack256Hash(encodedValues);
  }

  /// Encodes struct data according to CIP-23
  static List<int> encodeData(
    String typeName,
    Map<String, dynamic> data,
    Map<String, List<CIP23TypeField>> types,
  ) {
    final fields = types[typeName];
    if (fields == null) {
      throw ConfluxCIP23Exception('Type "$typeName" not found');
    }

    final encoded = <int>[];
    for (final field in fields) {
      final value = data[field.name];
      encoded.addAll(encodeValue(field.type, value, types));
    }

    return encoded;
  }

  /// Computes the hash of a struct according to CIP-23
  /// hashStruct(s) = keccak256(typeHash ‖ encodeData(s))
  static List<int> hashStruct(
    String typeName,
    Map<String, dynamic> data,
    Map<String, List<CIP23TypeField>> types,
  ) {
    final typeHashBytes = typeHash(typeName, types);
    final encodedData = encodeData(typeName, data, types);

    return QuickCrypto.keccack256Hash(typeHashBytes + encodedData);
  }

  /// Computes the domain separator
  static List<int> hashDomain(CIP23TypedData typedData) {
    return hashStruct('CIP23Domain', typedData.domain, typedData.types);
  }

  /// Computes the final message hash for signing
  /// encode(domainSeparator, message) = "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
  static List<int> hashMessage(CIP23TypedData typedData) {
    final domainSeparator = hashDomain(typedData);
    final messageHash =
        hashStruct(typedData.primaryType, typedData.message, typedData.types);

    // CIP-23: "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
    final prefix = [0x19, 0x01];
    final combined = prefix + domainSeparator + messageHash;

    return QuickCrypto.keccack256Hash(combined);
  }
}

