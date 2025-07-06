#!/bin/bash
# test-sync-e2e.sh - End-to-end test of complete sync workflow

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== End-to-End Task Sync Workflow Test ===${NC}"
echo ""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

# Test 1: Load tasks at session start
test_session_start_load() {
    echo "Simulating session start with load-tasks.sh..."
    
    # Run load script and check output
    local output=$(./content/scripts/load-tasks.sh 2>&1)
    
    if echo "$output" | grep -q "Found [0-9]* tasks in TASKS.md"; then
        echo "Tasks loaded successfully at session start"
        return 0
    else
        echo "Failed to load tasks at session start"
        return 1
    fi
}

# Test 2: Create new task via TodoWrite
test_create_new_task() {
    echo "Creating new task via TodoWrite hook..."
    
    # Simulate TodoWrite with new task
    local test_input=$(cat <<EOF
{
  "session_id": "e2e-test",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-e2e-001",
        "content": "End-to-end test task",
        "status": "pending",
        "priority": "high"
      }
    ]
  }
}
EOF
)
    
    # Save via sync script
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Verify task was saved
    if grep -q "task-e2e-001" /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md; then
        echo "New task created and saved to TASKS.md"
        return 0
    else
        echo "Failed to save new task"
        return 1
    fi
}

# Test 3: Update existing task
test_update_task() {
    echo "Updating existing task status..."
    
    # Get current timestamp if exists
    local old_timestamp=$(grep -A 3 "task-e2e-001" /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md | grep "Last Modified" | sed 's/.*: //' || echo "")
    
    # Wait to ensure different timestamp
    sleep 1
    
    # Update task status
    local test_input=$(cat <<EOF
{
  "session_id": "e2e-test",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-e2e-001",
        "content": "End-to-end test task",
        "status": "completed",
        "priority": "high"
      }
    ]
  }
}
EOF
)
    
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Verify status changed and timestamp updated
    if grep -A 2 "task-e2e-001" /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md | grep -q "completed"; then
        local new_timestamp=$(grep -A 3 "task-e2e-001" /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md | grep "Last Modified" | sed 's/.*: //')
        if [[ "$new_timestamp" != "$old_timestamp" ]]; then
            echo "Task updated with new timestamp"
            return 0
        else
            echo "Timestamp did not update"
            return 1
        fi
    else
        echo "Failed to update task status"
        return 1
    fi
}

# Test 4: Concurrent updates (merge test)
test_concurrent_updates() {
    echo "Testing concurrent updates from multiple sources..."
    
    # Load existing tasks first
    local existing_tasks=$(./content/scripts/sync-claude-tasks.sh load)
    local existing_count=$(echo "$existing_tasks" | jq 'length')
    
    # First update - add task from Claude session 1
    local claude_input=$(cat <<EOF
{
  "session_id": "e2e-test-1",
  "transcript_path": "~/.claude/test1.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-e2e-002",
        "content": "Concurrent test task A",
        "status": "pending",
        "priority": "medium"
      }
    ]
  }
}
EOF
)
    
    echo "$claude_input" | ./content/scripts/sync-claude-tasks.sh save > /dev/null 2>&1
    
    # Second update - add different task from session 2  
    local claude_input2=$(cat <<EOF
{
  "session_id": "e2e-test-2",
  "transcript_path": "~/.claude/test2.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-e2e-003",
        "content": "Concurrent test task B",
        "status": "pending",
        "priority": "low"
      }
    ]
  }
}
EOF
)
    
    echo "$claude_input2" | ./content/scripts/sync-claude-tasks.sh save > /dev/null 2>&1
    
    # Verify both tasks exist by loading all tasks
    local all_tasks=$(./content/scripts/sync-claude-tasks.sh load)
    local new_count=$(echo "$all_tasks" | jq 'length')
    
    # Should have 2 more tasks than before
    if [[ $new_count -eq $((existing_count + 2)) ]]; then
        echo "Concurrent updates merged successfully (was $existing_count, now $new_count)"
        return 0
    else
        echo "Failed to merge concurrent updates (expected $((existing_count + 2)), got $new_count)"
        return 1
    fi
}

# Test 5: Sync status check
test_sync_status() {
    echo "Checking sync status..."
    
    local status_output=$(./content/scripts/sync-claude-tasks.sh check)
    
    if echo "$status_output" | grep -q "Last sync:" && \
       echo "$status_output" | grep -q "Claude-managed tasks"; then
        echo "Sync status check working"
        return 0
    else
        echo "Sync status check failed"
        return 1
    fi
}

# Test 6: Backup creation
test_backup_creation() {
    echo "Verifying backup creation on save..."
    
    # Count current backups
    local backup_count_before=$(ls -1 /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md.backup-* 2>/dev/null | wc -l)
    
    # Trigger a save
    local test_input=$(cat <<EOF
{
  "session_id": "e2e-backup-test",
  "transcript_path": "~/.claude/test.jsonl",
  "tool_name": "TodoWrite",
  "tool_input": {
    "todos": [
      {
        "id": "task-backup-test",
        "content": "Backup test task",
        "status": "pending",
        "priority": "low"
      }
    ]
  }
}
EOF
)
    
    echo "$test_input" | ./content/scripts/sync-claude-tasks.sh save
    
    # Count backups after
    local backup_count_after=$(ls -1 /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md.backup-* 2>/dev/null | wc -l)
    
    if [[ $backup_count_after -gt $backup_count_before ]]; then
        echo "Backup created successfully"
        return 0
    else
        echo "No backup was created"
        return 1
    fi
}

# Test 7: Load after modifications
test_load_after_changes() {
    echo "Testing load functionality after changes..."
    
    # Load current tasks
    local loaded_tasks=$(./content/scripts/sync-claude-tasks.sh load)
    
    # Check if our test tasks are in the loaded data
    if echo "$loaded_tasks" | jq -e '.[] | select(.id == "task-e2e-001")' > /dev/null 2>&1 && \
       echo "$loaded_tasks" | jq -e '.[] | select(.id == "task-e2e-001") | select(.status == "completed")' > /dev/null 2>&1; then
        echo "Tasks loaded correctly with updated status"
        return 0
    else
        echo "Failed to load tasks with correct status"
        echo "Debug: Loaded tasks = $loaded_tasks"
        return 1
    fi
}

# Run all tests
echo -e "${YELLOW}Starting end-to-end workflow tests...${NC}"

run_test "Session start load" test_session_start_load
run_test "Create new task" test_create_new_task
run_test "Update existing task" test_update_task
run_test "Concurrent updates" test_concurrent_updates
run_test "Sync status check" test_sync_status
run_test "Backup creation" test_backup_creation
run_test "Load after changes" test_load_after_changes

# Clean up test tasks
echo -e "\n${YELLOW}Cleaning up test tasks...${NC}"
# Remove test tasks from TASKS.md
sed -i '' '/task-e2e-001/,+3d' /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md
sed -i '' '/task-e2e-002/,+3d' /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md
sed -i '' '/task-e2e-003/,+3d' /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md
sed -i '' '/task-backup-test/,+3d' /Users/ryarasi/deepworkspace/.untracked/local/TASKS.md

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

# Overall result
echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All end-to-end tests passed!${NC}"
    echo -e "${GREEN}The complete sync workflow is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some end-to-end tests failed.${NC}"
    exit 1
fi