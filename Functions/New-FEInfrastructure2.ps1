# Testing an overhaul of New-FEInfrastructure
Function Config
{
    [CmdLetbinding()]Param([Parameter(Mandatory)][Object]$Module)
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
                Write-Host "Collecting [~] ($($Zone.Zonename))"
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
    Class Config
    {
        [Object] $Module
        [Object] $IPConfig
        [Object] $IP
        [Object] $Dhcp
        [Object] $Dns
        [Object] $Adds
        [Object] $HyperV
        [Object] $Wds
        [Object] $Mdt
        [Object] $IIS
        [Object] $Output
        Config([Object]$Module)
        {
            $This.Module            = $Module
            Write-Host "Collecting [~] Network IP Config"
            $This.IPConfig          = Get-NetIPConfiguration | % { [IPConfig]$_ }
            $This.IP                = Get-NetIPAddress | % IPAddress
            $Features               = Get-WindowsFeature
            $Registry               = @( "","\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" })
            $This.Output            = @(
                ForEach ( $Item in "DHCP","DNS","AD-Domain-Services","Hyper-V","WDS","Web-WebServer")
                {
                    [DGList]::New($Item, [Bool]($Features | ? Name -eq $Item | % Installed))
                }
                
                ForEach ( $Item in "MDT","WinADK","WinPE")
                {
                    $Slot = Switch($Item)
                    {
                        MDT    { $Registry[0], "Microsoft Deployment Toolkit"                       , "6.3.8456.1000" }
                        WinADK { $Registry[1], "Windows Assessment and Deployment Kit - Windows 10" , "10.1.17763.1"  }
                        WinPE  { $Registry[1], "Preinstallation Environment Add-ons - Windows 10"   , "10.1.17763.1"  }
                    }
                        
                    [DGList]::New($Item, [Bool](Get-ItemProperty $Slot[0] | ? DisplayName -match $Slot[1] | ? DisplayVersion -ge $Slot[2]))
                }
            )
            If ($This.Output | ? Name -match DHCP | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Dhcp Server"
                $This.Dhcp              = [DhcpServer]::New().Scope
            }
            If ($This.Output | ? Name -match DNS | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Dns Server"
                $This.Dns               = [DnsServer]::New().Zone
            }
            If ($This.Output | ? Name -match AD-Domain-Services | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Adds Server"
                $This.Adds              = [AddsDomain]::New()
            }
            If ($This.Output | ? Name -match Hyper-V | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Hyper-V Server"
                $This.HyperV            = [VmHost]::New($This.IPConfig)
            }
            If ($This.Output | ? Name -match WDS | ? Value -eq 1)
            {
                Write-Host "Collecting [~] Wds Server"
                $This.WDS               = [WDSServer]::New($This.Module.Role.System.Network.IPAddress)
            }
            If ($This.Output | ? Name -match MDT | ? Value -eq 1)
            {
                Write-Host "Collecting [~] MDT/WinPE/WinADK Server"
                $This.MDT               = [MdtServer]::New($This.Module.Role.System.Network.IPAddress,$Registry)
            }
            If ($This.Output | ? Name -match Web-WebServer | ? Value -eq 1)
            {
                Write-Host "Collecting [~] IIS Server"
                $This.IIS               = [IISServer]::New()
            }
        }
    }
    [Config]::New($Module)
}

