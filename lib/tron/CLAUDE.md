[根目录](../../CLAUDE.md) > **tron**

# Tron 模块

## 模块职责

提供完整的 Tron 网络支持，包括地址管理、Protobuf 序列化、交易构建、合约交互和 HTTP 节点通信。

**核心功能**：
- Base58Check 地址编码
- Protobuf 交易序列化
- 20+ 种原生合约类型
- 多签交易支持
- 智能合约调用
- 资源管理（能量、带宽）

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/tron/tron.dart`

### 导出模块
```dart
export 'src/address/tron_address.dart';  // 地址管理
export 'src/keys/keys.dart';             // 密钥管理
export 'src/models/models.dart';         // 数据模型
export 'src/protbuf/encoder.dart';       // Protobuf 编码器
export 'src/provider/provider.dart';     // Provider 层
export 'src/utils/tron_helper.dart';     // 辅助工具
export 'src/exception/exception.dart';   // 异常定义
```

### 快速开始
```dart
import 'package:on_chain/tron/tron.dart';

// 1. 创建地址
final address = TronAddress("TJRyWwFs9wTFGZg3JbrVriFbNfCug5tDeC");

// 2. 创建 HTTP Provider
final provider = TronProvider(TronHTTPProvider(
  url: "https://api.trongrid.io",
));

// 3. 查询账户信息
final account = await provider.request(TronRequestGetAccount(address: address));

// 4. 创建转账交易
final transferContract = TransferContract(
  ownerAddress: fromAddress,
  toAddress: toAddress,
  amount: BigInt.from(1000000), // 1 TRX = 1,000,000 SUN
);

final transaction = Transaction(
  rawData: TransactionRaw(
    contract: [TransactionContract(parameter: transferContract)],
  ),
);
```

---

## 对外接口

### 地址 (Address)
- **`TronAddress`**：Tron 地址类
  - `TronAddress(String address)`：从 Base58Check 字符串创建
  - `toAddress()`：转换为字符串
  - `toBytes()`：转换为字节数组
  - `fromEthAddress(ETHAddress ethAddress)`：从 Ethereum 地址创建

### 密钥 (Keys)
- **`TronPrivateKey`**：私钥管理
  - `publicKey()`：获取公钥
  - `sign(List<int> digest)`：签名
- **`TronPublicKey`**：公钥管理
  - `toAddress()`：生成 Tron 地址

### 合约类型（位于 `src/models/contract/`）

#### 余额相关（`balance/`）
- `TransferContract`：TRX 转账
- `FreezBalanceContract` / `FreezBalanceV2Contract`：冻结余额（能量/带宽）
- `UnfreezBalanceContract` / `UnfreezBalanceV2Contract`：解冻余额
- `WithdrawBalanceContract`：提取奖励
- `DelegateResourceContract`：委托资源
- `UndelegateResourceContract`：取消资源委托

#### 资产相关（`assets_issue_contract/`）
- `AssetIssueContract`：发行资产（TRC10）
- `TransferAssetContract`：转移资产
- `UpdateAssetContract`：更新资产
- `UnfreezAssetsContract`：解冻资产

#### 智能合约相关（`smart_contract/`）
- `CreateSmartContract`：创建智能合约
- `TriggerSmartContract`：调用智能合约
- `UpdateEnergyLimitContract`：更新能量限制
- `UpdateSettingContract`：更新合约设置
- `ClearABIContract`：清除 ABI

#### 账户相关（`account/`）
- `AccountPermissionUpdateContract`：更新账户权限（多签）
- `SetAccountIdContract`：设置账户 ID
- `AccountCreateContract`：创建账户

#### 见证人相关（`witness/`）
- `WitnessCreateContract`：创建见证人
- `UpdateWitnessContract`：更新见证人
- `VoteWitnessContract`：投票见证人

#### 提案相关（`proposal/`）
- `ProposalCreateContract`：创建提案
- `ProposalApproveContract`：批准提案
- `ProposalDeleteContract`：删除提案

#### 交易所相关（`exchange/`）
- `ExchangeCreateContract`：创建交易对
- `ExchangeInjectContract`：注入流动性
- `ExchangeWithdrawContract`：提取流动性
- `ExchangeTransactionContract`：兑换交易

### Provider 方法（位于 `src/provider/methods/`）

#### 账户相关
- `TronRequestGetAccount`：获取账户信息
- `TronRequestCreateAccount`：创建账户
- `TronRequestAccountPermissionUpdate`：更新权限

#### 交易相关
- `TronRequestBroadcastTransaction`：广播交易
- `TronRequestBroadcastHex`：广播十六进制交易
- `TronRequestCreateTransaction`：创建交易
- `TronRequestGetTransactionById`：查询交易

#### 合约相关
- `TronRequestDeployContract`：部署合约
- `TronRequestTriggerSmartContract`：触发智能合约
- `TronRequestEstimateEnergy`：估算能量消耗

#### 资源相关
- `TronRequestDelegateResource`：委托资源
- `TronRequestFreezeBalance`：冻结余额
- `TronRequestUnfreezeBalance`：解冻余额

#### 资产相关
- `TronRequestCreateAssetIssue`：发行资产
- `TronRequestTransferAsset`：转移资产

### Protobuf 序列化
- **`ProtobufEncoder`**：编码器
  - `encode(dynamic data)`：编码为 Protobuf 字节
- **`ProtobufDecoder`**：解码器
  - `decode(List<int> data)`：从字节解码

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 ECDSA (secp256k1) 和 SHA256

### 内部依赖
- 无依赖其他模块（独立模块）

### 配置文件
- 无需额外配置文件

---

## 数据模型

### 核心模型（位于 `src/models/`）

#### 交易模型（`contract/transaction/`）
- **`Transaction`**：完整交易结构
  - `rawData: TransactionRaw`：原始交易数据
  - `signature: List<List<int>>`：签名列表（支持多签）
  - `ret: List<TransactionResult>`：执行结果
- **`TransactionRaw`**：原始交易数据
  - `contract: List<TransactionContract>`：合约列表
  - `timestamp: int`：时间戳
  - `expiration: int`：过期时间
  - `feeLimit: BigInt`：费用上限
- **`TransactionContract`**：交易合约
  - `type: ContractType`：合约类型
  - `parameter: TronBaseContract`：合约参数

#### 区块模型（`block/`）
- **`Block`**：区块数据
- **`BlockHeader`**：区块头

#### 账户模型
- **`Account`**：账户信息
- **`Permission`**：权限结构（用于多签）

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/tron/`

