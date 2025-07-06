#!/usr/bin/env python3
"""
Universal /sync command for aligning with project context.

This command reads README.md from the current directory (or parent directories)
and evaluates whether the current task/conversation aligns with the project context.
Completely agnostic to any specific workspace system.
"""

import os
import sys
import re
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum


class AlignmentLevel(Enum):
    """Severity levels for misalignment."""
    ALIGNED = "aligned"
    SUGGESTION = "suggestion"
    WARNING = "warning"
    CRITICAL = "critical"


@dataclass
class ProjectContext:
    """Extracted project context from README.md."""
    path: Path
    purpose: str
    rules: List[str]
    workflows: List[str]
    structure: Dict[str, str]
    never_rules: List[str]
    always_rules: List[str]
    technologies: List[str]
    raw_content: str


@dataclass
class AlignmentIssue:
    """Represents a misalignment between task and project context."""
    level: AlignmentLevel
    category: str
    description: str
    suggestion: str
    context_reference: Optional[str] = None


class ContextParser:
    """Parses README.md files to extract project context."""
    
    def __init__(self):
        self.section_patterns = {
            'purpose': re.compile(r'(?:purpose|overview|about|description):', re.I),
            'rules': re.compile(r'(?:rules?|requirements?|constraints?):', re.I),
            'workflow': re.compile(r'(?:workflow|process|procedures?):', re.I),
            'structure': re.compile(r'(?:structure|organization|layout):', re.I),
            'never': re.compile(r'(?:never|don\'t|avoid|prohibited):', re.I),
            'always': re.compile(r'(?:always|must|required|mandatory):', re.I),
            'tech': re.compile(r'(?:tech(?:nolog(?:y|ies))?|stack|tools?):', re.I),
        }
        
    def parse(self, content: str, file_path: Path) -> ProjectContext:
        """Parse README.md content into structured context."""
        lines = content.split('\n')
        
        context = ProjectContext(
            path=file_path,
            purpose="",
            rules=[],
            workflows=[],
            structure={},
            never_rules=[],
            always_rules=[],
            technologies=[],
            raw_content=content
        )
        
        # Extract purpose from first few paragraphs
        context.purpose = self._extract_purpose(lines)
        
        # Extract rules and requirements
        context.rules = self._extract_section_items(content, 'rules')
        context.workflows = self._extract_section_items(content, 'workflow')
        context.never_rules = self._extract_section_items(content, 'never')
        context.always_rules = self._extract_section_items(content, 'always')
        context.technologies = self._extract_section_items(content, 'tech')
        
        # Extract structure from code blocks or lists
        context.structure = self._extract_structure(content)
        
        # Also extract inline rules (lines with MUST, NEVER, ALWAYS in caps)
        context.rules.extend(self._extract_inline_rules(content))
        
        return context
    
    def _extract_purpose(self, lines: List[str]) -> str:
        """Extract project purpose from early content."""
        purpose_lines = []
        for i, line in enumerate(lines[:20]):  # Check first 20 lines
            if line.strip() and not line.startswith('#'):
                purpose_lines.append(line.strip())
            if len(purpose_lines) >= 3:  # Get first few sentences
                break
        return ' '.join(purpose_lines)
    
    def _extract_section_items(self, content: str, section_type: str) -> List[str]:
        """Extract items from a specific section type."""
        pattern = self.section_patterns.get(section_type)
        if not pattern:
            return []
            
        items = []
        lines = content.split('\n')
        in_section = False
        
        for i, line in enumerate(lines):
            if pattern.search(line):
                in_section = True
                continue
                
            if in_section:
                # End section on next header
                if line.strip().startswith('#'):
                    in_section = False
                    continue
                    
                # Extract list items
                if re.match(r'^\s*[-*+•]\s+(.+)', line):
                    item = re.sub(r'^\s*[-*+•]\s+', '', line).strip()
                    if item:
                        items.append(item)
                elif re.match(r'^\s*\d+\.\s+(.+)', line):
                    item = re.sub(r'^\s*\d+\.\s+', '', line).strip()
                    if item:
                        items.append(item)
        
        return items
    
    def _extract_inline_rules(self, content: str) -> List[str]:
        """Extract inline rules containing MUST, NEVER, ALWAYS, etc."""
        rules = []
        
        # Look for lines with strong imperatives
        imperative_pattern = re.compile(
            r'(MUST|NEVER|ALWAYS|REQUIRED|PROHIBITED|CRITICAL)[:]*\s+(.+)',
            re.I
        )
        
        for line in content.split('\n'):
            match = imperative_pattern.search(line)
            if match:
                rules.append(line.strip())
                
        return rules
    
    def _extract_structure(self, content: str) -> Dict[str, str]:
        """Extract project structure from code blocks or tree diagrams."""
        structure = {}
        
        # Look for tree-like structures in code blocks
        code_block_pattern = re.compile(r'```(?:bash|text|tree)?\n(.*?)\n```', re.DOTALL)
        matches = code_block_pattern.findall(content)
        
        for match in matches:
            if '├──' in match or '└──' in match or '|--' in match:
                # Parse tree structure
                lines = match.split('\n')
                for line in lines:
                    # Extract directory names
                    dir_match = re.search(r'[├└|]\s*[-–—]+\s*(\w+)/?', line)
                    if dir_match:
                        dir_name = dir_match.group(1)
                        structure[dir_name] = "directory"
                        
        return structure


