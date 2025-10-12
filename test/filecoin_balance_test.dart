import 'package:test/test.dart';
import 'package:on_chain/filecoin/filecoin.dart';
import 'package:blockchain_utils/service/service.dart';

void main() {
  group('Filecoin Balance RPC Tests', () {
    test('Parse JSON-RPC 2.0 response correctly', () async {
      // Create provider with testnet
      final provider = FilecoinProvider(
        TestFilecoinService(),
        network: FilecoinNetwork.testnet,
      );

      // Test WalletBalance request
      final balance = await provider.request(
        FilecoinRequestWalletBalance('t1jwwoujfexmqgakqlu4rcawufdgmu2gtpwoizpkq'),
      );

      // Should extract the result value from JSON-RPC response
      expect(balance, '98999830735399858421');
      print('[TEST] Balance parsed correctly: $balance');
    });

    test('Parse nonce from JSON-RPC 2.0 response', () async {
      final provider = FilecoinProvider(
        TestFilecoinService(),
        network: FilecoinNetwork.testnet,
      );

      final nonce = await provider.request(
        FilecoinRequestGetNonce('t1jwwoujfexmqgakqlu4rcawufdgmu2gtpwoizpkq'),
      );

      expect(nonce, 0);
      print('[TEST] Nonce parsed correctly: $nonce');
    });

    test('Parse ChainHead from JSON-RPC 2.0 response', () async {
      final provider = FilecoinProvider(
        TestFilecoinService(),
        network: FilecoinNetwork.testnet,
      );

      final chainHead = await provider.request(
        FilecoinRequestChainHead(),
      );

      expect(chainHead, isA<Map<String, dynamic>>());
      expect(chainHead['Height'], 12345);
      print('[TEST] ChainHead parsed correctly: $chainHead');
    });
  });
}

// Test service that returns JSON-RPC 2.0 formatted responses
class TestFilecoinService implements FilecoinServiceProvider {
  @override
  Future<FilecoinServiceResponse<T>> doRequest<T>(
    FilecoinRequestDetails params, {
    Duration? timeout,
  }) async {
    // Simulate JSON-RPC 2.0 response
    final response = <String, dynamic>{
      'id': params.requestID,
      'jsonrpc': '2.0',
      'result': _getTestResult(params.jsonBody['method']),
    };

    return ServiceSuccessRespose<T>(response: response as T, statusCode: 200);
  }

  dynamic _getTestResult(String method) {
    switch (method) {
      case 'Filecoin.WalletBalance':
        return '98999830735399858421';
      case 'Filecoin.MpoolGetNonce':
        return 0;
      case 'Filecoin.ChainHead':
        return {'Height': 12345, 'Cids': []};
      default:
        throw Exception('Unknown method: $method');
    }
  }

  @override
  String get rpcUri => 'http://test';
}
