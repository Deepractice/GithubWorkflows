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
git checkout develop
git pull origin develop  # 确保是最新的
git cherry-pick $MAIN_HASH || git cherry-pick --abort  # 如果有冲突就跳过
git push origin develop

# 3. 同步到 release 分支（如果存在）
for branch in $(git branch -r | grep 'origin/release/' | sed 's/origin\///'); do
    echo "同步到 $branch..."
    git checkout $branch
    git pull origin $branch
    git cherry-pick $MAIN_HASH || git cherry-pick --abort
    git push origin $branch
done

# 4. 回到 main 分支
git checkout main

echo "✅ 同步完成"
echo "Main commit: $MAIN_HASH"