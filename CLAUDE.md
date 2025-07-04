# Workspace Context for Claude

<!-- This file follows template @content/templates/T003 -->

<!-- BRANCH CHECK START -->
⚠️ **BRANCH STATUS CHECK**: 
- Current branch: Run `git branch --show-current` to check
- If NOT on main: You're continuing work from a previous session
- Check .untracked/local/BRANCH_REGISTRY.yaml for context
- DO NOT create new branches until current branch is merged
- See R010 for branch lifecycle rules
<!-- BRANCH CHECK END -->

You are in the DeepWorkspace root, which is itself a project following its own rules.

## Quick Orientation

1. **Start Here**: You're reading CLAUDE.md, the AI context entry point
2. **Read Next**: README.md for full workspace overview  
3. **Check Rules**: content/rules/ for all workspace rules
4. **Use Templates**: content/templates/ when creating files
5. **Follow Workflow**: Feature branches for all changes

## Critical Context

This workspace has a **fractal structure** - every project (including this workspace) follows the exact same pattern:
- README.md (human docs)
- CLAUDE.md (AI context) 
- content/ (actual content)
- projects/ (sub-projects, optional)

The workspace IS a project. No exceptions, no special folders.

## Navigation

```
Current Location: /deepworkspace/
├── You are here: CLAUDE.md
├── Human docs: README.md
├── System files: content/
│   ├── Templates: content/templates/T*.yaml
│   ├── Rules: content/rules/R*.yaml
│   ├── Scripts: content/scripts/*.sh
│   └── Temp: content/temp/
└── Projects: projects/*/CLAUDE.md
```

## Workflow Requirements

**CRITICAL**: All changes to files outside content/ MUST follow this workflow:

1. Create feature branch: `git checkout -b feature/description`
2. Make changes in feature branch
3. Commit with template T005 format
4. Create PR with template T006 format
5. Merge and cleanup

Use helper scripts:
- `./content/scripts/safe-edit.sh` - Start new feature
- `./content/scripts/create-pr.sh` - Create PR

## Key Rules to Remember

- **R001**: Every project has README.md, CLAUDE.md, content/
- **R002**: All work happens in content/ folders
- **R003**: Templates guide consistency
- **R004**: Projects can nest infinitely
- **R005**: Workspace follows its own rules
- **R006**: Feature branch workflow required
- **R007**: Commits follow template T005
- **R008**: PRs follow template T006

## Working with Projects

When entering any project:
1. Read its CLAUDE.md first
2. Check for sub-projects in projects/
3. Actual work is always in content/
4. Maintain the same structure

## Current Version

DeepWorkspace v3.0.0 - Minimalist, modular, git-centric

## Remember

- This workspace demonstrates its own rules
- Every project is self-similar
- Templates ensure consistency
- Git captures all context
- Simplicity enables complexity

Now read README.md for the complete picture.