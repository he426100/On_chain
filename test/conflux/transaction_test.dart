import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:on_chain/conflux/src/models/access_list.dart';
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

  group('EIP-2930 Transaction Tests', () {
    test('Create and sign EIP-2930 transaction', () {
      final privateKey = CFXPrivateKey.fromBytes(
        BytesUtils.fromHexString('0x0123456789012345678901234567890123456789012345678901234567890123'),
      );
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final accessList = [
        AccessListEntry(
          address: '0x1234567890123456789012345678901234567890',
          storageKeys: [
            '0x0000000000000000000000000000000000000000000000000000000000000001',
            '0x0000000000000000000000000000000000000000000000000000000000000002',
          ],
        ),
      ];

      final builder = CFXTransactionBuilder.eip2930Transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000), // 1 CFX
        chainId: BigInt.from(1029),
        accessList: accessList,
      );

      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000)); // 1 GDrip
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));

      final signedTx = builder.sign(privateKey);

      expect(signedTx.isSigned, isTrue);
      expect(signedTx.type, equals(CFXTransactionType.eip2930));
      expect(signedTx.accessList, isNotNull);
      expect(signedTx.accessList!.length, equals(1));
      expect(signedTx.gasPrice, equals(BigInt.from(1000000000)));
      expect(signedTx.maxFeePerGas, isNull);
      expect(signedTx.maxPriorityFeePerGas, isNull);
    });

    test('EIP-2930 transaction serialization has correct prefix', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip2930Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
      );

      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();

      // Check for "cfx\x01" prefix
      expect(serialized[0], equals(0x63)); // 'c'
      expect(serialized[1], equals(0x66)); // 'f'
      expect(serialized[2], equals(0x78)); // 'x'
      expect(serialized[3], equals(0x01)); // type 1
    });

    test('EIP-2930 transaction can be encoded for signing', () {
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip2930Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
      );

      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final unsignedTx = builder.build();
      final encoded = unsignedTx.encodeForSigning();

      expect(encoded.length, greaterThan(0));
      // Should start with "cfx\x01" prefix
      expect(encoded[0], equals(0x63));
      expect(encoded[1], equals(0x66));
      expect(encoded[2], equals(0x78));
      expect(encoded[3], equals(0x01));
    });

    test('Add access list entry dynamically', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip2930Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
      );

      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      // Add access list entries
      builder.addAccessListEntry(
        '0x1234567890123456789012345678901234567890',
        ['0x0000000000000000000000000000000000000000000000000000000000000001'],
      );
      builder.addAccessListEntry(
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
        ['0x0000000000000000000000000000000000000000000000000000000000000002'],
      );

      final signedTx = builder.sign(privateKey);

      expect(signedTx.accessList, isNotNull);
      expect(signedTx.accessList!.length, equals(2));
      expect(signedTx.accessList![0].address, equals('0x1234567890123456789012345678901234567890'));
      expect(signedTx.accessList![1].address, equals('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'));
    });
  });

  group('EIP-1559 Transaction Tests', () {
    test('Create and sign EIP-1559 transaction', () {
      final privateKey = CFXPrivateKey.fromBytes(
        BytesUtils.fromHexString('0x0123456789012345678901234567890123456789012345678901234567890123'),
      );
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000), // 1 CFX
        chainId: BigInt.from(1029),
        maxFeePerGas: BigInt.from(2000000000),
        maxPriorityFeePerGas: BigInt.from(1000000000),
      );

      builder.setNonce(BigInt.zero);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(12345678));

      final signedTx = builder.sign(privateKey);

      expect(signedTx.isSigned, isTrue);
      expect(signedTx.type, equals(CFXTransactionType.eip1559));
      expect(signedTx.maxFeePerGas, equals(BigInt.from(2000000000)));
      expect(signedTx.maxPriorityFeePerGas, equals(BigInt.from(1000000000)));
      expect(signedTx.gasPrice, isNull);
    });

    test('EIP-1559 transaction serialization has correct prefix', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
        maxFeePerGas: BigInt.from(2000000000),
        maxPriorityFeePerGas: BigInt.from(1000000000),
      );

      builder.setNonce(BigInt.zero);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();

      // Check for "cfx\x02" prefix
      expect(serialized[0], equals(0x63)); // 'c'
      expect(serialized[1], equals(0x66)); // 'f'
      expect(serialized[2], equals(0x78)); // 'x'
      expect(serialized[3], equals(0x02)); // type 2
    });

    test('EIP-1559 transaction with access list', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final accessList = [
        AccessListEntry(
          address: '0x1234567890123456789012345678901234567890',
          storageKeys: [
            '0x0000000000000000000000000000000000000000000000000000000000000001',
          ],
        ),
      ];

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
        maxFeePerGas: BigInt.from(2000000000),
        maxPriorityFeePerGas: BigInt.from(1000000000),
        accessList: accessList,
      );

      builder.setNonce(BigInt.zero);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final signedTx = builder.sign(privateKey);

      expect(signedTx.type, equals(CFXTransactionType.eip1559));
      expect(signedTx.accessList, isNotNull);
      expect(signedTx.accessList!.length, equals(1));
    });

    test('EIP-1559 builder requires max fees', () {
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
        // Not providing maxFeePerGas and maxPriorityFeePerGas
      );

      builder.setNonce(BigInt.zero);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      expect(
        () => builder.build(),
        throwsA(isA<InvalidConfluxTransactionException>()),
      );
    });

    test('EIP-1559 transaction JSON includes max fees', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
        maxFeePerGas: BigInt.from(2000000000),
        maxPriorityFeePerGas: BigInt.from(1000000000),
      );

      builder.setNonce(BigInt.zero);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final signedTx = builder.sign(privateKey);
      final json = signedTx.toJson();

      expect(json['type'], equals(2));
      expect(json['maxFeePerGas'], isNotNull);
      expect(json['maxPriorityFeePerGas'], isNotNull);
      expect(json['gasPrice'], isNull);
    });
  });

  group('Transaction Decoding Tests', () {
    test('Decode legacy transaction from raw', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );

      builder.setNonce(BigInt.from(5));
      builder.setGasPrice(BigInt.from(1500000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(999999));

      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();

      // Decode back
      final decoded = CFXTransaction.fromRawTransaction(serialized);

      expect(decoded.type, equals(CFXTransactionType.legacy));
      expect(decoded.nonce, equals(BigInt.from(5)));
      expect(decoded.gasPrice, equals(BigInt.from(1500000000)));
      expect(decoded.gas, equals(BigInt.from(21000)));
      expect(decoded.value, equals(BigInt.from(1000000000000000000)));
      expect(decoded.isSigned, isTrue);
    });

    test('Decode EIP-2930 transaction from raw', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final accessList = [
        AccessListEntry(
          address: '0x1234567890123456789012345678901234567890',
          storageKeys: ['0x0000000000000000000000000000000000000000000000000000000000000001'],
        ),
      ];

      final builder = CFXTransactionBuilder.eip2930Transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
        accessList: accessList,
      );

      builder.setNonce(BigInt.from(3));
      builder.setGasPrice(BigInt.from(2000000000));
      builder.setGas(BigInt.from(30000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(888888));

      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();

      // Decode back
      final decoded = CFXTransaction.fromRawTransaction(serialized);

      expect(decoded.type, equals(CFXTransactionType.eip2930));
      expect(decoded.nonce, equals(BigInt.from(3)));
      expect(decoded.gasPrice, equals(BigInt.from(2000000000)));
      expect(decoded.accessList, isNotNull);
      expect(decoded.accessList!.length, equals(1));
      expect(decoded.isSigned, isTrue);
    });

    test('Decode EIP-1559 transaction from raw', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.eip1559Transfer(
        from: from,
        to: to,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
        maxFeePerGas: BigInt.from(3000000000),
        maxPriorityFeePerGas: BigInt.from(1500000000),
      );

      builder.setNonce(BigInt.from(7));
      builder.setGas(BigInt.from(25000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(777777));

      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();

      // Decode back
      final decoded = CFXTransaction.fromRawTransaction(serialized);

      expect(decoded.type, equals(CFXTransactionType.eip1559));
      expect(decoded.nonce, equals(BigInt.from(7)));
      expect(decoded.maxFeePerGas, equals(BigInt.from(3000000000)));
      expect(decoded.maxPriorityFeePerGas, equals(BigInt.from(1500000000)));
      expect(decoded.gasPrice, isNull);
      expect(decoded.isSigned, isTrue);
    });

    test('Decode transaction from hex string', () {
      final privateKey = CFXPrivateKey.random();
      
      final from = CFXAddress.fromHex('0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f', 1029);
      
      final to = CFXAddress.fromBase32(
        'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
      );

      final builder = CFXTransactionBuilder.transfer(
        from: from,
        to: to,
        value: BigInt.one,
        chainId: BigInt.from(1029),
      );

      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.from(1000000000));
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.from(1000000));

      final signedTx = builder.sign(privateKey);
      final hexString = '0x${BytesUtils.toHexString(signedTx.serialize())}';

      // Decode from hex string
      final decoded = CFXTransaction.fromRawTransaction(hexString);

      expect(decoded.type, equals(CFXTransactionType.legacy));
      expect(decoded.nonce, equals(BigInt.zero));
      expect(decoded.isSigned, isTrue);
    });
  });

  group('Additional Transaction Tests from js-conflux-sdk', () {
    // 来自 js-conflux-sdk/test/transaction.test.js 的测试
    const testPrivateKey = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const networkId = 1;

    test('Transaction with s starting with 0x00 (edge case)', () {
      // 来自 transaction.test.js line 126-142
      // 测试签名中 s 值以 0x00 开头的特殊情况
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final to = CFXAddress.fromHex('0x0123456789012345678901234567890123456789', networkId);
      
      final builder = CFXTransactionBuilder.transfer(
        from: privateKey.publicKey().toAddress(networkId),
        to: to,
        value: BigInt.zero,
        chainId: BigInt.from(networkId),
      );
      
      builder.setNonce(BigInt.from(127)); // 特殊 nonce 导致 s 以 0x00 开头
      builder.setGasPrice(BigInt.one);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.zero);
      
      final signedTx = builder.sign(privateKey);
      
      // 验证签名的 s 值
      expect(signedTx.s, isNotNull);
      final sHex = BytesUtils.toHexString(signedTx.s!, prefix: '0x');
      
      // 来自 js-conflux-sdk 的预期值
      expect(
        sHex,
        equals('0x233f41b647de5846856106a8bc0fb67ba4dc3c184d328e565547928adedc8f3c'),
      );
      
      // 验证序列化结果
      final serialized = BytesUtils.toHexString(signedTx.serialize(), prefix: '0x');
      expect(
        serialized,
        equals('0xf863df7f01825208940123456789012345678901234567890123456789808080018001a0bde07fe87c58cf83c50a4787c637a05a521d5f8372bd8acb207504e8af2daee4a0233f41b647de5846856106a8bc0fb67ba4dc3c184d328e565547928adedc8f3c'),
      );
    });

    test('Decode transaction with null to address (contract deployment)', () {
      // 来自 transaction.test.js line 144-159
      final privateKey = CFXPrivateKey(testPrivateKey);
      
      final builder = CFXTransactionBuilder.deploy(
        from: privateKey.publicKey().toAddress(networkId),
        bytecode: [],
        chainId: BigInt.from(networkId),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.one);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.zero);
      
      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();
      
      // Decode and verify null to address
      final decoded = CFXTransaction.fromRawTransaction(serialized);
      expect(decoded.to, isNull);
    });

    test('Transaction with data field', () {
      // 来自 transaction.test.js line 160-171
      final privateKey = CFXPrivateKey(testPrivateKey);
      final data = StringUtils.encode('Example data');
      
      final to = CFXAddress.fromHex('0x0123456789012345678901234567890123456789', networkId);
      
      final builder = CFXTransactionBuilder.transfer(
        from: privateKey.publicKey().toAddress(networkId),
        to: to,
        value: BigInt.zero,
        chainId: BigInt.from(networkId),
      );
      
      builder.setNonce(BigInt.zero);
      builder.setGasPrice(BigInt.one);
      builder.setGas(BigInt.from(21000));
      builder.setStorageLimit(BigInt.zero);
      builder.setEpochHeight(BigInt.zero);
      builder.setData(data);
      
      final signedTx = builder.sign(privateKey);
      final serialized = signedTx.serialize();
      
      // Decode and verify data field
      final decoded = CFXTransaction.fromRawTransaction(serialized);
      expect(decoded.data, equals(data));
    });

    test('EIP-2930 transaction encode and decode', () {
      // 来自 transaction.test.js line 173-181
      const hex = '0x63667801f8a8f8636464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef01a0e3e73f1ae5a109b01f5f64b97c7eae0c870da2c050969916d0a440ac2eef0ca3a04e8c4415db648707bd6d4c7708793b04f5404ff38e873fb78f1a6474e36a2579';
      
      final decoded = CFXTransaction.fromRawTransaction(hex);
      
      expect(decoded.type, equals(CFXTransactionType.eip2930));
      expect(decoded.chainId, equals(BigInt.from(100)));
      expect(decoded.nonce, equals(BigInt.from(100)));
      expect(decoded.value, equals(BigInt.from(100)));
      expect(decoded.accessList, isNotNull);
    });

    test('EIP-1559 transaction encode and decode', () {
      // 来自 transaction.test.js line 183-193
      const hex = '0x63667802f8a9f864646464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef80a069a44af3ab58ea8be86d21262e900279adc674248a23df5771406545163c1383a0248424d9019fb6c0ecb59c0df3841623fada8fe829cf15e77b6d777accc7cfec';
      
      final decoded = CFXTransaction.fromRawTransaction(hex);
      
      expect(decoded.type, equals(CFXTransactionType.eip1559));
      expect(decoded.chainId, equals(BigInt.from(100)));
      expect(decoded.nonce, equals(BigInt.from(100)));
      expect(decoded.value, equals(BigInt.from(100)));
      expect(decoded.maxFeePerGas, equals(BigInt.from(100)));
      expect(decoded.maxPriorityFeePerGas, equals(BigInt.from(100)));
      expect(decoded.accessList, isNotNull);
    });
  });
}

