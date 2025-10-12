import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:on_chain/on_chain.dart';

void filecoinTestnetExample() {
  debugPrint('=== Filecoin Testnet (Calibration) Examples ===\n');

  // Generate a private key
  final privateKey = List.generate(32, (i) => i + 1);
  debugPrint('Private Key: ${BytesUtils.toHexString(privateKey, prefix: '0x')}');

  // Create addresses on testnet
  final secp256k1Address = FilecoinSigner.createSecp256k1Address(
    privateKey,
    network: FilecoinNetwork.testnet,
  );
  debugPrint('Testnet SECP256K1 Address: ${secp256k1Address.toAddress()}');
  debugPrint('Network: ${secp256k1Address.network.name}');
  debugPrint('Network Prefix: ${secp256k1Address.network.prefix}');

  final delegatedAddress = FilecoinSigner.createDelegatedAddress(
    privateKey,
    network: FilecoinNetwork.testnet,
  );
  debugPrint('\nTestnet Delegated Address: ${delegatedAddress.toAddress()}');
  debugPrint('Network: ${delegatedAddress.network.name}');

  // Parse testnet addresses
  final testnetIdAddress = FilecoinAddress.fromString('t0123');
  debugPrint('\nParsed Testnet ID Address: ${testnetIdAddress.toAddress()}');
  debugPrint('Actor ID: ${testnetIdAddress.actorId}');
  debugPrint('Network: ${testnetIdAddress.network.name}');

  // Validate testnet addresses
  const validTestnetAddress = 't0456';
  const invalidMainnetAddress = 'f0456'; // mainnet address is invalid on testnet
  debugPrint('\nIs "$validTestnetAddress" valid on testnet? ${FilecoinAddress.isValidAddressForNetwork(validTestnetAddress, FilecoinNetwork.testnet)}');
  debugPrint('Is "$invalidMainnetAddress" valid on testnet? ${FilecoinAddress.isValidAddressForNetwork(invalidMainnetAddress, FilecoinNetwork.testnet)}');

  // Parse mainnet address
  final mainnetAddress = FilecoinAddress.fromString('f0789');
  debugPrint('Parsed Mainnet Address: ${mainnetAddress.toAddress()}');
  debugPrint('Network: ${mainnetAddress.network.name}');

  debugPrint('\n');
}

void filecoinTestnetNetworkInfoExample() {
  debugPrint('=== Filecoin Network Information ===\n');

  debugPrint('Mainnet:');
  debugPrint('  Name: ${FilecoinNetwork.mainnet.name}');
  debugPrint('  Prefix: ${FilecoinNetwork.mainnet.prefix}');
  debugPrint('  Chain ID: ${FilecoinNetwork.mainnet.chainId}');
  debugPrint('  Chain ID (Hex): ${FilecoinNetwork.mainnet.chainIdHex}');
  debugPrint('  Coin Type: ${FilecoinNetwork.mainnet.coinType}');
  debugPrint('  Currency: ${FilecoinNetwork.mainnet.currencySymbol}');
  debugPrint('  Default RPC: ${FilecoinNetwork.mainnet.defaultRpcUrl}');
  debugPrint('  Default WS: ${FilecoinNetwork.mainnet.defaultWsUrl}');
  debugPrint('  Explorer: ${FilecoinNetwork.mainnet.explorerUrl}');
  debugPrint('  Derivation Path: ${FilecoinNetwork.mainnet.derivationPath()}');
  debugPrint('  Is Testnet: ${FilecoinNetwork.mainnet.isTestnet}');

  debugPrint('\nTestnet (Calibration):');
  debugPrint('  Name: ${FilecoinNetwork.testnet.name}');
  debugPrint('  Prefix: ${FilecoinNetwork.testnet.prefix}');
  debugPrint('  Chain ID: ${FilecoinNetwork.testnet.chainId}');
  debugPrint('  Chain ID (Hex): ${FilecoinNetwork.testnet.chainIdHex}');
  debugPrint('  Coin Type: ${FilecoinNetwork.testnet.coinType}');
  debugPrint('  Currency: ${FilecoinNetwork.testnet.currencySymbol}');
  debugPrint('  Default RPC: ${FilecoinNetwork.testnet.defaultRpcUrl}');
  debugPrint('  Default WS: ${FilecoinNetwork.testnet.defaultWsUrl}');
  debugPrint('  Explorer: ${FilecoinNetwork.testnet.explorerUrl}');
  debugPrint('  Derivation Path: ${FilecoinNetwork.testnet.derivationPath()}');
  debugPrint('  Is Testnet: ${FilecoinNetwork.testnet.isTestnet}');

  debugPrint('\n');
}

