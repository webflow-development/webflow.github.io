---
layout: post
title:  "Bicep Deployment Stack"
author: "Paulo Thüler"
categories: [ Azure ]
tags: [ Azure, Bicep, Gitlab, CI/CD, IaC ]
image: assets/images/bicep-deployment-stack-overview.png
description: "A scalable Bicep Deployment Stack to deploy your resources with Bicep, deployment stacks, and GitLab pipelines."
featured: true
hidden: false
---
## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
  - [Components](#components)
    - [1. Azure Subscription](#1-azure-subscription)
    - [2. GitLab Runner](#2-gitlab-runner)
    - [3. Docker Image with Tooling](#3-docker-image-with-tooling)
    - [4. Stack Repository](#4-stack-repository)
    - [5. Inheritable Pipeline Definition](#5-inheritable-pipeline-definition)
    - [6. Stack Versioning](#6-stack-versioning)
- [How To](#how-to)
  - [Dockerfile](#dockerfile)
  - [Scripts](#scripts)
  - [Bicep Deployment Stack](#bicep-deployment-stack)
    - [Pipeline definitions](#pipeline-definitions)
- [Bicep Deployment](#bicep-deployment)
- [Related Links](#related-links)

# Overview

This guide describes a scalable Bicep Deployment Stack designed for efficient infrastructure deployment using Bicep, Azure Deployment Stacks, and GitLab pipelines. The solution is modular and reusable, following best practices for Infrastructure as Code (IaC).

![Bicep Deployment Stack Overview](/assets/images/bicep-deployment-stack-overview.png)

# Prerequisites

Before you begin, ensure you have the following:

- An active Azure subscription
- Access to a GitLab instance (self-hosted or gitlab.com)
- Docker installed on your local machine or CI environment
- Basic knowledge of Bicep, Azure Resource Manager (ARM), and CI/CD concepts
- Visual Studio Code
  
## Components

The stack consists of the following components:

### 1. Azure Subscription
- You need one or more Azure subscriptions (e.g., Dev, Test, Prod).

### 2. GitLab Runner
- You have to add contributor permissions to your GitLab runner, or use multiple runners for each environment. In my case, I use one App Registration for one Subscription. At large scale, I recommend using a Kubernetes Cluster with Managed Identities for each Subscription.

### 3. Docker Image with Tooling
- Contains all required tools: Bicep CLI, Azure CLI, PowerShell, and supporting scripts.
- Ensures consistent build and deployment environments across projects.
- Located in the `bicep-base-image` directory.

### 4. Stack Repository
- Central repository for pipeline definitions and stack versioning.
- Houses the `bice.gitlab-ci.yml` file, which defines the CI/CD pipeline.
- Enables version control and traceability for stack changes.

### 5. Inheritable Pipeline Definition
- The `bice.gitlab-ci.yml` pipeline is designed to be inherited by multiple projects.
- Example: The `bicep-virtualmachine-deployment` project can reuse the same pipeline definition for consistent deployments.
- Promotes DRY (Don't Repeat Yourself) principles and simplifies maintenance.

### 6. Stack Versioning
- Each deployment stack is versioned, allowing controlled rollouts and easy rollbacks.
- Versioning is managed within the stack repository.

# How To

1. Create an Azure Subscription.
2. Create an App Registration with a Client Secret. Add a Role Assignment with `Contributor` to your Subscription.
3. Add the following GitLab variables to your `bicep-deployment-stack`:
    - AZURE_TENANT_ID
    - AZURE_SUBSCRIPTION_ID
    - AZURE_APPLICATION_ID
    - AZURE_CLIENT_SECRET (Masked)
4. Create three new repositories on GitLab:
   1. Repository for the base image with the Dockerfile.
   2. Repository for the deployment stack.
   3. Repository for the effective deployment of your infrastructure on Azure.
   4. (Optional): You can create more repositories to deploy different infrastructure use cases.


## Dockerfile

This is an example of how the base image for your Bicep deployment stack could look. It can also be used for the VS Code devcontainer.

```dockerfile
FROM mcr.microsoft.com/azure-powershell:14.0.0-ubuntu-22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

LABEL maintainer="services@webflow.ch"

ARG BICEP_VERSION="0.35.1"
# ARG AZ_RESOURCES_VERSION="7.7.0"

RUN curl -Lo bicep "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-x64" && \
    chmod +x ./bicep  && \
    mv ./bicep /usr/local/bin/bicep && \
    apt-get update

# Install specific PowerShell modules
# RUN pwsh -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
#     Install-Module -Name Az.Resources -RequiredVersion '${AZ_RESOURCES_VERSION}' \
#     -Scope AllUsers -Verbose -Force"

COPY scripts/ /usr/local/bin

# It is not recommended to use the root user
USER root 

```
## Scripts

- [Lint-Bicep.ps1](https://github.com/webflow-development/webflow.github.io/blob/main/assets/scripts/Lint-Bicep.ps1){:target="_blank"} – Lints Bicep files for syntax and best practices.
- [Build-Bicep.ps1](https://github.com/webflow-development/webflow.github.io/blob/main/assets/scripts/Build-Bicep.ps1){:target="_blank"} – Builds Bicep files into ARM templates.
- [Deploy-Bicep.ps1](https://github.com/webflow-development/webflow.github.io/blob/main/assets/scripts/Deploy-Bicep.ps1){:target="_blank"} – Deploys ARM templates to Azure.
- [Connect-Azure.ps1](https://github.com/webflow-development/webflow.github.io/blob/main/assets/scripts/Connect-Azure.ps1){:target="_blank"} – Authenticates and connects to Azure using a service principal.

Each script is designed to be used within the CI/CD pipeline or locally for development and testing.

## Bicep Deployment Stack 
### Pipeline definitions

```yaml
# .gitlab-ci.yml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_TAG

stages:
  - Publish

variables:
  VERSION: "1.0.${CI_PIPELINE_IID}"

gitlab:release:
  stage: Publish
  image: registry.gitlab.com/gitlab-org/release-cli
  script: 
    - echo "Create release"
  release:
    name: 'bicep-deployment-stack'
    description: 'Release for Bicep deployment stack'
    tag_name: $VERSION
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

```yaml
# bicep.gitlab-ci.yml
image: webflowch/bicep-deployment-image:1.2

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_TAG

stages:
  - build
  - test
  - deploy

variables:
  LOCATION: 'westeurope'
  STAGE: 'prod'

bicep-lint:
  stage: build
  script:
    - echo "Linting Bicep files..."
    - pwsh -Command "Lint-Bicep.ps1 -Path './src' -Recurse"
  rules:
    - if: $CI_COMMIT_BRANCH
      when: always
    - if: $CI_MERGE_REQUEST_ID

build-bicep:
  stage: build
  script:
    - echo "Building Bicep files..."
    - pwsh -Command "Build-Bicep.ps1 -File './src/main.bicep' -ParamFile './config/main-${STAGE}-${LOCATION}.bicepparam' -OutPath './artifacts'"
  artifacts:
    paths:
      - ./artifacts
    expire_in: 1 hour
    when: on_success
  rules:
    - if: $CI_COMMIT_BRANCH
      when: always
    - if: $CI_MERGE_REQUEST_ID

deploy-test:
  stage: deploy
  before_script:
    - echo "Login to Azure..."
    - pwsh -Command "Connect-Azure.ps1 -TenantId ${AZURE_TENANT_ID} -SubscriptionId ${AZURE_SUBSCRIPTION_ID} -ApplicationId ${AZURE_APPLICATION_ID} -ClientSecret (ConvertTo-SecureString ${AZURE_CLIENT_SECRET} -AsPlainText -Force) -UseServicePrincipal"
  script:
    - echo "Deploying to test environment..."
    - pwsh -Command "Deploy-Bicep.ps1 -DeploymentName 'bicep-deployment-stack' -TemplateFile './artifacts/main.json' -TemplateParameterFile './artifacts/main-${STAGE}-${LOCATION}.parameters.json' -Location '${LOCATION}' -Test"
  needs:
    - bicep-lint
    - build-bicep
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy:
  stage: deploy
  before_script:
    - echo "Login to Azure..."
    - pwsh -Command "Connect-Azure.ps1 -TenantId ${AZURE_TENANT_ID} -SubscriptionId ${AZURE_SUBSCRIPTION_ID} -ApplicationId ${AZURE_APPLICATION_ID} -ClientSecret (ConvertTo-SecureString ${AZURE_CLIENT_SECRET} -AsPlainText -Force) -UseServicePrincipal"
  script:
    - echo "Deploying to production environment..."
    - pwsh -Command "Deploy-Bicep.ps1 -DeploymentName 'bicep-deployment-stack' -TemplateFile './artifacts/main.json' -TemplateParameterFile './artifacts/main-${STAGE}-${LOCATION}.parameters.json' -Location '${LOCATION}'"
  needs:
    - deploy-test
    - build-bicep
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

```

# Bicep Deployment

Just include the `bicep.gitlab-ci.yml` file in your project with the correct version `ref`.

```yaml
include: 
  - project: 'webflow-development/bicep/bicep-deployment-stack'
    file: 'bicep.gitlab-ci.yml'
    ref: '1.0.41'
```

Here is the required file structure for the Bicep deployment stack.

```tree
│   .gitignore
│   .gitlab-ci.yml
│   README.md
├───.devcontainer
│       devcontainer.json
├───config
│       main-dev-westeurope.bicepparam
│       main-prod-westeurope.bicepparam
│       main-test-westeurope.bicepparam
└───src
    │   main.bicep
    │
    └───modules
            tags.bicep
            virtualmachine.bicep
```
# Related Links

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Azure Documentation](https://learn.microsoft.com/en-us/azure/)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Docker Documentation](https://docs.docker.com/)
- [Infrastructure as Code (IaC) Concepts](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

---

For more details or questions, feel free to reach out or open an issue in the repository.

