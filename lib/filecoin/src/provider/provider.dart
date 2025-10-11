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

  SERVICERESPONSE _findError<SERVICERESPONSE>(
      BaseServiceResponse<SERVICERESPONSE> response,
      FilecoinRequestDetails request) {
    final result = response.getResult(request);
    if (result is Map) {
      if (result.containsKey('error')) {
        final error = result['error'];
        if (error is Map) {
          throw RPCError(
              message: error['message']?.toString() ?? ServiceConst.defaultError,
              errorCode: error['code']);
        } else {
          throw RPCError(message: error?.toString() ?? ServiceConst.defaultError);
        }
      }
    }
    return result;
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