import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:on_chain/conflux/src/models/access_list.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// 这些测试用例直接来自 js-conflux-sdk 的官方测试
/// 确保我们的 Dart 实现与 JavaScript SDK 完全兼容
/// 
/// 参考: 
/// - js-conflux-sdk/test/transaction.test.js
/// - js-conflux-sdk/test/conflux/sendTransaction.test.js
void main() {
  group('js-conflux-sdk Compatibility Tests', () {
    // 来自 js-conflux-sdk/test/index.js 的测试密钥
    const testPrivateKey = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    
    // 预期的测试地址（chainId=1, testnet）
    const expectedAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
    
    group('Basic Transaction Signing and Serialization', () {
      // 来自 transaction.test.js 第7-16行
      test('Should match js-conflux-sdk transaction signature', () {
        final privateKey = CFXPrivateKey(testPrivateKey);
        final networkId = 1; // testnet
        
        // 来自 transaction.test.js 第7-16行的 txMeta
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
        
        final signedTx = builder.sign(privateKey);
        
        // 来自 transaction.test.js 第83-85行的预期值
        expect(
          BytesUtils.toHexString(signedTx.r!, prefix: '0x'),
          equals('0xef53e4af065905cb5134f7de4e9434e71656f824e3e268a9babb4f14ff808113'),
        );
        expect(
          BytesUtils.toHexString(signedTx.s!, prefix: '0x'),
          equals('0x407f05f44f79c1fd19262665d3efc29368e317fe5e77be27c0c1314b6a242a1e'),
        );
        // 关键：v值应该等于1（recovery ID）
        expect(signedTx.v, equals(1));
        
        // 来自 transaction.test.js 第18行的预期序列化结果
        const expectedRawTx = '0xf863df8001825208940123456789012345678901234567890123456789808080018001a0ef53e4af065905cb5134f7de4e9434e71656f824e3e268a9babb4f14ff808113a0407f05f44f79c1fd19262665d3efc29368e317fe5e77be27c0c1314b6a242a1e';
        
        final serialized = BytesUtils.toHexString(signedTx.serialize(), prefix: '0x');
        expect(serialized, equals(expectedRawTx));
        
        // 来自 transaction.test.js 第87行的预期交易哈希
        const expectedHash = '0x9e463f32428c7c4026575d132e8c4e5d6fe387322fce5234103e52f4ab39b053';
        expect(signedTx.getTransactionHashHex(), equals(expectedHash));
      });
      
      // 来自 transaction.test.js 第126-142行：测试以0x00开头的s值
      test('Should handle signature with leading 0x00 in s', () {
        final privateKey = CFXPrivateKey(testPrivateKey);
        final networkId = 1;
        
        final to = CFXAddress.fromHex('0x0123456789012345678901234567890123456789', networkId);
        
        final builder = CFXTransactionBuilder.transfer(
          from: privateKey.publicKey().toAddress(networkId),
          to: to,
          value: BigInt.zero,
          chainId: BigInt.from(networkId),
        );
        
        // 注意：nonce = 127 会产生一个以0x00开头的s值
        builder.setNonce(BigInt.from(127));
        builder.setGasPrice(BigInt.one);
        builder.setGas(BigInt.from(21000));
        builder.setStorageLimit(BigInt.zero);
        builder.setEpochHeight(BigInt.zero);
        
        final signedTx = builder.sign(privateKey);
        
        // 来自 transaction.test.js 第140行
        expect(
          BytesUtils.toHexString(signedTx.s!, prefix: '0x'),
          equals('0x233f41b647de5846856106a8bc0fb67ba4dc3c184d328e565547928adedc8f3c'),
        );
        
        // 来自 transaction.test.js 第141行
        const expectedSerialized = '0xf863df7f01825208940123456789012345678901234567890123456789808080018001a0bde07fe87c58cf83c50a4787c637a05a521d5f8372bd8acb207504e8af2daee4a0233f41b647de5846856106a8bc0fb67ba4dc3c184d328e565547928adedc8f3c';
        expect(
          BytesUtils.toHexString(signedTx.serialize(), prefix: '0x'),
          equals(expectedSerialized),
        );
      });
    });
    
    group('Transaction Decoding', () {
      // 来自 transaction.test.js 第144-171行
      test('Should decode raw legacy transaction', () {
        const rawTx = '0xf863df8001825208940123456789012345678901234567890123456789808080018001a0ef53e4af065905cb5134f7de4e9434e71656f824e3e268a9babb4f14ff808113a0407f05f44f79c1fd19262665d3efc29368e317fe5e77be27c0c1314b6a242a1e';
        
        final decoded = CFXTransaction.fromRawTransaction(rawTx);
        
        expect(decoded.chainId, equals(BigInt.one));
        expect(decoded.nonce, equals(BigInt.zero));
        expect(decoded.gasPrice, equals(BigInt.one));
        expect(decoded.gas, equals(BigInt.from(21000)));
        expect(decoded.to?.toHex(), equals('0x0123456789012345678901234567890123456789'));
        expect(decoded.value, equals(BigInt.zero));
        expect(decoded.storageLimit, equals(BigInt.zero));
        expect(decoded.epochHeight, equals(BigInt.zero));
        expect(decoded.isSigned, isTrue);
        expect(decoded.v, equals(1));
      });
      
      // 测试空 to 地址（合约部署）
      test('Should decode transaction with empty to address', () {
        final privateKey = CFXPrivateKey(testPrivateKey);
        
        final builder = CFXTransactionBuilder.contractCall(
          from: privateKey.publicKey().toAddress(1),
          contract: privateKey.publicKey().toAddress(1), // 不会使用
          data: [],
          chainId: BigInt.one,
        );
        
        // 手动设置为null来创建合约部署交易
        final tx = CFXTransaction(
          nonce: BigInt.zero,
          gasPrice: BigInt.one,
          gas: BigInt.from(21000),
          to: null, // 合约部署
          value: BigInt.zero,
          storageLimit: BigInt.zero,
          epochHeight: BigInt.zero,
          chainId: BigInt.one,
          data: [],
        );
        
        final signed = tx.copyWith(
          r: List.filled(32, 1),
          s: List.filled(32, 1),
          v: 0,
        );
        
        final serialized = signed.serialize();
        final decoded = CFXTransaction.fromRawTransaction(serialized);
        
        expect(decoded.to, isNull);
      });
      
      // 测试带data的交易
      test('Should decode transaction with data', () {
        final privateKey = CFXPrivateKey(testPrivateKey);
        final data = StringUtils.encode('Example data');
        
        final to = CFXAddress.fromHex('0x0123456789012345678901234567890123456789', 1);
        
        final builder = CFXTransactionBuilder.contractCall(
          from: privateKey.publicKey().toAddress(1),
          contract: to,
          data: data,
          chainId: BigInt.one,
        );
        
        builder.setNonce(BigInt.zero);
        builder.setGasPrice(BigInt.one);
        builder.setGas(BigInt.from(21000));
        builder.setStorageLimit(BigInt.zero);
        builder.setEpochHeight(BigInt.zero);
        
        final signed = builder.sign(privateKey);
        
        final decoded = CFXTransaction.fromRawTransaction(signed.serialize());
        expect(decoded.data, equals(data));
      });
    });
    
    group('EIP-2930 Transactions', () {
      // 来自 transaction.test.js 第92-104行
      test('Should encode EIP-2930 transaction correctly', () {
        final to = CFXAddress.fromHex('0x19578cf3c71eab48cf810c78b5175d5c9e6ef441', 100);
        
        final accessList = <AccessListEntry>[
          AccessListEntry(
            address: '0x19578cf3c71eab48cf810c78b5175d5c9e6ef441',
            storageKeys: [
              '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
            ],
          ),
        ];
        
        final tx = CFXTransaction(
          type: CFXTransactionType.eip2930,
          nonce: BigInt.from(100),
          gasPrice: BigInt.from(100),
          gas: BigInt.from(100),
          to: to,
          value: BigInt.from(100),
          storageLimit: BigInt.from(100),
          epochHeight: BigInt.from(100),
          chainId: BigInt.from(100),
          data: StringUtils.encode('Hello, World'),
          accessList: accessList,
          v: 0,
          r: [1], // 最小编码：0x01 而不是 0x0000...0001
          s: [1],
        );
        
        final encoded = tx.encodeForSigning();
        
        // 来自 transaction.test.js 第101行：应该以 "cfx\x01" 前缀开始
        expect(encoded[0], equals(0x63)); // 'c'
        expect(encoded[1], equals(0x66)); // 'f'
        expect(encoded[2], equals(0x78)); // 'x'
        expect(encoded[3], equals(0x01)); // type 1
        
        // 来自 transaction.test.js 第102行：keccak256 哈希
        final hash = QuickCrypto.keccack256Hash(encoded);
        expect(
          BytesUtils.toHexString(hash, prefix: '0x'),
          equals('0x690d58e271b90254e7954147846d5de0f76f3649510bb58a5f26e4fef8d601ba'),
        );
        
        // 来自 transaction.test.js 第103行：完整编码
        final fullEncoded = tx.serialize();
        expect(
          BytesUtils.toHexString(fullEncoded, prefix: '0x'),
          equals('0x63667801f868f8636464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef800101'),
        );
      });
      
      // 来自 transaction.test.js 第173-181行
      test('Should decode EIP-2930 transaction', () {
        const raw2930Tx = '0x63667801f8a8f8636464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef01a0e3e73f1ae5a109b01f5f64b97c7eae0c870da2c050969916d0a440ac2eef0ca3a04e8c4415db648707bd6d4c7708793b04f5404ff38e873fb78f1a6474e36a2579';
        
        final decoded = CFXTransaction.fromRawTransaction(raw2930Tx);
        
        expect(decoded.type, equals(CFXTransactionType.eip2930));
        expect(decoded.chainId, equals(BigInt.from(100)));
        expect(decoded.nonce, equals(BigInt.from(100)));
        expect(decoded.to?.toHex(), equals('0x19578cf3c71eab48cf810c78b5175d5c9e6ef441'));
        expect(decoded.value, equals(BigInt.from(100)));
        expect(decoded.accessList, isNotNull);
        expect(decoded.accessList!.length, equals(1));
      });
    });
    
    group('EIP-1559 Transactions', () {
      // 来自 transaction.test.js 第112-124行
      test('Should encode EIP-1559 transaction correctly', () {
        final to = CFXAddress.fromHex('0x19578cf3c71eab48cf810c78b5175d5c9e6ef441', 100);
        
        final accessList = <AccessListEntry>[
          AccessListEntry(
            address: '0x19578cf3c71eab48cf810c78b5175d5c9e6ef441',
            storageKeys: [
              '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
            ],
          ),
        ];
        
        final tx = CFXTransaction(
          type: CFXTransactionType.eip1559,
          nonce: BigInt.from(100),
          maxPriorityFeePerGas: BigInt.from(100),
          maxFeePerGas: BigInt.from(100),
          gas: BigInt.from(100),
          to: to,
          value: BigInt.from(100),
          storageLimit: BigInt.from(100),
          epochHeight: BigInt.from(100),
          chainId: BigInt.from(100),
          data: StringUtils.encode('Hello, World'),
          accessList: accessList,
          v: 0,
          r: [1], // 最小编码：0x01 而不是 0x0000...0001
          s: [1],
        );
        
        final encoded = tx.encodeForSigning();
        
        // 来自 transaction.test.js 第121行：应该以 "cfx\x02" 前缀开始
        expect(encoded[0], equals(0x63)); // 'c'
        expect(encoded[1], equals(0x66)); // 'f'
        expect(encoded[2], equals(0x78)); // 'x'
        expect(encoded[3], equals(0x02)); // type 2
        
        // 来自 transaction.test.js 第122行：keccak256 哈希
        final hash = QuickCrypto.keccack256Hash(encoded);
        expect(
          BytesUtils.toHexString(hash, prefix: '0x'),
          equals('0x3da56dbe2b76c41135c2429f3035cd79b1abb68902cf588075c30d4912e71cf3'),
        );
        
        // 来自 transaction.test.js 第123行：完整编码
        final fullEncoded = tx.serialize();
        expect(
          BytesUtils.toHexString(fullEncoded, prefix: '0x'),
          equals('0x63667802f869f864646464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef800101'),
        );
      });
      
      // 来自 transaction.test.js 第183-193行
      test('Should decode EIP-1559 transaction', () {
        const raw1559Tx = '0x63667802f8a9f864646464649419578cf3c71eab48cf810c78b5175d5c9e6ef441646464648c48656c6c6f2c20576f726c64f838f79419578cf3c71eab48cf810c78b5175d5c9e6ef441e1a01234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef80a069a44af3ab58ea8be86d21262e900279adc674248a23df5771406545163c1383a0248424d9019fb6c0ecb59c0df3841623fada8fe829cf15e77b6d777accc7cfec';
        
        final decoded = CFXTransaction.fromRawTransaction(raw1559Tx);
        
        expect(decoded.type, equals(CFXTransactionType.eip1559));
        expect(decoded.chainId, equals(BigInt.from(100)));
        expect(decoded.nonce, equals(BigInt.from(100)));
        expect(decoded.to?.toHex(), equals('0x19578cf3c71eab48cf810c78b5175d5c9e6ef441'));
        expect(decoded.value, equals(BigInt.from(100)));
        expect(decoded.accessList, isNotNull);
        expect(decoded.accessList!.length, equals(1));
        expect(decoded.maxFeePerGas, equals(BigInt.from(100)));
        expect(decoded.maxPriorityFeePerGas, equals(BigInt.from(100)));
      });
    });
  });
}

