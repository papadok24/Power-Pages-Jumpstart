# ALM Overview - Application Lifecycle Management

## Overview

This guide provides a conceptual overview of Application Lifecycle Management (ALM) options for Power Pages, covering Solutions, PAC CLI, Power Platform Pipelines, and GitHub Actions. Understanding these options helps you choose the right deployment strategy for your Power Pages projects.

**Prerequisites**:
- Basic understanding of Power Platform and Dataverse
- Familiarity with version control concepts
- Understanding of deployment workflows

---

## What is ALM?

Application Lifecycle Management (ALM) is the process of managing the lifecycle of an application from development through deployment to production. For Power Pages, ALM includes:

- **Version Control**: Tracking changes to site configuration and code
- **Deployment**: Moving changes between environments (dev, test, production)
- **Collaboration**: Multiple developers working on the same project
- **Quality Assurance**: Testing changes before production deployment
- **Rollback**: Reverting to previous versions if issues occur

---

## ALM Options for Power Pages

### 1. Solutions

Solutions are the primary mechanism for packaging and deploying Power Platform components, including Dataverse tables, Power Pages site metadata, and customizations.

#### What are Solutions?

Solutions are containers that hold:
- **Dataverse Tables**: Custom tables, columns, relationships
- **Power Pages Components**: Web pages, templates, forms, lists
- **Web Resources**: JavaScript, CSS, images
- **Site Settings**: Configuration settings
- **Table Permissions**: Security configurations

#### Solution Types

**Managed Solutions**:
- ✅ Locked and cannot be modified in target environment
- ✅ Used for production deployments
- ✅ Prevents accidental changes
- ✅ Supports uninstall (removes components)

**Unmanaged Solutions**:
- ✅ Can be modified in target environment
- ✅ Used for development
- ✅ Allows customization after import
- ❌ Cannot be uninstalled cleanly

#### Solution Layers

Solutions use a layering system:
1. **Base Solution**: Original components
2. **Managed Solutions**: Installed on top
3. **Unmanaged Customizations**: Local changes

**Best Practice**: Always work in unmanaged solutions during development, then export as managed for production.

#### Solution Publisher

Every solution has a publisher that defines:
- **Prefix**: Applied to custom components (e.g., `pa911_`)
- **Name**: Organization or project name
- **Version**: Solution version number

**Reference**: [Solutions Overview](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/introduction-solutions)

---

### 2. PAC CLI (Power Platform CLI)

PAC CLI is a command-line interface for Power Platform that enables automation of common tasks, including Power Pages site management.

#### Key PAC CLI Commands for Power Pages

**Authentication**:
```bash
# Authenticate to Dataverse environment
pac auth create -u https://your-org.crm.dynamics.com
```

**List Websites**:
```bash
# List all Power Pages websites in the environment
pac pages list
```

**Download Site**:
```bash
# Download Power Pages site metadata
pac pages download --path ./src/site -id {WebSiteId} --modelVersion 2
```

**Upload Changes**:
```bash
# Upload site metadata changes
pac pages upload --path ./src/site --modelVersion 2
```

**Upload with Deployment Profile**:
```bash
# Upload with environment-specific configuration
pac pages upload --path ./src/site --deploymentProfile dev --modelVersion 2
```

#### Model Versions

Power Pages supports two data models:
- **Model Version 1**: Standard data model
- **Model Version 2**: Enhanced data model (recommended)

**Check Model Version**:
```bash
pac pages list -v
```

#### Deployment Profiles

Deployment profiles allow environment-specific configurations:

**Structure**:
```
src/site/
└── deployment-profiles/
    ├── dev.deployment.yml
    ├── test.deployment.yml
    └── prod.deployment.yml
```

**Example Profile** (`dev.deployment.yml`):
```yaml
adx_contentsnippet:
  - adx_contentsnippetid: 76227a41-a33c-4d63-b0f6-cd4ecd116bf8
    adx_name: Browser Title Suffix
    adx_value: " · Custom Portal (Dev)"
```

