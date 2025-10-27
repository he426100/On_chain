import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/transaction/fil_transaction.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';
import 'package:on_chain/filecoin/src/keys/keys.dart';
import 'package:on_chain/filecoin/src/exception/exception.dart';

/// Signature types for Filecoin
enum FilecoinSignatureType {
  secp256k1(1),
  delegated(3);

  const FilecoinSignatureType(this.value);
  final int value;
}

/// Filecoin signature representation
class FilecoinSignature {
  final FilecoinSignatureType type;
  final List<int> data;

  const FilecoinSignature({
    required this.type,
    required this.data,
  });

  /// Get signature type code
  int get code => type.value;

  /// Create signature from Lotus RPC format
  /// Lotus format: {"Type": 1 or 3, "Data": "base64-encoded-signature"}
  factory FilecoinSignature.fromLotus(Map<String, dynamic> json) {
    final typeCode = json['Type'] as int;
    final dataBase64 = json['Data'] as String;

    final type = typeCode == 1
        ? FilecoinSignatureType.secp256k1
        : FilecoinSignatureType.delegated;

    return FilecoinSignature(
      type: type,
      data: base64.decode(dataBase64),
    );
  }

  /// Convert to Lotus RPC format
  /// Returns: {"Type": 1 or 3, "Data": "base64-encoded-signature"}
  Map<String, dynamic> toLotus() {
    return {
      'Type': type.value,
      'Data': base64.encode(data),
    };
  }

