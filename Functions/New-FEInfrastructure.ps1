<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: New-FEInfrastructure.ps1
          Solution: FightingEntropy Infrastructure Deployment Tool
          Purpose: For deploying virtual and physical infrastructure, including gateways and servers for ADDS
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-09-11
          Modified: 2021-10-05

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:

.Example
#>

Function New-FEInfrastructure
{
    # Load Assemblies
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms
    Import-Module FightingEntropy

    # Check for server operating system
    If (Get-CimInstance Win32_OperatingSystem | ? Caption -notmatch Server)
    {
        Throw "Must use Windows Server operating system"
    }

    If ($PSVersionTable.PSEdition -eq "Core")
    {
        Throw "Must use PowerShell v5 for MDT"
    }

    # [Location Classes]
    Class States
    {
        Static [Hashtable] $List            = @{

            "Alabama"                       = "AL" ; "Alaska"                        = "AK" ;
            "Arizona"                       = "AZ" ; "Arkansas"                      = "AR" ;
            "California"                    = "CA" ; "Colorado"                      = "CO" ;
            "Connecticut"                   = "CT" ; "Delaware"                      = "DE" ;
            "Florida"                       = "FL" ; "Georgia"                       = "GA" ;
            "Hawaii"                        = "HI" ; "Idaho"                         = "ID" ;
            "Illinois"                      = "IL" ; "Indiana"                       = "IN" ;
            "Iowa"                          = "IA" ; "Kansas"                        = "KS" ;
            "Kentucky"                      = "KY" ; "Louisiana"                     = "LA" ;
            "Maine"                         = "ME" ; "Maryland"                      = "MD" ;
            "Massachusetts"                 = "MA" ; "Michigan"                      = "MI" ;
            "Minnesota"                     = "MN" ; "Mississippi"                   = "MS" ;
            "Missouri"                      = "MO" ; "Montana"                       = "MT" ;
            "Nebraska"                      = "NE" ; "Nevada"                        = "NV" ;
            "New Hampshire"                 = "NH" ; "New Jersey"                    = "NJ" ;
            "New Mexico"                    = "NM" ; "New York"                      = "NY" ;
            "North Carolina"                = "NC" ; "North Dakota"                  = "ND" ;
            "Ohio"                          = "OH" ; "Oklahoma"                      = "OK" ;
            "Oregon"                        = "OR" ; "Pennsylvania"                  = "PA" ;
            "Rhode Island"                  = "RI" ; "South Carolina"                = "SC" ;
            "South Dakota"                  = "SD" ; "Tennessee"                     = "TN" ;
            "Texas"                         = "TX" ; "Utah"                          = "UT" ;
            "Vermont"                       = "VT" ; "Virginia"                      = "VA" ;
            "Washington"                    = "WA" ; "West Virginia"                 = "WV" ;
            "Wisconsin"                     = "WI" ; "Wyoming"                       = "WY" ;
            "American Samoa"                = "AS" ; "District of Columbia"          = "DC" ;
            "Guam"                          = "GU" ; "Marshall Islands"              = "MH" ;
            "Northern Mariana Island"       = "MP" ; "Puerto Rico"                   = "PR" ;
            "Virgin Islands"                = "VI" ; "Armed Forces Africa"           = "AE" ;
            "Armed Forces Americas"         = "AA" ; "Armed Forces Canada"           = "AE" ;
            "Armed Forces Europe"           = "AE" ; "Armed Forces Middle East"      = "AE" ;
            "Armed Forces Pacific"          = "AP" ;
        }
        Static [String] Name([String]$Code)
        {
            Return @( [States]::List | % GetEnumerator | ? Value -match $Code | % Name )
        }
        Static [String] Code([String]$State)
        {
            Return @( [States]::List | % GetEnumerator | ? Name -eq $State | % Value )
        }
        States(){}
    }

    Class ZipEntry
    {
        [String]       $Zip
        [String]      $Type
        [String]      $Name
        [String]     $State
        [String]   $Country
        [String]      $Long
        [String]       $Lat
        ZipEntry([String]$Line)
        {
            $String         = $Line -Split "`t"
            
            $This.Zip       = $String[0]
            $This.Type      = @("UNIQUE","STANDARD","PO_BOX","MILITARY")[$String[1]]
            $This.Name      = $String[2]
            $This.State     = $String[3]
            $This.Country   = $String[4]
            $This.Long      = $String[5]
            $This.Lat       = $String[6]
        }
        ZipEntry([UInt32]$Zip)
        {
            $This.Zip       = $Zip
            $This.Type      = "Invalid"
            $This.Name      = "N/A"
            $This.State     = "N/A"
            $This.Country   = "N/A"
            $This.Long      = "N/A"
            $This.Lat       = "N/A"
        }
    }

    Class ZipStack
    {
        [String]      $Path
        [Object]   $Content
        [Object]     $Stack
        ZipStack([String]$Path)
        {
            $This.Path    = $Path
            $This.Content = Get-Content $Path | ? Length -gt 0
            $This.Stack   = @{ }
            $X            = 0
            ForEach ( $Item in $This.Content )
            {
                $This.Stack.Add($Item.Substring(0,5),$X)
                $X ++
            }
        }
        [Object] ZipTown([String]$Zip)
        {
            $Index = $This.Stack["$Zip"]
            If (!$Index)
            {
                Return [ZipEntry][UInt32]$Zip
            }

            Return [ZipEntry]$This.Content[$Index]
        }
    }
    
    Class Scope
    {
        [String]  $Name
        [String]$Network
        Hidden [UInt32[]]$Network_
        [UInt32] $Prefix
        [String]$Netmask
        Hidden [UInt32[]]$Netmask_
        [UInt32]$HostCount
        [Object]$HostObject
        [String]$Start
        [String]$End
        [String]$Range
        [String]$Broadcast
        [Object] GetSubnetMask([UInt32]$Int)
        {
            $Bin   = @(0..($Int-1) | % {1};$Int..31| % {0})
            $Hash  = @{ }
            $Mask  = @{ }
            0..3 | % {

                $Hash.Add($_,$Bin[($_*8)..(($_*8) + 8)])
                $Mask.Add($_,(@(ForEach ($I in 0..7 )
                { 
                    Switch($Hash[$_][$I])
                    {
                        0 { 0 }
                        1 { (128,64,32,16,8,4,2,1)[$I] }
                    }
                }) -join "+" | Invoke-Expression ))
            }

            Return @( $Mask[0..3] -join '.' )
        }
        Scope([String]$Prefix)
        {
            $This.Name     = $Prefix
            $Object        = $Prefix.Split("/")
            $This.Network  = $Object[0]
            $This.Prefix   = $Object[1]
            $This.Netmask  = $This.GetSubnetMask($Object[1])
            $This.Remain()
        }
        Scope([String]$Network,[String]$Prefix,[String]$Netmask)
        {
            $This.Name       = "$Network/$Prefix"
            $This.Network    = $Network
            $This.Prefix     = $Prefix
            $This.Netmask    = $Netmask
            $This.Remain()
        }
        Remain()
        {
            $This.Network_   = $This.Network -Split "\."
            $This.Netmask_   = $This.Netmask -Split "\."

            $WC             = ForEach ( $X in 0..3 )
            { 
                Switch($This.Netmask_[$X])
                {
                    255 { 1 } 0 { 256 } Default { 256 - $This.Netmask_[$X] }
                }
            }

            $This.HostCount = (Invoke-Expression ($WC -join "*")) - 2
            $SRange = @{}

            ForEach ( $X in 0..3 )
            {
                $SRange.Add($X,@(Switch($WC[$X])
                {
                    1 { $This.Network_[$X] }
                    Default 
                    {
                        "{0}..{1}" -f $This.Network_[$X],(([UInt32]$This.Network_[$X] + (256-$This.Netmask_[$X]))-1)
                    }
                    256 { "0..255" }
                }))
            }

            $This.Range      = @( 0..3 | % { $SRange[$_] }) -join '/'

            $XRange          = @{ }

            ForEach ( $0 in $SRange[0] | Invoke-Expression )
            {
                ForEach ( $1 in $SRange[1] | Invoke-Expression )
                {
                    ForEach ( $2 in $SRange[2] | Invoke-Expression )
                    {
                        ForEach ( $3 in $SRange[3] | Invoke-Expression )
                        {
                            $XRange.Add($XRange.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.HostObject = @( 0..($XRange.Count-1) | % { $XRange[$_] } )
            $This.Start     = $This.HostObject[1]
            $This.End       = $This.HostObject[-2]
            $This.Broadcast = $This.HostObject[-1]
        }
        [String] ToString()
        {
            Return @($This.Network)
        }
    }
    
    Class Network
    {
        [String]$Network
        [String]$Prefix
        [String]$Netmask
        [Object[]]$Aggregate
        Network([String]$Network)
        {
            $Hash           = @{ }
            $NetworkHash    = @{ }
            $NetmaskHash    = @{ }
            $HostHash       = @{ }

            $This.Network   = $Network.Split("/")[0]
            $This.Prefix    = $Network.Split("/")[1]

            $NWSplit        = $This.Network.Split(".")
            $BinStr         = "{0}{1}" -f ("1" * $this.Prefix),("0" * (32-$This.Prefix))

            ForEach ( $I in 0..3 )
            {
                $Hash.Add($I,$BinStr.Substring(($I*8),8).ToCharArray())
            }

            ForEach ( $I in 0..3 )
            {
                Switch([UInt32]("0" -in $Hash[$I]))
                {
                    0
                    {
                        $NetworkHash.Add($I,$NWSplit[$I])
                        $NetmaskHash.Add($I,255)
                        $HostHash.Add($I,1)
                    }

                    1
                    {
                        $NwCt = ($Hash[$I] | ? { $_ -eq "1" }).Count
                        $HostHash.Add($I,(256,128,64,32,16,8,4,2,1)[$NwCt])

                        If ( $NwCt -eq 0)
                        {
                            $NetworkHash.Add($I,0)
                            $NetmaskHash.Add($I,0)
                        }

                        Else
                        {
                            $NetworkHash.Add($I,(128,64,32,16,8,4,2,1)[$NwCt-1])
                            $NetmaskHash.Add($I,(128,192,224,240,248,252,254,255)[$NwCt-1])
                        }
                    }
                }
            }

            $This.Netmask = $NetmaskHash[0..3] -join '.'

            $Hosts   = @{ }

            ForEach ( $I in 0..3 )
            {
                Switch ($HostHash[$I])
                {
                    1
                    {
                        $Hosts.Add($I,$NetworkHash[$I])
                    }

                    256
                    {
                        $Hosts.Add($I,0)
                    }

                    Default
                    {
                        $Hosts.Add($I,@(0..255 | ? { $_ % $HostHash[$I] -eq 0 }))
                    }
                }
            }

            $Wildcard = $HostHash[0..3] -join ','

            $Contain = @{ }

            ForEach ( $0 in $Hosts[0] )
            {
                ForEach ( $1 in $Hosts[1] )
                {
                    ForEach ( $2 in $Hosts[2] )
                    {
                        ForEach ( $3 in $Hosts[3] )
                        {
                            $Contain.Add($Contain.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.Aggregate = 0..( $Contain.Count - 1 ) | % { [Scope]::New($Contain[$_],$This.Prefix,$This.Netmask) }
        }
    }

    Class IPConfig
    {
        [String]   $Alias
        [UInt32]   $Index
        [String]   $Description
        [String]   $Profile
        [String[]] $IPV4Address
        [String]   $IPV4Gateway
        [String[]] $IPV6Address
        [String]   $IPV6Gateway
        [String[]] $DnsServer
        IPConfig([Object]$Ip)
        {
            $This.Alias       = $IP.InterfaceAlias
            $This.Index       = $IP.InterfaceIndex
            $This.Description = $IP.InterfaceDescription
            $This.Profile     = $IP.NetProfile.Name
            $This.IPV4Address = $IP.IPV4Address | % IPAddress
            $This.IPV4Gateway = $IP.IPV4DefaultGateway | % NextHop
            $This.IPV6Address = $IP.IPV6Address | % IPAddress
            $This.IPV6Address = $IP.IPV6DefaultGateway | % NextHop
            $This.DNSServer   = $IP.DNSServer | % ServerAddresses
        }
    }

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

    Class System
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
        System()
        {
            Write-Host "Collecting [~] Disks"
            $This.Disk             = Get-WmiObject -Class Win32_LogicalDisk    | % {     [SysDisk]$_ }
            
            Write-Host "Collecting [~] Network"
            $This.Network          = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | ? DefaultIPGateway | % { [SysNetwork]$_ }
            
            Write-Host "Collecting [~] Processor"
            $This.Processor        = Get-WmiObject -Class Win32_Processor      | % { [SysProcessor]$_ }
            
            Write-Host "Collecting [~] Computer"
            Get-WmiObject Win32_ComputerSystem        | % { 

                $This.Manufacturer = $_.Manufacturer; 
                $This.Model        = $_.Model; 
                $This.Memory       = "{0}GB" -f [UInt32]($_.TotalPhysicalMemory/1GB)
            }

            Write-Host "Collecting [~] Product"
            Get-WmiObject Win32_ComputerSystemProduct | % { 
                $This.UUID         = $_.UUID 
            }

            Write-Host "Collecting [~] Motherboard"
            Get-WmiObject Win32_BaseBoard             | % { 
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
            Get-WmiObject Win32_SystemEnclosure | % {
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
    }

    # [Dhcp Classes]
    Class DhcpServerv4Reservation
    {
        [String] $IPAddress
        [String] $ClientID
        [String] $Name
        [String] $Description
        DhcpServerv4Reservation([Object]$Res)
        {
            $This.IPAddress   = $Res.IPAddress
            $This.ClientID    = $Res.ClientID
            $This.Name        = $Res.Name
            $This.Description = $Res.Description
        }
    }

    Class DhcpServerV4OptionValue
    {
        [UInt32] $OptionID
        [String] $Name
        [String] $Type
        [String] $Value
        DhcpServerV4OptionValue([Object]$Opt)
        {
            $This.OptionID = $Opt.OptionID
            $This.Name     = $Opt.Name
            $This.Type     = $Opt.Type
            $This.Value    = $Opt.Value -join ", "
        }
    }

    Class DhcpServerv4Scope
    {
        [String] $ScopeID
        [String] $SubnetMask
        [String] $Name
        [UInt32] $State
        [String] $StartRange
        [String] $EndRange
        [Object[]] $Reservations
        [Object[]] $Options
        DhcpServerv4Scope([Object]$Scope)
        {
            $This.ScopeID      = $Scope.ScopeID
            $This.SubnetMask   = $Scope.SubnetMask
            $This.Name         = $Scope.Name
            $This.State        = @(0,1)[$Scope.State -eq "Active"]
            $This.StartRange   = $Scope.StartRange
            $This.EndRange     = $Scope.EndRange
            $This.Reservations = Get-DhcpServerV4Reservation -ScopeID $Scope.ScopeID | % { [DhcpServerv4Reservation]$_ }
            $This.Options      = Get-DhcpServerV4OptionValue -ScopeID $Scope.ScopeID | % { [DhcpServerV4OptionValue]$_ }
        }
    }

    Class DhcpServer
    {
        [Object]$Scope
        DhcpServer()
        {
            $This.Scope = Get-DhcpServerV4Scope | % { [DhcpServerv4Scope]$_ }
        }
    }

    # [Dns Classes]
    Class DnsServerResourceRecord
    {
        [Object] $Record
        [String] $Type
        [String] $Name
        DnsServerResourceRecord([Object]$Type,[Object]$Record)
        {
            $This.Record = $Record
            $This.Type   = $Type
            $This.Name   = Switch($Type)
            {
                NS    { $Record.NameServer      } SOA   { $Record.PrimaryServer   }
                MX    { $Record.MailExchange    } CNAME { $Record.HostNameAlias   }
                SRV   { $Record.DomainName      } A     { $Record.IPV4Address     }
                AAAA  { $Record.IPV6Address     } PTR   { $Record.PTRDomainName   }
                TXT   { $Record.DescriptiveText } DHCID { $Record.DHCID           }
            }
        }
        [String] ToString()
        {
            Return ( $This.Name )
        }
    }

    Class DnsServerHostRecord
    {
        [String] $HostName
        [String] $RecordType
        [UInt32] $Type
        [Object] $RecordData
        DnsServerHostRecord([Object]$Record)
        {
            $This.HostName   = $Record.HostName
            $This.RecordType = $Record.RecordType
            $This.Type       = $Record.Type
            $This.RecordData = [DnsServerResourceRecord]::New($Record.RecordType,$Record.RecordData).Name
        }
    }

    Class DnsServerZone
    {
        [String] $Index
        [String] $ZoneName
        [String] $ZoneType
        [UInt32] $IsReverseLookupZone
        [Object[]] $Hosts
        DnsServerZone([UInt32]$Index,[Object]$Zone)
        {
            $This.Index               = $Index
            $This.ZoneName            = $Zone.ZoneName
            $This.ZoneType            = $Zone.ZoneType
            $This.IsReverseLookupZone = $Zone.IsReverseLookupZone
            $This.Hosts               = Get-DNSServerResourceRecord -ZoneName $Zone.Zonename | % { [DnsServerHostRecord]::New($_) }
        }
    }

    Class DnsServer
    {
        [Object]$Zone
        DnsServer()
        {
            $This.Zone = @( )
            ForEach ($Zone in Get-DnsServerZone)
            {
                Write-Host "Collecting [~] ($Zone)"
                $This.Zone += [DnsServerZone]::New($This.Zone.Count,$Zone)
            }
        }
    }

    # [Adds Classes]
    Class AddsObject
    {
        Hidden [Object] $Object
        [String] $Name
        [String] $Class
        [String] $GUID
        [String] $DistinguishedName
        AddsObject([Object]$Object)
        {
            $This.Object            = $Object
            $This.Name              = $Object.Name
            $This.Class             = $Object.ObjectClass
            $This.GUID              = $Object.ObjectGUID
            $This.DistinguishedName = $Object.DistinguishedName
        }
        [String] ToString()
        {
            Return @( $This.Name )
        }
    }

    Class AddsDomain
    {
        [String] $HostName
        [String] $DCMode
        [String] $DomainMode
        [String] $ForestMode
        [String] $Root
        [String] $Config
        [String] $Schema
        [Object[]] $Site
        [Object[]] $SiteLink
        [Object[]] $Subnet
        [Object[]] $DHCP
        [Object[]] $OU
        [Object[]] $Computer
        AddsDomain()
        {
            Import-Module ActiveDirectory
            $Domain          = Get-Item AD:
            $This.Hostname   = $Domain.DNSHostName
            $This.DCMode     = $Domain.domainControllerFunctionality
            $This.DomainMode = $Domain.domainFunctionality
            $This.ForestMode = $Domain.forestFunctionality
            $This.Root       = $Domain.rootDomainNamingContext
            $This.Config     = $Domain.configurationNamingContext
            $This.Schema     = $Domain.schemaNamingContext

            $Cfg             = Get-ADObject -Filter * -SearchBase $This.Config | ? ObjectClass -match "(Site|Sitelink|Subnet|Dhcpclass)" | % { [AddsObject]$_ }
            $Base            = Get-ADObject -Filter * -SearchBase $This.Root   | ? ObjectClass -match "(OrganizationalUnit|Computer)"    | % { [AddsObject]$_ }

            $This.Site       = $Cfg  | ? Class -eq Site
            $This.SiteLink   = $Cfg  | ? Class -eq Sitelink
            $This.Subnet     = $Cfg  | ? Class -eq Subnet
            $This.Dhcp       = $Cfg  | ? Class -eq DhcpClass
            $This.OU         = $Base | ? Class -eq OrganizationalUnit
            $This.Computer   = $Base | ? Class -eq Computer
        }
    }

    # [HyperV]
    Class VmGuestNetwork
    {
        [String] $Name
        [String] $VMName
        [String] $SwitchName
        [String] $MacAddress
        VmGuestNetwork([Object]$Adapter)
        {
            $This.Name       = $Adapter.Name
            $This.VMName     = $Adapter.VMName
            $This.SwitchName = $Adapter.SwitchName
            $This.MacAddress = $Adapter.MacAddress
        }
    }

    Class VmGuest
    {
        [UInt32]   $Index
        [String]   $Name
        [String]   $ID
        [String]   $Path
        [String]   $Disk
        [String]   $Size
        [Object[]] $Network
        [String[]] $Switch
        VmGuest([UInt32]$Index,[Object]$VM)
        {
            Write-Host "Collecting [~] VM ($($Index+1))"
            $This.Index = $Index
            $This.Name = $VM.Name
            $This.ID   = $VM.ID
            $This.Path = $VM.Path
            $This.Disk = $VM.HardDrives[0].Path
            $This.Size = "{0:n2} GB" -f [Float]((Get-Item $This.Disk | % Length)/1GB)
            $This.Network = $VM.NetworkAdapters | % { [VmGuestNetwork]$_ }
            $This.Switch  = @($This.Network.SwitchName)
        }
    }

    Class VmSwitch
    {
        [UInt32] $Index
        [String] $Name
        [String] $ID
        [String] $Type
        [String] $Description
        [Object] $Interface
        VmSwitch([UInt32]$Index,[Object]$IP,[Object]$Switch)
        {
            Write-Host "Collecting [~] Switch ($($Index+1))"
            $This.Index       = $Index
            $This.Name        = $Switch.Name
            $This.ID          = $Switch.ID
            $This.Type        = $Switch.SwitchType
            $This.Description = @($Switch.NetAdapterInterfaceDescription,"-")[$Switch.NetAdapterInterfaceDescription -ne ""]
            $This.Interface   = $IP | ? Alias -match $Switch.Name
        }
    }

    Class VmHost
    {
        [String] $Name
        [UInt32] $Processor
        [String] $Memory
        [String] $VHDPath
        [String] $VMPath
        [Object] $Switch
        [Object] $Vm
        VmHost([Object]$IP)
        {
            Write-Host "Collecting [~] Virtual Machine Host"
            $VMHost         = Get-VMHost
            $This.Name      = @($VMHost.ComputerName,"$($VMHost.ComputerName).$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
            $This.Processor = $VMHost.LogicalProcessorCount
            $This.Memory    = "{0:n2} GB" -f [Float]($VMHost.MemoryCapacity/1GB)
            $This.VHDPath   = $VMHost.VirtualHardDiskPath
            $This.VMPath    = $VMHost.VirtualMachinePath
            
            Write-Host "Collecting [~] Virtual Machine Switch(es)"
            $This.Switch    = @( ) 
            Get-VMSwitch    | % { $This.Switch += [VmSwitch]::New($This.Switch.Count,$IP,$_) }

            Write-Host "Collecting [~] Virtual Machine Guest(s)"
            $This.Vm        = @( )
            Get-VM          | % { $This.Vm += [VmGuest]::New($This.Vm.Count,$_) }
        }
    }

    # [WDS Classes]
    Class WdsImage
    {
        [String] $Type
        [String] $Arch
        [String] $Created
        [String] $Language
        [String] $Description
        [UInt32] $Enabled
        [String] $FileName
        [String] $ID
        WdsImage([Object]$Type,[Object]$Image)
        {
            $This.Type        = $Type
            $This.Arch        = @("x86","x64")[$Image.Architecture -eq 3]
            $This.Created     = $Image.CreationTime
            $This.Language    = $Image.DefaultLanguage
            $This.Description = $Image.Description
            $This.Enabled     = @(0,1)[$Image.Enabled -eq $True]
            $This.FileName    = $Image.FileName
            $This.ID          = $Image.ID
        }
    }

    Class WdsServer
    {
        [String] $Server
        [Object[]] $IPAddress
        [Object] $Images
        WdsServer([Object]$IP)
        {
            $This.Server    = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
            $This.IPAddress = @($IP)
            $This.Images    = @( )
            Write-Host "Collecting [~] Wds Install Images"
            Get-WdsInstallImage -EA 0 | % { $This.Images += [WdsImage]::New("Install",$_) }
            Write-Host "Collecting [~] Wds Boot Images"
            Get-WdsBootImage    -EA 0 | % { $This.Images += [WdsImage]::New("Boot",$_) }
        }
    }

    # [Mdt Classes]
    Class MdtShare
    {
        [String] $Name
        [String] $Type
        [String] $Root
        [String] $Share
        [String] $Description
        MdtShare([Object]$Drive)
        {
            $This.Name        = $Drive.Name
            $This.Type        = If (Test-Path "$($Drive.Path)\PSDResources") { "PSD" } Else { "MDT" }
            $This.Root        = $Drive.Path
            $This.Share       = Get-SmbShare | ? Path -eq $Drive.Path | % Name
            $This.Description = $Drive.Description
        }
    }

    Class MdtServer
    {
        [String]      $Server
        [Object[]] $IPAddress
        [String]        $Path
        [String]     $Version
        [String]  $AdkVersion
        [String]   $PEVersion
        [Object]      $Shares
        MdtServer([Object]$IP,[Object]$Registry)
        {
            $This.Server     = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
            $This.IPAddress  = @($IP)
            $This.Path       = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment*" | % Install_Dir
            $This.Version    = Get-ItemProperty $Registry | ? DisplayName -match "Microsoft Deployment Toolkit" | % DisplayVersion | % TrimEnd \
            $This.AdkVersion = Get-ItemProperty $Registry | ? DisplayName -match "Windows Assessment and Deployment Kit - Windows 10" | % DisplayVersion
            $This.PeVersion  = Get-ItemProperty $Registry | ? DisplayName -match "Preinstallation Environment Add-ons - Windows 10"   | % DisplayVersion
            $This.Shares     = @( )
            Get-MDTModule | Import-Module
            Get-MDTPersistentDrive | % { $This.Shares += [MdtShare]$_ }
        }
    }

    # [IIS Classes]
    Class IISSiteBinding
    {
        [UInt32]      $Index
        [String]   $Protocol
        [String]    $Binding
        [String]   $SslFlags
        IISSiteBinding([UInt32]$Index,[Object]$Bind)
        {
            $This.Index    = $Index
            $This.Protocol = $Bind.Protocol
            $This.Binding  = $Bind.BindingInformation
            $This.SslFlags = $Bind.SslFlags
        }
        [String] ToString()
        {
            Return @( $This.Binding)
        }
    }

    Class IISSite
    {
        [String]        $Name
        [UInt32]          $ID
        [String]       $State
        [String]        $Path
        [Object[]]  $Bindings
        [UInt32]   $BindCount
        IISSite([Object]$Site)
        {
            $This.Name     = $Site.Name
            $This.ID       = $Site.ID
            $This.State    = $Site.State
            $This.Path     = $Site.Applications[0].VirtualDirectories[0].PhysicalPath
            $This.Bindings = @( )
            If ( $Site.Bindings.Count -gt 1 )
            {
                ForEach ( $Binding in $Site.Bindings)
                {
                    $This.Bindings += [IISSiteBinding]::New($This.Bindings.Count,$Binding)
                }
            }
            Else
            {
                $This.Bindings += [IISSiteBinding]::New(0,$Site.Bindings)
            }
            $This.BindCount = $This.Bindings.Count
        }
    }

    Class IISAppPool
    {
        [String]         $Name
        [String]       $Status
        [String]    $AutoStart
        [String]   $CLRVersion
        [String] $PipelineMode
        [String]    $StartMode
        IISAppPool([Object]$AppPool)
        {
            $This.Name         = $AppPool.Name
            $This.Status       = $AppPool.State
            $This.AutoStart    = $AppPool.Attributes | ? Name -eq autoStart             | % Value
            $This.CLRVersion   = $AppPool.Attributes | ? Name -eq managedRuntimeVersion | % Value
            $This.PipelineMode = $AppPool.ManagedPipelineMode
            $This.StartMode    = $AppPool.StartMode
        }
    }

    Class IISServer
    {
        [Object]     $AppDefaults
        [Object] $AppPoolDefaults
        [Object]    $SiteDefaults
        [Object] $VirtualDefaults
        [Object[]]      $AppPools
        [Object[]]         $Sites
        IISServer()
        {
            Import-Module WebAdministration
            $IIS                  = Get-IISServerManager
            $This.AppDefaults     = $IIS.ApplicationDefaults
            $This.AppPoolDefaults = $IIS.ApplicationPoolDefaults
            $This.AppPools        = $IIS.ApplicationPools | % { [IISAppPool]$_ }
            $This.SiteDefaults    = $IIS.SiteDefaults
            $This.Sites           = $IIS.Sites | % { [IISSite]$_ }
        }
    }

    # [GUI Classes]
    Class DcTopology
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]          $SiteLink
        [String]          $SiteName
        [UInt32]            $Exists
        [Object] $DistinguishedName
        DcTopology([Object]$SiteList,[Object]$SM)
        {
            $This.Name     = $SM.Sitename
            $This.Sitelink = $SM.Sitelink
            $This.Sitename = $SM.Sitename
            $Tmp           = $SiteList | ? Name -match $SM.SiteLink
            If ($Tmp)
            {
                $This.Exists = 1
                $This.DistinguishedName = $Tmp.DistinguishedName
            }
            Else
            {
                $This.Exists = 0
                $This.DistinguishedName = $Null
            }
        }
    }

    Class NwTopology
    {
        Hidden [String[]]     $Enum = "True","False"
        [String]              $Name
        [String]           $Network
        [UInt32]            $Exists
        [Object] $DistinguishedName
        NwTopology([Object]$SubnetList,[Object]$NW)
        {
            $This.Name     = $Nw.Name
            $This.Network  = $Nw.Network
            $Tmp           = $SubnetList | ? Name -match $Nw.Name
            If ($Tmp)
            {
                $This.Exists = 1
                $This.DistinguishedName = $Tmp.DistinguishedName
            }
            Else
            {
                $This.Exists = 0
                $This.DistinguishedName = $Null
            }
        }
    }

    Class Site
    {
        Hidden [Object] $Hash
        [String]$Name
        [String]$Location
        [String]$Region
        [String]$Country
        [String]$Postal
        [String]$TimeZone
        [String]$SiteLink
        [String]$SiteName
        [String]$Network
        [String]$Prefix
        [String]$Netmask
        [String]$Start
        [String]$End
        [String]$Range
        [String]$Broadcast
        Site([Object]$Domain,[Object]$Network)
        {
            $This.Hash      = @{ Domain = $Domain; Network = $Network }
            $This.Name      = $Domain.SiteLink
            $This.Location  = $Domain.Location
            $This.Region    = $Domain.Region
            $This.Country   = $Domain.Country
            $This.Postal    = $Domain.Postal
            $This.TimeZone  = $Domain.TimeZone
            $This.SiteLink  = $Domain.SiteLink
            $This.Sitename  = $Domain.Sitename
            $This.Network   = $Network.Network
            $This.Prefix    = $Network.Prefix
            $This.Netmask   = $Network.Netmask
            $This.Start     = $Network.Start
            $This.End       = $Network.End
            $This.Range     = $Network.Range
            $This.Broadcast = $Network.Broadcast
        }
    }

    Class SwTopologyBranch
    {
        [String]              $Type
        [String]              $Name
        [String] $DistinguishedName
        [Bool]              $Exists
        SwTopologyBranch([String]$Type,[String]$Name,[String]$Base,[Object]$OUList)
        {
            $This.Type              = $Type
            Switch($Type) 
            {
                Main 
                {
                    $This.Name              = $Name
                    $This.DistinguishedName = "OU=$Name,$Base"
                } 
                
                Leaf 
                { 
                    $This.Name              = $Name.Split("/")[1]
                    $This.DistinguishedName = "OU={1},OU={0},$Base" -f $Name.Split("/") 
                }
            }
            $This.Exists            = @(0,1)[$This.DistinguishedName -in $OUList.DistinguishedName] 
        }
    }

    Class SmTemplateItem
    {
        [String] $ObjectClass
        [Bool] $Create
        SmTemplateItem([String]$ObjectClass,[Bool]$Create)
        {
            $This.ObjectClass = $ObjectClass
            $This.Create      = $Create
        }
    }

    Class SmTemplate
    {
        Hidden [String[]] $Names = ("Gateway Server Computers Users Service" -Split " ")
        [Object] $Stack
        SmTemplate()
        {
            $This.Stack = @( )

            ForEach ( $Name in $This.Names )
            {
                $This.Stack += [SmTemplateItem]::New($Name,1)
            }
        }
    }

    Class Topology
    {
        [String] $Type
        [String] $DistinguishedName
        [Bool]   $Exists
        [String] $Name
        [String] $Location
        [String] $Region
        [String] $Country
        [String] $Postal
        [String] $TimeZone
        [String] $SiteLink
        [String] $SiteName
        [String] $Network
        [String] $Prefix
        [String] $Netmask
        [String] $Start
        [String] $End
        [String] $Range
        [String] $Broadcast
        Topology([String]$Type,[String]$DN,[Object]$Site)
        {
            $This.Type              = $Type
            $This.DistinguishedName = @{Gateway="CN=$($Site.Name),$DN";Server="CN=dc1-$($Site.Postal),$DN"}[$Type]
            $Return                 = Get-ADObject -Filter * | ? DistinguishedName -match $This.DistinguishedName
            $This.Exists            = $Return -ne $Null
            $This.Name              = $Site.Name
            $This.Location          = $Site.Location
            $This.Region            = $Site.Region
            $this.Country           = $Site.Country
            $This.Postal            = $Site.Postal
            $This.TimeZone          = $Site.TimeZone
            $This.SiteLink          = $Site.SiteLink
            $This.SiteName          = $Site.SiteName
            $This.Network           = $Site.Network
            $This.Prefix            = $Site.Prefix
            $This.Netmask           = $Site.Netmask
            $This.Start             = $Site.Start
            $This.End               = $Site.End
            $This.Range             = $Site.Range
            $This.Broadcast         = $Site.Broadcast
        }
    }

    Class DsShare
    {
        [String]$Name
        [String]$Root
        [Object]$Share
        [String]$Description
        [String]$Type
        DsShare([Object]$Drive)
        {
            $This.Name        = $Drive.Name
            $This.Root        = $Drive.Path
            $This.Share       = Get-SMBShare | ? Path -eq $Drive.Path | % Name
            $This.Description = $Drive.Description
            If (Test-Path "$($This.Root)\PSDResources")
            {
                $This.Type    = "PSD"
            }
            Else
            {
                $This.Type    = "MDT"
            }
        }
        DsShare([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
        {
            If (Get-SMBShare -Name $Share -EA 0)
            {
                Throw "Share name is already assigned"
            }

            $This.Name        = $Name
            $This.Root        = $Root
            $This.Share       = $Share
            $This.Description = $Description
            $This.Type        = @("MDT","PSD","-")[$Type]
        }
    }

    Class Certificate
    {
        Hidden[String] $ExternalIP
        Hidden[Object]       $Ping
        [String]     $Organization
        [String]       $CommonName
        [String]         $Location
        [String]           $Region
        [String]          $Country
        [Int32]            $Postal
        [String]         $TimeZone
        [String]         $SiteName
        [String]         $SiteLink
        Certificate([String]$Organization,[String]$CommonName)
        {
            $This.Organization     = $Organization
            $This.CommonName       = $CommonName  
            $This.Prime()
        }
        Certificate([Object]$Sitemap)
        {
            $This.Organization     = $Sitemap.Organization
            $This.CommonName       = $Sitemap.CommonName
            $This.Prime()
        }
        Prime()
        {
            # These (2) lines are from Chrissie Lamaire's script
            # https://gallery.technet.microsoft.com/scriptcenter/Get-ExternalPublic-IP-c1b601bb

            $This.ExternalIP       = Invoke-RestMethod http://ifconfig.me/ip 
            $This.Ping             = Invoke-RestMethod http://ipinfo.io/$($This.ExternalIP)

            $This.Location         = $This.Ping.City
            $This.Region           = $This.Ping.Region
            $This.Country          = $This.Ping.Country
            $This.Postal           = $This.Ping.Postal
            $This.TimeZone         = $This.Ping.TimeZone

            $This.GetSiteLink()
        }
        GetSiteLink()
        {
            $Return                = @{ }

            # City
            $Return.Add(0,@(Switch -Regex ($This.Location)
            {
                "\s"
                {
                    ( $This.Location | % Split " " | % { $_[0] } ) -join ''
                }

                Default
                {
                    $This.Location[0,1] -join ''
                }
    
            }).ToUpper())

            # State
            $Return.Add(1,[States]::List[$This.Region])

            # Country
            $Return.Add(2,$This.Country)

            # Zip
            $Return.Add(3,$This.Postal)

            $This.SiteLink = ($Return[0..3] -join "-").ToUpper()
            $This.SiteName = ("{0}.{1}" -f ($Return[0..3] -join "-"),$This.CommonName).ToLower()
        }
    }

    # [VM Classes]
    Class VmSelect
    {
        [String] $Type
        [String] $Name
        [Bool]   $Create
        VmSelect([Object]$Item)
        {
            $This.Type   = $Item.Type
            $This.Name   = $Item.Name
            $This.Create = 1
        }
    }

    Class VmTest
    {
        [Object] $Name
        [Bool] $Exists
        VmTest([String]$Name)
        {
            $This.Name   = $Name
            $Return      = Get-VM -Name $Name -EA 0
            $This.Exists = $Return -ne $Null
        }
    }

    Class VmController
    {
        [String]$Name
        [String]$Status
        [String]$Username
        [String]$Credential
        VmController([String]$ID)
        {
            If ($ID -eq "localhost")
            {
                $ID = $Env:ComputerName
            }

            $This.Name       = Resolve-DNSName $ID | Select-Object -First 1 | % Name
            $This.Status     = Get-Service -Name vmms | % Status
            $This.Username   = $Env:Username
            $This.Credential = Get-Credential $Env:Username
        }
        VmController([String]$ID,[Object]$Credential)
        {
            If ($ID -eq "localhost")
            {
                $ID = $Env:ComputerName
            }

            $This.Name       = Resolve-DNSName $ID | Select-Object -First 1 | % Name
            $This.Status     = Get-Service -Name vmms -ComputerName $ID | % Status
            $This.Username   = $Credential.Username
            $This.Credential = $Credential
        }
    }

    Class VMObject
    {
        [Object]$Item
        [Object]$Name
        [Double]$MemoryStartupBytes
        [Object]$Path
        [Object]$NewVHDPath
        [Double]$NewVHDSizeBytes
        [Object]$Generation
        [Object]$SwitchName
        VMObject([Object]$Item,[UInt32]$Mem,[UInt32]$HD,[UInt32]$Gen,[String]$Switch)
        {
            $This.Item               = $Item
            $This.Name               = $Item.Name
            $This.MemoryStartupBytes = ([UInt32]$Mem)*1048576
            $This.Path               = "{0}\$($Item.Name).vmx"
            $This.NewVhdPath         = "{0}\$($Item.Name).vhdx"
            $This.NewVhdSizeBytes    = ([UInt32]$HD)*1073741824
            $This.Generation         = $Gen
            $This.SwitchName         = $Switch
        }
        New([Object]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }

            ElseIf (Get-VM -Name $This.Name -EA 0)
            {
                Write-Host "VM exists..."
                If (Get-VM -Name $This.Name | ? Status -ne Off)
                {
                    $This.Stop()
                }

                $This.Remove()
            }

            $This.Path             = $This.Path -f $Path
            $This.NewVhdPath       = $This.NewVhdPath -f $Path

            If (Test-Path $This.Path)
            {
                Remove-Item $This.Path -Recurse -Confirm:$False -Verbose
            }

            If (Test-Path $This.NewVhdPath)
            {
                Remove-Item $This.NewVhdPath -Recurse -Confirm:$False -Verbose
            }

            $Object                = @{

                Name               = $This.Name
                MemoryStartupBytes = $This.MemoryStartupBytes
                Path               = $This.Path
                NewVhdPath         = $This.NewVhdPath
                NewVhdSizeBytes    = $This.NewVhdSizebytes
                Generation         = $This.Generation
                SwitchName         = $This.SwitchName
            }

            New-VM @Object -Verbose
            $Ct = @{Gateway=1;Server=2}[$This.Item.Type]
            Set-VMProcessor -VMName $This.Name -Count $Ct -Verbose
        }
        Start()
        {
            Get-VM -Name $This.Name | ? State -eq Off | Start-VM -Verbose
        }
        Remove()
        {
            Get-VM -Name $This.Name | Remove-VM -Force -Confirm:$False -Verbose
        }
        Stop()
        {
            Get-VM -Name $This.Name | ? State -ne Off | Stop-VM -Verbose -Force
        }
        LoadISO([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid ISO path"
            }

            Else
            {
                Get-VM -Name $This.Name | % { Set-VMDVDDrive -VMName $_.Name -Path $Path -Verbose }
            }
        }
    }

    Class VmStack
    {
        [Object] $Host
        [Object] $Switch
        [Object] $External
        [Object] $Internal
        VmStack([Object]$VmHost,[Object]$VmSwitch)
        {
            $This.Host     = $VmHost
            $This.Switch   = $VmSwitch
            $This.External = $Vmswitch | ? SwitchType -eq External
            $This.Internal = $Vmswitch | ? SwitchType -eq Internal
        }
    }

    # [Image Classes]
    # Add-Type -AssemblyName PresentationFramework
    Class ImageLabel
    {
        [String] $Name
        [String] $SelectedIndex
        [Object[]] $Content
        ImageLabel([Object]$Selected,[UInt32[]]$Index)
        {
            $This.Name          = $Selected.Path
            $This.SelectedIndex = $Index -join ","
            $This.Content       = @($Selected.Content | ? Index -in $Index)
        }
    }

    Class ImageSlot
    {
        Hidden [Object] $ImageFile
        Hidden [Object] $Arch
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [String] $Size
        [UInt32] $Architecture
        ImageSlot([Object]$ImageFile,[UInt32]$Arch,[Object]$Slot)
        {
            $This.ImageFile    = $ImageFile
            $This.Arch         = $Arch
            $This.Index        = $Slot.ImageIndex
            $This.Name         = $Slot.ImageName
            $This.Description  = $Slot.ImageDescription
            $This.Size         = "{0:n2} GB" -f ([Double]($Slot.ImageSize -Replace "(,|bytes|\s)","")/1073741824)
            $This.Architecture = @(86,64)[$Arch -eq 9]
        }
    }

    Class ImageFile
    {
        [UInt32]      $Index
        [UInt32]       $Arch
        [String]       $Type
        [String]       $Name
        [String]       $Path
        [String]     $Letter
        [Object[]]  $Content
        ImageFile([UInt32]$Index,[String]$Path)
        {
            $This.Index     = $Index
            $This.Name      = $Path | Split-Path -Leaf
            $This.Path      = $Path
            $This.Content   = @( )
        }
        [Object] GetDiskImage()
        {
            Return @( Get-DiskImage -ImagePath $This.Path )
        }
        MountDiskImage()
        {
            Mount-DiskImage -ImagePath $This.Path
            Do
            {
                Start-Sleep -Milliseconds 100
            }
            Until ($This.GetDiskImage() | ? Attached -eq $True)
            
            $This.Letter    = $This.GetDiskImage() | Get-Volume | % DriveLetter
        }
        DismountDiskImage()
        {
            Dismount-DiskImage -ImagePath $This.Path
        }
        GetWindowsImage([String]$Path)
        {
            $This.Arch     = Get-WindowsImage -ImagePath $Path -Index 1 | % Architecture
            $This.Content  = Get-WindowsImage -ImagePath $Path | % { [ImageSlot]::New($Path,$This.Arch,$_) }
            $This.Type     = @("Client","Server")[$This.Content[0].Name -match "Server"]
        }
    }

    Class ImageStack
    {
        [String] $Source
        [String] $Target
        [Object] $Selected
        [Object] $Store
        [Object] $Queue
        [Object] $Swap
        [Object] $Output
        ImageStack()
        {
            $This.Source   = $Null
            $This.Target   = $Null
            $This.Selected = $Null
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        [Void] LoadSilo([String]$Source)
        {
            If (!(Test-Path $Source))
            {
                Throw "Invalid source path"
            }

            ElseIf ((Get-ChildItem $Source *.iso).Count -eq 0)
            {
                [System.Windows.MessageBox]::Show("No ISO's detected")
            }

            Else
            {
                $This.Store  = @( )
                $This.Source = $Source

                ForEach ( $Item in Get-ChildItem $This.Source *.iso )
                {
                    $This.Store += [ImageFile]::New($This.Store.Count,$Item.FullName)
                }
            }
        }
        LoadIso([UInt32]$Index)
        {
            If ($This.Store.Count -eq 0)
            {
                [System.Windows.MessageBox]::Show("No ISO's detected")
            }

            $This.Selected = $This.Store[$Index]

            If ( $This.Selected.GetDiskImage() | ? Attached -eq $False )
            {
                $This.Selected.MountDiskImage()
                Start-Sleep 1
            }
            If ( $This.Selected.GetDiskImage() | ? Attached -eq $True )
            {
                $This.Selected.Letter = Get-DiskImage -ImagePath $This.Selected.Path | Get-Volume | % DriveLetter
            }

            $Path      = "$($This.Selected.Letter):\sources\install.wim"

            If (!(Test-Path $Path))
            {
                $This.Selected.DismountDiskImage()
                [System.Windows.MessageBox]::Show("Not a valid Windows image","Error")
            }
            Else
            {
                $This.Selected.GetWindowsImage($Path)
                Do
                {
                    Start-Sleep -Milliseconds 100
                }
                Until ($This.Selected.Content.Count -gt 0)
            }
        }
        [Void] UnloadIso()
        {
            $This.Selected.DismountDiskImage()
            $This.Selected = $Null
        }
        AddQueue([UInt32[]]$Index)
        {
            If ($This.Selected.Path -in $This.Queue.Name)
            {
                [System.Windows.MessageBox]::Show("That image is already in the queue - remove, and reindex","Error")
            }
            Else
            {
                $This.Queue += [ImageLabel]::New($This.Selected,$Index)
            }
        }
        [Void] DeleteQueue([String]$Name)
        {
            If ($Name -in $This.Queue.Name)
            {
                $This.Queue = @( $This.Queue | ? Name -ne $Name )
            }
        }
    }

    Class XamlWindow 
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object]               $Node
        [Object]                 $IO
        [String[]] FindNames()
        {
            Return @( [Regex]"((Name)\s*=\s*('|`")\w+('|`"))" | % Matches $This.Xaml | % Value | % { 

                ($_ -Replace "(\s+)(Name|=|'|`"|\s)","").Split('"')[1] 

            } | Select-Object -Unique ) 
        }
        XamlWindow([String]$XAML)
        {           
            If ( !$Xaml )
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ( $I in 0..( $This.Names.Count - 1 ) )
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force 
            }
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }
    
    Class DGList
    {
        [String]$Name
        [Object]$Value
        DGList([String]$Name,[Object]$Value)
        {
            $This.Name  = $Name
            $This.Value = $Value
        }
    }
    
    Class Sitemap
    {
        [String]$Organization
        [String]$CommonName
        [Object]$Sitemap
        Sitemap([String]$Organization,$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
            $This.Sitemap      = @( )
        }
    }
    
    Class Key
    {
        [String]     $NetworkPath
        [String]    $Organization
        [String]      $CommonName
        [String]      $Background
        [String]            $Logo
        [String]           $Phone
        [String]           $Hours
        [String]         $Website
        Key([Object]$Root)
        {
            $This.NetworkPath     = $Root[0]
            $This.Organization    = $Root[1]
            $This.CommonName      = $Root[2]
            $This.Background      = $Root[3]
            $This.Logo            = $Root[4]
            $This.Phone           = $Root[5]
            $This.Hours           = $Root[6]
            $This.Website         = $Root[7]
        }
    }

    Class WimFile
    {
        [UInt32] $Rank
        [Object] $Label
        [UInt32] $ImageIndex            = 1
        [String] $ImageName
        [String] $ImageDescription
        [String] $Version
        [String] $Architecture
        [String] $InstallationType
        [String] $SourceImagePath
        WimFile([UInt32]$Rank,[String]$Image)
        {
            If ( ! ( Test-Path $Image ) )
            {
                Throw "Invalid Path"
            }

            $This.SourceImagePath       = $Image
            $This.Rank                  = $Rank

            Get-WindowsImage -ImagePath $Image -Index 1 | % {
                
                $This.Version           = $_.Version
                $This.Architecture      = @(86,64)[$_.Architecture -eq 9]
                $This.InstallationType  = $_.InstallationType
                $This.ImageName         = $_.ImageName
                $This.Label             = Switch($This.InstallationType)
                {
                    Server
                    {
                        "{0}{1}" -f $(Switch -Regex ($This.ImageName){Standard{"SD"}Datacenter{"DC"}}),[Regex]::Matches($This.ImageName,"(\d{4})").Value
                    }

                    Client
                    {
                        "10{0}{1}" -f $(Switch -Regex ($This.ImageName) { Pro {"P"} Edu {"E"} Home {"H"} }),$This.Architecture
                    }
                }

                $This.ImageDescription  = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)][$($This.Label)]"

                If ( $This.ImageName -match "Evaluation" )
                {
                    $This.ImageName     = $This.ImageName -Replace "Evaluation \(Desktop Experience\) ",""
                }
            }
        }
    }

    Class BootImage
    {
        [Object] $Path
        [Object] $Name
        [Object] $Type
        [Object] $ISO
        [Object] $WIM
        [Object] $XML
        BootImage([String]$Path,[String]$Name)
        {
            $This.Path = $Path
            $This.Name = $Name
            $This.Type = Switch ([UInt32]($This.Name -match "\(x64\)")) { 0 { "x86" } 1 { "x64" } }
            $This.ISO  = "$Path\$Name.iso"
            $This.WIM  = "$Path\$Name.wim"
            $This.XML  = "$Path\$Name.xml"
        }
    }

    Class BootImages
    {
        [Object] $Images
        BootImages([Object]$Directory)
        {
            $This.Images = @( )

            ForEach ( $Item in Get-ChildItem $Directory | ? Extension | % BaseName | Select-Object -Unique )
            {
                $This.Images += [BootImage]::New($Directory,$Item)
            }
        }
    }
    
    # (Get-Content $home\desktop\FEInfrastructure.xaml) -Replace "'",'"' | % { "'$_',"} | Set-Clipboard
    Class FEInfrastructureGUI
    {
        Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Infrastructure Deployment System" Width="800" Height="780" Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen">',
        '    <Window.Resources>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Height" Value="28"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="{x:Type TextBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Foreground" Value="#000000"/>',
        '            <Setter Property="TextWrapping" Value="Wrap"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="Height" Value="24"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="TabItem">',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="TabItem">',
        '                        <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected" Value="True">',
        '                                <Setter TargetName="Border" Property="Background" Value="#4444FF"/>',
        '                                <Setter Property="Foreground" Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected" Value="False">',
        '                                <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground" Value="#000000"/>',
        '                            </Trigger>',
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="30"/>',
        '            <Setter Property="FontWeight" Value="Semibold"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Background" Value="#DFFFBA"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '        </Style>',
        '        <Style TargetType="TextBox" x:Key="Block">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="Height" Value="170"/>',
        '            <Setter Property="FontFamily" Value="System"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '            <Setter Property="AcceptsReturn" Value="True"/>',
        '            <Setter Property="VerticalAlignment" Value="Top"/>',
        '            <Setter Property="TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Top"/>',
        '            <Setter Property="VerticalScrollBarVisibility" Value="Visible"/>',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="AutoGenerateColumns" Value="False"/>',
        '            <Setter Property="AlternationCount" Value="2"/>',
        '            <Setter Property="HeadersVisibility" Value="Column"/>',
        '            <Setter Property="CanUserResizeRows" Value="False"/>',
        '            <Setter Property="CanUserAddRows" Value="False"/>',
        '            <Setter Property="IsReadOnly" Value="True"/>',
        '            <Setter Property="IsTabStop" Value="True"/>',
        '            <Setter Property="IsTextSearchEnabled" Value="True"/>',
        '            <Setter Property="SelectionMode" Value="Extended"/>',
        '            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>',
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex" Value="0">',
        '                    <Setter Property="Background" Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background" Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Medium"/>',
        '            <Setter Property="Margin" Value="2"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '        </Style>',
        '        <Style TargetType="Label" x:Key="Config">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '    </Window.Resources>',
        '    <Grid>',
        '        <Grid.Resources>',
        '            <Style TargetType="Grid">',
        '                <Setter Property="Background" Value="LightYellow"/>',
        '            </Style>',
        '        </Grid.Resources>',
        '        <TabControl>',
        '            <TabItem Header="Module">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="40"/>',
        '                        <RowDefinition Height="400"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Module Information and Components"/>',
        '                    <GroupBox Grid.Row="1" Header="[Information]">',
        '                        <DataGrid Name="Module_Info">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[Components]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <ComboBox Grid.Row="0" Grid.Column="0" Name="Module_Type"/>',
        '                            <ComboBox Grid.Row="0" Grid.Column="1" Name="Module_Property"/>',
        '                            <TextBox  Grid.Row="0" Grid.Column="2" Name="Module_Filter"/>',
        '                            <DataGrid Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3"  Name="Module_List">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Mode"          Binding="{Binding Mode}"   Width="40"/>',
        '                                    <DataGridTextColumn Header="LastWriteTime" Binding="{Binding LastWriteTime}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Length"        Binding="{Binding Length}" Width="75"/>',
        '                                    <DataGridTextColumn Header="Name"          Binding="{Binding Name}"   Width="200"/>',
        '                                    <DataGridTextColumn Header="Path"          Binding="{Binding Path}"   Width="600"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Config">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[CfgServices (Dependency Snapshot)]">',
        '                        <DataGrid Name="CfgServices">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"      Binding="{Binding Name}"  Width="150"/>',
        '                                <DataGridTextColumn Header="Installed/Meets minimum requirements" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Role">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Role and System Information"/>',
        '                                <GroupBox Grid.Row="1" Header="[Information]">',
        '                                    <DataGrid Name="Role_Info">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="System">',
        '                            <Grid Grid.Row="1" Name="System_Panel">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="290"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Server System Information"/>',
        '                                <GroupBox Header="[System]" Grid.Row="1">',
        '                                    <Grid Margin="5">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="240"/>',
        '                                            <ColumnDefinition Width="125"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <!-- Column 0 -->',
        '                                        <Label       Grid.Row="0" Grid.Column="0" Content="[Manufacturer]:"/>',
        '                                        <Label       Grid.Row="1" Grid.Column="0" Content="[Model]:"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="0" Content="[Processor]:"/>',
        '                                        <Label       Grid.Row="3" Grid.Column="0" Content="[Architecture]:"/>',
        '                                        <Label       Grid.Row="4" Grid.Column="0" Content="[UUID]:"/>',
        '                                        <Label       Grid.Row="5" Grid.Column="0" Content="[System Name]:"     ToolTip="Enter a new system name"/>',
        '                                        <!-- Column 1 -->',
        '                                        <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>',
        '                                        <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>',
        '                                        <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>',
        '                                        <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture"/>',
        '                                        <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3"  Name="System_UUID"/>',
        '                                        <TextBox     Grid.Row="5" Grid.Column="1" Name="System_Name"/>',
        '                                        <!-- Column 2 -->',
        '                                        <Label       Grid.Row="0" Grid.Column="2" Content="[Product]:"/>',
        '                                        <Label       Grid.Row="1" Grid.Column="2" Content="[Serial]:"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="2" Content="[Memory]:"/>',
        '                                        <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">',
        '                                            <Label   Content="[Chassis]:"/>',
        '                                            <CheckBox Name="System_IsVM" Content="IsVM" IsEnabled="False"/>',
        '                                        </StackPanel>',
        '                                        <Label       Grid.Row="5" Grid.Column="2" Content="[BIOS/UEFI]:"/>',
        '                                        <!-- Column 3 -->',
        '                                        <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>',
        '                                        <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>',
        '                                        <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>',
        '                                        <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis"/>',
        '                                        <ComboBox    Grid.Row="5" Grid.Column="3" Name="System_BiosUefi"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Disks]">',
        '                                    <DataGrid Name="System_Disk" Margin="5">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"       Width="50"/>',
        '                                            <DataGridTextColumn Header="Label"      Binding="{Binding Label}"      Width="200"/>',
        '                                            <DataGridTextColumn Header="FileSystem" Binding="{Binding FileSystem}" Width="80"/>',
        '                                            <DataGridTextColumn Header="Size"       Binding="{Binding Size}"       Width="100"/>',
        '                                            <DataGridTextColumn Header="Free"       Binding="{Binding Free}"       Width="100"/>',
        '                                            <DataGridTextColumn Header="Used"       Binding="{Binding Used}"       Width="100"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Network">',
        '                            <Grid Grid.Row="1" Name="Network_Panel" Visibility="Visible">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="180"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Network Adapter Information"/>',
        '                                <GroupBox Header="[Adapter]" Grid.Row="1">',
        '                                    <DataGrid Name="Network_Adapter" Margin="5" ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"       Width="250"/>',
        '                                            <DataGridTextColumn Header="Index"      Binding="{Binding Index}"      Width="50"/>',
        '                                            <DataGridTextColumn Header="IPAddress"  Binding="{Binding IPAddress}"  Width="100"/>',
        '                                            <DataGridTextColumn Header="SubnetMask" Binding="{Binding SubnetMask}" Width="100"/>',
        '                                            <DataGridTextColumn Header="Gateway"    Binding="{Binding Gateway}"    Width="100"/>',
        '                                            <DataGridTemplateColumn Header="DNSServer" Width="125">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox ItemsSource="{Binding DNSServer}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="DhcpServer" Binding="{Binding DhcpServer}" Width="100"/>',
        '                                            <DataGridTextColumn Header="MacAddress" Binding="{Binding MacAddress}" Width="125"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Header="[Network]" Grid.Row="2">',
        '                                    <Grid Margin="5">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="125"/>',
        '                                            <ColumnDefinition Width="250"/>',
        '                                            <ColumnDefinition Width="125"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <!-- Column 0 -->',
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[Adapter Name]:"/>',
        '                                        <Label    Grid.Row="1" Grid.Column="0" Content="[Network Type]:"/>',
        '                                        <Label    Grid.Row="2" Grid.Column="0" Content="[IP Address]:"/>',
        '                                        <Label    Grid.Row="3" Grid.Column="0" Content="[Subnet Mask]:"/>',
        '                                        <Label    Grid.Row="4" Grid.Column="0" Content="[Gateway]:"/>',
        '                                        <!-- Column 1 -->',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Network_Name"/>',
        '                                        <ComboBox Grid.Row="1" Grid.Column="1" Name="Network_Type"/>',
        '                                        <TextBox  Grid.Row="2" Grid.Column="1" Name="Network_IPAddress"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="1" Name="Network_SubnetMask"/>',
        '                                        <TextBox  Grid.Row="4" Grid.Column="1" Name="Network_Gateway"/>',
        '                                        <!-- Column 2 -->',
        '                                        <Label    Grid.Row="1" Grid.Column="2" Content="[Interface Index]:"/>',
        '                                        <Label    Grid.Row="2" Grid.Column="2" Content="[DNS Server(s)]:"/>',
        '                                        <Label    Grid.Row="3" Grid.Column="2" Content="[DHCP Server]:"/>',
        '                                        <Label    Grid.Row="4" Grid.Column="2" Content="[Mac Address]:"/>',
        '                                        <!-- Column 3 -->',
        '                                        <TextBox  Grid.Row="1" Grid.Column="3" Name="Network_Index"/>',
        '                                        <ComboBox Grid.Row="2" Grid.Column="3" Name="Network_DNS"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="3" Name="Network_DHCP"/>',
        '                                        <TextBox  Grid.Row="4" Grid.Column="3" Name="Network_MacAddress"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Dhcp">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="120"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Dynamic Host Control Protocol"/>',
        '                                <GroupBox Grid.Row="1"  Header="[Dhcp ScopeID] - (DHCP Server Scope ID Information)">',
        '                                    <DataGrid Name="CfgDhcpScopeID">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="ScopeID"    Binding="{Binding ScopeID}"    Width="100"/>',
        '                                            <DataGridTextColumn Header="SubnetMask" Binding="{Binding SubnetMask}" Width="100"/>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"       Width="150"/>',
        '                                            <DataGridTemplateColumn Header="State" Width="50">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding State}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="Inactive"/>',
        '                                                            <ComboBoxItem Content="Active"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="StartRange" Binding="{Binding StartRange}" Width="*"/>',
        '                                            <DataGridTextColumn Header="EndRange"   Binding="{Binding EndRange}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Dhcp Reservations] - (Selected DHCP Scope Reservations)">',
        '                                    <DataGrid Name="CfgDhcpScopeReservations">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="IPAddress"   Binding="{Binding IPAddress}"   Width="120"/>',
        '                                            <DataGridTextColumn Header="ClientID"    Binding="{Binding ClientID}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="250"/>',
        '                                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="3" Header="[Dhcp Scope Options] - (Selected DHCP Scope Option Values)">',
        '                                    <DataGrid Name="CfgDhcpScopeOptions">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="OptionID"    Binding="{Binding OptionID}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"     Width="150"/>',
        '                                            <DataGridTextColumn Header="Type"        Binding="{Binding Type}"     Width="200"/>',
        '                                            <DataGridTextColumn Header="Value"       Binding="{Binding Value}"    Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Dns">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="2*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Domain Name Service"/>',
        '                                <GroupBox Grid.Row="1" Header="[CfgDnsZone (DNS Server Zone List)]">',
        '                                    <DataGrid Name="CfgDnsZone">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Index" Binding="{Binding Index}"       Width="50"/>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding ZoneName}"    Width="*"/>',
        '                                            <DataGridTextColumn Header="Type"  Binding="{Binding ZoneType}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="Hosts" Binding="{Binding Hosts.Count}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[CfgDnsZone (Selected DNS Server Zone Hosts)]">',
        '                                    <DataGrid Name="CfgDnsZoneHosts">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="HostName"   Binding="{Binding HostName}"   Width="250"/>',
        '                                            <DataGridTextColumn Header="Record"     Binding="{Binding RecordType}" Width="65"/>',
        '                                            <DataGridTextColumn Header="Type"       Binding="{Binding Type}"       Width="65"/>',
        '                                            <DataGridTextColumn Header="Data"       Binding="{Binding RecordData}" Width="Auto"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Adds">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Active Directory Domain Service"/>',
        '                                <GroupBox Grid.Row="1" Header="[CfgAddsDomain] - (Active Directory Domain Information)">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="125"/>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <!-- Column 0 -->',
        '                                        <Label   Grid.Row="0" Grid.Column="0" Content="[Hostname]:"/>',
        '                                        <Label   Grid.Row="1" Grid.Column="0" Content="[DC Mode]:"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="0" Content="[Domain Mode]:"/>',
        '                                        <Label   Grid.Row="3" Grid.Column="0" Content="[Forest Mode]:"/>',
        '                                        <!-- Column 1 -->',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Adds_Hostname"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="1" Name="Adds_DCMode"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="Adds_DomainMode"/>',
        '                                        <TextBox Grid.Row="3" Grid.Column="1" Name="Adds_ForestMode"/>',
        '                                        <!-- Column 2 -->',
        '                                        <Label   Grid.Row="1" Grid.Column="2" Content="[Root]:"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="2" Content="[Config]:"/>',
        '                                        <Label   Grid.Row="3" Grid.Column="2" Content="[Schema]:"/>',
        '                                        <!-- Column 3 -->',
        '                                        <TextBox Grid.Row="1" Grid.Column="3" Name="Adds_Root"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="3" Name="Adds_Config"/>',
        '                                        <TextBox Grid.Row="3" Grid.Column="3" Name="Adds_Schema"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[CfgAddsObjects] - (Active Directory Objects)">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="200"/>',
        '                                            <ColumnDefinition Width="200"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="0" Name="CfgAddsType"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="1" Name="CfgAddsProperty"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="2" Name="CfgAddsFilter"/>',
        '                                        <DataGrid Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3"  Name="CfgAddsObject">',
        '                                            <DataGrid.Columns>',
        '                                                <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="200"/>',
        '                                                <DataGridTextColumn Header="Class"             Binding="{Binding Class}"             Width="150"/>',
        '                                                <DataGridTextColumn Header="GUID"              Binding="{Binding GUID}"              Width="250"/>',
        '                                                <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="500"/>',
        '                                            </DataGrid.Columns>',
        '                                        </DataGrid>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Hyper-V">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="120"/>',
        '                                    <RowDefinition Height="180"/>',
        '                                    <RowDefinition Height="180"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Veridian"/>',
        '                                <GroupBox Grid.Row="1" Header="[Hyper-V Host] - (Main Hyper-V Host Settings)">',
        '                                    <DataGrid Name="CfgHyperV">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"      Binding="{Binding Name}"      Width="150"/>',
        '                                            <DataGridTextColumn Header="Processor" Binding="{Binding Processor}" Width="80"/>',
        '                                            <DataGridTextColumn Header="Memory"    Binding="{Binding Memory}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="VMPath"    Binding="{Binding VMPath}"    Width="500"/>',
        '                                            <DataGridTextColumn Header="VHDPath"   Binding="{Binding VHDPath}"   Width="500"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Hyper-V Switch] - (Virtual Switches)">',
        '                                    <DataGrid Name="CfgHyperV_Switch">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Index"       Binding="{Binding Index}"       Width="40"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="ID"          Binding="{Binding ID}"          Width="250"/>',
        '                                            <DataGridTextColumn Header="Type"        Binding="{Binding Type}"        Width="80"/>',
        '                                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="200"/>',
        '                                            <DataGridTemplateColumn Header="Interface" Width="125">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox ItemsSource="{Binding Interface.IPV4Address}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="3" Header="[Hyper-V VM] - (Virtual Machines)">',
        '                                    <DataGrid Name="CfgHyperV_VM">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Index"       Binding="{Binding Index}"       Width="40"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="ID"          Binding="{Binding ID}"          Width="250"/>',
        '                                            <DataGridTextColumn Header="Size"        Binding="{Binding Size}"        Width="150"/>',
        '                                            <DataGridTemplateColumn Header="SwitchName" Width="125">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox ItemsSource="{Binding Network.SwitchName}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Disk"        Binding="{Binding Disk}"        Width="500"/>',
        '                                            <DataGridTextColumn Header="Path"        Binding="{Binding Path}"        Width="500"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Wds">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Windows Deployment Services"/>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0" Content="[Server]:"/>',
        '                                    <TextBox  Grid.Column="1" Name="WDS_Server"/>',
        '                                    <Label    Grid.Column="2" Content="[IPAddress]:"/>',
        '                                    <ComboBox Grid.Column="3" Name="WDS_IPAddress"/>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="2" Header="[Wds] - (Images)">',
        '                                    <DataGrid Name="Wds_Images">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type"        Binding="{Binding Type}"        Width="60"/>',
        '                                            <DataGridTextColumn Header="Arch"        Binding="{Binding Arch}"        Width="40"/>',
        '                                            <DataGridTextColumn Header="Created"     Binding="{Binding Created}"     Width="150"/>',
        '                                            <DataGridTextColumn Header="Language"    Binding="{Binding Language}"    Width="65"/>',
        '                                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="250"/>',
        '                                            <DataGridTemplateColumn Header="Enabled" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Enabled}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="FileName"    Binding="{Binding FileName}"    Width="250"/>',
        '                                            <DataGridTextColumn Header="ID"          Binding="{Binding ID}"          Width="250"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Mdt/WinADK/WinPE">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Windows Deployment Services"/>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="150"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Row="0" Grid.Column="0" Content="[Server]:"/>',
        '                                    <TextBox  Grid.Row="0" Grid.Column="1" Name="MDT_Server"/>',
        '                                    <Label    Grid.Row="0" Grid.Column="2" Content="[IPAddress]:"/>',
        '                                    <ComboBox Grid.Row="0" Grid.Column="3" Name="MDT_IPAddress"/>',
        '                                    <Label    Grid.Row="1" Grid.Column="0" Content="[WinADK Version]:"/>',
        '                                    <TextBox  Grid.Row="1" Grid.Column="1" Name="MDT_ADK_Version"/>',
        '                                    <Label    Grid.Row="1" Grid.Column="2" Content="[WinPE Version]:"/>',
        '                                    <TextBox  Grid.Row="1" Grid.Column="3" Name="MDT_PE_Version"/>',
        '                                    <Label    Grid.Row="2" Grid.Column="0" Content="[MDT Version]:"/>',
        '                                    <TextBox  Grid.Row="2" Grid.Column="1" Name="MDT_Version"/>',
        '                                    <Label    Grid.Row="3" Grid.Column="0" Content="[Installation Path]:"/>',
        '                                    <TextBox  Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3" Name="MDT_Path"/>',
        '                                    <GroupBox Grid.Row="4" Grid.Column="0" Grid.ColumnSpan="4" Header="[Mdt] - (Shares)">',
        '                                        <DataGrid Name="Mdt_Shares">',
        '                                            <DataGrid.Columns>',
        '                                                <DataGridTextColumn Header="Name"        Binding="{Binding Name}" Width="60"/>',
        '                                                <DataGridTextColumn Header="Type"        Binding="{Binding Type}" Width="60"/>',
        '                                                <DataGridTextColumn Header="Root"        Binding="{Binding Root}" Width="250"/>',
        '                                                <DataGridTextColumn Header="Share"       Binding="{Binding Share}" Width="150"/>',
        '                                                <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                                            </DataGrid.Columns>',
        '                                        </DataGrid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="IIS">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Style="{StaticResource Config}"  Content="[FightingEntropy]://Internet Information Services"/>',
        '                                <GroupBox Grid.Row="1" Header="[IIS App Pools]">',
        '                                    <DataGrid Name="IIS_AppPools">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"         Binding="{Binding Name}"         Width="150"/>',
        '                                            <DataGridTextColumn Header="Status"       Binding="{Binding Status}"       Width="80"/>',
        '                                            <DataGridTextColumn Header="AutoStart"    Binding="{Binding AutoStart}"    Width="80"/>',
        '                                            <DataGridTextColumn Header="CLRVersion"   Binding="{Binding CLRVersion}"   Width="80"/>',
        '                                            <DataGridTextColumn Header="PipelineMode" Binding="{Binding PipelineMode}" Width="150"/>',
        '                                            <DataGridTextColumn Header="StartMode"    Binding="{Binding StartMode}"    Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[IIS Sites]">',
        '                                    <DataGrid Name="IIS_Sites">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                            <DataGridTextColumn Header="ID"    Binding="{Binding ID}"    Width="40"/>',
        '                                            <DataGridTextColumn Header="State" Binding="{Binding State}" Width="100"/>',
        '                                            <DataGridTextColumn Header="Path"  Binding="{Binding Path}"  Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Bindings" Width="350">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox ItemsSource="{Binding Bindings}" SelectedIndex="0" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center"/>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="BindCount" Binding="{Binding BindCount}" Width="60"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Domain">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[DcOrganization] - (Company Name)">',
        '                            <TextBox Name="DcOrganization"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Header="[DcCommonName] - (Domain Name)">',
        '                            <TextBox Name="DcCommonName"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="2" Name="DcGetSitename" Content="Get Sitename"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="1" Header="[DcAggregate] - (Provision subdomain/site list)">',
        '                        <DataGrid Name="DcAggregate"',
        '                                                      ScrollViewer.CanContentScroll="True"',
        '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"     Binding="{Binding SiteLink}" Width="120"/>',
        '                                <DataGridTextColumn Header="Location" Binding="{Binding Location}" Width="100"/>',
        '                                <DataGridTextColumn Header="Region"   Binding="{Binding Region}" Width="60"/>',
        '                                <DataGridTextColumn Header="Country"  Binding="{Binding Country}" Width="60"/>',
        '                                <DataGridTextColumn Header="Postal"   Binding="{Binding Postal}" Width="60"/>',
        '                                <DataGridTextColumn Header="TimeZone" Binding="{Binding TimeZone}" Width="120"/>',
        '                                <DataGridTextColumn Header="SiteName" Binding="{Binding SiteName}" Width="Auto"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[DcAddSitenameTown]" IsEnabled="False">',
        '                            <TextBox Name="DcAddSitenameTown"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Header="[DcAddSitenameZip]">',
        '                            <TextBox Name="DcAddSitenameZip"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="2" Name="DcAddSitename" Content="+"/>',
        '                        <Button Grid.Column="3" Name="DcRemoveSitename" Content="-"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="3" Header="[DcViewer] - (View each sites&apos; properties/attributes)">',
        '                        <DataGrid Name="DcViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="4" Header="[DcTopology] - (Output/Existence validation)">',
        '                        <DataGrid Grid.Row="0" Name="DcTopology"',
        '                                                      ScrollViewer.CanContentScroll="True"',
        '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding SiteLink}" Width="150"/>',
        '                                <DataGridTextColumn Header="Sitename" Binding="{Binding SiteName}" Width="200"/>',
        '                                <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="DcGetTopology" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="DcNewTopology" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Network">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Row="0" Header="[NwScope] - (Enter master address/prefix length)">',
        '                            <TextBox Grid.Column="0" Name="NwScope"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="1" Name="NwScopeLoad" Content="Load" IsEnabled="False"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="1" Header="[NwAggregate] - (Provision independent subnets)">',
        '                        <DataGrid Name="NwAggregate"',
        '                                  ScrollViewer.CanContentScroll="True" ',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"      Binding="{Binding Network}"   Width="100"/>',
        '                                <DataGridTextColumn Header="Netmask"   Binding="{Binding Netmask}"   Width="100"/>',
        '                                <DataGridTextColumn Header="HostCount" Binding="{Binding HostCount}" Width="60"/>',
        '                                <DataGridTextColumn Header="Start"     Binding="{Binding Start}"     Width="100"/>',
        '                                <DataGridTextColumn Header="End"       Binding="{Binding End}"       Width="100"/>',
        '                                <DataGridTextColumn Header="Broadcast" Binding="{Binding Broadcast}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[NwSubnetName] - (Add an independent address/prefix length)">',
        '                            <TextBox Name="NwSubnetName"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="1" Name="NwAddSubnetName" Content="+"/>',
        '                        <Button Grid.Column="2" Name="NwRemoveSubnetName" Content="-"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="3" Header="[NwViewer] - (View each subnets&apos; properties/attributes)">',
        '                        <DataGrid Name="NwViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"   Binding="{Binding Name}"   Width="150"/>',
        '                                <DataGridTextColumn Header="Value"  Binding="{Binding Value}"   Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="4" Header="[NwTopology] - (Output/Existence validation)">',
        '                        <DataGrid Name="NwTopology"',
        '                                                          ScrollViewer.CanContentScroll="True"',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"    Binding="{Binding Name}" Width="150"/>',
        '                                <DataGridTextColumn Header="Network" Binding="{Binding Network}" Width="200"/>',
        '                                <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="NwGetSubnetName" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="NwNewSubnetName" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Sitemap">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="120"/>',
        '                        <RowDefinition Height="140"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="1.1*"/>',
        '                            <ColumnDefinition Width="120"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[SmSiteCount] - (Selected sites)">',
        '                            <TextBox Name="SmSiteCount"/>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Header="[SmNetworkCount] - (Selected Subnets)">',
        '                            <TextBox Name="SmNetworkCount"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="2" Name="SmLoadSitemap" Content="Load"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="1" Header="[SmAggregate] - (Sites to be generated)">',
        '                        <DataGrid Name="SmAggregate">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"      Binding="{Binding Name}"     Width="*"/>',
        '                                <DataGridTextColumn Header="Location"  Binding="{Binding Location}" Width="*"/>',
        '                                <DataGridTextColumn Header="Sitename"  Binding="{Binding SiteName}" Width="*"/>',
        '                                <DataGridTextColumn Header="Network"   Binding="{Binding Network}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[SmSiteLink] - (Select main trunk for ISGT/intersite topology generation)">',
        '                        <DataGrid Name="SmSiteLink">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"               Binding="{Binding Name}"              Width="150"/>',
        '                                <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="3" Header="[SmTemplate] - (Create the following objects for each selected site)">',
        '                        <DataGrid Grid.Row="1" Name="SmTemplate">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="ObjectClass" Binding="{Binding ObjectClass}" Width="150"/>',
        '                                <DataGridTemplateColumn Header="Create" Width="*">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Create}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="4" Header="[SmTopology] - (Output/Existence Validation)">',
        '                        <DataGrid Name="SmTopology">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="100"/>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
        '                                <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="5">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="SmGetSitemap" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="SmNewSitemap" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Gateway">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[GwAggregate] - (Provision gateway/router items)">',
        '                        <DataGrid Name="GwAggregate"',
        '                                  ScrollViewer.CanContentScroll="True" ',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="1" Name="GwAddGateway" Content="+" IsEnabled="False"/>',
        '                        <GroupBox Grid.Column="0" Header="[GwGatewayName] - (Enter an individual gateway name)" IsEnabled="False">',
        '                            <TextBox Name="GwGateway"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="2" Name="GwRemoveGateway" Content="-" IsEnabled="False"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="2" Header="[GwViewer] - (View each gateways&apos; properties/attributes)">',
        '                        <DataGrid Name="GwViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="3" Header="[GwTopology] - (Output/Existence validation)">',
        '                        <DataGrid Grid.Row="0" Name="GwTopology">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="SiteName"  Binding="{Binding SiteName}" Width="200"/>',
        '                                <DataGridTextColumn Header="Network"    Binding="{Binding Network}" Width="150"/>',
        '                                <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="GwGetGateway" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="GwNewGateway" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Server">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[SrAggregate] - (Provision server items)">',
        '                        <DataGrid Name="SrAggregate"',
        '                                  ScrollViewer.CanContentScroll="True" ',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                            <ColumnDefinition Width="40"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="1" Name="SrAddServer" Content="+" IsEnabled="False"/>',
        '                        <GroupBox Grid.Column="0" Header="[SrServerName] - (Enter an individual server name)" IsEnabled="False">',
        '                            <TextBox Name="SrServer"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="2" Name="SrRemoveServer" Content="-" IsEnabled="False"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="2" Header="[SrViewer] - (View each servers&apos; properties/attributes)">',
        '                        <DataGrid Name="SrViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="3" Header="[SrTopology] - (Output/Existence validation)">',
        '                        <DataGrid Name="SrTopology">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="SiteName"  Binding="{Binding SiteName}" Width="200"/>',
        '                                <DataGridTextColumn Header="Network"    Binding="{Binding Network}" Width="150"/>',
        '                                <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                    <DataGridTemplateColumn.CellTemplate>',
        '                                        <DataTemplate>',
        '                                            <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                <ComboBoxItem Content="False"/>',
        '                                                <ComboBoxItem Content="True"/>',
        '                                            </ComboBox>',
        '                                        </DataTemplate>',
        '                                    </DataGridTemplateColumn.CellTemplate>',
        '                                </DataGridTemplateColumn>',
        '                                <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="SrGetServer" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="SrNewServer" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Virtual">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Row="0" Header="[VmHost] - (Enter the control virtual machine server)">',
        '                            <TextBox Grid.Column="0" Name="VmHost"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="1" Name="VmHostSelect" Content="Select"/>',
        '                    </Grid>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Control">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="120"/>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="80"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Header="[VmController] - (View virtual machine server/service/credential properties)">',
        '                                    <DataGrid Name="VmController">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Status (Hyper-V Service)" Binding="{Binding Status}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Credential" Binding="{Binding Username}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[VmControllerSwitch] - (External VM switch)">',
        '                                        <ComboBox Name="VmControllerSwitch"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[VmControllerNetwork] - (External network)">',
        '                                        <TextBox Name="VmControllerNetwork"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[VmControllerConfigVM]" IsEnabled="False">',
        '                                        <ComboBox Name="VmControllerConfigVM"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[VmControllerGateway] - (External gateway)">',
        '                                        <TextBox Name="VmControllerGateway"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="3" Header="[VmSelect] - (Output/Existence validation)">',
        '                                    <DataGrid Name="VmSelect">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="100"/>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                            <DataGridTemplateColumn Header="Create VM?" Width="100">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Create}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Gateway">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="180"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[VmGateway] - (Provision physical/virtual machine gateways)">',
        '                                    <DataGrid Grid.Row="0" Name="VmGateway">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="100">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="0" Header="[VmGatewayScript] - (Script to install gateway item)" IsEnabled="False">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmGatewayScriptSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmGatewayScript"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="1" Header="[(RAM/MB)]">',
        '                                        <TextBox Name="VmGatewayMemory"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="0" Header="[VmGatewayImage] - (Image to install gateway item)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmGatewayImageSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmGatewayImage"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="1" Header="[(HDD/GB)]">',
        '                                        <TextBox Name="VmGatewayDrive"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Server">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="180"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[VmServer] - (Provision physical/virtual machine servers)">',
        '                                    <DataGrid  Name="VmServer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="100">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="0" Header="[VmServerScript] - (Script to install virtual servers)" IsEnabled="False">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmServerScriptSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmServerScript"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="1" Header="[(RAM/MB)]">',
        '                                        <TextBox Name="VmServerMemory"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="0" Header="[VmServerImage] - (Image to install virtual servers)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmServerImageSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmServerImage"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="1" Header="[(HDD/GB)]">',
        '                                        <TextBox Name="VmServerDrive"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                    <Grid Grid.Row="4">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="VmGetArchitecture" Content="Get"/>',
        '                        <Button Grid.Column="1" Name="VmNewArchitecture" Content="New"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Imaging">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Row="0" Header="[IsoPath (Source Directory)]">',
        '                            <TextBox Name="IsoPath"  Grid.Column="1"/>',
        '                        </GroupBox>',
        '                        <Button Name="IsoSelect" Grid.Column="1" Content="Select"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="1" Header="[IsoList (*.iso)] - (ISO files found in source directory)">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <DataGrid Grid.Row="0" Name="IsoList">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                    <DataGridTextColumn Header="Path" Binding="{Binding Path}" Width="2*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="IsoMount" Content="Mount" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="IsoDismount" Content="Dismount" IsEnabled="False"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="2">',
        '                        <GroupBox Grid.Row="2" Header="[IsoView (Image Viewer/Wim file selector)]">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <DataGrid Grid.Row="0" Name="IsoView">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Index" Binding="{Binding Index}" Width="40"/>',
        '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="*"/>',
        '                                        <DataGridTextColumn Header="Size"  Binding="{Binding Size}" Width="100"/>',
        '                                        <DataGridTextColumn Header="Architecture" Binding="{Binding Architecture}" Width="100"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="WimQueue" Content="Queue" IsEnabled="False"/>',
        '                                    <Button Grid.Column="1" Name="WimDequeue" Content="Dequeue" IsEnabled="False"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="3" Header="[WimIso (Queued WIM file extraction)]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="60"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Row="0" Name="WimIsoUp" Content="Up"/>',
        '                                <Button Grid.Row="1" Name="WimIsoDown" Content="Down"/>',
        '                                <DataGrid Grid.Column="1" Grid.Row="0" Grid.RowSpan="2" Name="WimIso">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="*"/>',
        '                                        <DataGridTextColumn Header="SelectedIndex" Binding="{Binding SelectedIndex}" Width="100"/>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </Grid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Name="WimSelect" Grid.Column="0" Content="Select"/>',
        '                                <TextBox Grid.Column="1" Name="WimPath"/>',
        '                                <Button Grid.Column="2" Name="WimExtract" Content="Extract"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Updates">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="200"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid>',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="100"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[UpdPath (Update file source directory)]">',
        '                            <TextBox Name="UpdPath"/>',
        '                        </GroupBox>',
        '                        <Button Grid.Column="1" Name="UpdSelect" Content="Select"/>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="1" Header="[UpdSelected] - (Updates found in source directory)">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <DataGrid Grid.Row="0"  Name="UpdAggregate">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="200"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="UpdAddUpdate" Content="Add"/>',
        '                                <Button Grid.Column="1" Name="UpdRemoveUpdate" Content="Remove"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[UpdViewer] - (View properties/attribues of update files)">',
        '                        <DataGrid Name="UpdViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>',
        '                                <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="3" Header="[UpdWim] - (Selected WIM file to inject the update(s) into)">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <DataGrid Grid.Row="0" Name="UpdWim">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                    <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>',
        '                                    <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="UpdInstallUpdate" Content="Install"/>',
        '                                <Button Grid.Column="1" Name="UpdUninstallUpdate" Content="Uninstall"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Share">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="180"/>',
        '                        <RowDefinition Height="160"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[DsAggregate] - (Existing/Provioning deployment shares)">',
        '                        <DataGrid Name="DsAggregate"',
        '                                  ScrollViewer.CanContentScroll="True" ',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"        Binding="{Binding Name}" Width="60"/>',
        '                                <DataGridTextColumn Header="Type"        Binding="{Binding Type}" Width="60"/>',
        '                                <DataGridTextColumn Header="Root"        Binding="{Binding Root}" Width="250"/>',
        '                                <DataGridTextColumn Header="Share"       Binding="{Binding Share}" Width="150"/>',
        '                                <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="1" Header="[DsDriveInfo] - (FileSystem Path), (PSDrive Name), (Legacy MDT/PSD), (Samba/SMB Share), , (Description)">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Grid Grid.Row="0">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="110"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Column="0" Content="[DsRootPath]:"/>',
        '                                <Button  Grid.Column="1" Name="DsRootSelect" Content="Browse"/>',
        '                                <TextBox Grid.Column="2" Name="DsRootPath"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="1">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="110"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="120"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label    Grid.Column="0" Content="[DsDriveName]:"/>',
        '                                <TextBox  Grid.Column="1"  Name="DsDriveName"/>',
        '                                <Label    Grid.Column="2" Content="[DsShareName]:"/>',
        '                                <TextBox  Grid.Column="3" Name="DsShareName"/>',
        '                                <Label    Grid.Column="4" Content="[DsType]:"/>',
        '                                <ComboBox Grid.Column="5" Name="DsType">',
        '                                    <ComboBoxItem Content="MDT"/>',
        '                                    <ComboBoxItem Content="PSD"/>',
        '                                    <ComboBoxItem Content="-"/>',
        '                                </ComboBox>',
        '                            </Grid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="110"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label    Grid.Column="0" Content="[DsDescription]:"/>',
        '                                <TextBox  Grid.Column="1" Name="DsDescription"/>',
        '                                <Button Grid.Column="2" Name="DsAddShare" Content="Add"/>',
        '                                <Button Grid.Column="3" Name="DsRemoveShare" Content="Remove"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[DsShareConfig]">',
        '                        <TabControl>',
        '                            <TabItem Header="Network">',
        '                                <Grid VerticalAlignment="Top">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="80"/>',
        '                                        <RowDefinition Height="80"/>',
        '                                        <RowDefinition Height="80"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <GroupBox Grid.Row="0" Header="[DsNwNetBiosName] - (Enter NetBIOS name)">',
        '                                        <TextBox Name="DsNwNetBiosName"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Header="[DsNwDnsName] - (Enter DNS name)">',
        '                                        <TextBox Name="DsNwDnsName"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Header="[DsNwMachineOuName] - (Enter the organizational unit container for child items)">',
        '                                        <TextBox Name="DsNwMachineOuName"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Domain">',
        '                                <Grid  VerticalAlignment="Top">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="80"/>',
        '                                        <RowDefinition Height="80"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <GroupBox Grid.Row="0" Header="[Domain Admin Username]">',
        '                                        <TextBox Name="DsDcUsername"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Header="[Password/Confirm]">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <PasswordBox Grid.Column="0" Name="DsDcPassword" HorizontalContentAlignment="Left"/>',
        '                                            <PasswordBox Grid.Column="1" Name="DsDcConfirm"  HorizontalContentAlignment="Left"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Local">',
        '                                <Grid VerticalAlignment="Top">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="80"/>',
        '                                        <RowDefinition Height="80"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <GroupBox Grid.Row="0" Header="[Local Admin Username]">',
        '                                        <TextBox Name="DsLmUsername"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Header="[Password/Confirm]">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <PasswordBox Grid.Column="0" Name="DsLmPassword"  HorizontalContentAlignment="Left"/>',
        '                                            <PasswordBox Grid.Column="1" Name="DsLmConfirm"  HorizontalContentAlignment="Left"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Branding">',
        '                                <Grid>',
        '                                    <Grid.Resources>',
        '                                        <Style TargetType="Label">',
        '                                            <Setter Property="HorizontalAlignment" Value="Left"/>',
        '                                            <Setter Property="VerticalAlignment"   Value="Center"/>',
        '                                        </Style>',
        '                                    </Grid.Resources>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="100"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Row="0" Grid.Column="1" Content="[BrPhone]:"/>',
        '                                    <TextBox  Grid.Row="0" Grid.Column="2" Name="DsBrPhone"/>',
        '                                    <Button   Grid.Row="1" Grid.Column="0" Name="DsBrCollect" Content="Collect"/>',
        '                                    <Label    Grid.Row="1" Grid.Column="1" Content="[BrHours]:"/>',
        '                                    <TextBox  Grid.Row="1" Grid.Column="2" Name="DsBrHours"/>',
        '                                    <Label    Grid.Row="2" Grid.Column="1" Content="[BrWebsite]:"/>',
        '                                    <TextBox  Grid.Row="2" Grid.Column="2" Name="DsBrWebsite"/>',
        '                                    <Button   Grid.Row="3" Grid.Column="0" Name="DsBrLogoSelect" Content="Browse"/>',
        '                                    <Label    Grid.Row="3" Grid.Column="1" Content="[BrLogo]:"/>',
        '                                    <TextBox  Grid.Row="3" Grid.Column="2" Name="DsBrLogo"/>',
        '                                    <Button   Grid.Row="4" Grid.Column="0" Name="DsBrBackgroundSelect" Content="Browse"/>',
        '                                    <Label    Grid.Row="4" Grid.Column="1" Content="[BrBackground]:"/>',
        '                                    <TextBox  Grid.Row="5" Grid.Column="2" Name="DsBrBackground"/>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Bootstrap">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="DsGenerateBootstrap" Content="Generate"/>',
        '                                        <TextBox Grid.Column="1" Name="DsBootstrapPath"/>',
        '                                        <Button Grid.Column="2" Name="DsSelectBootstrap" Content="Select"/>',
        '                                    </Grid>',
        '                                    <TextBox Grid.Row="1" Height="200" Background="White" Name="DsBootstrap" Style="{StaticResource Block}"/>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="CustomSettings">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button  Grid.Column="0" Name="DsGenerateCustomSettings" Content="Generate"/>',
        '                                        <TextBox Grid.Column="1" Name="DsCustomSettingsPath"/>',
        '                                        <Button  Grid.Column="2" Name="DsSelectCustomSettings" Content="Select"/>',
        '                                    </Grid>',
        '                                    <TextBox Grid.Row="1" Height="200" Background="White" Name="DsCustomSettings" Style="{StaticResource Block}"/>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="PostConfig">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button  Grid.Column="0" Name="DsGeneratePostConfig" Content="Generate"/>',
        '                                        <TextBox Grid.Column="1" Name="DsPostConfigPath"/>',
        '                                        <Button  Grid.Column="2" Name="DsSelectPostConfig" Content="Select"/>',
        '                                    </Grid>',
        '                                    <TextBox Grid.Row="1" Height="200" Background="White" Name="DsPostConfig" Style="{StaticResource Block}"/>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="3">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <Button Grid.Column="0" Name="DsCreate" Content="Create"/>',
        '                        <Button Grid.Column="1" Name="DsUpdate" Content="Update" IsEnabled="False"/>',
        '                    </Grid>',
        '                </Grid>',
        '            </TabItem>',
        '        </TabControl>',
        '    </Grid>',
        '</Window>' -join "`n")
    }

    Class ModuleFile
    {
        [String] $Mode
        [String] $LastWriteTime
        [String] $Length
        [String] $Name
        [String] $Path
        ModuleFile([Object]$File)
        {
            $This.Mode          = $File.Mode.ToString()
            $This.LastWriteTime = $File.LastWriteTime.ToString()
            $This.Length        = Switch ($File.Length)
            {
                {$_ -lt 1KB}                 { "{0} B"     -f  $File.Length      }
                {$_ -ge 1KB -and $_ -lt 1MB} { "{0:n2} KB" -f ($File.Length/1KB) }
                {$_ -ge 1MB}                 { "{0:n2} MB" -f ($File.Length/1MB) }
            }
            $This.Name          = $File.Name
            $This.Path          = $File.FullName
        }
    }

    # Controller class
    Class Main
    {
        [Object]            $Module = (Get-FEModule)
        Static [String]       $Base = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        Static [String]        $GFX = "$([Main]::Base)\Graphics"
        Static [String]       $Icon = "$([Main]::GFX)\icon.ico"
        Static [String]       $Logo = "$([Main]::GFX)\OEMLogo.bmp"
        Static [String] $Background = "$([Main]::GFX)\OEMbg.jpg"
        Hidden [Object]   $ZipStack
        [Object]            $System
        [Object]               $Win
        [Object]               $Reg
        [Object]            $Config
        [Object]          $IPConfig
        [Object]                $IP
        [Object]              $Dhcp
        [Object]               $Dns
        [Object]           $CfgAdds
        [Object]            $HyperV
        [Object]               $WDS
        [Object]               $MDT
        [Object]               $IIS
        [String]               $Org
        [String]                $CN
        [Object]        $Credential
        [Object]          $Template
        [String]        $SearchBase
        [Object]            $Drives
        [Object]        $EventPorts
        [Object]      $SiteLinkList
        [Object]          $SiteList
        [Object]        $SubnetList
        [Object]            $OUList
        [Object]        $SmTemplate
        [Object]            $Domain
        [Object]           $Network
        [Object]           $Sitemap
        [Object]           $Gateway
        [Object]            $Server
        [Object]           $Service
        [Object]              $ADDS
        [Object]           $Virtual
        [Object]                $Vm
        [Object]                $Sw
        [Object]                $Gw
        [Object]                $Sr
        [Object]             $Image
        [Object]            $Update
        [Object]             $Share
        Main()
        {
            ForEach ( $Item in $This.Module.Tree.Name )
            {
                $This.Module.$Item = @( $This.Module.$Item | % { [ModuleFile]$_ } )
            }

            Write-Host "Collecting [~] System"
            $This.System            = [System]::New()

            Write-Host "Collecting [~] Windows Features"
            $This.Win               = Get-WindowsFeature

            Write-Host "Collecting [~] Windows Registry"
            $This.Reg               = @( "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" })

            Write-Host "Collecting [~] Config"
            $This.Config            = @(

                ForEach ( $Item in "DHCP","DNS","AD-Domain-Services","Hyper-V","WDS","Web-WebServer")
                {
                    [DGList]::New( $Item, [Bool]( $This.Win | ? Name -eq $Item | % Installed ) )
                }
                
                ForEach ( $Item in "MDT","WinADK","WinPE")
                {
                    $Slot = Switch($Item)
                    {
                        MDT    { $This.Reg[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                        WinADK { $This.Reg[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                        WinPE  { $This.Reg[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
                    }
                        
                    [DGList]::New( $Item, [Bool]( Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2] ) )
                }
            )

            Write-Host "Collecting [~] Network IP Config"
            $This.IPConfig          = Get-NetIPConfiguration | % { [IPConfig]$_ }
            $This.IP                = Get-NetIPAddress | % IPAddress
            
            If ($This.Config | ? Name -match DHCP | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Dhcp Server"
                $This.DHCP              = [DhcpServer]::New().Scope
            }

            If ($This.Config | ? Name -match DNS | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Dns Server"
                $This.DNS               = [DnsServer]::New().Zone
            }

            If ($This.Config | ? Name -match AD-Domain-Services | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Adds Server"
                $This.CfgAdds           = [AddsDomain]::New()
            }

            If ($This.Config | ? Name -match Hyper-V | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Hyper-V Server"
                $This.HyperV            = [VmHost]::New($This.IPConfig)
            }

            If ($This.Config | ? Name -match WDS | ? Value -eq 1)
            {
                Write-Host "Collecting [~] WDS Server"
                $This.WDS               = [WDSServer]::New($This.System.Network.IPAddress)
            }

            If ($This.Config | ? Name -match MDT | ? Value -eq 1)
            {
                Write-Host "Collecting [~] MDT/WinPE/WinADK Server"
                $This.MDT               = [MdtServer]::New($This.System.Network.IPAddress,$This.Reg)
            }

            If ($This.Config | ? Name -match Web-WebServer | ? Value -eq 1)
            {
                Write-Host "Collecting [~] IIS Server"
                $This.IIS               = [IISServer]::New()
            }

            Write-Host "Collecting [~] Zipcode Database"
            $This.ZipStack              = [ZipStack]::New("$($This.Module.Path)\Control\zipcode.txt")

            $This.SmTemplate = [SmTemplate]::New().Stack
            $This.Domain     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Network    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Sitemap    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Gateway    = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Server     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Image      = [ImageStack]::New()
            $This.Update     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.Share      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            $This.ADDS       = @{ 

                Gateway      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                Server       = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            }
            $This.Virtual    = @{ 

                Gateway      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                Server       = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
            }

            $This.OUList     = Get-ADObject -Filter * | ? ObjectClass -eq OrganizationalUnit
        }
        SetNetwork([Object]$Xaml,[UInt32]$Index)
        {
            If ($Xaml.System.Network.Count -eq 1)
            {
                $IPInfo                                       = $This.System.Network
            }
            Else
            {
                $IPInfo                                       = $This.System.Network[$Index]
            }

            $X                                                = $IPInfo.DhcpServer -eq ""

            $Xaml.IO.Network_Name.Text                        = $IPInfo.Name
            $Xaml.IO.Network_Name.IsReadOnly                  = 1

            # [Network Type]
            $Xaml.IO.Network_Type.SelectedIndex               = $X

            # [Index]
            $Xaml.IO.Network_Index.Text                       = $IPInfo.Index
            $Xaml.IO.Network_Index.IsReadOnly                 = 1

            # [IPAddress]
            $Xaml.IO.Network_IPAddress.Text                   = $IPInfo.IPAddress
            $Xaml.IO.Network_IPAddress.IsReadOnly             = 1

            # [Subnetmask]
            $Xaml.IO.Network_SubnetMask.Text                  = $IPInfo.SubnetMask
            $Xaml.IO.Network_SubnetMask.IsReadOnly            = 1

            # [Gateway]
            $Xaml.IO.Network_Gateway.Text                     = $IPInfo.Gateway
            $Xaml.IO.Network_Gateway.IsReadOnly               = 1
            
            # [Dns]
            $Xaml.IO.Network_Dns.ItemsSource                  = @( )
            If ( $IPInfo.DNSServer.Count -ne 0)
            {
                $Xaml.IO.Network_DNS.ItemsSource                  = @($IPInfo.DNSServer)
                $Xaml.IO.Network_DNS.SelectedIndex                = 0
            }

            # [Dhcp]
            $Xaml.IO.Network_Dhcp.Text                        = @($IPInfo.DhcpServer,"-")[$IPInfo.DhcpServer -eq ""]
            $Xaml.IO.Network_Dhcp.IsReadOnly                  = 1

            # [MacAddress]
            $Xaml.IO.Network_MacAddress.Text                  = $IPInfo.MacAddress
            $Xaml.IO.Network_MacAddress.IsReadOnly            = 1
        }
        [Void] GetSiteList()
        {
            $This.Sitelist      = Get-ADObject -LDAPFilter "(objectClass=site)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetSiteLinkList()
        {
            $This.SitelinkList  = Get-ADObject -LDAPFilter "(objectClass=siteLink)" -Searchbase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetSubnetList()
        {
            $This.SubnetList    = Get-ADObject -LDAPFilter "(objectClass=subnet)" -SearchBase "CN=Configuration,$($This.SearchBase)"
        }
        [Void] GetOUList()
        {
            $This.OUList        = Get-ADObject -LDAPFilter "(objectClass=OrganizationalUnit)" -SearchBase $This.SearchBase 
        }
        [Object] NewCertificate()
        {
            Return @( [Certificate]::New($This.Org,$This.CN) )
        }
        [Void] LoadSite([String]$Organization,[String]$CommonName)
        {
            $This.Org           = $Organization
            $This.CN            = $CommonName
            $This.Template      = $This.NewCertificate()
            $This.SearchBase    = "DC=$( $CommonName.Split(".") -join ",DC=" )"
            
            $This.AddSiteName( $This.Zipstack.ZipTown($This.Template.Postal))
            $This.GetSiteList()
            $This.GetSiteLinkList()
            $This.GetSubnetList()
        }
        [Void] AddSitename([Object]$Obj)
        {
            $Tmp                = [Certificate]::New($This.Org,$This.CN)
            $Tmp.Location       = $Obj.Name
            $Tmp.Postal         = $Obj.Zip
            $Tmp.Region         = [States]::Name($Obj.State)
            $Tmp.GetSiteLink()
            $This.Domain       += @( $Tmp )
        }
        [Void] RemoveSitename([String]$Zip)
        {
            If ( $This.Domain.Count -gt 1 )
            {
                If ( $Zip -in $This.Domain.Postal )
                {
                    $Tmp                = @( $This.Domain )
                    $This.Domain        = @( )
                    $This.Domain        = @( $Tmp | ? Postal -ne $Zip )
                }
            }
        }
        [Object[]] GetDomain([Object]$List)
        {
            $This.GetSiteList()
            Return @( $List | % { [DcTopology]::New($This.SiteList,$_) } )
        }
        [Void] NewDomain([Object]$List)
        {
            ForEach ( $Item in $This.GetDomain($List) )
            {
                If ( $Item.Exists -eq 0 )
                {
                    Switch([System.Windows.MessageBox]::Show("Create ADReplicationSite?","Item $($Item.Sitelink) does not exist.","YesNo"))
                    {
                        Yes { New-ADReplicationSite -Name $Item.Sitelink -Verbose } No { Write-Host "Skipping $($Item.Sitelink)" }
                    }
                }
            }
        }
        [Void] LoadNetwork([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( [Network]::New($Prefix).Aggregate )
                $This.Network    = @( )
                $This.Network    = @( $Tmp )
            }
        }
        [Void] AddSubnet([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( [Scope]$Prefix )
                $This.Network   += @( $Tmp )
            }
        }
        [Void] RemoveSubnet([String]$Prefix)
        {
            If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)" )
            {
                [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
            }

            Else
            {
                $Tmp             = @( $This.Network | ? Name -ne $Prefix )
                $This.Network    = @( )
                $This.Network    = @( $Tmp )
            }
        }
        [Object[]] GetNetwork([Object]$List)
        {
            $This.GetSubnetList()
            Return @( $List | % { [NwTopology]::New($This.SubnetList,$_) } )
        }
        [Void] NewNetwork([Object]$List)
        {
            ForEach ( $Item in $This.GetNetwork($List) )
            {
                If ( $Item.Exists -eq 0 )
                {
                    Switch([System.Windows.MessageBox]::Show("Create ADReplicationSubnet?","Item $($Item.Name) does not exist.","YesNo"))
                    {
                        Yes { New-ADReplicationSubnet -Name $Item.Name -Verbose } No { Write-Host "Skipping $($Item.Name)" }
                    }
                }
            }
        }
        [Void] LoadSitemap()
        {
            If ($This.Network.Count -lt $This.Domain.Count)
            {
                Throw "Insufficient networks"
            }

            $This.Sitemap = @( )

            ForEach ($X in 0..($This.Domain.Count - 1))
            {
                $This.Sitemap += [Site]::New($This.Domain[$X],$This.Network[$X])
            }
        }
        [Void] RemoveGateway([String]$DistinguishedName)
        {
            If ( $This.Gateway.Count -gt 1 )
            {
                If ($DistinguishedName -in $This.Gateway.DistinguishedName)
                {
                    $This.Gateway = @( $This.Gateway | ? DistinguishedName -ne $DistinguishedName )
                }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("Invalid operation, only one gateway remaining","Error")
            }
        }
        [Void] RemoveServer([String]$DistinguishedName)
        {
            If ( $This.Server.Count -gt 1 )
            {
                If ($DistinguishedName -in $This.Server.DistinguishedName)
                {
                    $This.Server = @( $This.Server | ? DistinguishedName -ne $DistinguishedName )
                }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("Invalid operation, only one gateway remaining","Error")
            }
        }
        [Void] LoadImagePath([String]$ImagePath)
        {
            If ((Test-Path $ImagePath) -and (Get-ChildItem $ImagePath *.iso).Count -gt 0 )
            {
                $This.Image = [ImageStack]::New($ImagePath)
            }
        }
        [Object[]] LoadUpdate([String]$Path)
        {
            Return @( Get-ChildItem $Path -Recurse | ? Extension -match .msu | % FullName )
        }
        [Void] LoadDrives([Object[]]$Drives)
        {
            $This.Drives = $Drives
        }
        [String] GetNextEventPort()
        {
            $Collect = $This.Drives | % { Get-ItemProperty "$($_.Name):" }
            $Port    = @( 9800..9899 | ? { $_ % 2 -eq 0 } | ? { $_ -notin $Collect.MonitorEventPort } )
            Return $Port[0]
        }
        [Object] Enumerate([Hashtable]$Object)
        {
            $Output = @( )
            ForEach ( $Item in $Object.GetEnumerator() )
            {     
                If ( $Item.Value.GetType().Name -eq "Hashtable" )
                {
                    $Output += "[$($Item.Name)]"
                    $Object.$($Item.Name).GetEnumerator() | % { $Output += "$($_.Name)=$($_.Value)" }
                    $Output += ""
                }
            
                Else
                {
                    $Output += "$($Item.Name)=$($Item.Value)"
                    $Output += ""
                }
            }
            Return ($Output -join "`n")
        }
        [Object] Bootstrap([String]$Type,[String]$NetBIOS,[String]$UNC,[String]$UserID,[String]$Password)
        {
            $Output = $Null
            If ($Type -eq "MDT")
            {
                $Output                = @{ 
                    Settings           = @{ 
                        Priority       = "Default" }; 
                    Default            = @{
                        DeployRoot     = $UNC
                        UserID         = $UserID.Split("@")[0]
                        UserPassword   = $Password
                        UserDomain     = $NetBIOS
                        SkipBDDWelcome = "YES"
                    }
                }
            }

            If ($Type -eq "PSD")
            {
                $Output                = @{
                    Settings           = @{
                        Priority       = "Default"
                        Properties     = "PSDDeployRoots"
                    }
                    Default            = @{ 
                        PSDDeployRoots = $UNC
                        UserID         = $UserID.Split("@")[0]
                        UserPassword   = $Password
                        UserDomain     = $NetBIOS
                    }
                }
            }

            Return $This.Enumerate($Output)
        }
        [Object] CustomSettings([String]$Type,[String]$UNC,[String]$Org,[String]$NetBIOS,[String]$DNS,[String]$OU,[String]$UserID,[String]$Password)
        {
            $Output = $Null
            $Port   = $Null
            $Exists = Get-Item "$UNC\Control\CustomSettings.ini" -EA 0
            If ($Exists -eq $Null)
            {
                $Port = $This.GetNextEventPort()
            }
            If ($Exists -ne $Null)
            {
                $Port = [UInt32][Regex]::Matches((Get-Content "$UNC\Control\CustomSettings.ini"),"\/\/.+\:\d{4}").Value.Split(":")[-1]
            }

            If ($Type -eq "MDT")
            {
                $Output                      = @{ 
                    Settings                 = @{
                        Priority             = "Default"
                        Properties           = "MyCustomProperty"
                    }
                    Default                  = @{
                        _SMSTSOrgName        = $Org
                        JoinDomain           = $DNS
                        DomainAdmin          = $UserID
                        DomainAdminPassword  = $Password
                        DomainAdminDomain    = $DNS
                        MachineObjectOU      = $OU
                        SkipDomainMembership = "YES" 
                        OSInstall            = "Y"
                        SkipCapture          = "NO"
                        SkipAdminPassword    = "YES"
                        SkipProductKey       = "YES"
                        SkipComputerBackup   = "NO"
                        SkipBitlocker        = "YES"
                        KeyboardLocale       = "en-US"
                        TimeZoneName         = "$(Get-Timezone | % ID)"
                        EventService         = ("http://{0}:{1}" -f $DNS,$Port)
                    }
                }
            }

            If ($Type -eq "PSD")
            {
                $Output                      = @{
                    Settings                 = @{
                        Priority             = "Default"
                        Properties           = "PSDDeployRoots"
                    }
                    Default                  = @{
                        _SMSTSOrgName        = $Org
                        TimeZoneName         = "$(Get-Timezone | % ID)"
                        KeyboardLocale       = "en-US"
                        EventService         = ("http://{0}:{1}" -f $DNS,$Port)
                    }
                }
            }

            Return $This.Enumerate($Output)
        }
        [Object] PostConfig([String]$Key)
        {
            Return @("[Net.ServicePointManager]::SecurityProtocol = 3072",
            "Invoke-RestMethod https://github.com/mcc85s/FightingEntropy/blob/main/Install.ps1?raw=true | Invoke-Expression",
            "`$Module = Get-FEModule","`$Module.Role.LoadEnvironmentKey(`"$Key`")","`$Module.Role.Choco()" -join "`n")
        }
    }
    
    # These two variables do most of the work
    $Main                           = [Main]::New()
    $Xaml                           = [XamlWindow][FEInfrastructureGUI]::Tab

    <# $Last = $Null
    $Xaml.Names | ? { $_ -notin "ContentPresenter","Border","ContentSite" } | % {
        
        $Item = $_[0,1] -join ""
        If ($Last -eq $Null -or $Item -ne $Last)
        {
            Write-Theme "$Item Tab" -Text
        }
        $X = "    # `$Xaml.IO.$_"
        $Y = $Xaml.IO.$_.GetType().Name 
        "{0}{1} # $Y" -f $X,(" "*(60-$X.Length) -join '')
        $Last = $_[0,1] -join ""
    
    } | Set-Clipboard #>

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Module Tab ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    $Xaml.IO.Module_Info.ItemsSource    = @( )
    $Xaml.IO.Module_Info.ItemsSource    = @( ForEach ( $Item in "Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status" -Split " ")
    {
        $Name = Switch ($Item)
        {
            Default { $Item }
            Date    { "Installation Date" }
            RegPath { "Registry Path"     }
            ModPath { "Module File"       }
            ManPath { "Manifest File"     }
            Path    { "Module Path"       }
            Status  { "Module Status"     }
        }
        [DGList]::New($Name,$Main.Module.$Item) 
    })

    $Xaml.IO.Module_Type.ItemsSource     = @( )
    $Xaml.IO.Module_Type.ItemsSource     = @($Main.Module.Tree)
    $Xaml.IO.Module_Type.SelectedIndex   = 0
    
    $Xaml.IO.Module_Property.ItemsSource   = @( )
    $Xaml.IO.Module_Property.ItemsSource   = @("Name")
    $Xaml.IO.Module_Property.SelectedIndex = 0
    
    $Xaml.IO.Module_Filter.Text            = $Null
    $Xaml.IO.Module_List.ItemsSource       = @( )

    $Xaml.IO.Module_Type.Add_SelectionChanged(
    {
        $Xaml.IO.Module_Filter.Text        = $Null
        $Xaml.IO.Module_List.ItemsSource   = @( )
        $Xaml.IO.Module_List.ItemsSource   = @( $Main.Module."$($Xaml.IO.Module_Type.SelectedItem)" )
        Start-Sleep -Milliseconds 50
    })

    $Xaml.IO.Module_Filter.Add_TextChanged(
    {
        $Xaml.IO.Module_List.ItemsSource   = @( )
        $Xaml.IO.Module_List.ItemsSource   = @( $Main.Module."$($Xaml.IO.Module_Type.SelectedItem)" | ? $Xaml.IO.Module_Property.SelectedItem -match $Xaml.IO.Module_Filter.Text )
        Start-Sleep -Milliseconds 50
    })

    $Xaml.IO.Module_List.ItemsSource       = @( $Main.Module.Classes )

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Role Tab   ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    $Xaml.IO.Role_Info.ItemsSource = @( )
    $Xaml.IO.Role_Info.ItemsSource = @( ForEach ( $Item in "Name DNS NetBIOS Hostname Username IsAdmin Caption Version Build ReleaseID Code SKU Chassis" -Split " ")
    {
        [DGList]::New($Item,$Main.Module.Role.$Item)
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Configuration Tab  ]__________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Config]://Variables
    # $Xaml.IO.CfgServices              # DataGrid
    # $Xaml.IO.CfgDhcp                  # DataGrid
    # $Xaml.IO.CfgDns                   # DataGrid
    # $Xaml.IO.CfgAdds                  # DataGrid
    # $Xaml.IO.CfgHyperV                # DataGrid
    # $Xaml.IO.CfgWds                   # DataGrid
    # $Xaml.IO.CfgMdt                   # DataGrid
    # $Xaml.IO.CfgWinAdk                # DataGrid
    # $Xaml.IO.CfgWinPE                 # DataGrid
    # $Xaml.IO.CfgIIS                   # DataGrid

    # [CfgServices]://$Main.Config
    $Xaml.IO.CfgServices.ItemsSource                  = @( )
    $Xaml.IO.CfgServices.ItemsSource                  = @($Main.Config)

    # [System]
    $Xaml.IO.System_Manufacturer.Text                 = $Main.System.Manufacturer
    $Xaml.IO.System_Manufacturer.IsReadOnly           = 1
    
    $Xaml.IO.System_Model.Text                        = $Main.System.Model
    $Xaml.IO.System_Model.IsReadOnly                  = 1
    
    $Xaml.IO.System_Product.Text                      = $Main.System.Product
    $Xaml.IO.System_Product.IsReadOnly                = 1
    
    $Xaml.IO.System_Serial.Text                       = $Main.System.Serial
    $Xaml.IO.System_Serial.IsReadOnly                 = 1
    
    $Xaml.IO.System_Memory.Text                       = $Main.System.Memory
    $Xaml.IO.System_Memory.IsReadOnly                 = 1
    
    $Xaml.IO.System_UUID.Text                         = $Main.System.UUID
    $Xaml.IO.System_UUID.IsReadOnly                   = 1
        
    # Processor
    $Xaml.IO.System_Processor.ItemsSource             = @( )
    $Xaml.IO.System_Processor.ItemsSource             = @($Main.System.Processor.Name)
    $Xaml.IO.System_Processor.SelectedIndex           = 0
    
    $Xaml.IO.System_Architecture.ItemsSource          = @( )
    $Xaml.IO.System_Architecture.ItemsSource          = @("x86","x64")
    $Xaml.IO.System_Architecture.SelectedIndex        = $Main.System.Architecture -eq "x64"
    $Xaml.IO.System_Architecture.IsEnabled            = 0
    
    # Chassis
    $Xaml.IO.System_IsVM.IsChecked                    = 0
    $Xaml.IO.System_Chassis.ItemsSource               = @( )
    $Xaml.IO.System_Chassis.ItemsSource               = @("Desktop;Laptop;Small Form Factor;Server;Tablet" -Split ";")
    $Xaml.IO.System_Chassis.SelectedIndex             = @{Desktop=0;Laptop=1;"Small Form Factor"=2;Server=3;Tablet=4}[$Main.System.Chassis]
    $Xaml.IO.System_Chassis.IsEnabled                 = 0
    
    $Xaml.IO.System_BiosUefi.ItemsSource              = @( )
    $Xaml.IO.System_BiosUefi.ItemsSource              = @("BIOS","UEFI")
    $Xaml.IO.System_BiosUefi.SelectedIndex            = $Main.System.BiosUEFI -eq "UEFI"
    $Xaml.IO.System_BiosUefi.IsEnabled                = 0
    
    $Xaml.IO.System_Name.Text                         = @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
    
    # Disks
    $Xaml.IO.System_Disk.ItemsSource                  = @( )
    $Xaml.IO.System_Disk.ItemsSource                  = @($Main.System.Disk)

    # [Network]
    $Xaml.IO.Network_Adapter.ItemsSource              = @( )
    $Xaml.IO.Network_Adapter.ItemsSource              = @($Main.System.Network)
    $Xaml.IO.Network_Adapter.Add_SelectionChanged(
    {
        If ($Xaml.IO.Network_Adapter.SelectedIndex -ne -1)
        {
            $Main.SetNetwork($Xaml,$Xaml.IO.Network_Adapter.SelectedIndex)
        }
    })

    $Xaml.IO.Network_Type.ItemsSource                 = @( )
    $Xaml.IO.Network_Type.ItemsSource                 = @("DHCP","Static")
    $Xaml.IO.Network_Type.SelectedIndex               = 0
    
    $Main.SetNetwork($Xaml,0)

    $Xaml.IO.Network_Type.Add_SelectionChanged(
    {
        $Main.SetNetwork($Xaml,$Xaml.IO.Network_Type.SelectedIndex)
    })

    # [DHCP]
    $Xaml.IO.CfgDhcpScopeID.ItemsSource                = @( )
    $Xaml.IO.CfgDhcpScopeReservations.ItemsSource      = @( )
    $Xaml.IO.CfgDhcpScopeOptions.ItemsSource           = @( )
    $Xaml.IO.CfgDhcpScopeID.ItemsSource                = @($Main.Dhcp)
    $Xaml.IO.CfgDhcpScopeID.Add_SelectionChanged(
    {
        If ($Xaml.IO.CfgDhcpScopeID.SelectedIndex -ne -1)
        {
            $Scope = $Xaml.IO.CfgDhcpScopeID.SelectedItem
            
            $Xaml.IO.CfgDhcpScopeReservations.ItemsSource = @( )
            $Xaml.IO.CfgDhcpScopeReservations.ItemsSource = @( $Scope.Reservations )

            $Xaml.IO.CfgDhcpScopeOptions.ItemsSource      = @( )
            $Xaml.IO.CfgDhcpScopeOptions.ItemsSource      = @( $Scope.Options )
        }
    })

    # [Dns]
    $Xaml.IO.CfgDnsZone.ItemsSource              = @( )
    $Xaml.IO.CfgDnsZoneHosts.ItemsSource         = @( )
    $Xaml.IO.CfgDnsZone.ItemsSource              = @( $Main.Dns )
    $Xaml.IO.CfgDnsZone.Add_SelectionChanged(
    {
        If ($Xaml.IO.CfgDnsZone.SelectedIndex -ne -1)
        {
            $Zone = $Xaml.IO.CfgDnsZone.SelectedItem

            $Xaml.IO.CfgDnsZoneHosts.ItemsSource = @( )
            $Xaml.IO.CfgDnsZoneHosts.ItemsSource = @( $Zone.Hosts )
        }
    })

    # [Adds]
    $Xaml.IO.Adds_Hostname.Text         = $Main.CfgAdds.Hostname
    $Xaml.IO.Adds_Hostname.IsReadOnly   = 1

    $Xaml.IO.Adds_DCMode.Text           = $Main.CfgAdds.DCMode
    $Xaml.IO.Adds_DCMode.IsreadOnly     = 1
    
    $Xaml.IO.Adds_DomainMode.Text       = $Main.CfgAdds.DomainMode
    $Xaml.IO.Adds_DomainMode.IsReadOnly = 1

    $Xaml.IO.Adds_ForestMode.Text       = $Main.CfgAdds.ForestMode
    $Xaml.IO.Adds_ForestMode.IsReadOnly = 1

    $Xaml.IO.Adds_Root.Text             = $Main.CfgAdds.Root
    $Xaml.IO.Adds_Root.IsReadOnly       = 1

    $Xaml.IO.Adds_Config.Text           = $Main.CfgAdds.Config
    $Xaml.IO.Adds_Config.IsReadOnly     = 1

    $Xaml.IO.Adds_Schema.Text           = $Main.CfgAdds.Schema
    $Xaml.IO.Adds_Schema.IsReadOnly     = 1

    $Xaml.IO.CfgAddsObject.ItemsSource     = @( )
    $Xaml.IO.CfgAddsType.ItemsSource       = @( )
    $Xaml.IO.CfgAddsType.ItemsSource       = @("Site","Sitelink","Subnet","Dhcp","OU","Computer")
    $Xaml.IO.CfgAddsType.SelectedIndex     = 0

    $Xaml.IO.CfgAddsProperty.ItemsSource   = @( )
    $Xaml.IO.CfgAddsProperty.ItemsSource   = @("Name","GUID","DistinguishedName")
    $Xaml.IO.CfgAddsProperty.SelectedIndex = 0

    $Xaml.IO.CfgAddsType.Add_SelectionChanged(
    {
        Start-Sleep -Milliseconds 50
        $Xaml.IO.CfgAddsFilter.Text        = $Null
        $Xaml.IO.CfgAddsObject.ItemsSource = @( )
        $Xaml.IO.CfgAddsObject.ItemsSource = @( $Main.CfgAdds."$($Xaml.IO.CfgAddsType.SelectedItem)" )
    })

    $Xaml.IO.CfgAddsFilter.Add_TextChanged(
    {
        Start-Sleep -Milliseconds 50
        $Xaml.IO.CfgAddsObject.ItemsSource = @( )
        $Xaml.IO.CfgAddsObject.ItemsSource = @( $Main.CfgAdds."$($Xaml.IO.CfgAddsType.SelectedItem)" | ? $Xaml.IO.CfgAddsProperty.SelectedItem -match $Xaml.IO.CfgAddsFilter.Text )
    })

    # [HyperV]
    $Xaml.IO.CfgHyperV.ItemsSource        = @( )
    $Xaml.IO.CfgHyperV.ItemsSource        = @( $Main.HyperV )
    If ($Main.HyperV)
    {
        $Xaml.IO.VmHost.Text = $Main.HyperV.Name
    }
    $Xaml.IO.CfgHyperV_Switch.ItemsSource = @( )
    $Xaml.IO.CfgHyperV_Switch.ItemsSource = @($Main.HyperV.Switch)
    $Xaml.IO.CfgHyperV_VM.ItemsSource     = @( )
    $Xaml.IO.CfgHyperV_VM.ItemsSource     = @($Main.HyperV.VM)

    $Xaml.IO.WDS_Server.Text              = $Main.WDS.Server
    $Xaml.IO.WDS_IPAddress.ItemsSource    = @( )
    $Xaml.IO.WDS_IPAddress.ItemsSource    = @($Main.WDS.IPAddress)
    $Xaml.IO.WDS_IPAddress.SelectedIndex  = 0

    $Xaml.IO.WDS_Images.ItemsSource       = @( )
    $Xaml.IO.WDS_Images.ItemsSource       = @($Main.WDS.Images)

    # [Mdt/Adk/WinPE]
    $Xaml.IO.MDT_Server.Text              = $Main.MDT.Server
    $Xaml.IO.MDT_IPAddress.ItemsSource    = @( )
    $Xaml.IO.MDT_IPAddress.ItemsSource    = @($Main.MDT.IPAddress)
    $Xaml.IO.MDT_IPAddress.SelectedIndex  = 0
    
    $Xaml.IO.MDT_Path.Text                = $Main.MDT.Path
    $Xaml.IO.MDT_Version.Text             = $Main.MDT.Version
    $Xaml.IO.MDT_ADK_Version.Text         = $Main.MDT.AdkVersion
    $Xaml.IO.MDT_PE_Version.Text          = $Main.MDT.PeVersion
    $Xaml.IO.MDT_Shares.ItemsSource       = @( )
    $Xaml.IO.MDT_Shares.ItemsSource       = @($Main.MDT.Shares)

    # [IIS]
    $Xaml.IO.IIS_AppPools.ItemsSource     = @( )
    $Xaml.IO.IIS_AppPools.ItemsSource     = @($Main.IIS.AppPools)

    $Xaml.IO.IIS_Sites.ItemsSource        = @( )
    $Xaml.IO.IIS_Sites.ItemsSource        = @($Main.IIS.Sites)

    # [DataGrid]://PersistentDrives
    $Xaml.IO.DsAggregate.ItemsSource      = @( )

    # [CfgMdt]://Installed ? -> Load persistent drives
    If ($Main.Config | ? Name -eq MDT | ? Value -eq $True)
    {   
        Get-MDTModule | Import-Module
        Restore-MDTPersistentDrive
        $Drives = Get-MDTPersistentDrive
        $Main.LoadDrives($Drives)
        
        $Xaml.IO.DsAggregate.ItemsSource += [DsShare]::New("<New>","-",$Null,"-",2)
        
        ForEach ($Drive in $Main.Drives)
        {
            $Xaml.IO.DsAggregate.ItemsSource += [DsShare]$Drive
        }
    }

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Domain Tab ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Domain]://Variables
    # $Xaml.IO.DcOrganization           # Text
    # $Xaml.IO.DcCommonName             # Text
    # $Xaml.IO.DcGetSitename            # Button
    # $Xaml.IO.DcAggregate              # DataGrid
    # $Xaml.IO.DcAddSitename            # Button
    # $Xaml.IO.DcAddSitenameZip         # Text
    # $Xaml.IO.DcAddSitenameTown        # Text
    # $Xaml.IO.DcRemoveSitename         # Button
    # $Xaml.IO.DcViewer                 # DataGrid
    # $Xaml.IO.DcTopology               # DataGrid
    # $Xaml.IO.DcGetTopology            # Button
    # $Xaml.IO.DcNewTopology            # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.DcAggregate.ItemsSource    = @( )
    $Xaml.IO.DcViewer.ItemsSource       = @( )
    $Xaml.IO.DcTopology.ItemsSource     = @( )

    # [Domain]://Events
    $Xaml.IO.DcGetSitename.Add_Click(
    {
        If (!$Xaml.IO.DcOrganization.Text)
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null organization entry","Error")
        }

        ElseIf (!$Xaml.IO.DcCommonName.Text)
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null common name entry","Error")
        }

        Else
        {   # $Main.LoadSite("Secure Digits Plus LLC","securedigitsplus.com")
            $Main.LoadSite($Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text)
            $Xaml.IO.DcAggregate.ItemsSource   = @( )
            $Xaml.IO.DcAggregate.ItemsSource   = @( $Main.Domain )
            $Xaml.IO.DcGetSitename.IsEnabled   = 0
            $Xaml.IO.NwScopeLoad.IsEnabled     = 1
        }
    })

    $Xaml.IO.DcAggregate.Add_SelectionChanged(
    {
        $Object = $Xaml.IO.DcAggregate.SelectedItem
        If ( $Object )
        {
            $Xaml.IO.DcViewer.ItemsSource = @( )
            $Xaml.IO.DcViewer.ItemsSource = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName" -Split " " )
            {
                [DGList]::New($Item,$Object.$Item)
            }
        }
    })    

    $Xaml.IO.DcAddSitename.Add_Click(
    {
        $Return = $Main.Zipstack.ZipTown([UInt32]$Xaml.IO.DcAddSitenameZip.Text)

        If ($Return.Type -match "Invalid")
        {
            Return [System.Windows.MessageBox]::Show("Not a valid zip code","Error")
        }

        ElseIf ($Return.Zip -in $Main.Domain.Postal)
        {
            Return [System.Windows.MessageBox]::Show("That entry already exists","Error")
        }

        Else
        {
            $Main.AddSitename([Object]$Return)
            $Xaml.IO.DcAggregate.ItemsSource  = @( )
            $Xaml.IO.DcAggregate.ItemsSource  = @( $Main.Domain )
            $Xaml.IO.DcAddSitenameZip.Text    = ""
        }
    })

    $Xaml.IO.DcRemoveSitename.Add_Click(
    {
        If ( $Xaml.IO.DcAggregate.SelectedIndex -gt -1)
        {
            Switch($Main.Domain.Count)
            {
                1
                { 
                    Return [System.Windows.MessageBox]::Show("Count cannot be 1","Last site remaining")
                }

                Default
                {
                    $Item                            = $Xaml.IO.DcAggregate.SelectedItem
                    $Main.Domain                     = ForEach ( $Object in $Main.Domain )
                    {
                        If ( $Object.Postal -notmatch $Item.Postal )
                        {
                            $Object
                        }
                    }
                    $Xaml.IO.DcAggregate.ItemsSource = @( )
                    $Xaml.IO.DcAggregate.ItemsSource = @( $Main.Domain )
                }
            }
        }
    })

    $Xaml.IO.DcGetTopology.Add_Click(
    {
        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopology]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmSiteCount.Text         = $Main.Domain.Count
    })
    
    $Xaml.IO.DcNewTopology.Add_Click(
    {
        ForEach ( $Item in $Xaml.IO.DcTopology.ItemsSource )
        {
            If ( $Item.Exists -eq 0 )
            {
                New-ADReplicationSite -Name $Item.Sitelink -Verbose
            }
        }

        $Tmp                              = @( $Main.GetDomain($Main.Domain) | % { [DcTopology]::New($Main.SiteList,$_) } )
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmSiteCount.Text         = $Main.Domain.Count
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Network Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Network]://Variables
    # $Xaml.IO.NwScope                  # Text
    # $Xaml.IO.NwScopeLoad              # Button
    # $Xaml.IO.NwAggregate              # DataGrid
    # $Xaml.IO.NwViewer                 # DataGrid
    # $Xaml.IO.NwAddNetwork             # Button
    # $Xaml.IO.NwRemoveNetwork          # Button
    # $Xaml.IO.NwTopology               # DataGrid
    # $Xaml.IO.NwGetNetwork             # Button
    # $Xaml.IO.NwNewNetwork             # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.NwAggregate.ItemsSource    = @( )
    $Xaml.IO.NwViewer.ItemsSource       = @( )
    $Xaml.IO.NwTopology.ItemsSource     = @( )

    # [Network]://Events
    $Xaml.IO.NwScopeLoad.Add_Click(
    {
        If ($Xaml.IO.NwScope.Text -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
        }

        Else
        {   # $Main.LoadNetwork("172.16.0.1/19")
            $Main.LoadNetwork($Xaml.IO.NwScope.Text)
            $Xaml.IO.NwScope.Text              = ""
            $Xaml.IO.NwAggregate.ItemsSource   = @( )
            $Xaml.IO.NwViewer.ItemsSource      = @( )
            $Xaml.IO.NwAggregate.ItemsSource   = @( $Main.Network )
        }
    })

    $Xaml.IO.NwAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.NwViewer.ItemsSource     = @( )

        If ( $Xaml.IO.NwAggregate.SelectedIndex -gt -1 )
        {
            $Network                           = @( $Main.Network | ? Network -match $Xaml.IO.NwAggregate.SelectedItem.Network )
            
            $List = ForEach ( $Item in "Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Network.$Item) 
            }

            $Xaml.IO.NwViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.NwAddSubnetName.Add_Click(
    {
        $Prefix = $Xaml.IO.NwSubnetName.Text
        If ( $Prefix -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            Return [System.Windows.MessageBox]::Show("Invalid subnet provided","Error")
        }
        ElseIf( $Prefix -in $Main.Network.Name )
        {
            Return [System.Windows.MessageBox]::Show("Prefix already exists","Error")
        }
        Else
        {
            $Main.AddSubnet($Prefix)
            $Xaml.IO.NwSubnetName.Text       = ""
            $Xaml.IO.NwAggregate.ItemsSource = @( )
            $Xaml.IO.NwAggregate.ItemsSource = @( $Main.Network )
        }
    })

    $Xaml.IO.NwRemoveSubnetName.Add_Click(
    {
        If ( $Xaml.IO.NwAggregate.SelectedIndex -gt -1 )
        {
            $Main.Network                     = $Main.Network | ? Name -ne $Xaml.IO.NwAggregate.SelectedItem.Name
            $Xaml.IO.NwAggregate.ItemsSource  = @( )
            $Xaml.IO.NwAggregate.ItemsSource  = @( $Main.Network )
        }

        Else
        {
            Return [System.Windows.MessageBox]::Show("Select a subnet within the dialog box","Error")
        }
    })

    $Xaml.IO.NwGetSubnetName.Add_Click(
    {
        $Main.GetSubnetList()
        If (!$Main.SubnetList)
        {
            Throw "No valid networks detected"
        }
        
        $Xaml.IO.NwTopology.ItemsSource = @( )

        ForEach ( $Item in $Xaml.IO.NwAggregate.ItemsSource | % { [NwTopology]::New($Main.SubnetList,$_) } )
        {
            $Xaml.IO.NwTopology.ItemsSource += $Item
        }

        $Xaml.IO.SmNetworkCount.Text      = $Main.Network.Count 
    })

    $Xaml.IO.NwNewSubnetName.Add_Click(
    {
        ForEach ($Item in $Xaml.IO.NwTopology.ItemsSource)
        {
            If (!$Item.Exists)
            {
                New-ADReplicationSubnet -Name $Item.Name -Verbose
            }
        }

        $Tmp                              = @( $Main.GetNetwork($Main.Network) | % { [NwTopology]::New($Main.SubnetList,$_) } )
        $Xaml.IO.NwTopology.ItemsSource   = @( )
        $Xaml.IO.NwTopology.ItemsSource   = @( $Tmp )

        $Xaml.IO.SmNetworkCount.Text      = $Main.Network.Count
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Sitemap Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # $Xaml.IO.SmSiteCount               # TextBox
    # $Xaml.IO.SmNetworkCount            # TextBox
    # $Xaml.IO.SmLoadSitemap             # Button
    # $Xaml.IO.SmAggregate               # DataGrid
    # $Xaml.IO.SmTemplate                # DataGrid
    # $Xaml.IO.SmGetSitemap              # Button
    # $Xaml.IO.SmNewSitemap              # Button

    $Xaml.IO.SmTemplate.ItemsSource  = @( )
    $Xaml.IO.SmAggregate.ItemsSource = @( )
    $Xaml.IO.SmSiteLink.ItemsSource  = @( )
    $Xaml.IO.SmTopology.ItemsSource  = @( )

    $Xaml.IO.SmLoadSitemap.Add_Click(
    {
        If ($Main.Network.Count -lt $Main.Domain.Count)
        {
            Return [System.Windows.MessageBox]::Show("Insufficient networks","Error: Network count")
        }
    
        Else
        {
            $Main.LoadSitemap()
            $Xaml.IO.SmAggregate.ItemsSource = @( )
            $Xaml.IO.SmSiteLink.ItemsSource  = @( )
            $Xaml.IO.SmAggregate.ItemsSource = @( $Main.Sitemap )
            $Xaml.IO.SmSiteLink.ItemsSource  = @( $Main.Sitelinklist )
            If ( $Xaml.IO.SmAggregate.Items.Count -gt 0 )
            {
                $Xaml.IO.SmTemplate.ItemsSource  = @( $Main.SmTemplate )
            }
        }
    })

    $Xaml.IO.SmGetSitemap.Add_Click(
    {
        $Xaml.IO.SmTopology.ItemsSource = @( )

        ForEach ($Item in $Xaml.IO.SmAggregate.ItemsSource)
        {
            $Xaml.IO.SmTopology.ItemsSource += [SwTopologyBranch]::New("Main",$Item.Name,$Main.SearchBase,$Main.OUList)

            ForEach ($Name in $Xaml.IO.SmTemplate.Items | ? Create -eq 1)
            {
                $Xaml.IO.SmTopology.ItemsSource += [SwTopologyBranch]::New("Leaf","$($Item.Name)/$($Name.ObjectClass)",$Main.SearchBase,$Main.OUList)
            }
        }

        $Main.GetOUList()

        $Main.Sitelist                    = $Xaml.IO.SmTopology.ItemsSource
        $Main.Gateway                     = $Main.Sitelist | ? Name -eq Gateway
        $Main.Server                      = $Main.Sitelist | ? Name -eq Server

        $Xaml.IO.GwAggregate.ItemsSource  = $Main.Gateway
        $Xaml.IO.SrAggregate.ItemsSource  = $Main.Server
    })

    $Xaml.IO.SmNewSitemap.Add_Click(
    {
        If ( $Xaml.IO.SmSiteLink.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a master site link","Error")
        }

        ForEach ($X in 0..($Xaml.IO.SmTopology.ItemsSource.Count-1))
        {
            $Item               = $Xaml.IO.SmTopology.Items[$X]
            $Site               = $Main.Sitemap | ? Name -match ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ($Item.Exists -eq $False)
            {
                $OU             = @{

                    City        = $Site.Location
                    Country     = $Site.Country
                    Description = $Site.Hash.Network.Name
                    DisplayName = $Site.SiteName
                    PostalCode  = $Site.Postal
                    State       = $Site.Region
                    Name        = $Item.Name
                    Path        = $Item.DistinguishedName -Replace "OU=$($Item.Name),",""
                }        
                New-ADOrganizationalUnit @OU -Verbose
                Set-ADReplicationSiteLink -Identity $Xaml.IO.SmSiteLink.SelecteItem.DistinguishedName -SitesIncluded @{"Add"=$OU.Path} -Verbose
                $Location       = ("{0}, {1} {2}" -f $OU.City, $OU.State, $OU.PostalCode)
                Get-ADReplicationSubnet -Filter * | ? Name -match $OU.Description | Set-ADReplicationSubnet -Location $Location -Site $Item.Name -Verbose

                $Item.Exists    = $True
            }

            Else
            {
                Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
            }
        }
        
        $Main.Sitelist                    = $Xaml.IO.SmTopology.ItemsSource
        $Main.Gateway                     = $Main.Sitelist | ? Name -eq Gateway
        $Main.Server                      = $Main.Sitelist | ? Name -eq Server

        $Xaml.IO.GwAggregate.ItemsSource  = $Main.Gateway
        $Xaml.IO.SrAggregate.ItemsSource  = $Main.Server
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Gateway Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Gateway]://Variables
    # $Xaml.IO.GwSiteCount               # TextBox
    # $Xaml.IO.GwNetworkCount            # TextBox
    # $Xaml.IO.GwAggregate               # DataGrid
    # $Xaml.IO.GwAddGateway              # Button
    # $Xaml.IO.GwGateway                 # TextBox
    # $Xaml.IO.GwRemoveGateway           # Button
    # $Xaml.IO.GwViewer                  # DataGrid
    # $Xaml.IO.GwTopology                # DataGrid
    # $Xaml.IO.GwGetGateway              # Button
    # $Xaml.IO.GwNewGateway              # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.GwAggregate.ItemsSource    = @()
    $Xaml.IO.GwViewer.ItemsSource       = @()
    $Xaml.IO.GwTopology.ItemsSource     = @()

    # [Gateway]://Events

    $Xaml.IO.GwAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.GwViewer.ItemsSource     = @( )

        If ( $Xaml.IO.GwAggregate.SelectedIndex -gt -1 )
        {
            $Gateway                           = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.GwAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            
            $List = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Gateway.$Item) 
            }

            $Xaml.IO.GwViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.GwRemoveGateway.Add_Click(
    {
        If ( $Xaml.IO.GwAggregate.SelectedIndex -gt -1)
        {
            $Tmp = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.GwAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ( $Tmp.Name -in $Main.Sitemap.Name)
            {
                $Main.RemoveGateway($Tmp.Name)
                $Xaml.IO.GwAggregate.ItemsSource = @( )
                $Xaml.IO.GwAggregate.ItemsSource = @( $Main.Gateway )
            }
        }
    })

    $Xaml.IO.GwGetGateway.Add_Click(
    {
        $Xaml.IO.GwTopology.ItemsSource = @( )
        $Main.ADDS.Gateway              = @( )

        ForEach ( $Item in $Xaml.IO.GwAggregate.ItemsSource )
        {
            $Main.ADDS.Gateway += $Main.Sitemap | ? Name -eq ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value) | % { [Topology]::New("Gateway",$Item.DistinguishedName,$_)}
        }

        $Xaml.IO.GwTopology.ItemsSource = @($Main.ADDS.Gateway)
    })

    $Xaml.IO.GwNewGateway.Add_Click(
    {
        ForEach ( $X in 0..($Xaml.IO.GwTopology.ItemsSource.Count - 1))
        {
            $Item = $Xaml.IO.GwTopology.Items[$X]
            If ($Item.Exists -eq $False)
            {
                $Split = $Item.DistinguishedName -Split ","
                $Path  = $Split[1..($Split.Count-1)] -join ","
                New-ADComputer -Name $Item.Name -DNSHostName $Item.Sitename -Path $Path -TrustedForDelegation:$True -Verbose
                $Item.Exists = $True
            }

            Else
            {
                Write-Host ("Item Exists [+] [{0}]" -f $Item.DistinguishedName) -F 10
            }
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Server Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Server]://Variables
    # $Xaml.IO.SrSiteCount               # TextBox
    # $Xaml.IO.SrNetworkCount            # TextBox
    # $Xaml.IO.SrAggregate               # DataGrid
    # $Xaml.IO.SrAddGateway              # Button
    # $Xaml.IO.SrGateway                 # TextBox
    # $Xaml.IO.SrRemoveGateway           # Button
    # $Xaml.IO.SrViewer                  # DataGrid
    # $Xaml.IO.SrTopology                # DataGrid
    # $Xaml.IO.SrGetGateway              # Button
    # $Xaml.IO.SrNewGateway              # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.SrAggregate.ItemsSource    = @()
    $Xaml.IO.SrViewer.ItemsSource       = @()
    $Xaml.IO.SrTopology.ItemsSource     = @()

    # [Server]://Events
    $Xaml.IO.SrAggregate.Add_SelectionChanged(
    {
        $Xaml.IO.SrViewer.ItemsSource     = @( )

        If ( $Xaml.IO.SrAggregate.SelectedIndex -gt -1 )
        {
            $Server                           = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.SrAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            
            $List = ForEach ( $Item in "Location Region Country Postal TimeZone SiteLink SiteName Name Network Prefix Netmask Start End Range Broadcast".Split(" ") )
            {     
                [DGList]::New($Item,$Server.$Item) 
            }

            $Xaml.IO.SrViewer.ItemsSource     = @( $List )
        }
    })

    $Xaml.IO.SrRemoveServer.Add_Click(
    {
        If ( $Xaml.IO.SrAggregate.SelectedIndex -gt -1)
        {
            $Tmp = $Main.Sitemap | ? Name -eq ([Regex]::Matches($Xaml.IO.SrAggregate.SelectedItem.DistinguishedName,"(\w{2}\-){3}\d+").Value)
            If ( $Tmp.Name -in $Main.Sitemap.Name)
            {
                $Main.RemoveServer($Tmp.Name)
                $Xaml.IO.SrAggregate.ItemsSource = @( )
                $Xaml.IO.SrAggregate.ItemsSource = @( $Main.Server )
            }
        }
    })

    $Xaml.IO.SrGetServer.Add_Click(
    {
        $Xaml.IO.SrTopology.ItemsSource = @( )
        $Main.ADDS.Server               = @( )

        ForEach ( $Item in $Xaml.IO.SrAggregate.ItemsSource )
        {
            $Main.ADDS.Server += $Main.Sitemap | ? Name -eq ([Regex]::Matches($Item.DistinguishedName,"(\w{2}\-){3}\d+").Value) | % { [Topology]::New("Server",$Item.DistinguishedName,$_)}
        }

        $Main.Adds.Server | % { $_.Name = $_.DistinguishedName.Split(",")[0].Replace("CN=","") }

        $Xaml.IO.SrTopology.ItemsSource = @($Main.ADDS.Server)
    })

    $Xaml.IO.SrNewServer.Add_Click(
    {
        ForEach ( $X in 0..($Xaml.IO.SrTopology.ItemsSource.Count - 1))
        {
            $Item      = $Xaml.IO.SrTopology.Items[$X]
            $Split     = $Item.DistinguishedName -Split ","
            $Path      = $Split[1..($Split.Count-1)] -join ","
            $Item.Name = $Split[0].Replace("CN=","")
            $Split     = $Item.SiteName -Split "."
            $DNSName   = $Item.Name,$Split[1..($Split.Count-1)] -join "."
            If ($Item.Exists -eq $False)
            {
                New-ADComputer -Name $Item.Name -DNSHostName $DNSName -Path $Path -TrustedForDelegation:$True -Verbose
                $Item.Exists = $True
            }

            Else
            {
                Write-Host ("Item Exists [+] [{0}]" -f $Item.DistinguishedName) -F 10
            }
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Virtual Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # $Xaml.IO.VmSelect                  # DataGrid
    # $Xaml.IO.VmHostSelect              # Button
    # $Xaml.IO.VmHost                    # TextBox
    # $Xaml.IO.VmPopulate                # Button
    # $Xaml.IO.VmGateway                 # DataGrid
    # $Xaml.IO.VmGatewayScriptSelect     # Button
    # $Xaml.IO.VmGatewayScript           # TextBox
    # $Xaml.IO.VmGatewayImageSelect      # Button
    # $Xaml.IO.VmGatewayImage            # TextBox
    # $Xaml.IO.VmGatewayMemory           # TextBox
    # $Xaml.IO.VmGatewayDrive            # TextBox
    # $Xaml.IO.VmServer                  # DataGrid
    # $Xaml.IO.VmServerScriptSelect      # Button
    # $Xaml.IO.VmServerScript            # TextBox
    # $Xaml.IO.VmServerImageSelect       # Button
    # $Xaml.IO.VmServerImage             # TextBox
    # $Xaml.IO.VmServerMemory            # TextBox
    # $Xaml.IO.VmServerDrive             # TextBox
    # $Xaml.IO.VmGetArchitecture         # Button
    # $Xaml.IO.VmNewArchitecture         # Button

    $Xaml.IO.VmSelect.ItemsSource        = @( )
    $Xaml.IO.VmHostSelect.Add_Click(
    {
        If ($Xaml.IO.VmHost.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter a server hostname or IP address","Error")
        }

        ElseIf ((Test-Connection -ComputerName $Xaml.IO.VmHost.Text -Count 1 -EA 0) -eq $Null)
        {
            Return [System.Windows.Messagebox]::Show("Not a valid server hostname or IP Address","Error")
        }

        $Credential = Try 
        {
            Get-Credential
        }
        Catch
        {
            Return [System.Windows.MessageBox]::Show("No credential","Error")
        }

        Write-Host "Retrieving [~] VMHost"

        If ( $Xaml.IO.VmHost.Text -match "localhost" -or $Xaml.IO.VmHost.Text -in $Main.IP -or $Xaml.IO.VmHost.Text -match $Main.Module.Role.Name)
        {
            $Main.Vm    = [VmStack]::New($Main.HyperV,$Main.HyperV.Switch)
            If (Get-Service -Name vmms -EA 0 | ? Status -ne Running)
            {
                Return [System.Windows.MessageBox]::Show("The Hyper-V Virtual Machine Management service is not (installed/running)","Error")
            }

            $Xaml.IO.VmController.ItemsSource         = @([VmController]::New($Xaml.IO.VmHost.Text,$Credential))
        }
        Else
        {
            Return [System.Windows.MessageBox]::Show("Remote Hyper-V Server not implemented","Error")
        }
        
        $Xaml.IO.VmControllerSwitch.ItemsSource   = @( $Main.Vm.Switch | ? Type -eq External | % Name )
        # $Xaml.IO.VmControllerSwitch.SelectedIndex = 0
        $Xaml.IO.VmSelect.ItemsSource             = @( )
        $Collect                                  = @( )

        If ( $Main.ADDS.Gateway.Count -gt 0 )
        {
            $Main.ADDS.Gateway           | % { $Collect += $_ }
        }

        If ( $Main.ADDS.Server.Count -gt 0 )
        {
            $Main.ADDS.Server            | % { $Collect += $_ }
        }

        $Xaml.IO.VmSelect.ItemsSource    = @([VmSelect[]]$Collect)
        
        Write-Host "Retrieved [+] VMHost"
    })

    $Xaml.IO.VmControllerSwitch.Add_SelectionChanged(
    {
        $NetRoute = Get-NetAdapter | ? Name -match $Xaml.IO.VmControllerSwitch.SelectedItem | Get-NetRoute -AddressFamily IPV4
        $Xaml.IO.VmControllerNetwork.Text = $NetRoute | ? NextHop -eq 0.0.0.0 | Select-Object -Last 1 | % DestinationPrefix
        $Xaml.IO.VmControllerGateway.Text = $NetRoute | ? NextHop -ne 0.0.0.0 | % NextHop
    })

    $Xaml.IO.VmGatewayScriptSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }

        $Xaml.IO.VmGatewayScript.Text = $Item.FileName
    })

    $Xaml.IO.VmGatewayImageSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }
    
        $Xaml.IO.VmGatewayImage.Text = $Item.FileName
    })

    $Xaml.IO.VmServerScriptSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }

        $Xaml.IO.VmServerScript.Text = $Item.FileName
    })

    $Xaml.IO.VmServerImageSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }
    
        $Xaml.IO.VmServerImage.Text = $Item.FileName
    })

    $Xaml.IO.VmGatewayMemory.Text        = "2048"
    $Xaml.IO.VmGatewayDrive.Text         = "20"
    $Xaml.IO.VmServerMemory.Text         = "4096"
    $Xaml.IO.VmServerDrive.Text          = "100"

    $Xaml.IO.VMGetArchitecture.Add_Click(
    {
        $Main.Virtual.Gateway            = @( )
        $Main.Virtual.Server             = @( )

        ForEach ( $Item in $Xaml.IO.VmSelect.Items )
        {
            Switch($Item.Type)
            {
                Gateway 
                { 
                    If ($Item.Create -eq 1 )
                    {
                        $Main.Virtual.Gateway += $Main.Adds.Gateway | ? Name -eq $Item.Name
                    } 
                }
                Server  
                { 
                    If ($Item.Create -eq 1 )
                    {     
                        $Main.Virtual.Server  += $Main.Adds.Server | ? Name -eq $Item.Name
                    } 
                }
            }
        }

        $Xaml.IO.VmGateway.ItemsSource   = @($Main.Virtual.Gateway | % { [VmTest]$_.Name } )
        $Xaml.IO.VmServer.ItemsSource    = @($Main.Virtual.Server  | % { [VmTest]$_.Name } )
    })
    
    $Xaml.IO.VMNewArchitecture.Add_Click(
    {
        If (!$Xaml.IO.VmGatewayImage.Text)
        {
            Return [System.Windows.MessageBox]::Show("Must input an image to install virtual gateway(s)","Error")
        }

        If (!(Test-Path $Xaml.IO.VmGatewayImage.Text) -or $Xaml.IO.VmGatewayImage.Text.Split(".")[-1] -ne "iso" )
        {
            Return [System.Windows.MessageBox]::Show("Not a valid image (path/file)","Error")
        }

        If (!$Xaml.IO.VmServerImage.Text)
        {
            Return [System.Windows.MessageBox]::Show("Must input an image to install virtual server(s)","Error")
        }

        If (!(Test-Path $Xaml.IO.VmServerImage.Text) -or $Xaml.IO.VmServerImage.Text.Split(".")[-1] -ne "iso" )
        {
            Return [System.Windows.MessageBox]::Show("Not a valid image (path/file)","Error")
        }

        If(!($Main.Vm))
        {
            Return [System.Windows.MessageBox]::Show("Must have Hyper-V running","Error")
        }

        $Main.Credential    = Get-Credential root

        # Create the virtual switches
        Write-Theme "Deploying [~] [VMSwitch[]]" 14,6,15
        $Main.Sw = @( )
        ForEach ( $X in 0..($Main.Virtual.Gateway.Count-1))
        {
            $Sw = $Main.Virtual.Gateway[$X]
            If (Get-VMSwitch -Name $Sw.Name -EA 0)
            {
                Write-Theme "Removing [~] [Switch: $($Sw.Name)]" 12,4,15
                Remove-VMSwitch -Name $Sw.Name -Verbose -Confirm:$False -Force
            }

            Write-Theme "Creating [~] [Switch: $($Sw.Name)]" 9,1,15
            $Main.Sw += New-VMSwitch -Name $Sw.Name -SwitchType Internal -Verbose
        }
        Write-Theme "Deployed [+] [VMSwitch[]]" 10,2,15
        Start-Sleep 2

        Write-Theme "Updating [~] `$Main.Vm.Switch"
        $Main.Vm.Switch = Get-VMSwitch

        # Create the virtual gateways
        Write-Theme "Creating [~] [VMGateway[]]" 14,6,15
        $Main.Gw = @( )
        ForEach ( $X in 0..($Main.Virtual.Gateway.Count-1))
        {
            $Gw = $Main.Virtual.Gateway[$X]
            If (Get-VM -Name $Gw.Name -EA 0)
            {
                Write-Theme "Removing [~] [Gateway: $($Gw.Name)]" 12,4,15
                Remove-VM -Name $Gw.Name -Verbose -Confirm:$False -Force
            }

            Write-Theme "Creating [~] [Gateway: $($Gw.Name)]" 9,1,15
            $Item     = [VMObject]::New($Gw,$Xaml.IO.VmGatewayMemory.Text,$Xaml.IO.VmGatewayDrive.Text,1,$Main.Vm.External.Name)
            $Item.New($Main.VM.Host.VirtualMachinePath)
            Add-VMNetworkAdapter -VMName $Item.Name -SwitchName $Item.Name -Verbose
            $Item.LoadISO($Xaml.IO.VmGatewayImage.Text)
            $Item.Start()
            $Item.Stop()
            $Main.Gw += $Item
        }

        Write-Theme "Created [+] [VMGateway[]]" 10,2,15
        Start-Sleep 2

        # Create the virtual servers
        Write-Theme "Creating [~] [VMServer[]]" 14,6,15
        $Main.Sr = @( )
        ForEach ( $X in 0..($Main.Virtual.Server.Count-1))
        {
            $Sr = $Main.Virtual.Server[$X]
            If (Get-VM -Name $Sr.Name -EA 0)
            {
                Write-Theme "Removing [~] [Server: $($Sr.Name)]" 12,4,15
                Remove-VM -Name $Sr.Name -Verbose -Confirm:$False -Force
            }
                    
            Write-Theme "Creating [~] [Server: $($Sr.Name)]" 9,1,15
            $Item     = [VMObject]::New($Sr,$Xaml.IO.VmServerMemory.Text,$Xaml.IO.VmServerDrive.Text,2,$Main.Sw[$X].Name)
            $Item.New($Main.VM.Host.VirtualMachinePath)
            $VM       = Get-VM -Name $Item.Name
            $VM       | Add-VMDVDDrive -Verbose
            $Item.LoadISO($Xaml.IO.VmServerImage.Text)
            $Item.Start()
            $Item.Stop()
            $BootOrder = $VM | Get-VMFirmware | % { $_.BootOrder[2,0,1] }
            $VM        | Set-VMFirmware -BootOrder $BootOrder -Verbose
            $Main.Sr  += $Item
        }

        Write-Theme "Created [+] [VMServer[]]" 10,2,15
        Start-Sleep 2

        # Preparing [DNS/DHCP/MacAddress Stuff]
        $DNS      = Get-DNSServerResourceRecord -Zonename $Main.CN

        ForEach ( $Name in $Main.Gw.Name )
        {
            $DNS  | ? HostName -match $Item | Remove-DNSServerResourceRecord -ZoneName $Main.CN -Verbose -Confirm:$False -Force
        }

        $ScopeID  = Get-DhcpServerv4Scope
        $DHCP     = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID

        $DHCP     | ? Name -match "((\w{2}-){3}(\d{5})|OPNsense)" | Remove-DHCPServerV4Reservation -Verbose -EA 0

        $DHCP     = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID
        $Slot     = $DHCP[-1].IPAddress.ToString().Split(".")

        If ( $Main.Gw.Count -gt 1 )
        {
            $Spot    = [UInt32]$Slot[3]

            ForEach ( $X in 0..($Main.Gw.Count - 1))
            {
                $Reserve = Get-DhcpServerv4Reservation -ScopeID $ScopeID.ScopeID
                $Gw      = $Main.Gw[$X]
                $Item    = $Gw.Item
                $Mac     = Get-VMNetworkAdapter -VMName $Gw.Name | ? SwitchName -ne $Gw.Name | % MacAddress

                Write-Theme "Adding [~] DHCP Reservation [$($Item.Network)/$($Item.Prefix)]@[$($Item.Sitename)]" 10,2,15
                $Spot ++
                $Obj             = @{
        
                    ScopeID      = $ScopeID.ScopeID
                    IPAddress    = @($Slot[0,1,2];$Spot) -join '.'
                    ClientID     = $Mac
                    Name         = $Item.SiteLink
                    Description  = "[$($Item.Network)/$($Item.Prefix)]@[$($Item.Sitename)]"
                }
                Add-DhcpServerV4Reservation @Obj -Verbose
            }
        }

        Write-Theme "Added [+] DHCP Reservations"

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Gateway Template ]____________________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Writing [~] Gateway Objects"

        $Date       = Get-Date -UFormat %Y%m%d
        $Path       = "$Home\Desktop\VM($Date)\GW"
        $VMX        = $Main.Gw
        $Filter     = $Main | Select-Object CN, SearchBase, VM | ConvertTo-Json
        $Credential = $Main.Credential
        If (!(Test-Path $Path))
        {
            New-Item $Path -ItemType Directory -Verbose -Force
        }

        ForEach ( $X in 0..($Main.Sr.Count-1))
        {
            If (!(Test-Path "$Path\$X"))
            {
                New-Item "$Path\$X" -ItemType Directory -Verbose -Force
            }
            Set-Content -Path "$Path\$X\vmx.txt" -Value ( $VMX[$X] | ConvertTo-Json ) -Verbose -Force
            Set-Content -Path "$Path\$X\host.txt" -Value $Filter -Verbose -Force
            Export-CliXml -Path "$Path\$X\cred.txt" -InputObject $Credential -Verbose -Force
        }

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Server Template ]_____________________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Writing [~] Server Objects"

        $Date       = Get-Date -UFormat %Y%m%d
        $Path       = "$Home\Desktop\VM($Date)\SR"
        $VMX        = $Main.Sr
        $Filter     = $Main | Select-Object CN, SearchBase, VM | ConvertTo-Json
        $Credential = $Main.Credential
        If (!(Test-Path $Path))
        {
            New-Item $Path -ItemType Directory -Verbose -Force
        }

        ForEach ( $X in 0..($Main.Sr.Count-1))
        {
            If (!(Test-Path "$Path\$X"))
            {
                New-Item "$Path\$X" -ItemType Directory -Verbose -Force
            }
            Set-Content -Path "$Path\$X\vmx.txt" -Value ( $VMX[$X] | ConvertTo-Json ) -Verbose -Force
            Set-Content -Path "$Path\$X\host.txt" -Value $Filter -Verbose -Force
            Export-CliXml -Path "$Path\$X\cred.txt" -InputObject $Credential -Verbose -Force
        }

        #    ____                                                                                            ________    
        #   //¯¯\\__________________________________________________________________________________________//¯¯\\__//   
        #   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        #    ¯¯¯\\__[ Script Initialization  ]______________________________________________________________//¯¯¯        
        #        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

        Write-Theme "Creating [~] Script Initialization"
        Return [System.Windows.MessageBox]::Show("Virtual (Switch/Gateway/Server) item(s) have been created","Success")
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Imaging Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Imaging]://Variables
    # $Xaml.IO.IsoSelect                # Button
    # $Xaml.IO.IsoPath                  # Text
    # $Xaml.IO.IsoScan                  # Button
    # $Xaml.IO.IsoList                  # DataGrid
    # $Xaml.IO.IsoMount                 # Button
    # $Xaml.IO.IsoDismount              # Button
    # $Xaml.IO.IsoView                  # DataGrid
    # $Xaml.IO.WimQueue                 # Button
    # $Xaml.IO.WimDequeue               # Button
    # $Xaml.IO.WimIsoUp                 # Button
    # $Xaml.IO.WimIsoDown               # Button
    # $Xaml.IO.WimIso                   # DataGrid
    # $Xaml.IO.WimSelect                # Button
    # $Xaml.IO.WimPath                  # Text
    # $Xaml.IO.WimExtract               # Button

    # $Xaml                           = [XamlWindow][FEInfrastructureGUI]::Tab
    # [DataGrid]://Initialize
    $Xaml.IO.IsoList.ItemsSource        = @( )
    $Xaml.IO.IsoView.ItemsSource        = @( )
    $Xaml.IO.WimIso.ItemsSource         = @( )
    $Xaml.IO.WimIsoUp.IsEnabled         = 0
    $Xaml.IO.WimIsoDown.IsEnabled       = 0
    $Xaml.IO.IsoPath.IsEnabled          = 0

    # [Imaging]://Events
    $Xaml.IO.IsoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
                
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
            Return [System.Windows.MessageBox]::Show("Invalid image root path","Error")
        }

        ElseIf ((Get-ChildItem $Item.SelectedPath *.iso).Count -eq 0)
        {
            Return [System.Windows.MessageBox]::Show("No images detected","Error")
        }

        Else
        {
            $Xaml.IO.IsoPath.Text        = $Item.SelectedPath
            $Main.Image.LoadSilo($Xaml.IO.IsoPath.Text) 
            $Xaml.IO.IsoList.ItemsSource = @( )       
            $Xaml.IO.IsoList.ItemsSource = @($Main.Image.Store)
        }
    })
    
    $Xaml.IO.IsoList.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -gt -1 )
        {
            $Xaml.IO.IsoMount.IsEnabled = 1
        }
    
        Else
        {
            $Xaml.IO.IsoMount.IsEnabled = 0
        }
    })
    
    $Xaml.IO.IsoMount.Add_Click(
    {
        If ( $Xaml.IO.IsoList.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("No image selected","Error")
        }

        $Index = $Xaml.IO.IsoList.SelectedIndex
        $Name  = $Xaml.IO.IsoList.SelectedItem.Name
        If ($Name.Length -gt 65)
        {
            $Name = "$($Name.Substring(0,64))..."
        }

        Write-Theme "Mounting [~] $Name" 14,6,15
        $Xaml.IO.IsoMount.IsEnabled          = 0

        $Main.Image.LoadIso($Index)
        If ($Main.Image.Selected.Content -eq $Null)
        {
            Return [System.Windows.MessageBox]::Show("Not a windows image","Error")
            $Main.Image.UnloadIso()
            $Xaml.IO.IsoMount.IsEnabled      = 1
        }
        Else
        {
            $Xaml.IO.IsoView.ItemsSource     = $Main.Image.Store[$Index].Content
            $Xaml.IO.IsoList.IsEnabled       = 0

            $Xaml.IO.IsoDismount.IsEnabled   = 1
        }
    })
    
    $Xaml.IO.IsoDismount.Add_Click(
    {
        $Name  = $Xaml.IO.IsoList.SelectedItem.Name
        If ( $Name.Length -gt 65)
        {
            $Name = "$($Name.Substring(0,64))..."
        }
        Write-Theme "Dismounting [~] $Name" 12,4,15
        $Main.Image.UnloadIso()
        $Xaml.IO.IsoView.ItemsSource         = $Null
        $Xaml.IO.IsoList.IsEnabled           = 1
        $Xaml.IO.IsoMount.IsEnabled          = 1
        $Xaml.IO.IsoDismount.IsEnabled       = 0
    })
    
    $Xaml.IO.IsoView.Add_SelectionChanged(
    {
        If ( $Xaml.IO.IsoView.Items.Count -eq 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 0
        }
    
        If ( $Xaml.IO.IsoView.Items.Count -gt 0 )
        {
            $Xaml.IO.WimQueue.IsEnabled     = 1
        }
    })
    
    $Xaml.IO.WimIso.Add_SelectionChanged(
    {
        $Items = $Xaml.IO.WimIso.ItemsSource
        $Index = $Xaml.IO.WimIso.SelectedIndex
        If ($Items.Count -eq 0)
        {
            $Xaml.IO.WimDequeue.IsEnabled     = 0
            $Xaml.IO.WimIsoUp.IsEnabled       = 0
            $Xaml.IO.WimIsoDown.IsEnabled     = 0
        }
    
        Else
        {
            $Xaml.IO.WimDequeue.IsEnabled     = 1
            $Xaml.IO.WimIsoUp.IsEnabled       = $Index -ne 0
            $Xaml.IO.WimIsoDown.IsEnabled     = $Index -ne ($Items.Count-1)
        }
    })
    
    $Xaml.IO.WimQueue.Add_Click(
    {
        $Index = @( $Xaml.IO.IsoView.SelectedItems.Index )
        $Main.Image.AddQueue($Index)
        $Xaml.IO.WimIso.ItemsSource = @( )
        $Xaml.IO.WimIso.ItemsSource = @($Main.Image.Queue)
    })
    
    $Xaml.IO.WimDequeue.Add_Click(
    {
        $Main.Image.DeleteQueue($Xaml.IO.WimIso.SelectedItem.Name)
        $Xaml.IO.WimIso.ItemsSource = @( )
        $Xaml.IO.WimIso.ItemsSource = @($Main.Image.Queue)
    
        If ( $Xaml.IO.WimIso.Items.Count -eq 0 )
        {
            $Xaml.IO.WimDequeue.IsEnabled = 0
        }
    })
    
    $Xaml.IO.WimIsoUp.Add_Click(
    {
        If ($Main.Image.Queue.Count -gt 1)
        {
            $Index                        = $Xaml.IO.WimIso.SelectedIndex
            $Swap                         = $Main.Image.Queue[$Index-1]
            $Main.Image.Queue[$Index-1]   = $Main.Image.Queue[$Index]
            $Main.Image.Queue[$Index]     = $Swap
            $Xaml.IO.WimIso.ItemsSource   = @( )
            $Xaml.IO.WimIso.ItemsSource   = @($Main.Image.Queue)
        }
    })
    
    $Xaml.IO.WimIsoDown.Add_Click(
    {
        If ($Main.Image.Queue.Count -gt 1)
        {
            $Index                        = $Xaml.IO.WimIso.SelectedIndex
            $Swap                         = $Main.Image.Queue[$Index+1]
            $Main.Image.Queue[$Index+1]   = $Main.Image.Queue[$Index]
            $Main.Image.Queue[$Index]     = $Swap
            $Xaml.IO.WimIso.ItemsSource   = @( )
            $Xaml.IO.WimIso.ItemsSource   = @($Main.Image.Queue)
        }
    })
    
    $Xaml.IO.WimExtract.Add_Click(
    {
        $Target = $Xaml.IO.WimPath.Text
        If (Test-Path $Target)
        {
            $Children = Get-ChildItem $Target *.wim -Recurse | % FullName

            If ($Children.Count -gt 0)
            {
                Switch([System.Windows.MessageBox]::Show("Wim files detected at provided path.","Purge and rebuild?","YesNo"))
                {
                    Yes
                    {
                        ForEach ( $Child in $Children )
                        {
                            Get-ChildItem $Target | Remove-Item -Recurse -Confirm:$False -Force -Verbose
                        }
                    }

                    No
                    {
                        Break
                    }
                }
            }
        }

        If (!(Test-Path $Target))
        {
            New-Item -Path $Target -ItemType Directory -Verbose
        }
    
        $Main.Image.Target = $Target
    
        $X = 0
        ForEach ( $File in $Main.Image.Queue )
        {
            $Disk = Get-DiskImage -ImagePath $File.Name
            $Name = $File.Name | Split-Path -Leaf
            If ($Name.Length -gt 65)
            {
                $Name = "$($Name.Substring(0,64))..."
            }
            If (!$Disk.Attached)
            {
                Write-Theme "Mounting [~] $Name"
                Mount-DiskImage -ImagePath $Disk.ImagePath -Verbose
                $Disk = Get-DiskImage -ImagePath $File.Name
            }

            $Path  = "{0}:\sources\install.wim" -f ($Disk | Get-Volume | % DriveLetter)

            ForEach ($Item in $File.Content)
            {
                Switch -Regex ($Item.Name)
                {
                    Server
                    {
                        $Year               = [Regex]::Matches($Item.Name,"(\d{4})").Value
                        $ID                 = $Item.Name -Replace "Windows Server \d{4} ",''
                        ForEach ($Item in $Wim)
                        {
                            $ID            = $Item.ImageName -Replace "Windows Server \d{4} SERVER",''
                            $Edition, $Tag = Switch -Regex ($ID) 
                            {
                                "^STANDARDCORE$"   { "Standard Core",  "SDX" }
                                "^STANDARD$"       { "Standard",        "SD" }
                                "^DATACENTERCORE$" { "Datacenter Core","DCX" }
                                "^DATACENTER$"     { "Datacenter",      "DC" }
                            }
                        }
                        $DestinationName    = "Windows Server $Year $Edition (x64)"
                        $Label              = "{0}{1}" -f $Tag, $Year
                    }

                    Default
                    {
                        $ID                 = $Item.Name -Replace "Windows 10 "
                        $Tag                = Switch -Regex ($Item.Name)
                        {
                            "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                            "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                            "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                            "^Pro N$"            { "PRO_N"      } "^Pro Education [^N]" { "PRO_EDUC" }
                            "^Pro Edu.+N$"       { "PRO_EDUC_N" } "^Pro [^N].+Work.+$"  { "PRO_WS"   }
                            "^Pro N .+Work.+$"   { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                        }
                        $DestinationName    = "{0} (x{1})" -f $Item.Name, $Item.Architecture
                        $Label              = "10{0}{1}" -f $Tag, $Item.Architecture
                    }
                }

                $ISO                        = @{

                    SourceIndex             = $Item.Index
                    SourceImagePath         = $Path
                    DestinationImagePath    = ("{0}\({1}){2}\{2}.wim" -f $Main.Image.Target,$X,$Label)
                    DestinationName         = $DestinationName
                }

                New-Item ($Iso.DestinationImagePath | Split-Path -Parent) -ItemType Directory -Verbose

                Write-Theme "Extracting [~] $DestinationName" 14,6,15
                Start-Sleep 1

                Export-WindowsImage @ISO
                Write-Theme "Extracted [~] $DestinationName" 10,2,15
                Start-Sleep 1

                $X ++
            }
            Write-Theme "Dismounting [~] $Name" 12,4,15
            Start-Sleep 1

            Get-DiskImage -ImagePath $File.Name | Dismount-DiskImage
        }
        Write-Theme "Complete [+] ($($Main.Image.Queue.Content.Count)) *.wim files Extracted" 10,2,15
    })
    
    $Xaml.IO.WimSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.WimPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.WimPath.Add_TextChanged(
    {
        If ( $Xaml.IO.WimPath.Text -ne "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 1
        }
    
        If ( $Xaml.IO.WimPath.Text -eq "" )
        {
            $Xaml.IO.WimExtract.IsEnabled = 0
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Updates Tab    ]______________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

    # [Updates]://Variables
    # $Xaml.IO.UpdSelect                 # Button
    # $Xaml.IO.UpdPath                   # TextBox
    # $Xaml.IO.UpdAggregate              # DataGrid
    # $Xaml.IO.UpdAddUpdate              # Button
    # $Xaml.IO.UpdRemoveUpdate           # Button
    # $Xaml.IO.UpdViewer                 # DataGrid
    # $Xaml.IO.UpdWim                    # DataGrid
    # $Xaml.IO.UpdInstallUpdate          # Button
    # $Xaml.IO.UpdUninstallUpdate        # Button

    # [DataGrid(s)]://Initialize
    $Xaml.IO.UpdAggregate.ItemsSource   = @( )
    $Xaml.IO.UpdViewer.ItemsSource      = @( )
    $Xaml.IO.UpdWim.ItemsSource         = @( )

    # [Updates]://Events
    $Xaml.IO.UpdSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        ElseIf ((Get-ChildItem $Item.SelectedPath -Recurse *.msu).Count -eq 0)
        {
            Return [System.Windows.MessageBox]::Show("No .msu files were detected in the provided path","Error")
        }

        Else
        {
            $Xaml.IO.UpdPath.Text = $Item.SelectedPath
            $Main.Update
            $Xaml.IO.UpdAggregate = @( )
        }
    })

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Share Tab  ]__________________________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
    
    # [Share]://Variables
    # $Xaml.IO.DsAggregate              # DataGrid

    # $Xaml.IO.DsRootSelect             # Button
    # $Xaml.IO.DsRootPath               # Text
    # $Xaml.IO.DsShareName              # Text
    # $Xaml.IO.DsDriveName              # Text
    # $Xaml.IO.DsDescription            # Text
    # $Xaml.IO.DsType                   # ComboBox
    # $Xaml.IO.DsDcUsername             # Text
    # $Xaml.IO.DsDcPassword             # Password
    # $Xaml.IO.DsDcConfirm              # Password
    # $Xaml.IO.DsLmUsername             # Text
    # $Xaml.IO.DsLmPassword             # Password
    # $Xaml.IO.DsLmConfirm              # Password
    # $Xaml.IO.DsBrCollect              # Button
    # $Xaml.IO.DsBrPhone                # Text
    # $Xaml.IO.DsBrHours                # Text
    # $Xaml.IO.DsBrWebsite              # Text
    # $Xaml.IO.DsBrLogoSelect           # Button
    # $Xaml.IO.DsBrLogo                 # Text
    # $Xaml.IO.DsBrBackgroundSelect     # Button
    # $Xaml.IO.DsBrBackground           # Text
    # $Xaml.IO.DsNetBiosName            # Text
    # $Xaml.IO.DsDnsName                # Text
    # $Xaml.IO.DsMachineOuName          # Text
    # $Xaml.IO.DsSelectBootstrap         # Button
    # $Xaml.IO.DsGetBootstrap            # Button
    # $Xaml.IO.DsBootstrap               # TextBlock
    # $Xaml.IO.DsSelectCustomSettings    # Button
    # $Xaml.IO.DsGetCustomSettings       # Button
    # $Xaml.IO.DsCustomSettings          # TextBlock
    # $Xaml.IO.DsCreate                  # Button
    # $Xaml.IO.DsUpdate                  # Button

    # [Share]://Events
    $Xaml.IO.DsAggregate.Add_SelectionChanged(
    {
        $Item = $Xaml.IO.DsAggregate.SelectedItem
        If ( $Item.Name -match "(\<New\>)" )
        {
            $Xaml.IO.DsDriveName.Text          = ("FE{0:d3}" -f $Xaml.IO.DsAggregate.Items.Count)
            $Xaml.IO.DsRootPath.Text           = ""
            $Xaml.IO.DsShareName.Text          = ""
            $Xaml.IO.DsDescription.Text        = ("[FightingEntropy({0})][(2021.8.0)]" -f [char]960)
            $Xaml.IO.DsType.SelectedIndex      = 0
            $Xaml.IO.DsBootstrapPath.Text      = ""
            $Xaml.IO.DsCustomSettingsPath.Text = ""
            $Xaml.IO.DsPostConfigPath.Text     = ""
        }

        Else
        {
            $Xaml.IO.DsDriveName.Text          = $Item.Name
            $Xaml.IO.DsRootPath.Text           = $Item.Root
            $Xaml.IO.DsShareName.Text          = $Item.Share
            $Xaml.IO.DsDescription.Text        = $Item.Description
            $Xaml.IO.DsType.SelectedIndex      = @{MDT=0;PSD=1;"-"=2}[$Item.Type]
            $Xaml.IO.DsBootstrapPath.Text      = "$($Item.Root)\Control\Bootstrap.ini"
            $Xaml.IO.DsCustomSettingsPath.Text = "$($Item.Root)\Control\CustomSettings.ini"
            $Xaml.IO.DsPostConfigPath.Text     = "$($Item.Root)\Script\Install-FightingEntropy.ps1"
        }

        If ($Item.Root -in $Main.MDT.Shares.Path)
        {
            $Xaml.IO.DsCreate.IsEnabled = 0
            $Xaml.IO.DsUpdate.IsEnabled = 1
        }
        If ($Item.Root -notin $Main.MDT.Shares.Path)
        {
            $Xaml.IO.DsCreate.IsEnabled = 1
            $Xaml.IO.DsUpdate.IsEnabled = 0
        }
    })

    $Xaml.IO.DsAddShare.Add_Click(
    {
        If ($Xaml.IO.DsDriveName.Text -notmatch "(\w|\d)+")
        {
            Return [System.Windows.MessageBox]::Show("Drive label can only contain alphanumeric characters","Error")
        }

        ElseIf ($Xaml.IO.DsRootPath.Text -in $Xaml.IO.DsAggregate.Items.Root )
        {
            Return [System.Windows.MessageBox]::Show("Selected path is already assigned to another deployment share","Error")
        }

        ElseIf ($Xaml.IO.DsRootPath | ? Text -in @("",$Null) )
        {
            Return [System.Windows.MessageBox]::Show("Selected path is invalid","Error")
        }

        ElseIf ($Xaml.IO.DsShareName.Text -in $Xaml.IO.DsAggregate.Items.Share)
        {
            Return [System.Windows.MessageBox]::Show("Selected share name is already assigned to another deployment share","Error")
        }

        ElseIf($Xaml.IO.DsType.SelectedIndex -eq 2)
        {
            Return [System.Windows.MessageBox]::Show("Must select MDT or PSD for deployment share type","Error")
        }

        Else
        {
            $Xaml.IO.DsAggregate.ItemsSource  += [DsShare]::New($Xaml.IO.DsDriveName.Text,
            $Xaml.IO.DsRootPath.Text,
            $Xaml.IO.DsShareName.Text,
            $Xaml.IO.DsDescription.Text,
            $Xaml.IO.DsType.SelectedIndex)
            $Xaml.IO.DsAggregate.SelectedIndex = ($Xaml.IO.DsAggregate.Items.Count - 1)
        }
    })

    $Xaml.IO.DsRemoveShare.Add_Click(
    {
        If ($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("No share to remove...","Error")
        }

        ElseIf ($Xaml.IO.DsAggregate.SelectedItem.Name -eq "<New>")
        {
            Return [System.Windows.MessageBox]::Show("No deployment share selected","Error")
        }
        
        Else
        {
            $Items = @( $Xaml.IO.DsAggregate.ItemsSource | ? Name -ne $Xaml.IO.DsAggregate.SelectedItem.Name )
            $Xaml.IO.DsAggregate.ItemsSource = @( )
            $Xaml.IO.DsAggregate.ItemsSource = @( $Items )
        }
    })

    $Xaml.IO.DsBrCollect.Add_Click(
    {
        $OEM = Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation' -EA 0

        If ($OEM)
        {
            If ($OEM.Logo)
            {
                $Xaml.IO.DsBrLogo.Text = $Oem.Logo
            }

            If ($OEM.SupportPhone)
            {
                $Xaml.IO.DsBrPhone.Text = $Oem.SupportPhone
            }

            If ($OEM.SupportHours)
            {
                $Xaml.IO.DsBrHours.Text = $Oem.SupportHours
            }

            If ($OEM.SupportURL)
            {
                $Xaml.IO.DsBrWebsite.Text = $Oem.SupportURL
            }
        }

        $OEM = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -EA 0
        
        If ($OEM)
        {
            If ($OEM.Wallpaper)
            {
                $Xaml.IO.DsBrBackground.Text = $OEM.Wallpaper
            }
        }
    })

    $Xaml.IO.DsBrLogoSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Logo
        }

        $Xaml.IO.DsBrLogo.Text = $Item.FileName
    })
    
    $Xaml.IO.DsBrBackgroundSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = [Main]::Base
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = [Main]::Background
        }

        $Xaml.IO.DsBrBackground.Text = $Item.FileName
    })

    $Xaml.IO.DsRootSelect.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath  = ""
        }

        $Xaml.IO.DSRootPath.Text = $Item.SelectedPath
    })

    $Xaml.IO.DsRootPath.Add_TextChanged(
    {
        If ( $Xaml.IO.DSRootPath.Text -ne "" )
        {
            $Xaml.IO.DSShareName.Text = ("{0}$" -f $Xaml.IO.DSRootPath.Text.Split("(\/|\.)")[-1] )
        }
    })

    $Xaml.IO.DsGenerateBootstrap.Add_Click(
    {
        If ($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a share from the datagrid","Error")
        }
        ElseIf ($Xaml.IO.DsNwNetBiosName.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter the NetBIOS ID","Error")
        }
        ElseIf ($Xaml.IO.DsDcUsername.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin username","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin password","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -notmatch $Xaml.IO.DsDcConfirm.Password)
        {
            Return [System.Windows.Messagebox]::Show("Invalid password confirmation","Error")
        }
        Else
        {
            $Item                          = $Xaml.IO.DsAggregate.SelectedItem
            $Xaml.IO.DsBootstrap.Text      = @( ) 
            ForEach ( $Line in $Main.Bootstrap($Item.Type,$Xaml.IO.DsNwNetBiosName.Text,"\\$($Xaml.IO.NwDnsName)\$($Item.Share)",$Xaml.IO.DsDcUsername.Text,$Xaml.IO.DsDcPassword.Password))
            {
                $Xaml.IO.DsBootstrap.Text += $Line
            }
        }
    })

    $Xaml.IO.DsGenerateCustomSettings.Add_Click(
    {
        If ($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a share from the datagrid","Error")
        }
        ElseIf ($Xaml.IO.DcOrganization.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Invalid organization name","Error")
        }
        ElseIf($Xaml.IO.DsNwNetBiosName.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Invalid NetBIOS name","Error")
        }
        ElseIf($Xaml.IO.DsNwDnsName.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Invalid DNS name","Error")
        }
        ElseIf($Xaml.IO.DsNwMachineOUName.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Invalid computer OU designated","Error")
        }
        ElseIf ($Xaml.IO.DsDcUsername.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin username","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter domain admin password","Error")
        }
        ElseIf ($Xaml.IO.DsDcPassword.Password -notmatch $Xaml.IO.DsDcConfirm.Password)
        {
            Return [System.Windows.Messagebox]::Show("Invalid password confirmation","Error")
        }
        Else
        {
            $Item                               = $Xaml.IO.DsAggregate.SelectedItem
            $Xaml.IO.DsCustomSettings.Text      = @() 
            ForEach ($Line in $Main.CustomSettings($Item.Type,$Item.Share,$Xaml.IO.DcOrganization.Text,$Xaml.IO.DsNwNetBiosName.Text,
                                                $Xaml.IO.DsNwDnsName.Text,$Xaml.IO.DsNwMachineOUName.Text,$Xaml.IO.DsDcUsername.Text,$Xaml.IO.DsDcPassword.Password))
            {
                $Xaml.IO.DsCustomSettings.Text += $Line
            }
        }
    })

    $Xaml.IO.DsGeneratePostConfig.Add_Click(
    {
        If ($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a share from the datagrid","Error")
        }
        Else
        {
            $Item                           = $Xaml.IO.DsAggregate.SelectedItem
            $Xaml.IO.DsPostConfig.Text      = @( )
            ForEach ( $Line in $Main.PostConfig("\\$Env:ComputerName\$($Item.Share)\DSKey.csv") )
            {
                $Xaml.IO.DsPostConfig.Text += $Line
            }
        }
    })

    # [Select Scripts]
    $Xaml.IO.DsSelectBootstrap.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsBootstrapPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsBootstrapPath.Text      = $Item.FileName
            $Xaml.IO.DsBootstrap.Text          = Get-Content $Item.Filename
        }
    })
    
    $Xaml.IO.DsSelectCustomSettings.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsCustomSettingsPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsCustomSettingsPath.Text = $Item.FileName
            $Xaml.IO.DsCustomSettings.Text     = Get-Content $Item.Filename
        }
    })

    $Xaml.IO.DsSelectPostConfig.Add_Click(
    {
        $Item                                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory                 = "$($Xaml.IO.DsAggregate.SelectedItem.Root)\Control"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                     = $Xaml.IO.DsPostConfigPath.Text
        }

        If (Test-Path $Item.FileName)
        {
            $Xaml.IO.DsPostConfigPath.Text     = $Item.FileName
            $Xaml.IO.DsPostConfig.Text         = Get-Content $Item.Filename
        }
    })

    $Xaml.IO.DsCreate.Add_Click(
    {
        If ($Xaml.IO.CfgServices.Items | ? Name -eq MDT | ? Value -ne $True)
        {
            Throw "Unable to initialize, MDT not installed"
        }

        ElseIf ($PSVersionTable.PSEdition -ne "Desktop")
        {
            Throw "Unable to initialize, use Windows PowerShell v5.1"
        }

        ElseIf ($Xaml.IO.DsAggregate.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a valid drive in the aggregate category box","Error")
        }

        ElseIf($Xaml.IO.DsAggregate.SelectedItem.Name -eq "<New>")
        {
            Return [System.Windows.MessageBox]::Show("Cannot use the <New> for the share, select another option","Error")
        }

        ElseIf ($Xaml.IO.DcOrganization.Text.Length -eq 0)
        {
            Return [System.Windows.MessageBox]::Show("Missing the organization name","Error")
        }

        ElseIf ($Xaml.IO.DcCommonName.Text.Length -eq 0)
        {
            Return [Systme.Windows.MessageBox]::Show("Missing the domain name/common name","Error")
        }

        ElseIf (!$Xaml.IO.DsDcUsername.Text)
        {
            Return [System.Windows.MessageBox]::Show("Missing the deployment share domain account name","Error")
        }

        ElseIf ($Xaml.IO.DsDcPassword.SecurePassword -notmatch $Xaml.IO.DsDcConfirm.SecurePassword)
        {
            Return [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        } 

        ElseIf (!$Xaml.IO.DsLmUsername.Text)
        {
            Return [System.Windows.MessageBox]::Show("Missing the child item local account name","Error")
        }

        ElseIf ($Xaml.IO.DsLmPassword.SecurePassword -notmatch $Xaml.IO.DsLmConfirm.SecurePassword)
        {
            Return [System.Windows.MessageBox]::Show("Invalid domain account password/confirm","Error")
        }

        ElseIf (!(Get-ADOrganizationalUnit -Filter * | ? DistinguishedName -match $Xaml.IO.DsNwMachineOuName.Text))
        {
            Return [System.Windows.MessageBox]::Show("Invalid OU specified","Error")
        }

        ElseIf ($Xaml.IO.DsBootstrap.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("The bootstrap file was not generated or reviewed","Error")
        }

        ElseIf ($Xaml.IO.DsCustomSettings.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("The bootstrap file was not generated or reviewed","Error")
        }

        ElseIf ($Xaml.IO.DsPostConfig.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("The post config file was not generated or reviewed","Error")
        }

        Else
        {
            Write-Theme "Creating [~] Deployment Share"

            $Item = $Xaml.IO.DsAggregate.SelectedItem

            If (!(Test-Path $Item.Root))
            {
                New-Item $Item.Root -ItemType Directory -Verbose
            }

            $Hostname       = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()

            $SMB            = @{

                Name        = $Xaml.IO.DsShareName.Text
                Path        = $Xaml.IO.DsRootPath.Text
                Description = $Xaml.IO.DsDescription.Text
                FullAccess  = "Administrators"
            }

            $PSD            = @{ 

                Name        = $Xaml.IO.DsDriveName.Text
                PSProvider  = "MDTProvider"
                Root        = $Xaml.IO.DsRootPath.Text
                Description = $Xaml.IO.DsDescription.Text
                NetworkPath = ("\\{0}\{1}" -f $Hostname, $Xaml.IO.DsShareName.Text)
            }

            $MDT            = Get-ItemProperty HKLM:\Software\Microsoft\Deployment* | % Install_Dir | % TrimEnd \

            New-SMBShare @SMB
            New-PSDrive  @PSD -Verbose | Add-MDTPersistentDrive -Verbose

            If ($Item.Type -eq "PSD")
            {
                $ScriptRoot         = Get-PSDModule
                $ItemName           = "$($Item.Name):"
                $ItemRoot           = $Item.Root
                $ItemShare          = $Item.Share

                # Create backup folder      
                Write-Host "Creating [~] backup folder"
                $Backup             = "$ItemRoot\Backup\Scripts"
                
                New-Item $Backup -ItemType Directory -Force -Verbose

                # Remove specific files
                Write-Host "Moving [~] unneeded files to backup location"
                ForEach ( $ItemX in "UDIWizard_Config.xml.app Wizard.hta Wizard.ico Wizard.css Autorun.inf BDD_Welcome_ENU.xml Credentials_ENU.xml Summary_Definition_ENU.xml DeployWiz_Roles.xsl" -Split " ")
                {   
                    $Path           = "$ItemRoot\Scripts\$ItemX"

                    If (Test-Path $Path)
                    {
                        Write-Host "Moving [~] $Path"
                        Move-Item -Path $Path -Destination "$Backup\$ItemX" -Verbose
                    }
                }

                # Cleanup old stuff from DeploymentShare
                ForEach ($ItemX in Get-ChildItem "$ItemRoot\Scripts" | ? Name -match "(vbs|wsf|DeployWiz|UDI|WelcomeWiz_)")
                {
                    Write-Host "Moving [~] $($ItemX.FullName)"
                    Move-Item -Path $ItemX.FullName -Destination "$Backup\$($ItemX.Name)" -Verbose
                }

                # Copy/Unblock PS1 Files
                Get-ChildItem "$ScriptRoot\Scripts" | ? Extension -match "(ps1|xaml)" | Copy-Item -Destination "$ItemRoot\Scripts" -Verbose

                # Copy/Unblock templates
                Get-ChildItem "$ScriptRoot\Templates" | Copy-Item -Destination "$ItemRoot\Templates" -Verbose

                # Copy/Unblock the modules
                Write-Host "Copying [~] PSD Modules to $ItemRoot......."
                ForEach ($File in "PSDGather PSDDeploymentShare PSDUtility PSDWizard" -Split " ")
                {
                    If (!(Test-Path "$ItemRoot\Tools\Modules\$File"))
                    {
                        New-Item "$ItemRoot\Tools\Modules\$File" -ItemType Directory -Verbose
                    }

                    Write-Host "Copying [~] Module:[$File] to $ItemRoot\Tools\Modules"
                    Copy-Item "$ScriptRoot\Scripts\$File.psm1" -Destination "$ItemRoot\Tools\Modules\$File" -Verbose
                }

                # Copy the PSProvider module files
                Write-Host "Copying [~] MDT provider files to $ItemRoot\Tools\Modules"
                If (!(Test-Path "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn"))
                {
                    New-Item "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn" -ItemType Directory -Verbose
                }

                ForEach ( $ItemX in "PSSnapIn" | % { "$_.dll $_.dll.config $_.dll-help.xml $_.Format.ps1xml $_.Types.ps1xml Core.dll Core.dll.config ConfigManager.dll" -Split " " } ) 
                {
                    Copy-Item "$Mdt\Bin\Microsoft.BDD.$ItemX" -Destination "$ItemRoot\Tools\Modules\Microsoft.BDD.PSSnapIn" -Verbose
                }

                # Copy the provider template files
                Write-Host "Copying [~] PSD templates to $ItemRoot\Templates"
                If (!(Test-Path "$ItemRoot\Templates"))
                {
                    New-Item "$ItemRoot\Templates" -ItemType Directory -Verbose
                }

                ForEach ($ItemX in "Groups Medias OperatingSystems Packages SelectionProfiles TaskSequences Applications Drivers Groups LinkedDeploymentShares" -Split " ")
                {
                    Copy-Item "$MDT\Templates\$ItemX.xsd" "$ItemRoot\Templates" -Verbose
                }

                # Restore ZTIGather.XML
                Write-Host "Adding [~] ZTIGather.XML to correct folder"
                Copy-Item "$MDT\Templates\Distribution\Scripts\ZTIGather.xml" -Destination "$ItemRoot\Tools\Modules\PSDGather" -Verbose

                # Create folders
                Foreach ($ItemX in "Autopilot BootImageFiles\X86 BootImageFiles\X64 Branding Certificates CustomScripts DriverPackages DriverSources UserExitScripts BGInfo Prestart" -Split " ")
                {
                    Write-Host "Creating [~] [$ItemX] folder in $ItemShare\PSDResources"
                    New-Item "$ItemRoot\PSDResources\$ItemX" -ItemType Directory -Force -Verbose
                }

                # Copy PSDBackground to Branding folder
                Copy-Item -Path $ScriptRoot\Branding\PSDBackground.bmp -Destination $ItemRoot\PSDResources\Branding\PSDBackground.bmp -Force -Verbose

                # Copy PSDBGI to BGInfo folder
                Copy-Item -Path $ScriptRoot\Branding\PSD.bgi -Destination $ItemRoot\PSDResources\BGInfo\PSD.bgi -Force -Verbose

                # Copy BGInfo64.exe to BGInfo.exe
                Copy-Item -Path $ItemRoot\Tools\x64\BGInfo64.exe -Destination $ItemRoot\Tools\x64\BGInfo.exe -Verbose

                # Copy Prestart items
                Get-ChildItem $ScriptRoot\PSDResources\Prestart | Copy-Item -Destination $ItemRoot\PSDResources\Prestart -Verbose

                # Update the DeploymentShare properties
                If (!$Upgrade)
                {
                    Write-Host "Update [~] PSD Deployment Share properties"
                    86,64 | % { 

                        Set-ItemProperty $ItemName -Name "Boot.x$_.LiteTouchISOName" -Value "PSDLiteTouch_x$_.iso"
                        Set-ItemProperty $ItemName -Name "Boot.x$_.LiteTouchWIMDescription" -Value "PowerShell Deployment Boot Image (x$_)"
                        Set-ItemProperty $ItemName -Name "Boot.x$_.BackgroundFile" -Value "%DEPLOYROOT%\PSDResources\Branding\PSDBackground.bmp"
                    }

                    # Disable support for x86
                    Write-Host "Disable [~] Support for x86"
                    Set-ItemProperty $ItemName -Name "SupportX86" -Value "False"
                }

                # Relax Permissions on Deploymentfolder and DeploymentShare
                Write-Host "Relaxing [~] Permissons on $ItemShare"
                ForEach ($ItemX in "Users Administrators SYSTEM" -Split " ")
                {
                    icacls $ItemRoot /grant "`"$ItemX`":(OI)(CI)(RX)"
                }
                    
                Grant-SmbShareAccess -Name $ItemShare -AccountName "EVERYONE" -AccessRight Change -Force
                Revoke-SmbShareAccess -Name $ItemShare -AccountName "CREATOR OWNER" -Force

                Get-ChildItem $ItemRoot -Recurse | Unblock-File -Verbose
            }

            # Load Module / Share Drive Mount
            $Module                = Get-FEModule
            $Root                  = "$($PSD.Name):\"
            $Control               = "$($PSD.Root)\Control"
            $Script                = "$($PSD.Root)\Scripts"
            
            # Copies the background and logo if they were selected and are found
            ForEach ($File in $Xaml.IO.DsBrBackground.Text,$Xaml.IO.DsBrLogo.Text)
            {
                If (Test-Path $File)
                {
                    Copy-Item -Path $File -Destination $Script -Verbose

                    If ($File -eq $Key.Background)
                    {
                        $Key.Background = "$($PSD.NetworkPath)\Scripts\$($File | Split-Path -Leaf)"
                    }

                    If ($File -eq $Key.Logo)
                    {
                        $Key.Logo       = "$($PSD.NetworkPath)\Scripts\$($File | Split-Path -Leaf)"
                    }
                }
            }

            # For the PXE environment images
            ForEach ( $File in $Module.Control | ? Extension -eq .png )
            {
                Copy-Item -Path $File.Fullname -Destination $Script -Force -Verbose
            }

            # Copies custom template for FightingEntropy to post install/configure
            ForEach ( $File in $Module.Control | ? Name -match Mod.xml )
            {
                Copy-Item -Path $File.FullName -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates" -Force -Verbose
            }
            
            # [Collect Wim files/Images]
            Write-Theme "Collecting [~] images"
            $Images      = @( )
            
            # [Extract/order the WIM files and prime for MDT Injection]
            Get-ChildItem -Path $Xaml.IO.WimPath.Text -Recurse *.wim | % { 
                
                Write-Host "Processing [$($_.FullName)]"
                $Images += [WimFile]::New($Images.Count,$_.FullName) 
            }

            # [Import OS/TS to MDT Share]
            $OS          = "$($PSD.Name):\Operating Systems"
            $TS          = "$($PSD.Name):\Task Sequences"
            $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)][$($Item.Type)]"

            # [Create folders in the new MDT share]
            ForEach ( $Type in "Server","Client" )
            {
                ForEach ( $Version in $Images | ? InstallationType -eq $Type | % Version | Select-Object -Unique )
                {
                    ForEach ( $Slot in $OS, $TS )
                    {
                        If (!(Test-Path "$Slot\$Type"))
                        {
                            New-Item -Path $Slot -Enable True -Name $Type -Comments $Comment -ItemType Folder -Verbose
                        }

                        If (!(Test-Path "$Slot\$Type\$Version"))
                        {
                            New-Item -Path "$Slot\$Type" -Enable True -Name $Version -Comments $comment -ItemType Folder -Verbose
                        }
                    }
                }
            }

            # [Inject the Wim files into the MDT share]
            ForEach ( $Image in $Images )
            {
                $Type                   = $Image.InstallationType
                $Path                   = "$OS\$Type\$($Image.Version)"

                $OperatingSystem        = @{

                    Path                = $Path
                    SourceFile          = $Image.SourceImagePath
                    DestinationFolder   = $Image.Label
                }
                
                Import-MDTOperatingSystem @OperatingSystem -Move -Verbose

                $TaskSequence           = @{ 
                    
                    Path                = "$TS\$Type\$($Image.Version)"
                    Name                = ( "{0} (x{1})" -f $Image.ImageName, $Image.Architecture)
                    Template            = "{0}{1}Mod.xml" -f $Item.Type, $Type
                    Comments            = $Comment
                    ID                  = $Image.Label
                    Version             = "1.0"
                    OperatingSystemPath = Get-ChildItem -Path $Path | ? Name -match $Image.Label | % { "{0}\{1}" -f $Path, $_.Name }
                    FullName            = $Xaml.IO.DcLmUsername.Text
                    OrgName             = $Xaml.IO.DcOrganization.Text
                    HomePage            = $Xaml.IO.DcBrWebsite.Text
                    AdminPassword       = $Xaml.IO.DcLmPassword.Password
                }

                Import-MDTTaskSequence @TaskSequence -Verbose
            }

            # [Clean up the Wim file directory]
            Write-Theme "OS/TS [+] Imported, removing Wim Swap directory" 11,3,15,0
            Remove-Item -Path $Xaml.IO.WimPath.Text -Recurse -Force -Verbose


            Write-Theme "Setting [~] Share properties [($Root)]"
            # Share Settings
            Set-ItemProperty $Root -Name Comments    -Value $("[FightingEntropy({0})]{1}[{2}]" -f [Char]960,(Get-Date -UFormat "[%Y-%m%d (MCC/SDP)]"),$Item.Type ) -Verbose
            Set-ItemProperty $Root -Name MonitorHost -Value $HostName -Verbose

            # Image Names/Background
            ForEach ($x in 64,86)
            {
                $Names  = $X | % { "Boot.x$_" } | % { "$_.Generate{0}ISO $_.{0}WIMDescription $_.{0}ISOName $_.BackgroundFile" -f "LiteTouch" -Split " " }
                $Values = $X | % { "$($Module.Name)[$($Module.Version)][$($Item.Type)](x$_)" } | % { "True;$_;$_.iso;$($Xaml.IO.DsBrBackground.Text)" -Split ";" }
                0..3         | % { Set-ItemProperty -Path $Root -Name $Names[$_] -Value $Values[$_] -Verbose } 
            }

            $Encoding = New-Object System.Text.UTF8Encoding $False

            # [Bootstrap.ini]
            [System.IO.File]::WriteAllLines("$Control\Bootstrap.ini",$Xaml.IO.DsBootstrap.Text,$Encoding)

            # [CustomSettings.ini]
            [System.IO.File]::WriteAllLines("$Control\CustomSettings.ini",$Xaml.IO.DsBootstrap.Text,$Encoding)

            # [FightingEntropy Installation propogation]
            [System.IO.File]::WriteAllLines("$Script\Install-FightingEntropy.ps1",$Xaml.IO.DsPostConfig.Text,$Encoding)

            # [Propogate the variables as an environment keys for [server/client] child items to restore]
            $DS  = @($PSD.NetworkPath,$Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text,$Xaml.IO.DsBrBackground.Text,
                    $Xaml.IO.DsBrLogo.Text,$Xaml.IO.DsBrPhone.Text,$Xaml.IO.DsBrHours.Text,$Xaml.IO.DsBrWebsite.Text)
            $Key = [Key]$DS
        
            Set-Content -Path "$($PSD.Root)\DSKey.csv" -Value ($Key | ConvertTo-CSV) -Verbose

            # Update FEShare(MDT)
            Update-MDTDeploymentShare -Path $Root -Force -Verbose

            # Update/Flush FEShare(Images)
            $ImageLabel = Get-ItemProperty -Path $Root | % { 

                @{  64 = $_.'Boot.x64.LiteTouchWIMDescription'
                    86 = $_.'Boot.x86.LiteTouchWIMDescription' }
            }

            # Rename the Litetouch_ files
            Get-ChildItem -Path "$($Xaml.IO.DsRootPath.Text)\Boot" | ? Extension | % { 

                $Label          = $ImageLabel[$(Switch -Regex ($_.Name) { 64 {64} 86 {86}})]
                $Image          = @{ 

                    Path        = $_.FullName
                    Name        = $_.Name
                    NewName     = "{0}{1}" -f $Label,$_.Extension
                    Extension   = $_.Extension
                }

                If ( $Image.Name -match "LiteTouchPE_" )
                {
                    If ( Test-Path $Image.NewName )
                    {
                        Remove-Item -Path $Image.NewName -Force -Verbose
                    }

                    Rename-Item -Path $Image.Path -NewName $Image.NewName
                }
            }

            If (!(Get-Service -Name WDSServer))
            {
                Throw "WDS Server not installed"
            }

            Get-Service -Name WDSServer | ? Status -ne Running | Start-Service -Verbose

            # Update/Flush FEShare(WDS)
            ForEach ( $Image in [BootImages]::New("$($Xaml.IO.DsRootPath.Text)\Boot").Images )
            {        
                If (Get-WdsBootImage -Architecture $Image.Type -ImageName $Image.Name -EA 0)
                {
                    Write-Theme "Detected [!] $($Image.Name), removing..." 12,4,15,0
                    Remove-WDSBootImage -Architecture $Image.Type -ImageName $Image.Name -Verbose
                }

                Write-Theme "Importing [~] $($Image.Name)" 11,3,15,0
                Import-WdsBootImage -Path $Image.Wim -NewDescription $Image.Name -Verbose
            }

            Restart-Service -Name WDSServer

            Write-Theme -Flag

            $Xaml.IO.DialogResult = $True
        }
    })

    # Set initial TextBox values
    $Xaml.IO.DsNwNetBIOSName.Text = $Env:UserDomain
    $Xaml.IO.DsNwDNSName.Text     = @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
    $Xaml.IO.DsLmUsername.Text    = "Administrator"
    
    $Xaml.Invoke()
}
