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
  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse<Map<String, dynamic>> response,
      required FilecoinRequestDetails params}) {
    final Map<String, dynamic> r = response.getResult(params);
    final error = r['error'];
    if (error != null) {
      final errorJson = StringUtils.tryToJson<Map<String, dynamic>>(error);
      final errorCode = IntUtils.tryParse(errorJson?['code']);
      final String? message = error['message']?.toString();
      throw RPCError(
          errorCode: errorCode,
          message: message ?? error.toString(),
          request: params.toJson(),
          details: errorJson);
    }
    return ServiceProviderUtils.parseResponse(
        object: r['result'], params: params);
  }

  /// Sends a request to the Filecoin network using the specified [request] parameter
  ///
  /// The [timeout] parameter, if provided, specifies the maximum duration to wait for a response.
  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, FilecoinRequestDetails> request,
      {Duration? timeout}) async {
    final r = await requestDynamic(request, timeout: timeout);
    return request.onResonse(r);
  }

  /// Sends a request to the Filecoin network and returns the raw service response
  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, FilecoinRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response =
        await rpc.doRequest<Map<String, dynamic>>(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}