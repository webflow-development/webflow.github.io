---
layout: post
title:  "Bicep Deployment Stack"
author: "Paulo Thüler"
categories: [ Azure ]
tags: [ Azure, Bicep, Gitlab, CI/CD, IaC ]
image: assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack-avatar.png
description: "A scalable Bicep Deployment Stack to deploy your resources with Bicep, deployment stacks, and GitLab pipelines."
featured: true
hidden: false
---

# THIS IS A DRAFT

## Table of Contents
- [THIS IS A DRAFT](#this-is-a-draft)
  - [Table of Contents](#table-of-contents)
- [Why stack?](#why-stack)
- [Pipeline Overview](#pipeline-overview)
- [Prerequisites](#prerequisites)
  - [Components](#components)
    - [1. Azure Subscription](#1-azure-subscription)
    - [2. GitLab Runner](#2-gitlab-runner)
    - [3. Docker Image with Tooling](#3-docker-image-with-tooling)
    - [4. Stack Repository](#4-stack-repository)
    - [5. Inheritable Pipeline Definition](#5-inheritable-pipeline-definition)
    - [6. Stack Versioning](#6-stack-versioning)
- [How To](#how-to)
- [Bicep Deployment](#bicep-deployment)
- [Related Links](#related-links)

# Why stack?

This guide describes a scalable Bicep Deployment Stack designed for efficient infrastructure deployment using Bicep, Azure Deployment Stacks, and GitLab pipelines. The solution is modular and reusable, following best practices for Infrastructure as Code (IaC).

![Bicep Deployment Stack](/assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack.png)

The image above illustrates a layered architecture for the Bicep Deployment Stack:

- **Docker Layer:** The `bicep-base-image` provides the foundational Docker image for deployments.
- **CI/CD Layer (GitLab):** The `bicep-deployment-stack` builds on the base image and orchestrates deployments, including multiple deployment modules.
- **Azure Layer:** Individual deployment modules (e.g., `deployment 1`, `deployment 2`, etc.) are included by the stack and represent specific Azure deployment scenarios.
- **Local Development Layer:** The local development environment uses Visual Studio Code and a `devcontainer`, leveraging the same image for consistency across environments.

Arrows labeled **`image`** indicate Docker image relationships, while arrows labeled **`include`** show how deployment modules are integrated in the diagram above. This structure ensures modularity, reusability, and consistency from local development to cloud deployment.

# Pipeline Overview

![Bicep Deployment Stack Overview](/assets/2025-06-08-bicep-deployment-stack/bicep-deployment-stack-pipeline.png)

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

