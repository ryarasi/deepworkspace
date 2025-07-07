# Pattern: Pull Request Documentation

## When to Use

This pattern is recommended when:
- You want to preserve the full context of changes for future reference
- Your team needs to understand the reasoning behind implementations
- You're working with AI agents that need historical context
- Code reviews require comprehensive information
- You want to maintain a professional development process

## Pattern Overview

The Pull Request Documentation pattern establishes a comprehensive approach to documenting changes through pull requests. PRs become permanent context records that explain not just what changed, but why it changed, how decisions were made, and what alternatives were considered.

## Core Principles

### 1. Complete Context Capture
Every PR should preserve:
- Original request or requirement
- Implementation decisions and trade-offs
- Deviations from initial plans
- Lessons learned during implementation

### 2. Structured Information
Organize PR descriptions into consistent sections that reviewers and future readers can easily navigate.

### 3. Permanent Record
PRs serve as historical documentation that remains accessible even after code evolves or team members change.

## Implementation Guide

### PR Template Structure

```markdown
## Summary
[Brief overview of what this PR accomplishes - 2-3 sentences]

## Context
- **Initiated by**: [User/Team/Issue that requested this]
- **Task/Issue**: [Reference numbers or links]
- **Feature Branch**: [Branch name]
- **Date Started**: [When work began]
- **Priority**: [High/Medium/Low]

## Original Request
[Include the complete, verbatim request that initiated this work]
```
[Original request text, email, or issue description]
```

## Implementation Details

### Approach
[Explain the chosen implementation strategy]

### Key Decisions
- **Decision 1**: [What was decided and why]
- **Decision 2**: [Trade-offs considered]
- **Alternative approaches considered**: [What else was evaluated]

### Technical Notes
- [Architecture choices]
- [Performance considerations]
- [Security implications]
- [Dependencies added/removed]

## Changes Made

### Files Modified
- `path/to/file1.js`: [Brief description of changes]
- `path/to/file2.css`: [Brief description of changes]
- `docs/guide.md`: [Updated documentation for new feature]

### New Files
- `path/to/newfile.js`: [Purpose of this new file]

### Deleted Files
- `path/to/oldfile.js`: [Why it was removed]

## Testing

### Test Coverage
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed
- [ ] Edge cases considered

### Test Scenarios
1. [Scenario 1 and expected behavior]
2. [Scenario 2 and expected behavior]

### Performance Impact
- [Benchmarks or performance considerations]
- [Load testing results if applicable]

## Verification Checklist
- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] Tests pass locally
- [ ] No console errors or warnings
- [ ] Accessibility considerations addressed
- [ ] Security review completed (if applicable)

## References
- Related PRs: #123, #456
- Issues: Fixes #789, Addresses #012
- Documentation: [Link to relevant docs]
- Design Documents: [Link to specifications]

## Post-Merge Tasks
- [ ] Update deployment documentation
- [ ] Notify stakeholders
- [ ] Monitor for issues
- [ ] Update project board

## Screenshots/Demos
[Include if applicable for UI changes]
```

## Examples

### Feature Implementation PR

