#!/bin/bash
# Generate branch-specific context for Claude
# Called by git post-checkout hook

set -e

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CONTEXT_FILE="$PWD/.claude/branch-context.md"

# Ensure .claude directory exists
mkdir -p "$PWD/.claude"

# Remove context file if on main branch
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    rm -f "$CONTEXT_FILE"
    exit 0
fi

# Generate branch-specific context
cat > "$CONTEXT_FILE" << EOF
## ⚠️ BRANCH WARNING: You are on feature branch \`$CURRENT_BRANCH\`

### Current Git Status:
- **Branch**: $CURRENT_BRANCH
- **Working Directory**: $PWD

### Workspace Rules Reminder:
- **R006**: All changes must be made in feature branches
- **R007**: Commits must follow template T005 format
- **R008**: PRs must follow template T006 format

### Recommended Workflow:
1. Make your changes in this feature branch
2. Commit with descriptive messages following T005
3. When ready, create PR using: \`dws pr create -t "title"\`
4. After PR approval: \`dws pr merge\`

### Quick Commands:
\`\`\`bash
# Check current status
git status

# Stage and commit changes
git add .
git commit -m "type(scope): description"

# Create PR (recommended over gh pr)
dws pr create -t "feat: your feature description"

# Complete PR workflow
dws pr merge
\`\`\`

---
*This warning is dynamically generated based on your current branch.*
EOF

echo "Generated branch context for: $CURRENT_BRANCH"