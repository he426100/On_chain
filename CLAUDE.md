# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

On_chain is a cross-platform Dart/Flutter package for blockchain development supporting Ethereum, Tron, Solana, and Filecoin networks. The package provides transaction creation, smart contract interaction, signing, and RPC communication capabilities.

## Development Commands

### Testing
```bash
# Run all tests
dart test

# Run tests for a specific blockchain
dart test test/ethereum/
dart test test/tron/
dart test test/solana/
dart test test/filecoin/

# Run specific test file
dart test test/ethereum/transaction_test.dart
```

### Build and Analysis
```bash
# Analyze code
dart analyze

# Format code
dart format .

# Get dependencies
dart pub get
```

## Architecture

### Directory Structure

The codebase is organized by blockchain network:

- `lib/ethereum/` - Ethereum support (Legacy, EIP1559, EIP2930, EIP712, EIP4361)
- `lib/tron/` - Tron network support with protobuf encoding
- `lib/solana/` - Solana support with BorshSerialization and native programs
- `lib/filecoin/` - Filecoin support (SECP256K1, delegated addresses)
- `lib/solidity/` - Solidity ABI encoding/decoding and contract interaction
- `lib/bcs/` - Binary Canonical Serialization for Move language support
- `lib/utils/` - Shared utilities

### Key Components Per Network

Each blockchain implementation follows a consistent pattern:

1. **Address** - Address creation, validation, and conversion
   - Ethereum: `ETHAddress` (EVM-compatible)
   - Tron: `TronAddress` (Base58Check encoding)
   - Solana: `SolAddress` (Base58 encoding)
   - Filecoin: `FilAddress` (multiple types: f0, f1, f4)

2. **Keys** - Private/public key management
   - All networks support HD wallet derivation
   - Network-specific key formats and cryptographic operations

3. **Transaction** - Transaction building, serialization, and signing
   - Ethereum: Multiple transaction types (Legacy, EIP1559, EIP2930)
   - Tron: Protobuf-based transaction serialization
   - Solana: Versioned transactions with compact encoding
   - Filecoin: CBOR-based transaction format

4. **RPC Provider** - JSON-RPC communication with blockchain nodes
   - Each network has a `Provider` class for making RPC requests
   - Request/response models in `methods/` subdirectory
   - Service layer abstracts HTTP/WebSocket communication

5. **Contract Interaction**
   - Ethereum/Tron: ABI-based contract calls
   - Solana: Instruction-based program interaction with BorshSerialization
   - Solidity ABI encoder/decoder shared across EVM chains

### Solana Programs

Solana has extensive pre-built instruction support in `lib/solana/src/instructions/`:
- System Program (transfers, account creation)
- SPL Token Program (token operations)
- Address Lookup Table Program
- Stake Program
- Metaplex programs (NFTs, auctions, candy machines)
- Custom program support via BorshSerialization

### RPC Pattern

All networks follow the same RPC pattern:
```dart
// 1. Create service (HTTP or WebSocket)
final service = HTTPService(url);

// 2. Create provider
final provider = EthereumProvider(service);  // or TronProvider, SolanaRPCClient

// 3. Make requests using typed request classes
final request = ETHGetBalance(address: address, tag: BlockTagOrNumber.latest);
final balance = await provider.request(request);
```

### Transaction Building Pattern

Ethereum uses a builder pattern for transactions:
```dart
// Transaction builder approach
final transaction = ETHTransactionBuilder.eip1559(
  // ... parameters
);
```

Tron uses contract-based transaction creation:
```dart
// Contract-based approach
final contract = TransferContract(...);
final transaction = Transaction(rawData: TransactionRaw(...));
```

Solana uses instruction composition:
```dart
// Instruction-based approach
final instruction = SystemTransfer(...);
final transaction = VersionedTransaction(...);
```

## Important Implementation Details

### Ethereum Transaction Types
- Legacy transactions use RLP encoding
- EIP1559 includes base fee and priority fee
- EIP2930 includes access lists for gas optimization
- All transaction types share signing logic but differ in serialization

