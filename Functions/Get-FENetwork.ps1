<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FENetwork.ps1
          Solution: FightingEntropy Module
          Purpose: For collecting network adapters, interfaces, as well as a network service controller
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-07
          Modified: 2021-10-10
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FENetwork
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=1)][Switch]$Adapter,
        [Parameter(ParameterSetName=2)][Switch]$Interface,
        [ValidateSet(4,6)]
        [Parameter(ParameterSetName=2)][UInt32]$Version,
        [Parameter(ParameterSetName=2)][Switch]$Online,
        [Parameter(ParameterSetName=1)]
        [Parameter(ParameterSetName=2)][Switch]$Text)

    # [Adapter Classes]
    Class FENetworkAdapter      # Instantiates a single network adapter object
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [String] $MacAddress
        FENetworkAdapter([Object]$Adapter)
        {
            $This.Index       = $Adapter.InterfaceIndex
            $This.Name        = $Adapter.Name
            $This.Description = $Adapter.InterfaceDescription
            $This.MacAddress  = $Adapter.MacAddress.Replace("-","")
        }
    }

    Class FENetworkAdapters     # Collects aggregate total of network adapter objects
    {
        [Object] $Output
        FENetworkAdapters()
        {
            $This.Output = @( Get-NetAdapter | % { [FENetworkAdapter]$_ })
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Index { 3 } Name { 28 } Description { 40 } MacAddress { 13 }
            }
            If ( $String.Length -gt $Buffer)
            {
                Return $String.Substring(0,($Buffer-3)) + "..."
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @(
            "#   Name                         Description                              MacAddress  "
            "--  ----                         -----------                              ----------  "
            ForEach ($Item in $This.Output)
            {
                $This.Buffer("Index",$Item.Index),
                $This.Buffer("Name",$Item.Name),
                $This.Buffer("Description",$Item.Description),
                $This.Buffer("MacAddress",$Item.MacAddress) -join ' '
            })
        }
    }

    # [Interface Classes]
    Class FENetworkInterface    # Instantiates a single network interface object
    {
        [UInt32] $Index
        [String] $Alias
        [UInt32] $Version
        Hidden [UInt32] $Dhcp
        Hidden [UInt32] $Online
        [Object[]] $IPAddress
        FENetworkInterface([Object]$IF)
        {
            $This.Index       = $IF.InterfaceIndex
            $This.Alias       = $IF.InterfaceAlias
            $This.Version     = @(4,6)[$IF.AddressFamily -eq 23]
            $This.Dhcp        = $IF.Dhcp -eq "Enabled"
            $This.Online      = $IF.ConnectionState -eq "Connected"
            $This.IPAddress   = $IF | Get-NetIPAddress | % { $_.IPAddress -Replace "\%\d+","" }
        }
    }

    Class FENetworkInterfaces   # Collects aggregate total of network interface objects
    {
        [Object] $Output
        FENetworkInterfaces()
        {
            $This.Output = @( Get-NetIPInterface | % { [FENetworkInterface]$_ })
        }
        FENetworkInterfaces([UInt32]$Version)
        {
            $This.Output = @( Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Version -eq $Version)
        }
        FENetworkInterfaces([Bool]$All)
        {
            $This.Output = @(Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Online -eq $All)
        }
        FENetworkInterfaces([UInt32]$Version,[Bool]$All)
        {
            $This.Output = @(Get-NetIPInterface | % { [FENetworkInterface]$_ } | ? Version -eq $Version | ? Online -eq $All)
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Index { 3 } Alias { 28 } V { 1 } Qty { 3 } IPAddress { 47 }
            }
            If ($String.Length -gt $Buffer)
            {
                Return $String.Substring(0,($Buffer-3)) + "..."
            }
            Else
            {
                Return @( $String, (" " * ($Buffer - $String.Length) -join '') -join '')
            }
        }
        [String[]] ToString()
        {
            Return @(
            "#   Alias                        V Qty IPAddress                                      "
            "--  -----                        - --- ---------                                      "
            ForEach ($Item in $This.Output)
            {
                $Qty = $Item.IPAddress.Count
                If ($Item.IPAddress.Count -gt 1)
                {
                    $Item.IPAddress = $Item.IPAddress -join ", "
                }

                $This.Buffer("Index",$Item.Index),
                $This.Buffer("Alias",$Item.Alias),
                $This.Buffer("V",$Item.Version),
                $This.Buffer("Qty",$Qty),
                $This.Buffer("IPAddress",$Item.IPAddress),
                $This.Buffer("IPAddress",$Item.MacAddress) -join ' '
            })
        }
    }

    # [Nbt Classes]
    Class NbtReferenceObject    # Object to populate the NBT Reference Table
    {
        [String]      $ID
        [String]    $Type
        [String] $Service
        NbtReferenceObject([String]$In)
        {
            $This.ID, $This.Type, $This.Service = $In -Split "/"
            $This.ID = "<$($This.ID)>"
        }
        [String] ToString()
        {
            Return $This.ID
        }
    }

    Class NbtReference          # Reference object to map NetBIOS ID's to service names
    {
        [String[]] $String = (("00/{0}/Workstation {4};01/{0}/Messenger {6};01/{1}/Master Browser;03/{0}/Messenger {6};" + 
        "06/{0}/RAS Server {6};1F/{0}/NetDDE {6};20/{0}/File Server {6};21/{0}/RAS Client {6};22/{0}/{2} Interchange(MSMail C" + 
        "onnector);23/{0}/{2} Exchange Store;24/{0}/{2} Directory;30/{0}/{4} Server;31/{0}/{4} Client;43/{0}/{3} Control;44/{" + 
        "0}/SMS Administrators Remote Control Tool {6};45/{0}/{3} Chat;46/{0}/{3} Transfer;4C/{0}/DEC TCPIP SVC on Windows NT" +
        ";42/{0}/mccaffee anti-virus;52/{0}/DEC TCPIP SVC on Windows NT;87/{0}/{2} MTA;6A/{0}/{2} IMC;BE/{0}/{5} Agent;BF/{0}" + 
        "/{5} Application;03/{0}/Messenger {6};00/{1}/{7} Name;1B/{0}/{7} Master Browser;1C/{1}/{7} Controller;1D/{0}/Master " + 
        "Browser;1E/{1}/Browser {6} Elections;2B/{0}/Lotus Notes Server;2F/{1}/Lotus Notes ;33/{1}/Lotus Notes ;20/{1}/DCA Ir" + 
        "maLan Gateway Server;01/{1}/MS NetBIOS Browse Service") -f "UNIQUE","GROUP","Microsoft Exchange","SMS Clients Remote",
        "Modem Sharing","Network Monitor","Service","Domain").Split(";")
        [Object[]] $Output
        NbtReference()
        {
            $This.Output = @( )
            $This.String | % { 

                $This.Output += [NbtReferenceObject]::New($_)
            }
        }
    }

    Class NbtHostObject         # Used to identify NBT network hosts
    {
        Hidden [String[]]  $Line
        [String]           $Name
        [String]             $ID
        [String]           $Type
        [String]        $Service
        NbtHostObject([String]$Line)
        {
            $This.Line    = $Line.Split(" ") | ? Length -gt 0
            $This.Name    = $This.Line[0]
            $This.ID      = $This.Line[1]
            $This.Type    = $This.Line[2]
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NbtTable              # Parses/Formats the NBT table 
    {
        [String]      $Name
        [String] $IpAddress
        [Object]     $Hosts
        NbtTable([String]$Name)
        {
            $This.Name = $Name
            $This.Hosts = @( )
        }
        NodeIp([String]$Node)
        {
            $This.IpAddress = [Regex]::Matches($Node,"(\d+\.){3}(\d+)").Value
        }
        AddHost([String]$Line)
        {
            $This.Hosts += [NbtHostObject]::New($Line)
        }
        [String] ToString()
        {
            Return @( $This.Name.TrimEnd(":"))
        }
    }

    Class NbtStat               # Parses/Formats nbtstat -N
    {
        Hidden [Object] $Alias
        Hidden [Object] $Table
        Hidden [Object] $Section
        [Object] $Output
        NbtStat([Object[]]$Interface)
        {
            $This.Alias   = $Interface.Alias | % { "{0}:" -f $_ }
            $This.Table   = nbtstat -N
            $This.Section = @{ }
            $X            = -1

            ForEach ( $Line in $This.Table )
            {
                If ( $Line -in $This.Alias )
                {
                    $X ++
                    $This.Section.Add($X,[NbtTable]::New($Line))
                }

                ElseIf ( $Line -match "Node IpAddress" )
                {
                    $This.Section[$X].NodeIp($Line)
                }
    
                ElseIf ( $Line -match "Registered" )
                {
                    $This.Section[$X].AddHost($Line)
                }
            }

            $This.Output = $This.Section | % GetEnumerator | Sort-Object Name | % Value
        }
    }

    # [Arp Classes]
    Class ArpHostObject         # Used to identify (IPV4/ARP network) hosts
    {
        Hidden [String]    $Line
        [String]       $Hostname
        [String]      $IpAddress
        [String]     $MacAddress
        [String]         $Vendor
        [String]           $Type
        ArpHostObject([String]$Line)
        {
            $This.Line       = $Line
            $This.IpAddress  = $This.Line.Substring(2,22).Replace(" ","")
            $This.MacAddress = $This.Line.Substring(24,17)
            $This.Type       = $This.Line.Substring(46)
        }
        GetVendor([Object]$Vendor)
        {
            $This.Vendor     = $Vendor.VenID[ ( $This.MacAddress -Replace "(-|:)","" | % Substring 0 6 ) ]
        }
        [String] ToString()
        {
            Return @( $This.Hostname )
        }
    }

    Class ArpTable              # Used to parse each section of an ARP table
    {
        [String]      $Name
        [String] $IpAddress
        [Object]     $Hosts
        ArpTable([String]$Line)
        {
            $This.Name      = $Line.Split(" ")[-1]
            $This.IPAddress = $Line.Replace("Interface: ","").Split(" ")[0]
            $This.Hosts     = @( )
        }
        [String] ToString()
        {
            Return @( $This.IPAddress )
        }
    }

    Class ArpStat               # Parses the full ARP table into sections
    {
        [Object] $Alias
        [Object] $Table
        [Object] $Section
        [Object] $Output
        ArpStat([Object[]]$Interface)
        {
            $This.Alias = ForEach ( $I in $Interface ) 
            {
                "Interface: {0} --- 0x{1:x}" -f $I.IPV4.IPAddress, $I.Index 
            }

            $This.Table   = arp -a
            $This.Section = @{ }
            $X            = -1

            ForEach ( $Line in $This.Table )
            {
                If ( $Line -in $This.Alias )
                {
                    $X ++
                    $This.Section.Add( $X,[ArpTable]::New($Line))
                }

                ElseIf ( $Line -match "(static|dynamic)" )
                {
                    $This.Section[$X].Hosts += [ArpHostObject]::New($Line)
                }
            }

            $This.Output = $This.Section | % GetEnumerator | Sort-Object Name | % Value
        }
    }

    # [NetStat Classes]
    Class NetStatAddress        # Used for associating a netstat object
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
    }

    Class NetStatObject         # Used for each line of a netstat table
    {
        Hidden [String]   $Line
        Hidden [Object]   $Item
        [String]      $Protocol
        [String]  $LocalAddress
        [String]     $LocalPort
        [String] $RemoteAddress
        [String]    $RemotePort
        [String]         $State
        [String]     $Direction
        NetStatObject([String]$Line)
        {
            $This.Line          = $Line
            $This.Item          = $This.Line -Split " " | ? Length -gt 0
            $This.Protocol      = $This.Item[0]
            $This.LocalAddress  = $This.GetAddress($This.Item[1])
            $This.LocalPort     = $This.Item[1].Replace($This.LocalAddress + ":","")
            $This.RemoteAddress = $This.GetAddress($This.Item[2])
            $This.RemotePort    = $This.Item[2].Replace($This.RemoteAddress + ":","")
            $This.State         = $This.Item[3]
            $This.Direction     = $This.Item[4]
        }
        [String] GetAddress([String]$Item)
        {
            Return @( If ( $Item -match "(\[.+\])" )
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
            Return "[{0}/{1}/{2}]" -f $This.Protocol, $This.LocalAddress, $This.LocalPort
        }
    }

    Class NetStat               # Parses an entire netstat table
    {
        [Object] $Alias
        [Object] $Table
        [Object] $Section
        [Object] $Output
        NetStat()
        {
            $This.Alias   = "Active Connections"
            $This.Table   = netstat -ant
            
            $This.Section = @{}
            $X            = -1

            ForEach ( $Line in $This.Table )
            {
                If ( $Line -match "(TCP|UDP)" )
                {
                    $X ++
                    $This.Section.Add($X,[NetStatObject]::New($Line))
                }
            }

            $This.Output  = $This.Section | % GetEnumerator | Sort-Object Name | % Value 
        }
    }

    # [V4 Network Classes]
    Class V4PingObject          # Object returned from a ping (sweep/scan)
    {
        Hidden [Object]   $Reply
        [UInt32]          $Index
        [UInt32]         $Status
        [String]      $IPAddress
        [String]       $Hostname
        V4PingObject([UInt32]$Index,[String]$Address,[Object]$Reply)
        {
            $This.Reply          = $Reply.Result
            $This.Index          = $Index
            $This.Status         = $Reply.Result.Status -match "Success"
            $This.IPAddress      = $Address
            $This.Hostname       = Switch ($This.Status)
            {
                1
                {
                    Try 
                    {
                        [System.Net.Dns]::Resolve($This.IPAddress).HostName
                    }
                    Catch
                    {
                        "<unknown>"
                    }
                }

                Default
                {
                    "-"
                }
            }
        }
        Domain([String]$Domain)
        {
            If ( $This.Hostname -notmatch $Domain )
            {
                $This.Hostname = ("{0}.{1}" -f $This.Hostname, $Domain)
            }
        }
        [String] ToString()
        {
            Return $This.IPAddress
        }
    }

    Class V4PingSweep           # Scans a network range for potential hosts
    {
        Hidden [String]     $Domain
        [String]         $HostRange
        [String[]]       $IPAddress
        Hidden [Hashtable] $Process
        [Object] $Buffer         = @(97..119 + 97..105 | % { "0x{0:X}" -f $_ })
        [Object] $Options
        [Object] $Output
        [Object] $Result
        V4PingSweep([String]$HostRange)
        {
            $This.HostRange = $HostRange
            $This.Process   = @{ }
            $Item           = $This.Hostrange.Split("/")

            ForEach ($0 in $Item[0] | Invoke-Expression)
            {
                ForEach ($1 in $Item[1] | Invoke-Expression)
                {
                    ForEach ($2 in $Item[2] | Invoke-Expression) 
                    {
                        ForEach ($3 in $Item[3] | Invoke-Expression)
                        {
                            $This.Process.Add($This.Process.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }

            $This.IPAddress      = $This.Process | % GetEnumerator | Sort-Object Name | % Value
            $This.Refresh()
        }
        Refresh()
        {
            $This.Process        = @{ }

            ForEach ($X in 0..($This.IPAddress.Count - 1))
            {
                $IP              = $This.IPAddress[$X]

                $This.Options    = [System.Net.NetworkInformation.PingOptions]::new()
                $This.Process.Add($X,[System.Net.NetworkInformation.Ping]::new().SendPingAsync($IP,100,$This.Buffer,$This.Options))
            }

            $This.Output         = @( )
        
            ForEach ($X in 0..($This.IPAddress.Count - 1)) 
            {
                $IP              = $This.IPAddress[$X] 
                $This.Output    += [V4PingObject]::New($X,$IP,$This.Process[$X])
            }
        }
    }

    Class V4Network             # Provisions an entire IPV4 network range, information, etc.
    {
        [String]            $IPAddress
        [String]                $Class
        [Int32]                $Prefix
        [String]              $Netmask
        Hidden [Object]         $Route
        [String]              $Network
        [String]              $Gateway
        [String[]]             $Subnet
        [String]            $Broadcast
        [String]            $HostRange
        V4Network([Object]$Address)
        {
            If (!$Address)
            {
                Throw "Address Empty"
            }

            $This.IPAddress = $Address.IPAddress
            $This.Class     = @('N/A';@('A')*126;'Local';@('B')*64;@('C')*32;@('MC')*16;@('R')*15;'BC')[[Int32]$This.IPAddress.Split(".")[0]]
            $This.Prefix    = $Address.PrefixLength
            $This.Netmask   = $This.GetNetMask($This.Prefix)
            $This.Route     = Get-NetRoute -AddressFamily IPV4 | ? InterfaceIndex -eq $Address.InterfaceIndex
            $This.Network   = $This.Route | ? { ($_.DestinationPrefix -Split "/")[1] -match $This.Prefix } | % { ($_.DestinationPrefix -Split "/")[0] }
            $This.Gateway   = $This.Route | ? NextHop -ne 0.0.0.0 | % NextHop
            $This.Subnet    = $This.Route | ? DestinationPrefix -notin 255.255.255.255/32,224.0.0.0/4,0.0.0.0/0 | % DestinationPrefix | Sort-Object
            $This.Broadcast = ( $This.Subnet | % { ( $_ -Split "/" )[0] } )[-1]
            $This.GetHostRange()
        }
        [String] GetNetmask([Int32]$CIDR)
        {
            $Switch         = 0

            Return @( ForEach ( $I in 0..3 )
            {
                If ( $CIDR -in @{ 0 = 1..7; 1 = 8..15; 2 = 16..23; 3 = 24..30 }[$I] )
                {
                    $Switch = 1
                    @(0,128,192,224,240,248,252,254,255)[$CIDR % 8]
                }

                Else
                {
                    @(255,0)[$Switch]
                }
            }) -join "."
        }
        GetHostRange()
        {
            $Item           = [IPAddress]$This.IPAddress | % GetAddressBytes 
            $Mask           = [IPAddress]$This.Netmask   | % GetAddressBytes 
            $This.HostRange = @( ForEach ( $I in 0..3 )
            {
                $Step = 256 - $Mask[$I]
                
                Switch ( $Step )
                {
                    1 
                    { 
                        $Item[$I] 
                    } 
                    
                    256 
                    { 
                        "0..255" 
                    } 
                    
                    Default 
                    {
                        $Slot = 256 / $Step

                        ForEach ( $X in 0..( ( 256 / $Slot ) - 1 ) )
                        {
                            $IRange = ( $X * $Slot ) | % { $_..( $_ + $Slot - 1 ) }

                            If ( $Item[$I] -in $IRange )
                            {
                                "{0}..{1}" -f $IRange[0,-1]
                            }
                        }
                    }
                }
            }) -join '/'
        }
        [String] ToString()
        {
            Return $This.HostRange
        }
        [Object[]] ScanV4()
        {
            Return @( [V4PingSweep]::New($This.HostRange).Output | ? Status )
        }
    }

    # [V6 Network Class(es)]    # Provisions an entire IPV6 network
    Class V6Network
    {
        [String] $IPAddress
        [Int32]  $Prefix
        [String] $Link
        V6Network([Object]$Address)
        {
            $This.IPAddress = $Address.IPAddress
            $This.Prefix    = $Address.PrefixLength
        }
        [String] ToString()
        {
            Return ("{0}/{1}" -f $This.IPAddress, $This.Prefix)
        }
    }

    # [Controller Classes]
    Class DNSSuffix             # Obtains (Hostname/DNS/Domain) information
    {
        [String] $Path         = "HKLM:\System\CurrentControlSet\Services\TCPIP\Parameters"
        [UInt32] $IsDomain     = ([WMIClass]"\\.\ROOT\CIMV2:Win32_ComputerSystem" | % GetInstances | % PartOfDomain)
        [String] $ComputerName
        [String] $Domain
        [String] $NVDomain
        [UInt32] $Sync
        DNSSuffix()
        {
            Get-ItemProperty $This.Path | % { 

                $This.ComputerName = $_.HostName
                $This.Domain       = $_.Domain
                $This.NVDomain     = $_.'NV Domain'
                $This.Sync         = $_.SyncDomainWithMembership
            }
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
            If ( !$This.IsDomain )
            {
                "Domain","NV Domain" | % { Set-ItemProperty -Path $This.Path -Name $_ -Value $This.Domain -Verbose }
            }

            Else
            {
                [System.Windows.MessageBox]::Show("System is part of a domain","Exception")
            }
        }
        [String] ToString()
        {
            Return $This.Domain
        }
    }

    Class VendorList            # Obtains hardware vendor list to convert MacAddress to correct vendor name
    {
        Hidden [Object]    $File
        [String[]]          $Hex
        [String[]]        $Names
        [String[]]         $Tags
        [Hashtable]          $ID
        [Hashtable]       $VenID
        VendorList()
        {
            $This.File           = Get-FEModule -Control | ? Name -match vendorlist.txt | % { Get-Content $_.FullName }
            $This.Hex            = $This.File -Replace "(\t){1}.*","" -Split "`n"
            $This.Names          = $This.File -Replace "([A-F0-9]){6}\t","" -Split "`n"
            $This.Tags           = $This.Names | Sort-Object
            $This.ID             = @{ }

            ForEach ( $I in 0..( $This.Tags.Count - 1 ) )
            {
                If ( ! $This.ID[$This.Tags[$I]] )
                {
                    $This.ID.Add($This.Tags[$I],$I)
                }
            }

            $This.VenID          = @{ }
            ForEach ( $I in 0..( $This.Hex.Count - 1 ) )
            {
                $This.VenID.Add($This.Hex[$I],$This.Names[$I])
            }
        }
    }

    Class NetworkHost           # Collects everything needed for a host object
    {
        Hidden [Object] $PingObject
        Hidden [Object]        $NBT
        [String]         $IPAddress
        [String]          $Hostname
        [String]           $NetBIOS
        NetworkHost([Object]$PingObject)
        {
            $This.PingObject  = $PingObject
            $This.IPAddress   = $PingObject.IPAddress
            $This.HostName    = $PingObject.Hostname

            Write-Host ( "[~] {0}" -f $PingObject.Hostname )

            $Item             = nbtstat -A $PingObject.IPAddress

            If ( $Item -notmatch "Host not found" )
            {   
                $This.NBT     = $Item.Split("`n") | ? { $_ -match "Registered" } | % { [NbtHostObject]::New($_) }
            }
        }
        Domain([String]$Domain)
        {
            If ( $This.Hostname -notmatch $Domain )
            {
                $This.Hostname = ("{0}.{1}" -f $This.Hostname,$Domain )
            }
        }
    }

    Class FENetworkControllerInterface
    {
        Hidden [Object] $Interface
        [String] $Hostname
        [String] $Alias
        [Int32]  $Index
        [String] $Description
        [String] $Status
        [String] $MacAddress
        [String] $Vendor
        [Object] $IPv4
        [Object] $IPv6
        [Object] $Nbt
        [Object] $Arp
        FENetworkControllerInterface([Object]$Interface)
        {
            $This.Interface   = $Interface
            $This.HostName    = Resolve-DnsName $Interface.ComputerName | % Name | ? Length -gt 0 | Select-Object -Unique
            $This.Alias       = $Interface.InterfaceAlias
            $This.Index       = $Interface.InterfaceIndex
            $This.Description = $Interface.InterfaceDescription
            $This.Status      = $Interface.NetAdapter.Status
            $This.MacAddress  = $Interface.NetAdapter.LinkLayerAddress
            
            $This.IPV4        = @( )

            ForEach ( $Address in $Interface.IPV4Address ) 
            { 
                $This.IPV4   += [V4Network]::New($Address)
            }

            $This.IPV4        = $This.IPV4 | Select-Object -Unique
            
            $This.IPV6        = @( )

            ForEach ( $Address in $Interface.IPV6Address)
            {
                $This.IPV6   += [V6Network]::New($Address)
            }

            ForEach ( $Address in $Interface.IPV6LinkLocalAddress )
            {
                $This.IPV6   += [V6Network]::New($Address)
            }

            ForEach ( $Address in $Interface.IPV6TemporaryAddress )
            {
                $This.IPV6   += [V6Network]::New($Address)
            }

            $This.IPV6        = $This.IPV6 | Select-Object -Unique
        }
        GetVendor([Object]$Vendor)
        {
            $This.Vendor = $Vendor.VenID[ ( $This.MacAddress -Replace "(-|:)","" | % Substring 0 6 ) ]
        }
        Load([Object]$Nbt,[Object]$Arp)
        {
            $This.Nbt = $Nbt
            $This.Arp = $Arp
        }
        [String] ToString()
        {
            Return $This.Alias
        }
    }

    Class FENetworkController
    {
        [Object]            $Suffix
        Hidden [Object] $VendorList
        Hidden [Object] $NbtReference
        [Object]             $Nbt
        [Object]             $Arp
        [Object]       $Interface
        [Object]          $Active
        [Object]         $HostMap
        [Object]         $NbtScan
        FENetworkController()
        {
            Write-Host "Collecting [~] FightingEntropy Network Controller"

            $This.Suffix           = [DnsSuffix]::New()
            $This.VendorList       = [VendorList]::New()
            $This.NBTReference     = [NBTReference]::New().Output
            $This.Interface        = @( )
            
            ForEach ($Inter in Get-NetIPConfiguration)
            {
                $Int = [FENetworkControllerInterface]::New($Inter)
                Write-Host ( "[+] {0}" -f $Int.Alias )
                $Int.GetVendor($This.VendorList)
                $This.Interface   += $Int
            }
            
            Write-Host "Collecting [~] NbtStat Table"
            $This.NBT              = [NbtStat]::New($This.Interface).Output

            Write-Host "Collecting [~] Arp Table"
            $This.ARP              = [ArpStat]::New($This.Interface).Output

            Write-Host "Collecting [~] NbtStat Host Objects"
            ForEach ($Interface in $This.NBT)
            {
                ForEach ($xHost in $Interface.Hosts)
                {
                    $xHost.Service = $This.NBTReference | ? ID -match $xHost.ID | ? Type -eq $xHost.Type | % Service
                }
            }

            Write-Host "Collecting [~] Interface Host Objects"
            ForEach ($I in 0..( $This.Interface.Count - 1 ))
            {
                $IPAddress         = $This.Interface[$I].IPV4.IPAddress

                $xNbt              = $This.Nbt | ? IpAddress -match $IpAddress | % Hosts
                $xArp              = $This.Arp | ? IpAddress -match $IpAddress | % Hosts

                ForEach ($Item in $xArp)
                {
                    If ($Item.Type -match "static")
                    {
                        $Item.Hostname = "-"
                        $Item.Vendor   = "-"
                    }

                    If ($Item.Type -match "dynamic")
                    {
                        $Item.GetVendor($This.VendorList)

                        If (!$Item.Vendor)
                        {
                            $Item.Vendor = "<unknown>"
                        }
                    }
                }

                $This.Interface[$I].Load($xNbt,$xArp)
            }

            Write-Host "Collecting [~] Active Interfaces"
            $This.Active = $This.Interface | ? { $_.IPV4.Gateway }

            Write-Host "Running [~] Ping Sweep"
            $This.RefreshIPv4Scan()
        }
        [Object[]] NetStat()
        {
            Return @( [NetStat]::New().Output )
        }
        RefreshIPv4Scan()
        {
            If (!$This.Active)
            {
                Throw "No active network(s) found"
            }

            Else
            {                
                $This.Hostmap = @( )
                ForEach ( $Item in $This.Active.IPv4.ScanV4() )
                {
                    $This.Active.Arp | ? IpAddress -match $Item.IpAddress | % { $_.HostName = $Item.Hostname }
                    
                    If ( $Item.IPAddress -notin $This.Hostmap.IPAddress )
                    {
                        $This.Hostmap += $Item
                    }
                }
            }
        }
        NetBIOSScan()
        {
            If (!$This.Hostmap)
            {
                Throw "No hosts detected"
            }

            $This.NBTScan            = @( )

            ForEach ($XHost in $This.HostMap)
            { 
                $Item                = [NetworkHost]::New($XHost)
                
                If ( $Item.NBT.Count -gt 0 )
                {
                    ForEach ( $Obj in $Item.NBT )
                    {
                        $Obj.Service = $This.NbtReference | ? ID -match $Obj.ID | ? Type -match $Obj.Type | % Service

                        If ( $Obj.Service -eq "Domain Name" )
                        {
                            $Item.NetBIOS = $Obj.Name
                        }
                    }
                }

                If ( $Item.Hostname -notmatch $This.Suffix.Domain )
                {
                    $Item.Hostname = ("{0}.{1}" -f $Item.Hostname, $This.Suffix.Domain)
                }

                $This.NBTScan       += $Item
            }
        }
    }

    # End of Class Declarations
    Switch($PSCmdLet.ParameterSetName)
    {
        0 
        { 
            $Object = [FENetworkController]::New() 
            $Object
        } 
        1 
        { 
            $Object = [FeNetworkAdapters]::New()
            If (!$Text)
            {
                $Object.Output
            }
            If ($Text)
            {
                $Object.ToString()
            }
        }
        2
        {
            If (!$Version -and !$Online)
            {
                $Object = [FENetworkInterfaces]::New()
            }
            If ($Version -and !$Online)
            {
                $Object = [FeNetworkInterfaces]::New($Version)
            }
            If ($Online -and !$Version)
            {
                $Object = [FeNetworkInterfaces]::New($Online)
            }
            If ($Online -and $Version)
            {
                $Object = [FENetworkInterfaces]::New($Version,$Online)
            }
            If ($Text)
            {
                $Object.ToString()
            }
            If (!$Text)
            {
                $Object.Output
            }
        }
    }
}
