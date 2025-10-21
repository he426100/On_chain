[根目录](../../CLAUDE.md) > **filecoin**

# Filecoin 模块

## 模块职责

提供完整的 Filecoin 网络支持，包括多类型地址系统、CBOR 序列化、交易签名、RPC 通信和 Ethereum 兼容层。

**核心功能**：
- 多类型地址：f0 (ID), f1 (SECP256K1), f4 (Delegated/Ethereum-compatible)
- CBOR 交易序列化
- SECP256K1 和 BLS 签名
- Chain、Eth、Multisig 三类 RPC 方法
- 地址转换工具（Filecoin ↔ Ethereum）

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/filecoin/filecoin.dart`

### 导出模块
```dart
// Network
export 'src/network/filecoin_network.dart';

// Address
export 'src/address/fil_address.dart';
export 'src/address/address_converter.dart';

// Transaction
export 'src/transaction/fil_transaction.dart';

// Signer
export 'src/signer/fil_signer.dart';

// Wallet
export 'src/wallet/fil_wallet.dart';

// Provider
export 'src/provider/provider.dart';
export 'src/provider/core/request.dart';
export 'src/provider/service/service.dart';
export 'src/provider/methods/methods.dart';
export 'src/provider/methods/chain_methods.dart';
export 'src/provider/methods/eth_methods.dart';
export 'src/provider/methods/multisig_methods.dart';
export 'src/provider/models/models.dart';

// Message
export 'src/message/fil_message.dart';

// Token
export 'src/token/fil_token.dart';

// Utils
export 'src/utils/fil_utils.dart';

// Chains
export 'src/chains/fil_chains.dart';

// Contracts
export 'src/contracts/fil_forwarder.dart';
```

### 快速开始
```dart
import 'package:on_chain/filecoin/filecoin.dart';

// 1. 创建地址（f1 类型）
final address = FilAddress("f1abjxfbp274xpdqcpuaykwkfb43omjotacm2p3za");

// 2. 创建 RPC 客户端
final provider = FilecoinProvider(
  FilecoinHTTPProvider("https://api.node.glif.io"),
);

// 3. 查询余额
final balance = await provider.request(
  ChainGetBalance(address: address.toString()),
);

// 4. 创建交易消息
final message = FilMessage(
  to: toAddress,
  from: fromAddress,
  value: BigInt.from(1000000000000000000), // 1 FIL
  gasLimit: BigInt.from(1000000),
  gasFeeCap: BigInt.from(100000),
  gasPremium: BigInt.from(50000),
  nonce: nonce,
);

// 5. 签名
final signer = FilSigner(privateKey);
final signedMessage = signer.sign(message);

