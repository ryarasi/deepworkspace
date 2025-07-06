# DeepWork AI Context

This file provides AI-specific context for working with the DeepWork project.

## Project Structure Requirements

This project follows a strict fractal structure defined in docs/rules/R001-project-structure.yaml:
- **Root files**: Only README.md, docs/, .untracked/, and optional CLAUDE.md
- **Governance**: All rules, templates, and scripts under docs/rules/
- **No content folder**: Direct file placement at root level
- **Child projects**: Stored in .untracked/repos/

## Critical Rules

1. **R001**: Project structure - fractal pattern at every level
2. **R002**: Template integrity - all documents follow templates
3. **R003**: Self-demonstration - DeepWork uses its own system
4. **R004**: Reference integrity - all references must be valid
5. **R005**: Root file governance - strict control of root directory
6. **R006**: Script validation - all scripts must be validated

## Working with DeepWork

### Git Workflow
- Always work on feature branches (never on main)
- Follow commit standards in docs/rules/templates/T005-git-commit.yaml
- Create PRs with comprehensive documentation (T006)

### Validation
Always run validation after changes:
```bash
docs/rules/scripts/validate
```

### Key Commands
- `docs/rules/scripts/dws create` - Create new projects
- `docs/rules/scripts/validate` - Validate structure
- `docs/rules/scripts/sync` - Sync tasks and state

## Current Migration Status

The project is currently migrating from the old structure (rules/, templates/, scripts/ at root) to the new v5.0.0 structure where everything is consolidated under docs/rules/. This migration needs to be completed and committed properly.

## AI Instructions

1. **Respect the fractal structure** - Every project follows the same pattern
2. **Use templates** - All documents must follow their designated templates
3. **Validate changes** - Run validation scripts after modifications
4. **Follow git workflow** - Feature branches, proper commits, documented PRs
5. **Maintain self-containment** - docs/rules/ must be completely portable

## Context for Current Session

When working on this project:
- Check git status to understand current migration state
- Complete the structural migration before other changes
- Ensure all references are updated to new paths
- Validate the final structure matches R001 requirements