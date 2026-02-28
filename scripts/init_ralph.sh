#!/bin/bash
# Initialize Ralph Loop in a project

set -e

if [ -z "$1" ]; then
    echo "Usage: init_ralph.sh /path/to/project"
    exit 1
fi

TARGET_DIR="$1"
SPECS_DIR="$TARGET_DIR/specs"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

mkdir -p "$SPECS_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../assets/templates"

cp "$TEMPLATES_DIR/spec.md" "$SPECS_DIR/spec.md" 2>/dev/null && echo "Created specs/spec.md"
cp "$TEMPLATES_DIR/implementation_plan.md" "$SPECS_DIR/implementation_plan.md" 2>/dev/null && echo "Created specs/implementation_plan.md"
cp "$TEMPLATES_DIR/prompt.md" "$SPECS_DIR/prompt.md" 2>/dev/null && echo "Created specs/prompt.md"
cp "$TEMPLATES_DIR/run.sh" "$TARGET_DIR/run.sh" 2>/dev/null && chmod +x "$TARGET_DIR/run.sh" && echo "Created run.sh"

echo ""
echo "Next: Edit specs/*.md, then run ./run.sh"
