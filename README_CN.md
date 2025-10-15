# ON CHAIN Dart 包

[English](README.md) | [中文](README_CN.md)

On Chain 是一个面向 Dart 的高级跨平台解决方案,无缝集成了 Ethereum、Tron、Solana 和 Filecoin 区块链。它支持关键的以太坊标准,如 Legacy、EIP1559、EIP2930 和 EIP712,为开发者提供了强大的交易、智能合约和代币管理工具。

此插件提供以下功能:

- Tron: 账户创建、资产转移、原生操作和智能合约执行。
- Solana: Metaplex 集成、代币管理、质押和智能合约。
- Filecoin: 支持多种地址类型(f0、f1、f4)和交易操作。

该包简化了多个区块链生态系统的开发,是 Dart 开发者的综合工具包。

## 功能特性

### Ethereum 网络

- **签名(交易、个人签名)**: 在 Dart 应用程序中启用安全的交易和个人数据签名,确保加密完整性和身份验证。

- **EIP1559**: 采用以太坊改进提案 1559 的效率,优化交易费用机制,提高可预测性和用户体验。

- **EIP2930(访问列表)**: 使用访问列表简化与以太坊区块链的合约交互,通过指定具有直接访问权限的账户来提高效率并降低交易成本。

- **与合约交互**: 无缝与以太坊智能合约交互,通过 Dart 项目中高效的合约交互释放去中心化应用程序的全部潜力。

- **与以太坊节点交互(JSON RPC)**: 通过 JSON RPC 促进与以太坊节点的直接通信,使您的 Dart 应用程序能够以标准化和高效的方式访问和查询区块链数据。

- **EIP712(Legacy、v3、v4)**: 实现以太坊改进提案 712 标准的结构化和安全消息签名,支持 legacy 版本以及版本 3 和 4,以确保在多样化的以太坊生态系统中的兼容性和合规性。

- **HD 钱包**: 管理助记词生成、种子派生和地址创建。

- [示例代码](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/ethereum)

### Tron 网络

- **Tron 签名(交易、个人签名)**: 在 Dart 应用程序中安全授权 Tron 交易并签署个人数据,确保加密完整性和用户身份验证。

- **多重签名**: 通过多重签名功能增强 Tron 区块链的安全性和去中心化决策。通过要求多个加密签名来进行交易,实现协作,加强 Tron 网络内的信任和完整性。为您的 Dart 应用程序提供复杂的多重签名功能,实现弹性和协作式的 Tron 交易授权方法。

- **与 Tron 智能合约交互**: 无缝与 Tron 的智能合约交互,使您的 Dart 项目能够轻松执行和管理 Tron 区块链上的交易。

- **创建 Tron 原生合约交易**: 轻松发起各种 Tron 原生合约交易,包括账户创建、资产转移、投票、智能合约创建等。探索为 Tron 区块链定制的全面合约操作列表。

- **与 Tron HTTP 节点交互**: 通过 HTTP 节点促进与 Tron 区块链的直接通信,允许您的 Dart 应用程序以标准化和高效的方式查询和与 Tron 网络交互。

- **Tron 的所有功能**: 利用 Tron 区块链的所有功能,包括隐蔽转账、市场交易、资源委托、合约管理等,释放 Tron 区块链的全部潜力。为您的 Dart 应用程序提供全面的功能,实现丰富而动态的 Tron 区块链体验。

- **HD 钱包**: 管理助记词生成、种子派生和地址创建。

- [示例代码](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/tron)

### Solana 网络

- **交易**: 版本化交易生成、序列化和反序列化。

- **签名**: 轻松签署交易。

- **指令**: 该插件提供了许多预构建的指令,简化了创建自己交易的过程。以下是一些示例:

  - addressLockupTable(地址查找表)
  - associatedTokenAccount(关联代币账户)
  - computeBudget(计算预算)
  - ed25519
  - memo(备忘录)
  - nameService(名称服务)
  - secp256k1
  - splToken(SPL 代币)
  - splTokenMetaData(SPL 代币元数据)
  - splTokenSwap(SPL 代币交换)
  - stake(质押)
  - stakePool(质押池)
  - system(系统)
  - tokenLending(代币借贷)
  - vote(投票)
  - Metaplex
    - auctionHouse(拍卖行)
    - auctioneer(拍卖师)
    - bubblegum
    - candyMachineCore(糖果机核心)
    - fixedPriceSale(固定价格销售)
    - gumdrop
    - hydra
    - nftPacks(NFT 包)
    - tokenEntangler(代币纠缠器)
    - tokenMetaData(代币元数据)

- **自定义程序**: 该插件支持 Solana Buffer 布局结构,可轻松编码和解码相关数据。

- **HD 钱包**: 管理助记词生成、种子派生和地址创建。

- [示例代码](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example/solana)

### Filecoin 网络

- **地址支持**: 支持多种地址类型(ID f0、SECP256K1 f1、委托/以太坊兼容 f4)。

- **交易**: 基于 CBOR 的交易格式,支持签名和验证。

- **RPC 通信**: 通过 JSON-RPC 与 Filecoin 节点交互。

- **HD 钱包**: 管理助记词生成、种子派生和地址创建。

### Solidity

- 编码、解码并与 Solidity 智能合约交互。

### Move

- 编码和解码 Move 语言类型。

## 示例代码

浏览所有可用示例 [点击这里](https://github.com/mrtnetwork/On_chain/tree/main/example/lib/example)

## 贡献

欢迎贡献!请遵循以下准则:

- Fork 仓库并创建新分支。
- 进行更改并确保测试通过。
- 提交包含详细更改说明的 pull request。

## 功能请求和错误报告

请在 issue 跟踪器中提交功能请求和错误报告。
