# Just a rough idea I had in relation to [Security.Principal..] based objects
Class RoleLabelItem
{
    [Uint32] $Index
    [String] $Name
    [UInt32] $IsInRole
    RoleLabelItem([UInt32]$Index,[String]$Name,[UInt32]$IsInRole)
    {
        $This.Index    = $Index
        $This.Name     = $Name
        $This.IsInRole = $IsInRole
    }
}

Class RoleList
{
    [Object] $Identity
    [Object] $Output
    RoleList()
    {
        $This.Refresh()
    }
    [Object] GetIdentity()
    {
        Return [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    }
    [Object] RoleLabelItem([UInt32]$Index,[String]$Name,[UInt32]$IsInRole)
    {
        Return [RoleLabelItem]::New($Index,$Name,$IsInRole)
    }
    [String[]] GetBuiltInRole()
    {
        Return [System.Enum]::GetNames([Security.Principal.WindowsBuiltInRole])
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Identity = $This.GetIdentity()
        $This.Clear()

        ForEach ($Item in $This.GetBuiltInRole())
        {
            $This.Output += $This.RoleLabelItem($This.Output.Count,$Item,$This.Identity.IsInRole($Item))
        }
    }
}

$Role = [RoleList]::New()
<#
$Role.Output

Index Name            IsInRole
----- ----            --------
    0 Administrator          0
    1 User                   0
    2 Guest                  0
    3 PowerUser              0
    4 AccountOperator        0
    5 SystemOperator         0
    6 PrintOperator          0
    7 BackupOperator         0
    8 Replicator             0
#>
$Role.Identity.IsInRole("Administrators")
