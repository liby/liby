- 喂喂喂，人到齐了吗？
- 今天来给大家介绍一种管理和同步 dotfiles 的方法：bare Git repository，这个方法也是我最初在 [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles) 一文学到的，从标题可以看到作者自信满满的称赞说：这是存储 dotfiles 的最佳方式
-
- ### 介绍 一下标题中提到的两个关键词
- #### 什么是 Git Bare Repo
	- 裸仓库？通俗的来讲，我们每天都在用的  Git ，有一个 *.git* 目录。其实在 *.git* 目录里面的才叫 repository ，外面的实际是工作区副本（working copy） ，是 repository 里的某一个版本的拷贝
	- 所谓的 bare repository，就是没有工作区副本的 repository，比如 GitHub 应该就是在服务器上存了裸仓库：它只需要保存 Git 数据就行了
		- Git 数据包含了已跟踪的文件的状态以及修改记录。也就是说 commit 过的文件存储在 Git 数据里，而不是工作区里。工作区只是一份检出而已
	- 更详细的解释请戳 [What is a bare git repository?](https://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/)
- #### 什么是 dotfiles
	- 各种程序的配置文件，帮助这些程序管理其功能；之所以命名为 dotfiles，是因为每个文件和目录都以 `.` 开头，也是以此前缀来将它们与普通文件和目录区分开来
	- 在基于 Unix 的系统中，dotfiles 默认被操作系统隐藏
	- 常见的 dotfiles：`.bashrc`、`.zshrc`、`.vimrc`、`.gitconfig`、`.config` 等等
-
- ### 为什么要存储和同步 dotfiles
	- dotfiles 是属于你个人的，当你花了足够多的时候来调整你的配置文件，规划了最适合你的工作流程、审美和偏好设置，最终拥有一个能帮你事半功倍的开发环境
	- 如果在你花了那么多时间后，你现在不得不切换到一个新的、不同的机器上呢？是否意味着你必须从头再来？你会对你所有的设置和命令都烂熟于心吗？或者，如果你有多台设备，而你希望你的配置在这些设备间共享，那要怎么做？
	- 软件开发的主要目标之一就是使重复性的工作自动化，所以需要有一种方式来帮助我们存储和同步 dotfiles，这样我们的所有设置和偏好都可以跨设备共享
-
- ### 如何使用 Git Bare Repo 来管理 dotfiles
	- 目前比较流行的做法就是[使用 Git 来管理 dotfiles](https://dotfiles.github.io/)，借助 orphan branch 还可以给不同系统/设备建立不同的分支，分开管理，一般来说使用 Git 管理不外乎 3 个步骤：
		- 1. 建立一个仓库文件夹
		  2. 把所有 dotfiles 移动到仓库里
		  3. 在原来的位置建立一个软链接
	- #### 使用 Git Bare Repo 来管理有什么优点
		- 仅在 `$HOME` 里创建一个目录，可以在原地跟踪 dotfiles，不需要创建符号链接，没人希望给一堆文件手动建立软链接吧
		- Git 是唯一的依赖项，同时可以享受版本控制的好处，像 [GNU Stow](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html) 就需要额外安装依赖
		- 设置完成后，管理命令都是基本的 `git` 操作，学习成本较少
			- 没有工作区不代表不能执行常规的 Git 操作，只不过我们需要通过选项 `--work-tree` 来指定一下工作目录。这也是无需移动 dotfiles 的关键所在
	- #### 初始化
		- ```
		  # 初始化 Git Bare Repository
		  git init --bare $HOME/.dotfiles
		  
		  # 创建 alias，方便执行操作
		  alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
		  
		  # 不显示工作区（$HOME）未跟踪的文件
		  dot config --local status.showUntrackedFiles no
		  ```
		- 如果不设置 `config config --local status.showUntrackedFiles no` 的话，运行 `dot status` 你会发现列出来一大堆 untracked files，因为 `$HOME` 下所有文件都还没加入 Git 跟踪，但我们本意也不是要跟踪所有文件，这样全部列出来看着很乱
	- #### 使用
		- 至此我们完成了裸仓库的创建，可以像日常使用 Git 那样来直接管理你的目标文件，例如：
			- ```
			  # 添加 dotfile
			  dot add .zshrc
			  dot commit -m "chore: 🔧 add .zshrc"
			  
			  # 配置远程仓库
			  dot remote add origin <git_url>
			  
			  # 推送 commit 到远程仓库，同时将远程仓库与本地的 master 分支关联
			  # 关联以后，推送 commit 就只需要输入 dot push
			  dot push -u origin master
			  ```
	- #### 恢复
		- 在其他设备上或新系统上运行下列命令：
			- ```
			  git clone --bare <git_url> $HOME/.dotfiles
			  alias dot="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
			  dot config --local status.showUntrackedFiles no
			  
			  #  checkout 一下，就可以恢复所有文件了：
			  dot checkout
			  ```
		- 如果某些文件已经存在了，则会报错：
			- ```
			  error: The following untracked working tree files would be overwritten by checkout:
			  	.zshrc
			  Please move or remove them before you can switch branches.
			  Aborting
			  ```
			- 这种情况需要你备份后覆盖，然后手动合并
		- Shortcut(Optional)
			- 对于上面这些步骤，操作起来还是比较繁琐的；有一些并不是经常使用的命令，所以也不容易记得。因此，我们可以写一个脚本来达到一劳永逸的效果，就像 [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles#:~:text=you%20can%20create%20a%20simple%20script) 中提到的那样：
				- 1. 创建一个脚本
				  2. 存储为代码片段，可以使用 https://paste.gg/ 之类的网站
				  3. 为其创建一个短链接
- ### 其他方案
	- 除了上面提到的一些方案，还有一些我只听过，但完全没有尝试过的方法，比如：
		- [TheLocehiliosan/yadm: Yet Another Dotfiles Manager](https://github.com/TheLocehiliosan/yadm)
		- [【譯】使用 GNU stow 管理你的點文件](https://farseerfc.me/using-gnu-stow-to-manage-your-dotfiles.html)
		- [rcm, an rc file manager](https://thoughtbot.com/blog/rcm-for-rc-files-in-dotfiles-repos)
-
- ### 写在最后
	- 我现在有个重要的事情想和大家商量一下，你们认为手指最大的作用是用来做什么事情呢？不要想歪到什么 KP、YZ、CPG 上面喔，正经一点
	- 当霍金还剩下手指能动弹的时候，他在交流，他在传递信息，他在为人类星辰大海的征途绘制蓝图。而我们坐在电脑前，也只用手指操控键盘、鼠标和触摸板时，为什么就不能做一些更有意义的事情呢，把爱与快乐传播出去，点点赞，投投币，发发评论
	- 我今天在这里，呼吁大家，创造美好，从我做起，点赞投币评论三连唷～
-
- ### 参考
- [Dotfiles - ArchWiki](https://wiki.archlinux.org/title/Dotfiles)
- [Dotfiles – What is a Dotfile and How to Create it in Mac and Linux](https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/)
- [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
- [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)
- [使用 Git Bare Repository 管理 Dotfiles](https://shinta.ro/posts/manage-dotfiles-with-git/)
- [Dotfiles 管理-使用 git 裸仓库](https://chenhe.me/post/dotfiles%E7%AE%A1%E7%90%86-%E4%BD%BF%E7%94%A8git%E8%A3%B8%E4%BB%93%E5%BA%93/)