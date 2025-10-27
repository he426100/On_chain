// ignore_for_file: unused_local_variable

import 'package:on_chain/on_chain.dart';

void filecoinTestnetExample() {
  // Generate a private key
  final privateKey = List.generate(32, (i) => i + 1);

  // Create addresses on testnet
  final secp256k1Address = FilecoinSigner.createSecp256k1Address(
    privateKey,
    network: FilecoinNetwork.testnet,
  );

  final delegatedAddress = FilecoinSigner.createDelegatedAddress(
    privateKey,
    network: FilecoinNetwork.testnet,
  );

  // Parse testnet addresses
  final testnetIdAddress = FilecoinAddress.fromString('t0123');

  // Validate testnet addresses
  const validTestnetAddress = 't0456';
  const invalidMainnetAddress = 'f0456'; // mainnet address is invalid on testnet
  final isValidTestnet = FilecoinAddress.isValidAddressForNetwork(validTestnetAddress, FilecoinNetwork.testnet);
  final isInvalidOnTestnet = FilecoinAddress.isValidAddressForNetwork(invalidMainnetAddress, FilecoinNetwork.testnet);

  // Parse mainnet address
  final mainnetAddress = FilecoinAddress.fromString('f0789');

  // Get network information
  final secpNetworkName = secp256k1Address.network.name;
  final secpNetworkPrefix = secp256k1Address.network.prefix;
  final delNetworkName = delegatedAddress.network.name;
  final testnetNetworkName = testnetIdAddress.network.name;
  final mainnetNetworkName = mainnetAddress.network.name;
  final testnetActorId = testnetIdAddress.actorId;
}

void filecoinTestnetNetworkInfoExample() {
  // Mainnet network information
  final mainnetName = FilecoinNetwork.mainnet.name;
  final mainnetPrefix = FilecoinNetwork.mainnet.prefix;
  final mainnetChainId = FilecoinNetwork.mainnet.chainId;
  final mainnetChainIdHex = FilecoinNetwork.mainnet.chainIdHex;
  final mainnetCoinType = FilecoinNetwork.mainnet.coinType;
  final mainnetCurrency = FilecoinNetwork.mainnet.currencySymbol;
  final mainnetRpcUrl = FilecoinNetwork.mainnet.defaultRpcUrl;
  final mainnetWsUrl = FilecoinNetwork.mainnet.defaultWsUrl;
  final mainnetExplorer = FilecoinNetwork.mainnet.explorerUrl;
  final mainnetDerivationPath = FilecoinNetwork.mainnet.derivationPath();
  final mainnetIsTestnet = FilecoinNetwork.mainnet.isTestnet;

  // Testnet network information
  final testnetName = FilecoinNetwork.testnet.name;
  final testnetPrefix = FilecoinNetwork.testnet.prefix;
  final testnetChainId = FilecoinNetwork.testnet.chainId;
  final testnetChainIdHex = FilecoinNetwork.testnet.chainIdHex;
  final testnetCoinType = FilecoinNetwork.testnet.coinType;
  final testnetCurrency = FilecoinNetwork.testnet.currencySymbol;
  final testnetRpcUrl = FilecoinNetwork.testnet.defaultRpcUrl;
  final testnetWsUrl = FilecoinNetwork.testnet.defaultWsUrl;
  final testnetExplorer = FilecoinNetwork.testnet.explorerUrl;
  final testnetDerivationPath = FilecoinNetwork.testnet.derivationPath();
  final testnetIsTestnet = FilecoinNetwork.testnet.isTestnet;
}

void filecoinTestnetTransactionExample() {
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

  // Get transaction details
  final version = transaction.version;
  final nonce = transaction.nonce;
  final value = transaction.value;
  final gasLimit = transaction.gasLimit;
  final gasFeeCap = transaction.gasFeeCap;
  final gasPremium = transaction.gasPremium;

  // Get transaction CID
  final cid = transaction.getCid();

  // Sign transaction
  final signedTransaction = FilecoinSigner.signTransaction(
    transaction: transaction,
    privateKey: privateKey1,
  );

  // Get signature details
  final signatureType = signedTransaction.signature.type;
  final signatureDataLength = signedTransaction.signature.data.length;

  // Convert to JSON for submission to testnet
  final signedJson = signedTransaction.toJson();
  final testnetRpcUrl = FilecoinNetwork.testnet.defaultRpcUrl;
}

void filecoinTestnetAddressConversionExample() {
  // Convert Ethereum address to Filecoin testnet address
  final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');

  final testnetFilecoinFromEth = FilecoinAddressConverter.convertFromEthereum(
    ethAddress,
    network: FilecoinNetwork.testnet,
  );

  // Convert back to Ethereum
  final ethFromTestnetFilecoin = FilecoinAddressConverter.convertToEthereum(
    testnetFilecoinFromEth,
  );

  // Compare with mainnet conversion
  final mainnetFilecoinFromEth = FilecoinAddressConverter.convertFromEthereum(
    ethAddress,
    network: FilecoinNetwork.mainnet,
  );

  // Get comparison details
  final testnetNetworkName = testnetFilecoinFromEth.network.name;
  final testnetAddress = testnetFilecoinFromEth.toAddress();
  final mainnetAddress = mainnetFilecoinFromEth.toAddress();
  final testnetPrefix = testnetFilecoinFromEth.network.prefix;
  final mainnetPrefix = mainnetFilecoinFromEth.network.prefix;
}

void filecoinTestnetProviderExample() {
  // Get testnet network configuration for provider setup
  final testnetName = FilecoinNetwork.testnet.name;
  final testnetRpcUrl = FilecoinNetwork.testnet.defaultRpcUrl;
  final testnetWsUrl = FilecoinNetwork.testnet.defaultWsUrl;
}

void main() {
  filecoinTestnetExample();
  filecoinTestnetNetworkInfoExample();
  filecoinTestnetTransactionExample();
  filecoinTestnetAddressConversionExample();
  filecoinTestnetProviderExample();
}