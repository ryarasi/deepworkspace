#!/bin/bash
# DWS Validate Command - Check workspace and projects for rule compliance

# Get workspace root
WORKSPACE_ROOT="$(get_workspace_root)" || exit 1

# Initialize counters
TOTAL_PROJECTS=0
COMPLIANT_PROJECTS=0
TOTAL_VIOLATIONS=0
TOTAL_WARNINGS=0

# Arrays to store results
declare -a PROJECT_RESULTS
declare -a STRUCTURE_ISSUES

# Function to check if content tracking matches declaration
check_content_tracking() {
    local project_path="$1"
    local readme_path="$project_path/README.md"
    local gitignore_path="$project_path/.gitignore"
    
    # Extract Track Content preference from README
    local track_content=""
    if [[ -f "$readme_path" ]]; then
        track_content=$(grep -E "^\s*-\s*\*\*Track Content\*\*:" "$readme_path" | sed 's/.*: *//' | tr -d ' ')
    fi
    
    # Check if preference is declared
    if [[ -z "$track_content" ]]; then
        return 1  # Missing declaration
    fi
    
    # Check if .gitignore matches preference
    if [[ "$track_content" == "no" ]]; then
        # Should have content/ in .gitignore
        if [[ -f "$gitignore_path" ]]; then
            if grep -q "^content/$" "$gitignore_path"; then
                return 0  # Correct
            else
                return 2  # Mismatch - should ignore but doesn't
            fi
        else
            return 2  # No .gitignore but should have one
        fi
    elif [[ "$track_content" == "yes" ]]; then
        # Should NOT have content/ in .gitignore
        if [[ -f "$gitignore_path" ]]; then
            if grep -q "^content/$" "$gitignore_path"; then
                return 3  # Mismatch - ignores but shouldn't
            else
                return 0  # Correct
            fi
        else
            return 0  # No .gitignore is fine when tracking content
        fi
    else
        return 4  # Invalid value
    fi
}

