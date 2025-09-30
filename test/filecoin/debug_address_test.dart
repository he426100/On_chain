import 'package:test/test.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/filecoin.dart';

void main() {
  test('Debug address generation', () {
    final privateKeyHex = '1d969865e189957b9824bd34f26d5cbf357fda1a6d844cbf0c9ab1ed93fa7dbe';
    final privateKey = BytesUtils.fromHexString(privateKeyHex);
    final secp256k1PrivKey = Secp256k1PrivateKey.fromBytes(privateKey);
    final publicKey = secp256k1PrivKey.publicKey.uncompressed;

    print('Public key: ${BytesUtils.toHexString(publicKey)}');
    print('Public key length: ${publicKey.length}');

    final payload = QuickCrypto.blake2b160Hash(publicKey);
    print('Payload: ${BytesUtils.toHexString(payload)}');
    print('Payload length: ${payload.length}');

    final address = FilecoinAddress.fromSecp256k1PublicKey(publicKey);
    print('Address: ${address.toAddress()}');
    print('Expected: f1z4a36sc7mfbv4z3qwutblp2flycdui3baffytbq');

    final addressBytes = address.toBytes();
    print('Address bytes: ${BytesUtils.toHexString(addressBytes)}');
  });

  test('Debug delegated address generation', () {
    final privateKeyHex = '825d2bb32965764a98338139412c7591ed54c951dd65504cd8ddaeaa0fea7b2a';
    final privateKey = BytesUtils.fromHexString(privateKeyHex);
    final secp256k1PrivKey = Secp256k1PrivateKey.fromBytes(privateKey);
    final publicKey = secp256k1PrivKey.publicKey.uncompressed;

    print('Public key: ${BytesUtils.toHexString(publicKey)}');

    final publicKeyWithoutPrefix = publicKey.sublist(1);
    print('Public key without prefix: ${BytesUtils.toHexString(publicKeyWithoutPrefix)}');

    final keccakHash = QuickCrypto.keccack256Hash(publicKeyWithoutPrefix);
    print('Keccak hash: ${BytesUtils.toHexString(keccakHash)}');

    final payload = keccakHash.sublist(12);
    print('Payload (last 20 bytes): ${BytesUtils.toHexString(payload)}');

    final address = FilecoinAddress.fromDelegatedPublicKey(publicKey);
    print('Address: ${address.toAddress()}');
    print('Expected: f410fvak24cyg3saddajborn6idt7rrtfj2ptauk5pbq');

    final addressBytes = address.toBytes();
    print('Address bytes: ${BytesUtils.toHexString(addressBytes)}');
  });
}