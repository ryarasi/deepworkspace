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