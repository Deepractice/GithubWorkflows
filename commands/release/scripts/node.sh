#!/bin/bash

# Node.js release implementation
set -e

echo "Executing Node.js release for version $VERSION"

# Configure git first (needed for all git operations)
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# For release branches created by /start release, 
# package.json and CHANGELOG.md are already updated by changeset
# We only need to create tags and GitHub releases

# Verify version in package.json matches
if [ -f "package.json" ]; then
  CURRENT_VERSION=$(node -p "require('./package.json').version")
  if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    echo "Warning: package.json version ($CURRENT_VERSION) doesn't match expected version ($VERSION)"
    echo "This might happen for hotfix or manual releases"
    
    # Only update if versions don't match (e.g., hotfix scenario)
    node -e "
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      pkg.version = '$VERSION';
      fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\\n');
      console.log('Updated package.json to version ' + pkg.version);
    "
    
    # Update lock files only if package.json was changed
    if [ -f "package-lock.json" ]; then
      npm install --package-lock-only --silent
      echo "Updated package-lock.json"
    fi
    
    if [ -f "yarn.lock" ]; then
      yarn install --mode update-lockfile --silent
      echo "Updated yarn.lock"
    fi
    
    if [ -f "pnpm-lock.yaml" ]; then
      if command -v pnpm &> /dev/null; then
        pnpm install --lockfile-only --silent
        echo "Updated pnpm-lock.yaml"
      else
        echo "Warning: pnpm-lock.yaml exists but pnpm is not installed"
      fi
    fi
    
    # Commit only if there were changes
    git add package.json package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null || true
    git commit -m "chore(release): v$VERSION

[skip ci]" || echo "No changes to commit"
  else
    echo "✓ package.json version is already $VERSION"
  fi
fi

# Create and push tag
git tag "v$VERSION" -m "Release v$VERSION"
git push origin "$BRANCH"
git push origin "v$VERSION"

echo "✅ Node.js release completed for v$VERSION"