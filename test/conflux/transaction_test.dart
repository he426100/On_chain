import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  group('CFXTransaction Tests', () {
    test('Create basic transaction', () {
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final tx = CFXTransaction(
        nonce: BigInt.zero,
        gasPrice: BigInt.from(1000000000),
        gas: BigInt.from(21000),
        to: to,
        value: BigInt.from(1000000000000000000),
        storageLimit: BigInt.zero,
        epochHeight: BigInt.from(12345678),
        chainId: BigInt.from(1029),
        data: [],
      );
      
      expect(tx.nonce, equals(BigInt.zero));
      expect(tx.gasPrice, equals(BigInt.from(1000000000)));
      expect(tx.gas, equals(BigInt.from(21000)));
      expect(tx.to, equals(to));
      expect(tx.value, equals(BigInt.from(1000000000000000000)));
      expect(tx.storageLimit, equals(BigInt.zero));
      expect(tx.epochHeight, equals(BigInt.from(12345678)));
      expect(tx.chainId, equals(BigInt.from(1029)));
    });

    test('Encode unsigned transaction for signing', () {
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final tx = CFXTransaction(
        nonce: BigInt.zero,
        gasPrice: BigInt.from(1000000000),
        gas: BigInt.from(21000),
        to: to,
        value: BigInt.from(1000000000000000000),
        storageLimit: BigInt.zero,
        epochHeight: BigInt.from(12345678),
        chainId: BigInt.from(1029),
        data: [],
      );
      
      final encoded = tx.encodeForSigning();
      
      expect(encoded, isNotEmpty);
      expect(encoded, isA<List<int>>());
    });

    test('Transaction with data', () {
      final to = CFXAddress.fromHex('0x806d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final data = StringUtils.encode('Hello Conflux');
      
      final tx = CFXTransaction(
        nonce: BigInt.zero,
        gasPrice: BigInt.from(1000000000),
        gas: BigInt.from(50000),
        to: to,
        value: BigInt.zero,
        storageLimit: BigInt.from(1024),
        epochHeight: BigInt.from(12345678),
        chainId: BigInt.from(1029),
        data: data,
      );
      
      expect(tx.data, equals(data));
      expect(tx.storageLimit, equals(BigInt.from(1024)));
    });

    test('Get transaction hash for signed transaction', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));
      
      final privateKey = CFXPrivateKey.random();
      final signedTx = builder.sign(privateKey);
      
      final hash = signedTx.getTransactionHash();
      
      expect(hash, isNotEmpty);
      expect(hash.length, equals(32)); // 32 bytes
    });
  });

  group('CFXTransactionBuilder Tests', () {
    test('Build transfer transaction', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));
      
      final tx = builder.build();
      
      expect(tx.value, equals(BigInt.from(1000000000000000000)));
      expect(tx.chainId, equals(BigInt.from(1029)));
    });

    test('Build and sign transaction', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));
      
      final privateKey = CFXPrivateKey.random();
      final signedTx = builder.sign(privateKey);
      
      expect(signedTx.v, isNotNull);
      expect(signedTx.r, isNotNull);
      expect(signedTx.s, isNotNull);
      expect(signedTx.r!.length, equals(32));
      expect(signedTx.s!.length, equals(32));
    });

    test('Build contract call transaction', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final contract = CFXAddress.fromHex('0x806d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final data = BytesUtils.fromHexString('0x12345678');
      
      final builder = CFXTransactionBuilder.contractCall(
        from: from,
        contract: contract,
        data: data,
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(100000));
      builder.setStorageLimit(BigInt.from(1024));
      builder.setEpochHeight(BigInt.from(12345678));
      
      final tx = builder.build();
      
      expect(tx.data, equals(data));
      expect(tx.value, equals(BigInt.zero));
      expect(tx.storageLimit, greaterThan(BigInt.zero));
    });

    test('CopyWith creates new transaction', () {
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final tx1 = CFXTransaction(
        nonce: BigInt.zero,
        gasPrice: BigInt.from(1000000000),
        gas: BigInt.from(21000),
        to: to,
        value: BigInt.from(1000000000000000000),
        storageLimit: BigInt.zero,
        epochHeight: BigInt.from(12345678),
        chainId: BigInt.from(1029),
        data: [],
      );
      
      final tx2 = tx1.copyWith(
        nonce: BigInt.one,
        gasPrice: BigInt.from(2000000000),
      );
      
      expect(tx2.nonce, equals(BigInt.one));
      expect(tx2.gasPrice, equals(BigInt.from(2000000000)));
      expect(tx2.gas, equals(tx1.gas)); // Unchanged
      expect(tx2.to, equals(tx1.to)); // Unchanged
    });
  });

  group('Transaction Serialization Tests', () {
    test('Serialize and deserialize signed transaction', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));
      
      final privateKey = CFXPrivateKey.random();
      final originalTx = builder.sign(privateKey);
      
      final serialized = originalTx.serialize();
      final deserializedTx = CFXTransaction.fromRlp(serialized);
      
      expect(deserializedTx.nonce, equals(originalTx.nonce));
      expect(deserializedTx.gasPrice, equals(originalTx.gasPrice));
      expect(deserializedTx.gas, equals(originalTx.gas));
      expect(deserializedTx.value, equals(originalTx.value));
      expect(deserializedTx.storageLimit, equals(originalTx.storageLimit));
      expect(deserializedTx.epochHeight, equals(originalTx.epochHeight));
      expect(deserializedTx.chainId, equals(originalTx.chainId));
    });

    test('Transaction hash remains consistent', () {
      final from = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      final to = CFXAddress.fromHex('0x206d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
      
      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));
      
      final privateKey = CFXPrivateKey.random();
      final tx1 = builder.sign(privateKey);
      
      final hash1 = tx1.getTransactionHashHex();
      final hash2 = tx1.getTransactionHashHex();
      
      expect(hash1, equals(hash2));
    });
  });
}

