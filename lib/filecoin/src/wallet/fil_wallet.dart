import 'package:bip39/bip39.dart' as bip39;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'dart:typed_data';
import 'dart:convert' show base64, utf8;
import '../address/fil_address.dart';
import '../network/filecoin_network.dart';
import '../signature/fil_signature.dart';

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
  String toString() => 'FilecoinAccount(type: ${type.name}, address: $address, path: $path)';
}

/// Filecoin wallet utilities
/// Provides functionality for mnemonic generation, key derivation, signing, and verification
class FilecoinWallet {
  /// Generate 24-word mnemonic
  static String generateMnemonic() {
    return bip39.generateMnemonic(strength: 256);
  }

  /// Convert mnemonic to seed
  static Uint8List mnemonicToSeed(String mnemonic, [String password = '']) {
    return Uint8List.fromList(bip39.mnemonicToSeed(mnemonic, passphrase: password));
  }

  /// Validate mnemonic
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
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
      throw ArgumentError('Private key should be 32 bytes, got ${privateKey.length}');
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

  /// Get account from Lotus private key export (hex format)
  /// Lotus exports as hex({"Type":"bls"|"secp256k1","PrivateKey":"base64(key)"})
  /// Note: BLS private keys in Lotus are little-endian (reversed)
  static FilecoinAccount accountFromLotus(String lotusHex, FilecoinNetwork network) {
    final jsonBytes = BytesUtils.fromHexString(lotusHex);
    final jsonString = utf8.decode(jsonBytes);
    final Map<String, dynamic> json = {};

    // Parse JSON manually to handle Lotus format
    final typeMatch = RegExp(r'"Type":"([^"]+)"').firstMatch(jsonString);
    final keyMatch = RegExp(r'"PrivateKey":"([^"]+)"').firstMatch(jsonString);

    if (typeMatch == null || keyMatch == null) {
      throw ArgumentError('Invalid Lotus private key format');
    }

    final type = typeMatch.group(1)!.toLowerCase();
    final privateKeyBase64 = keyMatch.group(1)!;

    var privateKey = base64.decode(privateKeyBase64);

    // BLS private keys in Lotus are little-endian, need to reverse
    if (type == 'bls') {
      privateKey = Uint8List.fromList(privateKey.reversed.toList());
      return accountFromPrivateKey(
        privateKey: privateKey,
        type: FilecoinSignatureType.bls,
        network: network,
      );
    } else if (type == 'secp256k1') {
      return accountFromPrivateKey(
        privateKey: privateKey,
        type: FilecoinSignatureType.secp256k1,
        network: network,
      );
    }

    throw ArgumentError('Unsupported signature type: $type');
  }

  /// Export account to Lotus private key format (hex)
  static String accountToLotus(FilecoinAccount account) {
    if (account.privateKey == null) {
      throw ArgumentError('Private key not found in account');
    }

    var privateKey = account.privateKey!;
    String typeName;

    // BLS private keys need to be reversed for Lotus format (little-endian)
    if (account.type == FilecoinSignatureType.bls) {
      privateKey = Uint8List.fromList(privateKey.reversed.toList());
      typeName = 'bls';
    } else {
      typeName = 'secp256k1';
    }

    final privateKeyBase64 = base64.encode(privateKey);
    final jsonString = '{"Type":"$typeName","PrivateKey":"$privateKeyBase64"}';

    return BytesUtils.toHexString(utf8.encode(jsonString));
  }