### 测试文件
- `sign_test.dart`：签名测试
- `serialization_test.dart`：Protobuf 序列化测试
- `key_address_test.dart`：密钥和地址测试
- `json_buff_serialization_test.dart`：JSON 与 Protobuf 互转测试

### 运行测试
```bash
dart test test/tron/
```

### 示例代码
- HD 钱包：`example/lib/example/tron/hd_wallet_example.dart`
- 转账：`example/lib/example/tron/transactions/transfer_trx_example.dart`
- 多签：`example/lib/example/tron/transactions/multi_sig_transaction_example.dart`
- 权限更新：`example/lib/example/tron/transactions/update_account_permission_example.dart`
- HTTP 节点：`example/lib/example/tron/intract_with_http_node/http_node_example.dart`

---

## 常见问题 (FAQ)

### Q1: 如何计算交易费用？
```dart
// Tron 有两种资源：能量（Energy）和带宽（Bandwidth）
// 费用 = (能量消耗 * 能量单价) + (带宽消耗 * 带宽单价)

// 手动设置 feeLimit
final transaction = Transaction(
  rawData: TransactionRaw(
    feeLimit: BigInt.from(1000000), // 1 TRX
    // ...
  ),
);

// 或使用 estimateEnergy 估算
final energy = await provider.request(
  TronRequestEstimateEnergy(/* ... */),
);
```

### Q2: 如何实现多签交易？
```dart
// 1. 更新账户权限
final permissionUpdate = AccountPermissionUpdateContract(
  ownerAddress: ownerAddr,
  owner: Permission(
    type: PermissionType.owner,
    threshold: 2, // 需要 2 个签名
    keys: [
      Key(address: addr1, weight: 1),
      Key(address: addr2, weight: 1),
    ],
  ),
);

// 2. 签名交易（多个私钥）
transaction.sign(privateKey1);
transaction.sign(privateKey2);
```

### Q3: 如何调用智能合约（TRC20 转账）？
```dart
// 构建 TRC20 transfer 函数调用
final function = AbiFunctionFragment.fromJson({
  "name": "transfer",
  "type": "function",
  "inputs": [
    {"name": "to", "type": "address"},
    {"name": "value", "type": "uint256"},
  ],
});

final params = [toAddress, amount];
final encodedData = function.encode(params);

final triggerContract = TriggerSmartContract(
  ownerAddress: fromAddress,
  contractAddress: trc20ContractAddress,
  data: encodedData,
);
```

### Q4: Tron 地址与 Ethereum 地址如何转换？
```dart
// Ethereum -> Tron
final ethAddress = ETHAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
final tronAddress = TronAddress.fromEthAddress(ethAddress);
// 结果：TJRyWwFs9wTFGZg3JbrVriFbNfCug5tDeC

// Tron -> Ethereum
final tronAddr = TronAddress("TJRyWwFs9wTFGZg3JbrVriFbNfCug5tDeC");
final ethAddr = tronAddr.toEthAddress();
```

---

## 相关文件清单

### 核心文件
- `src/address/tron_address.dart`：地址实现
- `src/keys/private_key.dart`：私钥
- `src/keys/public_key.dart`：公钥
- `src/protbuf/encoder.dart`：Protobuf 编码器
- `src/protbuf/decoder.dart`：Protobuf 解码器
- `src/provider/provider/provider.dart`：Provider 实现
- `src/provider/core/request.dart`：请求基类
- `src/exception/exception.dart`：异常定义

### 合约文件（位于 `src/models/contract/`）
- `transaction/transaction.dart`：交易结构
- `base_contract/base_contract.dart`：合约基类
- `balance/transfer_contract.dart`：转账合约
- `smart_contract/trigger_smart_contract.dart`：智能合约触发
- `account/account_permission_update_contract.dart`：权限更新
- `witness/vote_witness_contract.dart`：投票合约
- `assets_issue_contract/asset_issue_contract.dart`：资产发行

### Provider 方法文件（位于 `src/provider/methods/`）
- `broadcast_transaction.dart`
- `create_transaction.dart`
- `deploy_contract.dart`
- `estimate_energy.dart`
- `delegate_resource.dart`
- `account_permission_update.dart`
- `create_asset_issue.dart`
- `get_transaction_by_id.dart`

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Tron 模块文档
- 覆盖地址、密钥、Protobuf、20+ 种合约类型、Provider 方法
- 添加多签、智能合约调用、地址转换等常见问题
