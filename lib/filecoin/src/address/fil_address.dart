import 'package:blockchain_utils/blockchain_utils.dart';
import '../network/filecoin_network.dart';

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
  static const int ethereumAddressManagerActorId = 10;
  static const String base32Alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  static const int checksumSize = 4;
  static const String prefix = 'f'; // Mainnet prefix

  final FilecoinAddressType type;
  final int actorId;
  final List<int> payload;
  final FilecoinNetwork network;

  const FilecoinAddress({
    required this.type,
    required this.actorId,
    required this.payload,
    this.network = FilecoinNetwork.mainnet,
  });

  /// Create a SECP256K1 address from public key
  factory FilecoinAddress.fromSecp256k1PublicKey(
    List<int> publicKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    // Use Blake2b with 20 byte output directly (same as wallet-core)
    final payload = QuickCrypto.blake2b160Hash(publicKey);
    return FilecoinAddress(
      type: FilecoinAddressType.secp256k1,
      actorId: 0,
      payload: payload,
      network: network,
    );
  }

  /// Create a delegated address from public key (Ethereum-compatible)
  factory FilecoinAddress.fromDelegatedPublicKey(
    List<int> publicKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    if (publicKey.length != 65) {
      throw ArgumentError('Extended SECP256k1 public key required for delegated address');
    }

    final hash = QuickCrypto.keccack256Hash(publicKey.sublist(1)); // Remove 0x04 prefix
    final payload = hash.sublist(12); // Last 20 bytes

    return FilecoinAddress(
      type: FilecoinAddressType.delegated,
      actorId: ethereumAddressManagerActorId,
      payload: payload,
      network: network,
    );
  }

  /// Create address from string representation with automatic network detection
  /// Accepts both mainnet ('f') and testnet ('t') addresses
  factory FilecoinAddress.fromString(String address) {
    if (address.length < 2) {
      throw ArgumentError('Invalid Filecoin address: too short');
    }

    // Determine network from prefix
    final networkPrefix = address[0];
    if (!FilecoinNetwork.isValidPrefix(networkPrefix)) {
      throw ArgumentError('Invalid Filecoin address prefix: $networkPrefix');
    }
    final network = FilecoinNetwork.fromPrefix(networkPrefix);

    final typeChar = address[1];
    final type = FilecoinAddressType.fromValue(int.parse(typeChar));

    if (type == FilecoinAddressType.id) {
      final actorIdStr = address.substring(2);
      final actorId = _parseActorIdString(actorIdStr);
      return FilecoinAddress(
        type: type,
        actorId: actorId,
        payload: [],
        network: network,
      );
    }

    int actorId = 0;
    int payloadStart = 2;

    if (type == FilecoinAddressType.delegated) {
      final separatorIndex = address.indexOf('f', 2);
      if (separatorIndex == -1 || separatorIndex <= 2) {
        throw ArgumentError('Invalid delegated address format');
      }
      final actorIdStr = address.substring(2, separatorIndex);
      actorId = _parseActorIdString(actorIdStr);
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
      network: network,
    );
  }

  /// Convert to string representation
  String toAddress() {
    final buffer = StringBuffer();
    buffer.write(network.prefix);
    buffer.write(type.value);

    if (type == FilecoinAddressType.id) {
      // Handle uint64_t max case (stored as -1 in signed int64)
      if (actorId == -1) {
        buffer.write('18446744073709551615');
      } else {
        buffer.write(actorId);
      }
      return buffer.toString();
    }

    if (type == FilecoinAddressType.delegated) {
      // Handle uint64_t max case (stored as -1 in signed int64)
      if (actorId == -1) {
        buffer.write('18446744073709551615');
      } else {
        buffer.write(actorId);
      }
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
    // Handle uint64_t max case (stored as -1 in signed int64)
    // This should encode as: ff ff ff ff ff ff ff ff ff 01
    if (actorId == -1) {
      return [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01];
    }

    final result = <int>[];
    var value = actorId;
    while (value >= 0x80) {
      result.add((value & 0x7F) | 0x80);
      value >>= 7;
    }
    result.add(value & 0x7F);
    return result;
  }

  /// Convert to bytes representation
  List<int> toBytes() {
    return _addressToBytes(type, actorId, payload);
  }

  /// Validate address string (accepts both mainnet and testnet addresses)
  static bool isValidAddress(String address) {
    try {
      FilecoinAddress.fromString(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate address string for a specific network
  /// Returns true only if the address is valid AND matches the expected network
  static bool isValidAddressForNetwork(String address, FilecoinNetwork network) {
    try {
      final addr = FilecoinAddress.fromString(address);
      return addr.network == network;
    } catch (e) {
      return false;
    }
  }

  /// Validate address bytes
  static bool isValidBytes(List<int> bytes) {
    try {
      FilecoinAddress.fromBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create address from bytes representation
  factory FilecoinAddress.fromBytes(
    List<int> encoded, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    // Should contain at least one byte (address type).
    if (encoded.isEmpty) {
      throw ArgumentError('Empty address bytes');
    }

    // Get address type
    final typeValue = encoded[0];
    FilecoinAddressType type;
    try {
      type = FilecoinAddressType.fromValue(typeValue);
    } catch (e) {
      throw ArgumentError('Invalid address type: $typeValue');
    }

    final withoutPrefix = encoded.sublist(1);

    switch (type) {
      case FilecoinAddressType.id:
        final result = _decodeActorId(withoutPrefix);
        if (result == null) {
          throw ArgumentError('Invalid actor ID encoding');
        }
        final actorId = result.$1;
        final remainingPos = result.$2;

        // Check if there are no remaining bytes
        if (remainingPos != withoutPrefix.length) {
          throw ArgumentError('Extra bytes after actor ID');
        }

        return FilecoinAddress(
          type: type,
          actorId: actorId,
          payload: [],
          network: network,
        );

      case FilecoinAddressType.secp256k1:
      case FilecoinAddressType.actor:
      case FilecoinAddressType.bls:
        if (!_isValidPayloadSize(type, withoutPrefix.length)) {
          throw ArgumentError('Invalid payload size for type $type');
        }
        return FilecoinAddress(
          type: type,
          actorId: 0,
          payload: withoutPrefix,
          network: network,
        );

      case FilecoinAddressType.delegated:
        final result = _decodeActorId(withoutPrefix);
        if (result == null) {
          throw ArgumentError('Invalid actor ID encoding in delegated address');
        }
        final actorId = result.$1;
        final remainingPos = result.$2;

        final payloadSize = withoutPrefix.length - remainingPos;
        if (!_isValidPayloadSize(type, payloadSize)) {
          throw ArgumentError('Invalid payload size for delegated address');
        }

        return FilecoinAddress(
          type: type,
          actorId: actorId,
          payload: withoutPrefix.sublist(remainingPos),
          network: network,
        );
    }
  }

  /// Parse actor ID from string, handling values that exceed int64 max
  /// Dart int is 64-bit signed, but we need to support uint64_t max (18446744073709551615)
  /// For values > int64 max, we store them as negative (overflow behavior)
  static int _parseActorIdString(String str) {
    // Check for invalid characters
    if (str.isEmpty || !RegExp(r'^\d+$').hasMatch(str)) {
      throw ArgumentError('Invalid actor ID: $str');
    }

    // Try regular parsing first
    try {
      return int.parse(str);
    } catch (e) {
      // For uint64_t max (18446744073709551615), which exceeds int64 max
      // wallet-core stores this as uint64_t, but Dart only has signed int64
      // We need to handle this specially - values that overflow become negative
      const maxUint64 = '18446744073709551615';
      if (str == maxUint64) {
        // This is uint64_t max, store as -1 (which is what happens in 2's complement)
        return -1;
      }
      // If it's not exactly uint64_t max and doesn't parse, it's invalid
      throw ArgumentError('Actor ID exceeds maximum: $str');
    }
  }

  /// Decode actor ID from bytes as unsigned varint
  /// Returns (actorId, remainingPos) or null if invalid
  static (int, int)? _decodeActorId(List<int> bytes) {
    const maxBytes = 9;

    int actorId = 0;
    int remainingPos = 0;

    for (remainingPos = 0;
        remainingPos < bytes.length && remainingPos <= maxBytes;
        ++remainingPos) {
      final byte = bytes[remainingPos];
      final k = byte & 0x7F; // SCHAR_MAX = 127 = 0x7F
      actorId |= k << (remainingPos * 7);

      // Check if last (bit 7 is 0)
      if ((byte & 0x80) == 0) {
        // If last byte is zero and not first byte, could have been more minimally encoded
        if (byte == 0 && remainingPos > 0) {
          return null;
        }
        ++remainingPos;
        return (actorId, remainingPos);
      }
    }

    // Couldn't find the last byte
    return null;
  }

  /// Validate payload size for address type
  static bool _isValidPayloadSize(FilecoinAddressType type, int size) {
    switch (type) {
      case FilecoinAddressType.id:
        return size == 0;
      case FilecoinAddressType.secp256k1:
      case FilecoinAddressType.actor:
        return size == 20;
      case FilecoinAddressType.bls:
        return size == 48;
      case FilecoinAddressType.delegated:
        return size >= 0 && size <= 54; // Max 54 bytes for delegated
    }
  }

  /// Convert ID address to Ethereum ID mask address (0xFF...)
  /// Only works for ID addresses (f0...)
  /// Returns null if address is not an ID address
  String? toIdMaskAddress() {
    if (type != FilecoinAddressType.id) {
      return null;
    }

    // Create 20-byte array
    final buf = List<int>.filled(20, 0);

    // Set first byte to 0xFF
    buf[0] = 0xFF;

    // Set the actor ID in the last 8 bytes (big endian)
    for (int i = 0; i < 8; i++) {
      buf[19 - i] = (actorId >> (i * 8)) & 0xFF;
    }

    // Apply EIP-55 checksum
    return _checksumEthAddress('0x${BytesUtils.toHexString(buf)}');
  }

  /// Compute EIP-55 checksum for Ethereum address
  static String _checksumEthAddress(String address) {
    final addr = address.toLowerCase().replaceFirst('0x', '');
    final hash = BytesUtils.toHexString(QuickCrypto.keccack256Hash(addr.codeUnits));

    final result = StringBuffer('0x');
    for (int i = 0; i < addr.length; i++) {
      final char = addr[i];
      if (int.tryParse(char) != null) {
        result.write(char);
      } else {
        final hashChar = hash[i];
        final hashValue = int.parse(hashChar, radix: 16);
        result.write(hashValue >= 8 ? char.toUpperCase() : char);
      }
    }
    return result.toString();
  }

  /// Convert delegated address to Ethereum address
  /// Only works for delegated addresses (f4...) with EAM actor ID
  /// Returns null if address cannot be converted
  String? toEthAddress() {
    if (type != FilecoinAddressType.delegated) {
      return null;
    }

    if (actorId != ethereumAddressManagerActorId) {
      return null;
    }

    if (payload.length != 20) {
      return null;
    }

    return _checksumEthAddress('0x${BytesUtils.toHexString(payload)}');
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