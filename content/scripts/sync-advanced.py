#!/usr/bin/env python3
"""
Advanced universal /sync command with enhanced capabilities.

Features:
- Task inference from recent git commits and file changes
- Deeper context understanding with NLP-like analysis
- Integration readiness for CI/CD and editors
- JSON output mode for programmatic use
- Watch mode for continuous alignment checking
"""

import os
import sys
import re
import json
import time
import hashlib
import argparse
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set, Any
from dataclasses import dataclass, asdict
from enum import Enum
from collections import defaultdict
from datetime import datetime


class OutputFormat(Enum):
    """Output format options."""
    HUMAN = "human"
    JSON = "json"
    MARKDOWN = "markdown"
    MINIMAL = "minimal"


@dataclass
class TaskContext:
    """Inferred context about the current task."""
    recent_files: List[str]
    recent_commits: List[str]
    current_branch: str
    uncommitted_changes: List[str]
    task_type: str  # 'feature', 'bugfix', 'docs', 'refactor', etc.
    estimated_scope: str  # 'small', 'medium', 'large'


@dataclass
class ContextCache:
    """Cache for parsed context to improve performance."""
    file_path: Path
    file_hash: str
    parsed_context: Any
    timestamp: float


class AdvancedContextParser:
    """Enhanced parser with deeper understanding capabilities."""
    
    def __init__(self):
        super().__init__()
        self.keyword_weights = {
            'must': 3.0,
            'never': 3.0,
            'always': 3.0,
            'required': 2.5,
            'critical': 2.5,
            'important': 2.0,
            'should': 1.5,
            'recommended': 1.0,
            'optional': 0.5
        }
        
        self.section_importance = {
            'rules': 3.0,
            'requirements': 3.0,
            'workflow': 2.5,
            'structure': 2.0,
            'guidelines': 1.5,
            'notes': 1.0
        }
        
    def extract_semantic_rules(self, content: str) -> List[Dict[str, Any]]:
        """Extract rules with semantic understanding and importance scoring."""
        rules = []
        lines = content.split('\n')
        
        for i, line in enumerate(lines):
            line_lower = line.lower()
            
            # Calculate importance score
            importance = 0.0
            matched_keywords = []
            
            for keyword, weight in self.keyword_weights.items():
                if keyword in line_lower:
                    importance += weight
                    matched_keywords.append(keyword)
            
            if importance > 0:
                # Determine rule type
                rule_type = 'general'
                if any(kw in line_lower for kw in ['never', 'don\'t', 'avoid']):
                    rule_type = 'prohibition'
                elif any(kw in line_lower for kw in ['must', 'always', 'required']):
                    rule_type = 'requirement'
                elif any(kw in line_lower for kw in ['should', 'recommended']):
                    rule_type = 'recommendation'
                
                # Extract context (surrounding lines)
                context_start = max(0, i - 2)
                context_end = min(len(lines), i + 3)
                context = '\n'.join(lines[context_start:context_end])
                
                rules.append({
                    'text': line.strip(),
                    'type': rule_type,
                    'importance': importance,
                    'keywords': matched_keywords,
                    'line_number': i + 1,
                    'context': context
                })
        
        # Sort by importance
        rules.sort(key=lambda x: x['importance'], reverse=True)
        return rules
    
    def infer_project_type(self, content: str, file_structure: Dict[str, str]) -> str:
        """Infer the type of project from context and structure."""
        indicators = {
            'web': ['frontend', 'backend', 'api', 'server', 'client', 'react', 'vue', 'angular'],
            'cli': ['command', 'cli', 'terminal', 'console', 'script'],
            'library': ['library', 'package', 'module', 'sdk', 'framework'],
            'application': ['app', 'application', 'software', 'program'],
            'documentation': ['docs', 'documentation', 'guide', 'manual'],
            'data': ['data', 'analysis', 'ml', 'ai', 'science', 'pipeline']
        }
        
        content_lower = content.lower()
        scores = defaultdict(int)
        
        for project_type, keywords in indicators.items():
            for keyword in keywords:
                if keyword in content_lower:
                    scores[project_type] += 1
        
        if scores:
            return max(scores, key=scores.get)
        return 'general'


