[根目录](../../CLAUDE.md) > **ethereum**

# Ethereum 模块

## 模块职责

提供完整的 Ethereum 网络支持，包括地址管理、密钥操作、交易构建、RLP 编解码、RPC 通信和 EIP 标准实现。

**核心功能**：
- 多种交易类型：Legacy、EIP1559、EIP2930
- EIP4361 (Sign-In with Ethereum)
- EIP712 结构化数据签名（v1、v3、v4）
- HD 钱包支持（BIP32/39/44）
- 完整的 JSON-RPC 客户端

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/ethereum/ethereum.dart`

### 导出模块
```dart
export 'src/address/evm_address.dart';     // 地址工具
export 'src/keys/keys.dart';               // 密钥管理
export 'src/models/models.dart';           // 数据模型
export 'src/rpc/rpc.dart';                 // RPC 通信
export 'src/rlp/rlp.dart';                 // RLP 编解码
export 'src/transaction/transaction.dart'; // 交易处理
export 'src/utils/helper.dart';            // 辅助工具
export 'src/exception/exception.dart';     // 异常定义
export 'src/eip_4361/eip_4361.dart';       // EIP4361 标准
```

### 快速开始
```dart
import 'package:on_chain/ethereum/ethereum.dart';

// 1. 创建地址
final address = ETHAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");

// 2. 创建 RPC 客户端
final service = HTTPService("https://eth.llamarpc.com");
final provider = EthereumProvider(service);

// 3. 查询余额
final balance = await provider.request(
  ETHGetBalance(address: address, tag: BlockTagOrNumber.latest)
);

// 4. 构建交易
final tx = ETHTransactionBuilder.eip1559(
  from: fromAddress,
  to: toAddress,
  value: EtherUnit.wei(BigInt.from(1000000)),
  chainId: BigInt.one,
);
```

---

## 对外接口

### 地址 (Address)
- **`ETHAddress`**：Ethereum 地址类
  - `ETHAddress(String address)`：从十六进制字符串创建
  - `toHex()`：转换为十六进制字符串
  - `toBytes()`：转换为字节数组

### 密钥 (Keys)
- **`ETHPrivateKey`**：私钥管理
  - 派生公钥：`publicKey()`
  - 签名：`sign(List<int> digest)`
- **`ETHPublicKey`**：公钥管理
  - 获取地址：`toAddress()`
  - 压缩/非压缩转换

### 交易 (Transaction)
- **`ETHTransactionBuilder`**：交易构建器
  - `ETHTransactionBuilder.eip1559(...)`：创建 EIP1559 交易
  - `ETHTransactionBuilder.legacy(...)`：创建 Legacy 交易
  - `ETHTransactionBuilder.eip2930(...)`：创建 EIP2930 交易
  - `ETHTransactionBuilder.contract(...)`：创建合约调用交易
- **交易方法**：
  - `estimateGas()`：估算 Gas
  - `setNonce()`：设置 nonce
  - `signTransaction(ETHPrivateKey key)`：签名交易
  - `sendTransaction()`：发送交易

### RPC Provider
- **`EthereumProvider`**：主 Provider 类
  - `request<T>(EthereumRequest<T, dynamic> params)`：通用请求方法
- **常用 RPC 方法类**（位于 `src/rpc/methds/`）：
  - `ETHGetBalance`：查询余额
  - `ETHGetTransactionCount`：获取 nonce
  - `ETHEstimateGas`：估算 Gas
  - `ETHSendRawTransaction`：发送原始交易
  - `ETHCall`：调用合约（不上链）
  - `ETHGetTransactionReceipt`：获取交易回执
  - `ETHGetBlockByNumber`：获取区块信息

### RLP 编解码
- **`RLPEncoder`**：RLP 编码器
  - `encode(dynamic data)`：编码数据
- **`RLPDecoder`**：RLP 解码器
  - `decode(List<int> data)`：解码数据

### EIP712 签名
- **`EIP712`**：结构化数据签名
  - `EIP712.fromJson(Map<String, dynamic> json)`：从 JSON 创建
  - `primaryHash()`：计算主哈希
  - `signHash(ETHPrivateKey key)`：签名哈希

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 ECDSA (secp256k1) 和 Keccak256 哈希

### 内部依赖
- 无依赖其他模块（独立模块）

### 配置文件
- 无需额外配置文件

---

## 数据模型

### 核心模型（位于 `src/models/`）
- **`Block`**：区块数据结构
- **`Transaction`**：交易数据结构
- **`TransactionReceipt`**：交易回执
- **`LogEntry`**：事件日志
- **`AccessList`**：EIP2930 访问列表
- **`Filter`**：事件过滤器
- **`FeeHistory`**：费用历史
- **`BlockTag`**：区块标签（latest、earliest、pending）

### 交易类型
1. **Legacy Transaction**：传统交易
   - 字段：`nonce`, `gasPrice`, `gasLimit`, `to`, `value`, `data`, `v`, `r`, `s`
2. **EIP1559 Transaction**：伦敦升级后的交易
   - 字段：`maxFeePerGas`, `maxPriorityFeePerGas`, `baseFee`
3. **EIP2930 Transaction**：带访问列表的交易
   - 字段：`accessList`

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/etherum/`（注意拼写）

