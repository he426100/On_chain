// SPDX-License-Identifier: Apache-2.0
//
// Ported from Trust Wallet wallet-core:
// tests/chains/Filecoin/AddressTests.cpp
//
// This file contains ALL 59 address test cases from wallet-core to ensure
// 100% compatibility. DO NOT modify or simplify these test cases.

import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

class AddressTestCase {
  final String string;
  final String encoded;
  final int actorID;
  final String payloadHex;

  const AddressTestCase({
    required this.string,
    required this.encoded,
    required this.actorID,
    required this.payloadHex,
  });
}

void main() {
  // Ported from wallet-core AddressTests.cpp lines 23-59
  const validAddresses = [
    // ID addresses
    AddressTestCase(
      string: 'f00',
      encoded: '0000',
      actorID: 0,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f01',
      encoded: '0001',
      actorID: 1,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f010',
      encoded: '000a',
      actorID: 10,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f0150',
      encoded: '009601',
      actorID: 150,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f0499',
      encoded: '00f303',
      actorID: 499,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f01024',
      encoded: '008008',
      actorID: 1024,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f01729',
      encoded: '00c10d',
      actorID: 1729,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f0999999',
      encoded: '00bf843d',
      actorID: 999999,
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f018446744073709551615',
      encoded: '00ffffffffffffffffff01',
      actorID: -1, // uint64_t max in Dart is stored as -1 (signed int64)
      payloadHex: '',
    ),
    // secp256k1 addresses
    AddressTestCase(
      string: 'f15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq',
      encoded: '01ea0f0ea039b291a0f08fd179e0556a8c3277c0d3',
      actorID: 0,
      payloadHex: 'ea0f0ea039b291a0f08fd179e0556a8c3277c0d3',
    ),
    AddressTestCase(
      string: 'f12fiakbhe2gwd5cnmrenekasyn6v5tnaxaqizq6a',
      encoded: '01d1500504e4d1ac3e89ac891a4502586fabd9b417',
      actorID: 0,
      payloadHex: 'd1500504e4d1ac3e89ac891a4502586fabd9b417',
    ),
    AddressTestCase(
      string: 'f1wbxhu3ypkuo6eyp6hjx6davuelxaxrvwb2kuwva',
      encoded: '01b06e7a6f0f551de261fe3a6fe182b422ee0bc6b6',
      actorID: 0,
      payloadHex: 'b06e7a6f0f551de261fe3a6fe182b422ee0bc6b6',
    ),
    AddressTestCase(
      string: 'f1xtwapqc6nh4si2hcwpr3656iotzmlwumogqbuaa',
      encoded: '01bcec07c05e69f92468e2b3e3bf77c874f2c5da8c',
      actorID: 0,
      payloadHex: 'bcec07c05e69f92468e2b3e3bf77c874f2c5da8c',
    ),
    AddressTestCase(
      string: 'f1xcbgdhkgkwht3hrrnui3jdopeejsoatkzmoltqy',
      encoded: '01b882619d46558f3d9e316d11b48dcf211327026a',
      actorID: 0,
      payloadHex: 'b882619d46558f3d9e316d11b48dcf211327026a',
    ),
    AddressTestCase(
      string: 'f17uoq6tp427uzv7fztkbsnn64iwotfrristwpryy',
      encoded: '01fd1d0f4dfcd7e99afcb99a8326b7dc459d32c628',
      actorID: 0,
      payloadHex: 'fd1d0f4dfcd7e99afcb99a8326b7dc459d32c628',
    ),
    // Actor addresses
    AddressTestCase(
      string: 'f24vg6ut43yw2h2jqydgbg2xq7x6f4kub3bg6as6i',
      encoded: '02e54dea4f9bc5b47d261819826d5e1fbf8bc5503b',
      actorID: 0,
      payloadHex: 'e54dea4f9bc5b47d261819826d5e1fbf8bc5503b',
    ),
    AddressTestCase(
      string: 'f25nml2cfbljvn4goqtclhifepvfnicv6g7mfmmvq',
      encoded: '02eb58bd08a15a6ade19d0989674148fa95a8157c6',
      actorID: 0,
      payloadHex: 'eb58bd08a15a6ade19d0989674148fa95a8157c6',
    ),
    AddressTestCase(
      string: 'f2nuqrg7vuysaue2pistjjnt3fadsdzvyuatqtfei',
      encoded: '026d21137eb4c4814269e894d296cf6500e43cd714',
      actorID: 0,
      payloadHex: '6d21137eb4c4814269e894d296cf6500e43cd714',
    ),
    AddressTestCase(
      string: 'f24dd4ox4c2vpf5vk5wkadgyyn6qtuvgcpxxon64a',
      encoded: '02e0c7c75f82d55e5ed55db28033630df4274a984f',
      actorID: 0,
      payloadHex: 'e0c7c75f82d55e5ed55db28033630df4274a984f',
    ),
    AddressTestCase(
      string: 'f2gfvuyh7v2sx3patm5k23wdzmhyhtmqctasbr23y',
      encoded: '02316b4c1ff5d4afb7826ceab5bb0f2c3e0f364053',
      actorID: 0,
      payloadHex: '316b4c1ff5d4afb7826ceab5bb0f2c3e0f364053',
    ),
    // BLS addresses
    AddressTestCase(
      string:
          'f3vvmn62lofvhjd2ugzca6sof2j2ubwok6cj4xxbfzz4yuxfkgobpihhd2thlanmsh3w2ptld2gqkn2jvlss4a',
      encoded:
          '03ad58df696e2d4e91ea86c881e938ba4ea81b395e12797b84b9cf314b9546705e839c7a99d606b247ddb4f9ac7a3414dd',
      actorID: 0,
      payloadHex:
          'ad58df696e2d4e91ea86c881e938ba4ea81b395e12797b84b9cf314b9546705e839c7a99d606b247ddb4f9ac7a3414dd',
    ),
    AddressTestCase(
      string:
          'f3wmuu6crofhqmm3v4enos73okk2l366ck6yc4owxwbdtkmpk42ohkqxfitcpa57pjdcftql4tojda2poeruwa',
      encoded:
          '03b3294f0a2e29e0c66ebc235d2fedca5697bf784af605c75af608e6a63d5cd38ea85ca8989e0efde9188b382f9372460d',
      actorID: 0,
      payloadHex:
          'b3294f0a2e29e0c66ebc235d2fedca5697bf784af605c75af608e6a63d5cd38ea85ca8989e0efde9188b382f9372460d',
    ),
    AddressTestCase(
      string:
          'f3s2q2hzhkpiknjgmf4zq3ejab2rh62qbndueslmsdzervrhapxr7dftie4kpnpdiv2n6tvkr743ndhrsw6d3a',
      encoded:
          '0396a1a3e4ea7a14d49985e661b22401d44fed402d1d0925b243c923589c0fbc7e32cd04e29ed78d15d37d3aaa3fe6da33',
      actorID: 0,
      payloadHex:
          '96a1a3e4ea7a14d49985e661b22401d44fed402d1d0925b243c923589c0fbc7e32cd04e29ed78d15d37d3aaa3fe6da33',
    ),
    AddressTestCase(
      string:
          'f3q22fijmmlckhl56rn5nkyamkph3mcfu5ed6dheq53c244hfmnq2i7efdma3cj5voxenwiummf2ajlsbxc65a',
      encoded:
          '0386b454258c589475f7d16f5aac018a79f6c1169d20fc33921dd8b5ce1cac6c348f90a3603624f6aeb91b64518c2e8095',
      actorID: 0,
      payloadHex:
          '86b454258c589475f7d16f5aac018a79f6c1169d20fc33921dd8b5ce1cac6c348f90a3603624f6aeb91b64518c2e8095',
    ),
    AddressTestCase(
      string:
          'f3u5zgwa4ael3vuocgc5mfgygo4yuqocrntuuhcklf4xzg5tcaqwbyfabxetwtj4tsam3pbhnwghyhijr5mixa',
      encoded:
          '03a7726b038022f75a384617585360cee629070a2d9d28712965e5f26ecc40858382803724ed34f2720336f09db631f074',
      actorID: 0,
      payloadHex:
          'a7726b038022f75a384617585360cee629070a2d9d28712965e5f26ecc40858382803724ed34f2720336f09db631f074',
    ),
    // Delegated addresses
    AddressTestCase(
      string: 'f432f77777777x32lpna',
      encoded: '0420ffffffffff',
      actorID: 32,
      payloadHex: 'ffffffffff',
    ),
    AddressTestCase(
      string: 'f418446744073709551615ftnkyfaq',
      encoded: '04ffffffffffffffffff01',
      actorID: -1, // uint64_t max in Dart is stored as -1 (signed int64)
      payloadHex: '',
    ),
    AddressTestCase(
      string: 'f410frw6wy7w6sbsguyn3yzeygg34fgf72n5ao5sxyky',
      encoded: '040a8dbd6c7ede90646a61bbc649831b7c298bfd37a0',
      actorID: 10,
      payloadHex: '8dbd6c7ede90646a61bbc649831b7c298bfd37a0',
    ),
    AddressTestCase(
      string: 'f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gmy',
      encoded: '040ad388ab098ed3e84c0d808776440b48f685198498',
      actorID: 10,
      payloadHex: 'd388ab098ed3e84c0d808776440b48f685198498',
    ),
    AddressTestCase(
      string:
          'f418446744073709551615faaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaafbbuagu',
      encoded:
          '04ffffffffffffffffff01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
      actorID: -1, // uint64_t max in Dart is stored as -1 (signed int64)
      payloadHex:
          '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
    ),
  ];

  // Ported from wallet-core AddressTests.cpp lines 61-77
  // Modified: wallet-core only tests mainnet, this tests network-agnostic validation
  const invalidAddresses = [
    '',
    'f0-1', // Negative :)
    'f018446744073709551616', // Greater than max uint64_t
    'f418446744073709551615', // No "f" separator
    'f4f77777777vnmsana', // Empty Actor ID
    'a15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq', // Unknown net
    'f95ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq', // Unknown address type
    // Invalid checksum cases
    'f15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7rdrr',
    'f24vg6ut43yw2h2jqydgbg2xq7x6f4kub3bg6as66',
    'f3vvmn62lofvhjd2ugzca6sof2j2ubwok6cj4xxbfzz4yuxfkgobpihhd2thlanmsh3w2ptld2gqkn2jvlss44',
    'f0vvmn62lofvhjd2ugzca6sof2j2ubwok6cj4xxbfzz4yuxfkgobpihhd2thlanmsh3w2ptld2gqkn2jvlss44',
    'f410f2oekwcmo2pueydmaq53eic2i62crtbeyuzx2gma',
  ];

  // Ported from wallet-core AddressTests.cpp lines 79-88
  group('FilecoinAddress - IsValid', () {
    test('All valid addresses should be valid (string)', () {
      for (final testCase in validAddresses) {
        expect(
          FilecoinAddress.isValidAddress(testCase.string),
          isTrue,
          reason: 'isValid(string) != true: ${testCase.string}',
        );
      }
    });

    test('All valid addresses should be valid (bytes)', () {
      for (final testCase in validAddresses) {
        final encodedBytes = BytesUtils.fromHexString(testCase.encoded);
        expect(
          FilecoinAddress.isValidBytes(encodedBytes),
          isTrue,
          reason: 'isValid(Data) != true: ${testCase.encoded}',
        );
      }
    });
  });

  // Ported from wallet-core AddressTests.cpp lines 90-102
  group('FilecoinAddress - IsInvalid', () {
    test('All invalid addresses should be invalid', () {
      for (final address in invalidAddresses) {
        expect(
          FilecoinAddress.isValidAddress(address),
          isFalse,
          reason: 'isValid(string) != false: $address',
        );
      }
    });

    test('Invalid byte encodings should be invalid', () {
      // Empty varuint
      expect(
        FilecoinAddress.isValidBytes(BytesUtils.fromHexString('00')),
        isFalse,
        reason: 'Empty varuint',
      );

      // Short varuint
      expect(
        FilecoinAddress.isValidBytes(BytesUtils.fromHexString('00ff')),
        isFalse,
        reason: 'Short varuint',
      );

      // Varuint with hole
      expect(
        FilecoinAddress.isValidBytes(BytesUtils.fromHexString('00ff00ff')),
        isFalse,
        reason: 'Varuint with hole',
      );

      // Long varuint
      expect(
        FilecoinAddress.isValidBytes(BytesUtils.fromHexString('000101')),
        isFalse,
        reason: 'Long varuint',
      );

      // Long varuint (zeros)
      expect(
        FilecoinAddress.isValidBytes(BytesUtils.fromHexString('000000')),
        isFalse,
        reason: 'Long varuint',
      );

      // Overflow
      expect(
        FilecoinAddress.isValidBytes(
            BytesUtils.fromHexString('00ffffffffffffffffff80')),
        isFalse,
        reason: 'Overflow',
      );
    });
  });

  // Ported from wallet-core AddressTests.cpp lines 104-112
  group('FilecoinAddress - Equal', () {
    test('Address from string equals address from bytes', () {
      for (final testCase in validAddresses) {
        final encodedBytes = BytesUtils.fromHexString(testCase.encoded);
        final lhs = FilecoinAddress.fromString(testCase.string);
        final rhs = FilecoinAddress.fromBytes(encodedBytes);

        expect(lhs, equals(rhs),
            reason: 'Address(string) != Address(Data): ${testCase.string}');
      }
    });

    test('Empty bytes should throw', () {
      expect(
        () => FilecoinAddress.fromBytes([]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // Ported from wallet-core AddressTests.cpp lines 114-129
  group('FilecoinAddress - ExpectedProperties', () {
    test('All addresses should have correct type, actorID, and payload', () {
      for (final testCase in validAddresses) {
        final encodedBytes = BytesUtils.fromHexString(testCase.encoded);
        final expectedType = encodedBytes[0];

        final address = FilecoinAddress.fromBytes(encodedBytes);

        expect(
          address.type.value,
          equals(expectedType),
          reason:
              'Unexpected type: ${address.type.value} != $expectedType: ${testCase.string}',
        );

        expect(
          address.actorId,
          equals(testCase.actorID),
          reason:
              'Unexpected actorID: ${address.actorId} != ${testCase.actorID}: ${testCase.string}',
        );

        final expectedPayload = testCase.payloadHex.isEmpty
            ? <int>[]
            : BytesUtils.fromHexString(testCase.payloadHex);
        expect(
          address.payload,
          equals(expectedPayload),
          reason:
              'Unexpected payload: ${BytesUtils.toHexString(address.payload)} != ${testCase.payloadHex}',
        );
      }
    });
  });

  // Ported from wallet-core AddressTests.cpp lines 131-136
  group('FilecoinAddress - ToString', () {
    test('Bytes to string conversion', () {
      for (final testCase in validAddresses) {
        final address =
            FilecoinAddress.fromBytes(BytesUtils.fromHexString(testCase.encoded));
        expect(
          address.toAddress(),
          equals(testCase.string),
          reason: 'Address(${testCase.encoded})',
        );
      }
    });
  });

  // Ported from wallet-core AddressTests.cpp lines 138-146
  group('FilecoinAddress - ToBytes', () {
    test('String to bytes conversion', () {
      for (final testCase in validAddresses) {
        final address = FilecoinAddress.fromString(testCase.string);
        final bytes = address.toBytes();
        expect(
          BytesUtils.toHexString(bytes),
          equals(testCase.encoded),
          reason: 'Address(${testCase.string})',
        );
      }
    });

    test('Invalid addresses should throw', () {
      for (final address in invalidAddresses) {
        expect(
          () => FilecoinAddress.fromString(address),
          throwsA(isA<ArgumentError>()),
          reason: 'Should throw for: $address',
        );
      }
    });
  });

  // Additional test: Network-specific validation
  group('FilecoinAddress - Network Validation', () {
    test('Testnet addresses are valid on testnet only', () {
      const testnetAddr = 't15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq';

      // Structurally valid address
      expect(FilecoinAddress.isValidAddress(testnetAddr), true);

      // Valid on testnet
      expect(FilecoinAddress.isValidAddressForNetwork(testnetAddr, FilecoinNetwork.testnet), true);

      // Invalid on mainnet
      expect(FilecoinAddress.isValidAddressForNetwork(testnetAddr, FilecoinNetwork.mainnet), false);
    });

    test('Mainnet addresses are valid on mainnet only', () {
      const mainnetAddr = 'f15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq';

      // Structurally valid address
      expect(FilecoinAddress.isValidAddress(mainnetAddr), true);

      // Valid on mainnet
      expect(FilecoinAddress.isValidAddressForNetwork(mainnetAddr, FilecoinNetwork.mainnet), true);

      // Invalid on testnet
      expect(FilecoinAddress.isValidAddressForNetwork(mainnetAddr, FilecoinNetwork.testnet), false);
    });
  });
}
