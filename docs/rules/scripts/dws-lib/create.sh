#!/bin/bash
# DWS Create Command - Create new projects in the workspace

# Get project root
PROJECT_ROOT="$(get_project_root)" || exit 1

# Check and warn if on main branch (context-specific warning)
if git rev-parse --git-dir > /dev/null 2>&1; then
    current_branch=$(git branch --show-current 2>/dev/null)
    if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        echo -e "\033[1;33m⚠️  Note: You're creating a project while on main branch.\033[0m" >&2
        echo -e "\033[1;33mRemember to create a feature branch before making changes to existing files.\033[0m" >&2
        echo >&2
    fi
fi

echo "Creating new project..."
echo

# Interactive prompts
# 1. Project name (human-readable)
read -p "Project name: " PROJECT_NAME

# Generate slug from name
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')

echo "Generated slug: $PROJECT_SLUG"
echo

# 2. Parent project (optional)
read -p "Parent project slug (leave empty for root): " PARENT_PROJECT

# Determine project path
if [[ -n "$PARENT_PROJECT" ]]; then
    PROJECT_PATH="projects/$PARENT_PROJECT/projects/$PROJECT_SLUG"
    
    # Validate parent project exists
    if ! project_exists "$PROJECT_ROOT" "projects/$PARENT_PROJECT"; then
        error "Parent project '$PARENT_PROJECT' does not exist"
        exit 1
    fi
else
    PROJECT_PATH="projects/$PROJECT_SLUG"
fi

# Check if project already exists
if project_exists "$PROJECT_ROOT" "$PROJECT_PATH"; then
    error "Project with slug '$PROJECT_SLUG' already exists at $PROJECT_PATH"
    exit 1
fi

# 3. Project type
echo
echo "Project type:"
echo "1) person - Projects about individuals"
echo "2) group - Projects about collections"
echo "3) entity - Projects about organizations"
echo "4) product - Projects creating deliverables"
echo "5) research - Investigation projects"
echo "6) learning - Educational projects"
read -p "Select type [1-6]: " TYPE_CHOICE

case $TYPE_CHOICE in
    1) PROJECT_TYPE="person" ;;
    2) PROJECT_TYPE="group" ;;
    3) PROJECT_TYPE="entity" ;;
    4) PROJECT_TYPE="product" ;;
    5) PROJECT_TYPE="research" ;;
    6) PROJECT_TYPE="learning" ;;
    *) error "Invalid choice"; exit 1 ;;
esac

# 4. Project subtype based on type
echo
case $PROJECT_TYPE in
    person)
        echo "Person subtype:"
        echo "1) human"
        echo "2) animal"
        read -p "Select subtype [1-2]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="human" ;;
            2) PROJECT_SUBTYPE="animal" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
    group)
        echo "Group subtype:"
        echo "1) people"
        echo "2) entity"
        read -p "Select subtype [1-2]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="people" ;;
            2) PROJECT_SUBTYPE="entity" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
    entity)
        echo "Entity subtype:"
        echo "1) company"
        echo "2) government"
        echo "3) organization"
        echo "4) community"
        read -p "Select subtype [1-4]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="company" ;;
            2) PROJECT_SUBTYPE="government" ;;
            3) PROJECT_SUBTYPE="organization" ;;
            4) PROJECT_SUBTYPE="community" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
    product)
        echo "Product subtype:"
        echo "1) software"
        echo "2) writing"
        echo "3) multimedia"
        echo "4) hardware"
        read -p "Select subtype [1-4]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="software" ;;
            2) PROJECT_SUBTYPE="writing" ;;
            3) PROJECT_SUBTYPE="multimedia" ;;
            4) PROJECT_SUBTYPE="hardware" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
    research)
        echo "Research subtype:"
        echo "1) project"
        echo "2) topic"
        read -p "Select subtype [1-2]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="project" ;;
            2) PROJECT_SUBTYPE="topic" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
    learning)
        echo "Learning subtype:"
        echo "1) topic"
        echo "2) skill"
        read -p "Select subtype [1-2]: " SUBTYPE_CHOICE
        case $SUBTYPE_CHOICE in
            1) PROJECT_SUBTYPE="topic" ;;
            2) PROJECT_SUBTYPE="skill" ;;
            *) error "Invalid choice"; exit 1 ;;
        esac
        ;;
esac

# 5. Project URL (optional)
echo
read -p "Project URL (optional, press Enter to skip): " PROJECT_URL

# 6. Purpose
echo
read -p "Purpose: " PURPOSE

# Create project structure
info "Creating project structure..."

# Create directories
mkdir -p "$PROJECT_ROOT/$PROJECT_PATH/docs"
mkdir -p "$PROJECT_ROOT/$PROJECT_PATH/.untracked/repos"
mkdir -p "$PROJECT_ROOT/$PROJECT_PATH/.untracked/local"

# Copy rules directory to new project
info "Copying governance system..."
cp -r "$PROJECT_ROOT/docs/rules" "$PROJECT_ROOT/$PROJECT_PATH/docs/"

