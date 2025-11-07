import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// Personal message signing tests
/// 
/// 来自 js-conflux-sdk/test/message.test.js
void main() {
  group('Personal Message Signing Tests', () {
    // Test data from js-conflux-sdk
    const privateKeyHex = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const networkId = 1;

    test('Sign and recover personal message (string)', () {
      // 来自 message.test.js: new Message(string)
      final privateKey = CFXPrivateKey(privateKeyHex);
      const message = 'Hello World';
      final messageBytes = StringUtils.encode(message);
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(messageBytes);
      
      // Signature should be 130 characters (65 bytes hex)
      expect(signature.length, equals(130));
      expect(signature.startsWith('0x'), isFalse); // Should not have 0x prefix
      
      // Recover public key from signature
      final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
        messageBytes,
        signature,
      );
      
      // Verify recovered public key matches original
      final originalPublicKey = privateKey.publicKey();
      expect(
        recoveredPublicKey.toHex(),
        equals(originalPublicKey.toHex()),
      );
      
      // Verify address matches
      final recoveredAddress = recoveredPublicKey.toAddress(networkId);
      final originalAddress = originalPublicKey.toAddress(networkId);
      expect(
        recoveredAddress.toBase32(),
        equals(originalAddress.toBase32()),
      );
    });

    test('Sign and recover personal message (bytes)', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      final messageBytes = BytesUtils.fromHexString('0x1234567890abcdef');
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(messageBytes);
      
      // Recover and verify
      final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
        messageBytes,
        signature,
      );
      
      final originalPublicKey = privateKey.publicKey();
      expect(
        recoveredPublicKey.toHex(),
        equals(originalPublicKey.toHex()),
      );
    });

    test('Sign and recover personal message (empty)', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      final messageBytes = <int>[];
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(messageBytes);
      
      // Recover and verify
      final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
        messageBytes,
        signature,
      );
      
      final originalPublicKey = privateKey.publicKey();
      expect(
        recoveredPublicKey.toHex(),
        equals(originalPublicKey.toHex()),
      );
    });

    test('Sign and recover personal message (UTF-8)', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      const message = '你好世界 🌍';
      final messageBytes = StringUtils.encode(message);
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(messageBytes);
      
      // Recover and verify
      final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
        messageBytes,
        signature,
      );
      
      final originalPublicKey = privateKey.publicKey();
      expect(
        recoveredPublicKey.toHex(),
        equals(originalPublicKey.toHex()),
      );
    });

    test('Sign and recover with 0x prefixed signature', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      const message = 'Test';
      final messageBytes = StringUtils.encode(message);
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(messageBytes);
      
      // Add 0x prefix
      final prefixedSignature = '0x$signature';
      
      // Should still be able to recover with 0x prefix
      final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
        messageBytes,
        prefixedSignature,
      );
      
      final originalPublicKey = privateKey.publicKey();
      expect(
        recoveredPublicKey.toHex(),
        equals(originalPublicKey.toHex()),
      );
    });

    test('Deterministic signature', () {
      // Same message and key should produce same signature
      final privateKey = CFXPrivateKey(privateKeyHex);
      const message = 'Deterministic test';
      final messageBytes = StringUtils.encode(message);
      
      final signature1 = privateKey.signPersonalMessage(messageBytes);
      final signature2 = privateKey.signPersonalMessage(messageBytes);
      
      expect(signature1, equals(signature2));
    });

    test('Different messages produce different signatures', () {
      final privateKey = CFXPrivateKey(privateKeyHex);
      final message1 = StringUtils.encode('Message 1');
      final message2 = StringUtils.encode('Message 2');
      
      final signature1 = privateKey.signPersonalMessage(message1);
      final signature2 = privateKey.signPersonalMessage(message2);
      
      expect(signature1, isNot(equals(signature2)));
    });

    test('Different keys produce different signatures', () {
      final privateKey1 = CFXPrivateKey(privateKeyHex);
      final privateKey2 = CFXPrivateKey.random();
      final messageBytes = StringUtils.encode('Same message');
      
      final signature1 = privateKey1.signPersonalMessage(messageBytes);
      final signature2 = privateKey2.signPersonalMessage(messageBytes);
      
      expect(signature1, isNot(equals(signature2)));
    });

    test('Invalid signature length should throw', () {
      final messageBytes = StringUtils.encode('Test');
      
      // Too short
      expect(
        () => CFXPublicKey.recoverFromPersonalMessage(messageBytes, 'abc'),
        throwsArgumentError,
      );
      
      // Too long
      expect(
        () => CFXPublicKey.recoverFromPersonalMessage(
          messageBytes,
          '0x${'00' * 66}',
        ),
        throwsArgumentError,
      );
    });

    test('Multiple random keys sign and recover correctly', () {
      const message = 'Random key test';
      final messageBytes = StringUtils.encode(message);
      
      for (var i = 0; i < 10; i++) {
        final privateKey = CFXPrivateKey.random();
        final signature = privateKey.signPersonalMessage(messageBytes);
        
        final recoveredPublicKey = CFXPublicKey.recoverFromPersonalMessage(
          messageBytes,
          signature,
        );
        
        expect(
          recoveredPublicKey.toHex(),
          equals(privateKey.publicKey().toHex()),
        );
      }
    });
  });
}

