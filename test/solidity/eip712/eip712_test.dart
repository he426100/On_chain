import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/abi/abi.dart';
import 'package:test/test.dart';

void main() {
  group('EIP-712 Typed Data Tests', () {
    group('EIP712Domain Auto-Generation', () {
      test('should auto-generate EIP712Domain when missing (NFT Permit)', () {
        // Test case from test-dapp: erc721.js getNFTMsgParams()
        final json = {
          "domain": {
            "name": "My NFT",
            "version": "1",
            "chainId": 1,
            "verifyingContract": "0x1234567890123456789012345678901234567890",
          },
          "types": {
            "Permit": [
              {"name": "spender", "type": "address"},
              {"name": "tokenId", "type": "uint256"},
              {"name": "nonce", "type": "uint256"},
              {"name": "deadline", "type": "uint256"},
            ],
            // Note: EIP712Domain is missing
          },
          "primaryType": "Permit",
          "message": {
            "spender": "0x0521797E19b8E274E4ED3bFe5254FAf6fac96F08",
            "tokenId": "3606393",
            "nonce": "0",
            "deadline": "1734995006",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);

        // Verify EIP712Domain was auto-generated as empty array
        // 参考：eth-sig-util/src/sign-typed-data.ts:332
        // sanitizedData.types = Object.assign({ EIP712Domain: [] }, sanitizedData.types);
        expect(typedData.types.containsKey('EIP712Domain'), isTrue);
        final domainFields = typedData.types['EIP712Domain']!;

        // eth-sig-util 补全的是空数组，不是完整定义
        expect(domainFields.length, 0,
            reason: 'EIP712Domain 应该是空数组（与 eth-sig-util 一致）');

        // Verify hash can be computed without error
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
        expect(hash.startsWith('0x') || hash.length == 64, isTrue);
      });

      test('should preserve existing EIP712Domain definition', () {
        // Test case from Trust Wallet tests
        final json = {
          "domain": {
            "name": "Ether Mail",
            "version": "1",
            "chainId": 1,
            "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
          },
          "types": {
            "EIP712Domain": [
              {"name": "name", "type": "string"},
              {"name": "version", "type": "string"},
              {"name": "chainId", "type": "uint256"},
              {"name": "verifyingContract", "type": "address"},
            ],
            "Person": [
              {"name": "name", "type": "string"},
              {"name": "wallet", "type": "address"},
            ],
            "Mail": [
              {"name": "from", "type": "Person"},
              {"name": "to", "type": "Person"},
              {"name": "contents", "type": "string"},
            ],
          },
          "primaryType": "Mail",
          "message": {
            "from": {
              "name": "Cow",
              "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            },
            "to": {
              "name": "Bob",
              "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            },
            "contents": "Hello, Bob!",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);

        // Verify EIP712Domain is preserved
        expect(typedData.types.containsKey('EIP712Domain'), isTrue);
        final domainFields = typedData.types['EIP712Domain']!;
        expect(domainFields.length, 4);

        // Verify hash can be computed
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });

      test('should handle partial domain fields', () {
        final json = {
          "domain": {
            "name": "Test",
            "chainId": 1,
            // Missing version and verifyingContract
          },
          "types": {
            "Message": [
              {"name": "content", "type": "string"},
            ],
          },
          "primaryType": "Message",
          "message": {
            "content": "Hello",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);

        // Verify EIP712Domain is auto-completed as empty array
        final domainFields = typedData.types['EIP712Domain']!;
        expect(domainFields.length, 0,
            reason: 'EIP712Domain 应该是空数组（与 eth-sig-util 一致）');

        // Verify hash can be computed
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });

      test('should handle domain with all standard fields including salt', () {
        final json = {
          "domain": {
            "name": "Test",
            "version": "1",
            "chainId": 1,
            "verifyingContract": "0x1234567890123456789012345678901234567890",
            "salt":
                "0x1234567890123456789012345678901234567890123456789012345678901234",
          },
          "types": {
            "Message": [
              {"name": "content", "type": "string"},
            ],
          },
          "primaryType": "Message",
          "message": {
            "content": "Hello",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);

        // Verify EIP712Domain is auto-completed as empty array
        final domainFields = typedData.types['EIP712Domain']!;
        expect(domainFields.length, 0,
            reason: 'EIP712Domain 应该是空数组（与 eth-sig-util 一致）');

        // Verify hash can be computed
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });
    });

    group('Complex Types', () {
      test('should handle arrays', () {
        final json = {
          "domain": {
            "name": "Test",
            "chainId": 1,
          },
          "types": {
            "Person": [
              {"name": "name", "type": "string"},
              {"name": "wallets", "type": "address[]"},
            ],
            "Message": [
              {"name": "people", "type": "Person[]"},
            ],
          },
          "primaryType": "Message",
          "message": {
            "people": [
              {
                "name": "Alice",
                "wallets": [
                  "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                  "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                ],
              },
            ],
          },
        };

        final typedData = Eip712TypedData.fromJson(json);
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });

      test('should handle nested structs', () {
        final json = {
          "domain": {
            "name": "Test",
            "chainId": 1,
          },
          "types": {
            "Person": [
              {"name": "name", "type": "string"},
              {"name": "wallet", "type": "address"},
            ],
            "Mail": [
              {"name": "from", "type": "Person"},
              {"name": "to", "type": "Person"},
              {"name": "contents", "type": "string"},
            ],
          },
          "primaryType": "Mail",
          "message": {
            "from": {
              "name": "Alice",
              "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            },
            "to": {
              "name": "Bob",
              "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            },
            "contents": "Hello",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });

      test('should handle bytes type', () {
        final json = {
          "domain": {
            "name": "Test",
            "chainId": 1,
          },
          "types": {
            "Message": [
              {"name": "data", "type": "bytes"},
            ],
          },
          "primaryType": "Message",
          "message": {
            "data": [0x12, 0x34, 0x56, 0x78],
          },
        };

        final typedData = Eip712TypedData.fromJson(json);
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });
    });

    group('Full Trust Wallet Test Cases', () {
      test('should handle complete Trust Wallet V4 example with arrays', () {
        // Full test case from Trust Wallet: EthereumProvider.spec.ts:436-482
        final json = {
          "domain": {
            "chainId": 1,
            "name": "Ether Mail",
            "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
            "version": "1",
          },
          "message": {
            "contents": "Hello, Bob!",
            "from": {
              "name": "Cow",
              "wallets": [
                "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
              ],
            },
            "to": [
              {
                "name": "Bob",
                "wallets": [
                  "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                  "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                  "0xB0B0b0b0b0b0B000000000000000000000000000",
                ],
              },
            ],
          },
          "primaryType": "Mail",
          "types": {
            "EIP712Domain": [
              {"name": "name", "type": "string"},
              {"name": "version", "type": "string"},
              {"name": "chainId", "type": "uint256"},
              {"name": "verifyingContract", "type": "address"},
            ],
            "Group": [
              {"name": "name", "type": "string"},
              {"name": "members", "type": "Person[]"},
            ],
            "Mail": [
              {"name": "from", "type": "Person"},
              {"name": "to", "type": "Person[]"},
              {"name": "contents", "type": "string"},
            ],
            "Person": [
              {"name": "name", "type": "string"},
              {"name": "wallets", "type": "address[]"},
            ],
          },
        };

        final typedData = Eip712TypedData.fromJson(json);
        expect(typedData.version, EIP712Version.v4);

        // Verify hash can be computed
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
        expect(hash.length, greaterThan(60));
      });
    });

    group('Signature Comparison Tests', () {
      test('V4 signature should match eth-sig-util result', () {
        // 使用与 test-dapp/test_sign_v4.js 相同的钱包和数据
        const privateKeyHex =
            '91e4ad47a567b23aec1157e280c00b3170125c4de7169ae63021aed37924931a';
        const expectedAddress = '0x6eCEcA63588925176Ce147Dc72d8f433D829bfb7';

        // eth-sig-util 的签名结果（来自 test_sign_v4.js）
        const expectedSignature =
            '0x8b5fd8c8e996d485a44657bb071d0c244acc160f1857400f2f1811e9d98de51f269ef97498bf87745c6597ebc65dc609fbd0ee1575dc5108635c66b7bbfdbb4a1b';

        // signTypedDataV4-sign.js 中的测试数据
        final json = {
          'domain': {
            'chainId': '11155111', // 字符串格式
            'name': 'Ether Mail',
            'verifyingContract': '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
            'version': '1',
          },
          'message': {
            'contents': 'Hello, Bob!',
            'from': {
              'name': 'Cow',
              'wallets': [
                '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
                '0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF',
              ],
            },
            'to': [
              {
                'name': 'Bob',
                'wallets': [
                  '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
                  '0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57',
                  '0xB0B0b0b0b0b0B000000000000000000000000000',
                ],
              },
            ],
            'attachment': '0x',
          },
          'primaryType': 'Mail',
          'types': {
            'EIP712Domain': [
              {'name': 'name', 'type': 'string'},
              {'name': 'version', 'type': 'string'},
              {'name': 'chainId', 'type': 'uint256'},
              {'name': 'verifyingContract', 'type': 'address'},
            ],
            'Group': [
              {'name': 'name', 'type': 'string'},
              {'name': 'members', 'type': 'Person[]'},
            ],
            'Mail': [
              {'name': 'from', 'type': 'Person'},
              {'name': 'to', 'type': 'Person[]'},
              {'name': 'contents', 'type': 'string'},
              {'name': 'attachment', 'type': 'bytes'},
            ],
            'Person': [
              {'name': 'name', 'type': 'string'},
              {'name': 'wallets', 'type': 'address[]'},
            ],
          },
        };

        // 解析 TypedData
        final typedData =
            Eip712TypedData.fromJson(json, version: EIP712Version.v4);

        // 编码消息（不 hash）
        final encodedMessage = typedData.encode(hash: false);
        print('Encoded message length: ${encodedMessage.length}');
        print('Encoded message: ${BytesUtils.toHexString(encodedMessage)}');

        // 获取 domainSeparator 和 messageHash 用于调试
        final domainSeparator =
            EIP712Utils.structHash(typedData, 'EIP712Domain', typedData.domain);
        final messageHash = EIP712Utils.structHash(
            typedData, typedData.primaryType, typedData.message);
        print('Domain separator: ${BytesUtils.toHexString(domainSeparator)}');
        print('Message hash: ${BytesUtils.toHexString(messageHash)}');

        // 调试：查看 Mail 类型的 typeHash 和编码
        final mailTypeHash = EIP712Utils.getMethodSigature(typedData, 'Mail');
        print('Mail typeHash: ${BytesUtils.toHexString(mailTypeHash)}');

        // 调试：查看 Person 类型的 typeHash
        final personTypeHash =
            EIP712Utils.getMethodSigature(typedData, 'Person');
        print('Person typeHash: ${BytesUtils.toHexString(personTypeHash)}');

        // 调试：查看 Mail 结构的完整编码
        final mailEncoded =
            EIP712Utils.encodeStruct(typedData, 'Mail', typedData.message);
        print(
            'Mail encoded (${mailEncoded.length} bytes): ${BytesUtils.toHexString(mailEncoded)}');

        // 创建签名器
        final privateKey = ETHPrivateKey(privateKeyHex);
        final publicKey = privateKey.publicKey();
        final address = publicKey.toAddress();

        // 验证地址
        expect(address.address.toLowerCase(), expectedAddress.toLowerCase());
        print('✅ 地址验证通过: ${address.address}');

        // 签名
        final signer = ETHSigner.fromKeyBytes(privateKey.toBytes());
        final signature = signer.signConst(encodedMessage);
        final signatureHex =
            BytesUtils.toHexString(signature.toBytes(), prefix: '0x');

        print('Our signature:      $signatureHex');
        print('Expected signature: $expectedSignature');

        // 对比签名
        expect(signatureHex.toLowerCase(), expectedSignature.toLowerCase(),
            reason: '签名结果应该与 eth-sig-util 一致');
      });
    });

    group('Real-world Test Cases', () {
      test('SEAPORT BulkOrder signature (from test-dapp)', () {
        // This is a simplified version - full SEAPORT types are very complex
        final json = {
          "domain": {
            "name": "Seaport",
            "version": "1.5",
            "chainId": 1,
            "verifyingContract": "0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC",
          },
          "types": {
            // EIP712Domain is missing - should auto-generate
            "OrderComponents": [
              {"name": "offerer", "type": "address"},
              {"name": "zone", "type": "address"},
            ],
          },
          "primaryType": "OrderComponents",
          "message": {
            "offerer": "0x0521797E19b8E274E4ED3bFe5254FAf6fac96F08",
            "zone": "0x0000000000000000000000000000000000000000",
          },
        };

        final typedData = Eip712TypedData.fromJson(json);

        // Verify EIP712Domain was auto-generated
        expect(typedData.types.containsKey('EIP712Domain'), isTrue);

        // Verify hash can be computed
        final hash = typedData.encodeHex();
        expect(hash, isNotEmpty);
      });
    });
  });
}
