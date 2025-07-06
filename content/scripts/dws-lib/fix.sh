#!/bin/bash
# DWS Fix Command - Automatically fix common validation issues

# Get workspace root
WORKSPACE_ROOT="$(get_workspace_root)" || exit 1

# Check and warn if on main branch (stricter for fix command)
if git rev-parse --git-dir > /dev/null 2>&1; then
    current_branch=$(git branch --show-current 2>/dev/null)
    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        echo -e "\033[1;31m❌ ERROR: Cannot run 'dws fix' on main branch!\033[0m" >&2
        echo -e "\033[1;33mThis command modifies files and must be run on a feature branch.\033[0m" >&2
        echo -e "\033[1;32mCreate a feature branch first: git checkout -b feature/fix-validation\033[0m" >&2
        exit 1
    fi
fi

# Initialize counters
TOTAL_FIXES=0
FIXES_APPLIED=0
FIXES_FAILED=0

# Function to fix missing directories
fix_missing_directories() {
    local project_path="$1"
    local fixed=0
    
    # Check and create required directories
    for dir in ".claude" "content" "projects"; do
        if [[ ! -d "$project_path/$dir" ]]; then
            info "Creating missing directory: $dir"
            mkdir -p "$project_path/$dir"
            ((fixed++))
        fi
    done
    
    # Check and create content/docs directory
    if [[ ! -d "$project_path/content/docs" ]]; then
        info "Creating missing directory: content/docs"
        mkdir -p "$project_path/content/docs"
        ((fixed++))
    fi
    
    # Create .untracked structure separately to count as one fix
    if [[ ! -d "$project_path/.untracked" ]]; then
        info "Creating .untracked directory structure"
        mkdir -p "$project_path/.untracked/repos"
        mkdir -p "$project_path/.untracked/local"
        ((fixed++))
    else
        # Check subdirectories
        if [[ ! -d "$project_path/.untracked/repos" ]]; then
            mkdir -p "$project_path/.untracked/repos"
            ((fixed++))
        fi
        if [[ ! -d "$project_path/.untracked/local" ]]; then
            mkdir -p "$project_path/.untracked/local"
            ((fixed++))
        fi
    fi
    
    return $fixed
}

# Function to fix .untracked gitignore entry
fix_untracked_gitignore() {
    local project_path="$1"
    local gitignore_path="$project_path/.gitignore"
    
    # Check if .gitignore exists
    if [[ ! -f "$gitignore_path" ]]; then
        # Create .gitignore with .untracked entry
        info "Creating .gitignore with .untracked/ entry"
        echo "# Untracked items" > "$gitignore_path"
        echo ".untracked/" >> "$gitignore_path"
        return 0
    elif ! grep -q "^\.untracked/" "$gitignore_path"; then
        # Add .untracked/ to existing .gitignore
        info "Adding .untracked/ to .gitignore"
        echo "" >> "$gitignore_path"
        echo "# Untracked items" >> "$gitignore_path"
        echo ".untracked/" >> "$gitignore_path"
        return 0
    fi
    
    return 1
}

# Function to fix missing template references
fix_template_references() {
    local project_path="$1"
    local fixed=0
    
    # Fix README.md
    if [[ -f "$project_path/README.md" ]]; then
        if ! grep -q "<!-- This file follows template @content/templates/T" "$project_path/README.md"; then
            info "Adding template reference to README.md"
            # Add after first line (usually the title)
            sed -i '' '1 a\
\
<!-- This file follows template @content/templates/T002 -->' "$project_path/README.md"
            ((fixed++))
        fi
    fi
    
    # Fix CLAUDE.md
    if [[ -f "$project_path/CLAUDE.md" ]]; then
        if ! grep -q "<!-- This file follows template @content/templates/T" "$project_path/CLAUDE.md"; then
            info "Adding template reference to CLAUDE.md"
            # Add after first line (usually the title)
            sed -i '' '1 a\
\
<!-- This file follows template @content/templates/T003 -->' "$project_path/CLAUDE.md"
            ((fixed++))
        fi
    fi
    
    return $fixed
}

# Function to fix missing overview.md
fix_missing_overview() {
    local project_path="$1"
    
    # Check if overview.md exists
    if [[ ! -f "$project_path/content/docs/overview.md" ]]; then
        info "Creating missing overview.md from template T009"
        
        # Load T009 template
        local OVERVIEW_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T009-project-overview.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
        
        # Get project name from README.md if exists
        local project_name="Project"
        if [[ -f "$project_path/README.md" ]]; then
            # Try to extract project name from README
            local extracted_name=$(grep "^# " "$project_path/README.md" | head -1 | sed 's/^# //')
            if [[ -n "$extracted_name" ]] && [[ "$extracted_name" != "README" ]]; then
                project_name="$extracted_name"
            fi
        fi
        
        # Create overview.md with placeholders replaced
        echo "$OVERVIEW_TEMPLATE" | sed \
            -e "s/\[Project Name\]/$project_name/g" \
            -e "s/\[YYYY-MM-DD\]/$(date +%Y-%m-%d)/g" \
            -e "s/\[One paragraph explaining what this project is, its purpose, and key goals\]/This project needs a proper description. Please update this section./g" \
            -e "s/\[List the main features or components of this project\]/- Feature 1\n- Feature 2\n- Feature 3/g" \
            -e "s/\[active|paused|archived\]/active/g" \
            -e "s/\[planning|development|testing|production\]/development/g" \
            -e "s/\[high|medium|low\]/medium/g" \
            -e "s/\[Brief description of current state and immediate next steps\]/Project is being set up. Next steps include updating this documentation./g" \
            -e "s/\[First step to understand or use this project\]/Review the project structure/g" \
            -e "s/\[Second step\]/Read the CLAUDE.md for AI context/g" \
            -e "s/\[Third step\]/Check TASKS.md for current work items/g" \
            -e "s/\[describe main directories\/files\]/[Project-specific structure]/g" \
            -e "s/\[Link to external resources\]/None yet/g" \
            -e "s/\[Link to dependencies or related projects\]/None yet/g" \
            > "$project_path/content/docs/overview.md"
        
        return 0
    fi
    
    return 1
}

