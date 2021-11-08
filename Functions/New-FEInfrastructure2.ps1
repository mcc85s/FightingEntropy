<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: New-FEInfrastructure2.ps1
          Solution: FightingEntropy Module
          Purpose: For managing the configuration AND distribution of ADDS nodes, virtual hive clusters, MDT/WDS shares, and sewing it all together like a friggen badass... 
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-11-08
          
          Version - 2021.10.0 - () - Still revising from version 1.

          TODO: VM tab, MDT, WDS

.Example
#>
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
                $This.DistinguishedName = @("OU=$Type,OU=$Name,$Root","OU=$Name,$Root")[$Type -eq "Main"]
                $This.Type              = Switch($Type)
                {
                    Default   { $Type         }
                    Computers { "Workstation" }
                    Users     { "User"        }
                }
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

        Class AddsOutput
        {
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            [Object] $User
            [Object] $Service
            AddsOutput()
            {
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
                $This.User        = @( )
                $This.Service     = @( )
            }
            Remove([String]$Type,[String]$Name)
            {
                Switch -Regex ($Type)
                {
                    "(Gateway|Server|Workstation)"
                    {
                        $This.$Type = $This.$Type | ? Hostname -ne $Name
                    }
                    "(User|Service)"
                    {
                        $This.$Type = $This.$Type | ? Name -ne $Name
                    }
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
            [String] $Type
            [String] $Hostname
            [String] $DnsName
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [Object] $Computer
            [String] $Guid
            AddsHost([Object]$Site,[Object]$Node)
            {
                $This.Organization      = $Site.Organization
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
                $This.Type              = $Node.Type
                $This.Hostname          = $Node.Name
                $This.DnsName           = ("{0}.{1}" -f $Node.Name, $Site.CommonName)
                $This.Parent            = $Node.Parent
                $This.DistinguishedName = $Node.DistinguishedName
                $This.Exists            = $Node.Exists
            }
            [Object] Get()
            {
                Return @( Try { Get-ADComputer -Identity $This.DistinguishedName -Property * } Catch { } )
            }
            [String] LocationString()
            {
                Return ("{0}, {1} {2} [{3}]" -f $This.Location, $This.Region, $This.Postal, $This.Sitelink)
            }
            New()
            {
                If (!$This.Get())
                {
                    New-ADComputer -Name $This.HostName -Location $This.LocationString() -DNSHostName $This.DNSName -Path $This.Parent -TrustedForDelegation:$True -Verbose
                }

                $This.Exists            = 1
                $This.Update()
            }
            Remove()
            {
                If ($This.Get())
                {
                    Remove-ADComputer -Identity $This.DistinguishedName -Verbose -Confirm:$False
                }

                $This.Exists            = 0
                $This.Computer          = $Null
                $This.Guid              = $Null
            }
            Update()
            {
                If ($This.Get())
                {
                    $This.Computer      = $This.Get()
                    $This.Guid          = $This.Computer.ObjectGuid
                }
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
            [String] $Name
            [String] $Type
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [Object] $Account
            [String] $SamName
            [String] $UserPrincipalName
            [String] $Guid
            AddsAccount([Object]$Site,[Object]$Node)
            {
                $This.Organization      = $Site.Organization
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
            [Object] Get()
            {
                Return @( Try { Get-ADUser -Identity $This.DistinguishedName -Property * } Catch { } )
            }
            [String] LocationString()
            {
                Return ("{0}, {1} {2} [{3}]" -f $This.Location, $This.Region, $This.Postal, $This.Sitelink)
            }
            [String] UserPrincipalNameString()
            {
                Return ("{0}@{1}" -f $This.Name, $This.CommonName)
            }
            New()
            {
                If (!$This.Get())
                {
                    @{ 
                        Name                 = $This.Name
                        City                 = $This.Location
                        Company              = $This.Organization
                        Country              = $This.Country
                        Organization         = $This.Organization
                        Path                 = $This.Parent
                        PostalCode           = $This.Postal
                        State                = $This.Region
                        TrustedForDelegation = $True
                        UserPrincipalName    = $This.UserPrincipalNameString()

                    } | % { New-ADUser @_ -Verbose }
                }

                $This.Exists                 = 1
                $This.Update()
            }
            Remove()
            {
                If ($This.Get())
                {
                    Remove-ADUser -Identity $This.DistinguishedName -Verbose -Confirm:$False
                }

                $This.Exists                = 0
                $This.Account               = $Null
                $This.SamName               = $Null
                $This.UserPrincipalName     = $Null
                $This.Guid                  = $Null
            }
            Update()
            {
                If ($This.Get())
                {
                    $This.Account           = $This.Get()
                    $This.SamName           = $This.Account.SamAccountName
                    $This.UserPrincipalName = $This.Account.UserPrincipalName
                    $This.Guid              = $This.Account.ObjectGuid
                }
            }
        }

        Class AddsNode
        {
            Hidden [String] $Site
            [String] $Name
            [String] $Type
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            AddsNode([String]$Site,[Object]$Name,[Object]$Type,[String]$Base)
            {
                $This.Site              = $Site
                $This.Name              = $Name
                $This.Type              = $Type
                $This.Parent            = $Base
                $This.DistinguishedName = "CN=$Name,$Base"
            }
            [String] ToString()
            {
                Return $This.Name
            }
        }

        Class AddsContainer
        {
            Hidden [String] $Site
            [String] $Name
            [String] $Type
            [String] $Parent
            [String] $DistinguishedName
            [UInt32] $Exists
            [Object] $Children
            AddsContainer([String]$Site,[Object]$Template)
            {
                $This.Site              = $Site
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
                    $This.Children += [AddsContainer]::New($This.Site,$Container)
                }         
            }
            [Object] NewNode([String]$Name)
            {
                Return [AddsNode]::New($This.Site,$Name,$This.Type,$This.DistinguishedName)
            }
            AddNode([Object]$Object)
            {
                If ($Object.Name -notin $This.Children.Name)
                {
                    $This.Children += $Object
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
                $This.Main        = [AddsContainer]::New($Control.Name,$Control.Template.Children[0])
                ForEach ($Item in $This.Template.Children[1..5])
                {
                    $This.Main.AddContainer($Item)
                }
                $This.Gateway     = $This.Main.Children[0]
                $This.Server      = $This.Main.Children[1]
                $This.Workstation = $This.Main.Children[2]
                $This.User        = $This.Main.Children[3]
                $This.Service     = $This.Main.Children[4]
            }
            [Object] GetContainer([String]$Name)
            {
                Return $This.$($Name)
            }
        }

        Class AddsController
        {
            [String] $Organization
            [String] $CommonName
            [Object] $Object
            [Object] $Sitemap
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            [Object] $User
            [Object] $Service
            [Object] $Output
            AddsController()
            {
                $This.Object      = Get-ADObject -Filter * | ? ObjectClass -match "(Computer|User)"
                $This.Sitemap     = @( )
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
                $This.User        = @( )
                $This.Service     = @( )
                $This.Output      = [AddsOutput]::New()
            }
            SetDomain([String]$Organization,[String]$CommonName)
            {
                $This.Organization = $Organization
                $This.CommonName   = $CommonName
            }
            [String] SearchBase()
            {
                Return (($This.CommonName.Split(".") | % { "DC=$_"} ) -join ',')
            }
            LoadSitemap([Object[]]$Sitemap)
            {
                $This.Sitemap     = @($Sitemap | % { [AddsSite]::New($_) })
            }
            [Object] GetSite([String]$Site)
            {
                Return $This.Sitemap | ? Name -eq $Site
            }
            Validate([Object]$Node)
            {
                If ($Node.DistinguishedName -in $This.Object.Distinguishedname)
                {
                    $Node.Exists = 1
                }
                If ($Node.Type -eq "Server")
                {
                    $Parent                     = "OU=Domain Controllers,{0}" -f $This.SearchBase()
                    $DN                         = "CN={0},$Parent" -f $Node.Name
                    If ($DN -in $This.Object.DistinguishedName)
                    {
                        $Node.Type              = "Domain Controller"
                        $Node.Parent            = $Parent
                        $Node.DistinguishedName = $DN
                        $Node.Exists            = 1
                    }
                }
            }
            GetGatewayList()
            {
                $This.Gateway = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Gateway)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Gateway += $Child
                        }
                    }
                }
            }
            GetServerList()
            {
                $This.Server = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Server)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Server += $Child
                        }
                    }
                }
            }
            GetWorkstationList()
            {
                $This.Workstation = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Workstation)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Workstation += $Child
                        }
                    }
                }
            }
            GetUserList()
            {
                $This.User = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.User)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.User += $Child
                        }
                    }
                }
            }
            GetServiceList()
            {
                $This.Service = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Service)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            $This.Service += $Child
                        }
                    }
                }
            }
            GetNodeList()
            {
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
                $This.User        = @( )
                $This.Service     = @( )
                ForEach ($Site in $This.Sitemap)
                {
                    ForEach ($Container in $Site.Gateway, $Site.Server, $Site.Workstation, $Site.User, $Site.Service)
                    {
                        ForEach ($Child in $Container.Children)
                        {
                            Switch -Regex ($Child.Type)
                            {
                                "(Gateway)"                  { $This.Gateway     += $Child }
                                "(Server|Domain Controller)" { $This.Server      += $Child }
                                "(Workstation)"              { $This.Workstation += $Child }
                                "(User)"                     { $This.User        += $Child }
                                "(Service)"                  { $This.Service     += $Child }
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
                    $Item  = $Container.NewNode($Name)
                    $This.Validate($Item)
                    $Container.AddNode($Item)
                }
            }
            RemoveNode([Object]$Object)
            {
                $Container = $Null
                Switch([UInt32]($Object.DistinguishedName -match "Domain Controllers"))
                {
                    0
                    {
                        $Sitename  = ($Object.DistinguishedName.Split(",") | ? { $_ -match "OU\=" })[-1] -Replace "OU=",""
                        $Site      = $This.GetSite($SiteName)
                        $Container = $This.GetContainer($Object.Type)
                    }
                    1
                    {
                        $Sitename  = $This.Sitemap | ? Name -match $Object.Name.Split("-")[1] | % Name
                        $Site      = $This.GetSite($Sitename)
                        $Container = $This.GetContainer("Server")
                    }
                }

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
                Switch ($Type)
                {
                    Default             { $Type         }
                    "Computers"         { "Workstation" }
                    "Users"             { "User"        }
                    "Domain Controller" { "Server"      }
                }
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
            GetOutput([String]$Type)
            {
                ForEach ($Node in $This.$Type)
                {
                    $Site = $This.Sitemap | ? Name -eq $Node.Site | % Control
                    Switch -Regex ($Type)
                    {
                        Gateway
                        {
                            $This.Output.Gateway     += [AddsHost]::New($Site,$Node)
                        }
                        Server
                        {
                            $This.Output.Server      += [AddsHost]::New($Site,$Node)
                        }
                        Workstation
                        {
                            $This.Output.Workstation += [AddsHost]::New($Site,$Node)
                        }
                        User
                        {
                            $This.Output.User        += [AddsAccount]::New($Site,$Node)
                        }
                        Service
                        {
                            $This.Output.Service     += [AddsAccount]::New($Site,$Node)
                        }
                    }
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

        Class VmTopology
        {
            [String] $Organization
            [String] $CommonName
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
            [String] $Type
            [String] $Hostname
            [String] $DnsName
            [String] $AddsParent
            [String] $AddsDistinguishedName
            [UInt32] $AddsExists
            [Object] $AddsComputer
            [String] $AddsGuid
            Hidden [Object] $Vm
            [String] $VmName
            [Double] $VmMemory
            [String] $VmPath
            [String] $VmVhd
            [Double] $VmVhdSize
            [UInt32] $VmGeneration
            [UInt32] $VmCore
            [Object[]] $VmSwitchName
            [UInt32] $VmExists
            [String] $VmGuid
            VmTopology([Object]$Node)
            {
                $This.Organization          = $Node.Organization
                $This.CommonName            = $Node.CommonName
                $This.Location              = $Node.Location
                $This.Region                = $Node.Region
                $This.Country               = $Node.Country
                $This.Postal                = $Node.Postal
                $This.Sitelink              = $Node.Sitelink
                $This.Sitename              = $Node.Sitename
                $This.Network               = $Node.Network
                $This.Prefix                = $Node.Prefix
                $This.Netmask               = $Node.Netmask
                $This.Start                 = $Node.Start
                $This.End                   = $Node.End
                $This.Range                 = $Node.Range
                $This.Broadcast             = $Node.Broadcast
                $This.ReverseDNS            = $Node.ReverseDNS
                $This.Type                  = $Node.Type
                $This.Hostname              = $Node.Hostname
                $This.DnsName               = $Node.DnsName
                $This.AddsParent            = $Node.Parent
                $This.AddsDistinguishedName = $Node.DistinguishedName
                $This.AddsExists            = $Node.Exists
                $This.AddsComputer          = $Node.Computer
                $This.AddsGuid              = $Node.Guid
            }
            LoadVmObject([Object]$Vm)
            {
                $This.Vm                    = $Vm
                $This.VmName                = $Vm.Name
                $This.VmMemory              = $Vm.Memory
                $This.VmPath                = $Vm.Path
                $This.VmVhd                 = $Vm.Vhd
                $This.VmVhdSize             = $Vm.VhdSize
                $This.VmGeneration          = $Vm.Generation
                $This.VmCore                = $Vm.Core
                $This.VmSwitchName          = $Vm.SwitchName
                $This.VmExists              = $Vm.Exists
                $This.VmGuid                = $Vm.Guid
            }
            New()
            {
                If (!$This.Vm.Get())
                {
                    $This.VM.New()
                    $This.LoadVmObject($This.Vm.Get())
                }
            }
            Remove()
            {
                If ($This.Vm.Get())
                {
                    $This.Vm.Remove()
                    $This.Update()
                }
            }
            Update()
            {
                $VmObj = $This.Vm.Get()
                If ($VmObj)
                {
                    $VmObj.Update()
                    $This.LoadVmObject($VmObj)
                }
                If (!$VmObj)
                {
                    $This.VmMemory          = 0
                    $This.VmPath            = $Null
                    $This.VmVhd             = $Null
                    $This.VmVhdSize         = 0
                    $This.VmGeneration      = $Null
                    $This.VmCore            = 0
                    $This.VmSwitchName      = @( )
                    $This.VmExists          = 0
                    $This.VmGuid            = $Null
                }
            }
            [String] ToString()
            {
                Return $This.DnsName
            }
        }

        Class VmQuery
        {
            [String] $Hostname
            [String] $Type
            [String] $DnsName
            VmQuery([String]$Type,[Object]$Object)
            {
                $This.Hostname = $Object.Hostname
                $This.Type     = $Type
                $This.DnsName  = $Object.DnsName
            }
        }

        Class VmAddsContainer
        {
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            [Object] $Query
            VmAddsContainer()
            {
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
                $This.Query       = @( )
            }
            LoadAddsTree([Object]$AddsInput)
            {
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
                $This.Query       = @( )

                ForEach ($Object in $AddsInput.Gateway)
                {
                    $Item              = [VmTopology]::New($Object)
                    $This.Query       += [VmQuery]::New("Gateway",$Item)
                    $This.Gateway     += $Item
                }

                ForEach ($Object in $AddsInput.Server)
                {
                    $Item              = [VmTopology]::New($Object)
                    $This.Query       += [VmQuery]::New("Server",$Item)
                    $This.Server      += $Item
                }

                ForEach ($Object in $AddsInput.Workstation) 
                {
                    $Item              = [VmTopology]::New($Object)
                    $This.Query       += [VmQuery]::New("Workstation",$Item)
                    $This.Workstation += $Item
                }
            }
        }

        Class VmCreate
        {
            [Object] $Switch
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            VmCreate()
            {
                $This.Gateway     = @( )
                $This.Switch      = @( )
                $This.Server      = @( )
                $This.Workstation = @( )
            }
        }

        Class VmSelect
        {
            [String] $Type
            [String] $Name
            [Bool]   $Exists
            [Bool]   $Create
            VmSelect([Object]$Object)
            {
                $This.Type   = $Object.Type
                $This.Name   = $Object.HostName
                $This.Exists = $Object.VmExists
                $This.Create = @(1,0)[$Object.VmExists]
            }
        }

        Class VmControl
        {
            [String] $Name
            [String] $Status
            [String] $Username
            [Object] $Credential
            VmControl([String]$Name,[String]$Status,[String]$Username,[Object]$Credential)
            {
                $This.Name       = $Name
                $This.Status     = $Status
                $This.Username   = $Username
                $This.Credential = $Credential
            }
            [String] ToString()
            {
                Return ("{0}/{1}/{2}" -f $This.Name, $This.Status, $This.Username)
            }
        }

        Class VmSwitchNode
        {
            Hidden [Object] $Switch
            [String] $Name
            [String] $ID
            [String] $Type
            [String] $Description
            [UInt32] $Exists
            VmSwitchNode([String]$Name,[String]$Type)
            {
                $This.Switch      = $Null
                $This.Name        = $Name
                $This.Type        = $Type
                $This.Exists      = 0
            }
            VmSwitchNode([Object]$VMSwitch)
            {
                $This.Switch      = $VMSwitch
                $This.Name        = $VMSwitch.Name
                $This.ID          = $VMSwitch.ID.Guid
                $This.Type        = $VMSwitch.SwitchType
                $This.Description = @($VMSwitch.NetAdapterInterfaceDescription,"-")[$VMSwitch.NetAdapterInterfaceDescription -ne ""]
                $This.Exists      = 1
            }
            [Object] Get()
            {
                Return @( Try { Get-VmSwitch -Name $This.Name } Catch { } )
            }
            New()
            {
                If ($This.Get())
                {
                    Throw "Switch already exists"
                }

                $This.Switch      = New-VMSwitch -Name $This.Name -SwitchType $This.Type -Verbose
                $This.ID          = $This.Switch.GUID
                $This.Description = @($This.Switch.NetAdapterInterfaceDescription,"-")[$This.Switch.NetAdapterInterfaceDescription -ne ""]
                $This.Exists      = 1
            }
            Remove()
            {
                $Sw = $This.Get()
                If (!$Sw)
                {
                    Throw "Switch does not exist"
                }

                If ($Sw)
                {
                    $Sw | Remove-VMSwitch -Force -Verbose -Confirm:$False
                }
            }
            Update()
            {
                $Sw = $This.Get()
                If (!$Sw)
                {
                    $This.VmSwitchNode([String]$This.Name,[String]$This.Type)
                }
                If ($Sw)
                {
                    $This.VmSwitchNode([Object]$Sw)
                }
            }
            [String] ToString()
            {
                Return $This.Name
            }
        }

        Class VmSwitchReservation
        {
            Hidden [Object]       $Site
            Hidden [Object]     $Switch
            [String]        $SwitchName
            [String]          $Sitename
            [String]           $ScopeID
            [String]         $IPAddress
            [String]        $MacAddress
            [String]              $Name
            [String]       $Description
            [UInt32]      $SwitchExists
            [UInt32]            $Exists
            VmSwitchReservation([Object]$Site,[Object]$Switch)
            {
                $This.Site         = $Site
                $This.Switch       = $Switch
                $This.SwitchName   = $This.Switch.Name
                $This.Sitename     = $This.Site.Sitename
                $This.ScopeID      = ""
                $This.IPAddress    = ""
                $This.MacAddress   = ""
                $This.Name         = $This.Site.Sitelink
                $This.Description  = $This.GetDescription()
                $This.SwitchExists = $This.Switch.Exists
                $This.Exists       = 0
            }
            VmSwitchReservation([Object]$Site,[Object]$VMSwitch,[Object]$Reservation)
            {
                $This.Site         = $Site
                $This.Switch       = $VMSwitch
                $This.SwitchName   = $This.Switch.Name
                $This.Sitename     = $This.Site.Sitename
                $This.ScopeID      = $Reservation.ScopeID
                $This.IPAddress    = $Reservation.IPAddress
                $This.MacAddress   = $Reservation.ClientID
                $This.Name         = $Reservation.Name
                $This.Description  = $This.GetDescription()
                $This.SwitchExists = $This.Switch.Exists
                $This.Exists       = If (!$This.Get()) { 0 } Else { 1 }
            }
            [String] GetDescription()
            {
                Return ("[{0}/{1}]@[{2}]" -f $This.Site.Network, $This.Site.Prefix, $This.Site.Sitename)
            }
            [Object] Get()
            {
                Return @( Try { Get-DhcpServerV4Reservation -ScopeID $This.ScopeID | ? Description -eq $This.Description  } Catch { } )
            }
            Remove()
            {
                $Sw = $This.Switch.Get()
                If ($Sw)
                {
                    $This.Switch.Remove()
                    $This.Switch.ID          = $Null
                    $This.Switch.Exists      = 0
                    $This.SwitchExists       = 0
                    $This.Switch.Description = $Null
                    $This.Get() | Remove-DhcpServerV4Reservation -Verbose 
                    $This.Exists             = 0
                }
            }
            New()
            {
                $Sw = $This.Switch.Get()
                If (!$Sw)
                {
                    $This.Switch.New()
                    $Sw                      = $This.Switch.Get()
                    $This.Switch.ID          = $Sw.ID.GUID
                    $This.Switch.Exists      = 1
                    $This.SwitchExists       = 1
                    $This.Description        = $This.GetDescription()
                    If (!$This.Get())
                    {
                        $This.Exists         = 0
                    }
                }
            }
            Add()
            {
                If (!$This.Get())
                {
                    @{
                        ScopeID              = $This.ScopeID
                        IPAddress            = $This.IPAddress
                        ClientID             = $This.MacAddress
                        Name                 = $This.Site.SiteLink
                        Description          = $This.GetDescription()
                    }                        | % { Add-DhcpServerV4Reservation @_ -Verbose }
                }
            }
            SetMacAddress([String]$MacAddress)
            {
                $This.MacAddress             = $MacAddress
            }
        }

        Class VmDhcpReservation
        {
            [UInt32] $Index
            [String] $IPAddress
            [String] $ScopeID
            [String] $ClientID
            [String] $Name
            [String] $Description
            [UInt32]   $Exists
            VmDhcpReservation([UInt32]$Index,[String]$ScopeID,[String]$IPAddress)
            {
                $This.Index       = $Index
                $This.IPAddress   = $IPAddress
                $This.ScopeID     = $ScopeID
                $This.ClientID    = "-"
                $This.Name        = "-"
                $This.Description = "-"
                $This.Exists      = 0
            }
            InsertReservation([Object]$Reservation)
            {
                $This.IPAddress   = $Reservation.IPAddress
                $This.ClientID    = $Reservation.ClientID
                $This.Name        = $Reservation.Name
                $This.Description = $Reservation.Description
                $This.Exists      = 1
            }
        }

        Class VmValidateNode
        {
            [String] $Name
            [String] $Path
            [String] $VhdPath
            [String] $Result
            VmValidateNode([String]$Path,[String]$Name)
            {
                $This.Name    = $Name
                $This.Path    = "$Path\$Name"
                $This.VhdPath = "$Path\$Name\$Name.vhdx"
                
                If (Test-Path $This.Path)
                {
                    $This.Result = "Fail"
                }

                ElseIf (Test-Path $This.VhdPath)
                {
                    $This.Result = "Fail"
                }

                Else
                {
                    $This.Result = "Success"
                }
            }
        }

        Class VmValidateBase
        {
            [String] $Type
            [String] $Path
            [String] $InstallType
            [String] $Iso
            [String] $Script
            [Object] $Container
            [Object] $Process
            [Object] $Output
            [String] $Result
            VmValidateBase([String]$Type,[String]$Path,[String]$InstallType,[String]$Iso,[String]$Script,[Object]$Container)
            {
                $This.Type        = $Type
                $This.Path        = $Path
                $This.InstallType = $InstallType
                $This.Iso         = $Iso
                $This.Script      = $Script
                $This.Container   = @($Container)
                $This.Process     = @( )
                $This.Output      = @( )

                $This.TestBase()
                If (!$This.Result -and $This.InstallType -eq "ISO")
                {
                    $This.TestIso()
                }
                If (!$This.Result)
                {
                    $This.Populate()
                }
                If (!$This.Result)
                {
                    $This.Result = "Success"
                }
            }
            TestBase()
            {
                If (!(Test-Path $This.Path))
                {
                    $This.Result  = "Fail"
                }
            }
            TestISO()
            {
                If (!(Test-Path $This.Iso))
                {
                    $This.Result = "Fail"
                }
    
                ElseIf ($This.Script -ne "" -and !(Test-Path $This.Script))
                {
                    $This.Result = "Fail"    
                }
            }
            Populate()
            {
                ForEach ($Item in $This.Container)
                {
                    If ($Item.VmName -notin $This.Process.Name)
                    {
                        $This.Process += [VmValidateNode]::New($This.Path,$Item.VmName)
                    }
                }

                If ("Fail" -in $This.Process.Result)
                {
                    $This.Result = "Fail"
                }
            }
        }

        Class VmValidationStack
        {
            [Object] $Gateway
            [Object] $Server
            [Object] $Workstation
            VmValidationStack()
            {
                $This.Gateway     = @( )
                $This.Server      = @( )
                $This.Workstation = @( ) 
            }
            ValidateBase([String]$Type,[String]$Path,[String]$InstallType,[String]$Iso,[String]$Script,[Object]$Container)
            {
                $Item = [VmValidateBase]::New($Type,$Path,$InstallType,$Iso,$Script,$Container) 
                Switch ($Type)
                {
                    Gateway 
                    { 
                        $This.Gateway     = $Item
                    }
                    Server 
                    { 
                        $This.Server      = $Item
                    }
                    Workstation 
                    { 
                        $This.Workstation = $Item
                    }
                }
            }
            [String] ToString()
            {
                Return "<VmValidationStack>"
            }
        }

        Class VmObjectNode
        {
            [Object]            $Name
            [Double]          $Memory
            [Object]            $Path
            [Object]             $Vhd
            [Double]         $VhdSize
            [Object]      $Generation
            [UInt32]            $Core
            [Object[]]    $SwitchName
            Hidden [String]      $Iso
            Hidden [String]   $Script
            Hidden [Object] $Firmware
            [UInt32]          $Exists
            [String]            $Guid
            VmObjectNode([String]$Name)
            {
                $This.Name               = $Name
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
                $This.Firmware           = Switch ($Vm.Generation) { 1 { $Vm | Get-VMBios } 2 { $Vm | Get-VmFirmware } }
                $This.Exists             = 1
                $This.Guid               = $Vm.Id
            }
            Stage([String]$Path,[UInt32]$Memory,[UInt32]$HDD,[UInt32]$Generation,[UInt32]$Core,[String]$Switch)
            {
                $This.Memory             = ([UInt32]$Memory)*1MB
                $This.Path               = "$Path\$($This.Name)"
                $This.Vhd                = "$Path\$($This.Name)\$($This.Name).vhdx"
                $This.VhdSize            = ([UInt32]$HDD)*1GB
                $This.Generation         = $Generation
                $This.Core               = $Core
                $This.SwitchName         = @($Switch)
                $This.Exists             = 0
                $This.Guid               = $Null
            }
            [Object] Get()
            {
                Return @( Try { Get-VM -Name $This.Name } Catch { } )
            }
            [Object] GetFirmware()
            {
                Return @( Switch ($This.Generation) { 1 { Get-VMBios -VmName $This.Name } 2 { Get-VmFirmware -VmName $This.Name } } )
            }
            New()
            {
                If ($This.Get())
                {
                    Throw "This VM already exists"
                }

                $Object                = @{

                    Name               = $This.Name
                    MemoryStartupBytes = $This.Memory
                    Path               = $This.Path
                    NewVhdPath         = $This.Vhd
                    NewVhdSizeBytes    = $This.VhdSize
                    Generation         = $This.Generation
                    SwitchName         = @($This.SwitchName,$This.SwitchName[0])[$This.SwitchName.GetType().Name -match "\[\]"]
                }

                New-VM @Object -Verbose
                $This.Firmware         = $This.GetFirmware()
                $This.Exists           = 1
                Set-VMProcessor -VMName $This.Name -Count $This.Core -Verbose
            }
            Start()
            {
                Get-VM -Name $This.Name | ? State -ne Running | Start-VM -Verbose
            }
            Remove()
            {
                $Vm = $This.Get()
                If ($Vm.State -ne "Off")
                {
                    Switch ($Vm.State)
                    {
                        Paused 
                        { 
                            $This.Start()
                            Do
                            {
                                Start-Sleep 1
                            }
                            Until ($This.Get().State -eq "Running")
                        }
                        Saved
                        {
                            $This.Start()
                            Do
                            {
                                Start-Sleep 1
                            }
                            Until ($This.Get().State -eq "Running")
                        }
                    }
                    $This.Stop()
                    Do
                    {
                        Start-Sleep 1
                    }
                    Until ($This.Get().State -eq "Off")
                }
                $This.Get()            | Remove-VM -Force -Confirm:$False -Verbose
                $This.Firmware         = $Null
                $This.Exists           = 0
                Remove-Item $This.Vhd -Force -Verbose -Confirm:$False
                Remove-Item $This.Path -Force -Recurse -Verbose -Confirm:$False
                Remove-Item ($This.Path | Split-Path -Parent) -Force -Verbose -Confirm:$False
            }
            Stop()
            {
                Get-VM -Name $This.Name | ? State -ne Off | Stop-VM -Verbose -Force
            }
            Update()
            {
                $Vm = $This.Get()
                If (!$Vm)
                {
                    $This.Memory     = 0
                    $This.Path       = $Null
                    $This.Vhd        = $Null
                    $This.VhdSize    = 0
                    $This.Generation = $Null
                    $This.Core       = 0
                    $This.SwitchName = @( )
                    $This.Iso        = $Null
                    $This.Firmware   = $Null
                    $This.Exists     = 0
                    $This.Guid       = $Null
                }
                If ($Vm)
                {
                    $This.Memory     = $Vm.MemoryStartup
                    $This.Path       = $Vm.Path
                    $This.Vhd        = $Vm.HardDrives[0].Path
                    $This.VhdSize    = $This.Vhd | Get-VHD | % Size
                    $This.Generation = $Vm.Generation
                    $This.Core       = $Vm.ProcessorCount
                    $This.SwitchName = $Vm.NetworkAdapters.SwitchName
                    $This.Firmware   = $This.GetFirmware()
                    $This.Exists     = 1
                    $This.Guid       = $Vm.Id
                }
            }
            SetIsoBoot()
            {
                If ($This.Iso)
                {
                    $This.GetFirmware() | % { $_.BootOrder[2,0,1] }
                }
                If (!$This.Iso)
                {
                    Throw "No Iso loaded"
                }
            }
            LoadISO([String]$Path)
            {
                If (!(Test-Path $Path))
                {
                    Throw "Invalid ISO path"
                }

                Else
                {
                    $This.Iso = $Path
                    Get-VM -Name $This.Name | % { Set-VMDVDDrive -VMName $_.Name -Path $Path -Verbose }
                }
            }
            UnloadIso()
            {
                Get-VM -Name $This.Name | % { Set-VMDVDDrive -VMName $_.Name -Path $Null -Verbose }
            }
            [String] ToString()
            {
                Return $This.Name
            }
        }

        Class VmController
        {
            [String]    $HostName
            [String]      $Status
            [String]    $Username
            [String]  $Credential
            [Object]        $Host
            [Object]      $Switch
            [Object]    $Internal
            [Object]    $External
            [Object]    $AddsNode
            [Object]      $VmNode
            [Object]    $VmSelect
            [Object]     $VmStack
            [Object] $Reservation
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
                    $This.AddsNode = [VmAddsContainer]::New()
                    $This.VmNode   = @( )
                    $This.VmSelect = @( )
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
                    $This.AddsNode = [VmAddsContainer]::New()
                    $This.VmNode   = @( )
                    ForEach ($Item in Get-Vm -ComputerName $This.Hostname)
                    {
                        Write-Host "Loading [~] [Virtual Machine: $($Item.Name)]"
                        $This.VmNode += [VmObjectNode]::New($Item)
                    }
                    $This.VmSelect = @( )
                    $This.VmStack  = @( )
                }
            }
            [Object] Populate() 
            {
                Return [VmControl]::New($This.HostName,$This.Status,$This.Username,$This.Credential)
            }
            [Object] Selection([Object]$Item)
            {
                Return [VmSelect]::New($Item)
            }
            LoadAddsTree([Object]$AddsTree)
            {
                $This.AddsNode.LoadAddsTree($AddsTree)
                $This.VmSelect          = @( )
                $This.VmStack           = @( )
                ForEach ($Node in $This.AddsNode.Query)
                {
                    $Vm                 = $This.VmNode | ? Name -eq $Node.HostName
                    $Item               = $This.AddsNode.$($Node.Type) | ? Hostname -eq $Node.Hostname
                    If (!$VM)
                    {
                        $Vm             = $This.NewVmObjectNode($Node.Hostname)
                    }
                    $Item.LoadVmObject($Vm)
                    $This.VmSelect     += $This.Selection($Item)
                    $This.VmStack      += $Item
                }
            }
            [Object] GetVmObjectNode([Object]$Object)
            {
                Return @($This.VmStack | ? Type -eq $Object.Type | ? HostName -eq $Object.Name)
            }
            [Object] NewVmObjectNode([String]$Name)
            {
                Return [VmObjectNode]::New($Name)
            }
            DeleteNode([Object]$Object)
            {
                If ($Object.Exists)
                {
                    $Type        = $Object.Type
                    $Name        = $Object.Name

                    # Adds Node
                    # $Item      = $Main.VmController.AddsNode.$Type | ? Hostname -eq $Name
                    $Item        = $This.AddsNode.$Type | ? Hostname -eq $Name
                    $Item.Remove()

                    # Vm Stack
                    # $Item      = $Main.VmController.VmStack | ? Hostname -eq $Name
                    $Item        = $This.VmStack | ? Hostname -eq $Name

                    # Vm Node
                    # $Item      = $Main.VmController.VmNode | ? Name -eq $Name
                    $Item        = $This.VmNode | ? Name -eq $Name
                    $Item.Update()

                    # Vm Select
                    # $Item      = $Main.VmController.VmSelect | ? Name -eq $Name
                    $Item        = $This.VmSelect | ? Name -eq $Name
                    $Item.Exists = $False
                    $Item.Create = $True
                }
                #>
            }
            [Object] NodeContainer()
            {
                Return [VmCreate]::New()
            }
            Refresh()
            {
                $This.VmStack = @( )
                ForEach ($Item in $This.VmSelect)
                {
                    $This.VmStack += $This.Selection($Item)
                }
            }
            [Object] ValidationStack()
            {
                Return [VmValidationStack]::New()
            }
            [Object[]] GetRange([String]$ScopeID)
            {
                # Build Reservation Template List
                $Start = $Null
                $End   = $Null
                Get-DhcpServerV4ExclusionRange -ScopeID $ScopeID | % { 

                    $Start = ([String]$_.StartRange).Split(".")
                    $End   = ([String]$_.EndRange).Split(".")
                }

                $H      = @{ }
                ForEach ($X in 0..3)
                {
                    If ($Start[$X] -eq $End[$X])
                    {
                        $H.Add($X,$Start[$X])
                    }
                    If ($Start[$X] -ne $End[$X])
                    {
                        $H.Add($X,($Start[$X])..($End[$X]))
                    }
                }

                $ReservationList = @( )
                ForEach ($0 in $H[0])
                {
                    ForEach ($1 in $H[1])
                    {
                        ForEach ($2 in $H[2])
                        {
                            ForEach ($3 in $H[3])
                            {
                                $ReservationList += [VmDhcpReservation]::New($ReservationList.Count,$ScopeID,"$0.$1.$2.$3")
                            }
                        }
                    }
                }

                # Get actual reservations and insert
                $List             = Get-DhcpServerV4Reservation -ScopeID $ScopeID

                ForEach ($X in 0..($ReservationList.Count-1))
                {
                    $Item = $List | ? IPAddress -eq $ReservationList[$X].IPAddress 
                    If ($Item)
                    {
                        $ReservationList[$X].InsertReservation($Item)
                    }
                }

                Return $ReservationList
            }
            GetReservations([String]$ScopeID)
            {
                # Aggregate switches based on gateway items
                $Sites            = $This.VmStack  | ? Type -eq Gateway
                $VMSwitch         = ForEach ($Site in $Sites)
                {
                    If ($Site.Sitelink -notin $This.Switch.Name)
                    {
                        [VmSwitchNode]::New($Site.Hostname,"Internal")
                    }
                    Else
                    {
                        $This.Switch | ? Name -eq $Site.Hostname
                    }
                }

                $List             = $This.GetRange($ScopeID)
                $This.Reservation = ForEach ($X in 0..($VMSwitch.Count-1))
                {
                    $Item         = $List | ? Description -match $Sites[$X].Sitename
                    If (!$Item)
                    {
                        $Item     = ($List | ? Description -eq "-")[0+$X]
                    }
                    [VmSwitchReservation]::New($Sites[$X],$VMSwitch[$X],$Item)
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
            [String] $Name
            [String] $Root
            [Object] $Share
            [String] $Description
            [String] $Type
            [Object] $WimFiles
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
                Write-Host ("Loading [~] (Mdt Drive) [{0}:\]" -f $This.Name)
                $Files = Get-ChildItem $Path *.wim -Recurse
                Write-Host ("Found [+] ({0}) Wim File(s)" -f $Files.Count)
                ForEach ($Item in $Files)
                {
                    $WimFile        = [WimFile]::New($This.WimFiles.Count,$Item.FullName)
                    If ($WimFile.Label -notin $This.WimFiles.Label)
                    {
                        Write-Host ("Importing [~] ({0})" -f $Item.Name)
                        $This.WimFiles += [WimFile]::New($This.WimFiles.Count,$Item.FullName)
                    }
                    ElseIf ($WimFile.Label -in $This.WimFiles.Label)
                    {
                        Write-Host ("Skipping [!] ({0}) - duplicate label present" -f $Item.Name)
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
            Key([String]$NetworkPath,[String]$Organization,[String]$CommonName,[String]$Background,[String]$Logo,[String]$Phone,[String]$Hours,[String]$Website)
            {
                $This.Networkpath     = $NetworkPath
                $This.Organization    = $Organization
                $This.CommonName      = $CommonName
                $This.Background      = $Background
                $This.Logo            = $Logo
                $this.Phone           = $Phone
                $This.Hours           = $Hours
                $This.Website         = $Website
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
            [Object] NewKey([String]$NetworkPath,[String]$Organization,[String]$CommonName,[String]$Background,[String]$Logo,[String]$Phone,[String]$Hours,[String]$Website)
            {
                Return [Key]::New($NetworkPath,$Organization,$CommonName,$Background,$Logo,$Phone,$Hours,$Website)
            }
            SetBrand([Object]$Brand)
            {
                $This.Brand = $Brand
            }
            [Object] GetBrand()
            {
                Return [Brand]::New()
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
                                New-Item -Path "$Slot\$Type" -Enable True -Name $Version -Comments $Comment -ItemType Folder -Verbose
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
        [Object]         $Dispatcher
        [Object]          $Exception
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
            $This.Dispatcher         = $This.IO.Dispatcher

            ForEach ($I in 0..($This.Names.Count - 1))
            {
                $Name                = $This.Names[$I]
                $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
                If ($This.IO.$Name)
                {
                    $This.Types    += [DGList]::New($Name,$This.IO.$Name.GetType().Name)
                }
            }
        }
        Invoke()
        {
            Try
            {
                $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
            }
            Catch
            {
                $This.Exception     = $PSItem
            }
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
        '                            <Trigger Property="IsEnabled" Value="False">',
        '                                <Setter TargetName="Border" Property="Background" Value="#6F6F6F"/>',
        '                                <Setter Property="Foreground" Value="#9F9F9F"/>',
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
        '                    <Setter Property="Background" Value="#FFC5E5EC"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="2">',
        '                    <Setter Property="Background" Value="#FFF0CBC5"/>',
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
        '                <GroupBox  Header="[Module]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="380"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="165"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label    Grid.Row="0" Content="[FightingEntropy]://Module Information"/>',
        '                        <DataGrid Grid.Row="1 " Name="Module_Info">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Label    Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="3" Content="[FightingEntropy]://Components"/>',
        '                        <Grid     Grid.Row="4">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="200"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <ComboBox Grid.Column="0" Name="Module_Type"/>',
        '                            <ComboBox Grid.Column="1" Name="Module_Property"/>',
        '                            <TextBox  Grid.Column="2" Name="Module_Filter"/>',
        '                        </Grid>',
        '                        <DataGrid  Grid.Row="5" Grid.Column="0" Grid.ColumnSpan="3"  Name="Module_List">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Mode"          Binding="{Binding Mode}"   Width="40"/>',
        '                                <DataGridTextColumn Header="LastWriteTime" Binding="{Binding LastWriteTime}"  Width="150"/>',
        '                                <DataGridTextColumn Header="Length"        Binding="{Binding Length}" Width="75"/>',
        '                                <DataGridTextColumn Header="Name"          Binding="{Binding Name}"   Width="200"/>',
        '                                <DataGridTextColumn Header="Path"          Binding="{Binding Path}"   Width="600"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Config">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="180"/>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Services]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[FightingEntropy]://Infrastructure Dependency Snapshot"/>',
        '                            <DataGrid Grid.Row="1" Name="CfgServices">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"      Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Installed/Meets minimum requirements" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Role">',
        '                            <GroupBox Grid.Row="1" Header="[Information]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[FightingEntropy]://Role and System Information"/>',
        '                                    <DataGrid Grid.Row="1"  Name="Role_Info">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="System">',
        '                            <GroupBox Header="[System]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="240"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[FightingEntropy]://Server System Information"/>',
        '                                    <Grid  Grid.Row="1">',
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
        '                                        <Label       Grid.Row="0" Grid.Column="0" Content="[Manufacturer]:"/>',
        '                                        <Label       Grid.Row="1" Grid.Column="0" Content="[Model]:"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="0" Content="[Processor]:"/>',
        '                                        <Label       Grid.Row="3" Grid.Column="0" Content="[Architecture]:"/>',
        '                                        <Label       Grid.Row="4" Grid.Column="0" Content="[UUID]:"/>',
        '                                        <Label       Grid.Row="5" Grid.Column="0" Content="[System Name]:"     ToolTip="Enter a new system name"/>',
        '                                        <TextBox     Grid.Row="0" Grid.Column="1" Name="System_Manufacturer"/>',
        '                                        <TextBox     Grid.Row="1" Grid.Column="1" Name="System_Model"/>',
        '                                        <ComboBox    Grid.Row="2" Grid.Column="1" Name="System_Processor"/>',
        '                                        <ComboBox    Grid.Row="3" Grid.Column="1" Name="System_Architecture"/>',
        '                                        <TextBox     Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3"  Name="System_UUID"/>',
        '                                        <TextBox     Grid.Row="5" Grid.Column="1" Name="System_Name"/>',
        '                                        <Label       Grid.Row="0" Grid.Column="2" Content="[Product]:"/>',
        '                                        <Label       Grid.Row="1" Grid.Column="2" Content="[Serial]:"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="2" Content="[Memory]:"/>',
        '                                        <StackPanel  Grid.Row="3" Grid.Column="2" Orientation="Horizontal">',
        '                                            <Label   Content="[Chassis]:"/>',
        '                                            <CheckBox Name="System_IsVM" Content="VM" IsEnabled="False"/>',
        '                                        </StackPanel>',
        '                                        <Label       Grid.Row="5" Grid.Column="2" Content="[BIOS/UEFI]:"/>',
        '                                        <TextBox     Grid.Row="0" Grid.Column="3" Name="System_Product"/>',
        '                                        <TextBox     Grid.Row="1" Grid.Column="3" Name="System_Serial"/>',
        '                                        <TextBox     Grid.Row="2" Grid.Column="3" Name="System_Memory"/>',
        '                                        <ComboBox    Grid.Row="3" Grid.Column="3" Name="System_Chassis"/>',
        '                                        <ComboBox    Grid.Row="5" Grid.Column="3" Name="System_BiosUefi"/>',
        '                                    </Grid>',
        '                                    <Border Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <Label Grid.Row="3" Grid.Column="0" Grid.ColumnSpan="4"  Content="[FightingEntropy]://Disk Information"/>',
        '                                    <DataGrid Grid.Row="4" Grid.ColumnSpan="4 " Name="System_Disk">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"       Binding="{Binding Name}"       Width="50"/>',
        '                                            <DataGridTextColumn Header="Label"      Binding="{Binding Label}"      Width="200"/>',
        '                                            <DataGridTextColumn Header="FileSystem" Binding="{Binding FileSystem}" Width="80"/>',
        '                                            <DataGridTextColumn Header="Size"       Binding="{Binding Size}"       Width="100"/>',
        '                                            <DataGridTextColumn Header="Free"       Binding="{Binding Free}"       Width="100"/>',
        '                                            <DataGridTextColumn Header="Used"       Binding="{Binding Used}"       Width="100"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Network">',
        '                            <GroupBox Header="[Adapter]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="180"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[FightingEntropy]://Network Adapter Information"/>',
        '                                    <DataGrid Grid.Row="1"  Name="Network_Adapter" Margin="5" ScrollViewer.HorizontalScrollBarVisibility="Visible">',
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
        '                                    <Grid Grid.Row="2">',
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
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[Adapter Name]:"/>',
        '                                        <Label    Grid.Row="1" Grid.Column="0" Content="[Network Type]:"/>',
        '                                        <Label    Grid.Row="2" Grid.Column="0" Content="[IP Address]:"/>',
        '                                        <Label    Grid.Row="3" Grid.Column="0" Content="[Subnet Mask]:"/>',
        '                                        <Label    Grid.Row="4" Grid.Column="0" Content="[Gateway]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Network_Name"/>',
        '                                        <ComboBox Grid.Row="1" Grid.Column="1" Name="Network_Type"/>',
        '                                        <TextBox  Grid.Row="2" Grid.Column="1" Name="Network_IPAddress"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="1" Name="Network_SubnetMask"/>',
        '                                        <TextBox  Grid.Row="4" Grid.Column="1" Name="Network_Gateway"/>',
        '                                        <Label    Grid.Row="1" Grid.Column="2" Content="[Interface Index]:"/>',
        '                                        <Label    Grid.Row="2" Grid.Column="2" Content="[DNS Server(s)]:"/>',
        '                                        <Label    Grid.Row="3" Grid.Column="2" Content="[DHCP Server]:"/>',
        '                                        <Label    Grid.Row="4" Grid.Column="2" Content="[Mac Address]:"/>',
        '                                        <TextBox  Grid.Row="1" Grid.Column="3" Name="Network_Index"/>',
        '                                        <ComboBox Grid.Row="2" Grid.Column="3" Name="Network_DNS"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="3" Name="Network_DHCP"/>',
        '                                        <TextBox  Grid.Row="4" Grid.Column="3" Name="Network_MacAddress"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Dhcp">',
        '                            <GroupBox Header="[Dhcp]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="0.75*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label    Grid.Row="0" Content="[Dhcp ScopeID List]"/>',
        '                                    <DataGrid Grid.Row="1" Name="CfgDhcpScopeID">',
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
        '                                    <Label    Grid.Row="2" Content="[Dhcp Reservations]"/>',
        '                                    <DataGrid Grid.Row="3" Name="CfgDhcpScopeReservations">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="IPAddress"   Binding="{Binding IPAddress}"   Width="120"/>',
        '                                            <DataGridTextColumn Header="ClientID"    Binding="{Binding ClientID}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"        Width="250"/>',
        '                                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Label    Grid.Row="4" Content="[Dhcp Scope Options]"/>',
        '                                    <DataGrid Grid.Row="5" Name="CfgDhcpScopeOptions">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="OptionID"    Binding="{Binding OptionID}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}"     Width="150"/>',
        '                                            <DataGridTextColumn Header="Type"        Binding="{Binding Type}"     Width="200"/>',
        '                                            <DataGridTextColumn Header="Value"       Binding="{Binding Value}"    Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Dns">',
        '                            <GroupBox Header="[Dns]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="2*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[DNS Server Zone List]"/>',
        '                                    <DataGrid Grid.Row="1"  Name="CfgDnsZone">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Index" Binding="{Binding Index}"       Width="50"/>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding ZoneName}"    Width="*"/>',
        '                                            <DataGridTextColumn Header="Type"  Binding="{Binding ZoneType}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="Hosts" Binding="{Binding Hosts.Count}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Label Grid.Row="2" Content="[DNS Server Zone Hosts]"/>',
        '                                    <DataGrid Grid.Row="3" Name="CfgDnsZoneHosts">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="HostName"   Binding="{Binding HostName}"   Width="250"/>',
        '                                            <DataGridTextColumn Header="Record"     Binding="{Binding RecordType}" Width="65"/>',
        '                                            <DataGridTextColumn Header="Type"       Binding="{Binding Type}"       Width="65"/>',
        '                                            <DataGridTextColumn Header="Data"       Binding="{Binding RecordData}" Width="Auto"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Adds">',
        '                            <GroupBox Header="[Adds]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="160"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Active Directory Domain Information]"/>',
        '                                    <Grid  Grid.Row="1">',
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
        '                                        <Label   Grid.Row="0" Grid.Column="0" Content="[Hostname]:"/>',
        '                                        <Label   Grid.Row="1" Grid.Column="0" Content="[DC Mode]:"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="0" Content="[Domain Mode]:"/>',
        '                                        <Label   Grid.Row="3" Grid.Column="0" Content="[Forest Mode]:"/>',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="3" Name="Adds_Hostname"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="1" Name="Adds_DCMode"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="Adds_DomainMode"/>',
        '                                        <TextBox Grid.Row="3" Grid.Column="1" Name="Adds_ForestMode"/>',
        '                                        <Label   Grid.Row="1" Grid.Column="2" Content="[Root]:"/>',
        '                                        <Label   Grid.Row="2" Grid.Column="2" Content="[Config]:"/>',
        '                                        <Label   Grid.Row="3" Grid.Column="2" Content="[Schema]:"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="3" Name="Adds_Root"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="3" Name="Adds_Config"/>',
        '                                        <TextBox Grid.Row="3" Grid.Column="3" Name="Adds_Schema"/>',
        '                                    </Grid>',
        '                                    <Label Grid.Row="2" Content="[Active Directory Objects]"/>',
        '                                    <Grid  Grid.Row="3">',
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
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Hyper-V">',
        '                            <GroupBox Header="[Veridian]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="80"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="120"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[(Veridian/Hyper-V) Host Settings]"/>',
        '                                    <DataGrid Grid.Row="1" Name="CfgHyperV">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"      Binding="{Binding Name}"      Width="150"/>',
        '                                            <DataGridTextColumn Header="Processor" Binding="{Binding Processor}" Width="80"/>',
        '                                            <DataGridTextColumn Header="Memory"    Binding="{Binding Memory}"    Width="150"/>',
        '                                            <DataGridTextColumn Header="VMPath"    Binding="{Binding VMPath}"    Width="500"/>',
        '                                            <DataGridTextColumn Header="VHDPath"   Binding="{Binding VHDPath}"   Width="500"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Label Grid.Row="2" Content="[Virtual Switches] (Disabled)"/>',
        '                                    <DataGrid Grid.Row="3" Name="CfgHyperV_Switch">',
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
        '                                    <Label Grid.Row="4" Content="[Virtual Machines] (Disabled)"/>',
        '                                    <DataGrid Grid.Row="5" Name="CfgHyperV_VM">',
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
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Wds">',
        '                            <GroupBox Header="[Wds]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Windows Deployment Services]"/>',
        '                                    <Grid  Grid.Row="1">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Server]:"/>',
        '                                        <TextBox  Grid.Column="1" Name="WDS_Server"/>',
        '                                        <Label    Grid.Column="2" Content="[IPAddress]:"/>',
        '                                        <ComboBox Grid.Column="3" Name="WDS_IPAddress"/>',
        '                                    </Grid>',
        '                                    <Label Grid.Row="2" Content="[Wds Images (Disabled)"/>',
        '                                    <DataGrid Grid.Row="3" Name="Wds_Images">',
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
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Mdt/WinADK/WinPE">',
        '                            <GroupBox Header="[Mdt]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="160"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Microsoft Deployment Toolkit (Top-Shelf)]"/>',
        '                                    <Grid Grid.Row="1">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="150"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[Server]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Name="MDT_Server"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="2" Content="[IPAddress]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="3" Name="MDT_IPAddress"/>',
        '                                        <Label    Grid.Row="1" Grid.Column="0" Content="[WinADK Version]:"/>',
        '                                        <TextBox  Grid.Row="1" Grid.Column="1" Name="MDT_ADK_Version"/>',
        '                                        <Label    Grid.Row="1" Grid.Column="2" Content="[WinPE Version]:"/>',
        '                                        <TextBox  Grid.Row="1" Grid.Column="3" Name="MDT_PE_Version"/>',
        '                                        <Label    Grid.Row="2" Grid.Column="0" Content="[MDT Version]:"/>',
        '                                        <TextBox  Grid.Row="2" Grid.Column="1" Name="MDT_Version"/>',
        '                                        <Label    Grid.Row="3" Grid.Column="0" Content="[Installation Path]:"/>',
        '                                        <TextBox  Grid.Row="3" Grid.Column="1" Grid.ColumnSpan="3" Name="MDT_Path"/>',
        '                                    </Grid>',
        '                                    <Label Grid.Row="2" Content="[Mdt Shares] (Disabled)"/>',
        '                                    <DataGrid Grid.Row="3" Name="Mdt_Shares">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"        Binding="{Binding Name}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Type"        Binding="{Binding Type}" Width="60"/>',
        '                                            <DataGridTextColumn Header="Root"        Binding="{Binding Root}" Width="250"/>',
        '                                            <DataGridTextColumn Header="Share"       Binding="{Binding Share}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="IIS">',
        '                            <GroupBox Header="[IIS]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label    Grid.Row="0" Content="[IIS Application Pools]"/>',
        '                                    <DataGrid Grid.Row="1" Name="IIS_AppPools">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"         Binding="{Binding Name}"         Width="150"/>',
        '                                            <DataGridTextColumn Header="Status"       Binding="{Binding Status}"       Width="80"/>',
        '                                            <DataGridTextColumn Header="AutoStart"    Binding="{Binding AutoStart}"    Width="80"/>',
        '                                            <DataGridTextColumn Header="CLRVersion"   Binding="{Binding CLRVersion}"   Width="80"/>',
        '                                            <DataGridTextColumn Header="PipelineMode" Binding="{Binding PipelineMode}" Width="150"/>',
        '                                            <DataGridTextColumn Header="StartMode"    Binding="{Binding StartMode}"    Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Label    Grid.Row="2" Content="[IIS Sites]"/>',
        '                                    <DataGrid Grid.Row="3" Name="IIS_Sites">',
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
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                    </TabControl>',
        '                </Grid>',
        '            </TabItem>',
        '            <TabItem Header="Domain">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Domain]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="80"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Aggregate]: Provision (subdomain/site) list"/>',
        '                            <DataGrid Grid.Row="1" Name="DcAggregate"',
        '                                      ScrollViewer.CanContentScroll="True"',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"     Binding="{Binding SiteLink}" Width="120"/>',
        '                                    <DataGridTextColumn Header="Location" Binding="{Binding Location}" Width="200"/>',
        '                                    <DataGridTextColumn Header="Region"   Binding="{Binding Region}"   Width="150"/>',
        '                                    <DataGridTextColumn Header="Country"  Binding="{Binding Country}"  Width="60"/>',
        '                                    <DataGridTextColumn Header="Postal"   Binding="{Binding Postal}"   Width="60"/>',
        '                                    <DataGridTextColumn Header="SiteName" Binding="{Binding SiteName}" Width="Auto"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Row="0" Grid.Column="0" Content="[Organization]:"/>',
        '                                <TextBox Grid.Row="0" Grid.Column="1" Name="DcOrganization"/>',
        '                                <Label   Grid.Row="0" Grid.Column="2" Content="[CommonName]:"/>',
        '                                <TextBox Grid.Row="0" Grid.Column="3" Name="DcCommonName"/>',
        '                                <Button  Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Name="DcGetSitename" Content="Get Sitename"/>',
        '                                <Label   Grid.Row="1" Grid.Column="2" Content="[Zip Code]:"/>',
        '                                <Grid Grid.Row="1" Grid.Column="3">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <TextBox Grid.Column="0" Name="DcAddSitenameZip"/>',
        '                                    <Button  Grid.Column="1" Name="DcAddSitename"    Content="+"/>',
        '                                    <Button  Grid.Column="2" Name="DcRemoveSitename" Content="-"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                            <Border Grid.Row="3" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label Grid.Row="4" Content="[Viewer]: View each sites&apos; (properties/attributes)"/>',
        '                            <DataGrid Grid.Row="5" Name="DcViewer">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Border Grid.Row="6" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label Grid.Row="7" Content="[Topology]: Output/Existence validation"/>',
        '                            <DataGrid Grid.Row="8" Name="DcTopology"',
        '                                      ScrollViewer.CanContentScroll="True"',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Sitename" Binding="{Binding SiteName}" Width="200"/>',
        '                                    <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="False"/>',
        '                                                    <ComboBoxItem Content="True"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1">',
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
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Network]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label    Grid.Row="0" Content ="[Aggregate]: Provision (master address/prefix) &amp; independent subnets"/>',
        '                            <DataGrid Grid.Row="1" Name="NwAggregate"',
        '                                      ScrollViewer.CanContentScroll="True" ',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"      Binding="{Binding Network}"   Width="100"/>',
        '                                    <DataGridTextColumn Header="Netmask"   Binding="{Binding Netmask}"   Width="100"/>',
        '                                    <DataGridTextColumn Header="Host Ct."  Binding="{Binding HostCount}" Width="60"/>',
        '                                    <DataGridTextColumn Header="Range"     Binding="{Binding HostRange}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Start"     Binding="{Binding Start}"     Width="125"/>',
        '                                    <DataGridTextColumn Header="End"       Binding="{Binding End}"       Width="125"/>',
        '                                    <DataGridTextColumn Header="Broadcast" Binding="{Binding Broadcast}" Width="125"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="80"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="40"/>',
        '                                    <ColumnDefinition Width="40"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Column="0" Content="[Scope]:"/>',
        '                                <TextBox Grid.Column="1" Name="NwScope"/>',
        '                                <Button  Grid.Column="2" Name="NwScopeLoad" Content="Load" IsEnabled="False"/>',
        '                                <Label   Grid.Column="3" Content="[Subnet]:"/>',
        '                                <TextBox Grid.Column="4" Name="NwSubnetName"/>',
        '                                <Button  Grid.Column="5" Name="NwAddSubnetName" Content="+"/>',
        '                                <Button  Grid.Column="6" Name="NwRemoveSubnetName" Content="-"/>',
        '                            </Grid>',
        '                            <Border   Grid.Row="3" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label    Grid.Row="4" Content="[Viewer]: View each subnets&apos; (properties/attributes)"/>',
        '                            <DataGrid Grid.Row="5" Name="NwViewer">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"   Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value"  Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Border   Grid.Row="6" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label    Grid.Row="7" Content="[Topology]: (Output/Existence) validation"/>',
        '                            <DataGrid Grid.Row="8" Name="NwTopology"',
        '                                      ScrollViewer.CanContentScroll="True"',
        '                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"    Binding="{Binding Name}"    Width="150"/>',
        '                                    <DataGridTextColumn Header="Network" Binding="{Binding Network}" Width="200"/>',
        '                                    <DataGridTemplateColumn Header="Exists" Width="50">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="False"/>',
        '                                                    <ComboBoxItem Content="True"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1">',
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
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Sitemap]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="140"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="100"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="105"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Aggregate]: Sites to be generated"/>',
        '                            <DataGrid Grid.Row="1" Name="SmAggregate">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"      Binding="{Binding Name}"     Width="125"/>',
        '                                    <DataGridTextColumn Header="Location"  Binding="{Binding Location}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Sitename"  Binding="{Binding SiteName}" Width="300"/>',
        '                                    <DataGridTextColumn Header="Network"   Binding="{Binding Network}"  Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="125"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Column="0" Content="[Site Count]:"/>',
        '                                <TextBox Grid.Column="1" Name="SmSiteCount"/>',
        '                                <Label   Grid.Column="2" Content="[Network Count]:"/>',
        '                                <TextBox Grid.Column="3" Name="SmNetworkCount"/>',
        '                                <Button  Grid.Column="4" Name="SmLoadSitemap" Content="Load"/>',
        '                            </Grid>',
        '                            <Border   Grid.Row="3" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Grid     Grid.Row="4">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="10"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Grid Grid.Column="0">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label    Grid.Row="0" Content="[SiteLink]: Select main ISTG trunk"/>',
        '                                    <DataGrid Grid.Row="1" Name="SmSiteLink">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"               Binding="{Binding Name}"              Width="150"/>',
        '                                            <DataGridTextColumn Header="Distinguished Name" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                </Grid>',
        '                                <Border   Grid.Column="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                <Grid Grid.Column="2">',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label    Grid.Row="0" Content="[Template]: Create these objects for each site"/>',
        '                                    <DataGrid Grid.Row="1" Name="SmTemplate">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="150"/>',
        '                                            <DataGridTemplateColumn Header="Create" Width="*">',
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
        '                                </Grid>',
        '                            </Grid>',
        '                            <Border   Grid.Row="5" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label    Grid.Row="6" Content="[Viewer]: View each sites&apos; (properties/attributes)"/>',
        '                            <DataGrid Grid.Row="7" Name="SmViewer">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}"  Width="150"/>',
        '                                    <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Border   Grid.Row="8" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label    Grid.Row="9" Content="[Topology]: (Output/Existence) Validation"/>',
        '                            <DataGrid Grid.Row="10"  Name="SmTopology">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="125"/>',
        '                                    <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="100"/>',
        '                                    <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                        <DataGridTemplateColumn.CellTemplate>',
        '                                            <DataTemplate>',
        '                                                <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                    <ComboBoxItem Content="False"/>',
        '                                                    <ComboBoxItem Content="True"/>',
        '                                                </ComboBox>',
        '                                            </DataTemplate>',
        '                                        </DataGridTemplateColumn.CellTemplate>',
        '                                    </DataGridTemplateColumn>',
        '                                    <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
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
        '                <GroupBox Header="[Adds]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="*"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="80"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="60"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="80"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="100"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label    Grid.Column="0" Content="[Name]:"/>',
        '                            <ComboBox Grid.Column="1" Name="AddsSite" ItemsSource="{Binding Name}"/>',
        '                            <Label    Grid.Column="2" Content="[Site]:"/>',
        '                            <TextBox  Grid.Column="3" Name="AddsSiteName" IsReadOnly="True"/>',
        '                            <Label    Grid.Column="4" Content="[Subnet]:"/>',
        '                            <TextBox  Grid.Column="5" Name="AddsSubnetName" IsReadOnly="True"/>',
        '                            <Button   Grid.Column="6" Name="AddsSiteDefaults" Content="[All] Defaults"/>',
        '                        </Grid>',
        '                        <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <TabControl Grid.Row="2">',
        '                            <TabItem Header="Control">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="1.5*"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label    Grid.Row="0" Content="[Viewer]"/>',
        '                                    <DataGrid Grid.Row="1" Name="AddsViewer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="150"/>',
        '                                            <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <Label Grid.Row="3" Content="[Children]"/>',
        '                                    <DataGrid Grid.Row="4" Name="AddsChildren">',
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
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Gateway">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="2*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                        <TextBox Grid.Column="1" Name="AddsGwName"/>',
        '                                        <Button  Grid.Column="2" Name="AddsGwAdd"     Content="+"/>',
        '                                        <Button  Grid.Column="3" Name="AddsGwDelete"  Content="-"/>',
        '                                        <Label   Grid.Column="4" Content="[List]:"/>',
        '                                        <TextBox Grid.Column="5" Name="AddsGwFile"/>',
        '                                        <Button  Grid.Column="6" Name="AddsGwBrowse"  Content="Browse"/>',
        '                                        <Button  Grid.Column="7" Name="AddsGwAddList" Content="+"/>',
        '                                    </Grid>',
        '                                    <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <TabControl Grid.Row="2">',
        '                                        <TabItem Header="Aggregate">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label    Grid.Row="0" Content="[Aggregate]: Provision (gateway/router) items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsGwAggregate"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label    Grid.Row="3" Content="[Viewer]: View a gateways&apos; properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsGwAggregateViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="Output">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label    Grid.Row="0" Content="[Output]: Provisioned (gateway/router) items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsGwOutput"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                                        <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                                        <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                                        <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                                        <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                                        <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                                        <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                                        <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                                        <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                                        <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                                        <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                                        <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                                        <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                                        <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                                        <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label    Grid.Row="3" Content="[Viewer]: View a gateways&apos; properties/attributes"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsGwOutputViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="AddsGwGet" Content="Get"/>',
        '                                        <Button Grid.Column="1" Name="AddsGwNew" Content="New"/>',
        '                                        <Button Grid.Column="2" Name="AddsGwRemove" Content="Remove"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Server">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="2*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                        <TextBox Grid.Column="1" Name="AddsSrName"/>',
        '                                        <Button  Grid.Column="2" Name="AddsSrAdd"     Content="+"/>',
        '                                        <Button  Grid.Column="3" Name="AddsSrDelete"  Content="-"/>',
        '                                        <Label   Grid.Column="4" Content="[List]:"/>',
        '                                        <TextBox Grid.Column="5" Name="AddsSrFile"/>',
        '                                        <Button  Grid.Column="6" Name="AddsSrBrowse"  Content="Browse"/>',
        '                                        <Button  Grid.Column="7" Name="AddsSrAddList" Content="+"/>',
        '                                    </Grid>',
        '                                    <Border     Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <TabControl Grid.Row="2">',
        '                                        <TabItem Header="Aggregate">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Aggregate]: Provision (server/domain controller) items"/>',
        '                                                <DataGrid Grid.Row="1 " Name="AddsSrAggregate"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label Grid.Row="3" Content="[Viewer]: View a servers&apos; properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsSrAggregateViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="Output">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Output]: Provisioned (server/domain controller) items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsSrOutput"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                                        <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                                        <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                                        <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                                        <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                                        <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                                        <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                                        <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                                        <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                                        <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                                        <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                                        <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                                        <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                                        <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                                        <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label    Grid.Row="3" Content="[Viewer]: View a gateways&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsSrOutputViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="AddsSrGet"    Content="Get"/>',
        '                                        <Button Grid.Column="1" Name="AddsSrNew"    Content="New"/>',
        '                                        <Button Grid.Column="2" Name="AddsSrRemove" Content="Remove"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Workstation">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="2*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                        <TextBox Grid.Column="1" Name="AddsWsName"/>',
        '                                        <Button  Grid.Column="2" Name="AddsWsAdd"     Content="+"/>',
        '                                        <Button  Grid.Column="3" Name="AddsWsDelete"  Content="-"/>',
        '                                        <Label   Grid.Column="4" Content="[List]:"/>',
        '                                        <TextBox Grid.Column="5" Name="AddsWsFile"/>',
        '                                        <Button  Grid.Column="6" Name="AddsWsBrowse"  Content="Browse"/>',
        '                                        <Button  Grid.Column="7" Name="AddsWsAddList" Content="+"/>',
        '                                    </Grid>',
        '                                    <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <TabControl Grid.Row="2">',
        '                                        <TabItem Header="Aggregate">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Aggregate]: Provision workstation items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsWsAggregate"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label Grid.Row="3" Content="[Viewer]: View a workstation&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4"  Name="AddsWsAggregateViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="Output">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Output]: Provisioned workstation items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsWsOutput"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                                        <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                                        <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                                        <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                                        <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                                        <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                                        <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                                        <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                                        <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                                        <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                                        <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                                        <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                                        <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                                        <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                                        <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                                        <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label Grid.Row="3" Content="[Viewer]: View a workstations&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsWsOutputViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="AddsWsGet" Content="Get"/>',
        '                                        <Button Grid.Column="1" Name="AddsWsNew" Content="New"/>',
        '                                        <Button Grid.Column="2" Name="AddsWsRemove" Content="Remove"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="User">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="2*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                        <TextBox Grid.Column="1" Name="AddsUserName"/>',
        '                                        <Button  Grid.Column="2" Name="AddsUserAdd"     Content="+"/>',
        '                                        <Button  Grid.Column="3" Name="AddsUserDelete"  Content="-"/>',
        '                                        <Label   Grid.Column="4" Content="[List]:"/>',
        '                                        <TextBox Grid.Column="5" Name="AddsUserFile"/>',
        '                                        <Button  Grid.Column="6" Name="AddsUserBrowse"  Content="Browse"/>',
        '                                        <Button  Grid.Column="7" Name="AddsUserAddList" Content="+"/>',
        '                                    </Grid>',
        '                                    <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <TabControl Grid.Row="2">',
        '                                        <TabItem Header="Aggregate">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Aggregate]: Provision user items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsUserAggregate"',
        '                                                      ScrollViewer.CanContentScroll="True" ',
        '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label Grid.Row="3" Content="[Viewer]: View a users&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4 " Name="AddsUserAggregateViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="Output">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Output]: Provisioned user items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsUserOutput"',
        '                                                          ScrollViewer.CanContentScroll="True" ',
        '                                                          ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                          ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Organization"      Binding="{Binding Organization}"      Width="150"/>',
        '                                                        <DataGridTextColumn Header="CommonName"        Binding="{Binding CommonName}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Site"              Binding="{Binding Site}"              Width="120"/>',
        '                                                        <DataGridTextColumn Header="Location"          Binding="{Binding Location}"          Width="150"/>',
        '                                                        <DataGridTextColumn Header="Region"            Binding="{Binding Region}"            Width="80"/>',
        '                                                        <DataGridTextColumn Header="Country"           Binding="{Binding Country}"           Width="60"/>',
        '                                                        <DataGridTextColumn Header="Postal"            Binding="{Binding Postal}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Sitelink"          Binding="{Binding Sitelink}"          Width="120"/>',
        '                                                        <DataGridTextColumn Header="Sitename"          Binding="{Binding Sitename}"          Width="250"/>',
        '                                                        <DataGridTextColumn Header="Network"           Binding="{Binding Network}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Prefix"            Binding="{Binding Prefix}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Netmask"           Binding="{Binding Netmask}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Start"             Binding="{Binding Start}"             Width="125"/>',
        '                                                        <DataGridTextColumn Header="End"               Binding="{Binding End}"               Width="125"/>',
        '                                                        <DataGridTextColumn Header="Range"             Binding="{Binding Range}"             Width="150"/>',
        '                                                        <DataGridTextColumn Header="Broadcast"         Binding="{Binding Broadcast}"         Width="125"/>',
        '                                                        <DataGridTextColumn Header="ReverseDNS"        Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="200"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="200"/>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="200"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="200"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Account"           Binding="{Binding Account}"           Width="200"/>',
        '                                                        <DataGridTextColumn Header="SamName"           Binding="{Binding SamName}"           Width="200"/>',
        '                                                        <DataGridTextColumn Header="UserPrincipalName" Binding="{Binding UserPrincipalName}" Width="200"/>',
        '                                                        <DataGridTextColumn Header="Guid"              Binding="{Binding Guid}"              Width="200"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label Grid.Row="3" Content="[Output]: View a users&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4 " Name="AddsUserOutputViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="AddsUserGet"    Content="Get"/>',
        '                                        <Button Grid.Column="1" Name="AddsUserNew"    Content="New"/>',
        '                                        <Button Grid.Column="2" Name="AddsUserRemove" Content="Remove"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                            <TabItem Header="Service">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="10"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Grid Grid.Row="0">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="70"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="2*"/>',
        '                                            <ColumnDefinition Width="80"/>',
        '                                            <ColumnDefinition Width="40"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label   Grid.Column="0" Content="[Name]:"/>',
        '                                        <TextBox Grid.Column="1" Name="AddsSvcName"/>',
        '                                        <Button  Grid.Column="2" Name="AddsSvcAdd"     Content="+"/>',
        '                                        <Button  Grid.Column="3" Name="AddsSvcDelete"  Content="-"/>',
        '                                        <Label   Grid.Column="4" Content="[List]:"/>',
        '                                        <TextBox Grid.Column="5" Name="AddsSvcFile"/>',
        '                                        <Button  Grid.Column="6" Name="AddsSvcBrowse"  Content="Browse"/>',
        '                                        <Button  Grid.Column="7" Name="AddsSvcAddList" Content="+"/>',
        '                                    </Grid>',
        '                                    <Border   Grid.Row="1" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                    <TabControl Grid.Row="2">',
        '                                        <TabItem Header="Aggregate">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Aggregate]: Provision service items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsSvcAggregate"',
        '                                              ScrollViewer.CanContentScroll="True" ',
        '                                              ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                              ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="100"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="100"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="350"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="350"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label    Grid.Row="3" Content="[Viewer]: View a service&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsSvcAggregateViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                        <TabItem Header="Output">',
        '                                            <Grid>',
        '                                                <Grid.RowDefinitions>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                    <RowDefinition Height="10"/>',
        '                                                    <RowDefinition Height="40"/>',
        '                                                    <RowDefinition Height="*"/>',
        '                                                </Grid.RowDefinitions>',
        '                                                <Label Grid.Row="0" Content="[Output]: Provisioned service items"/>',
        '                                                <DataGrid Grid.Row="1" Name="AddsSvcOutput"',
        '                                                      ScrollViewer.CanContentScroll="True" ',
        '                                                      ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                                      ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Organization"      Binding="{Binding Organization}"      Width="150"/>',
        '                                                        <DataGridTextColumn Header="CommonName"        Binding="{Binding CommonName}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Site"              Binding="{Binding Site}"              Width="120"/>',
        '                                                        <DataGridTextColumn Header="Location"          Binding="{Binding Location}"          Width="150"/>',
        '                                                        <DataGridTextColumn Header="Region"            Binding="{Binding Region}"            Width="80"/>',
        '                                                        <DataGridTextColumn Header="Country"           Binding="{Binding Country}"           Width="60"/>',
        '                                                        <DataGridTextColumn Header="Postal"            Binding="{Binding Postal}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Sitelink"          Binding="{Binding Sitelink}"          Width="120"/>',
        '                                                        <DataGridTextColumn Header="Sitename"          Binding="{Binding Sitename}"          Width="250"/>',
        '                                                        <DataGridTextColumn Header="Network"           Binding="{Binding Network}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Prefix"            Binding="{Binding Prefix}"            Width="60"/>',
        '                                                        <DataGridTextColumn Header="Netmask"           Binding="{Binding Netmask}"           Width="125"/>',
        '                                                        <DataGridTextColumn Header="Start"             Binding="{Binding Start}"             Width="125"/>',
        '                                                        <DataGridTextColumn Header="End"               Binding="{Binding End}"               Width="125"/>',
        '                                                        <DataGridTextColumn Header="Range"             Binding="{Binding Range}"             Width="150"/>',
        '                                                        <DataGridTextColumn Header="Broadcast"         Binding="{Binding Broadcast}"         Width="125"/>',
        '                                                        <DataGridTextColumn Header="ReverseDNS"        Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                                        <DataGridTextColumn Header="Name"              Binding="{Binding Name}"              Width="200"/>',
        '                                                        <DataGridTextColumn Header="Type"              Binding="{Binding Type}"              Width="200"/>',
        '                                                        <DataGridTextColumn Header="Parent"            Binding="{Binding Parent}"            Width="200"/>',
        '                                                        <DataGridTextColumn Header="DistinguishedName" Binding="{Binding DistinguishedName}" Width="200"/>',
        '                                                        <DataGridTemplateColumn Header="Exists" Width="60">',
        '                                                            <DataGridTemplateColumn.CellTemplate>',
        '                                                                <DataTemplate>',
        '                                                                    <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                                        <ComboBoxItem Content="False"/>',
        '                                                                        <ComboBoxItem Content="True"/>',
        '                                                                    </ComboBox>',
        '                                                                </DataTemplate>',
        '                                                            </DataGridTemplateColumn.CellTemplate>',
        '                                                        </DataGridTemplateColumn>',
        '                                                        <DataGridTextColumn Header="Account"           Binding="{Binding Account}"           Width="200"/>',
        '                                                        <DataGridTextColumn Header="SamName"           Binding="{Binding SamName}"           Width="200"/>',
        '                                                        <DataGridTextColumn Header="UserPrincipalName" Binding="{Binding UserPrincipalName}" Width="200"/>',
        '                                                        <DataGridTextColumn Header="Guid"              Binding="{Binding Guid}"              Width="200"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                                <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                                <Label    Grid.Row="3" Content="[Viewer]: View a users&apos; (properties/attributes)"/>',
        '                                                <DataGrid Grid.Row="4" Name="AddsSvcOutputViewer">',
        '                                                    <DataGrid.Columns>',
        '                                                        <DataGridTextColumn Header="Name"  Binding="{Binding Name}"   Width="150"/>',
        '                                                        <DataGridTextColumn Header="Value" Binding="{Binding Value}"   Width="*"/>',
        '                                                    </DataGrid.Columns>',
        '                                                </DataGrid>',
        '                                            </Grid>',
        '                                        </TabItem>',
        '                                    </TabControl>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="AddsSvcGet"    Content="Get"/>',
        '                                        <Button Grid.Column="1" Name="AddsSvcNew"    Content="New"/>',
        '                                        <Button Grid.Column="2" Name="AddsSvcRemove" Content="Remove"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </TabItem>',
        '                        </TabControl>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Virtual">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="220"/>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Controller]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="60"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Controller]: VmHost Server, Service State, Credential"/>',
        '                            <DataGrid Grid.Row="1" Name="VmControl">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Status (Hyper-V Service)" Binding="{Binding Status}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Credential" Binding="{Binding Username}" Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label   Grid.Column="0" Content="[Hostname]:"/>',
        '                                <TextBox Grid.Column="1" Name="VmHostName"/>',
        '                                <Button  Grid.Column="2" Name="VmHostConnect" Content="Connect"/>',
        '                                <Button  Grid.Column="3" Name="VmHostChange"  Content="Change" VerticalAlignment="Center"/>',
        '                            </Grid>',
        '                            <Grid Grid.Row="3">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label    Grid.Column="0" Content="[Switch]:"/>',
        '                                <ComboBox Grid.Column="1" Name="VmControllerSwitch"/>',
        '                                <Label    Grid.Column="2" Content="[Network]:"/>',
        '                                <TextBox  Grid.Column="3" Name="VmControllerNetwork"/>',
        '                                <Label    Grid.Column="4" Content="[Gateway]:"/>',
        '                                <TextBox  Grid.Column="5" Name="VmControllerGateway"/>',
        '                            </Grid>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <TabControl Grid.Row="1">',
        '                        <TabItem Header="Control">',
        '                            <GroupBox  Header="[Selection]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Adds Node]: (Output/Existence) Validation"/>',
        '                                    <DataGrid Grid.Row="1" Name="VmSelect">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="125"/>',
        '                                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
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
        '                                            <DataGridTemplateColumn Header="Create VM" Width="60">',
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
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button   Grid.Column="0" Content="[Import] Adds Host Nodes"    Name="VmLoadAddsNode"/>',
        '                                        <Button   Grid.Column="1" Content="[Delete] Existent Nodes"     Name="VmDeleteNodes"/>',
        '                                        <Button   Grid.Column="2" Content="[Create] Non-existent Nodes" Name="VmCreateNodes"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Switch">',
        '                            <GroupBox Header="[Switch]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Provision]: Virtual Switches"/>',
        '                                    <DataGrid Grid.Row="1" Name="VmDhcpReservations">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Switch"       Binding="{Binding SwitchName}" Width="100"/>',
        '                                            <DataGridTemplateColumn Header="Sw. Exists" Width="80">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding SwitchExists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTemplateColumn Header="Res. Exists" Width="60">',
        '                                                <DataGridTemplateColumn.CellTemplate>',
        '                                                    <DataTemplate>',
        '                                                        <ComboBox SelectedIndex="{Binding Exists}" Margin="0" Padding="2" Height="18" FontSize="10" VerticalContentAlignment="Center">',
        '                                                            <ComboBoxItem Content="False"/>',
        '                                                            <ComboBoxItem Content="True"/>',
        '                                                        </ComboBox>',
        '                                                    </DataTemplate>',
        '                                                </DataGridTemplateColumn.CellTemplate>',
        '                                            </DataGridTemplateColumn>',
        '                                            <DataGridTextColumn Header="Sitename"     Binding="{Binding IPAddress}"   Width="125"/>',
        '                                            <DataGridTextColumn Header="ScopeID"      Binding="{Binding ScopeID}"     Width="125"/>',
        '                                            <DataGridTextColumn Header="MacAddress"   Binding="{Binding MacAddress}"  Width="*"/>',
        '                                            <DataGridTextColumn Header="Name"         Binding="{Binding Name}"        Width="*"/>',
        '                                            <DataGridTextColumn Header="Description"  Binding="{Binding Description}" Width="*"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Column="0" Content="[Scope ID]:"/>',
        '                                        <ComboBox Grid.Column="1" Name="VmDhcpScopeID"/>',
        '                                        <Label    Grid.Column="2" Content="[Start]:"/>',
        '                                        <TextBox  Grid.Column="3" Name="VmDhcpStart"/>',
        '                                        <Label    Grid.Column="4" Content="[End]:"/>',
        '                                        <TextBox  Grid.Column="5" Name="VmDhcpEnd"/>',
        '                                    </Grid>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button Grid.Column="0" Name="VmGetSwitch"    Content="[Get] Switch + Reservations"/>',
        '                                        <Button Grid.Column="1" Name="VmDeleteSwitch" Content="[Delete] Existent"/>',
        '                                        <Button Grid.Column="2" Name="VmCreateSwitch" Content="[Create] Non-existent"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Gateway">',
        '                            <GroupBox Header="[Gateway]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="120"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Provision]: (Physical/Virtual) Gateways]"/>',
        '                                    <DataGrid Grid.Row="1" Name="VmGateway">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                            <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                            <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                            <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                            <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                            <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                            <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                            <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                            <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                            <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                            <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                            <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                            <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                            <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                            <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
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
        '                                            <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                            <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[RAM/MB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Name="VmGatewayMemory"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="2" Content="[HDD/GB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="3" Name="VmGatewayDrive"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="4" Content="[Generation]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="5" Name="VmGatewayGeneration" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="1"/>',
        '                                            <ComboBoxItem Content="2"/>',
        '                                        </ComboBox>',
        '                                        <Label    Grid.Row="0" Grid.Column="6" Content="[Core]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="7" Name="VmGatewayCore"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="8" Content="[Type]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="9" Name="VmGatewayInstallType" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="ISO"/>',
        '                                            <ComboBoxItem Content="Network"/>',
        '                                        </ComboBox>',
        '                                    </Grid>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button  Grid.Row="0" Grid.Column="0" Name="VmGatewayPathSelect" Content="Path"/>',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Name="VmGatewayPath"/>',
        '                                        <Button  Grid.Row="1" Grid.Column="0" Name="VmGatewayImageSelect" Content="Image"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="1" Name="VmGatewayImage"/>',
        '                                        <Button  Grid.Row="2" Grid.Column="0" Name="VmGatewayScriptSelect" Content="Script"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="VmGatewayScript"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Server">',
        '                            <GroupBox Header="[Server]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="120"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Provision]: (Physical/Virtual) Servers"/>',
        '                                    <DataGrid Grid.Row="1" Name="VmServer">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                            <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                            <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                            <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                            <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                            <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                            <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                            <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                            <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                            <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                            <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                            <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                            <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                            <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                            <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
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
        '                                            <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                            <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[RAM/MB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Name="VmServerMemory"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="2" Content="[HDD/GB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="3" Name="VmServerDrive"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="4" Content="[Generation]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="5" Name="VmServerGeneration" SelectedIndex="1">',
        '                                            <ComboBoxItem Content="1"/>',
        '                                            <ComboBoxItem Content="2"/>',
        '                                        </ComboBox>',
        '                                        <Label    Grid.Row="0" Grid.Column="6" Content="[Core]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="7" Name="VmServerCore"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="8" Content="[Type]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="9" Name="VmServerInstallType" SelectedIndex="0">',
        '                                            <ComboBoxItem Content="ISO"/>',
        '                                            <ComboBoxItem Content="Network"/>',
        '                                        </ComboBox>',
        '                                    </Grid>',
        '                                    <Grid Grid.Row="3">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button  Grid.Row="0" Grid.Column="0" Name="VmServerPathSelect" Content="Path"/>',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Name="VmServerPath"/>',
        '                                        <Button  Grid.Row="1" Grid.Column="0" Name="VmServerImageSelect" Content="Image"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="1" Name="VmServerImage"/>',
        '                                        <Button  Grid.Row="2" Grid.Column="0" Name="VmServerScriptSelect" Content="Script"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="VmServerScript"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
        '                        </TabItem>',
        '                        <TabItem Header="Workstation">',
        '                            <GroupBox Header="[Workstation]">',
        '                                <Grid>',
        '                                    <Grid.RowDefinitions>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="*"/>',
        '                                        <RowDefinition Height="40"/>',
        '                                        <RowDefinition Height="120"/>',
        '                                    </Grid.RowDefinitions>',
        '                                    <Label Grid.Row="0" Content="[Provision]: (Physical/Virtual) Workstations"/>',
        '                                    <DataGrid Grid.Row="1" Name="VmWorkstation">',
        '                                        <DataGrid.Columns>',
        '                                            <DataGridTextColumn Header="Organization"        Binding="{Binding Organization}"      Width="150"/>',
        '                                            <DataGridTextColumn Header="CommonName"          Binding="{Binding CommonName}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Site"                Binding="{Binding Site}"              Width="120"/>',
        '                                            <DataGridTextColumn Header="Location"            Binding="{Binding Location}"          Width="150"/>',
        '                                            <DataGridTextColumn Header="Region"              Binding="{Binding Region}"            Width="80"/>',
        '                                            <DataGridTextColumn Header="Country"             Binding="{Binding Country}"           Width="60"/>',
        '                                            <DataGridTextColumn Header="Postal"              Binding="{Binding Postal}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Sitelink"            Binding="{Binding Sitelink}"          Width="120"/>',
        '                                            <DataGridTextColumn Header="Sitename"            Binding="{Binding Sitename}"          Width="250"/>',
        '                                            <DataGridTextColumn Header="Network"             Binding="{Binding Network}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Prefix"              Binding="{Binding Prefix}"            Width="60"/>',
        '                                            <DataGridTextColumn Header="Netmask"             Binding="{Binding Netmask}"           Width="125"/>',
        '                                            <DataGridTextColumn Header="Start"               Binding="{Binding Start}"             Width="125"/>',
        '                                            <DataGridTextColumn Header="End"                 Binding="{Binding End}"               Width="125"/>',
        '                                            <DataGridTextColumn Header="Range"               Binding="{Binding Range}"             Width="150"/>',
        '                                            <DataGridTextColumn Header="Broadcast"           Binding="{Binding Broadcast}"         Width="125"/>',
        '                                            <DataGridTextColumn Header="ReverseDNS"          Binding="{Binding ReverseDNS}"        Width="150"/>',
        '                                            <DataGridTextColumn Header="Type"                Binding="{Binding Type}"              Width="125"/>',
        '                                            <DataGridTextColumn Header="Hostname"            Binding="{Binding Hostname}"          Width="100"/>',
        '                                            <DataGridTextColumn Header="DnsName"             Binding="{Binding DnsName}"           Width="250"/>',
        '                                            <DataGridTextColumn Header="Parent"              Binding="{Binding Parent}"            Width="400"/>',
        '                                            <DataGridTextColumn Header="DistinguishedName"   Binding="{Binding DistinguishedName}" Width="400"/>',
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
        '                                            <DataGridTextColumn Header="Computer"            Binding="{Binding Computer.Name}"     Width="200"/>',
        '                                            <DataGridTextColumn Header="Guid"                Binding="{Binding Guid}"              Width="300"/>',
        '                                        </DataGrid.Columns>',
        '                                    </DataGrid>',
        '                                    <Grid Grid.Row="2">',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="60"/>',
        '                                            <ColumnDefinition Width="65"/>',
        '                                            <ColumnDefinition Width="90"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label    Grid.Row="0" Grid.Column="0" Content="[RAM/MB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="1" Name="VmWorkstationMemory"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="2" Content="[HDD/GB]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="3" Name="VmWorkstationDrive"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="4" Content="[Generation]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="5" Name="VmWorkstationGeneration" SelectedIndex="1">',
        '                                            <ComboBoxItem Content="1"/>',
        '                                            <ComboBoxItem Content="2"/>',
        '                                        </ComboBox>',
        '                                        <Label    Grid.Row="0" Grid.Column="6" Content="[Core]:"/>',
        '                                        <TextBox  Grid.Row="0" Grid.Column="7" Name="VmWorkstationCore"/>',
        '                                        <Label    Grid.Row="0" Grid.Column="8" Content="[Type]:"/>',
        '                                        <ComboBox Grid.Row="0" Grid.Column="9" Name="VmWorkstationInstallType" SelectedIndex="1">',
        '                                            <ComboBoxItem Content="ISO"/>',
        '                                            <ComboBoxItem Content="Network"/>',
        '                                        </ComboBox>',
        '                                    </Grid>',
        '                                    <Grid Grid.Row="4">',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="120"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Button  Grid.Row="0" Grid.Column="0" Name="VmWorkstationPathSelect" Content="Path"/>',
        '                                        <TextBox Grid.Row="0" Grid.Column="1" Name="VmWorkstationPath"/>',
        '                                        <Button  Grid.Row="1" Grid.Column="0" Name="VmWorkstationImageSelect" Content="Image"/>',
        '                                        <TextBox Grid.Row="1" Grid.Column="1" Name="VmWorkstationImage"/>',
        '                                        <Button  Grid.Row="2" Grid.Column="0" Name="VmWorkstationScriptSelect" Content="Script"/>',
        '                                        <TextBox Grid.Row="2" Grid.Column="1" Name="VmWorkstationScript"/>',
        '                                    </Grid>',
        '                                </Grid>',
        '                            </GroupBox>',
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
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Imaging]">',
        '                        <Grid>',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="120"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="120"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="120"/>',
        '                                <RowDefinition Height="40"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label Grid.Row="0" Content="[Images (*.iso) files found in source directory]"/>',
        '                            <Grid Grid.Row="2">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="110"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="100"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Label Grid.Column="0" Content="[Image Path]:"/>',
        '                                <TextBox Grid.Column="1" Name="IsoPath"/>',
        '                                <Button Name="IsoSelect" Grid.Column="2" Content="Select"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Row="1" Name="IsoList">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                    <DataGridTextColumn Header="Path" Binding="{Binding Path}" Width="2*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="3">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="IsoMount" Content="Mount" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="IsoDismount" Content="Dismount" IsEnabled="False"/>',
        '                            </Grid>',
        '                            <Border   Grid.Row="4" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label    Grid.Row="5" Content="[Image Viewer/Wim file selector]"/>',
        '                            <DataGrid Grid.Row="6" Name="IsoView">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Index" Binding="{Binding Index}" Width="40"/>',
        '                                    <DataGridTextColumn Header="Name"  Binding="{Binding Name}" Width="*"/>',
        '                                    <DataGridTextColumn Header="Size"  Binding="{Binding Size}" Width="100"/>',
        '                                    <DataGridTextColumn Header="Architecture" Binding="{Binding Architecture}" Width="100"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Grid Grid.Row="7">',
        '                                <Grid.ColumnDefinitions>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                    <ColumnDefinition Width="*"/>',
        '                                </Grid.ColumnDefinitions>',
        '                                <Button Grid.Column="0" Name="WimQueue" Content="Queue" IsEnabled="False"/>',
        '                                <Button Grid.Column="1" Name="WimDequeue" Content="Dequeue" IsEnabled="False"/>',
        '                            </Grid>',
        '                            <Border Grid.Row="8" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Label Grid.Row="9" Content="[Queued (*.wim) file extraction]"/>',
        '                            <Grid Grid.Row="10">',
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
        '                            <Grid Grid.Row="11">',
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
        '                <GroupBox Header="[Updates]">',
        '                    <Grid>',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="10"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="*"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Label    Grid.Row="0" Content="[Aggregate]: Update file source directory"/>',
        '                        <DataGrid Grid.Row="1"  Name="UpdAggregate">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="200"/>',
        '                                <DataGridTextColumn Header="Value" Binding="{Binding Value}" Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid     Grid.Row="2">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="60"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                                <ColumnDefinition Width="40"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Button  Grid.Column="0" Name="UpdSelect" Content="Path"/>',
        '                            <TextBox Grid.Column="1" Name="UpdPath"/>',
        '                            <Button  Grid.Column="2" Name="UpdAddUpdate" Content="+"/>',
        '                            <Button  Grid.Column="3" Name="UpdRemoveUpdate" Content="-"/>',
        '                        </Grid>',
        '                        <Border   Grid.Row="3" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Label    Grid.Row="4" Content="[Viewer]: View (properties/attributes) of update files"/>',
        '                        <DataGrid Grid.Row="5" Name="UpdViewer">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>',
        '                                <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Border   Grid.Row="6" Background="Black" BorderThickness="0" Margin="4"/>',
        '                        <Label    Grid.Row="7" Content="[Update]: Selected (*.wim) file(s) to inject the update(s)"/>',
        '                        <DataGrid Grid.Row="8" Name="UpdWim">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>',
        '                                <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="*"/>',
        '                                <DataGridCheckBoxColumn Header="Install" Binding="{Binding Install}" Width="50"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                        <Grid Grid.Row="9">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Button Grid.Column="0" Name="UpdInstallUpdate" Content="Install"/>',
        '                            <Button Grid.Column="1" Name="UpdUninstallUpdate" Content="Uninstall"/>',
        '                        </Grid>',
        '                    </Grid>',
        '                </GroupBox>',
        '            </TabItem>',
        '            <TabItem Header="Share">',
        '                <Grid>',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                        <RowDefinition Height="40"/>',
        '                    </Grid.RowDefinitions>',
        '                    <GroupBox Grid.Row="0" Header="[Share]">',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.RowDefinitions>',
        '                                <RowDefinition Height="40"/>',
        '                                <RowDefinition Height="120"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="120"/>',
        '                                <RowDefinition Height="10"/>',
        '                                <RowDefinition Height="*"/>',
        '                            </Grid.RowDefinitions>',
        '                            <Label    Grid.Row="0" Content="[Aggregate]: (Existent/Provisioned) Deployment Shares &amp; FileSystem, PSDrive, (MDT/PSD), SMB Share, Description"/>',
        '                            <DataGrid Grid.Row="1" Name="DsAggregate"',
        '                                  ScrollViewer.CanContentScroll="True" ',
        '                                  ScrollViewer.IsDeferredScrollingEnabled="True"',
        '                                  ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Name"        Binding="{Binding Name}" Width="60"/>',
        '                                    <DataGridTextColumn Header="Type"        Binding="{Binding Type}" Width="60"/>',
        '                                    <DataGridTextColumn Header="Root"        Binding="{Binding Root}" Width="250"/>',
        '                                    <DataGridTextColumn Header="Share"       Binding="{Binding Share}" Width="150"/>',
        '                                    <DataGridTextColumn Header="Description" Binding="{Binding Description}" Width="350"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                            <Border   Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <Grid     Grid.Row="3">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Grid Grid.Row="0">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label   Grid.Column="0" Content="[Root]:"/>',
        '                                    <Button  Grid.Column="1" Name="DsRootSelect" Content="Browse"/>',
        '                                    <TextBox Grid.Column="2" Name="DsRootPath"/>',
        '                                </Grid>',
        '                                <Grid Grid.Row="1">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="120"/>',
        '                                        <ColumnDefinition Width="80"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0" Content="[Drive]:"/>',
        '                                    <TextBox  Grid.Column="1"  Name="DsDriveName"/>',
        '                                    <Label    Grid.Column="2" Content="[Share]:"/>',
        '                                    <TextBox  Grid.Column="3" Name="DsShareName"/>',
        '                                    <Label    Grid.Column="4" Content="[Type]:"/>',
        '                                    <ComboBox Grid.Column="5" Name="DsType">',
        '                                        <ComboBoxItem Content="MDT"/>',
        '                                        <ComboBoxItem Content="PSD"/>',
        '                                        <ComboBoxItem Content="-"/>',
        '                                    </ComboBox>',
        '                                </Grid>',
        '                                <Grid Grid.Row="2">',
        '                                    <Grid.ColumnDefinitions>',
        '                                        <ColumnDefinition Width="110"/>',
        '                                        <ColumnDefinition Width="*"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                        <ColumnDefinition Width="40"/>',
        '                                    </Grid.ColumnDefinitions>',
        '                                    <Label    Grid.Column="0" Content="[Description]:"/>',
        '                                    <TextBox  Grid.Column="1" Name="DsDescription"/>',
        '                                    <Button   Grid.Column="2" Name="DsAddShare" Content="+"/>',
        '                                    <Button   Grid.Column="3" Name="DsRemoveShare" Content="-"/>',
        '                                </Grid>',
        '                            </Grid>',
        '                            <Border   Grid.Row="4" Background="Black" BorderThickness="0" Margin="4"/>',
        '                            <TabControl Grid.Row="5">',
        '                                <TabItem Header="Import">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label Grid.Row="0" Content="[Import]: Operating Systems &amp; Task Sequences"/>',
        '                                        <Grid  Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button   Grid.Row="0" Grid.Column="0" Name="DsImportSelectWimFilePath" Content="Select"/>',
        '                                            <TextBox  Grid.Row="0" Grid.Column="1" Name="DsImportWimFilePath"/>',
        '                                            <ComboBox Grid.Row="0" Grid.Column="2" Name="DsImportWimFileMode"/>',
        '                                        </Grid>',
        '                                        <DataGrid Grid.Row="2" Name="DsImportWimFiles"',
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
        '                                </TabItem>',
        '                                <TabItem Header="Current">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label Grid.Row="0" Content="[Current]: Operating Systems &amp; Task Sequences"/>',
        '                                        <Grid  Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button   Grid.Row="0" Grid.Column="0" Name="DsCurrentSelectWimFilePath" Content="Select"/>',
        '                                            <TextBox  Grid.Row="0" Grid.Column="1" Name="DsCurrentWimFilePath"/>',
        '                                            <ComboBox Grid.Row="0" Grid.Column="2" Name="DsCurrentWimFileMode"/>',
        '                                        </Grid>',
        '                                        <DataGrid Grid.Row="2" Name="DsCurrentWimFiles"',
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
        '                                </TabItem>',
        '                                <TabItem Header="Domain/Network">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="80"/>',
        '                                            <RowDefinition Height="10"/>',
        '                                            <RowDefinition Height="120"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label Grid.Row="0" Content="[Domain/Network]: Credential &amp; (Server/Share) Information"/>',
        '                                        <Grid  Grid.Row="1">',
        '                                            <Grid.RowDefinitions>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                            </Grid.RowDefinitions>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button      Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Name="DsLogin" Content="Domain Admin Login [Populates all fields except Machine OU]"/>',
        '                                            <Label       Grid.Row="0" Grid.Column="2" Content="[Username]:"/>',
        '                                            <TextBox     Grid.Row="0" Grid.Column="3" Name="DsDcUsername"/>',
        '                                            <Label       Grid.Row="1" Grid.Column="0" Content="[Password]:"/>',
        '                                            <PasswordBox Grid.Row="1" Grid.Column="1" Name="DsDcPassword" HorizontalContentAlignment="Left"/>',
        '                                            <Label       Grid.Row="1" Grid.Column="2" Content="[Confirm]:"/>',
        '                                            <PasswordBox Grid.Row="1" Grid.Column="3" Name="DsDcConfirm"  HorizontalContentAlignment="Left"/>',
        '                                        </Grid>',
        '                                        <Border          Grid.Row="2" Background="Black" BorderThickness="0" Margin="4"/>',
        '                                        <Grid Grid.Row="3">',
        '                                            <Grid.RowDefinitions>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="10"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                            </Grid.RowDefinitions>',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="225"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Label       Grid.Row="0" Grid.Column="0" Content="[NetBios]:"/>',
        '                                            <TextBox     Grid.Row="0" Grid.Column="1" Name="DsNetBiosName" ToolTip="NetBIOS name of the deployment share (server/domain)"/>',
        '                                            <Label       Grid.Row="0" Grid.Column="2" Content="[Dns]:"/>',
        '                                            <TextBox     Grid.Row="0" Grid.Column="3" Name="DsDnsName" ToolTip="Dns name of the deployment share (server/domain)"/>',
        '                                            <Label       Grid.Row="1" Grid.Column="0" Content="[Org. Name]:"/>',
        '                                            <TextBox     Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3" Name="DsOrganization" ToolTip="Name of the organization"/>',
        '                                            <Button      Grid.Row="2" Grid.Column="0" Name="DsMachineOUSelect" Content="Machine OU"/>',
        '                                            <TextBox     Grid.Row="2" Grid.Column="1" Grid.ColumnSpan="3" Name="DsMachineOu" ToolTip="Adds Organizational Unit where the nodes are installed"/>',
        '                                        </Grid>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                                <TabItem Header="Local/Branding">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="10"/>',
        '                                            <RowDefinition Height="80"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Grid.ColumnDefinitions>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                            <ColumnDefinition Width="100"/>',
        '                                            <ColumnDefinition Width="*"/>',
        '                                        </Grid.ColumnDefinitions>',
        '                                        <Label       Grid.Row="0" Grid.ColumnSpan="4" Content="[Local/Branding]: Local Administrator &amp; Branding Information"/>',
        '                                        <Label       Grid.Row="1" Grid.Column="0" Content="[Username]:"/>',
        '                                        <TextBox     Grid.Row="1" Grid.Column="1" Name="DsLmUsername"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="0" Content="[Password]:"/>',
        '                                        <PasswordBox Grid.Row="2" Grid.Column="1" Name="DsLmPassword" HorizontalContentAlignment="Left"/>',
        '                                        <Label       Grid.Row="2" Grid.Column="2" Content="[Confirm]:"/>',
        '                                        <PasswordBox Grid.Row="2" Grid.Column="3" Name="DsLmConfirm"/>',
        '                                        <Border      Grid.Row="3" Grid.ColumnSpan="4"  Background="Black" BorderThickness="0" Margin="4"/>',
        '                                        <Button      Grid.Row="4" Grid.Column="0" Name="DsBrCollect" Content="Collect" Height="70"/>',
        '                                        <Grid        Grid.Row="4" Grid.Column="1" Grid.ColumnSpan="3">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="180"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Grid.RowDefinitions>',
        '                                                <RowDefinition Height="40"/>',
        '                                                <RowDefinition Height="40"/>',
        '                                            </Grid.RowDefinitions>',
        '                                            <Label   Grid.Row="0" Grid.Column="0" Content="[Phone]:"/>',
        '                                            <TextBox Grid.Row="0" Grid.Column="1" Name="DsBrPhone"/>',
        '                                            <Label   Grid.Row="0" Grid.Column="2" Content="[Hours]:"/>',
        '                                            <TextBox Grid.Row="0" Grid.Column="3" Name="DsBrHours"/>',
        '                                            <Label   Grid.Row="1" Grid.Column="0" Content="[Website]:"/>',
        '                                            <TextBox Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="3"  Name="DsBrWebsite"/>',
        '                                        </Grid>',
        '                                        <Button   Grid.Row="5" Grid.Column="0" Name="DsBrLogoSelect" Content="Logo"/>',
        '                                        <TextBox  Grid.Row="5" Grid.Column="1" Grid.ColumnSpan="3" Name="DsBrLogo"/>',
        '                                        <Button   Grid.Row="6" Grid.Column="0" Name="DsBrBackgroundSelect" Content="Background"/>',
        '                                        <TextBox  Grid.Row="6" Grid.Column="1" Grid.ColumnSpan="3" Name="DsBrBackground"/>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                                <TabItem Header="Bootstrap">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label   Grid.Row="0" Content="[Bootstrap]: Directly edit (Bootstrap.ini)"/>',
        '                                        <Grid    Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button Grid.Column="0" Name="DsGenerateBootstrap" Content="Generate"/>',
        '                                            <TextBox Grid.Column="1" Name="DsBootstrapPath"/>',
        '                                            <Button Grid.Column="2" Name="DsSelectBootstrap" Content="Select"/>',
        '                                        </Grid>',
        '                                        <TextBox Grid.Row="2" Height="200" Background="White" Name="DsBootstrap" Style="{StaticResource Block}"/>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                                <TabItem Header="Custom Settings">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label   Grid.Row="0" Content="[Custom Settings]: Directly edit (CustomSettings.ini)"/>',
        '                                        <Grid Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button  Grid.Column="0" Name="DsGenerateCustomSettings" Content="Generate"/>',
        '                                            <TextBox Grid.Column="1" Name="DsCustomSettingsPath"/>',
        '                                            <Button  Grid.Column="2" Name="DsSelectCustomSettings" Content="Select"/>',
        '                                        </Grid>',
        '                                        <TextBox Grid.Row="2" Height="200" Background="White" Name="DsCustomSettings" Style="{StaticResource Block}"/>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                                <TabItem Header="Post Configuration">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label   Grid.Row="0" Content="[Post Configuration]: Directly edit (Install-FightingEntropy.ps1)"/>',
        '                                        <Grid Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button  Grid.Column="0" Name="DsGeneratePostConfig" Content="Generate"/>',
        '                                            <TextBox Grid.Column="1" Name="DsPostConfigPath"/>',
        '                                            <Button  Grid.Column="2" Name="DsSelectPostConfig" Content="Select"/>',
        '                                        </Grid>',
        '                                        <TextBox Grid.Row="2" Height="200" Background="White" Name="DsPostConfig" Style="{StaticResource Block}"/>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                                <TabItem Header="DS Key">',
        '                                    <Grid>',
        '                                        <Grid.RowDefinitions>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="40"/>',
        '                                            <RowDefinition Height="*"/>',
        '                                        </Grid.RowDefinitions>',
        '                                        <Label   Grid.Row="0" Content="[Deployment Share Key]: Directly edit (DSKey.csv)"/>',
        '                                        <Grid Grid.Row="1">',
        '                                            <Grid.ColumnDefinitions>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                                <ColumnDefinition Width="*"/>',
        '                                                <ColumnDefinition Width="100"/>',
        '                                            </Grid.ColumnDefinitions>',
        '                                            <Button  Grid.Column="0" Name="DsGenerateDSKey" Content="Generate"/>',
        '                                            <TextBox Grid.Column="1" Name="DsDSKeyPath"/>',
        '                                            <Button  Grid.Column="2" Name="DsSelectDSKey" Content="Select"/>',
        '                                        </Grid>',
        '                                        <TextBox Grid.Row="2" Height="200" Background="White" Name="DsDSKey" Style="{StaticResource Block}"/>',
        '                                    </Grid>',
        '                                </TabItem>',
        '                            </TabControl>',
        '                        </Grid>',
        '                    </GroupBox>',
        '                    <Grid Grid.Row="1">',
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
        Hidden [Object]       $Time
        Hidden [Object]  $Container
        Hidden [Object]   $Validate
        Main()
        {
            $This.Module          = Get-FEModule
            $This.Connection      = Get-FEADLogin
            If (!$This.Connection)
            {
                Write-Error "Could not log into server"
                Break
            }
            Else
            {
                $This.Time = [System.Diagnostics.Stopwatch]::StartNew()
                $This.Log("[~] Initializing")
            }
            $This.Credential      = $This.Connection.Credential

            # Pulls system information
            $This.Module.Role.GetSystem()

            # Assigns system information to system variable
            $This.System            = $This.Module.Role.System
            $This.Log("[+] System")

            # Pulls configuration information (Network/DHCP/DNS/ADDS/Hyper-V/WDS/MDT/WinADK/WinPE/IIS)
            $This.Config            = Config -Module $This.Module
            $This.Log("[+] Config")

            # Pulls sitelist base and classes
            $This.SiteList          = Sitelist -Module $This.Module
            $This.Log("[+] SiteList")

            # Pulls networklist base and classes
            $This.NetworkList       = NetworkList
            $This.Log("[+] NetworkList")

            # Load and sort/rename module files
            ForEach ($Item in $This.Module.Tree.Name)
            {
                $This.Module.$Item  = @( $This.Module.$Item | % { [ModuleFile]$_ })
            }

            # Domain Controller
            $This.Sitemap           = Sitemap
            $This.Log("[+] Sitemap")

            # AD Controller
            $This.AddsController    = AddsController
            $This.Log("[+] AddsController")

            # VM Controller
            If ($This.Config.HyperV)
            {
                $This.VmController  = VmController -Hostname localhost -Credential $This.Credential
                $This.Log("[+] VmController")
            }

            # Imaging Controller
            $This.ImageController   = ImageController
            $This.Log("[+] ImageController")

            # Update Controller
            $This.UpdateController  = UpdateController
            $This.Log("[+] UpdateController")

            # Mdt Controller
            $This.MdtController     = MdtController -Module $This.Module
            $This.Log("[+] MdtController")

            # Wds Controller
            $This.WdsController     = WdsController
            $This.Log("[+] WdsController")

            $This.Time.Stop()
            $This.Log("[+] Initialized")
        }
        Log([String]$Message)
        {
            Write-Host "[$($This.Time.Elapsed)] $Message"
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
            $This.Organization   = $Organization
            $This.CommonName     = $CommonName
            $This.Sitelist       | % SetDomain $Organization $CommonName
            $This.NetworkList    | % SetDomain $Organization $CommonName
            $This.Sitemap        | % SetDomain $Organization $CommonName
            $This.AddsController | % SetDomain $Organization $CommonName
        }
        [Object] List([String]$Name,[Object]$Value)
        {
            Return [DGList]::New($Name,$Value)
        }
        [String[]] Reserved()
        {
            Return @(("ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GROUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;" + 
            "DIALUP;DIGEST AUTH;INTERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AUTHORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMO" +
            "TE INTERACTIVE;RESTRICTED;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORGANIZATION;USERS;WORLD") -Split ";" )
        }
        [String[]] Legacy()
        {
            Return @("-GATEWAY","-GW","-TAC")
        }
        [String[]] SecurityDescriptors()
        {
            Return @(("AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO,RS,RU,SA," +
            "SI,SO,SU,SY,WD") -Split ',')
        }
        Reset([Object]$Sender,[Object[]]$Content)
        {
            $Sender.Clear()
            ForEach ($Item in $Content)
            {
                $Sender.Add($Item)
            }
        }
        [String] CheckHostname([String]$String)
        {                
            If ($String.Length -lt 1 -or $String.Length -gt 15)
            {
                Return "[!] Length not between 1 and 15 characters"
            }
            ElseIf ($String -in $This.Reserved())
            {
                Return "[!] Entry is in reserved words list"
            }
            ElseIf ($String -in $This.Legacy())
            {
                Return "[!] Entry is in the legacy words list"
            }
            ElseIf ($String -notmatch "([\-0-9a-zA-Z])")
            { 
                Return "[!] Invalid characters"
            }
            ElseIf ($String[0] -match "(\W)" -or $String[-1] -match "(\W)")
            {
                Return "[!] First/Last Character cannot be a '.' or '-'"
            }                        
            ElseIf ($String -match "\.")
            {
                Return "[!] Hostname cannot contain a '.'"
            }
            ElseIf ($String -in $This.SecurityDescriptors())
            {
                Return "[!] Matches a security descriptor"
            }
            Else
            {
                Return $String
            }
        }
    }

    $Main = [Main]::New()
    $Xaml = [XamlWindow][FEInfrastructureGUI]::Tab

    # ---------------- #
    # <![Module Tab]!> #
    # ---------------- #

    # [Module.Information]
    $Content = ForEach ( $Item in "Base Name Description Author Company Copyright GUID Version Date RegPath Default Main Trunk ModPath ManPath Path Status" -Split " ")
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
    }
    $Main.Reset($Xaml.IO.Module_Info.Items,$Content)

    # [Module.Components]
    $Main.Reset($Xaml.IO.Module_Type.Items,$Main.Module.Tree)
    $Xaml.IO.Module_Type.SelectedIndex   = 0
    
    $Main.Reset($Xaml.IO.Module_Property.Items,"Name")
    $Xaml.IO.Module_Property.SelectedIndex = 0
    
    $Xaml.IO.Module_Filter.Text            = $Null
    $Xaml.IO.Module_Type.Add_SelectionChanged(
    {
        $Xaml.IO.Module_Filter.Text        = $Null
        $Main.Reset($Xaml.IO.Module_List.Items,$Main.Module."$($Xaml.IO.Module_Type.SelectedItem)")
        Start-Sleep -Milliseconds 50
    })

    $Xaml.IO.Module_Filter.Add_TextChanged(
    {
        $Main.Reset($Xaml.IO.Module_List.Items,@($Main.Module."$($Xaml.IO.Module_Type.SelectedItem)" | ? $Xaml.IO.Module_Property.SelectedItem -match $Xaml.IO.Module_Filter.Text))
        Start-Sleep -Milliseconds 50
    })

    $Main.Reset($Xaml.IO.Module_List.Items,$Main.Module.Classes)

    # ---------------- #
    # <![Config Tab]!> #
    # ---------------- #

    # [Config.Output]
    $Main.Reset($Xaml.IO.CfgServices.Items,$Main.Config.Output)

    # [Config.Role]
    $Content = ForEach ( $Item in "Name DNS NetBIOS Hostname Username IsAdmin Caption Version Build ReleaseID Code SKU Chassis" -Split " ")
    {
        [DGList]::New($Item,$Main.Module.Role.$Item)
    }
    $Main.Reset($Xaml.IO.Role_Info.Items,$Content)

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
    $Main.Reset($Xaml.IO.System_Processor.Items,$Main.System.Processor.Name)
    $Xaml.IO.System_Processor.SelectedIndex           = 0
    
    $Main.Reset($Xaml.IO.System_Architecture.Items,@("x86","x64"))
    $Xaml.IO.System_Architecture.SelectedIndex        = $Main.System.Architecture -eq "x64"
    $Xaml.IO.System_Architecture.IsEnabled            = 0
    
    # [Config.System.Chassis]
    $Xaml.IO.System_IsVM.IsChecked                    = 0

    $Main.Reset($Xaml.IO.System_Chassis.Items,@("Desktop;Laptop;Small Form Factor;Server;Tablet" -Split ";"))
    $Xaml.IO.System_Chassis.SelectedIndex             = @{Desktop=0;Laptop=1;"Small Form Factor"=2;Server=3;Tablet=4}[$Main.System.Chassis]
    $Xaml.IO.System_Chassis.IsEnabled                 = 0
    
    $Main.Reset($Xaml.IO.System_BiosUefi.Items,@("BIOS","UEFI"))
    $Xaml.IO.System_BiosUefi.SelectedIndex            = $Main.System.BiosUEFI -eq "UEFI"
    $Xaml.IO.System_BiosUefi.IsEnabled                = 0
    
    $Xaml.IO.System_Name.Text                         = $Main.GetHostname()
    
    # [Config.System.Disks]
    $Main.Reset($Xaml.IO.System_Disk.Items,$Main.System.Disk)

    # [Config.Network]
    $Main.Reset($Xaml.IO.Network_Adapter.Items,$Main.System.Network)
    $Xaml.IO.Network_Adapter.Add_SelectionChanged(
    {
        If ($Xaml.IO.Network_Adapter.SelectedIndex -ne -1)
        {
            $Main.SetNetwork($Xaml,$Xaml.IO.Network_Adapter.SelectedIndex)
        }
    })

    $Main.Reset($Xaml.IO.Network_Type.Items,@("DHCP","Static"))
    $Xaml.IO.Network_Type.SelectedIndex               = 0
    
    $Main.SetNetwork($Xaml,0)

    $Xaml.IO.Network_Type.Add_SelectionChanged(
    {
        $Main.SetNetwork($Xaml,$Xaml.IO.Network_Type.SelectedIndex)
    })

    # [Config.Dhcp]
    $Main.Reset($Xaml.IO.CfgDhcpScopeID.Items,$Main.Config.Dhcp)
    $Xaml.IO.CfgDhcpScopeID.Add_SelectionChanged(
    {
        If ($Xaml.IO.CfgDhcpScopeID.SelectedIndex -ne -1)
        {
            $Scope = $Xaml.IO.CfgDhcpScopeID.SelectedItem
            $Main.Reset($Xaml.IO.CfgDhcpScopeReservations.Items,$Scope.Reservations)
            $Main.Reset($Xaml.IO.CfgDhcpScopeOptions.Items,$Scope.Options )
        }
    })

    # [Config.Dns]
    $Main.Reset($Xaml.IO.CfgDnsZone.Items,$Main.Config.Dns)
    $Xaml.IO.CfgDnsZone.Add_SelectionChanged(
    {
        If ($Xaml.IO.CfgDnsZone.SelectedIndex -ne -1)
        {
            $Zone = $Xaml.IO.CfgDnsZone.SelectedItem

            $Main.Reset($Xaml.IO.CfgDnsZoneHosts.Items,$Zone.Hosts)
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

    $Main.Reset($Xaml.IO.CfgAddsType.Items,@("Site","Sitelink","Subnet","Dhcp","OU","Computer"))
    $Xaml.IO.CfgAddsType.SelectedIndex     = 0

    $Main.Reset($Xaml.IO.CfgAddsProperty.Items,@("Name","GUID","DistinguishedName"))
    $Xaml.IO.CfgAddsProperty.SelectedIndex = 0

    $Xaml.IO.CfgAddsType.Add_SelectionChanged(
    {
        Start-Sleep -Milliseconds 50
        $Xaml.IO.CfgAddsFilter.Text        = $Null
        $Main.Reset($Xaml.IO.CfgAddsObject.Items,$Main.Config.Adds."$($Xaml.IO.CfgAddsType.SelectedItem)")
    })

    $Xaml.IO.CfgAddsFilter.Add_TextChanged(
    {
        Start-Sleep -Milliseconds 50
        $Main.Reset($Xaml.IO.CfgAddsObject.Items,@($Main.Config.Adds."$($Xaml.IO.CfgAddsType.SelectedItem)" | ? $Xaml.IO.CfgAddsProperty.SelectedItem -match $Xaml.IO.CfgAddsFilter.Text))
    })

    # [Config.HyperV]
    If ($Main.Config.HyperV)
    {
        $Xaml.IO.VmHostName.Text           = $Main.HyperV.Name
        $Main.Reset($Xaml.IO.CfgHyperV.Items,$Main.Config.HyperV)
    }

    # [Config.Wds]
    $Xaml.IO.WDS_Server.Text              = $Main.Config.WDS.Server
    $Main.Reset($Xaml.IO.WDS_IPAddress.Items,$Main.Config.WDS.IPAddress)
    $Xaml.IO.WDS_IPAddress.SelectedIndex  = 0

    # [Config.Mdt]
    $Xaml.IO.MDT_Server.Text              = $Main.Config.MDT.Server
    $Main.Reset($Xaml.IO.MDT_IPAddress.Items,$Main.Config.MDT.IPAddress)
    $Xaml.IO.MDT_IPAddress.SelectedIndex  = 0
    
    $Xaml.IO.MDT_Path.Text                = $Main.Config.MDT.Path
    $Xaml.IO.MDT_Version.Text             = $Main.Config.MDT.Version
    $Xaml.IO.MDT_ADK_Version.Text         = $Main.Config.MDT.AdkVersion
    $Xaml.IO.MDT_PE_Version.Text          = $Main.Config.MDT.PeVersion

    # [Config.IIS]
    $Main.Reset($Xaml.IO.IIS_AppPools.Items,$Main.Config.IIS.AppPools)
    $Main.Reset($Xaml.IO.IIS_Sites.Items,$Main.Config.IIS.Sites)

    # ------------------------- #
    # <![Domain/SiteList Tab]!> #
    # ------------------------- #

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
            $Main.Reset($Xaml.IO.DcAggregate.Items,$Main.Sitelist.Aggregate)
            $Xaml.IO.DcGetSitename.IsEnabled   = 0
            $Xaml.IO.NwScopeLoad.IsEnabled     = 1
        }
    })

    $Xaml.IO.DcAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.DcAggregate.SelectedItem
        If ($Object)
        {
            $Main.Reset($Xaml.IO.DcViewer.Items,@($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) }))
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
            $Main.Reset($Xaml.IO.DcAggregate.Items,$Main.Sitelist.Aggregate)
            $Xaml.IO.DcAddSitenameZip.Text    = ""
        }
    })

    $Xaml.IO.DcRemoveSitename.Add_Click(
    {
        If ($Xaml.IO.DcAggregate.SelectedIndex -gt -1)
        {
            $Object                           = $Xaml.IO.DcAggregate.SelectedItem
            If ($Xaml.IO.DcViewer.Items | ? Name -eq Postal | ? Value -eq $Object.Postal)
            {
                $Xaml.IO.DcViewer.Items.Clear()
            }
            $Main.Sitelist.Aggregate          = $Main.Sitelist.Aggregate | ? Postal -ne $Object.Postal 
            $Main.Reset($Xaml.IO.DcAggregate.Items,$Main.Sitelist.Aggregate)

        }
    })

    $Xaml.IO.DcGetTopology.Add_Click(
    {
        $Main.Sitelist.GetSiteList()
        $Main.Reset($Xaml.IO.DcTopology.Items,$Main.Sitelist.Topology)
        $Xaml.IO.SmSiteCount.Text         = $Main.Sitelist.Topology.Count
    })
    
    $Xaml.IO.DcNewTopology.Add_Click(
    {
        $Main.Sitelist.NewSiteList()
        $Main.Reset($Xaml.IO.DcTopology.Items,$Main.Sitelist.Topology)
        $Xaml.IO.SmSiteCount.Text         = $Main.Sitelist.Topology.Count
    })

    # ----------------------------- #
    # <![Network/NetworkList Tab]!> #
    # ----------------------------- #

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
            $Main.Reset($Xaml.IO.NwAggregate.Items,$Main.NetworkList.Aggregate)
        }
    })

    $Xaml.IO.NwAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.NwAggregate.SelectedItem
        $Xaml.IO.NwViewer.Items.Clear()
        If ($Object)
        {
            $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
            $Main.Reset($Xaml.IO.NwViewer.Items,$Content)
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
            $Main.Reset($Xaml.IO.NwAggregate.Items,$Main.NetworkList.Aggregate)
        }
    })

    $Xaml.IO.NwRemoveSubnetName.Add_Click(
    {
        If ($Xaml.IO.NwAggregate.SelectedIndex -gt -1)
        {
            $Object                           = $Xaml.IO.NwAggregate.SelectedItem
            $Main.NetworkList.Aggregate       = $Main.NetworkList.Aggregate | ? Name -ne $Object.Name
            $Main.Reset($Xaml.IO.NwAggregate.Items,$Main.NetworkList.Aggregate)
            If ($Xaml.IO.NwViewer.ItemsSource | ? Name -eq Name | ? Value -eq $Object.Name)
            {
                $Xaml.IO.NwViewer.Items.Clear()
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
        $Main.Reset($Xaml.IO.NwTopology.Items,$Main.NetworkList.Topology)
        $Xaml.IO.SmNetworkCount.Text      = $Main.NetworkList.Topology.Count
    })

    $Xaml.IO.NwNewSubnetName.Add_Click(
    {
        $Main.NetworkList.NewNetworkList()
        $Main.Reset($Xaml.IO.NwTopology.Items,$Main.NetworkList.Topology)
        $Xaml.IO.SmNetworkCount.Text      = $Main.NetworkList.Topology.Count
    })

    # ----------------- #
    # <![Sitemap Tab]!> #
    # ----------------- #

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

            $Main.Reset($Xaml.IO.SmAggregate.Items, $Main.Sitemap.Aggregate)
            $Main.Reset($Xaml.IO.SmSiteLink.Items,  $Main.Sitemap.Sitelink)
            $Main.Reset($Xaml.IO.SmTemplate.Items,  $Main.Sitemap.Template.Output)
        }
    })

    $Xaml.IO.SmAggregate.Add_SelectionChanged(
    {
        $Object                                = $Xaml.IO.SmAggregate.SelectedItem
        If ($Object)
        {
            $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
            $Main.Reset($Xaml.IO.SmViewer.Items,$Content)
        }
    })

    $Xaml.IO.SmGetSitemap.Add_Click(
    {
        $Main.Sitemap.GetSitemap()
        $Main.Reset($Xaml.IO.SmTopology.Items,$Main.Sitemap.Topology)
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
            $Main.Reset($Xaml.IO.AddsSite.Items,$Main.AddsController.Sitemap.Name)
            $Xaml.IO.AddsSite.SelectedIndex = 0
        }
    })

    # -------------- #
    # <![Adds Tab]!> #
    # -------------- #

    # [Adds.Site]
    $Xaml.IO.AddsSite.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSite.SelectedIndex -ne -1)
        {
            $Object                                = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]

            # Site TextBox
            $Xaml.IO.AddsSiteName.Text             = $Object.Template.Site.Name
            
            # Subnet TextBox
            $Xaml.IO.AddsSubnetName.Text           = $Object.Template.Subnet.Name

            # Viewer
            $Content = @($Object.Control.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
            $Main.Reset($Xaml.IO.AddsViewer.Items,$Content)

            # Children
            $Main.Reset($Xaml.IO.AddsChildren.Items,$Object.Main.Children)

            $Main.AddsController.GetNodeList()

            # Gateway
            $Main.Reset($Xaml.IO.AddsGwAggregate.Items,   $Main.AddsController.Gateway)

            # Server
            $Main.Reset($Xaml.IO.AddsSrAggregate.Items,   $Main.AddsController.Server)

            # Workstation
            $Main.Reset($Xaml.IO.AddsWsAggregate.Items,   $Main.AddsController.Workstation)

            # User
            $Main.Reset($Xaml.IO.AddsUserAggregate.Items, $Main.AddsController.User)

            # Service
            $Main.Reset($Xaml.IO.AddsSvcAggregate.Items,  $Main.AddsController.Service)
        }
    })

    $Xaml.IO.AddsSiteDefaults.Add_Click(
    {
        ForEach ($Site in $Main.AddsController.Sitemap)
        {
            ForEach ($Container in $Site.Gateway, $Site.Server, $Site.Workstation, $Site.User, $Site.Service)
            {
                $Item = Switch ($Container.Type)
                {
                    Gateway     { $Container.NewNode($Site.Name)                       }
                    Server      { $Container.NewNode("dc1-$($Site.Control.Postal)")    }
                    Workstation { $Container.NewNode("ws1-$($Site.Control.Postal)")    }
                    User        { $Container.NewNode("adm1-$($Site.Control.Postal)")   }
                    Service     { $Container.NewNode("svc1-$($Site.Control.Postal)")   }
                }
                $Main.AddsController.Validate($Item)
                $Container.AddNode($Item)
            }
        }
        
        $Main.AddsController.GetNodeList()

        $Main.Reset($Xaml.IO.AddsGwAggregate.Items,   $Main.AddsController.Gateway)
        $Main.Reset($Xaml.IO.AddsSrAggregate.Items,   $Main.AddsController.Server)
        $Main.Reset($Xaml.IO.AddsWsAggregate.Items,   $Main.AddsController.Workstation)
        $Main.Reset($Xaml.IO.AddsUserAggregate.Items, $Main.AddsController.User)
        $Main.Reset($Xaml.IO.AddsSvcAggregate.Items,  $Main.AddsController.Service)

        # Viewer
        $Object  = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Content = @($Object.Control.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
        $Main.Reset($Xaml.IO.AddsViewer.Items,$Content)
        
        # Children
        $Main.Reset($Xaml.IO.AddsChildren.Items,$Object.Main.Children)
    })

    # [Adds.Gateway]
    $Xaml.IO.AddsGwAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Main.CheckHostname($Xaml.IO.AddsGwName.Text)

        If ($Name -ne $Xaml.IO.AddsGwName.Text)
        {
            Return [System.Windows.MessageBox]::Show($Name,"Error")
        }

        ElseIf (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in $Xaml.IO.AddsGwAggregate.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists","Error")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"Gateway",$Name)
            $Main.AddsController.GetGatewayList()
            $Main.Reset($Xaml.IO.AddsGwAggregate.Items, $Main.AddsController.Gateway)
            $Xaml.IO.AddsGwName.Text      = $Null
        }
    })

    $Xaml.IO.AddsGwDelete.Add_Click(
    {
        If ($Xaml.IO.AddsGwAggregate.SelectedIndex -ne -1)
        {
            ForEach ($Object in $Xaml.IO.AddsGwAggregate.SelectedItems)
            {
                $Main.AddsController.RemoveNode($Object.Site,"Gateway",$Object.Name)
                $Main.AddsController.Output.Remove("Gateway",$Object.Name)
            }
            $Main.AddsController.GetGatewayList()
            $Main.Reset($Xaml.IO.AddsGwAggregate.Items,$Main.AddsController.Gateway)
            $Main.Reset($Xaml.IO.AddsGwOutput.Items,$Main.AddsController.Output.Gateway)
        }
    })

    $Xaml.IO.AddsGwBrowse.Add_Click(
    {
        $Item                             = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory            = $Env:SystemDrive
        $Item.Filter                      = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }

        $Xaml.IO.AddsGwFile.Text          = $Item.FileName
    })

    $Xaml.IO.AddsGwAddList.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.AddsGwFile.Text) -or $Xaml.IO.AddsGwFile.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("No valid file selected","Error")
        }

        Else
        {
            ForEach ($Item in Get-Content $Xaml.IO.AddsGwFile.Text)
            {
                $Object                       = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
                $Xaml.IO.AddsGwName.Text      = $Item
                $Name                         = $Main.CheckHostName($Item)  

                If ($Name -ne $Item)
                {
                    Return [System.Windows.MessageBox]::Show($Name,"Error")
                }

                ElseIf (!$Object)
                {
                    Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
                }

                ElseIf ($Name -in $Xaml.IO.AddsGwAggregate.Items.Name)
                {
                    Return [System.Windows.MessageBox]::Show("That item already exists","Error")
                }

                Else
                {
                    $Main.AddsController.AddNode($Object.Name,"Gateway",$Name)
                    $Xaml.IO.AddsGwName.Text  = $Null
                }
            }
            $Main.AddsController.GetGatewayList()
            $Main.Reset($Xaml.IO.AddsGwAggregate.Items, $Main.AddsController.Gateway)
        }
    })

    $Xaml.IO.AddsGwAggregate.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsGwAggregate.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsGwAggregate.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsGwAggregateViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsGwOutput.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsGwOutput.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsGwOutput.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsGwOutputViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsGwGet.Add_Click(
    {
        If ($Main.AddsController.Gateway.Count -gt 1)
        {
            $Main.AddsController.GetOutput("Gateway")
            ForEach ($Item in $Main.AddsController.Output.Gateway)
            {
                If ($Item.Exists)
                {
                    $Item.Update()
                }
            }
            $Main.Reset($Xaml.IO.AddsGwOutput.Items,$Main.AddsController.Output.Gateway)
        }
    })

    $Xaml.IO.AddsGwNew.Add_Click(
    {
        If ($Main.AddsController.Output.Gateway.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Gateway)
            {
                If ($Item.Exists)
                {
                    Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If (!$Item.Exists)
                {
                    $Item.New()
                }
            }
            $Main.Reset($Xaml.IO.AddsGwOutput.Items,$Main.AddsController.Output.Gateway)
        }
    })

    $Xaml.IO.AddsGwRemove.Add_Click(
    {
        If ($Main.AddsController.Output.Gateway.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Gateway)
            {
                If (!$Item.Exists)
                {
                    Write-Host ("Item [!] Does not exist [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If ($Item.Exists)
                {
                    $Item.Remove()
                }
            }
            $Main.Reset($Xaml.IO.AddsGwOutput.Items,$Main.AddsController.Output.Gateway)
        }
    })

    # [Adds.Server]
    $Xaml.IO.AddsSrAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Main.CheckHostname($Xaml.IO.AddsSrName.Text)

        If ($Name -ne $Xaml.IO.AddsSrName.Text)
        {
            Return [System.Windows.MessageBox]::Show($Name,"Error")
        }

        If (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in $Xaml.IO.AddsSrAggregate.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists","Error")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"Server",$Name)
            $Main.AddsController.GetServerList()
            $Main.Reset($Xaml.IO.AddsSrAggregate.Items,$Main.AddsController.Server)
            $Xaml.IO.AddsSrName.Text      = $Null
        }
    })

    $Xaml.IO.AddsSrDelete.Add_Click(
    {
        If ($Xaml.IO.AddsSrAggregate.SelectedIndex -ne -1)
        {
            ForEach ($Object in $Xaml.IO.AddsSrAggregate.SelectedItems)
            {
                $Main.AddsController.RemoveNode($Object.Site,"Server",$Object.Name)
                $Main.AddsController.Output.Remove("Server",$Object.Name)
            }
            $Main.AddsController.GetServerList()
            $Main.Reset($Xaml.IO.AddsSrAggregate.Items,$Main.AddsController.Server)
            $Main.Reset($Xaml.IO.AddsSrOutput.Items,$Main.AddsController.Output.Server)
        }
    })

    $Xaml.IO.AddsSrBrowse.Add_Click(
    {
        $Item                             = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory            = $Env:SystemDrive
        $Item.Filter                      = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }

        $Xaml.IO.AddsSrFile.Text          = $Item.FileName
    })

    $Xaml.IO.AddsSrAddList.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.AddsSrFile.Text) -or $Xaml.IO.AddsSrFile.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("No valid file selected","Error")
        }

        Else
        {
            ForEach ($Item in Get-Content $Xaml.IO.AddsSrFile.Text)
            {
                $Object                       = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
                $Xaml.IO.AddsSrName.Text      = $Item
                $Name                         = $Main.CheckHostName($Item)  

                If ($Name -ne $Item)
                {
                    Return [System.Windows.MessageBox]::Show($Name,"Error")
                }

                ElseIf (!$Object)
                {
                    Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
                }

                ElseIf ($Name -in $Xaml.IO.AddsSrAggregate.Items.Name)
                {
                    Return [System.Windows.MessageBox]::Show("That item already exists","Error")
                }

                Else
                {
                    $Main.AddsController.AddNode($Object.Name,"Server",$Name)
                    $Xaml.IO.AddsSrName.Text  = $Null
                }
            }
            $Main.AddsController.GetServerList()
            $Main.Reset($Xaml.IO.AddsSrAggregate.Items,$Main.AddsController.Server)
        }
    })

    $Xaml.IO.AddsSrAggregate.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSrAggregate.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsSrAggregate.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsSrAggregateViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsSrOutput.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSrOutput.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsSrOutput.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsSrOutputViewer.Items,$Content)
            }
        }
    })
    
    $Xaml.IO.AddsSrGet.Add_Click(
    {
        If ($Main.AddsController.Server.Count -gt 1)
        {
            $Main.AddsController.GetOutput("Server")
            ForEach ($Item in $Main.AddsController.Output.Server)
            {
                If ($Item.Exists)
                {
                    $Item.Update()
                }
            }
            $Main.Reset($Xaml.IO.AddsSrOutput.Items,$Main.AddsController.Output.Server)
        }
    })

    $Xaml.IO.AddsSrNew.Add_Click(
    {
        If ($Main.AddsController.Output.Server.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Server)
            {
                If ($Item.Exists)
                {
                    Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If (!$Item.Exists)
                {
                    $Item.New()
                }
            }
            $Main.Reset($Xaml.IO.AddsSrOutput.Items,$Main.AddsController.Output.Server)
        }
    })

    $Xaml.IO.AddsSrRemove.Add_Click(
    {
        If ($Main.AddsController.Output.Server.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Server)
            {
                If (!$Item.Exists)
                {
                    Write-Host ("Item [!] Does not exist [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If ($Item.Exists)
                {
                    $Item.Remove()
                }
            }
            $Main.Reset($Xaml.IO.AddsSrOutput.Items,$Main.AddsController.Output.Server)
        }
    })

    # [Adds.Workstation]
    $Xaml.IO.AddsWsAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Main.CheckHostname($Xaml.IO.AddsWsName.Text)

        If ($Name -ne $Xaml.IO.AddsWsName.Text)
        {
            Return [System.Windows.MessageBox]::Show($Name,"Error")
        }

        If (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in $Xaml.IO.AddsWsAggregate.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists","Error")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"Workstation",$Name)
            $Main.AddsController.GetWorkstationList()
            $Main.Reset($Xaml.IO.AddsWsAggregate.Items,$Main.AddsController.Workstation)
            $Xaml.IO.AddsWsName.Text      = $Null
        }
    })

    $Xaml.IO.AddsWsDelete.Add_Click(
    {
        If ($Xaml.IO.AddsWsAggregate.SelectedIndex -ne -1)
        {
            ForEach ($Object in $Xaml.IO.AddsWsAggregate.SelectedItems)
            {
                $Main.AddsController.RemoveNode($Object.Site,"Workstation",$Object.Name)
                $Main.AddsController.Output.Remove("Workstation",$Object.Name)
            }
            $Main.AddsController.GetWorkstationList()
            $Main.Reset($Xaml.IO.AddsWsAggregate.Items,$Main.AddsController.Workstation)
            $Main.Reset($Xaml.IO.AddsWsOutput.Items,$Main.AddsController.Output.Workstation)
        }
    })

    $Xaml.IO.AddsWsBrowse.Add_Click(
    {
        $Item                             = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory            = $Env:SystemDrive
        $Item.Filter                      = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }

        $Xaml.IO.AddsWsFile.Text          = $Item.FileName
    })

    $Xaml.IO.AddsWsAddList.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.AddsWsFile.Text) -or $Xaml.IO.AddsWsFile.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("Invalid path","Error")
        }

        Else
        {
            ForEach ($Item in Get-Content $Xaml.IO.AddsWsFile.Text)
            {
                $Object                       = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
                $Xaml.IO.AddsWsName.Text      = $Item
                $Name                         = $Main.CheckHostName($Item)  

                If ($Name -ne $Item)
                {
                    Return [System.Windows.MessageBox]::Show($Name,"Error")
                }

                ElseIf (!$Object)
                {
                    Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
                }

                ElseIf ($Name -in $Xaml.IO.AddsWsAggregate.Items.Name)
                {
                    Return [System.Windows.MessageBox]::Show("That item already exists","Error")
                }

                Else
                {
                    $Main.AddsController.AddNode($Object.Name,"Workstation",$Name)
                    $Xaml.IO.AddsWsName.Text  = $Null
                }
            }
            $Main.AddsController.GetWorkstationList()
            $Main.Reset($Xaml.IO.AddsWsAggregate.Items,$Main.AddsController.Workstation)
        }
    })

    $Xaml.IO.AddsWsAggregate.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsWsAggregate.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsWsAggregate.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsWsAggregateViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsWsOutput.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsWsOutput.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsWsOutput.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsWsOutputViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsWsGet.Add_Click(
    {
        If ($Main.AddsController.Workstation.Count -gt 1)
        {
            $Main.AddsController.GetOutput("Workstation")
            ForEach ($Item in $Main.AddsController.Output.Workstation)
            {
                If ($Item.Exists)
                {
                    $Item.Update()
                }
            }
            $Main.Reset($Xaml.IO.AddsWsOutput.Items,$Main.AddsController.Output.Workstation)
        }
    })

    $Xaml.IO.AddsWsNew.Add_Click(
    {
        If ($Main.AddsController.Output.Workstation.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Workstation)
            {
                If ($Item.Exists)
                {
                    Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If (!$Item.Exists)
                {
                    $Item.New()
                }
            }
            $Main.Reset($Xaml.IO.AddsWsOutput.Items,$Main.AddsController.Output.Workstation)
        }
    })

    $Xaml.IO.AddsWsRemove.Add_Click(
    {
        If ($Main.AddsController.Output.Workstation.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Workstation)
            {
                If (!$Item.Exists)
                {
                    Write-Host ("Item [!] Does not exist [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If ($Item.Exists)
                {
                    $Item.Remove()
                }
            }
            $Main.Reset($Xaml.IO.AddsWsOutput.Items,$Main.AddsController.Output.Workstation)
        }
    })

    # [Adds.User]
    $Xaml.IO.AddsUserAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Main.CheckHostname($Xaml.IO.AddsUserName.Text)

        If ($Name -ne $Xaml.IO.AddsUserName.Text)
        {
            Return [System.Windows.MessageBox]::Show($Name,"Error")
        }

        If (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in $Xaml.IO.AddsUserAggregate.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists","Error")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"User",$Name)
            $Main.AddsController.GetUserList()
            $Main.Reset($Xaml.IO.AddsUserAggregate.Items,$Main.AddsController.User)
            $Xaml.IO.AddsUserName.Text      = $Null
        }
    })

    $Xaml.IO.AddsUserDelete.Add_Click(
    {
        If ($Xaml.IO.AddsUserAggregate.SelectedIndex -ne -1)
        {
            ForEach ($Object in $Xaml.IO.AddsUserAggregate.SelectedItems)
            {
                $Main.AddsController.RemoveNode($Object.Site,"User",$Object.Name)
                $Main.AddsController.Output.Remove("User",$Object.Name)
            }
            $Main.AddsController.GetUserList()
            $Main.Reset($Xaml.IO.AddsUserAggregate.Items,$Main.AddsController.User)
            $Main.Reset($Xaml.IO.AddsUserOutput.Items,$Main.AddsController.Output.User)
        }
    })

    $Xaml.IO.AddsUserBrowse.Add_Click(
    {
        $Item                             = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory            = $Env:SystemDrive
        $Item.Filter                      = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }

        $Xaml.IO.AddsUserFile.Text          = $Item.FileName
    })

    $Xaml.IO.AddsUserAddList.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.AddsUserFile.Text) -or $Xaml.IO.AddsUserFile.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("Invalid path","Error")
        }

        Else
        {
            ForEach ($Item in Get-Content $Xaml.IO.AddsUserFile.Text)
            {
                $Object                       = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
                $Xaml.IO.AddsUserName.Text    = $Item
                $Name                         = $Main.CheckHostName($Item)  

                If ($Name -ne $Item)
                {
                    Return [System.Windows.MessageBox]::Show($Name,"Error")
                }

                ElseIf (!$Object)
                {
                    Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
                }

                ElseIf ($Name -in $Xaml.IO.AddsUserAggregate.Items.Name)
                {
                    Return [System.Windows.MessageBox]::Show("That item already exists","Error")
                }

                Else
                {
                    $Main.AddsController.AddNode($Object.Name,"User",$Name)
                    $Xaml.IO.AddsUserName.Text  = $Null
                }
            }
            $Main.AddsController.GetUserList()
            $Main.Reset($Xaml.IO.AddsUserAggregate.Items,$Main.AddsController.User)
        }
    })

    $Xaml.IO.AddsUserAggregate.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsUserAggregate.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsUserAggregate.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsUserAggregateViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsUserOutput.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsUserOutput.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsUserOutput.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsUserOutputViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsUserGet.Add_Click(
    {
        If ($Main.AddsController.User.Count -gt 1)
        {
            $Main.AddsController.GetOutput("User")
            ForEach ($Item in $Main.AddsController.Output.User)
            {
                If ($Item.Exists)
                {
                    $Item.Update()
                }
            }
            $Main.Reset($Xaml.IO.AddsUserOutput.Items,$Main.AddsController.Output.User)
        }
    })

    $Xaml.IO.AddsUserNew.Add_Click(
    {
        If ($Main.AddsController.Output.User.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.User)
            {
                If ($Item.Exists)
                {
                    Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If (!$Item.Exists)
                {
                    $Item.New()
                }
            }
            $Main.Reset($Xaml.IO.AddsUserOutput.Items,$Main.AddsController.Output.User)
        }
    })

    $Xaml.IO.AddsUserRemove.Add_Click(
    {
        If ($Main.AddsController.Output.User.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.User)
            {
                If (!$Item.Exists)
                {
                    Write-Host ("Item [!] Does not exist [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If ($Item.Exists)
                {
                    $Item.Remove()
                }
            }
            $Main.Reset($Xaml.IO.AddsUserOutput.Items,$Main.AddsController.Output.User)
        }
    })

    # [Adds.Service]
    $Xaml.IO.AddsSvcAdd.Add_Click(
    {
        $Object                           = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
        $Name                             = $Main.CheckHostname($Xaml.IO.AddsSvcName.Text)

        If ($Name -ne $Xaml.IO.AddsSvcName.Text)
        {
            Return [System.Windows.MessageBox]::Show($Name,"Error")
        }

        If (!$Object)
        {
            Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
        }

        ElseIf ($Name -in $Xaml.IO.AddsSvcAggregate.Items.Name)
        {
            Return [System.Windows.MessageBox]::Show("That item already exists","Error")
        }

        Else
        {
            $Main.AddsController.AddNode($Object.Name,"Service",$Name)
            $Main.AddsController.GetUserList()
            $Main.Reset($Xaml.IO.AddsSvcAggregate.Items,$Main.AddsController.Service)
            $Xaml.IO.AddsSvcName.Text      = $Null
        }
    })

    $Xaml.IO.AddsSvcDelete.Add_Click(
    {
        If ($Xaml.IO.AddsSvcAggregate.SelectedIndex -ne -1)
        {
            ForEach ($Object in $Xaml.IO.AddsSvcAggregate.SelectedItems)
            {
                $Main.AddsController.RemoveNode($Object.Site,"Service",$Object.Name)
                $Main.AddsController.Output.Remove("Service",$Object.Name)
            }
            $Main.AddsController.GetServiceList()
            $Main.Reset($Xaml.IO.AddsSvcAggregate.Items,$Main.AddsController.Service)
            $Main.Reset($Xaml.IO.AddsSvcOutput.Items,$Main.AddsController.Output.Service)
        }
    })

    $Xaml.IO.AddsSvcBrowse.Add_Click(
    {
        $Item                             = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory            = $Env:SystemDrive
        $Item.Filter                      = 'Text File (*.txt)| *.txt'
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename                = ""
        }

        $Xaml.IO.AddsUserFile.Text          = $Item.FileName
    })

    $Xaml.IO.AddsSvcAddList.Add_Click(
    {
        If (!(Test-Path $Xaml.IO.AddsSvcFile.Text) -or $Xaml.IO.AddsSvcFile.Text -eq "")
        {
            Return [System.Windows.MessageBox]::Show("Invalid path","Error")
        }

        Else
        {
            ForEach ($Item in Get-Content $Xaml.IO.AddsSvcFile.Text)
            {
                $Object                       = $Main.AddsController.Sitemap[$Xaml.IO.AddsSite.SelectedIndex]
                $Xaml.IO.AddsSvcName.Text    = $Item
                $Name                         = $Main.CheckHostName($Item)  

                If ($Name -ne $Item)
                {
                    Return [System.Windows.MessageBox]::Show($Name,"Error")
                }

                ElseIf (!$Object)
                {
                    Return [System.Windows.MessageBox]::Show("Must select a site first","Error")
                }

                ElseIf ($Name -in $Xaml.IO.AddsSvcAggregate.Items.Name)
                {
                    Return [System.Windows.MessageBox]::Show("That item already exists","Error")
                }

                Else
                {
                    $Main.AddsController.AddNode($Object.Name,"Service",$Name)
                    $Xaml.IO.AddsSvcName.Text  = $Null
                }
            }
            $Main.AddsController.GetSvcList()
            $Main.Reset($Xaml.IO.AddsUserAggregate.Items,$Main.AddsController.Service)
        }
    })

    $Xaml.IO.AddsSvcAggregate.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSvcAggregate.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsSvcAggregate.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | ? Name -ne Template | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsSvcAggregateViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsSvcOutput.Add_SelectionChanged(
    {
        If ($Xaml.IO.AddsSvcOutput.SelectedIndex -ne -1)
        {
            $Object                                = $Xaml.IO.AddsSvcOutput.SelectedItem
            If ($Object)
            {
                $Content = @($Object.PSObject.Properties | % { $Main.List($_.Name,$_.Value) })
                $Main.Reset($Xaml.IO.AddsSvcOutputViewer.Items,$Content)
            }
        }
    })

    $Xaml.IO.AddsSvcGet.Add_Click(
    {
        If ($Main.AddsController.Service.Count -gt 1)
        {
            $Main.AddsController.GetOutput("Service")
            ForEach ($Item in $Main.AddsController.Output.Service)
            {
                If ($Item.Exists)
                {
                    $Item.Update()
                }
            }
            $Main.Reset($Xaml.IO.AddsSvcOutput.Items,$Main.AddsController.Output.Service)
        }
    })

    $Xaml.IO.AddsSvcNew.Add_Click(
    {
        If ($Main.AddsController.Output.Service.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Service)
            {
                If ($Item.Exists)
                {
                    Write-Host ("Item [+] Exists [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If (!$Item.Exists)
                {
                    $Item.New()
                }
            }
            $Main.Reset($Xaml.IO.AddsSvcOutput.Items,$Main.AddsController.Output.Service)
        }
    })

    $Xaml.IO.AddsSvcRemove.Add_Click(
    {
        If ($Main.AddsController.Output.Service.Count -gt 1)
        {
            ForEach ($Item in $Main.AddsController.Output.Service)
            {
                If (!$Item.Exists)
                {
                    Write-Host ("Item [!] Does not exist [{0}]" -f $Item.DistinguishedName) -F 12
                }
                If ($Item.Exists)
                {
                    $Item.Remove()
                }
            }
            $Main.Reset($Xaml.IO.AddsSvcOutput.Items,$Main.AddsController.Output.Service)
        }
    })

    # ----------------- #
    # <![Virtual Tab]!> #
    # ----------------- #

    # [Vm.Control]
    $Xaml.IO.VmHostName.Text                  = $Main.VmController.Hostname
    $Xaml.IO.VmHostName.IsEnabled             = 0
    $Xaml.IO.VmHostConnect.IsEnabled          = 0
    $Xaml.IO.VmHostChange.IsEnabled           = 1

    $Main.Reset($Xaml.IO.VmControl.Items,$Main.VmController.Populate())
    $Main.Reset($Xaml.IO.VmControllerSwitch.Items,$Main.VmController.External)

    $Xaml.IO.VmControllerSwitch.SelectedIndex = 0
    $NetRoute                                 = Get-NetAdapter | ? Name -match $Xaml.IO.VmControllerSwitch.SelectedItem | Get-NetRoute -AddressFamily IPV4
    $Xaml.IO.VmControllerNetwork.Text         = $NetRoute | ? NextHop -eq 0.0.0.0 | Select-Object -Last 1 | % DestinationPrefix
    $Xaml.IO.VmControllerGateway.Text         = $NetRoute | ? NextHop -ne 0.0.0.0 | % NextHop

    $Xaml.IO.VmHostChange.Add_Click(
    {
        $Xaml.IO.VmHostName.Text          = $Null
        $Xaml.IO.VmHostName.IsEnabled     = 1
        $Xaml.IO.VmHostConnect.IsEnabled  = 1
        $Xaml.IO.VmHostChange.IsEnabled   = 0
    })

    $Xaml.IO.VmHostConnect.Add_Click(
    {
        If ($Xaml.IO.VmHostName.Text -eq "")
        {
            Return [System.Windows.Messagebox]::Show("Must enter a server hostname or IP address","Error")
        }

        ElseIf (!(Test-Connection -ComputerName $Xaml.IO.VmHostName.Text -Count 1 -EA 0))
        {
            Return [System.Windows.Messagebox]::Show("Not a valid server hostname or IP Address","Error")
        }

        Write-Host "Retrieving [~] VMHost"

        If ($Xaml.IO.VmHostName.Text -match "localhost" -or $Xaml.IO.VmHostName.Text -in $Main.Config.IP -or $Xaml.IO.VmHostName.Text -match $Main.Module.Role.Name)
        {
            $Main.VmController = VmController -Hostname $Xaml.IO.VmHostname -Credential $Main.Credential
            If ($Main.VmController.Status -ne "Running")
            {
                Return [System.Windows.MessageBox]::Show("The Hyper-V Virtual Machine Management service is not (installed/running)","Error")
            }

            $Xaml.IO.VmControl.ItemsSource          = $Main.VmController.Populate()
            $Main.Reset($Xaml.IO.VmControllerSwitch.Items,$Main.VmController.External)
        }
        Else
        {
            Return [System.Windows.MessageBox]::Show("Remote Hyper-V Server not implemented","Error")
        }
    })

    $Xaml.IO.VmControllerSwitch.Add_SelectionChanged(
    {
        $NetRoute = Get-NetAdapter | ? Name -match $Xaml.IO.VmControllerSwitch.SelectedItem | Get-NetRoute -AddressFamily IPV4
        $Xaml.IO.VmControllerNetwork.Text = $NetRoute | ? NextHop -eq 0.0.0.0 | Select-Object -Last 1 | % DestinationPrefix
        $Xaml.IO.VmControllerGateway.Text = $NetRoute | ? NextHop -ne 0.0.0.0 | % NextHop
    })

    $Xaml.IO.VmLoadAddsNode.Add_Click(
    {
        # $Main.VmController = VmController -Hostname dsc0.securedigitsplus.com -Credential $Main.Credential
        $Main.VmController.LoadAddsTree($Main.AddsController.Output)
        $Main.Reset($Xaml.IO.VmSelect.Items,$Main.VmController.VmSelect)
    })

    $Xaml.IO.VmDeleteNodes.Add_Click(
    {
        Switch([System.Windows.MessageBox]::Show("This will delete any existing VMs in the list`n`nPress 'Yes' to confirm","Warning [!] Are you sure?","YesNo"))
        {
            Yes 
            { 
                Write-Theme "Deleting [!] VMs"
                ForEach ($Object in $Main.VmController.VmSelect | ? Exists -eq $True)
                {
                    $Main.VmController.DeleteNode($Object)
                    $Main.Reset($Xaml.IO.VmSelect.Items,$Main.VmController.VmSelect)
                }
            }
            No  { Break }
        }
    })

    $Xaml.IO.VmCreateNodes.Add_Click(
    {
        $Main.Container = $Main.VmController.NodeContainer()
        ForEach ($Object in $Main.VmController.VmSelect | ? Exists -eq $False | ? Create)
        {
            $Item = $Main.VmController.GetVMObjectNode($Object)
            Switch -Regex ($Object.Type)
            {
                Gateway
                {
                    $Main.Container.Gateway     += $Item
                }
                "(Server|Domain Controller)"
                {
                    $Main.Container.Server      += $Item
                }
                Workstation
                {
                    $Main.Container.Workstation += $Item
                }
            }
        }
        $Main.Reset($Xaml.IO.VmGateway.Items,$Main.Container.Gateway)
        $Main.Reset($Xaml.IO.VmServer.Items,$Main.Container.Server)
        $Main.Reset($Xaml.IO.VmWorkstation.Items,$Main.Container.Workstation)
    })

    # [Vm.Switch]
    $Xaml.IO.VmDhcpScopeID.Add_SelectionChanged(
    {
        If ($Xaml.IO.VmDhcpScopeID.SelectedIndex -ne -1)
        {
            $Object                   = $Main.VmController.GetRange($Xaml.IO.VmDhcpScopeID.SelectedItem)
            $Xaml.IO.VmDhcpStart.Text = $Object[0].IpAddress
            $Xaml.IO.VmDhcpEnd.Text   = $Object[-1].IpAddress
        }
    })

    $Main.Reset($Xaml.IO.VmDhcpScopeID.Items,$Main.Config.Dhcp.ScopeID)
    $Xaml.IO.VmDhcpScopeID.SelectedIndex = 0

    $Xaml.IO.VmGetSwitch.Add_Click(
    {
        If ($Main.Container.Gateway.Count -gt 0)
        {
            $Main.VmController.GetReservations($Xaml.IO.VmDhcpScopeID.SelectedItem)
            $Main.Reset($Xaml.IO.VmDhcpReservations.Items,$Main.VmController.Reservation)
        }
    })

    $Xaml.IO.VmDeleteSwitch.Add_Click(
    {
        If ($Main.VmController.Reservation.Count -gt 0)
        {
            ForEach ($Object in $Main.VmController.Reservation | ? SwitchExists)
            {
                $Object.Remove()
            }
            $Main.VmController.GetReservations($Xaml.IO.VmDhcpScopeID.SelectedItem)
            $Main.Reset($Xaml.IO.VmDhcpReservations.Items,$Main.VmController.Reservation)
        }
    })

    $Xaml.IO.VmCreateSwitch.Add_Click(
    {
        If ($Main.VmController.Reservation.Count -gt 0)
        {
            ForEach ($Object in $Main.VmController.Reservation | ? SwitchExists -eq 0)
            {
                $Object.New()
                $Object.SwitchExists = 1
            }
            $Main.VmController.GetReservations($Xaml.IO.VmDhcpScopeID.SelectedItem)
            $Main.Reset($Xaml.IO.VmDhcpReservations.Items,$Main.VmController.Reservation)
        }
    })

    # [Vm.Gateway]
    $Xaml.IO.VmGatewayInstallType.Add_SelectionChanged(
    {
        If ($Xaml.IO.VmGatewayInstallType.SelectedIndex -eq 0)
        {
            $Xaml.IO.VmGatewayImageSelect.IsEnabled  = 1
            $Xaml.IO.VmGatewayImage.IsEnabled        = 1
            $Xaml.IO.VmGatewayScriptSelect.IsEnabled = 1
            $Xaml.IO.VmGatewayScript.IsEnabled       = 1
        }
        If ($Xaml.IO.VmGatewayInstallType.SelectedIndex -eq 1)
        {
            $Xaml.IO.VmGatewayScriptSelect.IsEnabled = 0
            $Xaml.IO.VmGatewayScript.IsEnabled       = 0
            $Xaml.IO.VmGatewayImageSelect.IsEnabled  = 0
            $Xaml.IO.VmGatewayImage.IsEnabled        = 0
        }
    })

    $Xaml.IO.VmGatewayPathSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath           = ""
        }

        $Xaml.IO.VmGatewayPath.Text      = $Item.SelectedPath
    })

    $Xaml.IO.VmGatewayScriptSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }

        $Xaml.IO.VmGatewayScript.Text    = $Item.FileName
    })

    $Xaml.IO.VmGatewayImageSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }
    
        $Xaml.IO.VmGatewayImage.Text     = $Item.FileName
    })

    $Xaml.IO.VmGatewayMemory.Text          = 2048
    $Xaml.IO.VmGatewayDrive.Text           = 20
    $Xaml.IO.VmGatewayCore.Text            = 1

    # [Vm.Server]
    $Xaml.IO.VmServerInstallType.Add_SelectionChanged(
    {
        If ($Xaml.IO.VmServerInstallType.SelectedIndex -eq 0)
        {
            $Xaml.IO.VmServerImageSelect.IsEnabled  = 1
            $Xaml.IO.VmServerImage.IsEnabled        = 1
            $Xaml.IO.VmServerScriptSelect.IsEnabled = 1
            $Xaml.IO.VmServerScript.IsEnabled       = 1
        }
        If ($Xaml.IO.VmServerInstallType.SelectedIndex -eq 1)
        {
            $Xaml.IO.VmServerImageSelect.IsEnabled  = 0
            $Xaml.IO.VmServerImage.IsEnabled        = 0
            $Xaml.IO.VmServerScriptSelect.IsEnabled = 0
            $Xaml.IO.VmServerScript.IsEnabled       = 0
        }
    })

    $Xaml.IO.VmServerPathSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath           = ""
        }

        $Xaml.IO.VmServerPath.Text       = $Item.SelectedPath
    })

    $Xaml.IO.VmServerScriptSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }

        $Xaml.IO.VmServerScript.Text     = $Item.FileName
    })

    $Xaml.IO.VmServerImageSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }
    
        $Xaml.IO.VmServerImage.Text      = $Item.FileName
    })

    $Xaml.IO.VmServerMemory.Text           = 4096
    $Xaml.IO.VmServerDrive.Text            = 100
    $Xaml.IO.VmServerCore.Text             = 2

    # [Vm.Workstation]
    $Xaml.IO.VmWorkstationInstallType.Add_SelectionChanged(
    {
        If ($Xaml.IO.VmWorkstationInstallType.SelectedIndex -eq 0)
        {
            $Xaml.IO.VmWorkstationImageSelect.IsEnabled  = 1
            $Xaml.IO.VmWorkstationImage.IsEnabled        = 1
            $Xaml.IO.VmWorkstationScriptSelect.IsEnabled = 1
            $Xaml.IO.VmWorkstationScript.IsEnabled       = 1
        }
        If ($Xaml.IO.VmWorkstationInstallType.SelectedIndex -eq 1)
        {
            $Xaml.IO.VmWorkstationImageSelect.IsEnabled  = 0
            $Xaml.IO.VmWorkstationImage.IsEnabled        = 0
            $Xaml.IO.VmWorkstationScriptSelect.IsEnabled = 0
            $Xaml.IO.VmWorkstationScript.IsEnabled       = 0
        }
    })

    $Xaml.IO.VmWorkstationPathSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.FolderBrowserDialog
        $Item.ShowDialog()
        
        If (!$Item.SelectedPath)
        {
            $Item.SelectedPath           = ""
        }

        $Xaml.IO.VmWorkstationPath.Text       = $Item.SelectedPath
    })

    $Xaml.IO.VmWorkstationScriptSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.ps1)|*.ps1"
        $Item.ShowDialog()
        
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }

        $Xaml.IO.VmWorkstationScript.Text     = $Item.FileName
    })

    $Xaml.IO.VmWorkstationImageSelect.Add_Click(
    {
        $Item                            = New-Object System.Windows.Forms.OpenFileDialog
        $Item.InitialDirectory           = $Env:SystemDrive
        $Item.Filter                     = "(*.iso)|*.iso"
        $Item.ShowDialog()
            
        If (!$Item.Filename)
        {
            $Item.Filename               = ""
        }
    
        $Xaml.IO.VmWorkstationImage.Text      = $Item.FileName
    })

    $Xaml.IO.VmWorkstationMemory.Text      = 2048
    $Xaml.IO.VmWorkstationDrive.Text       = 20
    $Xaml.IO.VmWorkstationCore.Text        = 2

    $Xaml.IO.VMGetArchitecture.Add_Click(
    {
        $Main.Validate = $Main.VmController.ValidationStack()

        # Gateway
        If ($Main.Container.Gateway.Count -gt 0)
        {
            Write-Theme "Validating [~] Virtual Gateway(s)" 11,3,15
            $Main.Validate.ValidateBase(
                "Gateway",
                $Xaml.IO.VmGatewayPath.Text,
                $Xaml.IO.VmGatewayInstallType.SelectedItem.Content,
                $Xaml.IO.VmGatewayImage.Text,
                $Xaml.IO.VmGatewayScript.Text,
                $Main.Container.Gateway)

            If ($Main.Validate.Gateway.Result -eq "Fail")
            {
                Write-Theme "Error [!] Failure to validate ALL of the requested [Gateway] items" 12,4,15
                Return [System.Windows.MessageBox]::Show("Failure to get the requested items","Gateway Error")
            }

            If ($Main.Validate.Gateway.Result -eq "Success")
            {
                ForEach ($Object in $Main.Validate.Gateway.Container)
                {
                    $Item = $Main.VmController.NewVMObjectNode($Object.VmName)
                    $Item.Stage(
                        $Xaml.IO.VmGatewayPath.Text,
                        $Xaml.IO.VmGatewayMemory.Text,
                        $Xaml.IO.VmGatewayDrive.Text,
                        $Xaml.IO.VmGatewayGeneration.Text,
                        $Xaml.IO.VmGatewayCore.Text,
                        $Object.Sitelink)

                    $Main.Validate.Gateway.Output += $Item
                }
                Write-Theme "Validated [~] Virtual Gateway(s)" 10,2,15
            }
        }

        # Server
        If ($Main.Container.Server.Count -gt 0)
        {
            Write-Theme "Validating [~] Virtual Server(s)" 11,3,15
            $Main.Validate.ValidateBase("Server",
                $Xaml.IO.VmServerPath.Text,
                $Xaml.IO.VmServerInstallType.SelectedItem.Content,
                $Xaml.IO.VmServerImage.Text,
                $Xaml.IO.VmServerScript.Text,
                $Main.Container.Server)

            If ($Main.Validate.Server.Result -eq "Fail")
            {
                Write-Theme "Error [!] Failure to validate ALL of the requested [Server] items" 12,4,15
                Return [System.Windows.MessageBox]::Show("Failure to get the requested items","Server Error")
            }

            If ($Main.Validate.Server.Result -eq "Success")
            {
                ForEach ($Object in $Main.Validate.Server.Container)
                {
                    $Item = $Main.VmController.NewVMObjectNode($Object.VmName)
                    $Item.Stage($Xaml.IO.VmServerPath.Text,
                                $Xaml.IO.VmServerMemory.Text,
                                $Xaml.IO.VmServerDrive.Text,
                                $Xaml.IO.VmServerGeneration.Text,
                                $Xaml.IO.VmServerCore.Text,
                                $Object.Sitelink)

                    $Main.Validate.Server.Output += $Item
                }
                Write-Theme "Validated [~] Virtual Servers(s)" 10,2,15
            }
        }

        # Workstation
        If ($Main.Container.Workstation.Count -gt 0)
        {
            Write-Theme "Validating [~] Virtual Workstations(s)" 11,3,15
            $Main.Validate.ValidateBase(
                "Workstation",
                $Xaml.IO.VmWorkstationPath.Text,
                $Xaml.IO.VmWorkstationInstallType.SelectedItem.Content,
                $Xaml.IO.VmWorkstationImage.Text,
                $Xaml.IO.VmWorkstationScript.Text,
                $Main.Container.Workstation)

            If ($Main.Validate.Workstation.Result -eq "Fail")
            {
                Write-Theme "Error [!] Failure to validate ALL of the requested [Workstation] items" 12,4,15
                Return [System.Windows.MessageBox]::Show("Failure to get the requested items","Workstation Error")
            }

            If ($Main.Validate.Workstation.Result -eq "Success")
            {
                ForEach ($Object in $Main.Validate.Workstation.Container)
                {
                    $Item = $Main.VmController.NewVMObjectNode($Object.VmName)
                    $Item.Stage(
                        $Xaml.IO.VmWorkstationPath.Text,
                        $Xaml.IO.VmWorkstationMemory.Text,
                        $Xaml.IO.VmWorkstationDrive.Text,
                        $Xaml.IO.VmWorkstationGeneration.Text,
                        $Xaml.IO.VmWorkstationCore.Text,
                        $Object.Sitelink)

                    $Main.Validate.Workstation.Output += $Item
                }
                Write-Theme "Validated [~] Virtual Workstations(s)" 10,2,15
            }
        }
    })

    $Xaml.IO.VmNewArchitecture.Add_Click(
    {
        $Master = $Main.Validate.Gateway
        ForEach ($Object in $Master.Output)
        {   
            Write-Theme ("Initializing [~] Virtual Gateway ({0})" -f $Object.Name) 14,6,15
            $Object.New()
            $Object.Start()
            Do
            {
                Start-Sleep 1
                $MacAddress = $Object.Get().NetworkAdapters[0].MacAddress
            }
            Until ($MacAddress -notmatch "0{12}")
            $Object.Stop()
            $Reserve = $Main.VmController.Reservation | ? SwitchName -match $Object.Name 
            $Reserve.SetMacAddress($MacAddress)
            $Reserve.Add()
            $Object.LoadIso($Master.Iso)
            $Object.SetIsoBoot()
            Write-Theme ("Initialized [+] Virtual Gateway ({0})" -f $Object.Name) 10,2,15
        }

        $Master = $Main.Validate.Server
        ForEach ($Object in $Master.Output)
        {
            Write-Theme ("Initializing [~] Virtual Server ({0})" -f $Object.Name) 14,6,15
            $Object.New()
            $Object.LoadIso($Master.Iso)
            $Object.SetIsoBoot()
            Write-Theme ("Initialized [+] Virtual Server ({0})" -f $Object.Name) 10,2,15
        }

        $Master = $Main.Validate.Workstation
        ForEach ($Object in $Main.Validate.Workstation.Output)
        {
            Write-Theme ("Initializing [~] Virtual Workstation ({0})" -f $Object.Name) 14,6,15
            $Object.New()
            Write-Theme ("Initialized [+] Virtual Server ({0})" -f $Object.Name) 10,2,15
        }

        Write-Theme "Deployed [+] Virtual Machines (Next Phase -> Installation)"
    })

    Return @{ Xaml = $Xaml; Main = $Main }
}

<#

Add-Type -AssemblyName PresentationFramework
. $Home\Desktop\New-FEInfrastructure2.ps1
$Cap = New-FEInfrastructure2

$Xaml = $Cap.Xaml
$Main = $Cap.Main

$Xaml.Invoke()

# ---- #

$Main.UpdateController.SetBase("C:\Updates")
$Main.UpdateController.ProcessFileList()
$Main.UpdateController.UpdateList 

#>
