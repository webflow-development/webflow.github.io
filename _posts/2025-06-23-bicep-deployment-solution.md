---
layout: post
title:  "Bicep Deployment Solution for GitLab"
author: "Paulo Thüler"
categories: [ Azure, GitLab ]
tags: [ Azure, Bicep, GitLab, CI/CD, IaC ]
image: assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-avatar.png
description: "A scalable Bicep Deployment Solution to deploy your resources with Bicep, Azure deployment stacks, and GitLab pipelines."
featured: false
hidden: false
---

> **TL;DR:**
> This guide shows how to set up a scalable, modular Bicep deployment solution using GitLab CI/CD and Docker for Azure. It covers prerequisites, pipeline structure, variables, and project setup. The solution ensures consistent, automated, and secure deployments from local development to production, leveraging reusable pipeline definitions and best practices for Infrastructure as Code (IaC).

- [Overview](#overview)
- [Solution](#solution)
    - [Benefits](#benefits)
- [Pipeline Overview](#pipeline-overview)
- [Prerequisites](#prerequisites)
- [How-To](#how-to)
- [Bicep Deployment](#bicep-deployment)
- [Pipeline Variables](#pipeline-variables)
- [Example](#example)
    - [Results](#results)
- [Related Links](#related-links)

# Overview

This guide describes a centralized and scalable Bicep Deployment Solution designed for efficient infrastructure deployment using Bicep, Azure Deployment Stacks, and GitLab pipelines. The solution is modular and reusable, following best practices for Infrastructure as Code (IaC).

# Solution

The following image illustrates the layered architecture of the Bicep Deployment Solution:

![Bicep Deployment Solution](/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution.png)

- **Docker Layer:** The `bicep-base-image` provides the foundational Docker image with all necessary tools for deployments within the pipeline or in a local dev container.
- **CI/CD Layer (GitLab):** The `bicep-deployment-solution` builds on the base image and provides the centralized pipeline definition `bicep.gitlab-ci.yml`.
- **Projects (GitLab):** Individual deployments of infrastructure (e.g., `deployment 1`, `deployment 2`, etc.) that include the pipeline definition from the `bicep-deployment-solution` and represent specific Azure deployment scenarios.
- **Local Development Layer:** The local development environment (VS Code) uses Visual Studio Code and a dev container, leveraging the same image for consistency across environments.

Arrows labeled **`image`** indicate which Docker image the pipeline will use, while arrows labeled **`include`** show how projects include the centralized and versioned pipeline definition `bicep.gitlab-ci.yml`. This structure ensures modularity, reusability, and consistency from local development to cloud deployment.

`bicep-base-image` and the `bicep-deployment-solution` repositories are versioned and can be updated by a dependency bot like Renovate.

### Benefits

- **Declarative:** Infrastructure as code for predictable, repeatable deployments.
- **Clear Output:** Actionable pipeline outputs for easy troubleshooting.
- **Consistent & Portable:** Same tools and process from local dev to production using Docker and dev containers.
- **Automated & Auditable:** Fast, transparent, reliable CI/CD with full change tracking in Git.
- **Collaborative & Testable:** Team workflows with code reviews and pre-deployment validation.
- **Scalable & Integrated:** Manage multiple environments with seamless GitLab, Azure, and Bicep integration.
- **Secure:** Built-in secrets and permissions management.
  

# Pipeline Overview

The image illustrates a high-level overview of the CI/CD pipeline stages and their roles in automating Bicep deployments to Azure.

![Bicep Deployment Pipeline Overview](/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-pipeline.png)

When a developer pushes Bicep code changes to GitLab using Visual Studio Code, the action triggers a GitLab CI pipeline defined in the `bicep.gitlab-ci.yml` file. This pipeline runs within a Docker-based GitLab Runner that uses the `bicep-base-image` to ensure a consistent environment. The pipeline first lints and builds the Bicep code, generating ARM JSON files as artifacts. These artifacts are then passed to the validation and deployment stages. The pipeline validates deployments for both test and production environments using Azure PowerShell, and upon successful validation, deploys the code as Azure deployment stacks to the respective Azure test and production environments.

# Prerequisites

Before you begin, ensure you have the following:
- Active Azure subscriptions
- Access to a GitLab instance (self-hosted or gitlab.com)
- Docker installed on your local machine or CI environment
- Basic knowledge of Bicep, Azure Resource Manager (ARM), and CI/CD concepts
- Visual Studio Code

# How-To

1. Create two Azure Subscriptions (Test and Production Environment).
2. Create an App Registration with a Client Secret. Add a Role Assignment with the `Contributor` role to your Subscriptions.
3. Create three new repositories on GitLab:
   1. Repository for the base image with the Dockerfile.
   2. Repository for the deployment solution.
   3. Repository for deploying your actual infrastructure to Azure.

Add the following GitLab CI/CD variables to your `bicep-deployment-solution` group in GitLab:

- `AZURE_TENANT_ID`: Azure Active Directory Tenant ID
- `AZURE_SUBSCRIPTION_TEST_ID`: Test Azure Subscription ID
- `AZURE_SUBSCRIPTION_PROD_ID`: Production Azure Subscription ID
- `AZURE_APPLICATION_ID`: Azure App Registration (Client) ID
- `AZURE_CLIENT_SECRET`: Azure App Registration Secret (Masked/Secret)

> **NOTE:**  
> For large-scale environments and improved security, it is recommended to use your own GitLab Runner infrastructure with Kubernetes. For each purpose, use a different service principal without client secrets, or use managed identities and assign permissions directly via RBAC.

# Bicep Deployment

To use the deployment solution, include the `bicep.gitlab-ci.yml` file in your project, specifying the correct version `ref`.

```yaml
include: 
  - project: 'YOUR_BICEP_DEPLOYMENT_SOLUTION_PATH'
    file: 'bicep.gitlab-ci.yml'
    ref: '1.0.xx'
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
    └───modules
            tags.bicep
            virtualmachine.bicep
```

# Pipeline Variables

Below are key variables defined in the `bicep-deployment-solution` pipeline. Adjust them to fit your Azure environment and project requirements.

> **NOTE:**  
> For example, if you want to deploy to another region, you can set the `AZURE_LOCATION` variable to `switzerlandnorth`.  
> Make sure there is an appropriate `.bicepparam` file in the `config` directory of the project.

```yaml
variables:
  AZURE_LOCATION: "westeurope"
  AZURE_DEPLOYMENT_NAME: "bicep-${ENVIRONMENT}-${AZURE_LOCATION}-deployment"
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

A complete example project demonstrating the Bicep Deployment Solution, including pipeline configuration and sample infrastructure code, is available in the following repository:

> **[Bicep Deployment Solution on GitLab](https://gitlab.com/webflow-techblog/examples/bicep-virtualmachine-deployment)**

### Results

This is how my example looks on Azure.

**Subscriptions**
<a href="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-subscriptions.png" target="_blank">
  <img src="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-subscriptions.png" alt="Subscriptions" style="max-width:100%; height:auto;" />
</a>

**Resource group**
<a href="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-rg.png" target="_blank">
  <img src="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-rg.png" alt="Resource Groups" style="max-width:100%; height:auto;" />
</a>

**Resources**
<a href="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-resources.png" target="_blank">
  <img src="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-resources.png" alt="Resources" style="max-width:100%; height:auto;" />
</a>

**Azure deployment stacks**
<a href="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-ads.png" target="_blank">
  <img src="/assets/2025-06-08-bicep-deployment-solution/bicep-deployment-solution-ads.png" alt="Azure deployment stacks" style="max-width:100%; height:auto;" />
</a>

# Related Links

- [Docker - Documentation](https://docs.docker.com/)
- [GitLab - CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Microsoft - Azure Deployment Stacks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks?tabs=azure-powershell)
- [Microsoft - Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Microsoft - Infrastructure as Code (IaC) Concepts](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)
- [Microsoft - Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers)
- [Paul Hammant - Trunk-Based Development](https://trunkbaseddevelopment.com/)

---

For more details or questions, feel free to reach out or open an issue in the repository.