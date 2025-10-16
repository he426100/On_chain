import 'package:test/test.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Address Converter - Ethereum Address Validation', () {
    test('isEthAddress - valid addresses', () {
      expect(FilecoinAddressConverter.isEthAddress('0xb959b6fF9ED21CfD15EEC2BEC15d1C5b87df7F42'), isTrue);
      expect(FilecoinAddressConverter.isEthAddress('0xa0cf798816d4b9b9866b5330eea46a18382f251e'), isTrue);
      expect(FilecoinAddressConverter.isEthAddress('0x52963EF50e27e06D72D59fcB4F3c2a687BE3cfEf'), isTrue);

      // ID mask addresses
      expect(FilecoinAddressConverter.isEthAddress('0xff00000000000000000000000000000000000001'), isTrue);
      expect(FilecoinAddressConverter.isEthAddress('0xff00000000000000000000000000000000000064'), isTrue);
      expect(FilecoinAddressConverter.isEthAddress('0xff000000000000000000000000000000000013e0'), isTrue);
    });

    test('isEthAddress - invalid addresses', () {
      expect(FilecoinAddressConverter.isEthAddress('x'), isFalse);
      expect(FilecoinAddressConverter.isEthAddress('0xa'), isFalse);

      // Invalid checksum
      expect(FilecoinAddressConverter.isEthAddress('0xa5cc3c03994db5b0d9a5eEdD10Cabab0813678ac'), isFalse);
      expect(FilecoinAddressConverter.isEthAddress('0xa5cc3c03994db5b0d9a5eEdD10Cabab0813678az'), isFalse);
      expect(FilecoinAddressConverter.isEthAddress('0xa5cc3c03994db5b0d9a5eEdD10Cabab0813678aff'), isFalse);
      expect(FilecoinAddressConverter.isEthAddress('a5cc3c03994db5b0d9a5eEdD10Cabab0813678ac'), isFalse);
      expect(FilecoinAddressConverter.isEthAddress('0x8Ba1f109551bD432803012645Ac136ddd64DBa72'), isFalse);

      // ICAP format not supported
      expect(FilecoinAddressConverter.isEthAddress('XE65GB6LDNXYOFTX0NSV3FUWKOWIXAMJK36'), isFalse);
    });

    test('isIdMaskAddress - valid ID mask addresses', () {
      expect(FilecoinAddressConverter.isIdMaskAddress('0xff00000000000000000000000000000000000001'), isTrue);
      expect(FilecoinAddressConverter.isIdMaskAddress('0xff00000000000000000000000000000000000064'), isTrue);
      expect(FilecoinAddressConverter.isIdMaskAddress('0xff000000000000000000000000000000000013e0'), isTrue);
    });

    test('isIdMaskAddress - non-ID mask addresses', () {
      expect(FilecoinAddressConverter.isIdMaskAddress('0x52963EF50e27e06D72D59fcB4F3c2a687BE3cfEf'), isFalse);
      expect(FilecoinAddressConverter.isIdMaskAddress('invalid'), isFalse);
    });
  });

  group('Filecoin Address Converter - ETH to FIL Conversion', () {
    test('Convert ETH address to f4 delegated address', () {
      final f4 = FilecoinAddressConverter.fromEthAddress(
        '0xd388ab098ed3e84c0d808776440b48f685198498',
        network: FilecoinNetwork.testnet,
      );

      expect(f4.toString(), equals('t410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy'));
      expect(f4.type, equals(FilecoinAddressType.delegated));
    });

    test('Convert ID mask ETH address to f0 address', () {
      final address1 = '0xff000000000000000000000000000000000013e0';
      final id1 = FilecoinAddressConverter.fromEthAddress(address1);

      expect(id1.actorId, equals(5088));
      expect(id1.toString(), equals('f05088'));

      expect(
        FilecoinAddressConverter.fromEthAddress('0xff00000000000000000000000000000000000001', network: FilecoinNetwork.testnet).actorId,
        equals(1),
      );

      expect(
        FilecoinAddressConverter.fromEthAddress('0xff00000000000000000000000000000000000064', network: FilecoinNetwork.testnet).actorId,
        equals(100),
      );
    });

    test('Round trip - ETH to FIL and back', () {
      final ethAddress = '0xd388aB098ed3E84c0D808776440B48F685198498';
      final f4 = FilecoinAddressConverter.fromEthAddress(ethAddress.toLowerCase());

      expect(f4.toString().startsWith('f4'), isTrue);

      final convertedBack = f4.toEthAddress();
      expect(convertedBack, isNotNull);
      expect(convertedBack!.toLowerCase(), equals(ethAddress.toLowerCase()));
    });
  });

  group('Filecoin Address Converter - FIL to ETH Conversion', () {
    test('Convert f0 ID address to ID mask ETH address', () {
      final f0_1 = FilecoinAddress.fromString('f01');
      expect(f0_1.toIdMaskAddress(), equals('0xff00000000000000000000000000000000000001'));

      final f0_100 = FilecoinAddress.fromString('f0100');
      expect(f0_100.toIdMaskAddress(), equals('0xff00000000000000000000000000000000000064'));

      final f0_5088 = FilecoinAddress.fromString('f05088');
      expect(f0_5088.toIdMaskAddress(), equals('0xff000000000000000000000000000000000013e0'));

      final f0_1024 = FilecoinAddress.fromString('f01024');
      expect(f0_1024.toIdMaskAddress(), equals('0xfF00000000000000000000000000000000000400'));
    });

    test('Convert f4 delegated address to ETH address', () {
      final f4_1 = FilecoinAddress.fromString('f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      expect(
        f4_1.toEthAddress(),
        equals('0xd388aB098ed3E84c0D808776440B48F685198498'),
      );

      final t4_1 = FilecoinAddress.fromString('t410fkkld55ioe7qg24wvt7fu6pbknb56ht7pt4zamxa');
      expect(
        t4_1.toEthAddress(),
        equals('0x52963EF50e27e06D72D59fcB4F3c2a687BE3cfEf'),
      );
    });

    test('Non-convertible addresses return null', () {
      // Create SECP256K1 address
      final testPayload = List.generate(20, (i) => i);
      final secp256k1Addr = FilecoinAddress(
        type: FilecoinAddressType.secp256k1,
        actorId: 0,
        payload: testPayload,
      );

      expect(secp256k1Addr.toEthAddress(), isNull);
      expect(secp256k1Addr.toIdMaskAddress(), isNull);

      // BLS address
      final blsPayload = List.generate(48, (i) => i);
      final blsAddr = FilecoinAddress(
        type: FilecoinAddressType.bls,
        actorId: 0,
        payload: blsPayload,
      );

      expect(blsAddr.toEthAddress(), isNull);
      expect(blsAddr.toIdMaskAddress(), isNull);

      // Actor address
      final actorPayload = List.generate(20, (i) => i);
      final actorAddr = FilecoinAddress(
        type: FilecoinAddressType.actor,
        actorId: 0,
        payload: actorPayload,
      );

      expect(actorAddr.toEthAddress(), isNull);
      expect(actorAddr.toIdMaskAddress(), isNull);
    });
  });

  group('Filecoin Address Converter - Legacy API Compatibility', () {
    test('Convert ID address to Ethereum using convertToEthereum', () {
      final filecoinAddress = FilecoinAddress.fromString('f09876');
      final ethAddress = FilecoinAddressConverter.convertToEthereum(filecoinAddress);

      expect(ethAddress, isNotNull);
      expect(ethAddress!.address, equals('0xff00000000000000000000000000000000002694'));
    });

    test('Convert delegated address to Ethereum using convertToEthereum', () {
      final ethBytes = List.generate(20, (i) => i);
      final filecoinAddress = FilecoinAddress(
        type: FilecoinAddressType.delegated,
        actorId: FilecoinAddress.ethereumAddressManagerActorId,
        payload: ethBytes,
      );

      final ethAddress = FilecoinAddressConverter.convertToEthereum(filecoinAddress);
      expect(ethAddress, isNotNull);
    });

    test('Convert Ethereum address to Filecoin using convertFromEthereum', () {
      final ethAddress = ETHAddress('0x8dbD6c7Ede90646a61Bbc649831b7c298BFd37A0');
      final filecoinAddress = FilecoinAddressConverter.convertFromEthereum(ethAddress);

      expect(filecoinAddress.type, equals(FilecoinAddressType.delegated));
      expect(filecoinAddress.actorId, equals(FilecoinAddress.ethereumAddressManagerActorId));
      expect(filecoinAddress.toAddress().startsWith('f4'), isTrue);
    });

    test('Convert address strings using legacy API', () {
      final ethAddressString = '0x8dbD6c7Ede90646a61Bbc649831b7c298BFd37A0';
      final filecoinAddressString = FilecoinAddressConverter.convertFromEthereumString(ethAddressString);

      expect(filecoinAddressString.startsWith('f4'), isTrue);

      final convertedBack = FilecoinAddressConverter.convertToEthereumString(filecoinAddressString);
      expect(convertedBack?.toLowerCase(), equals(ethAddressString.toLowerCase()));
    });

    test('toEthAddress alias works correctly', () {
      final f4 = FilecoinAddress.fromString('f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy');
      final ethAddr1 = FilecoinAddressConverter.toEthAddress(f4);
      final ethAddr2 = f4.toEthAddress();

      expect(ethAddr1, isNotNull);
      expect(ethAddr2, isNotNull);
      expect(ethAddr1!.toLowerCase(), equals(ethAddr2!.toLowerCase()));
    });

    test('Cannot convert non-delegated addresses to Ethereum', () {
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

  group('Filecoin Address Converter - Test Vectors from Reference', () {
    test('Test vectors - mainnet addresses', () {
      // Based on reference implementation test vectors
      final testVectors = [
        {
          'eth': '0xd388ab098ed3e84c0d808776440b48f685198498',
          'fil': 'f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy',
        },
      ];

      for (final vector in testVectors) {
        final ethAddr = vector['eth']!;
        final expectedFil = vector['fil']!;

        // ETH -> FIL conversion
        final filAddr = FilecoinAddressConverter.fromEthAddress(ethAddr);
        expect(filAddr.toString(), equals(expectedFil));

        // FIL -> ETH conversion
        final convertedEth = filAddr.toEthAddress();
        expect(convertedEth, isNotNull);
        expect(convertedEth!.toLowerCase(), equals(ethAddr.toLowerCase()));
      }
    });

    test('Test vectors - ID mask addresses', () {
      final testVectors = [
        {'id': 1, 'eth': '0xff00000000000000000000000000000000000001', 'fil': 'f01'},
        {'id': 100, 'eth': '0xff00000000000000000000000000000000000064', 'fil': 'f0100'},
        {'id': 5088, 'eth': '0xff000000000000000000000000000000000013e0', 'fil': 'f05088'},
        {'id': 1024, 'eth': '0xfF00000000000000000000000000000000000400', 'fil': 'f01024'},
      ];

      for (final vector in testVectors) {
        final actorId = vector['id'] as int;
        final ethAddr = vector['eth'] as String;
        final filAddr = vector['fil'] as String;

        // ETH -> FIL conversion
        final fil = FilecoinAddressConverter.fromEthAddress(ethAddr);
        expect(fil.actorId, equals(actorId));
        expect(fil.toString(), equals(filAddr));

        // FIL -> ETH conversion
        final eth = FilecoinAddress.fromString(filAddr).toIdMaskAddress();
        expect(eth, isNotNull);
        expect(eth!.toLowerCase(), equals(ethAddr.toLowerCase()));
      }
    });

    test('Test vectors - testnet addresses', () {
      final testVectors = [
        {
          'eth': '0xd388ab098ed3e84c0d808776440b48f685198498',
          'fil': 't410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy',
        },
        {
          'eth': '0x52963ef50e27e06d72d59fcb4f3c2a687be3cfef',
          'fil': 't410fkkld55ioe7qg24wvt7fu6pbknb56ht7pt4zamxa',
        },
      ];

      for (final vector in testVectors) {
        final ethAddr = vector['eth']!;
        final expectedFil = vector['fil']!;

        // ETH -> FIL conversion
        final filAddr = FilecoinAddressConverter.fromEthAddress(
          ethAddr,
          network: FilecoinNetwork.testnet,
        );
        expect(filAddr.toString(), equals(expectedFil));

        // FIL -> ETH conversion
        final convertedEth = FilecoinAddress.fromString(expectedFil).toEthAddress();
        expect(convertedEth, isNotNull);
        expect(convertedEth!.toLowerCase(), equals(ethAddr.toLowerCase()));
      }
    });
  });

  group('Filecoin Address Converter - Error Handling', () {
    test('fromEthAddress throws on invalid address', () {
      expect(
        () => FilecoinAddressConverter.fromEthAddress('invalid'),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => FilecoinAddressConverter.fromEthAddress('0x123'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Delegated address with wrong actor ID returns null', () {
      final wrongActorId = FilecoinAddress(
        type: FilecoinAddressType.delegated,
        actorId: 99, // Not EAM actor ID
        payload: List.generate(20, (i) => i),
      );

      expect(wrongActorId.toEthAddress(), isNull);
      expect(FilecoinAddressConverter.convertToEthereum(wrongActorId), isNull);
    });

    test('Delegated address with wrong payload size returns null', () {
      final wrongPayloadSize = FilecoinAddress(
        type: FilecoinAddressType.delegated,
        actorId: FilecoinAddress.ethereumAddressManagerActorId,
        payload: List.generate(30, (i) => i), // Too large
      );

      expect(wrongPayloadSize.toEthAddress(), isNull);
      expect(FilecoinAddressConverter.convertToEthereum(wrongPayloadSize), isNull);
    });
  });
}
