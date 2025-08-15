#!/bin/bash
# Generic implementation of changeset (for unknown project types)

# Get parameters from environment variables (set by changeset.yml)
TYPE=${CHANGESET_TYPE:-patch}
MESSAGE=${CHANGESET_MESSAGE:-"Update"}
PR_NUMBER=${PR_NUMBER:-""}
PR_AUTHOR=${PR_AUTHOR:-"unknown"}

# Create .changes directory (generic location)
mkdir -p .changes

# Create changeset file in Markdown format
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILENAME=".changes/${TIMESTAMP}-pr${PR_NUMBER}.md"

# Determine semantic version type
case "$TYPE" in
    "major")
        VERSION_TYPE="BREAKING CHANGE"
        VERSION_BUMP="Major version (x.0.0)"
        ;;
    "minor")
        VERSION_TYPE="Feature"
        VERSION_BUMP="Minor version (0.x.0)"
        ;;
    "patch")
        VERSION_TYPE="Fix"
        VERSION_BUMP="Patch version (0.0.x)"
        ;;
    *)
        VERSION_TYPE="Change"
        VERSION_BUMP="Patch version (0.0.x)"
        ;;
esac

# Create generic changeset content
cat > "$FILENAME" << EOF
# ${VERSION_TYPE}: ${MESSAGE}

- **Type**: ${TYPE}
- **Version Impact**: ${VERSION_BUMP}
- **PR**: #${PR_NUMBER}
- **Author**: @${PR_AUTHOR}
- **Date**: $(date +%Y-%m-%d)

## Description

${MESSAGE}

## Changelog Entry

- ${MESSAGE} (#${PR_NUMBER} by @${PR_AUTHOR})
EOF

echo "Created generic changeset: $FILENAME"
echo "Note: This is a generic format. Consider implementing a specific format for your project type."