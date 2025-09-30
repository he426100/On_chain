import 'package:blockchain_utils/blockchain_utils.dart';

/// Filecoin address types
enum FilecoinAddressType {
  id(0),
  secp256k1(1),
  actor(2),
  bls(3),
  delegated(4);

  const FilecoinAddressType(this.value);
  final int value;

  static FilecoinAddressType fromValue(int value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid Filecoin address type: $value'),
    );
  }
}

/// Filecoin address implementation
class FilecoinAddress {
  static const String prefix = 'f';
  static const int ethereumAddressManagerActorId = 10;
  static const String base32Alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  static const int checksumSize = 4;

  final FilecoinAddressType type;
  final int actorId;
  final List<int> payload;

  const FilecoinAddress({
    required this.type,
    required this.actorId,
    required this.payload,
  });

  /// Create a SECP256K1 address from public key
  factory FilecoinAddress.fromSecp256k1PublicKey(List<int> publicKey) {
    // Use Blake2b with 20 byte output directly (same as wallet-core)
    final payload = QuickCrypto.blake2b160Hash(publicKey);
    return FilecoinAddress(
      type: FilecoinAddressType.secp256k1,
      actorId: 0,
      payload: payload,
    );
  }

  /// Create a delegated address from public key (Ethereum-compatible)
  factory FilecoinAddress.fromDelegatedPublicKey(List<int> publicKey) {
    if (publicKey.length != 65) {
      throw ArgumentError('Extended SECP256k1 public key required for delegated address');
    }

    final hash = QuickCrypto.keccack256Hash(publicKey.sublist(1)); // Remove 0x04 prefix
    final payload = hash.sublist(12); // Last 20 bytes

    return FilecoinAddress(
      type: FilecoinAddressType.delegated,
      actorId: ethereumAddressManagerActorId,
      payload: payload,
    );
  }

  /// Create address from string representation
  factory FilecoinAddress.fromString(String address) {
    if (address.length < 2 || address[0] != prefix) {
      throw ArgumentError('Invalid Filecoin address prefix');
    }

    final typeChar = address[1];
    final type = FilecoinAddressType.fromValue(int.parse(typeChar));

    if (type == FilecoinAddressType.id) {
      final actorId = int.parse(address.substring(2));
      return FilecoinAddress(
        type: type,
        actorId: actorId,
        payload: [],
      );
    }

    int actorId = 0;
    int payloadStart = 2;

    if (type == FilecoinAddressType.delegated) {
      final separatorIndex = address.indexOf('f', 2);
      if (separatorIndex == -1 || separatorIndex <= 2) {
        throw ArgumentError('Invalid delegated address format');
      }
      actorId = int.parse(address.substring(2, separatorIndex));
      payloadStart = separatorIndex + 1;
    }

    final encodedPayload = address.substring(payloadStart);
    // Custom base32 decode for Filecoin
    final decoded = _decodeBase32(encodedPayload, base32Alphabet);

    if (decoded.length < checksumSize) {
      throw ArgumentError('Address payload too short');
    }

    final payload = decoded.sublist(0, decoded.length - checksumSize);
    final checksum = decoded.sublist(decoded.length - checksumSize);

    // Verify checksum
    final expectedChecksum = _calculateChecksum(type, actorId, payload);
    if (!_bytesEqual(checksum, expectedChecksum)) {
      throw ArgumentError('Invalid address checksum');
    }

    return FilecoinAddress(
      type: type,
      actorId: actorId,
      payload: payload,
    );
  }

  /// Convert to string representation
  String toAddress() {
    final buffer = StringBuffer();
    buffer.write(prefix);
    buffer.write(type.value);

    if (type == FilecoinAddressType.id) {
      buffer.write(actorId);
      return buffer.toString();
    }

    if (type == FilecoinAddressType.delegated) {
      buffer.write(actorId);
      buffer.write('f');
    }

    final checksum = _calculateChecksum(type, actorId, payload);
    final toEncode = [...payload, ...checksum];
    final encoded = _encodeBase32(toEncode, base32Alphabet);

    buffer.write(encoded);
    return buffer.toString();
  }

  /// Calculate Blake2b checksum (4 bytes)
  static List<int> _calculateChecksum(FilecoinAddressType type, int actorId, List<int> payload) {
    final toHash = _addressToBytes(type, actorId, payload);
    // Use Blake2b with 4 byte (32 bit) output directly (same as wallet-core)
    return QuickCrypto.blake2b32Hash(toHash);
  }

  /// Convert address components to bytes for checksum calculation
  static List<int> _addressToBytes(FilecoinAddressType type, int actorId, List<int> payload) {
    final result = <int>[type.value];

    if (type == FilecoinAddressType.id || type == FilecoinAddressType.delegated) {
      result.addAll(_encodeActorId(actorId));
    }

    result.addAll(payload);
    return result;
  }

  /// Encode actor ID as unsigned varint
  static List<int> _encodeActorId(int actorId) {
    final result = <int>[];
    while (actorId >= 0x80) {
      result.add((actorId & 0x7F) | 0x80);
      actorId >>= 7;
    }
    result.add(actorId & 0x7F);
    return result;
  }

  /// Convert to bytes representation
  List<int> toBytes() {
    return _addressToBytes(type, actorId, payload);
  }

  /// Validate address string
  static bool isValidAddress(String address) {
    try {
      FilecoinAddress.fromString(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() => toAddress();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilecoinAddress &&
        other.type == type &&
        other.actorId == actorId &&
        _bytesEqual(other.payload, payload);
  }

  @override
  int get hashCode => Object.hash(type, actorId, payload.hashCode);

  /// Helper function to compare byte arrays
  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Custom Base32 decoder for Filecoin alphabet
  static List<int> _decodeBase32(String input, String alphabet) {
    if (input.isEmpty) return [];

    // Remove padding
    input = input.replaceAll('=', '');

    final output = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (final char in input.codeUnits) {
      final value = alphabet.indexOf(String.fromCharCode(char));
      if (value == -1) {
        throw ArgumentError('Invalid character in base32 string');
      }

      buffer = (buffer << 5) | value;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        output.add((buffer >> (bitsLeft - 8)) & 0xFF);
        bitsLeft -= 8;
      }
    }

    return output;
  }

  /// Custom Base32 encoder for Filecoin alphabet
  static String _encodeBase32(List<int> input, String alphabet) {
    if (input.isEmpty) return '';

    final output = StringBuffer();
    int buffer = 0;
    int bitsLeft = 0;

    for (final byte in input) {
      buffer = (buffer << 8) | byte;
      bitsLeft += 8;

      while (bitsLeft >= 5) {
        final index = (buffer >> (bitsLeft - 5)) & 0x1F;
        output.write(alphabet[index]);
        bitsLeft -= 5;
      }
    }

    if (bitsLeft > 0) {
      final index = (buffer << (5 - bitsLeft)) & 0x1F;
      output.write(alphabet[index]);
    }

    return output.toString();
  }
}