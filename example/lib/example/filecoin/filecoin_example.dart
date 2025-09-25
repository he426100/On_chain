import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:on_chain/on_chain.dart';

void filecoinAddressExample() {
  debugPrint('=== Filecoin Address Examples ===\n');

  // Generate a private key
  final privateKey = List.generate(32, (i) => i + 1);
  debugPrint('Private Key: ${BytesUtils.toHexString(privateKey, prefix: '0x')}');

  // Create SECP256K1 address
  final secp256k1Address = FilecoinSigner.createSecp256k1Address(privateKey);
  debugPrint('SECP256K1 Address: ${secp256k1Address.toAddress()}');

  // Create delegated address (Ethereum-compatible)
  final delegatedAddress = FilecoinSigner.createDelegatedAddress(privateKey);
  debugPrint('Delegated Address: ${delegatedAddress.toAddress()}');

  // Parse ID address
  final idAddress = FilecoinAddress.fromString('f0123');
  debugPrint('Parsed ID Address: ${idAddress.toAddress()}, Actor ID: ${idAddress.actorId}');

  // Address validation
  const validAddress = 'f0456';
  const invalidAddress = 'invalid_address';
  debugPrint('Is "$validAddress" valid? ${FilecoinAddress.isValidAddress(validAddress)}');
  debugPrint('Is "$invalidAddress" valid? ${FilecoinAddress.isValidAddress(invalidAddress)}');

  // Address type information
  debugPrint('\nAddress Types:');
  debugPrint('SECP256K1 Address Type: ${secp256k1Address.type} (value: ${secp256k1Address.type.value})');
  debugPrint('Delegated Address Type: ${delegatedAddress.type} (value: ${delegatedAddress.type.value})');
  debugPrint('ID Address Type: ${idAddress.type} (value: ${idAddress.type.value})');

  debugPrint('\n');
}

void filecoinAddressConverterExample() {
  debugPrint('=== Filecoin <-> Ethereum Address Conversion Examples ===\n');

  // Convert Ethereum address to Filecoin
  final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');
  debugPrint('Original Ethereum Address: $ethAddress');

  final filecoinFromEth = FilecoinAddressConverter.convertFromEthereum(ethAddress);
  debugPrint('Converted to Filecoin: ${filecoinFromEth.toAddress()}');

  // Convert back to Ethereum
  final ethFromFilecoin = FilecoinAddressConverter.convertToEthereum(filecoinFromEth);
  debugPrint('Converted back to Ethereum: $ethFromFilecoin');

  // String-based conversion
  const ethString = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';
  final filecoinString = FilecoinAddressConverter.convertFromEthereumString(ethString);
  debugPrint('\nString conversion:');
  debugPrint('Ethereum: $ethString');
  debugPrint('Filecoin: $filecoinString');

  final convertedBack = FilecoinAddressConverter.convertToEthereumString(filecoinString);
  debugPrint('Back to Ethereum: $convertedBack');

  // ID address conversion
  final idAddress = FilecoinAddress.fromString('f09876');
  final ethFromId = FilecoinAddressConverter.convertToEthereum(idAddress);
  debugPrint('\nID Address conversion:');
  debugPrint('Filecoin ID: ${idAddress.toAddress()}');
  debugPrint('Ethereum equivalent: $ethFromId');

  // Check conversion capability
  debugPrint('\nConversion capability check:');
  debugPrint('Can convert delegated address: ${FilecoinAddressConverter.canConvertToEthereum(filecoinFromEth)}');
  debugPrint('Can convert ID address: ${FilecoinAddressConverter.canConvertToEthereum(idAddress)}');

  debugPrint('\n');
}

void filecoinTransactionExample() {
  debugPrint('=== Filecoin Transaction Examples ===\n');

  // Create addresses
  final privateKey1 = List.generate(32, (i) => i + 1);
  final privateKey2 = List.generate(32, (i) => i + 100);

  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey1);
  final toAddress = FilecoinSigner.createDelegatedAddress(privateKey2);

  debugPrint('From Address: ${fromAddress.toAddress()}');
  debugPrint('To Address: ${toAddress.toAddress()}');

  // Create a simple transfer transaction
  final transaction = FilecoinTransaction.transfer(
    from: fromAddress,
    to: toAddress,
    nonce: 0,
    value: BigInt.from(1000000000000000000), // 1 FIL in attoFIL
    gasLimit: 1000000,
    gasFeeCap: BigInt.from(2000),
    gasPremium: BigInt.from(1000),
  );

  debugPrint('\nTransaction Details:');
  debugPrint('Version: ${transaction.version}');
  debugPrint('Nonce: ${transaction.nonce}');
  debugPrint('Value: ${transaction.value} attoFIL (${transaction.value ~/ BigInt.from(1000000000000000000)} FIL)');
  debugPrint('Gas Limit: ${transaction.gasLimit}');
  debugPrint('Gas Fee Cap: ${transaction.gasFeeCap}');
  debugPrint('Gas Premium: ${transaction.gasPremium}');
  debugPrint('Method: ${transaction.method} (${transaction.method.value})');

  // Get transaction CID
  final cid = transaction.getCid();
  debugPrint('Transaction CID: ${BytesUtils.toHexString(cid, prefix: '0x')}');

  // Convert to JSON (for RPC)
  final json = transaction.toJson();
  debugPrint('\nTransaction JSON:');
  json.forEach((key, value) {
    debugPrint('  $key: $value');
  });

  debugPrint('\n');
}

