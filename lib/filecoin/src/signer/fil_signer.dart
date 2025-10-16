import 'dart:convert';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/address/fil_address.dart';
import 'package:on_chain/filecoin/src/transaction/fil_transaction.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';

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
      throw ArgumentError('Invalid Lotus hex signature: empty');
    }

    final typeCode = bytes[0];
    final signatureData = bytes.sublist(1);

    if (typeCode == 0x01) {
      // SECP256K1 signature
      if (signatureData.length != 65) {
        throw ArgumentError(
            'SECP256K1 signature length should be 65, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: signatureData,
      );
    } else if (typeCode == 0x03) {
      // Delegated signature
      if (signatureData.length != 65) {
        throw ArgumentError(
            'Delegated signature length should be 65, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.delegated,
        data: signatureData,
      );
    }

    throw ArgumentError(
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
class FilecoinSigner {
  /// Sign a transaction with a private key
  static FilecoinSignedTransaction signTransaction({
    required FilecoinTransaction transaction,
    required List<int> privateKey,
  }) {
    // Get CID (Content Identifier) for the transaction
    // CID = [prefix] + Blake2b-256(CBOR-encoded message)
    final cid = transaction.getCid();

    // Hash the CID with Blake2b-256 (as per Filecoin specification)
    // This double-hashing is intentional and matches the reference implementation
    // See: iso-filecoin wallet.js signMessage() and sign()
    final messageHash = QuickCrypto.blake2b256Hash(cid);

    // Sign with SECP256k1 and get recovery ID
    // Filecoin requires 65-byte compact signature format: r (32) + s (32) + v (1)
    final signingKey = Secp256k1SigningKey.fromBytes(keyBytes: privateKey);
    final signatureWithRecovery = signingKey.signConst(digest: messageHash);

    // Extract signature components
    final sig = signatureWithRecovery.item1; // ECDSASignature
    final recoveryId = signatureWithRecovery.item2; // recovery ID (0-3)

    // Build 65-byte compact signature
    final rBytes = BigintUtils.toBytes(sig.r, length: 32);
    final sBytes = BigintUtils.toBytes(sig.s, length: 32);
    final signatureData = [...rBytes, ...sBytes, recoveryId];

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
  }

  /// Create address from private key for SECP256k1
  static FilecoinAddress createSecp256k1Address(
    List<int> privateKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final secp256k1 = Secp256k1PrivateKey.fromBytes(privateKey);
    final publicKey = secp256k1.publicKey.uncompressed;
    return FilecoinAddress.fromSecp256k1PublicKey(publicKey, network: network);
  }

  /// Create delegated address from private key
  static FilecoinAddress createDelegatedAddress(
    List<int> privateKey, {
    FilecoinNetwork network = FilecoinNetwork.mainnet,
  }) {
    final secp256k1 = Secp256k1PrivateKey.fromBytes(privateKey);
    final publicKey = secp256k1.publicKey.uncompressed;
    return FilecoinAddress.fromDelegatedPublicKey(publicKey, network: network);
  }

  /// Verify a signature (simplified - always returns true for now)
  static bool verifySignature({
    required FilecoinTransaction transaction,
    required FilecoinSignature signature,
    required FilecoinAddress senderAddress,
  }) {
    // TODO: Implement proper signature verification
    // This is a simplified version that just checks basic constraints
    return signature.data.length >= 64 && transaction.from == senderAddress;
  }
}