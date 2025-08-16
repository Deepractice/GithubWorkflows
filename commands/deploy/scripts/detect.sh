#!/bin/bash
set -e

# Detect project type and structure for deployment
echo "🔍 Detecting project structure..."

# Check for Node.js project
if [ -f "package.json" ]; then
  echo "detected_type=node" >> $GITHUB_OUTPUT
  
  # Check if it's a library (has main/module/exports)
  if grep -q '"main"\|"module"\|"exports"' package.json; then
    echo "node_type=library" >> $GITHUB_OUTPUT
    echo "  ✅ Node.js library detected"
  else
    echo "node_type=application" >> $GITHUB_OUTPUT
    echo "  ✅ Node.js application detected"
  fi
  
  # Check for Dockerfile
  if [ -f "Dockerfile" ]; then
    echo "has_dockerfile=true" >> $GITHUB_OUTPUT
    echo "  ✅ Dockerfile found"
  else
    echo "has_dockerfile=false" >> $GITHUB_OUTPUT
  fi
  
  # Get package name and version
  PACKAGE_NAME=$(node -p "require('./package.json').name" 2>/dev/null || echo "unknown")
  PACKAGE_VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "0.0.0")
  echo "package_name=$PACKAGE_NAME" >> $GITHUB_OUTPUT
  echo "package_version=$PACKAGE_VERSION" >> $GITHUB_OUTPUT
  echo "  📦 Package: $PACKAGE_NAME@$PACKAGE_VERSION"

# Check for Python project
elif [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  echo "detected_type=python" >> $GITHUB_OUTPUT
  echo "  ✅ Python project detected"
  
  if [ -f "Dockerfile" ]; then
    echo "has_dockerfile=true" >> $GITHUB_OUTPUT
  else
    echo "has_dockerfile=false" >> $GITHUB_OUTPUT
  fi

# Check for Go project
elif [ -f "go.mod" ]; then
  echo "detected_type=go" >> $GITHUB_OUTPUT
  echo "  ✅ Go project detected"
  
  if [ -f "Dockerfile" ]; then
    echo "has_dockerfile=true" >> $GITHUB_OUTPUT
  else
    echo "has_dockerfile=false" >> $GITHUB_OUTPUT
  fi
  
  # Get module name
  MODULE_NAME=$(head -1 go.mod | awk '{print $2}')
  echo "module_name=$MODULE_NAME" >> $GITHUB_OUTPUT
  echo "  📦 Module: $MODULE_NAME"

# Check for Docker-only project
elif [ -f "Dockerfile" ]; then
  echo "detected_type=docker" >> $GITHUB_OUTPUT
  echo "has_dockerfile=true" >> $GITHUB_OUTPUT
  echo "  ✅ Docker-only project detected"

else
  echo "detected_type=unknown" >> $GITHUB_OUTPUT
  echo "has_dockerfile=false" >> $GITHUB_OUTPUT
  echo "  ⚠️ Unknown project type"
fi

# Check for CI/CD configurations
if [ -f ".github/workflows/release.yml" ] || [ -f ".github/workflows/publish.yml" ]; then
  echo "has_ci=true" >> $GITHUB_OUTPUT
  echo "  ✅ CI/CD workflows detected"
else
  echo "has_ci=false" >> $GITHUB_OUTPUT
fi

# Check for registry configurations
if [ -f ".npmrc" ]; then
  echo "has_npmrc=true" >> $GITHUB_OUTPUT
  echo "  ✅ NPM configuration found"
else
  echo "has_npmrc=false" >> $GITHUB_OUTPUT
fi

echo ""
echo "Detection complete!"