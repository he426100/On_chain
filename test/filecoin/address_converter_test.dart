import 'package:test/test.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Address Converter Tests', () {
    test('Convert ID address to Ethereum', () {
      final filecoinAddress = FilecoinAddress.fromString('f09876');
      final ethAddress = FilecoinAddressConverter.convertToEthereum(filecoinAddress);

      expect(ethAddress, isNotNull);
      expect(ethAddress!.address, equals('0xff00000000000000000000000000000000002694'));
    });

    test('Convert delegated address to Ethereum', () {
      // Create a test delegated address
      final ethBytes = List.generate(20, (i) => i);
      final filecoinAddress = FilecoinAddress(
        type: FilecoinAddressType.delegated,
        actorId: FilecoinAddress.ethereumAddressManagerActorId,
        payload: ethBytes,
      );

      final ethAddress = FilecoinAddressConverter.convertToEthereum(filecoinAddress);
      expect(ethAddress, isNotNull);
    });

    test('Convert Ethereum address to Filecoin', () {
      final ethAddress = ETHAddress('0x8dbD6c7Ede90646a61Bbc649831b7c298BFd37A0');
      final filecoinAddress = FilecoinAddressConverter.convertFromEthereum(ethAddress);

      expect(filecoinAddress.type, equals(FilecoinAddressType.delegated));
      expect(filecoinAddress.actorId, equals(FilecoinAddress.ethereumAddressManagerActorId));
      expect(filecoinAddress.toAddress().startsWith('f4'), isTrue);
    });

    test('Convert address strings', () {
      final ethAddressString = '0x8dbD6c7Ede90646a61Bbc649831b7c298BFd37A0';
      final filecoinAddressString = FilecoinAddressConverter.convertFromEthereumString(ethAddressString);

      expect(filecoinAddressString.startsWith('f4'), isTrue);

      final convertedBack = FilecoinAddressConverter.convertToEthereumString(filecoinAddressString);
      expect(convertedBack?.toLowerCase(), equals(ethAddressString.toLowerCase()));
    });

    test('Cannot convert non-delegated addresses to Ethereum', () {
      // SECP256K1 address cannot be converted - test invalid address string
      expect(() => FilecoinAddress.fromString('f1abcdefghijk'), throwsA(isA<ArgumentError>()));

      // Test with a properly constructed SECP256K1 address
      final testPayload = List.generate(20, (i) => i);
      final secp256k1Addr = FilecoinAddress(
        type: FilecoinAddressType.secp256k1,
        actorId: 0,
        payload: testPayload,
      );

      final ethAddr = FilecoinAddressConverter.convertToEthereum(secp256k1Addr);
      expect(ethAddr, isNull);
    });

    test('Can convert check', () {
      final idAddress = FilecoinAddress.fromString('f0123');
      expect(FilecoinAddressConverter.canConvertToEthereum(idAddress), isTrue);

      expect(FilecoinAddressConverter.canConvertToEthereumString('f0123'), isTrue);
      expect(FilecoinAddressConverter.canConvertToEthereumString('invalid'), isFalse);
    });

    test('Round trip conversion', () {
      final ethAddress = ETHAddress('0x1234567890123456789012345678901234567890');
      final filecoinAddress = FilecoinAddressConverter.convertFromEthereum(ethAddress);
      final convertedBack = FilecoinAddressConverter.convertToEthereum(filecoinAddress);

      expect(convertedBack, isNotNull);
      expect(convertedBack!.address.toLowerCase(), equals(ethAddress.address.toLowerCase()));
    });
  });
}