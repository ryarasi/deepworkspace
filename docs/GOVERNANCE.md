# Project Governance System

This document is the entry point to the project's governance system - a self-contained, portable framework for maintaining consistency and quality across all projects.

## Quick Start

Validate your project compliance:
```bash
docs/governance/tools/validate
```

Create a new child project:
```bash
docs/governance/tools/create my-project
```

## Governance Structure

The governance system is organized into self-contained units:

### Core Rules

Each rule is a complete unit with its own validation:

1. **[structure/](governance/structure/)** - R001: Project Structure
   - Defines the fractal pattern all projects must follow
   - Validates: README.md, docs/, and gitignored directories

2. **[templates/](governance/templates/)** - R002: Template System  
   - Ensures documentation consistency through templates
   - Library of 11 templates for all document types

3. **[demonstration/](governance/demonstration/)** - R003: Self Demonstration
   - The governance system must follow its own rules
   - Meta-validation of the system itself

4. **[references/](governance/references/)** - R004: Reference Integrity
   - All links and references must be valid
   - No broken documentation links

5. **[hierarchy/](governance/hierarchy/)** - R005: Governance Hierarchy
   - Rules have clear precedence and organization
   - Immutable core vs. mutable extensions

6. **[validation/](governance/validation/)** - R006: Validation Requirements
   - All rules must be validatable
   - Master validation orchestration

### Supporting Components

- **[patterns/](governance/patterns/)** - Reusable workflow patterns
- **[tools/](governance/tools/)** - Command-line utilities

## The Fractal Principle

Every level of the project follows the same pattern:
```
any-level/
├── README.md          # Entry point
├── docs/              # Documentation
├── .local/            # Local workspace (gitignored)
├── projects/          # Child projects (gitignored)  
└── repos/             # External repos (gitignored)
```

This pattern repeats at every level, creating a self-similar structure that scales infinitely.

## Validation

Run the master validation to check all rules:
```bash
docs/governance/tools/validate
```

Or validate individual rules:
```bash
docs/governance/structure/validate.sh
docs/governance/templates/validate.sh
# ... etc
```

## Portability

The entire governance system is self-contained in `docs/governance/`. To use it in another project:

1. Copy the entire `docs/governance/` directory
2. Run `docs/governance/tools/validate` to check compliance
3. Use `docs/governance/tools/create` to create child projects

## Philosophy

This governance system embodies:
- **Minimalism**: Only essential rules and structures
- **Fractality**: Same patterns at every scale
- **Portability**: Works anywhere without dependencies
- **Flexibility**: Users control their own documentation

## For Developers

- Each rule directory contains:
  - `rule.yaml` - Rule definition
  - `validate.sh` - Validation script  
  - `README.md` - Documentation
  
- Templates are in `templates/library/`
- Tools are simple bash scripts in `tools/`
- Everything is file-based and portable

---

*This governance system is designed to be understood by both humans and AI assistants, providing clear structure while maintaining flexibility.*