import 'package:blockchain_utils/blockchain_utils.dart';
import 'dart:typed_data';
import 'dart:convert' show utf8;
import '../address/fil_address.dart';
import '../network/filecoin_network.dart';
import '../signer/fil_signer.dart';

/// FRC-102 prefix for personal sign
/// @see https://github.com/filecoin-project/FIPs/blob/master/FRCs/frc-0102.md
const String frc102Prefix = '\x19Filecoin Signed Message:\n';

/// Filecoin account containing keys and address
class FilecoinAccount {
  final FilecoinSignatureType type;
  final List<int>? privateKey;
  final List<int> publicKey;
  final FilecoinAddress address;
  final String? path;

  const FilecoinAccount({
    required this.type,
    this.privateKey,
    required this.publicKey,
    required this.address,
    this.path,
  });

  @override
  String toString() =>
      'FilecoinAccount(type: ${type.value}, address: $address, path: $path)';
}

/// Filecoin wallet utilities
/// Provides functionality for mnemonic generation, key derivation, signing, and verification
class FilecoinWallet {
  /// Generate 24-word mnemonic using blockchain_utils
  static String generateMnemonic() {
    final generator = Bip39MnemonicGenerator();
    final mnemonic = generator.fromWordsNumber(Bip39WordsNum.wordsNum24);
    return mnemonic.toStr();
  }

  /// Convert mnemonic to seed
  static Uint8List mnemonicToSeed(String mnemonic, [String password = '']) {
    final seed = Bip39SeedGenerator(Mnemonic.fromString(mnemonic))
        .generate(password);
    return Uint8List.fromList(seed);
  }

