#!/bin/bash
set -e

# Docker deployment script
# Usage: docker.sh --tag <tag> --registry <registry> --dry-run <true|false>

TAG=""
REGISTRY="ghcr.io"
DRY_RUN="false"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --registry)
      REGISTRY="$2"
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

echo "🐳 Docker Deployment"
echo "===================="
echo "Tag: $TAG"
echo "Registry: $REGISTRY"
echo "Dry run: $DRY_RUN"
echo ""

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
  echo "❌ Error: Dockerfile not found"
  exit 1
fi

# Build image name
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-$(git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\).*/\1/p')}"
REPO_NAME="${GITHUB_REPOSITORY##*/}"

# Construct full image name based on registry
case "$REGISTRY" in
  docker.io)
    IMAGE_NAME="${REPO_OWNER}/${REPO_NAME}"
    ;;
  ghcr.io)
    IMAGE_NAME="ghcr.io/${REPO_OWNER}/${REPO_NAME}"
    ;;
  *)
    IMAGE_NAME="${REGISTRY}/${REPO_OWNER}/${REPO_NAME}"
    ;;
esac

echo "Image: $IMAGE_NAME"

# Get version from package.json if exists, otherwise use git SHA
if [ -f "package.json" ]; then
  VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "${GITHUB_SHA:0:7}")
else
  VERSION="${GITHUB_SHA:0:7}"
fi

# Determine version tag based on deployment tag
if [ "$TAG" = "dev" ]; then
  VERSION_TAG="${VERSION}-dev.$(date +%Y%m%d%H%M%S)"
elif [ "$TAG" = "beta" ]; then
  VERSION_TAG="${VERSION}-beta.$(date +%s)"
else
  VERSION_TAG="$VERSION"
fi

echo "Version: $VERSION_TAG"
echo ""

# Analyze Dockerfile
echo "📋 Analyzing Dockerfile..."
BASE_IMAGE=$(grep "^FROM" Dockerfile | head -1 | awk '{print $2}')
echo "  Base image: $BASE_IMAGE"

STAGES=$(grep "^FROM" Dockerfile | wc -l)
if [ "$STAGES" -gt 1 ]; then
  echo "  Multi-stage build detected ($STAGES stages)"
fi

EXPOSED_PORTS=$(grep "^EXPOSE" Dockerfile | awk '{print $2}' | tr '\n' ' ' || echo "none")
if [ "$EXPOSED_PORTS" != "none" ] && [ -n "$EXPOSED_PORTS" ]; then
  echo "  Exposed ports: $EXPOSED_PORTS"
fi
echo ""

# Build and push
if [ "$DRY_RUN" = "true" ]; then
  echo "🚀 [DRY RUN] Would execute:"
  echo ""
  echo "1. Build image:"
  echo "   docker build -t ${IMAGE_NAME}:${TAG} -t ${IMAGE_NAME}:${VERSION_TAG} ."
  echo ""
  echo "2. Push image:"
  echo "   docker push ${IMAGE_NAME}:${TAG}"
  echo "   docker push ${IMAGE_NAME}:${VERSION_TAG}"
  echo ""
  echo "Would publish:"
  echo "  - ${IMAGE_NAME}:${TAG}"
  echo "  - ${IMAGE_NAME}:${VERSION_TAG}"
  echo ""
  echo "✅ Dry run completed successfully"
  
  # Output for GitHub Actions
  echo "image=$IMAGE_NAME" >> $GITHUB_OUTPUT
  echo "version=$VERSION_TAG" >> $GITHUB_OUTPUT
else
  echo "🔨 Building Docker image..."
  
  # Build with both tags
  docker build \
    -t "${IMAGE_NAME}:${TAG}" \
    -t "${IMAGE_NAME}:${VERSION_TAG}" \
    --build-arg VERSION="${VERSION_TAG}" \
    .
  
  echo ""
  echo "🚀 Pushing to registry..."
  docker push "${IMAGE_NAME}:${TAG}"
  docker push "${IMAGE_NAME}:${VERSION_TAG}"
  
  echo ""
  echo "✅ Successfully deployed!"
  echo ""
  echo "🐳 Image: $IMAGE_NAME"
  echo "📌 Tags: $TAG, $VERSION_TAG"
  echo ""
  echo "Pull with:"
  echo "  docker pull ${IMAGE_NAME}:${TAG}"
  echo "  docker pull ${IMAGE_NAME}:${VERSION_TAG}"
  
  if [ -n "$EXPOSED_PORTS" ] && [ "$EXPOSED_PORTS" != "none" ]; then
    FIRST_PORT=$(echo "$EXPOSED_PORTS" | awk '{print $1}')
    echo ""
    echo "Run with:"
    echo "  docker run -p ${FIRST_PORT}:${FIRST_PORT} ${IMAGE_NAME}:${TAG}"
  fi
  
  # Output for GitHub Actions
  echo "image=$IMAGE_NAME" >> $GITHUB_OUTPUT
  echo "version=$VERSION_TAG" >> $GITHUB_OUTPUT
  
  # Output registry URL if applicable
  case "$REGISTRY" in
    ghcr.io)
      echo "url=https://github.com/${REPO_OWNER}/${REPO_NAME}/pkgs/container/${REPO_NAME}" >> $GITHUB_OUTPUT
      ;;
    docker.io)
      echo "url=https://hub.docker.com/r/${IMAGE_NAME}" >> $GITHUB_OUTPUT
      ;;
  esac
fi