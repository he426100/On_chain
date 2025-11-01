/// Represents an epoch number or tag in Conflux Core Space.
/// 
/// Conflux uses epochs instead of block numbers in Core Space.
/// Epochs can be numeric or use special tags.
class EpochNumber {
  const EpochNumber._(this._value);

  final dynamic _value;

  /// Creates an [EpochNumber] from a numeric epoch.
  const EpochNumber.epoch(int epoch) : _value = epoch;

  /// The latest mined epoch.
  static const EpochNumber latestMined = EpochNumber._('latest_mined');

  /// The latest state (default for most operations).
  static const EpochNumber latestState = EpochNumber._('latest_state');

  /// The latest confirmed epoch.
  static const EpochNumber latestConfirmed = EpochNumber._('latest_confirmed');

  /// The latest checkpoint epoch.
  static const EpochNumber latestCheckpoint = EpochNumber._('latest_checkpoint');

  /// The latest finalized epoch.
  static const EpochNumber latestFinalized = EpochNumber._('latest_finalized');

  /// The earliest epoch (genesis).
  static const EpochNumber earliest = EpochNumber._('earliest');

  /// Parses an [EpochNumber] from a string or int.
  factory EpochNumber.parse(dynamic value) {
    if (value is int) return EpochNumber.epoch(value);
    if (value is String) {
      switch (value) {
        case 'latest_mined':
          return latestMined;
        case 'latest_state':
          return latestState;
        case 'latest_confirmed':
          return latestConfirmed;
        case 'latest_checkpoint':
          return latestCheckpoint;
        case 'latest_finalized':
          return latestFinalized;
        case 'earliest':
          return earliest;
        default:
          if (value.startsWith('0x')) {
            return EpochNumber.epoch(int.parse(value, radix: 16));
          }
          return EpochNumber.epoch(int.parse(value));
      }
    }
    throw ArgumentError('Invalid epoch number: $value');
  }

  /// Checks if this is a numeric epoch.
  bool get isNumeric => _value is int;

  /// Returns the numeric epoch value.
  /// Throws if this is not a numeric epoch.
  int get epoch {
    if (_value is int) return _value;
    throw StateError('Not a numeric epoch: $_value');
  }

  /// Returns the epoch as a hex string (for numeric epochs) or tag string.
  @override
  String toString() {
    if (_value is int) {
      return '0x${_value.toRadixString(16)}';
    }
    return _value;
  }

  /// Converts to JSON representation.
  dynamic toJson() => toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpochNumber && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

