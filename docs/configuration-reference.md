# Configuration Reference for Unified Notebook CI/CD

This document provides a comprehensive reference for configuring the unified notebook CI/CD system.

## Core Configuration Parameters

### Execution Mode

Controls the primary behavior of the workflow:

| Value | Description | Use Case |
|-------|-------------|----------|
| `'pr'` | Pull request mode | Validates changed notebooks, selective execution |
| `'merge'` | Merge/deploy mode | Full processing and documentation deployment |
| `'scheduled'` | Scheduled maintenance | Weekly validation and deprecation management |
| `'on-demand'` | Manual execution | Flexible manual triggers with various options |

**Example:**
```yaml
with:
  execution-mode: 'pr'
```

### Trigger Event

Fine-grained control over what actions to perform (used with on-demand mode):

| Value | Description | Actions Performed |
|-------|-------------|-------------------|
| `'all'` | Full pipeline | Validation + Security + Execution + Storage + HTML |
| `'validate'` | Validation only | pytest nbval validation |
| `'execute'` | Execution only | Notebook execution without validation |
| `'security'` | Security only | bandit security scanning |
| `'html'` | HTML build only | JupyterBook documentation generation |
| `'deprecate'` | Deprecation management | Tag/manage deprecated notebooks |

**Example:**
```yaml
with:
  execution-mode: 'on-demand'
  trigger-event: 'validate'
```

## Environment Configuration

### Python Version

Specify the Python version for the execution environment:

```yaml
with:
  python-version: '3.11'        # Default
  # python-version: '3.10'      # Alternative
  # python-version: '3.12'      # Latest
```

### Conda Environment

Use predefined conda environments from conda-forge:

```yaml
with:
  conda-environment: 'hstcal'   # For HST workflows
  # conda-environment: 'stenv'  # For JWST workflows
  # conda-environment: 'astropy' # For general astronomy
```

**Available Environments:**
- `hstcal` - HST calibration tools
- `stenv` - Space Telescope environment for JWST
- `astropy` - General astronomy Python environment
- Custom environments available on conda-forge

### Custom Requirements

Specify custom requirements file path:

```yaml
with:
  custom-requirements: 'requirements.txt'           # Root requirements
  # custom-requirements: 'environment/deps.txt'    # Custom path
  # custom-requirements: 'notebooks/requirements.txt' # Notebook-specific
```

## Feature Control

### Enable/Disable Features

Control which CI/CD features are active:

```yaml
with:
  enable-validation: true      # pytest nbval validation
  enable-security: true        # bandit security scanning
  enable-execution: true       # notebook execution
  enable-storage: true         # store outputs to gh-storage
  enable-html-build: false     # JupyterBook HTML generation
```

**Feature Combinations:**

#### Validation Only
```yaml
with:
  enable-validation: true
  enable-security: false
  enable-execution: false
  enable-storage: false
  enable-html-build: false
```

#### Execution with Storage
```yaml
with:
  enable-validation: false
  enable-security: false
  enable-execution: true
  enable-storage: true
  enable-html-build: false
```

#### Full CI/CD Pipeline
```yaml
with:
  enable-validation: true
  enable-security: true
  enable-execution: true
  enable-storage: true
  enable-html-build: true
```

## Notebook Selection

### Single Notebook Targeting

Execute or validate a specific notebook:

```yaml
with:
  single-notebook: 'notebooks/example/demo.ipynb'
  execution-mode: 'on-demand'
  trigger-event: 'execute'
```

### Directory-Based Selection

Automatically detected based on changed files in PR mode, or manually specified:

```yaml
with:
  affected-directories: '["notebooks/hst", "notebooks/jwst"]'  # JSON array
```

## Advanced Configuration

### Post-Processing Scripts

Execute custom scripts after notebook processing:

```yaml
with:
  post-processing-script: 'scripts/custom_processing.sh'
```

**Example post-processing script:**
```bash
#!/bin/bash
# scripts/custom_processing.sh

echo "Running custom post-processing..."

# Image optimization
find _build -name "*.png" -exec optipng {} \;

# Custom file processing
python scripts/process_outputs.py

# Cleanup
rm -rf temp_files/

echo "Post-processing complete"
```

### Deprecation Management

Configure notebook deprecation settings:

```yaml
with:
  deprecation-days: 60         # Days until notebook expires
  trigger-event: 'deprecate'   # For deprecation actions
```

## Repository-Specific Examples

### HST Notebooks Repository

```yaml
name: HST Notebook CI
jobs:
  hst-ci:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'pr'
      python-version: '3.11'
      conda-environment: 'hstcal'
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: false
      post-processing-script: 'scripts/hst_image_processing.sh'
    secrets:
      CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
      CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

### JWST Notebooks Repository

```yaml
name: JWST Notebook CI
jobs:
  jwst-ci:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'merge'
      python-version: '3.11'
      conda-environment: 'stenv'
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: true
      post-processing-script: 'scripts/jwst_data_processing.sh'
    secrets:
      CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
      CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

### Standard Python Repository

```yaml
name: Standard Notebook CI
jobs:
  standard-ci:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'pr'
      python-version: '3.11'
      custom-requirements: 'requirements.txt'
      enable-validation: true
      enable-security: false       # Disable security for simple repos
      enable-execution: true
      enable-storage: true
      enable-html-build: false
```

### Documentation-Heavy Repository

```yaml
name: Documentation CI
jobs:
  docs-ci:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'merge'
      python-version: '3.11'
      enable-validation: false     # Skip validation for docs
      enable-security: false
      enable-execution: false      # Skip execution for docs
      enable-storage: false
      enable-html-build: true      # Focus on HTML generation
      post-processing-script: 'scripts/docs_optimization.sh'
```

