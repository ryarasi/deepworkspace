#!/bin/bash
# DWS Start Command - Navigate to projects and launch Claude Desktop

# Get workspace root
WORKSPACE_ROOT="$(get_workspace_root)" || exit 1

# Check for --eval flag (for shell function integration)
EVAL_MODE=false
if [[ "${1:-}" == "--eval" ]]; then
    EVAL_MODE=true
fi

# Find all projects (including sub-projects)
info "DeepWorkspace Projects:"
echo

# Build project list with hierarchy
declare -a PROJECT_PATHS
declare -a PROJECT_NAMES
declare -a PROJECT_PURPOSES
PROJECT_COUNT=0

# Function to scan projects recursively
scan_projects() {
    local parent_path="$1"
    local indent="$2"
    
    # Find immediate subdirectories in projects folder
    if [[ -d "$parent_path/projects" ]]; then
        for project_dir in "$parent_path/projects"/*; do
            if [[ -d "$project_dir" ]] && [[ -f "$project_dir/README.md" ]]; then
                PROJECT_COUNT=$((PROJECT_COUNT + 1))
                local project_name=$(basename "$project_dir")
                
                # Extract purpose from README.md
                local purpose=$(grep -A1 "## Purpose" "$project_dir/README.md" 2>/dev/null | tail -n1 | sed 's/^[[:space:]]*//')
                if [[ -z "$purpose" ]]; then
                    purpose="No description available"
                fi
                
                # Store project info
                PROJECT_PATHS[$PROJECT_COUNT]="$project_dir"
                PROJECT_NAMES[$PROJECT_COUNT]="$project_name"
                PROJECT_PURPOSES[$PROJECT_COUNT]="$purpose"
                
                # Display project
                printf "%2d. %s%-20s - %s\n" "$PROJECT_COUNT" "$indent" "$project_name" "$purpose"
                
                # Recursively scan sub-projects
                scan_projects "$project_dir" "$indent  "
            fi
        done
    fi
}

# Start scanning from workspace root
scan_projects "$WORKSPACE_ROOT" ""

if [[ $PROJECT_COUNT -eq 0 ]]; then
    error "No projects found in workspace"
    exit 1
fi

echo
read -p "Select project (1-$PROJECT_COUNT): " SELECTION

# Validate selection
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [[ $SELECTION -lt 1 ]] || [[ $SELECTION -gt $PROJECT_COUNT ]]; then
    error "Invalid selection"
    exit 1
fi

# Get selected project path
SELECTED_PATH="${PROJECT_PATHS[$SELECTION]}"
SELECTED_NAME="${PROJECT_NAMES[$SELECTION]}"

if [[ "$EVAL_MODE" == "true" ]]; then
    # Output command for shell function to eval
    echo "dws-cd '$SELECTED_PATH'"
else
    # Regular mode - just show instructions
    echo
    success "Selected: $SELECTED_NAME"
    echo
    echo "To change to this directory and open Claude Desktop, run:"
    echo
    echo "  cd $SELECTED_PATH && claude --dangerously-skip-permissions"
    echo
    echo "Or use the dws-start shell function for one-step navigation."
    echo "See README.md for setup instructions."
fi