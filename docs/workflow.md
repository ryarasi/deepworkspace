# DeepWork Workflow Guide

<!-- This file follows template @templates/T008 -->

## Overview

This guide covers the essential workflows for working with DeepWork, including git workflow, AI agent instructions, and best practices.

## Table of Contents

- [Git Workflow](#git-workflow)
- [For AI Agents](#for-ai-agents)
- [Project Creation Workflow](#project-creation-workflow)
- [Task Management](#task-management)
- [Best Practices](#best-practices)

## Git Workflow

All changes to git-tracked files MUST follow this workflow:

### 1. Start from Main
```bash
git checkout main
git pull origin main
```

### 2. Create Feature Branch
```bash
git checkout -b feature/descriptive-name
# Example: git checkout -b feature/add-docs-structure
```

### 3. Make Changes
- Work in your feature branch
- Commit frequently with descriptive messages
- Follow template T005 for commit messages

### 4. Create Pull Request
```bash
git push -u origin feature/descriptive-name
gh pr create --title "feat: Brief description" --body "..."
# Or use: ./scripts/create-pr.sh
```

PR must include (template T006):
- Summary of changes
- Original user request
- Task IDs if applicable
- Verification checklist

### 5. Merge and Cleanup
```bash
# After PR is merged
git checkout main
git pull origin main
git branch -d feature/descriptive-name
```

### Helper Scripts

- `./scripts/safe-edit.sh` - Start new feature safely
- `./scripts/create-pr.sh` - Create PR with template
- `dws pr status` - Check PR workflow state

## For AI Agents

When working in this workspace:

### 1. Context Loading
- Read `README.md` first for context and metadata
- Check current git branch before any edits
- Load tasks from TASKS.md at session start

### 2. Rule Compliance
- Check `rules/` for all requirements
- Validate changes with `dws validate`
- Never edit directly on main branch

### 3. Template Usage
- Use `templates/` for new files
- Include template reference comments
- Maintain version consistency

### 4. Git Discipline
- Follow feature branch workflow for all changes
- Include full context in commits and PRs
- Use helper scripts when available

### 5. Structure Maintenance
- Maintain the fractal structure
- Keep docs in docs/ directory
- Update documentation when changing features

## Project Creation Workflow

### 1. Interactive Creation
```bash
dws create
# Follow prompts for metadata
```

### 2. Manual Creation
```bash
mkdir projects/my-project
cd projects/my-project
# Apply template T002 for README.md
# Create required directories
```

### 3. Validation
```bash
dws validate projects/my-project
dws fix  # If issues found
```

## Task Management

### Location
Tasks are stored in `.untracked/local/TASKS.md`

### Format
```markdown
## Active Tasks

### DWS-001: Task Title
- **Status**: in-progress
- **Created**: 2025-07-06
- **Description**: Clear task description
```

### Claude Integration
```bash
# Load tasks at session start
./scripts/load-tasks.sh
```

### Task Workflow
1. Add task to TASKS.md
2. Create feature branch
3. Complete implementation
4. Update task status
5. Create PR with task reference

## Best Practices

### 1. Commit Messages (T005)
```
feat: Add new feature description

- Detailed change 1
- Detailed change 2

Task: #DWS-001
```

### 2. Branch Naming
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation only
- `refactor/` - Code refactoring

### 3. Documentation
- Update docs/ when adding features
- Keep README.md minimal
- Link to detailed docs
- Include examples

### 4. Validation
```bash
# Before committing
dws validate

# After structural changes
dws fix

# Check PR status
dws pr status
```

### 5. AI Context
- Update CLAUDE.md for AI-specific changes
- Include clear instructions
- Reference relevant rules/templates
- Test with Claude Code

## References

- [Git Commit Template](../templates/T005-git-commit.yaml)
- [PR Description Template](../templates/T006-pr-description.yaml)
- [Feature Branch Rule](../rules/R006-feature-branch-workflow.yaml)

## Version History

- **v1.0.0** (2025-07-06): Initial workflow documentation