# Function to fix a single project
fix_project() {
    local project_path="$1"
    local project_name="$2"
    local fixes_needed=0
    local fixes_done=0
    
    echo
    echo "Checking: $project_name"
    echo "Path: $project_path"
    
    # Fix missing directories
    fix_missing_directories "$project_path"
    local dir_fixes=$?
    if [[ $dir_fixes -gt 0 ]]; then
        fixes_done=$((fixes_done + dir_fixes))
        success "Fixed $dir_fixes missing directories"
    fi
    
    # Fix .untracked gitignore entry
    if fix_untracked_gitignore "$project_path"; then
        ((fixes_done++))
        success "Fixed .untracked gitignore configuration"
    fi
    
    # Fix template references
    fix_template_references "$project_path"
    local ref_fixes=$?
    if [[ $ref_fixes -gt 0 ]]; then
        fixes_done=$((fixes_done + ref_fixes))
        success "Fixed $ref_fixes missing template references"
    fi
    
    # Fix missing overview.md
    if fix_missing_overview "$project_path"; then
        ((fixes_done++))
        success "Created missing overview.md"
    fi
    
    if [[ $fixes_done -eq 0 ]]; then
        info "No automatic fixes needed"
    else
        FIXES_APPLIED=$((FIXES_APPLIED + fixes_done))
    fi
}

# Function to scan and fix all projects recursively
scan_and_fix_projects() {
    local parent_path="$1"
    local project_name="$2"
    
    # Fix this project
    TOTAL_FIXES=$((TOTAL_FIXES + 1))
    fix_project "$parent_path" "$project_name"
    
    # Scan sub-projects
    if [[ -d "$parent_path/projects" ]]; then
        for project_dir in "$parent_path/projects"/*; do
            if [[ -d "$project_dir" ]] && [[ -f "$project_dir/README.md" ]]; then
                local sub_name=$(basename "$project_dir")
                scan_and_fix_projects "$project_dir" "$sub_name"
            fi
        done
    fi
}

# Function to fix structural issues
fix_structural_issues() {
    echo
    echo "STRUCTURAL FIXES"
    echo "================"
    
    # Check and fix pre-commit hook
    if [[ ! -f "$WORKSPACE_ROOT/.git/hooks/pre-commit" ]]; then
        error "Pre-commit hook missing - cannot fix automatically"
        echo "  Please run: git init (if needed) to create .git/hooks directory"
        ((FIXES_FAILED++))
    elif [[ ! -x "$WORKSPACE_ROOT/.git/hooks/pre-commit" ]]; then
        info "Making pre-commit hook executable"
        chmod +x "$WORKSPACE_ROOT/.git/hooks/pre-commit"
        success "Fixed pre-commit hook permissions"
        ((FIXES_APPLIED++))
    fi
    
}

# Main fix process
echo "DeepWorkspace Fix Tool"
echo "======================"
echo "Generated: $(date +"%Y-%m-%dT%H:%M:%S%z")"
echo
echo "This tool will automatically fix common issues:"
echo "- Missing required directories (.untracked, content, etc.)"
echo "- Missing .untracked/ in .gitignore"
echo "- Missing template references"
echo "- File permission issues"
echo

read -p "Proceed with automatic fixes? (y/n) " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Fix cancelled by user"
    exit 0
fi

# Fix structural issues first
fix_structural_issues

# Fix all projects
echo
echo "PROJECT FIXES"
echo "============="
info "Scanning and fixing all projects..."
scan_and_fix_projects "$WORKSPACE_ROOT" "workspace (root)"

# Generate summary report
echo
echo "SUMMARY"
echo "======="
echo "Projects processed: $TOTAL_FIXES"
echo "Fixes applied: $FIXES_APPLIED"
echo "Fixes failed: $FIXES_FAILED"
echo

# Note about manual fixes
if [[ $FIXES_FAILED -gt 0 ]]; then
    echo "MANUAL FIXES REQUIRED"
    echo "===================="
    echo "Some issues could not be fixed automatically:"
    echo "- Files in wrong locations (need manual move)"
    echo "- Missing metadata attributes (need manual edit)"
    echo "- Complex structural issues"
    echo
fi

# Recommend validation
echo "NEXT STEPS"
echo "=========="
echo "1. Run 'dws validate' to check if all issues are resolved"
echo "2. Review any remaining issues that need manual fixes"
echo "3. Commit the fixes using the standard git workflow"
echo

# Exit with appropriate code
if [[ $FIXES_FAILED -gt 0 ]]; then
    exit 1
else
    exit 0
fi