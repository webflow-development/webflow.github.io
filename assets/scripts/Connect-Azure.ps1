#Requires -Modules Az.Accounts
<#
.SYNOPSIS
    Connects to Azure using device code or service principal authentication.
.DESCRIPTION
    This script connects to Azure using the Az PowerShell module, supporting device code and service principal authentication. 
    For service principal, provide TenantId, ApplicationId, and ClientSecret.
.PARAMETER TenantId
    The Azure AD tenant ID for service principal authentication.
.PARAMETER SubscriptionId
    The Azure Subscription ID to connect to.  If not specified, the default subscription will be used.
.PARAMETER ApplicationId
    The Application (client) ID of the service principal.
.PARAMETER ClientSecret
    The client secret of the service principal as a SecureString.
.PARAMETER UseServicePrincipal
    Switch to enable service principal authentication.
.EXAMPLE
    .\Connect-Azure.ps1
    Connects to Azure using device code authentication.
.EXAMPLE
    .\Connect-Azure.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
    Connects to Azure using device code and sets the specified subscription.
.EXAMPLE
        .\Connect-Azure.ps1 -TenantId "tenant-id" -ApplicationId "app-id" `
        -ClientSecret (ConvertTo-SecureString "your-secret" -AsPlainText -Force) `
        -UseServicePrincipal
    Connects using a service principal with a secure secret.
.NOTES
    Requires the Az PowerShell module.  Service principal requires necessary Azure AD permissions.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId,

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationId,

    [Parameter(Position = 3)]
    [ValidateNotNullOrEmpty()]
    [SecureString]$ClientSecret,

    [Parameter(Position = 4)]
    [switch]$UseServicePrincipal
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    Write-Output "Attempting to connect to Azure..."
    $params = @{}

    if ($UseServicePrincipal) {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $ClientSecret
        $params['TenantId'] = $TenantId
        $params['SubscriptionId'] = $SubscriptionId
        $params['Credential'] = $Credential
        $params['ServicePrincipal'] = $true
    }
    else {
        Write-Output "No subscription specified, using device code authentication..."
        $params['UseDeviceAuthentication'] = $true
    }

    $connection = Connect-AzAccount @params
    
    if ($connection) {
        $Context = Get-AzContext
        Write-Output "Successfully connected to Azure"
        Write-Output "Subscription '$($Context.Subscription.Name)' ($($Context.Subscription.Id))"
    }
}
catch {
    Write-Error "Failed to connect to Azure: $_"
    exit 1
}