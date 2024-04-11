title:: Learn to Earn Schedule/05-03

- 今天开始看[《Move 编程语言》](https://move-book.com/cn/index.html#move-%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80)，昨天看 Move and SmartContract Development 中有很多关于 Move 的地方都是缺失的
	- 这部分介绍可以放到 [For solidity developer](http://localhost:3000/starcoin-cookbook/zh/docs/move/for-solidity-developer) 章节：
	  > 与其它智能合约编程语言（例如 Solidity）不同，Move 程序分为脚本和模块。前者可以让开发者在交易中加入更多逻辑，在更加灵活地同时节省时间和资源。后者允许开发人员更容易扩展区块链的功能，更加灵活地实现自定义智能合约。
- 为 Section Setting up Move develop environment 小节提了一个 [PR](https://github.com/starcoinorg/starcoin-cookbook/pull/45)，为 `mpm` 的下载做了说明
- 为 Understanding abilities 小节补充了一些[内容](https://github.com/starcoinorg/starcoin-cookbook/pull/47/files)，指向了相关的资源链接
- Move 的基本数据类型包括: 整型 (`u8`, `u64`, `u128`)、布尔型 `boolean` 和地址 `address`
	- Move 不支持字符串和浮点数
	- 地址是区块链中交易发送者的标识符