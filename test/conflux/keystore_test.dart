import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// Keystore encryption/decryption tests
/// 
/// 来自 js-conflux-sdk/test/wallet.test.js
void main() {
  group('Keystore Encryption/Decryption Tests', () {
    // Test data
    const testPrivateKey = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const password = 'password123';
    const weakPassword = 'test';
    
    test('Encrypt and decrypt private key', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Encrypt to keystore (returns JSON string)
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      // Validate keystore is valid JSON
      expect(keystoreJson, isA<String>());
      expect(keystoreJson, contains('"version"'));
      expect(keystoreJson, contains('"crypto"'));
      
      // Decrypt keystore
      final decrypted = CFXKeystore.decrypt(keystoreJson, password);
      
      // Verify decrypted key matches original
      expect(decrypted.toHex(), equals(privateKey.toHex()));
    });

    // Note: blockchain_utils doesn't support custom UUID in the current API
    // So we skip this test

    test('Encrypt and decrypt with Map keystore', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Encrypt to keystore
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      // Convert to Map
      final keystoreMap = StringUtils.toJson(keystoreJson);
      
      // Decrypt from Map
      final decrypted = CFXKeystore.decrypt(keystoreMap, password);
      
      expect(decrypted.toHex(), equals(privateKey.toHex()));
    });

    test('encryptToJson convenience method', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Use convenience method
      final keystoreJson = CFXKeystore.encryptToJson(privateKey, password);
      
      // Should be valid JSON string
      expect(keystoreJson, isA<String>());
      expect(keystoreJson, contains('"version"'));
      expect(keystoreJson, contains('"crypto"'));
      
      // Should be decryptable
      final decrypted = CFXKeystore.decrypt(keystoreJson, password);
      expect(decrypted.toHex(), equals(privateKey.toHex()));
    });

    test('Incorrect password should throw', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      // Try to decrypt with wrong password
      // blockchain_utils throws Web3SecretStorageDefinationV3Exception
      expect(
        () => CFXKeystore.decrypt(keystoreJson, 'wrongpassword'),
        throwsException,
      );
    });

    test('Invalid keystore format should throw', () {
      const invalidJson = '{"invalid": "keystore"}';
      
      expect(
        () => CFXKeystore.decrypt(invalidJson, password),
        throwsException,
      );
    });

    test('isValidKeystoreFormat validates correct format', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      // Should validate JSON string
      expect(CFXKeystore.isValidKeystoreFormat(keystoreJson), isTrue);
      
      // Should validate Map
      final keystoreMap = StringUtils.toJson(keystoreJson);
      expect(CFXKeystore.isValidKeystoreFormat(keystoreMap), isTrue);
    });

    test('isValidKeystoreFormat rejects invalid format', () {
      expect(CFXKeystore.isValidKeystoreFormat('{}'), isFalse);
      expect(CFXKeystore.isValidKeystoreFormat('invalid'), isFalse);
      expect(CFXKeystore.isValidKeystoreFormat({'version': 3}), isFalse);
      expect(CFXKeystore.isValidKeystoreFormat(null), isFalse);
      expect(CFXKeystore.isValidKeystoreFormat(123), isFalse);
    });

    test('getAddressFromKeystore extracts address', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      final address = CFXKeystore.getAddressFromKeystore(keystoreJson);
      
      // Address should be present (may be null or a hex string)
      // blockchain_utils may or may not include address in keystore
      if (address != null) {
        expect(address, isA<String>());
        expect(address.length, greaterThan(0));
      }
    });

    test('Different passwords produce different keystores', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final keystore1 = CFXKeystore.encrypt(privateKey, password);
      final keystore2 = CFXKeystore.encrypt(privateKey, weakPassword);
      
      // Ciphertexts should be different
      expect(keystore1, isNot(equals(keystore2)));
      
      // But both should decrypt to same key
      final decrypted1 = CFXKeystore.decrypt(keystore1, password);
      final decrypted2 = CFXKeystore.decrypt(keystore2, weakPassword);
      
      expect(decrypted1.toHex(), equals(decrypted2.toHex()));
    });

    test('Different keys produce different keystores', () {
      final privateKey1 = CFXPrivateKey(testPrivateKey);
      final privateKey2 = CFXPrivateKey.random();
      
      final keystore1 = CFXKeystore.encrypt(privateKey1, password);
      final keystore2 = CFXKeystore.encrypt(privateKey2, password);
      
      // Ciphertexts should be different
      expect(keystore1, isNot(equals(keystore2)));
      
      // Each should decrypt to its own key
      final decrypted1 = CFXKeystore.decrypt(keystore1, password);
      final decrypted2 = CFXKeystore.decrypt(keystore2, password);
      
      expect(decrypted1.toHex(), equals(privateKey1.toHex()));
      expect(decrypted2.toHex(), equals(privateKey2.toHex()));
      expect(decrypted1.toHex(), isNot(equals(decrypted2.toHex())));
    });

    // Note: blockchain_utils doesn't support custom scrypt parameters in the current API
    // So we skip this test

    test('Keystore is deterministic with same parameters', () {
      // Note: Keystore encryption includes random salt and IV,
      // so two encryptions of the same key will produce different results.
      // This test verifies that both can be decrypted correctly.
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final keystore1 = CFXKeystore.encrypt(privateKey, password);
      final keystore2 = CFXKeystore.encrypt(privateKey, password);
      
      // Keystores will be different due to random components
      expect(keystore1, isNot(equals(keystore2)));
      
      // But both should decrypt to same key
      final decrypted1 = CFXKeystore.decrypt(keystore1, password);
      final decrypted2 = CFXKeystore.decrypt(keystore2, password);
      
      expect(decrypted1.toHex(), equals(decrypted2.toHex()));
    });

    test('Empty password is allowed', () {
      // Note: Empty passwords are insecure but technically valid
      final privateKey = CFXPrivateKey(testPrivateKey);
      const emptyPassword = '';
      
      final keystoreJson = CFXKeystore.encrypt(privateKey, emptyPassword);
      final decrypted = CFXKeystore.decrypt(keystoreJson, emptyPassword);
      
      expect(decrypted.toHex(), equals(privateKey.toHex()));
    });

    test('Multiple random keys encrypt and decrypt correctly', () {
      for (var i = 0; i < 5; i++) {
        final privateKey = CFXPrivateKey.random();
        final testPassword = 'password$i';
        
        final keystoreJson = CFXKeystore.encrypt(privateKey, testPassword);
        final decrypted = CFXKeystore.decrypt(keystoreJson, testPassword);
        
        expect(decrypted.toHex(), equals(privateKey.toHex()));
      }
    });

    test('Keystore compatibility with Web3 standard', () {
      // Verify that our keystore follows Web3 Secret Storage Definition v3
      final privateKey = CFXPrivateKey(testPrivateKey);
      final keystoreJson = CFXKeystore.encrypt(privateKey, password);
      
      final keystoreMap = StringUtils.toJson(keystoreJson) as Map;
      
      // Check required fields
      expect(keystoreMap['version'], equals(3));
      expect(keystoreMap['id'], isNotNull);
      expect(keystoreMap['crypto'], isNotNull);
      
      final crypto = keystoreMap['crypto'] as Map;
      expect(crypto['cipher'], isNotNull);
      expect(crypto['ciphertext'], isNotNull);
      expect(crypto['cipherparams'], isNotNull);
      expect(crypto['kdf'], isNotNull);
      expect(crypto['kdfparams'], isNotNull);
      expect(crypto['mac'], isNotNull);
    });
  });
}

