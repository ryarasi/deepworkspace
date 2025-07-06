# Pattern: Feature Branch Git Workflow

## When to Use

This pattern is recommended when:
- Your project needs a clear audit trail of all changes
- Multiple contributors work on the same codebase
- You want to preserve context for future reference
- Code review or approval processes are beneficial
- You need rollback capabilities for changes

## Pattern Overview

The Feature Branch Git Workflow pattern establishes a systematic approach to making changes through isolated branches and pull requests. This workflow provides complete traceability, context preservation, and protected main branch integrity.

## Core Principles

### 1. All Changes Through Feature Branches
Every modification to git-tracked files should be made in a dedicated feature branch, never directly on the main branch. This includes:
- Code changes
- Documentation updates
- Configuration modifications
- Any file tracked by git

### 2. Pull Request Documentation
Each set of changes should be documented through a pull request that captures:
- The purpose and context of changes
- Implementation decisions
- Testing approach
- References to related work

### 3. Remote Repository Integration
Projects should be connected to a remote repository (e.g., GitHub) before implementing changes. This enables:
- Collaborative workflows
- Backup and disaster recovery
- Pull request creation and review
- Integration with CI/CD systems

### 4. Remote Push Before Changes
For new projects, it's highly recommended to push the initial structure to a remote repository before making any substantial changes. This ensures:
- The PR workflow can be used from the very beginning
- No local-only changes that bypass the workflow
- Complete audit trail from project inception
- Consistent workflow across all projects

## Implementation Guide

### Step 0: New Project Setup (if applicable)
```bash
# After creating a new project
cd projects/my-new-project

# Create GitHub repository
gh repo create my-new-project --public

# Push initial structure
git push -u origin main

# Now proceed with feature branches for all changes
```

### Step 1: Initial Setup
```bash
# Ensure you're on the main branch
git checkout main

# Pull latest changes
git pull

# Create a descriptive feature branch
git checkout -b feature/your-description
```

### Step 2: Make Your Changes
- Work within the feature branch
- Commit changes with descriptive messages
- Include context about why changes were made
- Reference any related issues or tasks

### Step 3: Create Pull Request
```bash
# Push your branch to remote
git push -u origin feature/your-description

# Create PR using GitHub CLI (or web interface)
gh pr create --title "Brief description" --body "Detailed explanation"
```

### Step 4: Merge and Cleanup
```bash
# After PR is merged, switch back to main
git checkout main

# Pull the merged changes
git pull

# Delete the feature branch locally
git branch -d feature/your-description

# Delete the remote branch (if not auto-deleted)
git push origin --delete feature/your-description
```

## Benefits

- **Traceability**: Every change has a clear history and context
- **Reversibility**: Easy to revert problematic changes
- **Collaboration**: Multiple developers can work simultaneously
- **Quality**: Opportunity for review before merging
- **Documentation**: PRs serve as permanent context records

## Adoption

To adopt this pattern in your project:

1. **Configure Git Hooks** (optional but recommended):
   - Add pre-commit hooks to prevent direct commits to main
   - Use branch naming conventions

2. **Create Helper Scripts** (optional):
   ```bash
   # Example: safe-edit.sh
   #!/bin/bash
   git checkout main
   git pull
   git checkout -b feature/$1
   ```

3. **Document the Workflow**:
   - Add workflow documentation to your README
   - Include in onboarding materials
   - Reference in contribution guidelines

4. **Set Branch Protection** (for GitHub):
   ```bash
   # Protect main branch
   gh repo edit --default-branch main --delete-branch-on-merge
   ```

## Exceptions

While this pattern is highly recommended, there are valid exceptions:
- Emergency hotfixes for production issues
- Initial repository setup
- Automated bot commits (with proper configuration)
- Files explicitly excluded from version control

## Related Patterns

- [Commit Standards](commit-standards.md): Guidelines for commit message formatting
- [PR Documentation](pr-documentation.md): Templates for pull request descriptions
- [Branch Management](branch-management.md): Strategies for branch lifecycle

## Example Workflow

```bash
# Start new feature
git checkout main
git pull
git checkout -b feature/add-user-authentication

# Make changes
echo "Authentication logic" > auth.js
git add auth.js
git commit -m "feat: Add user authentication module

- Implemented JWT-based authentication
- Added login/logout endpoints
- Included session management
"

# Push and create PR
git push -u origin feature/add-user-authentication
gh pr create --title "feat: Add user authentication" \
  --body "## Summary
  Added JWT-based authentication system
  
  ## Changes
  - New auth.js module
  - Login/logout endpoints
  - Session management
  
  ## Testing
  - Unit tests for auth functions
  - Integration tests for endpoints"

# After merge
git checkout main
git pull
git branch -d feature/add-user-authentication
```

## Tools and Automation

Consider these tools to support the workflow:
- **GitHub CLI (`gh`)**: Streamline PR creation
- **Git aliases**: Shortcuts for common commands
- **Branch naming conventions**: Enforce with git hooks
- **CI/CD integration**: Automate testing on PRs

---

*This pattern promotes professional development practices while maintaining flexibility for different project needs.*