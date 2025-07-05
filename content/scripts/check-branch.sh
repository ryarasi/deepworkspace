#!/bin/bash
# check-branch.sh - Verify git branch compliance for DeepWorkspace
# Part of R006 enforcement - prevents accidental main branch edits

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not in a git repository${NC}"
    exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Function to show branch status
show_branch_status() {
    echo -e "\n${BLUE}=== Git Branch Status ===${NC}"
    echo -e "Current branch: ${YELLOW}$CURRENT_BRANCH${NC}"
    
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        echo -e "\n${RED}❌ WARNING: You are on the main branch!${NC}"
        echo -e "${RED}Per R006, all changes must be made on feature branches.${NC}\n"
        echo -e "To create a feature branch:"
        echo -e "  ${GREEN}git checkout -b feature/your-description${NC}"
        echo -e "\nOr use the safe-edit script:"
        echo -e "  ${GREEN}./content/scripts/safe-edit.sh${NC}"
        
        # Check for uncommitted changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "\n${YELLOW}⚠️  You have uncommitted changes:${NC}"
            git status --short
            echo -e "\nTo save your work:"
            echo -e "  1. ${GREEN}git stash${NC} - Temporarily save changes"
            echo -e "  2. ${GREEN}git checkout -b feature/branch-name${NC} - Create feature branch"
            echo -e "  3. ${GREEN}git stash pop${NC} - Apply your changes"
        fi
        
        # Return error code to prevent operations
        return 1
    else
        echo -e "${GREEN}✓ On feature branch: $CURRENT_BRANCH${NC}"
        
        # Show uncommitted changes if any
        if ! git diff --quiet || ! git diff --cached --quiet; then
            echo -e "\n${YELLOW}Uncommitted changes:${NC}"
            git status --short
        else
            echo -e "${GREEN}✓ Working directory clean${NC}"
        fi
        
        # Check if branch exists on remote
        if ! git ls-remote --heads origin "$CURRENT_BRANCH" | grep -q .; then
            echo -e "\n${YELLOW}Note: Branch not yet pushed to remote${NC}"
            echo -e "When ready, push with:"
            echo -e "  ${GREEN}git push -u origin $CURRENT_BRANCH${NC}"
        fi
    fi
}

# Function to suggest next steps
suggest_next_steps() {
    echo -e "\n${BLUE}=== Suggested Next Steps ===${NC}"
    
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        echo -e "1. Create a feature branch before making changes"
        echo -e "2. Follow the PR workflow described in R006"
    else
        echo -e "1. Make your changes"
        echo -e "2. Commit with: ${GREEN}git commit -m \"type: description\"${NC} (see T005)"
        echo -e "3. Create PR with: ${GREEN}./content/scripts/create-pr.sh${NC}"
    fi
}

# Main execution
echo -e "${BLUE}DeepWorkspace Branch Compliance Check${NC}"
echo -e "${BLUE}=====================================/${NC}"

if show_branch_status; then
    suggest_next_steps
    exit 0
else
    # On main branch - show warning and exit with error
    suggest_next_steps
    echo -e "\n${RED}⚠️  Branch check failed - please switch to a feature branch${NC}"
    exit 1
fi