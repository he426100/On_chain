import 'package:on_chain/ethereum/src/rpc/core/core.dart';

/// Base class for Conflux RPC requests.
/// 
/// Extends the Ethereum request interface since Conflux uses similar RPC patterns.
abstract class ConfluxRequest<RESULT, PARAMS>
    extends EthereumRequest<RESULT, PARAMS> {
  const ConfluxRequest();

  /// Returns the RPC method name.
  @override
  String get method;

  /// Converts the parameters to JSON format for RPC request.
  @override
  List<dynamic> toJson();
}

/// Base class for Conflux Core Space RPC requests.
abstract class CFXRequest<RESULT, PARAMS> extends ConfluxRequest<RESULT, PARAMS> {
  const CFXRequest();
}

/// Base class for Conflux eSpace RPC requests.
/// 
/// eSpace RPC methods are compatible with Ethereum RPC.
abstract class ESpaceRequest<RESULT, PARAMS>
    extends ConfluxRequest<RESULT, PARAMS> {
  const ESpaceRequest();
}

