Function Add-ACL
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory)][String]$Path,
        [Parameter(Mandatory)][System.Security.AccessControl.FileSystemAccessRule] $ACL
    )

    Get-ACL -Path $Path | % AddAccessRule $ACL | % { Set-ACL -Path $Path -AclObject $_ }
}
