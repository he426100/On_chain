import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get the current head of the chain
/// [Filecoin.ChainHead](https://lotus.filecoin.io/reference/lotus/chain/)
class FilecoinRequestChainHead extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestChainHead();

  @override
  String get method => FilecoinMethods.chainHead;

  @override
  List<dynamic> toJson() => [];
}

