# GitHub Workflows - Automated Flows

This directory contains automated workflow flows that run based on GitHub events, not user commands.

## Directory Structure

```
flows/
├── auto-preview-release-after-pr/    # Auto preview after PR merge to develop
├── auto-create-changeset-on-pr/      # Auto create changeset when PR opens
└── ...
```

## Difference from Commands

- **Commands** (`/commands`): User-triggered actions via comments (e.g., `/start`, `/release`)
- **Flows** (`/flows`): Event-triggered automations (e.g., PR merged, issue created)

## Available Flows

### 1. Auto Preview Release After PR
- **Trigger**: When PR is merged to develop/dev branch
- **Action**: Posts release preview showing accumulated changesets
- **Purpose**: Keep team informed about upcoming release version

### 2. Auto Create Changeset on PR (Planned)
- **Trigger**: When PR is opened to develop
- **Action**: Automatically runs `/changeset` command
- **Purpose**: Ensure all PRs have changesets

## Usage

These flows are automatically included when you run:
```bash
node make.js <solution-name>
```

Flows can be selectively enabled/disabled in solution configurations.