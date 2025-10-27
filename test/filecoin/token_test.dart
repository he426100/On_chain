import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

/// Token tests migrated from iso-filecoin/test/token.test.js
/// Tests token unit conversions and serialization
void main() {
  group('Token Unit Conversions', () {
    group('Zero Values', () {
      test('should convert zero across all units', () {
        final token = FilecoinToken.fromAttoFIL(BigInt.zero);
        
        expect(token.toAttoFIL(), equals(BigInt.zero));
        expect(token.toFemtoFIL(), equals(BigInt.zero));
        expect(token.toPicoFIL(), equals(BigInt.zero));
        expect(token.toNanoFIL(), equals(BigInt.zero));
        expect(token.toMicroFIL(), equals(BigInt.zero));
        expect(token.toMilliFIL(), equals(BigInt.zero));
        expect(token.toFIL(), equals('0'));
      });
    });

    group('Positive Values', () {
      test('should convert 1 FIL to all units correctly', () {
        final token = FilecoinToken.fromFIL('1');
        
        expect(token.toAttoFIL().toString(), equals('1000000000000000000'));
        expect(token.toFemtoFIL().toString(), equals('1000000000000000'));
        expect(token.toPicoFIL().toString(), equals('1000000000000'));
        expect(token.toNanoFIL().toString(), equals('1000000000'));
        expect(token.toMicroFIL().toString(), equals('1000000'));
        expect(token.toMilliFIL().toString(), equals('1000'));
        expect(token.toFIL(), equals('1'));
      });
      
      test('should handle large values', () {
        final token = FilecoinToken.fromFIL('1000000');
        expect(token.toFIL(), equals('1000000'));
        expect(token.toMilliFIL().toString(), equals('1000000000'));
      });
    });

    group('Negative Values', () {
      test('should handle negative values (for calculation)', () {
        // Note: Filecoin uses negative values in internal calculations
        final token = FilecoinToken.fromAttoFIL(BigInt.from(-1000000000000000000));
        
        expect(token.value.isNegative, isTrue);
        expect(token.toAttoFIL().toString(), equals('-1000000000000000000'));
        expect(token.toFIL(), equals('-1'));
      });

      test('should convert negative FIL correctly', () {
        // Create negative token through arithmetic
        final positive = FilecoinToken.fromFIL('1');
        final negative = FilecoinToken.fromAttoFIL(-positive.toAttoFIL());
        
        expect(negative.toFemtoFIL().toString(), equals('-1000000000000000'));
        expect(negative.toPicoFIL().toString(), equals('-1000000000000'));
        expect(negative.toNanoFIL().toString(), equals('-1000000000'));
        expect(negative.toMicroFIL().toString(), equals('-1000000'));
        expect(negative.toMilliFIL().toString(), equals('-1000'));
        expect(negative.toFIL(), equals('-1'));
      });
    });

    group('Float/Decimal Values', () {
      test('should handle 0.001 FIL correctly', () {
        final token = FilecoinToken.fromFIL('0.001');
        
        expect(token.toAttoFIL().toString(), equals('1000000000000000'));
        expect(token.toFemtoFIL().toString(), equals('1000000000000'));
        expect(token.toPicoFIL().toString(), equals('1000000000'));
        expect(token.toNanoFIL().toString(), equals('1000000'));
        expect(token.toMicroFIL().toString(), equals('1000'));
        expect(token.toMilliFIL().toString(), equals('1'));
        expect(token.toFIL(), equals('0.001'));
      });

      test('should handle various decimal places', () {
        expect(FilecoinToken.fromFIL('0.1').toFIL(), equals('0.1'));
        expect(FilecoinToken.fromFIL('0.01').toFIL(), equals('0.01'));
        expect(FilecoinToken.fromFIL('0.001').toFIL(), equals('0.001'));
        expect(FilecoinToken.fromFIL('0.0001').toFIL(), equals('0.0001'));
        expect(FilecoinToken.fromFIL('0.123456789012345678').toFIL(), equals('0.123456789012345678'));
      });
    });

    group('High Precision BigInt', () {
      test('should handle very large precise values', () {
        final token = FilecoinToken.fromAttoFIL(
          BigInt.parse('11231000001100000000011')
        );
        
        expect(token.toAttoFIL().toString(), equals('11231000001100000000011'));
        
        // Convert to FIL and verify precision
        final fil = token.toFIL();
        expect(fil, equals('11231.000001100000000011'));
      });

      test('should maintain precision in conversions', () {
        final attoValue = BigInt.parse('123456789012345678901234567890');
        final token = FilecoinToken.fromAttoFIL(attoValue);
        
        // Convert back and verify no loss of precision
        expect(token.toAttoFIL(), equals(attoValue));
      });
    });
  });

  group('Token Serialization', () {
    // Test vectors from iso-filecoin/test/token.test.js
    final serializationVectors = [
      ['0', ''],
      ['9', '0009'],
      ['22', '0016'],
      ['-18', '0112'],
      ['-26118', '016606'],
      ['-20368000000000000', '01485c968cc90000'],
      ['23752000000000000', '0054625172b48000'],
      ['4171000000000000', '000ed1809d5bb000'],
      ['6098800000000000000000000', '00050b789c4844bc17c00000'],
      ['-6180700000000000000000000', '01051cd06b1a8ff003f00000'],
    ];

    for (final vector in serializationVectors) {
      final attoStr = vector[0];
      final expectedHex = vector[1];
      
      test('should serialize $attoStr correctly', () {
        final token = FilecoinToken.fromAttoFILString(attoStr);
        final bytes = token.toBytes();
        final hex = BytesUtils.toHexString(bytes).toLowerCase();
        
        expect(hex, equals(expectedHex), 
            reason: 'Serialization of $attoStr should match $expectedHex');
      });

      test('should deserialize $expectedHex correctly', () {
        if (expectedHex.isEmpty) {
          final token = FilecoinToken.fromBytes([]);
          expect(token.toAttoFILString(), equals('0'));
        } else {
          final bytes = BytesUtils.fromHexString(expectedHex);
          final token = FilecoinToken.fromBytes(bytes);
          expect(token.toAttoFILString(), equals(attoStr),
              reason: 'Deserialization of $expectedHex should match $attoStr');
        }
      });
    }
  });

  group('Token Formatting', () {
    test('should format with default options', () {
      final token = FilecoinToken.fromAttoFIL(BigInt.one);
      final formatted = token.toFIL();
      expect(formatted, equals('0.000000000000000001'));
    });

    test('should format with decimal places', () {
      final token = FilecoinToken.fromFIL('100.123456789');
      final formatted = token.toFIL(decimalPlaces: 2);
      expect(formatted, equals('100.12'));
    });

    test('should format with custom options', () {
      final token = FilecoinToken.fromFIL('1234567.89');
      final formatted = token.toFormat(
        decimalPlaces: 2,
        groupSeparator: ',',
        groupSize: 3,
        suffix: ' FIL',
      );
      expect(formatted, contains('1,234,567.89 FIL'));
    });

    test('should format without grouping', () {
      final token = FilecoinToken.fromFIL('1000000');
      final formatted = token.toFormat(
        decimalPlaces: 0,
        groupSize: 0,
      );
      expect(formatted, equals('1000000'));
    });

    test('should handle zero in formatting', () {
      final token = FilecoinToken.fromAttoFIL(BigInt.zero);
      expect(token.toFormat(suffix: ' FIL'), equals('0 FIL'));
    });
  });

  group('Token Arithmetic', () {
    test('should add tokens', () {
      final token1 = FilecoinToken.fromFIL('1');
      final token2 = FilecoinToken.fromFIL('2');
      final result = token1 + token2;
      expect(result.toFIL(), equals('3'));
    });

    test('should subtract tokens', () {
      final token1 = FilecoinToken.fromFIL('5');
      final token2 = FilecoinToken.fromFIL('2');
      final result = token1 - token2;
      expect(result.toFIL(), equals('3'));
    });

    test('should multiply token', () {
      final token = FilecoinToken.fromFIL('2');
      final result = token * BigInt.from(3);
      expect(result.toFIL(), equals('6'));
    });

    test('should divide token', () {
      final token = FilecoinToken.fromFIL('6');
      final result = token ~/ BigInt.from(2);
      expect(result.toFIL(), equals('3'));
    });

    test('should calculate absolute value', () {
      final token = FilecoinToken.fromAttoFIL(BigInt.from(-1000));
      final result = token.abs();
      expect(result.toAttoFIL(), equals(BigInt.from(1000)));
    });
  });

  group('Token Comparison', () {
    test('should compare tokens correctly', () {
      final token1 = FilecoinToken.fromFIL('1');
      final token2 = FilecoinToken.fromFIL('2');
      final token3 = FilecoinToken.fromFIL('1');
      
      expect(token1 < token2, isTrue);
      expect(token2 > token1, isTrue);
      expect(token1 == token3, isTrue);
      expect(token1 <= token3, isTrue);
      expect(token2 >= token1, isTrue);
    });

    test('should handle zero comparison', () {
      final zero = FilecoinToken.fromAttoFIL(BigInt.zero);
      final positive = FilecoinToken.fromFIL('1');
      final negative = FilecoinToken.fromAttoFIL(BigInt.from(-1));
      
      expect(zero < positive, isTrue);
      expect(zero > negative, isTrue);
      expect(zero == FilecoinToken.fromAttoFIL(BigInt.zero), isTrue);
    });
  });

  group('Edge Cases', () {
    test('should handle maximum safe integer', () {
      final maxSafeInt = BigInt.from(9007199254740991); // JavaScript MAX_SAFE_INTEGER
      final token = FilecoinToken.fromAttoFIL(maxSafeInt);
      expect(token.toAttoFIL(), equals(maxSafeInt));
    });

    test('should handle very large values beyond safe integer', () {
      final veryLarge = BigInt.parse('999999999999999999999999999999');
      final token = FilecoinToken.fromAttoFIL(veryLarge);
      expect(token.toAttoFIL(), equals(veryLarge));
    });

    test('should handle empty bytes as zero', () {
      final token = FilecoinToken.fromBytes([]);
      expect(token.toAttoFIL(), equals(BigInt.zero));
    });

    test('should round-trip correctly', () {
      final original = '123456789012345678';
      final token = FilecoinToken.fromAttoFILString(original);
      final bytes = token.toBytes();
      final recovered = FilecoinToken.fromBytes(bytes);
      expect(recovered.toAttoFILString(), equals(original));
    });
  });
}

