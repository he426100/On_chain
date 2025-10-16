import 'package:blockchain_utils/blockchain_utils.dart';
import 'dart:convert' show base64;

/// Filecoin signature types
enum FilecoinSignatureType {
  secp256k1(1),
  bls(2);

  const FilecoinSignatureType(this.code);
  final int code;

  static FilecoinSignatureType fromCode(int code) {
    return values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw ArgumentError('Invalid signature type code: $code'),
    );
  }

  String get name {
    switch (this) {
      case FilecoinSignatureType.secp256k1:
        return 'SECP256K1';
      case FilecoinSignatureType.bls:
        return 'BLS';
    }
  }
}

/// Filecoin signature class
/// Supports both SECP256K1 and BLS signatures with Lotus format conversion
class FilecoinSignature {
  final FilecoinSignatureType type;
  final List<int> data;

  const FilecoinSignature({
    required this.type,
    required this.data,
  });

  /// Get signature type code
  int get code => type.code;

  /// Create signature from Lotus RPC format
  /// Lotus format: {"Type": 1 or 2, "Data": "base64-encoded-signature"}
  factory FilecoinSignature.fromLotus(Map<String, dynamic> json) {
    final typeCode = json['Type'] as int;
    final dataBase64 = json['Data'] as String;

    return FilecoinSignature(
      type: FilecoinSignatureType.fromCode(typeCode),
      data: base64.decode(dataBase64),
    );
  }

  /// Convert to Lotus RPC format
  /// Returns: {"Type": 1 or 2, "Data": "base64-encoded-signature"}
  Map<String, dynamic> toLotus() {
    return {
      'Type': type.code,
      'Data': base64.encode(data),
    };
  }

  /// Create signature from Lotus-style hex string
  /// Lotus adds 0x01 or 0x02 prefix to the signature depending on the type
  factory FilecoinSignature.fromLotusHex(String hexString) {
    final bytes = BytesUtils.fromHexString(hexString);

    if (bytes.isEmpty) {
      throw ArgumentError('Invalid Lotus hex signature: empty');
    }

    final typeCode = bytes[0];
    final signatureData = bytes.sublist(1);

    if (typeCode == 0x02) {
      // BLS signature
      if (signatureData.length != 96) {
        throw ArgumentError('BLS signature length should be 96, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.bls,
        data: signatureData,
      );
    } else if (typeCode == 0x01) {
      // SECP256K1 signature
      if (signatureData.length != 65) {
        throw ArgumentError('SECP256K1 signature length should be 65, got ${signatureData.length}');
      }
      return FilecoinSignature(
        type: FilecoinSignatureType.secp256k1,
        data: signatureData,
      );
    }

    throw ArgumentError('Invalid signature type byte: 0x${typeCode.toRadixString(16)}');
  }

  /// Convert to Lotus-style hex string
  /// Adds 0x01 or 0x02 prefix depending on signature type
  String toLotusHex() {
    final prefix = type == FilecoinSignatureType.bls ? 0x02 : 0x01;
    return BytesUtils.toHexString([prefix, ...data]);
  }

  /// Validate signature data length
  bool isValid() {
    switch (type) {
      case FilecoinSignatureType.secp256k1:
        return data.length == 65;
      case FilecoinSignatureType.bls:
        return data.length == 96;
    }
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
  String toString() => 'FilecoinSignature(type: ${type.name}, data: ${BytesUtils.toHexString(data).substring(0, 20)}...)';
}
