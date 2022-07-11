title:: 使用 includeIf 管理 Git 多用户配置
type:: [[Post]]

- ### 背景描述
	- 我们通常会拥有公司或者个人的多个 GitHub/GitLab 账户，在不同项目下开发时，commit 的用户名和邮箱是不同的
		- 例如公司项目中，使用的是真实姓名+公司邮箱，而在 Side Project 中使用的是个人邮箱和昵称别名
	- 之前我会在全局的`$HOME/.gitconfig`  中配置我的个人邮箱和昵称别名，当克隆新项目到本地时再根据项目的归属来设置项目内的用户信息
		- 虽然可以使用 `alias` 一键完成设置操作，但克隆仓库和新建仓库的频率没有那么频繁，往往会忘记这个事情，导致 commit 时提交的用户信息不正确（这里不讨论 Husky 相关）
- ### 解决方案
	- 在 2017 年， `includeIf` 配置随着 Git 的 2.13.0 版本被发布，可以为不同目录下的 Git 仓库提供额外的配置文件，实现不同的仓库或者分支使用不同的用户名和邮箱；使用方式：
		- 1. 指定具体的分支，这里是 `test-branch`
		  ```
		  # 配置 test-branch 分支
		  [includeIf "onbranch:test-branch"]
		      path = ~/.gitconfig_self
		  ```
		  2. 指定具体的项目，这里是 demo
		  ```
		  # 配置demo项目
		  [includeIf "gitdir/i:~/workspace/private/demo/.git"]
		      path = ~/.gitconfig_self
		  ```
		  3. 指定一个目录，这里是 *~/workspace/public*
		  ```
		  # 配置public目录
		  [includeIf "gitdir/i:~/workspace/public/"]
		      path = ~/.gitconfig_work
		  ```
	- 设置完成后，将用户信息分别写入到被指定的子配置文件中即可（即上面例子中的 `.gitconfig_self` 和 `.gitconfig_work`）：
		- 1. 直接编辑该文件，写入以下内容
		  ```
		  [user]
		      name = Nick
		      email = user@example.com
		  ```
		  2. 用 `git config -f --file` 命令指定文件的 `$path`
		  ```
		  git config -f ~/.gitconfig_self user.name "Your Name"
		  
		  git config -f ~/.gitconfig_self user.email "your@example.com"
		  ```
- ### 内容详解
	- 来说 `includeIf` 之前，我们需要知道 Git 的配置文件生效的优先级，对这部分有所了解的可以直接略过看下一部分
	- #### 配置文件生效的优先级
		- Git 支持多级配置，如：系统级别、用户级别、项目级别、工作区级别；它们的优先级如下：`工作区级别配置 > 项目级别配置 > 用户级别配置 > 系统级别配置`；
			- 使用 Git 命令时，它首先会查找系统级别配置文件，然后查找用户级别的全局配置文件，最后查找每个仓库的 *.git/config* 配置（即项目或者工作区级别）。所有的配置项，从低优先级开始加载，出现冲突时，较高优先级的配置项会覆盖之前的配置
			- 每个级别的配置记录在对应的配置文件中，通过 `git config` 命令设置的配置项也都会写入到对应的配置文件中；详见此表：
			- | 级别 | 路径 | 说明 |
			  | :-----| ----: | :----: |
			  | 系统级 | */etc/gitconfig* | 对系统中所有用户都普遍适用的配置。若使用 `git config` 时用 `--system` 选项，读写的就是这个文件 |
			  | 用户级 | *$HOME/.gitconfig* | 用户目录下的配置文件只适用于该用户。若使用 `git config` 时用 `--global` 选项，读写的就是这个文件 |
			  | 项目级 | *PROJECT/.git/config* | 项目目录中的 *.git/config* 文件：这里的配置仅仅针对当前项目有效。若使用 `git config` 时用 `--local` 选项或省略，读写的就是这个文件 |
			  | 工作区级 | *PROJECT/.git/config* | 这里的配置仅仅针对当前工作区有效。若使用 `git config` 时用 `--worktree` 选项，读写的就是这个文件 |
	- #### `includeIf` 用法
		- 推荐在 Git 的用户级别配置文件中使用 includeIf 配置项来**包含**其它配置文件，Git 在解析配置文件时，会将 `includeIf` 指定的配置文件的内容内联到**包含指令**所在的位置
		- `includeIf` 配置项可指定包含的条件，只有当条件成立时，才会包含指定的配置文件
		- 语法介绍：
			- id:: 62c9478a-dee9-4dc5-b630-9d3c5723269d
			  ```
			  [includeIf "条件类型:匹配模式"]
			      path = 某类别/对应的配置文件1/的路径
			      path = 某类别/对应的配置文件2/的路径
			  ```
			- `"条件类型:匹配模式"` 是 `includeIf` 的条件；只有当条件成立时，才会包含 `path` 选项指定的配置文件
			- **条件类型**和**匹配模式** 用 `:` 分隔
			- **条件类型**共有以下几种：`gitdir`、`gitdir/i`、`onbranch`
				- `gitdir`、`gitdir/i`: 路径匹配模式，表示如果当前 Git 仓库的  *.git*  目录的位置**符合路径匹配模式**, 就加载对应的配置文件（`gitdir/i`表示**匹配模式忽略大小写**）
					- *.git* 目录的位置可能是 Git 自动找到的或是 `$GIT_DIR` 环境变量的值
				- `onbranch`: 分支匹配模式，表示如果我们位于**当前检出的分支名称**与**分支匹配模式匹配**的工作树中，就加载对应的配置文件
			- `匹配模式`采用标准的 glob 通配符再加上 `**` 通配符
			- `path` 用于指定配置文件的路径，可以通过写多个 `path` 来表示包含**多个配置**文件
- ### 注意事项
	- `includeIf` 只在指定目录下的 Git repositories 中工作，而在 non-repo 目录中[不工作](https://stackoverflow.com/questions/64843104/why-gitconfig-includeif-does-not-work)
	- 不要试图省事，直接将用户信息配置在 `includeIf` 部分，这会覆盖前面的用户配置项，也就是下面这种写法
		- ```
		  # $HOME/.gitconfig
		  
		  [user]
		      name = Nick
		      email = user@example.com
		  
		  [includeIf "gitdir/i:~/workspace/private/"]
		  # 如此配置会将上面的用户配置覆盖
		  	[user]
		        name = Fake
		        email = fake@example.com
		  
		  [includeIf "gitdir/i:~/workspace/private/"]
		  # 如此配置不会工作，会使用上面的用户配置项
		    name = Fake
		    email = fake@example.com
		  ```
	- 被 `includeIf` 包含的配置文件的配置项会覆盖 `includeIf` 之前的配置项，`includeIf` 之后的配置项会覆盖被 `includeIf` 包含的配置文件的配置项
		- 优先级是：`包含指令后面的配置项 > 被包含的配置文件的配置项 > 包含指令之前的配置项`
- ### 参考内容
	- [gitconfig includeIf 管理多用户配置](https://einverne.github.io/post/2020/10/gitconfig-includeIf.html)
	- [How to Use .gitconfig's includeIf](https://dzone.com/articles/how-to-use-gitconfigs-includeif)
	- [git-config配置多用户环境以及 includeIf用法](https://www.cnblogs.com/librarookie/p/15697181.html)
	- [git-config#Includes](https://git-scm.com/docs/git-config#_includes)