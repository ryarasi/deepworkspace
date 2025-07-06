#!/bin/bash
# test-timestamp-sync.sh - Test timestamp tracking in sync script

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Testing Timestamp Tracking in Sync Script ===${NC}"
echo ""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Backup existing TASKS.md
TASKS_FILE="/Users/ryarasi/deepworkspace/.untracked/local/TASKS.md"
BACKUP_FILE="${TASKS_FILE}.test-backup-$(date +%Y%m%d-%H%M%S)"
cp "$TASKS_FILE" "$BACKUP_FILE"
echo "Backed up TASKS.md to $BACKUP_FILE"

# Helper to run a test
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -e "\n${BLUE}TEST: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if $test_function; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: New task gets timestamp
test_new_task_timestamp() {
    # Create test input with a new task
    local test_input=$(cat <<EOF
{
  "session_id": "test-timestamp",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-999",
        "content": "Test task with timestamp",
        "status": "pending",
        "priority": "high"
      }
    ]
  }
}
EOF
)
    
    # Save the task
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Check if timestamp was added
    if grep -A 3 "task-999" "$TASKS_FILE" | grep -q "Last Modified"; then
        echo "Timestamp was added to new task"
        return 0
    else
        echo "Timestamp was NOT added to new task"
        return 1
    fi
}

# Test 2: Unchanged task keeps original timestamp
test_unchanged_task_timestamp() {
    # Get current timestamp for task-004
    local original_timestamp=$(grep -A 3 "task-004" "$TASKS_FILE" | grep "Last Modified" | sed 's/.*: //')
    
    # Save the same task again without changes
    local test_input=$(cat <<EOF
{
  "session_id": "test-timestamp",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-004",
        "content": "Create sync-claude-tasks.sh script with bidirectional sync functions",
        "status": "completed",
        "priority": "high"
      }
    ]
  }
}
EOF
)
    
    # Wait a second to ensure different timestamp if it changes
    sleep 1
    
    # Save the task
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Check if timestamp remained the same
    local new_timestamp=$(grep -A 3 "task-004" "$TASKS_FILE" | grep "Last Modified" | sed 's/.*: //')
    
    if [[ "$original_timestamp" == "$new_timestamp" ]] || [[ -z "$new_timestamp" ]]; then
        echo "Timestamp remained unchanged for unmodified task"
        return 0
    else
        echo "Timestamp changed unexpectedly: $original_timestamp -> $new_timestamp"
        return 1
    fi
}

# Test 3: Changed task gets new timestamp
test_changed_task_timestamp() {
    # Get current timestamp for task-022
    local original_timestamp=$(grep -A 4 "task-022" "$TASKS_FILE" | grep "Last Modified" | sed 's/.*: //')
    
    # Change the task status
    local test_input=$(cat <<EOF
{
  "session_id": "test-timestamp",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-022",
        "content": "Add task state tracking with timestamps to sync script",
        "status": "completed",
        "priority": "high"
      }
    ]
  }
}
EOF
)
    
    # Wait a second to ensure different timestamp
    sleep 1
    
    # Save the task
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Check if timestamp changed
    local new_timestamp=$(grep -A 4 "task-022" "$TASKS_FILE" | grep "Last Modified" | sed 's/.*: //')
    
    if [[ "$new_timestamp" != "$original_timestamp" ]] && [[ -n "$new_timestamp" ]]; then
        echo "Timestamp updated for modified task"
        return 0
    else
        echo "Timestamp did not update for modified task"
        return 1
    fi
}

# Test 4: Load preserves timestamps
test_load_preserves_timestamps() {
    # Load tasks and check if timestamps are included
    local loaded_tasks=$(./content/scripts/sync-claude-tasks.sh load)
    
    # Check if task-999 has timestamp in loaded data
    if echo "$loaded_tasks" | jq -e '.[] | select(.id == "task-999") | .last_modified' > /dev/null; then
        echo "Timestamps preserved when loading tasks"
        return 0
    else
        echo "Timestamps not preserved when loading tasks"
        return 1
    fi
}

# Run all tests
run_test "New task gets timestamp" test_new_task_timestamp
run_test "Unchanged task keeps original timestamp" test_unchanged_task_timestamp
run_test "Changed task gets new timestamp" test_changed_task_timestamp
run_test "Load preserves timestamps" test_load_preserves_timestamps

# Restore original TASKS.md
cp "$BACKUP_FILE" "$TASKS_FILE"
rm "$BACKUP_FILE"
echo -e "\nRestored original TASKS.md"

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

# Overall result
echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All timestamp tracking tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some timestamp tracking tests failed.${NC}"
    exit 1
fi