# GitHub Workflows 测试流程指南

## 📋 概述

本文档描述了 GitHub Workflows 项目的开发和测试流程。项目分为两个部分：
- **主仓库**：工作流模板的开发仓库
- **测试仓库**（temp/test）：用于验证工作流的测试环境

## 🏗️ 项目结构

```
GithubWorkflows/                 # 主仓库（模板开发）
├── commands/                    # 命令工作流模板
│   ├── changeset/
│   ├── release/
│   ├── publish/
│   └── ...
├── events/                      # 事件触发器模板
│   ├── pr-opened-develop/
│   ├── pr-opened-main/
│   └── ...
├── solutions/                   # 解决方案配置
├── make.js                      # 工作流生成器
└── temp/test/                   # 测试仓库（测试环境）
    └── .github/workflows/       # 生成的工作流文件
```

## 🔄 正确的工作流程

### 1. 开发阶段（在主仓库）
```bash
# 在主仓库修改模板
cd /path/to/GithubWorkflows
vim commands/release/release.yml     # 修改命令工作流
vim events/pr-opened-main/pr-opened-main.yml  # 修改事件触发器
```

### 2. 部署阶段（直接推送到 GitHub）
```bash
# 克隆一个临时目录用于部署
git clone git@github.com:Deepractice/GithubWorkflows.git temp/deploy
cd temp/deploy
git checkout main

# 生成工作流
node ../make.js node-opensource .

# 提交并推送
git add -A
git commit -m "sync: 更新工作流"
git push origin main

# 清理部署目录
cd ..
rm -rf deploy
```

### 3. 测试阶段（使用 feature 分支）
```bash
# 在本地创建 feature 分支进行测试
cd temp/test  # 或者任何测试目录
git checkout -b feature/test-xxx

# 创建测试代码
echo "test" > test.txt
git add test.txt
git commit -m "test: 触发工作流测试"
git push origin feature/test-xxx

# 在 GitHub 上创建 PR，测试工作流
# 注意：temp/test 下只应该有 feature 分支，不应该有 main/develop
```

## ⚠️ 重要原则

### ✅ 正确做法

1. **所有修改都在主仓库进行** - commands/、events/ 等目录
2. **main 分支是唯一事实来源** - 所有工作流从 main 生成
3. **temp/test 只有 feature 分支** - 不应该有 main/develop 等分支
4. **使用 make.js 部署** - 确保工作流的一致性

### ❌ 错误做法

1. 直接在 temp/test 修改工作流文件
2. 在 temp/test 创建 main/develop 分支
3. 手动复制工作流文件
4. 混淆主仓库和测试仓库的职责

## 🚀 快速更新流程

当需要修复或更新工作流时：

```bash
# 1. 在主仓库修改
cd /path/to/GithubWorkflows
vim commands/release/release.yml

# 2. 提交主仓库更改
git add -A
git commit -m "fix: 修复release命令"
git push origin main

# 3. 生成到测试仓库
node make.js node-opensource temp/test

# 4. 部署到测试环境
cd temp/test
git add -A
git commit -m "sync: 更新工作流"
git push origin main

# 5. 测试验证
# 在 GitHub 上的 PR 中执行命令，如 /release beta
```

## 🔍 调试技巧

### 查看当前状态
```bash
# 查看测试仓库使用的工作流版本
cd temp/test
git log --oneline -5

# 验证工作流是否包含修复
grep "特定修复内容" .github/workflows/release.yml
```

### 清理环境
```bash
# 如果环境混乱，重置测试仓库
cd temp/test
git checkout main
git reset --hard origin/main
```

## 📝 注意事项

1. **GitHub Actions 使用目标分支的工作流**
   - PR 向 main 合并 → 使用 main 分支的工作流
   - PR 向 develop 合并 → 使用 develop 分支的工作流

2. **工作流更新后需要推送到 GitHub**
   - 本地修改不会影响 GitHub Actions
   - 必须 push 到远程分支才能生效

3. **测试仓库的分支管理**
   - main：最新的工作流版本
   - develop：开发分支，可能落后于 main
   - release/*：发布分支，用于测试发布流程

## 🆘 常见问题

### Q: 修改了工作流但没有生效？
A: 确认以下步骤：
1. 在主仓库修改了模板文件
2. 运行了 make.js 生成到 temp/test
3. 在 temp/test 提交并推送到正确的分支
4. GitHub PR 的目标分支包含最新工作流

### Q: 测试仓库的分支不同步？
A: 只需要保证 main 分支是最新的：
```bash
cd temp/test
git checkout main
node ../../make.js node-opensource .
git add -A && git commit -m "sync" && git push
```

### Q: 如何添加新的工作流？
A: 在主仓库创建，然后生成：
1. 在 commands/ 或 events/ 创建新模板
2. 更新 solutions/ 中的配置（如需要）
3. 运行 make.js 生成到测试仓库
4. 测试验证

## 📚 相关文档

- [README.md](README.md) - 项目主文档
- [make.js](make.js) - 工作流生成器源码
- [solutions/](solutions/) - 解决方案配置