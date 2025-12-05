import 'package:on_chain/ethereum/src/exception/exception.dart';
import 'package:on_chain/solidity/address/core.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

extension ToEthereumAddress on SolidityAddress {
  ETHAddress toEthereumAddress() {
    if (this is ETHAddress) return this as ETHAddress;
    return ETHAddress(toHex());
  }
}

/// Class representing an Ethereum address, implementing the [SolidityAddress] interface.
class ETHAddress extends SolidityAddress {
  final String address;

  /// Private constructor for creating an instance of [ETHAddress] with a given Ethereum address
  const ETHAddress._(this.address) : super.unsafe(address);

  /// Creates an [ETHAddress] instance from a public key represented as a bytes.
  factory ETHAddress.fromPublicKey(List<int> keyBytes) {
    try {
      final toAddress = EthAddrEncoder().encodeKey(keyBytes);
      return ETHAddress._(toAddress);
    } catch (e) {
      throw ETHPluginException('invalid ethreum public key',
          details: {'input': BytesUtils.toHexString(keyBytes)});
    }
  }

  /// Creates an [ETHAddress] instance by recovering from a signature and message.
  ///
  /// This implements the `personal_ecRecover` functionality as specified in Trust Wallet.
  /// Reference: trust-web3-provider/packages/ethereum/MobileAdapter.ts:191-199
  ///
  /// Parameters:
  /// - [signature]: The signature bytes (65 bytes with recovery id)
  /// - [message]: The original message bytes (before personal sign prefix)
  /// - [payloadLength]: Optional payload length for the personal sign prefix
  ///
  /// Returns an [ETHAddress] recovered from the signature, or throws if recovery fails.
  factory ETHAddress.fromSignature(List<int> signature, List<int> message,
      {int? payloadLength}) {
    try {
      // Use ETHVerifier.getPublicKey to recover the public key from signature
      // This handles the personal sign message format internally:
      // "\x19Ethereum Signed Message:\n" + len(message) + message
      final publicKey = ETHVerifier.getPublicKey(message, signature,
          payloadLength: payloadLength);

      if (publicKey == null) {
        throw ETHPluginException(
            'Failed to recover public key from signature',
            details: {
              'signatureLength': signature.length,
              'messageLength': message.length
            });
      }

      // Convert public key to Ethereum address
      return ETHAddress.fromPublicKey(publicKey.toBytes());
    } catch (e) {
      throw ETHPluginException('Failed to recover address from signature',
          details: {
            'error': e.toString(),
            'signature': BytesUtils.toHexString(signature),
            'message': BytesUtils.toHexString(message)
          });
    }
  }

  /// Creates an [ETHAddress] instance from an Ethereum address string.
  ///
  /// Optionally, [skipChecksum] can be set to true to skip the address checksum validation.
  factory ETHAddress(String address, {bool skipChecksum = true}) {
    try {
      EthAddrDecoder().decodeAddr(address, {'skip_chksum_enc': skipChecksum});
      return ETHAddress._(EthAddrUtils.toChecksumAddress(address));
    } catch (e) {
      throw ETHPluginException('invalid ethereum address',
          details: {'input': address});
    }
  }

  /// Creates an [ETHAddress] instance from a bytes representing the address.
  factory ETHAddress.fromBytes(List<int> addrBytes) {
    return ETHAddress(BytesUtils.toHexString(addrBytes, prefix: '0x'));
  }

  /// Constant representing the length of the ETH address in bytes
  static const int lengthInBytes = 20;

  @override
  String toString() {
    return address;
  }

  @override
  bool operator ==(other) {
    if (other is! ETHAddress) return false;
    return address == other.address;
  }

  @override
  int get hashCode => address.hashCode;
}
