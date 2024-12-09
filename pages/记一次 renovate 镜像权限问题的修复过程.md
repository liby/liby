## 问题背景
	- [Renovate Runner](https://gitlab.com/renovate-bot/renovate-runner) 在被下游仓库触发时，renovate job 总是失败，查看日志是因为：EACCES: permission denied，权限问题
		- ```
		   INFO: Renovate is exiting with a non-zero code due to the following logged errors
		         "loggerErrors": [
		           {
		             "name": "renovate",
		             "level": 50,
		             "logContext": "WwZ3VJoGsXjTv08ZnPa1F",
		             "repository": "${PROJECT_ID}",
		             "err": {
		               "errno": -13,
		               "code": "EACCES",
		               "syscall": "open",
		               "path": "/builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/${PROJECT_ID}.json",
		               "message": "EACCES: permission denied, open '/builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/${PROJECT_ID}.json'",
		               "stack": "Error: EACCES: permission denied, open '/builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/${PROJECT_ID}.json'"
		             },
		             "msg": "Repository has unknown error"
		           }
		         ]
		  ```
	- 同事尝试通过设置 `RENOVATE_DOCKER_USER` 修复此问题，在 feature 分支测试通过，但合并到主分支 master 后依然遇到 EACCES: permission denied 报错
- ## 问题排查
	- 追溯最后一次运行正常的任务日志，使用的 renovate 镜像版本是：
		- ```
		  renovate:38.142.7@sha256:8327ee1726142dcc504d349d84c0e7f41656867e598ea7669bb7cf23786610a2
		  ```
	- 追溯第一次出现 EACCES: permission denied 错误的任务日志，使用的 renovate 镜像版本是：
		- ```
		  renovate:39.7.5@sha256:3de010f9d0adee856fd2d2a8085252f2643ffabea1d076ebf4a87038a393a1fc
		  ```
	- 翻看 renovate 的 [release notes](https://github.com/renovatebot/renovate/releases?page=15#:~:text=12021%20instead%20of%201001) 和 [diffs](https://github.com/renovatebot/renovate/compare/38.142.7...39.0.0#diff-f7c67be098bcabe494f61d730e516626b281d730b6daabd87db1401f133b0233)，发现 renovate 在 39.0.0 版本将镜像用户从 UID 1000 改为 UID 12021（release notes 中是使用 12021 替代 1001 应该是 typo 了）
- ## 问题诊断
	- 在 _.gitlab-ci.yml_ 添加详细日志后发现：
		- 在 master 分支上运行时出现 EACCES 权限错误
		- 错误发生在访问缓存文件时：
			- ```
			  /builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/${PROJECT_ID}.json
			  ```
	- 日志分析：
		- ```
		  Restoring cache
		  Checking cache for master-renovate-non_protected...
		  Downloading cache from https://gitlab-ci-cache.s3-us-east-2.amazonaws.com/gitlab_runner/project/${PROJECT_ID}/master-renovate-non_protected  ETag="c62ba41ccef234d6253f4c086b3903b5"
		  Downloading cache 96.66 KB/96.66 KB (69.2 MB/s)                
		  Successfully extracted cache
		  Executing "step_script" stage of the job script
		  00:49
		  $ echo "=== CI Environment Info ===" # collapsed multi-line command
		  === CI Environment Info ===
		  CI_PIPELINE_SOURCE: pipeline
		  CI_PROJECT_PATH: app/renovate-runner
		  CI_PROJECT_ID: ${PROJECT_ID}
		  Trigger Project ID: ${TRIGGER_PROJECT_ID}
		  CI_COMMIT_REF_NAME: master
		  CI_RUNNER_ID: 49
		  $ echo "=== User and Permission Info ===" # collapsed multi-line command
		  === User and Permission Info ===
		  uid=12021(ubuntu) gid=0(root) groups=0(root),999(docker)
		  $ echo "=== Directory Structure and Permissions ===" # collapsed multi-line command
		  === Directory Structure and Permissions ===
		  Base directory:
		  total 0
		  drwxrwxrwx. 3 root root  19 Dec  9 05:01 .
		  drwxrwxrwx. 4 root root 101 Dec  9 05:01 ..
		  drwxrwxrwx. 3 root root  22 Dec  9 05:01 cache
		  Cache directory:
		  total 0
		  drwxrwxrwx. 3 root root 22 Dec  9 05:01 .
		  drwxrwxrwx. 3 root root 19 Dec  9 05:01 ..
		  drwxrwxrwx. 3 root root 24 Dec  9 05:01 renovate
		  Renovate cache:
		  total 0
		  drwxrwxrwx. 3 root root 24 Dec  9 05:01 .
		  drwxrwxrwx. 3 root root 22 Dec  9 05:01 ..
		  drwxr-xr-x. 3 1000 root 20 May 31  2023 repository
		  Repository cache:
		  total 4
		  drwxr-xr-x. 3 1000 root   20 May 31  2023 .
		  drwxrwxrwx. 3 root root   24 Dec  9 05:01 ..
		  drwxr-xr-x. 2 1000 root 4096 Oct 29 07:05 gitlab
		  Gitlab cache:
		  total 160
		  drwxr-xr-x. 2 1000 root  4096 Oct 29 07:05 .
		  drwxr-xr-x. 3 1000 root    20 May 31  2023 ..
		  -rw-r--r--. 1 1000 root  8914 Oct 30 08:32 PROJECT_ID_1.json
		  ...
		  -rw-r--r--. 1 1000 root  8225 Mar  4  2024 PROJECT_ID_93.json
		  $ echo "=== Cache Files Status ===" # collapsed multi-line command
		  === Cache Files Status ===
		  168014201     12 -rw-r--r--   1 1000     root         8914 Oct 30 08:32 /builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/PROJECT_ID_1.json
		  ...
		  168017096     12 -rw-r--r--   1 1000     root         8225 Mar  4  2024 /builds/app/renovate-runner/renovate/cache/renovate/repository/gitlab/PROJECT_ID_93.json
		  ```
		- 缓存文件所有者是 UID 1000
		- 当前进程用户是 UID 12021
		- 文件权限是 `644 (-rw-r--r--)`，其他用户只有读权限
	- 根本原因：
		- Renovate 在 39.0.0 版本将基础镜像用户从 UID 1000 改为 UID 12021
		- 旧的缓存文件（键：`master-renovate-non_protected`）仍然属于 UID 1000
		- 从下游仓库触发时会复用这些旧缓存，导致权限错误
	- 为什么在 feature 分支测试没有 遇到问题：
		- 新分支使用不同的缓存键（即当前 MR 的分支名）
		- 因找不到缓存而创建新的缓存文件
		- 新创建的文件属于正确的 UID 12021
- ## 解决方案
	- 更新缓存键配置，包含新的 UID：
		- ```
		  cache:
		    key: "renovate-cache-uid-12021-${CI_COMMIT_REF_SLUG}"
		  ```
		- 这样强制创建新的缓存，确保所有缓存文件都由正确的用户（UID 12021）创建和拥有