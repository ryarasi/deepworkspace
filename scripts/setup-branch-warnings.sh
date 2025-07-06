#!/bin/bash
# Setup script for dynamic branch warning system
# Run this after cloning the repository to enable branch warnings

set -e

WORKSPACE_ROOT=$(git rev-parse --show-toplevel)
HOOK_FILE="$WORKSPACE_ROOT/.git/hooks/post-checkout"

echo "Setting up dynamic branch warning system..."

# Create post-checkout hook
cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Post-checkout hook to generate branch-specific Claude context
# Part of DeepWorkspace dynamic branch warning system

# Get the workspace root (where .git is located)
WORKSPACE_ROOT=$(git rev-parse --show-toplevel)

# Run the branch context generator if it exists
GENERATOR_SCRIPT="$WORKSPACE_ROOT/content/scripts/generate-branch-context.sh"

if [ -f "$GENERATOR_SCRIPT" ]; then
    # Only generate context for branch checkouts (not file checkouts)
    # $3 is 1 for branch checkout, 0 for file checkout
    if [ "$3" = "1" ]; then
        "$GENERATOR_SCRIPT"
    fi
fi

exit 0
EOF

# Make hook executable
chmod +x "$HOOK_FILE"

# Run the generator for current branch
"$WORKSPACE_ROOT/content/scripts/generate-branch-context.sh"

echo "✅ Branch warning system setup complete!"
echo "Branch context will be automatically generated when switching branches."