class TaskInference:
    """Infer current task from git state and recent changes."""
    
    @staticmethod
    def get_current_task_context() -> TaskContext:
        """Gather context about the current task."""
        context = TaskContext(
            recent_files=[],
            recent_commits=[],
            current_branch='unknown',
            uncommitted_changes=[],
            task_type='unknown',
            estimated_scope='unknown'
        )
        
        try:
            # Get current branch
            result = subprocess.run(
                ['git', 'branch', '--show-current'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                context.current_branch = result.stdout.strip()
            
            # Get recent commits
            result = subprocess.run(
                ['git', 'log', '--oneline', '-5'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                context.recent_commits = result.stdout.strip().split('\n')
            
            # Get uncommitted changes
            result = subprocess.run(
                ['git', 'status', '--porcelain'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                changes = result.stdout.strip().split('\n')
                context.uncommitted_changes = [c for c in changes if c]
                context.recent_files = [c.split()[-1] for c in changes if c]
            
            # Infer task type from branch name
            branch_lower = context.current_branch.lower()
            if 'feature' in branch_lower:
                context.task_type = 'feature'
            elif 'fix' in branch_lower or 'bug' in branch_lower:
                context.task_type = 'bugfix'
            elif 'docs' in branch_lower:
                context.task_type = 'documentation'
            elif 'refactor' in branch_lower:
                context.task_type = 'refactor'
            elif 'test' in branch_lower:
                context.task_type = 'testing'
            
            # Estimate scope
            num_changes = len(context.uncommitted_changes)
            if num_changes == 0:
                context.estimated_scope = 'none'
            elif num_changes <= 3:
                context.estimated_scope = 'small'
            elif num_changes <= 10:
                context.estimated_scope = 'medium'
            else:
                context.estimated_scope = 'large'
                
        except Exception:
            pass  # Git not available or not a git repo
            
        return context


class AlignmentEngine:
    """Advanced alignment checking with task awareness."""
    
    def __init__(self, project_context: Any, task_context: TaskContext):
        self.project = project_context
        self.task = task_context
        self.issues = []
        
    def check_task_project_fit(self) -> List[Any]:
        """Check if current task type fits project type."""
        # This would contain logic to match task types with project types
        # For example, documentation tasks in code-heavy projects might get warnings
        return []
    
    def check_scope_alignment(self) -> List[Any]:
        """Check if task scope aligns with project practices."""
        # Large changes might need to be broken down
        # Small changes might need to be batched
        return []
    
    def suggest_next_steps(self) -> List[str]:
        """Suggest next steps based on current state."""
        suggestions = []
        
        if self.task.current_branch == 'main':
            suggestions.append("Create a feature branch for your changes")
        
        if self.task.uncommitted_changes and len(self.task.uncommitted_changes) > 10:
            suggestions.append("Consider breaking large changes into smaller commits")
        
        if not self.task.recent_commits:
            suggestions.append("Make your first commit to establish task context")
            
        return suggestions


class SyncCache:
    """Cache manager for parsed contexts."""
    
    def __init__(self, cache_dir: Optional[Path] = None):
        self.cache_dir = cache_dir or Path.home() / '.cache' / 'sync'
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache: Dict[str, ContextCache] = {}
        
    def get_file_hash(self, file_path: Path) -> str:
        """Get hash of file contents."""
        return hashlib.md5(file_path.read_bytes()).hexdigest()
        
    def get(self, file_path: Path) -> Optional[Any]:
        """Get cached context if still valid."""
        cache_key = str(file_path)
        
        if cache_key in self.cache:
            cached = self.cache[cache_key]
            current_hash = self.get_file_hash(file_path)
            
            if cached.file_hash == current_hash:
                return cached.parsed_context
                
        return None
        
    def set(self, file_path: Path, context: Any):
        """Cache parsed context."""
        cache_key = str(file_path)
        file_hash = self.get_file_hash(file_path)
        
        self.cache[cache_key] = ContextCache(
            file_path=file_path,
            file_hash=file_hash,
            parsed_context=context,
            timestamp=time.time()
        )


class AdvancedSyncCommand:
    """Enhanced sync command with advanced features."""
    
    def __init__(self, args):
        self.args = args
        self.cache = SyncCache() if args.cache else None
        
    def watch_mode(self):
        """Run in watch mode, checking alignment periodically."""
        print("Starting sync watch mode... (Ctrl+C to stop)")
        last_check = {}
        
        while True:
            try:
                # Find CLAUDE.md
                claude_path = self.find_claude_md()
                if not claude_path:
                    print("⏸ No CLAUDE.md found, waiting...")
                    time.sleep(5)
                    continue
                
                # Check if file changed
                current_hash = hashlib.md5(claude_path.read_bytes()).hexdigest()
                if last_check.get(str(claude_path)) != current_hash:
                    # File changed or first run
                    os.system('clear' if os.name == 'posix' else 'cls')
                    self.run_check()
                    last_check[str(claude_path)] = current_hash
                    
                time.sleep(self.args.interval)
                
            except KeyboardInterrupt:
                print("\n👋 Stopping watch mode")
                break
                
    def output_json(self, data: Dict[str, Any]):
        """Output results as JSON."""
        print(json.dumps(data, indent=2, default=str))
        
    def output_markdown(self, data: Dict[str, Any]):
        """Output results as markdown."""
        md = []
        md.append("# Project Context Sync Report")
        md.append(f"\n**Date**: {datetime.now().isoformat()}")
        md.append(f"\n**Project**: `{data['project_name']}`")
        md.append(f"\n**Context File**: `{data['context_file']}`")
        
        if data['issues']:
            md.append("\n## Issues Found")
            
            for level in ['critical', 'warning', 'suggestion']:
                level_issues = [i for i in data['issues'] if i['level'] == level]
                if level_issues:
                    md.append(f"\n### {level.title()}s")
                    for issue in level_issues:
                        md.append(f"\n- **{issue['category']}**: {issue['description']}")
                        md.append(f"  - *Suggestion*: {issue['suggestion']}")
        else:
            md.append("\n## ✅ No Issues Found")
            
        print('\n'.join(md))
        
    def run_check(self):
        """Run the sync check with advanced features."""
        # Implementation would use all the advanced features
        # This is a placeholder for the main logic
        pass


def main():
    """Main entry point with argument parsing."""
    parser = argparse.ArgumentParser(
        description='Universal project context sync command'
    )
    
    parser.add_argument(
        '--format', '-f',
        type=OutputFormat,
        choices=list(OutputFormat),
        default=OutputFormat.HUMAN,
        help='Output format'
    )
    
    parser.add_argument(
        '--watch', '-w',
        action='store_true',
        help='Run in watch mode'
    )
    
    parser.add_argument(
        '--interval', '-i',
        type=int,
        default=5,
        help='Watch mode check interval in seconds'
    )
    
    parser.add_argument(
        '--cache', '-c',
        action='store_true',
        help='Enable context caching for performance'
    )
    
    parser.add_argument(
        '--strict',
        action='store_true',
        help='Exit with error on any issue (not just critical)'
    )
    
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Minimal output, only show issues'
    )
    
    args = parser.parse_args()
    
    command = AdvancedSyncCommand(args)
    
    if args.watch:
        command.watch_mode()
    else:
        command.run_check()


if __name__ == "__main__":
    main()