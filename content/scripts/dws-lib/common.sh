#!/bin/bash
# Common functions for DeepWorkspace CLI

# Get workspace root (traverse up until we find CLAUDE.md at root)
get_workspace_root() {
    local current_dir="$(pwd)"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/CLAUDE.md" ]] && [[ -d "$current_dir/content" ]] && [[ -d "$current_dir/projects" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    echo "Error: Not in a DeepWorkspace directory" >&2
    return 1
}

# Validate project name
validate_project_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Error: Project name cannot be empty" >&2
        return 1
    fi
    
    # Check for valid characters (lowercase, numbers, hyphens)
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "Error: Project name must contain only lowercase letters, numbers, and hyphens" >&2
        return 1
    fi
    
    # Check it doesn't start or end with hyphen
    if [[ "$name" =~ ^- ]] || [[ "$name" =~ -$ ]]; then
        echo "Error: Project name cannot start or end with a hyphen" >&2
        return 1
    fi
    
    return 0
}

# Check if project already exists
project_exists() {
    local workspace_root="$1"
    local project_path="$2"
    
    if [[ -d "$workspace_root/$project_path" ]]; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Replace template placeholders
replace_placeholders() {
    local template="$1"
    local project_name="$2"
    local project_slug="$3"
    local project_type="$4"
    local project_subtype="$5"
    local project_url="$6"
    local purpose="$7"
    local parent_project="$8"
    local created_date="$(date +%Y-%m-%dT%H:%M:%S%z)"
    local modified_date="$created_date"
    
    # Replace placeholders
    echo "$template" | sed \
        -e "s/\[Project Name\]/$project_name/g" \
        -e "s/\[project-name\]/$project_name/g" \
        -e "s/\[NAME\]/$project_name/g" \
        -e "s/\[project-slug\]/$project_slug/g" \
        -e "s/\[parent-slug or 'root'\]/${parent_project:-root}/g" \
        -e "s/\[person|group|entity|product|research|learning\]/$project_type/g" \
        -e "s/\[type-specific-subtype\]/$project_subtype/g" \
        -e "s|\[https://example.com/project-link\]|${project_url:-}|g" \
        -e "s/\[YYYY-MM-DDTHH:MM:SS+ZZZZ\]/$created_date/g" \
        -e "s/\[YYYY-MM-DD\]/$created_date/g" \
        -e "s/\[date\]/$created_date/g" \
        -e "s/\[One line description\]/$purpose/g" \
        -e "s/\[One paragraph explaining what this project is and why it exists\]/$purpose/g" \
        -e "s/\[active|paused|archived\]/active/g" \
        -e "s/\[comma-separated-project-slugs or empty\]//g" \
        -e "s/\[Describe what's in content: code, documents, etc.\]/Source code and related files/g" \
        -e "s/\[List sub-projects if any, or state \"No sub-projects\"\]/No sub-projects/g" \
        -e "s/\[2-3 steps to get started with this project\]/1. Review the TASKS.md file in .untracked\/local\/\n2. Update this README with more details\n3. Start developing in the content\/ folder/g" \
        -e "s/\[Project-specific important details\]/This is a code project. All source code should go in the content\/ folder./g" \
        -e "s/\[What's being worked on\]/Initial project setup/g" \
        -e "s/\[Future task 1\]/Set up development environment/g" \
        -e "s/\[Future task 2\]/Create initial project structure/g" \
        -e "s/\[path\]/projects\/$project_slug/g" \
        -e "s/\[Any special instructions for AI agents working on this project\]/Follow standard code project conventions/g" \
        -e "s/\[List key files\/directories in content\/\]/- Source code files will be added here/g" \
        -e "s/\[What should AI agents prioritize when working here\]/Setting up the basic project structure and documentation/g" \
        -e "s/\[Brief description of what's in this content directory\]/This directory contains all the actual work for this project./g" \
        -e "s/\[project-specific structure\]/src\/ - Source code files/g" \
        -e "s/\[List and describe the main components\/directories\]/- src\/ - Source code files\n- docs\/ - Documentation/g" \
        -e "s/\[Any specific notes about working in this directory\]/All development work should happen here./g" \
        -e "s/\[List key gitignore patterns\]/- .untracked\/ - External repositories and local data\n- node_modules\/ - Dependencies\n- dist\/ - Build output/g" \
        -e "s/\[Detailed description of what's in the content\/ directory\]/All project source code and related files/g" \
        -e "s/\[List main directories and files\]/src\/ - Source code\ndocs\/ - Documentation/g" \
        -e "s/\[with descriptions\]/tests\/ - Test files/g" \
        -e "s/\[Any build commands, development setup, or architecture notes\]/# Development setup instructions will be added here/g" \
        -e "s/\[List any external repositories in .untracked\/repos\/\]/No external repositories yet/g" \
        -e "s/\[repo-name\]/example-repo/g" \
        -e "s/\[Purpose\/description\]/Example repository/g" \
        -e "s/\[github.com\/\.\.\.\]/github.com\/example\/repo/g" \
        -e "s/\[YYYY-MM-DD\]/$created_date/g"
}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print success message
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Print error message
error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Print warning message
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Print info message
info() {
    echo -e "${YELLOW}→${NC} $1"
}