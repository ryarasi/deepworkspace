#!/bin/bash
# Integration examples for the universal /sync command

# Example 1: Basic usage in a script
echo "=== Example 1: Basic sync check ==="
if ./sync; then
    echo "✅ Context aligned, proceeding with task"
    # Your actual work here
else
    echo "❌ Context misalignment detected"
    exit 1
fi

# Example 2: Pre-commit hook
echo -e "\n=== Example 2: Git pre-commit hook ==="
cat > .git/hooks/pre-commit-sync-example << 'EOF'
#!/bin/bash
# Add to .git/hooks/pre-commit

echo "Checking project context alignment..."
if ! /path/to/sync --quiet; then
    echo "❌ Commit blocked: Project context misalignment detected"
    echo "Run '/sync' for details"
    exit 1
fi
EOF

# Example 3: CI/CD integration
echo -e "\n=== Example 3: GitHub Actions workflow ==="
cat > .github/workflows/sync-check-example.yml << 'EOF'
name: Context Alignment Check
on: [push, pull_request]

jobs:
  sync-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check context alignment
        run: |
          ./content/scripts/sync || {
            echo "::warning::Context misalignment detected"
            exit 0  # Don't fail CI, just warn
          }
EOF

# Example 4: VS Code task
echo -e "\n=== Example 4: VS Code task integration ==="
cat > .vscode/tasks-sync-example.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Check Context Alignment",
      "type": "shell",
      "command": "${workspaceFolder}/content/scripts/sync",
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
EOF

# Example 5: Bash function for continuous checking
echo -e "\n=== Example 5: Bash function for your shell config ==="
cat > sync-shell-function.sh << 'EOF'
# Add to ~/.bashrc or ~/.zshrc

# Quick sync check function
sync-check() {
    local sync_cmd="/path/to/your/sync"
    
    if [ -f "CLAUDE.md" ] || [ -f ".claude/CLAUDE.md" ]; then
        $sync_cmd "$@"
    else
        echo "No CLAUDE.md found in this project"
    fi
}

# Auto-check on directory change (for zsh)
sync-on-cd() {
    cd "$@" && sync-check --quiet
}
alias cd='sync-on-cd'

# Watch mode alias
alias sync-watch='/path/to/sync-advanced.py --watch'
EOF

# Example 6: Python integration
echo -e "\n=== Example 6: Python project integration ==="
cat > sync_integration.py << 'EOF'
#!/usr/bin/env python3
"""Example of integrating sync check into Python projects."""

import subprocess
import sys
from pathlib import Path

def check_context_alignment():
    """Check if current task aligns with project context."""
    sync_script = Path(__file__).parent / "sync.py"
    
    if not sync_script.exists():
        print("Warning: sync script not found")
        return True
    
    result = subprocess.run(
        [sys.executable, str(sync_script)],
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        return True
    elif result.returncode == 1:
        print("⚠️  Context warnings:", result.stdout)
        return True  # Warnings don't block
    else:
        print("❌ Critical context issues:", result.stdout)
        return False

# Use in your code
if __name__ == "__main__":
    if not check_context_alignment():
        print("Please run /sync to see context issues")
        sys.exit(1)
    
    # Your actual code here
    print("Proceeding with aligned context...")
EOF

# Example 7: Makefile integration
echo -e "\n=== Example 7: Makefile integration ==="
cat > Makefile.sync-example << 'EOF'
# Add to your Makefile

.PHONY: sync check-sync

# Manual sync check
sync:
	@./content/scripts/sync

# Pre-build sync check
check-sync:
	@echo "Checking project context alignment..."
	@./content/scripts/sync --quiet || (echo "Run 'make sync' for details" && exit 1)

# Add to your build targets
build: check-sync
	@echo "Building with aligned context..."
	# Your build commands here

test: check-sync
	@echo "Testing with aligned context..."
	# Your test commands here
EOF

# Example 8: Advanced watch mode usage
echo -e "\n=== Example 8: Advanced features ==="
cat > advanced-sync-usage.sh << 'EOF'
#!/bin/bash

# JSON output for programmatic use
./sync-advanced.py --format json | jq '.issues[] | select(.level == "critical")'

# Markdown report for documentation
./sync-advanced.py --format markdown > sync-report.md

# Watch mode with custom interval
./sync-advanced.py --watch --interval 10

# Strict mode for CI/CD
./sync-advanced.py --strict  # Fails on any issue, not just critical

# Cached mode for performance
./sync-advanced.py --cache  # Caches parsed CLAUDE.md
EOF

chmod +x sync_integration.py
chmod +x advanced-sync-usage.sh

echo -e "\n=== Integration examples created ==="
echo "Check the generated files for integration patterns"