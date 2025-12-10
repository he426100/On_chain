import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/solidity/abi/abi.dart';
import 'package:test/test.dart';

void main() {
  test('NFT Permit with actual params should match eth-sig-util', () {
    // 测试钱包（与 eth-sig-util 相同）
    const privateKeyHex =
        '91e4ad47a567b23aec1157e280c00b3170125c4de7169ae63021aed37924931a';
    const expectedAddress = '0x6eCEcA63588925176Ce147Dc72d8f433D829bfb7';

    // eth-sig-util 的签名结果
    const expectedSignature =
        '0x00d2d193315080e6f84cad3f8b27e70d0d30677dabced74db2f91821c6d9941302d9533c4bf923bb54b37d898ec2759a5cecb93cf886d55ae26de563257cf3051b';

    // eth-sig-util 的中间值
    const expectedDomainSeparator =
        '6192106f129ce05c9075d319c1fa6ea9b3ae37cbd0c1ef92e2be7137bb07baa1';
    const expectedMessageHash =
        '80994bf8902df440433b277b6864217e2890d667f5fee5e29cf0ed934403f097';
    const expectedPermitTypeHash =
        '49ecf333e5b8c95c40fdafc95c1ad136e8914a8fb55e9dc8bb01eaa83a2df9ad';

    // 实际传参（来自钱包日志）
    final jsonStr =
        '{"domain":{"name":"My NFT","version":"1","chainId":11155111,"verifyingContract":"0x8847905c90F5dd9e0B1f1d810e85e31EfFa4AbFD"},"types":{"Permit":[{"name":"spender","type":"address"},{"name":"tokenId","type":"uint256"},{"name":"nonce","type":"uint256"},{"name":"deadline","type":"uint256"}]},"primaryType":"Permit","message":{"spender":"0x0521797E19b8E274E4ED3bFe5254FAf6fac96F08","tokenId":"3606393","nonce":"0","deadline":"1734995006"}}';

    final json = StringUtils.toJson(jsonStr) as Map<String, dynamic>;

    print('=== NFT Permit 实际参数测试 ===\n');

    // 解析 TypedData
    final typedData = Eip712TypedData.fromJson(json, version: EIP712Version.v4);

    // 验证 EIP712Domain 是空数组
    expect(typedData.types.containsKey('EIP712Domain'), isTrue);
    final domainFields = typedData.types['EIP712Domain']!;
    expect(domainFields.length, 0,
        reason: 'EIP712Domain 应该是空数组（与 eth-sig-util 一致）');
    print('✅ EIP712Domain 是空数组');

    // 计算各个中间值
    final domainSeparator =
        EIP712Utils.structHash(typedData, 'EIP712Domain', typedData.domain);
    final messageHash =
        EIP712Utils.structHash(typedData, 'Permit', typedData.message);
    final permitTypeHash = EIP712Utils.getMethodSigature(typedData, 'Permit');

    print('Domain separator: ${BytesUtils.toHexString(domainSeparator)}');
    print('Expected:         $expectedDomainSeparator');
    expect(BytesUtils.toHexString(domainSeparator), expectedDomainSeparator,
        reason: 'Domain separator 应该与 eth-sig-util 一致');
    print('✅ Domain separator 一致\n');

    print('Message hash: ${BytesUtils.toHexString(messageHash)}');
    print('Expected:     $expectedMessageHash');
    expect(BytesUtils.toHexString(messageHash), expectedMessageHash,
        reason: 'Message hash 应该与 eth-sig-util 一致');
    print('✅ Message hash 一致\n');

    print('Permit typeHash: ${BytesUtils.toHexString(permitTypeHash)}');
    print('Expected:        $expectedPermitTypeHash');
    expect(BytesUtils.toHexString(permitTypeHash), expectedPermitTypeHash,
        reason: 'Permit typeHash 应该与 eth-sig-util 一致');
    print('✅ Permit typeHash 一致\n');

    // 编码消息
    final encodedMessage = typedData.encode(hash: false);
    print('Encoded message: ${BytesUtils.toHexString(encodedMessage)}');

    // 创建签名器
    final privateKey = ETHPrivateKey(privateKeyHex);
    final publicKey = privateKey.publicKey();
    final address = publicKey.toAddress();

    // 验证地址
    expect(address.address.toLowerCase(), expectedAddress.toLowerCase());
    print('✅ 地址验证通过: ${address.address}\n');

    // 签名
    final signer = ETHSigner.fromKeyBytes(privateKey.toBytes());
    final signature = signer.signConst(encodedMessage);
    final signatureHex =
        BytesUtils.toHexString(signature.toBytes(), prefix: '0x');

    print('Our signature:      $signatureHex');
    print('Expected signature: $expectedSignature');

    // 对比签名
    expect(signatureHex.toLowerCase(), expectedSignature.toLowerCase(),
        reason: '签名结果应该与 eth-sig-util 一致');

    print('\n✅ 所有验证通过！签名与 eth-sig-util 完全一致！');
  });
}
