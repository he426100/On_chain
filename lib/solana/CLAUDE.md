[根目录](../../CLAUDE.md) > **solana**

# Solana 模块

## 模块职责

提供完整的 Solana 网络支持，包括地址管理、Borsh 序列化、预构建指令、版本化交易、RPC 客户端和 Metaplex 生态集成。

**核心功能**：
- Base58 地址编码
- Borsh 序列化/反序列化
- 20+ 个预构建程序指令（System, SPL Token, Metaplex 等）
- 版本化交易（Versioned Transaction）
- Address Lookup Tables 支持
- 自定义程序 Layout 扩展

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/solana/solana.dart`

### 导出模块
```dart
export 'src/address/sol_address.dart';       // 地址管理
export 'src/instructions/instructions.dart'; // 预构建指令
export 'src/keypair/keypair.dart';           // 密钥对管理
export 'src/models/models.dart';             // 数据模型
export 'src/rpc/rpc.dart';                   // RPC 客户端
export 'src/transaction/transaction.dart';   // 交易处理
export 'src/utils/utils.dart';               // 辅助工具
```

### 快速开始
```dart
import 'package:on_chain/solana/solana.dart';

// 1. 创建地址
final address = SolAddress("9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g");

// 2. 创建 RPC 客户端
final rpc = SolanaRPCClient(
  SolanaHTTPProvider("https://api.mainnet-beta.solana.com"),
);

// 3. 查询余额
final balance = await rpc.request(SolanaRPCGetBalance(address: address.address));

// 4. 创建转账指令
final instruction = SystemTransfer(
  from: fromAddress,
  to: toAddress,
  lamports: BigInt.from(1000000000), // 1 SOL = 1,000,000,000 lamports
);

// 5. 构建交易
final transaction = VersionedTransaction(
  message: VersionedMessage.v0(
    instructions: [instruction],
    recentBlockhash: recentBlockhash,
    feePayer: fromAddress,
  ),
);

