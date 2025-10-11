/// Filecoin network types
enum FilecoinNetwork {
  /// Filecoin Mainnet (prefix: f)
  mainnet('mainnet', 'f', 314, '0x13a'),

  /// Filecoin Calibration Testnet (prefix: t)
  testnet('testnet', 't', 314159, '0x4cb2f');

  const FilecoinNetwork(this.name, this.prefix, this.chainId, this.chainIdHex);

  /// Network name
  final String name;

  /// Address prefix ('f' for mainnet, 't' for testnet)
  final String prefix;

  /// EVM chain ID (314 for mainnet, 314159 for testnet)
  final int chainId;

  /// EVM chain ID in hex format
  final String chainIdHex;

  /// Get network from prefix
  static FilecoinNetwork fromPrefix(String prefix) {
    return values.firstWhere(
      (network) => network.prefix == prefix,
      orElse: () => throw ArgumentError('Invalid network prefix: $prefix'),
    );
  }

  /// Get network from chain ID
  static FilecoinNetwork fromChainId(int chainId) {
    return values.firstWhere(
      (network) => network.chainId == chainId,
      orElse: () => throw ArgumentError('Invalid chain ID: $chainId'),
    );
  }

  /// Get network from name
  static FilecoinNetwork fromName(String name) {
    return values.firstWhere(
      (network) => network.name == name,
      orElse: () => throw ArgumentError('Invalid network name: $name'),
    );
  }

  /// Check if address prefix is valid
  static bool isValidPrefix(String prefix) {
    return values.any((network) => network.prefix == prefix);
  }

  /// Default RPC endpoint for this network
  String get defaultRpcUrl {
    switch (this) {
      case FilecoinNetwork.mainnet:
        return 'https://api.node.glif.io/rpc/v1';
      case FilecoinNetwork.testnet:
        return 'https://api.calibration.node.glif.io/rpc/v1';
    }
  }

  /// Default WebSocket endpoint for this network
  String get defaultWsUrl {
    switch (this) {
      case FilecoinNetwork.mainnet:
        return 'wss://wss.node.glif.io/apigw/lotus/rpc/v1';
      case FilecoinNetwork.testnet:
        return 'wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v1';
    }
  }

  /// Block explorer URL for this network
  String get explorerUrl {
    switch (this) {
      case FilecoinNetwork.mainnet:
        return 'https://filfox.info';
      case FilecoinNetwork.testnet:
        return 'https://calibration.filfox.info';
    }
  }

  /// Native currency symbol
  String get currencySymbol {
    switch (this) {
      case FilecoinNetwork.mainnet:
        return 'FIL';
      case FilecoinNetwork.testnet:
        return 'tFIL';
    }
  }

  /// BIP44 coin type for this network
  /// 461 for mainnet, 1 for testnet
  int get coinType {
    switch (this) {
      case FilecoinNetwork.mainnet:
        return 461;
      case FilecoinNetwork.testnet:
        return 1;
    }
  }

  /// Get default derivation path for this network
  /// m/44'/461'/0'/0/0 for mainnet
  /// m/44'/1'/0'/0/0 for testnet
  String derivationPath([int index = 0]) {
    return "m/44'/$coinType'/0'/0/$index";
  }

  /// Whether this is a testnet
  bool get isTestnet => this == FilecoinNetwork.testnet;

  @override
  String toString() => name;
}