Function SiteList
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param([Parameter(Mandatory,ParameterSetName=0)][Object]$Module)

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
        Static [String] GetName([String]$Code)
        {
            Return @( [States]::List | % GetEnumerator | ? Value -match $Code | % Name )
        }
        Static [String] GetCode([String]$Name)
        {
            Return @( [States]::List | % GetEnumerator | ? Name -eq $Name | % Value )
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
        [Object] Zip([String]$Zip)
        {
            $Index = $This.Stack["$Zip"]
            If (!$Index)
            {
                Return [ZipEntry][UInt32]$Zip
            }

            Return [ZipEntry]$This.Content[$Index]
        }
    }

    Class Location
    {
        [String]     $Organization
        [String]       $CommonName
        Hidden [String]      $Type
        [String]         $Location
        [String]           $Region
        [String]          $Country
        [Int32]            $Postal
        [String]         $SiteLink
        [String]         $SiteName
        Hidden [Object]    $SiteDN
        Location([String]$Organization,[String]$CommonName,[Object]$Zip)
        {
            $This.Organization     = $Organization
            $This.CommonName       = $CommonName
            $This.Type             = $Zip.Type

            $This.Location         = $Zip.Name
            $This.Country          = $Zip.Country
            $This.Postal           = $Zip.Zip

            If ($Zip.Type -ne "Invalid")
            {
                $This.Region           = $Zip.State
                $This.GetSiteLink()
                $This.Region           = [States]::GetName($Zip.State)
            }

            If ($Zip.Type -eq "Invalid" )
            {
                $This.Region           = "N/A"
                $This.SiteName         = "-"
                $This.Sitelink         = "-"
            }
        }
        GetSiteLink()
        {
            $Return                = @{ }

            # City
            $Return.Add(0,@( Switch -Regex ($This.Location)
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
            $Return.Add(1,$This.Region)

            # Country
            $Return.Add(2,$This.Country)

            # Zip
            $Return.Add(3,$This.Postal)

            $This.SiteLink = ($Return[0..3] -join "-").ToUpper()
            $This.SiteName = ("{0}.{1}" -f ($Return[0..3] -join "-"),$This.CommonName).ToLower()
        }
        [String] ToString()
        {
            Return $This.Sitelink
        }
    }

    Class Topology
    {
        Hidden [String[]]     $Enum = "True","False"
        [UInt32]             $Index
        [String]              $Name
        [String]          $SiteName
        [UInt32]            $Exists
        [Object] $DistinguishedName
        Topology([UInt32]$Index,[Object]$Site,[String]$Base)
        {
            $This.Index             = $Index
            $This.Name              = $Site.Sitelink
            $This.DistinguishedName = "CN=$($Site.SiteLink),$Base"
            $This.Sitename          = $Site.Sitename
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class SiteList
    {
        [String]      $Organization
        [String]        $CommonName
        Hidden [Object]   $Zipstack
        [Object]         $Aggregate
        [Object]          $Topology
        SiteList([String]$Path)
        {
            Write-Host "Loading [~] US Postal Code Database"
            $This.Zipstack     = [Zipstack]::New($Path)
            $This.Aggregate    = @( )
            $This.Topology     = @( )
        }
        SetDomain([String]$Organization,[String]$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
        }
        AddSite([UInt32]$Postal)
        {
            If ($Postal -notin $This.Output.Postal)
            {
                $Item              = $This.Zipstack.Zip($Postal)
                $This.Aggregate   += [Location]::New($This.Organization,$This.CommonName,$Item)
            }
        }
        RemoveSite([UInt32]$Postal)
        {
            If ($Postal -in $This.Output.Postal)
            {
                $This.Aggregate    = $This.Output | ? Postal -ne $Postal
            }
        }
        [String] SearchBase()
        {
            Return "CN=Sites,CN=Configuration,{0}" -f (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
        }
        GetSiteList()
        {
            $This.Topology      = @( )
            $SearchBase         = $This.SearchBase()
            $List               = Get-ADObject -LDAPFilter "(ObjectClass=Site)" -SearchBase $SearchBase
            ForEach ($Site in $This.Aggregate)
            {
                $Item           = [Topology]::New($This.Topology.Count,$Site,$SearchBase)
                $Item.Exists    = @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
                $Site.SiteDN    = $Item
                $This.Topology += $Item
            }
        }
        NewSiteList()
        {
            ForEach ($Site in $This.Topology)
            {
                Switch ($Site.Exists)
                {
                    0
                    {
                        New-ADReplicationSite -Name $Site.Name -Verbose
                        $Site.Exists = 1
                    }
                    1
                    {
                        Write-Host ("Item [+] Exists [{0}]" -f $Site.DistinguishedName) -F 12
                    }
                }
            }
        }
    }

    If (!$Module)
    {
        $Module = Get-FEModule
    }

    $Path   = $Module.Control | ? Name -match zipcode.txt | % FullName
    
    [SiteList]::New($Path)
}

Function NetworkList
{
    Class Subnet
    {
        [String]            $Name
        [String]         $Network
        [UInt32]          $Prefix
        [String]         $Netmask
        [UInt32]       $HostCount
        [String]       $HostRange
        [String]           $Start
        [String]             $End
        [String]       $Broadcast
        [String]      $ReverseDNS
        Hidden [Object] $SubnetDN
        Subnet([String]$Prefix)
        {
            $This.Name       = $Prefix
            $Object          = $Prefix.Split("/")
            $This.Network    = $Object[0]
            $This.Prefix     = $Object[1]
            $This.Netmask    = $This.GetSubnetMask($Object[1])
            $This.Remain()
            $This.ReverseDNS = $This.GetReverseDNS()
        }
        Subnet([String]$Network,[String]$Prefix,[String]$Netmask)
        {
            $This.Name       = "$Network/$Prefix"
            $This.Network    = $Network
            $This.Prefix     = $Prefix
            $This.Netmask    = $Netmask
            $This.Remain()
            $This.ReverseDNS = $This.GetReverseDNS()
        }
        [Object] GetSubnetMask([UInt32]$CIDR)
        {
            Return @( @( 0,8,16,24 | % {[Convert]::ToInt32(("{0}{1}" -f ("1" * $CIDR -join ''),("0" * (32-$CIDR) -join '')).Substring($_,8),2)} ) -join '.' )
        }
        Remain()
        {
            $NW             = [UInt32[]]$This.Network.Split(".")
            $NM             = [UInt32[]]$This.Netmask.Split(".")
            $This.HostCount = (( $NM | % { 256 - $_ } ) -join "*" | Invoke-Expression) - 2
            $This.HostRange = @( ForEach ($I in 0..3)
            {
                Switch ($NM[$I])
                {
                    255 
                    { 
                        $NW[$I]  
                    }
                    0   
                    { 
                        "0..255" 
                    } 
                    Default 
                    { 
                        "{0}..{1}" -f $NW[$I],($NW[$I]+((256-$NM[$I])-1))
                    }
                }
            } ) -join '/'

            $H           = @{ }
            ForEach ($I in 0..3)
            {
                Switch ($NM[$I])
                {
                    255     
                    { 
                        $H.Add($I,$NW[$I])
                    }
                    0       
                    { 
                        $H.Add($I,@(0,255))
                    }
                    Default 
                    { 
                        $H.Add($I,@($NW[$I],($NW[$I] + ((256 - $NM[$I]) - 1))))
                    }
                }
            }
            $I        = @{ }
            ForEach ($0 in $H[0])
            {
                ForEach ($1 in $H[1])
                {
                    ForEach ($2 in $H[2])
                    {
                        ForEach ($3 in $H[3])
                        {
                            $I.Add($I.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }
            $X              = [UInt32[]]$I[0].Split(".")
            $X[-1]          = $X[-1] + 1
            $This.Start     = $X -join "."

            $Y              = [UInt32[]]$I[$I.Count-1].Split(".")
            $Y[-1]          = $Y[-1] - 1
            $This.End       = $Y -join "."

            $This.Broadcast = $I[$I.Count-1]
        }
        [String] GetReverseDNS()
        {
            $Mask    = $This.Netmask.Split(".") | % { 256 - $_ }
            $NW      = $This.Network.Split(".")
            $Reverse = ForEach ($X in 3..0)
            {
                If ($Mask[$X] -ne 256)
                {
                    $NW[$X]
                }
            }
            Return @( "{0}.in-addr.arpa" -f ($Reverse -join ".") )
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
            $X              = $Network.Split("/")
            $This.Network   = $X[0]
            $This.Prefix    = [UInt32]$X[1]
            $Octet          = $This.Network.Split(".")
            $NM             = 0,8,16,24 | % { [Convert]::ToInt32(("{0}{1}" -f ("1" * $X[1] -join ''),("0" * (32-$X[1]) -join '')).Substring($_,8),2)}
            $This.Netmask   = $NM -join "."
            $Hash           = @{ }
            $Contain        = @{ }
            ForEach ($I in 0..3)
            {
                If ($NM[$I] -notmatch "(0|255)")
                {
                    $Hash.Add($I,@(0..255 | ? { $_ % (256 - $NM[$I]) -eq 0 }))
                }
                Else
                {
                    $Hash.Add($I,$Octet[$I])
                }
            }
            ForEach ($0 in $Hash[0])
            {
                ForEach ($1 in $Hash[1])
                {
                    ForEach ($2 in $Hash[2])
                    {
                        ForEach ($3 in $Hash[3])
                        {
                            $Contain.Add($Contain.Count,"$0.$1.$2.$3/$($This.Prefix)")
                        }
                    }
                }
            }
            Write-Host "Found [~] ($($Contain.Count)) Networks"
            $This.Aggregate = 0..($Contain.Count-1) | % {
            
                $Item = $Contain[$_]
                Write-Host "Collecting [~] ($Item)"
                [Subnet]::New($Item) 
            }
        }
    }

    Class Topology
    {
        Hidden [String[]]     $Enum = "True","False"
        [UInt32]             $Index
        [String]              $Name
        [Object]           $Network
        [UInt32]            $Exists
        [Object] $DistinguishedName
        Topology([UInt32]$Index,[Object]$Subnet,[Object]$SearchBase)
        {
            $This.Index             = $Index
            $This.Name              = $Subnet.Name
            $This.Network           = $Subnet.Network
            $This.DistinguishedName = "CN=$($Subnet.Name),CN=Subnets,CN=Sites,$SearchBase"
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NetworkList
    {
        [String]      $Organization
        [String]        $CommonName
        [Object]           $Control
        [String]           $Network
        [UInt32]            $Prefix
        [Object]         $Aggregate
        [Object]          $Topology
        NetworkList()
        {
            $This.Aggregate = @( )
            $This.Topology  = @( )
        }
        SetDomain([String]$Organization,[String]$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
        }
        AddNetwork([String]$Network)
        {
            If ($Network -match "(\d+\.){3}\d+\/\d+")
            {
                $This.Control = [Network]::New($Network)
            }

            If ($This.Control)
            {
                $This.Network   = $This.Control.Network
                $This.Prefix    = $This.Control.Prefix
                ForEach ($Item in $This.Control.Aggregate)
                {
                    $This.Aggregate += $Item
                }
            }
        }
        AddSubnet([String]$Network)
        {
            If ($Network -match "(\d+\.){3}\d+\/\d+")
            {
                $This.Aggregate += [Subnet]::New($Network)
            }
        }
        RemoveSubnet([String]$Network)
        {
            $This.Aggregate = $This.Aggregate | ? Network -ne $Network
        }
        [String] SearchBase()
        {
            Return "CN=Configuration,{0}" -f (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
        }
        GetNetworkList()
        {
            $This.Topology        = @( )
            $SearchBase           = $This.SearchBase()
            $List                 = Get-ADObject -LDAPFilter "(ObjectClass=Subnet)" -SearchBase $SearchBase
            ForEach ($Network in $This.Aggregate)
            {
                $Item             = [Topology]::New($This.Topology.Count,$Network,$SearchBase)
                $Item.Exists      = @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
                $Network.SubnetDN = $Item
                $This.Topology   += $Item
            }
        }
        NewNetworkList()
        {
            ForEach ($Network in $This.Topology)
            {
                Switch ($Network.Exists)
                {
                    0
                    {
                        New-ADReplicationSubnet -Name $Network.Name -Verbose
                        $Network.Exists = 1
                    }
                    1
                    {
                        Write-Host ("Item [+] Exists [{0}]" -f $Network.DistinguishedName) -F 12
                    }
                }
            }
        }
    }

    [NetworkList]::New()
}

Function Sitemap
{
    Class Topology
    {
        [String] $Name
        [String] $Type
        [UInt32] $Exists
        [String] $DistinguishedName
        Topology([String]$Name,[String]$Type,[String]$Root)
        {
            $This.Name              = $Name
            $This.Type              = $Type
            $This.DistinguishedName = @{$False="OU=$Type,OU=$Name,$Root"; $True="OU=$Name,$Root"}[$Type -eq "Main"]
        }
        [String] ToString()
        {
            Return ("{0}/{1}" -f $This.Type, $This.Name)
        }
    }

    Class DomainTemplate
    {
        [Object]     $Site
        [Object]   $Subnet
        [Object] $Children
        DomainTemplate([Object]$SiteDN,[Object]$SubnetDN)
        {            
            $This.Site      = $SiteDN
            $This.Subnet    = $SubnetDN
            $This.Children  = @( )
        }
        LoadChild([Object]$Child)
        {
            $This.Children += $Child
        }
    }

    Class Domain
    {
        [UInt32]        $Index
        [String] $Organization
        [String]   $CommonName
        [String]         $Name
        [String]     $Location
        [String]       $Region
        [String]      $Country
        [String]       $Postal
        [String]     $SiteLink
        [String]     $SiteName
        [String]      $Network
        [String]       $Prefix
        [String]      $Netmask
        [String]        $Start
        [String]          $End
        [String]        $Range
        [String]    $Broadcast
        [String]   $ReverseDNS
        [Object]     $Template
        Domain([UInt32]$Index,[Object]$Domain,[Object]$Network)
        {
            $This.Index        = $Index
            $This.Organization = $Domain.Organization
            $This.CommonName   = $Domain.CommonName
            $This.Name         = $Domain.SiteLink
            $This.Location     = $Domain.Location
            $This.Region       = $Domain.Region
            $This.Country      = $Domain.Country
            $This.Postal       = $Domain.Postal
            $This.SiteLink     = $Domain.SiteLink
            $This.Sitename     = $Domain.Sitename
            $This.Network      = $Network.Network
            $This.Prefix       = $Network.Prefix
            $This.Netmask      = $Network.Netmask
            $This.Start        = $Network.Start
            $This.End          = $Network.End
            $This.Range        = $Network.HostRange
            $This.Broadcast    = $Network.Broadcast
            $This.ReverseDNS   = $Network.ReverseDNS
            $This.Template     = [DomainTemplate]::New($Domain.SiteDN,$Network.SubnetDN)
        }
    }

    Class SmTemplateItem
    {
        [String]   $Type
        [Bool]   $Create
        SmTemplateItem([String]$Type,[Bool]$Create)
        {
            $This.Type   = $Type
            $This.Create = $Create
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class SmTemplate
    {
        Hidden [String[]] $Names = ("Gateway Server Computers Users Service" -Split " ")
        [Object] $Output
        SmTemplate()
        {
            $This.Output = @( )

            ForEach ($Name in $This.Names)
            {
                $This.Output += [SmTemplateItem]::New($Name,1)
            }
        }
    }

    Class Sitemap
    {
        [String]     $Organization
        [String]       $CommonName
        [Object]         $Sitelist
        [Object]      $Networklist
        [Object]         $Template
        [Object]         $Sitelink
        [Object]   $SitelinkBridge
        [Object]        $Aggregate
        [Object]         $Topology
        Sitemap()
        {
            $This.Sitelist     = @( )
            $This.NetworkList  = @( )
            $This.Template     = [SmTemplate]::New()
            $This.Sitelink     = @( )
            $This.Aggregate    = @( )
            $This.Topology     = @( )
        }
        SetDomain([String]$Organization,[String]$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
        }
        LoadSitelist([Object]$Sitelist)
        {
            $This.Sitelist     = @( )
            ForEach ($Site in $SiteList)
            {
                $This.Sitelist += $Site
            }
        }
        LoadNetworkList([Object]$NetworkList)
        {
            $This.NetworkList = @( )
            ForEach ($Network in $NetworkList)
            {
                $This.NetworkList += $Network
            }
        }
        LoadSitemap()
        {
            $This.Aggregate = @( )
            If ($This.NetworkList.Count -ge $This.Sitelist.Count)
            {
                ForEach ($X in 0..($This.Sitelist.Count-1))
                {
                    $This.Aggregate += [Domain]::New($X,$This.SiteList[$X],$This.NetworkList[$X])
                }
            }
        }
        [String] SearchBase()
        {
            Return (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
        }
        GetSitelinkList()
        {
            $This.SiteLink = @( ) 
            ForEach ($Item in Get-ADObject -LDAPFilter "(ObjectClass=siteLink)" -SearchBase "CN=Configuration,$($This.SearchBase())")
            {
                $This.SiteLink += $Item
            }
        }
        SetSitelinkBridge([String]$DistinguishedName)
        {
            $This.SitelinkBridge = $This.Sitelink | ? DistinguishedName -eq $DistinguishedName
        }
        GetSitemap()
        {
            $This.Topology          = @( )
            $List                   = Get-ADObject -LDAPFilter "(ObjectClass=OrganizationalUnit)" -SearchBase $This.SearchBase()
            ForEach ($Domain in $This.Aggregate)
            {
                $Item               = [Topology]::New($Domain.Name,"Main",$This.SearchBase())
                $Item.Exists        = @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
                $Domain.Template.LoadChild($Item)
                $This.Topology     += $Item

                ForEach ($Child in $This.Template.Output | ? Create -eq 1)
                {
                    $Item           = [Topology]::New($Domain.Name,$Child.Type,$This.SearchBase())
                    $Item.Exists   += @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
                    $Domain.Template.LoadChild($Item)
                    $This.Topology += $Item
                }
            }
        }
        NewSitemap()
        {
            ForEach ($Domain in $This.Aggregate)
            {
                $OU             = @{ 

                    City        = $Domain.Location
                    Country     = $Domain.Country
                    Description = "[{0}/{1} {2}]" -f $Domain.Network,$Domain.Prefix,$Domain.Name
                    DisplayName = $Domain.Sitename
                    PostalCode  = $Domain.Postal
                    State       = $Domain.State
                    Name        = $Domain.Name
                    Path        = $Null
                }

                ForEach ($Item in $Domain.Template.Children)
                {
                    $OU.Path    = $Item.DistinguishedName
                    Switch ($Item.Exists)
                    {
                        0
                        {
                            New-ADOrganizationalUnit @OU -Verbose
                            If ($Item.Type -eq "Main")
                            {
                                $Location    = ("{0}, {1} {2}" -f $OU.City, $OU.State, $OU.PostalCode)
                                $Description = ("{0}/{1}" -f $OU.Network, $OU.Prefix)
                                Get-ADReplicationSubnet -Filter * | ? Name -match $Description | Set-ADReplicationSubnet -Location $Location -Site $Item.Name -Verbose

                                $Config      = $Domain.Template.Subnet.DistinguishedName
                                If (Get-ADReplicationSiteLink -Filter * | ? DistinguishedName -eq $This.SitelinkBridge | ? $Config -notin SitesIncluded)
                                {
                                    Set-ADReplicationSiteLink -Identity $This.SitelinkBridge -SitesIncluded @{"Add"=$Config} -Verbose
                                }
                            }
                        }
                        1
                        {
                            Write-Host ("Item [+] Exists [({0}) {1}]" -f $Domain.Name, $OU.Path) -F 12
                        }
                    }

                }
            }
        }
    }
    [Sitemap]::New()
}

Function AddsNode
{
    Class Topology
    {
        [String] $Organization
        [String] $CommonName
        [String] $Type
        [String] $Name
        [String] $DNSHostname
        [String] $Location
        [String] $Region
        [String] $Country
        [String] $Postal
        [String] $Sitelink
        [String] $Sitename
        [String] $Network
        [String] $Prefix
        [String] $Netmask
        [String] $Start
        [String] $End
        [String] $Range
        [String] $Broadcast
        [String] $ReverseDNS
        [String] $Parent
        [String] $DistinguishedName
        [UInt32] $Exists
        Topology([String]$Type,[String]$Name,[Object]$Site)
        {
            $This.Organization      = $Site.Organization
            $This.CommonName        = $Site.CommonName
            $This.Type              = $Type
            $This.Name              = $Name
            $This.DNSHostname       = ("{0}.{1}" -f $Name, $Site.CommonName)
            $This.Location          = $Site.Location
            $This.Region            = $Site.Region
            $This.Country           = $Site.Country
            $This.Postal            = $Site.Postal
            $This.Sitelink          = $Site.Sitelink
            $This.Sitename          = $Site.Sitename
            $This.Network           = $Site.Network
            $This.Prefix            = $Site.Prefix
            $This.Netmask           = $Site.Netmask
            $This.Start             = $Site.Start
            $This.End               = $Site.End
            $This.Range             = $Site.Range
            $This.Broadcast         = $Site.Broadcast
            $This.ReverseDNS        = $Site.ReverseDNS
            $Site.Template.Children | ? Type -eq $Type | % {

                $This.DistinguishedName = "CN=$Name,$($_.DistinguishedName)"
                $This.Parent            =  $_.DistinguishedName
            }
        }
    }

    Class AddsNode
    {
        [Object] $Gateway
        [Object] $Server
        [Object] $Workstation
        [Object] $Object
        AddsNode()
        {
            $This.Gateway     = @( )
            $This.Server      = @( )
            $This.Workstation = @( )
            $This.Object      = @( )
        }
        [Object] GetAddsNode([String]$Type,[String]$Name,[Object]$Site)
        {
            $Item = [Topology]::New($Type,$Name,$Site)
            If (Get-ADObject -LDAPFilter "(ObjectClass=Computer)" -SearchBase $Item.Parent | ? Name -eq $Name)
            {
                $Item.Exists = 1
            }
            If ($Type -eq "Server" -and $Item.Exists -eq 0)
            {
                $Swap              = "OU=Server,OU=$($Item.Sitelink),","OU=Domain Controllers,"
                $Parent            = $Item.Parent.Replace($Swap[0],$Swap[1])
                $DistinguishedName = $Item.DistinguishedName.Replace($Swap[0],$Swap[1])
                If (Get-ADObject -LDAPFilter "(ObjectClass=Computer)" | ? DistinguishedName -eq $DistinguishedName)
                {
                    $Item.Parent            = $Parent
                    $Item.DistinguishedName = $DistinguishedName 
                    $Item.Exists            = 1
                }
            }
            Return $Item
        }
        [Object] GetAddsNode([String]$DistinguishedName)
        {
            Return $This.Object | ? DistinguishedName -eq $DistinguishedName
        }
        AddAddsNode([String]$Type,[String]$Name,[Object]$Site)
        {
            $Item = $This.GetAddsNode($Type,$Name,$Site)
            If ($Item.Name -notin $This.Object.Name)
            {
                $This.Object += $Item
                Switch ($Item.Type)
                {
                    Gateway
                    {
                        $This.Gateway     += $Item
                    }
                    Server
                    {
                        $This.Server      += $Item
                    }
                    Workstation
                    {
                        $This.Workstation += $Item
                    }
                }
            }
            Switch ($Item.Exists)
            {
                0
                {
                    New-ADComputer -Name $Name -DNSHostname $Item.DNSHostname -Path $Item.DistinguishedName -TrustedForDelegation:$True -Force -Verbose
                }
                1
                {
                    Write-Host ("Item Exists [+] [{0}]" -f $Item.DistinguishedName) -F 12
                }
            }
        }
        RemoveAddsNode([String]$DistinguishedName)
        {
            $Item        = $This.GetAddsNode($DistinguishedName)
            $This.Object = $This.Object | ? DistinguishedName -ne $DistinguishedName
            Switch ($Item.Type)
            {
                Gateway
                {
                    $This.Gateway     = $This.Gateway     | ? DistinguishedName -ne $DistinguishedName
                }
                Server
                {
                    $This.Server      = $This.Server      | ? DistinguishedName -ne $DistinguishedName
                }
                Workstation
                {
                    $This.Workstation = $This.Workstation | ? DistinguishedName -ne $DistinguishedName
                }
            }
            Switch ($Item.Exists)
            {
                0
                {
                    Write-Host ("Item does not exist [+] [{0}]" -f $Item.DistinguishedName) -F 12
                }
                1
                {
                    Remove-ADComputer -Identity $DistinguishedName -Verbose -Force -Confirm:$False
                    
                }
            }
        }
    }
    [AddsNode]::New()
}

Function VmNode
{
    [CmdLetBinding()]
    Param(
        [Parameter()][String]$HostName = "localhost",
        [Parameter()][PSCredential]$Credential
    )
    Class Topology
    {
        [String] $Organization
        [String] $CommonName
        [String] $Type
        [String] $Name
        [String] $DNSHostname
        [String] $Location
        [String] $Region
        [String] $Country
        [String] $Postal
        [String] $Sitelink
        [String] $Sitename
        [String] $Network
        [String] $Prefix
        [String] $Netmask
        [String] $Start
        [String] $End
        [String] $Range
        [String] $Broadcast
        [String] $ReverseDNS
        [String] $Parent
        [String] $DistinguishedName
        [UInt32] $Exists
        Topology([Object]$Node,[Object]$VM)
        {
            $This.Organization      = $Node.Organization
            $This.CommonName        = $Node.CommonName
            $This.Type              = $Node.Type
            $This.Name              = $Node.Name
            $This.DNSHostname       = $Node.DNSHostName
            $This.Location          = $Node.Location
            $This.Region            = $Node.Region
            $This.Country           = $Node.Country
            $This.Postal            = $Node.Postal
            $This.Sitelink          = $Node.Sitelink
            $This.Sitename          = $Node.Sitename
            $This.Network           = $Node.Network
            $This.Prefix            = $Node.Prefix
            $This.Netmask           = $Node.Netmask
            $This.Start             = $Node.Start
            $This.End               = $Node.End
            $This.Range             = $Node.Range
            $This.Broadcast         = $Node.Broadcast
            $This.ReverseDNS        = $Node.ReverseDNS
            $This.DistinguishedName = $Node.DistinguishedName
            $This.Parent            = $Node.Parent
        }
    }

    Class Select
    {
        [String] $Type
        [String] $Name
        [Bool]   $Create
        Select([Object]$Item)
        {
            $This.Type   = $Item.Type
            $This.Name   = $Item.Name
            $This.Create = 1
        }
    }

    Class Test
    {
        [Object] $Name
        [Bool] $Exists
        Test([String]$Type,[String]$Name)
        {
            $Return      = $Null
            $This.Name   = $Name
            If ($Type -eq "VM")
            {
                $Return  = Get-VM -Name $Name -EA 0
            }
            If ($Type -eq "Switch")
            {
                $Return  = Get-VMSwitch -Name $Name -EA 0
            }
            $This.Exists = !!$Return
        }
    }

    Class VMSwitch
    {
        [String] $Type = "Switch"
        [Object] $Name
        [Bool] $Create = $True
        VMSwitch([String]$Name)
        {
            $This.Name = $Name
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

            $This.Path             = $This.Path -f $Path
            $This.NewVhdPath       = $This.NewVhdPath -f $Path

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
            $Ct = @{Gateway=1;Server=2;Workstation=2}[$This.Item.Type]
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

    Class VmNode
    {
        [String]   $HostName
        [String]     $Status
        [String]   $Username
        [String] $Credential
        [Object]       $Host
        [Object]     $Switch
        [Object]    $Control
        [Object]   $Internal
        [Object]   $External
        [Object]     $ADNode
        [Object]     $VMNode
        VmNode([String]$ID)
        {
            $This.Username   = $Env:Username
            $This.Credential = Get-Credential $Env:Username
            $This.GetHost($ID)
        }
        VmNode([String]$ID,[PSCredential]$Credential)
        {
            $This.Username   = $Credential.Username
            $This.Credential = $Credential
            $This.GetHost($ID)
        }
        GetHost([String]$ID)
        {
            If ($ID -eq "localhost")
            {
                $ID = $Env:ComputerName
            }
            $This.Hostname = [System.Net.DNS]::Resolve($ID).Hostname | Select-Object -First 1
            $This.Status   = Get-Service -ComputerName $This.Hostname -Name vmms | % Status
            If ($This.Status -ne "Running")
            {
                $This.Host     = $Null
                $This.Switch   = $Null
                $This.External = $Null
                $This.Internal = $Null
            }
            If ($This.Status -eq "Running")
            {
                $This.Host     = Get-VMHost   -ComputerName $This.Hostname
                $This.Switch   = Get-VMSwitch -ComputerName $This.Hostname
                $This.External = $This.Switch | ? SwitchType -eq External
                $This.Internal = $This.Switch | ? SwitchType -eq Internal
            }
        }
        GetVmNode([Object]$DistinguishedName)
        {

        }
        AddVmNode([Object]$AddsNode)
        {

        }
    }
    If ($Credential)
    {
        [VmNode]::New($Hostname,$Credential)
    }
    If (!$Credential)
    {
        [VmNode]::New($Hostname)
    }
}

Function Image
{
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

                ForEach ($Item in Get-ChildItem $This.Source *.iso)
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
            }

            $This.Selected.Letter = $This.Selected.GetDiskImage() | Get-Volume | % DriveLetter
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
        SetTarget([String]$Target)
        {
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

            $This.Target = $Target
        }
        Extract()
        {
            $X               = 0
            $DestinationName = $Null
            $Label           = $Null

            ForEach ($File in $This.Image.Queue)
            {
                $Disk        = Get-DiskImage -ImagePath $File.Name
                $Name        = $File.Name | Split-Path -Leaf
                If ($Name.Length -gt 65)
                {
                    $Name    = "$($Name.Substring(0,64))..."
                }
                If (!$Disk.Attached)
                {
                    Write-Theme "Mounting [~] $Name"
                    Mount-DiskImage -ImagePath $Disk.ImagePath -Verbose
                    $Disk    = Get-DiskImage -ImagePath $File.Name
                }

                $Path        = "{0}:\sources\install.wim" -f ($Disk | Get-Volume | % DriveLetter)

                ForEach ($Item in $File.Content)
                {
                    Switch -Regex ($Item.Name)
                    {
                        Server
                        {
                            $Year               = [Regex]::Matches($Item.Name,"(\d{4})").Value
                            $ID                 = $Item.Name -Replace "Windows Server \d{4} SERVER",''
                            $Edition, $Tag      = Switch -Regex ($ID) 
                            {
                                "^STANDARDCORE$"   { "Standard Core",  "SDX" }
                                "^STANDARD$"       { "Standard",        "SD" }
                                "^DATACENTERCORE$" { "Datacenter Core","DCX" }
                                "^DATACENTER$"     { "Datacenter",      "DC" }
                            }
                            $DestinationName    = "Windows Server $Year $Edition (x64)"
                            $Label              = "{0}{1}" -f $Tag, $Year
                        }

                        Default
                        {
                            $ID                 = $Item.Name -Replace "Windows 10 "
                            $Tag                = Switch -Regex ($ID)
                            {
                                "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                                "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                                "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                                "^Pro N$"            { "PRO_N"      } "^Pro Education$"     { "PRO_EDUC" }
                                "^Pro Education N$"  { "PRO_EDUC_N" } "^Pro for Work.+$"    { "PRO_WS"   }
                                "^Pro N for Work.+$" { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                            }
                            $DestinationName    = "{0} (x{1})" -f $Item.Name, $Item.Architecture
                            $Label              = "10{0}{1}" -f $Tag, $Item.Architecture
                        }
                    }

                    $ISO                        = @{

                        SourceIndex             = $Item.Index
                        SourceImagePath         = $Path
                        DestinationImagePath    = ("{0}\({1}){2}\{2}.wim" -f $This.Image.Target,$X,$Label)
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
            Write-Theme "Complete [+] ($($This.Image.Queue.Content.Count)) *.wim files Extracted" 10,2,15
        }
    }
    [ImageStack]::New()
}

Function Mdt
{
    [CmdLetBinding()]
    Param([Parameter()][Object]$Module)

    Class WimFile
    {
        [UInt32] $Rank
        [Object] $Label
        [Object] $Date
        [UInt32] $ImageIndex            = 1
        [String] $ImageName
        [String] $ImageDescription
        [String] $Version
        [String] $Architecture
        [String] $InstallationType
        [String] $SourceImagePath
        WimFile([UInt32]$Rank,[String]$Image)
        {
            If (!(Test-Path $Image))
            {
                Throw "Invalid Path"
            }

            $Item                       = Get-Item $Image
            $This.Date                  = $Item.LastWriteTime.GetDateTimeFormats()[5]
            $SDate                      = $This.Date.Split("-")
            $This.SourceImagePath       = $Image
            $This.Rank                  = $Rank

            Get-WindowsImage -ImagePath $Image -Index 1 | % {
                
                $This.Version           = $_.Version
                $This.Architecture      = @(86,64)[$_.Architecture -eq 9]
                $This.InstallationType  = $_.InstallationType
                $This.ImageName         = $_.ImageName
                $This.Label             = $Item.BaseName
                $This.ImageDescription  = "[{0}-{1}{2} (MCC/SDP)][{3}]" -f $SDate[0],$SDate[1],$SDate[2],$This.Label

                If ($This.ImageName -match "Evaluation")
                {
                    $This.ImageName     = $This.ImageName -Replace "Evaluation","" -Replace "\(Desktop Experience\)","" -Replace "(\s{2,})"," "
                }
            }
        }
    }

    Class Share
    {
        [String]$Name
        [String]$Root
        [Object]$Share
        [String]$Description
        [String]$Type
        [Object]$WimFiles
        Share([Object]$Drive)
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
            If (Test-Path "$($This.Root)\Operating Systems")
            {
                $This.ImportWimFiles("$($This.Root)\Operating Systems")
            }
        }
        Share([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
        {
            If (Get-SMBShare -Name $Share -EA 0)
            {
                Throw "Share name is already assigned"
            }

            $This.Name          = $Name
            $This.Root          = $Root
            $This.Share         = $Share
            $This.Description   = $Description
            $This.Type          = @("MDT","PSD","-")[$Type]
        }
        ImportWimFiles([String]$Path)
        {
            $This.WimFiles      = @( )
            Write-Host "[Drive]://$($This.Name)" -F 10
            ForEach ($Item in Get-ChildItem $Path *.wim -Recurse)
            {
                $WimFile        = [WimFile]::New($This.WimFiles.Count,$Item.FullName)
                If ($WimFile.Label -notin $This.WimFiles.Label)
                {
                    Write-Host "[Importing]://$($Item.Name)" -F 10
                    $This.WimFiles += [WimFile]::New($This.WimFiles.Count,$Item.FullName)
                }
                ElseIf ($WimFile.Label -in $This.WimFiles.Label)
                {
                    Write-Host "[Skipping]://$($Item.Name) - duplicate label present" -F 12
                }
            }
        }
    }

    Class Brand
    {
        [String] $Wallpaper
        [String] $Logo
        [String] $Manufacturer
        [String] $SupportPhone
        [String] $SupportHours
        [String] $SupportURL
        Brand()
        {
            Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Ea 0 | % {

                $This.Wallpaper    = $_.Wallpaper
            }

            Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation -EA 0 | % {

                $This.Logo         = $_.Logo
                $This.Manufacturer = $_.Manufacturer
                $This.SupportPhone = $_.SupportPhone
                $This.SupportHours = $_.SupportHours
                $This.SupportURL   = $_.SupportURL
            }
        }
        SetBrand([Object]$Brand)
        {
            ForEach ($Item in $Brand.PSObject.Properties)
            {
                If ($Item.Value)
                {
                    Switch ($Item.Name)
                    {
                        Wallpaper    { $Brand.Wallpaper    = $Item.Value }
                        Logo         { $Brand.Logo         = $Item.Value }
                        Manufacturer { $Brand.Manufacturer = $Item.Value }
                        SupportPhone { $Brand.SupportPhone = $Item.Value }
                        SupportHours { $Brand.SupportHours = $Item.Value }
                        SupportURL   { $Brand.SupportURL   = $Item.Value }
                    }
                }
            }
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

    Class Mdt
    {
        [Object]       $Module
        [String]    $MDTModule
        [Object]         $Path
        [Object]        $Drive
        [Object]        $Brand
        [String]        $Admin
        [String]     $Password
        Mdt([Object]$Module)
        {
            $This.Module    = $Module
            $This.MDTModule = Get-MDTModule
            $This.Path      = $This.MDTModule.Split("\")[0..2] -join '\'
            $This.MDTModule | Import-Module
            Restore-MDTPersistentDrive
            $This.Drive     = Get-MDTPersistentDrive | % { [Share]$_ }
        }
        [Object] NewKey([Object]$Root)
        {
            Return [Key]::New($Root)
        }
        GetBrand()
        {
            $This.Brand = [Brand]::New()
        }
        [Object] UpdateMdtDriveList()
        {
            Return $This.Drive
        }
        AddMdtDrive([String]$Name,[String]$Root,[String]$Share,[String]$Description,[UInt32]$Type)
        {
            $This.Drive = [Share]::New($Name,$Root,$Share,$Description,$Type)
        }
        ImportWimFiles([String]$Name,[String]$Path,[UInt32]$Mode)
        {
            If (!$This.Brand)
            {
                Throw "Set a brand first"
            }

            If (!$This.Admin)
            {
                Throw "No local administrator username set"
            }

            If (!$This.Password)
            {
                Throw "No local administrator password set"
            }

            # [Import OS/TS to MDT Share]
            $Select       = $This.Drive | ? Name -eq $Name
            $Select.ImportWimFiles($Path)

            $Root        = $Select.Root
            $OS          = "$Root\Operating Systems"
            $TS          = "$Root\Task Sequences"
            $Comment     = Get-Date -UFormat "[%Y-%m%d (MCC/SDP)][$($Select.Type)]"

            # [Create folders in the new MDT share]
            ForEach ($Type in "Server","Client")
            {
                ForEach ($Version in $Select.WimFiles | ? InstallationType -eq $Type | % Version | Select-Object -Unique)
                {
                    ForEach ($Slot in $OS, $TS)
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
            ForEach ($Image in $Select.WimFiles)
            {
                $Type                   = $Image.InstallationType
                $OSPath                 = "$OS\$Type\$($Image.Version)"

                $OperatingSystem        = @{

                    Path                = $OSPath
                    SourceFile          = $Image.SourceImagePath
                    DestinationFolder   = $Image.Label
                }
                
                Switch ($Mode)
                {
                    0
                    {
                        Import-MDTOperatingSystem @OperatingSystem -Verbose
                    }
                    1
                    {
                        Import-MDTOperatingSystem @OperatingSystem -Move -Verbose
                    }
                }

                $TaskSequence           = @{ 
                    
                    Path                = "$TS\$Type\$($Image.Version)"
                    Name                = $Image.ImageName
                    Template            = "{0}{1}Mod.xml" -f $Select.Type, $Type
                    Comments            = $Comment
                    ID                  = $Image.Label
                    Version             = "1.0"
                    OperatingSystemPath = Get-ChildItem -Path $OSPath | ? Name -match $Image.Label | % { "{0}\{1}" -f $OSPath, $_.Name }
                    FullName            = $This.Admin
                    OrgName             = $This.Brand.Manufacturer
                    HomePage            = $This.Brand.SupportURL
                    AdminPassword       = $This.Password
                }

                Import-MDTTaskSequence @TaskSequence -Verbose
            }
        }
        [String] GetNextEventPort()
        {
            $Collect = $This.Drive | % { Get-ItemProperty "$($_.Name):" }
            $Port    = @( 9800..9899 | ? { $_ % 2 -eq 0 } | ? { $_ -notin $Collect.MonitorEventPort } )
            Return $Port[0]
        }
        [Object] Enumerate([Hashtable]$Object)
        {
            $Output = @( )
            ForEach ($Item in $Object.GetEnumerator())
            {     
                If ($Item.Value.GetType().Name -eq "Hashtable")
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
        [Object] CustomSettings([String]$Type,[String]$UNC,[String]$Org,[String]$NetBIOS,[String]$DNS,[String]$Server,[String]$OU,[String]$UserID,[String]$Password)
        {
            $Output = $Null
            $Port   = $Null
            $Exists = Get-Item "$UNC\Control\CustomSettings.ini" -EA 0
            If (!$Exists)
            {
                $Port = $This.GetNextEventPort()
            }
            If ($Exists)
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
                        JoinDomain           = $NetBIOS
                        DomainAdmin          = $UserID.Split("@")[0]
                        DomainAdminPassword  = $Password
                        DomainAdminDomain    = $NetBIOS
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
                        EventService         = ("http://{0}:{1}" -f $Server,$Port)
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
                        EventService         = ("http://{0}:{1}" -f $Server,$Port)
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
        [String] GetHostname()
        {
            Return @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
        }
    }
    [Mdt]::New($Module)
}

Function Wds
{
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
            ForEach ($Item in Get-ChildItem $Directory | ? Extension | % BaseName | Select-Object -Unique)
            {
                $This.Images += [BootImage]::New($Directory,$Item)
            }
        }
    }
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

Class Main
{
    [Object]            $Module = (Get-FEModule)
    Static [String]       $Base = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
    Static [String]        $GFX = ("{0}\Graphics"    -f [Main]::Base)
    Static [String]       $Icon = ("{0}\icon.ico"    -f [Main]::GFX)
    Static [String]       $Logo = ("{0}\OEMLogo.bmp" -f [Main]::GFX)
    Static [String] $Background = ("{0}\OEMbg.jpg"   -f [Main]::GFX)
    [String]      $Organization
    [String]        $CommonName
    [Object]        $Credential
    [Object]            $System
    [Object]            $Config
    [Object]          $SiteList
    [Object]       $NetworkList
    [Object]           $Sitemap
    [Object]          $AddsNode
    [Object]            $VmNode
    [Object]             $Image
    [Object]            $Update
    [Object]               $MDT
    [Object]               $WDS
    Main()
    {
        # Pulls system information
        $This.Module.Role.GetSystem()

        # Assigns system information to system variable
        $This.System           = $This.Module.Role.System

        # Pulls configuration information (Network/DHCP/DNS/ADDS/Hyper-V/WDS/MDT/WinADK/WinPE/IIS)
        $This.Config           = Config -Module $This.Module

        # Pulls sitelist base and classes
        $This.SiteList         = Sitelist -Module $This.Module

        # Pulls networklist base and classes
        $This.NetworkList      = NetworkList

        # Load and sort/rename module files
        ForEach ($Item in $This.Module.Tree.Name)
        {
            $This.Module.$Item = @( $This.Module.$Item | % { [ModuleFile]$_ })
        }

        $This.Sitemap          = Sitemap

        # AD Node factory
        $This.AddsNode         = AddsNode

        # VM Node factory
        If ($This.Config.HyperV)
        {
            $This.VmNode       = VmNode
        }

        # Imaging
        $This.Image            = Image

        $This.MDT              = MDT -Module $This.Module

        $This.WDS              = WDS
    }
}

$Main = [Main]::New()

# Sitelist
$Main.Sitelist.SetDomain("Secure Digits Plus LLC","securedigitsplus.com")
#$Main.Sitelist.AddSite(12065)
$Main.Sitelist.AddSite(12019)
$Main.Sitelist.AddSite(12020)
$Main.Sitelist.AddSite(12118)
$Main.Sitelist.AddSite(12170)
$Main.Sitelist.AddSite(12203)
$Main.Sitelist.AddSite(12056)
$Main.Sitelist.AddSite(98052)
$Main.Sitelist.GetSiteList()

# NetworkList
$Main.Networklist.SetDomain("Secure Digits Plus LLC","securedigitsplus.com")
$Main.NetworkList.AddNetwork("172.16.0.0/19")
$Main.NetworkList.RemoveSubnet("172.16.0.0")
$Main.NetworkList.GetNetworkList()

# Sitemap
$Main.Sitemap.SetDomain("Secure Digits Plus LLC","securedigitsplus.com")
$Main.Sitemap.LoadSitelist($Main.Sitelist.Aggregate)
$Main.Sitemap.LoadNetworkList($Main.NetworkList.Aggregate)
$Main.Sitemap.GetSitelinkList()
$Main.Sitemap.SetSiteLinkBridge($Main.Sitemap.Sitelink[0].DistinguishedName)
$Main.Sitemap.LoadSitemap()
$Main.Sitemap.GetSitemap()

# AD Node
# [Gateway]
ForEach ($Site in $Main.Sitemap.Aggregate)
{
    $Main.AddsNode.AddAddsNode("Gateway",$Site.Name,$Site)
}

# [Server]
ForEach ($Site in $Main.Sitemap.Aggregate)
{
    $Main.AddsNode.AddAddsNode("Server","dc1-$($Site.Postal)",$Site)
}
