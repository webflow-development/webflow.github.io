<#
.SYNOPSIS
    Performs linting on Bicep template files.

.DESCRIPTION
    This script performs linting on Bicep template files in the specified directory using the Bicep CLI.
    It can process files recursively and supports different diagnostic output formats.

.PARAMETER Path
    The path to search for Bicep files. Defaults to the current directory.

.PARAMETER DiagnosticsFormat
    The format for diagnostic output. Valid values include 'sarif' and 'json'.

.PARAMETER Recurse
    If specified, searches for Bicep files recursively in subdirectories.

.EXAMPLE
    .\Lint-Bicep.ps1 -Path './templates'
    Lints all Bicep files in the templates directory.

.EXAMPLE
    .\Lint-Bicep.ps1 -Path './templates' -Recurse -DiagnosticsFormat 'sarif'
    Recursively lints all Bicep files and outputs diagnostics in SARIF format.

.NOTES
    File Name      : Lint-Bicep.ps1
    Prerequisite   : Requires Bicep CLI to be installed and available in PATH
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, HelpMessage = "Path to search for Bicep files")]
    [ValidateNotNullOrEmpty()]
    [string]$Path = '.',
    
    [Parameter(Position = 1, HelpMessage = "Format for diagnostic output (e.g., Default, Sarif)")]
    [ValidateSet('Default', 'Sarif')]
    [ValidateNotNullOrEmpty()]
    [string]$DiagnosticsFormat = 'Default',

    [Parameter(HelpMessage = "Search for Bicep files recursively")]
    [ValidateNotNullOrEmpty()]
    [switch]$Recurse
)

# Set strict error handling
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Verify path exists
if (-not (Test-Path -Path $Path)) {
    throw "The specified path '$Path' does not exist."
}

try {
    # Ensure Bicep CLI is available
    if (-not (Get-Command bicep -ErrorAction SilentlyContinue)) {
        throw "Bicep CLI is not installed or not found in PATH"
    }

    Write-Output "Linting Bicep files in: $Path"
       
    # Get all .bicep files
    $searchParams = @{
        Path   = $Path
        Filter = "*.bicep"
        File   = $true
    }
    
    if ($Recurse) {
        $searchParams['Recurse'] = $true
    }
    
    $bicepFiles = Get-ChildItem @searchParams

    if ($bicepFiles.Count -eq 0) {
        Write-Warning "No Bicep files found in path: $Path"
        return
    }

    Write-Output "Found $($bicepFiles.Count) Bicep file(s)"

    $hasErrors = $false
    $processedFiles = 0
    $failedFiles = 0

    foreach ($file in $bicepFiles) {
        $processedFiles++
         Write-Output "Linting [$processedFiles/$($bicepFiles.Count)]: $($file.FullName)"
        
        try {
            $lintOutput = & bicep lint $file.FullName --diagnostics-format $DiagnosticsFormat 2>&1
            
            if ($LASTEXITCODE -ne 0) {
                $hasErrors = $true
                $failedFiles++
                Write-Warning "Linting failed for: $($file.FullName)"
                if ($lintOutput) {
                    Write-Warning $lintOutput                }
            }
            else {
                Write-Output "Successfully linted: $($file.FullName)"
            }
        }
        catch {
            $hasErrors = $true
            $failedFiles++
            Write-Error "Error processing $($file.FullName): $_"
        }
    }

    # Summary report
     Write-Output "`nLinting Summary:"
     Write-Output "----------------"
     Write-Output "Total files processed: $processedFiles"
     Write-Output "Successfully linted:   $($processedFiles - $failedFiles)"
     Write-Output "Failed:               $failedFiles"
    
    if ($hasErrors) {
        throw "Linting completed with errors in $failedFiles file(s)"
    }
    
     Write-Output "Linting completed successfully"
}
catch {
    Write-Error "Fatal error during linting process: $_"
    throw
}