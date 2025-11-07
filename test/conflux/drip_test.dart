import 'package:test/test.dart';
import 'package:on_chain/conflux/src/utils/cfx_unit.dart';

/// 这些测试用例直接迁移自 js-conflux-sdk/test/drip.test.js
/// 确保我们的 Dart 实现与 JavaScript SDK 完全兼容
void main() {
  group('CFXUnit.fromCFX', () {
    test('should throw on null', () {
      expect(() => CFXUnit.fromCFX(null), throwsArgumentError);
    });

    test('should throw on negative number', () {
      expect(() => CFXUnit.fromCFX(-1), throwsA(isA<ArgumentError>()));
    });

    test('should convert decimal CFX to Drip', () {
      expect(CFXUnit.fromCFX(3.14).toString(), equals('3140000000000000000'));
    });

    test('should convert smallest CFX to Drip', () {
      expect(CFXUnit.fromCFX(1e-18).toString(), equals('1'));
    });

    test('should throw on too small value', () {
      expect(() => CFXUnit.fromCFX(1e-19), throwsA(isA<ArgumentError>()));
    });

    test('should throw on empty string', () {
      expect(() => CFXUnit.fromCFX(''), throwsArgumentError);
    });

    test('should convert string 0.0', () {
      expect(CFXUnit.fromCFX('0.0').toString(), equals('0'));
    });

    test('should convert hex string', () {
      expect(CFXUnit.fromCFX('0x0a').toString(), equals('10000000000000000000'));
    });

    test('should convert scientific notation string', () {
      expect(CFXUnit.fromCFX('1e-18').toString(), equals('1'));
    });

    test('should throw on too small scientific notation', () {
      expect(() => CFXUnit.fromCFX('1e-19'), throwsA(isA<ArgumentError>()));
    });
  });

  group('CFXUnit.fromGDrip', () {
    test('should throw on null', () {
      expect(() => CFXUnit.fromGDrip(null), throwsArgumentError);
    });

    test('should throw on negative number', () {
      expect(() => CFXUnit.fromGDrip(-1), throwsA(isA<ArgumentError>()));
    });

    test('should convert decimal GDrip to Drip', () {
      expect(CFXUnit.fromGDrip(3.14).toString(), equals('3140000000'));
    });

    test('should convert smallest GDrip to Drip', () {
      expect(CFXUnit.fromGDrip(1e-9).toString(), equals('1'));
    });

    test('should throw on too small value', () {
      expect(() => CFXUnit.fromGDrip(1e-10), throwsA(isA<ArgumentError>()));
    });

    test('should throw on empty string', () {
      expect(() => CFXUnit.fromGDrip(''), throwsArgumentError);
    });

    test('should convert string 0.0', () {
      expect(CFXUnit.fromGDrip('0.0').toString(), equals('0'));
    });

    test('should convert hex string', () {
      expect(CFXUnit.fromGDrip('0x0a').toString(), equals('10000000000'));
    });

    test('should convert scientific notation string', () {
      expect(CFXUnit.fromGDrip('1e-9').toString(), equals('1'));
    });

    test('should throw on too small scientific notation', () {
      expect(() => CFXUnit.fromGDrip('1e-10'), throwsA(isA<ArgumentError>()));
    });
  });

  group('CFXUnit constructor (Drip)', () {
    test('should convert empty string to 0', () {
      expect(CFXUnit('').toString(), equals('0'));
    });

    test('should convert string 0.0 to 0', () {
      expect(CFXUnit('0.0').toString(), equals('0'));
    });

    test('should convert hex string', () {
      expect(CFXUnit('0x0a').toString(), equals('10'));
    });

    test('should convert integer', () {
      expect(CFXUnit(100).toString(), equals('100'));
    });

    test('should work with new keyword', () {
      expect(CFXUnit(100).toString(), equals('100'));
    });

    test('should throw on undefined', () {
      expect(() => CFXUnit(null), throwsArgumentError);
    });

    test('should throw on negative', () {
      expect(() => CFXUnit(-1), throwsA(isA<ArgumentError>()));
    });

    test('should throw on decimal', () {
      expect(() => CFXUnit(3.14), throwsA(isA<ArgumentError>()));
    });
  });

  group('CFXUnit conversion methods', () {
    test('should convert to string', () {
      final drip = CFXUnit.fromGDrip(3.14);
      expect(drip.toString(), equals('3140000000'));
    });

    test('should convert toGDrip', () {
      final drip = CFXUnit.fromGDrip(3.14);
      expect(drip.toGDrip(), equals('3.14'));
    });

    test('should convert toCFX', () {
      final drip = CFXUnit.fromGDrip(3.14);
      expect(drip.toCFX(), equals('0.00000000314'));
    });

    test('should serialize to JSON', () {
      final drip = CFXUnit.fromGDrip(3.14);
      expect(drip.toJson(), equals('3140000000'));
    });
  });

  group('CFXUnit edge cases', () {
    test('should handle zero value', () {
      final unit = CFXUnit(0);
      expect(unit.toString(), equals('0'));
      expect(unit.toCFX(), equals('0'));
      expect(unit.toGDrip(), equals('0'));
    });

    test('should handle large values', () {
      final unit = CFXUnit.fromCFX(1000000);
      expect(unit.toString(), equals('1000000000000000000000000'));
    });

    test('should handle maximum precision for CFX', () {
      final unit = CFXUnit.fromCFX('0.000000000000000001');
      expect(unit.toString(), equals('1'));
    });

    test('should handle maximum precision for GDrip', () {
      final unit = CFXUnit.fromGDrip('0.000000001');
      expect(unit.toString(), equals('1'));
    });
  });
}

