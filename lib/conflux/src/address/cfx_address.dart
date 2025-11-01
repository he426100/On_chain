import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/utils/base32_encoder.dart' as cfx_base32;

/// Conflux address types based on the first nibble of the hex address.
enum CFXAddressType {
  /// User address (starts with 0x1).
  user(0x10, 'user'),

  /// Contract address (starts with 0x8).
  contract(0x80, 'contract'),

  /// Built-in contract address (starts with 0x0, not null).
  builtin(0x00, 'builtin'),

  /// Null address (0x0000000000000000000000000000000000000000).
  nullAddress(0x00, 'null');

  const CFXAddressType(this.prefix, this.name);

  /// The prefix byte for this address type.
  final int prefix;

  /// The name of the address type.
  final String name;

  /// Determines address type from hex address.
  static CFXAddressType fromHexAddress(String hexAddress) {
    final cleanHex = hexAddress.startsWith('0x')
        ? hexAddress.substring(2)
        : hexAddress;

    if (cleanHex.length != 40) {
      throw InvalidConfluxAddressException(
        'Invalid hex address length',
        details: {'address': hexAddress},
      );
    }

    // Check if null address
    if (cleanHex == '0' * 40) {
      return CFXAddressType.nullAddress;
    }

    final firstByte = int.parse(cleanHex.substring(0, 2), radix: 16);

    // Address type detection based on high 4 bits
    if ((firstByte & 0xf0) == 0x10) return CFXAddressType.user;
    if ((firstByte & 0xf0) == 0x80) return CFXAddressType.contract;
    if ((firstByte & 0xf0) == 0x00) return CFXAddressType.builtin;

    // For addresses derived from public keys, the first byte can be anything
    // Default to user type for compatibility (common case for derived addresses)
    return CFXAddressType.user;
  }

  /// Gets the type-specific character for verbose format.
  String get typeString {
    switch (this) {
      case CFXAddressType.user:
        return 'type.user';
      case CFXAddressType.contract:
        return 'type.contract';
      case CFXAddressType.builtin:
        return 'type.builtin';
      case CFXAddressType.nullAddress:
        return 'type.null';
    }
  }
}

/// Conflux network identifiers.
class CFXNetwork {
  const CFXNetwork._(this.id, this.prefix);

  /// Network ID.
  final int id;

  /// Network prefix for Base32 addresses.
  final String prefix;

  /// Conflux mainnet (Core Space).
  static const CFXNetwork mainnet = CFXNetwork._(1029, 'cfx');

  /// Conflux testnet.
  static const CFXNetwork testnet = CFXNetwork._(1, 'cfxtest');

  /// Gets network prefix from network ID.
  static String getPrefix(int networkId) {
    if (networkId == 1029) return 'cfx';
    if (networkId == 1) return 'cfxtest';
    return 'net$networkId';
  }

  /// Parses network ID from prefix.
  static int? parsePrefix(String prefix) {
    if (prefix == 'cfx') return 1029;
    if (prefix == 'cfxtest') return 1;
    if (prefix.startsWith('net')) {
      final idStr = prefix.substring(3);
      return int.tryParse(idStr);
    }
    return null;
  }
}

/// Represents a Conflux Core Space address with Base32 encoding (CIP-37).
class CFXAddress {
  CFXAddress._(this._hexAddress, this._networkId, this._addressType);

  final String _hexAddress;
  final int _networkId;
  final CFXAddressType _addressType;

  /// Creates a [CFXAddress] from a Base32-encoded address string.
  /// 
  /// Example:
  /// ```dart
  /// final addr = CFXAddress('cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p');
  /// ```
  factory CFXAddress(String base32Address) {
    return CFXAddress.fromBase32(base32Address);
  }