// 6. 签名并发送
transaction.sign([keypair]);
await rpc.request(SolanaRPCSendTransaction(transaction));
```

---

## 对外接口

### 地址 (Address)
- **`SolAddress`**：Solana 地址类
  - `SolAddress(String address)`：从 Base58 字符串创建
  - `toAddress()`：转换为字符串
  - `toBytes()`：转换为字节数组

### 密钥对 (Keypair)
- **`SolanaKeyPair`**：密钥对管理
  - `fromPrivateKey(List<int> privateKey)`：从私钥创建
  - `publicKey()`：获取公钥
  - `sign(List<int> message)`：签名

### 预构建指令（位于 `src/instructions/`）

#### System Program（`system/`）
- `SystemTransfer`：SOL 转账
- `SystemCreateAccount`：创建账户
- `SystemAssign`：分配所有者
- `SystemAllocate`：分配空间
- `SystemCreateAccountWithSeed`：用种子创建账户

#### SPL Token Program（`spl_token/`）
- `SPLTokenInitializeMint`：初始化代币铸造
- `SPLTokenInitializeAccount`：初始化代币账户
- `SPLTokenTransfer`：代币转账
- `SPLTokenMintTo`：铸造代币
- `SPLTokenBurn`：销毁代币
- `SPLTokenApprove`：授权
- `SPLTokenRevoke`：撤销授权
- `SPLTokenCloseAccount`：关闭账户
- `SPLTokenFreezeAccount`：冻结账户
- `SPLTokenThawAccount`：解冻账户

#### Associated Token Account（`associated_token_account/`）
- `AssociatedTokenAccountCreate`：创建关联代币账户
- `AssociatedTokenAccountCreateIdempotent`：幂等创建
- `AssociatedTokenAccountRecoverNested`：恢复嵌套账户

#### Address Lookup Table（`address_lockup_table/`）
- `CreateLookupTable`：创建查找表
- `ExtendLookupTable`：扩展查找表
- `FreezeLookupTable`：冻结查找表
- `DeactivateLookupTable`：停用查找表
- `CloseLookupTable`：关闭查找表

#### Stake Program（`stake/`）
- `StakeInitialize`：初始化质押账户
- `StakeDelegate`：委托质押
- `StakeDeactivate`：停用质押
- `StakeWithdraw`：提取质押

#### Compute Budget（`compute_budget/`）
- `SetComputeUnitLimit`：设置计算单元限制
- `SetComputeUnitPrice`：设置计算单元价格
- `RequestHeapFrame`：请求堆栈帧
- `RequestUnits`：请求单元（已弃用）

#### Metaplex 生态

##### Auction House（`metaplex/auction_house/`）
- `AuctionHouseCreate`：创建拍卖行
- `AuctionHouseSell`：挂单出售
- `AuctionHouseBuy`：出价购买
- `AuctionHouseExecuteSale`：执行交易
- `AuctionHouseCancel`：取消订单
- `AuctionHouseWithdraw`：提取资金

##### Token Metadata（`metaplex/token_metadata/`）
- `CreateMetadataAccount`：创建元数据账户
- `UpdateMetadataAccount`：更新元数据
- `CreateMasterEdition`：创建主版本
- `MintNewEditionFromMasterEdition`：从主版本铸造新版本

##### Candy Machine（`metaplex/candy_machine_core/`）
- `CandyMachineInitialize`：初始化糖果机
- `CandyMachineMint`：铸造 NFT
- `CandyMachineUpdate`：更新糖果机

##### Bubblegum（`metaplex/bubblegum/`）
- 压缩 NFT 相关指令

#### 其他程序
- `memo/`：备注程序
- `ed25519/`：Ed25519 签名验证程序
- `secp256k1/`：Secp256k1 签名验证程序
- `name_service/`：域名服务
- `vote/`：投票程序
- `token_lending/`：代币借贷
- `spl_token_swap/`：代币交换

### 自定义程序
- **`ProgramLayout`**：自定义程序 Layout 基类
  - `serialize()`：序列化为字节
  - `deserialize(List<int> bytes)`：从字节反序列化
- **`UnknownProgramLayout`**：未知程序布局处理

### RPC 客户端

#### 常用 RPC 方法（位于 `src/rpc/methods/`）
- `SolanaRPCGetBalance`：获取余额
- `SolanaRPCGetAccountInfo`：获取账户信息
- `SolanaRPCGetTransaction`：获取交易
- `SolanaRPCGetRecentBlockhash`：获取最近区块哈希
- `SolanaRPCGetLatestBlockhash`：获取最新区块哈希
- `SolanaRPCSendTransaction`：发送交易
- `SolanaRPCSimulateTransaction`：模拟交易
- `SolanaRPCGetTokenAccountsByOwner`：查询代币账户
- `SolanaRPCGetProgramAccounts`：查询程序账户

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 Ed25519 和 SHA256/SHA512

### 内部依赖
- 无依赖其他模块（独立模块）

### 配置文件
- 无需额外配置文件

### 许可证
本模块基于 Solana Labs 和 Metaplex 的开源代码构建：
- Solana Program Library: Apache 2.0
- Metaplex Program Library: Apache 2.0
- 许可证位置：`lib/solana/licenses/`

---

## 数据模型

### 交易模型（位于 `src/models/`）
- **`VersionedTransaction`**：版本化交易
  - `message: VersionedMessage`：交易消息
  - `signatures: List<List<int>>`：签名列表
- **`VersionedMessage`**：版本化消息
  - `v0()`：Version 0 消息（支持 Address Lookup Tables）
  - `legacy()`：Legacy 消息
- **`TransactionInstruction`**：交易指令
  - `programId: SolAddress`：程序 ID
  - `keys: List<AccountMeta>`：账户元数据
  - `data: List<int>`：指令数据

### 账户模型
- **`AccountMeta`**：账户元数据
  - `pubkey: SolAddress`：公钥
  - `isSigner: bool`：是否签名者
  - `isWritable: bool`：是否可写

### Borsh 序列化
- **`BorshSerialization`**：Borsh 编解码器
  - `serialize(dynamic data)`：序列化
  - `deserialize<T>(List<int> bytes)`：反序列化

---

## 测试与质量

### 测试目录
无独立测试目录（测试可能位于 `test/solana/` 或集成在示例中）

### 示例代码
- HD 钱包：`example/lib/example/solana/hd_wallet_example.dart`
- Token 操作：
  - `example/lib/example/solana/token_program/create_mint_example.dart`
  - `example/lib/example/solana/token_program/mint_to_example.dart`
  - `example/lib/example/solana/token_program/create_associated_token_account.dart`
- System Program：
  - `example/lib/example/solana/system_program/withdraw_nonce_example.dart`

### 运行测试
```bash
# 当前无独立测试，建议补充
dart test test/solana/
```

---

## 常见问题 (FAQ)

### Q1: 如何创建 SPL Token？
```dart
// 1. 创建 Mint 账户
final mintAccount = SolanaKeyPair.generate();
final createMintIx = SPLTokenInitializeMint(
  mint: mintAccount.publicKey(),
  decimals: 9,
  mintAuthority: authority,
);

