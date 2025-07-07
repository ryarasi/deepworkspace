# Project AI Context

This file provides AI-specific context for working with this project.

## Project Structure Requirements

This project follows a strict fractal structure:
- **Root files**: Only README.md, docs/, and three gitignored directories
- **Governance**: Self-contained units under docs/governance/
- **Documentation**: Organized in docs/ with guide/, specs/, and user/
- **Workspaces**: .local/ (temp), projects/ (children), repos/ (external)

## Critical Rules

1. **R001**: Project structure - fractal pattern at every level
2. **R002**: Template integrity - all documents follow templates
3. **R003**: Self-demonstration - DeepWork uses its own system
4. **R004**: Reference integrity - all references must be valid
5. **R005**: Governance hierarchy - clear rule precedence
6. **R006**: Script validation - all rules must be validatable

## Working with DeepWork

### Git Workflow
- Always work on feature branches (never on main)
- Follow commit standards in governance templates
- Create PRs with comprehensive documentation

### Validation
Always run validation after changes:
```bash
docs/governance/tools/validate
```

### Key Commands
- `docs/governance/tools/create` - Create new projects
- `docs/governance/tools/validate` - Validate structure
- Each rule has its own `validate.sh` script

## Current Version: v6.0.0

The project now uses fractal governance units where each rule is self-contained with its own validation. The structure emphasizes:
- True fractal pattern (same at every level)
- Self-validating rules
- Clear separation of governance vs user documentation
- Three workspace directories for different purposes

## AI Instructions

1. **Respect the fractal structure** - Every project follows the same pattern
2. **Use templates** - All documents must follow their designated templates
3. **Validate changes** - Run validation scripts after modifications
4. **Follow git workflow** - Feature branches, proper commits, documented PRs
5. **Maintain self-containment** - docs/governance/ is completely portable

## Context for Current Session

When working on this project:
- Use the fractal pattern at every level
- Each rule directory contains rule.yaml, validate.sh, and README.md
- User documentation goes in docs/user/ (unstructured)
- Governance documentation stays in docs/governance/