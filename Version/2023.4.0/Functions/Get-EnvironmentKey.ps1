<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:43:13                                                                  //
 \\==================================================================================================// 

    FileName   : Get-EnvironmentKey.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For retrieving and instantiating an environment key (branding/icons/certificates/etc.)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
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