// 6. 发送交易
await provider.request(
  MpoolPush(signedMessage: signedMessage),
);
```

---

## 对外接口

### 地址 (Address)

#### 地址类型
- **f0 (ID Address)**：Actor ID 地址，例如 `f0123456`
- **f1 (SECP256K1 Address)**：SECP256K1 公钥哈希，例如 `f1abjxfbp274xpdqcpuaykwkfb43omjotacm2p3za`
- **f3 (BLS Address)**：BLS 公钥，例如 `f3vvmn62lofvhjd2ugzca6sof2j2ubwok6cj4xxbfzz4yuxfkgobpihhd2thlanmsh3w2ptld2gqkn2jvlss4a`
- **f4 (Delegated Address)**：委托地址（Ethereum 兼容），例如 `f410f...`

#### FilAddress API
- `FilAddress(String address)`：从字符串创建
- `FilAddress.fromBytes(List<int> bytes, int protocol)`：从字节创建
- `toString()`：转换为字符串
- `toBytes()`：转换为字节数组
- `protocol`：获取协议类型（0/1/3/4）

#### 地址转换
- **`FilAddressConverter`**：地址转换器
  - `ethToFil(ETHAddress ethAddress)`：Ethereum 地址 → Filecoin f410 地址
  - `filToEth(FilAddress filAddress)`：Filecoin f410 地址 → Ethereum 地址

### 签名 (Signer)
- **`FilSigner`**：交易签名器
  - `FilSigner(FilPrivateKey privateKey)`：创建签名器
  - `sign(FilMessage message)`：签名消息
  - `address()`：获取签名者地址

### 钱包 (Wallet)
- **`FilWallet`**：HD 钱包
  - `fromMnemonic(String mnemonic)`：从助记词创建
  - `deriveKey(int index)`：派生子密钥
  - `address(int index)`：获取地址

### 交易 (Transaction)
- **`FilMessage`**：交易消息
  - `to: FilAddress`：接收地址
  - `from: FilAddress`：发送地址
  - `value: BigInt`：转账金额（attoFIL）
  - `gasLimit: BigInt`：Gas 限制
  - `gasFeeCap: BigInt`：Gas 费用上限
  - `gasPremium: BigInt`：Gas 优先费
  - `nonce: int`：交易序号
  - `method: int`：方法编号（默认 0 为转账）
  - `params: List<int>`：方法参数（CBOR 编码）

- **`FilTransaction`**：已签名交易
  - `message: FilMessage`：原始消息
  - `signature: FilSignature`：签名

### RPC Provider

#### Chain 方法（`src/provider/methods/chain_methods.dart`）
- `ChainGetBalance`：获取余额
- `ChainGetMessage`：获取消息
- `ChainGetBlockMessages`：获取区块消息
- `ChainGetNode`：获取节点信息
- `ChainHead`：获取链头
- `ChainReadObj`：读取对象
- `ChainHasObj`：检查对象是否存在
- `ChainGetTipSet`：获取 tipset
- `ChainGetPath`：获取路径

#### Eth 方法（`src/provider/methods/eth_methods.dart`）
Ethereum 兼容层，用于与 FEVM (Filecoin EVM) 交互：
- `EthGetBalance`：获取余额（Ethereum 格式）
- `EthGetTransactionCount`：获取交易计数
- `EthCall`：调用合约（只读）
- `EthEstimateGas`：估算 Gas
- `EthSendRawTransaction`：发送原始交易
- `EthGetTransactionReceipt`：获取交易回执
- `EthGetCode`：获取合约代码
- `EthGetBlockByNumber`：获取区块

#### Multisig 方法（`src/provider/methods/multisig_methods.dart`）
多签钱包操作：
- `MsigCreate`：创建多签钱包
- `MsigPropose`：提议交易
- `MsigApprove`：批准交易
- `MsigCancel`：取消交易
- `MsigAddSigner`：添加签名者
- `MsigRemoveSigner`：移除签名者
- `MsigSwapSigner`：替换签名者
- `MsigChangeNumApprovalsThreshold`：修改批准阈值

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 SECP256K1、BLS 和 Blake2b

### 内部依赖
- 无依赖其他模块（独立模块）

### 配置文件
- 无需额外配置文件

---

## 数据模型

### 地址模型（位于 `src/address/`）
- **`FilAddress`**：通用地址类
- **地址协议**：
  - `0`：ID Address
  - `1`：SECP256K1 Address
  - `3`：BLS Address
  - `4`：Delegated Address (Ethereum-compatible)

### 网络模型（位于 `src/network/`）
- **`FilecoinNetwork`**：网络定义
  - `mainnet`：主网
  - `calibration`：校准网（测试网）

### 代币模型（位于 `src/token/`）
- **`FilToken`**：FIL 代币单位转换
  - `1 FIL = 10^18 attoFIL`

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/filecoin/`

### 测试文件（最完整的测试覆盖）
- `address_test.dart`：地址创建与验证
- `transaction_test.dart`：交易序列化与签名
- `signer_test.dart`：签名器测试
- `multisig_test.dart`：多签功能测试
- `wallet_core_compatibility_test.dart`：钱包核心兼容性
- `mnemonic_address_test.dart`：助记词与地址测试
- `filecoin_testnet_test.dart`：测试网测试
- `address_validation_test.dart`：地址验证
- `address_converter_test.dart`：地址转换测试
- `filecoin_enhanced_test.dart`：增强功能测试

