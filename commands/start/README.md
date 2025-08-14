# /start 命令

> 快速启动开发工作流

## 概述

`/start` 命令用于从 Issue 快速开始开发工作，自动创建规范的分支并更新 Issue 状态。

## 使用方法

### 基本语法

```bash
/start issue <issue_number> [--from-branch <branch_name>]
```

### 参数说明

- `issue_number`: Issue 编号（必需）
- `--from-branch`: 指定基础分支（可选，默认为 `main`）

## 使用示例

### 1. 从默认分支开始

```bash
/start issue 123
```

创建分支 `feature/#123-issue`，基于 `main` 分支。

### 2. 指定基础分支

```bash
/start issue 124 --from-branch develop
```

创建分支 `fix/#124-issue`，基于 `develop` 分支。

### 3. 基于其他 feature 分支

```bash
/start issue 125 --from-branch feature/#120-base
```

创建分支 `feature/#125-issue`，基于 `feature/#120-base` 分支。

## 分支命名规则

### 前缀映射

| Issue 类型 | 分支前缀 |
|-----------|---------|
| `type: feature` | `feature/` |
| `type: bug` | `fix/` |
| `type: enhancement` | `feature/` |
| `type: docs` | `docs/` |
| `type: refactor` | `chore/` |

### 命名格式

- **英文标题**: `{prefix}/#{issue_number}-{slug}`
  - 例: `feature/#123-user-login`
  
- **中文标题**: `{prefix}/#{issue_number}-issue`
  - 例: `feature/#123-issue`

## 工作流程

1. **解析命令**
   - 提取 Issue 编号
   - 确定基础分支

2. **获取 Issue 信息**
   - 读取标题、标签
   - 判断类型和优先级

3. **生成分支名**
   - 根据类型选择前缀
   - 处理中文标题

4. **创建分支**
   - 从指定基础分支创建
   - 推送到远程仓库

5. **更新 Issue**
   - 添加 `in-progress` 标签
   - 分配给执行者
   - 添加进度说明

## 返回信息

### 成功响应

```markdown
### 🚀 Development Started

✅ **Branch created**: `feature/#123-issue`
📌 **Base branch**: `main`

### Next steps:
```bash
git fetch origin
git checkout feature/#123-issue
```

### When ready to submit:
1. Commit your changes
2. Push to the branch
3. Create a Pull Request to `main`
4. Link this issue in the PR description using `Closes #123`
```

### 分支已存在

```markdown
⚠️ **Branch already exists**: `feature/#123-issue`

You can switch to it with:
```bash
git fetch origin
git checkout feature/#123-issue
```
```

## 权限要求

- `issues: write` - 更新 Issue 状态
- `contents: write` - 创建和推送分支

## 注意事项

1. **Issue 必须存在** - 命令会验证 Issue 是否存在
2. **基础分支必须存在** - 指定的 from-branch 必须已存在
3. **分支名唯一** - 如果分支已存在，不会重复创建
4. **自动分配** - 如果 Issue 未分配，会自动分配给命令执行者

## 最佳实践

1. **及时创建分支** - Issue 确认后立即使用 `/start issue` 开始工作
2. **选择正确基础** - 根据工作流选择合适的基础分支
3. **保持 Issue 更新** - 开发过程中持续更新 Issue 进度
4. **链接 PR** - 创建 PR 时使用 `Closes #xxx` 关联 Issue

## 故障排除

### 命令无响应

检查：
- 是否在 Issue 评论中使用（不能在 PR 中）
- 命令格式是否正确
- GitHub Actions 是否启用

### 分支创建失败

可能原因：
- 基础分支不存在
- 没有推送权限
- 网络连接问题

### Issue 更新失败

可能原因：
- `in-progress` 标签不存在
- 没有 Issue 写入权限