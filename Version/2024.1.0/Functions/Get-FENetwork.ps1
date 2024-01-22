<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 17:38:54                                                                  //
 \\==================================================================================================// 

    FileName   : Get-FENetwork.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : Extensive and elaborate utility meant to obtain and organize:
                 [+] hardware vendors
                 [+] (ARP/address resolution protocol) information
                 [+] (NBT/NetBEUI table) statistics
                 [+] (NetStat/network) statistics
                 [+] network interfaces
                 [+] network IP addresses
                 [+] network routes
                 [+] extended WMI/CIM properties
                 [+] compartments for each individual address family and type
                 [+] extensions that manage (V4/V6) network capabilities
                 [+] filtering everything into their own coresponding output types
                 [+] allowing for a domain controller to join an Active Directory domain (DCPromo)
                 [+] able to be extended with additional features
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : NBT scan remote addresses

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

    # // ====================================================================================================
    # // | Creates a time object similar to the [System.Diagnostics.Stopwatch] object, but is much simpler. |
    # // ====================================================================================================

    Class Time
    {
        Hidden [Object] $Start
        Time()
        {
            $This.Start = [DateTime]::Now
        }
        [String] ToString()
        {
            Return [Timespan]([DateTime]::Now-$This.Start)
        }
    }

    # // ========================================
    # // | Enum types for FENetwork mode switch |
    # // ========================================

    Enum ModeType
    {
        None
        NetstatOnly
        ArpNbtOnly
        ArpNbtNetstat
        VendorOnly
        VendorNetstat
        VendorArpNbt
        All
    }

    # // ====================================
    # // | Individual FENetwork mode switch |
    # // ====================================

    Class ModeItem
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        ModeItem([UInt32]$Index,[String]$Type)
        {
            $This.Index = $Index
            $This.Type  = [ModeType]::$Type
        }
        [String] ToString()
        {
            Return $This.Index
        }
    }

    # // =======================================
    # // | List of all FENetwork mode switches |
    # // =======================================

    Class ModeList
    {
        [String]     $Name
        [UInt32]    $Count
        [Object]   $Output
        [Object] $Selected
        ModeList()
        {
            $This.Name        = "ModeList"
            $This.Output      = @( )

            ForEach ($Name in [System.Enum]::GetNames([ModeType]))
            {
                $This.Add($Name)
            }

            $This.Selected    = $This.Select(0)
        }
        Add([String]$Type)
        {
            $Item             = [ModeItem]::New($This.Output.Count,$Type) 
            $Item.Description = Switch ($Item.Index)
            {
                0 { "[ ] Vendor [ ] Arp/Nbt [ ] Netstat" }
                1 { "[ ] Vendor [ ] Arp/Nbt [X] Netstat" }
                2 { "[ ] Vendor [X] Arp/Nbt [ ] Netstat" }
                3 { "[ ] Vendor [X] Arp/Nbt [X] Netstat" }
                4 { "[X] Vendor [ ] Arp/Nbt [ ] Netstat" }
                5 { "[X] Vendor [ ] Arp/Nbt [X] Netstat" }
                6 { "[X] Vendor [X] Arp/Nbt [ ] Netstat" }
                7 { "[X] Vendor [X] Arp/Nbt [X] Netstat" }
            }
            $This.Output     += $Item
            $This.Count       = $This.Output.Count
        }
        Select([UInt32]$Index)
        {
            $This.Selected    = $This.Output[$Index]
        }
        [String] ToString()
        {
            Return $This.Selected.Index
        }
    }

    # // ================================================
    # // | Collects DNS Suffix/registration information |
    # // ================================================

    Class DNSSuffix
    {
        [UInt32]     $IsDomain
        [String] $ComputerName
        [String]       $Domain
        [String]     $NVDomain
        [UInt32]         $Sync
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
                ForEach ($Item in "Domain","NV Domain")
                {
                    Set-ItemProperty -Path $This.Path -Name $Item -Value $This.Domain -Verbose 
                }
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
        [String]   $Hex
        [String]  $Name
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
        [String]   $Name
        [UInt32]  $Count
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
        [String] $IPAddress
        [String]  $Physical
        [String]      $Type
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
        [UInt32]     $Index
        [String]      $Type
        [String] $IpAddress
        [Object]      $Host
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
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
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
        [UInt32]   $Index
        [String]    $Name
        [String]      $Id
        [String]    $Type
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
        [UInt32]     $Index
        [String]      $Type
        [String]      $Name
        [String] $IpAddress
        [String]      $Node
        [UInt32]     $Count
        [Object]    $Output
        NbtStatInterface([String]$Type,[String]$Line)
        {
            $Line           = $Line.TrimEnd(" ")
            $This.Type      = $Type
            $This.Name      = $Line.TrimEnd(":")
            $This.Output    = @( )
        }
        AddNode([String]$Line,[String]$IpAddress)
        {
            $Split          = $Line -Replace "Scope","`nScope" -Split "`n"
            $This.IpAddress = [Regex]::Matches($Split[0],"(\d+\.){3}\d+").Value
            $This.Node      = @($This.IpAddress,$IpAddress)[!!$IpAddress]
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

    Class NbtStatList
    {
        Hidden [Object] $Reference
        [String]             $Name
        [UInt32]            $Count
        [Object]           $Output
        NbtStatList()
        {
            # // =================================================
            # // | Get NBT Reference table, and collect NBT info |
            # // =================================================

            $This.Name        = "NbtStatList"
            $This.Reference   = $This.GetNbtStatReference()
            $This.Output      = @( )
        }
        Refresh()
        {
            $This.Output      = @( )
            $This.Count       = 0

            $This.Local()
        }
        Local()
        {
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
                        $This.Output[-1].AddNode($Line,$Null)
                    }
                    Registered
                    {
                        $This.Output[-1].AddHost($Line)
                        $This.Output[-1].Output[-1] | % { $_.Service = $This.Service($_) }
                    }
                }
            }
            
        }
        Remote([Object]$Node)
        {
            $Stack         = nbtstat -A $Node.IpAddress
            ForEach ($Line in $Stack)
            {
                Switch -Regex ($Line)
                {
                    ".+\:$"
                    {
                        $This.Output          += $This.NbtStatInterface("Remote",$Line)
                        $This.Count            = $This.Output.Count
                    }
                    "^Node IpAddress"
                    {
                        $This.Output[-1].AddNode($Line,$Node.IpAddress)
                    }
                    Registered
                    {
                        $This.Output[-1].AddHost($Line)
                        $This.Output[-1].Output[-1] | % { $_.Service = $This.Service($_) }
                    }
                }
            }
        }
        [String] Service([Object]$Item)
        {
            Return $This.Reference | ? Id -eq $Item.Id | ? Type -eq $Item.Type | % Service
        }
        [Object[]] GetNbtStatReference()
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
        [String] ToString()
        {
            Return "({0}) <FENetwork.NbtStatList>" -f $This.Count
        }
    }

    # // =========================================
    # // | Used for associating a netstat object |
    # // =========================================

    Class NetStatAddress
    {
        [String] $IpAddress
        [String]      $Port
        NetStatAddress([String]$Item)
        {
            If ($Item -match "(\[.+\])")
            {
                $This.IpAddress = [Regex]::Matches($Item,"(\[.+\])").Value
                $This.Port      = $Item.Replace($This.IpAddress,"")
                $This.IPAddress = $Item.TrimStart("[").Split("%")[0]
            }

            Else
            {
                $This.IpAddress = $Item.Split(":")[0]
                $This.Port      = $Item.Split(":")[1]
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
            $This.Property += [NetworkAdapterProperty]::New($This.Rank,
                                                            $This.Property.Count,
                                                            $Name,
                                                            $Value)
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
        [Object[]] Cmdlet()
        {
            Return Get-CimInstance Win32_NetworkAdapter
        }
        Refresh()
        {
            $This.Output      = @( )
            ForEach ($Adapter in $This.CmdLet())
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

    Class NetworkAdapterConfigProperty
    {
        [String] $Adapter
        [UInt32]    $Rank
        [String]    $Name
        [Object]   $Value
        NetworkAdapterConfigProperty([UInt32]$Adapter,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Adapter  = $Adapter
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Value    = $Value
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapterConfigProperty>"
        }
    }

    # // ============================================
    # // | Represents a NetworkAdapterConfig object |
    # // ============================================

    Class NetworkAdapterConfig
    {
        [UInt32]    $Index
        [UInt32]     $Rank
        [String]     $Name
        [String]  $Service
        [UInt32]     $Dhcp
        [Object] $Property
        NetworkAdapterConfig([Object]$Config)
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
            $This.Property += [NetworkAdapterConfigProperty]::New($This.Index,
                                                                  $This.Property.Count,
                                                                  $Name,
                                                                  $Value)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkAdapterConfig>"
        }
    }

    # // =================================================================
    # // | Represents a list of (0 or more) NetworkAdapterConfig objects |
    # // =================================================================

    Class NetworkAdapterConfigList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkAdapterConfigList()
        {
            $This.Name   = "NetworkAdapterConfigList"
        }
        [Object[]] Cmdlet()
        {
            Return Get-CimInstance Win32_NetworkAdapterConfiguration
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Config in $This.Cmdlet())
            {
                $This.Add($Config)
            }
        }
        Add([Object]$Config)
        {
            $This.Output += [NetworkAdapterConfig]::New($Config)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.NetworkAdapterConfigList>" -f $This.Count
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
            $This.Type              = Switch -Regex ($Route.AddressFamily.ToString()) 
                                      { 
                                        4 { 4 } 
                                        6 { 6 } 
                                      }
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
            $This.Property += [NetworkRouteProperty]::New($This.Index,
                                                          $This.Property.Count,
                                                          $Name,
                                                          $Value)
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
        [Object[]] Cmdlet()
        {
            Return Get-CimInstance MSFT_NetRoute -Namespace ROOT/StandardCimv2
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($Route in $This.Cmdlet())
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
        [UInt32] $Index
        [UInt32]  $Rank
        [UInt32]  $Type
        [String]  $Name
        [Object] $Value
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
            $This.Type      = Switch -Regex ($Interface.AddressFamily.ToString()) 
                              { 
                                4 { 4 } 
                                6 { 6 } 
                              }
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
            $This.Property += [NetworkInterfaceProperty]::New($This.Index,
                                                              $This.Property.Count,
                                                              $This.Type,
                                                              $Name,
                                                              $Value)
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
        [Object[]] Cmdlet()
        {
            Return Get-CimInstance MSFT_NetIPInterface -Namespace ROOT\StandardCimv2
        }
        Refresh()
        {
            $This.Output = @( )

            ForEach ($If in $This.Cmdlet())
            {
                $This.Add($If)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$If)
        {
            $This.Output += [NetworkInterface]::New($If)
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
        [Object] $IpAddress
        [UInt32]    $Prefix
        [Object]  $Property
        NetworkIp([Object]$Ip)
        {
            $This.Index     = $Ip.InterfaceIndex
            $This.Type      = Switch -Regex ($IP.AddressFamily.ToString()) 
                              { 
                                4 { 4 } 
                                6 { 6 } 
                              }
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
            $This.Property += [NetworkIpProperty]::New($This.Index,
                                                       $This.Property.Count,
                                                       $Name,
                                                       $Value)
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
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        V4ClassList()
        {
            $This.Name   = "V4ClassList"
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
            $This.Count   = $This.Output.Count
        }
        [Object] Get([String]$IpAddress)
        {
            Return $This.Output[$IPAddress.Split(".")[0]]
        }
        [String] ToString()
        {
            Return "({0}) <FENetwork.V4ClassList>" -f $This.Count
        }
    }

    # // ============================================
    # // | Object returned from a ping (sweep/scan) |
    # // ============================================

    Class V4PingResponse
    {
        Hidden [UInt32]   $Index
        Hidden [UInt32]  $Status
        [String]      $IpAddress
        [String]       $Hostname
        V4PingResponse([UInt32]$Index,[String]$Address,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = $Reply.Result.Status -match "Success"
            $This.IPAddress      = $Address
        }
        GetHostname()
        {
            $This.Hostname       = Try 
            { 
                [System.Net.Dns]::Resolve($This.IPAddress).Hostname 
            } 
            Catch 
            { 
                "<Unknown>" 
            }
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
        [String] $IpAddress
        [UInt32]    $Prefix
        [String]     $Class
        [String]   $Netmask
        [String]   $Network
        [String]   $Gateway
        [String]     $Range
        [String] $Broadcast
        V4Network([Object]$If)
        {
            $This.IpAddress   = $If.IpAddress
            $This.Prefix      = $If.Prefix
            $This.Network     = $This.GetDestinationPrefix($If)

            If (!$This.Network)
            {
                $This.Network = "-"
            }

            $This.Gateway     = $If.Route | ? DestinationPrefix -match 0.0.0.0/0 | % NextHop

            If (!$This.Gateway)
            {
                $This.Gateway = "-"
            }

            If (!$This.Network)
            {
                $This.Network = "-"
            }
        }
        [String] GetDestinationPrefix([Object]$If)
        {
            Return $If.Route | ? DestinationPrefix -match "/$($This.Prefix)" | % DestinationPrefix
        }
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.IPAddress, $This.Prefix
        }
    }

    # // ======================================
    # // | Provisions an entire IPV6 network* |
    # // ======================================

    Class V6Network
    {
        [String] $IpAddress
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

    # // =====================================================================================
    # // | Base class for controlling various components of each network controller template |
    # // =====================================================================================

    Class NetworkControllerObjectList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NetworkControllerObjectList([String]$Type)
        {
            $This.Name    = $Type
            $This.Clear()
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
            Return ("({0}) {1}" -f $This.Count, ($This.Output -join ", "))
        }
    }

    # // ===========================================================================
    # // | For collecting total number of interfaces per (adapter/config/template) |
    # // ===========================================================================

    Class NetworkControllerInterfaceList : NetworkControllerObjectList
    {
        NetworkControllerInterfaceList([String]$Type) : base($Type)
        {

        }
    }

    # // =============================================================================
    # // | For collecting total number of IP addresses per (adapter/config/template) |
    # // =============================================================================

    Class NetworkControllerIpList : NetworkControllerObjectList
    {
        NetworkControllerIpList([String]$Type) : base($Type)
        {
            
        }
    }

    # // ===============================================================================
    # // | For collecting total number of network routes per (adapter/config/template) |
    # // ===============================================================================

    Class NetworkControllerRouteList : NetworkControllerObjectList
    {
        NetworkControllerRouteList([String]$Type) : base($Type)
        {
            
        }
    }

    # // =======================================================================================
    # // | For collecting total number of ARP (interfaces/hosts) per (adapter/config/template) |
    # // =======================================================================================

    Class NetworkControllerArpList : NetworkControllerObjectList
    {
        NetworkControllerArpList([String]$Type) : base($Type)
        {
            
        }
    }

    # // =======================================================================================
    # // | For collecting total number of NBT (interfaces/hosts) per (adapter/config/template) |
    # // =======================================================================================

    Class NetworkControllerNbtStatList : NetworkControllerObjectList
    {
        Hidden [Object] $Reference
        NetworkControllerNbtStatList([String]$Type) : base([String]$Type)
        {
            $This.Reference = $This.GetNbtStatReference()
        }
        Refresh()
        {
            $This.Clear()
            $This.Local()
        }
        Local()
        {
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
                        $This.Output[-1].AddNode($Line,$Null)
                    }
                    Registered
                    {
                        $This.Output[-1].AddHost($Line)
                        $This.Output[-1].Output[-1] | % { $_.Service = $This.Service($_) }
                    }
                }
            }
        }
        Remote([Object]$Node)
        {
            $Stack         = nbtstat -A $Node.IpAddress
            ForEach ($Line in $Stack)
            {
                Switch -Regex ($Line)
                {
                    ".+\:$"
                    {
                        $This.Output          += $This.NbtStatInterface("Remote",$Line)
                        $This.Count            = $This.Output.Count
                    }
                    "^Node IpAddress"
                    {
                        $This.Output[-1].AddNode($Line,$Node.IpAddress)
                    }
                    Registered
                    {
                        $This.Output[-1].AddHost($Line)
                        $This.Output[-1].Output[-1] | % { $_.Service = $This.Service($_) }
                    }
                }
            }
        }
        [String] Service([Object]$Item)
        {
            Return $This.Reference | ? ID -eq $Item.ID | ? Type -eq $Item.Type | % Service
        }
        [Object[]] GetNbtStatReference()
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
    }

    # // ======================================================================
    # // | Template object meant to assemble individual controller properties |
    # // ======================================================================

    Class NetworkControllerTemplate
    {
        [UInt32]      $Index
        [String]       $Name
        [String] $MacAddress
        [String]     $Vendor = "-"
        [Object]    $Adapter
        [Object]     $Config
        [Object]  $Interface
        [Object]         $IP
        [Object]      $Route
        [Object]        $Arp
        [Object]        $Nbt
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

            $This.Interface  = $This.NetworkControllerInterfaceList()
            $This.Ip         = $This.NetworkControllerIpList()
            $This.Route      = $This.NetworkControllerRouteList()
            $This.Arp        = $This.NetworkControllerArpList()
            $This.Nbt        = $This.NetworkControllerNbtStatList()
        }
        [Object] NetworkControllerInterfaceList()
        {
            Return [NetworkControllerInterfaceList]::New("Interface")
        }
        [Object] NetworkControllerIpList()
        {
            Return [NetworkControllerIpList]::New("Ip")
        }
        [Object] NetworkControllerRouteList()
        {
            Return [NetworkControllerRouteList]::New("Route")
        }
        [Object] NetworkControllerArpList()
        {
            Return [NetworkControllerArpList]::New("Arp")
        }
        [Object] NetworkControllerNbtStatList()
        {
            Return [NetworkControllerNbtStatList]::New("Nbt")
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
        [UInt32]  $Index
        [String] $Source
        [String]   $Name
        [Object]  $Value
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

    Class NetworkControllerCompartmentV4NbtHost
    {
        [UInt32]        $Index
        [IpAddress] $IpAddress
        [String]         $Name
        [String]           $Id
        [String]         $Type
        [String]      $Service
        NetworkControllerCompartmentV4NbtHost([UInt32]$Index,[Object]$Interface,[Object]$Node)
        {
            $This.Index     = $Index
            $This.IpAddress = $Interface.Node
            $This.Name      = $Node.Name
            $This.Id        = $Node.Id
            $This.Type      = $Node.Type
            $This.Service   = $Node.Service
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerCompartmentV4NbtHost>"
        }    
    }

    # // =============================================================
    # // | Meant to contain extensions for individual V4 Compartment |
    # // =============================================================

    Class NetworkControllerCompartmentV4Extension
    {
        [Object] $Arp
        [Object] $Nbt
        [Object] $Ping
        [Object] $Host
        NetworkControllerCompartmentV4Extension()
        {
            $This.Arp  = @( )
            $This.Nbt  = @( )
            $This.Ping = @( )
            $This.Host = @( )
        }
        AddV4NbtHost([Object]$If,[Object]$Node)
        {
            $This.Host += $This.NetworkControllerCompartmentV4NbtHost($This.Host.Count,
                                                                      $If,
                                                                      $Node)
        }
        [Object] NetworkControllerCompartmentV4NbtHost([UInt32]$Index,[Object]$If,[Object]$Node)
        {
            Return [NetworkControllerCompartmentV4NbtHost]::New($Index,$If,$Node)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerV4Extension>"
        }
    }

    # // =============================================================
    # // | Meant to contain extensions for individual V6 Compartment |
    # // =============================================================

    Class NetworkControllerCompartmentV6Extension
    {
        [Object] $Ping
        [Object] $Host
        NetworkControllerCompartmentV6Extension()
        {
            $This.Ping = @( )
            $This.Host = @( )
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerV6Extension>"
        }
    }

    Class NetworkControllerCompartmentControl
    {
        [UInt32]     $Index
        [Object]   $Adapter
        [Object]    $Config
        [Object] $Interface
        [Object]        $Ip
        [UInt32]      $Type
        NetworkControllerCompartmentControl([UInt32]$Index,[Object]$Tmp,[UInt32]$Type,[Object]$If,[Object]$Ip)
        {
            $This.Index     = $Index
            $This.Adapter   = $Tmp.Adapter
            $This.Config    = $Tmp.Config
            $This.Type      = $Type
            $This.Interface = $If
            $This.Ip        = $Ip
        }
        [String] ToString()
        {
            Return "<FENetworkControllerCompartmentControl>"
        }
    }

    # // ===========================================================================================
    # // | Provides control for each individual interface + IP + AddressFamily + Route + Arp + Nbt |
    # // ===========================================================================================

    Class NetworkControllerCompartment
    {
        [UInt32]          $Index
        Hidden [UInt32]    $Type
        Hidden [Object] $Control
        [UInt32] $InterfaceIndex
        [String] $InterfaceAlias
        [UInt32]  $AddressFamily
        [UInt32]           $Dhcp
        [UInt32]      $Connected
        [String]      $IpAddress
        [UInt32]         $Prefix
        [Object]        $Network
        [Object]          $Route
        [Object]      $Extension
        [Object]       $Property
        NetworkControllerCompartment([Object]$Control)
        {
            $This.Index          = $Control.Index
            $This.Control        = $Control
            $This.Type           = $Control.Type
            $This.InterfaceIndex = $Control.Interface.Index
            $This.InterfaceAlias = $Control.Interface.Alias
            $This.AddressFamily  = $Control.Interface.Type
            $This.Dhcp           = $Control.Interface.Dhcp
            $This.Connected      = $Control.Interface.Open
            $This.IPAddress      = $Control.IP.IPAddress
            $This.Prefix         = $Control.IP.Prefix
            $This.Extension      = Switch ($This.Type)
            {
                4 { $This.NetworkControllerCompartmentV4Extension() }
                6 { $This.NetworkControllerCompartmentV6Extension() }
            }
            
            $This.Property       = @( )

            ForEach ($Item in "Adapter","Config","Interface","IP")
            {
                ForEach ($Property in $Control.$Item.Property | ? Name -notmatch Cim)
                {
                    $This.AddCompartmentProperty($Item,$Property)
                }
            }
        }
        [Object] NetworkControllerCompartmentControl([Object]$Interface,[Object]$Ip)
        {
            Return [NetworkControllerCompartmentControl]::New($Interface,$Ip)
        }
        [Object] NetworkControllerCompartmentV4Extension()
        {
            Return [NetworkControllerCompartmentV4Extension]::New()
        }
        [Object] NetworkControllerCompartmentV6Extension()
        {
            Return [NetworkControllerCompartmentV6Extension]::New()
        }
        AddCompartmentProperty([String]$Source,[Object]$Property)
        {
            $This.Property += [NetworkControllerCompartmentProperty]::New($This.Property.Count,
                                                                          $Source,
                                                                          $Property)
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerCompartment>"
        }
    }

    # // ============================================================================
    # // | This is a list object for each individual network controller compartment |
    # // ============================================================================

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

    # // ==============================================================================
    # // | Controls the information for relaying adapter information to string output |
    # // ==============================================================================

    Class NetworkControllerOutputProperty
    {
        [UInt32] $Index
        [String] $Name
        [String] $Line
        [String[]] $Property
        NetworkControllerOutputProperty([UInt32]$Index,[String]$Name,[String]$Line,[String[]]$Property)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Line     = $Line
            $This.Property = $Property
        }
    }

    # // ==================================================================================
    # // | Controls the list of information to be printed to the console as string output |
    # // ==================================================================================

    Class NetworkControllerOutputList
    {
        [Object] $Output
        NetworkControllerOutputList()
        {
            $This.Output = @( )

            $This.Add("IPv4 Network Information",
            "====[ IPv4 Network Information ]==========================",
            @("IpAddress","Prefix","Class","Netmask","Network","Gateway","Range","Broadcast"))

            $This.Add("IPv4 Network Route(s)",
            "====[ IPv4 Network Route(s) Table ]=======================",
            @("Type","DestinationPrefix","NextHop","RouteMetric","State"))

            $This.Add("IPv4 (ARP/Address Resolution Protocol)",
            "====[ IPv4 (ARP/Address Resolution Protocol) Table ]======",
            @("IpAddress","Physical","Type"))
            
            $This.Add("IPv4 (NBT/NetBEUI) Node(s)",
            "====[ IPv4 (NBT/NetBEUI) Node(s) Table ]==================",
            @("Type","Name","IpAddress","Node","Count"))

            $This.Add("IPv4 Ping Host(s)",
            "====[ IPv4 Ping Host Map Table ]==========================",
            @("IpAddress","Hostname"))

            $This.Add("IPv4 (Ping + NBT/NetBEUI) Host(s) Map",
            "====[ IPv4 (Ping + NBT/NetBEUI) Host(s) Map Table ]=======",
            @("Index","IpAddress","Name","Id","Type","Service"))

            $This.Add("IPv6 Network Information",
            "====[ IPv6 Network Information ]==========================",
            @("IpAddress","Prefix","Type"))

            $This.Add("IPv6 Network Route(s)",
            "====[ IPv6 Network Route(s) Table ]=======================",
            @("Type","DestinationPrefix","NextHop","RouteMetric","State"))

            $This.Add("Network Statistics (UDP/TCP)",
            "====[ Network Statistics (UDP/TCP) ]======================",
            @("Protocol","LocalAddress","LocalPort","RemoteAddress","RemotePort","State","Direction"))
        }
        [Object] NetworkControllerOutputProperty([String]$Name,[String]$Line,[String[]]$Property)
        {
            Return [NetworkControllerOutputProperty]::New($This.Output.Count,
                                                          $Name,
                                                          $Line,
                                                          $Property)
        }
        Add([String]$Name,[String]$Line,[String[]]$Property)
        {
            $This.Output += $This.NetworkControllerOutputProperty($Name,$Line,$Property)
        }
    }

    # // ================================================================
    # // | Network controller master allows refreshing individual items |
    # // | from all of the previous classes, and provides extensions    |
    # // ================================================================

    Class NetworkControllerMaster
    {
        [Object]        $Mode
        [Object]       $Class
        [Object]      $Vendor
        [Object]         $Arp
        [Object]         $Nbt
        [Object]     $NetStat
        [Object]     $Adapter
        [Object]      $Config
        [Object]       $Route
        [Object]   $Interface
        [Object]          $Ip
        [Object] $Compartment
        Hidden [Object] $Form
        NetworkControllerMaster([UInt32]$Mode)
        {
            $This.Mode        = $This.ModeList()
            $This.Mode.Select($Mode)

            $This.Class       = $This.V4ClassList()

            If ($This.Mode.Selected.Index -in 4..7)
            {
                $This.Vendor  = $This.VendorList()
            }

            If ($This.Mode.Selected.Index -in 2,3,6,7)
            {
                $This.Arp     = $This.ArpList()
                $This.Nbt     = $this.NbtStatList()
            }

            If ($This.Mode.Selected.Index -in 1,3,5,7)
            {
                $This.NetStat = $This.NetStatList()
            }

            $This.Adapter     = $This.NetworkAdapterList()
            $This.Config      = $This.NetworkAdapterConfigList()
            $This.Route       = $This.NetworkRouteList()
            $This.Interface   = $This.NetworkInterfaceList()
            $This.Ip          = $This.NetworkIpList()
            $This.Compartment = $This.NetworkControllerCompartmentList()
            $This.Form        = $This.NetworkControllerOutputList().Output
        }
        [Object] Time()
        {
            Return [Time]::New()
        }
        [Object] V4PingOptions()
        {
            Return [System.Net.NetworkInformation.PingOptions]::New()
        }
        [Object] V4PingBuffer()
        {
            Return 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
        }
        [Object] ModeList()
        {
            Return [ModeList]::New()
        }
        [Object] V4ClassList()
        {
            Return [V4ClassList]::New()
        }
        [Object] VendorList()
        {
            Return [VendorList]::New()
        }
        [Object] ArpList()
        {
            Return [ArpList]::New()
        }
        [Object] NbtStatList()
        {
            Return [NbtStatList]::New()
        }
        [Object] NetStatList()
        {
            Return [NetStatList]::New()
        }
        [Object] NetworkAdapterList()
        {
            Return [NetworkAdapterList]::New()
        }
        [Object] NetworkAdapterConfigList()
        {
            Return [NetworkAdapterConfigList]::New()
        }
        [Object] NetworkRouteList()
        {
            Return [NetworkRouteList]::New()
        }
        [Object] NetworkInterfaceList()
        {
            Return [NetworkInterfaceList]::New()
        }
        [Object] NetworkIpList()
        {
            Return [NetworkIpList]::New()
        }
        [Object] NetworkControllerCompartmentList()
        {
            Return [NetworkControllerCompartmentList]::New()
        }
        [Object] NetworkControllerTemplateList()
        {
            Return [NetworkControllerTemplateList]::New()
        }
        [Object] NetworkControllerTemplate([UInt32]$Index,[UInt32]$Rank)
        {
            Return [NetworkControllerTemplate]::New($Index,
                                                    $This.Adapter.Output[$Rank],
                                                    $This.Config.Output[$Rank])
        }
        [Object] NetworkControllerCompartmentControl([Object]$Object,[UInt32]$Type,[Object]$Tmp,[Object]$Ip)
        {
            Return [NetworkControllerCompartmentControl]::New($This.Compartment.Count,$Object,$Type,$Tmp,$Ip)
        }
        [Object] NetworkControllerCompartment([Object]$Control)
        {
            Return [NetworkControllerCompartment]::New($Control)
        }
        [Object] NetworkControllerOutputList()
        {
            Return [NetworkControllerOutputList]::New()
        }
        [Object] V4Network([Object]$If)
        {
            $Item         = [V4Network]::New($If)

            $Item.Class   = $This.Class.Get($Item.IPAddress)

            $Str          = (0..31 | % { [Int32]($_ -lt $Item.Prefix); If ($_ -in 7,15,23) {"."} }) -join ''
            $Item.Netmask = ($Str.Split(".") | % { [Convert]::ToInt32($_,2 ) }) -join "."

            If (!!$Item.Network)
            {
                $This.V4HostRange($Item)
                $This.V4Broadcast($Item)
            }

            Return $Item
        }
        [Void] V4HostRange([Object]$Item)
        {
            $Item.Range = @( Switch ($Item.Network)
            {
                "-"
                {
                    "N/A"
                }
                Default
                {
                    $X  = [UInt32[]]$Item.Network.Split("/")[0].Split(".")
                    $Y  = [UInt32[]]$Item.Netmask.Split(".") | % { (256 - $_) - 1 }
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
        [Object] V4Ping([String]$Ip)
        {
            $Item = [System.Net.NetworkInformation.Ping]::New()
            Return $Item.SendPingAsync($Ip,100,$This.V4PingBuffer(),$This.V4PingOptions())
        }
        [Object] V4PingResponse([UInt32]$Index,[Object]$Ip,[Object]$Ping)
        {
            Return [V4PingResponse]::New($Index,$Ip,$Ping)
        }
        V4PingSweep([UInt32]$Index)
        {
            $Item = $This.Get($Index)

            If (!$Item)
            {
                Throw "Not a valid compartment index"
            }

            ElseIf ($Item.Type -ne 4)
            {
                Throw "Not a valid IPv4 compartment"
            }

            # Scratch variables/hashtables
            $Time                = $This.Time()
            $Item.Extension.Ping = @( )
            $X                   = @{ }
            $H                   = @{ }
            $P                   = @{ }
            $R                   = @{ }
            $Output              = @( )
    
            # Expand notation
            ForEach ($Object in $Item.Network.Range -Split "\/")
            {
                $X.Add($X.Count,($Object | Invoke-Expression))
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

            # Process based on the host count
            Switch ($H.Count)
            {
                0
                {
                    Throw "No addresses detected"
                }
                1
                {
                    # Send ping async
                    Write-Host "[$Time] Scanning [~] (1) Host" 
                    $P.Add(0,$This.V4Ping($H[0]))
        
                    # Await response
                    Write-Host "[$Time] Sent [~] Awaiting Response"
                    $R.Add(0,$This.V4PingResponse(0,$H[0],$P[0]))
        
                    # Prepare output
                    $Output = $R[0] | ? Status
                }
                Default
                {
                    # Send ping async
                    Write-Host ("[$Time] Scanning [~] ({0}) Hosts" -f $H.Count)
                    ForEach ($I in 0..($H.Count-1))
                    { 
                        $P.Add($P.Count,$This.V4Ping($H[$I]))
                    }
        
                    # Await response
                    Write-Host "[$Time] Sent [~] Awaiting Response"
                    ForEach ($I in 0..($P.Count-1)) 
                    {
                        $R.Add($I,$This.V4PingResponse($I,$H[$I],$P[$I]))
                    }
        
                    # Prepare output
                    $Output = $R[0..($R.Count-1)] | ? Status
                }
            }

            # Show process
            Write-Host "[$Time] Scanned [+] ($($Output.Count)) Host(s) reponded"
    
            # Regardless of output count
            Write-Host "[$Time] Resolving [~] Hostnames"
            ForEach ($Object in $Output)
            {
                $Object.GetHostname()
            }
    
            Write-Host "[$Time] Resolved [+] Hostnames"
    
            # Assign the output to the IPV4 network extension property "Ping"
            $Item.Extension.Ping = $Output
        }
        NbtScan([UInt32]$Index)
        {
            $Item = $This.Get($Index)

            If (!$Item)
            {
                Throw "Not a valid compartment index"
            }

            ElseIf ($Item.Type -ne 4)
            {
                Throw "Not a valid IPv4 compartment"
            }

            # Perform ping sweep on the correct adapter
            $This.V4PingSweep($Index)

            # (Clear/reset) the Nbt table
            $Item.Extension.Nbt.Refresh()
            ForEach ($Node in $Item.Extension.Ping | ? IpAddress -notmatch $Item.IpAddress)
            {
                $Item.Extension.Nbt.Remote($Node)
            }
            
            # Clear host array, then build based on all nodes
            $Item.Extension.Host = @( )
            ForEach ($Node in $Item.Extension.Nbt.Output)
            {
                ForEach ($Slot in $Node.Output)
                {
                    $Item.Extension.AddV4NbtHost($Node,$Slot)
                }
            }

            # Sort by IpAddress
            $Item.Extension.Host = $Item.Extension.Host | Sort-Object IpAddress

            # Rerank index
            For ($X = 0; $X -lt $Item.Extension.Host.Count; $X ++)
            {
                $Item.Extension.Host[$X].Index = $X
            }
        }
        [Object[]] RefreshTemplate()
        {
            # // =============================
            # // | Prepare the template list |
            # // =============================

            $Template = $This.NetworkControllerTemplatelist()
            $Template.Clear()

            If ($This.Mode.Selected.Index -in 2,3,6,7)
            {
                $This.Arp.Refresh()
                $This.Nbt.Refresh()
                ForEach ($Item in $This.Nbt.Output)
                {
                    $Item.Index = $This.Arp.Output | ? IPAddress -eq $Item.IPAddress | % Index
                }
            }

            If ($This.Mode.Selected.Index -in 1,3,5,7)
            {
                $This.NetStat.Refresh()
            }

            # // ============================================================================
            # // | Refresh all individual subcomponents (Adapter/Config/Route/Interface/Ip) |
            # // ============================================================================

            $This.Adapter.Refresh()
            $This.Config.Refresh()
            $This.Route.Refresh()
            $This.Interface.Refresh()
            $This.Ip.Refresh()

            # // ==================================================================
            # // | Filter everything into its' corresponding compartment template |
            # // ==================================================================

            $C = $This.Adapter.Output.Count
            $D = ([String]$C).Length
            $T = $C - 1

            If ($C -lt 2)
            {
                Throw "Add something to manage a 0-1 adapter(s)"
            }

            $Splat              = @{ 

                Activity        = "Refreshing [~] Template(s)"
                Status          = "({0:d$D}/{1})" -f 0, $T
                PercentComplete = 0
            }

            Write-Progress @Splat

            ForEach ($X in 0..($This.Adapter.Output.Count-1))
            {
                $Index        = $This.Config.Output[$X].Property | ? Name -eq InterfaceIndex | % Value
                $Id           = $This.NetworkControllerTemplate($Index,$X)
        
                If ($This.Mode.Selected.Index -in 4..7)
                {
                    If ($Id.MacAddress -ne "-")
                    {
                        $Id.SetVendor($This.Vendor)
                    }
                }

                If ($This.Mode.Selected.Index -in 1,3,5,7)
                {
                    ForEach ($Item in $This.Arp.Output | ? Index -eq $Index)
                    {
                        $Id.Arp.Add($Item)
                    }

                    ForEach ($Item in $This.Nbt.Output | ? Index -eq $Index)
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

                $Splat              = @{ 

                    Activity        = "Refreshing [~] Template(s)"
                    Status          = "({0:d$D}/{1})" -f $X, $T
                    PercentComplete = ($X*100)/$T
                }
    
                Write-Progress @Splat
            }

            Write-Progress -Activity "Refreshing [~] Template(s)" -Complete

            # // ====================================================================
            # // | Sort each template by the index, then process compartment output |
            # // ====================================================================

            $Template.Output =  $Template.Output | Sort-Object Index

            Return $Template
        }
        Refresh()
        {
            $Template = $This.RefreshTemplate()

            $This.Compartment.Clear()
    
            $C = $Template.Output.Count
            $D = ([String]$C).Length
            $T = $C - 1

            If ($C -lt 2)
            {
                Throw "Add something to manage a 0-1 compartments(s)"
            }

            $Splat              = @{ 

                Activity        = "Refreshing [~] Compartment(s)"
                Status          = "({0:d$D}/{1})" -f 0, $T
                PercentComplete = 0
            }

            Write-Progress @Splat

            ForEach ($X in 0..($Template.Output.Count-1))
            {
                $Object = $Template.Output[$X]
                ForEach ($Type in 4,6)
                {
                    ForEach ($Interface in $Object.Interface.Output | ? Type -eq $Type)
                    {
                        ForEach ($IP in $Object.IP.Output | ? Type -eq $Type)
                        {
                            $Control          = $This.NetworkControllerCompartmentControl($Object,$Type,$Interface,$IP)
                            $Item             = $This.NetworkControllerCompartment($Control)
                            $Item.Route       = $Object.Route.Output | ? Type -eq $Type
                            If ($Type -eq 4)
                            {
                                $Item.Network = $This.V4Network($Item)

                                If ($Object.Arp.Count -gt 0)
                                {
                                    $Item.Extension.Arp = $Object.Arp
                                }

                                If ($Object.Nbt.Count -gt 0)
                                {
                                    $Item.Extension.Nbt = $Object.Nbt
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

                $Splat              = @{ 

                    Activity        = "Refreshing [~] Template(s)"
                    Status          = "({0:d$D}/{1})" -f $X, $T
                    PercentComplete = ($X*100)/$T
                }

                Write-Progress @Splat
            }

            Write-Progress -Activity "Refreshing [~] Compartment(s)" -Complete
        }
        [Object] Section([Object]$Object,[String[]]$Names)
        {
            Return New-FEFormat -Section $Object -Property $Names
        }
        [Object] Table([Object]$Object,[String[]]$Names)
        {
            Return New-FEFormat -Table $Object -Property $Names
        }
        Add([Hashtable]$Hash,[Object]$Object)
        {
            ForEach ($Line in $Object)
            { 
                $Hash.Add($Hash.Count,$Line)
            }
        }
        [String[]] Draw([Hashtable]$Hashtable)
        {
            Return $Hashtable[0..($Hashtable.Count-1)]
        }
        [String[]] List()
        {
            $Out            = @{ }
            $Property       = "Index","InterfaceIndex","InterfaceAlias","AddressFamily","Dhcp","Connected","IpAddress","Prefix"
            $Section        = $This.Section($This.Compartment.Output,$Property)

            Switch ($This.Compartment.Count)
            {
                0
                {
                    Throw "No available compartments"
                }
                1
                {
                    $This.Add($Out,$Section.Draw(0))
                    $This.Add($Out,$This.DrawCompartment($This.Get(0)))
                }
                Default
                {
                    ForEach ($X in 0..($This.Compartment.Output.Count-1))
                    {
                        $This.Add($Out,$Section.Draw($X))
                        $This.Add($Out,$This.DrawCompartment($This.Get($X)))
                    }
                }
            }

            Return $This.Draw($Out)
        }
        [Object] DrawCompartment([Object]$If)
        {
            $X = $This.Form
            Return @( Switch ($If.Type)
            {
                4
                {
                    # 0 / Network (IPv4)
                    $X[0].Line
                    $This.Table($If.Network,$X[0].Property).Draw()

                    # 1 / Route
                    If ($If.Route.Count -gt 0)
                    {
                        $X[1].Line
                        $This.Table($If.Route,$X[1].Property).Draw()
                    }
                    
                    # 2 / Extension.Arp
                    If ($If.Extension.Arp.Count -gt 0)
                    {
                        $X[2].Line
                        $This.Table($If.Extension.Arp.output,$X[2].Property).Draw()
                    }

                    # 3 / Extension.Nbt
                    If ($If.Extension.Nbt.Count -gt 0)
                    {
                        $X[3].Line
                        $This.Table($If.Extension.Nbt.Output,$X[3].Property).Draw()
                    }

                    # 4 / Extension.Ping
                    If ($If.Extension.Ping.Count -gt 0)
                    {
                        $X[4].Line
                        $This.Table($If.Extension.Ping,$X[4].Property).Draw()
                    }

                    # 5 / Extension.Host
                    If ($If.Extension.Host.Count -gt 0)
                    {
                        $X[5].Line
                        $This.Table($If.Extension.Host,$X[5].Property).Draw()
                    }
                }
                6
                {
                    # 6 / Network (IPv6)
                    $X[6].Line
                    $This.Table($If.Network,$X[6].Property).Draw()

                    # 7 / Route
                    If ($If.Route.Count -gt 0)
                    {
                        $X[7].Line
                        $This.Table($If.Route,$X[7].Property).Draw()
                    }
                }
            })
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Compartment.Count)
            {
                Throw "Invalid compartment index"
            }
            
            Return $This.Compartment.Output[$Index]
        }
        [String] ToString()
        {
            Return "<FENetwork.NetworkControllerMaster>"
        }
    }
    
    $Ctrl = [NetworkControllerMaster]::New($Mode)
    $Ctrl.Refresh()
    $Ctrl
}
