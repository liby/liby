## 问题背景
	- [Renovate Runner](https://gitlab.com/renovate-bot/renovate-runner) 在被下游仓库触发时，renovate job 总是失败，查看日志是因为：EACCES: permission denied
	- 同事尝试通过设置 `RENOVATE_DOCKER_USER` 修复此问题，在 feature 分支测试通过，但合并到主分支 master 后依然遇到 EACCES: permission denied 报错