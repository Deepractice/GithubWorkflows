# Git Worktree 工作流程

## 📁 目录结构

```
GithubWorkflows/            # 主目录 - main 分支
├── .github/               # 工作流配置（修复在这里进行）
├── commands/              # 命令定义
├── solutions/             # 解决方案配置
└── temp/                  # Worktree 目录
    └── develop/           # develop 分支工作区

```

## 🔧 工作流程

### 1. 在 main 分支修复问题
```bash
# 当前目录就是 main 分支
pwd  # /Users/sean/Management/ContradictionManagement/projects/GithubWorkflows

# 直接修改文件
vim commands/start/start.yml

# 提交修复
git add .
git commit -m "fix: ..."
git push
```

### 2. 在其他分支操作
```bash
# 进入 develop 分支工作区
cd temp/develop

# 现在在 develop 分支
git status  # On branch develop

# 进行开发工作
vim new-feature.js
git add .
git commit -m "feat: ..."
git push
```

### 3. 管理 Worktree

#### 查看所有 worktree
```bash
git worktree list
```

#### 添加新分支的 worktree
```bash
# 例如添加 release 分支
git worktree add temp/release release/1.0.0
```

#### 删除 worktree
```bash
git worktree remove temp/develop
```

## 📌 注意事项

1. **temp/** 已在 `.gitignore` 中，不会被提交
2. 每个 worktree 是独立的工作区，可以同时操作不同分支
3. 修复总是在 main 上进行，然后 cherry-pick 到其他分支

## 🎯 典型场景

### 场景 1: 修复工作流错误
```bash
# 1. 在主目录（main）修复
vim .github/workflows/start.yml
git commit -am "fix: workflow issue"
git push

# 2. 同步到 develop
cd temp/develop
git pull
git cherry-pick <commit-id>
git push
```

### 场景 2: 开发新功能
```bash
# 在 develop 分支工作
cd temp/develop
git checkout -b feature/new-feature
# ... 开发 ...
git push -u origin feature/new-feature
```

### 场景 3: 创建发布
```bash
# 添加 release 分支的 worktree
git worktree add temp/release release/1.0.0
cd temp/release
# ... 发布流程 ...
```

## 💡 优势

1. **无需切换分支** - 同时操作多个分支
2. **快速修复** - main 始终可用于紧急修复
3. **并行工作** - 可以同时进行开发和修复
4. **清晰分离** - 每个分支有独立的工作目录