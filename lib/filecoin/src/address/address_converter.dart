import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';

/// Address converter for Filecoin and Ethereum interoperability
class FilecoinAddressConverter {
  /// Actor ID length when encoded as big endian uint64
  static const int actorIdEncodedLength = 8;

  /// Check if string is a valid Ethereum address
  /// Based on reference implementation from iso-filecoin
  /// See: https://github.com/filecoin-project/iso-filecoin/blob/main/packages/iso-filecoin/src/address.js
  static bool isEthAddress(String address) {
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) return false;
    if (address.toLowerCase() == address) return true;
    return _checksumEthAddress(address) == address;
  }

  /// Check if address is an Ethereum ID mask address
  /// ID mask addresses have format: 0xFF + 11 zero bytes + 8 bytes for actor ID
  static bool isIdMaskAddress(String address) {
    if (!isEthAddress(address)) {
      return false;
    }
    final bytes = BytesUtils.fromHexString(address.substring(2));
    if (bytes.length != 20) return false;

    // Check if first byte is 0xFF and next 11 bytes are zero
    if (bytes[0] != 0xFF) return false;
    for (int i = 1; i < 12; i++) {
      if (bytes[i] != 0) return false;
    }
    return true;
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

  /// Convert Ethereum address to Filecoin address
  /// Automatically detects ID mask addresses (f0) vs delegated addresses (f4)
  static FilecoinAddress fromEthAddress(
    String address, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    if (!isEthAddress(address)) {
      throw ArgumentError('Invalid Ethereum address: $address');
    }

    if (isIdMaskAddress(address)) {
      return _fromIdMaskAddress(address, network);
    }
    return _fromDelegatedEthAddress(address, network);
  }

  /// Create ID address from ID mask Ethereum address
  static FilecoinAddress _fromIdMaskAddress(String address, FilecoinNetwork network) {
    if (!isIdMaskAddress(address)) {
      throw ArgumentError('Invalid Ethereum ID mask address: $address');
    }

    final bytes = BytesUtils.fromHexString(address.substring(2));
    if (bytes.length != 20) {
      throw ArgumentError('Invalid Ethereum payload length: ${bytes.length} should be 20');
    }

    // Extract the actor ID from the last 8 bytes (big endian)
    int actorId = 0;
    for (int i = 12; i < 20; i++) {
      actorId = (actorId << 8) | bytes[i];
    }

    return FilecoinAddress(
      type: FilecoinAddressType.id,
      actorId: actorId,
      payload: [],
      network: network,
    );
  }

  /// Create delegated address from Ethereum address
  static FilecoinAddress _fromDelegatedEthAddress(String address, FilecoinNetwork network) {
    if (!isEthAddress(address)) {
      throw ArgumentError('Invalid Ethereum address: $address');
    }

    if (isIdMaskAddress(address)) {
      throw ArgumentError('Cannot convert Ethereum ID mask address to delegated: $address');
    }

    final bytes = BytesUtils.fromHexString(address.substring(2));
    if (bytes.length != 20) {
      throw ArgumentError('Invalid Ethereum payload length: ${bytes.length} should be 20');
    }

    return FilecoinAddress(
      type: FilecoinAddressType.delegated,
      actorId: FilecoinAddress.ethereumAddressManagerActorId,
      payload: bytes,
      network: network,
    );
  }

  /// Convert Filecoin address to Ethereum address
  /// Only works for ID addresses (f0...) and Delegated addresses (f4...)
  /// This is an alias for toEthAddress for compatibility
  static String? toEthAddress(FilecoinAddress address) {
    final ethAddr = convertToEthereum(address);
    return ethAddr?.toString();
  }

  /// Convert Filecoin address to Ethereum address
  /// Only works for ID addresses (f0...) and Delegated addresses (f4...)
  /// Returns null if conversion is not possible
  static ETHAddress? convertToEthereum(FilecoinAddress filecoinAddress) {
    switch (filecoinAddress.type) {
      case FilecoinAddressType.id:
        // For ID addresses, create an Ethereum address with 0xFF prefix
        // followed by zeros and the actor ID encoded as big endian uint64
        final payload = List<int>.filled(ETHAddress.lengthInBytes, 0);
        payload[0] = 0xFF;

        // Encode actor ID as big endian uint64
        final actorIdBytes = _encodeUint64BigEndian(filecoinAddress.actorId);
        final startIndex = ETHAddress.lengthInBytes - actorIdEncodedLength;
        for (int i = 0; i < actorIdEncodedLength; i++) {
          payload[startIndex + i] = actorIdBytes[i];
        }

        return ETHAddress.fromBytes(payload);

      case FilecoinAddressType.delegated:
        // Only convert delegated addresses from the Ethereum Address Manager
        if (filecoinAddress.actorId != FilecoinAddress.ethereumAddressManagerActorId) {
          return null;
        }

        // Payload must be exactly 20 bytes for Ethereum address
        if (filecoinAddress.payload.length != ETHAddress.lengthInBytes) {
          return null;
        }

        return ETHAddress.fromBytes(filecoinAddress.payload);

      default:
        // SECP256K1, Actor, and BLS addresses cannot be converted
        return null;
    }
  }

  /// Convert Filecoin address string to Ethereum address string
  static String? convertToEthereumString(String filecoinAddressString) {
    try {
      final filecoinAddress = FilecoinAddress.fromString(filecoinAddressString);
      final ethAddress = convertToEthereum(filecoinAddress);
      return ethAddress?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Convert Ethereum address to Filecoin delegated address
  static FilecoinAddress convertFromEthereum(
    ETHAddress ethereumAddress, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    // Convert Ethereum address to delegated Filecoin address
    // This uses the Ethereum Address Manager actor ID (10)
    final payload = BytesUtils.fromHexString(ethereumAddress.address.substring(2));

    return FilecoinAddress(
      type: FilecoinAddressType.delegated,
      actorId: FilecoinAddress.ethereumAddressManagerActorId,
      payload: payload,
      network: network,
    );
  }

  /// Convert Ethereum address string to Filecoin delegated address string
  static String convertFromEthereumString(
    String ethereumAddressString, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final ethAddress = ETHAddress(ethereumAddressString);
    final filecoinAddress = convertFromEthereum(ethAddress, network: network);
    return filecoinAddress.toAddress();
  }

  /// Check if a Filecoin address can be converted to Ethereum
  static bool canConvertToEthereum(FilecoinAddress filecoinAddress) {
    return convertToEthereum(filecoinAddress) != null;
  }

  /// Check if a Filecoin address string can be converted to Ethereum
  static bool canConvertToEthereumString(String filecoinAddressString) {
    try {
      final filecoinAddress = FilecoinAddress.fromString(filecoinAddressString);
      return canConvertToEthereum(filecoinAddress);
    } catch (e) {
      return false;
    }
  }

  /// Encode uint64 as big endian bytes
  static List<int> _encodeUint64BigEndian(int value) {
    final bytes = <int>[];
    for (int i = 7; i >= 0; i--) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }
}