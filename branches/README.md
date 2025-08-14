# 分支管理系统

> 自动化的 Git 分支策略配置和保护规则

## 目录结构

```
branches/
├── protection/           # 分支保护规则
│   ├── main.yml         # 主分支保护
│   ├── develop.yml      # 开发分支保护
│   └── default.yml      # 默认保护规则
├── automation/          # 自动化工作流
│   ├── auto-merge.yml   # 自动合并
│   ├── branch-sync.yml  # 分支同步
│   └── cleanup.yml      # 自动清理
├── scripts/             # 管理脚本
│   ├── setup.sh         # 初始化分支
│   └── protect.js       # 配置保护规则
└── strategies/          # 分支策略模板
    ├── github-flow.yml  # GitHub Flow
    ├── git-flow.yml     # Git Flow
    └── dual-flow.yml    # 双主线策略
```

## 快速开始

### 1. 初始化分支策略

```bash
# 运行设置脚本
./branches/scripts/setup.sh

# 选择分支策略
Select branching strategy:
1) GitHub Flow (简单)
2) Dual Flow (推荐)
3) Git Flow (完整)
> 2
```

### 2. 自动创建的分支结构

```
main (protected)
  └── develop (protected)
       ├── feature/* (规范)
       ├── fix/* (规范)
       └── docs/* (规范)
```

## 分支策略配置

### Dual Flow（推荐）

```yaml
# branches/strategies/dual-flow.yml
strategy: dual-flow
branches:
  main:
    description: 生产分支，稳定版本
    protected: true
    source: develop
    
  develop:
    description: 开发主线，集成测试
    protected: true
    source: feature/*, fix/*
    
  feature/*:
    description: 功能开发
    base: develop
    merge_to: develop
    
  fix/*:
    description: 问题修复
    base: develop
    merge_to: develop
    
  hotfix/*:
    description: 紧急修复
    base: main
    merge_to: [main, develop]
```

## 分支保护规则

### Main 分支保护

```yaml
# branches/protection/main.yml
name: main
protection_rules:
  # 基础保护
  require_pull_request: true
  required_approving_review_count: 2
  dismiss_stale_reviews: true
  require_code_owner_reviews: true
  
  # 状态检查
  required_status_checks:
    strict: true  # 必须基于最新代码
    contexts:
      - continuous-integration/test
      - continuous-integration/lint
      - continuous-integration/typecheck
      - continuous-integration/security
      - changeset-bot
  
  # 合并规则
  enforce_admins: false
  require_linear_history: true
  allow_force_pushes: false
  allow_deletions: false
  
  # 限制推送
  restrictions:
    users: []
    teams: ["maintainers"]
    apps: ["github-actions"]
```

### Develop 分支保护

```yaml
# branches/protection/develop.yml
name: develop
protection_rules:
  # 基础保护
  require_pull_request: true
  required_approving_review_count: 1
  dismiss_stale_reviews: true
  
  # 状态检查
  required_status_checks:
    strict: false
    contexts:
      - continuous-integration/test
      - continuous-integration/lint
      - changeset-bot
  
  # 合并规则
  enforce_admins: false
  require_linear_history: false
  allow_force_pushes: false
  allow_deletions: false
```

## 自动化工作流

### 自动合并

```yaml
# branches/automation/auto-merge.yml
name: Auto Merge

on:
  pull_request:
    types: [labeled, unlabeled, synchronize, opened, reopened]
  check_suite:
    types: [completed]

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    steps:
      - name: Auto merge Dependabot PRs
        uses: pascalgn/merge-action@v0.15.0
        if: contains(github.event.pull_request.labels.*.name, 'automerge')
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          MERGE_METHOD: squash
          MERGE_COMMIT_MESSAGE: pull-request-title
```

### 分支同步

```yaml
# branches/automation/branch-sync.yml
name: Branch Sync

on:
  push:
    branches: [main]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Sync develop with main
        run: |
          git fetch origin
          git checkout develop
          git merge origin/main --no-edit
          git push origin develop
```

## 设置脚本