  /// Create new random account
  static FilecoinAccount create(FilecoinSignatureType type, FilecoinNetwork network) {
    late List<int> privateKey;

    switch (type) {
      case FilecoinSignatureType.secp256k1:
        privateKey = QuickCrypto.generateRandom(32);
        break;
      case FilecoinSignatureType.bls:
        // BLS also uses 32-byte private keys
        privateKey = QuickCrypto.generateRandom(32);
        break;
    }

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
    switch (type) {
      case FilecoinSignatureType.secp256k1:
        final publicKey = Secp256k1PrivateKey.fromBytes(privateKey).publicKey.uncompressed;

        final address = FilecoinAddress.fromSecp256k1PublicKey(
          publicKey,
          network: network,
        );

        return FilecoinAccount(
          type: FilecoinSignatureType.secp256k1,
          publicKey: publicKey,
          address: address,
        );

      case FilecoinSignatureType.bls:
        // BLS public key generation
        // For now, we'll use a placeholder since BLS crypto isn't fully in blockchain_utils
        // In production, you'd use a proper BLS library
        throw UnimplementedError('BLS key derivation requires additional BLS crypto library');
    }
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
    switch (type) {
      case FilecoinSignatureType.secp256k1:
        // Hash with Blake2b-256
        final hash = QuickCrypto.blake2b256Hash(data);

        // Sign with SECP256K1
        final privKey = Secp256k1PrivateKey.fromBytes(privateKey);
        final signature = privKey.signDigest(hash);

        // Filecoin SECP256K1 signature format: [r(32) | s(32) | v(1)]
        final signatureBytes = Uint8List(65);
        signatureBytes.setAll(0, signature.r);
        signatureBytes.setAll(32, signature.s);
        signatureBytes[64] = signature.v;

        return FilecoinSignature(
          type: FilecoinSignatureType.secp256k1,
          data: signatureBytes,
        );

      case FilecoinSignatureType.bls:
        // BLS signing would go here
        throw UnimplementedError('BLS signing requires additional BLS crypto library');
    }
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

  /// Verify signature
  static bool verify({
    required FilecoinSignature signature,
    required List<int> data,
    required List<int> publicKey,
  }) {
    switch (signature.type) {
      case FilecoinSignatureType.secp256k1:
        // Hash with Blake2b-256
        final hash = QuickCrypto.blake2b256Hash(data);

        // Extract r, s, v from signature
        final r = signature.data.sublist(0, 32);
        final s = signature.data.sublist(32, 64);
        final v = signature.data[64];

        try {
          final sig = Secp256k1Signature(r: r, s: s, v: v);
          final pubKey = Secp256k1PublicKey.fromBytes(publicKey);

          return pubKey.verifyDigest(hash, sig);
        } catch (e) {
          return false;
        }

      case FilecoinSignatureType.bls:
        // BLS verification would go here
        throw UnimplementedError('BLS verification requires additional BLS crypto library');
    }
  }

  /// Personal verify using FRC-102
  static bool personalVerify({
    required FilecoinSignature signature,
    required List<int> data,
    required List<int> publicKey,
  }) {
    final prefix = utf8.encode('$frc102Prefix${data.length}');
    final prefixedData = Uint8List.fromList([...prefix, ...data]);

    return verify(
      signature: signature,
      data: prefixedData,
      publicKey: publicKey,
    );
  }

  /// Recover public key from SECP256K1 signature
  static List<int> recoverPublicKey({
    required FilecoinSignature signature,
    required List<int> data,
  }) {
    if (signature.type != FilecoinSignatureType.secp256k1) {
      throw ArgumentError('Public key recovery is only supported for SECP256K1');
    }

    final hash = QuickCrypto.blake2b256Hash(data);

    final r = signature.data.sublist(0, 32);
    final s = signature.data.sublist(32, 64);
    final v = signature.data[64];

    final sig = Secp256k1Signature(r: r, s: s, v: v);
    final recoveredKey = sig.recoverPublicKey(hash);

    return recoveredKey.uncompressed;
  }

  /// Recover address from signature
  static FilecoinAddress recoverAddress({
    required FilecoinSignature signature,
    required List<int> data,
    required FilecoinNetwork network,
  }) {
    final publicKey = recoverPublicKey(signature: signature, data: data);

    return FilecoinAddress.fromSecp256k1PublicKey(
      publicKey,
      network: network,
    );
  }

  /// Helper: Determine network from derivation path
  static FilecoinNetwork _networkFromPath(String path) {
    // Parse coin type from path (m/44'/coinType'/...)
    final parts = path.split('/');
    if (parts.length >= 3) {
      final coinType = parts[2].replaceAll("'", '');
      final coinTypeInt = int.tryParse(coinType);

      if (coinTypeInt == 1) {
        return FilecoinNetwork.testnet;
      } else if (coinTypeInt == 461) {
        return FilecoinNetwork.mainnet;
      }
    }

    return FilecoinNetwork.mainnet;
  }
}