```markdown
## Summary
Implemented a real-time notification system that allows users to receive instant updates when their documents are modified by collaborators.

## Context
- **Initiated by**: Product team request for Q4 roadmap
- **Task/Issue**: #1234 - Real-time collaboration phase 1
- **Feature Branch**: feature/realtime-notifications
- **Date Started**: 2024-01-15
- **Priority**: High

## Original Request
```
We need users to see when other people are editing their documents in real-time. 
Should show:
1. Who is currently viewing/editing
2. Notifications when changes are saved
3. Visual indicators on the document
Must work across all supported browsers and degrade gracefully.
```

## Implementation Details

### Approach
Implemented using WebSocket connections with Socket.io for broad browser compatibility. Falls back to polling for environments without WebSocket support.

### Key Decisions
- **WebSocket vs SSE**: Chose WebSocket for bidirectional communication needs
- **Library choice**: Socket.io over raw WebSockets for better compatibility
- **State management**: Used Redux for notification state to integrate with existing store
- **Alternative considered**: Server-Sent Events, but rejected due to one-way limitation

### Technical Notes
- Added Redis for scaling WebSocket connections across multiple servers
- Implemented heartbeat mechanism to detect disconnected clients
- Rate limiting added to prevent notification spam
- Maximum 100 concurrent connections per document

## Changes Made

### Files Modified
- `src/components/Editor.jsx`: Added presence indicators and notification listener
- `src/store/notifications.js`: New Redux slice for notification state
- `server/websocket.js`: WebSocket server implementation
- `package.json`: Added socket.io dependencies

### New Files
- `src/hooks/useNotifications.js`: Custom hook for notification management
- `server/redis-client.js`: Redis adapter for Socket.io
- `tests/notifications.test.js`: Test suite for notification system

## Testing

### Test Coverage
- [x] Unit tests for notification reducer
- [x] Integration tests for WebSocket connection
- [x] E2E tests for full notification flow
- [x] Load tests with 100 concurrent users

### Test Scenarios
1. User A edits while User B views - B receives notification
2. Network disconnection - Graceful reconnection with queued notifications
3. Rate limiting - Max 10 notifications per minute per user
4. Browser compatibility - Tested in Chrome, Firefox, Safari, Edge

### Performance Impact
- Initial connection adds ~50ms to page load
- Negligible impact on editor performance
- Redis memory usage: ~1KB per active connection

## References
- Design Doc: docs/realtime-collaboration-spec.md
- Related PR: #1230 (WebSocket infrastructure)
- Issues: Fixes #1234, Partially addresses #1235
```

## Benefits

- **Knowledge Transfer**: New team members understand past decisions
- **Debugging Aid**: Historical context helps troubleshoot issues
- **Audit Trail**: Complete record of changes and approvals
- **AI Context**: Future AI agents can understand implementation history
- **Decision History**: Learn from past choices and avoid repeating mistakes

## Adoption

To adopt this pattern in your project:

1. **Create PR Template**:
   Create `.github/pull_request_template.md`:
   ```markdown
   ## Summary
   [Brief overview]

   ## Context
   - **Task/Issue**: 
   - **Feature Branch**: 

   ## Changes
   - 

   ## Testing
   - [ ] Tests added/updated
   - [ ] Manual testing completed

   ## References
   - 
   ```

2. **Configure Repository**:
   - Set up branch protection rules
   - Require PR reviews (optional)
   - Enable auto-delete head branches

3. **Team Guidelines**:
   - Document PR standards in CONTRIBUTING.md
   - Provide examples of well-documented PRs
   - Include in onboarding process

4. **Automation** (optional):
   - PR size warnings for large changes
   - Automated checks for PR description
   - Integration with project management tools

## Anti-patterns to Avoid

❌ **Minimal Description**
```
Fixed bug
```

❌ **No Context**
```
Updated files as requested
```

❌ **Missing Original Request**
```
Implemented feature
[No explanation of what was actually requested]
```

✅ **Good Example**
```
## Summary
Fixed critical authentication bug that allowed users to access other accounts

## Context
- **Initiated by**: Security audit finding on 2024-01-10
- **Severity**: Critical
- **Issue**: SEC-001

## Original Request
Security team reported: "Users can access other accounts by manipulating the JWT token userId claim. This needs immediate fix."

[Full implementation details follow...]
```

## Related Patterns

- [Feature Branch Workflow](git-workflow.md): The workflow that creates PRs
- [Commit Standards](commit-standards.md): Individual commit documentation
- [Branch Management](branch-management.md): Managing PR lifecycle

## Tips for Success

1. **Write for Future You**: Assume you'll forget all context in 6 months
2. **Include "Why" Not Just "What"**: Code shows what, PR explains why
3. **Link Everything**: Connect to issues, docs, and related PRs
4. **Visual Aids**: Include diagrams or screenshots when helpful
5. **Acknowledge Uncertainty**: Document known limitations or concerns

---

*A well-documented PR is an investment in your project's future. It transforms a list of changes into a valuable historical record that serves the team for years to come.*