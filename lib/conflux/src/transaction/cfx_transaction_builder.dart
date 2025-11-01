import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/conflux/src/address/cfx_address.dart';
import 'package:on_chain/conflux/src/exception/exception.dart';
import 'package:on_chain/conflux/src/keys/private_key.dart';
import 'package:on_chain/conflux/src/models/access_list.dart';
import 'package:on_chain/conflux/src/transaction/cfx_transaction.dart';
import 'package:on_chain/conflux/src/transaction/transaction_type.dart';

/// Builder for constructing Conflux Core Space transactions.
/// 
/// Supports three transaction types:
/// - Legacy: Traditional gasPrice-based transactions
/// - EIP-2930: Adds access lists for gas optimization
/// - EIP-1559: Dynamic fee pricing with maxFeePerGas and maxPriorityFeePerGas
/// 
/// Example (Legacy):
/// ```dart
/// final builder = CFXTransactionBuilder.transfer(
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
/// 
/// Example (EIP-1559):
/// ```dart
/// final builder = CFXTransactionBuilder.eip1559Transfer(
///   from: fromAddress,
///   to: toAddress,
///   value: BigInt.from(1000000000000000000),
///   chainId: BigInt.from(1029),
///   maxFeePerGas: BigInt.from(2000000000),
///   maxPriorityFeePerGas: BigInt.from(1000000000),
/// );
/// ```
class CFXTransactionBuilder {
  CFXTransactionBuilder._({
    this.type = CFXTransactionType.legacy,
    required this.from,
    this.to,
    this.value,
    this.data,
    required this.chainId,
    BigInt? nonce,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    BigInt? gas,
    BigInt? storageLimit,
    BigInt? epochHeight,
    AccessList? accessList,
  })  : _nonce = nonce,
        _gasPrice = gasPrice,
        _maxFeePerGas = maxFeePerGas,
        _maxPriorityFeePerGas = maxPriorityFeePerGas,
        _gas = gas,
        _storageLimit = storageLimit,
        _epochHeight = epochHeight,
        _accessList = accessList;

  /// The transaction type.
  final CFXTransactionType type;

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
  BigInt? _maxFeePerGas;
  BigInt? _maxPriorityFeePerGas;
  BigInt? _gas;
  BigInt? _storageLimit;
  BigInt? _epochHeight;
  AccessList? _accessList;

  /// Sets the nonce.
  void setNonce(BigInt nonce) {
    _nonce = nonce;
  }

  /// Sets the gas price in Drip (for Legacy and EIP-2930 transactions).
  void setGasPrice(BigInt gasPrice) {
    _gasPrice = gasPrice;
  }

  /// Sets the maximum fee per gas (for EIP-1559 transactions).
  void setMaxFeePerGas(BigInt maxFeePerGas) {
    _maxFeePerGas = maxFeePerGas;
  }

