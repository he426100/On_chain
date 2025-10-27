import 'dart:convert';
import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Signature Verification Tests', () {
    // Test vectors from wallet-core and iso-filecoin
    late FilPrivateKey privateKey;
    late FilPublicKey publicKey;
    late FilecoinAddress secp256k1Address;
    late List<int> testMessage;

    setUp(() {
      // Use a known test private key
      final keyBytes = List<int>.generate(32, (i) => i + 1);
      privateKey = FilPrivateKey(keyBytes);
      publicKey = privateKey.publicKey();
      secp256k1Address = privateKey.toSecp256k1Address();
      testMessage = utf8.encode('test message for signature verification');
    });

    test('FilPublicKey.verify() should correctly verify valid signature', () {
      // Sign the message
      final hash = QuickCrypto.blake2b256Hash(testMessage);
      final signature = privateKey.sign(hash);

      // Verify signature length
      expect(signature.length, equals(65), reason: 'Signature should be 65 bytes');

      // Verify with correct public key should succeed
      final isValid = publicKey.verify(hash, signature);
      expect(isValid, isTrue, reason: 'Valid signature should verify successfully');
    });

    test('FilPublicKey.verify() should reject invalid signature', () {
      final hash = QuickCrypto.blake2b256Hash(testMessage);
      final signature = privateKey.sign(hash);

      // Tamper with the signature
      final tamperedSignature = List<int>.from(signature);
      tamperedSignature[0] = (tamperedSignature[0] + 1) % 256;

      // Verification should fail
      final isValid = publicKey.verify(hash, tamperedSignature);
      expect(isValid, isFalse, reason: 'Tampered signature should fail verification');
    });

    test('FilPublicKey.verify() should reject wrong public key', () {
      final hash = QuickCrypto.blake2b256Hash(testMessage);
      final signature = privateKey.sign(hash);

      // Create a different key pair
      final wrongKeyBytes = List<int>.generate(32, (i) => i + 100);
      final wrongPrivateKey = FilPrivateKey(wrongKeyBytes);
      final wrongPublicKey = wrongPrivateKey.publicKey();

      // Verification with wrong public key should fail
      final isValid = wrongPublicKey.verify(hash, signature);
      expect(isValid, isFalse, reason: 'Wrong public key should fail verification');
    });

    test('FilPublicKey.verify() should reject wrong message', () {
      final hash = QuickCrypto.blake2b256Hash(testMessage);
      final signature = privateKey.sign(hash);

      // Sign a different message
      final wrongMessage = utf8.encode('different message');
      final wrongHash = QuickCrypto.blake2b256Hash(wrongMessage);

      // Verification should fail
      final isValid = publicKey.verify(wrongHash, signature);
      expect(isValid, isFalse, reason: 'Signature for different message should fail verification');
    });

    test('FilPublicKey.verify() should reject invalid signature length', () {
      final hash = QuickCrypto.blake2b256Hash(testMessage);

      // Test with wrong length signatures
      expect(publicKey.verify(hash, List<int>.filled(64, 0)), isFalse,
          reason: 'Should reject 64-byte signature');
      expect(publicKey.verify(hash, List<int>.filled(66, 0)), isFalse,
          reason: 'Should reject 66-byte signature');
      expect(publicKey.verify(hash, List<int>.filled(0, 0)), isFalse,
          reason: 'Should reject empty signature');
    });

    test('FilecoinWallet.verify() should correctly verify valid signature', () {
      // Create signature using FilecoinWallet.sign()
      final signature = FilecoinWallet.sign(
        privateKey: privateKey.bytes,
        type: FilecoinSignatureType.secp256k1,
        data: testMessage,
      );

      // Verify using FilecoinWallet.verify()
      final isValid = FilecoinWallet.verify(
        publicKey: publicKey.bytes,
        data: testMessage,
        signature: signature,
      );

      expect(isValid, isTrue, reason: 'Valid signature should verify successfully');
    });

    test('FilecoinWallet.verify() should reject tampered signature', () {
      final signature = FilecoinWallet.sign(
        privateKey: privateKey.bytes,
        type: FilecoinSignatureType.secp256k1,
        data: testMessage,
      );

      // Tamper with signature data
      final tamperedData = List<int>.from(signature.data);
      tamperedData[10] = (tamperedData[10] + 1) % 256;

      final tamperedSignature = FilecoinSignature(
        type: signature.type,
        data: tamperedData,
      );

      final isValid = FilecoinWallet.verify(
        publicKey: publicKey.bytes,
        data: testMessage,
        signature: tamperedSignature,
      );

      expect(isValid, isFalse, reason: 'Tampered signature should fail verification');
    });

    test('FilecoinWallet.verify() should work with different message sizes', () {
      // Test with various message sizes
      final messages = [
        utf8.encode('a'), // 1 byte
        utf8.encode('hello'), // 5 bytes
        utf8.encode('a' * 100), // 100 bytes
        utf8.encode('a' * 1000), // 1000 bytes
      ];

      for (final message in messages) {
        final signature = FilecoinWallet.sign(
          privateKey: privateKey.bytes,
          type: FilecoinSignatureType.secp256k1,
          data: message,
        );

        final isValid = FilecoinWallet.verify(
          publicKey: publicKey.bytes,
          data: message,
          signature: signature,
        );

        expect(isValid, isTrue, reason: 'Should verify message of size ${message.length}');
      }
    });

    test('FilecoinWallet.personalSign() and personalVerify() should work correctly', () {
      // Test FRC-102 personal sign
      final personalSignature = FilecoinWallet.personalSign(
        privateKey: privateKey.bytes,
        type: FilecoinSignatureType.secp256k1,
        data: testMessage,
      );

      final isValid = FilecoinWallet.personalVerify(
        publicKey: publicKey.bytes,
        data: testMessage,
        signature: personalSignature,
      );

      expect(isValid, isTrue, reason: 'Personal signature should verify successfully');
    });

    test('FilecoinWallet.personalVerify() should reject non-personal signature', () {
      // Create a regular signature
      final regularSignature = FilecoinWallet.sign(
        privateKey: privateKey.bytes,
        type: FilecoinSignatureType.secp256k1,
        data: testMessage,
      );

      // Try to verify it as a personal signature (should fail)
      final isValid = FilecoinWallet.personalVerify(
        publicKey: publicKey.bytes,
        data: testMessage,
        signature: regularSignature,
      );

      expect(isValid, isFalse, reason: 'Regular signature should fail personal verification');
    });

    test('FilecoinSigner.verify() should work correctly', () {
      // Create a transaction
      final signer = FilecoinSigner(privateKey);
      final toAddress = FilecoinAddress.fromString('f1abjxfbp274xpdqcpuaykwkfb43omjotacm2p3za');

      final transaction = FilecoinTransaction(
        to: toAddress,
        from: secp256k1Address,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 100000,
        gasFeeCap: BigInt.from(1000),
        gasPremium: BigInt.from(500),
      );

      // Sign the transaction
      final signedTx = signer.sign(transaction);

      // Verify the signature
      final isValid = signer.verify(
        transaction: transaction,
        signature: signedTx.signature,
      );

      expect(isValid, isTrue, reason: 'Transaction signature should verify successfully');
    });

    test('FilecoinSigner.verify() should reject tampered transaction', () {
      final signer = FilecoinSigner(privateKey);
      final toAddress = FilecoinAddress.fromString('f1abjxfbp274xpdqcpuaykwkfb43omjotacm2p3za');

      final transaction = FilecoinTransaction(
        to: toAddress,
        from: secp256k1Address,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 100000,
        gasFeeCap: BigInt.from(1000),
        gasPremium: BigInt.from(500),
      );

      final signedTx = signer.sign(transaction);

      // Create a tampered transaction (different value)
      final tamperedTx = FilecoinTransaction(
        to: toAddress,
        from: secp256k1Address,
        nonce: 0,
        value: BigInt.from(2000000), // Changed!
        gasLimit: 100000,
        gasFeeCap: BigInt.from(1000),
        gasPremium: BigInt.from(500),
      );

      // Verify should fail with tampered transaction
      final isValid = signer.verify(
        transaction: tamperedTx,
        signature: signedTx.signature,
      );

      expect(isValid, isFalse, reason: 'Tampered transaction should fail verification');
    });

    test('Multiple sign/verify cycles should work consistently', () {
      // Test multiple iterations to ensure consistency
      for (var i = 0; i < 10; i++) {
        final message = utf8.encode('test message $i');
        final hash = QuickCrypto.blake2b256Hash(message);
        final signature = privateKey.sign(hash);
        
        final isValid = publicKey.verify(hash, signature);
        expect(isValid, isTrue, reason: 'Iteration $i should verify successfully');
      }
    });

    test('Cross-verification between FilPublicKey and FilecoinWallet', () {
      // Sign with FilPrivateKey
      final hash = QuickCrypto.blake2b256Hash(testMessage);
      final signature1 = privateKey.sign(hash);

      // Sign with FilecoinWallet
      final signature2 = FilecoinWallet.sign(
        privateKey: privateKey.bytes,
        type: FilecoinSignatureType.secp256k1,
        data: testMessage,
      );

      // Both should verify with both methods
      expect(publicKey.verify(hash, signature1), isTrue);
      expect(publicKey.verify(hash, signature2.data), isTrue);
      
      final filSignature1 = FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: signature1,
      );
      
      expect(
        FilecoinWallet.verify(
          publicKey: publicKey.bytes,
          data: testMessage,
          signature: filSignature1,
        ),
        isTrue,
      );
      expect(
        FilecoinWallet.verify(
          publicKey: publicKey.bytes,
          data: testMessage,
          signature: signature2,
        ),
        isTrue,
      );
    });
  });

  group('Edge Cases and Error Handling', () {
    test('Should handle all-zero signature gracefully', () {
      final keyBytes = List<int>.generate(32, (i) => i + 1);
      final privateKey = FilPrivateKey(keyBytes);
      final publicKey = privateKey.publicKey();
      
      final hash = QuickCrypto.blake2b256Hash(utf8.encode('test'));
      final zeroSignature = List<int>.filled(65, 0);
      
      // Should return false, not throw
      expect(publicKey.verify(hash, zeroSignature), isFalse);
    });

    test('Should handle malformed signature data', () {
      final keyBytes = List<int>.generate(32, (i) => i + 1);
      final publicKey = FilPrivateKey(keyBytes).publicKey();
      final hash = QuickCrypto.blake2b256Hash(utf8.encode('test'));
      
      // Various malformed signatures
      final malformed = [
        List<int>.generate(65, (i) => 255), // All 0xFF
        List<int>.generate(65, (i) => i), // Sequential
        [0xFF, ...List<int>.filled(64, 0)], // Invalid r value
      ];
      
      for (final sig in malformed) {
        expect(publicKey.verify(hash, sig), isFalse,
            reason: 'Should handle malformed signature gracefully');
      }
    });
  });
}

