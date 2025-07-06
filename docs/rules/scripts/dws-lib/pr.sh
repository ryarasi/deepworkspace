#!/bin/bash
# DWS PR Command - Reliable PR workflow management
# Rule enforcement: R006, R007, R009

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Display help
show_help() {
    cat << EOF
Usage: dws pr <subcommand> [options]

Complete pull request workflow management to ensure 100% reliability.

Subcommands:
  create      Create a new PR from current branch
  merge       Auto-merge current PR and complete workflow
  status      Check PR status and workflow state
  complete    Full workflow: create PR, merge, cleanup

Options:
  -b, --base <branch>    Base branch for PR (default: main)
  -t, --title <title>    PR title (for create/complete)
  -d, --desc <desc>      PR description (for create/complete)
  -h, --help            Show this help message

Examples:
  dws pr create -t "feat: Add new feature"
  dws pr merge
  dws pr status
  dws pr complete -t "fix: Resolve bug" -d "Fixes issue #123"

Note: This command ensures the full PR workflow is completed even if
      context limitations occur. It tracks state and can resume operations.
EOF
}

# Check if gh CLI is installed
check_gh() {
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed. Please install it first."
        info "Visit: https://cli.github.com/manual/installation"
        exit 1
    fi
    
    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        error "GitHub CLI is not authenticated. Run: gh auth login"
        exit 1
    fi
}

# Get current branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Get PR number for current branch
get_pr_number() {
    local branch="$1"
    gh pr list --head "$branch" --json number --jq '.[0].number // empty'
}

# Create PR state file
STATE_FILE=".git/dws-pr-state"

# Save workflow state
save_state() {
    local pr_number="$1"
    local status="$2"
    echo "pr_number=$pr_number" > "$STATE_FILE"
    echo "status=$status" >> "$STATE_FILE"
    echo "branch=$(get_current_branch)" >> "$STATE_FILE"
    echo "timestamp=$(date +%Y-%m-%dT%H:%M:%S%z)" >> "$STATE_FILE"
}

# Load workflow state
load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        source "$STATE_FILE"
        echo "pr_number=${pr_number:-}"
        echo "status=${status:-}"
        echo "branch=${branch:-}"
    fi
}

# Clear workflow state
clear_state() {
    rm -f "$STATE_FILE"
}

# Create PR
create_pr() {
    local base_branch="${1:-main}"
    local title="$2"
    local description="${3:-}"
    
    local current_branch=$(get_current_branch)
    
    # Check if on main/master
    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        error "Cannot create PR from main branch. Create a feature branch first."
        exit 1
    fi
    
    # Check if PR already exists
    local existing_pr=$(get_pr_number "$current_branch")
    if [[ -n "$existing_pr" ]]; then
        success "PR already exists: #$existing_pr"
        save_state "$existing_pr" "created"
        echo "View at: https://github.com/ryarasi/deepworkspace/pull/$existing_pr"
        return 0
    fi
    
    # Ensure changes are pushed
    info "Pushing changes to remote..."
    git push -u origin "$current_branch"
    
    # Create PR
    info "Creating pull request..."
    local pr_cmd="gh pr create --base '$base_branch' --title '$title'"
    
    if [[ -n "$description" ]]; then
        # Use heredoc for description to handle multiline
        gh pr create --base "$base_branch" --title "$title" --body "$(cat <<EOF
$description

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
    else
        # Generate description from commits
        gh pr create --base "$base_branch" --title "$title" --fill
    fi
    
    # Get the PR number after creation
    local pr_number=$(get_pr_number "$current_branch")
    
    if [[ -n "$pr_number" ]]; then
        success "Created PR #$pr_number"
        save_state "$pr_number" "created"
        echo "View at: https://github.com/ryarasi/deepworkspace/pull/$pr_number"
    else
        error "Failed to create PR"
        exit 1
    fi
}

