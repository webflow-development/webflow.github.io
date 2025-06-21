---
layout: post
title:  "Bicep Deployment Stack"
author: "Paulo Thüler"
categories: [ Development ]
tags: [ Azure, Bicep, Gitlab, CI/CD, IaC ]
image: assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack-avatar.png
description: "A scalable Bicep Deployment Stack to deploy your resources with Bicep, deployment stacks, and GitLab pipelines."
featured: true
hidden: false
---

## Table of Contents
- [Why stack?](#why-stack)
- [Pipeline Overview](#pipeline-overview)
- [Prerequisites](#prerequisites)
- [How To](#how-to)
- [Bicep Deployment](#bicep-deployment)
- [Pipeline Variables](#pipeline-variables)
- [Example](#example)
- [Related Links](#related-links)

# Why stack?

This guide describes a scalable Bicep Deployment Stack designed for efficient infrastructure deployment using Bicep, Azure Deployment Stacks, and GitLab pipelines. The solution is modular and reusable, following best practices for Infrastructure as Code (IaC).

![Bicep Deployment Stack](/assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack.png)

The image above illustrates a layered architecture for the Bicep Deployment Stack:

- **Docker Layer:** The `bicep-base-image` provides the foundational Docker image with all necessary tools for deployments within the pipeline or in a local devcontainer.
- **CI/CD Layer (GitLab):** The `bicep-deployment-stack` builds on the base image and provides the centralized pipeline definition `bicep.gitlab-ci.yml`.
- **Projects:** Individual deployments of infrastructure (e.g., `deployment 1`, `deployment 2`, etc.) that include the pipeline definition from the `bicep-deployment-stack` and represent specific Azure deployment scenarios.
- **Local Development Layer:** The local development environment uses Visual Studio Code and a `devcontainer`, leveraging the same image for consistency across environments.

Arrows labeled **`image`** indicate Docker image relationships, while arrows labeled **`include`** show how deployment modules are integrated in the diagram above. This structure ensures modularity, reusability, and consistency from local development to cloud deployment.

Both the `bicep-base-image` and the `bicep-deployment-stack` repositories are versioned and can be updated by a dependency bot like `Renovate`.

# Pipeline Overview

A high-level overview of the CI/CD pipeline stages and their roles in automating Bicep deployments to Azure.

![Bicep Deployment Stack Overview](/assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack-pipeline.png)

The image above illustrates the pipeline flow for a typical Bicep deployment project.

- Developer pushes Bicep code changes to GitLab using VS Code.
- The push triggers a GitLab CI pipeline defined in `bicep.gitlab-ci.yml`.
- The pipeline runs in a Docker-based GitLab Runner using the `bicep-base-image`.
- Pipeline steps:
  - Lint and build the Bicep code into ARM JSON files as artifacts.
  - Pass the artifacts to the validation and deployment stages.
  - Validate deployments for test and production using Azure PowerShell.
  - Deploy the validated code to Azure test and production environments.

# Prerequisites

Before you begin, ensure you have the following:

- An active Azure subscription
- Access to a GitLab instance (self-hosted or gitlab.com)
- Docker installed on your local machine or CI environment
- Basic knowledge of Bicep, Azure Resource Manager (ARM), and CI/CD concepts
- Visual Studio Code

# How To

1. Create an Azure Subscription.
2. Create an App Registration with a Client Secret. Add a Role Assignment with `Contributor` to your Subscriptions.
3. Add the following GitLab variables to your `bicep-deployment-stack`:
    - AZURE_TENANT_ID
    - AZURE_SUBSCRIPTION_TEST_ID
    - AZURE_SUBSCRIPTION_PROD_ID
    - AZURE_APPLICATION_ID
    - AZURE_CLIENT_SECRET (Masked)
4. Create three new repositories on GitLab:
   1. Repository for the base image with the Dockerfile.
   2. Repository for the deployment stack.
   3. Repository for the effective deployment of your infrastructure on Azure.

# Bicep Deployment

Just include the `bicep.gitlab-ci.yml` file in your project with the correct version `ref`.

```yaml
include: 
  - project: 'YOUR_BICEP_DEPLOYMENT_STACK_PATH'
    file: 'bicep.gitlab-ci.yml'
    ref: '1.0.41'
```

Here is the required file structure for your projects.

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

# Pipeline Variables

Key pipeline variables defined in the Bicep stack pipeline definition. Adjust these to fit your Azure environment and project needs.

> **NOTE:**  
> For example, if you want to deploy to another region, you can set the `AZURE_LOCATION` variable to `switzerlandnorth`.  
> Make sure there is an appropriate `.bicepparam` file in the `config` directory of the project.

```yaml
variables:
  AZURE_LOCATION: "westeurope"
  AZURE_DEPLOYMENT_NAME: "bicep-${ENVIRONMENT}-${AZURE_LOCATION}-deployment-stack"
  BICEP_SOURCE_DIR: "./src"
  BICEP_MAIN_FILE: "./src/main.bicep"
  BICEP_PARAMETERS_DIR: "./config"
  ARM_OUTPUT_DIR: "./artifacts"
  ARM_TEMPLATE_FILE: "./artifacts/main.json"
  ARM_PARAMETERS_FILE: "./artifacts/main-${ENVIRONMENT}-${AZURE_LOCATION}.parameters.json"
  DENY_SETTINGS_MODE: "None"
  ACTION_ON_UNMANAGE: "DeleteAll"
```

# Example

You can find a complete example project demonstrating the Bicep Deployment Stack, including pipeline configuration and sample infrastructure code, in the following repository:

[Bicep Deployment Stack on GitLab](https://gitlab.com/webflow-techblog/bicep-deployment-stack)

# Related Links

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Azure Documentation](https://learn.microsoft.com/en-us/azure/)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Docker Documentation](https://docs.docker.com/)
- [Infrastructure as Code (IaC) Concepts](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

---

For more details or questions, feel free to reach out or open an issue in the repository.

