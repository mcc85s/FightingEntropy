<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:50:03                                                                  //
 \\==================================================================================================// 

    FileName   : Get-FEImageManifest.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : For retrieving a list of images to use on a forward FE Server
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

Function Get-FEImageManifest
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)][String]$Path,
        [Parameter(Mandatory,Position=1)][String]$Source,
        [Parameter(Mandatory,Position=2)][String]$Destination
    )

    If (!(Test-Path $Source))
    {
        Throw "Invalid image source path"
    }

    If (Test-Path $Path)
    {
        $Manifest = Get-Content $Path
    }

    If (!(Test-Path $Destination))
    {
        New-Item $Destination -ItemType Directory -Verbose
    }

    ForEach ( $File in $Manifest )
    {
        If (!(Test-Path "$Source\$File"))
        {
            Write-Warning "Invalid file in manifest"
        }

        Else
        {
            Copy-FileStream -Source "$Source\$File" -Destination "$Destination\$File" 
        }
    }
}
