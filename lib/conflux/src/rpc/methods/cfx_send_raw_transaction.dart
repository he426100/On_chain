import 'package:on_chain/conflux/src/rpc/core/core.dart';

/// Sends a signed transaction to the network.
/// 
/// Example:
/// ```dart
/// final signedTx = builder.sign(privateKey);
/// final serialized = '0x' + BytesUtils.toHexString(signedTx.serialize());
/// 
/// final txHash = await provider.request(
///   CFXSendRawTransaction(signedTransaction: serialized),
/// );
/// print('Transaction hash: $txHash');
/// ```
class CFXSendRawTransaction extends CFXRequest<String, String> {
  CFXSendRawTransaction({required this.signedTransaction});

  /// The signed and serialized transaction (hex string with 0x prefix).
  final String signedTransaction;

  @override
  String get method => 'cfx_sendRawTransaction';

  @override
  List<dynamic> toJson() => [signedTransaction];

  @override
  String onResonse(result) {
    return result;
  }
}

