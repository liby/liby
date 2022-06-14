title:: pnpm V6 升级 V7 的记录

- Major 改动很多，但在升级中发现对我影响特别大的地方不算很多
- `--filter` 的参数必须遵守 glob 语法
	- 在 pnpm V6 中，为了选择某个目录下的包，一般这样写：`--filter=./apps`
	- 在pnpm v7中，应该使用 glob：`--filter=./apps/**`
	- 这个地方卡了我最久，我们有一个 monorepo 仓库，它在根目录下的 package.json 有一个 build 命令：`pnpm -r --filter ./packages run build`
		- 但我一开始根本没注意到它，也没有任何报错，幸好在跑测试的时候总是报错，说 `Cannot find module '@pkg/mock-server' or its corresponding type declarations.`
		- 就是因为没有 build 成功，导致根本找不到 module
- `pnpm run <script>` 时[不需要再传 `--` 了](https://github.com/pnpm/pnpm/pull/4290)
	- 在 [[2022-03-11]] 才学到的知识就已经用不上了
	- ```
	  "scripts": {
	    // 修改前
	    "dev": "pnpm run cmd -- --param",
	    // 修改后
	    "dev": "pnpm run cmd --param"
	  }
	  ```
- `pnpm install -g pkg` 不再会向全局的 Node.js 或 npm 文件夹里安装 pkg，除非提前通过 `PNPM_HOME` 环境变量来指定
	- 可以通过运行 `pnpm steup` 来完成设置环境变量的操作，它会：
		- 为 pnpm CLI 创建一个主目录
		- 通过更新 shell 配置文件将 pnpm 主目录添加到 `PATH`
		- 将 pnpm 可执行文件复制到 pnpm 主目录
	- 这个地方也小小的踩了一下坑，有一个镜像中执行了 `pnpm add -g typescript` 而后因为这个问题报错了，在 Dockerfile 中加了环境变量解决：
		- ```
		  ENV PNPM_HOME="~/.local/share/pnpm"
		  ENV PATH="${PNPM_HOME}:${PATH}"
		  ```
- 全局 store 的文件夹从 *~/.pnpm-store* 改为 *<pnpm home directory>/store*
	- 在 Linux，默认是 *~/.local/share/pnpm/store*
	- 在 Windows，默认是 *%LOCALAPPDATA%/pnpm/store*
	- 在 macOS，默认是 *~/Library/pnpm/store*
	- 这里被坑的比较惨，一开始把 `pnpm config set store-dir .pnpm-store` 删掉了，认为再也用不到，还提了个 issue 问 V7 的持续集成部分的文档是不是忘记更新了，后面才发现 [GitLab CI 不能缓存不在项目文件夹中的文件夹](https://stackoverflow.com/questions/53953122/gitlab-ci-cache-no-matching-files)，那么这里还是要把 `pnpm config set store-dir .pnpm-store` 加回来
		- 此外看到还有朋友说 [node_modules 文件夹也要一起 cache](https://github.com/pnpm/pnpm/issues/1174#issuecomment-1028199705)，以避免在每个步骤中执行 `pnpm install`
- 最后就是在 CI 中使用 `curl -f https://get.pnpm.io/v6.js | node - add --global pnpm` 来安装 pnpm 会有问题，后续你通过 `pnpm add -g pkg` 来装包时，会遇到这个报错：
	- > ERROR  The CLI has no write access to the pnpm home directory at ~/.local/share/pnpm
	- 使用 `npm install -g pnpm@7` 来安装就没有问题
	- 显然在 CI 运行时，[我不可能在安装完成后重启终端](https://github.com/pnpm/pnpm/issues/3319#issuecomment-974883195)