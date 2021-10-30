<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FERole.ps1
          Solution: FightingEntropy Module
          Purpose: For extended information regarding the host operating system, and hosts specialized functions
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-19
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FERole
{
    # [System Classes]
    Class SysNetwork
    {
        [String]$Name
        [UInt32]$Index
        [String]$IPAddress
        [String]$SubnetMask
        [String]$Gateway
        [String[]] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        SysNetwork([Object]$If)
        {
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway     | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = $IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DhcpServer = $IF.DhcpServer           | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
    }

    Class SysDisk
    {
        [String] $Name
        [String] $Label
        [String] $FileSystem
        [String] $Size
        [String] $Free
        [String] $Used
        SysDisk([Object]$Disk)
        {
            $This.Name       = $Disk.DeviceID
            $This.Label      = $Disk.VolumeName
            $This.FileSystem = $Disk.FileSystem
            $This.Size       = "{0:n2} GB" -f ($Disk.Size/1GB)
            $This.Free       = "{0:n2} GB" -f ($Disk.FreeSpace/1GB)
            $This.Used       = "{0:n2} GB" -f (($Disk.Size-$Disk.FreeSpace)/1GB)
        }
    }

    Class SysProcessor
    {
        [String]$Name
        [String]$Caption
        [String]$DeviceID
        [String]$Manufacturer
        [UInt32]$Speed
        SysProcessor([Object]$CPU)
        {
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.DeviceID     = $CPU.DeviceID
            $This.Manufacturer = $CPU.Manufacturer
            $This.Speed        = $CPU.MaxClockSpeed
        }
    }

    Class Win32_System
    {
        [Object] $Manufacturer
        [Object] $Model
        [Object] $Product
        [Object] $Serial
        [Object[]] $Processor
        [String] $Memory
        [String] $Architecture
        [Object] $UUID
        [Object] $Chassis
        [Object] $BiosUEFI
        [Object] $AssetTag
        [Object[]] $Disk
        [Object[]] $Network
        Win32_System()
        {
            Write-Host "Collecting [~] Disks"
            $This.Disk             = Invoke-Expression "[wmiclass]'Win32_LogicalDisk'" | % GetInstances | % { [SysDisk]$_ }
            
            Write-Host "Collecting [~] Network"
            $This.Network          = Invoke-Expression "[wmiclass]'Win32_NetworkAdapterConfiguration'" | % GetInstances | ? DefaultIPGateway | % { [SysNetwork]$_ }
            
            Write-Host "Collecting [~] Processor"
            $This.Processor        = Invoke-Expression "[wmiclass]'Win32_Processor' | % GetInstances" | % { [SysProcessor]$_ }
            
            Write-Host "Collecting [~] Computer"
            Invoke-Expression "[wmiclass]'Win32_ComputerSystem'" | % GetInstances | % { 

                $This.Manufacturer = $_.Manufacturer; 
                $This.Model        = $_.Model; 
                $This.Memory       = "{0}GB" -f [UInt32]($_.TotalPhysicalMemory/1GB)
            }

            Write-Host "Collecting [~] Product"
            Invoke-Expression "[wmiclass]'Win32_ComputerSystemProduct'" | % GetInstances | % { 

                $This.UUID         = $_.UUID 
            }

            Write-Host "Collecting [~] Motherboard"
            Invoke-Expression "[wmiclass]'Win32_BaseBoard'" | % GetInstances | % { 

                $This.Product      = $_.Product
                $This.Serial       = $_.SerialNumber -Replace "\.",""
            }
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }
        
            Write-Host "Collecting [~] Chassis"
            Invoke-Expression "[wmiclass]'Win32_SystemEnclosure'" | % GetInstances | % {

                $This.AssetTag    = $_.SMBIOSAssetTag.Trim()
                $This.Chassis     = Switch([UInt32]$_.ChassisTypes[0])
                {
                    {$_ -in 8..12+14,18,21} {"Laptop"}
                    {$_ -in 3..7+15,16}     {"Desktop"}
                    {$_ -in 23}             {"Server"}
                    {$_ -in 34..36}         {"Small Form Factor"}
                    {$_ -in 30..32+13}      {"Tablet"}
                }
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[$Env:PROCESSOR_ARCHITECTURE]
        }
        [String] ToString()
        {
            Return ("<[{0}]|[{1}]|[{2}]({3})>" -f $This.Manufacturer, $This.Model, $This.Memory, $This.Architecture)
        }
    }

    Class Win32_Client
    {
        [String]                $Name
        [String]                 $DNS
        [String]             $NetBIOS
        [String]            $Hostname
        [String]            $Username
        [Object]           $Principal
        [Bool]               $IsAdmin
        [Object]              $System
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
        
            If ($This.IsAdmin -eq 0)
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
        GetSystem()
        {
            $This.System               = [Win32_System]::New()
        }
        GetService()
        {
            $This.Service              = (Get-FEService)
        }
        GetProcess()
        {
            $This.Process              = (Get-FEProcess)
        }
        GetNetwork()
        {
            $This.Network              = (Get-FENetwork)
        }
        GetFeature()
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
            Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression
        }
        Status()
        {
            $This.GetSystem()
            $This.GetService()
            $This.GetProcess()
            $This.GetNetwork()
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
        [Object]              $System
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

            $This.Principal            = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
            $This.IsAdmin              = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
        
            If ($This.IsAdmin -eq 0)
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
        GetSystem()
        {
            $This.System               = [Win32_System]::New()
        }
        GetService()
        {
            $This.Service              = (Get-FEService)
        }
        GetProcess()
        {
            $This.Process              = (Get-FEProcess)
        }
        GetNetwork()
        {
            $This.Network              = (Get-FENetwork)
        }
        GetFeature()
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
            Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression
        }
        Status()
        {
            $This.GetSystem()
            $This.GetService()
            $This.GetProcess()
            $This.GetNetwork()
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
