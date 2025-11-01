import 'package:on_chain/conflux/src/models/account_info.dart';
import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Returns the current status of the Conflux node.
/// 
/// Example:
/// ```dart
/// final status = await provider.request(CFXGetStatus());
/// print('Chain ID: ${status.chainId}');
/// print('Epoch Number: ${status.epochNumber}');
/// ```
class CFXGetStatus extends CFXRequest<CFXStatus, Map<String, dynamic>> {
  CFXGetStatus();

  @override
  String get method => 'cfx_getStatus';

  @override
  List<dynamic> toJson() => [];

  @override
  CFXStatus onResonse(result) {
    return CFXStatus.fromJson(result);
  }
}

