#!/bin/bash
# DeepWorkspace Setup Script
# Configures your shell to use dws commands globally

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
info() {
    echo -e "${BLUE}→${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Get the workspace root (parent of content/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "DeepWorkspace Setup"
echo "==================="
echo

# Verify we're in a valid workspace
if [[ ! -f "$WORKSPACE_ROOT/README.md" ]] || [[ ! -d "$WORKSPACE_ROOT/content" ]]; then
    error "This script must be run from a DeepWorkspace installation"
    error "Expected to find workspace at: $WORKSPACE_ROOT"
    exit 1
fi

info "Workspace detected at: $WORKSPACE_ROOT"

# Detect user's shell
if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_TYPE="zsh"
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ -n "$BASH_VERSION" ]]; then
    SHELL_TYPE="bash"
    SHELL_CONFIG="$HOME/.bashrc"
else
    # Try to detect from SHELL variable
    case "$SHELL" in
        */zsh)
            SHELL_TYPE="zsh"
            SHELL_CONFIG="$HOME/.zshrc"
            ;;
        */bash)
            SHELL_TYPE="bash"
            SHELL_CONFIG="$HOME/.bashrc"
            ;;
        *)
            error "Unsupported shell: $SHELL"
            echo "Please manually add the following to your shell configuration:"
            echo
            echo "export PATH=\"\$PATH:$WORKSPACE_ROOT/content/scripts\""
            exit 1
            ;;
    esac
fi

info "Detected shell: $SHELL_TYPE"
info "Config file: $SHELL_CONFIG"

# Create shell config if it doesn't exist
if [[ ! -f "$SHELL_CONFIG" ]]; then
    info "Creating $SHELL_CONFIG"
    touch "$SHELL_CONFIG"
fi

# Check if PATH export already exists
if grep -q "deepworkspace/content/scripts" "$SHELL_CONFIG" 2>/dev/null; then
    warning "PATH already configured for DeepWorkspace"
    PATH_EXISTS=true
else
    PATH_EXISTS=false
fi

# Check if functions already exist
if grep -q "dws-cd()" "$SHELL_CONFIG" 2>/dev/null; then
    FUNCTIONS_EXIST=true
else
    FUNCTIONS_EXIST=false
fi

# If everything already exists, ask about update
if [[ "$PATH_EXISTS" == "true" ]] && [[ "$FUNCTIONS_EXIST" == "true" ]]; then
    echo
    read -p "DeepWorkspace already configured. Update configuration? (y/n) " UPDATE
    if [[ "$UPDATE" != "y" ]]; then
        info "Setup cancelled"
        exit 0
    fi
    
    # Remove old configuration
    info "Removing old configuration..."
    # Create backup
    cp "$SHELL_CONFIG" "$SHELL_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
    
    # Remove old entries (between markers)
    sed -i.tmp '/# BEGIN DEEPWORKSPACE CONFIG/,/# END DEEPWORKSPACE CONFIG/d' "$SHELL_CONFIG"
    rm -f "$SHELL_CONFIG.tmp"
fi

# Add new configuration
info "Adding DeepWorkspace configuration to $SHELL_CONFIG"

cat >> "$SHELL_CONFIG" << EOF

# BEGIN DEEPWORKSPACE CONFIG
# Added by DeepWorkspace setup.sh on $(date +"%Y-%m-%dT%H:%M:%S%z")

# Add dws commands to PATH
export PATH="\$PATH:$WORKSPACE_ROOT/content/scripts"

# Function to change directory and open Claude Desktop
dws-cd() {
    cd "\$1" && claude --dangerously-skip-permissions
}

# Quick project navigation with Claude
dws-start() {
    eval \$(dws start --eval)
}

# END DEEPWORKSPACE CONFIG
EOF

success "Configuration added to $SHELL_CONFIG"

# Test if dws would be available in new shell
export PATH="$PATH:$WORKSPACE_ROOT/content/scripts"
if command -v dws &> /dev/null; then
    success "dws command is now available"
else
    warning "dws command not found - you may need to restart your terminal"
fi

# Final instructions
echo
echo "Setup Complete!"
echo "=============="
echo
echo "To start using dws commands, either:"
echo "1. Reload your shell configuration:"
echo "   ${GREEN}source $SHELL_CONFIG${NC}"
echo
echo "2. Or open a new terminal window"
echo
echo "Available commands:"
echo "  ${BLUE}dws create${NC}    - Create a new project"
echo "  ${BLUE}dws start${NC}     - Navigate to a project and open Claude"
echo "  ${BLUE}dws validate${NC}  - Check projects for rule compliance"
echo "  ${BLUE}dws fix${NC}       - Auto-fix common issues"
echo "  ${BLUE}dws help${NC}      - Show all commands"
echo
echo "Shell functions:"
echo "  ${BLUE}dws-start${NC}     - Quick navigation with Claude integration"
echo "  ${BLUE}dws-cd${NC}        - Change directory and open Claude"
echo

# Offer to source immediately
if [[ -t 0 ]]; then  # Check if interactive
    read -p "Would you like to load the configuration now? (y/n) " LOAD_NOW
    if [[ "$LOAD_NOW" == "y" ]]; then
        echo
        info "Configuration loaded for this session"
        info "Run 'dws help' to get started!"
    fi
fi