#!/bin/bash

# Python release implementation
set -e

echo "Executing Python release for version $VERSION"

# Update pyproject.toml version
if [ -f "pyproject.toml" ]; then
  sed -i.bak "s/^version = .*/version = \"$VERSION\"/" pyproject.toml
  rm pyproject.toml.bak
  echo "Updated pyproject.toml to version $VERSION"
fi

# Update setup.py if exists
if [ -f "setup.py" ]; then
  sed -i.bak "s/version=['\"].*['\"]/version='$VERSION'/" setup.py
  rm setup.py.bak
  echo "Updated setup.py to version $VERSION"
fi

# Update __version__ in __init__.py if exists
if [ -f "*/__init__.py" ] || [ -f "src/*/__init__.py" ]; then
  find . -name "__init__.py" -exec sed -i.bak "s/__version__ = .*/__version__ = \"$VERSION\"/" {} \;
  find . -name "*.bak" -delete
  echo "Updated __version__ in Python files"
fi

# Generate CHANGELOG
echo "Generating CHANGELOG..."
CHANGELOG_ENTRY="## $VERSION - $(date +%Y-%m-%d)

"

# Collect changes from .changes directory
if [ -d ".changes" ]; then
  for file in .changes/*.md; do
    if [ -f "$file" ]; then
      # Extract type from file
      CHANGE_TYPE=$(grep -E "^type: (major|minor|patch)" "$file" | sed 's/type: //')
      DESCRIPTION=$(grep -v "^type:" "$file" | sed '/^$/d' | head -1)
      
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

# Commit changes
git add pyproject.toml setup.py CHANGELOG.md 2>/dev/null || true
git add **/__init__.py 2>/dev/null || true
git commit -m "chore(release): v$VERSION

[skip ci]" || echo "No changes to commit"

# Create and push tag
git tag "v$VERSION" -m "Release v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Python release completed for v$VERSION"