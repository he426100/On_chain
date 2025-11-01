// Simple smoke test to verify basic Conflux functionality
import 'package:test/test.dart';
import 'package:on_chain/conflux/conflux.dart';

void main() {
  group('Conflux Basic Functionality', () {
    test('Create private key and derive addresses', () {
      // Create a random private key
      final privateKey = CFXPrivateKey.random();
      expect(privateKey, isNotNull);

      // Get public key
      final publicKey = privateKey.publicKey();
      expect(publicKey, isNotNull);

      // Generate Core Space mainnet address
      final coreAddr = publicKey.toAddress(1029);
      expect(coreAddr.networkId, 1029);
      expect(coreAddr.toBase32(), startsWith('cfx:'));
      expect(coreAddr.toHex(), startsWith('0x'));

      // Generate Core Space testnet address
      final testnetAddr = publicKey.toAddress(1);
      expect(testnetAddr.networkId, 1);
      expect(testnetAddr.toBase32(), startsWith('cfxtest:'));

      // Generate eSpace address
      final eSpaceAddr = publicKey.toESpaceAddress();
      expect(eSpaceAddr.toHex(), startsWith('0x'));
    });

    test('Create and serialize transaction', () {
      final privateKey = CFXPrivateKey(
        '0x1234567890123456789012345678901234567890123456789012345678901234',
      );
      final publicKey = privateKey.publicKey();
      final fromAddr = publicKey.toAddress(1029);
      final toAddr = publicKey.toAddress(1029); // Self-transfer for simplicity

      final txBuilder = CFXTransactionBuilder.transfer(
        from: fromAddr,
        to: toAddr,
        value: BigInt.from(1000000000000000000),
        chainId: BigInt.from(1029),
      );

      txBuilder.setNonce(BigInt.zero);
      txBuilder.setGasPrice(BigInt.from(1000000000));
      txBuilder.setGas(BigInt.from(21000));
      txBuilder.setStorageLimit(BigInt.zero);
      txBuilder.setEpochHeight(BigInt.from(12345678));

      final signedTx = txBuilder.sign(privateKey);

      // Verify transaction has signature
      expect(signedTx.v, isNotNull);
      expect(signedTx.r, isNotNull);
      expect(signedTx.s, isNotNull);

      // Serialize
      final serialized = signedTx.serialize();
      expect(serialized, isNotEmpty);

      // Get hash
      final txHash = signedTx.getTransactionHashHex();
      expect(txHash, startsWith('0x'));
    });

    test('Epoch number utilities', () {
      expect(EpochNumber.latestState.toString(), 'latest_state');
      expect(EpochNumber.latestMined.toString(), 'latest_mined');
      expect(EpochNumber.earliest.toString(), 'earliest');
    });

    test('Sign personal message', () {
      final privateKey = CFXPrivateKey.random();
      final message = 'Hello Conflux!'.codeUnits;
      final signature = privateKey.signPersonalMessage(message);

      expect(signature, isNotEmpty);
      // Signature should be hex string
      expect(signature.length >= 128, true);
    });

    test('Convert hex to Base32 address', () {
      final hexAddress = '0x1063E0B1B39C08806E5E445D633C70D66E401750';
      
      // Mainnet
      final mainnetAddr = CFXAddress.fromHex(hexAddress, 1029);
      expect(mainnetAddr.networkId, 1029);
      expect(mainnetAddr.toBase32(), startsWith('cfx:'));
      expect(mainnetAddr.toHex().toLowerCase(), hexAddress.toLowerCase());

      // Testnet
      final testnetAddr = CFXAddress.fromHex(hexAddress, 1);
      expect(testnetAddr.networkId, 1);
      expect(testnetAddr.toBase32(), startsWith('cfxtest:'));
    });
  });
}

