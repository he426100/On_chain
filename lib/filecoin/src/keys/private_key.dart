import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/keys/public_key.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';
import 'package:on_chain/filecoin/src/exception/exception.dart';

/// Filecoin private key for SECP256K1
class FilPrivateKey {
  final List<int> _keyBytes;

  /// Create private key from bytes
  FilPrivateKey(List<int> keyBytes) : _keyBytes = List.unmodifiable(keyBytes) {
    if (keyBytes.length != 32) {
      throw FilecoinException(
        'Private key must be 32 bytes, got ${keyBytes.length}',
      );
    }
  }

  /// Create from hex string
  factory FilPrivateKey.fromHex(String hex) {
    try {
      final bytes = BytesUtils.fromHexString(hex);
      return FilPrivateKey(bytes);
    } catch (e) {
      throw FilecoinException('Invalid private key hex string', e);
    }
  }

  /// Create from WIF (Wallet Import Format) - not commonly used in Filecoin
  factory FilPrivateKey.fromWif(String wif) {
    try {
      // WIF format: [version][32-byte private key][checksum]
      final decoded = Base58Decoder.checkDecode(wif);
      if (decoded.length < 33) {
        throw ArgumentError('Invalid WIF length');
      }
      // Skip version byte (first byte) and optional compression flag
      final keyBytes = decoded.sublist(1, 33);
      return FilPrivateKey(keyBytes);
    } catch (e) {
      throw FilecoinException('Invalid WIF format', e);
    }
  }

  /// Get raw key bytes
  List<int> get bytes => _keyBytes;

  /// Get hex representation
  String toHex() => BytesUtils.toHexString(_keyBytes, prefix: "0x");

  /// Derive public key
  FilPublicKey publicKey() {
    try {
      final secp256k1 = Secp256k1PrivateKey.fromBytes(_keyBytes);
      final publicKeyBytes = secp256k1.publicKey.uncompressed;
      return FilPublicKey(publicKeyBytes);
    } catch (e) {
      throw FilecoinSignerException('Failed to derive public key', e);
    }
  }

  /// Sign message digest
  /// Returns 65-byte signature (r + s + recovery_id)
  List<int> sign(List<int> digest) {
    try {
      final signingKey = Secp256k1SigningKey.fromBytes(keyBytes: _keyBytes);
      final signatureWithRecovery = signingKey.signConst(digest: digest);

      // Extract signature components
      final sig = signatureWithRecovery.item1; // ECDSASignature
      final recoveryId = signatureWithRecovery.item2; // recovery ID (0-3)

      // Build 65-byte compact signature
      final rBytes = BigintUtils.toBytes(sig.r, length: 32);
      final sBytes = BigintUtils.toBytes(sig.s, length: 32);
      return [...rBytes, ...sBytes, recoveryId];
    } catch (e) {
      throw FilecoinSignerException('Failed to sign digest', e);
    }
  }

  /// Create SECP256K1 address (f1) from this private key
  FilecoinAddress toSecp256k1Address({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final pubKey = publicKey();
    return pubKey.toSecp256k1Address(network: network);
  }

  /// Create delegated address (f410) from this private key
  FilecoinAddress toDelegatedAddress({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final pubKey = publicKey();
    return pubKey.toDelegatedAddress(network: network);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilPrivateKey &&
        BytesUtils.bytesEqual(other._keyBytes, _keyBytes);
  }

  @override
  int get hashCode => BytesUtils.toHexString(_keyBytes).hashCode;

  @override
  String toString() {
    // Only show first 8 characters for security
    final hex = BytesUtils.toHexString(_keyBytes);
    return 'FilPrivateKey(${hex.substring(0, 8)}...)';
  }
}

