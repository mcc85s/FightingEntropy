Function Get-FERole
{
    Class Win32_Client
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
        [UInt32]           $ReleaseID
        [String]                $Code
        [String]                 $SKU
        [String]             $Chassis
        [Object]               $Drive
        [Object]             $Process
        [Object]             $Network
        [Object]             $Service
        Hidden [String[]]      $Tools = ("ViperBomb Chocolatey" -Split " ")
        [Object]                $Tool
        [Object]             $Feature
        Win32_Client()
        {
            Get-FEHost                 | % { 

                $This.Name             = $_.Name
                $This.DNS              = $_.DNS
                $This.NetBIOS          = $_.NetBIOS
                $This.Hostname         = $_.Hostname
                $This.Username         = $_.UserName
                $This.Drive            = (Get-PSDrive)
            }

            $This.Principal           = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            $This.IsAdmin             = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
            If ( $This.IsAdmin -eq 0 )
            {
                Throw "Must run as administrator"
            }

            Get-FEInfo                 | % { 

                $This.Caption          = $_.Caption
                $This.Version          = $_.Version
                $This.Build            = $_.Build
                $This.ReleaseID        = $_.ReleaseID
                $This.Code             = "{0}/{1}" -f $_.CodeName,$_.Name
                $This.SKU              = $_.SKU
                $This.Chassis          = $_.Chassis
            }
        }
        GetServices()
        {
            $This.Service             = (Get-FEService)
        }
        GetProcesses()
        {
            $This.Process             = (Get-FEProcess)
        }
        GetNetwork()
        {
            $This.Network             = (Get-FENetwork)
        }
        GetFeatures()
        {
        
        }
        LoadEnvironmentKey([String]$Path)
        {
            $Key = Get-EnvironmentKey -Path $Path -Convert
            If ($Key)
            {
                New-EnvironmentKey -Key $Key | % Apply 
            }
        }
        Choco()
        {
            Invoke-Expression ( Invoke-RestMethod https://chocolatey.org/install.ps1 )
        }
    }

    Class Win32_Server
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
        [UInt32]           $ReleaseID
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
        Win32_Server()
        {
            Get-FEHost                 | % { 

                $This.Name             = $_.Name
                $This.DNS              = $_.DNS
                $This.NetBIOS          = $_.NetBIOS
                $This.Hostname         = $_.Hostname
                $This.Username         = $_.UserName
                $This.Drive            = (Get-PSDrive)
            }

            $This.Principal           = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            $This.IsAdmin             = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
            If ( $This.IsAdmin -eq 0 )
            {
                Throw "Must run as administrator"
            }

            Get-FEInfo                 | % { 

                $This.Caption          = $_.Caption
                $This.Version          = $_.Version
                $This.Build            = $_.Build
                $This.ReleaseID        = $_.ReleaseID
                $This.Code             = "{0}/{1}" -f $_.CodeName,$_.Name
                $This.SKU              = $_.SKU
                $This.Chassis          = $_.Chassis
            }
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
            Install-PackageProvider -Name NuGet -Confirm:$False -Force
            Find-Module -Name PoshRSJob | Install-Module -Confirm:$False -Force
        }
        LoadEnvironmentKey([String]$Path)
        {
            $Key = Get-EnvironmentKey -Path $Path -Convert
            If ($Key)
            {
                New-EnvironmentKey -Key $Key | % Apply 
            }
        }
        Choco()
        {
            Invoke-Expression ( Invoke-RestMethod https://chocolatey.org/install.ps1 )
        }
    }

    Class RHELCentOS
    {
        [Object] $Host
        [Object] $Info
        [Object] $Tools
        [Object] $Services
        [Object] $Processes
        [Object] $Network
        [Object] $Control
        RHELCentOS()
        {
            $This.Host      = @( )
            $This.Info      = @( )
            $This.Tools     = @( )
            $This.Services  = @( )
            $This.Processes = @( )
            $This.Network   = @( )
        }
    }

    Class Ubuntu
    {
        [Object] $Host
        [Object] $Info
        [Object] $Tools
        [Object] $Services
        [Object] $Processes
        [Object] $Network
        [Object] $Control
        Ubuntu()
        {
            $This.Host      = @( )
            $This.Info      = @( )
            $This.Tools     = @( )
            $This.Services  = @( )
            $This.Processes = @( )
            $This.Network   = @( )
        }
    }

    Class UnixBSD
    {
        [Object] $Host
        [Object] $Info
        [Object] $Tools
        [Object] $Services
        [Object] $Processes
        [Object] $Network
        [Object] $Control
        UnixBSD()
        {
            $This.Host      = @( )
            $This.Info      = @( )
            $This.Tools     = @( )
            $This.Services  = @( )
            $This.Processes = @( )
            $This.Network   = @( )
        }
    }

    Class Role
    {
        [String] $Name
        [Object] $Output
        Role([String]$Name)
        {
            $This.Name   = $Name
            $This.Output = Switch($Name)
            {
                Win32_Client 
                { 
                    [Win32_Client]::New() 
                } 
                Win32_Server 
                { 
                    [Win32_Server]::New() 
                } 
                UnixBSD      
                { 
                    [UnixBSD]::New()      
                } 
                Ubuntu
                {
                    [Ubuntu]::New()
                }
                RHELCentOS   
                { 
                    [RHELCentOS]::New()   
                }
            }
        }
    }

    $Type = Get-FEOS | % Type
    [Role]::New($Type).Output 
}
