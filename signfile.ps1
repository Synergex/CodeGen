<#
.SYNOPSIS
Signs a file using AzureSignTool.

.DESCRIPTION
This function wraps AzureSignTool to sign files using Azure Key Vault. It supports different verbosity levels and allows for application authentication.
More information for AzureSignTool can be found here: https://github.com/vcsjones/AzureSignTool
Examples for using AzureSignTool directly for pipelines can be found here: https://github.com/vcsjones/AzureSignTool/blob/main/WALKTHROUGH.md

.PARAMETER Description
The description to be embedded in the signed file.

.PARAMETER TargetFile
The path of one or more files to be signed.

.PARAMETER CertFile
The name of the certificate in Azure Key Vault to use for signing.

.PARAMETER SignSecret
The secret associated with the Azure Key Vault.

.PARAMETER Verbosity
Controls the verbosity level of the output. Valid values are 0, 1, or 2.

.PARAMETER ApplicationId
The GUID of the Azure application to be authenticated. Default value is the ID of rg-devops-prod

.PARAMETER DirectoryId
The GUID of the Azure directory for the application. Default value is the directory of rg-devops-prod

.EXAMPLE
Azure-SignFile -Description "My Application" -TargetFile "path\to\file.exe" -CertFile "myCert" -SignSecret "secret" -Verbosity 1
#>

function Azure-SignFile
{
    param (
        [Parameter(Mandatory)]
        [string] $CertFile,
        [Parameter(Mandatory)]
        [string] $SignSecret,
        [Parameter(Mandatory)]
        [string] $Description,
        [Parameter(Mandatory)]
        [string[]] $TargetFile,
        [Parameter()]
        [int] $Verbosity,
        [Parameter()]
        [string] $ApplicationId,
        [Parameter()]
        [string] $DirectoryId
    )

    $signtool = "$env:userprofile\.dotnet\tools\AzureSignTool.exe"
    if (!(Test-Path "$signtool" -PathType leaf))
    {
        $toolInstall = Start-Process -FilePath "dotnet.exe" -ArgumentList "tool install --global azuresigntool" -Wait -NoNewWindow -PassThru
        if ($toolInstall.ExitCode -ne 0)
        {
            Write-Host "Failed to install azuresigntool"
            return;
        }
    }

    $sVerbosity = "-q"
    if ($Verbosity -eq 1)
    {
        $sVerbosity = ""
    }
    elseif ($Verbosity -eq 2)
    {
        $sVerbosity = "-v"  
    }

    if ($Verbosity -eq 2)
    {
        Write-Host "Signing $TargetFile"
    }
    $arguments = "sign
        $sVerbosity
        -tr `"http://timestamp.digicert.com`"
        -td sha256
        -fd sha256
        -d `"$Description`"
        -du `"https://www.synergex.com`"
        -kvu `"https://kv-synergex-premium-prod.vault.azure.net`"
        -kvs `"$SignSecret`"
        -kvi `"$ApplicationId`"
        -kvt `"$DirectoryId`"
        -kvc `"$CertFile`"
        $TargetFile" -replace "`n","" -replace "`r","";

    $signResult = Start-Process -FilePath "$signtool" -Wait -NoNewWindow -PassThru -ArgumentList $arguments
    if ($signResult.ExitCode -ne 0)
    {
        Write-Error "Failed to sign files";
    }
}