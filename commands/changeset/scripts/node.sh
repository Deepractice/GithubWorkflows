#!/bin/bash
# Node.js implementation of changeset

TYPE=$1
MESSAGE=$2
PR_NUMBER=$3
PR_AUTHOR=$4

# Check if changesets is configured
if [ ! -f ".changeset/config.json" ]; then
    echo "Changesets not configured. Run: npx changeset init"
    exit 1
fi

# Create changeset file
TIMESTAMP=$(date +%s)
FILENAME=".changeset/${TIMESTAMP}-pr-${PR_NUMBER}-${TYPE}.md"

# Get package name from package.json
PACKAGE_NAME=$(node -e "console.log(require('./package.json').name || '@unknown/package')")

# Create changeset content
cat > "$FILENAME" << EOF
---
"${PACKAGE_NAME}": ${TYPE}
---

${MESSAGE}

Contributed by @${PR_AUTHOR} via #${PR_NUMBER}
EOF

echo "Created Node.js changeset: $FILENAME"