import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/keys/private_key.dart';
import 'package:on_chain/conflux/src/transaction/cfx_transaction.dart';

/// Builder for constructing Conflux Core Space transactions.
/// 
/// Example:
/// ```dart
/// final builder = CFXTransactionBuilder(
///   from: fromAddress,
///   to: toAddress,
///   value: BigInt.from(1000000000000000000), // 1 CFX
///   chainId: BigInt.from(1029),
/// );
/// 
/// builder.setNonce(BigInt.zero);
/// builder.setGasPrice(BigInt.from(1000000000)); // 1 GDrip
/// builder.setGas(BigInt.from(21000));
/// builder.setStorageLimit(BigInt.zero);
/// builder.setEpochHeight(BigInt.from(12345678));
/// 
/// final signedTx = builder.sign(privateKey);
/// ```
class CFXTransactionBuilder {
  CFXTransactionBuilder({
    required this.from,
    this.to,
    this.value,
    this.data,
    required this.chainId,
    BigInt? nonce,
    BigInt? gasPrice,
    BigInt? gas,
    BigInt? storageLimit,
    BigInt? epochHeight,
  })  : _nonce = nonce,
        _gasPrice = gasPrice,
        _gas = gas,
        _storageLimit = storageLimit,
        _epochHeight = epochHeight;

  /// The sender address.
  final CFXAddress from;

  /// The recipient address (null for contract creation).
  final CFXAddress? to;

  /// The value to transfer in Drip.
  final BigInt? value;

  /// The transaction data/input.
  final List<int>? data;

  /// The chain ID.
  final BigInt chainId;

  BigInt? _nonce;
  BigInt? _gasPrice;
  BigInt? _gas;
  BigInt? _storageLimit;
  BigInt? _epochHeight;

  /// Sets the nonce.
  void setNonce(BigInt nonce) {
    _nonce = nonce;
  }

  /// Sets the gas price in Drip.
  void setGasPrice(BigInt gasPrice) {
    _gasPrice = gasPrice;
  }

  /// Sets the gas limit.
  void setGas(BigInt gas) {
    _gas = gas;
  }

  /// Sets the storage limit in bytes.
  void setStorageLimit(BigInt storageLimit) {
    _storageLimit = storageLimit;
  }

  /// Sets the epoch height.
  void setEpochHeight(BigInt epochHeight) {
    _epochHeight = epochHeight;
  }

  /// Builds the transaction.
  /// 
  /// Throws [InvalidConfluxTransactionException] if required fields are missing.
  CFXTransaction build() {
    if (_nonce == null) {
      throw InvalidConfluxTransactionException('Nonce is required');
    }
    if (_gasPrice == null) {
      throw InvalidConfluxTransactionException('Gas price is required');
    }
    if (_gas == null) {
      throw InvalidConfluxTransactionException('Gas limit is required');
    }
    if (_storageLimit == null) {
      throw InvalidConfluxTransactionException('Storage limit is required');
    }
    if (_epochHeight == null) {
      throw InvalidConfluxTransactionException('Epoch height is required');
    }

    return CFXTransaction(
      nonce: _nonce!,
      gasPrice: _gasPrice!,
      gas: _gas!,
      to: to,
      value: value ?? BigInt.zero,
      storageLimit: _storageLimit!,
      epochHeight: _epochHeight!,
      chainId: chainId,
      data: data ?? [],
    );
  }

  /// Signs the transaction with the given private key and returns the signed transaction.
  CFXTransaction sign(CFXPrivateKey privateKey) {
    final unsignedTx = build();

    // Encode for signing
    final encoded = unsignedTx.encodeForSigning();
    final hash = QuickCrypto.keccack256Hash(encoded);

    // Sign
    final signature = privateKey.sign(hash, hashMessage: false);

    // Create signed transaction with signature bytes
    final rBytes = BigintUtils.toBytes(signature.r, length: 32);
    final sBytes = BigintUtils.toBytes(signature.s, length: 32);
    
    return unsignedTx.copyWith(
      v: signature.v,
      r: rBytes,
      s: sBytes,
    );
  }

  /// Creates a builder for a simple CFX transfer.
  factory CFXTransactionBuilder.transfer({
    required CFXAddress from,
    required CFXAddress to,
    required BigInt value,
    required BigInt chainId,
  }) {
    return CFXTransactionBuilder(
      from: from,
      to: to,
      value: value,
      chainId: chainId,
    );
  }

  /// Creates a builder for a contract call.
  factory CFXTransactionBuilder.contractCall({
    required CFXAddress from,
    required CFXAddress contract,
    required List<int> data,
    required BigInt chainId,
    BigInt? value,
  }) {
    return CFXTransactionBuilder(
      from: from,
      to: contract,
      value: value,
      data: data,
      chainId: chainId,
    );
  }

  /// Creates a builder for contract deployment.
  factory CFXTransactionBuilder.deploy({
    required CFXAddress from,
    required List<int> bytecode,
    required BigInt chainId,
    BigInt? value,
  }) {
    return CFXTransactionBuilder(
      from: from,
      to: null, // null for deployment
      value: value,
      data: bytecode,
      chainId: chainId,
    );
  }
}

