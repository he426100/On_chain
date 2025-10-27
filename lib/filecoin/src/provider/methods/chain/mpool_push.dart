import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Push a signed message to the message pool
/// [Filecoin.MpoolPush](https://lotus.filecoin.io/reference/lotus/mpool/)
class FilecoinRequestMpoolPush extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestMpoolPush(this.signedMessage);

  final Map<String, dynamic> signedMessage;

  @override
  String get method => FilecoinMethods.mpoolPush;

  @override
  List<dynamic> toJson() => [signedMessage];
}

