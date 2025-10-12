import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/service/service.dart';
import 'package:on_chain/filecoin/src/network/filecoin_network.dart';

/// Facilitates communication with the Filecoin network using JSON-RPC
class FilecoinProvider extends BaseProvider<FilecoinRequestDetails> {
  /// The underlying Filecoin service provider used for network communication
  final FilecoinServiceProvider rpc;

  /// The Filecoin network this provider is connected to
  final FilecoinNetwork network;

  /// Constructs a new [FilecoinProvider] instance with the specified [rpc] service provider
  FilecoinProvider(
    this.rpc, {
    this.network = FilecoinNetwork.mainnet,
  });

  /// The unique identifier for each JSON-RPC request
  int _id = 0;

  /// Finds the result in the JSON-RPC 2.0 response data or throws an [RPCError]
  /// if an error is encountered.
  ///
  /// This method extracts the 'result' field from the JSON-RPC 2.0 response,
  /// matching the behavior of Ethereum and Solana providers.
  SERVICERESPONSE _findError<SERVICERESPONSE>(
      BaseServiceResponse<SERVICERESPONSE> response,
      FilecoinRequestDetails request) {
    dynamic result = response.getResult(request);

    // If the response is a JSON string, parse it first
    if (result is String) {
      try {
        result = StringUtils.toJson(result);
      } catch (e) {
        // If parsing fails, return the string as-is
        return result as SERVICERESPONSE;
      }
    }

    // Handle JSON-RPC 2.0 response format
    if (result is Map) {
      // Check for error field
      if (result.containsKey('error')) {
        final error = result['error'];
        if (error is Map) {
          throw RPCError(
              message: error['message']?.toString() ?? ServiceConst.defaultError,
              errorCode: error['code'],
              request: request.toJson());
        } else {
          throw RPCError(
              message: error?.toString() ?? ServiceConst.defaultError,
              request: request.toJson());
        }
      }

      // Extract the 'result' field from JSON-RPC 2.0 response
      // This matches the behavior of Ethereum and Solana providers
      if (result.containsKey('result')) {
        return result['result'] as SERVICERESPONSE;
      }
    }

    // Fallback: return result as-is if it's not a Map or doesn't have 'result' field
    return result as SERVICERESPONSE;
  }

  /// Sends a request to the Filecoin network using the specified [request] parameter
  ///
  /// The [timeout] parameter, if provided, specifies the maximum duration to wait for a response.
  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, FilecoinRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final data = await rpc.doRequest<SERVICERESPONSE>(params, timeout: timeout);
    final result = _findError(data, params);
    return result as RESULT;
  }

  /// Sends a request to the Filecoin network and returns the raw service response
  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, FilecoinRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final data = await rpc.doRequest<SERVICERESPONSE>(params, timeout: timeout);
    return _findError(data, params);
  }
}