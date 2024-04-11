title:: 使用 Difftastic 取代命令行工具 diff
type:: [[Post]]
status:: [[Draft]]

- Difftastic 是一个实验性的 diff 工具，根据文件的语法进行比较。如果一个文件有一个不被识别的扩展名，Difftastic 会使用一个带有单词高亮的文本差异。
-
- ### 简单的介绍
	- Difftastic 是一个实验性的差异工具，可以根据文件的语法比较文件。
	- 它与 Delta（也是由 Rust 实现的 diff 工具） 相比：Delta 只是很好地比较格式化上的差异，而 Difftastic 能够理解：
		- 1. Difftastic 理解嵌套
		  2. Difftastic 了解哪些行应该对齐
		  3. Difftastic 理解换行没有意义
- ### 已知的缺点
	- Performance：Difftastic 在有大量变化的文件上的扩展性相对较差，而且会使用大量的内存
	- Display：Difftastic 有一个并排的显示方式，通常效果很好，但可能会让人困惑
	- Robustness：Difftastic 经常有修复崩溃的版本
-
- ### 用法
	- Diffing Files：`difft sample_files/before.js sample_files/after.js`
		- Difftastic 使用文件扩展名来决定使用哪个解析器
	- Diffing Directories：`difft sample_files/dir_before/ sample_files/dir_after/`
		- Difftastic 将递归遍历这两个目录，区分具有相同名称的文件
		- 在区分包含许多未更改文件的目录时，`--skip-unchanged` 选项非常有用
	- Language Detection：
		- Difftastic 根据文件的扩展名、文件名和第一行的内容来猜测所使用的语言
		- 你可以通过传递 `--language` 选项来覆盖语言检测。Difftastic会将输入的文件视为具有该扩展名的文件，而忽略其他语言检测的方法
			- ```
			  difft --language cpp before.c after.c
			  ```
-
- 配合 Git 食用
	- Git 支持[外部比较工具](https://git-scm.com/docs/diff-config#Documentation/diff-config.txt-diffexternal)。可以将 `GIT_EXTERNAL_DIFF`用于一次性 Git 命令
		- ```
		  $ GIT_EXTERNAL_DIFF=difft git diff
		  $ GIT_EXTERNAL_DIFF=difft git log -p --ext-diff
		  $ GIT_EXTERNAL_DIFF=difft git show e96a7241760319 --ext-diff
		  ```
	- 如果你想在默认情况下使用 Difftastic，请使用 `git config` 进行设置
		- ```
		  # Set git configuration for the current repository.
		  $ git config diff.external difft
		  
		  # Set git configuration for all repositories.
		  $ git config --global diff.external difft
		  ```
		- 运行以上命令后，`git diff` 将自动使用 Difftastic。其他 `git` 命令需要 `--ext-diff` 才能使用Difftastic
			- ```
			  $ git diff
			  $ git log -p --ext-diff
			  $ git show e96a7241760319 --ext-diff
			  ```