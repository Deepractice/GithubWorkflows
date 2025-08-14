#!/bin/bash

# Go release implementation
set -e

echo "Executing Go release for version $VERSION"

# Update version.go if exists
if [ -f "version.go" ]; then
  sed -i.bak "s/const Version = .*/const Version = \"$VERSION\"/" version.go
  rm version.go.bak
  echo "Updated version.go to version $VERSION"
elif [ -f "internal/version/version.go" ]; then
  sed -i.bak "s/const Version = .*/const Version = \"$VERSION\"/" internal/version/version.go
  rm internal/version/version.go.bak
  echo "Updated internal/version/version.go to version $VERSION"
else
  # Create version.go if doesn't exist
  cat > version.go << EOF
package main

// Version is the current version of the application
const Version = "$VERSION"
EOF
  echo "Created version.go with version $VERSION"
fi

# Generate CHANGELOG
echo "Generating CHANGELOG..."
CHANGELOG_ENTRY="## $VERSION - $(date +%Y-%m-%d)

"

# Collect changes from .changes directory
if [ -d ".changes" ]; then
  for file in .changes/*.yaml; do
    if [ -f "$file" ]; then
      # Parse YAML (simple approach)
      CHANGE_TYPE=$(grep "^type:" "$file" | sed 's/type: //')
      DESCRIPTION=$(grep "^description:" "$file" | sed 's/description: //')
      
      if [ -n "$DESCRIPTION" ]; then
        case "$CHANGE_TYPE" in
          major)
            CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 💥 Breaking Changes\n\n- ${DESCRIPTION}\n\n"
            ;;
          minor)
            CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### ✨ Features\n\n- ${DESCRIPTION}\n\n"
            ;;
          patch)
            CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 🐛 Bug Fixes\n\n- ${DESCRIPTION}\n\n"
            ;;
        esac
      fi
    fi
  done
fi

# Update or create CHANGELOG.md
if [ -f "CHANGELOG.md" ]; then
  echo "$CHANGELOG_ENTRY" > CHANGELOG.tmp
  cat CHANGELOG.md >> CHANGELOG.tmp
  mv CHANGELOG.tmp CHANGELOG.md
else
  echo "# Changelog

$CHANGELOG_ENTRY" > CHANGELOG.md
fi

echo "Updated CHANGELOG.md"

# Update go.mod if needed (for module versioning)
if [ -f "go.mod" ]; then
  MODULE_NAME=$(grep "^module " go.mod | sed 's/module //')
  echo "Module: $MODULE_NAME"
  # Note: Go modules use git tags for versioning, no file update needed
fi

# Commit changes
git add version.go internal/version/version.go CHANGELOG.md 2>/dev/null || true
git commit -m "chore(release): v$VERSION

[skip ci]" || echo "No changes to commit"

# Create and push tag
git tag "v$VERSION" -m "Release v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Go release completed for v$VERSION"