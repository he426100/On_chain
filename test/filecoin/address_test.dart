import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Address Tests', () {
    test('Address creation from secp256k1 public key', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final secp256k1PrivKey = Secp256k1PrivateKey.fromBytes(privateKey);
      final publicKey = secp256k1PrivKey.publicKey.uncompressed;

      final address = FilecoinAddress.fromSecp256k1PublicKey(publicKey);
      expect(address.type, equals(FilecoinAddressType.secp256k1));
      expect(address.toAddress().startsWith('f1'), isTrue);
    });

    test('Address creation from delegated public key', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final secp256k1PrivKey = Secp256k1PrivateKey.fromBytes(privateKey);
      final publicKey = secp256k1PrivKey.publicKey.uncompressed;

      final address = FilecoinAddress.fromDelegatedPublicKey(publicKey);
      expect(address.type, equals(FilecoinAddressType.delegated));
      expect(address.toAddress().startsWith('f4'), isTrue);
    });

    test('ID address parsing', () {
      final address = FilecoinAddress.fromString('f0123');
      expect(address.type, equals(FilecoinAddressType.id));
      expect(address.actorId, equals(123));
      expect(address.payload, isEmpty);
    });

    test('Address validation', () {
      expect(FilecoinAddress.isValidAddress('f0123'), isTrue);
      expect(FilecoinAddress.isValidAddress('invalid'), isFalse);
      expect(FilecoinAddress.isValidAddress(''), isFalse);
    });

    test('Address equality', () {
      final addr1 = FilecoinAddress.fromString('f0123');
      final addr2 = FilecoinAddress.fromString('f0123');
      final addr3 = FilecoinAddress.fromString('f0456');

      expect(addr1, equals(addr2));
      expect(addr1, isNot(equals(addr3)));
    });

    test('Address toString', () {
      final address = FilecoinAddress.fromString('f0123');
      expect(address.toString(), equals('f0123'));
    });

    test('Address types validation', () {
      for (final type in FilecoinAddressType.values) {
        expect(FilecoinAddressType.fromValue(type.value), equals(type));
      }
    });

    test('Address round trip conversion', () {
      final privateKey = List.generate(32, (i) => i + 1);
      final secp256k1PrivKey = Secp256k1PrivateKey.fromBytes(privateKey);
      final publicKey = secp256k1PrivKey.publicKey.uncompressed;

      final address = FilecoinAddress.fromSecp256k1PublicKey(publicKey);
      final addressString = address.toAddress();
      final parsedAddress = FilecoinAddress.fromString(addressString);

      expect(parsedAddress, equals(address));
      expect(parsedAddress.type, equals(address.type));
      expect(parsedAddress.actorId, equals(address.actorId));
    });
  });
}