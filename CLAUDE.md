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
dart test test/etherum/
dart test test/tron/
dart test test/solana/
dart test test/filecoin/

# Run specific test file
dart test test/etherum/transaction_test.dart
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
- Program layouts extend `ProgramLayout` base class
- Unknown programs can be handled with `UnknownProgramLayout`

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

## Dependencies

Main dependency: `blockchain_utils` package provides cryptographic primitives (ECDSA, EdDSA, hashing, BIP32/39/44) used across all blockchain implementations.
