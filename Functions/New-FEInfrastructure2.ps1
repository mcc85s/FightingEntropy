Function New-FEInfrastructure2
{
    # Testing an overhaul of New-FEInfrastructure
    Add-Type -AssemblyName PresentationFramework,System.Windows.Forms
    Import-Module FightingEntropy

    Function Config
    {
        [CmdLetBinding()]Param([Parameter(Mandatory)][Object]$Module)
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
                    $This.Zone += [DnsServerZone]::New($This.Zone.Count,$Zone)
                    Write-Host "[+] ($($Zone.Zonename))"
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
        Class VmHost
        {
            [String] $Name
            [UInt32] $Processor
            [String] $Memory
            [String] $VHDPath
            [String] $VMPath
            [UInt32] $Switch
            [UInt32] $Vm
            VmHost([Object]$IP)
            {
                $VMHost         = Get-VMHost
                $This.Name      = @($VMHost.ComputerName,"$($VMHost.ComputerName).$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
                $This.Processor = $VMHost.LogicalProcessorCount
                $This.Memory    = "{0:n2} GB" -f [Float]($VMHost.MemoryCapacity/1GB)
            }
        }
        # [WDS Classes]
        Class WdsServer
        {
            [String] $Server
            [Object[]] $IPAddress
            WdsServer([Object]$IP)
            {
                $This.Server    = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
                $This.IPAddress = @($IP)
            }
        }
        # [Mdt Classes]
        Class MdtServer
        {
            [String]      $Server
            [Object[]] $IPAddress
            [String]        $Path
            [String]     $Version
            [String]  $AdkVersion
            [String]   $PEVersion
            MdtServer([Object]$IP,[Object]$Registry)
            {
                $This.Server     = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
                $This.IPAddress  = @($IP)
                $This.Path       = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment*" | % Install_Dir
                $This.Version    = Get-ItemProperty $Registry | ? DisplayName -match "Microsoft Deployment Toolkit" | % DisplayVersion | % TrimEnd \
                $This.AdkVersion = Get-ItemProperty $Registry | ? DisplayName -match "Windows Assessment and Deployment Kit - Windows 10" | % DisplayVersion
                $This.PeVersion  = Get-ItemProperty $Registry | ? DisplayName -match "Preinstallation Environment Add-ons - Windows 10"   | % DisplayVersion
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
                $This.IPConfig          = Get-NetIPConfiguration | % { [IPConfig]$_ }
                Write-Host "[+] Network Configuration"

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
                    $This.Dhcp              = [DhcpServer]::New().Scope
                    Write-Host "[+] Dhcp"
                }
                If ($This.Output | ? Name -match DNS | ? Value -eq 1)
                {
                    $This.Dns               = [DnsServer]::New().Zone
                    Write-Host "[+] Dns"
                }
                If ($This.Output | ? Name -match AD-Domain-Services | ? Value -eq 1)
                {
                    $This.Adds              = [AddsDomain]::New()
                    Write-Host "[+] Adds"
                }
                If ($This.Output | ? Name -match Hyper-V | ? Value -eq 1)
                {
                    $This.HyperV            = [VmHost]::New($This.IPConfig)
                    Write-Host "[+] Veridian"
                }
                If ($This.Output | ? Name -match WDS | ? Value -eq 1)
                {
                    $This.WDS               = [WDSServer]::New($This.Module.Role.System.Network.IPAddress)
                    Write-Host "[+] Wds"
                }
                If ($This.Output | ? Name -match MDT | ? Value -eq 1)
                {
                    $This.MDT               = [MdtServer]::New($This.Module.Role.System.Network.IPAddress,$Registry)
                    Write-Host "[+] Mdt/WinPE/WinAdk"
                }
                If ($This.Output | ? Name -match Web-WebServer | ? Value -eq 1)
                {
                    $This.IIS               = [IISServer]::New()
                    Write-Host "[+] IIS"
                }
            }
            [String] ToString()
            {
                Return "<Config>"
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
            [Object] GetExternalIP()
            {
                Return Invoke-RestMethod http://ifconfig.me/ip 
            }
            [Object] GetLocation()
            {
                Return Invoke-RestMethod http://ipinfo.io/$($This.GetExternalIP())
            }
            AddSite([UInt32]$Postal)
            {
                If ($Postal -notin $This.Aggregate.Postal)
                {
                    $Item              = $This.Zipstack.Zip($Postal)
                    $This.Aggregate   += [Location]::New($This.Organization,$This.CommonName,$Item)
                }
            }
            RemoveSite([UInt32]$Postal)
            {
                If ($Postal -in $This.Aggregate.Postal)
                {
                    $This.Aggregate    = $This.Aggregate | ? Postal -ne $Postal
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
            [String] ToString()
            {
                Return "<Sitelist>"
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
                $This.Aggregate = $This.Aggregate | ? Name -ne $Network
            }
            [String] SearchBase()
            {
                Return "CN=Configuration,{0}" -f (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
            }
            GetNetworkList()
            {
                $This.Topology            = @( )
                $SearchBase               = $This.SearchBase()
                $List                     = Get-ADObject -LDAPFilter "(ObjectClass=Subnet)" -SearchBase $SearchBase
                ForEach ($Network in $This.Aggregate)
                {
                    $Item                 = [Topology]::New($This.Topology.Count,$Network,$SearchBase)
                    $Item.Exists          = @(0,1)[$Item.DistinguishedName -in $List.DistinguishedName]
                    $Network.SubnetDN     = $Item
                    If ($Item.Name -notin $This.Topology)
                    {
                        $This.Topology   += $Item
                    }
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
            [String] ToString()
            {
                Return "<NetworkList>"
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
            [String] ToString()
            {
                Return "<DomainTemplate>"
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
            [String] ToString()
            {
                Return $This.Sitename
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
            [String] ToString()
            {
                Return "<Sitemap>"
            }
        }
        [Sitemap]::New()
    }

    Function AddsController
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

        Class AddsHost
        {
            [String] $Organization
            [String] $CommonName
            [String] $Site
            [String] $Location
            [String] $Region
            [String] $Country
            [UInt32] $Postal
            [String] $Sitelink
            [String] $Sitename
            [String] $Network
            [UInt32] $Prefix
            [String] $Netmask
            [String] $Start
            [String] $End
            [String] $Range
            [String] $Broadcast
            [String] $ReverseDNS
            [Object] $Computer
            [String] $Hostname
            [String] $DnsName
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [String] $Guid
            AddsHost([Object]$Site,[Object]$Node)
            {
                $This.Site              = $Site.Organization
                $This.CommonName        = $Site.CommonName
                $This.Site              = $Site.SiteLink
                $This.Location          = $Site.Location
                $This.Region            = $Site.Region
                $This.Country           = $Site.Country
                $This.Postal            = $Site.Postal
                $This.SiteLink          = $Site.SiteLink
                $This.Sitename          = $Site.Sitename
                $This.Network           = $Site.Network
                $This.Prefix            = $Site.Prefix
                $This.Netmask           = $Site.Netmask
                $This.Start             = $Site.Start
                $This.End               = $Site.End
                $This.Range             = $Site.Range
                $This.Broadcast         = $Site.Broadcast
                $This.ReverseDNS        = $Site.ReverseDNS
                $This.Hostname          = $Node.Name
                $This.Type              = $Node.Type
                $This.DnsName           = ("{0}.{1}" -f $Node.Name, $Site.CommonName)
                $This.Parent            = $Node.Parent
                $This.DistinguishedName = $Node.DistinguishedName
                $This.Exists            = $Node.Exists
            }
            Get()
            {

            }
            New()
            {

            }
            Remove()
            {

            }
        }

        Class AddsAccount
        {
            [String] $Organization
            [String] $CommonName
            [String] $Site
            [String] $Location
            [String] $Region
            [String] $Country
            [UInt32] $Postal
            [String] $Sitelink
            [String] $Sitename
            [String] $Network
            [UInt32] $Prefix
            [String] $Netmask
            [String] $Start
            [String] $End
            [String] $Range
            [String] $Broadcast
            [String] $ReverseDNS
            [Object] $Account
            [String] $Name
            [String] $Type
            [String] $SamName
            [String] $UserPrincipalName
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [String] $Guid
            AddsAccount([Object]$Site,[Object]$Node)
            {
                $This.Site              = $Site.Organization
                $This.CommonName        = $Site.CommonName
                $This.Site              = $Site.SiteLink
                $This.Location          = $Site.Location
                $This.Region            = $Site.Region
                $This.Country           = $Site.Country
                $This.Postal            = $Site.Postal
                $This.SiteLink          = $Site.SiteLink
                $This.Sitename          = $Site.Sitename
                $This.Network           = $Site.Network
                $This.Prefix            = $Site.Prefix
                $This.Netmask           = $Site.Netmask
                $This.Start             = $Site.Start
                $This.End               = $Site.End
                $This.Range             = $Site.Range
                $This.Broadcast         = $Site.Broadcast
                $This.ReverseDNS        = $Site.ReverseDNS
                $This.Name              = $Node.Name
                $This.Type              = $Node.Type
                $This.Parent            = $Node.Parent
                $This.DistinguishedName = $Node.DistinguishedName
                $This.Exists            = $Node.Exists
            }
            Get()
            {

            }
            New()
            {

            }
            Remove()
            {

            }
        }

        Class AddsNode
        {
            [String] $Name
            [String] $Type
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            AddsNode([Object]$Name,[Object]$Type,[String]$Base)
            {
                $This.Name              = $Name
                $This.Type              = $Type
                If ($This.Type -eq "Computers")
                {
                    $This.Type = "Workstation"
                }
                $This.Parent            = $Base
                $This.DistinguishedName = "CN=$Name,$Base"
                If (Get-ADObject -Identity "CN=$Name,$Base")
                {
                    $This.Exists        = 1
                }
            }
            [String] ToString()
            {
                Return $This.Name
            }
        }

        Class AddsContainer
        {
            [String] $Name
            [String] $Type
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [Object] $Children
            AddsContainer([Object]$Template)
            {
                $This.Name              = $Template.Name
                $This.Type              = $Template.Type
                $This.Parent            = $Template.DistinguishedName.Replace($Template.DistinguishedName.Split(",")[0],'').TrimStart(",")
                $This.DistinguishedName = $Template.DistinguishedName
                $This.Children          = @( )
                $This.Exists            = 1
            }
            [Object] GetNode([String]$Name)
            {
                Return $This.Children | ? Name -eq $Name
            }
            AddContainer([Object]$Container)
            {
                If ($Container.Type -notin $This.Children.Type)
                {
                    $This.Children += [AddsContainer]::New($Container)
                }         
            }
            AddNode([String]$Name)
            {
                If ($Name -notin $This.Children.Name)
                {
                    $This.Children += [AddsNode]::New($Name,$This.Type,$This.DistinguishedName)
                }
            }
            RemoveNode([String]$Name)
            {
                If ($Name -in $This.Children.Name)
                {
                    $This.Children = @( $This.Children | ? Name -ne $Name )
                }
            }
            [String] ToString()
            {
                Return "{0}/{1}" -f $This.Type, $This.Name
            }
        }

        Class AddsSite
        {
            [String] $Name
            [Object] $Control
            [Object] $Template
            [Object] $Site
            [Object] $Subnet
            [Object] $Main
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            [Object] $User
            [Object] $Service
            AddsSite([Object]$Control)
            {
                $This.Name        = $Control.Name
                $This.Control     = $Control
                $This.Template    = $Control.Template
                $This.Site        = $Control.Template.Site
                $This.Subnet      = $Control.Template.Subnet
                $This.Main        = $Control.Template.Children | ? Type -eq Main      | % { [AddsContainer]::New($_) }
                ForEach ($Item in $Control.Template.Children | ? Type -ne Main)
                {
                    $This.Main.AddContainer($Item)
                }
                $This.Gateway     = $This.Main.Children | ? Type -eq Gateway
                $This.Server      = $This.Main.Children | ? Type -eq Server
                $This.Workstation = $This.Main.Children | ? Type -eq Computers
                $This.User        = $This.Main.Children | ? Type -eq Users
                $This.Service     = $This.Main.Children | ? Type -eq Service
            }
            [Object] GetContainer([String]$Name)
            {
                Return $This.$($Name)
            }
        }

        Class AddsController
        {
            [Object] $Sitemap
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            [Object] $User
            [Object] $Service
            [Object] $Host
            [Object] $Account
            AddsController()
            {
                $This.Sitemap     = @( )
                $This.Gateway     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                $This.Server      = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                $This.Workstation = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                $This.User        = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                $This.Service     = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
                $This.Host        = @( )
                $This.Account     = @( )
            }
            LoadSitemap([Object[]]$Sitemap)
            {
                $This.Sitemap     = @($Sitemap | % { [AddsSite]::New($_) })
            }
            [Object] GetSite([String]$Sitename)
            {
                Return $This.Sitemap | ? Name -eq $Sitename
            }
            GetGatewayList()
            {
                $This.Gateway.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Gateway)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Gateway.Add($Child)
                        }
                    }
                }
            }
            GetServerList()
            {
                $This.Server.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Server)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Server.Add($Child)
                        }
                    }
                }
            }
            GetWorkstationList()
            {
                $This.Workstation.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Workstation)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Workstation.Add($Child)
                        }
                    }
                }
            }
            GetUserList()
            {
                $This.User.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.User)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.User.Add($Child)
                        }
                    }
                }
            }
            GetServiceList()
            {
                $This.Service.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Service)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Service.Add($Child)
                        }
                    }
                }
            }
            GetNodeList()
            {
                $This.Gateway.Clear()
                $This.Server.Clear()
                $This.Workstation.Clear()
                $This.User.Clear()
                $This.Service.Clear()
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Gateway, $Site.Server, $Site.Workstation, $Site.User, $Site.Service)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            Switch ($Child.Type)
                            {
                                Gateway     { $This.Gateway.Add($Child)     }
                                Server      { $This.Server.Add($Child)      }
                                Workstation { $This.Workstation.Add($Child) }
                                User        { $This.User.Add($Child)        }
                                Service     { $This.Service.Add($Child)     }
                            }
                        }
                    }
                }
            }
            AddNode([String]$Sitename,[String]$Type,[String]$Name)
            {
                $Site      = $This.GetSite($Sitename)
                $Container = $Site.GetContainer($Type)
                If ($Name -notin $Container.Children.Name)
                {
                    $Container.AddNode($Name)
                }
            }
            RemoveNode([Object]$Object)
            {
                $Sitename  = ($Object.DistinguishedName.Split(",") | ? { $_ -match "OU\=" })[-1] -Replace "OU=",""
                $Site      = $This.GetSite($SiteName)
                $Container = $This.GetContainer($Object.Type)
                If ($Object.Name -in $Container.Children.Name)
                {
                    $Container.RemoveNode($Object.Name)
                } 
                $This.GetNodeList($Object.Type)                
            }
            RemoveNode([String]$Sitename,[String]$Type,[String]$Name)
            {
                $Site      = $This.GetSite($Sitename)
                $Container = $Site.GetContainer($Type)
                If ($Name -in $Container.Children.Name)
                {
                    $Container.RemoveNode($Name)
                }
            }
            [Object] GetNode([String]$Sitename,[String]$Type,[String]$Name)
            {
                $Site      = $This.GetSite($Sitename)
                $Container = $Site.GetContainer($Type)
                If ($Name -in $Container.Children.Name)
                {
                    Return $Container.GetNode($Name)
                }
                Else
                {
                    Return $Null
                }
            }
            [Object] GetNode([String]$DistinguishedName)
            {
                $Sitename  = ($DistinguishedName.Split(",") | ? { $_ -match "OU\=" })[-1] -Replace "OU=",""
                $Type      = ($DistinguishedName.Split(",") | ? { $_ -match "OU\=" })[0]  -Replace "OU=",""
                $Name      = ($DistinguishedName.Split(",") | ? { $_ -match "CN\=" })  -Replace "CN=",""
                $Site      = $This.GetSite($SiteName)
                $Container = $Site.GetContainer($Type)
                If ($Name -in $Container.Children.Name)
                {
                    Return $Container.GetNode($Name)
                }
                Else
                {
                    Return $Null
                }
            }
            NewHost([Object]$Site,[Object]$Node)
            {
                If ($Node.DistinguishedName -notin $This.Host.DistinguishedName)
                {
                    $This.Host    += [AddsHost]::New($Site,$Node)
                }
            }
            NewAccount([Object]$Site,[Object]$Node)
            {
                If ($Node.DistinguishedName -notin $This.Account.DistinguishedName)
                {
                    $This.Account += [AddsAccount]::New($Site,$Node)
                }
            }
            [String] ToString()
            {
                Return "<AddsController>"
            } 
        }
        [AddsController]::New()
    }

    Function VmController
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
            [Object] $VMInstance
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
                $This.VMInstance        = $VM
            }
        }

        Class Select
        {
            [String] $Type
            [String] $Name
            [Bool]   $Create
            Select([Object]$Type,[Object]$Item)
            {
                $This.Type   = $Item.Type
                $This.Name   = $Item.Name
                $This.Create = 1
            }
        }

        Class VmSwitchNode
        {
            [String] $Name
            [String] $ID
            [String] $Type
            [String] $Description
            [UInt32] $Exists
            VmSwitchNode([String]$Name,[String]$Type)
            {
                $This.Name        = $Name
                $This.Type        = $Type
                $This.Exists      = 0
            }
            VmSwitchNode([Object]$Switch)
            {
                $This.Name        = $Switch.Name
                $This.ID          = $Switch.ID
                $This.Type        = $Switch.SwitchType
                $This.Description = @($Switch.NetAdapterInterfaceDescription,"-")[$Switch.NetAdapterInterfaceDescription -ne ""]
                $This.Exists      = 1
            }
            New()
            {
                If (Get-VMSwitch -Name $This.Name)
                {
                    Throw "Switch already exists"
                }

                $Switch           = New-VMSwitch -Name $This.Name -Type $This.Type -Verbose
                
                $This.ID          = $Switch.GUID
                $This.Description = @($Switch.NetAdapterInterfaceDescription,"-")[$Switch.NetAdapterInterfaceDescription -ne ""]
                $This.Exists      = 1
            }
            Remove()
            {
                If (!$This.Exists)
                {
                    Throw "Switch does not exist"
                }

                Get-Switch -Name $This.Name | Remove-VMSwitch -Force -Verbose -Confirm:$False
            }
        }

        Class VmObjectNode
        {
            [Object]         $Item
            [Object]         $Name
            [Double]       $Memory
            [Object]         $Path
            [Object]          $Vhd
            [Double]      $VhdSize
            [Object]   $Generation
            [UInt32]         $Core
            [Object[]] $SwitchName
            [UInt32]       $Exists
            VmObjectNode([Object]$Item,[UInt32]$Memory,[UInt32]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch,[String]$Path)
            {
                $This.Item               = $Item
                $This.Name               = $Item.Name
                $This.Memory             = ([UInt32]$Memory)*1MB
                $This.Path               = "$Path\$($Item.Name)"
                $This.Vhd                = "$Path\$($Item.Name)\$($Item.Name).vhdx"
                $This.VhdSize            = ([UInt32]$HDD)*1GB
                $This.Generation         = $Generation
                $This.Core               = $Core
                $This.SwitchName         = @($Switch)
                $This.Exists             = 0
            }
            VmObjectNode([Object]$VM)
            {
                $This.Name               = $Vm.Name
                $This.Memory             = $Vm.MemoryStartup
                $This.Path               = $Vm.Path
                $This.Vhd                = $Vm.HardDrives[0].Path
                $This.VhdSize            = $This.Vhd | Get-VHD | % Size
                $This.Generation         = $Vm.Generation
                $This.Core               = $Vm.ProcessorCount
                $This.SwitchName         = $Vm.NetworkAdapters.SwitchName
                $This.Exists             = 1
            }
            New()
            {
                If (Get-VM -Name $This.Name)
                {
                    Throw "This VM already exists"
                }

                If (!(Test-Path $This.Path))
                {
                    Throw "Invalid path"
                }

                $Object                = @{

                    Name               = $This.Name
                    MemoryStartupBytes = $This.Memory
                    Path               = $This.Path
                    NewVhdPath         = $This.Vhd
                    NewVhdSizeBytes    = $This.VhdSize
                    Generation         = $This.Generation
                    SwitchName         = $This.SwitchName
                }

                New-VM @Object -Verbose
                $This.Exists           = 1
                Set-VMProcessor -VMName $This.Name -Count $This.Core -Verbose
            }
            Start()
            {
                Get-VM -Name $This.Name | ? State -eq Off | Start-VM -Verbose
            }
            Remove()
            {
                Get-VM -Name $This.Name | Remove-VM -Force -Confirm:$False -Verbose
                $This.Exists           = 0
                Remove-Item $This.Vhd -Force -Verbose -Confirm:$False
                Remove-Item $This.Path -Force -Recurse -Verbose -Confirm:$False
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

        Class VmController
        {
            [String]   $HostName
            [String]     $Status
            [String]   $Username
            [String] $Credential
            [Object]       $Host
            [Object]     $Switch
            [Object]   $Internal
            [Object]   $External
            [Object]   $AddsNode
            [Object]     $VmNode
            [Object]    $VmStack
            VmController([String]$ID)
            {
                $This.Username   = $Env:Username
                $This.Credential = Get-Credential $Env:Username
                $This.GetHost($ID)
            }
            VmController([String]$ID,[PSCredential]$Credential)
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
                    $This.AddsNode = @( )
                    $This.VmNode   = @( )
                    $This.VmStack  = @( )
                }
                If ($This.Status -eq "Running")
                {
                    Write-Host "Loading [~] [Virtual Host: $($This.Hostname)]"
                    $This.Host     = Get-VMHost   -ComputerName $This.Hostname

                    $This.Switch   = @( )
                    ForEach ($Item in Get-VMSwitch -ComputerName $This.Hostname)
                    {
                        Write-Host "Loading [~] [Virtual Switch: $($Item.Name)]"
                        $This.Switch += [VmSwitchNode]::New($Item) 
                    }

                    $This.External = $This.Switch | ? Type -eq External
                    $This.Internal = $This.Switch | ? Type -eq Internal
                    $This.AddsNode = @( )
                    $This.VmNode   = @( )
                    ForEach ($Item in Get-Vm -ComputerName $This.Hostname)
                    {
                        Write-Host "Loading [~] [Virtual Machine: $($Item.Name)]"
                        $This.VmNode += [VmObjectNode]::New($Item)
                    }
                    $This.VmStack  = @( )
                }
            }
            LoadAddsNode([Object]$AddsNode)
            {
                $This.AddsNode += $AddsNode   
            }
            [Object] GetVmObjectNode([String]$Name)
            {
                Return @( $This.VmNode | ? Name -eq $Name )
            }
            AddVmObjectNode([Object]$AddsNode,[UInt32]$Memory,[UInt32]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$SwitchName,[String]$Path)
            {
                $Item = $This.GetVMNode($AddsNode.Name)
                If ($Item)
                {
                    Write-Host "Item [!] Exists [$($Item.Name)]" -F 12
                }
                If (!$Item)
                {
                    $This.VmNode += [VMObjectNode]::New($AddsNode,$Memory,$HDD,$Generation,$Core,$SwitchName,$Path)
                }
            }
            GetVmNodeList()
            {
                $This.VmStack = @( )
                ForEach ($Item in $This.VmNode)
                {
                    If ($Item.Name -in $This.AddsNode.Name)
                    {
                        $ADDS          = $This.AddsNode | ? Name -eq $Item.Name 
                        $Item.Item     = $ADDS.Type
                        $This.VmStack += [Topology]::New($ADDS,$Item)
                    }
                }
            }
            [String] ToString()
            {
                Return "<VmController>"
            }
        }
        If ($Credential)
        {
            [VmController]::New($Hostname,$Credential)
        }
        If (!$Credential)
        {
            [VmController]::New($Hostname)
        }
    }

    Function ImageController
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

        Class ImageController
        {
            [String] $Source
            [String] $Target
            [Object] $Selected
            [Object] $Store
            [Object] $Queue
            [Object] $Swap
            [Object] $Output
            ImageController()
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
            [String] ToString()
            {
                Return '<ImageController>'
            }
        }
        [ImageController]::New()
    }

    Function UpdateController # Heavily modified version of this https://github.com/MicksITBlogs/PowerShell/blob/master/Get-MSUFileInfo.ps1
    {
        Class StringList
        {
            [String] $Name
            [Object] $Value
            StringList([String]$Line)
            {
                $X          = $Line -Split "="
                $This.Name  = $X[0] -Replace " ",""
                $This.Value = $X[1] -Replace '"','' -Split ";" | ? Length -gt 0
            }
        }

        Class UpdateExtract
        {
            Hidden [Object] $File
            [String] $KB
            [Object] $Directory
            [String] $Type
            [Object] $Name 
            Hidden [Object] $ExitCode
            [String] $Expand
            [Object] $Output
            UpdateExtract([String]$File,[String]$Executable,[String]$Parameters)
            {
                $This.File         = Get-Item $File
                $This.KB           = [Regex]::Matches($File,"(kb\d{7})").Value.ToUpper()
                $This.Type         = $This.File.Extension
                $This.Directory    = $This.File.Directory
                $This.Name         = $This.File.Name
                $This.ExitCode     = Start-Process -FilePath $Executable -ArgumentList $Parameters -WindowStyle Hidden -Wait -Passthru | % ExitCode
                $This.Expand       = Get-ChildItem $This.Directory | ? Name -match $This.KB | ? Name -notmatch $This.Name | % FullName
                $This.Output       = Get-Content $This.Expand | % { [StringList]::New($_) }
                Remove-Item $This.Expand -Verbose -EA 0
            }
        }

        Class MsuFile
        {
            [String] $Fullname
            [String] $Name
            [String] $Type
            [Object] $Info
            MsuFile([Object]$File)
            {
                $This.Fullname   = $File.Fullname
                $This.Name       = $File.Name
            }
        }

        Class UpdateController
        {
            [String]     $Expand
            [String]       $Base
            [Object]   $FileList
            [Object] $UpdateList
            UpdateController()
            {
                $This.Expand      = "$Env:Windir\System32\expand.exe"
                $This.UpdateList  = @( )
            }
            SetUpdateBase([String]$Base)
            {
                $This.Base        = $Base
                $This.FileList    = Get-ChildItem $Base -Recurse | ? Extension -match .msu | % { [MsuFile]$_ }
            }
            GetFileInfo([String]$File)
            {
                If (!(Get-Item $File | ? Extension -match .msu))
                {
                    Throw "Not a proper update file"
                }

                $This.UpdateList += [UpdateExtract]::New($File,$This.Expand,$This.Parameters($File))
            }
            [String] Parameters([String]$File)
            {
                Return '-F:*properties.txt "{0}" "{1}"' -f $File, ($File | Split-Path -Parent)
            }
            [Object] ExitCode([String]$File)
            {
                Return Start-Process -FilePath $This.Expand -ArgumentList $This.Parameters($File) -WindowStyle Hidden -Wait -Passthru | % ExitCode
            }
            ProcessFileList()
            {
                ForEach ($File in $This.FileList)
                {
                    Write-Host "Processing [~] ($($File.Name))"
                    $This.GetFileInfo($File.Fullname)
                }
            }
            [String] ToString()
            {
                Return "<UpdateController>"
            }
        }
        [UpdateController]::New()
    }

    Function MdtController
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

        Class MdtController
        {
            [Object]       $Module
            [String]    $MDTModule
            [Object]         $Path
            [Object]        $Drive
            [Object]        $Brand
            [String]        $Admin
            [String]     $Password
            MdtController([Object]$Module)
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
            [String] ToString()
            {
                Return "<MdtController>"
            }
        }
        [MdtController]::New($Module)
    }
    
    Function WdsController
    {
        Class WdsRegItem
        {
            [String] $Name
            [String] $DisplayName
            [String] $Path
            [String] $Property
            [String] $Type
            [Object] $Value
            WdsRegItem([String]$DisplayName,[String]$Path,[String]$Property,[String]$Type,[Object]$Value)
            {
                $This.Name        = $DisplayName -Replace " ",""
                $This.DisplayName = $DisplayName
                $This.Path        = $Path
                $This.Property    = $Property
                $This.Type        = $Type
                $This.Value       = $Value
            }
            [Object] GetProperty()
            {
                If ($This.Path -match "\<\w+\>")
                {
                    $Temp = $This.Path -Replace "<\w+>",""
                    Return @( ForEach ($Item in Get-ChildItem $Temp)
                    {
                        Get-ItemProperty "$Temp\$($Item.Name)" -Property $This.Property
                    })
                }
                Return @( Get-ItemProperty -Path $This.Path -Property $This.Property )
            }
            [String] ToString()
            {
                Return $This.Name
            }
        }

        Class WdsReg # Modified version of https://www.windows-noob.com/forums/topic/617-windows-deployment-services-registry-entries/
        {
            [Object] $Stack
            WdsReg()
            {
                $This.Stack = @(
                
                # Critical Providers
                [WdsRegItem]::New("Critical Providers","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsDcMgr",
                "IsCritical","REG_DWORD",@{0="Not critical";1="Critical"})

                # Client Answer Policy
                # Windows Deployment Services has a global on/off policy that controls whether or not client requests are answered
                [WdsRegItem]::New("Client Answer Requests","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
                "netbootAnswerRequests","REG_SZ",@{$False="Client requests will not be answered";$True="Client requests will be answered"})

                # Client Answer Policy
                # You can configure Windows Deployment Services to answer all incoming PXE requests or only those from prestaged 
                # clients (for example, WDSUTIL /Set-Server /AnswerClients:All). 
                [WdsRegItem]::New("Client Answer Valid Clients","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
                "netbootAnswerOnlyValidClients","REG_SZ",@{$False="All client requests will be answered";$True="Only prestaged clients will be answered"})

                # Logging for the Windows Deployment Services Client
                # The values for logging level are stored in the following keys of the Windows Deployment Services server:
                [WdsRegItem]::New("Client Logging Bool","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging",
                "Enabled","REG_DWORD", @{0="DISABLED";1="ENABLED"})

                # Client Logging
                [WdsRegItem]::New("Client Logging Level","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsImgSrv\ClientLogging",
                "LogLevel","REG_DWORD",@{0="OFF";1="ERRORS";2="WARNINGS";3="INFO"})

                # DHCP Authorization
                # Specifies the amount of time (in seconds) that the PXE server will wait before rechecking its authorization. 
                # This time is only used when a successful authorization process has been performed, irrespective of whether the server was previously authorized.
                [WdsRegItem]::New("DHCP Auth Recheck Time","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "AuthRecheckTime","REG_DWORD",3600)

                # Specifies the amount of time (in seconds) that the PXE server will wait if any step of authorization fails
                [WdsRegItem]::New("DHCP Auth Timeout","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "AuthFailureRetryTime","REG_DWORD",30)

                # Rogue Detection
                [WdsRegItem]::New("Rogue Detection Bool","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "DisableRogueDetection","REG_DWORD",@{0="Enabled";1="Disabled"})

                # DHCP Authorization Cache
                # Whenever the PXE server successfully queries AD DS, the results are cached under HKLM\System\CurrentControlSet\Services\WDSSERVER\Providers\WDSPXE\AuthCache as follows:
                [WdsRegItem]::New("DHCP Authorization Cache","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\AuthCache",
                $Env:UserDnsDomain.ToLower(),"REG_DWORD",@{0="Failed communication with ADDS, server not authorized";1="Successful communication with ADDS, server authorized"})

                # Toggles whether the DHCP server ignores port 67
                [WdsRegItem]::New("Toggle DHCP Port 67","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "UseDHCPPorts","REG_DWORD",@{0="PXE server DOES NOT listen on port 67";1="PXE server DOES listen on port 67"})

                # Architecture Detection
                [WdsRegItem]::New("Architecture Detection","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
                "DisableArchDisc","REG_DWORD",@{0="Architecture discovery ENABLED";1="Architecture discovery is DISABLED"})
        
                # PXE Response Delay
                [WdsRegItem]::New("PXE Response Delay","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
                "ResponseDelay","REG_DWORD",0) # <delay time, in seconds>

                # Banned GUIDs
                # Tells certain GUIDs that they're tentatively banned from going to the WDS's birthday party
                [WdsRegItem]::New("Banned Guids","HKLM:\SYSTEM\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "BannedGuids","REG_MULTI_SZ","{00000000000000000000000000000000}") 

                # Order of PXE Providers
                # A registering provider can select its order in the existing provider list. The provider order is maintained in the registry at the following location:
                [WdsRegItem]::New("PXE Provider Order","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "ProvidersOrder","MULTI_SZ","WDSDCPXE") # Default / Ordered list of providers

                # Registered PXE Providers
                [WdsRegItem]::New("PXE Providers Registered","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\<Custom Provider Name>",
                "ProviderDLL","REG_SZ","%systemroot%\system32\wdspxe.dll") # Default / The full path and file name of the provider .dll

                # Bind Policy for Network Interfaces
                [WdsRegItem]::New("Bind Policy Network Interfaces","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "BindPolicy","REG_DWORD",@{0="Defined bind interfaces EXCLUDED";1="Defined bind interfaces INCLUDED"})

                # BindInterfaces
                [WdsRegItem]::New("Bind Interface List","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe",
                "BindInterfaces","REG_MULTI_SZ",@{-1=$Null;0="Exclude, set BindInterfaces to IP/MAC for interfaces to INCLUDE";1="Include, set BindInterfaces to IP/MAC for interfaces to EXCLUDE"})

                # Location of TFTP Files
                # The TFTP root is the parent folder that contains all files available for download by client computers. 
                # By default, the TFTP root is set to the RemoteInstall folder as specified in the following registry setting:
                [WdsRegItem]::New("TFTP File Path","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsTftp","RootFolder","REG_SZ","C:\RemoteInstall") # Default / <full path and folder name of the TFTP root>

                # Unattended installation
                # This policy is defined in the Windows Deployment Services server registry at the following location:
                [WdsRegItem]::New("Unattend Install Bool","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\WdsImgSrv\Unattend","Enabled","REG_DWORD",@{0="Disabled";1="Enabled"})

                # Per-Architecture Unattend Policy
                # Unattend files are architecture specific, so you need a unique file for each architecture. 
                # These values are stored in the registry at the following location (where <arch> is either x86, x64, or ia64):
                [WdsRegItem]::New("Per Arch Unattend Path","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\WdsImgSrv\Unattend\<arch>","WDSUnattendFilePath","REG_SZ",$Null) 
                # The file path to the Windows Deployment Services client unattend file (for example, D:\RemoteInstall\WDSClientUnattend\WDSClientUnattend.xml)
        
                # Network Boot Programs
                [WdsRegItem]::New("Network Boot Programs:arm", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm", "Default","REG_SZ",$Null)
                [WdsRegItem]::New("Network Boot Programs:ia64","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64","Default","REG_SZ",$Null)
                [WdsRegItem]::New("Network Boot Programs:x64", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64", "Default","REG_SZ",$Null)
                [WdsRegItem]::New("Network Boot Programs:x86", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86", "Default","REG_SZ",$Null)
                # The relative path to the default NBP that all booting clients of this architecture should receive (for example, boot\x86\pxeboot.com)

                # Per-Client NBP
                [WdsRegItem]::New("Relative Client NBP Path:arm", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm", ".n12","REG_SZ",$Null)
                [WdsRegItem]::New("Relative Client NBP Path:ia64","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64",".n12","REG_SZ",$Null)
                [WdsRegItem]::New("Relative Client NBP Path:x64", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64", ".n12","REG_SZ",$Null)
                [WdsRegItem]::New("Relative Client NBP Path:x86", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86", ".n12","REG_SZ",$Null)
                # The relative path to the NBP that will be sent by using the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12)

                # Unknown Clients Automatically PXE Boot
                [WdsRegItem]::New("Unknown Clients Auto PXE Boot","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\","AllowN12ForNewClients","REG_DWORD",@{0="Not Enabled";1="Unknown allowed"})

                # .n12 NBP
                # Windows Deployment Services sends the defined .n12 NBP according to the following registry settings (where <arch> is either x86, x64, or IA64):
                [WdsRegItem]::New("N12 NBP:arm", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\arm", ".n12","REG_SZ",$Null)
                [WdsRegItem]::New("N12 NBP:ia64","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\ia64",".n12","REG_SZ",$Null)
                [WdsRegItem]::New("N12 NBP:x64", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x64", ".n12","REG_SZ",$Null)
                [WdsRegItem]::New("N12 NBP:x86", "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\BootPrograms\x86", ".n12","REG_SZ",$Null)
                # The relative path to the NBP that will be sent according to the AllowN12ForNewClients setting (for example, boot\x86\pxeboot.n12).

                # Resetting the NBP to the Default on the Next Boot
                [WdsRegItem]::New("Reset NBP Default Next Boot","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC","ResetBootProgram","REG_DWORD",@{0="No Action";1="Reset netbootMachineFilePath"})

                # Auto Approval
                [WdsRegItem]::New("Auto Device Approval","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove","Policy","REG_DWORD",@{0="No action";1="Pending"})
                
                # Auto-Add Policy
                [WdsRegItem]::New("Auto Add Policy","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove","PendingMessage","REG_SZ",$Null)

                # Time-Out Value
                # The client state is not maintained on the server. Rather, the Wdsnbp.com program polls the server for the settings in the following keys after it has paused the client’s boot. The values for these settings are sent to the client by the server in the DHCP options field of the DHCP acknowledge control packet (ACK). The default setting for these values is to poll the server every 10 seconds for 2,160 tries, bringing the total default time-out to six hours.
                [WdsRegItem]::New("Time Out Value","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove","PollInterval","REG_DWORD",$Null) 
                # The amount of time (in seconds) between polls of the server

                # Max Retry Count
                [WdsRegItem]::New("Max Retry Count","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove","PollMaxRetry","REG_DWORD",2160)

                # Referral server
                # The name of the Windows Deployment Services server that the client should download the NBP from
                [WdsRegItem]::New("Referral Server:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "ReferralServer","REG_SZ",$Null)
                [WdsRegItem]::New("Referral Server:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "ReferralServer","REG_SZ",$Null)
                [WdsRegItem]::New("Referral Server:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "ReferralServer","REG_SZ",$Null)
                [WdsRegItem]::New("Referral Server:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","ReferralServer","REG_SZ",$Null)
                [WdsRegItem]::New("Referral Server:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "ReferralServer","REG_SZ",$Null)
                [WdsRegItem]::New("Referral Server:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","ReferralServer","REG_SZ",$Null)
                # The name of the server to refer the client to. The default setting is for this value to be blank (no server name).

                # Boot Program Path
                # The name of the NBP that the client should download
                [WdsRegItem]::New("Boot Program Path:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "BootProgramPath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Program Path:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "BootProgramPath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Program Path:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "BootProgramPath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Program Path:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","BootProgramPath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Program Path:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "BootProgramPath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Program Path:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","BootProgramPath","REG_SZ",$Null)

                # Boot Image Path
                # The name of the boot image, which the client should receive. 
                # Setting this value means that the client will not see a boot menu because the specified boot image will be processed automatically
                [WdsRegItem]::New("Boot Image Path:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "BootImagePath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Image Path:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "BootImagePath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Image Path:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "BootImagePath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Image Path:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","BootImagePath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Image Path:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "BootImagePath","REG_SZ",$Null)
                [WdsRegItem]::New("Boot Image Path:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","BootImagePath","REG_SZ",$Null)
                # The name of the boot image that the client should receive. The default setting is for this value to be blank (no boot image).

                # Domain Administrator Account
                # The primary user associated with the generated computer account. This user will be granted JoinRights authorization, as defined later in this section
                [WdsRegItem]::New("Domain Administrator:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "User","REG_SZ","Domain Admins")
                [WdsRegItem]::New("Domain Administrator:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "User","REG_SZ","Domain Admins")
                [WdsRegItem]::New("Domain Administrator:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "User","REG_SZ","Domain Admins")
                [WdsRegItem]::New("Domain Administrator:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","User","REG_SZ","Domain Admins")
                [WdsRegItem]::New("Domain Administrator:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "User","REG_SZ","Domain Admins")
                [WdsRegItem]::New("Domain Administrator:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","User","REG_SZ","Domain Admins")

                # Join Domain
                # Specifies whether or not the device should be joined to the domain
                [WdsRegItem]::New("Join Domain:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                [WdsRegItem]::New("Join Domain:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                [WdsRegItem]::New("Join Domain:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                [WdsRegItem]::New("Join Domain:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                [WdsRegItem]::New("Join Domain:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                [WdsRegItem]::New("Join Domain:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","JoinDomain","REG_DWORD",@{0="Join the domain";1="Do not join the domain"})
                # 0 or not defined means that the computer should be joined to the domain / 1 means that the computer should not be joined to the domain

                # Join Rights
                # JoinOnly requires the administrator to reset the computer account before the user can join the computer to the domain
                # Full gives full permissions to the user (including the right to join the domain)
                [WdsRegItem]::New("Join Rights:arm",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\arm",    "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                [WdsRegItem]::New("Join Rights:ia64",   "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\ia64",   "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                [WdsRegItem]::New("Join Rights:x64",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64",    "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                [WdsRegItem]::New("Join Rights:x64uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x64uefi","JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                [WdsRegItem]::New("Join Rights:x86",    "HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86",    "JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                [WdsRegItem]::New("Join Rights:x86uefi","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC\AutoApprove\x86uefi","JoinRights","REG_DWORD",@{0="Join Only";1="Full"})
                # 0 or not defined means JoinOnly / 1 means Full

                # Default Server
                [WdsRegItem]::New("Default Server","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC","DefaultServer","REG_SZ",$Env:ComputerName)

                # Global Catalog
                [WdsRegItem]::New("Default Global Catalog","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC","DefaultGCServer","REG_SZ",$Env:ComputerName) 
                # The name of the global catalog that Windows Deployment Services should use. This can be either the NETBIOS name or the FQDN.

                # Search Order
                # 1 or not set means that the global catalog will be searched first, and then the domain controller; 
                [WdsRegItem]::New("Active Directory Search Order","HKLM:\System\CurrentControlSet\Services\WDSServer\Providers\WdsPxe\Providers\BINLSVC",
                "ADSearchOrder","REG_SZ",@{0="Search global catalog First";1="Search domain controller first"})
                )
            }
        }

        Class BootImage
        {
            [Object] $Path
            [Object] $Name
            [Object] $Type
            [Object] $Iso
            [Object] $Wim
            [Object] $Xml
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

        Class WdsController
        {
            [Object] $Control
            [String] $Path
            [String] $Server
            [Object] $Images
            WdsController()
            {   
                $This.Control   = [WdsReg]::New().Stack
                $This.Path      = $This.Control | ? DisplayName -eq "TFTP File Path" | % Value
                $This.Server    = @($Env:ComputerName,"$Env:ComputerName.$Env:UserDNSDomain")[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
                $This.Images    = @( )
                Write-Host "Collecting [~] Wds Install Images"
                Get-WdsInstallImage -EA 0 | % { $This.Images += [WdsImage]::New("Install",$_) }
                Write-Host "Collecting [~] Wds Boot Images"
                Get-WdsBootImage    -EA 0 | % { $This.Images += [WdsImage]::New("Boot",$_) }
            }
            ImportWdsImage()
            {

            }
            RemoveWdsImage([String]$Type,[String]$Name)
            {

            }
            [String] ToString()
            {
                Return "<WdsController>"
            }
        }
        [WdsController]::New()
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

    Class XamlWindow
    {
        Hidden [Object]        $XAML
        Hidden [Object]         $XML
        [String[]]            $Names
        [Object[]]            $Types
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
            If (!$Xaml)
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml               = $Xaml
            $This.XML                = [XML]$Xaml
            $This.Names              = $This.FindNames()
            $This.Types              = @( )
            $This.Node               = [System.XML.XmlNodeReader]::New($This.XML)
            $This.IO                 = [System.Windows.Markup.XAMLReader]::Load($This.Node)

            ForEach ($I in 0..($This.Names.Count - 1))
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
                If ($This.IO.$Name)
                {
                    $This.Types    += [DGList]::New($Name,$This.IO.$Name.GetType().Name)
                }
            }

            $This.IO.Dispatcher.Thread.ApartmentState = "MTA"
        }
        Invoke()
        {
            $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
        }
    }

    # Get-Content $Home\Desktop\FEInfrastructure.xaml | % { "        '$_',"} | Set-Clipboard
    Class FEInfrastructureGUI
    {
        Static [String] $Tab = @(        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Infrastructure Deployment System" Width="800" Height="780" Icon=" C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" ResizeMode="NoResize" FontWeight="SemiBold" HorizontalAlignment="Center" WindowStartupLocation="CenterScreen" Topmost="True">',
        '    <Window.Resources>',
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
        '        <Style TargetType="Label">',
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
        '                    <Label Grid.Row="0" Content="[FightingEntropy]://Module Information and Components"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Role and System Information"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Server System Information"/>',
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
        '                                            <CheckBox Name="System_IsVM" Content="VM" IsEnabled="False"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Network Adapter Information"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Dynamic Host Control Protocol"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Domain Name Service"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Active Directory Domain Service"/>',
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
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Veridian"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Windows Deployment Services"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Windows Deployment Services"/>',
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
        '                                <Label Grid.Row="0" Content="[FightingEntropy]://Internet Information Services"/>',
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
        '                                  ScrollViewer.CanContentScroll="True"',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"     Binding="{Binding SiteLink}" Width="120"/>',
        '                                <DataGridTextColumn Header="Location" Binding="{Binding Location}" Width="100"/>',
        '                                <DataGridTextColumn Header="Region"   Binding="{Binding Region}"   Width="60"/>',
        '                                <DataGridTextColumn Header="Country"  Binding="{Binding Country}"  Width="60"/>',
        '                                <DataGridTextColumn Header="Postal"   Binding="{Binding Postal}"   Width="60"/>',
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
        '                                               ScrollViewer.CanContentScroll="True"',
        '                                               ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                               ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
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
        '                                <DataGridTextColumn Header="HostRange" Binding="{Binding HostRange}" Width="100"/>',
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
        '                                <DataGridTextColumn Header="Name"   Binding="{Binding Name}"  Width="150"/>',
        '                                <DataGridTextColumn Header="Value"  Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="4" Header="[NwTopology] - (Output/Existence validation)">',
        '                        <DataGrid Name="NwTopology"',
        '                                  ScrollViewer.CanContentScroll="True"',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"    Binding="{Binding Name}"    Width="150"/>',
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
        '                        <RowDefinition Height="140"/>',
        '                        <RowDefinition Height="140"/>',
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
        '                                <DataGridTextColumn Header="Name"      Binding="{Binding Name}"     Width="125"/>',
        '                                <DataGridTextColumn Header="Location"  Binding="{Binding Location}" Width="150"/>',
        '                                <DataGridTextColumn Header="Sitename"  Binding="{Binding SiteName}" Width="300"/>',
        '                                <DataGridTextColumn Header="Network"   Binding="{Binding Network}"  Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="2">',
        '                        <Grid.ColumnDefinitions>',
        '                            <ColumnDefinition Width="*"/>',
        '                            <ColumnDefinition Width="*"/>',
        '                        </Grid.ColumnDefinitions>',
        '                        <GroupBox Grid.Column="0" Header="[SmSiteLink] - (Select main ISTG trunk)">',
        '                            <DataGrid Name="SmSiteLink">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"               Binding="{Binding Name}"              Width="150"/>',
        '                                    <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </GroupBox>',
        '                        <GroupBox Grid.Column="1" Header="[SmTemplate] - (Create these objects for each site)">',
        '                            <DataGrid Name="SmTemplate">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="150"/>',
        '                                    <DataGridTemplateColumn Header="Create" Width="*">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Create}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="False"/>',
        '                                                    <ComboBoxItem Content="True"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </GroupBox>',
        '                    </Grid>',
        '                    <GroupBox Grid.Row="3" Header="[SmViewer] - (View each sites&apos; properties/attributes)">',
        '                        <DataGrid Name="SmViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="4" Header="[SmTopology] - (Output/Existence Validation)">',
        '                        <DataGrid Name="SmTopology">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="125"/>',
        '                                <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="100"/>',
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
        '            <TabItem Header="Adds">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="80"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="120"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <GroupBox Grid.Column="0" Header="[Name]">',
        '                                <ComboBox Name="AddsSite" ItemsSource="{Binding Name}"/>',
        '                            </GroupBox>',
        '                            <GroupBox Grid.Column="1" Header="[Site]">',
        '                                <TextBox Name="AddsSiteName" IsReadOnly="True"/>',
        '                            </GroupBox>',
        '                            <GroupBox Grid.Column="2" Header="[Subnet]">',
        '                                <TextBox Name="AddsSubnetName" IsReadOnly="True"/>',
        '                            </GroupBox>',
        '                            <Button Name="AddsSiteDefaults" Grid.Column="3" Content="Add All Defaults"/>',
        '                        </Grid>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Control">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[Viewer]">',
        '                                    <DataGrid Name="AddsViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="1" Header="[Children]">',
        '                                    <DataGrid Name="AddsChildren">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Gateway">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[Gateway Name] - (Enter a gateway name)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsGwName"/>',
        '                                            <Button  Grid.Column="1" Name="AddsGwAdd"     Content="+"/>',
        '                                            <Button  Grid.Column="2" Name="AddsGwRemove"  Content="-"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[Gateway List] - (Input a file/list)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="80"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsGwFile"/>',
        '                                            <Button  Grid.Column="1" Name="AddsGwBrowse"  Content="Browse"/>',
        '                                            <Button  Grid.Column="2" Name="AddsGwAddList" Content="+"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="1" Header="[Gateway Aggregate] - (Provision gateway/router items)">',
        '                                    <DataGrid Name="AddsGwAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                            <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Gateway Viewer] - (View a gateways&apos; properties/attributes)">',
        '                                    <DataGrid Name="AddsGwViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="AddsGwGet" Content="Get"/>',
        '                                    <Button Grid.Column="1" Name="AddsGwNew" Content="New"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Server">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[Server Name] - (Enter a server name)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsSrName"/>',
        '                                            <Button  Grid.Column="1" Name="AddsSrAdd"     Content="+"/>',
        '                                            <Button  Grid.Column="2" Name="AddsSrRemove"  Content="-"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[Server List] - (Input a file/list)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="80"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsSrFile"/>',
        '                                            <Button  Grid.Column="1" Name="AddsSrBrowse" Content="Browse"/>',
        '                                            <Button  Grid.Column="2" Name="AddsSrAddList" Content="+"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="1" Header="[Server Aggregate] - (Provision server items)">',
        '                                    <DataGrid Name="AddsSrAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                            <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Server Viewer] - (View each servers&apos; properties/attributes)">',
        '                                    <DataGrid Name="AddsSrViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="AddsSrGet" Content="Get"/>',
        '                                    <Button Grid.Column="1" Name="AddsSrNew" Content="New"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Workstation">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[Workstation Name] - (Enter a workstation name)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsWsName"/>',
        '                                            <Button  Grid.Column="1" Name="AddsWsAdd"     Content="+"/>',
        '                                            <Button  Grid.Column="2" Name="AddsWsRemove"  Content="-"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[Workstation List] - (Input a file/list)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="80"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsWsFile"/>',
        '                                            <Button  Grid.Column="1" Name="AddsWsBrowse" Content="Browse"/>',
        '                                            <Button  Grid.Column="2" Name="AddsWsAddList" Content="+"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="1" Header="[Workstation Aggregate] - (Provision workstation items)">',
        '                                    <DataGrid Name="AddsWsAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                            <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Workstation Viewer] - (View each servers&apos; properties/attributes)">',
        '                                    <DataGrid Name="AddsWsViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="AddsWsGet" Content="Get"/>',
        '                                    <Button Grid.Column="1" Name="AddsWsNew" Content="New"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="User">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[User Name] - (Enter a user name)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsUserName"/>',
        '                                            <Button  Grid.Column="1" Name="AddsUserAdd"     Content="+"/>',
        '                                            <Button  Grid.Column="2" Name="AddsUserRemove"  Content="-"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[User List] - (Input a file/list)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="80"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsUserFile"/>',
        '                                            <Button  Grid.Column="1" Name="AddsUserBrowse" Content="Browse"/>',
        '                                            <Button  Grid.Column="2" Name="AddsUserAddList" Content="+"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="1" Header="[User Aggregate] - (Provision user items)">',
        '                                    <DataGrid Name="AddsUserAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                            <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[User Viewer] - (View each servers&apos; properties/attributes)">',
        '                                    <DataGrid Name="AddsUserViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="AddsUserGet" Content="Get"/>',
        '                                    <Button Grid.Column="1" Name="AddsUserNew" Content="New"/>',
        '                                </Grid>',
        '                            </Grid>    ',
        '                        </TabItem>',
        '                        <TabItem Header="Service">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="90"/>',
        '                                    <RowDefinition Height="200"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Column="0" Header="[Service Name] - (Enter a user name)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsSvcName"/>',
        '                                            <Button  Grid.Column="1" Name="AddsSvcAdd"     Content="+"/>',
        '                                            <Button  Grid.Column="2" Name="AddsSvcRemove"  Content="-"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Column="1" Header="[Service List] - (Input a file/list)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="80"/>',
        '                                                <ColumnDefinition Width="40"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <TextBox Grid.Column="0" Name="AddsSvcFile"/>',
        '                                            <Button  Grid.Column="1" Name="AddsSvcBrowse" Content="Browse"/>',
        '                                            <Button  Grid.Column="2" Name="AddsSvcAddList" Content="+"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                                <GroupBox Grid.Row="1" Header="[Service Aggregate] - (Provision user items)">',
        '                                    <DataGrid Name="AddsSvcAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                            <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <GroupBox Grid.Row="2" Header="[Service Viewer] - (View each servers&apos; properties/attributes)">',
        '                                    <DataGrid Name="AddsSvcViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </GroupBox>',
        '                                <Grid Grid.Row="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Button Grid.Column="0" Name="AddsSvcGet" Content="Get"/>',
        '                                    <Button Grid.Column="1" Name="AddsSvcNew" Content="New"/>',
        '                                </Grid>',
        '                            </Grid> ',
        '                        </TabItem>',
        '                    </TabControl>',
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
        '                        <TabItem Header="Switch">',
        '                            <GroupBox Grid.Row="0" Header="[VmSwitch] - (Provision virtual switches)">',
        '                                <DataGrid Grid.Row="0" Name="VmSwitch">',
        '                                    <DataGrid.Columns>',
        '                                        <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                        <DataGridTemplateColumn Header="Exists" Width="100">',
        '                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                <DataTemplate>',
        '                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                        <ComboBoxItem Content="False"/>',
        '                                                        <ComboBoxItem Content="True"/>',
        '                                                    </ComboBox>',
        '                                                </DataTemplate>',
        '                                            </DataGridTemplateColumn.CellTemplate>',
        '                                        </DataGridTemplateColumn>',
        '                                    </DataGrid.Columns>',
        '                                </DataGrid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Gateway">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="270"/>',
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
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Header="[VmGatewayPath] - (Path to the VMX/VHD files)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmGatewayPathSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmGatewayPath"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="0" Header="[VmGatewayScript] - (Script to install gateway item)" IsEnabled="False">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmGatewayScriptSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmGatewayScript"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="1" Header="[(RAM/MB)]">',
        '                                        <TextBox Name="VmGatewayMemory"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="0" Header="[VmGatewayImage] - (Image to install gateway item)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmGatewayImageSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmGatewayImage"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="1" Header="[(HDD/GB)]">',
        '                                        <TextBox Name="VmGatewayDrive"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Server">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="270"/>',
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
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Header="[VmServerPath] - (Path to the VMX/VHD files)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmServerPathSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmServerPath"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="0" Header="[VmServerScript] - (Script to install virtual servers)" IsEnabled="False">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmServerScriptSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmServerScript"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="1" Header="[(RAM/MB)]">',
        '                                        <TextBox Name="VmServerMemory"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="0" Header="[VmServerImage] - (Image to install virtual servers)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmServerImageSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmServerImage"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="1" Header="[(HDD/GB)]">',
        '                                        <TextBox Name="VmServerDrive"/>',
        '                                    </GroupBox>',
        '                                </Grid>',
        '                            </Grid>',
        '                        </TabItem>',
        '                        <TabItem Header="Workstation">',
        '                            <Grid>',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="270"/>',
        '                                </Grid.RowDefinitions>',
        '                                <GroupBox Grid.Row="0" Header="[VmWorkstation] - (Provision physical/virtual machine workstations)">',
        '                                    <DataGrid  Name="VmWorkstation">',
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
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <GroupBox Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Header="[VmWorkstationPath] - (Path to the VMX/VHD files)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmWorkstationPathSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmWorkstationPath"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="0" Header="[VmWorkstationScript] - (Script to install virtual servers)" IsEnabled="False">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmWorkstationScriptSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmWorkstationScript"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="1" Grid.Column="1" Header="[(RAM/MB)]">',
        '                                        <TextBox Name="VmWorkstationMemory"/>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="0" Header="[VmWorkstationImage] - (Image to install virtual servers)">',
        '                                        <Grid>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="VmWorkstationImageSelect" Content="Select"/>',
        '                                            <TextBox Grid.Column="1" Name="VmWorkstationImage"/>',
        '                                        </Grid>',
        '                                    </GroupBox>',
        '                                    <GroupBox Grid.Row="2" Grid.Column="1" Header="[(HDD/GB)]">',
        '                                        <TextBox Name="VmWorkstationDrive"/>',
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
        '                    <GroupBox Grid.Row="2" Header="[UpdViewer] - (View properties/attributes of update files)">',
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
        '                    <GroupBox Grid.Row="1" Header="[DsDriveInfo] - (FileSystem Path), (PSDrive Name), (Legacy MDT/PSD), (Samba/SMB Share), (Description)">',
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
        '                                <Label   Grid.Column="0" Content="[Root]:" HorizontalContentAlignment="Right"/>',
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
        '                                <Label    Grid.Column="0" Content="[Drive]:" HorizontalContentAlignment="Right"/>',
        '                                <TextBox  Grid.Column="1"  Name="DsDriveName"/>',
        '                                <Label    Grid.Column="2" Content="[Share]:" HorizontalContentAlignment="Right"/>',
        '                                <TextBox  Grid.Column="3" Name="DsShareName"/>',
        '                                <Label    Grid.Column="4" Content="[Type]:" HorizontalContentAlignment="Right"/>',
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
        '                                <Label    Grid.Column="0" Content="[Description]:" HorizontalContentAlignment="Right"/>',
        '                                <TextBox  Grid.Column="1" Name="DsDescription"/>',
        '                                <Button Grid.Column="2" Name="DsAddShare" Content="Add"/>',
        '                                <Button Grid.Column="3" Name="DsRemoveShare" Content="Remove"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <GroupBox Grid.Row="2" Header="[DsShareConfig]" Name="DsShareConfig">',
        '                        <TabControl>',
        '                            <TabItem Header="Import OS/TS">',
        '                                <GroupBox Grid.Row="0" Header="[DsWimFiles] - (Selected Wim Files)">',
        '                                    <Grid Height="215" VerticalAlignment="Top">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="160"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid Grid.Row="0">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button   Grid.Row="0" Grid.Column="0" Name="DsSelectWimFilePath" Content="Select"/>',
        '                                            <TextBox  Grid.Row="0" Grid.Column="1" Name="DsWimFilePath"/>',
        '                                            <ComboBox Grid.Row="0" Grid.Column="2" Name="DsWimFileMode"/>',
        '                                        </Grid>',
        '                                        <DataGrid Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" Name="DsWimFiles"',
        '                                                  ScrollViewer.CanContentScroll="True" ',
        '                                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                            <DataGrid.Columns>',
        '                                                <DataGridTextColumn Header="Rank"        Binding="{Binding Rank}"             Width="30"/>',
        '                                                <DataGridTextColumn Header="Label"       Binding="{Binding Label}"            Width="100"/>',
        '                                                <DataGridTextColumn Header="Name"        Binding="{Binding ImageName}"        Width="250"/>',
        '                                                <DataGridTextColumn Header="Description" Binding="{Binding ImageDescription}" Width="200"/>',
        '                                                <DataGridTextColumn Header="Version"     Binding="{Binding Version}"          Width="100"/>',
        '                                                <DataGridTextColumn Header="Arch"        Binding="{Binding Architecture}"     Width="30"/>',
        '                                                <DataGridTextColumn Header="Type"        Binding="{Binding InstallationType}" Width="50"/>',
        '                                                <DataGridTextColumn Header="Path"        Binding="{Binding SourceImagePath}"  Width="Auto"/>',
        '                                            </DataGrid.Columns>',
        '                                        </DataGrid>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                            </TabItem>',
        '                            <TabItem Header="Domain/Network">',
        '                                <GroupBox Header="[Domain/Network]">',
        '                                    <Grid VerticalAlignment="Top">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="225"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <!-- Row 0 -->',
        '                                        <Label Grid.Row="0" Grid.Column="0" Content="[Username]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Name="DsDcUsername"/>',
        '                                        <Label Grid.Row="0" Grid.Column="2" Content="[Password]:" HorizontalContentAlignment="Right"/>',
        '                                        <PasswordBox Grid.Row="0" Grid.Column="3" Name="DsDcPassword" HorizontalContentAlignment="Left"/>',
        '                                        <!-- Row 1 -->',
        '                                        <Button Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Name="DsLogin" Content="Login"/>',
        '                                        <Label Grid.Row="1" Grid.Column="2" Content="[Confirm]:" HorizontalContentAlignment="Right"/>',
        '                                        <PasswordBox Grid.Row="1" Grid.Column="3" Name="DsDcConfirm"  HorizontalContentAlignment="Left"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="0" Content="[NetBios]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="DsNetBiosName"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="2" Content="[Dns]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="3" Name="DsDnsName"/>',
        '                                        <Label   Grid.Row="3" Grid.Column="0" Content="[Organization]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3" Name="DsOrganization"/>',
        '                                        <Label   Grid.Row="4" Grid.Column="0" Content="[MachineOu]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3" Name="DsMachineOu"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
        '                            </TabItem>',
        '                            <TabItem Header="Local/Branding">',
        '                                <GroupBox Header="[Local/Branding]">',
        '                                    <Grid>',
        '                                        <Grid.Resources>',
        '                                            <Style TargetType="Label">',
        '                                                <Setter Property="HorizontalAlignment" Value="Left"/>',
        '                                                <Setter Property="VerticalAlignment"   Value="Center"/>',
        '                                            </Style>',
        '                                        </Grid.Resources>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="225"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <!-- Row 0 -->',
        '                                        <Label       Grid.Row="0" Grid.Column="0" Content="[Username]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox     Grid.Row="0" Grid.Column="1" Name="DsLmUsername"/>',
        '                                        <Label       Grid.Row="0" Grid.Column="2" Content="[Password]:" HorizontalContentAlignment="Right"/>',
        '                                        <PasswordBox Grid.Row="0" Grid.Column="3" Name="DsLmPassword" HorizontalContentAlignment="Left"/>',
        '                                        <!-- Row 1 -->',
        '                                        <Button      Grid.Row="1" Grid.RowSpan="2" Grid.Column="0" Name="DsBrCollect" Content="Collect"/>',
        '                                        <Grid Grid.Row="1" Grid.Column="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="2*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Label Grid.Column="0" Content="[Phone]:" HorizontalContentAlignment="Right"/>',
        '                                            <TextBox Grid.Column="1" Name="DsBrPhone"/>',
        '                                        </Grid>',
        '                                        <Label       Grid.Row="1" Grid.Column="2" Content="[Confirm]:" HorizontalContentAlignment="Right"/>',
        '                                        <PasswordBox Grid.Row="1" Grid.Column="3" Name="DsLmConfirm"  HorizontalContentAlignment="Left"/>',
        '                                        <!-- Row 2 -->',
        '                                        <Grid Grid.Row="2" Grid.Column="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="2*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Label Grid.Column="0" Content="[Hours]:"/>',
        '                                            <TextBox Grid.Column="1" Name="DsBrHours"/>',
        '                                        </Grid>',
        '                                        <Label    Grid.Row="2" Grid.Column="2" Content="[Website]:" HorizontalContentAlignment="Right"/>',
        '                                        <TextBox  Grid.Row="2" Grid.Column="3" Name="DsBrWebsite"/>',
        '                                        <!-- Row 3/4 -->',
        '                                        <Button   Grid.Row="3" Grid.Column="0" Name="DsBrLogoSelect" Content="Logo"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3" Name="DsBrLogo"/>',
        '                                        <Button   Grid.Row="4" Grid.Column="0" Name="DsBrBackgroundSelect" Content="Background"/>',
        '                                        <TextBox  Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3" Name="DsBrBackground"/>',
        '                                    </Grid>',
        '                                </GroupBox>',
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

    Class Main
    {
        [Object]            $Module
        [Object]        $Connection
        [String]      $Organization
        [String]        $CommonName
        [Object]        $Credential
        Static [String]       $Base = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
        Static [String]        $GFX = ("{0}\Graphics"    -f [Main]::Base)
        Static [String]       $Icon = ("{0}\icon.ico"    -f [Main]::GFX)
        Static [String]       $Logo = ("{0}\OEMLogo.bmp" -f [Main]::GFX)
        Static [String] $Background = ("{0}\OEMbg.jpg"   -f [Main]::GFX)
        [Object]            $System
        [Object]            $Config
        [Object]          $SiteList
        [Object]       $NetworkList
        [Object]           $Sitemap
        [Object]    $AddsController
        [Object]      $VmController
        [Object]   $ImageController
        [Object]  $UpdateController
        [Object]     $MdtController
        [Object]     $WdsController
        Main()
        {
            $This.Module          = Get-FEModule
            $This.Connection      = Get-FEADLogin
            If (!$This.Connection)
            {
                Write-Error "Could not log into server"
                Break
            }
            $This.Credential      = $This.Connection.Credential

            # Pulls system information
            $This.Module.Role.GetSystem()

            # Assigns system information to system variable
            $This.System            = $This.Module.Role.System

            # Pulls configuration information (Network/DHCP/DNS/ADDS/Hyper-V/WDS/MDT/WinADK/WinPE/IIS)
            $This.Config            = Config -Module $This.Module

            # Pulls sitelist base and classes
            $This.SiteList          = Sitelist -Module $This.Module

            # Pulls networklist base and classes
            $This.NetworkList       = NetworkList

            # Load and sort/rename module files
            ForEach ($Item in $This.Module.Tree.Name)
            {
                $This.Module.$Item  = @( $This.Module.$Item | % { [ModuleFile]$_ })
            }

            # Domain Controller
            $This.Sitemap           = Sitemap

            # AD Controller
            $This.AddsController    = AddsController

            # VM Controller
            If ($This.Config.HyperV)
            {
                $This.VmController  = VmController -Hostname localhost -Credential $This.Credential
            }

            # Imaging Controller
            $This.ImageController   = ImageController

            # Update Controller
            $This.UpdateController  = UpdateController

            # Mdt Controller
            $This.MdtController     = MdtController -Module $This.Module

            # Wds Controller
            $This.WdsController     = WdsController
        }
        SetNetwork([Object]$Xaml,[UInt32]$Index)
        {
            If ($Xaml.System.Network.Count -eq 1)
            {
                $IPInfo                                       = $This.Module.Role.System.Network
            }
            Else
            {
                $IPInfo                                       = $This.Module.Role.System.Network[$Index]
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
        [String] GetHostname()
        {
            Return @{0=$Env:ComputerName;1="$Env:ComputerName.$Env:UserDNSDomain"}[[Int32](Get-CimInstance Win32_ComputerSystem | % PartOfDomain)].ToLower()
        }
        SetDomain([String]$Organization,[String]$CommonName)
        {
            $This.Organization = $Organization
            $This.CommonName   = $CommonName
            $This.Sitelist     | % SetDomain $Organization $CommonName
            $This.NetworkList  | % SetDomain $Organization $CommonName
            $This.Sitemap      | % SetDomain $Organization $CommonName
        }
        [Object] List([String]$Name,[Object]$Value)
        {
            Return [DGList]::New($Name,$Value)
        }
    }

    $Main = [Main]::New()
    $Xaml = [XamlWindow][FEInfrastructureGUI]::Tab

    # ---------------- #
    # <![Module Tab]!> #
    # ---------------- #

    # [Module.Information]
    $Xaml.IO.Module_Info.ItemsSource    = @( )
    $Xaml.IO.Module_Info.ItemsSource    = @( ForEach ( $Item in "Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status" -Split " ")
    {
        $Name = Switch ($Item)
        {
            Default { $Item               }
            Date    { "Installation Date" }
            RegPath { "Registry Path"     }
            ModPath { "Module File"       }
            ManPath { "Manifest File"     }
            Path    { "Module Path"       }
            Status  { "Module Status"     }
        }
        [DGList]::New($Name,$Main.Module.$Item)
    })

    # [Module.Components]
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

    # ---------------- #
    # <![Config Tab]!> #
    # ---------------- #

    # [Config.Output]
    $Xaml.IO.CfgServices.ItemsSource                  = @( )
    $Xaml.IO.CfgServices.ItemsSource                  = @($Main.Config.Output)

    # [Config.Role]
    $Xaml.IO.Role_Info.ItemsSource = @( )
    $Xaml.IO.Role_Info.ItemsSource = @( ForEach ( $Item in "Name DNS NetBIOS Hostname Username IsAdmin Caption Version Build ReleaseID Code SKU Chassis" -Split " ")
    {
        [DGList]::New($Item,$Main.Module.Role.$Item)
    })

    # [Config.System]
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
        
    # [Config.System.Processor]
    $Xaml.IO.System_Processor.ItemsSource             = @( )
    $Xaml.IO.System_Processor.ItemsSource             = @($Main.System.Processor.Name)
    $Xaml.IO.System_Processor.SelectedIndex           = 0
    
    $Xaml.IO.System_Architecture.ItemsSource          = @( )
    $Xaml.IO.System_Architecture.ItemsSource          = @("x86","x64")
    $Xaml.IO.System_Architecture.SelectedIndex        = $Main.System.Architecture -eq "x64"
    $Xaml.IO.System_Architecture.IsEnabled            = 0
    
    # [Config.System.Chassis]
    $Xaml.IO.System_IsVM.IsChecked                    = 0
    $Xaml.IO.System_Chassis.ItemsSource               = @( )
    $Xaml.IO.System_Chassis.ItemsSource               = @("Desktop;Laptop;Small Form Factor;Server;Tablet" -Split ";")
    $Xaml.IO.System_Chassis.SelectedIndex             = @{Desktop=0;Laptop=1;"Small Form Factor"=2;Server=3;Tablet=4}[$Main.System.Chassis]
    $Xaml.IO.System_Chassis.IsEnabled                 = 0
    
    $Xaml.IO.System_BiosUefi.ItemsSource              = @( )
    $Xaml.IO.System_BiosUefi.ItemsSource              = @("BIOS","UEFI")
    $Xaml.IO.System_BiosUefi.SelectedIndex            = $Main.System.BiosUEFI -eq "UEFI"
    $Xaml.IO.System_BiosUefi.IsEnabled                = 0
    
    $Xaml.IO.System_Name.Text                         = $Main.GetHostname()
    
    # [Config.System.Disks]
    $Xaml.IO.System_Disk.ItemsSource                  = @( )
    $Xaml.IO.System_Disk.ItemsSource                  = @($Main.System.Disk)

    # [Config.Network]
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

    # [Config.Dhcp]
    $Xaml.IO.CfgDhcpScopeID.ItemsSource                = @( )
    $Xaml.IO.CfgDhcpScopeReservations.ItemsSource      = @( )
    $Xaml.IO.CfgDhcpScopeOptions.ItemsSource           = @( )
    $Xaml.IO.CfgDhcpScopeID.ItemsSource                = @($Main.Config.Dhcp)
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

    # [Config.Dns]
    $Xaml.IO.CfgDnsZone.ItemsSource              = @( )
    $Xaml.IO.CfgDnsZoneHosts.ItemsSource         = @( )
    $Xaml.IO.CfgDnsZone.ItemsSource              = @( $Main.Config.Dns )
    $Xaml.IO.CfgDnsZone.Add_SelectionChanged(
    {
        If ($Xaml.IO.CfgDnsZone.SelectedIndex -ne -1)
        {
            $Zone = $Xaml.IO.CfgDnsZone.SelectedItem

            $Xaml.IO.CfgDnsZoneHosts.ItemsSource = @( )
            $Xaml.IO.CfgDnsZoneHosts.ItemsSource = @( $Zone.Hosts )
        }
    })

    # [Config.Adds]
    $Xaml.IO.Adds_Hostname.Text         = $Main.Config.Adds.Hostname
    $Xaml.IO.Adds_Hostname.IsReadOnly   = 1

    $Xaml.IO.Adds_DCMode.Text           = $Main.Config.Adds.DCMode
    $Xaml.IO.Adds_DCMode.IsreadOnly     = 1
    
    $Xaml.IO.Adds_DomainMode.Text       = $Main.Config.Adds.DomainMode
    $Xaml.IO.Adds_DomainMode.IsReadOnly = 1

    $Xaml.IO.Adds_ForestMode.Text       = $Main.Config.Adds.ForestMode
    $Xaml.IO.Adds_ForestMode.IsReadOnly = 1

    $Xaml.IO.Adds_Root.Text             = $Main.Config.Adds.Root
    $Xaml.IO.Adds_Root.IsReadOnly       = 1

    $Xaml.IO.Adds_Config.Text           = $Main.Config.Adds.Config
    $Xaml.IO.Adds_Config.IsReadOnly     = 1

    $Xaml.IO.Adds_Schema.Text           = $Main.Config.Adds.Schema
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
        $Xaml.IO.CfgAddsObject.ItemsSource = @( $Main.Config.Adds."$($Xaml.IO.CfgAddsType.SelectedItem)" )
    })

    $Xaml.IO.CfgAddsFilter.Add_TextChanged(
    {
        Start-Sleep -Milliseconds 50
        $Xaml.IO.CfgAddsObject.ItemsSource = @( )
        $Xaml.IO.CfgAddsObject.ItemsSource = @( $Main.Config.Adds."$($Xaml.IO.CfgAddsType.SelectedItem)" | ? $Xaml.IO.CfgAddsProperty.SelectedItem -match $Xaml.IO.CfgAddsFilter.Text )
    })

    # [Config.HyperV]
    $Xaml.IO.CfgHyperV.ItemsSource        = @( )

    If ($Main.Config.HyperV)
    {
        $Xaml.IO.VmHost.Text                  = $Main.HyperV.Name
        $Xaml.IO.CfgHyperV.ItemsSource        = @($Main.Config.HyperV)
    }

    # [Config.Wds]
    $Xaml.IO.WDS_Server.Text              = $Main.Config.WDS.Server
    $Xaml.IO.WDS_IPAddress.ItemsSource    = @( )
    $Xaml.IO.WDS_IPAddress.ItemsSource    = @($Main.Config.WDS.IPAddress)
    $Xaml.IO.WDS_IPAddress.SelectedIndex  = 0

    # [Config.Mdt]
    $Xaml.IO.MDT_Server.Text              = $Main.Config.MDT.Server
    $Xaml.IO.MDT_IPAddress.ItemsSource    = @( )
    $Xaml.IO.MDT_IPAddress.ItemsSource    = @($Main.Config.MDT.IPAddress)
    $Xaml.IO.MDT_IPAddress.SelectedIndex  = 0
    
    $Xaml.IO.MDT_Path.Text                = $Main.Config.MDT.Path
    $Xaml.IO.MDT_Version.Text             = $Main.Config.MDT.Version
    $Xaml.IO.MDT_ADK_Version.Text         = $Main.Config.MDT.AdkVersion
    $Xaml.IO.MDT_PE_Version.Text          = $Main.Config.MDT.PeVersion

    # [Config.IIS]
    $Xaml.IO.IIS_AppPools.ItemsSource     = @( )
    $Xaml.IO.IIS_AppPools.ItemsSource     = @($Main.Config.IIS.AppPools)

    $Xaml.IO.IIS_Sites.ItemsSource        = @( )
    $Xaml.IO.IIS_Sites.ItemsSource        = @($Main.Config.IIS.Sites)

    # ------------------------- #
    # <![Domain/SiteList Tab]!> #
    # ------------------------- #

    $Xaml.IO.DcAggregate.ItemsSource    = @( )
    $Xaml.IO.DcViewer.ItemsSource       = @( )
    $Xaml.IO.DcTopology.ItemsSource     = @( )

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
        {
            $Main.SetDomain($Xaml.IO.DcOrganization.Text,$Xaml.IO.DcCommonName.Text)
            $Main.Sitelist.AddSite($Main.Sitelist.GetLocation().Postal)
            $Xaml.IO.DcAggregate.ItemsSource   = @( )
            $Xaml.IO.DcAggregate.ItemsSource   = @($Main.Sitelist.Aggregate)
            $Xaml.IO.DcGetSitename.IsEnabled   = 0
            $Xaml.IO.NwScopeLoad.IsEnabled     = 1
        }
    })

    $Xaml.IO.DcAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.DcAggregate.SelectedItem
        $Xaml.IO.DcViewer.ItemsSource          = @( )
        If ($Object)
        {
            $Xaml.IO.DcViewer.ItemsSource      = @($Object.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    })    

    $Xaml.IO.DcAddSitename.Add_Click(
    {
        $Object = $Main.Sitelist.Zipstack.Zip($Xaml.IO.DcAddSitenameZip.Text)

        If ($Object.Type -match "Invalid")
        {
            Return [System.Windows.MessageBox]::Show("Not a valid zip code","Error")
        }
        ElseIf ($Object.Zip -in $Main.Sitelist.Aggregate.Postal)
        {
            Return [System.Windows.MessageBox]::Show("That entry already exists","Error")
        }

        Else
        {
            $Main.Sitelist.AddSite($Object.Zip)
            $Xaml.IO.DcAggregate.ItemsSource  = @( )
            $Xaml.IO.DcAggregate.ItemsSource  = @($Main.Sitelist.Aggregate)
            $Xaml.IO.DcAddSitenameZip.Text    = ""
        }
    })

    $Xaml.IO.DcRemoveSitename.Add_Click(
    {
        If ($Xaml.IO.DcAggregate.SelectedIndex -gt -1)
        {
            $Object                           = $Xaml.IO.DcAggregate.SelectedItem
            $Main.Sitelist.Aggregate          = $Main.Sitelist.Aggregate | ? Postal -ne $Object.Postal 
            $Xaml.IO.DcAggregate.ItemsSource  = @( )
            $Xaml.IO.DcAggregate.ItemsSource  = @($Main.Sitelist.Aggregate)
            If ($Xaml.IO.DcViewer.ItemsSource | ? Name -eq Postal | ? Value -eq $Object.Postal)
            {
                $Xaml.IO.DcViewer.ItemsSource = @( )
            }
        }
    })

    $Xaml.IO.DcGetTopology.Add_Click(
    {
        $Main.Sitelist.GetSiteList()
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @($Main.Sitelist.Topology)
        $Xaml.IO.SmSiteCount.Text         = $Main.Sitelist.Topology.Count
    })
    
    $Xaml.IO.DcNewTopology.Add_Click(
    {
        $Main.Sitelist.NewSiteList()
        $Xaml.IO.DcTopology.ItemsSource   = @( )
        $Xaml.IO.DcTopology.ItemsSource   = @($Main.Sitelist.Topology)
        $Xaml.IO.SmSiteCount.Text         = $Main.Sitelist.Topology.Count
    })

    # ----------------------------- #
    # <![Network/NetworkList Tab]!> #
    # ----------------------------- #

    $Xaml.IO.NwAggregate.ItemsSource    = @( )
    $Xaml.IO.NwViewer.ItemsSource       = @( )
    $Xaml.IO.NwTopology.ItemsSource     = @( )

    $Xaml.IO.NwScopeLoad.Add_Click(
    {
        If ($Xaml.IO.NwScope.Text -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            Return [System.Windows.MessageBox]::Show("Invalid/null network string (Use 'IP/Prefix' notation)","Error")
        }

        Else
        {
            $Main.NetworkList.AddNetwork($Xaml.IO.NwScope.Text)
            $Xaml.IO.NwScope.Text              = ""
            $Xaml.IO.NwAggregate.ItemsSource   = @( )
            $Xaml.IO.NwViewer.ItemsSource      = @( )
            $Xaml.IO.NwAggregate.ItemsSource   = @($Main.NetworkList.Aggregate)
        }
    })

    $Xaml.IO.NwAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.NwAggregate.SelectedItem
        $Xaml.IO.NwViewer.ItemsSource          = @( )
        If ($Object)
        {
            $Xaml.IO.NwViewer.ItemsSource      = @($Object.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) })
        }
    })

    $Xaml.IO.NwAddSubnetName.Add_Click(
    {
        $Object = $Xaml.IO.NwSubnetName.Text
        If ($Object -notmatch "((\d+\.+){3}\d+\/\d+)")
        {
            Return [System.Windows.MessageBox]::Show("Invalid subnet provided","Error")
        }
        ElseIf ($Object -in $Main.NetworkList.Aggregate.Name)
        {
            Return [System.Windows.MessageBox]::Show("Prefix already exists","Error")
        }
        Else
        {
            $Main.NetworkList.AddSubnet($Object)
            $Xaml.IO.NwSubnetName.Text       = ""
            $Xaml.IO.NwAggregate.ItemsSource = @( )
            $Xaml.IO.NwAggregate.ItemsSource = @($Main.NetworkList.Aggregate)
        }
    })

    $Xaml.IO.NwRemoveSubnetName.Add_Click(
    {
        If ($Xaml.IO.NwAggregate.SelectedIndex -gt -1)
        {
            $Object                           = $Xaml.IO.NwAggregate.SelectedItem
            $Main.NetworkList.Aggregate       = $Main.NetworkList.Aggregate | ? Name -ne $Object.Name
            $Xaml.IO.NwAggregate.ItemsSource  = @( )
            $Xaml.IO.NwAggregate.ItemsSource  = @($Main.NetworkList.Aggregate)
            If ($Xaml.IO.NwViewer.ItemsSource | ? Name -eq Name | ? Value -eq $Object.Name)
            {
                $Xaml.IO.DcViewer.ItemsSource = @( )
            }
        }

        Else
        {
            Return [System.Windows.MessageBox]::Show("Select a subnet within the dialog box","Error")
        }
    })

    $Xaml.IO.NwGetSubnetName.Add_Click(
    {
        $Main.NetworkList.GetNetworkList()       
        $Xaml.IO.NwTopology.ItemsSource   = @( )
        $Xaml.IO.NwTopology.ItemsSource   = @($Main.NetworkList.Topology)
        $Xaml.IO.SmNetworkCount.Text      = $Main.NetworkList.Topology.Count
    })

    $Xaml.IO.NwNewSubnetName.Add_Click(
    {
        $Main.NetworkList.NewNetworkList()
        $Xaml.IO.NwTopology.ItemsSource   = @( )
        $Xaml.IO.NwTopology.ItemsSource   = @($Main.NetworkList.Topology)
        $Xaml.IO.SmNetworkCount.Text      = $Main.NetworkList.Topology.Count
    })

    # ----------------- #
    # <![Sitemap Tab]!> #
    # ----------------- #

    $Xaml.IO.SmTemplate.ItemsSource        = @( )
    $Xaml.IO.SmAggregate.ItemsSource       = @( )
    $Xaml.IO.SmSiteLink.ItemsSource        = @( )
    $Xaml.IO.SmTopology.ItemsSource        = @( )

    $Xaml.IO.AddsViewer.ItemsSource        = @( )
    $Xaml.IO.AddsChildren.ItemsSource      = @( )

    $Xaml.IO.AddsGwAggregate.ItemsSource   = @( )
    $Xaml.IO.AddsGwViewer.ItemsSource      = @( )
    $Xaml.IO.AddsGwTopology.ItemsSource    = @( )

    $Xaml.IO.AddsSrAggregate.ItemsSource   = @( )
    $Xaml.IO.AddsSrViewer.ItemsSource      = @( )
    $Xaml.IO.AddsSrTopology.ItemsSource    = @( )

    $Xaml.IO.AddsWsAggregate.ItemsSource   = @( )
    $Xaml.IO.AddsWsViewer.ItemsSource      = @( )
    $Xaml.IO.AddsWsTopology.ItemsSource    = @( )

    $Xaml.IO.AddsUserAggregate.ItemsSource = @( )
    $Xaml.IO.AddsUserViewer.ItemsSource    = @( )
    $Xaml.IO.AddsUserTopology.ItemsSource  = @( )

    $Xaml.IO.AddsSvcAggregate.ItemsSource  = @( )
    $Xaml.IO.AddsSvcViewer.ItemsSource     = @( )
    $Xaml.IO.AddsSvcTopology.ItemsSource   = @( )

    $Xaml.IO.SmLoadSitemap.Add_Click(
    {
        If ($Main.NetworkList.Topology.Count -lt $Main.SiteList.Topology.Count)
        {
            Return [System.Windows.MessageBox]::Show("Insufficient networks","Error: Network count")
        }
    
        Else
        {
            $Main.Sitemap                    | % LoadSiteList    $Main.Sitelist.Aggregate
            $Main.Sitemap                    | % LoadNetworkList $Main.NetworkList.Aggregate
            $Main.Sitemap                    | % LoadSitemap
            $Main.Sitemap                    | % GetSitelinkList

            $Xaml.IO.SmAggregate.ItemsSource = @( )
            $Xaml.IO.SmAggregate.ItemsSource = @($Main.Sitemap.Aggregate)

            $Xaml.IO.SmSiteLink.ItemsSource  = @( )
            $Xaml.IO.SmSiteLink.ItemsSource  = @($Main.Sitemap.Sitelink)

            If ($Xaml.IO.SmAggregate.Items.Count -gt 0)
            {
                $Xaml.IO.SmTemplate.ItemsSource = @($Main.Sitemap.Template.Output)
            }
        }
    })

    $Xaml.IO.SmAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.SmAggregate.SelectedItem
        $Xaml.IO.SmViewer.ItemsSource          = @( )
        If ($Object)
        {
            $Xaml.IO.SmViewer.ItemsSource      = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
        }
    })

    $Xaml.IO.SmGetSitemap.Add_Click(
    {
        $Main.Sitemap.GetSitemap()       
        $Xaml.IO.SmTopology.ItemsSource   = @( )
        $Xaml.IO.SmTopology.ItemsSource   = @($Main.Sitemap.Topology)
    })

    $Xaml.IO.SmNewSitemap.Add_Click(
    {
        If ($Xaml.IO.SmSiteLink.SelectedIndex -eq -1)
        {
            Return [System.Windows.MessageBox]::Show("Must select a master site link","Error")
        }

        Else
        {
            $Main.Sitemap.SetSitelinkBridge($Xaml.IO.SmSiteLink.SelectedItem.DistinguishedName)
            $Main.Sitemap.NewSitemap()
            $Main.AddsController.LoadSitemap($Main.Sitemap.Aggregate)
            $Xaml.IO.AddsSite.ItemsSource   = @( )
            $Xaml.IO.AddsSite.ItemsSource   = @($Main.AddsController.Sitemap.Name)
            $Xaml.IO.AddsSite.SelectedIndex = 0
        }
    })

    # -------------- #
    # <![Adds Tab]!> #
    # -------------- #

    # AddsSite                  ComboBox
    # AddsSiteName              TextBox
    # AddsSubnetName            TextBox
    # AddsViewer                DataGrid
    # AddsChildren              DataGrid

    $Xaml.IO.AddsSite.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSite.SelectedIndex -ne -1)
        {
            $Object                                = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]

            # Site TextBox
            Write-Host "Site [+] Textbox"
            $Xaml.IO.AddsSiteName.Text             = $Object.Template.Site.Name
            
            # Subnet TextBox
            Write-Host "Subnet [+] Textbox"
            $Xaml.IO.AddsSubnetName.Text           = $Object.Template.Subnet.Name

            # Viewer
            Write-Host "Viewer [+] ItemsSource"
            $Xaml.IO.AddsViewer.ItemsSource        = @($Object.Control.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })

            # Children
            Write-Host "Site [+] Children"
            $Xaml.IO.AddsChildren.ItemsSource      = @($Object.Main.Children)

            $Main.AddsController.GetNodeList()

            # Gateway
            If ($Main.AddsController.Gateway.Count -gt 0)
            {
                $Xaml.IO.AddsGwAggregate.ItemsSource   = @($Main.AddsController.Gateway)
            }

            # Server
            If ($Main.AddsController.Server.Count -gt 0)
            {
                $Xaml.IO.AddsSrAggregate.ItemsSource   = @($Main.AddsController.Server)
            }

            # Workstation
            If ($Main.AddsController.Workstation.Count -gt 0)
            {
                $Xaml.IO.AddsWsAggregate.ItemsSource   = @($Main.AddsController.Workstation)
            }

            # User
            If ($Main.AddsController.UserAggregate.Count -gt 0)
            {
                $Xaml.IO.AddsUserAggregate.ItemsSource = @($Main.AddsController.User)
            }

            # Service
            If ($Main.AddsController.SvcAggregate.Count -gt 0)
            {
                $Xaml.IO.AddsSvcAggregate.ItemsSource  = @($Main.AddsController.Service)
            }
        }
    })

    $Xaml.IO.AddsGwAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Xaml.IO.AddsGwName.Text
        If (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in @($Null,""))
        {
            Return [System.Windows.MessageBox]::Show("Must provide a name for the gateway to add")
        }

        ElseIf ($Name -in $Xaml.IO.AddsGwAggregate.ItemsSource.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"Gateway",$Name)
            $Main.AddsController.GetGatewayList()
            $Xaml.IO.AddsGwAggregate.ItemsSource   = @( )
            $Xaml.IO.AddsGwAggregate.ItemsSource   = @($Main.AddsController.Gateway)
        }
    })

    $Xaml.IO.AddsGwDefault.Add_Click(
    {
        $Object                                    = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                                      = $Object.Name

        If ($Name -notin $Main.AddsController.Gateway)
        {
            $Main.AddsController.AddNode($Object.Name,"Gateway",$Name)
            $Main.AddsController.GetGatewayList()
            $Xaml.IO.AddsGwAggregate.ItemsSource   = @( )
            $Xaml.IO.AddsGwAggregate.ItemsSource   = @($Main.AddsController.Gateway)
        }
        If ($Name -in $Main.AddsController.Gateway)
        {
            Return [System.Windows.MessageBox]::Show("Default item already added","Error")
        }
    })

    $Xaml.IO.AddsGwRemove.Add_Click(
    {
        $Xaml.IO.AddsGwAggregate.ItemsSource = @( )
        If ($Xaml.IO.AddsGwAggregate.SelectedIndex -ne -1)
        {
            $Object                              = $Xaml.IO.AddsGwAggregate.SelectedItem
            If ($Object)
            {
                $Main.AddsController.RemoveNode($Object.DistinguishedName)
                $Main.AddsController.GetGatewayList()
                $Xaml.IO.AddsGwAggregate.ItemsSource   = @( )
                $Xaml.IO.AddsGwAggregate.ItemsSource   = @($Main.AddsController.Gateway)
            }
        }
    })

    $Xaml.IO.AddsGwBrowse.Add_Click(
    {
        $Item                  = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory = $Env:SystemDrive
        $Item.Filter           = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename     = ""
        }

        $Xaml.IO.AddsGwFile.Text = $Item.FileName
    })

    $Xaml.IO.AddsGwAddList.Add_Click(
    {
        $Xaml.IO.AddsGwAggregate.ItemsSource   = @( )
        ForEach ($Item in Get-Content $Xaml.IO.AddsGwFile.Text)
        {
            If ($Item -notin $Main.AddsController.Gateway)
            {
                $Main.AddsController.AddNode($Object.Name,"Gateway",$Name)
            }
        }
        $Main.AddsController.GetGatewayList()
        $Xaml.IO.AddsGwAggregate.ItemsSource   = @($Main.AddsController.Gateway)
    })

    $Xaml.IO.AddsGwAggregate.Add_SelectionChanged(
    {
        $Object                                = $Main.AddsController.GetNode($Xaml.IO.AddsGwAggregate.SelectedItem.DistinguishedName)
        $Xaml.IO.AddsGwViewer.ItemsSource      = @( )
        If ($Object)
        {
            $Xaml.IO.AddsGwViewer.ItemsSource  = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
        }
    })

    $Xaml.IO.AddsGwGet.Add_Click(
    {
        $Xaml.IO.AddsGwTopology.ItemsSource    = @( )
        $Main.AddsController.GetGatewayList()
        ForEach ($Object in $Main.AddsController.Gateway)
        {
            If (Get-ADObject -LDAPFilter "(objectClass=Computer)" -SearchBase $Object.Parent)
            {
                $Object.Exists = 1
            }
            Else
            {
                New-ADComputer -Name $Item.Name -DNSHostName $DNSName -Path $Path -TrustedForDelegation:$True -Verbose
            }
        }
    })

    # AddsGwAdd                 Button
    # AddsGwName                TextBox
    # AddsGwRemove              Button
    # AddsGwAggregate           DataGrid
    # AddsGwViewer              DataGrid
    # AddsGwTopology            DataGrid
    # AddsGwGet                 Button
    # AddsGwNew                 Button

    # $Xaml.Invoke()
    Return @{ Xaml = $Xaml; Main = $Main }
}

<#

Add-Type -AssemblyName PresentationFramework
. $Home\Desktop\New-FEInfrastructure2.ps1
$Cap = New-FEInfrastructure2

$Xaml = $Cap.Xaml
$Main = $Cap.Main

$Main.SetDomain("Secure Digits Plus LLC","securedigitsplus.com")
$Xaml.IO.DcOrganization.Text = $Main.Organization
$Xaml.IO.DcCommonName.Text   = $Main.CommonName
$Main.Sitelist.AddSite(12019)
$Main.Sitelist.AddSite(12020)
$Main.Sitelist.GetSitelist()
$Main.Sitelist.NewSitelist()
$Xaml.IO.DcAggregate.ItemsSource = @($Main.Sitelist.Aggregate)
$Xaml.IO.DcTopology.ItemsSource  = @(@Main.Sitelist.Topology)

$Main.NetworkList.AddNetwork("172.16.0.0/19")
$Main.NetworkList.RemoveSubnet("172.16.0.0/19")
$Main.NetworkList.GetNetworkList()
$Main.NetworkList.NewNetworkList()
$Xaml.IO.NwAggregate.ItemsSource = @($Main.NetworkList.Aggregate)
$Xaml.IO.NwTopology.ItemsSource  = @($Main.NetworkList.Topology)

$Main.Sitemap.LoadSitelist($Main.Sitelist.Aggregate)
$Main.Sitemap.LoadNetworkList($Main.NetworkList.Aggregate)
$Main.Sitemap.GetSitelinkList()
$Main.Sitemap.SetSiteLinkBridge($Main.Sitemap.Sitelink[0].DistinguishedName)
$Main.Sitemap.LoadSitemap()
$Main.Sitemap.GetSitemap()
$Main.Sitemap.NewSitemap()
$Xaml.IO.SmAggregate.ItemsSource = @($Main.Sitemap.Aggregate)
$Xaml.IO.SmTopology.ItemsSource  = @($Main.Sitemap.Topology)

#>

   <# -------------- #
    # <![Adds Tab]!> #
    # -------------- #
    
    $Xaml.IO.AddsSitename.

    $Main.Gateway                     = $Main.Sitelist | ? Name -eq Gateway
    $Main.Server                      = $Main.Sitelist | ? Name -eq Server

    $Xaml.IO.GwAggregate.ItemsSource  = $Main.Gateway
    $Xaml.IO.SrAggregate.ItemsSource  = $Main.Server


# [Gateway]
ForEach ($Site in $Main.Sitemap.Aggregate)
{
    $Main.AddsController.AddAddsNode("Gateway",$Site.Name,$Site)
}

# [Server]
ForEach ($Site in $Main.Sitemap.Aggregate)
{
    $Main.AddsController.AddAddsNode("Server","dc1-$($Site.Postal)",$Site)
}

# [Send AddsController nodes to VmController]
ForEach ($Item in $Main.AddsController.Object)
{
    $Main.VmController.LoadAddsNode($Item)
}

# Populate VMController VMStack
$Main.VmController.GetVMNodeList()

$Main.UpdateController.SetBase("C:\Updates")
$Main.UpdateController.ProcessFileList()
$Main.UpdateController.UpdateList #>
