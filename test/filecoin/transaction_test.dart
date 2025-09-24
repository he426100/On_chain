import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  group('Filecoin Transaction Tests', () {
    late FilecoinAddress fromAddress;
    late FilecoinAddress toAddress;

    setUp(() {
      final privateKey = List.generate(32, (i) => i + 1);
      fromAddress = FilecoinSigner.createSecp256k1Address(privateKey);
      toAddress = FilecoinSigner.createSecp256k1Address(List.generate(32, (i) => i + 10));
    });

    test('Transaction creation', () {
      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      expect(transaction.from, equals(fromAddress));
      expect(transaction.to, equals(toAddress));
      expect(transaction.nonce, equals(0));
      expect(transaction.value, equals(BigInt.from(1000000)));
      expect(transaction.gasLimit, equals(1000));
      expect(transaction.gasFeeCap, equals(BigInt.from(100)));
      expect(transaction.gasPremium, equals(BigInt.from(50)));
      expect(transaction.method, equals(FilecoinMethod.send));
      expect(transaction.params, isEmpty);
    });

    test('Transaction JSON serialization', () {
      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 5,
        value: BigInt.from(2000000),
        gasLimit: 2000,
        gasFeeCap: BigInt.from(200),
        gasPremium: BigInt.from(100),
      );

      final json = transaction.toJson();

      expect(json['Version'], equals(0));
      expect(json['From'], equals(fromAddress.toAddress()));
      expect(json['To'], equals(toAddress.toAddress()));
      expect(json['Nonce'], equals(5));
      expect(json['Value'], equals('2000000'));
      expect(json['GasLimit'], equals(2000));
      expect(json['GasFeeCap'], equals('200'));
      expect(json['GasPremium'], equals('100'));
      expect(json['Method'], equals(0));
    });

    test('Transaction with parameters', () {
      final params = [1, 2, 3, 4, 5];
      final transaction = FilecoinTransaction(
        from: fromAddress,
        to: toAddress,
        nonce: 1,
        value: BigInt.from(500000),
        gasLimit: 1500,
        gasFeeCap: BigInt.from(150),
        gasPremium: BigInt.from(75),
        method: FilecoinMethod.invokeEvm,
        params: params,
      );

      expect(transaction.params, equals(params));
      expect(transaction.method, equals(FilecoinMethod.invokeEvm));

      final json = transaction.toJson();
      expect(json['Method'], equals(3844450837));
      expect(json['Params'], isNotNull);
    });

    test('Transaction CID generation', () {
      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final cid = transaction.getCid();
      expect(cid, isNotEmpty);
      expect(cid.length, equals(32)); // Blake2b-256 hash is 32 bytes
    });

    test('Transaction message bytes generation', () {
      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final messageBytes = transaction.getMessageBytes();
      expect(messageBytes, isNotEmpty);
    });

    test('Transaction toString', () {
      final transaction = FilecoinTransaction.transfer(
        from: fromAddress,
        to: toAddress,
        nonce: 0,
        value: BigInt.from(1000000),
        gasLimit: 1000,
        gasFeeCap: BigInt.from(100),
        gasPremium: BigInt.from(50),
      );

      final string = transaction.toString();
      expect(string, contains('FilecoinTransaction'));
      expect(string, contains(fromAddress.toString()));
      expect(string, contains(toAddress.toString()));
      expect(string, contains('1000000'));
    });

    test('Method enum values', () {
      expect(FilecoinMethod.send.value, equals(0));
      expect(FilecoinMethod.invokeEvm.value, equals(3844450837));
    });
  });
}