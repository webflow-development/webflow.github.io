# Bicep Base Image

A foundational Docker image for building and deploying Bicep templates with Azure PowerShell.

## Overview

This project provides a Docker image pre-configured with the Bicep CLI and Azure PowerShell modules, streamlining the process of automating Azure infrastructure deployments. It's designed to offer a consistent and reliable environment for building, linting, and deploying Bicep templates.

## Features

*   **Bicep CLI:** Includes the Bicep command-line tool for compiling `.bicep` files into ARM templates.
*   **Azure PowerShell:** Equipped with the `Az.Accounts` and `Az.Resources` modules for authenticating and interacting with Azure resources.
*   **Ubuntu Based:** Utilizes a lightweight Ubuntu base image for optimal size and security.
*   **Script Automation:** Contains PowerShell scripts for common Bicep development tasks.

## Contents

The repository includes the following key components:

*   **Dockerfile:** Defines the steps to build the Docker image.
*   **scripts/:**
    *   `Build-Bicep.ps1`: Compiles a Bicep file into an ARM template JSON file.
    *   `Connect-Azure.ps1`: Connects to Azure using device code or service principal authentication.
    *   `Deploy-Bicep.ps1`: Deploys a Bicep template as a deployment stack at the subscription level.
    *   `Lint-Bicep.ps1`: Performs linting on Bicep template files.
*   **README.md:** This file, providing an overview of the project.

## Getting Started

### Prerequisites

*   Docker installed on your machine.

### Usage

1.  **Build the Image:**

    ```bash
    docker build -t bicep-base-image .
    ```

2.  **Run the Container:**

    ```bash
    docker run -it bicep-base-image pwsh
    ```

3.  **Connect to Azure:**

    Use the `Connect-Azure.ps1` script to connect to your Azure subscription.

    ```powershell
    /usr/local/bin/Connect-Azure.ps1 -UseDeviceAuthentication
    ```

    Or, using a service principal:

    ```powershell
    /usr/local/bin/Connect-Azure.ps1 -TenantId "your-tenant-id" -ApplicationId "your-app-id" -ClientSecret (ConvertTo-SecureString "your-secret" -AsPlainText -Force) -UseServicePrincipal
    ```

4.  **Build Bicep Templates:**

    Use the `Build-Bicep.ps1` script to compile your Bicep templates.

    ```powershell
    /usr/local/bin/Build-Bicep.ps1 -File "./main.bicep" -OutPath "./artifacts"
    ```

5.  **Lint Bicep Templates:**
    Use the `Lint-Bicep.ps1` script to analyze your Bicep templates.
    ```powershell
    /usr/local/bin/Lint-Bicep.ps1 -Path "."
    ```

6.  **Deploy Bicep Templates:**

    Use the `Deploy-Bicep.ps1` script to deploy your Bicep templates to Azure.

    ```powershell
    /usr/local/bin/Deploy-Bicep.ps1 -DeploymentName "my-deployment" -Location "eastus" -TemplateFile "./artifacts/main.json" -TemplateParameterFile "./artifacts/main.parameters.json"
    ```

## Configuration

The following environment variables can be used to configure the image:

*   `BICEP_VERSION`: Specifies the version of the Bicep CLI to install.
*   `AZ_RESOURCES_VERSION`: Specifies the version of the `Az.Resources` PowerShell module to install.

These can be overridden at build time using the `--build-arg` flag:

```bash
docker build --build-arg BICEP_VERSION="latest" -t bicep-base-image .
```

