import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// 这些测试用例来自 js-conflux-sdk/test/wallet.test.js
/// 测试私钥的 Keystore 加密和解密功能
void main() {
  const privateKeyHex = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const testPublicKey = '0x4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8ffffe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559';
  const testAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
  const password = 'password';
  
  // Keystore 来自 js-conflux-sdk
  final referenceKeystore = {
    'version': 3,
    'id': 'db029583-f1bd-41cc-aeb5-b2ed5b33227b',
    'address': '1cad0b19bb29d4674531d6f115237e16afce377c',
    'crypto': {
      'ciphertext': '3198706577b0880234ecbb5233012a8ca0495bf2cfa2e45121b4f09434187aba',
      'cipherparams': {'iv': 'a9a1f9565fd9831e669e8a9a0ec68818'},
      'cipher': 'aes-128-ctr',
      'kdf': 'scrypt',
      'kdfparams': {
        'dklen': 32,
        'salt': '3ce2d51bed702f2f31545be66fa73d1467d24686059776430df9508407b74231',
        'n': 8192,
        'r': 8,
        'p': 1,
      },
      'mac': 'cf73832f328f3d5d1e0ec7b0f9c220facf951e8bba86c9f26e706d2df1e34890',
    },
  };

  group('Keystore Encryption and Decryption', () {
    test('should encrypt private key to keystore', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      
      // Encrypt to keystore using blockchain_utils
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      
      // Verify keystore structure
      expect(keystore['version'], equals(3));
      expect(keystore['address'], isA<String>());
      expect(keystore['crypto'], isA<Map>());
      
      final crypto = keystore['crypto'] as Map;
      expect(crypto['ciphertext'], isA<String>());
      expect(crypto['cipher'], equals('aes-128-ctr'));
      expect(crypto['kdf'], equals('scrypt'));
      expect(crypto['cipherparams'], isA<Map>());
      expect(crypto['kdfparams'], isA<Map>());
      expect(crypto['mac'], isA<String>());
      
      // Verify ciphertext is valid hex
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(crypto['ciphertext']), isTrue);
      
      // Verify IV is 32 hex chars (16 bytes)
      final iv = (crypto['cipherparams'] as Map)['iv'] as String;
      expect(iv.length, equals(32));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(iv), isTrue);
      
      // Verify MAC is 64 hex chars (32 bytes)
      final mac = crypto['mac'] as String;
      expect(mac.length, equals(64));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(mac), isTrue);
    });

    test('should decrypt keystore back to private key', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      
      // Encrypt
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      
      // Decrypt
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        keystore,
        password,
      );
      final decryptedKey = CFXPrivateKey.fromBytes(decryptedBytes);
      
      // Verify decrypted key matches original
      expect(decryptedKey.toHex(), equals(privateKey.toHex()));
      expect(decryptedKey.publicKey().toHex(), equals(privateKey.publicKey().toHex()));
    });

    test('should decrypt reference keystore from js-conflux-sdk', () {
      // Decrypt the keystore from js-conflux-sdk
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        referenceKeystore,
        password,
      );
      final privateKey = CFXPrivateKey.fromBytes(decryptedBytes);
      
      // Verify it matches expected values
      expect(privateKey.toHex(), equals(privateKeyHex));
      
      final publicKey = privateKey.publicKey();
      expect(publicKey.toHex(), equals(testPublicKey));
      
      final address = publicKey.toAddress(1); // testnet
      expect(address.toBase32(), equals(testAddress));
    });

    test('should fail with wrong password', () {
      expect(
        () => Web3SecretStorageDefinationV3.decode(
          referenceKeystore,
          'wrong_password',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should produce different ciphertexts for same key', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      
      // Encrypt twice
      final keystore1 = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      final keystore2 = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      
      // Ciphertexts should be different (different salts/IVs)
      expect(
        (keystore1['crypto'] as Map)['ciphertext'],
        isNot(equals((keystore2['crypto'] as Map)['ciphertext'])),
      );
      
      // But both should decrypt to the same key
      final decrypted1 = Web3SecretStorageDefinationV3.decode(keystore1, password);
      final decrypted2 = Web3SecretStorageDefinationV3.decode(keystore2, password);
      
      expect(
        BytesUtils.toHexString(decrypted1),
        equals(BytesUtils.toHexString(decrypted2)),
      );
    });

    test('should have correct kdf parameters', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      
      final kdfParams = (keystore['crypto'] as Map)['kdfparams'] as Map;
      
      expect(kdfParams['dklen'], equals(32));
      expect(kdfParams['n'], equals(8192));
      expect(kdfParams['r'], equals(8));
      expect(kdfParams['p'], equals(1));
      expect(kdfParams['salt'], isA<String>());
      
      // Verify salt is 64 hex chars (32 bytes)
      final salt = kdfParams['salt'] as String;
      expect(salt.length, equals(64));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(salt), isTrue);
    });

    test('should handle random private keys', () {
      final privateKey = CFXPrivateKey.random();
      
      // Encrypt
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        password,
      );
      
      // Decrypt
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        keystore,
        password,
      );
      final decryptedKey = CFXPrivateKey.fromBytes(decryptedBytes);
      
      // Verify round-trip
      expect(decryptedKey.toHex(), equals(privateKey.toHex()));
    });

    test('should work with empty password', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      const emptyPassword = '';
      
      // Encrypt with empty password
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        emptyPassword,
      );
      
      // Decrypt with empty password
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        keystore,
        emptyPassword,
      );
      final decryptedKey = CFXPrivateKey.fromBytes(decryptedBytes);
      
      expect(decryptedKey.toHex(), equals(privateKey.toHex()));
    });

    test('should work with long password', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      const longPassword = 'This is a very long password with many characters and special symbols !@#\$%^&*()_+-=[]{}|;:,.<>?';
      
      // Encrypt with long password
      final keystore = Web3SecretStorageDefinationV3.encode(
        privateKey.toBytes(),
        longPassword,
      );
      
      // Decrypt with long password
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        keystore,
        longPassword,
      );
      final decryptedKey = CFXPrivateKey.fromBytes(decryptedBytes);
      
      expect(decryptedKey.toHex(), equals(privateKey.toHex()));
    });
  });

  group('Keystore Address Derivation', () {
    test('should derive correct address from keystore', () {
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        referenceKeystore,
        password,
      );
      final privateKey = CFXPrivateKey.fromBytes(decryptedBytes);
      final publicKey = privateKey.publicKey();
      
      // Derive address for testnet
      final address = publicKey.toAddress(1);
      expect(address.toBase32(), equals(testAddress));
      
      // Verify public key
      expect(publicKey.toHex(), equals(testPublicKey));
    });

    test('should match keystore address field', () {
      // The address in keystore is the hex address without 0x prefix and without checksum
      final expectedAddressInKeystore = '1cad0b19bb29d4674531d6f115237e16afce377c';
      
      expect(referenceKeystore['address'], equals(expectedAddressInKeystore));
      
      // Derive address from private key
      final decryptedBytes = Web3SecretStorageDefinationV3.decode(
        referenceKeystore,
        password,
      );
      final privateKey = CFXPrivateKey.fromBytes(decryptedBytes);
      final publicKey = privateKey.publicKey();
      
      // The address in CFX format
      final cfxAddress = publicKey.toAddress(1); // testnet
      final hexAddr = cfxAddress.toHex();
      final hexWithoutPrefix = hexAddr.startsWith('0x') 
          ? hexAddr.substring(2) 
          : hexAddr;
      
      expect(hexWithoutPrefix.toLowerCase(), equals(expectedAddressInKeystore));
    });
  });
}

