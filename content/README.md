# Content Directory

This directory contains all the actual work for the DeepWorkspace system.

## Overview

This is the workspace system's core implementation - templates, rules, scripts, and documentation that make DeepWorkspace function.

## Structure

```
content/
├── README.md      # This file
├── templates/     # Project and file templates (T001-T999)
├── rules/         # Workspace rules (R001-R999)
├── scripts/       # Helper scripts and dws CLI
├── archive/       # Compressed old projects
└── temp/          # Temporary files
```

## Key Components

- **templates/** - YAML templates that ensure consistency across the workspace
- **rules/** - YAML rules that define workspace requirements and behavior
- **scripts/** - The dws CLI and supporting shell scripts
- **archive/** - Long-term storage for completed/old projects (compressed)
- **temp/** - Temporary working directory (gitignored)

## External Dependencies

External repositories and untracked items are now stored in `.untracked/` at the project root level, not in the content directory. This keeps the workspace system's content focused on templates, rules, and scripts.

## Development Notes

- All changes to templates and rules should follow the feature branch workflow
- Scripts should be thoroughly tested before merging
- Archive old projects using the archival system
- Keep temp/ clean - it's for temporary work only

## Build Artifacts

The following patterns are gitignored:
- temp/* - Temporary files (except .gitkeep)
- *.tmp - Temporary files
- *.swp - Editor swap files