# GitHub Workflow 配置

此配置由 make.js 自动生成，基于解决方案: **node-opensource**

## 配置信息

- **解决方案**: node-opensource
- **描述**: Node.js 开源项目的 GitHub 工作流
- **分支策略**: dual-flow
- **生成时间**: 2025-08-15T07:10:23.079Z

## 启用的命令

- `/start`
- `/test`
- `/changeset`
- `/release`
- `/publish`

## 自动化事件

- `pr-opened`
- `pr-merged-develop`

## 环境变量

需要在 GitHub Settings > Secrets 中配置：

- **NPM_TOKEN**: NPM 发布令牌
