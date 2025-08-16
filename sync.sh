#!/bin/bash

# 同步工作流到所有分支
# 用法: ./sync.sh [commit-message]
# 原则：所有改动都先在 main 分支进行，然后同步到其他分支

MSG="${1:-sync: update workflows}"

echo "🔄 同步工作流..."

# 1. 在 main 分支生成并提交
git checkout main
git pull origin main  # 确保是最新的
node make.js node-opensource .

# 手动复制四个事件文件（make.js 目前只生成两个）
cp events/pr-opened-develop/pr-opened-develop.yml .github/workflows/
cp events/pr-opened-main/pr-opened-main.yml .github/workflows/
cp events/pr-merged-main/pr-merged-main.yml .github/workflows/

git add -A && git commit -m "$MSG" && git push origin main
MAIN_HASH=$(git rev-parse HEAD)

# 2. 同步到 develop 分支
echo "📌 同步到 develop 分支..."
git checkout develop
git pull origin develop  # 确保是最新的

# 直接使用 merge 而不是 cherry-pick，保持提交历史一致
if ! git merge $MAIN_HASH --no-edit; then
    echo "⚠️  Merge 有冲突，尝试自动解决..."
    
    # 对于工作流文件，总是使用 main 的版本
    git checkout main -- .github/workflows/ commands/ events/
    git add -A
    
    # 继续合并
    git commit --no-edit || {
        echo "❌ 合并失败，尝试强制同步..."
        git merge --abort
        
        # 强制同步工作流文件
        git checkout main -- .github/workflows/ commands/ events/
        git add -A
        git commit -m "$MSG (force sync from main)"
    }
fi

git push origin develop

# 3. 同步到 release 分支（如果存在）
for branch in $(git branch -r | grep 'origin/release/' | sed 's/origin\///'); do
    echo "📌 同步到 $branch..."
    git checkout $branch
    git pull origin $branch
    
    # 同样的策略
    if ! git cherry-pick $MAIN_HASH; then
        echo "⚠️  Cherry-pick 失败，尝试 merge 策略..."
        git cherry-pick --abort
        
        # 使用 merge 策略
        git merge $MAIN_HASH --no-edit --strategy-option=theirs || {
            echo "❌ Merge 也失败了，尝试强制同步工作流文件..."
            
            # 直接从 main 复制工作流文件
            git checkout main -- .github/workflows/ commands/ events/
            git add -A
            git commit -m "$MSG (force sync from main)"
        }
    fi
    
    git push origin $branch
done

# 4. 回到 main 分支
git checkout main

echo "✅ 同步完成"
echo "Main commit: $MAIN_HASH"

# 显示同步状态
echo ""
echo "📊 同步状态检查："
echo "Main:    $(git rev-parse --short HEAD)"
echo "Develop: $(git rev-parse --short origin/develop)"
for branch in $(git branch -r | grep 'origin/release/' | sed 's/origin\///'); do
    echo "$branch: $(git rev-parse --short origin/$branch)"
done