import 'package:on_chain/conflux/src/cip23/cip23_type_field.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';

/// Represents CIP-23 typed structured data for signing.
///
/// CIP-23 is Conflux's version of Ethereum's EIP-712, with the following differences:
/// - Uses "CIP23Domain" instead of "EIP712Domain"
/// - chainId field is mandatory in CIP23Domain
/// - Address type must be in Base32 format, converted to hex before signing
class CIP23TypedData {
  const CIP23TypedData({
    required this.types,
    required this.primaryType,
    required this.domain,
    required this.message,
  });

  /// Type definitions for all struct types used in the message
  /// Must contain "CIP23Domain" as a key
  final Map<String, List<CIP23TypeField>> types;

  /// The primary type to hash (must be defined in types)
  final String primaryType;

  /// The domain separator parameters
  final Map<String, dynamic> domain;

  /// The message to be signed
  final Map<String, dynamic> message;

  /// Creates a [CIP23TypedData] from JSON
  factory CIP23TypedData.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (!json.containsKey('types')) {
      throw ConfluxCIP23Exception('CIP23TypedData must contain "types" field');
    }
    if (!json.containsKey('primaryType')) {
      throw ConfluxCIP23Exception(
          'CIP23TypedData must contain "primaryType" field');
    }
    if (!json.containsKey('domain')) {
      throw ConfluxCIP23Exception('CIP23TypedData must contain "domain" field');
    }
    if (!json.containsKey('message')) {
      throw ConfluxCIP23Exception(
          'CIP23TypedData must contain "message" field');
    }

    // Parse types
    final typesJson = json['types'] as Map<String, dynamic>;
    final types = <String, List<CIP23TypeField>>{};

    // Check for CIP23Domain
    if (!typesJson.containsKey('CIP23Domain')) {
      throw ConfluxCIP23Exception(
        'CIP23TypedData types must contain "CIP23Domain"',
      );
    }

    for (final entry in typesJson.entries) {
      final fieldList = entry.value as List;
      types[entry.key] = fieldList
          .map((field) => CIP23TypeField.fromJson(field as Map<String, dynamic>))
          .toList();
    }

    // Validate that primaryType is defined
    final primaryType = json['primaryType'] as String;
    if (!types.containsKey(primaryType)) {
      throw ConfluxCIP23Exception(
        'primaryType "$primaryType" is not defined in types',
        details: {'primaryType': primaryType, 'availableTypes': types.keys},
      );
    }

    // Validate domain contains chainId
    final domain = json['domain'] as Map<String, dynamic>;
    if (!domain.containsKey('chainId')) {
      throw ConfluxCIP23Exception(
        'CIP23Domain must contain "chainId" field',
        details: {'domain': domain},
      );
    }

    return CIP23TypedData(
      types: types,
      primaryType: primaryType,
      domain: domain,
      message: json['message'] as Map<String, dynamic>,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
        'types': types.map((key, value) =>
            MapEntry(key, value.map((field) => field.toJson()).toList())),
        'primaryType': primaryType,
        'domain': domain,
        'message': message,
      };

  @override
  String toString() => 'CIP23TypedData(primaryType: $primaryType)';
}

