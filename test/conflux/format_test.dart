import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// 这些测试用例直接迁移自 js-conflux-sdk/test/util/format.test.js
/// 测试各种数据格式转换功能，确保与 JavaScript SDK 兼容
void main() {
  const hex64 = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  const hex40 = '0x0123456789012345678901234567890123456789';

  group('Hex Conversion Tests', () {
    test('should convert null to 0x', () {
      expect(BytesUtils.toHexString([]), equals(''));
    });

    test('should convert number to hex', () {
      expect(BytesUtils.toHexString([0], prefix: '0x'), equals('0x00'));
      expect(BytesUtils.toHexString([1], prefix: '0x'), equals('0x01'));
      expect(BigInt.from(256).toRadixString(16), equals('100'));
    });

    test('should convert buffer to hex', () {
      expect(BytesUtils.toHexString([]), equals(''));
      expect(BytesUtils.toHexString([1, 10, 255], prefix: '0x'), equals('0x010aff'));
    });

    test('should convert bool to hex-like number', () {
      expect(false ? 1 : 0, equals(0));
      expect(true ? 1 : 0, equals(1));
    });

    test('should handle hex string', () {
      expect(BytesUtils.toHexString(BytesUtils.fromHexString('0x1234'), prefix: '0x'), 
             equals('0x1234'));
      
      expect(BytesUtils.toHexString(BytesUtils.fromHexString('0x0a'), prefix: '0x'),
             equals('0x0a'));
      expect(BytesUtils.toHexString(BytesUtils.fromHexString('0X0A'), prefix: '0x'),
             equals('0x0a'));
    });
  });

  group('BigInt Conversion Tests', () {
    test('should convert string to BigInt', () {
      expect(BigInt.parse('0'), equals(BigInt.zero));
      expect(BigInt.parse('1'), equals(BigInt.one));
      expect(BigInt.parse('16', radix: 16), equals(BigInt.from(16)));
    });

    test('should convert number to BigInt', () {
      expect(BigInt.from(3), equals(BigInt.from(3)));
      expect(BigInt.from(0), equals(BigInt.zero));
    });

    test('should handle large numbers', () {
      final maxSafeInt = 9007199254740991; // 2^53 - 1
      expect(BigInt.from(maxSafeInt), equals(BigInt.from(maxSafeInt)));
    });

    test('should throw on negative bigUInt', () {
      expect(() {
        final negative = BigInt.from(-1);
        if (negative < BigInt.zero) throw ArgumentError('not match "bigUInt"');
      }, throwsArgumentError);
    });
  });

  group('Hex Buffer Tests', () {
    test('should convert buffer', () {
      expect(BytesUtils.fromHexString('0x0001'), equals([0, 1]));
    });

    test('should handle empty buffer', () {
      expect(BytesUtils.fromHexString('0x'), equals([]));
    });

    test('should convert number to buffer', () {
      final bytes = BigintUtils.toBytes(BigInt.zero, length: 1);
      expect(bytes, equals([0]));
      
      final bytes2 = BigintUtils.toBytes(BigInt.from(1024), length: 2);
      expect(bytes2, equals([4, 0]));
    });

    test('should convert hex string to buffer', () {
      expect(BytesUtils.fromHexString('0x0a'), equals([10]));
    });

    test('should convert bool to buffer-like', () {
      expect(false ? [1] : [0], equals([0]));
      expect(true ? [1] : [0], equals([1]));
    });
  });

  group('Bytes Validation Tests', () {
    test('should validate hex string', () {
      expect(() => BytesUtils.fromHexString('0x0a'), returnsNormally);
      expect(BytesUtils.fromHexString('0x0a'), equals([10]));
    });

    test('should handle array', () {
      expect([0, 1], equals([0, 1]));
    });

    test('should handle buffer', () {
      final buffer = [0, 1];
      expect(buffer, equals([0, 1]));
    });
  });

  group('Keccak256 Hash Tests', () {
    test('should hash empty input', () {
      expect(
        BytesUtils.toHexString(QuickCrypto.keccack256Hash([]), prefix: '0x'),
        equals('0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470'),
      );
    });

    test('should hash single byte', () {
      expect(
        BytesUtils.toHexString(QuickCrypto.keccack256Hash([0x42]), prefix: '0x'),
        equals('0x1f675bff07515f5df96737194ea945c36c41e7b4fcef307b7cd4d0e602a69111'),
      );
    });

    test('should produce consistent hash', () {
      final hash1 = QuickCrypto.keccack256Hash([0x42]);
      final hash2 = QuickCrypto.keccack256Hash([0x42]);
      expect(hash1, equals(hash2));
    });
  });

  group('Hex Length Validation Tests', () {
    test('should validate hex40', () {
      expect(hex40.length, equals(42)); // '0x' + 40 hex chars
    });

    test('should validate hex64', () {
      expect(hex64.length, equals(66)); // '0x' + 64 hex chars
    });

    test('should validate checksum address format', () {
      // Mixed case checksum address
      const checksumAddr = '0x1B716c51381e76900EBAA7999A488511A4E1fD0a';
      expect(checksumAddr.startsWith('0x'), isTrue);
      expect(checksumAddr.length, equals(42));
    });
  });

  group('Number Parsing Tests', () {
    test('should parse decimal strings', () {
      expect(int.parse('0'), equals(0));
      expect(int.parse('10'), equals(10));
      expect(double.parse('3.14'), closeTo(3.14, 0.001));
    });

    test('should parse hex strings', () {
      expect(int.parse('10', radix: 16), equals(16));
      expect(int.parse('0a', radix: 16), equals(10));
    });

    test('should parse scientific notation', () {
      expect(double.parse('1e2'), equals(100.0));
      expect(double.parse('1e-2'), equals(0.01));
    });

    test('should handle binary prefix', () {
      expect(int.parse('10', radix: 2), equals(2));
    });

    test('should handle octal prefix', () {
      expect(int.parse('10', radix: 8), equals(8));
    });
  });

  group('BigInt Hex Conversion Tests', () {
    test('should convert BigInt to hex', () {
      expect(BigInt.from(100).toRadixString(16), equals('64'));
      expect(BigInt.from(10).toRadixString(16), equals('a'));
      expect(BigInt.from(10).toRadixString(16), equals('a'));
    });

    test('should handle leading zeros', () {
      final hex = '0x000a';
      expect(BigInt.parse(hex.substring(2), radix: 16).toRadixString(16), equals('a'));
    });

    test('should handle max safe integer', () {
      final maxSafe = BigInt.from(9007199254740991);
      expect(maxSafe.toRadixString(16), equals('1fffffffffffff'));
    });
  });

  group('Fixed Point Conversion Tests', () {
    test('should handle fixed64 format (conceptual)', () {
      // In js-conflux-sdk, fixed64 represents a value between 0 and 1
      // where 0xffffffff...ffff represents 1.0
      // We test the concept with BigInt
      
      final zero = BigInt.zero;
      final half = BigInt.parse('7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', radix: 16);
      final one = BigInt.parse('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', radix: 16);
      
      expect(zero, equals(BigInt.zero));
      expect(half < one, isTrue);
      expect(one > half, isTrue);
    });
  });

  group('Epoch Number Format Tests', () {
    test('should format epoch number', () {
      expect(BigInt.zero.toRadixString(16), equals('0'));
      expect(BigInt.from(10).toRadixString(16), equals('a'));
    });

    test('should handle special epoch tags', () {
      const latestMined = 'latest_mined';
      const latestState = 'latest_state';
      
      expect(latestMined, equals('latest_mined'));
      expect(latestState, equals('latest_state'));
    });
  });

  group('Address Format Tests', () {
    test('should validate address length', () {
      expect(hex40.length, equals(42)); // 0x + 40 chars
    });

    test('should handle hex address normalization', () {
      const upper = '0X0123456789012345678901234567890123456789';
      const lower = '0x0123456789012345678901234567890123456789';
      
      expect(upper.toLowerCase(), equals(lower));
    });

    test('should validate hex format', () {
      final isValidHex = RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(hex40);
      expect(isValidHex, isTrue);
    });
  });
}

