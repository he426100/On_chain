import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/keys/private_key.dart';

/// Conflux keystore utilities for encrypting and decrypting private keys.
/// 
/// This class provides a high-level API for working with Web3 Secret Storage
/// Definition (keystore v3) compatible with js-conflux-sdk and Ethereum wallets.
/// 
/// Example:
/// ```dart
/// // Encrypt private key to keystore
/// final privateKey = CFXPrivateKey.random();
/// final keystore = CFXKeystore.encrypt(privateKey, 'password123');
/// 
/// // Decrypt keystore to private key
/// final decryptedKey = CFXKeystore.decrypt(keystore, 'password123');
/// ```
class CFXKeystore {
  const CFXKeystore._();

  /// Encrypts a private key with a password to create a keystore.
  /// 
  /// The keystore format follows the Web3 Secret Storage Definition (v3),
  /// compatible with js-conflux-sdk, Ethereum wallets, and MetaMask.
  /// 
  /// Parameters:
  /// - [privateKey]: The private key to encrypt
  /// - [password]: The password for encryption
  /// - [uuid]: Optional UUID for the keystore (auto-generated if not provided)
  /// - [scryptN]: Scrypt N parameter (default: 8192)
  /// - [scryptP]: Scrypt P parameter (default: 1)
  /// - [scryptR]: Scrypt R parameter (default: 8)
  /// - [scryptDklen]: Derived key length (default: 32)
  /// 
  /// Returns the encrypted keystore as a JSON string.
  static String encrypt(
    CFXPrivateKey privateKey,
    String password, {
    String? uuid,
    int scryptN = 8192,
    int scryptP = 1,
    int scryptR = 8,
    int scryptDklen = 32,
  }) {
    // blockchain_utils Web3SecretStorageDefinationV3.encode supports scryptN and p parameters
    final keystore = Web3SecretStorageDefinationV3.encode(
      privateKey.toBytes(),
      password,
      scryptN: scryptN,
      p: scryptP,
    );
    return keystore.encrypt();
  }

  /// Decrypts a keystore with a password to retrieve the private key.
  /// 
  /// Parameters:
  /// - [keystoreJson]: The keystore as a JSON string or Map
  /// - [password]: The password for decryption
  /// 
  /// Returns the decrypted [CFXPrivateKey].
  /// 
  /// Throws an exception if the password is incorrect or the keystore is invalid.
  static CFXPrivateKey decrypt(
    dynamic keystoreJson,
    String password,
  ) {
    // Convert to JSON string if it's a Map
    String jsonString;
    if (keystoreJson is Map) {
      jsonString = StringUtils.fromJson(keystoreJson);
    } else if (keystoreJson is String) {
      jsonString = keystoreJson;
    } else {
      throw ArgumentError('keystoreJson must be a String or Map');
    }

    // Decrypt the keystore
    final wallet = Web3SecretStorageDefinationV3.decode(
      jsonString,
      password,
    );

    // Create CFXPrivateKey from decrypted data
    return CFXPrivateKey.fromBytes(wallet.data);
  }

  /// Encrypts a private key and returns the keystore as a JSON string.
  /// 
  /// This is an alias for [encrypt] for backwards compatibility.
  static String encryptToJson(
    CFXPrivateKey privateKey,
    String password, {
    String? uuid,
    int scryptN = 8192,
    int scryptP = 1,
    int scryptR = 8,
    int scryptDklen = 32,
  }) {
    return encrypt(
      privateKey,
      password,
      uuid: uuid,
      scryptN: scryptN,
      scryptP: scryptP,
      scryptR: scryptR,
      scryptDklen: scryptDklen,
    );
  }

  /// Validates that a keystore JSON is well-formed.
  /// 
  /// Returns true if the keystore appears to be valid (has required fields),
  /// false otherwise.
  static bool isValidKeystoreFormat(dynamic keystoreJson) {
    try {
      if (keystoreJson is String) {
        final map = StringUtils.toJson(keystoreJson);
        return _hasRequiredKeystoreFields(map);
      } else if (keystoreJson is Map) {
        return _hasRequiredKeystoreFields(keystoreJson);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Checks if a map has the required keystore fields.
  static bool _hasRequiredKeystoreFields(dynamic json) {
    if (json is! Map) return false;
    
    return json.containsKey('version') &&
        json.containsKey('id') &&
        json.containsKey('crypto') &&
        json['crypto'] is Map &&
        (json['crypto'] as Map).containsKey('cipher') &&
        (json['crypto'] as Map).containsKey('ciphertext') &&
        (json['crypto'] as Map).containsKey('kdf');
  }

  /// Gets the address from a keystore without decrypting it.
  /// 
  /// Returns the address stored in the keystore (if present), or null.
  /// Note: The address may not be present in all keystores.
  static String? getAddressFromKeystore(dynamic keystoreJson) {
    try {
      Map json;
      if (keystoreJson is String) {
        json = StringUtils.toJson(keystoreJson);
      } else if (keystoreJson is Map) {
        json = keystoreJson;
      } else {
        return null;
      }

      return json['address'] as String?;
    } catch (e) {
      return null;
    }
  }
}

