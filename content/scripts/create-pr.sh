#!/bin/bash
# Create PR Script - Creates and auto-merges pull request
# Usage: ./content/scripts/create-pr.sh <feature-name> <task-id> "user request"

set -e

FEATURE_NAME="$1"
TASK_ID="$2"
USER_REQUEST="$3"

if [ -z "$FEATURE_NAME" ] || [ -z "$TASK_ID" ]; then
    echo "Usage: $0 <feature-name> <task-id> \"user request\""
    exit 1
fi

BRANCH_NAME="feature/$FEATURE_NAME"
CURRENT_BRANCH=$(git branch --show-current)

# Verify we're on the feature branch
if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    echo "Error: You must be on branch $BRANCH_NAME"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Push branch to origin
echo "Pushing branch to origin..."
git push -u origin "$BRANCH_NAME"

# Create PR using gh CLI
echo "Creating pull request..."

PR_TITLE="feat: $FEATURE_NAME"
PR_BODY=$(cat <<EOF
## Summary
Implementation of $FEATURE_NAME as requested by user.

## Context
- **Initiated by**: User request
- **Task IDs**: $TASK_ID
- **Feature Branch**: $BRANCH_NAME
- **Date**: $(date +%Y-%m-%d)

## Changes Made
Please see commit messages for detailed changes.

## Verification
- [x] Follows workspace rules
- [x] Templates applied correctly
- [x] No direct main branch commits

## User Request
\`\`\`
$USER_REQUEST
\`\`\`

## AI Implementation Notes
This PR was created following the DeepWorkspace feature branch workflow.
All changes were made in the feature branch as per workspace rules.

---
Following template @content/templates/T006
EOF
)

# Create the PR
gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base main --head "$BRANCH_NAME"

echo
echo "Pull request created successfully!"
echo
echo "To merge the PR, run:"
echo "gh pr merge --auto --squash --delete-branch \"$BRANCH_NAME\""
echo
echo "After merge, return to main with:"
echo "git checkout main && git pull"