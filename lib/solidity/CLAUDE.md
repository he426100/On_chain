[根目录](../../CLAUDE.md) > **solidity**

# Solidity 模块

## 模块职责

提供 Solidity ABI 编解码、智能合约交互和 EIP712 结构化数据签名功能，为 EVM 兼容链（Ethereum、Tron、Filecoin FEVM 等）提供统一的合约接口层。

**核心功能**：
- Solidity ABI 编码/解码（支持所有 ABI 类型）
- 合约 ABI 解析与函数调用
- Fragment 模式的合约交互
- EIP712 结构化数据签名（v1、v3、v4）
- 类型安全的参数编码

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/solidity/solidity.dart`

### 导出模块
```dart
export 'abi/abi.dart';                 // ABI 编解码
export 'contract/contract_abi.dart';   // 合约 ABI 交互
export 'contract/fragments.dart';      // Fragment 定义
```

### 快速开始
```dart
import 'package:on_chain/solidity/solidity.dart';

// 1. 解析 ABI
final abi = ContractABI.fromJson([
  {
    "type": "function",
    "name": "transfer",
    "inputs": [
      {"name": "to", "type": "address"},
      {"name": "amount", "type": "uint256"}
    ],
    "outputs": [{"name": "", "type": "bool"}]
  }
]);

// 2. 编码函数调用
final transferFunc = abi.functionFragments["transfer"];
final encodedData = transferFunc.encode([
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  BigInt.from(1000000000000000000), // 1 token
]);

// 3. 解码返回值
final result = transferFunc.decodeOutput(returnData);
final success = result[0]; // bool

// 4. EIP712 签名
final typedData = {
  "types": {
    "EIP712Domain": [
      {"name": "name", "type": "string"},
      {"name": "version", "type": "string"},
      {"name": "chainId", "type": "uint256"},
      {"name": "verifyingContract", "type": "address"}
    ],
    "Person": [
      {"name": "name", "type": "string"},
      {"name": "wallet", "type": "address"}
    ]
  },
  "primaryType": "Person",
  "domain": {
    "name": "MyDApp",
    "version": "1",
    "chainId": 1,
    "verifyingContract": "0x..."
  },
  "message": {
    "name": "Alice",
    "wallet": "0x..."
  }
};

final eip712 = EIP712.fromJson(typedData);
final hash = eip712.primaryHash();
```

---

## 对外接口

### ABI 编解码

#### 核心类（位于 `abi/core/`）
- **`AbiParameter`**：ABI 参数定义
  - `name: String`：参数名称
  - `type: String`：参数类型
  - `components: List<AbiParameter>`：组件（用于 tuple）
- **`AbiEncoder`**：ABI 编码器
  - `encode(String type, dynamic value)`：编码单个值
  - `encodeParameters(List<AbiParameter> params, List<dynamic> values)`：编码参数列表
- **`AbiDecoder`**：ABI 解码器
  - `decode(String type, List<int> data)`：解码单个值
  - `decodeParameters(List<AbiParameter> params, List<int> data)`：解码参数列表

#### 支持的 ABI 类型（位于 `abi/types/`）

##### 基础类型
- **`address.dart`**：地址类型（20 字节）
- **`boolean.dart`**：布尔类型
- **`bytes.dart`**：动态字节 `bytes` 和固定字节 `bytesN` (N=1..32)
- **`string.dart`**：字符串类型
- **`numbers.dart`**：整数类型
  - `uintN` (N=8..256, 步长 8)：无符号整数
  - `intN` (N=8..256, 步长 8)：有符号整数

##### 复合类型
- **`array.dart`**：数组类型
  - 固定长度数组：`type[N]`
  - 动态数组：`type[]`
- **`tuple.dart`**：元组类型 `(type1, type2, ...)`
- **`function.dart`**：函数类型（24 字节：地址 + 函数选择器）

### 合约交互

#### Fragment 类型（位于 `contract/fragments.dart`）
- **`AbiFunctionFragment`**：函数 Fragment
  - `name: String`：函数名称
  - `inputs: List<AbiParameter>`：输入参数
  - `outputs: List<AbiParameter>`：输出参数
  - `stateMutability: String`：状态可变性（view, pure, payable, nonpayable）
  - `encode(List<dynamic> params)`：编码函数调用（包含 selector）
  - `decodeOutput(List<int> data)`：解码返回值
  - `selector`：函数选择器（keccak256(signature) 前 4 字节）

- **`AbiEventFragment`**：事件 Fragment
  - `name: String`：事件名称
  - `inputs: List<AbiParameter>`：参数（包含 `indexed` 属性）
  - `anonymous: bool`：是否匿名
  - `encodeTopics(List<dynamic> params)`：编码 topics
  - `decodeLog(List<String> topics, String data)`：解码日志

- **`AbiConstructorFragment`**：构造函数 Fragment
  - `inputs: List<AbiParameter>`：构造函数参数
  - `encode(List<dynamic> params)`：编码构造函数参数

- **`AbiFallbackFragment`**：Fallback Fragment
- **`AbiReceiveFragment`**：Receive Fragment

#### ContractABI（位于 `contract/contract_abi.dart`）
- **`ContractABI`**：合约 ABI 容器
  - `fromJson(List<Map<String, dynamic>> json)`：从 JSON 解析
  - `functionFragments: Map<String, AbiFunctionFragment>`：函数映射
  - `eventFragments: Map<String, AbiEventFragment>`：事件映射
  - `constructor: AbiConstructorFragment`：构造函数
  - `getFunction(String name)`：获取函数 Fragment
  - `getEvent(String name)`：获取事件 Fragment

### EIP712 签名（位于 `abi/eip712/`）

#### EIP712 类
- **`EIP712`**：结构化数据签名
  - `fromJson(Map<String, dynamic> json)`：从 JSON 创建
  - `types: Map<String, List<AbiParameter>>`：类型定义
  - `primaryType: String`：主类型
  - `domain: Map<String, dynamic>`：域分隔符
  - `message: Map<String, dynamic>`：消息内容
  - `domainHash()`：计算域哈希
  - `primaryHash()`：计算主哈希（用于签名）
  - `encodeData(String primaryType, Map<String, dynamic> data)`：编码数据

#### EIP712 版本
- **v1 (Legacy)**：简单的类型哈希
- **v3**：引入域分隔符
- **v4**：支持数组和递归结构（推荐使用）

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供 Keccak256 哈希

### 内部依赖
- 可被 `ethereum`、`tron`、`filecoin` 模块引用

### 配置文件
- 无需额外配置文件

---

## 数据模型

### ABI 参数类型映射

| Solidity 类型 | Dart 类型 | 示例 |
|--------------|----------|------|
| `address` | `String` | `"0x742d35Cc..."` |
| `bool` | `bool` | `true` |
| `uint256` | `BigInt` | `BigInt.from(1000)` |
| `int256` | `BigInt` | `BigInt.from(-1000)` |
| `bytes` | `List<int>` | `[0x12, 0x34]` |
| `bytes32` | `List<int>` | `[0x12, ...] // 长度 32` |
| `string` | `String` | `"Hello"` |
| `address[]` | `List<String>` | `["0x...", "0x..."]` |
| `uint256[]` | `List<BigInt>` | `[BigInt.from(1), BigInt.from(2)]` |
| `tuple` | `List<dynamic>` | `["Alice", BigInt.from(30)]` |

