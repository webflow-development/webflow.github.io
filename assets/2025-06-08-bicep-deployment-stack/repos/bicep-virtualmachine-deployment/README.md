# Bicep Virtualmachine Deployment

This repository contains Bicep templates for deploying a Windows Virtual Machine and its supporting Azure resources. The deployment includes a virtual network, public IP address, network security group, and tagging, all orchestrated via modular Bicep files.

## Repository Structure

- **src/**  
  Main Bicep templates and modules.
  - **main.bicep**: Entry point for the deployment.
  - **modules/**: Contains reusable Bicep modules:
    - `virtualnetwork.bicep`: Deploys a virtual network, public IP, and NSG.
    - `virtualmachine.bicep`: Deploys a Windows VM and its network interface.
    - `tags.bicep`: Applies resource tags.
- **config/**  
  Parameter files for different environments (dev, test, prod).
- **artifacts/**  
  Output directory for generated deployment files.
- **.devcontainer/**  
  Dev container configuration for consistent development environments.

## Local Development

1. Start the dev container
2. Run the following scripts
    * Lint-Bicep.ps1 -Path ./src -Recurse .
    * Build-Bicep.ps1 -File ./src/main.bicep -ParamFile ./config/main-dev-westeurope.bicepparam -OutPath ./artifacts
    * Deploy-Bicep.ps1 -DeploymentName "bicep-deployment-stack" -Location "westeurope" -TemplateFile ./artifacts/main.json -TemplateParameterFile ./artifacts/main-dev-westeurope.parameters.json -Test
    * Deploy-Bicep.ps1 -DeploymentName "bicep-deployment-stack" -Location "westeurope" -TemplateFile ./artifacts/main.json -TemplateParameterFile ./artifacts/main-dev-westeurope.parameters.json