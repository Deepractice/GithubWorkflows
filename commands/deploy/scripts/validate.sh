#!/bin/bash
set -e

# Validate deploy command parameters
# Usage: validate.sh <target> <tag>

TARGET="$1"
TAG="$2"

echo "🔍 Validating deploy command..."

# Validate target
if [[ -z "$TARGET" ]]; then
  echo "❌ Error: Missing deployment target"
  echo "Usage: /deploy <npm|docker> --tag <dev|beta|latest>"
  exit 1
fi

VALID_TARGETS=("npm" "docker")
if [[ ! " ${VALID_TARGETS[@]} " =~ " ${TARGET} " ]]; then
  echo "❌ Error: Invalid target '$TARGET'"
  echo "Valid targets: ${VALID_TARGETS[*]}"
  exit 1
fi

# Validate tag
if [[ -z "$TAG" ]]; then
  TAG="latest"
  echo "ℹ️ No tag specified, using default: latest"
fi

VALID_TAGS=("dev" "beta" "latest")
if [[ ! " ${VALID_TAGS[@]} " =~ " ${TAG} " ]]; then
  echo "❌ Error: Invalid tag '$TAG'"
  echo "Valid tags: ${VALID_TAGS[*]}"
  exit 1
fi

# Additional validation based on target
if [ "$TARGET" = "npm" ]; then
  if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found"
    echo "NPM deployment requires a Node.js project with package.json"
    exit 1
  fi
  
  # Check if npm token is available (in CI environment)
  if [ -n "$CI" ] && [ -z "$NODE_AUTH_TOKEN" ] && [ -z "$NPM_TOKEN" ]; then
    echo "⚠️ Warning: NPM_TOKEN not found in environment"
    echo "Make sure NPM_TOKEN secret is configured in repository settings"
  fi
fi

if [ "$TARGET" = "docker" ]; then
  if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found"
    echo "Docker deployment requires a Dockerfile in the repository root"
    exit 1
  fi
  
  # Check if docker is available
  if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in PATH"
    exit 1
  fi
fi

echo "✅ Validation successful"
echo "  Target: $TARGET"
echo "  Tag: $TAG"
echo ""

# Output for GitHub Actions
echo "valid=true" >> $GITHUB_OUTPUT
echo "target=$TARGET" >> $GITHUB_OUTPUT
echo "tag=$TAG" >> $GITHUB_OUTPUT