[根目录](../../CLAUDE.md) > **bcs**

# BCS 模块

## 模块职责

提供 Binary Canonical Serialization (BCS) 编解码和 Move 语言类型支持，主要用于与基于 Move 语言的区块链（如 Aptos、Sui）交互。

**核心功能**：
- BCS 序列化/反序列化
- Move 语言基础类型（AccountAddress、TypeTag、StructTag 等）
- 类型安全的编解码

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/bcs/serialization.dart`

### 导出模块
```dart
export 'serialization/serialization.dart';  // BCS 序列化器
export 'move/move.dart';                    // Move 类型定义
export 'exeption/exeption.dart';            // 异常定义
```

### 快速开始
```dart
import 'package:on_chain/bcs/serialization.dart';

// 1. 序列化基础类型
final serialized = BCS.serialize({
  "address": "0x1234...", // Move AccountAddress
  "amount": BigInt.from(1000),
  "flag": true,
});

// 2. 反序列化
final deserialized = BCS.deserialize(serialized, schema);

// 3. Move 类型操作
final accountAddress = AccountAddress.fromHex("0x1234...");
final typeTag = TypeTag.fromString("0x1::coin::Coin<0x1::aptos_coin::AptosCoin>");
final structTag = StructTag(
  address: accountAddress,
  module: "coin",
  name: "Coin",
  typeParams: [/* ... */],
);
```

---

## 对外接口

### BCS 序列化（位于 `serialization/`）

#### BCS 类
- **`BCS`**：BCS 序列化器
  - `serialize(dynamic data)`：序列化数据
  - `deserialize<T>(List<int> bytes, BcsSchema<T> schema)`：反序列化数据

#### 支持的 BCS 类型
- **bool**：布尔值
- **u8, u16, u32, u64, u128, u256**：无符号整数
- **i8, i16, i32, i64, i128**：有符号整数
- **string**：UTF-8 字符串
- **vector<T>**：动态数组
- **option<T>**：可选值（类似 Rust 的 Option）
- **struct**：结构体
- **enum**：枚举

### Move 类型（位于 `move/types/`）

#### 基础类型
- **`AccountAddress`**：账户地址（32 字节）
  - `fromHex(String hex)`：从十六进制创建
  - `toHex()`：转换为十六进制
  - `toBytes()`：转换为字节数组

- **`Identifier`**：标识符（模块名、函数名等）
  - `Identifier(String name)`：创建标识符
  - `toString()`：转换为字符串

#### 类型标签
- **`TypeTag`**：类型标签（用于泛型）
  - `TypeTag.bool`：布尔类型
  - `TypeTag.u8`, `TypeTag.u64`, `TypeTag.u128`, `TypeTag.u256`：整数类型
  - `TypeTag.address`：地址类型
  - `TypeTag.signer`：签名者类型
  - `TypeTag.vector(TypeTag elementType)`：向量类型
  - `TypeTag.struct(StructTag structTag)`：结构体类型

- **`StructTag`**：结构体标签
  - `address: AccountAddress`：定义结构体的账户地址
  - `module: Identifier`：模块名
  - `name: Identifier`：结构体名
  - `typeParams: List<TypeTag>`：类型参数（泛型）
  - 示例：`0x1::coin::Coin<0x1::aptos_coin::AptosCoin>`

#### Move 值类型
- **`MoveValue`**：Move 值的抽象表示
  - `MoveValue.bool(bool value)`
  - `MoveValue.u8(int value)`
  - `MoveValue.u64(BigInt value)`
  - `MoveValue.address(AccountAddress addr)`
  - `MoveValue.vector(List<MoveValue> items)`
  - `MoveValue.struct(Map<String, MoveValue> fields)`

---

## 关键依赖与配置

### 外部依赖
- `blockchain_utils: ^5.2.0`：提供编解码工具

### 内部依赖
- 无依赖其他模块（独立模块）

### 配置文件
- 无需额外配置文件

---

## 数据模型

### BCS 编码规则

| 类型 | 编码方式 | 示例 |
|------|---------|------|
| `bool` | 1 字节（0x00 或 0x01） | `true` → `0x01` |
| `u8` | 1 字节 | `255` → `0xFF` |
| `u32` | 4 字节（小端序） | `1000` → `0xE8030000` |
| `u64` | 8 字节（小端序） | `1000` → `0xE803000000000000` |
| `u128` | 16 字节（小端序） | - |
| `string` | 长度 + UTF-8 字节 | `"abc"` → `0x03616263` |
| `vector<T>` | 长度 + 元素 | `[1, 2, 3]` → `0x03010203` |
| `option<T>` | 标志 + 值 | `Some(5)` → `0x0105`, `None` → `0x00` |

### Move 地址格式
- **长度**：32 字节（固定）
- **格式**：十六进制，前缀 `0x`
- **示例**：`0x0000000000000000000000000000000000000000000000000000000000000001`（简写为 `0x1`）

---

## 测试与质量

### 测试目录
`/home/mrpzx/git/flutter/wallet/On_chain/test/move/`

### 测试文件
- `move_test.dart`：BCS 序列化与 Move 类型测试

### 运行测试
```bash
dart test test/move/
```

### 示例代码
- 当前无独立示例，建议补充

---

## 常见问题 (FAQ)

### Q1: 如何序列化 Move 结构体？
```dart
// Move 结构体：
// struct User {
//   name: vector<u8>,
//   age: u8,
//   balance: u64,
// }

final user = {
  "name": "Alice".codeUnits, // vector<u8>
  "age": 30,
  "balance": BigInt.from(1000),
};

final serialized = BCS.serialize(user);
```

### Q2: 如何解析 TypeTag 字符串？
```dart
// 解析泛型类型字符串
final typeTag = TypeTag.fromString(
  "0x1::coin::Coin<0x1::aptos_coin::AptosCoin>"
);

// 访问结构体信息
if (typeTag is TypeTagStruct) {
  final structTag = typeTag.value;
  print(structTag.address); // 0x1
  print(structTag.module);  // coin
  print(structTag.name);    // Coin
  print(structTag.typeParams); // [TypeTag for AptosCoin]
}
```

### Q3: 如何处理 Option 类型？
```dart
// Some(value)
final someValue = BCS.serialize({"option": 5, "isSome": true});

// None
final noneValue = BCS.serialize({"option": null, "isSome": false});
```

### Q4: BCS 与 Solidity ABI 有什么区别？
| 特性 | BCS | Solidity ABI |
|------|-----|-------------|
| 编码方式 | 紧凑、小端序 | 32 字节对齐、大端序 |
| 动态类型 | 长度前缀 | 长度存储在数据末尾 |
| 适用场景 | Move 链（Aptos, Sui） | EVM 链（Ethereum, BSC） |
| 复杂度 | 简单、高效 | 复杂、灵活 |

---

## 相关文件清单

### 核心文件
- `serialization/serialization.dart`：BCS 序列化器实现
- `move/move.dart`：Move 类型总入口
- `move/types/types.dart`：Move 类型定义
- `move/utils/utils.dart`：Move 工具函数
- `exeption/exeption.dart`：异常定义

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 BCS 模块文档
- 覆盖 BCS 序列化、Move 类型（AccountAddress、TypeTag、StructTag）
- 添加 BCS 编码规则、Move 地址格式说明
- 对比 BCS 与 Solidity ABI 差异
