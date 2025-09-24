import 'package:blockchain_utils/service/service.dart';
import 'package:on_chain/filecoin/src/provider/core/request.dart';

typedef FilecoinServiceResponse<T> = BaseServiceResponse<T>;

/// A mixin for providing JSON-RPC service functionality for Filecoin
mixin FilecoinServiceProvider implements BaseServiceProvider<FilecoinRequestDetails> {
  /// URI for the Filecoin JSON-RPC endpoint
  String get rpcUri;

  @override
  Future<FilecoinServiceResponse<T>> doRequest<T>(FilecoinRequestDetails params,
      {Duration? timeout});
}