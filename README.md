# ON CHAIN Dart Package

[English](README.md) | [中文](README_CN.md)

Onchain Plugin for Dart—an advanced cross-platform solution that seamlessly integrates with Ethereum, Tron, Solana, Conflux, and Filecoin blockchains. It supports key Ethereum standards such as Legacy, EIP1559, EIP2930, and EIP712, providing developers with powerful tools for transactions, smart contracts, and token management.

this plugin enables:

- Ethereum: Legacy, EIP1559, EIP2930, EIP712, smart contracts, and HD wallet support.
- Tron: Account creation, asset transfers, native operations, and smart contract execution.
- Solana: Metaplex integration, token management, staking, and smart contracts.
- Conflux: Core Space (Base32 addresses) and eSpace (EVM-compatible) support with full transaction capabilities.
- Filecoin: Address management, transaction signing, and FIL token operations.

This package streamlines blockchain development across multiple ecosystems, making it a comprehensive toolkit for Dart developers.


## Features

### Ethereum Network

- Sign (Transaction, Personal Signing): Enable secure transaction and personal data signing within your Dart applications, ensuring cryptographic integrity and authentication.

- EIP1559: Embrace the efficiency of the Ethereum Improvement Proposal 1559, optimizing transaction fee mechanisms for enhanced predictability and user experience.

- EIP2930 (Access List): Streamline contract interactions with the Ethereum blockchain using Access Lists, enhancing efficiency and reducing transaction costs by specifying accounts with direct access permissions.

- Interact with Contract: Seamlessly engage with Ethereum smart contracts, unlocking the full potential of decentralized applications through efficient contract interactions within your Dart projects.

- Interact with Ethereum Node (JSON RPC): Facilitate direct communication with Ethereum nodes through JSON RPC, enabling your Dart applications to access and query blockchain data in a standardized and efficient manner.

- EIP712 (Legacy, v3, v4): Implement Ethereum Improvement Proposal 712 standards for structured and secure message signing, supporting legacy as well as versions 3 and 4 to ensure compatibility and compliance across diverse Ethereum ecosystems.

- HD-Wallet: Manage mnemonic generation, seed derivation, and address creation

- [Examples](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/ethereum)

### Tron Network


- Sign (Transaction, Personal Signing) for Tron: Securely authorize Tron transactions and sign personal data within your Dart applications, ensuring cryptographic integrity and user authentication.

- Multi-Signature: Enhance security and decentralized decision-making on the Tron blockchain with multi-signature capabilities. Enable collaboration by requiring multiple cryptographic signatures for transactions, reinforcing trust and integrity within the Tron network. Empower your Dart applications with sophisticated multi-signature functionality for a resilient and collaborative approach to transaction authorization on Tron.

- Interact with Tron Smart Contract: Seamlessly engage with Tron's smart contracts, enabling your Dart projects to execute and manage transactions on the Tron blockchain with ease.

- Create Tron Native Contract Transactions: Effortlessly initiate a wide array of Tron native contract transactions, including account creation, asset transfers, voting, smart contract creation, and more. Explore a comprehensive list of supported contract operations tailored for Tron's blockchain.

- Interact with Tron HTTP Node: Facilitate direct communication with Tron's blockchain through HTTP nodes, allowing your Dart applications to query and interact with Tron's network in a standardized and efficient manner.

- All Features of Tron: Harness the full potential of Tron's blockchain by leveraging all its features, including shielded transfers, market transactions, resource delegation, contract management, and more. Empower your Dart applications with comprehensive functionality for a rich and dynamic Tron blockchain experience.

- HD-Wallet: Manage mnemonic generation, seed derivation, and address creation

- [Examples](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/tron)

### Solana Network

- Transaction: Versioned Transaction Generation, Serialization, and Deserialization.

- Sign: Effortlessly Sign Transactions

- Instructions: The plugin offers numerous pre-built instructions, simplifying the process of creating your own transactions. Here are some examples:
  
  - addressLockupTable
  - associatedTokenAccount
  - computeBudget
  - ed25519
  - memo
  - nameService
  - secp256k1
  - splToken
  - splTokenMetaData
  - splTokenSwap
  - stake
  - stakePool
  - system
  - tokenLending
  - vote
  - Metaplex
    - auctionHouse
    - auctioneer
    - bubblegum
    - candyMachineCore
    - fixedPriceSale
    - gumdrop
    - hydra
    - nftPacks
    - tokenEntangler
    - tokenMetaData

- Custom Programs: The plugin facilitates the Solana Buffer layout structure, enabling effortless encoding and decoding of pertinent data

- HD-Wallet: Manage mnemonic generation, seed derivation, and address creation

- [Examples](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/solana)

### Conflux Network

- **Core Space Support**: Full support for Conflux's native Core Space with Base32 address encoding (CIP-37 standard)

- **eSpace Support**: Complete EVM-compatible eSpace support with 0x addresses

- **Address Management**: 
  - Base32 address encoding/decoding for Core Space (cfx:...)
  - Hex address support for eSpace (0x...)
  - Address type identification (user, contract, builtin, null)
  - Network ID validation (mainnet=1029, testnet=1)

- **Transaction Building**: Comprehensive transaction creation and management
  - Core Space transactions with storageLimit and epochHeight
  - Transaction signing and serialization
  - RLP encoding/decoding
  - Transaction hash calculation

- **Key Management**: 
  - Private/public key generation
  - Address derivation for both Core Space and eSpace
  - HD wallet support using BIP44 (Ethereum coin type)
  - Personal message signing

- **RPC Methods**: 14+ Core Space RPC methods including:
  - Account operations (balance, nonce)
  - Transaction operations (send, receipt, estimation)
  - Contract operations (call, getCode)
  - Sponsor mechanism (getSponsorInfo, checkBalanceAgainstTransaction)
  - Network operations (chainId, gasPrice, epochNumber)

- **Conflux Features**: 
  - Storage collateral support
  - Epoch number handling
  - Sponsor mechanism integration
  - Network-specific address formatting

- **HD-Wallet**: Manage mnemonic generation, seed derivation, and address creation

- [Examples](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/conflux)
- [Technical Documentation](https://github.com/mrtnetwork/On_chain/blob/main/lib/conflux/CLAUDE.md)

### solidity

- Encode, decode, and interact with Solidity smart contracts.

### Move

- Encode and decode Move language types.

## Examples

Explore all available examples [here](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example)


## Contributing

Contributions are welcome! Please follow these guidelines:

- Fork the repository and create a new branch.
- Make your changes and ensure tests pass.
- Submit a pull request with a detailed description of your changes.

## Feature requests and bugs

Please file feature requests and bugs in the issue tracker.
