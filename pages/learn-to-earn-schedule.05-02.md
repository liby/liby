title:: Learn to Earn Schedule/05-02

- LATER 没有任何内容，需要补充的章节；同时也需要 i18n
	- DONE [Setting up Move develop environment](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/prepare-move-env): [PR](https://github.com/starcoinorg/starcoin-cookbook/pull/45)
	- DONE [Move Language](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/move-language)
		- 已经有 [PR](https://github.com/starcoinorg/starcoin-cookbook/pull/38) 了
	- DONE [Understanding ability](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/understanding-ability): [PR](https://github.com/starcoinorg/starcoin-cookbook/pull/47)
	- [Starcoin Move Framework](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/starcoin-framework)
	- [Deploy your first move contract](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/deploy-first-move-contract)
	- [Interactiong with the contract by CLI](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/interacting-with-the-contract)
	- [Understanding module dependency](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/module-dependency)
	- [How to upgrade Move Module](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/how-to-upgrade%20copy/)
		- 这里给了 3 个 discord 的链接，我不清楚是我网络不好，还是链接本身就有问题，等了很久都没打开
	- [For solidity developer](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/for-solidity-developer/)
	- [Create a new Token](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/move-examples/create-a-new-token)
	- [Create a new NFT](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/move-examples/create-a-new-nft)
	- [How to design permission system with Capability](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/advance-move/how-to-design-permission-system)
	- [How to handle the mapping requirement](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/advance-move/how-to-handle-mapping-requirement)
- TODO 现在已经可以确定可以做的东西
	- 1. 安装 mpm 说明
	  2. 提供一些学习 Move 语法的链接
- User Guide of Move Package Manager 下的内容是否可以拆分放到上面几个没有任何的内容的章节内呢？
- [测试注解 - 意思和用法](https://starcoinorg.github.io/starcoin-cookbook/zh/docs/move/move-test/move-unit-test#%E6%B5%8B%E8%AF%95%E6%B3%A8%E8%A7%A3---%E6%84%8F%E6%80%9D%E5%92%8C%E7%94%A8%E6%B3%95) 提到的这句话应该是翻译错了
	- > 注解 `#[test]` 用来标记某个函数是测试函数。`#[test]` 和 `#[expected_failure]` 可以带参数。但要标记没有参数的函数时，`#[test]` 不能带参数。
	- 顺手提了一个 [PR](https://github.com/starcoinorg/starcoin-cookbook/pull/43)
- TODO 要读一下 diem 写的这篇 [Move Tutorial](https://github.com/diem/move/tree/main/language/documentation/tutorial)
- 发现 Move and SmartContract Development 这个部分东西很多，但是都缺少内容；内容组织也比较随意，有不少重复的地方，一路看过来表示有些懵，感觉学习路线突然陡峭起来；默默估量了一下，光是这个部分的文档增补就可以忙活很久