**Reference**: [Power Platform CLI Tutorial](https://learn.microsoft.com/en-us/power-pages/configure/power-platform-cli-tutorial)

---

### 3. Power Platform Pipelines

Power Platform Pipelines provide a low-code/no-code approach to deploying solutions between environments.

#### What are Pipelines?

Pipelines are automated workflows that:
- Deploy solutions from source to target environment
- Run validation checks
- Handle approvals
- Provide deployment history

#### Pipeline Components

1. **Host Environment**: Manages pipeline definitions
2. **Source Environment**: Where solutions are developed
3. **Target Environment**: Where solutions are deployed
4. **Stages**: Steps in the deployment process

#### Pipeline Stages

Typical pipeline stages:
1. **Validation**: Check solution for errors
2. **Export**: Export solution from source
3. **Import**: Import solution to target
4. **Approval**: Manual approval step (optional)
5. **Post-Deployment**: Run scripts or flows

#### When to Use Pipelines

**Use Pipelines When**:
- ✅ You want a low-code deployment solution
- ✅ You need approval workflows
- ✅ You have multiple environments (dev → test → prod)
- ✅ You want deployment history and audit trails

**Don't Use Pipelines When**:
- ❌ You need fine-grained control over deployment
- ❌ You want to deploy only specific components
- ❌ You need custom deployment scripts

**Reference**: [Power Platform Pipelines](https://learn.microsoft.com/en-us/power-platform/alm/power-platform-pipelines)

---

### 4. GitHub Actions

GitHub Actions provides CI/CD (Continuous Integration/Continuous Deployment) for Power Pages using automation scripts and workflows.

#### What are GitHub Actions?

GitHub Actions are automated workflows that:
- Trigger on events (push, pull request, schedule)
- Run scripts and commands
- Deploy to environments
- Run tests and validations

#### GitHub Actions Workflow Structure

**Example Workflow** (`.github/workflows/deploy-power-pages.yml`):
```yaml
name: Deploy Power Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PAC CLI
        uses: microsoft/powerplatform-actions/setup-cli@v1
      
      - name: Authenticate
        run: |
          pac auth create --url ${{ secrets.DATAVERSE_URL }} \
            --username ${{ secrets.USERNAME }} \
            --password ${{ secrets.PASSWORD }}
      
      - name: Upload Power Pages
        run: |
          pac pages upload --path ./src/site \
            --modelVersion 2 \
            --deploymentProfile ${{ env.DEPLOYMENT_PROFILE }}
      
      - name: Export Solution
        run: |
          pac solution export --path ./src/solution \
            --name "PawsFirst Portal" \
            --managed
```

#### GitHub Secrets

Store sensitive information as secrets:
- `DATAVERSE_URL`: Environment URL
- `USERNAME`: Service account username
- `PASSWORD`: Service account password
- `DEPLOYMENT_PROFILE`: Environment name (dev, test, prod)

#### When to Use GitHub Actions

**Use GitHub Actions When**:
- ✅ You want full control over deployment process
- ✅ You need custom deployment scripts
- ✅ You want to integrate with other tools
- ✅ You need advanced CI/CD features

**Don't Use GitHub Actions When**:
- ❌ You prefer low-code solutions
- ❌ You don't have DevOps expertise
- ❌ You want simple approval workflows

**Reference**: [Power Platform GitHub Actions](https://github.com/microsoft/powerplatform-actions)

---

## Decision Matrix

Use this matrix to choose the right ALM approach:

| Scenario | Recommended Approach | Why |
|----------|---------------------|-----|
| **Simple deployments, few environments** | Solutions + PAC CLI | Quick setup, manual control |
| **Multiple environments, approval needed** | Power Platform Pipelines | Built-in approvals, audit trail |
| **Advanced CI/CD, custom scripts** | GitHub Actions | Full automation, flexibility |
| **Development only** | Unmanaged Solutions | Easy to modify, iterate quickly |
| **Production deployment** | Managed Solutions | Locked, prevents changes |
| **Environment-specific config** | Deployment Profiles | Different settings per environment |

---

## Best Practices

### Version Control

1. **Use Git**: Store all Power Pages metadata in version control
2. **Commit Often**: Commit changes frequently with descriptive messages
3. **Branch Strategy**: Use branches for features, fixes, and releases
4. **Tag Releases**: Tag solution versions for easy rollback

### Deployment Strategy

1. **Dev → Test → Prod**: Always deploy through environments in order
2. **Test First**: Test changes in dev/test before production
3. **Backup Before Deploy**: Export solutions before major deployments
4. **Document Changes**: Keep changelog of what's being deployed

### Solution Management

1. **One Solution Per Project**: Keep related components together
2. **Meaningful Names**: Use descriptive solution names
3. **Version Numbers**: Follow semantic versioning (1.0.0, 1.1.0, 2.0.0)
4. **Managed for Prod**: Always use managed solutions in production

### PAC CLI Workflow

1. **Download Before Changes**: Always download latest before making changes
2. **Test Locally**: Test changes locally before uploading
3. **Use Deployment Profiles**: Use profiles for environment-specific configs
4. **Document Commands**: Keep scripts of common commands

---

## Common Workflows

### Workflow 1: Development to Production (PAC CLI)

```bash
# 1. Download from dev
pac pages download --path ./src/site -id {dev-site-id} --modelVersion 2

# 2. Make changes locally
# (edit files in ./src/site)

# 3. Upload to test
pac auth create -u https://test-org.crm.dynamics.com
pac pages upload --path ./src/site --deploymentProfile test --modelVersion 2

# 4. After testing, upload to production
pac auth create -u https://prod-org.crm.dynamics.com
pac pages upload --path ./src/site --deploymentProfile prod --modelVersion 2
```

### Workflow 2: Solution Deployment (Pipelines)

1. Develop solution in dev environment
2. Export solution as managed
3. Create pipeline from dev to test
4. Run pipeline to deploy to test
5. Test in test environment
6. Create pipeline from test to prod
7. Get approval and deploy to prod

### Workflow 3: CI/CD with GitHub Actions

1. Developer makes changes locally
2. Commits and pushes to feature branch
3. GitHub Actions runs tests
4. Create pull request to main
5. Merge triggers deployment to dev
6. Manual approval triggers deployment to prod

---

## Troubleshooting

### Common Issues

**Issue**: PAC CLI authentication fails
- **Solution**: Verify environment URL is correct
- **Solution**: Check user has appropriate permissions
- **Solution**: Try interactive authentication

**Issue**: Upload fails with conflicts
- **Solution**: Download latest version first
- **Solution**: Resolve conflicts manually
- **Solution**: Check for locked components

**Issue**: Deployment profile not applying
- **Solution**: Verify profile file name matches parameter
- **Solution**: Check YAML syntax is correct
- **Solution**: Verify profile is in correct location

**Issue**: Solution import fails
- **Solution**: Check target environment has required dependencies
- **Solution**: Verify solution version compatibility
- **Solution**: Check for missing required components

---

## Next Steps

- **[SharePoint Integration](sharepoint-integration.md)** - Set up document management
- **[Pet Document Upload (OOTB)](pet-document-upload-ootb.md)** - Implement OOTB document management
- **[Pet Document Upload (Custom)](pet-document-upload-custom.md)** - Build custom document management

---

## References

- [Power Platform CLI Documentation](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction)
- [Power Platform CLI Tutorial for Power Pages](https://learn.microsoft.com/en-us/power-pages/configure/power-platform-cli-tutorial)
- [Solutions Overview](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/introduction-solutions)
- [Power Platform Pipelines](https://learn.microsoft.com/en-us/power-platform/alm/power-platform-pipelines)
- [Power Platform GitHub Actions](https://github.com/microsoft/powerplatform-actions)
- [Deployment Profiles](https://learn.microsoft.com/en-us/power-pages/configure/power-platform-cli-tutorial#upload-the-changes-using-deployment-profile)

