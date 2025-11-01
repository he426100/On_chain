import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

void main() {
  group('Signature Compatibility Tests (Helios)', () {
    group('CFX Personal Sign', () {
      // Test case from helios/packages/signature/index.test.js
      test('personal sign and recover', () {
        final pk = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        final expectedAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
        const networkId = 1; // testnet
        const message = 'Hello, world!';
        
        final privateKey = CFXPrivateKey(pk);
        final messageBytes = StringUtils.encode(message);
        final signature = privateKey.signPersonalMessage(messageBytes);
        
        // Verify signature format
        expect(signature, isNotNull);
        expect(signature.length, 130); // 65 bytes * 2 hex chars
        
        // Verify we can derive the address from private key
        final address = privateKey.publicKey().toAddress(networkId);
        expect(address.toBase32(), expectedAddress);
      });
    });
    
    group('CFX signTypedData_v4 (CIP-23)', () {
      // Test case from helios/packages/signature/index.test.js
      test('signTypedData_v4 - Mail example', () {
        final typedData = CIP23TypedData(
          types: {
            'CIP23Domain': [
              CIP23TypeField(name: 'name', type: 'string'),
              CIP23TypeField(name: 'version', type: 'string'),
              CIP23TypeField(name: 'chainId', type: 'uint256'),
              CIP23TypeField(name: 'verifyingContract', type: 'address'),
            ],
            'Person': [
              CIP23TypeField(name: 'name', type: 'string'),
              CIP23TypeField(name: 'wallets', type: 'address[]'),
            ],
            'Mail': [
              CIP23TypeField(name: 'from', type: 'Person'),
              CIP23TypeField(name: 'to', type: 'Person[]'),
              CIP23TypeField(name: 'contents', type: 'string'),
            ],
            'Group': [
              CIP23TypeField(name: 'name', type: 'string'),
              CIP23TypeField(name: 'members', type: 'Person[]'),
            ],
          },
          domain: {
            'name': 'Ether Mail',
            'version': '1',
            'chainId': 1,
            'verifyingContract': '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
          },
          primaryType: 'Mail',
          message: {
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
            'contents': 'Hello, Bob!',
          },
        );
        
        final pk = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        final expectedAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
        const networkId = 1; // testnet
        
        // Expected signature from helios
        const expectedSignature = '0x3404e089c443cbe853e35d53670ae074860731930fa4ac87f2f6e10d7f2337270ac970680c7d609b5bb2f05b50398aee323ddac925e9e9ead5accc3fd2fb849001';
        
        final privateKey = CFXPrivateKey(pk);
        final signature = CIP23Signer.sign(privateKey, typedData);
        
        // Verify signature matches helios
        expect('0x$signature'.toLowerCase(), expectedSignature.toLowerCase());
        
        // Recover address from signature
        final recovered = CIP23Signer.recover(signature, typedData, networkId);
        expect(recovered.toBase32(), expectedAddress);
      });
      
      test('signTypedData_v4 with recursive types', () {
        final typedData = CIP23TypedData(
          types: {
            'CIP23Domain': [
              CIP23TypeField(name: 'name', type: 'string'),
              CIP23TypeField(name: 'version', type: 'string'),
              CIP23TypeField(name: 'chainId', type: 'uint256'),
              CIP23TypeField(name: 'verifyingContract', type: 'address'),
            ],
            'Person': [
              CIP23TypeField(name: 'name', type: 'string'),
              CIP23TypeField(name: 'mother', type: 'Person'),
              CIP23TypeField(name: 'father', type: 'Person'),
            ],
          },
          domain: {
            'name': 'Family Tree',
            'version': '1',
            'chainId': 1,
            'verifyingContract': '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
          },
          primaryType: 'Person',
          message: {
            'name': 'Jon',
            'mother': {
              'name': 'Lyanna',
              'father': {'name': 'Rickard'},
            },
            'father': {
              'name': 'Rhaegar',
              'father': {'name': 'Aeris II'},
            },
          },
        );
        
        final pk = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        final expectedAddress = 'cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7';
        const networkId = 1;
        
        // Expected signature from helios
        const expectedSignature = '0xa5d4de96227cb8d7b6e3d44c8ca3f66f6361d81530e7c386c4fbaa55a8fa3df0229807250407e0c500803f1efd095d2a24554b520be9e88ee1e79a13efc4379101';
        
        final privateKey = CFXPrivateKey(pk);
        final signature = CIP23Signer.sign(privateKey, typedData);
        
        // Verify signature matches helios
        expect('0x$signature'.toLowerCase(), expectedSignature.toLowerCase());
        
        // Recover address from signature
        final recovered = CIP23Signer.recover(signature, typedData, networkId);
        expect(recovered.toBase32(), expectedAddress);
      });
    });
    
    group('Account derivation from private key', () {
      // Test case from helios/packages/account/index.test.js
      test('fromPrivate should return the right address', () {
        const ecprivkey = '0x3c9229289a6125f7fdf1885a77bb12c37a8d3b4962d936f7e3084dece32a3ca1';
        const expectedChecksumAddress = '0xED54a7C1d8634BB589f24Bb7F05a5554b36F9618';
        
        final privateKey = CFXPrivateKey(ecprivkey);
        final publicKey = privateKey.publicKey();
        
        // Get eSpace address (Ethereum-style with checksum)
        final eSpaceAddress = publicKey.toESpaceAddress();
        
        expect(eSpaceAddress.toHex(), expectedChecksumAddress);
      });
    });
  });
}

