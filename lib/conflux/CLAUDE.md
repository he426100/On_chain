# Conflux Module - Technical Documentation

## 模块概述

Conflux 模块为 Dart/Flutter 应用提供完整的 Conflux 区块链支持，包括 Core Space 和 eSpace 两个网络空间。

**模块职责**：
- Core Space Base32 地址（CIP-37）的编解码与验证
- eSpace 0x 地址（EVM 兼容）的支持
- 私钥/公钥管理与地址派生
- Core Space 交易构建、签名与序列化
- RLP 编解码（复用 Ethereum 实现）
- Conflux RPC 方法（Core Space + eSpace）
- Epoch 数字、Storage Collateral、Sponsor 机制等 Conflux 特有功能

**设计理念**：
- 遵循项目现有架构（参考 Ethereum/Solana/Tron 模块）
- 复用成熟组件（如 Ethereum 的 RLP、EVM 地址编码）
- 清晰分离 Core Space 和 eSpace 逻辑
- 完整的测试覆盖（57+ 单元测试）

---

## 入口与启动

### 模块位置
`/home/mrpzx/git/flutter/wallet/On_chain/lib/conflux/`

### 主入口文件
`lib/conflux/conflux.dart`

### 导入方式
```dart
import 'package:on_chain/conflux/conflux.dart';
```

### 快速开始示例
```dart
// 1. 创建私钥
final privateKey = CFXPrivateKey.random();

// 2. 派生地址
final publicKey = privateKey.publicKey();
final coreAddr = publicKey.toAddress(1029); // Core Space mainnet
final eSpaceAddr = publicKey.toESpaceAddress(); // eSpace

// 3. 构建并签名交易
final txBuilder = CFXTransactionBuilder.transfer(
  from: coreAddr,
  to: recipientAddr,
  value: BigInt.from(1000000000000000000), // 1 CFX
  chainId: BigInt.from(1029),
);

txBuilder.setNonce(BigInt.zero);
txBuilder.setGasPrice(BigInt.from(1000000000));
txBuilder.setGas(BigInt.from(21000));
txBuilder.setStorageLimit(BigInt.zero);
txBuilder.setEpochHeight(BigInt.from(12345678));

final signedTx = txBuilder.sign(privateKey);

// 4. 序列化交易
final serialized = signedTx.serialize();
final txHash = signedTx.getTransactionHashHex();
```

---

## 对外接口 (Public API)

### 地址管理 (`src/address/`)

#### CFXAddress
Core Space Base32 地址（CIP-37 标准）

```dart
// 从 Base32 创建
final addr = CFXAddress('cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg');

// 从 Hex 创建
final addr = CFXAddress.fromHex('0x106d49f8505410eb4e671d51f7d96d2c87807b09', 1029);

// 获取 Base32 格式
final base32 = addr.toBase32(); // cfx:...
final verbose = addr.toBase32(verbose: true); // cfx:type.user:...

// 获取 Hex 格式
final hex = addr.toHex(); // 0x106d...

// 地址属性
final networkId = addr.networkId; // 1029 (mainnet), 1 (testnet)
final type = addr.addressType; // user, contract, builtin, nullAddress
```

#### ESpaceAddress
eSpace 0x 地址（EVM 兼容）

```dart
// 从 0x 地址创建
final addr = ESpaceAddress('0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed');

// 转换为 Core Space 地址
final coreAddr = addr.toCoreSpaceAddress(1029);

// 获取 Hex 格式
final hex = addr.toHex(); // 0x5aAeb6...
```

### 密钥管理 (`src/keys/`)

#### CFXPrivateKey
```dart
// 创建私钥
final privateKey = CFXPrivateKey.random();
final privateKey = CFXPrivateKey('0x...');
final privateKey = CFXPrivateKey.fromBytes(bytes);

// 派生公钥
final publicKey = privateKey.publicKey();

// 签名
final signature = privateKey.sign(message, hashMessage: true);
final personalSig = privateKey.signPersonalMessage(message);

// 序列化
final hex = privateKey.toHex();
final bytes = privateKey.toBytes();
```

#### CFXPublicKey
```dart
// 创建公钥
final publicKey = CFXPublicKey.fromBytes(bytes);
final publicKey = CFXPublicKey.fromHex(hex);

// 派生地址
final coreAddr = publicKey.toAddress(1029); // Core Space
final eSpaceAddr = publicKey.toESpaceAddress(); // eSpace

// 获取密钥格式
final compressed = publicKey.toCompressedBytes(); // 33 bytes
final uncompressed = publicKey.toUncompressedBytes(); // 65 bytes
```

### 交易管理 (`src/transaction/`)

#### CFXTransaction
Core Space 交易对象