---

## 测试与质量

### 测试目录
无独立测试目录（ABI 编解码测试可能集成在 Ethereum 测试中）

### 示例代码
- 合约调用：`example/lib/example/contract/call_example.dart`
- Fragment 模式：`example/lib/example/contract/call_with_fragment_example.dart`
- ABI 定义：`example/lib/example/contract/abi.dart`
- EIP712 v4：`example/lib/example/eip_712/v4_example.dart`
- EIP712 Legacy：`example/lib/example/eip_712/legacy_example.dart`

### 运行测试
```bash
# 建议补充独立测试
dart test test/solidity/
```

---

## 常见问题 (FAQ)

### Q1: 如何编码复杂的 tuple 参数？
```dart
// Solidity: function swap(address token, (uint256 amount, address recipient) data)
final swapFunc = AbiFunctionFragment.fromJson({
  "name": "swap",
  "inputs": [
    {"name": "token", "type": "address"},
    {
      "name": "data",
      "type": "tuple",
      "components": [
        {"name": "amount", "type": "uint256"},
        {"name": "recipient", "type": "address"}
      ]
    }
  ]
});

final encoded = swapFunc.encode([
  "0x...", // token
  [BigInt.from(1000), "0x..."], // tuple
]);
```

### Q2: 如何解码事件日志？
```dart
final eventFragment = AbiEventFragment.fromJson({
  "name": "Transfer",
  "inputs": [
    {"name": "from", "type": "address", "indexed": true},
    {"name": "to", "type": "address", "indexed": true},
    {"name": "value", "type": "uint256", "indexed": false}
  ]
});

// 从区块链获取的日志
final topics = ["0x...", "0x...", "0x..."];
final data = "0x...";

final decoded = eventFragment.decodeLog(topics, data);
// decoded = {"from": "0x...", "to": "0x...", "value": BigInt(...)}
```

### Q3: 如何验证 EIP712 签名？
```dart
final eip712 = EIP712.fromJson(typedDataJson);
final hash = eip712.primaryHash();

// 签名
final signature = privateKey.sign(hash);

// 验证：恢复签名者地址
final recoveredAddress = signature.recoverPublicKey(hash).toAddress();
final isValid = recoveredAddress == expectedAddress;
```

### Q4: 如何处理动态数组嵌套？
```dart
// Solidity: uint256[][]
final nestedArrayType = "uint256[][]";

final data = [
  [BigInt.from(1), BigInt.from(2)],
  [BigInt.from(3), BigInt.from(4), BigInt.from(5)],
];

final encoded = AbiEncoder.encode(nestedArrayType, data);
final decoded = AbiDecoder.decode(nestedArrayType, encoded);
```

---

## 相关文件清单

### 核心文件
- `abi/abi.dart`：ABI 总入口
- `abi/core/abi.dart`：ABI 核心逻辑
- `contract/contract_abi.dart`：合约 ABI 容器
- `contract/fragments.dart`：Fragment 定义
- `abi/eip712/eip712.dart`：EIP712 实现
- `abi/exception/abi_exception.dart`：ABI 异常

### ABI 类型文件（位于 `abi/types/`）
- `address.dart`：地址类型
- `boolean.dart`：布尔类型
- `bytes.dart`：字节类型
- `string.dart`：字符串类型
- `numbers.dart`：数值类型
- `array.dart`：数组类型
- `tuple.dart`：元组类型
- `function.dart`：函数类型

### EIP712 文件（位于 `abi/eip712/`）
- `eip712.dart`：EIP712 主实现
- `utils.dart`：EIP712 工具函数

### 工具文件
- `abi/utils/utils.dart`：ABI 工具函数
- `address/core.dart`：地址工具

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Solidity 模块文档
- 覆盖 ABI 编解码（所有 ABI 类型）、Fragment 模式、EIP712 签名
- 添加复杂类型编码、事件解码、签名验证等常见问题
