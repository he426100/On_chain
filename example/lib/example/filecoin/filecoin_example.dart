// ignore_for_file: unused_local_variable

import 'package:on_chain/on_chain.dart';

void filecoinAddressExample() {
  // Generate a private key
  final privateKey = List.generate(32, (i) => i + 1);

  // Create SECP256K1 address
  final secp256k1Address = FilecoinSigner.createSecp256k1Address(privateKey);

  // Create delegated address (Ethereum-compatible)
  final delegatedAddress = FilecoinSigner.createDelegatedAddress(privateKey);

  // Parse ID address
  final idAddress = FilecoinAddress.fromString('f0123');

  // Address validation
  const validAddress = 'f0456';
  final isValid1 = FilecoinAddress.isValidAddress(validAddress);
  final isValid2 = FilecoinAddress.isValidAddress('invalid_address');

  // Get address type information
  final secpType = secp256k1Address.type.value;
  final delType = delegatedAddress.type.value;
  final idType = idAddress.type.value;
}

void filecoinAddressConverterExample() {
  // Convert Ethereum address to Filecoin
  final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');
  final filecoinFromEth = FilecoinAddressConverter.convertFromEthereum(ethAddress);

  // Convert back to Ethereum
  final ethFromFilecoin = FilecoinAddressConverter.convertToEthereum(filecoinFromEth);

  // String-based conversion
  const ethString = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd';
  final filecoinString = FilecoinAddressConverter.convertFromEthereumString(ethString);
  final convertedBack = FilecoinAddressConverter.convertToEthereumString(filecoinString);

  // ID address conversion
  final idAddress = FilecoinAddress.fromString('f09876');
  final ethFromId = FilecoinAddressConverter.convertToEthereum(idAddress);

  // Check conversion capability
  final canConvertDelegated = FilecoinAddressConverter.canConvertToEthereum(filecoinFromEth);
  final canConvertId = FilecoinAddressConverter.canConvertToEthereum(idAddress);
}

void filecoinTransactionExample() {
  // Create addresses
  final privateKey1 = List.generate(32, (i) => i + 1);
  final privateKey2 = List.generate(32, (i) => i + 100);

  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey1);
  final toAddress = FilecoinSigner.createDelegatedAddress(privateKey2);

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

  // Get transaction CID
  final cid = transaction.getCid();

  // Convert to JSON (for RPC)
  final json = transaction.toJson();

  // Get transaction details
  final version = transaction.version;
  final method = transaction.method.value;
  final gasLimit = transaction.gasLimit;
}

void filecoinSigningExample() {
  // Generate keypair
  final privateKey = List.generate(32, (i) => i + 42);
  final fromAddress = FilecoinSigner.createSecp256k1Address(privateKey);
  final toAddress = FilecoinSigner.createDelegatedAddress(List.generate(32, (i) => i + 200));

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

  // Sign transaction
  final signedTransaction = FilecoinSigner.signTransaction(
    transaction: transaction,
    privateKey: privateKey,
  );

  // Convert to JSON for submission
  final signedJson = signedTransaction.toJson();

  // Verify signature
  final isValid = FilecoinSigner.verifySignature(
    transaction: transaction,
    signature: signedTransaction.signature,
    senderAddress: fromAddress,
  );

  // Get signature details
  final signatureType = signedTransaction.signature.type.value;
  final signatureDataLength = signedTransaction.signature.data.length;
}

void filecoinMethodsExample() {
  // Get method values
  final sendMethod = FilecoinMethod.send.value;
  final invokeEvmMethod = FilecoinMethod.invokeEvm.value;

  // Get address types
  const addressTypes = FilecoinAddressType.values;

  // Get signature types
  const signatureTypes = FilecoinSignatureType.values;

  // Get constants
  const ethManagerActorId = FilecoinAddress.ethereumAddressManagerActorId;
  const addressPrefix = FilecoinAddress.prefix;
  const base32Alphabet = FilecoinAddress.base32Alphabet;
  const checksumSize = FilecoinAddress.checksumSize;
}

void main() {
  filecoinAddressExample();
  filecoinAddressConverterExample();
  filecoinTransactionExample();
  filecoinSigningExample();
  filecoinMethodsExample();
}