```dart
// 创建交易
final tx = CFXTransaction(
  nonce: BigInt.zero,
  gasPrice: BigInt.from(1000000000),
  gas: BigInt.from(21000),
  to: recipientAddr,
  value: BigInt.from(1000000000000000000),
  storageLimit: BigInt.zero,
  epochHeight: BigInt.from(12345678),
  chainId: BigInt.from(1029),
  data: [],
);

// 序列化
final encoded = tx.encodeForSigning(); // 签名前编码
final serialized = tx.serialize(); // 完整序列化（需签名）

// 获取交易哈希
final hash = tx.getTransactionHash(); // List<int>
final hashHex = tx.getTransactionHashHex(); // String

// 从 RLP 解码
final tx = CFXTransaction.fromRlp(rlpBytes);
```

#### CFXTransactionBuilder
交易构建器（Builder 模式）

```dart
// 转账交易
final builder = CFXTransactionBuilder.transfer(
  from: senderAddr,
  to: recipientAddr,
  value: BigInt.from(1000000000000000000),
  chainId: BigInt.from(1029),
);

// 合约调用交易
final builder = CFXTransactionBuilder.contractCall(
  from: senderAddr,
  contract: contractAddr,
  data: encodedData,
  chainId: BigInt.from(1029),
);

// 设置参数
builder.setNonce(nonce);
builder.setGasPrice(gasPrice);
builder.setGas(gas);
builder.setStorageLimit(storageLimit);
builder.setEpochHeight(epochHeight);

// 构建并签名
final tx = builder.build(); // 构建未签名交易
final signedTx = builder.sign(privateKey); // 签名并返回
```

### RPC 通信 (`src/rpc/`)

#### ConfluxProvider
RPC 提供者（支持 Core Space 和 eSpace）

```dart
// 创建 Provider
final service = HTTPService(url: 'https://main.confluxrpc.com');
final provider = ConfluxProvider(service);

// 发送 RPC 请求
final balance = await provider.request(
  CFXGetBalance(
    address: addr.toBase32(),
    epochNumber: CFXEpochNumber.latestState(),
  ),
);
```

#### 核心 RPC 方法（已实现）
- **账户相关**：`CFXGetBalance`, `CFXGetNextNonce`
- **交易相关**：`CFXSendRawTransaction`, `CFXGetTransactionByHash`, `CFXGetTransactionReceipt`, `CFXEstimateGasAndCollateral`
- **区块相关**：`CFXEpochNumber`
- **合约相关**：`CFXCall`, `CFXGetCode`
- **Sponsor 机制**：`CFXGetSponsorInfo`, `CFXCheckBalanceAgainstTransaction`
- **网络相关**：`CFXGasPrice`, `CFXChainId`

### 数据模型 (`src/models/`)

#### CFXEpochNumber
Conflux 特有的 Epoch 概念

```dart
// 创建 Epoch
final epoch = CFXEpochNumber.fromNumber(12345678);
final epoch = CFXEpochNumber.latestState();
final epoch = CFXEpochNumber.latestConfirmed();
final epoch = CFXEpochNumber.latestCheckpoint();

// 转换为字符串（用于 RPC）
final str = epoch.toString(); // "0xbc614e" or "latest_state"
```

#### CFXSponsorInfo
Sponsor 赞助信息

```dart
final sponsorInfo = CFXSponsorInfo.fromJson(json);

// 访问赞助信息
final gasBalance = sponsorInfo.sponsorBalanceForGas;
final collateralBalance = sponsorInfo.sponsorBalanceForCollateral;
final gasBound = sponsorInfo.sponsorGasBound;
```

#### CFXStorageCollateral
Storage 存储抵押信息

```dart
final collateral = CFXStorageCollateral.fromJson(json);

// 访问抵押信息
final total = collateral.totalStorageCollateral;
final sponsored = collateral.totalStorageCoveredBySponsor;
final points = collateral.totalStoragePoint;
```

### 工具类 (`src/utils/`)

#### Base32Encoder
Base32 编解码器（CIP-37 标准）

```dart
// 编码
final encoded = Base32Encoder.encode(
  hexAddress: '0x106d...',
  networkId: 1029,
  verbose: false,
);

// 解码
final decoded = Base32Encoder.decode('cfx:aarc...');
// 返回: {hexAddress, networkId, addressType}

// 验证
final isValid = Base32Encoder.validate('cfx:aarc...');
```

---

## 关键依赖

### 内部依赖
- `ethereum` 模块：复用 RLP 编解码、EVM 地址编码、RPC 基础架构
- `blockchain_utils`：密码学原语（secp256k1、Keccak256）、编码工具

### 外部依赖
- `blockchain_utils: ^4.0.0`：核心区块链工具库

### 配置要求
- Dart SDK: >=3.0.0
- Flutter: >=3.10.0

