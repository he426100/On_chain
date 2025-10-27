/// Filecoin cryptographic key management
/// 
/// This module provides classes for managing Filecoin private and public keys:
/// - [FilPrivateKey]: SECP256K1 private key operations
/// - [FilPublicKey]: SECP256K1 public key operations
/// 
/// Example usage:
/// ```dart
/// // Create private key from bytes
/// final privateKey = FilPrivateKey(keyBytes);
/// 
/// // Derive public key
/// final publicKey = privateKey.publicKey();
/// 
/// // Generate addresses
/// final f1Address = privateKey.toSecp256k1Address();
/// final f410Address = privateKey.toDelegatedAddress();
/// 
/// // Sign message
/// final signature = privateKey.sign(messageHash);
/// 
/// // Verify signature
/// final isValid = publicKey.verify(messageHash, signature);
/// ```

export 'private_key.dart';
export 'public_key.dart';

