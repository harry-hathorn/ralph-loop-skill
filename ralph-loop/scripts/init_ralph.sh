#!/bin/bash
# Initialize Ralph Loop in a project

set -e

if [ -z "$1" ]; then
    echo "Usage: init_ralph.sh /path/to/project"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../assets/templates"

# Create directories
mkdir -p "$TARGET_DIR/specs"
mkdir -p "$TARGET_DIR/src"

# Copy files to project root
cp "$TEMPLATES_DIR/loop.sh" "$TARGET_DIR/loop.sh" && chmod +x "$TARGET_DIR/loop.sh" && echo "Created loop.sh"
cp "$TEMPLATES_DIR/PROMPT_plan.md" "$TARGET_DIR/PROMPT_plan.md" && echo "Created PROMPT_plan.md"
cp "$TEMPLATES_DIR/PROMPT_build.md" "$TARGET_DIR/PROMPT_build.md" && echo "Created PROMPT_build.md"
cp "$TEMPLATES_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md" && echo "Created AGENTS.md"

# Copy example spec into specs/
cp "$TEMPLATES_DIR/spec.md" "$TARGET_DIR/specs/spec.md" && echo "Created specs/spec.md"

echo ""
echo "Project structure:"
echo "  loop.sh              - Ralph loop script (plan/build modes)"
echo "  PROMPT_plan.md       - Planning mode prompt (edit [project-specific goal])"
echo "  PROMPT_build.md      - Building mode prompt"
echo "  AGENTS.md            - Operational guide (update validation commands)"
echo "  specs/spec.md        - Example spec (one per topic of concern)"
echo "  src/                 - Application source code"
echo ""
echo "Next steps:"
echo "  1. Edit PROMPT_plan.md — replace [project-specific goal]"
echo "  2. Edit AGENTS.md — add your build/test/lint commands"
echo "  3. Write specs in specs/ (one per topic of concern)"
echo "  4. Run: ./loop.sh plan    (generates IMPLEMENTATION_PLAN.md)"
echo "  5. Run: ./loop.sh         (builds from plan)"
