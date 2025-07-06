#!/bin/bash
# Safe Edit Script - Enforces feature branch workflow
# Usage: ./scripts/safe-edit.sh <feature-name> <task-id> "user request"

set -e

FEATURE_NAME="$1"
TASK_ID="$2"
USER_REQUEST="$3"

if [ -z "$FEATURE_NAME" ] || [ -z "$TASK_ID" ]; then
    echo "Usage: $0 <feature-name> <task-id> \"user request\""
    echo "Example: $0 update-docs #123 \"Update documentation for new feature\""
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Error: You must be on main branch to start a new feature"
    echo "Run: git checkout main"
    exit 1
fi

# Create feature branch
BRANCH_NAME="feature/$FEATURE_NAME"
echo "Creating feature branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

echo
echo "Feature branch created successfully!"
echo "Branch: $BRANCH_NAME"
echo "Task: $TASK_ID"
echo
echo "Make your changes, then commit with:"
echo "git add ."
echo "git commit -m \"Your commit message following template T005\""
echo
echo "When ready to create PR, run:"
echo "./scripts/create-pr.sh \"$FEATURE_NAME\" \"$TASK_ID\" \"$USER_REQUEST\""