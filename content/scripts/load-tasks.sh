#!/bin/bash
# load-tasks.sh - Manual task loader for Claude sessions
# Since PreToolUse hooks can't inject data, this provides a manual way to load tasks

set -euo pipefail

SYNC_SCRIPT="/Users/ryarasi/deepworkspace/content/scripts/sync-claude-tasks.sh"
TASKS_FILE="/Users/ryarasi/deepworkspace/.untracked/local/TASKS.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Claude Task Loader ===${NC}"
echo ""

# Check if TASKS.md exists
if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: TASKS.md not found at $TASKS_FILE${NC}"
    exit 1
fi

# Load tasks from TASKS.md
echo -e "${YELLOW}Loading tasks from TASKS.md...${NC}"
TASKS_JSON=$("$SYNC_SCRIPT" load)

# Count tasks
TASK_COUNT=$(echo "$TASKS_JSON" | jq 'length')

if [ "$TASK_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No tasks found in TASKS.md${NC}"
    exit 0
fi

echo -e "${GREEN}Found $TASK_COUNT tasks in TASKS.md${NC}"
echo ""

# Display tasks summary
echo -e "${BLUE}Task Summary:${NC}"
echo "$TASKS_JSON" | jq -r '.[] | "- [\(.status)] \(.id): \(.content)"' | \
    sed 's/\[completed\]/✓/g' | \
    sed 's/\[in_progress\]/⚡/g' | \
    sed 's/\[pending\]/○/g'

echo ""
echo -e "${BLUE}=== Instructions for Claude ===${NC}"
echo -e "${YELLOW}To import these tasks into your TodoWrite system, copy and run this command:${NC}"
echo ""
echo -e "${GREEN}TodoWrite${NC}"
echo "$TASKS_JSON" | jq -c '.'
echo ""
echo -e "${YELLOW}Note: This manual load is necessary because PreToolUse hooks cannot inject data into Claude tools.${NC}"
echo -e "${YELLOW}Run this at the start of each Claude session to restore your task list.${NC}"

# Optionally create a quick copy command
echo ""
echo -e "${BLUE}Quick copy command (for macOS):${NC}"
echo "$TASKS_JSON" | jq -c '.' | pbcopy && echo -e "${GREEN}✓ Tasks JSON copied to clipboard!${NC}"