import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';

void filecoinAddressExample() {
  print('=== Filecoin Address Examples ===\n');

  // Generate a private key
  final privateKey = List.generate(32, (i) => i + 1);
  print('Private Key: ${BytesUtils.toHexString(privateKey, prefix: '0x')}');

  // Create SECP256K1 address
  final secp256k1Address = FilecoinSigner.createSecp256k1Address(privateKey);
  print('SECP256K1 Address: ${secp256k1Address.toAddress()}');

  // Create delegated address (Ethereum-compatible)
  final delegatedAddress = FilecoinSigner.createDelegatedAddress(privateKey);
  print('Delegated Address: ${delegatedAddress.toAddress()}');

  // Parse ID address
  final idAddress = FilecoinAddress.fromString('f0123');
  print('Parsed ID Address: ${idAddress.toAddress()}, Actor ID: ${idAddress.actorId}');

  // Address validation
  final validAddress = 'f0456';
  final invalidAddress = 'invalid_address';
  print('Is "$validAddress" valid? ${FilecoinAddress.isValidAddress(validAddress)}');
  print('Is "$invalidAddress" valid? ${FilecoinAddress.isValidAddress(invalidAddress)}');

  // Address type information
  print('\nAddress Types:');
  print('SECP256K1 Address Type: ${secp256k1Address.type} (value: ${secp256k1Address.type.value})');
  print('Delegated Address Type: ${delegatedAddress.type} (value: ${delegatedAddress.type.value})');
  print('ID Address Type: ${idAddress.type} (value: ${idAddress.type.value})');

  print('\n');
}

void filecoinAddressConverterExample() {
  print('=== Filecoin <-> Ethereum Address Conversion Examples ===\n');

  // Convert Ethereum address to Filecoin
  final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');
  print('Original Ethereum Address: $ethAddress');

  final filecoinFromEth = FilecoinAddressConverter.convertFromEthereum(ethAddress);
  print('Converted to Filecoin: ${filecoinFromEth.toAddress()}');

  // Convert back to Ethereum
  final ethFromFilecoin = FilecoinAddressConverter.convertToEthereum(filecoinFromEth);
  print('Converted back to Ethereum: $ethFromFilecoin');

  // String-based conversion
  final ethString = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';
  final filecoinString = FilecoinAddressConverter.convertFromEthereumString(ethString);
  print('\nString conversion:');
  print('Ethereum: $ethString');
  print('Filecoin: $filecoinString');

  final convertedBack = FilecoinAddressConverter.convertToEthereumString(filecoinString);
  print('Back to Ethereum: $convertedBack');

  // ID address conversion
  final idAddress = FilecoinAddress.fromString('f09876');
  final ethFromId = FilecoinAddressConverter.convertToEthereum(idAddress);
  print('\nID Address conversion:');
  print('Filecoin ID: ${idAddress.toAddress()}');
  print('Ethereum equivalent: $ethFromId');

  // Check conversion capability
  print('\nConversion capability check:');
  print('Can convert delegated address: ${FilecoinAddressConverter.canConvertToEthereum(filecoinFromEth)}');
  print('Can convert ID address: ${FilecoinAddressConverter.canConvertToEthereum(idAddress)}');

  print('\n');
}

void filecoinTransactionExample() {
  print('=== Filecoin Transaction Examples ===\n');

  // Create addresses
  final privateKey1 = List.generate(32, (i) => i + 1);
  final privateKey2 = List.generate(32, (i) => i + 100);

  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey1);
  final toAddress = FilecoinSigner.createDelegatedAddress(privateKey2);

  print('From Address: ${fromAddress.toAddress()}');
  print('To Address: ${toAddress.toAddress()}');

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

  print('\nTransaction Details:');
  print('Version: ${transaction.version}');
  print('Nonce: ${transaction.nonce}');
  print('Value: ${transaction.value} attoFIL (${transaction.value ~/ BigInt.from(1000000000000000000)} FIL)');
  print('Gas Limit: ${transaction.gasLimit}');
  print('Gas Fee Cap: ${transaction.gasFeeCap}');
  print('Gas Premium: ${transaction.gasPremium}');
  print('Method: ${transaction.method} (${transaction.method.value})');

  // Get transaction CID
  final cid = transaction.getCid();
  print('Transaction CID: ${BytesUtils.toHexString(cid, prefix: '0x')}');

  // Convert to JSON (for RPC)
  final json = transaction.toJson();
  print('\nTransaction JSON:');
  json.forEach((key, value) {
    print('  $key: $value');
  });

  print('\n');
}

void filecoinSigningExample() {
  print('=== Filecoin Transaction Signing Examples ===\n');

  // Generate keypair
  final privateKey = List.generate(32, (i) => i + 42);
  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey);
  final toAddress = FilecoinSigner.createDelegatedAddress(List.generate(32, (i) => i + 200));

  print('Signer Address: ${fromAddress.toAddress()}');
  print('Recipient Address: ${toAddress.toAddress()}');

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

  print('\nSigned Transaction:');
  print('Signature Type: ${signedTransaction.signature.type} (${signedTransaction.signature.type.value})');
  print('Signature Data Length: ${signedTransaction.signature.data.length} bytes');
  print('Signature Data: ${BytesUtils.toHexString(signedTransaction.signature.data.take(32).toList(), prefix: '0x')}...');

  // Convert to JSON for submission
  final signedJson = signedTransaction.toJson();
  print('\nSigned Transaction JSON (for RPC submission):');
  print('Message: ${signedJson['Message']}');
  print('Signature: ${signedJson['Signature']}');

  // Verify signature
  final isValid = FilecoinSigner.verifySignature(
    transaction: transaction,
    signature: signedTransaction.signature,
    senderAddress: fromAddress,
  );
  print('\nSignature Verification: ${isValid ? 'VALID' : 'INVALID'}');

  print('\n');
}

void filecoinMethodsExample() {
  print('=== Filecoin Methods and Values Examples ===\n');

  print('Transaction Methods:');
  print('SEND: ${FilecoinMethod.send.value}');
  print('INVOKE_EVM: ${FilecoinMethod.invokeEvm.value}');

  print('\nAddress Types:');
  for (final type in FilecoinAddressType.values) {
    print('${type.name.toUpperCase()}: ${type.value}');
  }

  print('\nSignature Types:');
  for (final type in FilecoinSignatureType.values) {
    print('${type.name.toUpperCase()}: ${type.value}');
  }

  print('\nConstants:');
  print('Ethereum Address Manager Actor ID: ${FilecoinAddress.ethereumAddressManagerActorId}');
  print('Address Prefix: "${FilecoinAddress.prefix}"');
  print('Base32 Alphabet: "${FilecoinAddress.base32Alphabet}"');
  print('Checksum Size: ${FilecoinAddress.checksumSize}');

  print('\n');
}

void main() {
  print('🚀 Filecoin Examples - On Chain Library\n');
  print('This example demonstrates Filecoin functionality including:');
  print('- Address creation and validation');
  print('- Address conversion between Filecoin and Ethereum');
  print('- Transaction creation and signing');
  print('- Constants and method values');
  print('\n' + '=' * 60 + '\n');

  filecoinAddressExample();
  filecoinAddressConverterExample();
  filecoinTransactionExample();
  filecoinSigningExample();
  filecoinMethodsExample();

  print('✅ All Filecoin examples completed successfully!');
  print('\n' + '=' * 60);
  print('📚 For more information, visit: https://github.com/mrtnetwork/on_chain');
}