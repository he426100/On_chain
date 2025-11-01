import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/address/espace_address.dart';

/// Represents a Conflux public key.
/// 
/// This class wraps a secp256k1 public key and provides methods to derive
/// both Core Space (Base32) and eSpace (0x) addresses.
/// 
/// Conflux uses the same cryptographic primitives as Ethereum (secp256k1 + Keccak256).
class CFXPublicKey {
  CFXPublicKey._(this._key);

  /// Creates a public key from bytes.
  /// 
  /// The bytes should be a valid secp256k1 public key (compressed or uncompressed).
  factory CFXPublicKey.fromBytes(List<int> bytes) {
    return CFXPublicKey._(Secp256k1PublicKey.fromBytes(bytes));
  }

  /// Creates a public key from a hex string.
  factory CFXPublicKey.fromHex(String hex) {
    return CFXPublicKey._(Secp256k1PublicKey.fromBytes(BytesUtils.fromHexString(hex)));
  }

  final Secp256k1PublicKey _key;

  /// Returns the public key as compressed bytes (33 bytes).
  List<int> toCompressedBytes() {
    return _key.compressed;
  }

  /// Returns the public key as uncompressed bytes (65 bytes).
  List<int> toUncompressedBytes() {
    return _key.uncompressed;
  }

  /// Returns the public key as a hex string (compressed format).
  String toHex() {
    return BytesUtils.toHexString(toCompressedBytes());
  }

  /// Generates a Conflux Core Space address for the specified network.
  /// 
  /// The address is derived using Ethereum's address derivation algorithm
  /// (Keccak256 hash of uncompressed public key), then converted to a user
  /// address type (0x1 prefix) as per Conflux convention, and encoded in
  /// Conflux's Base32 format (CIP-37).
  /// 
  /// Note: Conflux automatically converts addresses derived from private keys
  /// to user address type (0x1...), regardless of the original hash output.
  /// 
  /// Example:
  /// ```dart
  /// final address = publicKey.toAddress(1029); // mainnet
  /// print(address.toBase32()); // cfx:...
  /// ```
  CFXAddress toAddress(int networkId) {
    // Use Ethereum address encoder to derive address from public key
    final hexAddress = EthAddrEncoder().encodeKey(toCompressedBytes());
    
    // Convert to user address type (0x1...) as per Conflux convention
    // This matches the behavior of js-conflux-sdk's privateKeyToAddress
    final userHexAddress = '0x1${hexAddress.substring(3)}';
    
    return CFXAddress.fromHex(userHexAddress, networkId);
  }

  /// Generates an eSpace address (0x format, Ethereum-compatible).
  /// 
  /// Note: eSpace addresses are NOT converted to user address type (0x1...)
  /// as they follow Ethereum's standard address derivation.
  ESpaceAddress toESpaceAddress() {
    // Use EthAddrEncoder to get address from public key
    // eSpace addresses maintain the original Ethereum-style address format
    final hexAddress = EthAddrEncoder().encodeKey(toCompressedBytes());

    return ESpaceAddress(hexAddress);
  }

  @override
  String toString() => toHex();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CFXPublicKey && other._key == _key;
  }

  @override
  int get hashCode => _key.hashCode;
}
