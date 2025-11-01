import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';

/// Represents a Conflux eSpace address (EVM-compatible).
/// 
/// eSpace uses the same address format as Ethereum (0x-prefixed hex).
/// This class is a wrapper around [ETHAddress] with additional Conflux-specific functionality.
class ESpaceAddress {
  ESpaceAddress._(this._ethAddress);

  /// Creates an eSpace address from a hex string.
  /// 
  /// The address should be a valid Ethereum address (0x-prefixed, 42 characters).
  /// 
  /// Example:
  /// ```dart
  /// final address = ESpaceAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb');
  /// ```
  factory ESpaceAddress(String hexAddress) {
    return ESpaceAddress._(ETHAddress(hexAddress));
  }

  final ETHAddress _ethAddress;

  /// Returns the address as a hex string (0x-prefixed).
  String toHex() => _ethAddress.toHex();

  /// Converts the eSpace address to a Core Space address.
  /// 
  /// The underlying hex address remains the same, but the format changes to Base32.
  /// 
  /// Example:
  /// ```dart
  /// final eSpace = ESpaceAddress('0x...');
  /// final coreSpace = eSpace.toCoreSpaceAddress(1029); // mainnet
  /// print(coreSpace.toBase32()); // cfx:...
  /// ```
  CFXAddress toCoreSpaceAddress(int networkId) {
    return CFXAddress.fromHex(toHex(), networkId);
  }

  @override
  String toString() => toHex();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ESpaceAddress && other._ethAddress == _ethAddress;
  }

  @override
  int get hashCode => _ethAddress.hashCode;
}
