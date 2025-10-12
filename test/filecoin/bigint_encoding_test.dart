// Test BigInt encoding to match iso-filecoin

import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('BigInt Encoding', () {
    test('encode 87316 should match iso-filecoin', () {
      // From iso-filecoin test: value 87316
      // Expected: 00 01 54 94
      final value = BigInt.from(87316);

      // Use FilecoinTransaction's internal encoding
      final transaction = FilecoinTransaction(
        version: 0,
        to: FilecoinAddress.fromString('f1ypi542zmmgaltijzw4byonei5c267ev5iif2liy'),
        from: FilecoinAddress.fromString('f17dyptywvmnldq2fsm6j226txnltf4aiwsi3vlka'),
        nonce: 0,
        value: value,
        gasLimit: 0,
        gasFeeCap: BigInt.zero,
        gasPremium: BigInt.zero,
        method: FilecoinMethod.send,
        params: [],
      );

      final messageBytes = transaction.getMessageBytes();
      final hex = BytesUtils.toHexString(messageBytes, prefix: '');
      print('Message CBOR: $hex');

      // Manually encode BigInt to test
      final encoded = _encodeFilecoinBigInt(value);
      final encodedHex = BytesUtils.toHexString(encoded, prefix: '');
      print('Value 87316 encoded: $encodedHex');
      print('Expected:            00015494');

      // 87316 = 0x15494
      expect(encodedHex, equals('00015494'));
    });

    test('encode gas values', () {
      // GasFeeCap: 42908 = 0xA79C
      final gasFeeCap = BigInt.from(42908);
      final encoded1 = _encodeFilecoinBigInt(gasFeeCap);
      print('GasFeeCap 42908: ${BytesUtils.toHexString(encoded1, prefix: "")}');
      print('Expected:        0000a79c');

      // GasPremium: 28871 = 0x70C7
      final gasPremium = BigInt.from(28871);
      final encoded2 = _encodeFilecoinBigInt(gasPremium);
      print('GasPremium 28871: ${BytesUtils.toHexString(encoded2, prefix: "")}');
      print('Expected:         000070c7');
    });
  });
}

// Copy of FilecoinTransaction's _encodeFilecoinBigInt for testing
List<int> _encodeFilecoinBigInt(BigInt value) {
  if (value == BigInt.zero) {
    return [];
  }

  if (value < BigInt.zero) {
    throw ArgumentError('Negative values not supported');
  }

  // Sign byte: 0x00 = positive, 0x01 = negative
  final signByte = [0x00];

  // Convert BigInt to bytes (big-endian, matching iso-filecoin)
  var hex = value.toRadixString(16);
  if (hex.length % 2 != 0) {
    hex = '0$hex'; // Pad with leading zero if odd length
  }

  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }

  return [...signByte, ...bytes];
}
