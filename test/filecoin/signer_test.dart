import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Signer Tests', () {
    late List<int> privateKey;
    late FilecoinAddress secp256k1Address;
    late FilecoinAddress delegatedAddress;

    setUp(() {
      privateKey = List.generate(32, (i) => i + 1);
      secp256k1Address = FilecoinSigner.createSecp256k1Address(privateKey);
      delegatedAddress = FilecoinSigner.createDelegatedAddress(privateKey);
    });

    test('Create SECP256K1 address from private key', () {
      final address = FilecoinSigner.createSecp256k1Address(privateKey);
      expect(address.type, equals(FilecoinAddressType.secp256k1));
      expect(address.toAddress().startsWith('f1'), isTrue);
    });

    test('Create delegated address from private key', () {
      final address = FilecoinSigner.createDelegatedAddress(privateKey);
      expect(address.type, equals(FilecoinAddressType.delegated));
      expect(address.toAddress().startsWith('f4'), isTrue);
      expect(address.actorId, equals(FilecoinAddress.ethereumAddressManagerActorId));
    });

    test('Sign transaction with SECP256K1', () {
      final transaction = FilecoinTransaction.transfer(
        from: secp256k1Address,
        to: delegatedAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      expect(signedTransaction.message, equals(transaction));
      expect(signedTransaction.signature.type, equals(FilecoinSignatureType.secp256k1));
      expect(signedTransaction.signature.data, isNotEmpty);
    });

    test('Sign transaction with delegated address', () {
      final transaction = FilecoinTransaction.transfer(
        from: delegatedAddress,
        to: secp256k1Address,
        nonce: 1,
        value: BigInt.from(2000000),
        gasLimit: 1500,
        gasFeeCap: BigInt.from(150),
        gasPremium: BigInt.from(75),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      expect(signedTransaction.message, equals(transaction));
      expect(signedTransaction.signature.type, equals(FilecoinSignatureType.delegated));
      expect(signedTransaction.signature.data, isNotEmpty);
    });

    test('Signed transaction JSON serialization', () {
      final transaction = FilecoinTransaction.transfer(
        from: secp256k1Address,
        to: delegatedAddress,
        nonce: 2,
        value: BigInt.from(500000),
        gasLimit: 800,
        gasFeeCap: BigInt.from(80),
        gasPremium: BigInt.from(40),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      final json = signedTransaction.toJson();
      expect(json, containsPair('Message', isA<Map<String, dynamic>>()));
      expect(json, containsPair('Signature', isA<Map<String, dynamic>>()));

      final messageJson = json['Message'] as Map<String, dynamic>;
      expect(messageJson['From'], equals(secp256k1Address.toAddress()));
      expect(messageJson['To'], equals(delegatedAddress.toAddress()));
      expect(messageJson['Nonce'], equals(2));
      expect(messageJson['Value'], equals('500000'));

      final signatureJson = json['Signature'] as Map<String, dynamic>;
      expect(signatureJson['Type'], equals(1)); // SECP256K1
      expect(signatureJson['Data'], isA<String>());
    });

    test('Signature verification (basic)', () {
      final transaction = FilecoinTransaction.transfer(
        from: secp256k1Address,
        to: delegatedAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      final isValid = FilecoinSigner.verifySignature(
        transaction: transaction,
        signature: signedTransaction.signature,
        senderAddress: secp256k1Address,
      );

      expect(isValid, isTrue);
    });

    test('Signature type enum values', () {
      expect(FilecoinSignatureType.secp256k1.value, equals(1));
      expect(FilecoinSignatureType.delegated.value, equals(3));
    });

    test('Signature data format', () {
      final transaction = FilecoinTransaction.transfer(
        from: secp256k1Address,
        to: delegatedAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final signedTransaction = FilecoinSigner.signTransaction(
        transaction: transaction,
        privateKey: privateKey,
      );

      // Signature should be exactly 65 bytes (r + s + v)
      // 32 bytes for r, 32 bytes for s, 1 byte for recovery ID
      expect(signedTransaction.signature.data.length, equals(65));
    });

    test('Different private keys produce different signatures', () {
      final privateKey2 = List.generate(32, (i) => i + 100);
      final address2 = FilecoinSigner.createSecp256k1Address(privateKey2);

      final transaction1 = FilecoinTransaction.transfer(
        from: secp256k1Address,
        to: delegatedAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final transaction2 = FilecoinTransaction.transfer(
        from: address2,
        to: delegatedAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final signed1 = FilecoinSigner.signTransaction(
        transaction: transaction1,
        privateKey: privateKey,
      );

      final signed2 = FilecoinSigner.signTransaction(
        transaction: transaction2,
        privateKey: privateKey2,
      );

      expect(signed1.signature.data, isNot(equals(signed2.signature.data)));
    });
  });
}