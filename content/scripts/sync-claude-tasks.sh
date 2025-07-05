#!/bin/bash
# sync-claude-tasks.sh - Bidirectional sync between Claude TodoWrite/TodoRead and TASKS.md
# Usage: 
#   sync-claude-tasks.sh save    - Save todos from Claude to TASKS.md (called by hook)
#   sync-claude-tasks.sh load    - Load tasks from TASKS.md to Claude
#   sync-claude-tasks.sh check   - Check sync status

set -euo pipefail

TASKS_FILE="/Users/ryarasi/deepworkspace/.untracked/local/TASKS.md"
CLAUDE_DIR="$HOME/.claude"
SYNC_LOG="/tmp/claude-task-sync.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$SYNC_LOG"
}

# Extract todos from stdin JSON (PostToolUse hook format)
extract_todos_from_stdin() {
    local json_input
    json_input=$(cat)
    
    # Log the input for debugging
    log "Received JSON input: $json_input"
    
    # Extract the todos array from tool_input
    echo "$json_input" | jq -r '.tool_input.todos // empty'
}

# Save todos from Claude to TASKS.md
save_todos_to_tasks() {
    log "Starting save_todos_to_tasks"
    
    # Read todos from stdin
    local todos_json
    todos_json=$(extract_todos_from_stdin)
    
    if [ -z "$todos_json" ]; then
        log "No todos found in input"
        return 0
    fi
    
    # Create backup of TASKS.md
    cp "$TASKS_FILE" "${TASKS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Create temporary file for new content
    local temp_file="/tmp/tasks_update_$$.md"
    
    # Start building new TASKS.md content
    {
        # Copy everything before Claude-Managed Tasks section
        awk '/^## Claude-Managed Tasks/ {exit} {print}' "$TASKS_FILE"
        
        # Add Claude-Managed Tasks section
        echo "## Claude-Managed Tasks"
        echo "<!-- SYNC_STATUS: last_sync=$(date -u +%Y-%m-%dT%H:%M:%SZ) -->"
        echo ""
        
        # Parse and add each todo
        echo "$todos_json" | jq -r '.[] | 
            "### \(.id): \(.content)\n" +
            "- **Status**: \(.status)\n" +
            "- **Priority**: \(.priority)\n"'
        
        # Check if there's content after Claude-Managed Tasks section
        if awk '/^## Claude-Managed Tasks/ {found=1; next} found && /^## [^C]/ {exit 1}' "$TASKS_FILE"; then
            # No section after Claude-Managed Tasks, we're done
            :
        else
            # There is content after Claude-Managed Tasks, copy it
            awk '/^## Claude-Managed Tasks/ {found=1} found && /^## [^C]/ {p=1} p {print}' "$TASKS_FILE"
        fi
        
    } > "$temp_file"
    
    # Replace TASKS.md with updated content
    mv "$temp_file" "$TASKS_FILE"
    
    log "Successfully saved $(echo "$todos_json" | jq 'length') todos to TASKS.md"
}

# Load tasks from TASKS.md to Claude
load_tasks_to_claude() {
    log "Starting load_tasks_to_claude"
    
    # Check if TASKS.md exists
    if [ ! -f "$TASKS_FILE" ]; then
        log "TASKS.md not found"
        return 0
    fi
    
    # Extract Claude-managed tasks from TASKS.md
    local tasks_section
    tasks_section=$(awk '/^## Claude-Managed Tasks/,/^## [^C]/' "$TASKS_FILE" | grep -E "^### task-" -A 2 || true)
    
    if [ -z "$tasks_section" ]; then
        log "No Claude-managed tasks found in TASKS.md"
        echo "[]"
        return 0
    fi
    
    # Parse tasks into JSON format
    local todos_json="["
    local first=true
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^###\ (task-[0-9]+):\ (.+) ]]; then
            if [ "$first" = false ]; then
                todos_json+=","
            fi
            first=false
            
            local task_id="${BASH_REMATCH[1]}"
            local task_content="${BASH_REMATCH[2]}"
            
            # Read next two lines for status and priority
            read -r status_line
            read -r priority_line
            
            local status=$(echo "$status_line" | sed -n 's/.*\*\*Status\*\*: //p')
            local priority=$(echo "$priority_line" | sed -n 's/.*\*\*Priority\*\*: //p')
            
            todos_json+=$(jq -n \
                --arg id "$task_id" \
                --arg content "$task_content" \
                --arg status "${status:-pending}" \
                --arg priority "${priority:-medium}" \
                '{id: $id, content: $content, status: $status, priority: $priority}')
        fi
    done <<< "$tasks_section"
    
    todos_json+="]"
    
    echo "$todos_json"
    log "Loaded $(echo "$todos_json" | jq 'length') tasks from TASKS.md"
}

# Check sync status
check_sync_status() {
    if [ -f "$TASKS_FILE" ]; then
        local last_sync=$(grep -oP 'last_sync=\K[^\s]+' "$TASKS_FILE" 2>/dev/null || echo "never")
        echo "Last sync: $last_sync"
        
        # Count tasks
        local claude_tasks=$(grep -c "^### task-" "$TASKS_FILE" 2>/dev/null || echo 0)
        echo "Claude-managed tasks in TASKS.md: $claude_tasks"
    else
        echo "TASKS.md not found"
    fi
}

# Initialize Claude-Managed Tasks section if it doesn't exist
init_claude_section() {
    if ! grep -q "^## Claude-Managed Tasks" "$TASKS_FILE" 2>/dev/null; then
        log "Initializing Claude-Managed Tasks section"
        {
            echo ""
            echo "## Claude-Managed Tasks"
            echo "<!-- SYNC_STATUS: last_sync=$(date -u +%Y-%m-%dT%H:%M:%SZ) -->"
            echo ""
        } >> "$TASKS_FILE"
    fi
}

# Main command handler
case "${1:-}" in
    save)
        init_claude_section
        save_todos_to_tasks
        ;;
    load)
        load_tasks_to_claude
        ;;
    check)
        check_sync_status
        ;;
    check-load)
        # Called by PreToolUse hook - check if we need to load
        if [ ! -f "/tmp/claude-tasks-loaded-$$" ]; then
            touch "/tmp/claude-tasks-loaded-$$"
            load_tasks_to_claude
        fi
        ;;
    *)
        echo "Usage: $0 {save|load|check|check-load}"
        echo "  save       - Save todos from Claude to TASKS.md (hook)"
        echo "  load       - Load tasks from TASKS.md to Claude"
        echo "  check      - Check sync status"
        echo "  check-load - Check and load if needed (hook)"
        exit 1
        ;;
esac