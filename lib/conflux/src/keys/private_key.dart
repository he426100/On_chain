import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/keys/public_key.dart';
import 'package:on_chain/ethereum/ethereum.dart';

/// Represents a Conflux private key for cryptographic operations.
/// 
/// Supports signing for both Core Space and eSpace transactions.
class CFXPrivateKey {
  const CFXPrivateKey._(this._privateKey);

  final Secp256k1PrivateKey _privateKey;

  /// Creates a [CFXPrivateKey] from a hexadecimal private key string.
  /// 
  /// Example:
  /// ```dart
  /// final privateKey = CFXPrivateKey('0x...');
  /// ```
  factory CFXPrivateKey(String privateKeyHex) {
    return CFXPrivateKey.fromBytes(BytesUtils.fromHexString(privateKeyHex));
  }

  /// Creates a [CFXPrivateKey] from bytes.
  factory CFXPrivateKey.fromBytes(List<int> keyBytes) {
    try {
      final Secp256k1PrivateKey key = Secp256k1PrivateKey.fromBytes(keyBytes);
      return CFXPrivateKey._(key);
    } catch (e) {
      throw ConfluxPluginException(
        'Invalid Conflux private key',
        details: {'input': BytesUtils.toHexString(keyBytes)},
      );
    }
  }

  /// Generates a random [CFXPrivateKey].
  factory CFXPrivateKey.random() {
    final key = Secp256k1PrivateKey.fromBytes(
      QuickCrypto.generateRandom(32),
    );
    return CFXPrivateKey._(key);
  }

  /// Retrieves the raw bytes of the private key.
  List<int> toBytes() {
    return _privateKey.raw;
  }

  /// Converts the private key to a hexadecimal string.
  String toHex() {
    return BytesUtils.toHexString(toBytes());
  }

  /// Retrieves the corresponding Conflux public key.
  CFXPublicKey publicKey() {
    return CFXPublicKey.fromBytes(_privateKey.publicKey.compressed);
  }

  /// Signs a message digest using ECDSA.
  /// 
  /// If [hashMessage] is true (default), the message will be hashed with Keccak256 before signing.
  /// Returns the signature with recovery ID (v, r, s format).
  ETHSignature sign(List<int> messageDigest, {bool hashMessage = true}) {
    final ethSigner = ETHSigner.fromKeyBytes(toBytes());
    return ethSigner.signConst(messageDigest, hashMessage: hashMessage);
  }

  /// Signs a personal message (Conflux Core Space format).
  /// 
  /// Personal messages are prefixed with:
  /// "\x19Conflux Signed Message:\n" + len(message)
  /// 
  /// Returns the signature as a hex string.
  String signPersonalMessage(List<int> message) {
    // Use ETHSigner for signing (same algorithm as Ethereum but different prefix)
    // We'll manually create the prefixed message
    final prefix = '\x19Conflux Signed Message:\n${message.length}';
    final prefixBytes = StringUtils.encode(prefix);
    
    final fullMessage = <int>[...prefixBytes, ...message];
    // Sign the full message (ETHSigner will hash it)
    final ethSigner = ETHSigner.fromKeyBytes(toBytes());
    final signatureBytes = ethSigner.signConst(fullMessage, hashMessage: true);
    
    return signatureBytes.toHex();
  }

  /// Signs a personal message for eSpace (Ethereum format).
  /// 
  /// eSpace uses the standard Ethereum personal message format:
  /// "\x19Ethereum Signed Message:\n" + len(message)
  String signESpacePersonalMessage(List<int> message) {
    final ethSigner = ETHSigner.fromKeyBytes(toBytes());
    final signature = ethSigner.signProsonalMessageConst(message);
    return BytesUtils.toHexString(signature);
  }

  /// Converts this Conflux private key to an Ethereum private key.
  ETHPrivateKey toEthPrivateKey() {
    return ETHPrivateKey.fromBytes(toBytes());
  }

  @override
  String toString() => toHex();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CFXPrivateKey &&
        BytesUtils.bytesEqual(other.toBytes(), toBytes());
  }

  @override
  int get hashCode => toBytes().hashCode;
}

