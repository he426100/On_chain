import 'package:on_chain/conflux/src/exception/exception.dart';

/// Represents a single field in a CIP-23 struct type.
///
/// Each field has a name and a type, following the CIP-23 specification.
class CIP23TypeField {
  const CIP23TypeField({
    required this.name,
    required this.type,
  });

  /// The name of the field
  final String name;

  /// The type of the field (e.g., "string", "address", "uint256", "Person")
  final String type;

  /// Creates a [CIP23TypeField] from JSON
  factory CIP23TypeField.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('name') || !json.containsKey('type')) {
      throw ConfluxCIP23Exception(
        'CIP23TypeField must contain "name" and "type" fields',
        details: {'json': json},
      );
    }

    return CIP23TypeField(
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
      };

  @override
  String toString() => '$type $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CIP23TypeField &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(name, type);
}

