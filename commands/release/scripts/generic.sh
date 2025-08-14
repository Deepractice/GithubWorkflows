#!/bin/bash

# Generic release implementation for unknown project types
set -e

echo "Executing generic release for version $VERSION"

# Update VERSION file if exists
if [ -f "VERSION" ]; then
  echo "$VERSION" > VERSION
  echo "Updated VERSION file to $VERSION"
elif [ -f ".version" ]; then
  echo "$VERSION" > .version
  echo "Updated .version file to $VERSION"
else
  # Create VERSION file
  echo "$VERSION" > VERSION
  echo "Created VERSION file with version $VERSION"
fi

# Generate CHANGELOG
echo "Generating CHANGELOG..."
CHANGELOG_ENTRY="## $VERSION - $(date +%Y-%m-%d)

"

# Collect generic changes
if [ -d ".changes" ]; then
  for file in .changes/*; do
    if [ -f "$file" ]; then
      # Try to extract content
      CONTENT=$(cat "$file" | head -1)
      if [ -n "$CONTENT" ]; then
        CHANGELOG_ENTRY="${CHANGELOG_ENTRY}- ${CONTENT}\n"
      fi
    fi
  done
elif [ -d ".changeset" ]; then
  for file in .changeset/*.md; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "README.md" ]; then
      # Extract description
      DESCRIPTION=$(sed -n '/^---$/,/^---$/!p' "$file" | sed '/^$/d' | head -1)
      if [ -n "$DESCRIPTION" ]; then
        CHANGELOG_ENTRY="${CHANGELOG_ENTRY}- ${DESCRIPTION}\n"
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
git add VERSION .version CHANGELOG.md 2>/dev/null || true
git commit -m "chore(release): v$VERSION

[skip ci]" || echo "No changes to commit"

# Create and push tag
git tag "v$VERSION" -m "Release v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Generic release completed for v$VERSION"