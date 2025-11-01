[根目录](../../CLAUDE.md) > **conflux**

# Conflux 模块

## 模块职责

提供完整的 Conflux 区块链支持，包括 **Core Space**（Base32 地址空间）和 **eSpace**（EVM 兼容空间）两个网络环境。

**核心功能**：
- Base32 地址编解码（CIP-37）
- Core Space 和 eSpace 双重地址支持
- Conflux 特有交易字段（storageLimit、epochHeight）
- Sponsor 机制支持
- 30+ 个 Core Space RPC 方法
- HD 钱包支持（BIP32/39/44）

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/conflux/conflux.dart`

### 导出模块
```dart
export 'src/address/cfx_address.dart';     // Core Space 地址
export 'src/address/espace_address.dart';  // eSpace 地址
export 'src/keys/keys.dart';               // 密钥管理
export 'src/models/models.dart';           // 数据模型
export 'src/rpc/rpc.dart';                 // RPC 通信
export 'src/transaction/transaction.dart'; // 交易处理
export 'src/rlp/rlp.dart';                 // RLP 编解码
export 'src/exception/exception.dart';     // 异常定义
```

### 快速开始
```dart
import 'package:on_chain/conflux/conflux.dart';

// 1. 创建 Core Space 地址
final address = CFXAddress('cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p');

// 2. 创建 RPC Provider
final provider = ConfluxProvider(
  HTTPService('https://main.confluxrpc.com'),
);

// 3. 查询余额
final balance = await provider.request(
  CFXGetBalance(address: address.toBase32()),
);

// 4. 构建交易
final privateKey = CFXPrivateKey('0x...');
final txBuilder = CFXTransactionBuilder.transfer(
  from: fromAddr,
  to: toAddr,
  value: BigInt.from(1000000000000000000), // 1 CFX
  chainId: BigInt.from(1029),
);

txBuilder.setNonce(BigInt.zero);
txBuilder.setGasPrice(BigInt.from(1000000000));
txBuilder.setGas(BigInt.from(21000));
txBuilder.setStorageLimit(BigInt.zero);
txBuilder.setEpochHeight(BigInt.from(12345678));

