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

# 4. Track content in git (default: n)
read -p "Track content in git? (y/n) [n]: " TRACK_CONTENT
TRACK_CONTENT=${TRACK_CONTENT:-n}

# Create project structure
info "Creating project structure..."

# Create directories
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/content"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/projects"
mkdir -p "$WORKSPACE_ROOT/$PROJECT_PATH/.claude"

# Load templates
README_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T002-project-readme.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
CLAUDE_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T003-project-claude.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
TASKS_TEMPLATE=$(cat "$WORKSPACE_ROOT/content/templates/T007-project-tasks.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')

# Replace placeholders and create files
replace_placeholders "$README_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" "$TRACK_CONTENT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/README.md"

replace_placeholders "$CLAUDE_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" "$TRACK_CONTENT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/CLAUDE.md"

replace_placeholders "$TASKS_TEMPLATE" "$PROJECT_NAME" "code" "$PURPOSE" "$PARENT_PROJECT" "$TRACK_CONTENT" \
    > "$WORKSPACE_ROOT/$PROJECT_PATH/content/TASKS.md"

# Initialize git repository
info "Initializing git repository..."
cd "$WORKSPACE_ROOT/$PROJECT_PATH"

# Create project .gitignore if tracking is disabled
if [[ "$TRACK_CONTENT" == "n" ]]; then
    echo "# Project content (not tracked in git)" > .gitignore
    echo "content/" >> .gitignore
fi

# Initialize git and make initial commit
git init
git add README.md CLAUDE.md
if [[ -f .gitignore ]]; then
    git add .gitignore
fi
git commit -m "Initial project structure

- Created standard DeepWorkspace project structure
- Ready for remote push and PR workflow"

cd - > /dev/null

# Success messages
success "Created project structure at $PROJECT_PATH/"
success "Created TASKS.md with starter tasks"
success "Initialized git repository"

echo
echo "IMPORTANT: Next steps:"
echo "1. cd $WORKSPACE_ROOT/$PROJECT_PATH"
echo "2. Create GitHub repo: gh repo create $PROJECT_NAME --public"
echo "3. Push to remote: git push -u origin main"
echo "4. Then make all changes via feature branches"
echo
info "Remember: All code goes in the content/ folder"
info "Sub-projects can be created in the projects/ folder"
if [[ "$TRACK_CONTENT" == "y" ]]; then
    info "Content tracking enabled - content/ will be committed to git"
else
    info "Content tracking disabled - content/ is gitignored"
fi