### Tron Protobuf Encoding
- Tron uses Google Protobuf for transaction serialization
- Protobuf encoders/decoders are in `lib/tron/src/protbuf/`
- Multi-signature transactions require permission updates

### Solana BorshSerialization
- Solana programs use Borsh (Binary Object Representation Serializer for Hashing)
- Program layouts extend `ProgramLayout` base class in `lib/solana/src/borsh_serialization/core/program_layout.dart`
- Unknown programs can be handled with `UnknownProgramLayout`
- Custom program layouts must implement `serialize()` and `deserialize()` methods

### Filecoin Addresses
- Multiple address types: ID (f0), SECP256K1 (f1), Delegated/Ethereum-compatible (f4)
- Custom Base32 encoding with Filecoin-specific alphabet
- Address conversion utilities in `address_converter.dart`

### Contract ABI Handling
- Solidity ABI types in `lib/solidity/abi/types/`
- Support for tuples, arrays, fixed/dynamic types
- EIP712 typed data signing (v1, v3, v4)
- Fragment-based contract interaction in `lib/solidity/contract/`

## Testing Strategy

Tests are organized by network under `test/`:
- Unit tests for keys, addresses, serialization
- Transaction signing and verification tests
- ABI encoding/decoding tests
- Integration examples (not actual tests) in `example/lib/example/`

### Running Specific Tests
```bash
# Test specific blockchain module
dart test test/ethereum/
dart test test/tron/
dart test test/solana/
dart test test/filecoin/

# Test specific functionality
dart test test/ethereum/transaction_test.dart
dart test test/solana/address_test.dart
```

## Dependencies

Main dependency: `blockchain_utils` package (v5.2.0+) provides cryptographic primitives (ECDSA, EdDSA, hashing, BIP32/39/44) used across all blockchain implementations.

## Transaction Builder Pattern Details

### Ethereum Transaction Creation
The `ETHTransactionBuilder` class in `lib/ethereum/src/transaction/eth_transaction_builder.dart` provides:
- Basic transfers: `ETHTransactionBuilder(from, to, value, chainId)`
- Contract calls: `ETHTransactionBuilder.contract(contractAddress, function, functionParams)`
- Transaction type selection via `transactionType` parameter (Legacy, EIP1559, EIP2930)
- Automatic gas estimation, nonce management, and signing through builder methods

### Transaction Lifecycle
1. Build transaction using appropriate builder method
2. Set gas parameters (manually or via `estimateGas()`)
3. Set nonce (manually or via `setNonce()`)
4. Sign transaction with `signTransaction(privateKey)`
5. Send via `sendTransaction()` or get raw bytes via `transaction.serialized`

## Error Handling

Each blockchain module has its own exception types:
- Ethereum: `ETHPluginException` in `lib/ethereum/src/exception/exception.dart`
- Tron: `TronPluginException`
- Solana: `SolanaPluginException`
- Filecoin: `FilecoinPluginException`

Common error scenarios:
- Invalid address format
- Insufficient balance
- Gas estimation failures
- RPC connection errors
- Signature validation failures

## Key File Locations

When making changes, these are the critical files to understand:

### Ethereum
- Transaction types: `lib/ethereum/src/transaction/eth_transaction.dart`
- Builder: `lib/ethereum/src/transaction/eth_transaction_builder.dart`
- Provider: `lib/ethereum/src/rpc/provider/provider.dart`
- RPC methods: `lib/ethereum/src/rpc/methds/`

### Tron
- Contracts: `lib/tron/src/contract/`
- Provider: `lib/tron/src/provider/provider/provider.dart`
- Protobuf: `lib/tron/src/protbuf/`

### Solana
- Instructions: `lib/solana/src/instructions/`
- RPC client: `lib/solana/src/rpc/provider/provider.dart`
- Transaction models: `lib/solana/src/models/`

### Filecoin
- Provider: `lib/filecoin/src/provider/provider.dart`
- Methods: `lib/filecoin/src/methods/`
- Address handling: `lib/filecoin/src/address/`
