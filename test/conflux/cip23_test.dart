import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';

void main() {
  group('CIP23TypedData Tests', () {
    test('Create simple typed data', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Message': [
            CIP23TypeField(name: 'content', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {
          'name': 'Test',
          'chainId': 1029,
        },
        message: {
          'content': 'Hello',
        },
      );

      expect(typedData.primaryType, equals('Message'));
      expect(typedData.domain['name'], equals('Test'));
      expect(typedData.message['content'], equals('Hello'));
    });

    test('Create typed data with nested structs', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Mail': [
            CIP23TypeField(name: 'from', type: 'Person'),
            CIP23TypeField(name: 'to', type: 'Person'),
            CIP23TypeField(name: 'contents', type: 'string'),
          ],
          'Person': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'wallet', type: 'address'),
          ],
        },
        primaryType: 'Mail',
        domain: {
          'name': 'Conflux Mail',
          'chainId': 1029,
        },
        message: {
          'from': {
            'name': 'Alice',
            'wallet': 'cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p',
          },
          'to': {
            'name': 'Bob',
            'wallet': 'cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg',
          },
          'contents': 'Hello Bob!',
        },
      );

      expect(typedData.types.containsKey('Mail'), isTrue);
      expect(typedData.types.containsKey('Person'), isTrue);
      final mailType = typedData.types['Mail']!;
      expect(mailType.length, equals(3));
      expect(mailType[0].name, equals('from'));
      expect(mailType[0].type, equals('Person'));
    });

    test('Convert typed data to JSON', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {'name': 'Test'},
        message: {'text': 'Hello'},
      );

      final json = typedData.toJson();
      expect(json['primaryType'], equals('Message'));
      expect(json['types'], isA<Map>());
      expect(json['domain'], isA<Map>());
      expect(json['message'], isA<Map>());
    });

    test('Parse typed data from JSON', () {
      final json = {
        'types': {
          'CIP23Domain': [
            {'name': 'name', 'type': 'string'},
            {'name': 'chainId', 'type': 'uint256'},
          ],
          'Message': [
            {'name': 'content', 'type': 'string'},
          ],
        },
        'primaryType': 'Message',
        'domain': {
          'name': 'Test',
          'chainId': 1029,
        },
        'message': {
          'content': 'Hello',
        },
      };

      final typedData = CIP23TypedData.fromJson(json);
      expect(typedData.primaryType, equals('Message'));
      expect(typedData.domain['name'], equals('Test'));
      expect(typedData.domain['chainId'], equals(1029));
    });
  });

  group('CIP23Encoder Tests', () {
    test('Encode type string', () {
      final types = {
        'Person': [
          CIP23TypeField(name: 'name', type: 'string'),
          CIP23TypeField(name: 'wallet', type: 'address'),
        ],
      };

      final encoded = CIP23Encoder.encodeType('Person', types);
      expect(encoded, equals('Person(string name,address wallet)'));
    });

    test('Encode nested type string', () {
      final types = {
        'Mail': [
          CIP23TypeField(name: 'from', type: 'Person'),
          CIP23TypeField(name: 'to', type: 'Person'),
          CIP23TypeField(name: 'contents', type: 'string'),
        ],
        'Person': [
          CIP23TypeField(name: 'name', type: 'string'),
          CIP23TypeField(name: 'wallet', type: 'address'),
        ],
      };

      final encoded = CIP23Encoder.encodeType('Mail', types);
      expect(
          encoded,
          equals(
              'Mail(Person from,Person to,string contents)Person(string name,address wallet)'));
    });

    test('Compute type hash', () {
      final types = {
        'Person': [
          CIP23TypeField(name: 'name', type: 'string'),
          CIP23TypeField(name: 'wallet', type: 'address'),
        ],
      };

      final hash = CIP23Encoder.typeHash('Person', types);
      expect(hash.length, equals(32));
    });

    test('Encode and hash domain separator', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {
          'name': 'Test',
          'chainId': 1029,
        },
        message: {
          'text': 'Hello',
        },
      );

      final domainSeparator = CIP23Encoder.hashDomain(typedData);
      expect(domainSeparator.length, equals(32));
    });

    test('Compute message hash', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {
          'name': 'Test',
          'chainId': 1029,
        },
        message: {
          'text': 'Hello',
        },
      );

      final messageHash = CIP23Encoder.hashMessage(typedData);
      expect(messageHash.length, equals(32));
    });

    test('Message hash is deterministic', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {'name': 'Test'},
        message: {'text': 'Hello'},
      );

      final hash1 = CIP23Encoder.hashMessage(typedData);
      final hash2 = CIP23Encoder.hashMessage(typedData);
      expect(hash1, equals(hash2));
    });
  });

  group('CIP23Signer Tests', () {
    test('Sign typed data', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {
          'name': 'Test',
          'chainId': 1029,
        },
        message: {
          'text': 'Hello',
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130)); // 64 (r) + 64 (s) + 2 (v)
    });

    test('Signature is deterministic', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {'name': 'Test'},
        message: {'text': 'Hello'},
      );

      final sig1 = CIP23Signer.sign(privateKey, typedData);
      final sig2 = CIP23Signer.sign(privateKey, typedData);
      expect(sig1, equals(sig2));
    });

    test('Recover address from signature', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );
      final publicKey = privateKey.publicKey();
      final expectedAddress = publicKey.toAddress(1);

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {
          'name': 'Test',
          'chainId': 1029,
        },
        message: {
          'text': 'Hello Conflux!',
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      final recoveredAddress = CIP23Signer.recover(signature, typedData, 1);

      expect(recoveredAddress.toBase32(), equals(expectedAddress.toBase32()));
    });

    test('Sign and recover with Base32 addresses in message', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );
      final publicKey = privateKey.publicKey().toAddress(1029);
      
      // Generate a second address for 'to'
      final privateKey2 = CFXPrivateKey(
        '0xabcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789',
      );
      final toAddress = privateKey2.publicKey().toAddress(1029);

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Transfer': [
            CIP23TypeField(name: 'from', type: 'address'),
            CIP23TypeField(name: 'to', type: 'address'),
            CIP23TypeField(name: 'amount', type: 'uint256'),
          ],
        },
        primaryType: 'Transfer',
        domain: {
          'name': 'Token',
          'chainId': 1029,
        },
        message: {
          'from': publicKey.toBase32(),
          'to': toAddress.toBase32(),
          'amount': '1000000000000000000',
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      final recovered = CIP23Signer.recover(signature, typedData, 1029);

      expect(recovered.toBase32(), equals(publicKey.toBase32()));
    });

    test('Get domain separator', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {'name': 'Test'},
        message: {},
      );

      final domainSeparator = CIP23Signer.getDomainSeparator(typedData);
      expect(domainSeparator.length, equals(32));
    });

    test('Get message hash', () {
      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Message': [
            CIP23TypeField(name: 'text', type: 'string'),
          ],
        },
        primaryType: 'Message',
        domain: {'name': 'Test'},
        message: {'text': 'Hello'},
      );

      final messageHash = CIP23Signer.getMessageHash(typedData);
      expect(messageHash.length, equals(32));
    });
  });

  group('CIP23 Complex Types Tests', () {
    test('Sign typed data with arrays', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'List': [
            CIP23TypeField(name: 'items', type: 'string[]'),
          ],
        },
        primaryType: 'List',
        domain: {'name': 'Test'},
        message: {
          'items': ['item1', 'item2', 'item3'],
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130));
    });

    test('Sign typed data with numbers', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Numbers': [
            CIP23TypeField(name: 'uint', type: 'uint256'),
            CIP23TypeField(name: 'int', type: 'int256'),
          ],
        },
        primaryType: 'Numbers',
        domain: {'name': 'Test'},
        message: {
          'uint': '123456789',
          'int': '-987654321',
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130));
    });

    test('Sign typed data with bytes', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Data': [
            CIP23TypeField(name: 'content', type: 'bytes'),
          ],
        },
        primaryType: 'Data',
        domain: {'name': 'Test'},
        message: {
          'content': '0x1234567890abcdef',
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130));
    });

    test('Sign typed data with boolean', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
          ],
          'Flag': [
            CIP23TypeField(name: 'enabled', type: 'bool'),
          ],
        },
        primaryType: 'Flag',
        domain: {'name': 'Test'},
        message: {
          'enabled': true,
        },
      );

      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130));
    });
  });

  group('CIP23 Integration Tests', () {
    test('End-to-end mail example', () {
      final privateKey = CFXPrivateKey(
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );
      final publicKey = privateKey.publicKey();
      final senderAddress = publicKey.toAddress(1029);  // Use mainnet

      // Generate a second address for recipient
      final privateKey2 = CFXPrivateKey(
        '0xabcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789',
      );
      final recipientAddress = privateKey2.publicKey().toAddress(1029);

      final typedData = CIP23TypedData(
        types: {
          'CIP23Domain': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'version', type: 'string'),
            CIP23TypeField(name: 'chainId', type: 'uint256'),
          ],
          'Mail': [
            CIP23TypeField(name: 'from', type: 'Person'),
            CIP23TypeField(name: 'to', type: 'Person'),
            CIP23TypeField(name: 'contents', type: 'string'),
          ],
          'Person': [
            CIP23TypeField(name: 'name', type: 'string'),
            CIP23TypeField(name: 'wallet', type: 'address'),
          ],
        },
        primaryType: 'Mail',
        domain: {
          'name': 'Conflux Mail',
          'version': '1',
          'chainId': 1029,
        },
        message: {
          'from': {
            'name': 'Alice',
            'wallet': senderAddress.toBase32(),
          },
          'to': {
            'name': 'Bob',
            'wallet': recipientAddress.toBase32(),
          },
          'contents': 'Hello Bob!',
        },
      );

      // Sign
      final signature = CIP23Signer.sign(privateKey, typedData);
      expect(signature.length, equals(130));

      // Recover
      final recovered = CIP23Signer.recover(signature, typedData, 1029);
      expect(recovered.toBase32(), equals(senderAddress.toBase32()));

      // Verify message hash
      final messageHash = CIP23Signer.getMessageHash(typedData);
      expect(messageHash.length, equals(32));
    });
  });
}