  /// Create signature from Lotus-style hex string
  /// Lotus adds 0x01 or 0x03 prefix to the signature depending on the type
  factory FilecoinSignature.fromLotusHex(String hexString) {
    final bytes = BytesUtils.fromHexString(hexString);

    if (bytes.isEmpty) {
      throw FilecoinSignerException('Invalid Lotus hex signature: empty');
    }

    final typeCode = bytes[0];
    final signatureData = bytes.sublist(1);

    if (typeCode == 0x01) {
      // SECP256K1 signature
      if (signatureData.length != 65) {
        throw FilecoinSignerException(
            'SECP256K1 signature length should be 65, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: signatureData,
      );
    } else if (typeCode == 0x03) {
      // Delegated signature
      if (signatureData.length != 65) {
        throw FilecoinSignerException(
            'Delegated signature length should be 65, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.delegated,
        data: signatureData,
      );
    }

    throw FilecoinSignerException(
        'Invalid signature type byte: 0x${typeCode.toRadixString(16)}');
  }

  /// Convert to Lotus-style hex string
  /// Adds 0x01 or 0x03 prefix depending on signature type
  String toLotusHex() {
    final prefix = type == FilecoinSignatureType.secp256k1 ? 0x01 : 0x03;
    return BytesUtils.toHexString([prefix, ...data]);
  }

  /// Validate signature data length
  bool isValid() {
    // Both SECP256K1 and delegated use 65-byte signatures
    return data.length == 65;
  }

  Map<String, dynamic> toJson() {
    return toLotus();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilecoinSignature &&
        other.type == type &&
        BytesUtils.bytesEqual(other.data, data);
  }

  @override
  int get hashCode => Object.hash(type, BytesUtils.toHexString(data));

  @override
  String toString() =>
      'FilecoinSignature(type: ${type.value}, data: ${BytesUtils.toHexString(data).substring(0, 20)}...)';
}

/// Signed Filecoin transaction
class FilecoinSignedTransaction {
  final FilecoinTransaction message;
  final FilecoinSignature signature;

  const FilecoinSignedTransaction({
    required this.message,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'Message': message.toJson(),
      'Signature': signature.toJson(),
    };
  }
}

/// Filecoin transaction signer
/// 
/// This class provides methods for signing Filecoin transactions and creating addresses.
/// It now uses the [FilPrivateKey] and [FilPublicKey] classes for better key management.
class FilecoinSigner {
  final FilPrivateKey _privateKey;

  /// Create signer with a private key
  FilecoinSigner(this._privateKey);

  /// Create signer from raw bytes
  factory FilecoinSigner.fromBytes(List<int> bytes) {
    return FilecoinSigner(FilPrivateKey(bytes));
  }

  /// Create signer from hex string
  factory FilecoinSigner.fromHex(String hex) {
    return FilecoinSigner(FilPrivateKey.fromHex(hex));
  }

  /// Get the private key
  FilPrivateKey get privateKey => _privateKey;

  /// Get the public key
  FilPublicKey get publicKey => _privateKey.publicKey();

  /// Get SECP256K1 address (f1 type)
  FilecoinAddress getSecp256k1Address({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    return _privateKey.toSecp256k1Address(network: network);
  }

  /// Get delegated address (f410 type)
  FilecoinAddress getDelegatedAddress({
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    return _privateKey.toDelegatedAddress(network: network);
  }

  /// Sign a transaction
  FilecoinSignedTransaction sign(FilecoinTransaction transaction) {
    try {
      // Get CID (Content Identifier) for the transaction
      // CID = [prefix] + Blake2b-256(CBOR-encoded message)
      final cid = transaction.getCid();

      // Hash the CID with Blake2b-256 (as per Filecoin specification)
      // This double-hashing is intentional and matches the reference implementation
      // See: iso-filecoin wallet.js signMessage() and sign()
      final messageHash = QuickCrypto.blake2b256Hash(cid);

      // Sign with the private key
      final signatureData = _privateKey.sign(messageHash);

      // Determine signature type based on sender address
      final signatureType = transaction.from.type == FilecoinAddressType.delegated
          ? FilecoinSignatureType.delegated
          : FilecoinSignatureType.secp256k1;

      final filSignature = FilecoinSignature(
        type: signatureType,
        data: signatureData,
      );

      return FilecoinSignedTransaction(
        message: transaction,
        signature: filSignature,
      );
    } catch (e) {
      throw FilecoinSignerException('Failed to sign transaction', e);
    }
  }

  /// Verify a signature for a transaction
  bool verify({
    required FilecoinTransaction transaction,
    required FilecoinSignature signature,
  }) {
    try {
      final cid = transaction.getCid();
      final messageHash = QuickCrypto.blake2b256Hash(cid);
      return publicKey.verify(messageHash, signature.data);
    } catch (e) {
      return false;
    }
  }

  // ==================== Static helper methods (backward compatibility) ====================

  /// Sign a transaction with a private key (static method for backward compatibility)
  static FilecoinSignedTransaction signTransaction({
    required FilecoinTransaction transaction,
    required List<int> privateKey,
  }) {
    final signer = FilecoinSigner.fromBytes(privateKey);
    return signer.sign(transaction);
  }

  /// Create address from private key for SECP256k1 (static method for backward compatibility)
  static FilecoinAddress createSecp256k1Address(
    List<int> privateKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final privKey = FilPrivateKey(privateKey);
    return privKey.toSecp256k1Address(network: network);
  }

  /// Create delegated address from private key (static method for backward compatibility)
  static FilecoinAddress createDelegatedAddress(
    List<int> privateKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final privKey = FilPrivateKey(privateKey);
    return privKey.toDelegatedAddress(network: network);
  }

  /// Verify a signature (static method for backward compatibility)
  /// 
  /// Note: This performs basic validation checks.
  /// For full cryptographic verification, use a dedicated verification library.
  static bool verifySignature({
    required FilecoinTransaction transaction,
    required FilecoinSignature signature,
    required FilecoinAddress senderAddress,
  }) {
    try {
      // Basic validation: signature should be 65 bytes
      if (signature.data.length != 65) {
        return false;
      }

      // Verify the sender address matches
      if (transaction.from != senderAddress) {
        return false;
      }

      // Additional validation: check that signature type matches address type
      final expectedType = senderAddress.type == FilecoinAddressType.delegated
          ? FilecoinSignatureType.delegated
          : FilecoinSignatureType.secp256k1;

      if (signature.type != expectedType) {
        return false;
      }

      // Basic format validation passed
      // Note: Full ECDSA verification would require recovering the public key
      // and comparing it with the sender address. This is left as a future enhancement.
      return true;
    } catch (e) {
      return false;
    }
  }
}
