#!/bin/bash
# test-task-sync.sh - Comprehensive test suite for task sync system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test environment
TEST_DIR="/tmp/task-sync-test-$$"
TEST_TASKS="$TEST_DIR/TASKS.md"
SYNC_SCRIPT="/Users/ryarasi/deepworkspace/scripts/sync-claude-tasks.sh"
LOAD_SCRIPT="/Users/ryarasi/deepworkspace/scripts/load-tasks.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
setup_test() {
    mkdir -p "$TEST_DIR"
    # Temporarily modify scripts to use test directory
    sed "s|TASKS_FILE=.*|TASKS_FILE=\"$TEST_TASKS\"|" "$SYNC_SCRIPT" > "$TEST_DIR/sync.sh"
    sed "s|TASKS_FILE=.*|TASKS_FILE=\"$TEST_TASKS\"|" "$LOAD_SCRIPT" > "$TEST_DIR/load.sh"
    chmod +x "$TEST_DIR/sync.sh" "$TEST_DIR/load.sh"
}

cleanup_test() {
    rm -rf "$TEST_DIR"
}

run_test() {
    local test_name="$1"
    local test_func="$2"
    
    echo -e "\n${BLUE}TEST: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if $test_func; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Initial save to empty TASKS.md
test_initial_save() {
    # Create empty TASKS.md
    echo "# Test Tasks" > "$TEST_TASKS"
    
    # Simulate saving tasks
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-001", "content": "First task", "status": "pending", "priority": "high"},
      {"id": "task-002", "content": "Second task", "status": "completed", "priority": "medium"}
    ]
  }
}
EOF

    # Verify tasks were saved
    local count=$(grep -c "^### task-" "$TEST_TASKS")
    [ "$count" -eq 2 ]
}

# Test 2: Merge with existing tasks
test_merge_existing() {
    # Setup initial tasks
    cat > "$TEST_TASKS" << 'EOF'
# Test Tasks

## Claude-Managed Tasks
<!-- SYNC_STATUS: last_sync=2025-01-01T00:00:00Z -->

### task-001: Original task
- **Status**: completed
- **Priority**: high

### task-002: Task to update
- **Status**: pending
- **Priority**: low

EOF

    # Save with overlapping and new tasks
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-002", "content": "Task to update (modified)", "status": "in_progress", "priority": "high"},
      {"id": "task-003", "content": "New task", "status": "pending", "priority": "medium"}
    ]
  }
}
EOF

    # Verify:
    # 1. task-001 preserved
    grep -q "task-001: Original task" "$TEST_TASKS" || return 1
    grep -A1 "task-001" "$TEST_TASKS" | grep -q "completed" || return 1
    
    # 2. task-002 updated
    grep -q "task-002: Task to update (modified)" "$TEST_TASKS" || return 1
    grep -A1 "task-002" "$TEST_TASKS" | grep -q "in_progress" || return 1
    
    # 3. task-003 added
    grep -q "task-003: New task" "$TEST_TASKS" || return 1
    
    # 4. Total count = 3
    local count=$(grep -c "^### task-" "$TEST_TASKS")
    [ "$count" -eq 3 ]
}

# Test 3: Load tasks returns correct JSON
test_load_tasks() {
    # Setup test data
    cat > "$TEST_TASKS" << 'EOF'
# Test Tasks

## Claude-Managed Tasks
<!-- SYNC_STATUS: last_sync=2025-01-01T00:00:00Z -->

### task-001: Test load
- **Status**: pending
- **Priority**: high

### task-002: Another task
- **Status**: completed
- **Priority**: low

EOF

    # Load tasks
    local json=$("$TEST_DIR/sync.sh" load)
    
    # Verify JSON structure
    echo "$json" | jq -e 'length == 2' || return 1
    echo "$json" | jq -e '.[0].id == "task-001"' || return 1
    echo "$json" | jq -e '.[1].status == "completed"' || return 1
}

