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
}

