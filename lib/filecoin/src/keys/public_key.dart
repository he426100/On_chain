import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';
import 'package:on_chain/filecoin/src/exception/exception.dart';

/// Filecoin public key for SECP256K1
class FilPublicKey {
  final List<int> _keyBytes;

  /// Create public key from bytes
  FilPublicKey(List<int> keyBytes) : _keyBytes = List.unmodifiable(keyBytes) {
    if (keyBytes.length != 65 && keyBytes.length != 33) {
      throw FilecoinException(
        'Public key must be 33 (compressed) or 65 (uncompressed) bytes, got ${keyBytes.length}',
      );
    }
    
    // Validate public key format
    if (keyBytes.length == 65 && keyBytes[0] != 0x04) {
      throw FilecoinException('Invalid uncompressed public key prefix');
    }
    if (keyBytes.length == 33 && keyBytes[0] != 0x02 && keyBytes[0] != 0x03) {
      throw FilecoinException('Invalid compressed public key prefix');
    }
  }

  /// Create from hex string
  factory FilPublicKey.fromHex(String hex) {
    try {
      final bytes = BytesUtils.fromHexString(hex);
      return FilPublicKey(bytes);
    } catch (e) {
      throw FilecoinException('Invalid public key hex string', e);
    }
  }

  /// Get raw key bytes
  List<int> get bytes => _keyBytes;

  /// Get hex representation
  String toHex() => BytesUtils.toHexString(_keyBytes, prefix: "0x");

  /// Check if compressed format
  bool get isCompressed => _keyBytes.length == 33;

  /// Check if uncompressed format
  bool get isUncompressed => _keyBytes.length == 65;

  /// Convert to compressed format
  FilPublicKey toCompressed() {
    if (isCompressed) return this;
    
    try {
      final secp256k1 = Secp256k1PublicKey.fromBytes(_keyBytes);
      final compressedBytes = secp256k1.compressed;
      return FilPublicKey(compressedBytes);
    } catch (e) {
      throw FilecoinException('Failed to compress public key', e);
    }
  }

  /// Convert to uncompressed format
  FilPublicKey toUncompressed() {
    if (isUncompressed) return this;
    
    try {
      final secp256k1 = Secp256k1PublicKey.fromBytes(_keyBytes);
      final uncompressedBytes = secp256k1.uncompressed;
      return FilPublicKey(uncompressedBytes);
    } catch (e) {
      throw FilecoinException('Failed to uncompress public key', e);
    }
  }

  /// Convert to Filecoin SECP256K1 address (f1 type)
  FilecoinAddress toSecp256k1Address({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    try {
      // Filecoin uses uncompressed public key for address generation
      final uncompressed = isUncompressed ? _keyBytes : toUncompressed()._keyBytes;
      return FilecoinAddress.fromSecp256k1PublicKey(uncompressed, network: network);
    } catch (e) {
      throw FilecoinAddressException('Failed to create SECP256K1 address', e);
    }
  }

  /// Convert to Filecoin delegated address (f410 type - Ethereum compatible)
  FilecoinAddress toDelegatedAddress({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    try {
      // Filecoin uses uncompressed public key for address generation
      final uncompressed = isUncompressed ? _keyBytes : toUncompressed()._keyBytes;
      return FilecoinAddress.fromDelegatedPublicKey(uncompressed, network: network);
    } catch (e) {
      throw FilecoinAddressException('Failed to create delegated address', e);
    }
  }

  /// Verify a signature against a message digest
  /// 
  /// The signature should be 65 bytes: r(32) + s(32) + recovery_id(1)
  /// This method verifies the ECDSA signature using the public key.
  bool verify(List<int> digest, List<int> signature) {
    // Validate signature length: should be 65 bytes (r + s + recovery_id)
    if (signature.length != 65) {
      return false;
    }
    
    try {
      // Extract r and s from signature (first 64 bytes)
      // The last byte (recovery_id) is not used for verification
      final r = BigintUtils.fromBytes(signature.sublist(0, 32));
      final s = BigintUtils.fromBytes(signature.sublist(32, 64));
      
      // Create ECDSA signature from r and s
      final ecdsaSignature = ECDSASignature(r, s);
      
      // Create verifier from this public key
      final verifier = Secp256k1Verifier.fromKeyBytes(_keyBytes);
      
      // Verify the signature
      // Note: hashMessage is false because digest is already hashed
      return verifier.verify(
        digest,
        ecdsaSignature.toBytes(32), // Convert to 64-byte format (r + s)
        hashMessage: false,
      );
    } catch (e) {
      // Any error during verification means invalid signature
      return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilPublicKey &&
        BytesUtils.bytesEqual(other._keyBytes, _keyBytes);
  }

  @override
  int get hashCode => BytesUtils.toHexString(_keyBytes).hashCode;

  @override
  String toString() {
    final hex = BytesUtils.toHexString(_keyBytes);
    final format = isCompressed ? 'compressed' : 'uncompressed';
    return 'FilPublicKey($format, ${hex.substring(0, 16)}...)';
  }
}

