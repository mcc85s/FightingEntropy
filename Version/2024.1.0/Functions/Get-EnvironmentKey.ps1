<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 17:13:57                                                                  //
 \\==================================================================================================// 

    FileName   : Get-EnvironmentKey.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : For retrieving and instantiating an environment key (branding/icons/certificates/etc.)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-EnvironmentKey
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Path,
        [Parameter()][Switch]$Convert
    )

    If (![System.IO.File]::Exists($Path))
    {
        Throw "Invalid path"
    }

    ElseIf ($Path -match "^.+\.csv")
    {
        Throw "Invalid environment key"
    }

    $Key = Import-Csv $Path
    If ($Convert)
    {
        $Key = $Key | ConvertTo-Json
    }

    $Key
}
