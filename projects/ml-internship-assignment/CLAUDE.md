# ML Internship Assignment Context

<!-- This file follows template @content/templates/T003 -->

You are in the ml-internship-assignment project directory.

## Quick Context

- **Project Type**: code
- **Purpose**: Machine learning internship assignments and technical assessments
- **Status**: active

## Navigation

1. **You are here**: projects/ml-internship-assignment/CLAUDE.md
2. **Read next**: README.md for project details
3. **Work in**: content/ folder
4. **Sub-projects**: projects/ folder (currently none)

## Project-Specific Instructions

When working on ML assignments in this project:
- Prioritize code clarity and documentation
- Include comprehensive comments explaining ML concepts
- Create reproducible notebooks with clear outputs
- Follow best practices for ML experimentation (train/test splits, cross-validation, etc.)
- Document model performance metrics clearly

## Key Commands

```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r content/requirements.txt

# Launch Jupyter for notebooks
jupyter notebook

# Run specific assignment
cd content/assignment_name
python main.py
```

## Important Files

- `content/requirements.txt` - Python dependencies for all assignments
- `content/datasets/` - Local datasets used across assignments
- `content/utils/` - Shared utility functions and helpers
- `content/notebooks/` - Jupyter notebooks for explorations
- Assignment folders will be created as: `content/assignment_[number]_[name]/`

## Sub-Projects

No sub-projects currently.

## Rules & Conventions

This project follows all workspace rules, plus:
- Use descriptive variable names that explain ML concepts
- Follow PEP 8 for Python code style
- Create a README.md for each assignment explaining the problem and approach
- Include performance metrics and visualizations
- Use type hints where appropriate
- Implement proper error handling and input validation

## Current Focus

Initial project setup and structure creation. Next priority is implementing the first assignment with proper documentation and testing framework.

## Remember

- All actual work happens in content/
- Follow workspace git workflow for changes
- Check README.md for human-oriented details
- Keep assignments self-contained and reproducible
- Document assumptions and design choices