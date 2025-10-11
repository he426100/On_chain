import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';

/// Address converter for Filecoin and Ethereum interoperability
class FilecoinAddressConverter {
  /// Actor ID length when encoded as big endian uint64
  static const int actorIdEncodedLength = 8;

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