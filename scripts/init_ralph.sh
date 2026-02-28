#!/bin/bash
# Ralph Loop Initialization Script
# Sets up spec.md, implementation_plan.md, prompt.md, and run.sh in your project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if directory argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a target directory${NC}"
    echo "Usage: init_ralph.sh /path/to/project"
    exit 1
fi

TARGET_DIR="$1"
SPECS_DIR="$TARGET_DIR/specs"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist${NC}"
    exit 1
fi

# Create specs directory
echo -e "${GREEN}Creating specs directory...${NC}"
mkdir -p "$SPECS_DIR"

# Get the script's directory to find templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../assets/templates"

# Copy templates
echo -e "${GREEN}Copying Ralph Loop templates...${NC}"

# Create spec.md
if [ -f "$TEMPLATES_DIR/spec.md" ]; then
    cp "$TEMPLATES_DIR/spec.md" "$SPECS_DIR/spec.md"
    echo "  ✓ Created specs/spec.md"
else
    echo -e "${YELLOW}Warning: spec.md template not found${NC}"
fi

# Create implementation_plan.md
if [ -f "$TEMPLATES_DIR/implementation_plan.md" ]; then
    cp "$TEMPLATES_DIR/implementation_plan.md" "$SPECS_DIR/implementation_plan.md"
    echo "  ✓ Created specs/implementation_plan.md"
else
    echo -e "${YELLOW}Warning: implementation_plan.md template not found${NC}"
fi

# Create prompt.md
if [ -f "$TEMPLATES_DIR/prompt.md" ]; then
    cp "$TEMPLATES_DIR/prompt.md" "$SPECS_DIR/prompt.md"
    echo "  ✓ Created specs/prompt.md"
else
    echo -e "${YELLOW}Warning: prompt.md template not found${NC}"
fi

# Create run.sh
if [ -f "$TEMPLATES_DIR/run.sh" ]; then
    cp "$TEMPLATES_DIR/run.sh" "$TARGET_DIR/run.sh"
    chmod +x "$TARGET_DIR/run.sh"
    echo "  ✓ Created run.sh (executable)"
else
    echo -e "${YELLOW}Warning: run.sh template not found${NC}"
fi

echo ""
echo -e "${GREEN}✨ Ralph Loop initialized in $TARGET_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit specs/spec.md with your feature requirements"
echo "2. Edit specs/implementation_plan.md with your task list"
echo "3. Update specs/prompt.md with repository-specific context"
echo "4. Run: ./run.sh"
echo ""
echo -e "${YELLOW}Remember: Run the loop while watching at first!${NC}"
