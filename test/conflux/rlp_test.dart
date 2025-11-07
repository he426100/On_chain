import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/src/rlp/encode.dart';
import 'package:on_chain/ethereum/src/rlp/decode.dart';

/// 这些测试用例直接迁移自 js-conflux-sdk/test/util/rlp.test.js
/// 确保我们的 RLP 实现与 JavaScript SDK 完全兼容
void main() {
  group('RLP Encoding Tests', () {
    test('should encode zero', () {
      final value = BigintUtils.toBytes(BigInt.zero, length: 1);
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x80'));
    });

    test('should encode single byte number', () {
      final value = BigintUtils.toBytes(BigInt.one, length: 1);
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x01'));
    });

    test('should encode big endian number', () {
      final value = BigintUtils.toBytes(BigInt.from(1024), length: 2);
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x820400'));
    });

    test('should encode empty buffer', () {
      final value = <int>[];
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x80'));
    });

    test('should encode short buffer', () {
      final value = StringUtils.encode('dog');
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x83646f67'));
    });

    test('should encode long buffer', () {
      // Create a buffer of 1024 empty arrays
      final value = List<int>.filled(1024, 0);
      final encoded = RLPEncoder.encode(value);
      final prefix = BytesUtils.toHexString(encoded.sublist(0, 3), prefix: '0x');
      expect(prefix, equals('0xb90400'));
    });

    test('should encode empty array', () {
      final value = <List<int>>[];
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0xc0'));
    });

    test('should encode short array', () {
      final value = [
        StringUtils.encode('cat'),
        [0],
        StringUtils.encode('dog'),
      ];
      final encoded = RLPEncoder.encode(value);
      expect(
        BytesUtils.toHexString(encoded, prefix: '0x'),
        equals('0xc9836361748083646f67'),
      );
    });

    test('should encode long array', () {
      // Create an array of 1024 empty arrays
      final value = List.generate(1024, (_) => <int>[]);
      final encoded = RLPEncoder.encode(value);
      final prefix = BytesUtils.toHexString(encoded.sublist(0, 3), prefix: '0x');
      expect(prefix, equals('0xf90400'));
    });

    test('should encode nested array', () {
      final value = [
        <int>[],
        [<int>[]],
        [<int>[], [<int>[]]]
      ];
      final encoded = RLPEncoder.encode(value);
      expect(
        BytesUtils.toHexString(encoded, prefix: '0x'),
        equals('0xc7c0c1c0c3c0c1c0'),
      );
    });
  });

  group('RLP Decoding Tests', () {
    test('should decode zero', () {
      final encoded = BytesUtils.fromHexString('0x80');
      final decoded = RLPDecoder.decode(encoded);
      expect(decoded, equals([]));
    });

    test('should decode single byte', () {
      final encoded = BytesUtils.fromHexString('0x01');
      final decoded = RLPDecoder.decode(encoded);
      expect(decoded, equals([1]));
    });

    test('should decode short string', () {
      final encoded = BytesUtils.fromHexString('0x83646f67');
      final decoded = RLPDecoder.decode(encoded);
      expect(StringUtils.decode(decoded), equals('dog'));
    });

    test('should decode empty array', () {
      final encoded = BytesUtils.fromHexString('0xc0');
      final decoded = RLPDecoder.decode(encoded);
      expect(decoded, equals([]));
    });

    test('should decode short array', () {
      final encoded = BytesUtils.fromHexString('0xc9836361748083646f67');
        final decoded = RLPDecoder.decode(encoded) as List;
      
      expect(decoded.length, equals(3));
      expect(StringUtils.decode(decoded[0]), equals('cat'));
      expect(decoded[1], equals([0]));
      expect(StringUtils.decode(decoded[2]), equals('dog'));
    });

    test('should decode nested array', () {
      final encoded = BytesUtils.fromHexString('0xc7c0c1c0c3c0c1c0');
        final decoded = RLPDecoder.decode(encoded) as List;
      
      expect(decoded.length, equals(3));
      expect(decoded[0], equals([]));
      expect((decoded[1] as List).length, equals(1));
      expect((decoded[2] as List).length, equals(2));
    });
  });

  group('RLP Round-trip Tests', () {
    test('should encode and decode correctly', () {
      final testData = [
        <int>[],
        [1, 2, 3],
        StringUtils.encode('hello'),
        [
          StringUtils.encode('test'),
          [1, 2, 3],
        ],
      ];

      for (final data in testData) {
        final encoded = RLP.encode(data);
        final decoded = RLPDecoder.decode(encoded);
        
        // Note: decoded result structure might differ, but encoded result should match
        final reEncoded = RLP.encode(decoded);
        expect(reEncoded, equals(encoded));
      }
    });
  });

  group('RLP Special Cases', () {
    test('should handle maximum single byte', () {
      final value = [0x7f];
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x7f'));
    });

    test('should handle minimum two-byte encoding', () {
      final value = [0x80];
      final encoded = RLPEncoder.encode(value);
      expect(BytesUtils.toHexString(encoded, prefix: '0x'), equals('0x8180'));
    });

    test('should handle 55-byte string', () {
      final value = List<int>.filled(55, 0x61); // 55 'a' characters
      final encoded = RLPEncoder.encode(value);
      final decoded = RLPDecoder.decode(encoded);
      expect(decoded, equals(value));
    });

    test('should handle 56-byte string', () {
      final value = List<int>.filled(56, 0x61); // 56 'a' characters
      final encoded = RLPEncoder.encode(value);
      final decoded = RLPDecoder.decode(encoded);
      expect(decoded, equals(value));
    });

    test('should handle large numbers', () {
      final largeNum = BigInt.parse('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', radix: 16);
      final value = BigintUtils.toBytes(largeNum, length: 32);
      final encoded = RLPEncoder.encode(value);
      final decoded = RLPDecoder.decode(encoded);
      final decodedNum = BigintUtils.fromBytes(decoded);
      expect(decodedNum, equals(largeNum));
    });
  });
}