void filecoinTestnetTransactionExample() {
  debugPrint('=== Filecoin Testnet Transaction Example ===\n');

  // Create testnet addresses
  final privateKey1 = List.generate(32, (i) => i + 1);
  final privateKey2 = List.generate(32, (i) => i + 100);

  final fromAddress = FilecoinSigner.createSecp256k1Address(
    privateKey1,
    network: FilecoinNetwork.testnet,
  );
  final toAddress = FilecoinSigner.createDelegatedAddress(
    privateKey2,
    network: FilecoinNetwork.testnet,
  );

  debugPrint('From Address (Testnet): ${fromAddress.toAddress()}');
  debugPrint('To Address (Testnet): ${toAddress.toAddress()}');

  // Create a transfer transaction on testnet
  final transaction = FilecoinTransaction.transfer(
    from: fromAddress,
    to: toAddress,
    nonce: 0,
    value: BigInt.from(100000000000000000), // 0.1 tFIL in attoFIL
    gasLimit: 1000000,
    gasFeeCap: BigInt.from(2000),
    gasPremium: BigInt.from(1000),
  );

  debugPrint('\nTestnet Transaction Details:');
  debugPrint('Version: ${transaction.version}');
  debugPrint('Nonce: ${transaction.nonce}');
  debugPrint('Value: ${transaction.value} attoFIL (${transaction.value ~/ BigInt.from(1000000000000000000)} tFIL)');
  debugPrint('Gas Limit: ${transaction.gasLimit}');
  debugPrint('Gas Fee Cap: ${transaction.gasFeeCap}');
  debugPrint('Gas Premium: ${transaction.gasPremium}');

  // Get transaction CID
  final cid = transaction.getCid();
  debugPrint('Transaction CID: ${BytesUtils.toHexString(cid, prefix: '0x')}');

  // Sign the transaction
  final signedTransaction = FilecoinSigner.signTransaction(
    transaction: transaction,
    privateKey: privateKey1,
  );

  debugPrint('\nSigned Testnet Transaction:');
  debugPrint('Signature Type: ${signedTransaction.signature.type}');
  debugPrint('Signature Data Length: ${signedTransaction.signature.data.length} bytes');

  // Convert to JSON for submission to testnet
  final signedJson = signedTransaction.toJson();
  debugPrint('\nSigned Transaction JSON (for testnet RPC submission):');
  debugPrint('Message: ${signedJson['Message']}');
  debugPrint('Signature: ${signedJson['Signature']}');
  debugPrint('Ready to submit to: ${FilecoinNetwork.testnet.defaultRpcUrl}');

  debugPrint('\n');
}

void filecoinTestnetAddressConversionExample() {
  debugPrint('=== Filecoin Testnet Address Conversion ===\n');

  // Convert Ethereum address to Filecoin testnet address
  final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');
  debugPrint('Original Ethereum Address: $ethAddress');

  final testnetFilecoinFromEth = FilecoinAddressConverter.convertFromEthereum(
    ethAddress,
    network: FilecoinNetwork.testnet,
  );
  debugPrint('Converted to Filecoin Testnet: ${testnetFilecoinFromEth.toAddress()}');
  debugPrint('Network: ${testnetFilecoinFromEth.network.name}');

  // Convert back to Ethereum
  final ethFromTestnetFilecoin = FilecoinAddressConverter.convertToEthereum(
    testnetFilecoinFromEth,
  );
  debugPrint('Converted back to Ethereum: $ethFromTestnetFilecoin');

  // Compare with mainnet conversion
  final mainnetFilecoinFromEth = FilecoinAddressConverter.convertFromEthereum(
    ethAddress,
    network: FilecoinNetwork.mainnet,
  );
  debugPrint('\nComparison with Mainnet:');
  debugPrint('Mainnet Address: ${mainnetFilecoinFromEth.toAddress()}');
  debugPrint('Testnet Address: ${testnetFilecoinFromEth.toAddress()}');
  debugPrint('Same payload: ${BytesUtils.toHexString(mainnetFilecoinFromEth.payload) == BytesUtils.toHexString(testnetFilecoinFromEth.payload)}');
  debugPrint('Different prefix: ${mainnetFilecoinFromEth.network.prefix} vs ${testnetFilecoinFromEth.network.prefix}');

  debugPrint('\n');
}

void filecoinTestnetProviderExample() {
  debugPrint('=== Filecoin Testnet Provider Example ===\n');

  // Create testnet provider
  // Note: This is a conceptual example showing how to set up a provider
  debugPrint('Setting up Filecoin Testnet Provider:');
  debugPrint('Network: ${FilecoinNetwork.testnet.name}');
  debugPrint('RPC URL: ${FilecoinNetwork.testnet.defaultRpcUrl}');
  debugPrint('WebSocket URL: ${FilecoinNetwork.testnet.defaultWsUrl}');

  // Example of creating a provider (pseudo-code)
  debugPrint('\nExample usage:');
  debugPrint('''
// Create HTTP service
final service = FilecoinHTTPService(
  url: FilecoinNetwork.testnet.defaultRpcUrl,
);

// Create provider
final provider = FilecoinProvider(
  service,
  network: FilecoinNetwork.testnet,
);

// Now you can use the provider to interact with testnet
// Example: Get chain head, send transactions, etc.
''');

  debugPrint('\n');
}

void main() {
  debugPrint('🚀 Filecoin Testnet Examples - On Chain Library\n');
  debugPrint('This example demonstrates Filecoin Testnet (Calibration) functionality:');
  debugPrint('- Testnet address creation and parsing');
  debugPrint('- Network information and configuration');
  debugPrint('- Testnet transactions');
  debugPrint('- Address conversion with testnet');
  debugPrint('- Provider setup for testnet');
  debugPrint('\n${'=' * 60}\n');

  filecoinTestnetExample();
  filecoinTestnetNetworkInfoExample();
  filecoinTestnetTransactionExample();
  filecoinTestnetAddressConversionExample();
  filecoinTestnetProviderExample();

  debugPrint('✅ All Filecoin Testnet examples completed successfully!');
  debugPrint('\n${'=' * 60}');
  debugPrint('📚 For more information, visit:');
  debugPrint('   - Calibration Testnet: https://docs.filecoin.io/networks/calibration/');
  debugPrint('   - Testnet Faucet: https://faucet.calibration.fildev.network/');
  debugPrint('   - On Chain Library: https://github.com/mrtnetwork/on_chain');
}
