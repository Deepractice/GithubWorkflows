# GitHub Workflow 配置

此配置由 make.js 自动生成，基于解决方案: **node-opensource**

## 配置信息

- **解决方案**: node-opensource
- **描述**: Node.js 开源项目的 GitHub 工作流
- **分支策略**: dual-flow
<<<<<<< HEAD
- **生成时间**: 2025-08-16T10:31:05.674Z
=======
- **生成时间**: 2025-08-16T10:43:40.032Z
>>>>>>> 6e2b81b2148445d0aa0156f52caad37958a06eb3

## 启用的命令

- `/start`
- `/test`
- `/changeset`
- `/release`
- `/deploy`

## 自动化事件

- `pr-opened-develop`
- `pr-opened-main`
- `pr-merged-develop`
- `pr-merged-main`
- `release-created`

## 环境变量

需要在 GitHub Settings > Secrets 中配置：

- **NPM_TOKEN**: NPM 发布令牌