class AlignmentChecker:
    """Checks alignment between current task and project context."""
    
    def __init__(self, context: ProjectContext):
        self.context = context
        self.issues: List[AlignmentIssue] = []
        
    def check_current_state(self) -> List[AlignmentIssue]:
        """Check various aspects of current state against project context."""
        self.issues = []
        
        # Check current directory
        self._check_directory_alignment()
        
        # Check git status if in git repo
        self._check_git_workflow()
        
        # Check for rule violations
        self._check_rule_compliance()
        
        # Check file operations
        self._check_file_operations()
        
        return self.issues
    
    def _check_directory_alignment(self):
        """Check if we're in the right directory for the project."""
        cwd = Path.cwd()
        context_dir = self.context.path.parent
        
        # If README.md is in a parent directory, might be okay
        if context_dir not in cwd.parents and context_dir != cwd:
            self.issues.append(AlignmentIssue(
                level=AlignmentLevel.WARNING,
                category="location",
                description=f"Working directory may not align with project root",
                suggestion=f"Consider navigating to {context_dir}"
            ))
    
    def _check_git_workflow(self):
        """Check git workflow compliance."""
        if not (Path.cwd() / '.git').exists():
            return
            
        # Check for workflow rules about branches
        for rule in self.context.always_rules + self.context.workflows:
            if 'feature branch' in rule.lower() or 'branch' in rule.lower():
                # Get current branch
                try:
                    import subprocess
                    result = subprocess.run(
                        ['git', 'branch', '--show-current'],
                        capture_output=True,
                        text=True
                    )
                    current_branch = result.stdout.strip()
                    
                    if current_branch == 'main' or current_branch == 'master':
                        self.issues.append(AlignmentIssue(
                            level=AlignmentLevel.CRITICAL,
                            category="workflow",
                            description="Working directly on main branch",
                            suggestion="Create a feature branch before making changes",
                            context_reference=rule
                        ))
                except:
                    pass
    
    def _check_rule_compliance(self):
        """Check for potential rule violations."""
        # This is where we'd check current task against rules
        # For now, we'll just flag critical rules for awareness
        
        if self.context.never_rules:
            self.issues.append(AlignmentIssue(
                level=AlignmentLevel.SUGGESTION,
                category="rules",
                description="Project has critical NEVER rules",
                suggestion="Review never rules: " + "; ".join(self.context.never_rules[:2])
            ))
    
    def _check_file_operations(self):
        """Check if file operations align with project structure."""
        # Check if there are structure rules
        if self.context.structure:
            if 'content' in self.context.structure:
                self.issues.append(AlignmentIssue(
                    level=AlignmentLevel.SUGGESTION,
                    category="structure",
                    description="Project uses specific directory structure",
                    suggestion="Ensure files are created in appropriate directories"
                ))


