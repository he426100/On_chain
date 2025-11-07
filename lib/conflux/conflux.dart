// Conflux network support library for Dart/Flutter.
//
// This library provides comprehensive support for both Conflux Core Space
// and Conflux eSpace (EVM-compatible) networks.
//
// Quick Start:
//
// ```dart
// import 'package:on_chain/conflux/conflux.dart';
//
// // Create a Core Space address
// final address = CFXAddress('cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p');
//
// // Create RPC provider
// final provider = ConfluxProvider(HTTPService('https://main.confluxrpc.com'));
//
// // Query balance
// final balance = await provider.request(
//   CFXGetBalance(address: address.toBase32()),
// );
//
// // Build and sign transaction
// final privateKey = CFXPrivateKey('0x...');
// final txBuilder = CFXTransactionBuilder.transfer(
//   from: fromAddr,
//   to: toAddr,
//   value: BigInt.from(1000000000000000000), // 1 CFX
//   chainId: BigInt.from(1029),
// );
//
// txBuilder.setNonce(BigInt.zero);
// txBuilder.setGasPrice(BigInt.from(1000000000));
// txBuilder.setGas(BigInt.from(21000));
// txBuilder.setStorageLimit(BigInt.zero);
// txBuilder.setEpochHeight(BigInt.from(12345678));
//
// final signedTx = txBuilder.sign(privateKey);
// ```

// Export Core Space address utilities
export 'src/address/cfx_address.dart';

/// Export eSpace address utilities
export 'src/address/espace_address.dart';

/// Export key management
export 'src/keys/keys.dart';

/// Export transaction handling
export 'src/transaction/transaction.dart';

/// Export RLP encoding/decoding (reuses Ethereum RLP)
export 'src/rlp/rlp.dart';

/// Export models (hide AccessList to avoid conflict with Ethereum's AccessList)
export 'src/models/models.dart' hide AccessList, AccessListEntry;

/// Export RPC
export 'src/rpc/rpc.dart';

/// Export exceptions
export 'src/exception/exception.dart';

// Export CIP-23 structured data signing
export 'src/cip23/cip23.dart';

// Export utilities
export 'src/utils/cfx_unit.dart';
export 'src/utils/cfx_keystore.dart';