### 运行测试
```bash
# 运行所有 Filecoin 测试
dart test test/filecoin/

# 运行特定测试
dart test test/filecoin/multisig_test.dart
```

### 示例代码
- 基本操作：`example/lib/example/filecoin/filecoin_example.dart`
- 测试网：`example/lib/example/filecoin/testnet_example.dart`

---

## 常见问题 (FAQ)

### Q1: 如何在 f1 和 f410 地址之间转换？
```dart
// Ethereum 地址 -> Filecoin f410 地址
final ethAddress = ETHAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
final f410Address = FilAddressConverter.ethToFil(ethAddress);
// 结果：f410f...

// Filecoin f410 地址 -> Ethereum 地址
final filAddress = FilAddress("f410f...");
final ethAddr = FilAddressConverter.filToEth(filAddress);
```

### Q2: 如何创建多签钱包？
```dart
// 1. 创建多签钱包
final createMsig = await provider.request(
  MsigCreate(
    signers: [signer1Addr, signer2Addr, signer3Addr],
    threshold: 2, // 需要 2 个签名
    value: BigInt.zero,
    duration: 0,
  ),
);

final msigAddress = createMsig.robustAddress;

// 2. 提议交易
final propose = await provider.request(
  MsigPropose(
    multisigAddress: msigAddress,
    to: recipientAddress,
    value: amount,
    from: proposerAddress,
  ),
);

// 3. 批准交易
await provider.request(
  MsigApprove(
    multisigAddress: msigAddress,
    txnId: propose.txnId,
    proposer: proposerAddress,
    from: approverAddress,
  ),
);
```

### Q3: 如何使用 FEVM 调用 Ethereum 智能合约？
```dart
// 使用 Eth RPC 方法（Ethereum 兼容层）
final result = await provider.request(
  EthCall(
    params: EthCallParams(
      to: contractAddress, // f410 地址
      data: encodedFunctionCall,
    ),
    blockNumber: "latest",
  ),
);
```

### Q4: 如何从助记词派生 Filecoin 地址？
```dart
// 使用 HD 钱包
final wallet = FilWallet.fromMnemonic(
  "your twelve word mnemonic phrase here",
);

// 派生地址（BIP44 路径：m/44'/461'/0'/0/index）
final address0 = wallet.address(0); // f1...
final address1 = wallet.address(1); // f1...
```

---

## 相关文件清单

### 核心文件
- `src/address/fil_address.dart`：地址实现
- `src/address/address_converter.dart`：地址转换工具
- `src/signer/fil_signer.dart`：签名器
- `src/wallet/fil_wallet.dart`：HD 钱包
- `src/transaction/fil_transaction.dart`：交易处理
- `src/message/fil_message.dart`：消息结构
- `src/provider/provider.dart`：Provider 实现
- `src/network/filecoin_network.dart`：网络定义
- `src/token/fil_token.dart`：代币工具
- `src/utils/fil_utils.dart`：辅助工具

### Provider 方法文件
- `src/provider/methods/chain_methods.dart`：Chain RPC 方法
- `src/provider/methods/eth_methods.dart`：Eth RPC 方法
- `src/provider/methods/multisig_methods.dart`：Multisig RPC 方法
- `src/provider/models/models.dart`：RPC 数据模型

### 合约文件
- `src/contracts/fil_forwarder.dart`：转发器合约
- `src/chains/fil_chains.dart`：链定义

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Filecoin 模块文档
- 覆盖多类型地址系统、CBOR 序列化、三类 RPC 方法
- 添加地址转换、多签、FEVM 交互等常见问题
- 记录完整的测试覆盖（10 个测试文件）
