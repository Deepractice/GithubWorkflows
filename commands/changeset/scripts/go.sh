#!/bin/bash
# Go implementation of changeset

# Get parameters from environment variables (set by changeset.yml)
TYPE=${CHANGESET_TYPE:-patch}
MESSAGE=${CHANGESET_MESSAGE:-"Update"}
PR_NUMBER=${PR_NUMBER:-""}
PR_AUTHOR=${PR_AUTHOR:-"unknown"}

# Create .changes directory if not exists
mkdir -p .changes

# Create changeset file (YAML format for Go)
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FILENAME=".changes/${TIMESTAMP}-pr${PR_NUMBER}.yaml"

# Get module name from go.mod
MODULE_NAME="unknown-module"
if [ -f "go.mod" ]; then
    MODULE_NAME=$(head -1 go.mod | cut -d' ' -f2)
fi

# Create changeset content (YAML format)
cat > "$FILENAME" << EOF
---
kind: ${TYPE}
module: ${MODULE_NAME}
pr: ${PR_NUMBER}
author: ${PR_AUTHOR}
description: |
  ${MESSAGE}
EOF

echo "Created Go changeset: $FILENAME"