# Create RULES.md entry point
cat > "$PROJECT_ROOT/$PROJECT_PATH/docs/RULES.md" << 'EOF'
# Project Rules

This project follows a self-contained rule system that governs its structure, organization, and validation.

## Rule System

All contents of this project must comply with the rules specified in the `docs/rules/` directory. These rules are:

1. **Immutable Core Rules (R001-R006)**: Fundamental rules that define project structure and governance
2. **Extension Rules (R007+)**: Project-specific rules that extend but cannot override core rules

## Entry Point

Start with [R001 - Project Structure](rules/R001-project-structure.yaml), which defines the required structure for this project. Each rule references the next in sequence, creating a complete chain of governance.

## Self-Contained Governance

The `docs/rules/` directory contains everything needed to understand and enforce project governance:

- **rules/*.yaml** - The rule definitions themselves
- **templates/** - Templates referenced by the rules
- **scripts/** - Scripts that validate and enforce the rules

This makes the project fully portable - the entire governance model travels with the project.

## Validation

To validate this project against its rules, run:

```bash
docs/rules/scripts/validate
```

## Rule Chain

The rules form a dependency chain:

```
R001 (Structure) → R002 (Templates) → R003 (Self-Demo) → R004 (References) → R005 (Root Files) → R006 (Scripts)
```

Each rule builds upon the previous ones, creating a complete governance framework.
EOF

# Load templates
README_TEMPLATE=$(cat "$PROJECT_ROOT/docs/rules/templates/T002-project-readme.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
TASKS_TEMPLATE=$(cat "$PROJECT_ROOT/docs/rules/templates/T007-project-tasks.yaml" | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d')
PSD_TEMPLATE=$(cat "$PROJECT_ROOT/docs/rules/templates/T010-project-psd.yaml" 2>/dev/null | sed -n '/^content: |/,/^[a-z]/p' | sed '1d;$d' || echo "# $PROJECT_NAME Project Specification Document")

# Get timestamps
CREATED_DATE="$(date +%Y-%m-%dT%H:%M:%S%z)"
MODIFIED_DATE="$CREATED_DATE"

# Replace placeholders and create files
echo "$README_TEMPLATE" | sed \
    -e "s/\[Project Name\]/$PROJECT_NAME/g" \
    -e "s/\[project-slug\]/$PROJECT_SLUG/g" \
    -e "s/\[parent-slug or 'root'\]/${PARENT_PROJECT:-root}/g" \
    -e "s/\[person|group|entity|product|research|learning\]/$PROJECT_TYPE/g" \
    -e "s/\[type-specific-subtype\]/$PROJECT_SUBTYPE/g" \
    -e "s|\[https://example.com/project-link\]|${PROJECT_URL:-}|g" \
    -e "s/\[YYYY-MM-DDTHH:MM:SS+ZZZZ\]/$CREATED_DATE/g" \
    -e "s/\[active|paused|archived\]/active/g" \
    -e "s/\[One paragraph explaining what this project is and why it exists\]/$PURPOSE/g" \
    > "$PROJECT_ROOT/$PROJECT_PATH/README.md"

echo "$TASKS_TEMPLATE" | sed \
    -e "s/\[Project Name\]/$PROJECT_NAME/g" \
    -e "s/\[YYYY-MM-DD\]/$CREATED_DATE/g" \
    > "$PROJECT_ROOT/$PROJECT_PATH/.untracked/local/TASKS.md"

# Create PSD.md
echo "$PSD_TEMPLATE" | sed \
    -e "s/\[Project Name\]/$PROJECT_NAME/g" \
    -e "s/\[YYYY-MM-DD\]/$(date +%Y-%m-%d)/g" \
    -e "s/\[project purpose\]/$PURPOSE/g" \
    > "$PROJECT_ROOT/$PROJECT_PATH/docs/PSD.md"

# Create project .gitignore
cat > "$PROJECT_ROOT/$PROJECT_PATH/.gitignore" << 'EOF'
# Untracked items
.untracked/

# Claude Desktop settings (entire directory)
.claude/

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
cd "$PROJECT_ROOT/$PROJECT_PATH"

# Initialize git and make initial commit
git init
git add README.md .gitignore docs/
git commit -m "Initial project structure

- Created project with embedded governance system
- Added docs/rules/ with complete rule system
- Added .untracked/ directory for local workspace
- Ready for remote push and PR workflow"

cd - > /dev/null

# Success messages
success "Created project structure at $PROJECT_PATH/"
success "Created .untracked/ directory with TASKS.md"
success "Initialized git repository"

echo
echo "IMPORTANT: Next steps:"
echo "1. cd $PROJECT_ROOT/$PROJECT_PATH"
echo "2. Create GitHub repo: gh repo create $PROJECT_NAME --public"
echo "3. Push to remote: git push -u origin main"
echo "4. Then make all changes via feature branches"
echo
info "Remember: Project governance is in docs/rules/"
info "Child projects go in .untracked/repos/ (gitignored)"
info "Tasks are tracked in .untracked/local/TASKS.md"
info "Run 'docs/rules/scripts/validate' to check compliance"