// 5. 签名并发送
final signedTx = txBuilder.sign(privateKey);
final txHash = await provider.request(
  CFXSendRawTransaction(
    signedTransaction: '0x' + BytesUtils.toHexString(signedTx.serialize()),
  ),
);
```

---

## 对外接口

### 地址 (Address)

#### Core Space 地址
- **`CFXAddress`**：Conflux Core Space 地址类（Base32 格式）
  - `CFXAddress(String base32Address)`：从 Base32 字符串创建
  - `CFXAddress.fromHex(String hexAddress, int networkId)`：从 Hex 创建
  - `toBase32({bool verbose = false})`：转换为 Base32
  - `toHex()`：转换为 Hex
  - `networkId`：网络 ID（1029=mainnet, 1=testnet）
  - `addressType`：地址类型（user/contract/builtin/null）

#### eSpace 地址
- **`eSpaceAddress`**：Conflux eSpace 地址类（0x 格式）
  - `eSpaceAddress(String hexAddress)`：从十六进制字符串创建
  - `toCore SpaceAddress(int networkId)`：转换为 Core Space 地址
  - `toHex()`：转换为十六进制字符串

### 密钥 (Keys)
- **`CFXPrivateKey`**：私钥管理
  - `CFXPrivateKey(String privateKeyHex)`：从十六进制创建
  - `CFXPrivateKey.random()`：生成随机私钥
  - `publicKey()`：获取公钥
  - `sign(List<int> digest)`：签名
  - `signPersonalMessage(List<int> message)`：个人消息签名
  
- **`CFXPublicKey`**：公钥管理
  - `toAddress(int networkId)`：生成 Core Space 地址
  - `toESpaceAddress()`：生成 eSpace 地址

### 交易 (Transaction)

#### Core Space 交易
- **`CFXTransaction`**：Core Space 交易类
  - 特有字段：`storageLimit`、`epochHeight`
  - `serialize()`：RLP 序列化
  - `getTransactionHash()`：获取交易哈希
  
- **`CFXTransactionBuilder`**：交易构建器
  - `CFXTransactionBuilder.transfer(...)`：创建转账交易
  - `CFXTransactionBuilder.contractCall(...)`：创建合约调用
  - `CFXTransactionBuilder.deploy(...)`：创建合约部署
  - `setNonce(BigInt nonce)`：设置 nonce
  - `setGasPrice(BigInt gasPrice)`：设置 gas 价格
  - `setGas(BigInt gas)`：设置 gas 限制
  - `setStorageLimit(BigInt storageLimit)`：设置存储限制
  - `setEpochHeight(BigInt epochHeight)`：设置 epoch 高度
  - `sign(CFXPrivateKey privateKey)`：签名交易

#### eSpace 交易
- 复用 Ethereum 交易类型（`ETHTransaction`、`ETHTransactionBuilder`）

### RPC Provider
- **`ConfluxProvider`**：主 Provider 类
  - `request<T, P>(ConfluxRequest<T, P> params)`：通用请求方法
  - `batchRequest(List<ConfluxRequest> params)`：批量请求
  - `subscribe(ConfluxRequest params)`：订阅事件（WebSocket）
  - `unsubscribe(String id)`：取消订阅

### Core Space RPC 方法

#### 账户相关（`src/rpc/methods/`）
- `CFXGetBalance`：查询余额
- `CFXGetNextNonce`：获取下一个 nonce
- `CFXGetNextUsableNonce`：获取下一个可用 nonce（包含 pending）

#### 交易相关
- `CFXSendRawTransaction`：发送原始交易
- `CFXGetTransactionByHash`：查询交易
- `CFXGetTransactionReceipt`：获取交易回执
- `CFXEstimateGasAndCollateral`：估算 gas 和存储抵押

#### 区块/Epoch 相关
- `CFXEpochNumber`：获取当前 epoch 号

#### 合约相关
- `CFXCall`：调用合约（只读）
- `CFXGetCode`：获取合约字节码

#### Sponsor 机制
- `CFXGetSponsorInfo`：获取 Sponsor 信息
- `CFXCheckBalanceAgainstTransaction`：检查余额是否足够（考虑 sponsor）

#### 网络相关
- `CFXGasPrice`：获取 gas 价格
- `CFXChainId`：获取 chain ID
- `CFXNetVersion`：获取网络版本

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 ECDSA (secp256k1) 和 Keccak256 哈希

### 内部依赖
- 复用 `ethereum` 模块的 RLP 编解码和 RPC 服务层
- eSpace 复用 `ethereum` 的交易类型

### 配置文件
- 无需额外配置文件

---

## 数据模型

### 核心模型（位于 `src/models/`）
- **`EpochNumber`**：Epoch 数字或标签
  - `latestMined`：最新挖出的 epoch
  - `latestState`：最新状态 epoch（默认）
  - `latestConfirmed`：最新确认 epoch
  - `latestCheckpoint`：最新检查点 epoch
  - `latestFinalized`：最新最终确认 epoch
  - `earliest`：创世 epoch

- **`StorageCollateral`**：存储抵押信息
  - `storageCollateralized`：已抵押的存储（Drip）
  - `storageLimit`：存储限制（bytes）
  - `storageReleased`：释放的存储（Drip）

- **`SponsorInfo`**：Sponsor 信息
  - `sponsorForGas`：Gas 赞助者地址
  - `sponsorForCollateral`：存储赞助者地址
  - `sponsorGasBound`：每笔交易最大赞助 gas
  - `sponsorBalanceForGas`：gas 赞助余额
  - `sponsorBalanceForCollateral`：存储赞助余额

- **`BalanceCheck`**：余额检查结果
  - `isBalanceEnough`：余额是否足够
  - `willPayCollateral`：用户是否需要支付存储抵押
  - `willPayTxFee`：用户是否需要支付交易费

### 交易类型
- **Core Space Transaction**：
  - 字段：`nonce`, `gasPrice`, `gas`, `to`, `value`, `storageLimit`, `epochHeight`, `chainId`, `data`, `v`, `r`, `s`
  - 与 Ethereum 差异：增加了 `storageLimit` 和 `epochHeight`

---

## Conflux 特色功能

### 1. Base32 地址（CIP-37）
```
格式：[network-prefix]:[optional-type]:[base32-encoded-payload]
示例：cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p
      cfxtest:aajg4wt2mbmbb44sp6szd783ry0jtad5beynr4zd2u
```

**地址类型**：
- `user` (0x1)：普通用户地址
- `contract` (0x8)：合约地址
- `builtin` (0x0)：内置合约地址
- `null` (0x0...0)：零地址

### 2. Sponsor 机制
合约可以赞助用户的交易费用和存储抵押：

```dart
// 查询 sponsor 信息
final sponsorInfo = await provider.request(
  CFXGetSponsorInfo(address: contractAddr),
);

if (sponsorInfo.hasGasSponsor) {
  print('Gas is sponsored!');
}

// 检查用户是否需要支付费用
final check = await provider.request(
  CFXCheckBalanceAgainstTransaction(
    accountAddress: userAddr,
    contractAddress: contractAddr,
    gasLimit: '0x5208',
    gasPrice: '0x1',
    storageLimit: '0x0',
  ),
);

if (!check.willPayTxFee) {
  print('Transaction fee will be sponsored');
}
```

### 3. Storage Collateral
Conflux 要求为存储数据支付抵押：

```dart
// 估算 gas 和存储抵押
final estimation = await provider.request(
  CFXEstimateGasAndCollateral(
    transaction: {
      'from': fromAddr,
      'to': toAddr,
      'data': '0x...',
    },
  ),
);

