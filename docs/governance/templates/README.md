# R002 - Template System

This rule ensures all documents follow standardized templates for consistency.

## Rule Summary
All documentation files should reference and follow a template from the library.

## Template Library
All templates are stored in `library/`:
- `T001-template-meta.yaml` - Template for templates
- `T002-project-readme.yaml` - Project README template
- `T003-pattern-doc.yaml` - Pattern documentation
- `T004-rule-template.yaml` - Rule definition template
- `T005-git-commit.yaml` - Commit message template
- `T006-pr-description.yaml` - Pull request template
- `T007-project-tasks.yaml` - Task list template
- `T008-documentation-file.yaml` - General documentation
- `T009-rule-doc.yaml` - Rule documentation
- `T010-project-psd.yaml` - Project specification
- `T011-rule-manifest.yaml` - Rule manifest

## Validation
Run the validation script to check template compliance:
```bash
./validate.sh [project-directory]
```

## Using Templates
1. Choose appropriate template from library/
2. Add template reference in your document:
   ```markdown
   <!-- This file follows template @governance/templates/library/T008 -->
   ```
3. Follow the template structure

## Creating New Templates
1. Use T001 as the meta-template
2. Add to library/
3. Document in this README