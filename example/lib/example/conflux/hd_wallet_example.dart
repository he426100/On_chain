// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';

void main() {
  /// Generate a 24-word mnemonic with an optional passphrase
  const passphrase = "MRTNETWORK";
  final mnemonic =
      Bip39MnemonicGenerator().fromWordsNumber(Bip39WordsNum.wordsNum24);
  final seed = Bip39SeedGenerator(mnemonic).generate(passphrase);

  /// Create a BIP44 wallet for Conflux using Ethereum coin type (60)
  /// Conflux uses the same derivation path as Ethereum
  final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum);

  /// Derive the default path (m/44'/60'/0'/0/0)
  final defaultPath = wallet.deriveDefaultPath;

  /// Create a Conflux private key from the BIP44 private key
  final privateKey = CFXPrivateKey.fromBytes(defaultPath.privateKey.raw);

  /// Derive the public key
  final publicKey = privateKey.publicKey();

  /// Generate Core Space address (mainnet)
  final coreSpaceMainnet = publicKey.toAddress(1029);

  /// Generate Core Space address (testnet)
  final coreSpaceTestnet = publicKey.toAddress(1);

  /// Generate eSpace address (compatible with Ethereum)
  final eSpaceAddress = publicKey.toESpaceAddress();
}
