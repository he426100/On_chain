/// Chain configuration for Filecoin networks
class FilecoinChain {
  final dynamic id; // Can be int or String
  final String name;
  final NativeCurrency nativeCurrency;
  final RpcUrls rpcUrls;
  final Map<String, BlockExplorer> blockExplorers;
  final Map<String, Contract>? contracts;
  final bool testnet;
  final String chainId;
  final String chainNamespace;
  final String caipNetworkId;
  final List<String>? iconUrls;

  const FilecoinChain({
    required this.id,
    required this.name,
    required this.nativeCurrency,
    required this.rpcUrls,
    required this.blockExplorers,
    this.contracts,
    this.testnet = false,
    required this.chainId,
    required this.chainNamespace,
    required this.caipNetworkId,
    this.iconUrls,
  });

  /// Convert to Ethereum chain format (for Metamask)
  Map<String, dynamic> toEthereumChain() {
    final List<String> rpcUrlsList = rpcUrls.defaultUrls.http;
    final List<String> blockExplorerUrlsList = blockExplorers.values.map((e) => e.url).toList();

    return {
      'chainId': chainId,
      'chainName': name,
      'rpcUrls': rpcUrlsList,
      'blockExplorerUrls': blockExplorerUrlsList,
      'nativeCurrency': {
        'name': nativeCurrency.name,
        'symbol': nativeCurrency.symbol,
        'decimals': nativeCurrency.decimals,
      },
      if (iconUrls != null) 'iconUrls': iconUrls,
    };
  }
}

class NativeCurrency {
  final String name;
  final String symbol;
  final int decimals;

  const NativeCurrency({
    required this.name,
    required this.symbol,
    required this.decimals,
  });
}

class RpcUrls {
  final RpcEndpoints defaultUrls;

  const RpcUrls({required this.defaultUrls});
}

class RpcEndpoints {
  final List<String> http;
  final List<String>? webSocket;

  const RpcEndpoints({
    required this.http,
    this.webSocket,
  });
}

class BlockExplorer {
  final String name;
  final String url;

  const BlockExplorer({
    required this.name,
    required this.url,
  });
}

class Contract {
  final String address;
  final int? blockCreated;

  const Contract({
    required this.address,
    this.blockCreated,
  });
}

/// Filecoin EVM Mainnet chain
const FilecoinChain mainnetChain = FilecoinChain(
  id: 314,
  name: 'Filecoin - Mainnet',
  nativeCurrency: NativeCurrency(
    name: 'Filecoin',
    symbol: 'FIL',
    decimals: 18,
  ),
  rpcUrls: RpcUrls(
    defaultUrls: RpcEndpoints(
      http: ['https://api.node.glif.io/rpc/v1'],
      webSocket: ['wss://wss.node.glif.io/apigw/lotus/rpc/v1'],
    ),
  ),
  blockExplorers: {
    'Beryx': BlockExplorer(
      name: 'Beryx',
      url: 'https://beryx.io/fil/mainnet',
    ),
    'Filfox': BlockExplorer(
      name: 'Filfox',
      url: 'https://filfox.info',
    ),
    'Glif': BlockExplorer(
      name: 'Glif',
      url: 'https://www.glif.io/en',
    ),
    'default': BlockExplorer(
      name: 'Blockscout',
      url: 'https://filecoin.blockscout.com',
    ),
  },
  contracts: {
    'multicall3': Contract(
      address: '0xcA11bde05977b3631167028862bE2a173976CA11',
      blockCreated: 3328594,
    ),
  },
  chainId: '0x13a',
  chainNamespace: 'eip155',
  caipNetworkId: 'eip155:314',
  iconUrls: ['https://filsnap.dev/filecoin-logo.svg'],
);

