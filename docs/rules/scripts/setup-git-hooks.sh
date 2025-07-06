#!/bin/bash
# Setup git hooks for project branch management

set -e

# Get project root
PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

echo "Setting up project git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/.git/hooks"

# Create post-checkout hook
cat > "$PROJECT_ROOT/.git/hooks/post-checkout" << 'EOF'
#!/bin/bash
# Post-checkout hook to update branch context

# Get the project root
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Run the branch context generator
if [ -x "$PROJECT_ROOT/docs/rules/scripts/generate-branch-context.sh" ]; then
    "$PROJECT_ROOT/docs/rules/scripts/generate-branch-context.sh"
fi
EOF

# Create post-merge hook
cat > "$PROJECT_ROOT/.git/hooks/post-merge" << 'EOF'
#!/bin/bash
# Post-merge hook to update branch context

# Get the project root
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Run the branch context generator
if [ -x "$PROJECT_ROOT/docs/rules/scripts/generate-branch-context.sh" ]; then
    "$PROJECT_ROOT/docs/rules/scripts/generate-branch-context.sh"
fi
EOF

# Create pre-commit hook
cat > "$PROJECT_ROOT/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook to prevent direct commits to main branch

# Get current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Check if on main branch
if [ "$BRANCH" = "main" ]; then
    echo "Error: Direct commits to main branch are not allowed!"
    echo "Please create a feature branch:"
    echo "  git checkout -b feature/your-feature-name"
    echo ""
    echo "Or use the safe-edit script:"
    echo "  ./scripts/safe-edit.sh"
    exit 1
fi

# All good, allow commit
exit 0
EOF

# Make hooks executable
chmod +x "$PROJECT_ROOT/.git/hooks/post-checkout"
chmod +x "$PROJECT_ROOT/.git/hooks/post-merge"
chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"

echo "✓ Git hooks installed successfully!"
echo ""
echo "Hooks installed:"
echo "- post-checkout: Updates branch context when switching branches"
echo "- post-merge: Updates branch context after merges"
echo "- pre-commit: Prevents direct commits to main branch"
echo ""
echo "To test the hooks, try switching branches or committing on main."