print('Gas limit: ${estimation.gasLimit}');
print('Storage collateralized: ${estimation.storageCollateralized}');
```

### 4. Epoch vs Block
- **Core Space** 使用 Epoch Number（树状 DAG 结构）
- **eSpace** 使用 Block Number（链状结构）

---

## 网络配置

### Core Space
```dart
// Mainnet
chainId: 1029 (0x405)
networkId: 1029
rpcUrl: 'https://main.confluxrpc.com'

// Testnet
chainId: 1 (0x1)
networkId: 1
rpcUrl: 'https://test.confluxrpc.com'
```

### eSpace
```dart
// Mainnet
chainId: 1030 (0x406)
networkId: 1030
rpcUrl: 'https://evm.confluxrpc.com'

// Testnet
chainId: 71 (0x47)
networkId: 71
rpcUrl: 'https://evmtestnet.confluxrpc.com'
```

---

## 常见问题 (FAQ)

### Q1: Core Space 和 eSpace 有什么区别？
- **Core Space**：Conflux 原生空间，使用 Base32 地址，有 Sponsor 机制和存储抵押
- **eSpace**：EVM 兼容空间，使用 0x 地址，完全兼容 Ethereum 工具和合约

### Q2: 如何转换 Core Space 和 eSpace 地址？
```dart
// Hex -> Core Space
final coreAddr = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);
print(coreAddr.toBase32()); // cfx:aajg4wt2mbmbb44sp6szd783ry0jtad5bea80xdy7p

// eSpace -> Core Space
final eSpaceAddr = eSpaceAddress('0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb');
final coreAddr2 = eSpaceAddr.toCoreSpaceAddress(1030);
```

### Q3: 如何估算交易费用？
```dart
// 估算 gas 和存储抵押
final estimation = await provider.request(
  CFXEstimateGasAndCollateral(
    transaction: {
      'from': 'cfx:...',
      'to': 'cfx:...',
      'value': '0x1',
    },
  ),
);

// 计算总费用
final gasFee = estimation.gasLimit * gasPrice;
final storageFee = estimation.storageCollateralized * (1e18 / 1024); // 每 KB
final totalFee = gasFee + storageFee;
```

### Q4: 如何使用 Sponsor 机制？
Sponsor 机制由合约设置，用户无需特别操作。只需查询是否有 sponsor：

```dart
final check = await provider.request(
  CFXCheckBalanceAgainstTransaction(
    accountAddress: userAddr,
    contractAddress: contractAddr,
    gasLimit: '0x5208',
    gasPrice: '0x1',
    storageLimit: '0x0',
  ),
);

if (!check.isBalanceEnough && check.willPayTxFee) {
  print('Insufficient balance and no sponsor');
}
```

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/conflux/`

### 推荐测试
```bash
# 运行所有 Conflux 测试
dart test test/conflux/

# 运行特定测试
dart test test/conflux/address_test.dart
```

---

## 相关文件清单

### 核心文件
- `src/address/cfx_address.dart`：Core Space 地址
- `src/address/espace_address.dart`：eSpace 地址
- `src/keys/private_key.dart`：私钥
- `src/keys/public_key.dart`：公钥
- `src/transaction/cfx_transaction.dart`：Core Space 交易
- `src/transaction/cfx_transaction_builder.dart`：交易构建器
- `src/utils/base32_encoder.dart`：Base32 编解码器

### RPC 方法文件（位于 `src/rpc/methods/`）
- `cfx_get_balance.dart`
- `cfx_get_next_nonce.dart`
- `cfx_send_raw_transaction.dart`
- `cfx_get_transaction_by_hash.dart`
- `cfx_get_transaction_receipt.dart`
- `cfx_estimate_gas_and_collateral.dart`
- `cfx_epoch_number.dart`
- `cfx_call.dart`
- `cfx_get_code.dart`
- `cfx_get_sponsor_info.dart`
- `cfx_check_balance_against_transaction.dart`
- `cfx_gas_price.dart`
- `cfx_chain_id.dart`

### 模型文件（位于 `src/models/`）
- `epoch_number.dart`
- `storage_collateral.dart`
- `sponsor_info.dart`

---

## 参考资源

- [Conflux 官方文档](https://doc.confluxnetwork.org/)
- [CIP-37: Base32 Address](https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-37.md)
- [CIP-23: Structured Data Signing](https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-23.md)
- [Helios Wallet (参考实现)](https://github.com/Conflux-Chain/helios)
- [js-conflux-sdk](https://github.com/Conflux-Chain/js-conflux-sdk)

---

## 变更记录 (Changelog)

### 2025-11-01
- ✅ 初始化 Conflux 模块
- ✅ 实现 Base32 地址编解码（CIP-37）
- ✅ 实现 Core Space 和 eSpace 地址支持
- ✅ 实现密钥管理
- ✅ 实现 Core Space 交易类型
- ✅ 实现 15+ 个核心 RPC 方法
- ✅ 实现 Sponsor 机制支持
- ✅ 创建 ConfluxProvider
- ⏳ 待实现：更多 RPC 方法、CIP-23 签名、完整测试覆盖

