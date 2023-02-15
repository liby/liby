- 使用 `gpg --expert --full-gen-key` 来构建 GPG Keys 或者引入已经生成/备份好的私钥
	- 如果是通过[脚本生成的](logseq://graph/liby?block-id=63d9432b-8d35-4b0b-bd17-dcc05682a3ec)，你能还需要增加新的 UID（每个都对应一个邮箱）并信任、[修改 Public key 的 usage](logseq://graph/liby?block-id=63d9432b-77b3-457b-b7b7-09bd6f3dbb2c) 为 Certify
- [编辑 Master Key，为其添加 Sub Key](logseq://graph/liby?block-id=63d9432b-8811-4ed7-ae95-37ee6d3ce216)
	- 创建 3 个 Sub Key，分别赋予 Sign Only、Encrypt Only 和 Authenticate Only 功能，有效期均为 1 年
- 生成 Master Key 的私钥
	- ```
	  gpg --armor --export-secret-keys <KEY> --export-options backup -o <PATH>
	  ```
	- 恢复，`--import-options restore` 导入一些常规导入中跳过的数据，包括 GunPG 专有数据
	  collapsed:: true
		- ```
		  
		  gpg --import --import-options restore <PATH>
		  ```
	- ```
	  gpg --import --import-options restore <PATH>
	  ```
- 生成 Revoke Key
	- ```
	  gpg --armor --output <PATH> --gen-revoke <KEY>
	  ```
- 生成公钥方便上传到服务器，比如 GitHub
	- ```
	  gpg --armor --export <KEY>
	  ```
- [修改卡的信息；修改 PIN 和 Admin PIN；修改 PIN、Reset Code 以及 Admin PIN 重试次数](logseq://graph/liby?block-id=63d9432b-f180-4c5c-bc7c-6def178fe424)
- [将 Sub Key 写入到 YubiKey](https://phyng.com/2022/12/14/yubikey.html#:~:text=%E5%85%A5%E5%88%B0%20Yubikey%E3%80%82-,%E5%86%99%E5%85%A5%E5%88%B0%20Yubikey,-%E4%BD%BF%E7%94%A8%E4%B8%8B%E9%9D%A2%E7%BC%96%E8%BE%91)
	- [在把密钥添加到 YubiKey 之前，先导出备份](logseq://graph/liby?block-id=63d9432b-5e7a-4cb9-9502-e51f9e518cf0)
- 导出并删除 Master Key：`gpg --delete-secret-keys <KEY>`