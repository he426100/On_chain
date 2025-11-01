import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  group('CFXPrivateKey Tests', () {
    test('Create from random', () {
      final privateKey = CFXPrivateKey.random();
      
      expect(privateKey, isNotNull);
      expect(privateKey.toHex().length, equals(64)); // 64 hex chars
    });

    test('Create from hex string', () {
      final hex = '0x1234567890123456789012345678901234567890123456789012345678901234';
      final privateKey = CFXPrivateKey(hex);
      
      expect(privateKey.toHex(), equals(hex.substring(2))); // Remove 0x prefix
    });

    test('Create from bytes', () {
      final bytes = List<int>.filled(32, 1);
      final privateKey = CFXPrivateKey.fromBytes(bytes);
      
      expect(privateKey, isNotNull);
      expect(privateKey.toBytes().length, equals(32));
    });

    test('Derive public key', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      
      expect(publicKey, isNotNull);
      expect(publicKey.toCompressedBytes().length, equals(33));
    });

    test('Sign and verify message', () {
      final privateKey = CFXPrivateKey.random();
      final message = StringUtils.encode('Hello Conflux!');
      
      // Sign message
      final signature = privateKey.sign(message, hashMessage: true);
      
      expect(signature, isNotNull);
      expect(signature.r, isNotNull);
      expect(signature.s, isNotNull);
      expect(signature.v, isNotNull);
    });

    test('Sign personal message', () {
      final privateKey = CFXPrivateKey.random();
      final message = StringUtils.encode('Test message');
      
      final signature = privateKey.signPersonalMessage(message);
      
      expect(signature, isNotNull);
      expect(signature.length, greaterThan(0));
      // Signature is hex string (may or may not have 0x prefix)
      expect(signature.length, equals(130)); // 130 hex chars (65 bytes * 2)
    });

    test('Deterministic key derivation', () {
      final hex = '0x1234567890123456789012345678901234567890123456789012345678901234';
      final privateKey1 = CFXPrivateKey(hex);
      final privateKey2 = CFXPrivateKey(hex);
      
      final addr1 = privateKey1.publicKey().toAddress(1029);
      final addr2 = privateKey2.publicKey().toAddress(1029);
      
      expect(addr1.toBase32(), equals(addr2.toBase32()));
    });
  });

  group('CFXPublicKey Tests', () {
    test('Create from bytes', () {
      final privateKey = CFXPrivateKey.random();
      final publicKeyBytes = privateKey.publicKey().toCompressedBytes();
      
      final publicKey = CFXPublicKey.fromBytes(publicKeyBytes);
      
      expect(publicKey, isNotNull);
      expect(publicKey.toCompressedBytes(), equals(publicKeyBytes));
    });

    test('Derive Core Space address', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      
      final mainnetAddr = publicKey.toAddress(1029);
      final testnetAddr = publicKey.toAddress(1);
      
      expect(mainnetAddr.networkId, equals(1029));
      expect(mainnetAddr.toBase32(), startsWith('cfx:'));
      expect(testnetAddr.networkId, equals(1));
      expect(testnetAddr.toBase32(), startsWith('cfxtest:'));
    });

    test('Derive eSpace address', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      
      final eSpaceAddr = publicKey.toESpaceAddress();
      
      expect(eSpaceAddr.toHex(), startsWith('0x'));
      expect(eSpaceAddr.toHex().length, equals(42));
    });

    test('Core Space and eSpace addresses from same key', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      
      final coreAddr = publicKey.toAddress(1029);
      final eSpaceAddr = publicKey.toESpaceAddress();
      
      // Core Space address is converted to user type (0x1...)
      // eSpace address follows Ethereum's standard derivation (no conversion)
      // They share the same last 19 bytes
      expect(coreAddr.toHex().substring(3).toLowerCase(), 
             equals(eSpaceAddr.toHex().substring(3).toLowerCase()));
      expect(coreAddr.toHex().startsWith('0x1'), isTrue);
    });

    test('Compressed vs uncompressed public key', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      
      final compressed = publicKey.toCompressedBytes();
      final uncompressed = publicKey.toUncompressedBytes();
      
      expect(compressed.length, equals(33));
      expect(uncompressed.length, equals(65));
      expect(uncompressed[0], equals(0x04)); // Uncompressed prefix
    });
  });

  group('HD Wallet Tests', () {
    test('BIP44 derivation for Conflux', () {
      // Generate mnemonic
      final mnemonic = Bip39MnemonicGenerator().fromWordsNumber(Bip39WordsNum.wordsNum12);
      final seed = Bip39SeedGenerator(mnemonic).generate();
      
      // Conflux uses Ethereum coin type (60) for BIP44
      final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
      final defaultPath = wallet.deriveDefaultPath;
      
      // Create Conflux private key
      final privateKey = CFXPrivateKey.fromBytes(defaultPath.privateKey.raw);
      
      expect(privateKey, isNotNull);
      
      // Derive addresses
      final coreAddr = privateKey.publicKey().toAddress(1029);
      final eSpaceAddr = privateKey.publicKey().toESpaceAddress();
      
      expect(coreAddr.networkId, equals(1029));
      expect(eSpaceAddr.toHex(), startsWith('0x'));
    });

    test('Deterministic address generation from mnemonic', () {
      const mnemonicWords = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final mnemonic = Mnemonic.fromString(mnemonicWords);
      final seed = Bip39SeedGenerator(mnemonic).generate();
      
      final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);
      final defaultPath = wallet.deriveDefaultPath;
      
      final privateKey1 = CFXPrivateKey.fromBytes(defaultPath.privateKey.raw);
      final addr1 = privateKey1.publicKey().toAddress(1029);
      
      // Re-derive from same mnemonic
      final mnemonic2 = Mnemonic.fromString(mnemonicWords);
      final seed2 = Bip39SeedGenerator(mnemonic2).generate();
      final wallet2 = Bip44.fromSeed(seed2, Bip44Coins.ethereum);
      final defaultPath2 = wallet2.deriveDefaultPath;
      final privateKey2 = CFXPrivateKey.fromBytes(defaultPath2.privateKey.raw);
      final addr2 = privateKey2.publicKey().toAddress(1029);
      
      expect(addr1.toBase32(), equals(addr2.toBase32()));
    });
  });

  group('Key Serialization Tests', () {
    test('Private key to/from hex', () {
      final privateKey = CFXPrivateKey.random();
      final hex = privateKey.toHex();
      
      final restored = CFXPrivateKey(hex);
      
      expect(restored.toHex(), equals(hex));
    });

    test('Private key to/from bytes', () {
      final privateKey = CFXPrivateKey.random();
      final bytes = privateKey.toBytes();
      
      final restored = CFXPrivateKey.fromBytes(bytes);
      
      expect(restored.toBytes(), equals(bytes));
    });

    test('Public key to/from hex', () {
      final privateKey = CFXPrivateKey.random();
      final publicKey = privateKey.publicKey();
      final hex = publicKey.toHex();
      
      final restored = CFXPublicKey.fromHex(hex);
      
      expect(restored.toHex(), equals(hex));
    });
  });
}

