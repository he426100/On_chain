import 'package:on_chain/filecoin/src/provider/core/request.dart';
import 'package:on_chain/filecoin/src/provider/methods/methods.dart';

/// Get version information
/// [Filecoin.Version](https://lotus.filecoin.io/reference/lotus/)
class FilecoinRequestVersion extends FilecoinRequest<Map<String, dynamic>, Map<String, dynamic>> {
  FilecoinRequestVersion();

  @override
  String get method => FilecoinMethods.version;

  @override
  List<dynamic> toJson() => [];
}

