# Pattern: Git Commit Message Standards

## When to Use

This pattern is recommended when:
- You want to maintain a clean, understandable git history
- Future developers (or AI agents) need to understand past decisions
- You need to track changes for compliance or debugging
- Your project benefits from semantic versioning
- You want to generate changelogs automatically

## Pattern Overview

The Git Commit Message Standards pattern establishes a structured approach to writing commit messages that preserve context, explain rationale, and create self-documenting history. Well-written commits become a valuable knowledge base for your project.

## Core Principles

### 1. Conventional Format
Use a consistent format with type prefixes:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Formatting, no code change
- `refactor`: Code restructuring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

### 2. Context Preservation
Every commit should explain:
- **Why** the change was made (not just what)
- **Context** that influenced the decision
- **Impact** on the system
- **Verification** approach used

### 3. Structured Sections
Organize commit messages into clear sections for consistency and readability.

## Implementation Guide

### Basic Format
```
[type]: [Brief description - 50 chars max]

[Optional body with more details]
[Can be multiple paragraphs]

[Optional footer with references]
```

### Enhanced Format with Sections
```
[type]: [Brief description]

## Context
- Task/Issue: [Reference if applicable]
- Purpose: [Why this change is needed]
- Background: [Relevant context]

## Changes
- [Specific change 1]
- [Specific change 2]
- [Impact or side effects]

## Testing
- [How the change was verified]
- [Test scenarios covered]

## References
- Related to: [Issue/PR numbers]
- Follows: [Relevant patterns or standards]
- See also: [Documentation links]
```

## Examples

### Simple Commit
```
fix: Correct user authentication timeout

The session was expiring after 15 minutes instead of the 
configured 30 minutes due to incorrect unit conversion.

Fixes #123
```

### Detailed Commit
```
feat: Add real-time collaboration features

## Context
- Task ID: PROJ-456
- Purpose: Enable multiple users to edit documents simultaneously
- Requested by: Product team for Q4 launch

## Changes
- Implemented WebSocket connection for real-time updates
- Added conflict resolution algorithm
- Created presence indicators for active users
- Updated UI to show collaborative cursors

## Testing
- Tested with up to 10 concurrent users
- Verified conflict resolution with simultaneous edits
- Checked performance impact on server
- Validated graceful degradation without WebSocket support

## References
- Implements: Design doc at docs/collaboration-design.md
- Related PR: #789 (WebSocket infrastructure)
- Issue: #456
```

## Benefits

- **Knowledge Preservation**: Decisions and context remain accessible
- **Debugging Aid**: Understanding why changes were made helps fix issues
- **Onboarding**: New team members can understand project evolution
- **Automation**: Tools can parse structured commits for changelogs
- **Accountability**: Clear record of who made what changes and why

## Adoption

To adopt this pattern in your project:

1. **Create a Commit Template**:
   ```bash
   # Save as .gitmessage in your project
   # type: Brief description

   ## Context
   - Purpose: 
   - Task/Issue: 

   ## Changes
   - 

   ## Testing
   - 

   ## References
   - 
   ```

   Configure git to use it:
   ```bash
   git config commit.template .gitmessage
   ```

2. **Add Commit Linting** (optional):
   - Use tools like `commitlint` for enforcement
   - Add pre-commit hooks for validation

3. **Document Standards**:
   - Include in CONTRIBUTING.md
   - Provide examples in your documentation
   - Create a quick reference guide

4. **Training and Culture**:
   - Share examples of good commits
   - Review commit messages in code reviews
   - Celebrate well-documented changes

## Guidelines

### Subject Line
- Keep under 50 characters
- Use imperative mood ("Add feature" not "Added feature")
- Don't end with a period
- Capitalize first letter

### Body
- Wrap at 72 characters
- Explain what and why, not how
- Use bullet points for multiple items
- Include relevant measurements or data

### Footer
- Reference issues with "Fixes #123" or "Closes #456"
- Note breaking changes with "BREAKING CHANGE:"
- Credit co-authors if applicable

## Anti-patterns to Avoid

❌ **Vague Messages**
```
Updated files
Fixed stuff
Changes
```

❌ **No Context**
```
fix: Update user.js
```

❌ **Too Technical Without Why**
```
refactor: Change Array.prototype.map to for loop
```

✅ **Better Version**
```
refactor: Optimize user list rendering for large datasets

Replaced Array.map with for loop in user list component to 
improve performance when displaying 1000+ users. Benchmarks 
showed 40% faster rendering time.

Performance issue reported in #234
```

## Related Patterns

- [Feature Branch Workflow](git-workflow.md): How to organize your changes
- [PR Documentation](pr-documentation.md): Documenting sets of commits
- [Branch Management](branch-management.md): Organizing work across branches

## Tools and Resources

- **Conventional Commits**: https://www.conventionalcommits.org/
- **Git Commit Template**: Built into git
- **Commitizen**: Interactive commit message helper
- **Standard Version**: Automated versioning based on commits

---

*Well-crafted commit messages are a gift to your future self and your team. They transform git history from a list of changes into a valuable knowledge base.*