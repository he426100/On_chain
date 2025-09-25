import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/bcs/exeption/exeption.dart';
import 'package:on_chain/bcs/move/utils/utils.dart';
import 'package:on_chain/bcs/serialization/serialization.dart';
import 'package:on_chain/utils/utils/map_utils.dart';

/// Abstract base class for Move types, extends [BcsSerialization].
/// This class holds a value of type [T] and provides layout structure serialization.
abstract class MoveType<T> extends BcsSerialization {
  /// The value associated with the Move type
  final T value;
  const MoveType(this.value);

  @override
  Map<String, dynamic> toLayoutStruct() {
    return {"value": value}; // Returns the value as a layout structure
  }
}

/// Represents a Move `u8` argument type (8-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU8 extends MoveType<int> {
  MoveU8(int value) : super(MoveUtils.parseU8(value: value));

  /// Parses an object to MoveU8, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  factory MoveU8.parse(Object? object) {
    if (object is MoveU8) return object;
    return MoveU8(MoveUtils.parseU8(value: object));
  }
  factory MoveU8.fromStruct(Map<String, dynamic> json) {
    return MoveU8(json.as("value"));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u8(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU8) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `u16` argument type (16-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU16 extends MoveType<int> {
  MoveU16(int value) : super(MoveUtils.parseU16(value: value));

  /// Parses an object to MoveU16, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  factory MoveU16.fromStruct(Map<String, dynamic> json) {
    return MoveU16(json.as("value"));
  }
  factory MoveU16.parse(Object? object) {
    if (object is MoveU16) return object;
    return MoveU16(MoveUtils.parseU16(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u16(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU16) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `u32` argument type (32-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU32 extends MoveType<int> {
  MoveU32(int value) : super(MoveUtils.parseU32(value: value));
  factory MoveU32.fromStruct(Map<String, dynamic> json) {
    return MoveU32(json.as("value"));
  }

  /// Parses an object to MoveU32, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  /// this class provides encoding for integers to little-endian byte format.
  factory MoveU32.parse(Object? object) {
    if (object is MoveU32) return object;
    return MoveU32(MoveUtils.parseU32(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u32(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU32) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `u64` argument type (64-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU64 extends MoveType<BigInt> {
  MoveU64(BigInt value) : super(MoveUtils.parseU64(value: value));
  factory MoveU64.fromStruct(Map<String, dynamic> json) {
    return MoveU64(json.as("value"));
  }

  /// Parses an object to MoveU64, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  factory MoveU64.parse(Object? object) {
    if (object is MoveU64) return object;
    return MoveU64(MoveUtils.parseU64(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u64(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU64) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `u128` argument type (128-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU128 extends MoveType<BigInt> {
  MoveU128(BigInt value) : super(MoveUtils.parseU128(value: value));
  factory MoveU128.fromStruct(Map<String, dynamic> json) {
    return MoveU128(json.as("value"));
  }

  /// Parses an object to MoveU128, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  /// this class provides encoding for integers to little-endian byte format.
  factory MoveU128.parse(Object? object) {
    if (object is MoveU128) return object;
    return MoveU128(MoveUtils.parseU128(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u128(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU128) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `u256` argument type (256-bit unsigned integer).
/// this class provides encoding for integers to little-endian byte format.
class MoveU256 extends MoveType<BigInt> {
  MoveU256(BigInt value) : super(MoveUtils.parseU256(value: value));
  factory MoveU256.fromStruct(Map<String, dynamic> json) {
    return MoveU256(json.as("value"));
  }

  /// Parses an object to MoveU256, supporting int, BigInt, Int as String, and hexDecimal integer formats.
  factory MoveU256.parse(Object? object) {
    if (object is MoveU256) return object;
    return MoveU256(MoveUtils.parseU256(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.u256(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU256) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `bool` argument type (boolean value).
class MoveBool extends MoveType<bool> {
  MoveBool(super.value);
  factory MoveBool.fromStruct(Map<String, dynamic> json) {
    return MoveBool(json.as("value"));
  }

  /// Parses a value into a boolean, supporting bool, 0/1, and 'true'/'false' strings.
  factory MoveBool.parse(Object? object) {
    if (object is MoveBool) return object;
    return MoveBool(MoveUtils.parseBoolean(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.boolean(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveBool) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `address` argument type.
/// The bytes should be 32 bytes, and data is encoded without length.
class MoveAddress extends MoveType<List<int>> {
  MoveAddress(List<int> value) : super(MoveUtils.parseAddressBytes(value: value).asImmutableBytes);
  factory MoveAddress.fromStruct(Map<String, dynamic> json) {
    return MoveAddress(json.asBytes("value"));
  }
  factory MoveAddress.parse(Object? object) {
    if (object is MoveAddress) return object;
    return MoveAddress(MoveUtils.parseAddressBytes(value: object));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.fixedBlob32(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveAddress) return false;
    return BytesUtils.bytesEqual(value, other.value);
  }

  @override
  int get hashCode => HashCodeGenerator.generateBytesHashCode(value);
}

/// Represents a Move `u8Vector` argument type (a vector of u8 values).
/// The data is encoded in BCS format, with the length encoded as LEB128.
class MoveU8Vector extends MoveType<List<int>> {
  MoveU8Vector(List<int> value) : super(value.asImmutableBytes);
  factory MoveU8Vector.parse(Object? object) {
    return MoveU8Vector(MoveUtils.parseBytes(value: object));
  }
  factory MoveU8Vector.fromStruct(Map<String, dynamic> json) {
    return MoveU8Vector(json.asBytes("value"));
  }
  factory MoveU8Vector.fromHex(String hexBytes) {
    return MoveU8Vector(BytesUtils.fromHexString(hexBytes));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.bcsBytes(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveU8Vector) return false;
    return BytesUtils.bytesEqual(value, other.value);
  }

  @override
  int get hashCode => HashCodeGenerator.generateBytesHashCode(value);
}

/// Represents a Move `serialized` argument type.
/// This is used for Move transaction script arguments, similar to `MoveU8Vector`,
class MoveSerialized extends MoveType<List<int>> {
  MoveSerialized(List<int> value) : super(value.asImmutableBytes);
  factory MoveSerialized.fromHex(String hexBytes) {
    return MoveSerialized(BytesUtils.fromHexString(hexBytes));
  }

  factory MoveSerialized.parse(Object? object) {
    return MoveSerialized(MoveUtils.parseBytes(value: object));
  }

  factory MoveSerialized.fromStruct(Map<String, dynamic> json) {
    return MoveSerialized(json.asBytes("value"));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.bcsBytes(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveSerialized) return false;
    return BytesUtils.bytesEqual(value, other.value);
  }

  @override
  int get hashCode => HashCodeGenerator.generateBytesHashCode(value);
}

/// Represents a Move `string` argument type (a UTF-8 encoded string).
/// The data is encoded to UTF-8, and then the bytes are encoded as BCS with the length encoded as LEB128.
class MoveString extends MoveType<String> {
  const MoveString(super.value);
  factory MoveString.parse(Object? value) {
    if (value is MoveString) return value;
    return MoveString(MoveUtils.parseString(value: value));
  }
  static Layout<Map<String, dynamic>> layout({String? property}) {
    return LayoutConst.struct([LayoutConst.bcsString(property: "value")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(property: property);
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveString) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a Move `Option` argument type (optional type).
class MoveOption<CODEC extends MoveType>
    extends MoveType<CODEC?> {
  const MoveOption(super.value);

  static Layout<Map<String, dynamic>> layout(MoveType? codec,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(codec?.createLayout() ?? LayoutConst.noArgs(),
          property: "value")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(value, property: property);
  }

  @override
  Map<String, dynamic> toLayoutStruct() {
    return {"value": value?.toLayoutStruct()};
  }

  @override
  String toString() {
    return "Option<$CODEC>";
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveOption) return false;
    return value == other.value;
  }

  @override
  int get hashCode =>
      HashCodeGenerator.generateHashCode([value, value != null]);
}

/// Represents a Move `vector` argument type (a list of MoveType values).
/// The length of the vector is encoded as LEB128.
class MoveVector<MOVE extends MoveType>
    extends MoveType<List<MOVE>> {
  const MoveVector._(super.value);
  factory MoveVector(List<MOVE> value) {
    if (value.isNotEmpty) {
      final firstType = value.first.runtimeType;
      final hasDifferentType =
          value.any((item) => item.runtimeType != firstType);
      if (hasDifferentType) {
        throw BcsSerializationException(
          "Type mismatch: All elements must be of the same type. Found both $firstType and other differing types.",
        );
      }
    }
    return MoveVector._(value);
  }

  /// Creates a `MoveVector` of `MoveU8` from a parsed byte array.
  static MoveVector<MoveU8> u8(Object? value) {
    return MoveVector<MoveU8>(MoveUtils.parseBytes(value: value)
        .map((e) => MoveU8.parse(e))
        .toList());
  }

  /// Creates a `MoveVector` of `MoveU16` from a list of objects.
  static MoveVector<MoveU16> u16(List<Object> value) {
    return MoveVector<MoveU16>(value.map((e) => MoveU16.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveU32` from a list of objects.
  static MoveVector<MoveU32> u32(List<Object> value) {
    return MoveVector<MoveU32>(value.map((e) => MoveU32.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveU64` from a list of objects.
  static MoveVector<MoveU64> u64(List<Object> value) {
    return MoveVector<MoveU64>(value.map((e) => MoveU64.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveU128` from a list of objects.
  static MoveVector<MoveU128> u128(List<Object> value) {
    return MoveVector<MoveU128>(value.map((e) => MoveU128.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveU256` from a list of objects.
  static MoveVector<MoveU256> u256(List<Object> value) {
    return MoveVector<MoveU256>(value.map((e) => MoveU256.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveString` from a list of objects.
  static MoveVector<MoveString> string(List<Object> value) {
    return MoveVector<MoveString>(
        value.map((e) => MoveString.parse(e)).toList());
  }

  /// Creates a `MoveVector` of `MoveBool` from a list of objects.
  static MoveVector<MoveBool> boolean(List<Object> value) {
    return MoveVector<MoveBool>(value.map((e) => MoveBool.parse(e)).toList());
  }

  static Layout<Map<String, dynamic>> layout(MoveType? codec,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.bcsVector(codec?.createLayout() ?? LayoutConst.noArgs(),
          property: "value"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createLayout({String? property}) {
    return layout(value.isEmpty ? null : value.first, property: property);
  }

  @override
  Map<String, dynamic> toLayoutStruct() {
    return {"value": value.map((e) => e.toLayoutStruct()).toList()};
  }

  @override
  String toString() {
    return "Vector<$MOVE>";
  }

  @override
  operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! MoveVector) return false;
    return CompareUtils.iterableIsEqual(value, other.value);
  }

  @override
  int get hashCode => HashCodeGenerator.generateHashCode(value);
}