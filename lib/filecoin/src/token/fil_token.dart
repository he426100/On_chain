import 'package:blockchain_utils/blockchain_utils.dart';

/// Filecoin token denominations
/// @see https://docs.filecoin.io/basics/assets/the-fil-token/#denomonations
class FilecoinTokenDenomination {
  static const int attoDecimals = 18;
  static const int femtoDecimals = 15;
  static const int picoDecimals = 12;
  static const int nanoDecimals = 9;
  static const int microDecimals = 6;
  static const int milliDecimals = 3;
  static const int wholeDecimals = 0;

  static final BigInt femtoMultiplier = BigInt.from(10).pow(milliDecimals);
  static final BigInt picoMultiplier = BigInt.from(10).pow(microDecimals);
  static final BigInt nanoMultiplier = BigInt.from(10).pow(nanoDecimals);
  static final BigInt microMultiplier = BigInt.from(10).pow(picoDecimals);
  static final BigInt milliMultiplier = BigInt.from(10).pow(femtoDecimals);
  static final BigInt wholeMultiplier = BigInt.from(10).pow(attoDecimals);
}

/// Filecoin Token class for working with different denominations
/// Similar to iso-filecoin's Token class
class FilecoinToken {
  /// Internal value in attoFIL (smallest unit)
  final BigInt value;

  const FilecoinToken._(this.value);

  /// Create token from attoFIL (10^-18 FIL)
  factory FilecoinToken.fromAttoFIL(BigInt value) {
    return FilecoinToken._(value);
  }

  /// Create token from attoFIL string
  factory FilecoinToken.fromAttoFILString(String value) {
    return FilecoinToken._(BigInt.parse(value));
  }

  /// Create token from femtoFIL (10^-15 FIL)
  factory FilecoinToken.fromFemtoFIL(BigInt value) {
    return FilecoinToken._(value * FilecoinTokenDenomination.femtoMultiplier);
  }

  /// Create token from picoFIL (10^-12 FIL)
  factory FilecoinToken.fromPicoFIL(BigInt value) {
    return FilecoinToken._(value * FilecoinTokenDenomination.picoMultiplier);
  }

  /// Create token from nanoFIL (10^-9 FIL)
  factory FilecoinToken.fromNanoFIL(BigInt value) {
    return FilecoinToken._(value * FilecoinTokenDenomination.nanoMultiplier);
  }

  /// Create token from microFIL (10^-6 FIL)
  factory FilecoinToken.fromMicroFIL(BigInt value) {
    return FilecoinToken._(value * FilecoinTokenDenomination.microMultiplier);
  }

  /// Create token from milliFIL (10^-3 FIL)
  factory FilecoinToken.fromMilliFIL(BigInt value) {
    return FilecoinToken._(value * FilecoinTokenDenomination.milliMultiplier);
  }

  /// Create token from FIL (whole unit)
  factory FilecoinToken.fromFIL(String value) {
    // Handle decimal values
    final parts = value.split('.');
    BigInt result = BigInt.zero;

    // Handle whole part
    if (parts[0].isNotEmpty && parts[0] != '0') {
      result = BigInt.parse(parts[0]) * FilecoinTokenDenomination.wholeMultiplier;
    }

    // Handle decimal part
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final decimalPart = parts[1].padRight(FilecoinTokenDenomination.attoDecimals, '0');
      final decimalValue = BigInt.parse(
        decimalPart.substring(0, FilecoinTokenDenomination.attoDecimals.clamp(0, decimalPart.length)),
      );

      if (value.startsWith('-')) {
        result -= decimalValue;
      } else {
        result += decimalValue;
      }
    }

