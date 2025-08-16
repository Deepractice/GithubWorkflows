# Deploy Command

Deploy packages to NPM or Docker registries with GitHub Deployments integration.

## Usage

```bash
/deploy <target> --tag <tag> [--dry-run] [--auto]
```

### Parameters

- `<target>`: Deployment target (`npm` or `docker`)
- `--tag`: Deployment tag (`dev`, `beta`, or `latest`)
- `--dry-run`: Preview deployment without actually publishing
- `--auto`: Flag for automated deployments (suppresses success comments)

### Examples

```bash
# Deploy to NPM with dev tag
/deploy npm --tag dev

# Deploy to Docker with latest tag
/deploy docker --tag latest

# Preview NPM deployment
/deploy npm --tag beta --dry-run

# Automated deployment (usually triggered by workflows)
/deploy npm --tag dev --auto
```

## Deployment Targets

### NPM Deployment

Publishes Node.js packages to NPM registry.

**Requirements:**
- `package.json` file
- NPM_TOKEN secret configured
- Valid NPM package configuration

**Version Handling:**
- `dev`: Appends `-dev.TIMESTAMP` to version
- `beta`: Appends `-beta.TIMESTAMP` to version
- `latest`: Uses current package version

### Docker Deployment

Builds and pushes Docker images to container registries.

**Requirements:**
- `Dockerfile` in repository root
- Docker registry credentials (DOCKER_USERNAME/DOCKER_PASSWORD or GITHUB_TOKEN)

**Supported Registries:**
- Docker Hub (docker.io)
- GitHub Container Registry (ghcr.io)

**Version Handling:**
- `dev`: Appends `-dev.TIMESTAMP` to version
- `beta`: Appends `-beta.TIMESTAMP` to version
- `latest`: Uses current version or git SHA

## GitHub Deployments Integration

Each deployment creates a GitHub Deployment record with:
- Environment tracking (development/staging/production)
- Deployment status updates
- Environment URLs for viewing deployments

## Environment Mapping

| Tag    | NPM Environment | Docker Environment | GitHub Environment |
|--------|----------------|-------------------|-------------------|
| dev    | development    | development       | npm-development / docker-development |
| beta   | staging        | staging           | npm-staging / docker-staging |
| latest | production     | production        | npm-production / docker-production |

## Permissions

- Requires write permission or higher
- GitHub Actions bot is automatically allowed for automated deployments

## Testing

Run tests locally with act:

```bash
cd commands/deploy/test
make test
```

### Test Individual Scenarios

```bash
# Test NPM deployments
make test-npm

# Test Docker deployments
make test-docker

# Test error handling
make test-invalid

# Test dry-run mode
make test-dry-run

# Test automated deployments
make test-auto
```

## Scripts

### detect.sh
Detects project type and structure for deployment.

### validate.sh
Validates deployment command parameters.

### npm.sh
Handles NPM package publishing.

### docker.sh
Handles Docker image building and pushing.

## Configuration

### Required Secrets

**For NPM:**
- `NPM_TOKEN`: NPM authentication token

**For Docker Hub:**
- `DOCKER_USERNAME`: Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub password

**For GitHub Container Registry:**
- Uses `GITHUB_TOKEN` (automatically provided)

### Optional Configuration

- `.npmrc`: NPM configuration file
- `NPM_CONFIG_PROVENANCE`: Enable provenance for NPM packages

## Workflow Integration

### Automated Dev Deployment

```yaml
# In pr-merged-develop workflow
- name: Auto-deploy dev version
  uses: actions/github-script@v7
  with:
    script: |
      await github.rest.issues.createComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: pr.number,
        body: '/deploy npm --tag dev --auto'
      });
```

### Release-triggered Deployment

```yaml
# In release-created event
- name: Deploy release
  uses: actions/github-script@v7
  with:
    script: |
      const isPrerelease = context.payload.release.prerelease;
      const tag = isPrerelease ? 'beta' : 'latest';
      
      await github.rest.issues.createComment({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
        body: `/deploy npm --tag ${tag} --auto`
      });
```

## Error Handling

The command includes comprehensive error handling for:
- Missing or invalid parameters
- Missing project files (package.json, Dockerfile)
- Authentication failures
- Build/publish failures
- Network issues

## Dry Run Mode

Use `--dry-run` to preview deployment without actually publishing:
- Shows what would be executed
- Validates all parameters and configurations
- Creates deployment record with "inactive" status
- Useful for testing and verification

## Best Practices

1. **Always test with dry-run first** for production deployments
2. **Use appropriate tags** for different environments
3. **Configure secrets properly** before deployment
4. **Monitor deployment status** in GitHub Deployments tab
5. **Use automated deployments** for CI/CD integration

## Troubleshooting

### NPM Deployment Issues

1. **Authentication Error**: Check NPM_TOKEN is correctly set
2. **Version Conflict**: Ensure version doesn't already exist
3. **Build Failure**: Verify build script and dependencies

### Docker Deployment Issues

1. **Login Failed**: Check registry credentials
2. **Build Error**: Verify Dockerfile syntax
3. **Push Denied**: Check repository permissions

### Common Issues

1. **Permission Denied**: User needs write access or higher
2. **Invalid Command**: Check command syntax and parameters
3. **Missing Files**: Ensure required files exist (package.json/Dockerfile)