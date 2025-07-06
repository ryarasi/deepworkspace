#!/bin/bash
# Project Self-Validation - Validates project against its own rules

# Function to validate project-specific rules
validate_project_rules() {
    local root_path="$1"
    local violations=()
    local warnings=()
    local passes=()
    
    echo "Project Self-Validation"
    echo "======================"
    echo
    
    # R001: Project Structure
    echo -n "R001 - Project Structure... "
    local missing_items=()
    [[ ! -f "$root_path/README.md" ]] && missing_items+=("README.md")
    [[ ! -d "$root_path/docs" ]] && missing_items+=("docs/")
    [[ ! -f "$root_path/docs/RULES.md" ]] && missing_items+=("docs/RULES.md")
    [[ ! -f "$root_path/docs/PSD.md" ]] && missing_items+=("docs/PSD.md")
    [[ ! -d "$root_path/docs/rules" ]] && missing_items+=("docs/rules/")
    [[ ! -d "$root_path/docs/rules/templates" ]] && missing_items+=("docs/rules/templates/")
    [[ ! -d "$root_path/docs/rules/scripts" ]] && missing_items+=("docs/rules/scripts/")
    [[ ! -d "$root_path/.untracked" ]] && missing_items+=(".untracked/")
    
    if [[ ${#missing_items[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R001: Project structure complete")
    else
        echo "✗ FAIL"
        violations+=("R001: Missing required items: ${missing_items[*]}")
    fi
    
    # R002: Template System Integrity
    echo -n "R002 - Template System Integrity... "
    local template_issues=()
    local template_ids=()
    
    # Check all templates have valid YAML structure and unique IDs
    if [[ -d "$root_path/docs/rules/templates" ]]; then
        for template in "$root_path"/docs/rules/templates/T*.yaml; do
            if [[ -f "$template" ]]; then
                # Extract template ID
                local tid=$(grep "^id:" "$template" | head -1 | cut -d' ' -f2)
                if [[ -z "$tid" ]]; then
                    template_issues+=("$(basename "$template"): missing ID")
                elif [[ " ${template_ids[@]} " =~ " ${tid} " ]]; then
                    template_issues+=("Duplicate ID: $tid")
                else
                    template_ids+=("$tid")
                fi
                
                # Check required fields
                grep -q "^name:" "$template" || template_issues+=("$(basename "$template"): missing name")
                grep -q "^version:" "$template" || template_issues+=("$(basename "$template"): missing version")
                grep -q "^content:" "$template" || template_issues+=("$(basename "$template"): missing content")
            fi
        done
    fi
    
    if [[ ${#template_issues[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R002: All templates have valid structure")
    else
        echo "✗ FAIL"
        for issue in "${template_issues[@]}"; do
            violations+=("R002: $issue")
        done
    fi
    
    # R003: Self-Demonstration Principle
    echo -n "R003 - Self-Demonstration Principle... "
    local demo_issues=()
    
    # Check if README references docs/RULES.md
    if [[ -f "$root_path/README.md" ]]; then
        grep -q "docs/RULES.md" "$root_path/README.md" || demo_issues+=("README.md doesn't reference docs/RULES.md")
    fi
    
    # Check if PSD follows T010
    if [[ -f "$root_path/docs/PSD.md" ]]; then
        grep -q "@templates/T010" "$root_path/docs/PSD.md" || demo_issues+=("docs/PSD.md doesn't follow T010")
    fi
    
    if [[ ${#demo_issues[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R003: Project demonstrates its own patterns")
    else
        echo "✗ FAIL"
        for issue in "${demo_issues[@]}"; do
            violations+=("R003: $issue")
        done
    fi
    
    # R004: Reference Integrity
    echo -n "R004 - Reference Integrity... "
    local ref_issues=()
    
    # Check template references in rules
    if [[ -d "$root_path/docs/rules" ]]; then
        for rule in "$root_path"/docs/rules/R*.yaml; do
            if [[ -f "$rule" ]]; then
                # Extract references - look for references section and extract rule/template IDs
                local refs=$(awk '/^references:/{flag=1;next}/^[^[:space:]-]/{flag=0}flag && /^[[:space:]]*-[[:space:]]*"[RT][0-9]+"/' "$rule" | grep -oE '"[RT][0-9]+"' | tr -d '"')
                for ref in $refs; do
                    if [[ $ref == T* ]]; then
                        # Check if template exists
                        if ! ls "$root_path"/docs/rules/templates/${ref}-*.yaml >/dev/null 2>&1; then
                            ref_issues+=("$(basename "$rule"): references non-existent template $ref")
                        fi
                    elif [[ $ref == R* ]]; then
                        # Check if rule exists
                        if ! ls "$root_path"/docs/rules/${ref}-*.yaml >/dev/null 2>&1; then
                            ref_issues+=("$(basename "$rule"): references non-existent rule $ref")
                        fi
                    fi
                done
            fi
        done
    fi
    
    if [[ ${#ref_issues[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R004: All references are valid")
    else
        echo "✗ FAIL"
        for issue in "${ref_issues[@]}"; do
            violations+=("R004: $issue")
        done
    fi
    
    # R005: Governance Hierarchy
    echo -n "R005 - Governance Hierarchy... "
    local hierarchy_issues=()
    
    # Check that governance is properly organized
    [[ ! -d "$root_path/docs/rules" ]] && hierarchy_issues+=("docs/rules/ missing")
    [[ ! -d "$root_path/docs/rules/templates" ]] && hierarchy_issues+=("templates not under docs/rules/")
    [[ ! -d "$root_path/docs/rules/scripts" ]] && hierarchy_issues+=("scripts not under docs/rules/")
    [[ -d "$root_path/templates" ]] && hierarchy_issues+=("Found templates/ at root (should be in docs/rules/)")
    [[ -d "$root_path/rules" ]] && hierarchy_issues+=("Found rules/ at root (should be in docs/)")
    [[ -d "$root_path/scripts" ]] && hierarchy_issues+=("Found scripts/ at root (should be in docs/rules/)")
    
    # Check for incorrect nesting
    [[ -d "$root_path/system" ]] && root_issues+=("Found incorrect 'system/' directory")
    [[ -d "$root_path/.system" ]] && root_issues+=("Found incorrect '.system/' directory")
    
    if [[ ${#hierarchy_issues[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R005: Governance hierarchy correct")
    else
        echo "✗ FAIL"
        for issue in "${hierarchy_issues[@]}"; do
            violations+=("R005: $issue")
        done
    fi
    
    # R006: Script Validation Requirements
    echo -n "R006 - Script Validation Requirements... "
    local script_issues=()
    
    # Check if key scripts exist
    if [[ -d "$root_path/docs/rules/scripts" ]]; then
        # Check for validation script
        if [[ ! -f "$root_path/docs/rules/scripts/validate" ]] && [[ ! -f "$root_path/docs/rules/scripts/dws" ]]; then
            script_issues+=("Missing validation script")
        fi
    else
        script_issues+=("docs/rules/scripts/ directory missing")
    fi
    
    if [[ ${#script_issues[@]} -eq 0 ]]; then
        echo "✓ PASS"
        passes+=("R006: Validation scripts present")
    else
        echo "✗ FAIL"
        for issue in "${script_issues[@]}"; do
            violations+=("R006: $issue")
        done
    fi
    
    # Check for project-specific rules (R007+)
    echo
    echo "Extension Rules"
    echo "--------------"
    local extension_count=0
    if [[ -d "$root_path/docs/rules" ]]; then
        for rule in "$root_path"/docs/rules/R{007..999}-*.yaml; do
            if [[ -f "$rule" ]]; then
                ((extension_count++))
                echo "  Found: $(basename "$rule")"
            fi
        done
    fi
    if [[ $extension_count -eq 0 ]]; then
        echo "  No extension rules found (R007+)"
    fi
    
    # Summary
    echo
    echo "Summary"
    echo "-------"
    echo "✓ Passed: ${#passes[@]} rules"
    echo "✗ Failed: ${#violations[@]} violations"
    echo "⚠ Warnings: ${#warnings[@]}"
    
    if [[ ${#violations[@]} -gt 0 ]]; then
        echo
        echo "Violations:"
        for v in "${violations[@]}"; do
            echo "  ✗ $v"
        done
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo
        echo "Warnings:"
        for w in "${warnings[@]}"; do
            echo "  ⚠ $w"
        done
    fi
    
    # Return non-zero if any violations
    [[ ${#violations[@]} -eq 0 ]]
}

# Export function for use in validation scripts
export -f validate_project_rules