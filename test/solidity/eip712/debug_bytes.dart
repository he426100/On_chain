import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/solidity/abi/abi.dart';
import 'package:test/test.dart';

void main() {
  test('Debug bytes encoding', () {
    // 测试空字符串 "0x" 的处理
    print('=== 测试 bytes 类型编码 ===\n');

    // 测试 1: 空字符串 "0x" - 使用修复后的 fromHexString
    final emptyHex = '0x';
    final bytes1 = BytesUtils.fromHexString(emptyHex);
    final hash1 = QuickCrypto.keccack256Hash(bytes1);
    print('Input: "$emptyHex" (hex parsed)');
    print('Bytes: ${bytes1.isEmpty ? "(empty)" : BytesUtils.toHexString(bytes1)}');
    print('Length: ${bytes1.length}');
    print('Hash: ${BytesUtils.toHexString(hash1)}');
    print('');

    // 测试 2: 空 List<int>
    final emptyList = <int>[];
    final hash2 = QuickCrypto.keccack256Hash(emptyList);
    print('Input: []');
    print('Length: ${emptyList.length}');
    print('Hash: ${BytesUtils.toHexString(hash2)}');
    print('');

    // 测试 3: 字符串 "0x" 的 UTF-8 编码
    final utf8Bytes = StringUtils.encode('0x');
    final hash3 = QuickCrypto.keccack256Hash(utf8Bytes);
    print('Input: "0x" as UTF-8 string');
    print('Bytes: ${BytesUtils.toHexString(utf8Bytes)}');
    print('Length: ${utf8Bytes.length}');
    print('Hash: ${BytesUtils.toHexString(hash3)}');
    print('');

    // 期望的 hash (eth-sig-util 的结果)
    const expectedHash =
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470';
    print('Expected hash: $expectedHash');
  });
}
