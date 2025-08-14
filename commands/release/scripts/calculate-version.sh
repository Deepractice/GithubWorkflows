#!/bin/bash

# Calculate version based on changesets and locks
# Exports: NEW_VERSION, IS_PRERELEASE

set -e

# Get current version from package.json/pyproject.toml/etc
get_current_version() {
  case "$PROJECT_TYPE" in
    node)
      if [ -f "package.json" ]; then
        node -e "console.log(require('./package.json').version || '0.0.0')"
      else
        echo "0.0.0"
      fi
      ;;
    python)
      if [ -f "pyproject.toml" ]; then
        grep -E "^version = " pyproject.toml | sed 's/version = "\(.*\)"/\1/' || echo "0.0.0"
      else
        echo "0.0.0"
      fi
      ;;
    go)
      if [ -f "version.go" ]; then
        grep -E "const Version = " version.go | sed 's/const Version = "\(.*\)"/\1/' || echo "0.0.0"
      else
        echo "0.0.0"
      fi
      ;;
    *)
      echo "0.0.0"
      ;;
  esac
}

# Calculate bump type from changesets
get_bump_type() {
  local bump="patch"
  
  case "$PROJECT_TYPE" in
    node)
      if [ -d ".changeset" ]; then
        # Check for major changes
        if grep -l '"[^"]*": "major"' .changeset/*.md 2>/dev/null | grep -v README.md | head -1 > /dev/null; then
          bump="major"
        # Check for minor changes
        elif grep -l '"[^"]*": "minor"' .changeset/*.md 2>/dev/null | grep -v README.md | head -1 > /dev/null; then
          bump="minor"
        fi
      fi
      ;;
    *)
      # For other project types, check .changes directory
      if [ -d ".changes" ]; then
        if grep -l "type: major" .changes/* 2>/dev/null | head -1 > /dev/null; then
          bump="major"
        elif grep -l "type: minor" .changes/* 2>/dev/null | head -1 > /dev/null; then
          bump="minor"
        fi
      fi
      ;;
  esac
  
  echo "$bump"
}

# Increment version
increment_version() {
  local version=$1
  local bump=$2
  
  # Remove any prerelease suffix
  version=${version%%-*}
  
  IFS='.' read -ra PARTS <<< "$version"
  local major="${PARTS[0]:-0}"
  local minor="${PARTS[1]:-0}"
  local patch="${PARTS[2]:-0}"
  
  case "$bump" in
    major)
      echo "$((major + 1)).0.0"
      ;;
    minor)
      echo "$major.$((minor + 1)).0"
      ;;
    patch)
      echo "$major.$minor.$((patch + 1))"
      ;;
    *)
      echo "$major.$minor.$patch"
      ;;
  esac
}

# Get next prerelease version
get_next_prerelease() {
  local base_version=$1
  local prerelease_type=$2
  
  # Check existing tags for this prerelease series
  local pattern="v${base_version}-${prerelease_type}."
  local latest_tag=$(git tag -l "${pattern}*" 2>/dev/null | sort -V | tail -1)
  
  if [ -z "$latest_tag" ]; then
    echo "${base_version}-${prerelease_type}.1"
  else
    # Extract counter and increment
    local counter=$(echo "$latest_tag" | grep -oE '[0-9]+$')
    echo "${base_version}-${prerelease_type}.$((counter + 1))"
  fi
}

# Main version calculation
if [ "$GRADUATE" = "true" ]; then
  # Graduate prerelease to stable
  CURRENT_VERSION=$(get_current_version)
  # Remove prerelease suffix
  NEW_VERSION=${CURRENT_VERSION%%-*}
  IS_PRERELEASE=false
  
elif [ "$FORCE_VERSION" != "" ]; then
  # Force specific version
  NEW_VERSION="$FORCE_VERSION"
  if [[ "$NEW_VERSION" == *"-"* ]]; then
    IS_PRERELEASE=true
  else
    IS_PRERELEASE=false
  fi
  
elif [ "$HAS_LOCK" = "true" ] && [ "$PRERELEASE" != "" ]; then
  # Continue locked prerelease series
  if [ "$PRERELEASE" = "$LOCKED_PRERELEASE" ]; then
    # Same prerelease type, increment counter
    NEW_VERSION="${LOCKED_VERSION}-${PRERELEASE}.$((LOCKED_COUNTER + 1))"
  else
    # Different prerelease type, start new series
    NEW_VERSION="${LOCKED_VERSION}-${PRERELEASE}.1"
  fi
  IS_PRERELEASE=true
  
elif [ "$PRERELEASE" != "" ]; then
  # Start new prerelease series
  CURRENT_VERSION=$(get_current_version)
  BUMP_TYPE=$(get_bump_type)
  BASE_VERSION=$(increment_version "$CURRENT_VERSION" "$BUMP_TYPE")
  NEW_VERSION=$(get_next_prerelease "$BASE_VERSION" "$PRERELEASE")
  IS_PRERELEASE=true
  
else
  # Regular release
  if [ "$HAS_LOCK" = "true" ]; then
    # Release the locked version
    NEW_VERSION="$LOCKED_VERSION"
  else
    # Calculate from changesets
    CURRENT_VERSION=$(get_current_version)
    BUMP_TYPE=$(get_bump_type)
    NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$BUMP_TYPE")
  fi
  IS_PRERELEASE=false
fi

echo "Calculated version: $NEW_VERSION (prerelease: $IS_PRERELEASE)"
export NEW_VERSION
export IS_PRERELEASE