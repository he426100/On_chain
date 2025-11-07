import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  group('CFXAddress Tests', () {
    group('Base32 encoding/decoding (Helios compatibility)', () {
      // Test examples from helios/packages/base32-address/index.test.js
      // These ensure 100% compatibility with the JavaScript implementation
      
      test('Null address (all zeros)', () {
        final hexAddress = '0x0000000000000000000000000000000000000000';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        expect(address.toBase32(), 'cfx:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0sfbnjm2');
        expect(address.addressType, CFXAddressType.nullAddress);
        
        // Test verbose format
        final verboseAddress = CFXAddress('CFX:TYPE.NULL:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0SFBNJM2');
        expect(verboseAddress.toHex().toLowerCase(), hexAddress);
        expect(verboseAddress.networkId, 1029);
      });
      
      test('User address - example 1', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        expect(address.toBase32(), 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p');
        
        // Test verbose format (case insensitive)
        final verboseAddress = CFXAddress('CFX:TYPE.USER:AAJG4WT2MBMBB44SP6SZD783RY0JTAD5BEA80XDY7P');
        expect(verboseAddress.toHex().toLowerCase(), hexAddress);
      });
      
      test('User address - example 2', () {
        final hexAddress = '0x1a2f80341409639ea6a35bbcab8299066109aa55';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        expect(address.toBase32(), 'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg');
        
        // Test verbose format
        final verboseAddress = CFXAddress('CFX:TYPE.USER:AARC9ABYCUE0HHZGYRR53M6CXEDGCCRMMYYBJGH4XG');
        expect(verboseAddress.toHex().toLowerCase(), hexAddress);
      });
      
      test('Contract address', () {
        final hexAddress = '0x806d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        expect(address.toBase32(), 'cfx:acag4wt2mbmbb44sp6szd783ry0jtad5bex25t8vc9');
        expect(address.addressType, CFXAddressType.contract);
        
        // Test verbose format
        final verboseAddress = CFXAddress('CFX:TYPE.CONTRACT:ACAG4WT2MBMBB44SP6SZD783RY0JTAD5BEX25T8VC9');
        expect(verboseAddress.toHex().toLowerCase(), hexAddress);
      });
      
      test('Builtin address', () {
        final hexAddress = '0x006d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        expect(address.toBase32(), 'cfx:aaag4wt2mbmbb44sp6szd783ry0jtad5beaar3k429');
        expect(address.addressType, CFXAddressType.builtin);
        
        // Test verbose format
        final verboseAddress = CFXAddress('CFX:TYPE.BUILTIN:AAAG4WT2MBMBB44SP6SZD783RY0JTAD5BEAAR3K429');
        expect(verboseAddress.toHex().toLowerCase(), hexAddress);
      });
      
      test('Different networks', () {
        // Mainnet (1029)
        final mainnet = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
        expect(mainnet.toBase32(), 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p');
        
        // Testnet (1)
        final testnet = CFXAddress.fromHex('0x806d49f8505410eb4e671d51f7d96d2c87807b09', 1);
        expect(testnet.toBase32(), 'cfxtest:acag4wt2mbmbb44sp6szd783ry0jtad5be3xj925gz');
        
        // Custom network (10086)
        final custom = CFXAddress.fromHex('0x006d49f8505410eb4e671d51f7d96d2c87807b09', 10086);
        expect(custom.toBase32(), 'net10086:aaag4wt2mbmbb44sp6szd783ry0jtad5benr1ap5gp');
      });
    });

    group('Base32 encoding/decoding (additional)', () {
      test('Mainnet user address', () {
        final hexAddress = '0x1063E0B1B39C08806E5E445D633C70D66E401750';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.networkId, 1029);
        expect(address.addressType, CFXAddressType.user);
        expect(address.toBase32(), startsWith('cfx:'));
        expect(address.toHex().toLowerCase(), hexAddress.toLowerCase());
      });

      test('Testnet user address', () {
        final hexAddress = '0x1063E0B1B39C08806E5E445D633C70D66E401750';
        final address = CFXAddress.fromHex(hexAddress, 1);
        
        expect(address.networkId, 1);
        expect(address.addressType, CFXAddressType.user);
        expect(address.toBase32(), startsWith('cfxtest:'));
        expect(address.toHex().toLowerCase(), hexAddress.toLowerCase());
      });

      test('Contract address', () {
        final hexAddress = '0x8063E0B1B39C08806E5E445D633C70D66E401750';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.contract);
        expect(address.toBase32(), startsWith('cfx:'));
      });

      test('Null address', () {
        final hexAddress = '0x0000000000000000000000000000000000000000';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.nullAddress);
      });

      test('Builtin address', () {
        final hexAddress = '0x0000000000000000000000000000000000000001';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.builtin);
      });
    });

    group('Address type identification', () {
      test('User address (type 0x1)', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.user);
      });

      test('Contract address (type 0x8)', () {
        final hexAddress = '0x806d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.contract);
      });

      test('Builtin address (type 0x0, non-zero)', () {
        final hexAddress = '0x0000000000000000000000000000000000000005';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.builtin);
      });

      test('Null address (all zeros)', () {
        final hexAddress = '0x0000000000000000000000000000000000000000';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.addressType, CFXAddressType.nullAddress);
      });
    });

    group('Verbose format', () {
      test('Mainnet verbose format', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        final verbose = address.toBase32(verbose: true);
        expect(verbose, contains('type.'));
        expect(verbose, startsWith('cfx:'));
      });

      test('Testnet verbose format', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1);
        
        final verbose = address.toBase32(verbose: true);
        expect(verbose, contains('type.'));
        expect(verbose, startsWith('cfxtest:'));
      });
    });

    group('Network ID', () {
      test('Different network IDs produce different addresses', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        
        final mainnet = CFXAddress.fromHex(hexAddress, 1029);
        final testnet = CFXAddress.fromHex(hexAddress, 1);
        final custom = CFXAddress.fromHex(hexAddress, 999);
        
        expect(mainnet.toBase32(), isNot(equals(testnet.toBase32())));
        expect(mainnet.toBase32(), isNot(equals(custom.toBase32())));
        expect(testnet.toBase32(), isNot(equals(custom.toBase32())));
      });

      test('Same hex, different networks maintain hex equality', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        
        final mainnet = CFXAddress.fromHex(hexAddress, 1029);
        final testnet = CFXAddress.fromHex(hexAddress, 1);
        
        expect(mainnet.toHex().toLowerCase(), equals(testnet.toHex().toLowerCase()));
      });
    });

    group('Roundtrip conversion', () {
      test('Hex -> Base32 -> Hex', () {
        final original = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(original, 1029);
        final base32 = address.toBase32();
        final decoded = CFXAddress(base32);
        
        expect(decoded.toHex().toLowerCase(), equals(original.toLowerCase()));
        expect(decoded.networkId, equals(1029));
      });

      test('Base32 -> Hex -> Base32', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        final original = address.toBase32();
        
        final decoded = CFXAddress(original);
        final hex = decoded.toHex();
        final reencoded = CFXAddress.fromHex(hex, 1029);
        
        expect(reencoded.toBase32(), equals(original));
      });
    });

    group('Edge cases', () {
      test('Minimum address value', () {
        final hexAddress = '0x0000000000000000000000000000000000000001';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.toHex().toLowerCase(), contains('0x'));
        expect(address.toBase32(), isNotEmpty);
      });

      test('Maximum address value', () {
        final hexAddress = '0xffffffffffffffffffffffffffffffffffffffff';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.toHex().toLowerCase(), contains('0xf'));
        expect(address.toBase32(), isNotEmpty);
      });

      test('Mixed case hex address', () {
        final hexAddress = '0x106d49F8505410EB4e671d51F7d96d2c87807B09';
        final address = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(address.toHex().toLowerCase(), equals('0x106d49f8505410eb4e671d51f7d96d2c87807b09'));
      });
    });

    group('Equality', () {
      test('Same hex and network are equal', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        
        final addr1 = CFXAddress.fromHex(hexAddress, 1029);
        final addr2 = CFXAddress.fromHex(hexAddress, 1029);
        
        expect(addr1, equals(addr2));
        expect(addr1.hashCode, equals(addr2.hashCode));
      });

      test('Different networks are not equal', () {
        final hexAddress = '0x106d49f8505410eb4e671d51f7d96d2c87807b09';
        
        final mainnet = CFXAddress.fromHex(hexAddress, 1029);
        final testnet = CFXAddress.fromHex(hexAddress, 1);
        
        expect(mainnet, isNot(equals(testnet)));
      });

      test('Different hex addresses are not equal', () {
        final addr1 = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
        final addr2 = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
        
        expect(addr1, isNot(equals(addr2)));
      });
    });
  });

  group('ESpaceAddress Tests', () {
    test('Create from 0x address', () {
      final address = ESpaceAddress('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed');
      
      expect(address.toHex(), contains('0x'));
      expect(address.toHex().length, equals(42));
    });

    test('Convert to Core Space address', () {
      final eSpace = ESpaceAddress('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed');
      final coreSpace = eSpace.toCoreSpaceAddress(1029);
      
      expect(coreSpace.networkId, equals(1029));
      expect(coreSpace.toBase32(), startsWith('cfx:'));
    });

    test('eSpace addresses are case-insensitive', () {
      final addr1 = ESpaceAddress('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed');
      final addr2 = ESpaceAddress('0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed');
      
      expect(addr1.toHex().toLowerCase(), equals(addr2.toHex().toLowerCase()));
    });

    test('Round trip eSpace -> Core -> eSpace preserves hex', () {
      final original = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
      final eSpace = ESpaceAddress(original);
      final coreSpace = eSpace.toCoreSpaceAddress(1029);
      
      expect(coreSpace.toHex().toLowerCase(), equals(original.toLowerCase()));
    });
  });
}
