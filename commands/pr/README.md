# /pr 命令

> 通过 Issue 评论快速创建 Pull Request

## 概述

`/pr` 命令用于在 Issue 中快速创建 Pull Request，支持智能检测源分支、目标分支，自动生成 PR 标题和描述。

## 使用方法

### 基本语法

```bash
/pr [--source <branch>] [--target <branch>] [--title "<title>"] [--content "<content>"] [--draft]
```

### 参数说明

所有参数都是可选的：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--source` | 源分支名称 | 自动检测（匹配 Issue 号的分支） |
| `--target` | 目标分支名称 | 基于源分支类型智能选择 |
| `--title` | PR 标题 | 从 Issue 标题生成 |
| `--content` | PR 描述内容 | 自动生成（包含 Issue 信息） |
| `--draft` | 创建草稿 PR | false（创建正式 PR） |

## 智能默认值

### 源分支检测

按以下优先级自动检测：

1. 查找匹配当前 Issue 号的分支
   - `feature/#123-*`
   - `fix/#123-*`
   - `docs/#123-*`
   - `chore/#123-*`
2. 如果找不到，提示用户使用 `--source` 指定

### 目标分支选择

基于源分支类型智能选择：

| 源分支类型 | 目标分支优先级 |
|-----------|---------------|
| `feature/*` | develop → dev → main → master |
| `fix/*`, `hotfix/*` | main → master |
| `docs/*`, `chore/*` | main → master |
| 其他 | 仓库默认分支 |

### PR 标题生成

如未指定，自动从 Issue 标题生成：

- Issue: "添加用户认证功能"
- PR 标题: "feat: 添加用户认证功能"

### PR 内容生成

自动生成的 PR 描述包含：

- Issue 标题和编号
- Issue 描述摘要
- 提交历史链接
- 测试清单模板

## 使用示例

### 场景 1：全自动创建

```bash
/pr
```

系统将：
1. 检测 Issue #7 的相关分支（如 `feature/#7-issue`）
2. 自动选择目标分支（如 `develop`）
3. 生成 PR 标题和描述
4. 创建正式 PR

### 场景 2：指定目标分支

```bash
/pr --target main
```

将当前 Issue 的分支合并到 `main` 分支。

### 场景 3：自定义标题

```bash
/pr --title "feat: 实现 OAuth 2.0 认证"
```

使用自定义标题，其他参数自动生成。

### 场景 4：创建草稿 PR

```bash
/pr --draft
```

创建草稿 PR，完成开发后可转为正式 PR。

### 场景 5：完全指定

```bash
/pr --source feature/#7-oauth --target develop --title "feat: OAuth 认证" --content "实现 OAuth 2.0 认证流程"
```

## 测试场景

### 测试场景 1：自动检测成功

**前置条件**：
- Issue #7 存在
- 分支 `feature/#7-issue` 存在且有新提交

**执行命令**：
```bash
/pr
```

**预期结果**：
- 自动检测源分支为 `feature/#7-issue`
- 自动选择目标分支 `develop`
- 创建 PR 成功

### 测试场景 2：无法检测源分支

**前置条件**：
- Issue #8 存在
- 没有匹配 #8 的分支

**执行命令**：
```bash
/pr
```

**预期结果**：
- 提示错误：无法检测源分支
- 建议使用 `--source` 参数

### 测试场景 3：分支间无新提交

**前置条件**：
- 源分支和目标分支内容相同

**执行命令**：
```bash
/pr --source feature/#7-issue --target main
```

**预期结果**：
- 提示错误：没有新的提交
- 不创建 PR

### 测试场景 4：PR 已存在

**前置条件**：
- 已存在相同源和目标分支的 PR

**执行命令**：
```bash
/pr
```

**预期结果**：
- 提示 PR 已存在
- 返回现有 PR 链接

### 测试场景 5：创建草稿 PR

**执行命令**：
```bash
/pr --draft --title "WIP: 新功能开发"
```

**预期结果**：
- 创建草稿状态的 PR
- 提示用户完成后点击 "Ready for review"