### 测试文件
- `transaction_test.dart`：交易序列化与签名测试
- `sign_test.dart`：签名验证测试
- `rlp_encode_decode_test.dart`：RLP 编解码测试
- `keys_test.dart`：密钥操作测试
- `eip_4631_test.dart`：EIP4361 测试

### 运行测试
```bash
# 运行所有 Ethereum 测试
dart test test/etherum/

# 运行特定测试
dart test test/etherum/transaction_test.dart
```

### 示例代码
- HD 钱包：`example/lib/example/ethereum/hd_wallet.dart`
- EIP712 签名：`example/lib/example/eip_712/v4_example.dart`
- 合约调用：`example/lib/example/contract/call_example.dart`

---

## 常见问题 (FAQ)

### Q1: 如何创建 EIP1559 交易？
```dart
final tx = ETHTransactionBuilder.eip1559(
  from: ETHAddress("0x..."),
  to: ETHAddress("0x..."),
  value: EtherUnit.ether(BigInt.one),
  chainId: BigInt.from(1),
  maxFeePerGas: EtherUnit.gwei(BigInt.from(50)),
  maxPriorityFeePerGas: EtherUnit.gwei(BigInt.from(2)),
);
```

### Q2: 如何调用智能合约？
```dart
// 方式 1：使用 TransactionBuilder
final tx = ETHTransactionBuilder.contract(
  contractAddress: contractAddr,
  function: AbiFunctionFragment.fromJson(functionJson),
  functionParams: [param1, param2],
);

// 方式 2：使用 ETHCall RPC 方法（只读调用）
final result = await provider.request(ETHCall(
  params: ETHCallParams(
    to: contractAddr,
    data: encodedData,
  ),
));
```

### Q3: 如何处理 WebSocket 订阅？
```dart
final wsService = WebSocketService("wss://eth.llamarpc.com");
final provider = EthereumProvider(wsService);

// 订阅新区块
await provider.request(ETHNewHeadsSubscribe());

// 监听事件
wsService.stream.listen((event) {
  print("New block: $event");
});
```

### Q4: 如何验证 EIP712 签名？
```dart
final eip712 = EIP712.fromJson(typedDataJson);
final hash = eip712.primaryHash();
final signature = privateKey.sign(hash);

// 恢复签名者地址
final recoveredAddress = signature.recoverPublicKey(hash).toAddress();
```

---

## 相关文件清单

### 核心文件
- `src/address/evm_address.dart`：EVM 地址实现
- `src/keys/private_key.dart`：私钥实现
- `src/keys/public_key.dart`：公钥实现
- `src/transaction/eth_transaction.dart`：交易类型定义
- `src/transaction/eth_transaction_builder.dart`：交易构建器
- `src/rpc/provider/provider.dart`：RPC Provider
- `src/rpc/service/service.dart`：HTTP/WebSocket 服务
- `src/rlp/encode.dart`：RLP 编码器
- `src/rlp/decode.dart`：RLP 解码器
- `src/eip_4361/types/eip_4631.dart`：EIP4361 实现
- `src/exception/exception.dart`：异常定义

### RPC 方法文件（部分，位于 `src/rpc/methds/`）
- `get_balance.dart`
- `get_transaction_count.dart`
- `estimate_gas.dart`
- `send_raw_transaction.dart`
- `rpc_call.dart`
- `get_transaction_receipt.dart`
- `get_block_by_number.dart`
- `fee_history.dart`
- `create_access_list.dart`

### 订阅相关（位于 `src/rpc/methds/subscribes/methods/`）
- `new_heads.dart`
- `logs.dart`
- `pending_transactions.dart`
- `syncing.dart`
- `unsubscribe.dart`

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Ethereum 模块文档
- 覆盖地址、密钥、交易、RPC、RLP、EIP712 所有核心功能
- 添加常见问题与使用示例
