import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Wallet and Signature Tests', () {
    test('should generate and validate mnemonic', () {
      // Generate mnemonic
      final mnemonic = FilecoinWallet.generateMnemonic();
      expect(mnemonic.split(' ').length, 24);

      // Validate mnemonic
      expect(FilecoinWallet.validateMnemonic(mnemonic), true);

      // Invalid mnemonic
      expect(FilecoinWallet.validateMnemonic('invalid mnemonic words'), false);
    });

    test('should create account from mnemonic', () {
      final mnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

      final account = FilecoinWallet.accountFromMnemonic(
        mnemonic: mnemonic,
        type: FilecoinSignatureType.secp256k1,
        path: "m/44'/461'/0'/0/0",
      );

      expect(account.type, FilecoinSignatureType.secp256k1);
      expect(account.address.network, FilecoinNetwork.mainnet);
      expect(account.privateKey, isNotNull);
      expect(account.publicKey, isNotEmpty);
    });

    test('should create random account', () {
      final account = FilecoinWallet.create(
        FilecoinSignatureType.secp256k1,
        FilecoinNetwork.testnet,
      );

      expect(account.privateKey, isNotNull);
      expect(account.privateKey!.length, 32);
      expect(account.address.network, FilecoinNetwork.testnet);
    });

    test('should sign and verify message', () {
      final account = FilecoinWallet.create(
        FilecoinSignatureType.secp256k1,
        FilecoinNetwork.mainnet,
      );

      final message = [1, 2, 3, 4, 5];

      // Sign
      final signature = FilecoinWallet.sign(
        privateKey: account.privateKey!,
        type: account.type,
        data: message,
      );

      expect(signature.isValid(), true);
      expect(signature.data.length, 65);

      // Verify
      final isValid = FilecoinWallet.verify(
        publicKey: account.publicKey,
        data: message,
        signature: signature,
      );

      expect(isValid, true);
    });

    test('should support FRC-102 personal sign', () {
      final account = FilecoinWallet.create(
        FilecoinSignatureType.secp256k1,
        FilecoinNetwork.mainnet,
      );

      final message = 'Hello Filecoin!'.codeUnits;

      // Personal sign
      final signature = FilecoinWallet.personalSign(
        privateKey: account.privateKey!,
        type: account.type,
        data: message,
      );

      expect(signature.isValid(), true);

      // Personal verify
      final isValid = FilecoinWallet.personalVerify(
        publicKey: account.publicKey,
        data: message,
        signature: signature,
      );

      expect(isValid, true);
    });
  });

  group('FilecoinSignature Lotus Format Tests', () {
    test('should convert to/from Lotus format', () {
      final signature = FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: List<int>.filled(65, 0),
      );

      // To Lotus
      final lotusData = signature.toLotus();
      expect(lotusData['Type'], 1);
      expect(lotusData['Data'], isA<String>());

      // From Lotus
      final restored = FilecoinSignature.fromLotus(lotusData);
      expect(restored.type, FilecoinSignatureType.secp256k1);
      expect(restored.data.length, 65);
    });

    test('should convert to/from Lotus hex format', () {
      final signature = FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: List<int>.filled(65, 0),
      );

      // To Lotus hex
      final lotusHex = signature.toLotusHex();
      expect(lotusHex.startsWith('01'), true); // SECP256K1 prefix
      expect(lotusHex.length, 132); // 0x01 + 65 bytes = 66 bytes = 132 hex chars

      // From Lotus hex
      final restored = FilecoinSignature.fromLotusHex(lotusHex);
      expect(restored.type, FilecoinSignatureType.secp256k1);
      expect(restored.data.length, 65);
    });
  });

  group('Token Tests', () {
    test('should convert between denominations', () {
      // Test FIL to attoFIL
      final token = FilecoinToken.fromFIL('1');
      expect(token.toAttoFILString(), '1000000000000000000');

      // Test denomination conversions
      expect(token.toFemtoFIL().toString(), '1000000000000000');
      expect(token.toPicoFIL().toString(), '1000000000000');
      expect(token.toNanoFIL().toString(), '1000000000');
      expect(token.toMicroFIL().toString(), '1000000');
      expect(token.toMilliFIL().toString(), '1000');
      expect(token.toFIL(), '1');
    });

    test('should handle zero values', () {
      final zero = FilecoinToken.fromAttoFIL(BigInt.zero);
      expect(zero.toString(), '0');
      expect(zero.toFIL(), '0');
      expect(zero.toBytes(), []);
    });

    test('should serialize to bytes correctly', () {
      final token = FilecoinToken.fromAttoFILString('9');
      final bytes = token.toBytes();
      expect(bytes, [0x00, 0x09]); // [sign_byte, value]
    });
  });

  group('Chain Configuration Tests', () {
    test('should have correct mainnet configuration', () {
      expect(mainnetChain.id, 314);
      expect(mainnetChain.name, 'Filecoin - Mainnet');
      expect(mainnetChain.nativeCurrency.symbol, 'FIL');
      expect(mainnetChain.nativeCurrency.decimals, 18);
      expect(mainnetChain.testnet, false);
      expect(mainnetChain.chainId, '0x13a');
      expect(mainnetChain.caipNetworkId, 'eip155:314');
    });

    test('should have correct testnet configuration', () {
      expect(testnetChain.id, 314159);
      expect(testnetChain.name, 'Filecoin - Calibration testnet');
      expect(testnetChain.nativeCurrency.symbol, 'tFIL');
      expect(testnetChain.testnet, true);
      expect(testnetChain.chainId, '0x4cb2f');
      expect(testnetChain.caipNetworkId, 'eip155:314159');
    });
  });

  group('FilForwarder Contract Tests', () {
    test('should have correct contract configuration', () {
      expect(FilForwarderMetadata.contractAddress,
          '0x2B3ef6906429b580b7b2080de5CA893BC282c225');
      expect(FilForwarderMetadata.abi, isNotEmpty);
      expect(FilForwarderMetadata.chainIds['filecoinMainnet'], 'eip155:314');
      expect(FilForwarderMetadata.chainIds['filecoinCalibrationTestnet'],
          'eip155:314159');
    });
  });

  group('Utils Tests', () {
    test('should parse derivation path', () {
      final components =
          FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0/0");

      expect(components.purpose, 44);
      expect(components.coinType, 461);
      expect(components.account, 0);
      expect(components.change, 0);
      expect(components.addressIndex, 0);
    });

    test('should get network from path', () {
      final mainnetPath = "m/44'/461'/0'/0/0";
      expect(FilecoinUtils.getNetworkFromPath(mainnetPath),
          FilecoinNetwork.mainnet);

      final testnetPath = "m/44'/1'/0'/0/0";
      expect(
          FilecoinUtils.getNetworkFromPath(testnetPath), FilecoinNetwork.testnet);
    });

    test('should generate Lotus CID', () {
      final data = [1, 2, 3, 4, 5];
      final cid = FilecoinUtils.lotusCid(data);

      expect(cid[0], 0x01); // CIDv1
      expect(cid[1], 0x71); // dag-cbor
      expect(cid.length, 38); // 6 + 32 bytes
    });
  });
}
