# Filecoin Support for On-Chain Library

This implementation provides Filecoin support for the on_chain Dart library, based on the TrustWallet Filecoin implementation patterns.

## Features

### ✅ Implemented
- **Address Creation and Validation**
  - SECP256K1 addresses (f1...)
  - Delegated addresses (f4...) - Ethereum-compatible
  - ID addresses (f0...)
  - Address string validation and parsing

- **Transaction Building**
  - Simple transfers
  - Gas fee management (gasFeeCap, gasPremium)
  - Transaction serialization to JSON

- **Cryptographic Signing**
  - SECP256K1 signature scheme
  - Blake2b message hashing
  - Transaction signing with private keys

- **Address Types**
  - Full support for all Filecoin address types
  - Address conversion between types
  - Custom Base32 encoding/decoding for Filecoin alphabet

### 🚧 Future Improvements
- CBOR message encoding (currently using simplified serialization)
- Complete signature verification with public key recovery
- BLS signature support
- Smart contract interaction methods
- RPC client integration

## Usage Examples

```dart
import 'package:on_chain/on_chain.dart';

// Create addresses from private key
final privateKey = List.generate(32, (i) => i + 1);

// Create SECP256K1 address
final secp256k1Address = FilecoinSigner.createSecp256k1Address(privateKey);
print('SECP256K1 Address: ${secp256k1Address.toAddress()}'); // f1...

// Create delegated address (Ethereum-compatible)
final delegatedAddress = FilecoinSigner.createDelegatedAddress(privateKey);
print('Delegated Address: ${delegatedAddress.toAddress()}'); // f4...

// Create a transaction
final transaction = FilecoinTransaction.transfer(
  from: secp256k1Address,
  to: delegatedAddress,
  nonce: 0,
  value: BigInt.from(1000000000000000000), // 1 FIL in attoFIL
  gasLimit: 1000000,
  gasFeeCap: BigInt.from(2000),
  gasPremium: BigInt.from(1000),
);

// Sign the transaction
final signedTransaction = FilecoinSigner.signTransaction(
  transaction: transaction,
  privateKey: privateKey,
);

// Get JSON representation for RPC calls
final json = signedTransaction.toJson();
print('Signed Transaction: ${json}');

// Address validation
final isValid = FilecoinAddress.isValidAddress('f1...');
```

## Architecture

The implementation follows the same patterns as other blockchain integrations in the on_chain library:

- `FilecoinAddress`: Address creation, validation, and conversion
- `FilecoinTransaction`: Transaction building and serialization
- `FilecoinSigner`: Cryptographic operations and signing
- `FilecoinMethod`: Transaction method types (Send, InvokeEVM)
- `FilecoinSignature`: Signature representation and JSON serialization

## Compatibility

This implementation is compatible with:
- Filecoin mainnet addressing schemes
- Ethereum-compatible delegated addresses
- Standard SECP256K1 cryptographic operations
- JSON-RPC transaction format

The implementation uses the same `blockchain_utils` cryptographic primitives as other chains in the library, ensuring consistency and security.