## 工作流程

1. **解析命令**
   - 提取所有参数
   - 验证参数格式

2. **获取 Issue 信息**
   - 读取标题、描述、标签

3. **检测源分支**
   - 优先使用指定分支
   - 自动匹配 Issue 相关分支

4. **选择目标分支**
   - 优先使用指定分支
   - 基于源分支类型智能选择

5. **生成 PR 信息**
   - 生成标题（类型前缀 + Issue 标题）
   - 生成描述（Issue 信息 + 提交历史）

6. **创建 Pull Request**
   - 检查是否已存在
   - 创建新 PR
   - 添加标签和分配人

7. **反馈结果**
   - 成功：返回 PR 链接
   - 失败：提供错误信息和建议

## 返回信息

### 成功创建

```markdown
### ✅ Pull Request 创建成功！

**PR**: #8
**链接**: https://github.com/owner/repo/pull/8
**源分支**: `feature/#7-issue`
**目标分支**: `develop`

✅ PR 已准备好接受审查。

### 后续步骤
1. 等待 CI 检查通过
2. 请求代码审查
3. 合并到 `develop` 分支
```

### 草稿 PR

```markdown
### 📝 草稿 PR 创建成功！

**PR**: #8
**链接**: https://github.com/owner/repo/pull/8
**源分支**: `feature/#7-issue`
**目标分支**: `develop`

⚠️ 这是一个草稿 PR，完成开发后请点击 "Ready for review" 按钮。
```

### PR 已存在

```markdown
### ⚠️ Pull Request 已存在

**PR**: #8
**链接**: https://github.com/owner/repo/pull/8
**分支**: `feature/#7-issue` → `develop`
```

## 权限要求

- `contents: write` - 读取分支和提交信息
- `pull-requests: write` - 创建 Pull Request
- `issues: write` - 读取 Issue 信息和添加评论

## 注意事项

1. **必须有新提交** - 源分支必须有目标分支没有的提交
2. **分支必须存在** - 源和目标分支都必须已推送到远程
3. **Issue 关联** - PR 会自动关联当前 Issue（Closes #xxx）
4. **标签继承** - PR 会继承 Issue 的标签
5. **自动分配** - PR 会分配给命令执行者

## 最佳实践

1. **开发流程**
   ```bash
   /start issue           # 创建分支
   # ... 开发和提交代码 ...
   /pr                    # 创建 PR
   ```

2. **使用草稿 PR**
   - 开发初期使用 `--draft` 创建草稿
   - 完成后转为正式 PR

3. **明确的标题**
   - 使用语义化的提交规范
   - feat: 新功能
   - fix: 修复
   - docs: 文档
   - chore: 杂项

4. **及时更新**
   - PR 创建后继续提交会自动更新
   - 保持 PR 描述与实际改动同步

## 故障排除

### 无法检测源分支

**问题**：提示 "Could not find a branch for issue #xxx"

**解决**：
1. 确认分支命名符合规范（如 `feature/#123-xxx`）
2. 使用 `--source` 明确指定分支名

### 没有新提交

**问题**：提示 "No commits to create PR"

**解决**：
1. 确认已提交代码：`git status`
2. 推送到远程：`git push`
3. 检查分支差异：`git log target..source`

### 分支不存在

**问题**：提示 "branch does not exist"

**解决**：
1. 检查分支名拼写
2. 确认分支已推送：`git push -u origin branch-name`
3. 拉取最新：`git fetch origin`

## 与其他命令配合

### 完整工作流

```bash
# 1. 开始开发
/start issue

# 2. 开发完成后运行测试
/test

# 3. 创建 PR
/pr

# 4. PR 中添加变更记录
/changeset minor "新增用户认证功能"

# 5. 合并后发布
/release
/publish
```

### 快速修复流程

```bash
# 1. 创建修复分支
/start issue --from-branch main

# 2. 修复并测试
/test

# 3. 直接创建到 main 的 PR
/pr --target main --title "fix: 紧急修复登录问题"
```