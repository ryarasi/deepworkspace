#!/bin/bash
# Initialize DeepWorkspace by cloning child projects

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPOS_DIR="$WORKSPACE_ROOT/.untracked/repos"

echo -e "${GREEN}DeepWorkspace Project Initialization${NC}"
echo "======================================="
echo

# Ensure repos directory exists
mkdir -p "$REPOS_DIR"

# Function to clone a project
clone_project() {
    local name="$1"
    local url="$2"
    local target_dir="$REPOS_DIR/$name"
    
    if [[ "$url" == *"PLACEHOLDER"* ]]; then
        echo -e "${YELLOW}⚠ Skipping $name - placeholder URL${NC}"
        return
    fi
    
    if [[ -d "$target_dir" ]]; then
        echo -e "${GREEN}✓ $name already exists${NC}"
        return
    fi
    
    echo -e "${GREEN}→ Cloning $name...${NC}"
    if git clone "$url" "$target_dir"; then
        echo -e "${GREEN}✓ Successfully cloned $name${NC}"
    else
        echo -e "${RED}✗ Failed to clone $name${NC}"
        return 1
    fi
}

# Parse projects from README.md
echo "Reading project list from README.md..."
echo

# Extract project lines from the Projects section
projects_section=false
while IFS= read -r line; do
    # Check if we're in the Projects section
    if [[ "$line" == "## Projects" ]]; then
        projects_section=true
        continue
    fi
    
    # Stop at the next section
    if $projects_section && [[ "$line" == "##"* ]] && [[ "$line" != "## Projects" ]]; then
        break
    fi
    
    # Parse project lines (format: - **name**: description | `URL`)
    if $projects_section && [[ "$line" =~ ^-\ \*\*([^*]+)\*\*:.*\|\ \`([^\`]+)\` ]]; then
        project_name="${BASH_REMATCH[1]}"
        project_url="${BASH_REMATCH[2]}"
        clone_project "$project_name" "$project_url"
    fi
done < "$WORKSPACE_ROOT/README.md"

echo
echo -e "${GREEN}Initialization complete!${NC}"
echo

# Show current repos
echo "Current repositories in .untracked/repos/:"
if [[ -d "$REPOS_DIR" ]] && [[ -n "$(ls -A "$REPOS_DIR" 2>/dev/null)" ]]; then
    ls -la "$REPOS_DIR"
else
    echo "(none)"
fi

echo
echo "To work with a project:"
echo "  cd .untracked/repos/PROJECT_NAME"
echo
echo "To create a new project:"
echo "  dws create"