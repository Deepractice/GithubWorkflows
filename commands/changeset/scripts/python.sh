#!/bin/bash
# Python implementation of changeset

# Get parameters from environment variables (set by changeset.yml)
TYPE=${CHANGESET_TYPE:-patch}
MESSAGE=${CHANGESET_MESSAGE:-"Update"}
PR_NUMBER=${PR_NUMBER:-""}
PR_AUTHOR=${PR_AUTHOR:-"unknown"}

# Create .changes directory if not exists
mkdir -p .changes

# Create changeset file (following Python conventions)
TIMESTAMP=$(date +%s)
FILENAME=".changes/${PR_NUMBER}.${TYPE}.md"

# Get package name from pyproject.toml or setup.py
PACKAGE_NAME="unknown-package"
if [ -f "pyproject.toml" ]; then
    # Try to extract name from pyproject.toml
    PACKAGE_NAME=$(grep "^name" pyproject.toml | cut -d'"' -f2 || echo "unknown-package")
elif [ -f "setup.py" ]; then
    # Try to extract from setup.py
    PACKAGE_NAME=$(grep "name=" setup.py | head -1 | cut -d"'" -f2 || echo "unknown-package")
fi

# Determine version bump
case "$TYPE" in
    "major")
        VERSION_BUMP="major"
        ;;
    "minor")
        VERSION_BUMP="feature"
        ;;
    "patch")
        VERSION_BUMP="bugfix"
        ;;
    *)
        VERSION_BUMP="patch"
        ;;
esac

# Create changeset content (towncrier format)
cat > "$FILENAME" << EOF
${MESSAGE}

Type: ${VERSION_BUMP}
PR: #${PR_NUMBER}
Author: @${PR_AUTHOR}
EOF

echo "Created Python changeset: $FILENAME"