    return FilecoinToken._(result);
  }

  /// Convert to attoFIL
  BigInt toAttoFIL() => value;

  /// Convert to attoFIL string
  String toAttoFILString() => value.toString();

  /// Convert to femtoFIL
  BigInt toFemtoFIL() => value ~/ FilecoinTokenDenomination.femtoMultiplier;

  /// Convert to picoFIL
  BigInt toPicoFIL() => value ~/ FilecoinTokenDenomination.picoMultiplier;

  /// Convert to nanoFIL
  BigInt toNanoFIL() => value ~/ FilecoinTokenDenomination.nanoMultiplier;

  /// Convert to microFIL
  BigInt toMicroFIL() => value ~/ FilecoinTokenDenomination.microMultiplier;

  /// Convert to milliFIL
  BigInt toMilliFIL() => value ~/ FilecoinTokenDenomination.milliMultiplier;

  /// Convert to FIL with decimal representation
  String toFIL({int? decimalPlaces}) {
    final isNegative = value.isNegative;
    final absValue = value.abs();

    final wholePart = absValue ~/ FilecoinTokenDenomination.wholeMultiplier;
    final fractionalPart = absValue % FilecoinTokenDenomination.wholeMultiplier;

    if (fractionalPart == BigInt.zero) {
      return '${isNegative ? '-' : ''}$wholePart';
    }

    var fractionalStr = fractionalPart.toString().padLeft(FilecoinTokenDenomination.attoDecimals, '0');

    // Apply decimal places limit if specified
    if (decimalPlaces != null && decimalPlaces < FilecoinTokenDenomination.attoDecimals) {
      fractionalStr = fractionalStr.substring(0, decimalPlaces);
    }

    // Remove trailing zeros
    fractionalStr = fractionalStr.replaceAll(RegExp(r'0+$'), '');

    if (fractionalStr.isEmpty) {
      return '${isNegative ? '-' : ''}$wholePart';
    }

    return '${isNegative ? '-' : ''}$wholePart.$fractionalStr';
  }

  /// Format token with custom options
  String toFormat({
    int decimalPlaces = 18,
    String decimalSeparator = '.',
    String groupSeparator = ',',
    int groupSize = 3,
    String prefix = '',
    String suffix = '',
  }) {
    final isNegative = value.isNegative;
    final absValue = value.abs();

    final wholePart = absValue ~/ FilecoinTokenDenomination.wholeMultiplier;
    final fractionalPart = absValue % FilecoinTokenDenomination.wholeMultiplier;

    // Format whole part with grouping
    String wholeStr = wholePart.toString();
    if (groupSize > 0 && groupSeparator.isNotEmpty) {
      final buffer = StringBuffer();
      var count = 0;
      for (var i = wholeStr.length - 1; i >= 0; i--) {
        if (count > 0 && count % groupSize == 0) {
          buffer.write(groupSeparator);
        }
        buffer.write(wholeStr[i]);
        count++;
      }
      wholeStr = buffer.toString().split('').reversed.join();
    }

    // Format fractional part
    var fractionalStr = '';
    if (decimalPlaces > 0 && fractionalPart != BigInt.zero) {
      fractionalStr = fractionalPart
          .toString()
          .padLeft(FilecoinTokenDenomination.attoDecimals, '0')
          .substring(0, decimalPlaces.clamp(0, FilecoinTokenDenomination.attoDecimals));

      // Remove trailing zeros
      fractionalStr = fractionalStr.replaceAll(RegExp(r'0+$'), '');
    }

    final result = StringBuffer();
    result.write(prefix);
    if (isNegative) result.write('-');
    result.write(wholeStr);
    if (fractionalStr.isNotEmpty) {
      result.write(decimalSeparator);
      result.write(fractionalStr);
    }
    result.write(suffix);

    return result.toString();
  }

  /// Encode as bytes according to Filecoin specification
  /// Returns empty list for zero, otherwise [sign_byte, ...bytes] for numbers
  /// Matches iso-filecoin Token.toBytes() implementation
  List<int> toBytes() {
    if (value == BigInt.zero) {
      return [];
    }

    final isNegative = value.isNegative;
    final absValue = value.abs();

    // Sign byte: 0x00 = positive, 0x01 = negative
    final signByte = isNegative ? 0x01 : 0x00;

    // Convert BigInt to bytes (big-endian)
    var hex = absValue.toRadixString(16);
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }

    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }

    return [signByte, ...bytes];
  }

  /// Decode from bytes according to Filecoin specification
  factory FilecoinToken.fromBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return FilecoinToken._(BigInt.zero);
    }

    final isNegative = bytes[0] == 0x01;
    final valueBytes = bytes.sublist(1);

    if (valueBytes.isEmpty) {
      return FilecoinToken._(BigInt.zero);
    }

    final hex = BytesUtils.toHexString(valueBytes);
    var value = BigInt.parse(hex, radix: 16);

    if (isNegative) {
      value = -value;
    }

    return FilecoinToken._(value);
  }

  /// Arithmetic operations
  FilecoinToken operator +(FilecoinToken other) {
    return FilecoinToken._(value + other.value);
  }

  FilecoinToken operator -(FilecoinToken other) {
    return FilecoinToken._(value - other.value);
  }

  FilecoinToken operator *(BigInt multiplier) {
    return FilecoinToken._(value * multiplier);
  }

  FilecoinToken operator ~/(BigInt divisor) {
    return FilecoinToken._(value ~/ divisor);
  }

  /// Absolute value
  FilecoinToken abs() {
    return FilecoinToken._(value.abs());
  }

  /// Comparison operators
  bool operator >(FilecoinToken other) => value > other.value;
  bool operator <(FilecoinToken other) => value < other.value;
  bool operator >=(FilecoinToken other) => value >= other.value;
  bool operator <=(FilecoinToken other) => value <= other.value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilecoinToken && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => toAttoFILString();
}
