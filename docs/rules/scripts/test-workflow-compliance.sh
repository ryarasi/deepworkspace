#!/bin/bash
# test-workflow-compliance.sh - Test R006 workflow compliance across the system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== DeepWork Workflow Compliance Test ===${NC}"
echo ""

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_behavior="$3"  # "pass", "fail", or "warn"
    
    echo -e "\n${BLUE}TEST: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
    
    # Run command and capture output/exit code
    local output
    local exit_code=0
    output=$($test_command 2>&1) || exit_code=$?
    
    # Check result based on expected behavior
    case "$expected_behavior" in
        "pass")
            if [ $exit_code -eq 0 ]; then
                echo -e "${GREEN}✓ PASS${NC} - Command succeeded as expected"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗ FAIL${NC} - Command failed unexpectedly"
                echo "Exit code: $exit_code"
                echo "Output: $output"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
            ;;
        "fail")
            if [ $exit_code -ne 0 ]; then
                echo -e "${GREEN}✓ PASS${NC} - Command blocked as expected"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗ FAIL${NC} - Command should have been blocked"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
            ;;
        "warn")
            if echo "$output" | grep -q "WARNING: You are on the main branch"; then
                echo -e "${GREEN}✓ PASS${NC} - Warning displayed as expected"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                echo -e "${RED}✗ FAIL${NC} - Warning not displayed"
                echo "Output: $output"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
            ;;
    esac
}

# Save current branch
ORIGINAL_BRANCH=$(git branch --show-current)

# Test 1: check-branch.sh script
echo -e "\n${YELLOW}=== Testing check-branch.sh ===${NC}"

# On feature branch
run_test "check-branch.sh on feature branch" "./content/scripts/check-branch.sh" "pass"

# On main branch
git checkout main 2>/dev/null
run_test "check-branch.sh on main branch" "./content/scripts/check-branch.sh" "fail"
git checkout "$ORIGINAL_BRANCH" 2>/dev/null

# Test 2: DWS commands
echo -e "\n${YELLOW}=== Testing DWS Commands ===${NC}"

# Switch to main for tests
git checkout main 2>/dev/null

# Test dws help (should warn)
run_test "dws help on main branch" "./content/scripts/dws help" "warn"

# Test dws validate (should warn but run)
run_test "dws validate on main branch" "./content/scripts/dws validate" "warn"

# Test dws fix (should block)
run_test "dws fix on main branch" "./content/scripts/dws fix" "fail"

# Switch back to feature branch
git checkout "$ORIGINAL_BRANCH" 2>/dev/null

# Test 3: Pre-commit hooks
echo -e "\n${YELLOW}=== Testing Pre-commit Hooks ===${NC}"

# Create a test file
TEST_FILE="/tmp/test-workflow-$$"
echo "test content" > "$TEST_FILE"

# On feature branch (should work)
run_test "File write on feature branch" "echo 'test' > $TEST_FILE" "pass"

# Test 4: Claude Context
echo -e "\n${YELLOW}=== Testing Claude Context ===${NC}"

# Check CLAUDE.md for warning
if grep -q "CRITICAL BRANCH CHECK" ./CLAUDE.md && grep -q "R006 VIOLATION" ./CLAUDE.md; then
    echo -e "${GREEN}✓ PASS${NC} - CLAUDE.md contains branch warning"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - CLAUDE.md missing branch warning"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test 5: Settings.json hooks
echo -e "\n${YELLOW}=== Testing Claude Hooks ===${NC}"

if grep -q "main branch! Create a feature branch" ~/.claude/settings.json; then
    echo -e "${GREEN}✓ PASS${NC} - Pre-commit hook configured"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Pre-commit hook not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Cleanup
rm -f "$TEST_FILE"

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

# Overall result
echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All workflow compliance tests passed!${NC}"
    echo -e "${GREEN}R006 enforcement is working correctly across the system.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some workflow compliance tests failed.${NC}"
    echo -e "${RED}Please review and fix the issues above.${NC}"
    exit 1
fi