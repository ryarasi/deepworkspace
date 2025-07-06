#!/bin/bash
# DWS Validate Command - Check workspace and projects for rule compliance

# Get project root
PROJECT_ROOT="$(get_project_root)" || exit 1

# Initialize counters
TOTAL_PROJECTS=0
COMPLIANT_PROJECTS=0
TOTAL_VIOLATIONS=0
TOTAL_WARNINGS=0

# Arrays to store results
declare -a PROJECT_RESULTS
declare -a STRUCTURE_ISSUES

# Function to check .untracked directory structure
check_untracked_structure() {
    local project_path="$1"
    
    # Check if .untracked exists with proper structure
    if [[ ! -d "$project_path/.untracked" ]]; then
        return 1  # Missing .untracked
    fi
    
    if [[ ! -d "$project_path/.untracked/repos" ]]; then
        return 2  # Missing repos subdirectory
    fi
    
    if [[ ! -d "$project_path/.untracked/local" ]]; then
        return 3  # Missing local subdirectory
    fi
    
    # Check if .gitignore includes .untracked
    if [[ -f "$project_path/.gitignore" ]]; then
        if ! grep -q "^\.untracked/" "$project_path/.gitignore"; then
            return 4  # .untracked not in .gitignore
        fi
    else
        return 5  # No .gitignore file
    fi
    
    return 0  # All good
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
    [[ ! -d "$project_path/.untracked" ]] && missing_items+=(".untracked/")
    [[ ! -d "$project_path/docs" ]] && missing_items+=("docs/")
    [[ ! -f "$project_path/docs/PSD.md" ]] && missing_items+=("docs/PSD.md")
    
    if [[ ${#missing_items[@]} -gt 0 ]]; then
        violations+=("R001: Missing required items: ${missing_items[*]}")
    fi
    
    # R001/R002: Check .untracked structure
    check_untracked_structure "$project_path"
    local untracked_status=$?
    case $untracked_status in
        1) violations+=("R001: Missing .untracked/ directory") ;;
        2) violations+=("R001: Missing .untracked/repos/ subdirectory") ;;
        3) violations+=("R001: Missing .untracked/local/ subdirectory") ;;
        4) violations+=("R002: .untracked/ not in .gitignore") ;;
        5) violations+=("R002: Missing .gitignore file") ;;
    esac
    
    # R003: Check template references
    if [[ -f "$project_path/README.md" ]]; then
        if ! grep -q "<!-- This file follows template @templates/T" "$project_path/README.md"; then
            warnings+=("R003: README.md missing template reference")
        fi
    fi
    
    # With new structure, project files can live at root - no need to check for "extra" files
    
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
    for rule_file in "$PROJECT_ROOT/docs/rules"/*.yaml; do
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
                    if ! ls "$PROJECT_ROOT/docs/rules/${ref}"*.yaml >/dev/null 2>&1; then
                        issues+=("$(basename "$rule_file") references missing rule: $ref")
                    fi
                elif [[ "$ref" =~ ^T ]]; then
                    if ! ls "$PROJECT_ROOT/docs/rules/templates/${ref}"*.yaml >/dev/null 2>&1; then
                        issues+=("$(basename "$rule_file") references missing template: $ref")
                    fi
                fi
            fi
        done < "$rule_file"
    done
    
    # Check for rule numbering gaps
    for i in {001..010}; do
        if ! ls "$PROJECT_ROOT/docs/rules/R${i}"*.yaml >/dev/null 2>&1; then
            issues+=("Rule numbering gap: R${i} is missing (expected in sequence)")
        fi
    done
    
    # Check if pre-commit hook exists and is executable
    if [[ ! -f "$PROJECT_ROOT/.git/hooks/pre-commit" ]]; then
        issues+=("Pre-commit hook missing (required by R006)")
    elif [[ ! -x "$PROJECT_ROOT/.git/hooks/pre-commit" ]]; then
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
echo "Project Validation Report"
echo "==============================="
echo "Generated: $(date +"%Y-%m-%dT%H:%M:%S%z")"
echo

# Check if we're validating a project with its own rules
if [[ -d "./docs/rules" ]]; then
    # Source project-specific validation
    source "$(dirname "${BASH_SOURCE[0]}")/validate-project.sh"
    
    echo "PROJECT SELF-VALIDATION"
    echo "----------------------"
    validate_project_rules "$(pwd)"
    echo
fi

# Check structural consistency first
echo "STRUCTURAL CHECKS"
echo "-----------------"
check_structural_logic
echo

# Validate all projects
echo "PROJECT COMPLIANCE"
echo "------------------"
info "Scanning all projects..."
scan_projects "$PROJECT_ROOT" "" "project (root)"

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
    echo "3. Ensure all projects have .untracked/ directory with proper structure"
    echo "4. Check that all required directories exist"
    echo "5. Verify .gitignore includes .untracked/"
    
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