---

## 数据模型详解

### 地址模型
- **CFXAddress**：Core Space Base32 地址
  - 格式：`cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg`
  - 包含：网络前缀（cfx/cfxtest）、可选类型、Base32 编码的地址、校验和
  - 地址类型：
    - `user` (0x1)：用户地址
    - `contract` (0x8)：合约地址
    - `builtin` (0x0, 非零)：内置地址
    - `nullAddress` (0x0, 全零)：空地址

- **ESpaceAddress**：eSpace 0x 地址
  - 格式：`0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed`
  - 与 Ethereum 地址格式相同（EVM 兼容）

### 交易模型
- **CFXTransaction**：Core Space 交易
  - 标准字段：nonce, gasPrice, gas, to, value, data
  - Conflux 特有字段：
    - `storageLimit`: 存储抵押上限
    - `epochHeight`: Epoch 高度（类似区块高度）
    - `chainId`: 链 ID（1029=主网，1=测试网）

### 网络参数
```dart
// Core Space Mainnet
chainId: 1029
networkId: 1029
rpc: https://main.confluxrpc.com

// Core Space Testnet
chainId: 1
networkId: 1
rpc: https://test.confluxrpc.com

// eSpace Mainnet
chainId: 1030
networkId: 1030
rpc: https://evm.confluxrpc.com

// eSpace Testnet
chainId: 71
networkId: 71
rpc: https://evmtestnet.confluxrpc.com
```

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/conflux/`

### 测试文件
- `address_test.dart`：地址编解码、验证、网络 ID、地址类型（25 测试）
- `keys_test.dart`：密钥生成、派生、签名、HD 钱包（17 测试）
- `transaction_test.dart`：交易构建、签名、序列化、RLP 编解码（10 测试）
- `simple_test.dart`：基础冒烟测试（5 测试）

### 测试覆盖率
- **总计**：57+ 单元测试
- **覆盖率**：>80%（核心功能 100%）
- **状态**：All tests passed! ✅

### 运行测试
```bash
# 运行所有 Conflux 测试
dart test test/conflux/

# 运行特定测试
dart test test/conflux/address_test.dart
dart test test/conflux/keys_test.dart
dart test test/conflux/transaction_test.dart
```

### 代码质量
```bash
# 静态分析
flutter analyze
# 结果：No issues found! ✅

# 格式化
dart format lib/conflux/

# 测试
dart test test/conflux/
```

---

## 常见问题 (FAQ)

### Q1: 如何区分 Core Space 和 eSpace？
**A**: Core Space 使用 Base32 地址（cfx:...），eSpace 使用 0x 地址（类似 Ethereum）。

```dart
// Core Space
final coreAddr = CFXAddress('cfx:aarc...');
final coreAddr = publicKey.toAddress(1029);

// eSpace
final eSpaceAddr = ESpaceAddress('0x5aAeb...');
final eSpaceAddr = publicKey.toESpaceAddress();
```

### Q2: 为什么交易需要 storageLimit？
**A**: Conflux Core Space 使用 Storage Collateral 机制。合约调用需要抵押存储空间，简单转账设为 0。

```dart
// 简单转账
builder.setStorageLimit(BigInt.zero);

// 合约调用
builder.setStorageLimit(BigInt.from(1024)); // 根据合约需求设置
```

### Q3: Epoch 与 Block 有什么区别？
**A**: Conflux Core Space 使用树状区块结构，Epoch 是树的高度。eSpace 使用传统的链状区块。

```dart
// Core Space 使用 Epoch
final epoch = CFXEpochNumber.latestState();

// eSpace 使用 Block Number（复用 Ethereum）
```

### Q4: 如何从助记词派生 Conflux 地址？
**A**: Conflux 使用 Ethereum 的 BIP44 路径（coin type 60）。

```dart
final mnemonic = Bip39MnemonicGenerator().fromWordsNumber(Bip39WordsNum.wordsNum24);
final seed = Bip39SeedGenerator(mnemonic).generate();
final wallet = Bip44.fromSeed(seed, Bip44Coins.ethereum); // 使用 Ethereum coin type
final defaultPath = wallet.deriveDefaultPath;

final privateKey = CFXPrivateKey.fromBytes(defaultPath.privateKey.raw);
final coreAddr = privateKey.publicKey().toAddress(1029); // Core Space
final eSpaceAddr = privateKey.publicKey().toESpaceAddress(); // eSpace
```

### Q5: Base32 地址的 verbose 模式是什么？
**A**: Verbose 模式在地址中显式包含地址类型（type.user, type.contract等）。

```dart
final addr = CFXAddress.fromHex('0x106d...', 1029);

// 标准格式
final standard = addr.toBase32(); 
// cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg

