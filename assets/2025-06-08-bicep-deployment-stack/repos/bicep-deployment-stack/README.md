# Bicep Deployment Stack CI/CD Pipelines

This repository contains two GitLab CI/CD pipeline definitions:

## 1. [.gitlab-ci.yml](.gitlab-ci.yml)

This pipeline handles the release process for the Bicep deployment stack.  
It creates a release when changes are pushed to the default branch, a merge request is created, or a tag is pushed.  
The release uses the GitLab Release CLI and tags the release with a version based on the pipeline ID.

## 2. [bicep.gitlab-ci.yml](bicep.gitlab-ci.yml)

This pipeline manages the build, test, and deployment of Bicep files:

- **bicep-lint**: Lints Bicep files for syntax and style issues.
- **build-bicep**: Builds Bicep templates and outputs artifacts.
- **deploy-test**: Validates the built templates to a production environment in Azure.
- **deploy**: Deploys the templates to the production environment in Azure.

The pipeline uses a custom Docker image with Bicep and PowerShell tools, and authenticates to Azure using service principal credentials.

> **Note:**  
> The `bicep.gitlab-ci.yml` file is designed for reusability.  
> It can be included in other projects to provide a standardized Bicep build and deployment pipeline.