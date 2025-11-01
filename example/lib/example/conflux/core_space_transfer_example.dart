// ignore_for_file: unused_local_variable

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/on_chain.dart';

void main() async {
  /// Create RPC provider (mainnet)
  /// Note: You need to implement or use an HTTP service that implements BaseServiceProvider
  /// Example: final service = HTTPService(url: 'https://main.confluxrpc.com');
  /// final provider = ConfluxProvider(service);

  /// Generate a private key (NEVER share your private key!)
  final privateKey = CFXPrivateKey(
    '0x1234567890123456789012345678901234567890123456789012345678901234',
  );

  /// Derive the public key and Core Space address
  final publicKey = privateKey.publicKey();
  final fromAddress = publicKey.toAddress(1029); // Mainnet network ID

  /// Define the recipient address
  final toAddress = CFXAddress.fromHex(
    '0x106d49f8505410eb4e671d51f7d96d2c87807b09',
    1029,
  );

  /// Build a Core Space transaction
  final txBuilder = CFXTransactionBuilder.transfer(
    from: fromAddress,
    to: toAddress,
    value: BigInt.from(1000000000000000000), // 1 CFX
    chainId: BigInt.from(1029), // Mainnet
  );

  /// Set transaction parameters
  /// In a real application, you would fetch these from the RPC:
  /// - nonce from cfx_getNextNonce
  /// - gasPrice from cfx_gasPrice
  /// - epochHeight from cfx_epochNumber
  txBuilder.setNonce(BigInt.zero);
  txBuilder.setGasPrice(BigInt.from(1000000000)); // 1 GDrip
  txBuilder.setGas(BigInt.from(21000)); // Standard transfer
  txBuilder.setStorageLimit(BigInt.zero); // No storage for simple transfer
  txBuilder.setEpochHeight(BigInt.from(12345678));

  /// Sign the transaction
  final signedTx = txBuilder.sign(privateKey);

  /// Get transaction hash
  final txHash = signedTx.getTransactionHashHex();

  /// Serialize the transaction for broadcasting
  final serializedTx = signedTx.serialize();
  final hexSerializedTx = '0x${BytesUtils.toHexString(serializedTx)}';

  /// Send transaction using RPC (commented out)
  /// final sentTxHash = await provider.request(
  ///   CFXSendRawTransaction(signedTransaction: hexSerializedTx),
  /// );

  /// Query transaction receipt after sending (commented out)
  /// await Future.delayed(const Duration(seconds: 5));
  /// final receipt = await provider.request(
  ///   CFXGetTransactionReceipt(transactionHash: sentTxHash),
  /// );
}
