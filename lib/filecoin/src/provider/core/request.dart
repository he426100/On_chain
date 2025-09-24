import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/string/string.dart';

/// HTTP methods for Filecoin JSON-RPC requests
enum FilecoinHTTPMethods {
  post;

  String get value => name;
  RequestServiceType get requestType => RequestServiceType.post;
}

/// Base class for Filecoin JSON-RPC method requests
abstract class FilecoinRequest<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, FilecoinRequestDetails> {
  /// The JSON-RPC method name
  abstract final String method;

  /// Converts the request parameters to a JSON format
  List<dynamic> toJson();

  /// Converts the request parameters to [FilecoinRequestDetails]
  @override
  FilecoinRequestDetails buildRequest(int requestID) {
    final jsonBody = {
      'jsonrpc': '2.0',
      'id': requestID,
      'method': method,
      'params': toJson(),
    };

    return FilecoinRequestDetails(
      requestID: requestID,
      jsonBody: jsonBody,
      headers: ServiceConst.defaultPostHeaders,
      type: requestType,
    );
  }

  @override
  RequestServiceType get requestType => RequestServiceType.post;
}

/// Represents the details of a Filecoin network request
class FilecoinRequestDetails extends BaseServiceRequestParams {
  /// Constructs a new [FilecoinRequestDetails] instance
  const FilecoinRequestDetails({
    required super.requestID,
    required super.headers,
    required super.type,
    required this.jsonBody,
  });

  /// Request parameters encoded as a JSON-formatted string
  final Map<String, dynamic> jsonBody;

  @override
  List<int>? body() {
    return StringUtils.encode(StringUtils.fromJson(jsonBody));
  }

  @override
  Map<String, dynamic> toJson() => jsonBody;

  @override
  Uri toUri(String uri) {
    // For Filecoin JSON-RPC, we typically use the base URI without additional paths
    return Uri.parse(uri);
  }
}