<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2022-12-18 21:37:05                                                                  //
 \\==================================================================================================// 

    FileName   : Get-FENetwork.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : For collecting network adapters, interfaces, as well as a network service controller
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-12-14
    Modified   : 2022-12-14
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : IPV6 Type stuff, Ping Sweep (IPV4), NBT scan remote addresses

.Example
    ===========================================
    | 00 | [ ] Vendor [ ] Arp/Nbt [ ] Netstat |
    | 01 | [ ] Vendor [ ] Arp/Nbt [X] Netstat |
    | 02 | [ ] Vendor [X] Arp/Nbt [ ] Netstat |
    | 03 | [ ] Vendor [X] Arp/Nbt [X] Netstat |
    | 04 | [X] Vendor [ ] Arp/Nbt [ ] Netstat |
    | 05 | [X] Vendor [ ] Arp/Nbt [X] Netstat |
    | 06 | [X] Vendor [X] Arp/Nbt [ ] Netstat |
    | 07 | [X] Vendor [X] Arp/Nbt [X] Netstat |
    ===========================================
#>
Function Get-FENetwork
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode=0)

    # // ================================================
    # // | Collects DNS Suffix/registration information |
    # // ================================================

    Class DNSSuffix
    {
        [UInt32] $IsDomain
        [String] $ComputerName
        [String] $Domain
        [String] $NVDomain
        [UInt32] $Sync
        DNSSuffix()
        {
            $This.IsDomain     = $This.GetComputerSystem().PartOfDomain
            $Item              = $This.GetParameters()
            $This.ComputerName = $Item.HostName
            $This.Domain       = @("-",$Item.Domain)[$This.IsDomain]
            $This.NVDomain     = @("-",$Item.'NV Domain')[$This.IsDomain]
            $This.Sync         = $Item.SyncDomainWithMembership
        }
        [Object] GetParameters()
        {
            Return Get-ItemProperty "HKLM:\System\CurrentControlSet\Services\TCPIP\Parameters"
        }
        [Object] GetComputerSystem()
        {
            Return Get-CimInstance Win32_ComputerSystem
        }
        SetDomain([String]$Domain)
        {
            $This.Domain           = $Domain
        }
        SetComputerName([String]$ComputerName)
        {
            $This.ComputerName     = $ComputerName
        }
        SetSync()
        {
            If (!$This.IsDomain)
            {
                "Domain","NV Domain" | % { Set-ItemProperty -Path $This.Path -Name $_ -Value $This.Domain -Verbose }
            }

            Else
            {
                Throw "System is part of a domain"
            }
        }
        [String] ToString()
        {
            Return $This.Domain
        }
    }

    # // =====================================================
    # // | Individual vendor information for the vendor list |
    # // =====================================================

    Class VendorItem
    {
        [String] $Index
        [String] $Hex
        [String] $Name
        VendorItem([UInt32]$Index,[String]$Line)
        {
            $This.Index = $Index
            $This.Hex, $This.Name = $Line -Split "\t"
        }
        [String] ToString()
        {
            Return "<FENetwork.VendorItem>"
        }
    }

    # // ====================================================
    # // | Collects vendor information from the vendor list |
    # // ====================================================

    Class VendorList
    {
        [String] $Name
        [UInt32] $Count
        [Object] $Output
        VendorList()
        {
            $This.Name = "VendorList"
            $Module    = Get-FEModule -Mode 1
            $Path      = $Module._Control("vendorlist.txt").Fullname

            If (![System.IO.File]::Exists($Path))
            {
                Throw "Unable to locate the vendor list file"
            }

            $File      = [System.IO.File]::ReadAllLines($Path)
            $Hash      = @{ }

            ForEach ($Line in $File)
            {
                $Hash.Add($Hash.Count,$This.VendorItem($Hash.Count,$Line))
            }

            $This.Output = $Hash[0..($Hash.Count-1)]
            $This.Count  = $This.Output.Count
        }
        [Object] VendorItem([UInt32]$Index,[String]$Line)
        {
            Return [VendorItem]::New($Index,$Line)
        }
        [String] Find([String]$Mac)
        {
            $ID         = $Mac -Replace "(-|:)","" | % Substring 0 6
            $Item       = $This.Output | ? Hex -eq $ID 

            If (!$Item)
            {
                $Item   = $This.VendorItem(0,"0`t-")
            }

            Return $Item.Name
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.VendorList>" -f $This.Count
        }
    }

    # // =====================================================
    # // | Collects/formats the information for an ARP entry |
    # // =====================================================

    Class ArpHost
    {
        [String]    $IPAddress
        [String]     $Physical
        [String]         $Type
        ArpHost([String]$Line)
        {
            $This.IPAddress  = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Physical   = [Regex]::Matches($Line,"([0-9a-f]{2}\-){5}[0-9a-f]{2}").Value
            $This.Type       = $Line.Substring(46).TrimEnd(" ")
            $This.GetAssociation()
        }
        GetAssociation()
        {
            $Split = $This.IPAddress.ToString().Split(".")
            If ($Split[0] -in 224,239)
            {
                $This.Type = "Multicast"
            }
            If ($Split[0] -eq 255)
            {
                $This.Type = "Broadcast"
            }
            If ($This.Physical -match "(ff\-){5}ff")
            {
                If ($Split[0] -ne 255)
                {
                    $This.Type = "HostMax"
                }
                Else
                {
                    $This.Type = "Broadcast"
                }
            }
            If ($This.Type -eq "dynamic")
            {
                $This.Type = "Host"
            }
        }
        [String] ToString()
        {
            Return "<FENetwork.ArpHost>"
        }
    }

    # // =================================================================
    # // | Collects/formats information for an adapter in the ARP table  |
    # // =================================================================

    Class ArpAdapter
    {
        [UInt32]        $Index
        [String]         $Type
        [String]    $IPAddress
        [Object]         $Host
        ArpAdapter([String]$Line)
        {
            $This.Index     = [Regex]::Matches($Line,"(0x\d+)").Value
            $This.IPAddress = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Type      = @("Public","Private")[$This.IPAddress -match 169.254]
            $This.Host      = @( )
        }
        Add([String]$Line)
        {
            $This.Host     += [ArpHost]::New($Line)
        }
        [String] ToString()
        {
            Return "<FENetwork.ArpAdapter>"
        }
    }

    # // =========================================
    # // | Collects/Formats the entire ARP table |
    # // =========================================

    Class ArpList
    {
        [String]    $Name
        [UInt32]   $Count
        [Object]  $Output
        ArpList()
        {
            $This.Name = "ArpList"
        }
        Refresh()
        {
            $Query       = arp -a
            $This.Output = @( )
            ForEach ($X in 0..($Query.Count-1))
            {
                $Line    = $Query[$X]
                Switch -Regex ($Line)
                {
                    "^Interface"
                    {
                        $This.Output += [ArpAdapter]::New($Line)
                    }
                    "^\s{2}\d"
                    {
                        $This.Output[$This.Output.Count-1].Add($Line)
                    }
                }
            }
            $This.Count  = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.ArpList>" -f $This.Count
        }
    }

    # // ==============================================
    # // | Object to populate the NBT Reference Table |
    # // ==============================================

    Class NbtStatReference
    {
        [String]      $ID
        [String]    $Type
        [String] $Service
        NbtStatReference([String]$In)
        {
            $This.ID, $This.Type, $This.Service = $In -Split "/"
            $This.ID = "<$($This.ID)>"
        }
        [String] ToString()
        {
            Return "<FENetwork.NbtStatReference>"
        }
    }

    # // ========================================
    # // | Information about detected NBT hosts |
    # // ========================================

    Class NbtStatHost
    {
        [UInt32] $Index
        [String] $Name
        [String] $Id
        [String] $Type
        [String] $Service
        NbtStatHost([UInt32]$Index,[String]$Line)
        {
            $Item           = $Line -Split " " | ? Length -gt 0
            $This.Index     = $Index
            $This.Name      = $Item[0]
            $This.Id        = $Item[1]
            $This.Type      = $Item[2]
        }
        [String] ToString()
        {
            Return "<FENetwork.NbtStatHost>"
        }
    }

    # // ==================================
    # // | Information from netstat table |
    # // ==================================

    Class NbtStatInterface
    {
        [UInt32]        $Index
        [String]         $Type
        [String]         $Name
        [String]    $IPAddress
        [String]         $Node
        [UInt32]        $Count
        [Object]       $Output
        NbtStatInterface([String]$Type,[String]$Line)
        {
            $Line           = $Line.TrimEnd(" ")
            $This.Type      = $Type
            $This.Name      = $Line.TrimEnd(":")
            $This.Output    = @( )
        }
        AddNode([String]$Line)
        {
            $Split          = $Line     -Replace "Scope","`nScope" -Split "`n"
            $This.IPAddress = [Regex]::Matches($Split[0],"(\d+\.){3}\d+").Value
            $This.Node      = $Split[1] -Replace "(Scope Id: \[|\])",""
        }
        AddHost([String]$Line)
        {
            $This.Output   += [NbtStatHost]::New($This.Output.Count,$Line)
            $This.Count     = $This.Output.Count
        }
        [String] ToString()
        {
            Return "<FENetwork.NbtStatInterface>"
        }
    }

    # // ==============================================================
    # // | Collects the local NBT table (will be modified for remote) |
    # // ==============================================================

    Class NbtStatLocalList
    {
        Hidden [Object] $Reference
        [String]             $Name
        [UInt32]            $Count
        [Object]           $Output
        NbtStatLocalList()
        {
            # // =================================================
            # // | Get NBT Reference table, and collect NBT info |
            # // =================================================

            $This.Name        = "NbtStatLocalList"
            $This.Reference   = $This.NbtStatReference()
        }
        [Object[]] NbtStatReference()
        {
            $Out = "00/{0}/Workstation {4};01/{0}/Messenger {6};01/{1}/Master Browser;03"+
            "/{0}/Messenger {6};06/{0}/RAS Server {6};1F/{0}/NetDDE {6};20/{0}/File Serv"+
            "er {6};21/{0}/RAS Client {6};22/{0}/{2} Interchange(MSMail Connector);23/{0"+
            "}/{2} Exchange Store;24/{0}/{2} Directory;30/{0}/{4} Server;31/{0}/{4} Clie"+
            "nt;43/{0}/{3} Control;44/{0}/SMS Administrators Remote Control Tool {6};45/"+
            "{0}/{3} Chat;46/{0}/{3} Transfer;4C/{0}/DEC TCPIP SVC on Windows NT;42/{0}/"+
            "mccaffee anti-virus;52/{0}/DEC TCPIP SVC on Windows NT;87/{0}/{2} MTA;6A/{0"+
            "}/{2} IMC;BE/{0}/{5} Agent;BF/{0}/{5} Application;03/{0}/Messenger {6};00/{"+
            "1}/{7} Name;1B/{0}/{7} Master Browser;1C/{1}/{7} Controller;1D/{0}/Master B"+
            "rowser;1E/{1}/Browser {6} Elections;2B/{0}/Lotus Notes Server;2F/{1}/Lotus "+
            "Notes ;33/{1}/Lotus Notes ;20/{1}/DCA IrmaLan Gateway Server;01/{1}/MS NetB"+
            "IOS Browse Service" 
            
            $Out = $Out -f "UNIQUE","GROUP","Microsoft Exchange","SMS Clients Remote",
            "Modem Sharing","Network Monitor","Service","Domain" 

            Return $Out -Split ";" | % { [NbtStatReference]::New($_) }
        }
        [Object] NbtStatInterface([String]$Type,[String]$Line)
        {
            Return [NbtStatInterface]::New($Type,$Line)
        }
        Refresh()
        {
            $This.Output      = @( )
            $Stack            = nbtstat -N
            ForEach ($Line in $Stack)
            {
                Switch -Regex ($Line)
                {
                    ".+\:$"
                    {
                        $This.Output          += $This.NbtStatInterface("Local",$Line)
                        $This.Count            = $This.Output.Count
                    }
                    "^Node IpAddress"
                    {
                        $This.Output[-1].AddNode($Line)
                    }
                    Registered
                    {
                        $This.Output[-1].AddHost($Line)
                        $This.Output[-1].Output[-1] | % { $_.Service = $This.Reference | ? ID -eq $_.ID | ? Type -eq $_.Type | % Service }
                    }
                }
            }
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NbtStatLocalList>" -f $This.Count
        }
    }

    # // =========================================
    # // | Used for associating a netstat object |
    # // =========================================

    Class NetStatAddress
    {
        Hidden [String]  $Item
        [String]    $IPAddress
        [String]         $Port
        NetStatAddress([String]$Item)
        {
            $This.Item      = $Item

            If ( $Item -match "(\[.+\])" )
            {
                $This.IPAddress = [Regex]::Matches($Item,"(\[.+\])").Value
                $This.Port      = $Item.Replace($This.IPAddress,"")
                $This.IPAddress = $Item.TrimStart("[").Split("%")[0]
            }

            Else
            {
                $This.IPAddress = $This.Item.Split(":")[0]
                $This.Port      = $This.Item.Split(":")[1]
            }
        }
        [String] ToString()
        {
            Return "<FENetwork.NetStatAddress>"
        }
    }

    # // =========================================
    # // | Used for each line of a netstat table |
    # // =========================================

    Class NetStatConnection
    {
        [String]      $Protocol
        [String]  $LocalAddress
        [String]     $LocalPort
        [String] $RemoteAddress
        [String]    $RemotePort
        [String]         $State
        [String]     $Direction
        NetStatConnection([String]$Line)
        {
            $Item               = $Line -Split " " | ? Length -gt 0
            $This.Protocol      = $Item[0]
            $This.LocalAddress  = $This.GetAddress($Item[1])
            $This.LocalPort     = $Item[1].Replace($This.LocalAddress + ":","")
            $This.RemoteAddress = $This.GetAddress($Item[2])
            $This.RemotePort    = $Item[2].Replace($This.RemoteAddress + ":","")
            $This.State         = $Item[3]
            $This.Direction     = $Item[4]
        }
        [String] GetAddress([String]$Item)
        {
            Return @(If ($Item -match "(\[.+\])")
            {
                [Regex]::Matches($Item,"(\[.+\])").Value
            }

            Else
            {
                $Item.Split(":")[0]
            })
        }
        [String] ToString()
        {
            Return "<FENetwork.NetStatConnection>"
        }
    }

    # // ==================================
    # // | Parses an entire netstat table |
    # // ==================================

    Class NetStatList
    {
        [Object]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetStatList()
        {
            $This.Name   = "NetStatList"
        }
        Refresh()
        {
            $This.Output  = @( )
            $This.Count   = 0

            $Table        = netstat -ant
            $Section      = @{}

            ForEach ($Line in $Table)
            {
                If ($Line -match "(TCP|UDP)")
                {
                    $Section.Add($Section.Count,$This.NetstatConnection($Line))
                }
            }

            Switch ($Section.Count)
            {
                0
                {

                }
                1
                {
                    $This.Output  = $Section[0]
                    $This.Count   = 1
                }
                Default
                {
                    $This.Output  = @($Section[0..($Section.Count-1)])
                    $This.Count   = $This.Output.Count
                }
            }
        }
        [Object] NetStatConnection([String]$Line)
        {
            Return [NetStatConnection]::New($Line)
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetStatList>" -f $This.Count
        }
    }

    # // =====================================================
    # // | Represents properties for a NetworkAdapter object |
    # // =====================================================

    Class NetworkAdapterProperty
    {
        [String] $Adapter
        [UInt32]    $Rank
        [String]    $Name
        [Object]   $Value
        NetworkAdapterProperty([UInt32]$Adapter,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Adapter  = $Adapter
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Value    = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapterProperty>"
        }
    }

    # // ======================================
    # // | Represents a NetworkAdapter object |
    # // ======================================

    Class NetworkAdapter
    {
        [UInt32]    $Index
        [UInt32]     $Rank
        [String]     $Name
        [String]     $Type
        [Object] $Property
        NetworkAdapter([Object]$Adapter)
        {
            $This.Rank     = $Adapter.DeviceId
            $This.Name     = $Adapter.Name
            $This.Type     = $Adapter.AdapterType
            $This.Property = @( )

            ForEach ($Item in $Adapter.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetworkAdapterProperty]::New($This.Rank,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapter>"
        }
    }

    # // ===========================================================
    # // | Represents a list of (0 or more) NetworkAdapter objects |
    # // ===========================================================

    Class NetworkAdapterList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkAdapterList()
        {
            $This.Name        = "NetworkAdapterList"
        }
        Refresh()
        {
            $This.Output      = @( )
            ForEach ($Adapter in Get-CimInstance Win32_NetworkAdapter)
            {
                $This.Add($Adapter)
            }

            $This.Output      = $This.Output | Sort-Object Rank
        }
        Add([Object]$Adapter)
        {
            $This.Output += [NetworkAdapter]::New($Adapter)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkAdapterList>" -f $This.Count
        }
    }

    # // ==================================================================
    # // | Represents properties for a NetworkAdapterConfiguration object |
    # // ==================================================================

    Class NetworkAdapterConfigurationProperty
    {
        [String] $Adapter
        [UInt32]    $Rank
        [String]    $Name
        [Object]   $Value
        NetworkAdapterConfigurationProperty([UInt32]$Adapter,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Adapter  = $Adapter
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Value    = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapterConfigurationProperty>"
        }
    }

    # // ===================================================
    # // | Represents a NetworkAdapterConfiguration object |
    # // ===================================================

    Class NetworkAdapterConfiguration
    {
        [UInt32]    $Index
        [UInt32]     $Rank
        [String]     $Name
        [String]  $Service
        [UInt32]     $Dhcp
        [Object] $Property
        NetworkAdapterConfiguration([Object]$Config)
        {
            $This.Rank     = $Config.Index
            $This.Name     = $Config.Description
            $This.Service  = $Config.ServiceName
            $This.Dhcp     = $Config.DhcpEnabled
            $This.Property = @( )

            ForEach ($Item in $Config.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetworkAdapterConfigurationProperty]::New($This.Index,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapterConfiguration>"
        }
    }

    # // ========================================================================
    # // | Represents a list of (0 or more) NetworkAdapterConfiguration objects |
    # // ========================================================================

    Class NetworkAdapterConfigurationList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkAdapterConfigurationList()
        {
            $This.Name   = "NetworkAdapterConfigurationList"
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Config in Get-CimInstance Win32_NetworkAdapterConfiguration)
            {
                $This.Add($Config)
            }
        }
        Add([Object]$Config)
        {
            $This.Output += [NetworkAdapterConfiguration]::New($Config)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkAdapterConfigurationList>" -f $This.Count
        }
    }

    # // ================================================
    # // | Represents properties for a NetworkIp object |
    # // ================================================

    Class NetworkRouteProperty
    {
        [UInt32] $Index
        [UInt32]  $Rank
        [String]  $Name
        [Object] $Value
        NetworkRouteProperty([UInt32]$Index,[UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Name  = $Name
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkRouteProperty>"
        }
    }

    # // ====================================
    # // | Represents a NetworkRoute object |
    # // ====================================

    Class NetworkRoute
    {
        [UInt32]             $Index
        [UInt32]              $Type
        [String] $DestinationPrefix
        [String]           $NextHop
        [UInt32]       $RouteMetric
        [String]             $State
        Hidden [Object]   $Property
        NetworkRoute([Object]$Route)
        {
            $This.Index             = $Route.InterfaceIndex
            $This.Type              = Switch -Regex ($Route.AddressFamily.ToString()) { 4 { 4 } 6 { 6 } }
            $This.DestinationPrefix = $Route.DestinationPrefix
            $This.NextHop           = $Route.NextHop
            $This.RouteMetric       = $Route.RouteMetric
            $This.State             = $Route.State
            $This.Property          = @( )

            ForEach ($Item in $Route.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetworkRouteProperty]::New($This.Index,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkRoute>"
        }
    }

    # // ===========================================================
    # // | Represents a list of (0 or more) NetworkRoute object(s) |
    # // ===========================================================

    Class NetworkRouteList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkRouteList()
        {
            $This.Name   = "NetworkRouteList"
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Route in Get-CimInstance MSFT_NetRoute -Namespace ROOT/StandardCimv2)
            {
                $This.Add($Route)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Item)
        {
            $This.Output += [NetworkRoute]::New($Item)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkRouteList>" -f $This.Count
        }
    }

    # // =======================================================
    # // | Represents properties for a NetworkInterface object |
    # // =======================================================

    Class NetworkInterfaceProperty
    {
        [UInt32]  $Index
        [UInt32]   $Rank
        [UInt32]   $Type
        [String]   $Name
        [Object]  $Value
        NetworkInterfaceProperty([UInt32]$Index,[UInt32]$Rank,[UInt32]$Type,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.Type   = $Type
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkInterfaceProperty>"
        }
    }

    # // ========================================
    # // | Represents a NetworkInterface object |
    # // ========================================

    Class NetworkInterface
    {
        [Object]    $Index
        [String]    $Alias
        [UInt32]     $Type
        [UInt32]     $Dhcp
        [UInt32]     $Open
        [Object] $Property
        NetworkInterface([Object]$Interface)
        {
            $This.Index     = $Interface.InterfaceIndex
            $This.Alias     = $Interface.InterfaceAlias
            $This.Type      = Switch -Regex ($Interface.AddressFamily.ToString()) { 4 { 4 } 6 { 6 } }
            $This.Dhcp      = $Interface.Dhcp -eq "Enabled"
            $This.Open      = $Interface.ConnectionState -eq "Connected"
            $This.Property  = @( )

            ForEach ($Item in $Interface.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetworkInterfaceProperty]::New($This.Index,$This.Property.Count,$This.Type,$Name,$Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkInterface>"
        }
    }

    # // =============================================================
    # // | Represents a list of (0 or more) NetworkInterface objects |
    # // =============================================================

    Class NetworkInterfaceList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkInterfaceList()
        {
            $This.Name   = "NetworkInterfaceList"
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Interface in Get-CimInstance MSFT_NetIPInterface -Namespace ROOT\StandardCimv2)
            {
                $This.Add($Interface)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Interface)
        {
            $This.Output += [NetworkInterface]::New($Interface)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkInterfaceList>" -f $This.Count
        }
    }

    # // ================================================
    # // | Represents properties for a NetworkIp object |
    # // ================================================

    Class NetworkIpProperty
    {
        [UInt32] $Index
        [UInt32]  $Rank
        [String]  $Name
        [Object] $Value
        NetworkIpProperty([UInt32]$Index,[UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Name  = $Name
            $This.Value = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkIpProperty>"
        }
    }

    # // =================================
    # // | Represents a NetworkIp object |
    # // =================================

    Class NetworkIp
    {
        [UInt32]     $Index
        [UInt32]      $Type
        [Object] $IPAddress
        [UInt32]    $Prefix
        [Object]  $Property
        NetworkIp([Object]$Ip)
        {
            $This.Index     = $Ip.InterfaceIndex
            $This.Type      = Switch -Regex ($IP.AddressFamily.ToString()) { 4 { 4 } 6 { 6 } }
            $This.IpAddress = $Ip.IpAddress.ToString().Split("%")[0]
            $This.Prefix    = $Ip.PrefixLength
            $This.Property  = @( )

            ForEach ($Item in $IP.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetworkIpProperty]::New($This.Index,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkIp>"
        }
    }

    # // ======================================================
    # // | Represents a list of (0 or more) NetworkIp objects |
    # // ======================================================

    Class NetworkIpList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkIpList()
        {
            $This.Name   = "NetworkIpList"
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Address in Get-NetIpAddress)
            {
                $This.Add($Address)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$IP)
        {
            $This.Output += [NetworkIp]::New($Ip)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkIpList>" -f $This.Count
        }
    }

    # // ==================================
    # // | Class object for V4 Network(s) |
    # // ==================================

    Class V4Class
    {
        [UInt32] $Index
        [String] $Label
        [String] $Name
        V4Class([UInt32]$Index,[String]$Label,[String]$Name)
        {
            $This.Index = $Index
            $This.Label = $Label
            $This.Name  = $Name
        }
        [String] ToString()
        {
            Return $This.Label
        }        
    }

    # // ==============================
    # // | List object for V4 classes |
    # // ==============================

    Class V4ClassList
    {
        [Object] $Output
        V4ClassList()
        {
            $This.Output = @( ) 

            ForEach ($X in 0..255)
            {
                $Item = Switch ($X)
                {
                    {$_ -eq        0} { "X",       "N/A" }
                    {$_ -in   1..126} { "A",   "Class A" }
                    {$_ -eq      127} { "L",     "Local" }
                    {$_ -in 128..191} { "B",   "Class B" }
                    {$_ -in 192..223} { "C",   "Class C" }
                    {$_ -in 224..239} { "M", "Multicast" }
                    {$_ -in 240..254} { "R",  "Reserved" }
                    {$_ -eq      255} { "B", "Broadcast" }
                }

                $This.Add($X,$Item[0],$Item[1])
            }
        }
        Add([UInt32]$Index,[String]$Label,[String]$Name)
        {
            $This.Output += [V4Class]::New($Index,$Label,$Name)
        }
        [Object] Get([String]$IpAddress)
        {
            Return $This.Output[$IPAddress.Split(".")[0]]
        }
    }

    # // ============================================
    # // | Object returned from a ping (sweep/scan) |
    # // ============================================

    Class V4PingResponse
    {
        [UInt32]          $Index
        Hidden [UInt32]  $Status
        [String]      $IPAddress
        [String]       $Hostname
        V4PingResponse([UInt32]$Index,[String]$Address,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = $Reply.Result.Status -match "Success"
            $This.IPAddress      = $Address
        }
        GetHostname()
        {
            $This.Hostname       = Try {[System.Net.Dns]::Resolve($This.IPAddress).Hostname} Catch {"<Unknown>"}
        }
        Domain([String]$Domain)
        {
            If ($This.Hostname -match $Domain)
            {
                $This.Hostname = ("{0}.{1}" -f $This.Hostname, $Domain)
            }
        }
        [String] ToString()
        {
            Return $This.IPAddress
        }
    }

    # // ==============================================================
    # // | Provisions an entire IPV4 network range, information, etc. |
    # // ==============================================================

    Class V4Network
    {
        [String]                $IPAddress
        [UInt32]                   $Prefix
        [String]                    $Class
        [String]                  $Netmask
        [String]                  $Network
        [String]                  $Gateway
        [String]                    $Range
        [String]                $Broadcast
        V4Network([Object]$Interface)
        {
            $This.IPAddress   = $Interface.IPAddress
            $This.Prefix      = $Interface.Prefix
            $This.Network     = $Interface.Route | ? DestinationPrefix -match "/$($This.Prefix)" | % DestinationPrefix

            If (!$This.Network)
            {
                $This.Network = "-"
            }

            $This.Gateway     = $Interface.Route | ? DestinationPrefix -match 0.0.0.0/0 | % NextHop

            If (!$This.Gateway)
            {
                $This.Gateway = "-"
            }

            If (!$This.Network)
            {
                $This.Network = "-"
            }
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.IPAddress, $This.Prefix
        }
    }

    # // =====================================
    # // | Provisions an entire IPV6 network |
    # // =====================================

    Class V6Network
    {
        [String] $IPAddress
        [UInt32]    $Prefix
        [String]      $Type
        V6Network([Object]$Interface)
        {
            $This.IpAddress = $Interface.IpAddress
            $This.Prefix    = $Interface.Prefix
            $This.Type      = Switch -Regex ($This.IpAddress)
            {
                "^fe80\:" { "Link-Local" }
                "^2001\:" {     "Global" }
                Default   {  "Specified" }
            }
        }
        [String] ToString()
        {
            Return ("{0}/{1}" -f $This.IPAddress, $This.Prefix)
        }
    }

    # // ========================================================================
    # // | Controls various subcomponents of each individual network controller |
    # // ========================================================================

    Class NetworkControllerObjectList
    {
        Hidden [UInt32] $Rank
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        NetworkControllerObjectList([String]$Type)
        {
            $This.Rank   = $This.SetRank($Type)
            $This.Name   = $Type
            $This.Output = @( )
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
            $This.Count   = $This.Output.Count
        }
        [UInt32] SetRank([String]$Type)
        {
            $Item = Switch -Regex ($Type) 
            { 
                Interface {0} 
                IP        {1} 
                Route     {2} 
                Arp       {3}
                Nbt       {4} 
            }

            Return $Item
        }
        [String] ToString()
        {
            Return ("({0}) {1}" -f $This.Count, ($This.Output -join ", "))
        }
    }

    # // ======================================================================
    # // | Template object meant to assemble individual controller properties |
    # // ======================================================================

    Class NetworkControllerTemplate
    {
        [UInt32]          $Index
        [String]           $Name
        [String]     $MacAddress
        [String]         $Vendor = "-"
        [Object]        $Adapter
        [Object]         $Config
        [Object]      $Interface
        [Object]             $IP
        [Object]          $Route
        [Object]            $Arp
        [Object]            $Nbt
        NetworkControllerTemplate([UInt32]$Index,[Object]$Adapter,[Object]$Config)
        {
            $This.Index      = $Index
            $This.Adapter    = $Adapter
            $This.Config     = $Config
            $This.Name       = $This.Get(0,"Name")
            $This.MacAddress = $This.Get(1,"MacAddress")

            If (!$This.MacAddress)
            {
                $This.MacAddress = "-"
            }

            ForEach ($Item in "Interface","IP","Route","Arp","Nbt")
            {
                $This.$Item     = $This.NetworkControllerObjectList($Item)
            }
        }
        [Object] NetworkControllerObjectList([String]$Type)
        {
            Return [NetworkControllerObjectList]::New($Type)
        }
        [Object] Get([UInt32]$Slot,[String]$Property)
        {
            If ($Slot -notin 0,1)
            {
                Throw "Invalid slot"
            }

            $Item = Switch ($Slot)
            {
                0 { $This.Adapter.Property }
                1 { $This.Config.Property  }
            }

            Return $Item | ? Name -eq $Property | % Value
        }
        SetVendor([Object]$Vendor)
        {
            $This.Vendor = $Vendor.Find($This.MacAddress)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerTemplate>"
        }
    }

    # // =========================================================
    # // | List object meant to contain individual controller(s) |
    # // =========================================================

    Class NetworkControllerTemplateList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkControllerTemplateList()
        {
            $This.Name = "NetworkControllerTemplateList"
        }
        Clear()
        {
            $This.Output  = @( )
            $This.Count   = 0
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkControllerTemplateList>" -f $This.Count
        }
    }

    # // ============================================================================
    # // | For fine-grained control over all various properties in each compartment |
    # // ============================================================================

    Class NetworkControllerCompartmentProperty
    {
        [UInt32] $Index
        [String] $Source
        [String] $Name
        [Object] $Value
        NetworkControllerCompartmentProperty([UInt32]$Index,[String]$Source,[Object]$Property)
        {
            $This.Index  = $Index
            $This.Source = $Source
            $This.Name   = $Property.Name
            $This.Value  = $Property.Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerCompartmentProperty>"
        }
    }

    # // ===========================================================================================
    # // | Provides control for each individual interface + IP + AddressFamily + Route + Arp + Nbt |
    # // ===========================================================================================

    Class NetworkControllerCompartment
    {
        [UInt32]                 $Index
        Hidden [UInt32]           $Type
        Hidden [Object]        $Adapter
        Hidden [Object]         $Config
        Hidden [Object]      $Interface
        Hidden [Object]             $Ip
        [UInt32]        $InterfaceIndex
        [String]        $InterfaceAlias
        [UInt32]         $AddressFamily
        [UInt32]                  $Dhcp
        [UInt32]             $Connected
        [String]             $IpAddress
        [UInt32]                $Prefix
        [Object]               $Network
        [Object]                 $Route
        [Object]                   $Arp
        [Object]                   $Nbt
        [Object]              $Property
        [Object]             $Extension
        NetworkControllerCompartment([UInt32]$Index,[Object]$Adapter,[Object]$Config,[Object]$Interface,[Object]$IP)
        {
            $This.Index          = $Index
            $This.Type           = $Interface.Type
            $This.Adapter        = $Adapter
            $This.Config         = $Config
            $This.Interface      = $Interface
            $This.IP             = $IP
            $This.InterfaceIndex = $Interface.Index
            $This.InterfaceAlias = $Interface.Alias
            $This.AddressFamily  = $Interface.Type
            $This.Dhcp           = $Interface.Dhcp
            $This.Connected      = $Interface.Open
            $This.IPAddress      = $IP.IPAddress
            $This.Prefix         = $IP.Prefix
            $This.Network        = 

            $This.Property       = @( )

            ForEach ($Item in "Adapter","Config","Interface","IP")
            {
                ForEach ($Property in $This.$Item.Property | ? Name -notmatch Cim)
                {
                    $This.AddCompartmentProperty($Item,$Property)
                }
            }
        }
        AddCompartmentProperty([String]$Source,[Object]$Property)
        {
            $This.Property += [NetworkControllerCompartmentProperty]::New($This.Property.Count,$Source,$Property)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerCompartment>"
        }
    }

    Class NetworkControllerCompartmentList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkControllerCompartmentList()
        {
            $This.Name   = "NetworkControllerCompartmentList"
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkControllerCompartmentList>" -f $This.Count
        }
    }

    # // ================================================================
    # // | Network controller master allows refreshing individual items |
    # // | from all of the previous classes, and provides extensions    |
    # // ================================================================

    Class NetworkControllerMaster
    {
        [UInt32] $Mode
        [Object] $Class
        [Object] $Vendor
        [Object] $Arp
        [Object] $NbtLocal
        [Object] $NetStat
        [Object] $Adapter
        [Object] $Config
        [Object] $Route
        [Object] $Interface
        [Object] $Ip
        [Object] $Compartment
        NetworkControllerMaster([UInt32]$Mode)
        {
            $This.Mode      = $Mode
            $This.Class     = $This.V4ClassList()

            <#
            ===========================================
            | 00 | [ ] Vendor [ ] Arp/Nbt [ ] Netstat |
            | 01 | [ ] Vendor [ ] Arp/Nbt [X] Netstat |
            | 02 | [ ] Vendor [X] Arp/Nbt [ ] Netstat |
            | 03 | [ ] Vendor [X] Arp/Nbt [X] Netstat |
            | 04 | [X] Vendor [ ] Arp/Nbt [ ] Netstat |
            | 05 | [X] Vendor [ ] Arp/Nbt [X] Netstat |
            | 06 | [X] Vendor [X] Arp/Nbt [ ] Netstat |
            | 07 | [X] Vendor [X] Arp/Nbt [X] Netstat |
            ===========================================
            #>

            If ($This.Mode -in 4..7)
            {
                $This.Vendor    = [VendorList]::New()
            }

            If ($This.Mode -in 2,3,6,7)
            {
                $This.Arp       = [ArpList]::New()
                $This.NbtLocal  = [NbtStatLocalList]::New()
            }

            If ($This.Mode -in 1,3,5,7)
            {
                $This.NetStat   = [NetStatList]::New()
            }

            $This.Adapter       = [NetworkAdapterList]::New()
            $This.Config        = [NetworkAdapterConfigurationList]::New()
            $This.Route         = [NetworkRouteList]::New()
            $This.Interface     = [NetworkInterfaceList]::New()
            $This.Ip            = [NetworkIpList]::New()
            $This.Compartment   = [NetworkControllerCompartmentList]::New()
        }
        [Object] V4Network([Object]$Interface)
        {
            $Item             = [V4Network]::New($Interface)
            
            # Class
            $Item.Class       = $This.Class.Get($Item.IPAddress)

            # Netmask
            $Str              = (0..31 | % { [Int32]($_ -lt $Item.Prefix); If ($_ -in 7,15,23) {"."} }) -join ''
            $Item.Netmask     = ($Str.Split(".") | % { [Convert]::ToInt32($_,2 ) }) -join "."

            If (!!$Item.Network)
            {
                $This.V4HostRange($Item)
                $This.V4Broadcast($Item)
            }

            Return $Item
        }
        [Void] V4HostRange([Object]$Item)
        {
            $Item.Range       = @( Switch ($Item.Network)
            {
                "-"
                {
                    "N/A"
                }
                Default
                {
                    $X = [UInt32[]]$Item.Network.Split("/")[0].Split(".")
                    $Y = [UInt32[]]$Item.Netmask.Split(".") | % { (256 - $_) - 1 }
                    @( ForEach ($I in 0..3)
                    {
                        Switch($Y[$I])
                        {
                            0 { $X[$I] } Default { "{0}..{1}" -f $X[$I],($X[$I]+$Y[$I]) }
                        }
                    } ) -join '/'
                }
            })
        }
        [Void] V4Broadcast([Object]$Item)
        {
            If ($Item.Network -ne "-")
            {
                $Split   = $Item.Range.Split("/")
                $T       = @{ }
                0..3     | % { $T.Add($_,(Invoke-Expression $Split[$_])) }

                $Item.Broadcast  = Switch -Regex ($Item.Class)
                {
                    "(^A$|^Local$)" { $T[0], $T[1][-1], $T[2][-1], $T[3][-1] -join "." }
                    "(^Apipa$|^MC$|^R$'|^BC$)" { "-" }
                    ^B$             { $T[0], $T[1]    , $T[2][-1], $T[3][-1] -join "." }
                    ^C$             { $T[0], $T[1]    , $T[2]    , $T[3][-1] -join "." }
                }
            }
            Else
            {
                $Item.Broadcast = "-"
            }
        }
        [Object] V6Network([Object]$Interface)
        {
            Return [V6Network]::New($Interface)
        }
        [Object] V4ClassList()
        {
            Return [V4ClassList]::New()
        }
        [Object] V4PingOptions()
        {
            Return [System.Net.NetworkInformation.PingOptions]::New()
        }
        [Object] V4PingBuffer()
        {
            Return 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
        }
        [Object] V4Ping([String]$Ip)
        {
            $Item = [System.Net.NetworkInformation.Ping]::New()
            Return $Item.SendPingAsync($Ip,100,$This.V4PingBuffer(),$This.V4PingOptions())
        }
        [Object] V4PingResponse([UInt32]$Index,[Object]$Ip,[Object]$Ping)
        {
            Return [V4PingResponse]::New($Index,$Ip,$Ping)
        }
        [Object] V4PingSweep([Object]$Compartment)
        {
            If ($Compartment.Type -ne 4)
            {
                Throw "Not a valid IPv4 compartment"
            }
    
            $Start = [DateTime]::Now
            $X     = @{ }
            $H     = @{ }
            $P     = @{ }
            $R     = @{ }
    
            # Expand notation
            ForEach ($Item in $Compartment.Network.Range -Split "\/")
            {
                $X.Add($X.Count,($Item | Invoke-Expression))
            }
    
            # Populate total possible hosts from notation
            ForEach ($0 in $X[0])
            {
                ForEach ($1 in $X[1])
                {
                    ForEach ($2 in $X[2])
                    {
                        ForEach ($3 in $X[3])
                        {
                            $H.Add($H.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }
    
            # Throw if no addresses detected
            If ($H.Count -eq 0)
            {
                Throw "No addresses detected"
            }
    
            # If (1) address detected
            If ($H.Count -eq 1)
            {
                Write-Host "Scanning [~] (1) Host" 
                $P.Add(0,$Ctrl.V4Ping($H[0]))
    
                # Await response
                Write-Host "Sent [~] Awaiting Response"
                $R.Add(0,$Ctrl.V4PingResponse(0,$H[0],$P[0]))
    
                # Prepare output
                $Output = $R[0] | ? Status
            }
    
            # If (1+) address detected
            ElseIf ($H.Count -gt 1)
            {
                Write-Host ("Scanning [~] ({0}) Hosts" -f $H.Count)
                ForEach ($I in 0..($H.Count-1))
                { 
                    $P.Add($P.Count,$Ctrl.V4Ping($H[$I]))
                }
    
                # Await response
                Write-Host "Sent [~] Awaiting Response"
                ForEach ($I in 0..($P.Count-1)) 
                {
                    $R.Add($I,$Ctrl.V4PingResponse($I,$H[$I],$P[$I]))
                }
    
                # Prepare output
                $Output = $R[0..($R.Count-1)] | ? Status
            }
    
            # Show process
            Write-Host "Scanned [+] ($($Output.Count)) Host(s) reponded [$($Ctrl.Elapsed($Start))]"
    
            # Regardless of output count
            Write-Host "Resolving [~] Hostnames [$($Ctrl.Elapsed($Start))]"
            ForEach ($Object in $Output)
            {
                $Object.GetHostname()
            }
    
            Write-Host "Resolved [+] Hostnames [$($Ctrl.Elapsed($Start))]"
    
            Return $Output
        }
        [Object] Elapsed([Object]$Start)
        {
            Return [Timespan]([DateTime]::Now-$Start)
        }
        [Object] NetworkControllerTemplate([UInt32]$Index,[UInt32]$Rank)
        {
            Return [NetworkControllerTemplate]::New($Index,
                                                    $This.Adapter.Output[$Rank],
                                                    $This.Config.Output[$Rank])
        }
        Refresh()
        {
            $Template = [NetworkControllerTemplateList]::New()
            $Template.Clear()

            If ($This.Mode -in 2,3,6,7)
            {
                $This.Arp.Refresh()
                $This.NbtLocal.Refresh()
                ForEach ($Item in $This.NbtLocal.Output)
                {
                    $Item.Index = $This.Arp.Output | ? IPAddress -eq $Item.IPAddress | % Index
                }

                <# Todo: Add [NbtRemote] #>
            }

            If ($This.Mode -in 1,3,5,7)
            {
                $This.NetStat.Refresh()
            }

            $This.Adapter.Refresh()
            $This.Config.Refresh()
            $This.Route.Refresh()
            $This.Interface.Refresh()
            $This.Ip.Refresh()

            ForEach ($X in 0..($This.Adapter.Output.Count-1))
            {
                $Index        = $This.Config.Output[$X].Property | ? Name -eq InterfaceIndex | % Value
                $Id           = $This.NetworkControllerTemplate($Index,$X)
        
                If ($This.Mode -in 4..7)
                {
                    If ($Id.MacAddress -ne "-")
                    {
                        $Id.SetVendor($This.Vendor)
                    }
                }

                If ($This.Mode -in 1,3,5,7)
                {
                    ForEach ($Item in $This.Arp.Output | ? Index -eq $Index)
                    {
                        $Id.Arp.Add($Item)
                    }

                    ForEach ($Item in $This.NbtLocal.Output | ? Index -eq $Index)
                    {
                        $Id.Nbt.Add($Item)
                    }
                }

                ForEach ($Item in $This.Interface.Output | ? Index -eq $Index)
                {
                    $Id.Interface.Add($Item)
                }
        
                ForEach ($Item in $This.Ip.Output | ? Index -eq $Index)
                {
                    $Id.IP.Add($Item)
                }
        
                ForEach ($Item in $This.Route.Output | ? Index -eq $Index)
                {
                    $Id.Route.Add($Item)
                }
        
                $Template.Add($Id)
            }

            $Template.Output = $Template.Output | Sort-Object Index

            $This.Compartment.Clear()
    
            ForEach ($X in 0..($Template.Output.Count-1))
            {
                $Object = $Template.Output[$X]
                ForEach ($Type in 4,6)
                {
                    ForEach ($Interface in $Object.Interface.Output | ? Type -eq $Type)
                    {
                        ForEach ($IP in $Object.IP.Output | ? Type -eq $Type)
                        {
                            $Item       = [NetworkControllerCompartment]::New($This.Compartment.Count,
                                                                              $Object.Adapter,
                                                                              $Object.Config,
                                                                              $Interface,
                                                                              $IP)
                            $Item.Route = $Object.Route.Output | ? Type -eq $Type
                            If ($Type -eq 4)
                            {
                                $Item.Network = $This.V4Network($Item)

                                If ($Object.Arp.Count -gt 0)
                                {
                                    $Item.Arp = $Object.Arp.Output
                                }
                                If ($Object.Nbt.Count -gt 0)
                                {
                                    $Item.Nbt = $Object.Nbt.Output
                                }
                            }
                            If ($Type -eq 6)
                            {
                                $Item.Network = $This.V6Network($Item)
                            }
            
                            $This.Compartment.Add($Item)
                        }
                    }
                }
            }
        }
        [Object] Section([Object]$Object,[String[]]$Names)
        {
            Return New-FEFormat -Section $Object $Names
        }
        [Object] Table([Object]$Object,[String[]]$Names)
        {
            Return New-FEFormat -Table $Object $Names
        }
        Box([Hashtable]$Hash,[String]$Line)
        {
            $Hash.Add($Hash.Count,(@([Char]95) * ($Line.Length + 4) -join ''))
            $Hash.Add($Hash.Count,"| $Line |")
            $Hash.Add($Hash.Count,(@([Char]175) * ($Line.Length + 4) -join ''))
        }
        Add([Hashtable]$Hash,[Object]$Object)
        {
            $Object | % { $Hash.Add($Hash.Count,$_) }
        }
        [Hashtable] Prop()
        {
            Return [Hashtable]@{

                Config    = "Index","Name","MacAddress","Vendor"
                IPv4      = "IPAddress","Class","Prefix","Netmask","Network","Gateway","Range","Broadcast"
                Route     = "DestinationPrefix","NextHop","RouteMetric","State"
                Arp       = "IPAddress","Physical","Type"
                Nbt       = "Name","Id","Type","Service"
                IPv6      = "IPAddress","Prefix","Type"
                Netstat   = "Protocol","LocalAddress","LocalPort","RemoteAddress","RemotePort","State","Direction"
            }
        }
        [Object] List()
        {
            $Prop         = $This.Prop()

            $Section      = $This.Section($This.Output,$Prop.Config)
            $Out          = @{ }

            $This.Box($Out,"Hostname: $($This.Hostname)")

            ForEach ($X in 0..($Section.Count-1))
            {
                # // ==================
                # // | Section Header |
                # // ==================

                $This.Add($Out,$Section.Draw($X))
        
                # // ===================
                # // | Section Content |
                # // ===================

                $Item = $This.Output[$X]

                If (!!$Item.IPv4)
                {
                    $This.Box($Out,"====[ IPv4 IP Address ]==============================")
                    $This.Add($Out,$This.Table($Item.IPv4,$Prop.IPv4).Draw())
                }
                If (!!$Item.IPv4.Route)
                {
                    $This.Box($Out,"====[ IPv4 IP Route ]================================")
                    $This.Add($Out,$This.Table($Item.IPv4.Route,$Prop.Route).Draw())
                }

                If (!!$Item.Arp)
                {
                    $This.Box($Out,"====[ IPv4 Address Resolution Protocol ]=============")
                    $This.Add($Out,$This.Table($Item.Arp,$Prop.Arp).Draw())
                }

                If (!!$Item.Nbt)
                {
                    $This.Box($Out,"====[ IPv4 NetBEUI Hostmap ]=========================")
                    $This.Add($Out,$This.Table($Item.Nbt,$Prop.Nbt).Draw())
                }

                If (!!$Item.IPv6)
                {
                    $This.Box($Out,"====[ IPv6 IP Address ]==============================")
                    $This.Add($Out,$This.Table($Item.IPv6,$Prop.IPv6).Draw())
                }
                If (!!$Item.IPv6.Route)
                {
                    $This.Box($Out,"====[ IPv6 IP Route ]================================")
                    $This.Add($Out,$This.Table($Item.IPv6.Route,$Prop.Route).Draw())
                }
            }

            If ($This.Netstat)
            {
                $This.Box($Out,"====[ Network Statistics ]===========================")
                $This.Add($Out,$This.Table($This.Netstat,$Prop.Netstat).Draw())
            }

            Return $Out[0..($Out.Count-1)]
        }
    }

    $Ctrl = [NetworkControllerMaster]::New($Mode)
    $Ctrl.Refresh()
    $Ctrl
}
