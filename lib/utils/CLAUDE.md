[根目录](../../CLAUDE.md) > **utils**

# Utils 模块

## 模块职责

提供跨模块共享的通用工具函数，包括数字处理、Map 操作等辅助功能。

**核心功能**：
- 数字类型转换与格式化
- Map 数据操作
- 通用辅助工具

---

## 入口与启动

### 主入口文件
`/home/mrpzx/git/flutter/wallet/On_chain/lib/utils/utils.dart`

### 导出模块
```dart
export 'utils/number_utils.dart';  // 数字工具
export 'utils/utils.dart';         // 通用工具
```

### 快速开始
```dart
import 'package:on_chain/utils/utils.dart';

// 数字处理
final hexString = numberToHex(255); // "0xff"
final bigInt = hexToBigInt("0x64"); // BigInt(100)

// Map 操作
final cleanedMap = removeNullValues({
  "name": "Alice",
  "age": null,
  "city": "NYC",
}); // {"name": "Alice", "city": "NYC"}
```

---

## 对外接口

### 数字工具（`utils/number_utils.dart`）

#### 数字转换函数
- **`numberToHex(dynamic number)`**：将数字转换为十六进制字符串
  - 支持：`int`, `BigInt`, `String`
  - 返回：带 `0x` 前缀的十六进制字符串
  - 示例：`numberToHex(255)` → `"0xff"`

- **`hexToBigInt(String hex)`**：将十六进制字符串转换为 BigInt
  - 支持：带或不带 `0x` 前缀
  - 返回：`BigInt`
  - 示例：`hexToBigInt("0x64")` → `BigInt.from(100)`

- **`hexToInt(String hex)`**：将十六进制字符串转换为 int
  - 支持：带或不带 `0x` 前缀
  - 返回：`int`
  - 示例：`hexToInt("0x64")` → `100`

#### 数字格式化
- **`formatBigInt(BigInt value, int decimals)`**：格式化 BigInt 为可读字符串
  - 示例：`formatBigInt(BigInt.from(1000000000000000000), 18)` → `"1.0"`

- **`parseBigInt(String value, int decimals)`**：解析字符串为 BigInt
  - 示例：`parseBigInt("1.5", 18)` → `BigInt.from(1500000000000000000)`

### Map 工具（`utils/map_utils.dart`）

#### Map 操作函数
- **`removeNullValues(Map<String, dynamic> map)`**：移除 Map 中的 null 值
  - 返回：新的 Map（不修改原 Map）
  - 示例：
    ```dart
    final input = {"a": 1, "b": null, "c": 3};
    final output = removeNullValues(input);
    // output = {"a": 1, "c": 3}
    ```

- **`deepCopy(Map<String, dynamic> map)`**：深拷贝 Map
  - 递归复制嵌套的 Map 和 List
  - 返回：新的 Map

- **`mergeMap(Map<String, dynamic> map1, Map<String, dynamic> map2)`**：合并两个 Map
  - 冲突时 `map2` 的值优先
  - 返回：新的 Map

### 通用工具（`utils/utils.dart`）

#### 字节操作
- **`bytesToHex(List<int> bytes)`**：将字节数组转换为十六进制字符串
  - 示例：`bytesToHex([0x12, 0x34])` → `"1234"`

- **`hexToBytes(String hex)`**：将十六进制字符串转换为字节数组
  - 示例：`hexToBytes("1234")` → `[0x12, 0x34]`

#### 字符串操作
- **`padLeft(String str, int length, String padding)`**：左填充字符串
  - 示例：`padLeft("5", 4, "0")` → `"0005"`

- **`padRight(String str, int length, String padding)`**：右填充字符串
  - 示例：`padRight("5", 4, "0")` → `"5000"`

---

## 关键依赖与配置

### 外部依赖
- 无外部依赖（纯 Dart 实现）

### 内部依赖
- 被所有模块引用（`ethereum`, `tron`, `solana`, `filecoin`, `solidity`, `bcs`）

### 配置文件
- 无需额外配置文件

---

## 数据模型

### 数字单位转换示例

```dart
// Wei <-> Ether (Ethereum)
final wei = BigInt.from(1000000000000000000); // 1 ETH
final ether = formatBigInt(wei, 18); // "1.0"

// SUN <-> TRX (Tron)
final sun = BigInt.from(1000000); // 1 TRX
final trx = formatBigInt(sun, 6); // "1.0"

// Lamports <-> SOL (Solana)
final lamports = BigInt.from(1000000000); // 1 SOL
final sol = formatBigInt(lamports, 9); // "1.0"

// attoFIL <-> FIL (Filecoin)
final attoFil = BigInt.from(1000000000000000000); // 1 FIL
final fil = formatBigInt(attoFil, 18); // "1.0"
```

---

## 测试与质量

### 测试目录
无独立测试目录（测试可能集成在各模块测试中）

### 运行测试
```bash
# 建议补充独立测试
dart test test/utils/
```

---

## 常见问题 (FAQ)

### Q1: 如何处理大数字运算？
```dart
// 使用 BigInt 避免精度丢失
final amount1 = BigInt.parse("1000000000000000000"); // 1 ETH
final amount2 = BigInt.parse("500000000000000000");  // 0.5 ETH
final total = amount1 + amount2; // 1.5 ETH

// 格式化为可读字符串
final formatted = formatBigInt(total, 18); // "1.5"
```

### Q2: 如何在不同进制之间转换？
```dart
// 十进制 -> 十六进制
final hex = numberToHex(255); // "0xff"

// 十六进制 -> 十进制
final decimal = hexToInt("0xff"); // 255

// 十六进制 -> BigInt
final bigInt = hexToBigInt("0x1000000000000000"); // 很大的数字
```

### Q3: 如何安全地操作嵌套 Map？
```dart
final data = {
  "user": {
    "name": "Alice",
    "settings": {
      "theme": "dark",
      "notifications": null,
    }
  }
};

// 深拷贝避免修改原数据
final copy = deepCopy(data);
copy["user"]["settings"]["theme"] = "light";

// 移除所有 null 值
final cleaned = removeNullValues(data);
```

---

## 相关文件清单

### 核心文件
- `utils/utils.dart`：主入口
- `utils/utils/utils.dart`：通用工具函数
- `utils/utils/number_utils.dart`：数字工具函数
- `utils/utils/map_utils.dart`：Map 工具函数

---

## 变更记录 (Changelog)

### 2025-10-21 10:56:05
- 初始化 Utils 模块文档
- 覆盖数字转换、Map 操作、字节/字符串处理等工具函数
- 添加跨链数字单位转换示例
