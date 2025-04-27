title:: macOS/launchd/How to Use launchd to Run Services in macOS
type:: [[Post]]
status:: [[DONE]]

- 之前写过一篇 [[macOS/launchd/launchd 踩坑初体验]]，可以说堪堪入门，把服务跑起来就算成功，经过不断的测试和翻阅资料，总算搞明白了之前留下的问题
- 前面说  `load | unload` 命令已经被弃用，文档说推荐用 `bootstrap | bootout | enable | disable` 等命令来代替，下面就来详细讲讲这几个命令
	- `launchctl  bootstrap domain-target [service-path service-path2 ...] | service-target`
		- 加载并运行服务（会立即执行一次）
			- [并不会立即执行一次](https://www.xiebruce.top/983.html)，只有设置了 `RunAtLoad: true` 或者 `keepAlive: true` 才会在加载这些 plist 文件的同时启动 plist 所描述的服务
		- `launchctl bootstrap gui/<user's UID> ~/Library/LaunchAgents/com.company.launchagent.plist`
		- `gui/$UID` 和 plist 文件路径之间有空格，且要带 `.plist` 文件后缀
		- 不知道 UID 可以直接写 `gui/$UID`，也可以通过 `id -u <username>` 来获取具体 ID
		- domain-target 主要有以下几个参数
			- system/[service-name]
			  Targets the system-wide domain or service within. Root privileges are required to make modifications.
			- user/<uid>/[service-name]
			  Targets the user domain or service within. A process running as the target user may make modifications. Root may modify any user’s domain. User domains do not exist on iOS.
			- gui/<uid>/[service-name]
			  Targets the GUI domain or service within. Each GUI domain is associated with a user domain, and a process running as the owner of that user domain may make modifications. Root may modify any GUI domain. GUI domains do not exist on iOS.
	- `launchctl bootout domain-target [service-path service-path2 ...] | service-target`
		- 卸载并禁用服务
		- 你还可以通过不指定路径来卸载用户域中的所有内容，慎用此命令
			- `launchctl bootout gui/<user's UID>`
	- `launchctl enable | disable service-target`
		- 启用｜禁用目标服务
		- `launchctl disable gui/<user's UID>/com.company.launchagent.label`
			- 要注意 `gui/$UID` 和 plist 文件路径之间是用 `/` 相连的，且没有 `.plist` 文件后缀
		- 我看很多文档都说要用 `enable` 来代替之前的 `load` 命令启动服务，实际这是不对的，`load` 命令应该要用 `bootstrap` 来替代，`enable`只是起到启用**被禁用服务**的作用，没有任何 `start` 或者 `run` 的作用
			- 具体可以看这个[讨论串](https://www.reddit.com/r/MacOS/comments/kbko61/comment/hybuaqq/?utm_source=share&utm_medium=web2x&context=3)
	- `launchctl kickstart -k gui/$(id -u)/com.example.app`
		- 重新启动目标服务
- 此外， [LAUNCHCTL 2.0 SYNTAX](https://babodee.wordpress.com/2016/04/09/launchctl-2-0-syntax/) 还提到了一个 `print` 命令 #read
	- 大概就是说，之前都是用 `launchctl list` 列出正在运行的服务/代理，并且还可以用 `grep` 来做筛选
		- `launchctl list | grep pattern`
	- 但是现在不推荐使用 `list` 命令了，有一个与之类似地 `launchctl print`，例如，你想将打印特定用户域下正在运行的所有服务：
		- `launchctl print gui/<user's UID>`
	- 或者打印指定服务的详细信息
		- `launchctl print gui/<user's UID>/com.company.launchagent.label`
	- 值得注意的是，Apple 对此有一个声明
		- > IMPORTANT: This output is NOT API in any sense at all. Do NOT rely on the structure or information emitted for ANY reason. It may change from release to release without warning.
		  > 重要提示：此输出在任何意义上都不是 API。不要因为任何原因依赖于结构或发出的信息。它可能会在没有警告的情况下从一个版本更改到另一个版本。
-