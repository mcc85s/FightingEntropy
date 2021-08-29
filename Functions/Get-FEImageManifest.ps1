Function Get-FEImageManifest
{
    [CmdLetBinding()]Param(
        [Paramter(Mandatory,Position=0)][String]$Path,
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
