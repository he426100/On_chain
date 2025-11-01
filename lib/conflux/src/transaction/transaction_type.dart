/// Transaction types for Conflux Core Space transactions.
/// 
/// Conflux supports three types of transactions:
/// - Legacy: Original transaction format
/// - EIP-2930: Adds access lists for gas optimization
/// - EIP-1559: Adds dynamic fee pricing with max fee and priority fee
class CFXTransactionType {
  const CFXTransactionType._(this.name, this.value);

  /// The name of the transaction type.
  final String name;

  /// The numeric value of the transaction type.
  final int value;

  /// Legacy transaction type (type 0).
  /// 
  /// Uses gasPrice for fee calculation.
  /// RLP encoding: [[tx_fields], v, r, s]
  static const CFXTransactionType legacy = CFXTransactionType._('Legacy', 0);

  /// EIP-2930 transaction type (type 1).
  /// 
  /// Adds accessList field for gas optimization.
  /// RLP encoding: "cfx\x01" + [[tx_fields, accessList], v, r, s]
  static const CFXTransactionType eip2930 =
      CFXTransactionType._('EIP-2930', 1);

  /// EIP-1559 transaction type (type 2).
  /// 
  /// Uses maxFeePerGas and maxPriorityFeePerGas for dynamic fee pricing.
  /// Also includes accessList field.
  /// RLP encoding: "cfx\x02" + [[tx_fields, accessList], v, r, s]
  static const CFXTransactionType eip1559 =
      CFXTransactionType._('EIP-1559', 2);

  @override
  String toString() => name;

  /// A list of all supported transaction types.
  static const List<CFXTransactionType> values = [legacy, eip2930, eip1559];

  /// Returns the [CFXTransactionType] corresponding to the given value.
  static CFXTransactionType fromValue(int value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => throw ArgumentError('Invalid transaction type: $value'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CFXTransactionType && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