# Merge PR
merge_pr() {
    local current_branch=$(get_current_branch)
    
    # Get PR number
    local pr_number=$(get_pr_number "$current_branch")
    
    if [[ -z "$pr_number" ]]; then
        # Check saved state
        eval "$(load_state)"
        if [[ -z "$pr_number" ]]; then
            error "No PR found for current branch: $current_branch"
            exit 1
        fi
    fi
    
    # Check PR status
    local pr_state=$(gh pr view "$pr_number" | grep -E '^state:' | awk '{print $2}')
    
    if [[ "$pr_state" == "MERGED" ]]; then
        info "PR #$pr_number is already merged"
        save_state "$pr_number" "merged"
    elif [[ "$pr_state" == "CLOSED" ]]; then
        error "PR #$pr_number is closed"
        exit 1
    else
        # Merge PR
        info "Merging PR #$pr_number..."
        gh pr merge "$pr_number" --merge --delete-branch
        save_state "$pr_number" "merged"
        success "PR #$pr_number merged successfully"
    fi
    
    # Complete local cleanup
    info "Switching to main branch..."
    git checkout main || git checkout master
    
    info "Pulling latest changes..."
    git pull
    
    # Delete local feature branch if it exists
    if git show-ref --verify --quiet "refs/heads/$current_branch"; then
        info "Deleting local branch: $current_branch"
        git branch -d "$current_branch" 2>/dev/null || git branch -D "$current_branch"
    fi
    
    clear_state
    success "PR workflow completed successfully!"
}

# Check PR status
check_status() {
    local current_branch=$(get_current_branch)
    
    echo "Current branch: $current_branch"
    
    # Check for saved state
    if [[ -f "$STATE_FILE" ]]; then
        echo ""
        echo "Saved workflow state:"
        cat "$STATE_FILE"
    fi
    
    # Check for PR
    local pr_number=$(get_pr_number "$current_branch")
    
    if [[ -n "$pr_number" ]]; then
        echo ""
        echo "Pull Request #$pr_number:"
        gh pr view "$pr_number"
    else
        echo ""
        echo "No PR found for current branch"
    fi
    
    # Check git status
    echo ""
    echo "Git status:"
    git status --short
}

# Complete workflow
complete_workflow() {
    local base_branch="${1:-main}"
    local title="$2"
    local description="${3:-}"
    
    if [[ -z "$title" ]]; then
        error "Title is required for complete workflow"
        exit 1
    fi
    
    info "Starting complete PR workflow..."
    
    # Create PR
    create_pr "$base_branch" "$title" "$description"
    
    # Wait a moment for GitHub to process
    sleep 2
    
    # Merge PR
    merge_pr
}

# Main command processing
case "${1:-}" in
    create)
        shift
        check_gh
        
        title=""
        description=""
        base_branch="main"
        
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -t|--title)
                    title="$2"
                    shift 2
                    ;;
                -d|--desc)
                    description="$2"
                    shift 2
                    ;;
                -b|--base)
                    base_branch="$2"
                    shift 2
                    ;;
                *)
                    error "Unknown option: $1"
                    show_help
                    exit 1
                    ;;
            esac
        done
        
        if [[ -z "$title" ]]; then
            error "Title is required"
            show_help
            exit 1
        fi
        
        create_pr "$base_branch" "$title" "$description"
        ;;
        
    merge)
        check_gh
        merge_pr
        ;;
        
    status)
        check_gh
        check_status
        ;;
        
    complete)
        shift
        check_gh
        
        title=""
        description=""
        base_branch="main"
        
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -t|--title)
                    title="$2"
                    shift 2
                    ;;
                -d|--desc)
                    description="$2"
                    shift 2
                    ;;
                -b|--base)
                    base_branch="$2"
                    shift 2
                    ;;
                *)
                    error "Unknown option: $1"
                    show_help
                    exit 1
                    ;;
            esac
        done
        
        complete_workflow "$base_branch" "$title" "$description"
        ;;
        
    -h|--help|help)
        show_help
        ;;
        
    "")
        error "No subcommand specified"
        show_help
        exit 1
        ;;
        
    *)
        error "Unknown subcommand: $1"
        show_help
        exit 1
        ;;
esac