#!/bin/bash
set -e

# npm 发布脚本
# 用法: npm.sh --version <version> --tag <tag> --access <access> [--dry-run]

VERSION=""
TAG="latest"
ACCESS="public"
DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    --access)
      ACCESS="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# 验证必需参数
if [ -z "$VERSION" ]; then
  echo "Error: --version is required"
  exit 1
fi

# 检查 package.json
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found"
  exit 1
fi

# 获取包名
PACKAGE_NAME=$(node -p "require('./package.json').name")
echo "📦 Package: $PACKAGE_NAME"
echo "📌 Version: $VERSION"
echo "🏷️  Tag: $TAG"
echo "🔒 Access: $ACCESS"

# 检查版本是否匹配
PACKAGE_VERSION=$(node -p "require('./package.json').version")
if [ "$PACKAGE_VERSION" != "$VERSION" ]; then
  echo "⚠️  Warning: package.json version ($PACKAGE_VERSION) doesn't match release version ($VERSION)"
  echo "Updating package.json version to $VERSION"
  
  # 更新 package.json 版本
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.version = '$VERSION';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\\n');
  "
fi

# 检查是否需要构建
if [ -f "package.json" ]; then
  # 检查是否有 build 脚本
  if grep -q '"build"' package.json; then
    echo "🔨 Running build..."
    npm run build
  fi
  
  # 检查是否有 prepublishOnly 脚本
  if grep -q '"prepublishOnly"' package.json; then
    echo "🔧 Running prepublishOnly..."
    npm run prepublishOnly
  fi
fi

# 检查 .npmignore 或 files 字段
if [ ! -f ".npmignore" ]; then
  if ! grep -q '"files"' package.json; then
    echo "⚠️  Warning: No .npmignore file and no 'files' field in package.json"
    echo "All files will be included in the package"
  fi
fi

# 预览将要发布的文件
echo ""
echo "📋 Files to be published:"
npm pack --dry-run 2>/dev/null | grep -E "^npm notice" | sed 's/npm notice /  /'

# 检查包大小
TARBALL=$(npm pack --pack-destination /tmp 2>/dev/null)
SIZE=$(du -h "$TARBALL" | cut -f1)
echo ""
echo "📦 Package size: $SIZE"
rm -f "$TARBALL"

# 检查是否已存在该版本
echo ""
echo "🔍 Checking if version exists on npm..."
if npm view "$PACKAGE_NAME@$VERSION" version 2>/dev/null; then
  echo "❌ Error: Version $VERSION already exists on npm"
  exit 1
fi

# 设置 npm 配置
if [ -n "$NODE_AUTH_TOKEN" ]; then
  echo "🔑 Using npm token for authentication"
  echo "//registry.npmjs.org/:_authToken=${NODE_AUTH_TOKEN}" > ~/.npmrc
elif [ "$NPM_CONFIG_PROVENANCE" = "true" ]; then
  echo "🔐 Using OIDC trusted publishing"
  # OIDC 不需要 token，GitHub Actions 会自动处理
else
  echo "⚠️  Warning: No authentication configured"
  echo "Attempting to use existing npm login"
fi

# 执行发布
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "🚀 [DRY RUN] Would publish with:"
  echo "  npm publish --tag $TAG --access $ACCESS"
  
  # 模拟发布输出
  echo ""
  echo "npm notice"
  echo "npm notice 📦  $PACKAGE_NAME@$VERSION"
  echo "npm notice === Tarball Contents ==="
  npm pack --dry-run 2>/dev/null | grep -E "^npm notice" | head -20
  echo "npm notice === Tarball Details ==="
  echo "npm notice name:          $PACKAGE_NAME"
  echo "npm notice version:       $VERSION"
  echo "npm notice tag:           $TAG"
  echo "npm notice access:        $ACCESS"
  echo ""
  echo "✅ Dry run completed successfully"
else
  echo ""
  echo "🚀 Publishing to npm..."
  
  # 构建发布命令
  PUBLISH_CMD="npm publish"
  
  # 添加 tag
  PUBLISH_CMD="$PUBLISH_CMD --tag $TAG"
  
  # 添加 access（仅对 scoped 包有效）
  if [[ "$PACKAGE_NAME" == @* ]]; then
    PUBLISH_CMD="$PUBLISH_CMD --access $ACCESS"
  fi
  
  # 添加 provenance（如果启用）
  if [ "$NPM_CONFIG_PROVENANCE" = "true" ]; then
    PUBLISH_CMD="$PUBLISH_CMD --provenance"
  fi
  
  echo "Running: $PUBLISH_CMD"
  $PUBLISH_CMD
  
  echo ""
  echo "✅ Successfully published $PACKAGE_NAME@$VERSION to npm!"
  echo ""
  echo "View on npm: https://www.npmjs.com/package/$PACKAGE_NAME/v/$VERSION"
  
  # 输出安装命令
  echo ""
  echo "📥 Install with:"
  if [ "$TAG" = "latest" ]; then
    echo "  npm install $PACKAGE_NAME"
    echo "  npm install $PACKAGE_NAME@$VERSION"
  else
    echo "  npm install $PACKAGE_NAME@$TAG"
    echo "  npm install $PACKAGE_NAME@$VERSION"
  fi
fi

# 清理临时文件
if [ -f ~/.npmrc ] && [ -n "$NODE_AUTH_TOKEN" ]; then
  rm -f ~/.npmrc
fi