// 2. 创建关联代币账户
final ataIx = AssociatedTokenAccountCreate(
  payer: payer,
  associatedToken: ata,
  owner: owner,
  mint: mintAccount.publicKey(),
);

// 3. 铸造代币
final mintToIx = SPLTokenMintTo(
  mint: mintAccount.publicKey(),
  destination: ata,
  authority: authority,
  amount: BigInt.from(1000000000),
);
```

### Q2: 如何使用 Address Lookup Tables 减少交易大小？
```dart
// 1. 创建 Lookup Table
final createLUT = CreateLookupTable(
  authority: authority,
  payer: payer,
  recentSlot: recentSlot,
);

// 2. 扩展 Lookup Table（添加地址）
final extendLUT = ExtendLookupTable(
  lookupTable: lutAddress,
  authority: authority,
  payer: payer,
  newAddresses: [addr1, addr2, addr3],
);

// 3. 在交易中使用
final message = VersionedMessage.v0(
  instructions: [/* ... */],
  addressLookupTableAccounts: [lutAccount],
);
```

### Q3: 如何估算交易费用？
```dart
// 模拟交易获取费用
final simulation = await rpc.request(
  SolanaRPCSimulateTransaction(transaction),
);

final fee = simulation.value.fee; // 单位：lamports
```

### Q4: 如何创建自定义程序指令？
```dart
// 1. 定义 Layout
class MyProgramLayout extends ProgramLayout {
  final int instructionIndex;
  final String data;

  MyProgramLayout({required this.instructionIndex, required this.data});

  @override
  List<int> serialize() {
    return BorshSerialization.serialize({
      "instructionIndex": instructionIndex,
      "data": data,
    });
  }

  static MyProgramLayout deserialize(List<int> bytes) {
    final decoded = BorshSerialization.deserialize(bytes);
    return MyProgramLayout(
      instructionIndex: decoded["instructionIndex"],
      data: decoded["data"],
    );
  }
}

// 2. 创建指令
final instruction = TransactionInstruction(
  programId: myProgramId,
  keys: [
    AccountMeta(pubkey: account1, isSigner: true, isWritable: true),
  ],
  data: MyProgramLayout(instructionIndex: 0, data: "test").serialize(),
);
```

---

## 相关文件清单

### 核心文件
- `src/address/sol_address.dart`：地址实现
- `src/keypair/keypair.dart`：密钥对
- `src/transaction/transaction.dart`：交易处理
- `src/models/models.dart`：数据模型
- `src/rpc/provider/provider.dart`：RPC Provider
- `src/borsh_serialization/core/program_layout.dart`：程序 Layout 基类
- `src/borsh_serialization/core/borsh_serializable.dart`：Borsh 序列化接口

### 预构建指令目录（位于 `src/instructions/`）
- `system/`：系统程序
- `spl_token/`：SPL Token 程序
- `associated_token_account/`：关联代币账户
- `address_lockup_table/`：地址查找表
- `stake/`：质押程序
- `compute_budget/`：计算预算
- `memo/`：备注
- `ed25519/`：Ed25519 验证
- `metaplex/auction_house/`：Metaplex 拍卖行
- `metaplex/token_metadata/`：代币元数据
- `metaplex/candy_machine_core/`：糖果机
- `metaplex/bubblegum/`：压缩 NFT

### RPC 方法文件（位于 `src/rpc/methods/`）
- `get_balance.dart`
- `get_account_info.dart`
- `get_transaction.dart`
- `send_transaction.dart`
- `simulate_transaction.dart`
- `get_token_accounts_by_owner.dart`
- `get_program_accounts.dart`

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Solana 模块文档
- 覆盖 20+ 个预构建程序指令
- 添加 Borsh 序列化、版本化交易、Address Lookup Tables 说明
- 列出 Metaplex 生态集成（Auction House, Token Metadata, Candy Machine）
