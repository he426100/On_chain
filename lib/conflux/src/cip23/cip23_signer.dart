import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/crypto/crypto/cdsa/point/base.dart';
import 'package:on_chain/conflux/src/cip23/cip23_typed_data.dart';
import 'package:on_chain/conflux/src/cip23/cip23_encoder.dart';
import 'package:on_chain/conflux/src/cip23/cip23_type_field.dart';
import 'package:on_chain/conflux/src/keys/private_key.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';

/// Signer for CIP-23 typed structured data.
///
/// Provides methods to sign and verify CIP-23 typed data messages.
class CIP23Signer {
  const CIP23Signer._();

  /// Signs CIP-23 typed data with a private key.
  ///
  /// Returns the signature as a hexadecimal string (130 characters, 65 bytes).
  static String sign(CFXPrivateKey privateKey, CIP23TypedData typedData) {
    final messageHash = CIP23Encoder.hashMessage(typedData);
    final signature = privateKey.sign(messageHash, hashMessage: false);

    // Concatenate r, s, v (without 0x prefix)
    final rBytes = BigintUtils.toBytes(signature.r, length: 32);
    final sBytes = BigintUtils.toBytes(signature.s, length: 32);
    final r = BytesUtils.toHexString(rBytes, lowerCase: false);
    final s = BytesUtils.toHexString(sBytes, lowerCase: false);
    final v = signature.v.toRadixString(16).padLeft(2, '0');

    return '$r$s$v';
  }

  /// Recovers the signer address from a CIP-23 signature.
  ///
  /// Returns the Core Space address that signed the message.
  static CFXAddress recover(
    String signature,
    CIP23TypedData typedData,
    int networkId,
  ) {
    final messageHash = CIP23Encoder.hashMessage(typedData);

    // Parse signature components
    if (signature.startsWith('0x')) {
      signature = signature.substring(2);
    }

    if (signature.length != 130) {
      throw ArgumentError('Invalid signature length: ${signature.length}');
    }

    final r = BigInt.parse(signature.substring(0, 64), radix: 16);
    final s = BigInt.parse(signature.substring(64, 128), radix: 16);
    final v = int.parse(signature.substring(128, 130), radix: 16);

    // Recovery ID must be 0 or 1 for ECDSA recovery
    // The v value in the signature is already offset by 27 (from ETHSigner)
    final recoverId = v >= 27 ? v - 27 : v;

    // Create ECDSA signature (without v, just r and s)
    final rBytes = BigintUtils.toBytes(r, length: 32);
    final sBytes = BigintUtils.toBytes(s, length: 32);
    final sigBytes = [...rBytes, ...sBytes];

    // Recover public key using ECDSA signature recovery
    final signatureBytes = ECDSASignature.fromBytes(
      sigBytes,
      CryptoSignerConst.generatorSecp256k1,
    );
    final recoveredPublicKey = signatureBytes.recoverPublicKey(
      messageHash,
      CryptoSignerConst.generatorSecp256k1,
      recoverId,
    );

    // Convert public key to address
    // For ECDSA public key recovery, we get a ProjectiveECCPoint
    // We need the uncompressed format (65 bytes: 0x04 + 32 bytes x + 32 bytes y)
    // Then remove the 0x04 prefix and hash the remaining 64 bytes
    final pubKeyUncompressed = recoveredPublicKey.toBytes(EncodeType.uncompressed);
    final pubKeyBytes = pubKeyUncompressed.sublist(1); // Remove 0x04 prefix
    final hash = QuickCrypto.keccack256Hash(pubKeyBytes);
    final addressBytes = hash.sublist(12); // Take last 20 bytes

    return CFXAddress.fromHex(
      '0x${BytesUtils.toHexString(addressBytes, lowerCase: false)}',
      networkId,
    );
  }

  /// Computes the CIP-23 message hash for typed data.
  ///
  /// This is the hash that gets signed.
  static List<int> getMessageHash(CIP23TypedData typedData) {
    return CIP23Encoder.hashMessage(typedData);
  }

  /// Computes the domain separator hash.
  static List<int> getDomainSeparator(CIP23TypedData typedData) {
    return CIP23Encoder.hashDomain(typedData);
  }

  /// Encodes a type string according to CIP-23 specification.
  static String encodeType(
    String primaryType,
    Map<String, List> types,
  ) {
    final convertedTypes = types.map(
      (key, value) => MapEntry(
        key,
        value
            .map((field) => field is Map<String, dynamic> ? field : {})
            .map((field) => CIP23TypeField(
                  name: field['name'] as String? ?? '',
                  type: field['type'] as String? ?? '',
                ))
            .toList(),
      ),
    );
    return CIP23Encoder.encodeType(primaryType, convertedTypes);
  }
}

