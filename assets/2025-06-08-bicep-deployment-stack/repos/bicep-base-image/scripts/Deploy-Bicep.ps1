#Requires -Modules Az.Resources
<#
<#
.SYNOPSIS
    Deploys a Bicep template as a deployment stack at the subscription level.
.DESCRIPTION
    This script deploys Azure resources using a Bicep template. It supports testing, updating, and creating deployment stacks.
.PARAMETER DeploymentName
    The name of the deployment stack. Default: 'bicep-deployment-stack'.
.PARAMETER Location
    The Azure region for the deployment stack. Default: 'westeurope'.
.PARAMETER DenySettingsMode
    The deny settings mode for the deployment stack. Options: 'None', 'DenyDelete', 'DenyWriteAndDelete'. Default: 'None'.
.PARAMETER ActionOnUnmanage
    Action to take on unmanaged resources. Options: 'DeleteAll', 'Ignore'. Default: 'DeleteAll'.
.PARAMETER TemplateFile
    Path to the ARM template JSON file. Default: './artifacts/main.json'.
.PARAMETER TemplateParameterFile
    Path to the parameters file. Default: './artifacts/main.parameters.json'.
.PARAMETER Test
    Validates the deployment without making changes.
.EXAMPLE
    .\Deploy-Bicep.ps1 -DeploymentName "my-stack" -Location "eastus"
    Deploys a Bicep template with a custom name and location.
.EXAMPLE
    .\Deploy-Bicep.ps1 -Test
    Validates the deployment using default parameters.
.NOTES
    Requires the Az PowerShell module.
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, HelpMessage = "Name of the deployment stack")]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName = 'bicep-deployment-stack',

    [Parameter(Position = 1, HelpMessage = "Azure region for deployment")]
    [ValidateNotNullOrEmpty()]
    [string]$Location = 'westeurope',

    [Parameter(Position = 2, HelpMessage = "Deny settings mode for the deployment")]
    [ValidateSet('None', 'DenyDelete', 'DenyWriteAndDelete')]
    [string]$DenySettingsMode = 'None',

    [Parameter(Position = 3, HelpMessage = "Action to take on unmanaged resources")]
    [ValidateSet('DeleteAll', 'Ignore')]
    [string]$ActionOnUnmanage = 'DeleteAll',

    [Parameter(Position = 4, HelpMessage = "Path to the ARM template file")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$TemplateFile = './artifacts/main.json',

    [Parameter(Position = 5, HelpMessage = "Path to the parameters file")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$TemplateParameterFile = './artifacts/main.parameters.json',

    [Parameter(HelpMessage = "Test mode, no changes will be made")]
    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    Write-Output "Starting deployment process..."
    # Prepare deployment parameters
    $params = @{
        Name                  = $DeploymentName
        Location              = $Location
        DenySettingsMode      = $DenySettingsMode
        ActionOnUnmanage      = $ActionOnUnmanage
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
        Verbose               = $true
        Force                 = $true
    }

    # Log deployment parameters
    Write-Output "Deployment parameters:"
    foreach ($param in $params.Keys) {
        Write-Output "  $($param): $($params[$param])"
    }

    # Check if deployment stack already exists
    Write-Output "Checking for existing deployment stack '$DeploymentName'..."
    $existingStack = Get-AzSubscriptionDeploymentStack -Name $DeploymentName -ErrorAction SilentlyContinue
    Write-Output "Existing deployment stack: $($null -ne $existingStack)"
    if ($existingStack) {
        $existingStack = $existingStack[0]
        Write-Output "Deployment stack '$DeploymentName' already exists."
        Write-Verbose "  Name: $($existingStack.Name)"
        Write-Verbose "  State: $($existingStack.ProvisioningState)"
        Write-Verbose "  Location: $($existingStack.Location)"
        Write-Verbose "  Template File: $templateFile"
        Write-Verbose "  Template Parameter File: $templateParameterFile"
        Write-Verbose "  Resource Cleanup Action: $($existingStack.resourcesCleanupAction)"
        Write-Verbose "  ResourceGroups Cleanup Action: $($existingStack.resourceGroupsCleanupAction)"
        Write-Verbose "  ManagementGroups Cleanup Action: $($existingStack.managementGroupsCleanupAction)"
        Write-Verbose "  Created By: $($existingStack.systemData.CreatedBy)"
        Write-Verbose "  Created At: $($existingStack.systemData.CreatedAt)"
        Write-Verbose "  Last Modified By: $($existingStack.systemData.LastModifiedBy)"
        Write-Verbose "  Last Modified At: $($existingStack.systemData.LastModifiedAt)"
    }

    $deploymentScenario = if ($Test) {
        "Test"
    }
    elseif ($existingStack) {
        "Update"
    }
    else {
        "New"
    }

    $deployment = switch ($deploymentScenario) {
        "Test" {
            Write-Output "Validating deployment..."
            Test-AzSubscriptionDeploymentStack @params
        }
        "Update" {
            Write-Output "Updating deployment stack..."
            Set-AzSubscriptionDeploymentStack @params
        }
        "New" {
            Write-Output "Starting deployment..."
            New-AzSubscriptionDeploymentStack @params
        }
    }
}
catch {
    Write-Error "Deployment failed: $_"
    exit 1
}
