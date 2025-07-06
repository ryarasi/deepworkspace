# DeepWork Architecture

<!-- This file follows template @templates/T008 -->

## Overview

This document details the technical architecture and design principles of DeepWork, including its fractal structure, component organization, and script architecture.

## Table of Contents

- [Structure Overview](#structure-overview)
- [Core Concepts](#core-concepts)
- [DWS Script Architecture](#dws-script-architecture)
- [Content Manifest](#content-manifest)
- [Design Principles](#design-principles)

## Structure Overview

```
deepworkspace/                    # The root project (this workspace)
├── README.md                     # Universal documentation and AI context
├── docs/                         # Detailed documentation
│   └── PSD.md                   # Project Specification Document
├── templates/                    # T001-T999 templates
├── rules/                        # R001-R999 rules  
├── scripts/                      # Helper scripts
├── .untracked/                   # External repos and local data
│   ├── repos/                   # Cloned child projects
│   └── local/                   # Local workspace files
└── [project files]              # Any other files at root level
```

## Core Concepts

### 1. Universal Project Structure

Every project (including this workspace) has exactly:
- `README.md` - Universal documentation for humans and AI with metadata
- `docs/` - Documentation directory with PSD.md
- `.untracked/` - Untracked items (repos/, local/)
- Project files live directly at root level
- `projects/` - Sub-projects (optional)

### 2. Modular Projects

Projects can contain other projects, enabling:
- Complex software with multiple components (web-ui, mobile-ui, api)
- Large documentation projects with sub-sections
- Any hierarchical organization needed

The fractal nature means every level follows identical patterns.

### 3. Template System

All consistency comes from templates in `templates/`:
- Templates ensure uniform structure
- Templates are versioned
- Templates reference: `@templates/T###`
- Key templates:
  - T001: Template metadata
  - T002: Project README
  - T010: Project specification document (PSD)
  - T004: Rule template
  - T005: Git commit message
  - T006: PR description
  - T007: Project tasks
  - T008: Documentation files

### 4. Rules Engine

Workspace integrity maintained by rules in `rules/`:
- Rules define requirements
- Rules are actionable
- Rules reference: `@rules/R###`
- Key rules:
  - R001: Universal project structure
  - R003: Template usage
  - R003: Template application
  - R004: Infinite nesting
  - R005: Workspace as project
  - R006: Feature branch workflow
  - R007: Commit message standards
  - R008: PR documentation

### 5. Git Workflow

All changes must follow:
1. Create feature branch
2. Make changes
3. Create PR with full context
4. Merge to main
5. Pull and cleanup

## DWS Script Architecture

The DWS CLI provides comprehensive workspace management through modular scripts:

### Command Structure
```
scripts/
├── dws                  # Main dispatcher script
├── dws-lib/            # Command implementations
│   ├── common.sh       # Shared functions and validation
│   ├── create.sh       # Project creation with metadata
│   ├── validate.sh     # Rule compliance checking
│   ├── fix.sh          # Automated issue resolution
│   ├── pr.sh           # Pull request workflow
│   └── start.sh        # Project navigation
└── [other scripts]     # Utility scripts
```

### Validation Capabilities

DWS scripts provide extensive validation:
- **Structural validation**: Project structure compliance (R001)
- **Template validation**: Template existence and references
- **Rule validation**: Rule numbering and references
- **Git validation**: Branch status and workflow compliance

### Key Functions (common.sh)

- `validate_project_structure()`: Checks R001 compliance
- `check_and_warn_main_branch()`: Enforces feature branch workflow
- `verify_template_references()`: Validates template usage
- `auto_fix_structure()`: Repairs common issues

## System File Organization

DeepWork system files live directly at the root level:

### Structure
```
deepworkspace/
├── docs/          # Detailed documentation
├── templates/     # Project and file templates (T001-T999)
├── rules/         # Workspace rules and requirements (R001-R999)
├── scripts/       # CLI tools and automation
│   ├── dws        # Main CLI entry point
│   └── dws-lib/   # Command implementations
└── .untracked/    # Local workspace and temp files
```

### Key Components
- **Docs**: Comprehensive documentation including PSD.md
- **Templates**: Define consistent structure for all files
- **Rules**: Enforce workspace integrity and conventions
- **Scripts**: Provide CLI tools for project management
- **DWS CLI**: Main command-line interface for workspace operations

## Design Principles

1. **Minimalism**: Only essential structure, no bloat
2. **Self-Similarity**: Fractal pattern at every level
3. **Git-First**: All context captured in version control
4. **Template-Driven**: Consistency through templates
5. **AI-Optimized**: Clear context for AI agents
6. **Modular**: Components can be mixed and matched
7. **Extensible**: Easy to add new rules and templates

## References

- [Rules Documentation](rules.md)
- [Template Guide](templates.md)
- [Workflow Documentation](workflow.md)

## Version History

- **v1.0.0** (2025-07-06): Initial architecture documentation