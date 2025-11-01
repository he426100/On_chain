import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';

/// Conflux RPC provider for making requests to Conflux nodes.
/// 
/// Supports both Core Space and eSpace RPC methods.
/// 
/// Example:
/// ```dart
/// // Core Space provider
/// final service = HTTPService('https://main.confluxrpc.com');
/// final provider = ConfluxProvider(service);
/// 
/// // Make RPC requests using Ethereum provider
/// final balance = await provider.request(
///   CFXGetBalance(
///     address: 'cfx:...',
///     epochNumber: EpochNumber.latestState,
///   ),
/// );
/// 
/// // eSpace provider (uses Ethereum RPC)
/// final eSpaceProvider = ConfluxProvider(
///   HTTPService('https://evm.confluxrpc.com'),
/// );
/// ```
class ConfluxProvider extends EthereumProvider {
  /// Creates a Conflux provider with the specified service.
  ConfluxProvider(super.rpc);
}