# Function to validate a single project
validate_project() {
    local project_path="$1"
    local project_name="$2"
    local violations=()
    local warnings=()
    
    # R001: Check required files and directories
    local missing_items=()
    [[ ! -f "$project_path/README.md" ]] && missing_items+=("README.md")
    [[ ! -f "$project_path/CLAUDE.md" ]] && missing_items+=("CLAUDE.md")
    [[ ! -d "$project_path/.claude" ]] && missing_items+=(".claude/")
    [[ ! -d "$project_path/content" ]] && missing_items+=("content/")
    [[ ! -d "$project_path/projects" ]] && missing_items+=("projects/")
    
    if [[ ${#missing_items[@]} -gt 0 ]]; then
        violations+=("R001: Missing required items: ${missing_items[*]}")
    fi
    
    # R001/R002: Check content tracking
    check_content_tracking "$project_path"
    local tracking_status=$?
    case $tracking_status in
        1) violations+=("R002: Missing 'Track Content' declaration in README.md") ;;
        2) violations+=("R002: Content tracking mismatch - declared 'no' but content/ not in .gitignore") ;;
        3) violations+=("R002: Content tracking mismatch - declared 'yes' but content/ is in .gitignore") ;;
        4) violations+=("R002: Invalid 'Track Content' value (must be yes/no)") ;;
    esac
    
    # R003: Check template references
    if [[ -f "$project_path/README.md" ]]; then
        if ! grep -q "<!-- This file follows template @content/templates/T" "$project_path/README.md"; then
            warnings+=("R003: README.md missing template reference")
        fi
    fi
    if [[ -f "$project_path/CLAUDE.md" ]]; then
        if ! grep -q "<!-- This file follows template @content/templates/T" "$project_path/CLAUDE.md"; then
            warnings+=("R003: CLAUDE.md missing template reference")
        fi
    fi
    
    # R001: Check for extra files at root
    local allowed_files=("README.md" "CLAUDE.md" ".git" ".gitignore" ".claude" "content" "projects")
    local extra_files=()
    for item in "$project_path"/{*,.*}; do
        local basename=$(basename "$item")
        # Skip . and ..
        [[ "$basename" == "." || "$basename" == ".." ]] && continue
        # Check if it's in allowed list
        local allowed=false
        for allowed_item in "${allowed_files[@]}"; do
            [[ "$basename" == "$allowed_item" ]] && allowed=true && break
        done
        [[ "$allowed" == false ]] && extra_files+=("$basename")
    done
    
    if [[ ${#extra_files[@]} -gt 0 ]]; then
        violations+=("R001: Extra files/folders at root: ${extra_files[*]}")
    fi
    
    # Update global counters
    TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + ${#violations[@]}))
    TOTAL_WARNINGS=$((TOTAL_WARNINGS + ${#warnings[@]}))
    
    # Display results
    echo
    echo "Project: $project_name"
    echo "Path: $project_path"
    if [[ ${#violations[@]} -eq 0 && ${#warnings[@]} -eq 0 ]]; then
        echo "Status: ✓ Fully compliant"
        return 0
    else
        echo "Status: ${#violations[@]} violations, ${#warnings[@]} warnings"
        for v in "${violations[@]}"; do
            echo "  ✗ $v"
        done
        for w in "${warnings[@]}"; do
            echo "  ⚠ $w"
        done
        return 1
    fi
}

# Function to check basic structural logic
check_structural_logic() {
    info "Checking structural consistency..."
    echo
    
    local issues=()
    
    # Check for missing references
    for rule_file in "$WORKSPACE_ROOT/content/rules"/*.yaml; do
        [[ ! -f "$rule_file" ]] && continue
        
        # Extract references section
        local in_refs=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^references: ]]; then
                in_refs=true
                continue
            fi
            if [[ "$in_refs" == true ]] && [[ "$line" =~ ^[a-z]+: ]]; then
                break
            fi
            if [[ "$in_refs" == true ]] && [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\"([RT][0-9]+)\" ]]; then
                local ref="${BASH_REMATCH[1]}"
                if [[ "$ref" =~ ^R ]]; then
                    if ! ls "$WORKSPACE_ROOT/content/rules/${ref}"*.yaml >/dev/null 2>&1; then
                        issues+=("$(basename "$rule_file") references missing rule: $ref")
                    fi
                elif [[ "$ref" =~ ^T ]]; then
                    if ! ls "$WORKSPACE_ROOT/content/templates/${ref}"*.yaml >/dev/null 2>&1; then
                        issues+=("$(basename "$rule_file") references missing template: $ref")
                    fi
                fi
            fi
        done < "$rule_file"
    done
    
    # Check for rule numbering gaps
    for i in {001..010}; do
        if ! ls "$WORKSPACE_ROOT/content/rules/R${i}"*.yaml >/dev/null 2>&1; then
            if [[ "$i" != "009" ]]; then  # R009 is known to be missing
                issues+=("Rule numbering gap: R${i} is missing (expected in sequence)")
            fi
        fi
    done
    
    # Check if pre-commit hook exists and is executable
    if [[ ! -f "$WORKSPACE_ROOT/.git/hooks/pre-commit" ]]; then
        issues+=("Pre-commit hook missing (required by R006)")
    elif [[ ! -x "$WORKSPACE_ROOT/.git/hooks/pre-commit" ]]; then
        issues+=("Pre-commit hook not executable (required by R006)")
    fi
    
    # Display results
    if [[ ${#issues[@]} -eq 0 ]]; then
        success "No structural issues found"
    else
        warning "Structural issues found:"
        for issue in "${issues[@]}"; do
            echo "  ⚠ $issue"
        done
        STRUCTURE_ISSUES+=("${issues[@]}")
    fi
}

# Function to scan all projects recursively
scan_projects() {
    local parent_path="$1"
    local indent="$2"
    local project_name="$3"
    
    # Validate this project
    TOTAL_PROJECTS=$((TOTAL_PROJECTS + 1))
    
    if validate_project "$parent_path" "$project_name"; then
        COMPLIANT_PROJECTS=$((COMPLIANT_PROJECTS + 1))
    fi
    
    # Scan sub-projects
    if [[ -d "$parent_path/projects" ]]; then
        for project_dir in "$parent_path/projects"/*; do
            if [[ -d "$project_dir" ]] && [[ -f "$project_dir/README.md" ]]; then
                local sub_name=$(basename "$project_dir")
                scan_projects "$project_dir" "$indent  " "$sub_name"
            fi
        done
    fi
}

# Main validation process
echo "DeepWorkspace Validation Report"
echo "==============================="
echo "Generated: $(date +"%Y-%m-%dT%H:%M:%S%z")"
echo

# Check structural consistency first
echo "STRUCTURAL CHECKS"
echo "-----------------"
check_structural_logic
echo

# Validate all projects
echo "PROJECT COMPLIANCE"
echo "------------------"
info "Scanning all projects..."
scan_projects "$WORKSPACE_ROOT" "" "workspace (root)"

# Generate summary report
echo
echo "SUMMARY"
echo "======="
echo "Total projects scanned: $TOTAL_PROJECTS"
echo "Fully compliant: $COMPLIANT_PROJECTS"
echo "Projects with issues: $((TOTAL_PROJECTS - COMPLIANT_PROJECTS))"
echo "Total violations: $TOTAL_VIOLATIONS"
echo "Total warnings: $TOTAL_WARNINGS"
echo "Structural issues: ${#STRUCTURE_ISSUES[@]}"
echo

# Note about limitations
echo "NOTE ON VALIDATION SCOPE"
echo "========================"
echo "This tool performs basic structural and configuration checks only."
echo "It CANNOT detect semantic contradictions between rules or complex"
echo "logical conflicts. For comprehensive rule analysis, manual review"
echo "or AI-assisted analysis is recommended."
echo

# Provide recommendations
if [[ $TOTAL_VIOLATIONS -gt 0 ]] || [[ ${#STRUCTURE_ISSUES[@]} -gt 0 ]]; then
    echo "RECOMMENDATIONS"
    echo "==============="
    echo "1. Run 'dws fix' to automatically fix common violations"
    echo "2. Review structural issues and fix manually if needed"
    echo "3. Ensure all projects have proper 'Track Content' declarations"
    echo "4. Check that all required directories exist"
    
    if [[ ${#STRUCTURE_ISSUES[@]} -gt 0 ]]; then
        echo "5. Address structural issues (missing references, hooks, etc.)"
    fi
    
    echo
    read -p "Would you like to run 'dws fix' now? (y/n) " RUN_FIX
    if [[ "$RUN_FIX" == "y" ]]; then
        echo
        info "Running dws fix..."
        source "$DWS_LIB/fix.sh"
    fi
else
    success "All projects are fully compliant! 🎉"
fi

# Exit with appropriate code
if [[ $TOTAL_VIOLATIONS -gt 0 ]] || [[ ${#STRUCTURE_ISSUES[@]} -gt 0 ]]; then
    exit 1
else
    exit 0
fi