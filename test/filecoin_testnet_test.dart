import 'package:on_chain/filecoin/filecoin.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  group('Filecoin Testnet Network', () {
    test('Network properties - Mainnet', () {
      expect(FilecoinNetwork.mainnet.name, 'mainnet');
      expect(FilecoinNetwork.mainnet.prefix, 'f');
      expect(FilecoinNetwork.mainnet.chainId, 314);
      expect(FilecoinNetwork.mainnet.chainIdHex, '0x13a');
      expect(FilecoinNetwork.mainnet.coinType, 461);
      expect(FilecoinNetwork.mainnet.currencySymbol, 'FIL');
      expect(FilecoinNetwork.mainnet.isTestnet, false);
      expect(FilecoinNetwork.mainnet.derivationPath(), "m/44'/461'/0'/0/0");
      expect(FilecoinNetwork.mainnet.derivationPath(1), "m/44'/461'/0'/0/1");
    });

    test('Network properties - Testnet', () {
      expect(FilecoinNetwork.testnet.name, 'testnet');
      expect(FilecoinNetwork.testnet.prefix, 't');
      expect(FilecoinNetwork.testnet.chainId, 314159);
      expect(FilecoinNetwork.testnet.chainIdHex, '0x4cb2f');
      expect(FilecoinNetwork.testnet.coinType, 1);
      expect(FilecoinNetwork.testnet.currencySymbol, 'tFIL');
      expect(FilecoinNetwork.testnet.isTestnet, true);
      expect(FilecoinNetwork.testnet.derivationPath(), "m/44'/1'/0'/0/0");
      expect(FilecoinNetwork.testnet.derivationPath(5), "m/44'/1'/0'/0/5");
    });

    test('Network from prefix', () {
      expect(FilecoinNetwork.fromPrefix('f'), FilecoinNetwork.mainnet);
      expect(FilecoinNetwork.fromPrefix('t'), FilecoinNetwork.testnet);
      expect(() => FilecoinNetwork.fromPrefix('x'), throwsArgumentError);
    });

    test('Network from chain ID', () {
      expect(FilecoinNetwork.fromChainId(314), FilecoinNetwork.mainnet);
      expect(FilecoinNetwork.fromChainId(314159), FilecoinNetwork.testnet);
      expect(() => FilecoinNetwork.fromChainId(999), throwsArgumentError);
    });

    test('Network validation', () {
      expect(FilecoinNetwork.isValidPrefix('f'), true);
      expect(FilecoinNetwork.isValidPrefix('t'), true);
      expect(FilecoinNetwork.isValidPrefix('x'), false);
      expect(FilecoinNetwork.isValidPrefix('1'), false);
    });
  });

  group('Filecoin Testnet Address', () {
    test('Create testnet SECP256K1 address', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final address = FilecoinSigner.createSecp256k1Address(
        privateKey,
        network: FilecoinNetwork.testnet,
      );

      expect(address.network, FilecoinNetwork.testnet);
      expect(address.toAddress().startsWith('t1'), true);
      expect(address.type, FilecoinAddressType.secp256k1);
    });

    test('Create mainnet SECP256K1 address', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final address = FilecoinSigner.createSecp256k1Address(
        privateKey,
        network: FilecoinNetwork.mainnet,
      );

      expect(address.network, FilecoinNetwork.mainnet);
      expect(address.toAddress().startsWith('f1'), true);
      expect(address.type, FilecoinAddressType.secp256k1);
    });

    test('Create testnet delegated address', () {
      final privateKey = List.generate(32, (i) => i + 100);
      final address = FilecoinSigner.createDelegatedAddress(
        privateKey,
        network: FilecoinNetwork.testnet,
      );

      expect(address.network, FilecoinNetwork.testnet);
      expect(address.toAddress().startsWith('t410'), true);
      expect(address.type, FilecoinAddressType.delegated);
      expect(address.actorId, 10);
    });

    test('Parse testnet ID address', () {
      final address = FilecoinAddress.fromString('t0123');
      expect(address.network, FilecoinNetwork.testnet);
      expect(address.type, FilecoinAddressType.id);
      expect(address.actorId, 123);
      expect(address.toAddress(), 't0123');
    });

    test('Parse mainnet ID address', () {
      final address = FilecoinAddress.fromString('f0456');
      expect(address.network, FilecoinNetwork.mainnet);
      expect(address.type, FilecoinAddressType.id);
      expect(address.actorId, 456);
      expect(address.toAddress(), 'f0456');
    });

    test('Parse testnet SECP256K1 address', () {
      // Example testnet address from reference implementation
      final address = FilecoinAddress.fromString('t1wbxhu3ypkuo6eyp6hjx6davuelxaxrvwb2kuwva');
      expect(address.network, FilecoinNetwork.testnet);
      expect(address.type, FilecoinAddressType.secp256k1);
      expect(address.toAddress(), 't1wbxhu3ypkuo6eyp6hjx6davuelxaxrvwb2kuwva');
    });

    test('Parse testnet delegated address', () {
      // Example testnet delegated address from reference implementation
      final address = FilecoinAddress.fromString('t410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      expect(address.network, FilecoinNetwork.testnet);
      expect(address.type, FilecoinAddressType.delegated);
      expect(address.actorId, 10);
      expect(address.toAddress(), 't410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
    });

    test('Address validation', () {
      expect(FilecoinAddress.isValidAddress('t0123'), true);
      expect(FilecoinAddress.isValidAddress('f0123'), true);
      expect(FilecoinAddress.isValidAddress('x0123'), false);
      expect(FilecoinAddress.isValidAddress('t1wbxhu3ypkuo6eyp6hjx6davuelxaxrvwb2kuwva'), true);
    });

    test('Address bytes round-trip - testnet', () {
      final address = FilecoinAddress.fromString('t0789');
      final bytes = address.toBytes();
      final restored = FilecoinAddress.fromBytes(bytes, network: FilecoinNetwork.testnet);
      expect(restored.toAddress(), 't0789');
      expect(restored.network, FilecoinNetwork.testnet);
    });

    test('Same payload, different network prefix', () {
      final privateKey = List.generate(32, (i) => i + 1);

      final mainnetAddr = FilecoinSigner.createSecp256k1Address(
        privateKey,
        network: FilecoinNetwork.mainnet,
      );

      final testnetAddr = FilecoinSigner.createSecp256k1Address(
        privateKey,
        network: FilecoinNetwork.testnet,
      );

      // Same payload
      expect(
        BytesUtils.toHexString(mainnetAddr.payload),
        BytesUtils.toHexString(testnetAddr.payload),
      );

      // Different prefixes
      expect(mainnetAddr.toAddress().startsWith('f1'), true);
      expect(testnetAddr.toAddress().startsWith('t1'), true);
    });
  });

  group('Filecoin Testnet Address Conversion', () {
    test('Convert Ethereum to testnet Filecoin address', () {
      final ethAddress = ETHAddress('0xd388ab098ed3e84c0d808776440b48f685198498');
      final filAddress = FilecoinAddressConverter.convertFromEthereum(
        ethAddress,
        network: FilecoinNetwork.testnet,
      );

      expect(filAddress.network, FilecoinNetwork.testnet);
      expect(filAddress.toAddress(), 't410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      expect(filAddress.type, FilecoinAddressType.delegated);
    });

    test('Convert Ethereum to mainnet Filecoin address', () {
      final ethAddress = ETHAddress('0xd388ab098ed3e84c0d808776440b48f685198498');
      final filAddress = FilecoinAddressConverter.convertFromEthereum(
        ethAddress,
        network: FilecoinNetwork.mainnet,
      );

      expect(filAddress.network, FilecoinNetwork.mainnet);
      expect(filAddress.toAddress(), 'f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      expect(filAddress.type, FilecoinAddressType.delegated);
    });

    test('Convert testnet Filecoin to Ethereum', () {
      final filAddress = FilecoinAddress.fromString('t410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      final ethAddress = FilecoinAddressConverter.convertToEthereum(filAddress);

      expect(ethAddress, isNotNull);
      expect(ethAddress!.address.toLowerCase(), '0xd388ab098ed3e84c0d808776440b48f685198498');
    });

    test('Round-trip conversion testnet', () {
      final originalEth = ETHAddress('0x1234567890123456789012345678901234567890');

      final testnetFil = FilecoinAddressConverter.convertFromEthereum(
        originalEth,
        network: FilecoinNetwork.testnet,
      );

      final convertedEth = FilecoinAddressConverter.convertToEthereum(testnetFil);

      expect(convertedEth, isNotNull);
      expect(convertedEth!.address.toLowerCase(), originalEth.address.toLowerCase());
    });

    test('Same ETH, different network prefixes', () {
      final ethAddress = ETHAddress('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd');

      final mainnetFil = FilecoinAddressConverter.convertFromEthereum(
        ethAddress,
        network: FilecoinNetwork.mainnet,
      );

      final testnetFil = FilecoinAddressConverter.convertFromEthereum(
        ethAddress,
        network: FilecoinNetwork.testnet,
      );

      // Same payload
      expect(
        BytesUtils.toHexString(mainnetFil.payload),
        BytesUtils.toHexString(testnetFil.payload),
      );

      // Different network
      expect(mainnetFil.network, FilecoinNetwork.mainnet);
      expect(testnetFil.network, FilecoinNetwork.testnet);

      // Different string representation
      expect(mainnetFil.toAddress().startsWith('f410'), true);
      expect(testnetFil.toAddress().startsWith('t410'), true);
    });
  });

  group('Filecoin Testnet Transaction', () {
    test('Create transaction on testnet', () {
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

      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(100000000000000000), // 0.1 tFIL
        gasLimit: 1000000,
        gasFeeCap: BigInt.from(2000),
        gasPremium: BigInt.from(1000),
      );

      expect(transaction.from, fromAddress);
      expect(transaction.to, toAddress);
      expect(transaction.value, BigInt.from(100000000000000000));
      expect(fromAddress.toAddress().startsWith('t'), true);
      expect(toAddress.toAddress().startsWith('t'), true);
    });

    test('Sign transaction on testnet', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final fromAddress = FilecoinSigner.createSecp256k1Address(
        privateKey,
        network: FilecoinNetwork.testnet,
      );

      final toAddress = FilecoinSigner.createDelegatedAddress(
        List.generate(32, (i) => i + 100),
        network: FilecoinNetwork.testnet,
      );

      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(1000000000000000000), // 1 tFIL
        gasLimit: 1000000,
        gasFeeCap: BigInt.from(2000),
        gasPremium: BigInt.from(1000),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      expect(signedTransaction.signature.data.length, greaterThanOrEqualTo(64));
      expect(signedTransaction.message, transaction);
    });
  });

  group('Filecoin Provider Network', () {
    test('Provider with testnet network', () {
      // This is a conceptual test - actual RPC calls would require network access
      // Just verify the provider can be created with testnet configuration
      final testnetUrl = FilecoinNetwork.testnet.defaultRpcUrl;
      expect(testnetUrl, contains('calibration'));
      expect(testnetUrl, startsWith('https://'));
    });

    test('Network configuration URLs', () {
      expect(FilecoinNetwork.mainnet.defaultRpcUrl, 'https://api.node.glif.io/rpc/v1');
      expect(FilecoinNetwork.testnet.defaultRpcUrl, 'https://api.calibration.node.glif.io/rpc/v1');

      expect(FilecoinNetwork.mainnet.defaultWsUrl, 'wss://wss.node.glif.io/apigw/lotus/rpc/v1');
      expect(FilecoinNetwork.testnet.defaultWsUrl, 'wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v1');

      expect(FilecoinNetwork.mainnet.explorerUrl, 'https://filfox.info');
      expect(FilecoinNetwork.testnet.explorerUrl, 'https://calibration.filfox.info');
    });
  });
}
