- 生成 Master Key 的私钥
	- ```
	  gpg --armor --export-secret-keys <KEY> --export-options backup -o <PATH>
	  ```
- 生成 Revoke Key
	- ```
	  gpg --armor --output <PATH> --gen-revoke <KEY>
	  ```