# Slash Commands for GitHub Workflows

## Available Commands

### Version Management
- `/changeset patch` - Create patch version changeset
- `/changeset minor` - Create minor version changeset  
- `/changeset major` - Create major version changeset
- `/version status` - Check version and pending changesets

### Testing
- `/test` - Run default test suite
- `/test all` - Run all tests
- `/test unit` - Run unit tests only

### Publishing
- `/publish npm dev` - Publish to npm dev tag
- `/publish npm alpha` - Publish to npm alpha tag
- `/publish npm beta` - Publish to npm beta tag
- `/publish npm latest` - Publish to npm latest tag

### Workflow Control
- `/hold` - Block merge
- `/unhold` - Unblock merge
- `/retry` - Retry failed checks