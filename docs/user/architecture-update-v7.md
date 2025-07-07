# DeepWork Architecture Update v7.0.0

## Overview

This document proposes architecture updates for DeepWork v7.0.0 to support the new .dws workspace convention and remove parent references from child projects.

## Key Changes

### 1. Workspace Convention

**Current (v6.0.0)**:
- Projects exist anywhere in the filesystem
- No centralized workspace concept
- Parent-child relationships stored bidirectionally

**Proposed (v7.0.0)**:
- Centralized workspace at `~/.dws/`
- All user projects under `~/.dws/projects/`
- Workspace-level configuration and caching

### 2. Parent-Child Relationships

**Current**:
- Child projects store parent reference in metadata
- Parent projects list children in README
- Bidirectional references create maintenance issues

**Proposed**:
- Only parents reference children
- Children have no knowledge of parents
- PR-based approval for adding children to parents

### 3. Template Updates

#### T002-project-readme.yaml Changes

Remove from metadata:
```yaml
- **Parent**: [parent-slug or 'root']
```

Add new section:
```yaml
## Projects

Child projects:
- **[child-slug]**: [Brief description]

## Repositories

External repositories:
- **[repo-slug]**: [Brief description]
```

### 4. CLI Integration

The new deepwork-cli will:
- Manage the ~/.dws workspace
- Handle parent-child relationships via PRs
- Provide project discovery without parent references
- Support hierarchical context loading

### 5. Migration Path

For existing projects:
1. Remove "Parent" field from README metadata
2. Ensure parent projects list all children
3. Move projects to ~/.dws/projects/ structure
4. Update .gitignore patterns

## Benefits

1. **Cleaner Architecture**: Unidirectional references are easier to maintain
2. **Better Portability**: Child projects can be moved without updating references
3. **Centralized Management**: ~/.dws provides a single point of control
4. **PR-Based Workflow**: Clear approval process for parent-child relationships

## Implementation Steps

1. Update T002 template to remove parent references
2. Create migration script for existing projects
3. Update validation scripts to check new structure
4. Document the new architecture in governance
5. Release deepwork-cli with new conventions

## Compatibility

- Backward compatible with v6.0.0 structure
- Migration tools provided for existing projects
- Grace period for updating templates

## Timeline

- Phase 1: Template updates (immediate)
- Phase 2: CLI release (1 week)
- Phase 3: Migration tools (2 weeks)
- Phase 4: Full v7.0.0 release (3 weeks)