#!/bin/bash
set -e

# NPM deployment script
# Usage: npm.sh --tag <tag> --dry-run <true|false>

TAG=""
DRY_RUN="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$TAG" ]; then
  echo "Error: --tag is required"
  exit 1
fi

echo "📦 NPM Deployment"
echo "=================="
echo "Tag: $TAG"
echo "Dry run: $DRY_RUN"
echo ""

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "❌ Error: package.json not found"
  exit 1
fi

# Get package info
PACKAGE_NAME=$(node -p "require('./package.json').name")
PACKAGE_VERSION=$(node -p "require('./package.json').version")

echo "Package: $PACKAGE_NAME"
echo "Version: $PACKAGE_VERSION"
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
if [ -f "pnpm-lock.yaml" ]; then
  echo "Using pnpm"
  pnpm install --frozen-lockfile
elif [ -f "yarn.lock" ]; then
  echo "Using yarn"
  yarn install --frozen-lockfile
elif [ -f "package-lock.json" ]; then
  echo "Using npm"
  npm ci
else
  echo "Using npm install"
  npm install
fi

# Build if needed
if [ -f "tsconfig.json" ] || [ -f "rollup.config.js" ] || [ -f "webpack.config.js" ]; then
  echo ""
  echo "🔨 Building package..."
  if npm run build 2>/dev/null; then
    echo "✅ Build successful"
  else
    echo "⚠️ No build script or build failed, continuing..."
  fi
fi

# Determine version suffix based on tag
PUBLISH_VERSION="$PACKAGE_VERSION"
if [ "$TAG" = "dev" ]; then
  # For dev, add timestamp
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  PUBLISH_VERSION="${PACKAGE_VERSION}-dev.${TIMESTAMP}"
  echo ""
  echo "📝 Setting dev version: $PUBLISH_VERSION"
  if [ "$DRY_RUN" != "true" ]; then
    npm version "$PUBLISH_VERSION" --no-git-tag-version
  fi
elif [ "$TAG" = "beta" ]; then
  # For beta, add beta suffix with timestamp
  TIMESTAMP=$(date +%s)
  PUBLISH_VERSION="${PACKAGE_VERSION}-beta.${TIMESTAMP}"
  echo ""
  echo "📝 Setting beta version: $PUBLISH_VERSION"
  if [ "$DRY_RUN" != "true" ]; then
    npm version "$PUBLISH_VERSION" --no-git-tag-version
  fi
fi

# Publish to NPM
echo ""
if [ "$DRY_RUN" = "true" ]; then
  echo "🚀 [DRY RUN] Would execute:"
  echo "  npm publish --tag $TAG"
  echo ""
  echo "Would publish: $PACKAGE_NAME@$PUBLISH_VERSION with tag '$TAG'"
  echo ""
  echo "✅ Dry run completed successfully"
  
  # Output for GitHub Actions
  echo "version=$PUBLISH_VERSION" >> $GITHUB_OUTPUT
  echo "package=$PACKAGE_NAME" >> $GITHUB_OUTPUT
  echo "url=https://www.npmjs.com/package/$PACKAGE_NAME" >> $GITHUB_OUTPUT
else
  echo "🚀 Publishing to NPM..."
  npm publish --tag "$TAG"
  
  echo ""
  echo "✅ Successfully published!"
  echo ""
  echo "📦 Package: $PACKAGE_NAME@$PUBLISH_VERSION"
  echo "🏷️  Tag: $TAG"
  echo ""
  echo "Install with:"
  echo "  npm install $PACKAGE_NAME@$TAG"
  
  # Output for GitHub Actions
  echo "version=$PUBLISH_VERSION" >> $GITHUB_OUTPUT
  echo "package=$PACKAGE_NAME" >> $GITHUB_OUTPUT
  echo "url=https://www.npmjs.com/package/$PACKAGE_NAME" >> $GITHUB_OUTPUT
fi