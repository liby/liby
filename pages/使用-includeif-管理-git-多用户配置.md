title:: 使用 includeIf 管理 Git 多用户配置
type:: [[Post]]

- ### 前言
	- 我们通常会拥有公司或者个人的多个 GitHub/GitLab 账户，在不同项目下开发时，commit 的用户名和邮箱是不同的
		- 例如公司项目中，使用的是真实姓名+公司邮箱，而在 Side Project 中使用的是个人邮箱和昵称别名
	- 之前我会在全局的`$HOME/.gitconfig`  中配置我的个人邮箱和昵称别名，当克隆新项目到本地时再根据项目的归属来设置项目内的用户信息
		- 虽然可以使用 `alias` 一键完成设置操作，但克隆仓库和新建仓库的频率没有那么频繁，往往会忘记这个事情，导致 commit 时提交的用户信息不正确（这里不讨论 Husky 相关）
- ### 简单介绍
	- 在 2017 年， `includeIf` 配置随着 Git 的 2.13.0 版本被发布，可以为不同目录下的 Git 仓库提供额外的配置文件，实现不同的仓库使用不同的用户名和邮箱；使用方式：
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
		-
- ### `includeIf` 用法
	- `"条件类型:匹配模式"` 是 `includeIf` 的条件；只有当条件成立时，才会包含 `path` 选项指定的配置文件
	- **条件类型** 和 **匹配模式** 用 `:` 分隔
	- **条件类型** 共有以下几种：`gitdir`、`gitdir/i`、`onbranch`
		- `gitdir`、`gitdir/i`: 路径匹配模式，表示如果当前 Git 仓库的  *.git*  目录的位置**符合路径匹配模式**, 就加载对应的配置文件（`gitdir/i`表示**匹配模式忽略大小写**）
		- *.git* 目录的位置可能是 Git 自动找到的或是 `$GIT_DIR` 环境变量的值
		- `onbranch`: 分支匹配模式，表示如果我们位于**当前检出的分支名称**与**分支匹配模式匹配**的工作树中，就加载对应的配置文件
		- `匹配模式`采用标准的 glob 通配符再加上**表示任务路径**的通配符 `**`
		- `path` 用于指定配置文件的路径
		  可以通过写多个 `path` 来表示包含**多个配置**文件
- ### 注意
	- `includeIf` 只在指定目录下的 repositories 中工作，而在 non-repo 目录中[不工作](https://stackoverflow.com/questions/64843104/why-gitconfig-includeif-does-not-work)
- ### 参考
	- [gitconfig includeIf 管理多用户配置](https://einverne.github.io/post/2020/10/gitconfig-includeIf.html)
	- [How to Use .gitconfig's includeIf](https://dzone.com/articles/how-to-use-gitconfigs-includeif)
	- [git-config配置多用户环境以及 includeIf用法](https://www.cnblogs.com/librarookie/p/15697181.html)
	- [git-config#Includes](https://git-scm.com/docs/git-config#_includes)