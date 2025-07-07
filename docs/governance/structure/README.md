# R001 - Project Structure

This rule defines the required fractal structure for all projects.

## Rule Summary
Every project must follow the same minimal structure pattern, enabling infinite nesting while maintaining consistency.

## Required Structure
```
project/
├── README.md          # Entry point (required)
├── docs/              # Documentation (required)
├── .local/            # Local workspace (gitignored)
├── projects/          # Child projects (gitignored)
└── repos/             # External repos (gitignored)
```

## Validation
Run the validation script to check compliance:
```bash
./validate.sh [project-directory]
```

If no directory is specified, it validates the current directory.

## Key Principles
1. **Minimal**: Only two required elements (README.md and docs/)
2. **Fractal**: Same pattern at every level
3. **Flexible**: Three gitignored directories for different purposes
4. **Clean**: No configuration files at root level

## Migration from v5
If you have a `.untracked/` directory, migrate its contents:
- `.untracked/local/` → `.local/`
- `.untracked/repos/` → `repos/`
- Child projects → `projects/`