# Test 4: Handle empty TASKS.md
test_empty_file() {
    rm -f "$TEST_TASKS"
    
    # Load from non-existent file
    local json=$("$TEST_DIR/sync.sh" load)
    [ "$json" = "[]" ] || return 1
    
    # Save to non-existent file (should create it)
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-001", "content": "Create file test", "status": "pending", "priority": "high"}
    ]
  }
}
EOF

    # Verify file created with task
    [ -f "$TEST_TASKS" ] || return 1
    grep -q "task-001: Create file test" "$TEST_TASKS" || return 1
}

# Test 5: Preserve non-Claude sections
test_preserve_sections() {
    cat > "$TEST_TASKS" << 'EOF'
# Test Tasks

## Manual Tasks
- Do something manually
- Another manual task

## Claude-Managed Tasks
<!-- SYNC_STATUS: last_sync=2025-01-01T00:00:00Z -->

### task-001: Claude task
- **Status**: pending
- **Priority**: high

## Notes Section
Some important notes here
EOF

    # Save new tasks
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-002", "content": "New Claude task", "status": "pending", "priority": "medium"}
    ]
  }
}
EOF

    # Verify all sections preserved
    grep -q "## Manual Tasks" "$TEST_TASKS" || return 1
    grep -q "Do something manually" "$TEST_TASKS" || return 1
    grep -q "## Notes Section" "$TEST_TASKS" || return 1
    grep -q "Some important notes here" "$TEST_TASKS" || return 1
}

# Test 6: Load script functionality
test_load_script() {
    # Setup test tasks
    cat > "$TEST_TASKS" << 'EOF'
# Test Tasks

## Claude-Managed Tasks
<!-- SYNC_STATUS: last_sync=2025-01-01T00:00:00Z -->

### task-001: Test task
- **Status**: completed
- **Priority**: high

EOF

    # Run load script (redirect to capture output)
    local output=$("$TEST_DIR/load.sh" 2>&1)
    
    # Check for expected output
    echo "$output" | grep -q "Found 1 tasks" || return 1
    echo "$output" | grep -q "task-001: Test task" || return 1
    echo "$output" | grep -q "TodoWrite" || return 1
}

# Test 7: Backup creation
test_backup_creation() {
    echo "# Initial content" > "$TEST_TASKS"
    
    # Save tasks (should create backup)
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-001", "content": "Test backup", "status": "pending", "priority": "high"}
    ]
  }
}
EOF

    # Check backup exists
    ls "$TEST_TASKS".backup-* >/dev/null 2>&1 || return 1
}

# Test 8: Sort order maintained
test_sort_order() {
    # Save tasks in random order
    cat << 'EOF' | "$TEST_DIR/sync.sh" save
{
  "tool_input": {
    "todos": [
      {"id": "task-010", "content": "Task 10", "status": "pending", "priority": "low"},
      {"id": "task-001", "content": "Task 1", "status": "pending", "priority": "high"},
      {"id": "task-005", "content": "Task 5", "status": "pending", "priority": "medium"}
    ]
  }
}
EOF

    # Verify sorted by ID
    local tasks=$(grep "^### task-" "$TEST_TASKS" | cut -d: -f1 | cut -d- -f2)
    local expected="001
005
010"
    [ "$tasks" = "$expected" ] || return 1
}

# Main test runner
main() {
    echo -e "${BLUE}=== Task Sync System Test Suite ===${NC}"
    
    # Setup
    setup_test
    
    # Run all tests
    run_test "Initial save to empty file" test_initial_save
    run_test "Merge with existing tasks" test_merge_existing
    run_test "Load tasks returns correct JSON" test_load_tasks
    run_test "Handle empty TASKS.md" test_empty_file
    run_test "Preserve non-Claude sections" test_preserve_sections
    run_test "Load script functionality" test_load_script
    run_test "Backup creation" test_backup_creation
    run_test "Sort order maintained" test_sort_order
    
    # Summary
    echo -e "\n${BLUE}=== Test Summary ===${NC}"
    echo -e "Tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    # Cleanup
    cleanup_test
    
    # Exit code
    [ $TESTS_FAILED -eq 0 ]
}

# Run tests
main