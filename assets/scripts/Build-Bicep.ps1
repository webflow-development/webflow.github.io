<#
.SYNOPSIS
    Builds a Bicep file into an ARM template.
.DESCRIPTION
    Compiles the specified Bicep file into an ARM (Azure Resource Manager) template JSON file.
.PARAMETER File
    Path to the source Bicep file. Defaults to './main.bicep'.
.PARAMETER Outfile
    Destination path for the compiled ARM template. Defaults to './artifacts/main.json'.
.EXAMPLE
    .\Build-Bicep.ps1 -File './src/main.bicep' -Outfile './artifacts/main.json'
.NOTES
    Requires Bicep CLI to be installed and available in the system path.
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$File = './main.bicep',

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$ParamFile = './main.bicepparam',

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$OutPath = './artifacts'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    # Ensure Bicep CLI is available
    if (-not (Get-Command bicep -ErrorAction SilentlyContinue)) {
        throw "Bicep CLI is not installed or not found in PATH"
    }

    # Ensure source files exist
    if (-not (Test-Path $File)) {
        throw "Source file '$File' not found"
    }

    if (-not (Test-Path $ParamFile)) {
        throw "Parameter file '$ParamFile' not found"
    }

    # Create output directory if it doesn't exist
    if (-not (Test-Path $OutPath)) {
        New-Item -ItemType Directory -Path $OutPath -Force | Out-Null
    }

    # Define output files
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($File)
    $Outfile = Join-Path $OutPath "$fileName.json"
    $paramOutFile = Join-Path $OutPath "$([System.IO.Path]::GetFileNameWithoutExtension($ParamFile)).parameters.json"

    Write-Output "Building Bicep file: $File"
    Write-Output "Parameter file: $ParamFile"
    Write-Output "Output location: $Outfile"
    Write-Output "Parameter file output location: $paramOutFile"
    
    # Build the Bicep file and parameters
    bicep build $File --outfile $Outfile
    if ($LASTEXITCODE -ne 0) {
        throw "Bicep compilation failed with exit code: $LASTEXITCODE"
    }

    bicep build-params $ParamFile --outfile $paramOutFile
    if ($LASTEXITCODE -ne 0) {
        throw "Bicep parameter compilation failed with exit code: $LASTEXITCODE"
    }

    Write-Output "Successfully compiled Bicep file to: $Outfile"
    Write-Output "Successfully compiled Bicep parameters to: $paramOutFile"
}
catch {
    Write-Error "Error building Bicep file: $_"
    exit 1
}