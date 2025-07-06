# DeepWorkspace Setup Guide

<!-- This file follows template @templates/T008 -->

## Overview

This guide provides detailed instructions for setting up DeepWorkspace on your system, including both automated and manual setup options.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Automated Setup](#automated-setup)
- [Manual Setup](#manual-setup)
- [Available Commands](#available-commands)
- [Verification](#verification)

## Prerequisites

- Git installed and configured
- Bash or Zsh shell
- Claude Desktop app (for AI integration)

## Automated Setup

The easiest way to get started:

```bash
# 1. Clone this repository
git clone https://github.com/ryarasi/deepworkspace.git
cd deepworkspace

# 2. Run the setup script
./scripts/setup.sh

# 3. Reload your shell (or open a new terminal)
source ~/.bashrc  # or source ~/.zshrc

# 4. Create your first project
dws create

# 5. Navigate to projects
dws start
```

## Manual Setup

If you prefer to set up manually instead of using the setup script, add these to your shell configuration file (`~/.bashrc` or `~/.zshrc`):

```bash
# Add dws to PATH
export PATH="$PATH:$HOME/deepworkspace/scripts"

# Function to change directory and open Claude Desktop
dws-cd() {
    cd "$1" && claude --dangerously-skip-permissions
}

# Quick project navigation with Claude
dws-start() {
    eval $(dws start --eval)
}
```

After adding these lines:
1. Save the file
2. Reload your shell: `source ~/.bashrc` or `source ~/.zshrc`
3. Verify installation: `dws help`

## Available Commands

After setup, you can use:

- `dws create` - Create new projects interactively
- `dws start` or `dws-start` - Navigate to projects and open Claude Desktop
- `dws validate` - Check all projects for rule compliance
- `dws fix` - Automatically fix common issues
- `dws pr` - Manage pull request workflow
- `dws help` - Show all available commands

### Command Details

#### dws create
Interactive project creation with:
- Metadata collection (name, type, description)
- Automatic template application
- Git initialization
- Structure validation

#### dws validate
Comprehensive validation including:
- Project structure checks (R001 compliance)
- Template reference validation
- Rule consistency verification
- Git workflow compliance

#### dws fix
Automated fixes for:
- Missing directories
- Incorrect .gitignore entries
- Structure compliance issues
- Common configuration problems

## Verification

To verify your setup is working correctly:

```bash
# Check dws is available
which dws

# Show available commands
dws help

# Validate workspace structure
dws validate

# Create a test project
dws create
```

## References

- [Architecture Documentation](architecture.md)
- [Workflow Guide](workflow.md)
- [DWS Script Reference](scripts.md)

## Version History

- **v1.0.0** (2025-07-06): Initial documentation