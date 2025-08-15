#!/bin/bash

# Node.js release implementation
set -e

echo "Executing Node.js release for version $VERSION"
echo "Is prerelease: ${IS_PRERELEASE:-false}"
echo "Prerelease type: ${PRERELEASE:-none}"

# Configure git first (needed for all git operations)
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# For release branches created by /start release, 
# package.json and CHANGELOG.md are already updated by changeset
# We only need to create tags and GitHub releases

# Verify version in package.json matches
if [ -f "package.json" ]; then
  CURRENT_VERSION=$(node -p "require('./package.json').version")
  
  # For beta releases on release branches, VERSION includes -beta.X suffix
  # but package.json might still have the base version
  if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    echo "Notice: package.json version ($CURRENT_VERSION) differs from release version ($VERSION)"
    
    # For prerelease, we expect VERSION to have the suffix
    # For production release, VERSION should match package.json
    if [ "$IS_PRERELEASE" = "true" ]; then
      echo "Creating prerelease $VERSION from base version $CURRENT_VERSION"
      # Don't update package.json for prerelease - keep base version
    else
      echo "This might happen for hotfix or manual releases"
      # Only update if it's not a prerelease scenario
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
    fi
  else
    echo "✓ package.json version is already $VERSION"
  fi
fi

# Create and push tag
# Check if tag already exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "⚠️ Tag v$VERSION already exists"
  # For production release after beta, we update the existing tag to point to main
  if [ "$IS_PRERELEASE" != "true" ]; then
    echo "Updating tag to point to current commit (production release)"
    git tag -f "v$VERSION" -m "Release v$VERSION (production)"
    git push origin "v$VERSION" --force
  else
    echo "Skipping tag creation for prerelease (already exists)"
  fi
else
  # Create new tag
  git tag "v$VERSION" -m "Release v$VERSION"
  git push origin "v$VERSION"
fi

# Push current branch (we're on the source branch, not target)
git push origin HEAD

echo "✅ Node.js release completed for v$VERSION"