/// Represents a value in Drip (the smallest unit of CFX).
/// 
/// Conflux uses Drip as its base unit:
/// - 1 CFX = 10^18 Drip
/// - 1 GDrip = 10^9 Drip
/// 
/// This class provides conversion methods similar to js-conflux-sdk's Drip class.
class CFXUnit {
  /// The value in Drip (smallest unit).
  final BigInt drip;

  /// Creates a CFXUnit from a Drip value.
  /// 
  /// Throws [ArgumentError] if the value is negative or has decimals.
  CFXUnit(dynamic value) : drip = _parseDrip(value);

  const CFXUnit._(this.drip);

  /// Creates a CFXUnit from CFX value.
  /// 
  /// Example:
  /// ```dart
  /// final amount = CFXUnit.fromCFX(3.14); // 3.14 CFX = 3140000000000000000 Drip
  /// ```
  factory CFXUnit.fromCFX(dynamic cfx) {
    final BigInt dripValue = _convertFromCFX(cfx);
    return CFXUnit._(dripValue);
  }

  /// Creates a CFXUnit from GDrip value.
  /// 
  /// Example:
  /// ```dart
  /// final amount = CFXUnit.fromGDrip(3.14); // 3.14 GDrip = 3140000000 Drip
  /// ```
  factory CFXUnit.fromGDrip(dynamic gdrip) {
    final BigInt dripValue = _convertFromGDrip(gdrip);
    return CFXUnit._(dripValue);
  }

  /// Converts CFX to Drip.
  static BigInt _convertFromCFX(dynamic cfx) {
    if (cfx == null) {
      throw ArgumentError('Invalid number: null');
    }

    if (cfx is String) {
      if (cfx.isEmpty) {
        throw ArgumentError('Invalid number: empty string');
      }
      
      // Handle hex strings
      if (cfx.startsWith('0x') || cfx.startsWith('0X')) {
        final hexValue = BigInt.parse(cfx.substring(2), radix: 16);
        return hexValue * BigInt.from(10).pow(18);
      }
      
      // Handle scientific notation
      if (cfx.contains('e') || cfx.contains('E')) {
        final num value = num.parse(cfx);
        return _multiplyByPowerOf10(value, 18);
      }
      
      // Handle decimal strings
      return _parseDecimalToDrip(cfx, 18);
    }

    if (cfx is num) {
      if (cfx < 0) {
        throw ArgumentError('not match "bigUInt"');
      }
      if (!cfx.isFinite) {
        throw ArgumentError('Invalid number: $cfx');
      }
      return _multiplyByPowerOf10(cfx, 18);
    }

    throw ArgumentError('Invalid number type');
  }

  /// Converts GDrip to Drip.
  static BigInt _convertFromGDrip(dynamic gdrip) {
    if (gdrip == null) {
      throw ArgumentError('Invalid number: null');
    }

    if (gdrip is String) {
      if (gdrip.isEmpty) {
        throw ArgumentError('Invalid number: empty string');
      }
      
      // Handle hex strings
      if (gdrip.startsWith('0x') || gdrip.startsWith('0X')) {
        final hexValue = BigInt.parse(gdrip.substring(2), radix: 16);
        return hexValue * BigInt.from(10).pow(9);
      }
      
      // Handle scientific notation
      if (gdrip.contains('e') || gdrip.contains('E')) {
        final num value = num.parse(gdrip);
        return _multiplyByPowerOf10(value, 9);
      }
      
      // Handle decimal strings
      return _parseDecimalToDrip(gdrip, 9);
    }

    if (gdrip is num) {
      if (gdrip < 0) {
        throw ArgumentError('not match "bigUInt"');
      }
      if (!gdrip.isFinite) {
        throw ArgumentError('Invalid number: $gdrip');
      }
      return _multiplyByPowerOf10(gdrip, 9);
    }

    throw ArgumentError('Invalid number type');
  }