class SyncCommand:
    """Main sync command implementation."""
    
    def __init__(self):
        self.parser = ContextParser()
        self.context: Optional[ProjectContext] = None
        
    def find_claude_md(self) -> Optional[Path]:
        """Find README.md file in current or parent directories."""
        current = Path.cwd()
        
        # Check common locations in current directory first
        locations = [
            'README.md',
            'readme.md',
            'Readme.md',
            'docs/README.md',
        ]
        
        for _ in range(6):  # Check up to 5 parent directories
            for loc in locations:
                path = current / loc
                if path.exists() and path.is_file():
                    return path
                    
            # Move to parent directory
            if current.parent == current:
                break
            current = current.parent
            
        return None
    
    def load_context(self, path: Path) -> ProjectContext:
        """Load and parse project context from README.md."""
        try:
            content = path.read_text(encoding='utf-8')
            return self.parser.parse(content, path)
        except Exception as e:
            print(f"Error reading {path}: {e}")
            sys.exit(1)
    
    def analyze_alignment(self) -> List[AlignmentIssue]:
        """Analyze alignment between current state and project context."""
        if not self.context:
            return []
            
        checker = AlignmentChecker(self.context)
        return checker.check_current_state()
    
    def format_output(self, issues: List[AlignmentIssue]) -> str:
        """Format alignment analysis for output."""
        output = []
        
        # Header
        output.append("=" * 60)
        output.append("PROJECT CONTEXT SYNC ANALYSIS")
        output.append("=" * 60)
        output.append("")
        
        # Context summary
        output.append(f"Project: {self.context.path.parent.name}")
        output.append(f"Context: {self.context.path}")
        output.append("")
        
        if self.context.purpose:
            output.append("Purpose:")
            output.append(f"  {self.context.purpose[:200]}...")
            output.append("")
        
        # Alignment status
        if not issues:
            output.append("✅ FULLY ALIGNED - No issues detected")
            output.append("")
            output.append("Current task appears to align with project context.")
        else:
            # Group issues by level
            critical = [i for i in issues if i.level == AlignmentLevel.CRITICAL]
            warnings = [i for i in issues if i.level == AlignmentLevel.WARNING]
            suggestions = [i for i in issues if i.level == AlignmentLevel.SUGGESTION]
            
            if critical:
                output.append("❌ CRITICAL ISSUES:")
                for issue in critical:
                    output.append(f"  - {issue.description}")
                    output.append(f"    → {issue.suggestion}")
                    if issue.context_reference:
                        output.append(f"    Reference: {issue.context_reference}")
                output.append("")
                
            if warnings:
                output.append("⚠️  WARNINGS:")
                for issue in warnings:
                    output.append(f"  - {issue.description}")
                    output.append(f"    → {issue.suggestion}")
                output.append("")
                
            if suggestions:
                output.append("💡 SUGGESTIONS:")
                for issue in suggestions:
                    output.append(f"  - {issue.description}")
                    output.append(f"    → {issue.suggestion}")
                output.append("")
        
        # Key rules reminder
        if self.context.always_rules or self.context.never_rules:
            output.append("-" * 40)
            output.append("KEY RULES TO REMEMBER:")
            
            if self.context.always_rules[:3]:
                output.append("\nALWAYS:")
                for rule in self.context.always_rules[:3]:
                    output.append(f"  • {rule}")
                    
            if self.context.never_rules[:3]:
                output.append("\nNEVER:")
                for rule in self.context.never_rules[:3]:
                    output.append(f"  • {rule}")
        
        output.append("")
        output.append("=" * 60)
        
        # Add trigger for strategic thinking if critical issues
        if any(i.level == AlignmentLevel.CRITICAL for i in issues):
            output.append("")
            output.append("🤔 STRATEGIC RECALIBRATION NEEDED")
            output.append("Critical misalignments detected. Ultrathinking recommended to:")
            output.append("  1. Understand the project's actual requirements")
            output.append("  2. Identify why the current approach diverged")
            output.append("  3. Develop a corrective strategy")
            output.append("  4. Ensure future alignment with project context")
        
        return "\n".join(output)
    
    def run(self):
        """Main command execution."""
        # Find CLAUDE.md
        claude_path = self.find_claude_md()
        
        if not claude_path:
            print("❌ No CLAUDE.md found in current or parent directories")
            print("This command requires a CLAUDE.md file to understand project context.")
            sys.exit(1)
        
        # Load context
        self.context = self.load_context(claude_path)
        
        # Analyze alignment
        issues = self.analyze_alignment()
        
        # Output results
        print(self.format_output(issues))
        
        # Return appropriate exit code
        if any(i.level == AlignmentLevel.CRITICAL for i in issues):
            sys.exit(2)  # Critical misalignment
        elif any(i.level == AlignmentLevel.WARNING for i in issues):
            sys.exit(1)  # Warnings present
        else:
            sys.exit(0)  # Aligned or only suggestions


if __name__ == "__main__":
    command = SyncCommand()
    command.run()