<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-EnvironmentKey.ps1
          Solution: FightingEntropy Module
          Purpose: For retrieving and instantiating an environment key (branding, icons, certificates, etc)
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-EnvironmentKey
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Path,
        [Parameter()][Switch]$Convert
    )

    If (!(Test-Path $Path))
    {
        Throw "Invalid path"
    }

    If (Get-Item $Path | ? Extension -ne ".csv")
    {
        Throw "Invalid environment key"
    }

    $Key = Import-CSV $Path
    If ($Convert)
    {
        $Key = $Key | ConvertTo-Json
    }

    $Key
}
