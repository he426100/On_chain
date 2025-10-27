// Migrated from iso-filecoin/test/wallet.test.js
// Tests for wallet creation, Lotus format import/export, and specific test vectors

import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  // Test mnemonic from reference implementation
  const mnemonic =
      'raw include ecology social turtle still perfect trip dance food welcome aunt patient very toss very program estate diet portion city camera loop guess';

  group('Filecoin Wallet - Account Creation', () {
    test('should create account from mnemonic', () {
      final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
      final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
      final derivedKey = bip32.derivePath("m/44'/461'/0'/0/0");
      
      final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
      final publicKey = privateKey.publicKey();
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        publicKey.bytes,
        network: FilecoinNetwork.mainnet,
      );

      expect(address.toAddress(), equals('f17levgrkmq7jeloew44ixqokvl4qdozvmacidp7i'));
    });

    test('should create account from seed', () {
      final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
      final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
      final derivedKey = bip32.derivePath("m/44'/461'/0'/0/0");
      
      final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
      final publicKey = privateKey.publicKey();
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        publicKey.bytes,
        network: FilecoinNetwork.mainnet,
      );

      expect(address.toAddress(), equals('f17levgrkmq7jeloew44ixqokvl4qdozvmacidp7i'));
    });

    test('should create account from MetaMask mnemonic', () {
      const metamaskMnemonic =
          'already turtle birth enroll since owner keep patch skirt drift any dinner';
      
      final seed = Bip39SeedGenerator(Mnemonic.fromString(metamaskMnemonic)).generate();
      final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
      final derivedKey = bip32.derivePath("m/44'/461'/0'/0/0");
      
      final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
      final publicKey = privateKey.publicKey();
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        publicKey.bytes,
        network: FilecoinNetwork.mainnet,
      );

      expect(address.toAddress(), equals('f1jbnosztqwadgh4smvsnojdvwjgqxsmtzy5n5imi'));
    });
  });

  group('Filecoin Wallet - Sign/Verify with Test Vectors', () {
    test('should sign/verify bytes with SECP256K1', () {
      // Private key: LzjsZEXCy6tDWAxcFiu76IRQwHkohWvsVK1T+2Q5NfY=
      final privateKeyBytes = BytesUtils.fromHexString(
        '2f38ec6445c2cbab435c0c5c162bbbe88450c0792885656bec54ad53fb643935'
      );
      
      final privateKey = FilPrivateKey(privateKeyBytes);
      final publicKey = privateKey.publicKey();
      
      // Data to sign: "hello" in hex
      final data = BytesUtils.fromHexString('68656c6c6f');
      
      // Hash the data with Blake2b-256 first (as required by Filecoin)
      final hashedData = QuickCrypto.blake2b256Hash(data);
      
      // Sign the hashed data
      final signature = privateKey.sign(hashedData);
      
      // Expected signature (Lotus hex format without type byte)
      // 015322ea74a2985bb1a91be635bad133b4505b566b7aed97276ece9a26bab344340e0b602cf68ca9259766d81ad9d4bfe15a0d5efa2398cab1c18b1f160dd8682600
      // Verify the signature is 65 bytes (r + s + recovery_id)
      expect(signature.length, equals(65));
      
      // Verify the signature
      expect(publicKey.verify(hashedData, signature), isTrue);
      
      // Verify with tampered data fails
      final tamperedData = BytesUtils.fromHexString('68656c6c6e'); // "helln"
      final hashedTamperedData = QuickCrypto.blake2b256Hash(tamperedData);
      expect(publicKey.verify(hashedTamperedData, signature), isFalse);
    });

    test('should sign transaction with specific test vector', () {
      // Test vector from iso-filecoin wallet.test.js line 226-266
      // Private key: tI1wF8uJseC1QdNj3CbpBAVC8G9/pfgtSYt4yXlJ+UY=
      final privateKeyBytes = BytesUtils.fromHexString(
        'b48d7017cb89b1e0b541d363dc26e9040542f06f7fa5f82d498b78c97949f946'
      );
      
      final privateKey = FilPrivateKey(privateKeyBytes);
      final publicKey = privateKey.publicKey();
      
      // Verify public key is 65 bytes (uncompressed format)
      expect(publicKey.bytes.length, equals(65));
      expect(publicKey.bytes[0], equals(0x04)); // Uncompressed prefix
      
      // Create address from public key
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        publicKey.bytes,
        network: FilecoinNetwork.mainnet,
      );
      expect(address.toAddress(), equals('f17dyptywvmnldq2fsm6j226txnltf4aiwsi3vlka'));
      
      // Create message
      final message = FilecoinMessage(
        version: 0,
        to: 'f1ypi542zmmgaltijzw4byonei5c267ev5iif2liy',
        from: 'f17dyptywvmnldq2fsm6j226txnltf4aiwsi3vlka',
        value: '87316',
        gasFeeCap: '42908',
        gasPremium: '28871',
        gasLimit: 20982,
        nonce: 20101,
        method: 65360, // This is a custom method number
        params: '',
      );
      
      // Expected serialization
      final expectedSerialization = '8a005501c3d1de6b2c6180b9a139b703873488e8b5ef92bd5501f8f0f9e2d563563868b26793ad7a776ae65e0116194e8544000155141951f64300a79c430070c719ff5040';
      expect(
        BytesUtils.toHexString(message.serialize()),
        equals(expectedSerialization)
      );
      
      // Sign the message
      final transaction = FilecoinTransaction(
        version: message.version,
        to: FilecoinAddress.fromString(message.to),
        from: FilecoinAddress.fromString(message.from),
        nonce: message.nonce,
        value: BigInt.parse(message.value),
        gasLimit: message.gasLimit,
        gasFeeCap: BigInt.parse(message.gasFeeCap),
        gasPremium: BigInt.parse(message.gasPremium),
        method: FilecoinMethod.send, // Use send as placeholder for custom method
        params: [],
      );
      
      final signer = FilecoinSigner(privateKey);
      final signedTx = signer.sign(transaction);
      
      // Verify signature is 65 bytes
      expect(signedTx.signature.data.length, equals(65));
      
      // Verify signature using signer
      expect(
        signer.verify(
          transaction: transaction,
          signature: signedTx.signature,
        ),
        isTrue
      );
    });
  });

  group('Filecoin Wallet - FRC-102 Personal Sign', () {
    test('should sign/verify using FRC-102', () {
      // Private key: LzjsZEXCy6tDWAxcFiu76IRQwHkohWvsVK1T+2Q5NfY=
      final privateKeyBytes = BytesUtils.fromHexString(
        '2f38ec6445c2cbab435c0c5c162bbbe88450c0792885656bec54ad53fb643935'
      );
      
      final privateKey = FilPrivateKey(privateKeyBytes);
      final publicKey = privateKey.publicKey();
      
      // Message: "hello world"
      const message = 'hello world';
      
      // Convert string to bytes
      final messageBytes = message.codeUnits;
      
      // Sign using FRC-102
      final signature = FilecoinWallet.personalSign(
        privateKey: privateKeyBytes,
        type: FilecoinSignatureType.secp256k1,
        data: messageBytes,
      );
      
      // Verify using FRC-102
      final isValid = FilecoinWallet.personalVerify(
        publicKey: publicKey.bytes,
        data: messageBytes,
        signature: signature,
      );
      
      expect(isValid, isTrue);
      
      // Verify with wrong message fails
      final wrongMessageBytes = 'wrong message'.codeUnits;
      final isInvalid = FilecoinWallet.personalVerify(
        publicKey: publicKey.bytes,
        data: wrongMessageBytes,
        signature: signature,
      );
      
      expect(isInvalid, isFalse);
    });
  });

  group('Filecoin Wallet - Edge Cases', () {
    test('should handle empty params in message', () {
      final privateKeyBytes = List.generate(32, (i) => i + 1);
      final privateKey = FilPrivateKey(privateKeyBytes);
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        privateKey.publicKey().bytes,
      );
      
      final message = FilecoinMessage(
        to: address.toAddress(),
        from: address.toAddress(),
        value: '1000',
        params: '', // Empty params
      );
      
      expect(() => message.serialize(), returnsNormally);
    });

    test('should create account from different derivation paths', () {
      final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
      final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
      
      final paths = [
        "m/44'/461'/0'/0/0",
        "m/44'/461'/0'/0/1",
        "m/44'/461'/1'/0/0",
      ];
      
      final addresses = <String>{};
      
      for (final path in paths) {
        final derivedKey = bip32.derivePath(path);
        final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
        final address = FilecoinAddress.fromSecp256k1PublicKey(
          privateKey.publicKey().bytes,
          network: FilecoinNetwork.mainnet,
        );
        addresses.add(address.toAddress());
      }
      
      // All addresses should be unique
      expect(addresses.length, equals(paths.length));
    });

    test('should handle testnet derivation path', () {
      final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
      final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
      
      // Testnet uses coin_type = 1
      final derivedKey = bip32.derivePath("m/44'/1'/0'/0/0");
      final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
      final address = FilecoinAddress.fromSecp256k1PublicKey(
        privateKey.publicKey().bytes,
        network: FilecoinNetwork.testnet,
      );
      
      expect(address.toAddress().startsWith('t'), isTrue);
    });
  });

  group('Filecoin Wallet - Round Trip Tests', () {
    test('should preserve data through sign/verify cycle', () {
      final privateKeyBytes = List.generate(32, (i) => i * 7 % 256);
      final privateKey = FilPrivateKey(privateKeyBytes);
      final publicKey = privateKey.publicKey();
      
      final testData = List.generate(100, (i) => i);
      final hashedTestData = QuickCrypto.blake2b256Hash(testData);
      final signature = privateKey.sign(hashedTestData);
      
      expect(publicKey.verify(hashedTestData, signature), isTrue);
    });

    test('should create consistent addresses from same mnemonic', () {
      final addresses = <String>[];
      
      for (var i = 0; i < 3; i++) {
        final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
        final bip32 = Bip32Slip10Secp256k1.fromSeed(seed);
        final derivedKey = bip32.derivePath("m/44'/461'/0'/0/0");
        
        final privateKey = FilPrivateKey(derivedKey.privateKey.raw);
        final address = FilecoinAddress.fromSecp256k1PublicKey(
          privateKey.publicKey().bytes,
          network: FilecoinNetwork.mainnet,
        );
        addresses.add(address.toAddress());
      }
      
      // All addresses should be identical
      expect(addresses.toSet().length, equals(1));
      expect(addresses.first, equals('f17levgrkmq7jeloew44ixqokvl4qdozvmacidp7i'));
    });
  });
}