  /// Parses a Drip value (must be integer).
  static BigInt _parseDrip(dynamic value) {
    if (value == null) {
      throw ArgumentError('Cannot convert null to Drip');
    }

    if (value is String) {
      if (value.isEmpty) {
        return BigInt.zero;
      }
      
      // Handle hex strings
      if (value.startsWith('0x') || value.startsWith('0X')) {
        return BigInt.parse(value.substring(2), radix: 16);
      }
      
      // Check for decimal point
      if (value.contains('.')) {
        // Only accept .0 or .00 etc
        final double parsed = double.parse(value);
        if (parsed != parsed.truncateToDouble()) {
          throw ArgumentError('Cannot convert decimal to Drip');
        }
        return BigInt.from(parsed);
      }
      
      return BigInt.parse(value);
    }

    if (value is int) {
      if (value < 0) {
        throw ArgumentError('not match "bigUInt"');
      }
      return BigInt.from(value);
    }

    if (value is double) {
      if (value < 0) {
        throw ArgumentError('not match "bigUInt"');
      }
      if (value != value.truncateToDouble()) {
        throw ArgumentError('Cannot convert decimal to Drip');
      }
      return BigInt.from(value);
    }

    if (value is BigInt) {
      if (value < BigInt.zero) {
        throw ArgumentError('not match "bigUInt"');
      }
      return value;
    }

    throw ArgumentError('Cannot convert ${value.runtimeType} to Drip');
  }

  /// Multiplies a number by 10^power and returns a BigInt.
  static BigInt _multiplyByPowerOf10(num value, int power) {
    if (value < 0) {
      throw ArgumentError('not match "bigUInt"');
    }

    // Convert to string to handle precision correctly
    final String valueStr = value.toString();
    
    if (valueStr.contains('e') || valueStr.contains('E')) {
      // Handle scientific notation
      final parts = valueStr.toLowerCase().split('e');
      final mantissa = parts[0];
      final exponent = int.parse(parts[1]);
      
      return _parseDecimalToDrip(mantissa, power + exponent);
    }
    
    return _parseDecimalToDrip(valueStr, power);
  }

  /// Parses a decimal string and multiplies by 10^power.
  static BigInt _parseDecimalToDrip(String value, int power) {
    if (value.contains('.')) {
      final parts = value.split('.');
      final intPart = parts[0];
      final fracPart = parts[1];
      
      // Check if we have too many decimal places
      if (fracPart.length > power) {
        throw ArgumentError('Cannot convert $value: too many decimal places');
      }
      
      // Pad the fractional part to the required length
      final paddedFrac = fracPart.padRight(power, '0');
      final combined = intPart + paddedFrac;
      
      return BigInt.parse(combined);
    } else {
      // No decimal point, just multiply by 10^power
      return BigInt.parse(value) * BigInt.from(10).pow(power);
    }
  }

  /// Converts the Drip value to CFX as a string.
  /// 
  /// Example:
  /// ```dart
  /// final unit = CFXUnit.fromGDrip(3.14);
  /// print(unit.toCFX()); // "0.00000000314"
  /// ```
  String toCFX() {
    return _formatFromDrip(drip, 18);
  }

  /// Converts the Drip value to GDrip as a string.
  /// 
  /// Example:
  /// ```dart
  /// final unit = CFXUnit.fromGDrip(3.14);
  /// print(unit.toGDrip()); // "3.14"
  /// ```
  String toGDrip() {
    return _formatFromDrip(drip, 9);
  }

  /// Formats a Drip value by dividing by 10^power.
  static String _formatFromDrip(BigInt drip, int power) {
    final String dripStr = drip.toString();
    
    String result;
    if (dripStr.length <= power) {
      // Add leading zeros
      final paddedStr = dripStr.padLeft(power + 1, '0');
      final intPart = paddedStr.substring(0, paddedStr.length - power);
      final fracPart = paddedStr.substring(paddedStr.length - power);
      result = '$intPart.$fracPart';
    } else {
      // Split naturally
      final intPart = dripStr.substring(0, dripStr.length - power);
      final fracPart = dripStr.substring(dripStr.length - power);
      result = '$intPart.$fracPart';
    }
    
    // Remove trailing zeros
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      // If all decimals were removed, also remove the decimal point
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }
    
    return result;
  }

  /// Returns the Drip value as a string.
  @override
  String toString() {
    return drip.toString();
  }

  /// Returns the Drip value as a hex string.
  String toHex() {
    return '0x${drip.toRadixString(16)}';
  }

  /// JSON serialization returns the Drip value as a string.
  String toJson() {
    return drip.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CFXUnit && other.drip == drip;
  }

  @override
  int get hashCode => drip.hashCode;
}

