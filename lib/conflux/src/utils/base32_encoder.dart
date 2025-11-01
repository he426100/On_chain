import 'package:on_chain/conflux/src/exception/exception.dart';

/// Base32 encoding/decoding for Conflux addresses (CIP-37).
/// 
/// Conflux uses a custom Base32 encoding with a specific character set.
class Base32Encoder {
  Base32Encoder._();

  /// Base32 character set (lowercase) used by Conflux.
  static const String _charset = 'abcdefghjkmnprstuvwxyz0123456789';

  /// Reverse lookup map for decoding.
  static final Map<String, int> _charsetMap = {
    for (var i = 0; i < _charset.length; i++) _charset[i]: i
  };

  /// Polymod constants for checksum calculation (CIP-37).
  static const List<int> _polymodConstants = [
    0x98f2bc8e61,
    0x79b76d99e2,
    0xf33e5fb3c4,
    0xae2eabe2a8,
    0x1e4f43e470,
  ];

  /// Encodes bytes to Base32 string (without checksum).
  static String encode(List<int> bytes) {
    final bits = <bool>[];
    
    // Convert bytes to bits
    for (final byte in bytes) {
      for (var i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1 == 1);
      }
    }

    final result = StringBuffer();
    
    // Convert bits to Base32 characters (5 bits per character)
    for (var i = 0; i < bits.length; i += 5) {
      var value = 0;
      for (var j = 0; j < 5 && i + j < bits.length; j++) {
        if (bits[i + j]) {
          value |= 1 << (4 - j);
        }
      }
      result.write(_charset[value]);
    }

    return result.toString();
  }

  /// Decodes Base32 string to bytes (without checksum verification).
  static List<int> decode(String encoded) {
    final bits = <bool>[];

    // Convert characters to bits
    for (var i = 0; i < encoded.length; i++) {
      final char = encoded[i].toLowerCase();
      final value = _charsetMap[char];
      
      if (value == null) {
        throw InvalidBase32Exception(
          'Invalid Base32 character: $char',
          details: {'position': i, 'character': char},
        );
      }

      // Convert value to 5 bits
      for (var j = 4; j >= 0; j--) {
        bits.add((value >> j) & 1 == 1);
      }
    }

    // Convert bits to bytes
    final bytes = <int>[];
    for (var i = 0; i < bits.length; i += 8) {
      if (i + 8 <= bits.length) {
        var byte = 0;
        for (var j = 0; j < 8; j++) {
          if (bits[i + j]) {
            byte |= 1 << (7 - j);
          }
        }
        bytes.add(byte);
      }
    }

    return bytes;
  }

  /// Calculates polymod for checksum.
  static BigInt _polymod(List<int> values) {
    var checksum = BigInt.one;
    
    for (final value in values) {
      final high = checksum >> 35;
      checksum = ((checksum & BigInt.from(0x07ffffffff)) << 5) ^ BigInt.from(value);
      
      for (var i = 0; i < 5; i++) {
        if ((high >> i) & BigInt.one == BigInt.one) {
          checksum ^= BigInt.from(_polymodConstants[i]);
        }
      }
    }

    return checksum;
  }

  /// Converts string to polymod values.
  static List<int> _stringToValues(String str) {
    final values = <int>[];
    for (var i = 0; i < str.length; i++) {
      values.add(str.codeUnitAt(i) & 0x1f);
    }
    return values;
  }

  /// Calculates checksum for given prefix and payload.
  static String calculateChecksum(String prefix, List<int> payload) {
    // Convert prefix to values
    final prefixValues = _stringToValues(prefix);
    
    // Convert payload to Base32 values
    final payloadStr = encode(payload);
    final payloadValues = <int>[];
    for (var i = 0; i < payloadStr.length; i++) {
      payloadValues.add(_charsetMap[payloadStr[i]]!);
    }

    // Combine: prefix + 0 separator + payload + 8 zeros
    final values = [...prefixValues, 0, ...payloadValues, 0, 0, 0, 0, 0, 0, 0, 0];
    
    final polymod = _polymod(values) ^ BigInt.one;
    
    // Convert polymod to checksum string (8 characters)
    final checksum = StringBuffer();
    for (var i = 0; i < 8; i++) {
      final value = ((polymod >> (5 * (7 - i))) & BigInt.from(0x1f)).toInt();
      checksum.write(_charset[value]);
    }

    return checksum.toString();
  }

  /// Verifies checksum for given address.
  static bool verifyChecksum(String prefix, String encoded) {
    try {
      // Extract payload and checksum
      if (encoded.length < 8) return false;
      
      final payloadPart = encoded.substring(0, encoded.length - 8);
      final checksumPart = encoded.substring(encoded.length - 8);

      // Decode payload
      final payload = decode(payloadPart);
      
      // Calculate expected checksum
      final expectedChecksum = calculateChecksum(prefix, payload);

      return expectedChecksum == checksumPart;
    } catch (_) {
      return false;
    }
  }

  /// Encodes bytes with checksum.
  static String encodeWithChecksum(String prefix, List<int> bytes) {
    final encoded = encode(bytes);
    final checksum = calculateChecksum(prefix, bytes);
    return '$encoded$checksum';
  }

  /// Decodes Base32 with checksum verification.
  static List<int> decodeWithChecksum(String prefix, String encoded) {
    if (!verifyChecksum(prefix, encoded)) {
      throw InvalidChecksumException(
        'Invalid checksum for Base32 address',
        details: {'prefix': prefix, 'encoded': encoded},
      );
    }

    // Remove checksum and decode
    final payloadPart = encoded.substring(0, encoded.length - 8);
    return decode(payloadPart);
  }
}

