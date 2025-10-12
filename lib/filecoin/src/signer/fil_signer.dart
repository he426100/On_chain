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

  Map<String, dynamic> toJson() {
    return {
      'Type': type.value,
      'Data': base64.encode(data),
    };
  }
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
    // Get CBOR-encoded message bytes
    final messageBytes = transaction.getMessageBytes();

    // Hash the message with Blake2b-256 (as per Filecoin specification)
    // This is what Filecoin nodes use to verify signatures
    final messageHash = QuickCrypto.blake2b256Hash(messageBytes);

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