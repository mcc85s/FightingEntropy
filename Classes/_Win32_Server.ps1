Class _Win32_Server
{
    [String]                $Name
    [String]                 $DNS
    [String]             $NetBIOS

    [String]            $Hostname
    [String]            $Username
    [Object]           $Principal
    [Bool]               $IsAdmin

    [String]             $Caption
    [String]             $Version
    [UInt32]               $Build
    [UInt32]          $ReleasedID
    [String]                $Code
    [String]                 $SKU
    [String]             $Chassis
    [Object]               $Drive
    [Object]             $Process
    
    [Object]             $Network
    [Object]             $Service

    Hidden [String[]]      $Tools = ("ViperBomb Chocolatey MDT WinPE WinADK WDS IIS/BITS ASP.Net DNS DHCP ADDS" -Split " ")
    [Object]                $Tool
    [Object]             $Feature

    _Win32_Server()
    {
        $This.Principal           = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $This.IsAdmin             = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
        If ( $This.IsAdmin -eq 0 )
        {
            Throw "Must run as administrator"
        }

        [_Info]::New()             | % { 

            $This.Caption          = $_.Caption
            $This.Version          = $_.Version
            $This.Build            = $_.Build
            $This.ReleasedID       = $_.ReleaseID
            $This.Code             = "{0}/{1}" -f $_.CodeName,$_.Name
            $This.SKU              = $_.SKU
            $This.Chassis          = $_.Chassis
        }

        $This.Initialize()
    }

    Initialize()
    {
        $This.Name                = [Environment]::MachineName.ToLower()
        $This.DNS                 = @($Env:UserDNSDomain,"-")[!$env:USERDNSDOMAIN]
        $This.NetBIOS             = [Environment]::UserDomainName.ToLower()

        $This.Hostname            = @($This.Name;"{0}.{1}" -f $This.Name, $This.DNS)[(Get-CimInstance Win32_ComputerSystem).PartOfDomain].ToLower()
        $This.Username            = [Environment]::UserName
        $This.Drive               = (Get-PSDrive)
    }
    
    GetServices()
    {
        $This.Service             = (Get-FEService)
    }
    
    GetProcesses()
    {
        $This.Process             = (Get-Process)
    }
    
    GetNetwork()
    {
        $This.Network             = (Get-FENetwork)
    }

    GetFeatures()
    {
        
    }
}
