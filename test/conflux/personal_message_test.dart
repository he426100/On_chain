import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// 这些测试用例直接迁移自 js-conflux-sdk/test/personalMessage.test.js
/// 确保我们的 Dart 实现与 JavaScript SDK 完全兼容
void main() {
  const testPrivateKey = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const testPublicKey = '0x4646ae5047316b4230d0086c8acec687f00b1cd9d1dc634f6cb358ac0a9a8ffffe77b4dd0a4bfb95851f3b7355c781dd60f8418fc8a65d14907aff47c903a559';
  const testAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
  const networkId = 1;
  const message = 'Hello World';

  group('Personal Message Signing', () {
    test('should sign personal message correctly', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(
        StringUtils.encode(message),
      );
      
      // Verify signature format (130 chars = 0x + 65 bytes hex)
      expect(signature.length, equals(130));
      expect(signature.startsWith('0x'), isTrue);
      
      // Verify against known signature from js-conflux-sdk
      const expectedSignature = '0xd72ea2020802d6dfce0d49fc1d92a16b43baa58fc152d6f437d852a014e0c5740b3563375b0b844a835be4f1521b4ae2a691048622f70026e0470acc5351043a01';
      expect(signature, equals(expectedSignature));
    });

    test('should recover correct address from signature', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Sign the message
      final signature = privateKey.signPersonalMessage(
        StringUtils.encode(message),
      );
      
      // Recover public key from signature
      final recovered = recoverPersonalMessagePublicKey(signature, message);
      
      expect(recovered, equals(testPublicKey));
    });

    test('should recover correct address for different messages', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final messages = [
        'Hello World',
        'Test Message',
        '1234567890',
        'Special chars: !@#\$%^&*()',
      ];
      
      for (final msg in messages) {
        final signature = privateKey.signPersonalMessage(
          StringUtils.encode(msg),
        );
        final recovered = recoverPersonalMessagePublicKey(signature, msg);
        
        expect(recovered, equals(testPublicKey),
            reason: 'Failed to recover for message: $msg');
      }
    });

    test('should handle empty message', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final signature = privateKey.signPersonalMessage([]);
      
      // Should not throw, should return valid signature
      expect(signature.length, equals(130));
      expect(signature.startsWith('0x'), isTrue);
    });

    test('should handle binary message', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Binary message with various bytes
      final binaryMessage = List<int>.generate(256, (i) => i % 256);
      
      final signature = privateKey.signPersonalMessage(binaryMessage);
      
      expect(signature.length, equals(130));
      expect(signature.startsWith('0x'), isTrue);
    });

    test('should produce different signatures for different messages', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final sig1 = privateKey.signPersonalMessage(
        StringUtils.encode('Message 1'),
      );
      final sig2 = privateKey.signPersonalMessage(
        StringUtils.encode('Message 2'),
      );
      
      expect(sig1, isNot(equals(sig2)));
    });

    test('should produce same signature for same message', () {
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final sig1 = privateKey.signPersonalMessage(
        StringUtils.encode(message),
      );
      final sig2 = privateKey.signPersonalMessage(
        StringUtils.encode(message),
      );
      
      expect(sig1, equals(sig2));
    });
  });

  group('Personal Message Format', () {
    test('should use Conflux personal message prefix', () {
      // Conflux uses: "\x19Conflux Signed Message:\n" + len(message)
      // Ethereum uses: "\x19Ethereum Signed Message:\n" + len(message)
      
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      // Sign with Conflux format
      final cfxSignature = privateKey.signPersonalMessage(
        StringUtils.encode(message),
      );
      
      // Sign with Ethereum format (for comparison)
      final ethSignature = privateKey.signESpacePersonalMessage(
        StringUtils.encode(message),
      );
      
      // Should be different due to different prefixes
      expect(cfxSignature, isNot(equals(ethSignature)));
    });
  });
}

/// Helper function to recover public key from personal message signature.
String recoverPersonalMessagePublicKey(String signature, String message) {
  // Remove 0x prefix
  final sigHex = signature.startsWith('0x') ? signature.substring(2) : signature;
  
  if (sigHex.length != 130) {
    throw ArgumentError('Invalid signature length');
  }
  
  // Parse signature components
  final r = BigInt.parse(sigHex.substring(0, 64), radix: 16);
  final s = BigInt.parse(sigHex.substring(64, 128), radix: 16);
  final v = int.parse(sigHex.substring(128, 130), radix: 16);
  
  // Create prefixed message (Conflux format)
  final messageBytes = StringUtils.encode(message);
  final prefix = '\x19Conflux Signed Message:\n${messageBytes.length}';
  final prefixBytes = StringUtils.encode(prefix);
  final fullMessage = <int>[...prefixBytes, ...messageBytes];
  
  // Hash the full message
  final messageHash = QuickCrypto.keccack256Hash(fullMessage);
  
  // Recover public key
  final verifier = Secp256k1PublicKey.fromBytes(
    QuickCrypto.recoverPublicKey(
      BigintUtils.toBytes(r, length: 32),
      BigintUtils.toBytes(s, length: 32),
      messageHash,
      v,
    ),
  );
  
  return BytesUtils.toHexString(verifier.uncompressed, prefix: '0x');
}

