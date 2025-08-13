#!/bin/bash
# Detect project type and call appropriate implementation

detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ]; then
        echo "java-maven"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java-gradle"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "composer.json" ]; then
        echo "php"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    else
        echo "unknown"
    fi
}

# Main execution
PROJECT_TYPE=$(detect_project_type)
echo "Detected project type: $PROJECT_TYPE"

# Call appropriate implementation
case "$PROJECT_TYPE" in
    "node")
        bash implementations/node.sh "$@"
        ;;
    "python")
        bash implementations/python.sh "$@"
        ;;
    "go")
        bash implementations/go.sh "$@"
        ;;
    *)
        echo "Unsupported project type: $PROJECT_TYPE"
        echo "Using generic implementation..."
        bash implementations/generic.sh "$@"
        ;;
esac