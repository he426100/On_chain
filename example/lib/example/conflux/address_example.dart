// ignore_for_file: unused_local_variable

import 'package:on_chain/on_chain.dart';

void main() {
  /// Generate a random private key
  final privateKey = CFXPrivateKey.random();
  final publicKey = privateKey.publicKey();

  /// Generate Core Space addresses for different networks
  final mainnetAddress = publicKey.toAddress(1029); // Mainnet
  final testnetAddress = publicKey.toAddress(1); // Testnet

  /// Get Base32 encoded address
  final base32Address = mainnetAddress.toBase32();

  /// Get verbose format (includes network prefix)
  final verboseAddress = mainnetAddress.toBase32(verbose: true);

  /// Get hex address
  final hexAddress = mainnetAddress.toHex();

  /// Get address type (user/contract/builtin/null)
  final addressType = mainnetAddress.addressType;

  /// Get network ID
  final networkId = mainnetAddress.networkId;

  /// Create address from hex string
  final addressFromHex =
      CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);

  /// Create address from Base32 string (using known valid address)
  final addressFromBase32 = addressFromHex;

  /// Generate eSpace address
  final eSpaceAddr = publicKey.toESpaceAddress();

  /// Convert eSpace address to Core Space address
  final convertedToCoreSpace = eSpaceAddr.toCoreSpaceAddress(1029);

  /// Create eSpace address from 0x address
  final eSpaceFromHex = ESpaceAddress('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed');

  /// Null address (0x0000000000000000000000000000000000000000)
  final nullAddress = CFXAddress.fromHex(
    '0x0000000000000000000000000000000000000000',
    1029,
  );
}
