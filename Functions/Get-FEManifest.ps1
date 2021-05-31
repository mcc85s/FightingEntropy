Function Get-FEManifest
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$Version)
    [_Manifest]::New($Version)
}
