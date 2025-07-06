# DeepWork Project Specification Document

<!-- This file follows template @templates/T010 -->

## Table of Contents

- [System Architecture](#system-architecture)
- [Core Philosophy](#core-philosophy)
- [Technical Specifications](#technical-specifications)
- [Directory Structure](#directory-structure)
- [Component Details](#component-details)
- [Workflow Processes](#workflow-processes)
- [Development Guidelines](#development-guidelines)
- [Extended Documentation](#extended-documentation)

## System Architecture

DeepWork is a minimalist, template-driven project management system that brings order to chaos through fractal architecture. Every project follows the same self-similar pattern, enabling infinite nesting while maintaining simplicity at its core.

### Core Principles

1. **Fractal Structure**: Every project looks identical, can contain other projects
2. **Minimal Files**: Only README.md, docs/, and .untracked/ at root
3. **Git-Centric**: All projects are independent git repositories
4. **Template-Driven**: Consistency through templates, not tooling
5. **AI-Optimized**: Designed for seamless Claude Code integration

### System Components

- **README.md**: Universal entry point with standardized metadata
- **docs/**: Extended documentation (PSD.md and other docs)
- **scripts/**: Automation and tooling
- **templates/**: Project and file templates
- **rules/**: System rules and constraints
- **.untracked/**: Local workspace and cloned child projects

## Core Philosophy

### Why DeepWork?

By maintaining the most minimalist structure possible, we optimize for efficiency and elegance. This system captures endless complexity through modular nesting while remaining simple at its core.

### Design Decisions

1. **No CLAUDE.md**: README serves both humans and AI, avoiding redundancy
2. **No content/ folder**: Files live at root where developers expect them
3. **Child projects in .untracked/repos/**: Prevents git nesting issues
4. **Standardized README**: Same format everywhere for predictability
5. **PSD for details**: Keeps README lightweight, PSD for deep documentation

## Technical Specifications

### Project Structure

```
project/
├── README.md          # Standardized metadata and overview
├── docs/             
│   └── PSD.md        # Project Specification Document
├── .untracked/       # Gitignored local workspace
│   ├── repos/        # Cloned child projects
│   └── local/        # Local workspace files
└── [project files]   # Any other files at root level
```

### README.md Format

All README files follow this exact structure:

```markdown
# Project Name

<!-- This file follows template @templates/T002 -->

## Metadata
- **Name**: [Full name]
- **Slug**: [lowercase-hyphenated]
- **Parent**: [parent-slug or empty]
- **Type**: [person|group|entity|product|research|learning]
- **Subtype**: [type-specific]
- **URL**: [repository URL]
- **Created**: [ISO timestamp]
- **Modified**: [ISO timestamp]
- **Status**: [active|paused|archived]
- **Related**: [comma-separated slugs]

## Overview
[Brief description]

For more details see [docs/PSD.md](docs/PSD.md)

## Projects
Child projects of [Name]:
- **child-slug**: Description | `URL`

To clone child projects, run:
\`\`\`bash
./scripts/init-project.sh
\`\`\`

## Quick Start
[Essential commands]

## Documentation
See [Project Specification Document](docs/PSD.md) for detailed specifications.
```

### Project Types and Subtypes

**Types**:
- person (human, animal)
- group (people, entity)
- entity (company, government, organization, community)
- product (software, writing, multimedia, hardware)
- research (project, topic)
- learning (topic, skill)

## Directory Structure

### Root Level
- **README.md**: Entry point with metadata
- **docs/**: All documentation
- **.gitignore**: Excludes .untracked/
- **[project files]**: Source code, assets, etc.

### docs/
- **PSD.md**: This file, detailed specifications
- **[other docs]**: Architecture, API, guides, etc.

### .untracked/
- **repos/**: Cloned child projects
- **local/**: Workspace files (TASKS.md, etc.)

## Component Details

### DWS Command Line Tool

Located at `scripts/dws`, provides:
- `dws create`: Interactive project creation
- `dws start`: Navigate and open projects
- `dws validate`: Check rule compliance
- `dws fix`: Auto-fix common issues
- `dws pr`: Pull request workflow management

### Templates

- **T002**: README.md template
- **T005**: Git commit message template
- **T006**: Pull request template
- **T007**: Project tasks template
- **T008**: Documentation file template
- **T010**: PSD template (this format)

### Rules

- **R001**: Minimal project structure
- **R002**: Content isolation in project root
- **R004**: Infinite nesting capability
- **R006**: Feature branch workflow
- **R007**: Commit standards
- **R008**: PR standards

## Workflow Processes

### Creating a New Project

1. Run `dws create` for interactive creation
2. Or manually:
   - Create directory
   - Add README.md with metadata
   - Create docs/PSD.md
   - Create .untracked/
   - Add .gitignore

### Git Workflow

1. Create feature branch: `git checkout -b feature/description`
2. Make changes
3. Commit with T005 format
4. Create PR with `scripts/create-pr.sh`
5. Merge and cleanup

### Managing Child Projects

1. List in parent's README.md Projects section
2. Clone with `scripts/init-workspace.sh`
3. Each child is independent git repo
4. Work in `.untracked/repos/child-name/`

## Development Guidelines

### Best Practices

1. **Keep README minimal**: Overview only, details in PSD
2. **One source of truth**: No duplicate information
3. **Fractal consistency**: Every level looks the same
4. **Git independence**: Each project has its own repository
5. **Clear hierarchies**: Parent lists children, not grandchildren

### Common Patterns

- **Monorepo alternative**: Use child projects instead
- **Shared code**: Clone as child project, reference
- **Documentation**: README for quick, PSD for deep
- **Tasks**: Use .untracked/local/TASKS.md

## Extended Documentation

### Version History

- **v3.0.0** (2025-07-06): Ultra-minimal structure
- **v2.0.0** (2025-07-05): Branch protection and validation
- **v1.0.0** (2025-07-03): Initial release

### Migration Notes

From v2.x to v3.x:
1. Remove CLAUDE.md files
2. Move content/* to root
3. Update all path references
4. Create docs/PSD.md

### Future Considerations

- Even more minimal: Just README + .untracked?
- Template inheritance system
- Automated cross-project dependencies
- Web-based project browser

---

*This PSD provides comprehensive specifications for the DeepWork system. For quick overview, see [README.md](../README.md).*