/// Filecoin EVM Calibration testnet chain
const FilecoinChain testnetChain = FilecoinChain(
  id: 314159,
  name: 'Filecoin - Calibration testnet',
  nativeCurrency: NativeCurrency(
    name: 'Filecoin',
    symbol: 'tFIL',
    decimals: 18,
  ),
  rpcUrls: RpcUrls(
    defaultUrls: RpcEndpoints(
      http: ['https://api.calibration.node.glif.io/rpc/v1'],
      webSocket: ['wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v1'],
    ),
  ),
  blockExplorers: {
    'Beryx': BlockExplorer(
      name: 'Beryx',
      url: 'https://beryx.io/fil/calibration',
    ),
    'Filfox': BlockExplorer(
      name: 'Filfox',
      url: 'https://calibration.filfox.info',
    ),
    'Glif': BlockExplorer(
      name: 'Glif',
      url: 'https://www.glif.io/en/calibrationnet',
    ),
    'default': BlockExplorer(
      name: 'Blockscout',
      url: 'https://filecoin-testnet.blockscout.com',
    ),
  },
  contracts: {
    'multicall3': Contract(
      address: '0xcA11bde05977b3631167028862bE2a173976CA11',
      blockCreated: 1446201,
    ),
  },
  testnet: true,
  chainId: '0x4cb2f',
  chainNamespace: 'eip155',
  caipNetworkId: 'eip155:314159',
  iconUrls: ['https://filsnap.dev/filecoin-logo.svg'],
);

/// Filecoin EVM Calibration testnet chain (alias)
const FilecoinChain calibrationChain = testnetChain;

/// Filecoin Native chain
const FilecoinChain filecoinNativeChain = FilecoinChain(
  id: 'f',
  name: 'Filecoin',
  nativeCurrency: NativeCurrency(
    name: 'Filecoin',
    symbol: 'FIL',
    decimals: 18,
  ),
  rpcUrls: RpcUrls(
    defaultUrls: RpcEndpoints(
      http: ['https://api.node.glif.io/rpc/v1'],
      webSocket: ['wss://wss.node.glif.io/apigw/lotus/rpc/v1'],
    ),
  ),
  blockExplorers: {
    'Beryx': BlockExplorer(
      name: 'Beryx',
      url: 'https://beryx.io/fil/mainnet',
    ),
    'Filfox': BlockExplorer(
      name: 'Filfox',
      url: 'https://filfox.info',
    ),
    'Glif': BlockExplorer(
      name: 'Glif',
      url: 'https://www.glif.io/en',
    ),
    'default': BlockExplorer(
      name: 'Blockscout',
      url: 'https://filecoin.blockscout.com',
    ),
  },
  chainNamespace: 'fil',
  caipNetworkId: 'fil:f',
  chainId: 'f',
  iconUrls: ['https://filsnap.dev/filecoin-logo.svg'],
);

/// Filecoin Native Calibration chain
const FilecoinChain filecoinNativeCalibrationChain = FilecoinChain(
  id: 't',
  name: 'Filecoin Calibration',
  nativeCurrency: NativeCurrency(
    name: 'Filecoin',
    symbol: 'tFIL',
    decimals: 18,
  ),
  rpcUrls: RpcUrls(
    defaultUrls: RpcEndpoints(
      http: ['https://api.calibration.node.glif.io/rpc/v1'],
      webSocket: ['wss://wss.calibration.node.glif.io/apigw/lotus/rpc/v1'],
    ),
  ),
  blockExplorers: {
    'Beryx': BlockExplorer(
      name: 'Beryx',
      url: 'https://beryx.io/fil/calibration',
    ),
    'Filfox': BlockExplorer(
      name: 'Filfox',
      url: 'https://calibration.filfox.info',
    ),
    'Glif': BlockExplorer(
      name: 'Glif',
      url: 'https://www.glif.io/en/calibrationnet',
    ),
    'default': BlockExplorer(
      name: 'Blockscout',
      url: 'https://filecoin-testnet.blockscout.com',
    ),
  },
  testnet: true,
  chainNamespace: 'fil',
  caipNetworkId: 'fil:t',
  chainId: 't',
  iconUrls: ['https://filsnap.dev/filecoin-logo.svg'],
);
