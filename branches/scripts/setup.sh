#!/bin/bash
set -e

# 分支策略设置脚本
# 用于初始化项目的分支策略和保护规则

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BRANCHES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🎯 GitHub 分支策略设置${NC}"
echo ""

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ 错误：当前目录不是 git 仓库${NC}"
    exit 1
fi

# 检查是否有远程仓库
if ! git remote get-url origin > /dev/null 2>&1; then
    echo -e "${RED}❌ 错误：没有配置远程仓库${NC}"
    echo "请先添加远程仓库："
    echo "  git remote add origin <repository-url>"
    exit 1
fi

# 获取仓库信息
REPO_URL=$(git remote get-url origin)
if [[ $REPO_URL == git@github.com:* ]]; then
    REPO_PATH=${REPO_URL#git@github.com:}
    REPO_PATH=${REPO_PATH%.git}
elif [[ $REPO_URL == https://github.com/* ]]; then
    REPO_PATH=${REPO_URL#https://github.com/}
    REPO_PATH=${REPO_PATH%.git}
else
    echo -e "${YELLOW}⚠️  警告：不是 GitHub 仓库，某些功能可能不可用${NC}"
    REPO_PATH=""
fi

if [ -n "$REPO_PATH" ]; then
    REPO_OWNER=$(echo $REPO_PATH | cut -d'/' -f1)
    REPO_NAME=$(echo $REPO_PATH | cut -d'/' -f2)
    echo -e "${GREEN}📦 仓库: ${REPO_OWNER}/${REPO_NAME}${NC}"
fi

echo ""
echo "选择分支策略:"
echo "1) GitHub Flow (简单) - 只有 main + feature 分支"
echo "2) Dual Flow (推荐) - main + develop + feature 分支"
echo "3) Git Flow (完整) - main + develop + feature/release/hotfix"
echo "4) Trunk Based (激进) - 只有 main，频繁合并"
echo "5) 自定义配置"
echo ""
read -p "请选择 [1-5]: " choice

case $choice in
    1)
        STRATEGY="github-flow"
        STRATEGY_NAME="GitHub Flow"
        ;;
    2)
        STRATEGY="dual-flow"
        STRATEGY_NAME="Dual Flow"
        ;;
    3)
        STRATEGY="git-flow"
        STRATEGY_NAME="Git Flow"
        ;;
    4)
        STRATEGY="trunk-based"
        STRATEGY_NAME="Trunk Based Development"
        ;;
    5)
        STRATEGY="custom"
        STRATEGY_NAME="Custom"
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📋 应用策略: ${STRATEGY_NAME}${NC}"
echo ""

# 创建配置文件
CONFIG_FILE=".github/branch-config.yml"
mkdir -p .github

cat > $CONFIG_FILE << EOF
# 分支策略配置
# 自动生成于: $(date)
strategy: $STRATEGY
repository: ${REPO_OWNER}/${REPO_NAME}

# 从模板继承设置
extends: $BRANCHES_DIR/strategies/${STRATEGY}.yml

# 自定义覆盖（根据需要修改）
overrides:
  # 示例：修改 main 分支的审核要求
  # main:
  #   required_approving_review_count: 3
EOF

echo -e "${GREEN}✅ 创建配置文件: $CONFIG_FILE${NC}"

# 根据策略创建必要的分支
echo ""
echo -e "${BLUE}🌿 创建分支...${NC}"

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)

# 确保有 main 分支
if ! git show-ref --verify --quiet refs/heads/main; then
    if git show-ref --verify --quiet refs/heads/master; then
        echo "将 master 重命名为 main..."
        git branch -m master main
    else
        echo "创建 main 分支..."
        git checkout -b main
    fi
else
    git checkout main 2>/dev/null || true
fi

