#!/bin/bash
# DWS Create Command - Create new projects in the workspace

# Get workspace root
WORKSPACE_ROOT="$(get_workspace_root)" || exit 1

echo "Creating new code project..."
echo

# Interactive prompts
# 1. Project name
while true; do
    read -p "Project name: " PROJECT_NAME
    if validate_project_name "$PROJECT_NAME"; then
        break
    fi
done

# 2. Parent project (optional)
read -p "Parent project (leave empty for root): " PARENT_PROJECT

# Determine project path
if [[ -n "$PARENT_PROJECT" ]]; then
    PROJECT_PATH="projects/$PARENT_PROJECT/projects/$PROJECT_NAME"
    
    # Validate parent project exists
    if ! project_exists "$WORKSPACE_ROOT" "projects/$PARENT_PROJECT"; then
        error "Parent project '$PARENT_PROJECT' does not exist"
        exit 1
    fi
else
    PROJECT_PATH="projects/$PROJECT_NAME"
fi

# Check if project already exists
if project_exists "$WORKSPACE_ROOT" "$PROJECT_PATH"; then
    error "Project '$PROJECT_NAME' already exists at $PROJECT_PATH"
    exit 1
fi

# 3. Purpose
read -p "Purpose: " PURPOSE

# Create project structure
info "Creating project structure..."

# Create directories
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/content"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/projects"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/.claude"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/.untracked/repos"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/.untracked/local"

# Load templates
README_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T002-project-readme.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
CLAUDE_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T003-project-claude.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
TASKS_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T007-project-tasks.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
CONTENT_README_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T009-content-readme.yaml" | sed -n '/^template: |/,/^[a-z]/p' | sed '1d;$d')

# Replace placeholders and create files
replace_placeholders "$README_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/README.md"

replace_placeholders "$CLAUDE_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/CLAUDE.md"

replace_placeholders "$TASKS_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/.untracked/TASKS.md"

replace_placeholders "$CONTENT_README_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/content/README.md"

# Create project .gitignore
cat > "$WORKSPACE_ROOT/$PROJECT_PATH/.gitignore" << 'EOF'
# Untracked items
.untracked/

# Claude Desktop settings (local to each developer)
**/.claude/settings.local.json

# Temporary files in content
content/temp/*
!content/temp/.gitkeep

# Build artifacts
dist/
build/
*.o
*.so
*.dll
*.exe

# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# Archive extraction
*.tar.gz.tmp
*.zip.tmp

# System files
.DS_Store
*.swp
*.swo
*~

# IDE files
.idea/
.vscode/
*.code-workspace

# Log files
*.log

# Temporary files
*.tmp
*.temp
EOF

# Initialize git repository
info "Initializing git repository..."
cd "$WORKSPACE_ROOT/$PROJECT_PATH"

# Initialize git and make initial commit
git init
git add README.md CLAUDE.md .gitignore content/README.md
git commit -m "Initial project structure

- Created standard DeepWorkspace project structure
- Added content/README.md for content documentation
- Added .untracked/ directory for untracked items
- Content is tracked by default
- Ready for remote push and PR workflow"

cd - > /dev/null

# Success messages
success "Created project structure at $PROJECT_PATH/"
success "Created content/README.md for content documentation"
success "Created .untracked/ directory with TASKS.md"
success "Initialized git repository"

echo
echo "IMPORTANT: Next steps:"
echo "1. cd $WORKSPACE_ROOT/$PROJECT_PATH"
echo "2. Create GitHub repo: gh repo create $PROJECT_NAME --public"
echo "3. Push to remote: git push -u origin main"
echo "4. Then make all changes via feature branches"
echo
info "Remember: All code goes in the content/ folder"
info "External repos go in .untracked/repos/ (gitignored)"
info "Tasks are tracked in .untracked/TASKS.md (not in git)"
info "Sub-projects can be created in the projects/ folder"