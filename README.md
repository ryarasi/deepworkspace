# DeepWorkspace

<!-- This file follows template @content/templates/T002 -->

## Metadata
- **Name**: DeepWorkspace
- **Slug**: deepworkspace
- **Parent**: root
- **Type**: product
- **Subtype**: software
- **URL**: https://github.com/ryarasi/deepworkspace
- **Created**: 2025-07-03T20:00:00+0530
- **Modified**: 2025-07-05T12:45:00+0530
- **Status**: active
- **Related**:

## What is DeepWorkspace?

DeepWorkspace is a structured, template-driven workspace management system that brings order to chaos through:

- **Fractal Architecture**: Every project follows the same pattern, projects can contain projects
- **Template-Driven**: Consistency through templates, not complex tooling
- **Git-First**: All context and history captured in version control
- **AI-Optimized**: Designed for seamless Claude Code integration
- **Minimalist**: Lightweight orchestration, maximum flexibility

## Why DeepWorkspace?

Our thesis: By maintaining the most minimalist structure possible, we optimize for efficiency and elegance. This system captures endless complexity through modular nesting while remaining simple at its core.

### Key Benefits
1. **No Installation Required**: Just clone and follow this README
2. **Infinitely Scalable**: Projects within projects, any depth
3. **Self-Documenting**: The workspace follows its own rules
4. **Version Controlled**: Complete history of all changes
5. **AI-Friendly**: Optimized for Claude Code context

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/ryarasi/deepworkspace.git
cd deepworkspace

# 2. Run the setup script
./content/scripts/setup.sh

# 3. Reload your shell (or open a new terminal)
source ~/.bashrc  # or source ~/.zshrc

# 4. Create your first project
dws create

# 5. Navigate to projects
dws start
```

## Manual Setup (Alternative)

If you prefer to set up manually instead of using the setup script, add these to your shell configuration file (`~/.bashrc` or `~/.zshrc`):

```bash
# Add dws to PATH
export PATH="$PATH:$HOME/deepworkspace/content/scripts"

# Function to change directory and open Claude Desktop
dws-cd() {
    cd "$1" && claude --dangerously-skip-permissions
}

# Quick project navigation with Claude
dws-start() {
    eval $(dws start --eval)
}
```

## Available Commands

After setup, you can use:
- `dws create` - Create new projects interactively
- `dws start` or `dws-start` - Navigate to projects and open Claude Desktop
- `dws validate` - Check all projects for rule compliance
- `dws fix` - Automatically fix common issues
- `dws help` - Show all available commands

## Structure

```
deepworkspace/                    # The root project (this workspace)
├── README.md                     # You are here
├── CLAUDE.md                     # AI context entry point
├── .claude/                      # Claude Desktop settings
├── .untracked/                   # External repos and local data
├── content/                      # Workspace system files
│   ├── templates/                # T001-T999 templates
│   ├── rules/                    # R001-R999 rules  
│   ├── scripts/                  # Helper scripts
│   └── temp/                     # Temporary files
└── projects/                     # All your projects
    └── [project-name]/          # Each project follows same structure
        ├── README.md            # Project documentation
        ├── CLAUDE.md            # Project AI context
        ├── content/             # Project actual content
        └── projects/            # Sub-projects (optional)
```

## Core Concepts

### 1. Universal Project Structure
Every project (including this workspace) has exactly:
- `README.md` - Human documentation
- `CLAUDE.md` - AI context
- `content/` - Actual content (code, docs, or system files)
- `projects/` - Sub-projects (optional)

### 2. Modular Projects
Projects can contain other projects, enabling:
- Complex software with multiple components (web-ui, mobile-ui, api)
- Large documentation projects with sub-sections
- Any hierarchical organization needed

### 3. Template System
All consistency comes from templates in `content/templates/`:
- Templates ensure uniform structure
- Templates are versioned
- Templates reference: `@content/templates/T###`

### 4. Rules Engine
Workspace integrity maintained by rules in `content/rules/`:
- Rules define requirements
- Rules are actionable
- Rules reference: `@content/rules/R###`

### 5. Git Workflow
All changes (except in content/) must follow:
1. Create feature branch
2. Make changes
3. Create PR with full context
4. Auto-merge to main
5. Pull and cleanup

## Content Manifest

The content/ directory contains all DeepWorkspace system files:

### Structure
```
content/
├── templates/     # Project and file templates (T001-T999)
├── rules/         # Workspace rules and requirements (R001-R999)
├── scripts/       # CLI tools and automation
│   ├── dws        # Main CLI entry point
│   └── dws-lib/   # Command implementations
└── temp/          # Temporary files (gitignored)
```

### Key Components
- **Templates**: Define consistent structure for all files
- **Rules**: Enforce workspace integrity and conventions
- **Scripts**: Provide CLI tools for project management
- **DWS CLI**: Main command-line interface for workspace operations

## External Repositories

No external repositories are currently integrated into the workspace system.

| Repository | Description | URL | Added | Last Modified |
|------------|-------------|-----|-------|---------------|
| - | - | - | - | - |

## For AI Agents

When working in this workspace:
1. Read `CLAUDE.md` first for context
2. Check `content/rules/` for requirements
3. Use `content/templates/` for new files
4. Follow git workflow for all changes
5. Maintain the fractal structure

## Version History

- **v1.0.0**: Original deepwork concept
- **v2.0.0**: v0.deepworkspace implementation  
- **v3.0.0**: Current minimalist, modular design

## Roadmap

See `content/TASKS.md` for current tasks and future plans.

Future features:
- GitHub issue-based change tracking
- Automated template validation
- Cross-project dependency management
- External repository integration tools

---

*This workspace is itself a project that follows its own rules. No exceptions, no special cases.* 