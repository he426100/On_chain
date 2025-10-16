/// FEVM FilForwarder contract metadata
/// Contract source: https://github.com/FilOzone/FilForwarder
library;

/// FilForwarder contract ABI
const List<Map<String, dynamic>> filForwarderAbi = [
  {
    'inputs': [
      {
        'internalType': 'int256',
        'name': 'errorCode',
        'type': 'int256',
      },
    ],
    'name': 'ActorError',
    'type': 'error',
  },
  {
    'inputs': [],
    'name': 'FailToCallActor',
    'type': 'error',
  },
  {
    'inputs': [
      {
        'internalType': 'bytes',
        'name': 'addr',
        'type': 'bytes',
      },
    ],
    'name': 'InvalidAddress',
    'type': 'error',
  },
  {
    'inputs': [],
    'name': 'InvalidAddress',
    'type': 'error',
  },
  {
    'inputs': [
      {
        'internalType': 'uint64',
        'name': '',
        'type': 'uint64',
      },
    ],
    'name': 'InvalidCodec',
    'type': 'error',
  },
  {
    'inputs': [],
    'name': 'InvalidResponseLength',
    'type': 'error',
  },
  {
    'inputs': [
      {
        'internalType': 'uint256',
        'name': 'balance',
        'type': 'uint256',
      },
      {
        'internalType': 'uint256',
        'name': 'value',
        'type': 'uint256',
      },
    ],
    'name': 'NotEnoughBalance',
    'type': 'error',
  },
  {
    'inputs': [
      {
        'internalType': 'bytes',
        'name': 'destination',
        'type': 'bytes',
      },
    ],
    'name': 'forward',
    'outputs': [],
    'stateMutability': 'payable',
    'type': 'function',
  },
];

/// FilForwarder contract address (same on all chains)
const String filForwarderContractAddress = '0x2B3ef6906429b580b7b2080de5CA893BC282c225';

/// Chain IDs where FilForwarder is deployed
const Map<String, String> filForwarderChainIds = {
  'filecoinMainnet': 'eip155:314',
  'filecoinCalibrationTestnet': 'eip155:314159',
};

/// FilForwarder contract metadata
class FilForwarderMetadata {
  /// Contract ABI
  static const abi = filForwarderAbi;

  /// Contract address (same on all chains where deployed)
  static const contractAddress = filForwarderContractAddress;

  /// CAIP-2 chain IDs where the contract is deployed
  static const chainIds = filForwarderChainIds;
}
