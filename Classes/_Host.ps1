Class _Host
{
    [String]                $Name = [Environment]::MachineName.ToLower()
    [String]                 $DNS
    [String]             $NetBIOS = [Environment]::UserDomainName.ToLower()

    [String]            $Hostname
    [String]            $Username = [Environment]::UserName
    [Object]           $Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    [Bool]               $IsAdmin
    [Object]             $Network

    _Host()
    {
        $This.DNS                 = @($Env:UserDNSDomain,"-")[!$env:USERDNSDOMAIN]
        $This.Hostname            = @($This.Name;"{0}.{1}" -f $This.Name, $This.DNS)[(Get-CimInstance Win32_ComputerSystem).PartOfDomain].ToLower()
        $This.IsAdmin             = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
        If ( $This.IsAdmin -eq 0 )
        {
            Throw "Must run as administrator"
        }
    }

    _Network()
    {
        $This.Network             = Get-FENetwork
    }
}
