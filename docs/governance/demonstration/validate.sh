#!/bin/bash
# Validate R003 - Self Demonstration
# Ensures the project demonstrates its own governance system

set -e

PROJECT_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

echo "Validating self-demonstration in: $PROJECT_DIR"
echo "========================================="

# Check if this is the governance project itself
if [ -d "$PROJECT_DIR/docs/governance" ]; then
    echo -e "${GREEN}✓${NC} Project contains governance system"
    
    # Check if it follows its own rules
    echo -n "Checking if project follows its own structure rule... "
    if [ -f "$PROJECT_DIR/README.md" ] && [ -d "$PROJECT_DIR/docs" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        ((ERRORS++))
    fi
    
    # Check if governance docs have template references
    echo -n "Checking if governance docs follow templates... "
    if [ -f "$PROJECT_DIR/docs/GOVERNANCE.md" ] || [ -f "$PROJECT_DIR/docs/RULES.md" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ No governance entry point found${NC}"
    fi
else
    echo -e "${GREEN}✓${NC} Not a governance project - rule satisfied"
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Self-demonstration valid${NC}"
    exit 0
else
    echo -e "${RED}✗ Self-demonstration failed${NC}"
    exit 1
fi