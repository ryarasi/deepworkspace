# Pattern: Branch Lifecycle Management

## When to Use

This pattern is recommended when:
- Multiple developers work on different features simultaneously
- You need to track the status of ongoing work
- Long-running feature branches need to be managed
- You want to prevent orphaned or forgotten branches
- Context needs to be preserved across development sessions

## Pattern Overview

The Branch Lifecycle Management pattern establishes a systematic approach to creating, tracking, and completing git branches. It ensures that all branches have clear purposes, are properly documented, and are eventually merged or explicitly abandoned.

## Core Principles

### 1. One Active Branch at a Time
Focus on completing one feature branch before starting another. This prevents context switching and ensures work is finished.

### 2. Document Branch Purpose
Every branch should have a clear, documented purpose that explains what it aims to accomplish.

### 3. Track Branch State
Maintain awareness of all active branches and their current status to prevent work from being lost or forgotten.

### 4. Complete the Lifecycle
Every branch should reach a definitive end state: merged, abandoned, or archived.

## Implementation Guide

### Branch Naming Conventions

Use descriptive, consistent naming:
```
feature/add-user-authentication
fix/memory-leak-in-parser
docs/update-api-reference
refactor/simplify-data-flow
chore/update-dependencies
```

### Branch Registry

Consider maintaining a branch registry to track active work:

```yaml
# .untracked/local/BRANCH_REGISTRY.yaml
branches:
  - name: feature/payment-integration
    created: 2024-01-15T10:00:00Z
    author: alice@example.com
    purpose: Integrate Stripe payment processing
    status: active
    context: |
      - Adding subscription management
      - Implementing webhook handlers
      - Creating payment history views
    pr_url: null
    
  - name: fix/email-validation
    created: 2024-01-18T14:30:00Z
    author: bob@example.com
    purpose: Fix email validation regex
    status: in-review
    context: |
      - Previous regex rejected valid emails with + signs
      - Updated to RFC 5322 compliant pattern
    pr_url: https://github.com/org/repo/pull/123
```

### Lifecycle Stages

1. **Creation**
   ```bash
   # Always branch from main
   git checkout main
   git pull origin main
   git checkout -b feature/descriptive-name
   
   # Document in registry or project notes
   echo "Created feature/descriptive-name for [purpose]" >> .untracked/BRANCHES.md
   ```

2. **Development**
   - Make focused commits
   - Keep branch up to date with main
   - Document significant decisions

3. **Review**
   - Create pull request
   - Address feedback
   - Update documentation

4. **Completion**
   ```bash
   # After PR is merged
   git checkout main
   git pull origin main
   git branch -d feature/descriptive-name
   git push origin --delete feature/descriptive-name
   ```

### Branch Age Management

Set guidelines for branch lifecycle:
- **Active Development**: Regular commits expected
- **Stale Warning**: No commits for 7 days
- **Review Required**: No activity for 14 days
- **Archive Candidate**: No activity for 30 days

## Implementation Strategies

### 1. Manual Tracking

Simple markdown file tracking:
```markdown
# Active Branches

## feature/user-profiles
- Created: 2024-01-15
- Purpose: Add user profile functionality
- Status: In development
- Last update: 2024-01-16

## fix/data-export
- Created: 2024-01-14
- Purpose: Fix CSV export encoding
- Status: Ready for review
- PR: #456
```

### 2. Git Hooks

Pre-push hook to check branch age:
```bash
#!/bin/bash
# .git/hooks/pre-push

current_branch=$(git branch --show-current)
if [[ $current_branch == feature/* ]]; then
    last_commit=$(git log -1 --format=%ct)
    current_time=$(date +%s)
    days_old=$(( ($current_time - $last_commit) / 86400 ))
    
    if [ $days_old -gt 7 ]; then
        echo "Warning: This branch is $days_old days old. Consider creating a PR soon."
    fi
fi
```

### 3. CLI Integration

Add branch status to your prompt or CLI tools:
```bash
# In .bashrc or .zshrc
parse_git_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ ! -z "$branch" ] && [ "$branch" != "main" ]; then
        echo " ($branch)"
    fi
}

PS1="\w\$(parse_git_branch) $ "
```

## Benefits

- **No Lost Work**: All branches are tracked and accounted for
- **Clear Context**: Purpose and status always documented
- **Reduced Conflicts**: Fewer long-lived branches mean fewer merge conflicts
- **Better Collaboration**: Team awareness of ongoing work
- **Cleaner Repository**: Regular cleanup of completed branches

## Adoption

To adopt this pattern in your project:

1. **Establish Naming Convention**:
   - Document in CONTRIBUTING.md
   - Use branch protection rules to enforce

2. **Create Tracking System**:
   - Choose manual (markdown) or automated approach
   - Make it part of your workflow

3. **Set up Reminders**:
   - Calendar reminders for branch reviews
   - Automated reports of branch age
   - Integration with project management

4. **Team Practices**:
   - Regular "branch cleanup" sessions
   - Include branch status in standups
   - Celebrate completed branches

## Common Scenarios

### Scenario 1: Starting New Work
```bash
# Check for existing branches
git branch -a

# Ensure clean state
git status

# Start fresh from main
git checkout main
git pull
git checkout -b feature/new-feature

# Document purpose
echo "Feature: Implementing new dashboard widgets" > .branch-purpose
```

### Scenario 2: Resuming Work
```bash
# Check current branch
git branch --show-current

# If not on expected branch
git checkout feature/my-feature

# Check status
git status

# Review branch purpose
cat .branch-purpose

# Continue work...
```

### Scenario 3: Cleaning Up
```bash
# List all branches
git branch -a

# Delete merged branches
git branch --merged | grep -v main | xargs -n 1 git branch -d

# Remove remote tracking
git remote prune origin
```

## Anti-patterns to Avoid

❌ **Branch Proliferation**
- Creating multiple branches without finishing any
- Having 10+ active feature branches per developer

❌ **Vague Names**
- `feature/update`
- `fix/bug`
- `test-branch-2`

❌ **Eternal Branches**
- Branches that live for months
- "Just in case" branches never deleted

✅ **Good Practices**
- One or two active branches maximum
- Clear, descriptive names
- Regular cleanup of merged branches

## Related Patterns

- [Feature Branch Workflow](git-workflow.md): The workflow that creates branches
- [Commit Standards](commit-standards.md): How to document work within branches
- [PR Documentation](pr-documentation.md): Completing the branch lifecycle

## Tools and Automation

- **Git Flow**: Structured branching model
- **GitHub Branch Protection**: Enforce lifecycle rules
- **Git Town**: Enhanced git commands for branch management
- **Hub/GitHub CLI**: Simplify branch and PR operations

---

*Effective branch management is like tending a garden: regular attention prevents overgrowth and ensures healthy, productive development.*