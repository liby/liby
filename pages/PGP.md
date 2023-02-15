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
-