  /// Creates a [CFXAddress] from a Base32-encoded address.
  factory CFXAddress.fromBase32(String base32Address) {
    // Parse address parts
    final parts = base32Address.split(':');
    
    if (parts.isEmpty || parts.length > 3) {
      throw InvalidConfluxAddressException(
        'Invalid Base32 address format',
        details: {'address': base32Address},
      );
    }

    String prefix;
    String? typeStr;
    String encoded;

    if (parts.length == 1) {
      throw InvalidConfluxAddressException(
        'Base32 address must include network prefix',
        details: {'address': base32Address},
      );
    } else if (parts.length == 2) {
      prefix = parts[0].toLowerCase();
      encoded = parts[1].toLowerCase();
    } else {
      // Verbose format: cfx:type.user:encoded
      prefix = parts[0].toLowerCase();
      typeStr = parts[1].toLowerCase();
      encoded = parts[2].toLowerCase();
    }

    // Check for mixed case (not allowed)
    final originalEncoded = parts.length == 2 ? parts[1] : parts[2];
    if (originalEncoded != originalEncoded.toLowerCase() &&
        originalEncoded != originalEncoded.toUpperCase()) {
      throw InvalidConfluxAddressException(
        'Mixed-case address not allowed',
        details: {'address': base32Address},
      );
    }

    // Parse network ID
    final networkId = CFXNetwork.parsePrefix(prefix);
    if (networkId == null) {
      throw InvalidNetworkIdException(
        'Invalid network prefix',
        details: {'prefix': prefix},
      );
    }

    // Decode hex address (CIP-37: payload = version-byte + 20-byte address)
    final payload = cfx_base32.Base32Encoder.decodeWithChecksum(prefix, encoded);
    
    if (payload.length != 21) {
      throw InvalidConfluxAddressException(
        'Decoded payload must be 21 bytes (version-byte + address)',
        details: {'length': payload.length},
      );
    }

    // Extract version-byte and address
    final versionByte = payload[0];
    if (versionByte != 0x00) {
      throw InvalidConfluxAddressException(
        'Unsupported version byte',
        details: {'versionByte': versionByte},
      );
    }

    final hexBytes = payload.sublist(1); // Remove version-byte
    final hexAddress = '0x${BytesUtils.toHexString(hexBytes, lowerCase: true)}';
    final addressType = CFXAddressType.fromHexAddress(hexAddress);

    // Verify type if verbose format
    if (typeStr != null) {
      final expectedType = 'type.${addressType.name}';
      if (typeStr != expectedType) {
        throw InvalidConfluxAddressException(
          'Address type mismatch',
          details: {'expected': expectedType, 'actual': typeStr},
        );
      }
    }

    return CFXAddress._(hexAddress, networkId, addressType);
  }

  /// Creates a [CFXAddress] from a hex address and network ID.
  /// 
  /// Example:
  /// ```dart
  /// final addr = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
  /// ```
  factory CFXAddress.fromHex(String hexAddress, int networkId) {
    final cleanHex = hexAddress.startsWith('0x')
        ? hexAddress.substring(2)
        : hexAddress;

    if (cleanHex.length != 40) {
      throw InvalidConfluxAddressException(
        'Hex address must be 40 characters',
        details: {'address': hexAddress, 'length': cleanHex.length},
      );
    }

    if (networkId < 0 || networkId > 0xFFFFFFFF) {
      throw InvalidNetworkIdException(
        'Network ID must be in range [0, 0xFFFFFFFF]',
        details: {'networkId': networkId},
      );
    }

    final normalizedHex = '0x${cleanHex.toLowerCase()}';
    final addressType = CFXAddressType.fromHexAddress(normalizedHex);

    return CFXAddress._(normalizedHex, networkId, addressType);
  }

  /// Returns the hex representation of the address.
  String get hexAddress => _hexAddress;

  /// Returns the network ID.
  int get networkId => _networkId;

  /// Returns the address type.
  CFXAddressType get addressType => _addressType;

  /// Returns the network prefix.
  String get networkPrefix => CFXNetwork.getPrefix(_networkId);

  /// Converts to Base32-encoded address.
  /// 
  /// If [verbose] is true, includes the type in the format:
  /// `cfx:type.user:encoded`
  String toBase32({bool verbose = false}) {
    final hexBytes = BytesUtils.fromHexString(_hexAddress);
    
    // CIP-37: payload = version-byte (0x00) + 20-byte address
    final payload = [0x00, ...hexBytes];
    final encoded = cfx_base32.Base32Encoder.encodeWithChecksum(networkPrefix, payload);

    if (verbose) {
      return '$networkPrefix:${_addressType.typeString}:${encoded.toUpperCase()}';
    }

    return '$networkPrefix:$encoded';
  }

  /// Converts to hex address (without 0x prefix).
  String toHex({bool includePrefix = true}) {
    if (includePrefix) return _hexAddress;
    return _hexAddress.substring(2);
  }

  /// Returns the address as bytes.
  List<int> toBytes() {
    return BytesUtils.fromHexString(_hexAddress);
  }

  /// Checks if this is a user address.
  bool get isUser => _addressType == CFXAddressType.user;

  /// Checks if this is a contract address.
  bool get isContract => _addressType == CFXAddressType.contract;

  /// Checks if this is a built-in contract address.
  bool get isBuiltin => _addressType == CFXAddressType.builtin;

  /// Checks if this is the null address.
  bool get isNull => _addressType == CFXAddressType.nullAddress;

  @override
  String toString() => toBase32();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CFXAddress &&
        other._hexAddress.toLowerCase() == _hexAddress.toLowerCase() &&
        other._networkId == _networkId;
  }

  @override
  int get hashCode => Object.hash(_hexAddress.toLowerCase(), _networkId);
}