  /// Sets the maximum priority fee per gas (tip) for EIP-1559 transactions.
  void setMaxPriorityFeePerGas(BigInt maxPriorityFeePerGas) {
    _maxPriorityFeePerGas = maxPriorityFeePerGas;
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

  /// Sets the access list (for EIP-2930 and EIP-1559 transactions).
  void setAccessList(AccessList accessList) {
    _accessList = accessList;
  }

  /// Adds an entry to the access list.
  void addAccessListEntry(String address, List<String> storageKeys) {
    _accessList ??= [];
    _accessList!.add(AccessListEntry(
      address: address,
      storageKeys: storageKeys,
    ));
  }

  /// Builds the transaction.
  /// 
  /// Throws [InvalidConfluxTransactionException] if required fields are missing.
  CFXTransaction build() {
    if (_nonce == null) {
      throw InvalidConfluxTransactionException('Nonce is required');
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

    // Validate based on transaction type
    if (type == CFXTransactionType.legacy) {
      if (_gasPrice == null) {
        throw InvalidConfluxTransactionException(
          'Gas price is required for legacy transactions',
        );
      }
    } else if (type == CFXTransactionType.eip2930) {
      if (_gasPrice == null) {
        throw InvalidConfluxTransactionException(
          'Gas price is required for EIP-2930 transactions',
        );
      }
    } else if (type == CFXTransactionType.eip1559) {
      if (_maxFeePerGas == null || _maxPriorityFeePerGas == null) {
        throw InvalidConfluxTransactionException(
          'Max fee per gas and max priority fee per gas are required for EIP-1559 transactions',
        );
      }
    }

    return CFXTransaction(
      type: type,
      nonce: _nonce!,
      gasPrice: _gasPrice,
      maxFeePerGas: _maxFeePerGas,
      maxPriorityFeePerGas: _maxPriorityFeePerGas,
      gas: _gas!,
      to: to,
      value: value ?? BigInt.zero,
      storageLimit: _storageLimit!,
      epochHeight: _epochHeight!,
      chainId: chainId,
      data: data ?? [],
      accessList: _accessList,
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

  /// Creates a builder for a Legacy CFX transfer.
  factory CFXTransactionBuilder.transfer({
    required CFXAddress from,
    required CFXAddress to,
    required BigInt value,
    required BigInt chainId,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.legacy,
      from: from,
      to: to,
      value: value,
      chainId: chainId,
    );
  }

  /// Creates a builder for an EIP-2930 CFX transfer with access list.
  factory CFXTransactionBuilder.eip2930Transfer({
    required CFXAddress from,
    required CFXAddress to,
    required BigInt value,
    required BigInt chainId,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip2930,
      from: from,
      to: to,
      value: value,
      chainId: chainId,
      accessList: accessList,
    );
  }

  /// Creates a builder for an EIP-1559 CFX transfer with dynamic fees.
  factory CFXTransactionBuilder.eip1559Transfer({
    required CFXAddress from,
    required CFXAddress to,
    required BigInt value,
    required BigInt chainId,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip1559,
      from: from,
      to: to,
      value: value,
      chainId: chainId,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      accessList: accessList,
    );
  }

  /// Creates a builder for a Legacy contract call.
  factory CFXTransactionBuilder.contractCall({
    required CFXAddress from,
    required CFXAddress contract,
    required List<int> data,
    required BigInt chainId,
    BigInt? value,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.legacy,
      from: from,
      to: contract,
      value: value,
      data: data,
      chainId: chainId,
    );
  }

  /// Creates a builder for an EIP-2930 contract call with access list.
  factory CFXTransactionBuilder.eip2930ContractCall({
    required CFXAddress from,
    required CFXAddress contract,
    required List<int> data,
    required BigInt chainId,
    BigInt? value,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip2930,
      from: from,
      to: contract,
      value: value,
      data: data,
      chainId: chainId,
      accessList: accessList,
    );
  }

  /// Creates a builder for an EIP-1559 contract call with dynamic fees.
  factory CFXTransactionBuilder.eip1559ContractCall({
    required CFXAddress from,
    required CFXAddress contract,
    required List<int> data,
    required BigInt chainId,
    BigInt? value,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip1559,
      from: from,
      to: contract,
      value: value,
      data: data,
      chainId: chainId,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      accessList: accessList,
    );
  }

  /// Creates a builder for Legacy contract deployment.
  factory CFXTransactionBuilder.deploy({
    required CFXAddress from,
    required List<int> bytecode,
    required BigInt chainId,
    BigInt? value,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.legacy,
      from: from,
      to: null, // null for deployment
      value: value,
      data: bytecode,
      chainId: chainId,
    );
  }

  /// Creates a builder for EIP-2930 contract deployment with access list.
  factory CFXTransactionBuilder.eip2930Deploy({
    required CFXAddress from,
    required List<int> bytecode,
    required BigInt chainId,
    BigInt? value,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip2930,
      from: from,
      to: null,
      value: value,
      data: bytecode,
      chainId: chainId,
      accessList: accessList,
    );
  }

  /// Creates a builder for EIP-1559 contract deployment with dynamic fees.
  factory CFXTransactionBuilder.eip1559Deploy({
    required CFXAddress from,
    required List<int> bytecode,
    required BigInt chainId,
    BigInt? value,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    AccessList? accessList,
  }) {
    return CFXTransactionBuilder._(
      type: CFXTransactionType.eip1559,
      from: from,
      to: null,
      value: value,
      data: bytecode,
      chainId: chainId,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      accessList: accessList,
    );
  }
}