// Verbose 格式
final verbose = addr.toBase32(verbose: true);
// cfx:type.user:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg
```

---

## 架构设计

### 模块结构
```
lib/conflux/
├── conflux.dart              # 主入口
├── CLAUDE.md                 # 本文档
├── README.md                 # 用户文档
└── src/
    ├── address/              # 地址管理
    │   ├── cfx_address.dart  # Core Space Base32 地址
    │   └── espace_address.dart # eSpace 0x 地址
    ├── keys/                 # 密钥管理
    │   ├── private_key.dart
    │   └── public_key.dart
    ├── transaction/          # 交易管理
    │   ├── cfx_transaction.dart
    │   └── cfx_transaction_builder.dart
    ├── models/               # 数据模型
    │   ├── epoch_number.dart
    │   ├── sponsor_info.dart
    │   └── storage_collateral.dart
    ├── rpc/                  # RPC 通信
    │   ├── methods/          # RPC 方法
    │   └── provider/         # RPC 提供者
    ├── utils/                # 工具类
    │   └── base32_encoder.dart
    ├── rlp/                  # RLP 编解码（复用 ethereum）
    └── exception/            # 异常定义
```

### 设计模式
- **Builder 模式**：`CFXTransactionBuilder` 用于构建复杂交易
- **Factory 模式**：地址、密钥的多种创建方式
- **复用优先**：RLP、密码学等复用 `ethereum` 模块
- **类型安全**：强类型化的地址、交易、Epoch 等

---

## 相关文件清单

### 核心实现
- `lib/conflux/conflux.dart` - 主入口文件
- `lib/conflux/src/address/cfx_address.dart` - Core Space 地址
- `lib/conflux/src/address/espace_address.dart` - eSpace 地址
- `lib/conflux/src/keys/private_key.dart` - 私钥管理
- `lib/conflux/src/keys/public_key.dart` - 公钥管理
- `lib/conflux/src/transaction/cfx_transaction.dart` - 交易对象
- `lib/conflux/src/transaction/cfx_transaction_builder.dart` - 交易构建器
- `lib/conflux/src/utils/base32_encoder.dart` - Base32 编解码
- `lib/conflux/src/rpc/provider/provider.dart` - RPC 提供者

### 测试文件
- `test/conflux/address_test.dart` - 地址测试（25 tests）
- `test/conflux/keys_test.dart` - 密钥测试（17 tests）
- `test/conflux/transaction_test.dart` - 交易测试（10 tests）
- `test/conflux/simple_test.dart` - 基础测试（5 tests）

### 示例文件
- `example/lib/example/conflux/hd_wallet_example.dart` - HD 钱包示例
- `example/lib/example/conflux/address_example.dart` - 地址操作示例
- `example/lib/example/conflux/core_space_transfer_example.dart` - 转账示例

---

## 参考资源

### 官方文档
- [Conflux 官方文档](https://doc.confluxnetwork.org/)
- [CIP-37: Base32 地址标准](https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-37.md)
- [CIP-23: 结构化签名](https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-23.md)

### SDK 参考
- [js-conflux-sdk](https://github.com/Conflux-Chain/js-conflux-sdk) - JavaScript SDK
- [rust-conflux-sdk](https://github.com/Conflux-Chain/rust-conflux-sdk) - Rust SDK

### 代码参考
- `/home/mrpzx/git/wallet/helios` - 参考实现（JavaScript）
- `lib/ethereum/` - Ethereum 模块（RLP、RPC 架构）
- `lib/solana/` - Solana 模块（模块结构参考）

---

## 版本历史

### v1.0.0 (当前版本)
- ✅ 完整的 Core Space 支持
- ✅ eSpace 基础支持
- ✅ Base32 地址编解码（CIP-37）
- ✅ 密钥管理与地址派生
- ✅ Core Space 交易构建与签名
- ✅ 14+ Core Space RPC 方法
- ✅ 57+ 单元测试
- ✅ 完整的技术文档

### 未来计划
- [ ] CIP-23 结构化签名（类似 EIP-712）
- [ ] eSpace 完整交易支持（EIP-1559）
- [ ] 更多 RPC 方法（区块查询、日志过滤等）
- [ ] 智能合约 ABI 编解码
- [ ] Ledger/Trezor 硬件钱包支持

---

## 维护者

本模块由 On_chain 项目团队维护，参考 Helios 项目实现，严格遵循项目编码规范。

**贡献指南**：
1. 遵循现有代码风格（`dart format`）
2. 通过静态分析（`flutter analyze`）
3. 编写单元测试（覆盖率 >80%）
4. 更新文档（CLAUDE.md, README.md）

**联系方式**：
- 项目仓库：/home/mrpzx/git/flutter/wallet/On_chain
- 参考项目：/home/mrpzx/git/wallet/helios
