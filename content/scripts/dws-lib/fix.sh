#!/bin/bash
# DWS Fix Command - Automatically fix common validation issues

# Get workspace root
WORKSPACE_ROOT="$(get_workspace_root)" || exit 1

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
    
    return $fixed
}

# Function to fix content tracking mismatch
fix_content_tracking() {
    local project_path="$1"
    local readme_path="$project_path/README.md"
    local gitignore_path="$project_path/.gitignore"
    
    # Extract Track Content preference from README
    local track_content=""
    if [[ -f "$readme_path" ]]; then
        track_content=$(grep -E "^\s*-\s*\*\*Track Content\*\*:" "$readme_path" | sed 's/.*: *//' | tr -d ' ')
    fi
    
    # If no preference declared, can't fix automatically
    if [[ -z "$track_content" ]]; then
        return 1
    fi
    
    # Fix based on preference
    if [[ "$track_content" == "no" ]]; then
        # Should have content/ in .gitignore
        if [[ ! -f "$gitignore_path" ]]; then
            # Create .gitignore
            info "Creating .gitignore with content/ entry"
            echo "# Project content (not tracked in git)" > "$gitignore_path"
            echo "content/" >> "$gitignore_path"
            return 0
        elif ! grep -q "^content/$" "$gitignore_path"; then
            # Add content/ to existing .gitignore
            info "Adding content/ to .gitignore"
            echo "" >> "$gitignore_path"
            echo "# Project content (not tracked in git)" >> "$gitignore_path"
            echo "content/" >> "$gitignore_path"
            return 0
        fi
    elif [[ "$track_content" == "yes" ]]; then
        # Should NOT have content/ in .gitignore
        if [[ -f "$gitignore_path" ]] && grep -q "^content/$" "$gitignore_path"; then
            info "Removing content/ from .gitignore"
            # Create temp file without content/ line
            grep -v "^content/$" "$gitignore_path" > "$gitignore_path.tmp"
            # Also remove the comment line before it if present
            grep -v "# Project content (not tracked in git)" "$gitignore_path.tmp" > "$gitignore_path"
            rm "$gitignore_path.tmp"
            # Remove empty .gitignore
            if [[ ! -s "$gitignore_path" ]]; then
                rm "$gitignore_path"
            fi
            return 0
        fi
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
    
    # Fix content tracking
    if fix_content_tracking "$project_path"; then
        ((fixes_done++))
        success "Fixed content tracking configuration"
    fi
    
    # Fix template references
    fix_template_references "$project_path"
    local ref_fixes=$?
    if [[ $ref_fixes -gt 0 ]]; then
        fixes_done=$((fixes_done + ref_fixes))
        success "Fixed $ref_fixes missing template references"
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
    
    # Note about missing rules
    if ! ls "$WORKSPACE_ROOT/content/rules/R009"*.yaml >/dev/null 2>&1; then
        info "R009 is missing - this appears to be intentional"
    fi
}

# Main fix process
echo "DeepWorkspace Fix Tool"
echo "======================"
echo "Generated: $(date +"%Y-%m-%dT%H:%M:%S%z")"
echo
echo "This tool will automatically fix common issues:"
echo "- Missing required directories"
echo "- Content tracking mismatches"
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
    echo "- Missing 'Track Content' declarations (need manual edit)"
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