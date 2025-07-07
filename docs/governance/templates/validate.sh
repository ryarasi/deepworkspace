#!/bin/bash
# Validate R002 - Template Integrity
# This script validates that documents follow their declared templates

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

echo "Validating template usage in: $PROJECT_DIR"
echo "========================================="

# Function to check if a file has a template reference
check_template_reference() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Skip files that don't need templates
    if [[ "$filename" == "README.md" ]] || [[ "$filename" == "GOVERNANCE.md" ]]; then
        return 0
    fi
    
    # Check for template reference in first 10 lines
    if head -n 10 "$file" | grep -q "This file follows template"; then
        echo -e "${GREEN}✓${NC} $file"
        return 0
    else
        echo -e "${RED}✗${NC} $file - missing template reference"
        return 1
    fi
}

# Check all markdown files in docs/
echo "Checking markdown files for template references..."
while IFS= read -r -d '' file; do
    if ! check_template_reference "$file"; then
        ((ERRORS++))
    fi
done < <(find "$PROJECT_DIR/docs" -name "*.md" -type f -print0 2>/dev/null)

# Check all yaml files for template structure
echo
echo "Checking template files for required fields..."
if [ -d "$PROJECT_DIR/docs/governance/templates/library" ]; then
    for template in "$PROJECT_DIR/docs/governance/templates/library"/*.yaml; do
        if [ -f "$template" ]; then
            echo -n "$(basename "$template"): "
            # Check for required fields
            if grep -q "^id:" "$template" && \
               grep -q "^name:" "$template" && \
               grep -q "^purpose:" "$template" && \
               grep -q "^content:" "$template"; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗ Missing required fields${NC}"
                ((ERRORS++))
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠ No template library found${NC}"
    ((WARNINGS++))
fi

# Summary
echo
echo "Validation Summary"
echo "=================="
echo -e "Errors: ${ERRORS}"
echo -e "Warnings: ${WARNINGS}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Template usage is valid${NC}"
    exit 0
else
    echo -e "${RED}✗ Template validation failed${NC}"
    exit 1
fi