# 根据策略创建额外分支
case $STRATEGY in
    "dual-flow"|"git-flow")
        if ! git show-ref --verify --quiet refs/heads/develop; then
            echo "创建 develop 分支..."
            git checkout -b develop main
            git push -u origin develop 2>/dev/null || echo -e "${YELLOW}⚠️  无法推送到远程（可能需要认证）${NC}"
        else
            echo -e "${GREEN}✓ develop 分支已存在${NC}"
        fi
        git checkout develop 2>/dev/null || true
        ;;
esac

# 推送 main 分支
git push -u origin main 2>/dev/null || echo -e "${YELLOW}⚠️  无法推送到远程（可能需要认证）${NC}"

# 恢复原始分支
git checkout $CURRENT_BRANCH 2>/dev/null || git checkout main

# 应用分支保护规则
echo ""
echo -e "${BLUE}🔒 配置分支保护...${NC}"

# 检查是否安装了 GitHub CLI
if command -v gh &> /dev/null; then
    echo "检测到 GitHub CLI"
    read -p "是否立即应用分支保护规则? [y/N]: " apply_protection
    
    if [[ $apply_protection =~ ^[Yy]$ ]]; then
        # 检查是否已认证
        if gh auth status &> /dev/null; then
            echo "应用保护规则..."
            
            # 使用 Node.js 脚本应用规则
            if command -v node &> /dev/null; then
                node "$SCRIPT_DIR/protect.js" --strategy="$STRATEGY" --repo="${REPO_OWNER}/${REPO_NAME}"
            else
                echo -e "${YELLOW}⚠️  需要 Node.js 来应用保护规则${NC}"
                echo "请安装 Node.js 后运行："
                echo "  node $SCRIPT_DIR/protect.js --strategy=$STRATEGY"
            fi
        else
            echo -e "${YELLOW}⚠️  GitHub CLI 未认证${NC}"
            echo "请先运行: gh auth login"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  未安装 GitHub CLI${NC}"
    echo "安装 GitHub CLI 后可以自动配置分支保护："
    echo "  brew install gh  # macOS"
    echo "  gh auth login"
    echo "  node $SCRIPT_DIR/protect.js --strategy=$STRATEGY"
fi

# 创建示例 PR 模板
PR_TEMPLATE=".github/PULL_REQUEST_TEMPLATE.md"
if [ ! -f "$PR_TEMPLATE" ]; then
    cat > $PR_TEMPLATE << 'EOF'
## 📝 描述
<!-- 简要描述这个 PR 的改动 -->

## 🎯 改动类型
- [ ] 🐛 Bug 修复
- [ ] ✨ 新功能
- [ ] 📝 文档更新
- [ ] 🎨 代码重构
- [ ] ⚡ 性能优化
- [ ] ✅ 测试相关
- [ ] 🔧 配置修改

## ✅ 检查清单
- [ ] 代码已本地测试
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] 遵循了代码规范
- [ ] 添加了 changeset（如需要）

## 📸 截图（如适用）
<!-- 添加相关截图 -->

## 🔗 相关 Issue
<!-- 关联的 Issue 编号 -->
Closes #

## 📚 测试步骤
<!-- 描述如何测试这些改动 -->
1. 
2. 
3. 
EOF
    echo -e "${GREEN}✅ 创建 PR 模板: $PR_TEMPLATE${NC}"
fi

# 总结
echo ""
echo -e "${GREEN}🎉 分支策略设置完成！${NC}"
echo ""
echo "📋 已完成："
echo "  ✅ 创建配置文件: $CONFIG_FILE"
echo "  ✅ 创建必要的分支"
echo "  ✅ 创建 PR 模板"
echo ""
echo "📝 后续步骤："
echo "  1. 查看并自定义配置: $CONFIG_FILE"
echo "  2. 应用分支保护规则:"
echo "     gh auth login"
echo "     node $SCRIPT_DIR/protect.js --strategy=$STRATEGY"
echo "  3. 复制工作流文件:"
echo "     cp -r $BRANCHES_DIR/automation/* .github/workflows/"
echo ""
echo "📚 查看文档: $BRANCHES_DIR/README.md"