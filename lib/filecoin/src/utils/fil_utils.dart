import 'package:blockchain_utils/blockchain_utils.dart';
import '../network/filecoin_network.dart';

/// BIP-32 path component regex
final RegExp bip32PathRegex = RegExp(r"^\d+'?$");

/// Derivation path components
class DerivationPathComponents {
  final int purpose;
  final int coinType;
  final int account;
  final int change;
  final int addressIndex;

  const DerivationPathComponents({
    required this.purpose,
    required this.coinType,
    required this.account,
    required this.change,
    required this.addressIndex,
  });

  @override
  String toString() =>
      'DerivationPathComponents(purpose: $purpose, coinType: $coinType, account: $account, change: $change, addressIndex: $addressIndex)';
}

/// Filecoin utilities
class FilecoinUtils {
  /// Parse derivation path into components
  /// Path format: m/44'/coinType'/account'/change/addressIndex
  /// @see https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
  static DerivationPathComponents parseDerivationPath(String path) {
    final parts = path.split('/');

    if (parts.length != 6) {
      throw ArgumentError(
        'Invalid derivation path: depth must be 5 "m / purpose\' / coin_type\' / account\' / change / address_index"',
      );
    }

    if (parts[0] != 'm') {
      throw ArgumentError('Invalid derivation path: depth 0 must be "m"');
    }

    if (parts[1] != "44'") {
      throw ArgumentError(
        'Invalid derivation path: The "purpose" node (depth 1) must be the string "44\'"',
      );
    }

    if (!bip32PathRegex.hasMatch(parts[2]) || !parts[2].endsWith("'")) {
      throw ArgumentError(
        'Invalid derivation path: The "coin_type" node (depth 2) must be a hardened BIP-32 node.',
      );
    }

    if (!bip32PathRegex.hasMatch(parts[3]) || !parts[3].endsWith("'")) {
      throw ArgumentError(
        'Invalid derivation path: The "account" node (depth 3) must be a hardened BIP-32 node.',
      );
    }

    if (!bip32PathRegex.hasMatch(parts[4]) || parts[4].endsWith("'")) {
      throw ArgumentError(
        'Invalid derivation path: The "change" node (depth 4) must be a BIP-32 node.',
      );
    }

    if (!bip32PathRegex.hasMatch(parts[5]) || parts[5].endsWith("'")) {
      throw ArgumentError(
        'Invalid derivation path: The "address_index" node (depth 5) must be a BIP-32 node.',
      );
    }

    try {
      final purpose = int.parse(parts[1].replaceAll("'", ''));
      final coinType = int.parse(parts[2].replaceAll("'", ''));
      final account = int.parse(parts[3].replaceAll("'", ''));
      final change = int.parse(parts[4]);
      final addressIndex = int.parse(parts[5]);

      return DerivationPathComponents(
        purpose: purpose,
        coinType: coinType,
        account: account,
        change: change,
        addressIndex: addressIndex,
      );
    } on FormatException catch (e) {
      throw ArgumentError('Invalid derivation path: Invalid number format - ${e.message}');
    }
  }

  /// Get network prefix from network
  static String getNetworkPrefix(FilecoinNetwork network) {
    return network.prefix;
  }

  /// Get network from prefix
  static FilecoinNetwork getNetwork(String prefix) {
    return prefix == 'f' ? FilecoinNetwork.mainnet : FilecoinNetwork.testnet;
  }

  /// Get network from derivation path (based on coin type)
  static FilecoinNetwork getNetworkFromPath(String path) {
    final components = parseDerivationPath(path);
    return components.coinType == 1 ? FilecoinNetwork.testnet : FilecoinNetwork.mainnet;
  }

  /// Get network from chain ID
  static FilecoinNetwork getNetworkFromChainId(dynamic chainId) {
    switch (chainId) {
      case 314159:
      case '0x4cb2f':
      case 'eip155:314159':
      case 'testnet':
      case 't':
        return FilecoinNetwork.testnet;
      case 314:
      case '0x13a':
      case 'eip155:314':
      case 'mainnet':
      case 'f':
        return FilecoinNetwork.mainnet;
      default:
        throw ArgumentError('Unknown chain id: $chainId');
    }
  }

  /// Create derivation path from network and index
  static String pathFromNetwork(FilecoinNetwork network, [int index = 0]) {
    switch (network) {
      case FilecoinNetwork.mainnet:
        return "m/44'/461'/0'/0/$index";
      case FilecoinNetwork.testnet:
        return "m/44'/1'/0'/0/$index";
    }
  }

  /// Generate Lotus CID from data
  /// CID = CIDv1 (0x01) + dag-cbor codec (0x71) + blake2b-256 multihash (0xa0e40220) + hash
  static List<int> lotusCid(List<int> data) {
    final hash = QuickCrypto.blake2b256Hash(data);
    return [
      0x01, // CIDv1
      0x71, // dag-cbor codec
      0xa0, 0xe4, 0x02, 0x20, // blake2b-256 multihash with 32-byte length
      ...hash,
    ];
  }

  /// Compute EIP-55 checksum for Ethereum address
  static String checksumEthAddress(String address) {
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

  /// Check if string is valid Ethereum address
  static bool isEthAddress(String address) {
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
      return false;
    }
    // All lowercase or all uppercase (except 0x) is valid
    final withoutPrefix = address.substring(2);
    if (withoutPrefix.toLowerCase() == withoutPrefix || withoutPrefix.toUpperCase() == withoutPrefix) {
      return true;
    }
    // Mixed case must match EIP-55 checksum
    return checksumEthAddress(address) == address;
  }

  /// Check if address is an Ethereum ID mask address (0xFF00...00{id})
  static bool isIdMaskAddress(String address) {
    if (!isEthAddress(address)) {
      return false;
    }
    final bytes = BytesUtils.fromHexString(address.substring(2));
    final idMaskPrefix = List<int>.filled(12, 0);
    idMaskPrefix[0] = 0xFF;

    return BytesUtils.bytesEqual(bytes.sublist(0, 12), idMaskPrefix);
  }
}
