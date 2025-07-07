# DeepWork CLI - Project Requirements Prompt (PRP)

## Project Overview

DeepWork CLI (`dws`) is a command-line interface tool that implements the complete DeepWork project management system. It serves as the core engine for managing fractal project structures, handling git operations, and orchestrating LLM-powered workflows.

## Core Requirements

### 1. Architecture Requirements

- **Language**: Rust (for performance, safety, and single-binary distribution)
- **Integration**: Must integrate seamlessly with deepwork-client (Tauri/Rust application)
- **Distribution**: Available as npm package with pre-built binaries
- **Platform Support**: Windows, macOS, Linux

### 2. Workspace Structure

The CLI manages a `.dws` workspace in the user's home directory:

```
~/.dws/
├── config.toml              # Global configuration
├── projects/                # User's root projects
│   ├── {project-slug}/      # Each project follows fractal structure
│   └── ...
└── cache/                   # LLM response cache, temporary files
```

### 3. Authentication & Security

- **GitHub Integration**: OAuth flow for GitHub authentication
- **API Key Storage**: Secure storage using OS keyring for:
  - Anthropic API key
  - Google Gemini API key
  - Azure OpenAI credentials
- **Project Ownership**: Each project has an `author` field (GitHub username)
- **PR-based Approvals**: Parent-child relationships require PR approval

### 4. Command Specifications

#### 4.1 `dws setup`
- Welcome message explaining DeepWork
- Check if first-time setup or existing workspace
- For new users:
  - Prompt for full name
  - Prompt for username (slug)
  - Create ~/.dws directory structure
  - Initialize root project
- For existing users:
  - Scan for valid projects
  - Offer to create new workspace if needed
- Configure API keys and GitHub authentication

#### 4.2 `dws list-projects`
- List all child projects of current project
- Show project hierarchy with indentation
- Display project metadata (name, description, author)

#### 4.3 `dws set-project`
- Interactive project selector
- Change working directory to selected project
- Load project context (hierarchical README files)
- Set environment variables for project rules

#### 4.4 `dws create-child`
- Interactive prompts:
  - Project name (human-readable)
  - Auto-generate slug from name
  - Description
- Create project structure following fractal pattern
- Update parent's README.md to list new child

#### 4.5 `dws set-parent`
- Specify target parent project
- Create PR in parent repository
- PR adds current project as child in parent's README
- No parent reference stored in child project

#### 4.6 `dws create-repo`
- Interactive prompts:
  - Repository name
  - Slug (auto-generated)
  - Description
- Create folder in `repos/` directory
- Initialize git repository
- Add entry to project's README.md

#### 4.7 `dws import-repo`
- Accept git URL as parameter
- Clone repository to `repos/` directory
- Extract metadata from repository
- Add entry to project's README.md

### 5. LLM Integration

The CLI must support workflow orchestration with multiple LLMs:

#### 5.1 Supported Providers
- **Anthropic Claude**: Via API key
- **Google Gemini**: Via API key
- **Azure OpenAI**: Via endpoint + API key

#### 5.2 Workflow Engine
- Define workflows in YAML/TOML format
- Route requests to appropriate LLMs
- Handle response chaining and transformations
- Implement retry logic and error handling
- Cache responses for efficiency

### 6. Context Management

#### 6.1 Hierarchical README System
- Each folder contains README.md describing child folders
- Context loaded incrementally based on navigation
- Minimal context at each level for efficiency

#### 6.2 Project Rules
- Load CLAUDE.md files for AI context
- Apply project-specific rules and constraints
- Environment variable management

### 7. Git Integration

- All operations are git-first
- Automatic commit for structural changes
- Branch management for features
- PR creation and management via GitHub API

### 8. Error Handling

- Graceful error messages
- Rollback capabilities for failed operations
- Detailed logging for debugging
- User-friendly suggestions for common issues

### 9. Performance Requirements

- Sub-second response for local operations
- Efficient file system operations
- Parallel processing where applicable
- Minimal memory footprint

### 10. Future Extensibility

Design with these future features in mind:
- Plugin system for custom commands
- Web UI integration
- Multi-user collaboration
- Advanced LLM orchestration
- Task decomposition engine

## Implementation Priorities

1. **Phase 1**: Core CLI structure and basic commands
2. **Phase 2**: GitHub integration and authentication
3. **Phase 3**: LLM integration and workflow engine
4. **Phase 4**: Advanced features and optimizations

## Success Criteria

- Single binary under 10MB
- All commands complete in <1 second (excluding network calls)
- 100% compatibility with deepwork-client
- Comprehensive error handling
- Cross-platform consistency

## Technical Specifications

### Dependencies
- `clap`: CLI argument parsing
- `tokio`: Async runtime
- `reqwest`: HTTP client for APIs
- `git2`: Git operations
- `keyring`: Secure credential storage
- `serde`: Serialization
- `dialoguer`: Interactive prompts

### API Contracts
- RESTful API design for LLM providers
- GitHub API v3 for repository operations
- Standardized error responses
- JSON for data exchange

### Testing Strategy
- Unit tests for core logic
- Integration tests for commands
- Mock LLM responses for testing
- CI/CD pipeline with cross-platform builds

## Prompt for Implementation

"Build a Rust CLI application called 'dws' that implements a fractal project management system. The CLI should manage projects in a ~/.dws directory, support GitHub authentication, integrate with multiple LLM providers (Anthropic, Gemini, Azure), and provide commands for project creation, repository management, and parent-child relationships. Each project follows a fractal structure with README.md files providing hierarchical context. The CLI must compile to a single binary, integrate with a Tauri application, and be distributable via npm. Implement secure credential storage, PR-based approval workflows, and efficient file operations. Focus on minimalism, performance, and cross-platform compatibility."