void filecoinSigningExample() {
  debugPrint('=== Filecoin Transaction Signing Examples ===\n');

  // Generate keypair
  final privateKey = List.generate(32, (i) => i + 42);
  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey);
  final toAddress = FilecoinSigner.createDelegatedAddress(List.generate(32, (i) => i + 200));

  debugPrint('Signer Address: ${fromAddress.toAddress()}');
  debugPrint('Recipient Address: ${toAddress.toAddress()}');

  // Create transaction
  final transaction = FilecoinTransaction.transfer(
    from: fromAddress,
    to: toAddress,
    nonce: 5,
    value: BigInt.from(500000000000000000), // 0.5 FIL
    gasLimit: 800000,
    gasFeeCap: BigInt.from(1500),
    gasPremium: BigInt.from(750),
  );

  // Sign the transaction
  final signedTransaction = FilecoinSigner.signTransaction(
    transaction: transaction,
    privateKey: privateKey,
  );

  debugPrint('\nSigned Transaction:');
  debugPrint('Signature Type: ${signedTransaction.signature.type} (${signedTransaction.signature.type.value})');
  debugPrint('Signature Data Length: ${signedTransaction.signature.data.length} bytes');
  debugPrint('Signature Data: ${BytesUtils.toHexString(signedTransaction.signature.data.take(32).toList(), prefix: '0x')}...');

  // Convert to JSON for submission
  final signedJson = signedTransaction.toJson();
  debugPrint('\nSigned Transaction JSON (for RPC submission):');
  debugPrint('Message: ${signedJson['Message']}');
  debugPrint('Signature: ${signedJson['Signature']}');

  // Verify signature
  final isValid = FilecoinSigner.verifySignature(
    transaction: transaction,
    signature: signedTransaction.signature,
    senderAddress: fromAddress,
  );
  debugPrint('\nSignature Verification: ${isValid ? 'VALID' : 'INVALID'}');

  debugPrint('\n');
}

void filecoinMethodsExample() {
  debugPrint('=== Filecoin Methods and Values Examples ===\n');

  debugPrint('Transaction Methods:');
  debugPrint('SEND: ${FilecoinMethod.send.value}');
  debugPrint('INVOKE_EVM: ${FilecoinMethod.invokeEvm.value}');

  debugPrint('\nAddress Types:');
  for (final type in FilecoinAddressType.values) {
    debugPrint('${type.name.toUpperCase()}: ${type.value}');
  }

  debugPrint('\nSignature Types:');
  for (final type in FilecoinSignatureType.values) {
    debugPrint('${type.name.toUpperCase()}: ${type.value}');
  }

  debugPrint('\nConstants:');
  debugPrint('Ethereum Address Manager Actor ID: ${FilecoinAddress.ethereumAddressManagerActorId}');
  debugPrint('Address Prefix: "${FilecoinAddress.prefix}"');
  debugPrint('Base32 Alphabet: "${FilecoinAddress.base32Alphabet}"');
  debugPrint('Checksum Size: ${FilecoinAddress.checksumSize}');

  debugPrint('\n');
}

void main() {
  debugPrint('🚀 Filecoin Examples - On Chain Library\n');
  debugPrint('This example demonstrates Filecoin functionality including:');
  debugPrint('- Address creation and validation');
  debugPrint('- Address conversion between Filecoin and Ethereum');
  debugPrint('- Transaction creation and signing');
  debugPrint('- Constants and method values');
  debugPrint('\n${'=' * 60}\n');

  filecoinAddressExample();
  filecoinAddressConverterExample();
  filecoinTransactionExample();
  filecoinSigningExample();
  filecoinMethodsExample();

  debugPrint('✅ All Filecoin examples completed successfully!');
  debugPrint('\n${'=' * 60}');
  debugPrint('📚 For more information, visit: https://github.com/mrtnetwork/on_chain');
}