```bash
#!/bin/bash
# branches/scripts/setup.sh

echo "🎯 GitHub 分支策略设置"
echo ""
echo "选择分支策略:"
echo "1) GitHub Flow (简单)"
echo "2) Dual Flow (推荐)"
echo "3) Git Flow (完整)"
read -p "> " choice

case $choice in
  1)
    strategy="github-flow"
    ;;
  2)
    strategy="dual-flow"
    ;;
  3)
    strategy="git-flow"
    ;;
  *)
    echo "无效选择"
    exit 1
    ;;
esac

echo "📋 应用策略: $strategy"

# 创建必要的分支
if [ "$strategy" = "dual-flow" ]; then
  git checkout -b develop main 2>/dev/null || git checkout develop
  git push -u origin develop
fi

# 应用分支保护
node branches/scripts/protect.js --strategy=$strategy

echo "✅ 分支策略设置完成!"
```

## 分支命名规范

```yaml
# branches/naming.yml
patterns:
  feature:
    pattern: "^feature/[a-z0-9-]+$"
    example: "feature/user-authentication"
    description: "新功能开发"
    
  fix:
    pattern: "^fix/[a-z0-9-]+$"
    example: "fix/memory-leak"
    description: "问题修复"
    
  hotfix:
    pattern: "^hotfix/[a-z0-9-]+$"
    example: "hotfix/critical-bug"
    description: "紧急修复"
    
  docs:
    pattern: "^docs/[a-z0-9-]+$"
    example: "docs/api-reference"
    description: "文档更新"
    
  chore:
    pattern: "^chore/[a-z0-9-]+$"
    example: "chore/update-deps"
    description: "日常维护"
    
  release:
    pattern: "^release/v[0-9]+\\.[0-9]+\\.[0-9]+$"
    example: "release/v1.2.0"
    description: "发布准备"
```

## 集成到 CI/CD

### PR 检查

```yaml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  branch-check:
    runs-on: ubuntu-latest
    steps:
      - name: Check branch naming
        run: |
          branch="${{ github.head_ref }}"
          if ! echo "$branch" | grep -qE "^(feature|fix|docs|chore|hotfix)/[a-z0-9-]+$"; then
            echo "❌ 分支名不符合规范"
            echo "请使用: feature/xxx, fix/xxx, docs/xxx"
            exit 1
          fi
          
      - name: Check merge direction
        run: |
          base="${{ github.base_ref }}"
          head="${{ github.head_ref }}"
          
          # feature/fix 只能合并到 develop
          if [[ "$head" =~ ^(feature|fix)/ ]] && [ "$base" != "develop" ]; then
            echo "❌ feature/fix 分支只能合并到 develop"
            exit 1
          fi
          
          # develop 只能合并到 main
          if [ "$head" = "develop" ] && [ "$base" != "main" ]; then
            echo "❌ develop 只能合并到 main"
            exit 1
          fi
```

## 使用方法

### 在新项目中使用

```bash
# 1. 添加为子模块
git submodule add https://github.com/your/github-workflows .github/workflows-lib

# 2. 运行设置
.github/workflows-lib/branches/scripts/setup.sh

# 3. 复制工作流
cp -r .github/workflows-lib/branches/automation/* .github/workflows/
```

### 自定义配置

```yaml
# .github/branch-config.yml
extends: dual-flow  # 继承基础策略

# 覆盖特定规则
overrides:
  main:
    required_approving_review_count: 3  # 需要 3 个审核
  develop:
    required_approving_review_count: 2  # 需要 2 个审核

# 添加自定义分支
custom_branches:
  staging:
    base: develop
    protection: medium
```

## 最佳实践

1. **保持分支短期存活**
   - feature 分支: < 1 周
   - fix 分支: < 3 天
   - hotfix 分支: < 1 天

2. **定期清理**
   - 自动删除已合并分支
   - 清理过期分支（> 30 天）

3. **提交规范**
   - 使用 conventional commits
   - 每个 PR 包含 changeset

4. **代码审查**
   - 至少 1 人审查（develop）
   - 至少 2 人审查（main）

## 常见问题

### Q: 如何修改分支保护规则？

编辑对应的 YAML 文件，然后运行：
```bash
node branches/scripts/protect.js --branch=main
```

### Q: 如何处理冲突的合并？

```bash
# develop 落后于 main
git checkout develop
git merge main --no-ff
git push origin develop
```

### Q: 如何创建紧急修复？

```bash
# 基于 main 创建 hotfix
git checkout -b hotfix/critical-bug main
# 修复后合并到 main 和 develop
```