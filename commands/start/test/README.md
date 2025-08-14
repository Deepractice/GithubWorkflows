# /start issue Command Test Cases

## Test Scenarios

### 1. Basic Usage
- **File**: `start-issue-basic.json`
- **Command**: `/start issue 123`
- **Expected**: Creates branch from auto-detected base branch (develop > dev > main)

### 2. With Explicit Branch
- **File**: `start-issue-from-branch.json`
- **Command**: `/start issue 456 --from-branch develop`
- **Expected**: Creates branch from specified develop branch

### 3. Current Issue (No Number)
- **File**: `start-issue-current.json`
- **Command**: `/start issue`
- **Expected**: Creates branch for current issue #789, auto-detects base branch

### 4. Current Issue with Branch
- **File**: `start-issue-current-with-branch.json`
- **Command**: `/start issue --from-branch staging`
- **Expected**: Creates branch for current issue #999 from staging branch

### 5. Chinese Title
- **File**: `start-issue-chinese.json`
- **Command**: `/start issue 200`
- **Expected**: Creates branch with format `feature/#200-issue` (fallback for non-ASCII)

### 6. Bug Issue
- **File**: `start-issue-bug.json`
- **Command**: `/start issue 300`
- **Expected**: Creates branch with `fix/` prefix

### 7. Branch Already Exists
- **File**: `start-issue-exists.json`
- **Command**: `/start issue 400`
- **Expected**: Shows warning that branch already exists

### 8. Invalid Command
- **File**: `start-issue-invalid.json`
- **Command**: `/start` (missing "issue")
- **Expected**: Command not triggered

## Branch Detection Scenarios

### Repository with develop branch
- **File**: `branches-with-develop.json`
- **Expected**: Auto-selects `develop` as base branch

### Repository with dev branch
- **File**: `branches-with-dev.json`
- **Expected**: Auto-selects `dev` as base branch

### Repository with only main branch
- **File**: `branches-main-only.json`
- **Expected**: Auto-selects `main` as base branch

## Default Branch Priority

When no `--from-branch` is specified, the command checks branches in this order:

1. `develop` (if exists)
2. `dev` (if exists)
3. `main` (if exists)
4. `master` (if exists)
5. Repository's default branch

## Command Formats

### Valid Formats
- `/start issue` - Use current issue, auto-detect branch
- `/start issue 123` - Use issue #123, auto-detect branch
- `/start issue --from-branch custom` - Use current issue, custom branch
- `/start issue 123 --from-branch custom` - Use issue #123, custom branch

### Invalid Formats
- `/start` - Missing "issue" keyword
- `/start 123` - Missing "issue" keyword
- `/start issue abc` - Invalid issue number