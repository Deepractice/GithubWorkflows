#!/bin/bash

# Node.js release implementation
set -e

echo "Executing Node.js release for version $VERSION"

# Update package.json version
if [ -f "package.json" ]; then
  # Update version in package.json
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.version = '$VERSION';
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\\n');
    console.log('Updated package.json to version ' + pkg.version);
  "
  
  # Update package-lock.json if exists
  if [ -f "package-lock.json" ]; then
    npm install --package-lock-only --silent
    echo "Updated package-lock.json"
  fi
  
  # Update yarn.lock if exists
  if [ -f "yarn.lock" ]; then
    yarn install --mode update-lockfile --silent
    echo "Updated yarn.lock"
  fi
  
  # Update pnpm-lock.yaml if exists
  if [ -f "pnpm-lock.yaml" ]; then
    pnpm install --lockfile-only --silent
    echo "Updated pnpm-lock.yaml"
  fi
fi

# Generate CHANGELOG
echo "Generating CHANGELOG..."
CHANGELOG_ENTRY="## $VERSION - $(date +%Y-%m-%d)

"

# Collect changeset content
if [ -d ".changeset" ]; then
  for file in .changeset/*.md; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "README.md" ]; then
      # Extract package and type
      CHANGE_TYPE=$(grep -oE '"[^"]*": "(patch|minor|major)"' "$file" | head -1 | sed 's/.*: "\(.*\)"/\1/')
      
      # Extract description (everything after the frontmatter)
      DESCRIPTION=$(sed -n '/^---$/,/^---$/!p' "$file" | sed '/^$/d')
      
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
  # Insert new entry after the header
  echo "$CHANGELOG_ENTRY" > CHANGELOG.tmp
  cat CHANGELOG.md >> CHANGELOG.tmp
  mv CHANGELOG.tmp CHANGELOG.md
else
  echo "# Changelog

$CHANGELOG_ENTRY" > CHANGELOG.md
fi

echo "Updated CHANGELOG.md"

# Commit changes
git add package.json package-lock.json yarn.lock pnpm-lock.yaml CHANGELOG.md 2>/dev/null || true
git commit -m "chore(release): v$VERSION

[skip ci]" || echo "No changes to commit"

# Create and push tag
git tag "v$VERSION" -m "Release v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Node.js release completed for v$VERSION"