  /// Validate mnemonic
  static bool validateMnemonic(String mnemonic) {
    try {
      final validator = Bip39MnemonicValidator();
      validator.validate(mnemonic);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get account from mnemonic
  static FilecoinAccount accountFromMnemonic({
    required String mnemonic,
    required FilecoinSignatureType type,
    required String path,
    String password = '',
    FilecoinNetwork? network,
  }) {
    final seed = mnemonicToSeed(mnemonic, password);
    return accountFromSeed(
      seed: seed,
      type: type,
      path: path,
      network: network,
    );
  }

  /// Get account from seed
  static FilecoinAccount accountFromSeed({
    required Uint8List seed,
    required FilecoinSignatureType type,
    required String path,
    FilecoinNetwork? network,
  }) {
    // Derive key using BIP32
    final masterKey = Bip32Slip10Secp256k1.fromSeed(seed);
    final derivedKey = masterKey.derivePath(path) as Bip32Slip10Secp256k1;

    final privateKey = derivedKey.privateKey.raw;

    // Determine network from path if not provided
    network ??= _networkFromPath(path);

    final accountInfo = getPublicKey(
      privateKey: privateKey,
      network: network,
      type: type,
    );

    return FilecoinAccount(
      type: type,
      privateKey: privateKey,
      publicKey: accountInfo.publicKey,
      address: accountInfo.address,
      path: path,
    );
  }

  /// Get account from private key
  static FilecoinAccount accountFromPrivateKey({
    required List<int> privateKey,
    required FilecoinSignatureType type,
    required FilecoinNetwork network,
    String? path,
  }) {
    if (privateKey.length != 32) {
      throw ArgumentError(
          'Private key should be 32 bytes, got ${privateKey.length}');
    }

    final accountInfo = getPublicKey(
      privateKey: privateKey,
      network: network,
      type: type,
    );

    return FilecoinAccount(
      type: type,
      privateKey: privateKey,
      publicKey: accountInfo.publicKey,
      address: accountInfo.address,
      path: path,
    );
  }

  /// Create new random account
  static FilecoinAccount create(
      FilecoinSignatureType type, FilecoinNetwork network) {
    final privateKey = QuickCrypto.generateRandom(32);

    return accountFromPrivateKey(
      privateKey: privateKey,
      type: type,
      network: network,
    );
  }

  /// Get public key and address from private key
  static FilecoinAccount getPublicKey({
    required List<int> privateKey,
    required FilecoinNetwork network,
    required FilecoinSignatureType type,
  }) {
    final secp256k1Key = Secp256k1PrivateKey.fromBytes(privateKey);
    final publicKey = secp256k1Key.publicKey.uncompressed;

    late FilecoinAddress address;

    switch (type) {
      case FilecoinSignatureType.secp256k1:
        address = FilecoinAddress.fromSecp256k1PublicKey(
          publicKey,
          network: network,
        );
        break;
      case FilecoinSignatureType.delegated:
        address = FilecoinAddress.fromDelegatedPublicKey(
          publicKey,
          network: network,
        );
        break;
    }

    return FilecoinAccount(
      type: type,
      publicKey: publicKey,
      address: address,
    );
  }

  /// Sign Filecoin message CID
  static FilecoinSignature signMessage({
    required List<int> privateKey,
    required FilecoinSignatureType type,
    required List<int> messageCid,
  }) {
    return sign(
      privateKey: privateKey,
      type: type,
      data: messageCid,
    );
  }

  /// Sign arbitrary bytes (Lotus wallet sign equivalent)
  static FilecoinSignature sign({
    required List<int> privateKey,
    required FilecoinSignatureType type,
    required List<int> data,
  }) {
    // Hash with Blake2b-256
    final hash = QuickCrypto.blake2b256Hash(data);

    // Sign with SECP256K1
    final signingKey = Secp256k1SigningKey.fromBytes(keyBytes: privateKey);
    final signatureWithRecovery = signingKey.signConst(digest: hash);

    // Extract signature components
    final sig = signatureWithRecovery.item1; // ECDSASignature
    final recoveryId = signatureWithRecovery.item2; // recovery ID (0-3)

    // Build 65-byte compact signature
    final rBytes = BigintUtils.toBytes(sig.r, length: 32);
    final sBytes = BigintUtils.toBytes(sig.s, length: 32);
    final signatureData = Uint8List.fromList([...rBytes, ...sBytes, recoveryId]);

    return FilecoinSignature(
      type: type,
      data: signatureData,
    );
  }

  /// Personal sign using FRC-102
  /// @see https://github.com/filecoin-project/FIPs/blob/master/FRCs/frc-0102.md
  static FilecoinSignature personalSign({
    required List<int> privateKey,
    required FilecoinSignatureType type,
    required List<int> data,
  }) {
    final prefix = utf8.encode('$frc102Prefix${data.length}');
    final prefixedData = Uint8List.fromList([...prefix, ...data]);

    return sign(
      privateKey: privateKey,
      type: type,
      data: prefixedData,
    );
  }

  /// Verify personal signature
  static bool personalVerify({
    required List<int> publicKey,
    required List<int> data,
    required FilecoinSignature signature,
  }) {
    final prefix = utf8.encode('$frc102Prefix${data.length}');
    final prefixedData = Uint8List.fromList([...prefix, ...data]);

    return verify(
      publicKey: publicKey,
      data: prefixedData,
      signature: signature,
    );
  }

  /// Verify signature
  static bool verify({
    required List<int> publicKey,
    required List<int> data,
    required FilecoinSignature signature,
  }) {
    if (signature.data.length != 65) {
      return false;
    }

    // Hash with Blake2b-256
    final hash = QuickCrypto.blake2b256Hash(data);

    // Extract r, s from signature (v is recovery id, not needed for verification)
    final r = BigintUtils.fromBytes(signature.data.sublist(0, 32));
    final s = BigintUtils.fromBytes(signature.data.sublist(32, 64));
    // final v = signature.data[64]; // Recovery ID not needed for verification

    // Create ECDSA signature
    final ecdsaSignature = ECDSASignature(r, s);

    // Create verifier
    final verifier = Secp256k1Verifier.fromKeyBytes(publicKey);

    return verifier.verify(hash, ecdsaSignature.toBytes(32), hashMessage: false);
  }

  /// Determine network from derivation path
  static FilecoinNetwork _networkFromPath(String path) {
    // BIP44 coin type: 461 for mainnet, 1 for testnet
    if (path.contains("44'/461'") || path.contains('44\'/461\'')) {
      return FilecoinNetwork.mainnet;
    } else if (path.contains("44'/1'") || path.contains('44\'/1\'')) {
      return FilecoinNetwork.testnet;
    }
    // Default to mainnet
    return FilecoinNetwork.mainnet;
  }
}
