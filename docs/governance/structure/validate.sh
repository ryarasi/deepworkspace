#!/bin/bash
# Validate R001 - Project Structure
# This script validates that a project follows the required fractal structure

set -e

# Get the directory to validate (default to current directory)
PROJECT_DIR="${1:-.}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation results
ERRORS=0
WARNINGS=0

echo "Validating project structure in: $PROJECT_DIR"
echo "========================================="

# Check required files
echo -n "Checking README.md... "
if [ -f "$PROJECT_DIR/README.md" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Missing${NC}"
    ((ERRORS++))
fi

# Check required directories
echo -n "Checking docs/ directory... "
if [ -d "$PROJECT_DIR/docs" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Missing${NC}"
    ((ERRORS++))
fi

# Check for gitignored directories (they should exist)
for dir in .local projects repos; do
    echo -n "Checking $dir/ directory... "
    if [ -d "$PROJECT_DIR/$dir" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ Missing (optional but recommended)${NC}"
        ((WARNINGS++))
    fi
done

# Check for legacy .untracked directory
if [ -d "$PROJECT_DIR/.untracked" ]; then
    echo -e "${YELLOW}⚠ Legacy .untracked/ directory found (should migrate to new structure)${NC}"
    ((WARNINGS++))
fi

# Check for prohibited files at root
echo -n "Checking for prohibited root files... "
PROHIBITED_FILES=0
for file in "$PROJECT_DIR"/*.yaml "$PROJECT_DIR"/*.yml "$PROJECT_DIR"/*.sh; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "." ]; then
        ((PROHIBITED_FILES++))
    fi
done

if [ $PROHIBITED_FILES -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Found $PROHIBITED_FILES prohibited files at root${NC}"
    ((ERRORS++))
fi

# Summary
echo
echo "Validation Summary"
echo "=================="
echo -e "Errors: ${ERRORS}"
echo -e "Warnings: ${WARNINGS}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Project structure is valid${NC}"
    exit 0
else
    echo -e "${RED}✗ Project structure validation failed${NC}"
    exit 1
fi