## Secrets Configuration

### Required Secrets

Configure these secrets in your repository settings:

| Secret | Required | Description | Example |
|--------|----------|-------------|---------|
| `CASJOBS_USERID` | Optional | CasJobs database user ID | `'your_userid'` |
| `CASJOBS_PW` | Optional | CasJobs database password | `'your_password'` |

### Setting Secrets

1. Go to your repository settings
2. Navigate to "Secrets and variables" > "Actions"
3. Click "New repository secret"
4. Add the secret name and value

**In workflow:**
```yaml
secrets:
  CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
  CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

## Trigger Configuration

### Pull Request Triggers

Configure which files trigger the workflow:

```yaml
on:
  pull_request:
    branches: [ main ]
    paths:
      - 'notebooks/**'           # Any notebook changes
      - 'requirements.txt'       # Root requirements
      - 'pyproject.toml'         # Python project config
      - '*.yml'                  # YAML configuration
      - '*.yaml'                 # YAML configuration
      - '*.md'                   # Documentation
      - '*.html'                 # Web assets
      - '*.css'                  # Stylesheets
      - '*.js'                   # JavaScript
```

### Push Triggers

Configure main branch deployment:

```yaml
on:
  push:
    branches: [ main ]
    paths:
      - 'notebooks/**'
      - 'requirements.txt'
      - 'pyproject.toml'
      - '*.yml'
      - '*.yaml'
      - '*.md'
      - '*.html'
```

### Scheduled Triggers

Configure maintenance schedules:

```yaml
on:
  schedule:
    # Every Sunday at 2 AM UTC
    - cron: '0 2 * * 0'
    
    # Every day at midnight UTC (for high-activity repos)
    # - cron: '0 0 * * *'
    
    # Every Monday at 9 AM UTC (for work-week schedules)
    # - cron: '0 9 * * 1'
```

### Manual Triggers

Configure on-demand workflows:

```yaml
on:
  workflow_dispatch:
    inputs:
      action_type:
        description: 'Action to perform'
        required: true
        type: choice
        options:
          - 'validate-all'
          - 'execute-single'
          - 'build-html-only'
        default: 'validate-all'
      
      single_notebook:
        description: 'Notebook path for single actions'
        required: false
        type: string
      
      python_version:
        description: 'Python version override'
        required: false
        type: string
        default: '3.11'
```

## Performance Optimization

### Docs-Only Detection

Automatically detected for these file types:
- `*.md`, `*.rst` - Documentation
- `*.html`, `*.css`, `*.js` - Web assets
- `_config.yml`, `_toc.yml` - Documentation config
- `*.yml`, `*.yaml` - Configuration files (non-workflow)

### Selective Execution

Automatically processes only:
- Changed notebooks in PR mode
- Affected directories when requirements change
- Dependencies based on file change analysis

### Caching Optimization

The unified workflow includes:
- Python environment caching
- Package installation caching
- Dependency resolution caching

### Resource Management

Configure timeouts and limits:
```yaml
# In the unified workflow (advanced users)
timeout-minutes: 120           # Maximum workflow runtime
max-parallel: 5               # Maximum parallel jobs
```

## Error Handling

### Continue on Error

For non-critical steps:
```yaml
# In custom implementations
continue-on-error: true
```

### Conditional Execution

Skip steps based on conditions:
```yaml
# Example: Skip security scan for docs-only changes
if: needs.setup-matrix.outputs.docs-only != 'true'
```

### Retry Logic

The unified workflow includes automatic retry for:
- Git operations
- Package installations
- Network-dependent operations

## Monitoring and Debugging

### Workflow Summary

The unified workflow provides detailed summaries including:
- Configuration used
- Execution strategy (selective/full)
- Performance metrics
- Error details

### Debug Mode

Enable verbose logging:
```yaml
# Set in repository variables
ACTIONS_STEP_DEBUG: true
ACTIONS_RUNNER_DEBUG: true
```

### Performance Metrics

Monitor these metrics in workflow summaries:
- Execution time per notebook
- Number of notebooks processed
- Cache hit/miss ratios
- Resource usage

## Migration Considerations

### From Existing Workflows

When migrating, map these configurations:

| Old Setting | New Configuration |
|-------------|-------------------|
| Manual matrix setup | Automatic detection |
| Hardcoded Python version | `python-version` parameter |
| Fixed conda env | `conda-environment` parameter |
| Always-on features | Feature toggle parameters |
| Repository-specific logic | Configurable parameters |

### Testing Migration

1. **Start with PR workflow**: Test the most common use case first
2. **Use draft PRs**: Test without affecting main branch
3. **Monitor performance**: Compare execution times and resource usage
4. **Verify outputs**: Ensure generated outputs match expectations

## Best Practices

### Configuration Management

1. **Start simple**: Begin with basic configuration, add complexity gradually
2. **Document choices**: Comment configuration decisions in workflow files
3. **Test thoroughly**: Validate configuration with test PRs
4. **Monitor performance**: Watch for execution time and resource usage

### Repository-Specific Customization

1. **Use appropriate environments**: Choose conda env that matches your domain
2. **Enable relevant features**: Only enable features you actually need
3. **Configure triggers carefully**: Avoid unnecessary workflow runs
4. **Customize post-processing**: Add domain-specific processing as needed

### Maintenance

1. **Regular updates**: Keep workflow references current (`@dev-actions-v2` or specific tags)
2. **Monitor deprecation**: Watch for deprecated configuration options
3. **Performance review**: Periodically review and optimize configuration
4. **Documentation updates**: Keep repository docs in sync with configuration
