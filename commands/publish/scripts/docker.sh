#!/bin/bash
set -e

# Docker 发布脚本
# 用法: docker.sh --version <version> --registry <registry> --tag <tag> --platform <platform> [--dry-run]

VERSION=""
REGISTRY="docker.io"
TAG="latest"
PLATFORM="linux/amd64"
DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --registry)
      REGISTRY="$2"
      shift 2
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
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

# 检查 Dockerfile
if [ ! -f "Dockerfile" ]; then
  echo "Error: Dockerfile not found"
  exit 1
fi

# 构建镜像名称
REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-$(git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\).*/\1/p')}"
REPO_NAME="${GITHUB_REPOSITORY##*/}"

# 根据 registry 构建完整镜像名
case "$REGISTRY" in
  docker.io)
    # Docker Hub: username/repo
    IMAGE_NAME="${REPO_OWNER}/${REPO_NAME}"
    ;;
  ghcr.io)
    # GitHub Container Registry: ghcr.io/owner/repo
    IMAGE_NAME="ghcr.io/${REPO_OWNER}/${REPO_NAME}"
    ;;
  ecr)
    # AWS ECR: 需要从环境变量获取
    if [ -z "$AWS_ECR_REGISTRY" ]; then
      echo "Error: AWS_ECR_REGISTRY environment variable is required for ECR"
      exit 1
    fi
    IMAGE_NAME="${AWS_ECR_REGISTRY}/${REPO_NAME}"
    ;;
  *)
    # 自定义 registry
    IMAGE_NAME="${REGISTRY}/${REPO_OWNER}/${REPO_NAME}"
    ;;
esac

echo "🐳 Docker Image Publishing"
echo "📦 Image: $IMAGE_NAME"
echo "📌 Version: $VERSION"
echo "🏷️  Tags: $TAG, $VERSION"
echo "🖥️  Platform: $PLATFORM"
echo "🏢 Registry: $REGISTRY"

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

# 分析 Dockerfile
echo ""
echo "📋 Analyzing Dockerfile..."

# 检查基础镜像
BASE_IMAGE=$(grep "^FROM" Dockerfile | head -1 | awk '{print $2}')
echo "  Base image: $BASE_IMAGE"

# 检查是否有多阶段构建
STAGES=$(grep "^FROM" Dockerfile | wc -l)
if [ "$STAGES" -gt 1 ]; then
  echo "  Multi-stage build detected ($STAGES stages)"
fi

# 检查暴露的端口
EXPOSED_PORTS=$(grep "^EXPOSE" Dockerfile | awk '{print $2}' | tr '\n' ' ' || echo "none")
if [ "$EXPOSED_PORTS" != "none" ] && [ -n "$EXPOSED_PORTS" ]; then
  echo "  Exposed ports: $EXPOSED_PORTS"
fi

# 准备构建参数
BUILD_ARGS=""

# 添加版本构建参数
BUILD_ARGS="$BUILD_ARGS --build-arg VERSION=$VERSION"

# 如果有 package.json，添加 Node 相关构建参数
if [ -f "package.json" ]; then
  NODE_ENV="${NODE_ENV:-production}"
  BUILD_ARGS="$BUILD_ARGS --build-arg NODE_ENV=$NODE_ENV"
fi

# 准备标签
TAGS=""
# 添加版本标签
TAGS="$TAGS -t ${IMAGE_NAME}:${VERSION}"

# 添加额外标签（如 latest, beta 等）
for t in $(echo "$TAG" | tr ',' ' '); do
  TAGS="$TAGS -t ${IMAGE_NAME}:${t}"
done

# 执行构建和发布
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "🚀 [DRY RUN] Would execute:"
  echo ""
  echo "1. Build image:"
  echo "   docker buildx build \\"
  echo "     --platform $PLATFORM \\"
  echo "     $BUILD_ARGS \\"
  echo "     $TAGS \\"
  echo "     ."
  echo ""
  echo "2. Push image:"
  for t in $(echo "$TAG" | tr ',' ' '); do
    echo "   docker push ${IMAGE_NAME}:${t}"
  done
  echo "   docker push ${IMAGE_NAME}:${VERSION}"
  echo ""
  echo "✅ Dry run completed successfully"
else
  echo ""
  echo "🔨 Building Docker image..."
  
  # 使用 buildx 进行多平台构建
  if docker buildx version >/dev/null 2>&1; then
    echo "Using Docker Buildx for multi-platform build"
    
    # 创建或使用 builder
    BUILDER_NAME="multiplatform-builder"
    if ! docker buildx ls | grep -q "$BUILDER_NAME"; then
      echo "Creating buildx builder..."
      docker buildx create --name "$BUILDER_NAME" --use
    else
      docker buildx use "$BUILDER_NAME"
    fi
    
    # 构建并推送（buildx 可以一步完成）
    echo "Building and pushing image..."
    docker buildx build \
      --platform "$PLATFORM" \
      $BUILD_ARGS \
      $TAGS \
      --push \
      .
      
  else
    echo "Docker Buildx not available, using standard build"
    
    # 标准构建（仅支持本地平台）
    docker build \
      $BUILD_ARGS \
      $TAGS \
      .
    
    # 推送所有标签
    echo ""
    echo "🚀 Pushing Docker image..."
    for t in $(echo "$TAG" | tr ',' ' '); do
      echo "Pushing ${IMAGE_NAME}:${t}..."
      docker push "${IMAGE_NAME}:${t}"
    done
    echo "Pushing ${IMAGE_NAME}:${VERSION}..."
    docker push "${IMAGE_NAME}:${VERSION}"
  fi
  
  echo ""
  echo "✅ Successfully published Docker image!"
  echo ""
  echo "📥 Pull with:"
  echo "  docker pull ${IMAGE_NAME}:${VERSION}"
  if [[ "$TAG" == *"latest"* ]]; then
    echo "  docker pull ${IMAGE_NAME}:latest"
  fi
  
  # 输出运行命令示例
  echo ""
  echo "🏃 Run with:"
  if [ -n "$EXPOSED_PORTS" ] && [ "$EXPOSED_PORTS" != "none" ]; then
    # 获取第一个端口
    FIRST_PORT=$(echo "$EXPOSED_PORTS" | awk '{print $1}')
    echo "  docker run -p ${FIRST_PORT}:${FIRST_PORT} ${IMAGE_NAME}:${VERSION}"
  else
    echo "  docker run ${IMAGE_NAME}:${VERSION}"
  fi
  
  # 根据 registry 输出查看链接
  echo ""
  case "$REGISTRY" in
    docker.io)
      echo "🔗 View on Docker Hub:"
      echo "  https://hub.docker.com/r/${IMAGE_NAME}"
      ;;
    ghcr.io)
      echo "🔗 View on GitHub Packages:"
      echo "  https://github.com/${REPO_OWNER}/${REPO_NAME}/pkgs/container/${REPO_NAME}"
      ;;
  esac
fi

echo ""
echo "📊 Image details:"
if [ "$DRY_RUN" = false ]; then
  # 获取镜像大小
  SIZE=$(docker images --format "{{.Size}}" "${IMAGE_NAME}:${VERSION}" | head -1)
  echo "  Size: $SIZE"
  
  # 获取镜像 ID
  IMAGE_ID=$(docker images --format "{{.ID}}" "${IMAGE_NAME}:${VERSION}" | head -1)
  echo "  ID: $IMAGE_ID"
fi