title:: macOS/launchd/launchd 踩坑初体验

- launchd 是通过以 *.plist* 后缀结尾的 xml 文件来定义一个程序的开机自启动的，一般称它为 plist 文件
- plist 文件分别放在以下几个目录：
	- | 类型 | 位置 | 运行用户 |
	  | :-----| ----: | :----: |
	  |用户 Agents|~/Library/LaunchAgents|当前登录用户|
	  |全局 Agents|/Library/LaunchAgents|当前登录用户|
	  |全局 Daemons|/Library/LaunchDaemons|root或指定的用户|
	  |系统 Agents|/System/Library/LaunchAgents|当前登录用户|
	  |系统 Daemons|/System/Library/LaunchDaemons|root或指定的用户|
	- 其中 */System* 目录下的我们不用管，那些是系统本身的一些进程，我们要关注的是以下三个目录：
		- ```
		  ~/Library/LaunchAgents
		  /Library/LaunchAgents
		  /Library/LaunchDaemons
		  ```
		- 只要在这三个目录中的 plist 文件所定义的服务，都会在开机/登录时，自动加载plist文件，且当 plist 文件中设置 `RunAtLoad` 为 `true` 时，会在加载的同时启动 plist 对应的服务。
- launchctl 是 launchd 的管理工具，它用于管理 plist 文件对应的服务的启动、停止、重启等等。
	- 列出已加载的 Job (即 plist 文件)：`launchctl list`
		- ```
		  358 0   com.apple.commerce
		  -   0   com.apple.TMHelperAgent.SetupOffer
		  -   0   com.apple.AddressBook.SourceSync
		  -   0   com.apple.installerauthagent
		  ```
		- 以 `-` 开头的表示虽然加载了，但是未启动，数字开头的表示已启动且这个数字就是它的 pid 。
	- 开机的时候系统会自动加载 LaunchDaemons 目录下的 plist 文件，登入系统时会自动加载两个LaunchAgents 目录中的 plist 文件，你可以对刚刚添加的 plist 做如下操作：
		- 手动加载一个任务：
			- `launchctl load ~/Library/LaunchAgents/com.example.app.plist`
		- 禁用一个任务(加载的反操作)：
			- `launchctl unload ~/Library/LaunchAgents/com.example.app.plist`
		- 启动一个任务：
			- `launchctl start com.example.app`
		- 停止一个任务：
			- `launchctl stop com.example.app`
-