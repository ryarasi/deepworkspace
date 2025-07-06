# Universal /sync Command

## Overview

The `/sync` command is a universal context alignment tool that works in ANY project with a `README.md` file. It reads the project context and evaluates whether your current task/conversation aligns with the project's rules, workflows, and requirements.

## Key Features

- **Completely Agnostic**: Works with any project structure, not tied to any specific system
- **Auto-Discovery**: Finds README.md in current or parent directories
- **Smart Parsing**: Extracts rules, workflows, and requirements from various README.md formats
- **Alignment Analysis**: Detects misalignments between current state and project context
- **Strategic Guidance**: Provides actionable suggestions when issues are found

## Installation

1. Place the sync scripts in your project:
   ```bash
   scripts/sync.py    # Main Python implementation
   scripts/sync       # Shell wrapper
   ```

2. Make them executable:
   ```bash
   chmod +x scripts/sync.py
   chmod +x scripts/sync
   ```

3. Add to your PATH or create an alias:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias /sync="/path/to/your/project/scripts/sync"
   ```

## Usage

Simply run `/sync` from any directory containing a README.md file:

```bash
/sync
```

## How It Works

1. **Discovery Phase**:
   - Searches for README.md in current directory
   - Checks common locations: `./, ./docs/`
   - Traverses up to 5 parent directories if needed

2. **Context Extraction**:
   - Parses README.md to extract:
     - Project purpose and description
     - Rules and requirements
     - Workflow specifications
     - Never/Always rules
     - Directory structure
     - Technology stack

3. **Alignment Analysis**:
   - Checks current directory alignment
   - Verifies git workflow compliance
   - Identifies rule violations
   - Validates file operations

4. **Output Generation**:
   - Categorizes issues by severity:
     - ❌ CRITICAL: Must be fixed immediately
     - ⚠️  WARNING: Should be addressed
     - 💡 SUGGESTION: Recommended improvements
   - Provides specific corrective actions
   - Triggers strategic thinking for critical issues

## Example Output

```
============================================================
PROJECT CONTEXT SYNC ANALYSIS
============================================================

Project: my-project
Context: /path/to/my-project/README.md

Purpose:
  A web application for task management...

❌ CRITICAL ISSUES:
  - Working directly on main branch
    → Create a feature branch before making changes
    Reference: All changes must be in feature branches

⚠️  WARNINGS:
  - Working directory may not align with project root
    → Consider navigating to /path/to/my-project

💡 SUGGESTIONS:
  - Project uses specific directory structure
    → Ensure files are created in appropriate directories

----------------------------------------
KEY RULES TO REMEMBER:

ALWAYS:
  • Use feature branches for all changes
  • Run tests before committing
  • Update documentation

NEVER:
  • Commit directly to main
  • Create files outside project directories
  • Skip code reviews

============================================================

🤔 STRATEGIC RECALIBRATION NEEDED
Critical misalignments detected. Ultrathinking recommended...
```

## README.md Format Flexibility

The sync command works with any README.md format. It intelligently extracts context from:

- Section headers (Rules:, Requirements:, Workflow:, etc.)
- Bullet points and numbered lists
- Inline imperatives (MUST, NEVER, ALWAYS)
- Code blocks showing structure
- Natural language descriptions

## Exit Codes

- `0`: Fully aligned or only suggestions
- `1`: Warnings present
- `2`: Critical misalignments detected

## Advanced Usage

### Integration with Shell Scripts

```bash
# Check alignment before operations
if /sync; then
    echo "Aligned with project context"
    # Proceed with operations
else
    echo "Misalignment detected, please review"
    exit 1
fi
```

### Continuous Integration

```yaml
# In CI/CD pipeline
- name: Check Project Alignment
  run: |
    /sync || exit 0  # Don't fail CI, just inform
```

## Customization

The sync command is designed to be extended. Key extension points:

1. **Add New Parsers**: Extend `ContextParser` class for custom formats
2. **Custom Checks**: Add methods to `AlignmentChecker` for specific rules
3. **Output Formats**: Modify `format_output` for different display styles
4. **Integration**: Add hooks for IDE or editor integration

## Philosophy

The `/sync` command embodies the principle of "context-aware development". By continuously checking alignment with project context, it helps:

- Prevent mistakes before they happen
- Maintain consistency across teams
- Reduce cognitive load
- Enable faster onboarding
- Ensure compliance with project standards

## Troubleshooting

**No README.md found**: Ensure your project has a README.md file in the root or standard locations.

**Parse errors**: The command handles various formats gracefully, but extremely unusual formats might need custom parsing.

**Performance**: For very large README.md files, parsing is still fast but could be optimized with caching.

## Future Enhancements

Potential improvements for the universal sync command:

1. **Watch Mode**: Continuously monitor for alignment
2. **Auto-Fix**: Automatically correct simple misalignments
3. **Context Caching**: Cache parsed context for performance
4. **Multi-Project**: Handle multiple README.md files in complex projects
5. **IDE Integration**: Direct integration with VS Code, etc.

---

The `/sync` command is your universal guardian for project context alignment. Use it liberally to ensure you're always working in harmony with project requirements.