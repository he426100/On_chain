import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';

/// Utils tests migrated from iso-filecoin/test/utils.test.js
/// Tests utility functions like derivation path parsing
void main() {
  group('Derivation Path Parsing', () {
    test('should parse testnet bip44 derivation path', () {
      final components = FilecoinUtils.parseDerivationPath("m/44'/1'/0'/0/0");
      
      expect(components.purpose, equals(44));
      expect(components.coinType, equals(1));
      expect(components.account, equals(0));
      expect(components.change, equals(0));
      expect(components.addressIndex, equals(0));
    });

    test('should parse mainnet bip44 derivation path', () {
      final components = FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0/0");
      
      expect(components.purpose, equals(44));
      expect(components.coinType, equals(461));
      expect(components.account, equals(0));
      expect(components.change, equals(0));
      expect(components.addressIndex, equals(0));
    });

    test('should parse path with different indices', () {
      final components = FilecoinUtils.parseDerivationPath("m/44'/461'/5'/1/10");
      
      expect(components.purpose, equals(44));
      expect(components.coinType, equals(461));
      expect(components.account, equals(5));
      expect(components.change, equals(1));
      expect(components.addressIndex, equals(10));
    });

    test('should fail parse short bip44 derivation path', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('depth must be 5'),
        )),
      );
    });

    test('should fail parse bip44 derivation path without m', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("/44'/461'/0'/0/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('depth 0 must be "m"'),
        )),
      );
    });

    test("should fail parse bip44 derivation path with part 1 != 44'", () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/j4'/461'/0'/0/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('"purpose" node (depth 1) must be the string "44\'"'),
        )),
      );
    });

    test('should fail parse with non-hardened coin_type', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461/0'/0/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('"coin_type" node (depth 2) must be a hardened BIP-32 node'),
        )),
      );
    });

    test('should fail parse with non-hardened account', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/0/0/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('"account" node (depth 3) must be a hardened BIP-32 node'),
        )),
      );
    });

    test('should fail parse with hardened change node', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0'/0"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('"change" node (depth 4) must be a BIP-32 node'),
        )),
      );
    });

    test('should fail parse with hardened address_index', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0/0'"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('"address_index" node (depth 5) must be a BIP-32 node'),
        )),
      );
    });

    test('should fail parse with invalid characters', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/a'/0/0"),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should fail parse with extra components', () {
      expect(
        () => FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0/0/extra"),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('depth must be 5'),
        )),
      );
    });
  });

  group('Network Utilities', () {
    test('should get network prefix', () {
      expect(FilecoinUtils.getNetworkPrefix(FilecoinNetwork.mainnet), equals('f'));
      expect(FilecoinUtils.getNetworkPrefix(FilecoinNetwork.testnet), equals('t'));
    });

    test('should get network from prefix', () {
      expect(FilecoinUtils.getNetwork('f'), equals(FilecoinNetwork.mainnet));
      expect(FilecoinUtils.getNetwork('t'), equals(FilecoinNetwork.testnet));
    });

    test('should get network from derivation path', () {
      expect(
        FilecoinUtils.getNetworkFromPath("m/44'/461'/0'/0/0"),
        equals(FilecoinNetwork.mainnet),
      );
      expect(
        FilecoinUtils.getNetworkFromPath("m/44'/1'/0'/0/0"),
        equals(FilecoinNetwork.testnet),
      );
    });

    test('should get network from chain ID', () {
      // Mainnet
      expect(FilecoinUtils.getNetworkFromChainId(314), equals(FilecoinNetwork.mainnet));
      expect(FilecoinUtils.getNetworkFromChainId('0x13a'), equals(FilecoinNetwork.mainnet));
      expect(FilecoinUtils.getNetworkFromChainId('eip155:314'), equals(FilecoinNetwork.mainnet));
      expect(FilecoinUtils.getNetworkFromChainId('mainnet'), equals(FilecoinNetwork.mainnet));
      expect(FilecoinUtils.getNetworkFromChainId('f'), equals(FilecoinNetwork.mainnet));
      
      // Testnet
      expect(FilecoinUtils.getNetworkFromChainId(314159), equals(FilecoinNetwork.testnet));
      expect(FilecoinUtils.getNetworkFromChainId('0x4cb2f'), equals(FilecoinNetwork.testnet));
      expect(FilecoinUtils.getNetworkFromChainId('eip155:314159'), equals(FilecoinNetwork.testnet));
      expect(FilecoinUtils.getNetworkFromChainId('testnet'), equals(FilecoinNetwork.testnet));
      expect(FilecoinUtils.getNetworkFromChainId('t'), equals(FilecoinNetwork.testnet));
    });

    test('should fail on unknown chain ID', () {
      expect(
        () => FilecoinUtils.getNetworkFromChainId(999),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => FilecoinUtils.getNetworkFromChainId('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should generate path from network', () {
      expect(
        FilecoinUtils.pathFromNetwork(FilecoinNetwork.mainnet, 0),
        equals("m/44'/461'/0'/0/0"),
      );
      expect(
        FilecoinUtils.pathFromNetwork(FilecoinNetwork.mainnet, 5),
        equals("m/44'/461'/0'/0/5"),
      );
      expect(
        FilecoinUtils.pathFromNetwork(FilecoinNetwork.testnet, 0),
        equals("m/44'/1'/0'/0/0"),
      );
      expect(
        FilecoinUtils.pathFromNetwork(FilecoinNetwork.testnet, 10),
        equals("m/44'/1'/0'/0/10"),
      );
    });
  });

  group('Address Utilities', () {
    test('should validate Ethereum address', () {
      // Valid - all lowercase
      expect(FilecoinUtils.isEthAddress('0x742d35cc6634c0532925a3b844bc9e7595f0beb0'), isTrue);
      expect(FilecoinUtils.isEthAddress('0x0000000000000000000000000000000000000000'), isTrue);
      
      // Valid - all uppercase
      expect(FilecoinUtils.isEthAddress('0x742D35CC6634C0532925A3B844BC9E7595F0BEB0'), isTrue);
      
      // Invalid format
      expect(FilecoinUtils.isEthAddress('742d35Cc6634C0532925a3b844Bc9e7595f0bEb0'), isFalse);
      expect(FilecoinUtils.isEthAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0b'), isFalse);
      expect(FilecoinUtils.isEthAddress('0xGGGd35Cc6634C0532925a3b844Bc9e7595f0bEb0'), isFalse);
    });

    test('should validate ID mask address', () {
      // ID mask address: 0xFF + 11 zeros + 8-byte ID
      expect(
        FilecoinUtils.isIdMaskAddress('0xff00000000000000000000000000000000000001'),
        isTrue,
      );
      expect(
        FilecoinUtils.isIdMaskAddress('0xff00000000000000000000000000000000000064'),
        isTrue,
      );
      
      // Not ID mask (missing 0xFF prefix)
      expect(
        FilecoinUtils.isIdMaskAddress('0x0000000000000000000000000000000000000001'),
        isFalse,
      );
      // Not ID mask (wrong format)
      expect(
        FilecoinUtils.isIdMaskAddress('0xfF00000000000000000000000000000000000001'),
        isFalse,
      );
    });

    test('should compute EIP-55 checksum', () {
      final address = '0x742d35cc6634c0532925a3b844bc9e7595f0beb';
      final checksummed = FilecoinUtils.checksumEthAddress(address);
      
      // Should have mixed case
      expect(checksummed, isNot(equals(address)));
      expect(checksummed.toLowerCase(), equals(address.toLowerCase()));
      
      // Should be consistent
      expect(
        FilecoinUtils.checksumEthAddress(checksummed),
        equals(checksummed),
      );
    });
  });

  group('CID Utilities', () {
    test('should generate Lotus CID correctly', () {
      final data = [1, 2, 3, 4, 5];
      final cid = FilecoinUtils.lotusCid(data);
      
      // CID should start with: 0x01 (CIDv1), 0x71 (dag-cbor), 0xa0e40220 (blake2b-256 multihash)
      expect(cid[0], equals(0x01)); // CIDv1
      expect(cid[1], equals(0x71)); // dag-cbor codec
      expect(cid[2], equals(0xa0)); // blake2b-256 multihash
      expect(cid[3], equals(0xe4)); // multihash continued
      expect(cid[4], equals(0x02)); // multihash continued
      expect(cid[5], equals(0x20)); // 32-byte hash length
      
      // Total length should be 6 (prefix) + 32 (hash) = 38
      expect(cid.length, equals(38));
    });

    test('should generate different CIDs for different data', () {
      final cid1 = FilecoinUtils.lotusCid([1, 2, 3]);
      final cid2 = FilecoinUtils.lotusCid([4, 5, 6]);
      
      expect(cid1, isNot(equals(cid2)));
      
      // But prefixes should be the same
      expect(cid1.sublist(0, 6), equals(cid2.sublist(0, 6)));
    });

    test('should generate same CID for same data', () {
      final data = [1, 2, 3, 4, 5];
      final cid1 = FilecoinUtils.lotusCid(data);
      final cid2 = FilecoinUtils.lotusCid(data);
      
      expect(cid1, equals(cid2));
    });
  });

  group('Edge Cases', () {
    test('should handle empty derivation path components', () {
      // This should fail
      expect(
        () => FilecoinUtils.parseDerivationPath("m////"),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle very large address indices', () {
      final components = FilecoinUtils.parseDerivationPath("m/44'/461'/0'/0/2147483647");
      expect(components.addressIndex, equals(2147483647));
    });

    test('should handle path generation with large index', () {
      final path = FilecoinUtils.pathFromNetwork(FilecoinNetwork.mainnet, 999999);
      expect(path, equals("m/44'/461'/0'/0/999999"));
      
      // Should be parseable
      final components = FilecoinUtils.parseDerivationPath(path);
      expect(components.addressIndex, equals(999999));
    });
  });
}

