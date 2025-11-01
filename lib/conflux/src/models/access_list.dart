import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';

/// Represents a list of access list entries for EIP-2930 and EIP-1559 transactions.
typedef AccessList = List<AccessListEntry>;

/// Represents an entry in an access list, specifying an address and its storage keys.
/// 
/// Access lists are used in EIP-2930 and EIP-1559 transactions to pre-declare
/// which accounts and storage slots will be accessed, allowing for gas optimization.
class AccessListEntry {
  /// The address to be accessed.
  final String address;

  /// The list of storage keys to be accessed at this address.
  final List<String> storageKeys;

  const AccessListEntry({
    required this.address,
    required this.storageKeys,
  });

  /// Creates an [AccessListEntry] from a JSON map.
  factory AccessListEntry.fromJson(Map<String, dynamic> json) {
    return AccessListEntry(
      address: json['address'] as String,
      storageKeys: (json['storageKeys'] as List).cast<String>(),
    );
  }

  /// Creates an [AccessListEntry] from a serialized list of dynamic objects.
  /// 
  /// Expected format: [addressBytes, [storageKey1Bytes, storageKey2Bytes, ...]]
  factory AccessListEntry.fromSerialized(List<dynamic> serialized) {
    try {
      final addr = BytesUtils.toHexString(serialized[0] as List<int>, prefix: '0x');
      final storageKeys = (serialized[1] as List)
          .map((e) => BytesUtils.toHexString(e as List<int>, prefix: '0x'))
          .toList();
      return AccessListEntry(address: addr, storageKeys: storageKeys);
    } catch (e) {
      throw ConfluxPluginException(
        'Invalid AccessListEntry serialized data',
        details: {'error': e.toString()},
      );
    }
  }

  /// Serializes the access list entry to a list for RLP encoding.
  /// 
  /// Returns: [addressBytes, [storageKey1Bytes, storageKey2Bytes, ...]]
  List<dynamic> serialize() {
    return [
      BytesUtils.fromHexString(address),
      storageKeys.map<List<int>>((e) => BytesUtils.fromHexString(e)).toList()
    ];
  }

  /// Converts the access list entry to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'storageKeys': storageKeys,
    };
  }

  @override
  String toString() {
    return 'AccessListEntry{address: $address, storageKeys: $storageKeys}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccessListEntry) return false;
    if (address != other.address) return false;
    if (storageKeys.length != other.storageKeys.length) return false;
    for (var i = 0; i < storageKeys.length; i++) {
      if (storageKeys[i] != other.storageKeys[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(address, Object.hashAll(storageKeys));
}

/// Extension methods for AccessList.
extension AccessListExtension on AccessList {
  /// Serializes the access list to a list for RLP encoding.
  List<dynamic> serialize() {
    return map((entry) => entry.serialize()).toList();
  }

  /// Converts the access list to a JSON list.
  List<Map<String, dynamic>> toJson() {
    return map((entry) => entry.toJson()).toList();
  }
}

