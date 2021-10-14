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
          Modified: 2021-10-13
          
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

    # [ArpClasses]
    Class ArpEntry                  # Collects/formats the information for an ARP entry
    {
        [IPAddress]   $Address
        [String]     $Physical
        [String]         $Type
        ArpEntry([String]$Line)
        {
            $This.Address  = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Physical = [Regex]::Matches($Line,"([0-9a-f]{2}\-){5}[0-9a-f]{2}").Value
            $This.Type     = $Line.Substring(46).TrimEnd(" ")
            $This.GetAssociation()
        }
        GetAssociation()
        {
            $Split = $This.Address.ToString().Split(".")
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
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Address  { 15 }
                Physical { 17 }
                Type     { 10 }
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
        [String] ToString()
        {
            Return @(
                $This.Buffer( "Address",$This.Address),
                $This.Buffer("Physical",$This.Physical),
                $This.Buffer(    "Type",$This.Type) -join ' '
            )
        }
    }

    Class ArpAdapter                # Collects/formats information for an adapter in the ARP table 
    {
        [UInt32]      $Index
        [String]       $Slot
        [IPAddress] $Address
        [UInt32]    $Adapter
        [Object[]]    $Entry
        ArpAdapter([UInt32]$Index,[String]$Line)
        {
            $This.Index     = $Index
            $This.Address   = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Slot      = @("Public","Private")[$This.Address -match 169.254]
            $This.Adapter   = [Regex]::Matches($line,"(0x\d+)").Value
            $This.Entry     = @( )
        }
        AddEntry([String]$Line)
        {
            $This.Entry    += [ArpEntry]::New($Line)
        }
        [String] Buffer([String]$Type,[String]$String)
        {
            $Buffer = Switch ($Type)
            {
                Index   {  5 }
                Address { 15 }
                Adapter {  7 }
                Slot    {  7 }
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
                "Index Address         Adapter Type"
                "----- -------         ------- ----"
                $This.Buffer(  "Index",$This.Index),
                $This.Buffer("Address",$This.Address),
                $This.Buffer("Adapter",$This.Adapter),
                $This.Buffer(   "Type",$This.Slot) -join ' '
                "Address         Physical          Type"
                "-------         --------          ----"
                ForEach ($Entry in $This.Entry)
                {
                    $Entry.ToString()
                }
                " "
            )
        }
    }

    Class ArpTable                  # Collects/Formats the entire ARP table
    {
        [Object]     $Query
        [Object[]] $Section
        ArpTable()
        {
            $This.Query   = arp -a
            $This.Section = @( )
            ForEach ($X in 0..($This.Query.Count-1))
            {
                $Line = $This.Query[$X]
                Switch -Regex ($Line)
                {
                    "^Interface"
                    {
                        $This.Section += [ArpAdapter]::New($This.Section.Count,$Line)
                    }
                    "^\s{2}\d"
                    {
                        $This.Section[$This.Section.Count-1].AddEntry($Line)
                    }
                }
            }
        }
        [String[]] ToString()
        {
            Return @( 

                ForEach ($Section in $This.Section)
                {
                    $Section.ToString()
                }
            )
        }
    }

    # [Nbt Classes]
    Class NbtReferenceObject        # Object to populate the NBT Reference Table
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

    Class NbtReference              # Reference object to map NetBIOS ID's to service names
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

    Class NbtEntry                  # Used to identify NBT network hosts and any NetBIOS services it may be running
    {
        [String] $Name
        [String] $ID
        [String] $Type
        [String] $Service
        NbtEntry([String]$Line)
        {
            $This.Name    = $Line.Substring(0,19).Replace(" ","")
            $This.ID      = $Line.Substring(19,4)
            $This.Type    = $Line.Substring(23,8).Replace(" ","")
        }
        GetService([Object]$NbtReference)
        {
            $This.Service = $NbtReference | ? ID -eq $This.ID | ? Type -eq $This.Type | % Service
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NbtSection                # Collects/formats a remote or local Nbtstat table
    {
        [String]      $Alias
        [String]       $Slot
        [IPAddress] $Address
        [Object[]]    $Entry
        NbtSection([String]$Slot,[String]$Line)
        {
            $This.Alias = $Line.TrimEnd(":")
            $This.Slot  = $Slot
        }
        AddAddress([String]$Line)
        {
            $This.Address = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
        }
        AddEntry([String]$Line)
        {
            $This.Entry += [NbtEntry]::New($Line)
        }
        [String] ToString()
        {
            Return ("{0}/{1}/{2}" -f $This.Slot, $This.Alias, $This.Address)
        }
    }

    Class NbtNode                   # Collects node entries and converts to a table entry
    {
        [String] $Alias
        [String] $Slot
        [IPAddress] $Address
        [String] $Name
        [String] $ID
        [String] $Type
        [String] $Service
        NbtNode([Object]$Object,[Object]$Entry)
        {
            $This.Alias       = $Object.Alias
            $This.Slot        = $Object.Slot
            $This.Address     = $Object.Address
            $This.Name        = $Entry.Name
            $This.ID          = $Entry.ID
            $This.Type        = $Entry.Type
            $This.Service     = $Entry.Service
            If (!$Entry)
            {
                $This.Name    = "-"
                $This.ID      = "-"
                $This.Type    = "-"
                $This.Service = "-"
            }
        }
    }

    Class NbtDc                     # Retrieves Domain Controllers from Arp stack
    {
        [IPAddress] $IPAddress
        [String] $Hostname
        [String] $NetBIOS
        NbtDc([Object]$Object)
        {
            $This.IPAddress  = $Object.Address
            $This.Hostname   = [System.Net.Dns]::Resolve($Object.Address).Hostname
            $This.NetBIOS    = $Object.Name
        }
    }

    Class NbtTable                  # Combines the ARP stack with NBT
    {
        [Object] $Reference = ([NbtReference]::New().Output)
        [Object]       $Arp
        [Object[]]   $Local
        [Object[]]  $Remote
        [Object]      $Swap
        [Object]    $Output
        NbtTable()
        {
            Write-Host "Collecting [~] Arp Table"

            $This.Arp       = [ArpTable]::New()
            $This.Local     = @( )
            $This.Remote    = @( )
            $This.GetLocal()
            ForEach ($Section in $This.Arp.Section)
            {
                Write-Host ("Scanning [~] [Index: {0}] [Slot: {1}] [Address: {2}] [Adapter: {3}]" -f $Section.Index, $Section.Slot, $Section.Address, $Section.Adapter)
                ForEach ($Entry in $Section.Entry | ? Type -eq "Host")
                {
                    Write-Host ("[Entry: {0}]" -f $Entry.Address)
                    $This.GetRemote($Entry.Address)
                }
            }
            ForEach ($Section in $This.Remote | ? {$_.Entry.Count -gt 0 })
            {
                ForEach ($Entry in $Section.Entry)
                {
                    $Entry.GetService($This.Reference)
                }
            }
            $This.GetSwap()
            $This.GetOutput()
        }
        GetLocal()
        {
            $Stack          = nbtstat -N
            ForEach ($X in 0..($Stack.Count-1))
            {
                $Line = $Stack[$X]
                Switch -Regex ($Line)
                {
                    "^(\w|\d)+\:$"
                    {
                        $This.Local += [NbtSection]::New("Local",$Line)
                    }
                    "^Node"
                    {
                        $This.Local[$This.Local.Count-1].AddAddress($Line)
                    }
                    "Registered"
                    {
                        $This.Local[$This.Local.Count-1].AddEntry($Line)
                    }
                }
            }
            ForEach ($Entry in $This.Local.Entry)
            {
                $Entry.GetService($This.Reference)
            }
        }
        GetRemote([String]$IPAddress)
        {
            $Stack = nbtstat -A $IPAddress
            ForEach ($X in 0..($Stack.Count-1))
            {
                $Line = $Stack[$X]
                Switch -Regex ($Line)
                {
                    "^(\w|\d)+\:$"
                    {
                        $This.Remote += [NbtSection]::New("Remote",$Line)
                    }
                    "^Node"
                    {
                        $This.Remote[$This.Remote.Count-1].AddAddress($IPAddress)
                    }
                    "Registered"
                    {
                        $This.Remote[$This.Remote.Count-1].AddEntry($Line)
                    }
                }
            }
        }
        GetSwap()
        {
            $This.Swap = @( )
            ForEach ($Item in @($This.Local;$This.Remote) | Sort-Object IPAddress)
            {
                If ($Item.Entry.Count -eq 0)
                {
                    $This.Swap += [NbtNode]::New($Item,$Null)
                }
                If ($Item.Entry.Count -gt 0)
                {
                    ForEach ($Entry in $Item.Entry)
                    {
                        $This.Swap += [NbtNode]::New($Item,$Entry)
                    }
                }
            }
        }
        GetOutput()
        {
            $This.Output = $This.Swap | ? ID -match "1b|1c" | Sort-Object Address | Select-Object Address -Unique | % {[NbtDc]::New($_) }
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
    Class V4PingObject           # Object returned from a ping (sweep/scan)
    {
        [UInt32]          $Index
        Hidden [UInt32]  $Status
        [String]      $IPAddress
        [String]       $Hostname
        V4PingObject([UInt32]$Index,[String]$Address,[Object]$Reply)
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

    Class V4Network             # Provisions an entire IPV4 network range, information, etc.
    {
        Hidden Static [String[]]  $Classes = @('N/A';@('A')*126;'Local';@('B')*64;@('C')*32;@('MC')*16;@('R')*15;'BC')
        Hidden Static [Object]    $Options = [System.Net.NetworkInformation.PingOptions]::new()
        Hidden Static [String[]]   $Buffer  = @( 97..119 + 97..105 | % { "0x{0:X}" -f $_ } )
        [String]            $IPAddress
        [String]                $Class
        [Int32]                $Prefix
        [String]              $Netmask
        Hidden [Object]         $Route
        [String]              $Network
        [String]              $Gateway
        [String]            $Broadcast
        [String]            $HostRange
        Hidden [Object]         $Range
        V4Network([Object]$Address)
        {
            If (!$Address)
            {
                Throw "Address Empty"
            }

            $This.IPAddress = $Address.IPAddress
            $This.Class     = $This.GetClass()
            $This.Prefix    = $Address.PrefixLength
            $This.Netmask   = $This.GetNetMask($This.Prefix)
            $This.Route     = Get-NetRoute -AddressFamily IPV4 | ? InterfaceIndex -eq $Address.InterfaceIndex
            $This.Network   = $This.Route | ? DestinationPrefix -match "/$($This.Prefix)" | % DestinationPrefix
            $This.Gateway   = $This.Route | ? DestinationPrefix -match 0.0.0.0/0 | % NextHop
            $This.HostRange = $This.GetHostRangeString()
            $This.GetHostRange()
        }
        [String] GetClass()
        {
            Return [V4Network]::Classes[$This.IPAddress.Split(".")[0]]
        }
        [String] GetNetmask([Int32]$CIDR)
        {
            Return @( @( 0,8,16,24 | % {[Convert]::ToInt32(("{0}{1}" -f ("1" * $CIDR -join ''),("0" * (32-$CIDR) -join '')).Substring($_,8),2)} ) -join '.' )
        }
        [String] GetHostRangeString()
        {
            $X = [UInt32[]]$This.Network.Split("/")[0].Split(".")
            $Y = [UInt32[]]$This.Netmask.Split(".") | % { (256 - $_) - 1 }
            Return @( ForEach ($I in 0..3)
            {
                Switch($Y[$I])
                {
                    0 { $X[$I] } Default { "{0}..{1}" -f $X[$I],($X[$I]+$Y[$I]) }
                }
            } ) -join '/'
        }
        GetHostRange()
        {
            $I              = $This.HostRange.Split("/")
            $X              = @{ }
            ForEach ( $0 in $I[0] | Invoke-Expression)
            {
                ForEach ( $1 in $I[1] | Invoke-Expression)
                {
                    ForEach ( $2 in $I[2] | Invoke-Expression) 
                    {
                        ForEach ( $3 in $I[3] | Invoke-Expression)
                        {
                            $X.Add($X.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }
            $X               = $X | % GetEnumerator | Sort-Object Name | % Value
            $This.Broadcast  = $X[-1]
            $This.Range      = $X[1..($X.Count-2)] -join "`n"
        }
        [Object] PingSweep()
        {
            $Process  = @{ }
            $Response = @( )
            $Output   = @( )
            $Time     = [System.Diagnostics.Stopwatch]::StartNew()
            $List     = $Null
            $List     = $This.Range -Split "`n"
            
            Write-Host "Scanning [~] ($($List.Count)) Hosts [$($Time.Elapsed)]"
            ForEach ($X in 0..($List.Count - 1))
            {
                $IP              = $List[$X]
                $Process.Add($X,[System.Net.NetworkInformation.Ping]::new().SendPingAsync($IP,100,[V4Network]::Buffer,[V4Network]::Options))
            }
        
            Write-Host "Sent [~] Awaiting Response"
            ForEach ($X in 0..($List.Count - 1)) 
            {
                $IP              = $List[$X] 
                $Response       += [V4PingObject]::New($X,$IP,$Process[$X])
            }

            $Output              = $Response | ? Status
            Write-Host "Scanned [+] ($($Output.Count)) Host(s) reponded [$($Time.Elapsed)]"

            If ($Output.Count -gt 1)
            {
                Write-Progress -Activity "Resolving [~] Hostnames... [$($Time.Elapsed)]" -PercentComplete 0
                ForEach ($X in 0..($Output.Count-1))
                {
                    Write-Progress -Activity "Resolving [~] Hostnames... [$($Time.Elapsed)]" -Status "($X/$($Output.Count))" -PercentComplete (($X/$Output.Count)*100)
                    $Item             = $Output[$X]
                    $Item.Index       = $X
                    $Item.GetHostname()
                }
                Write-Progress -Activity "Resolving [~] Hostnames... [$($Time.Elapsed)]" -Completed
            }
            If ($Output.Count -eq 1)
            {
                $Item                 = $Output
                $Item.Index           = 0
                $Item.GetHostname()
            }
            $Time.Stop()
            Write-Host "Sweep [+] Complete [$($Time.Elapsed)]"
            Return $Output
        }
        [String] ToString()
        {
            Return $This.HostRange
        }
    }

    #$Config    = Get-NetIPConfiguration -Detailed
    #$IPAddress = $Config.IPV4Address[0]
    #$V4Network = [V4Network]::New($IPAddress)
    #$Range     = $V4Network.Range
    #$V4network.PingSweep()

    # [V6 Network Class(es)]    # Provisions an entire IPV6 network
    Class V6Network
    {
        [String] $IPAddress
        [Int32]  $Prefix
        [String] $Type
        V6Network([Object]$Address,[String]$Type)
        {
            $This.IPAddress = $Address.IPAddress
            $This.Prefix    = $Address.PrefixLength
            $This.Type      = $Type
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

    Class HostObject
    {
        [UInt32]    $Index
        [IPAddress] $IPAddress
        [String] $Hostname
        HostObject([Uint32]$Index,[Object]$xHost)
        {
            $This.Index     = $Index
            $This.IPAddress = $xHost.IPAddress
            $This.Hostname  = $xHost.Hostname 
        }
    }

    Class HostMap
    {
        [Object] $Output
        Hostmap()
        {
            $This.Output = @( )
        }
        AddHost([Object]$xHost)
        {
            $This.Output += [HostObject]::New($This.Output.Count,$xHost)
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

            ForEach ($Address in $Interface.IPV4Address)
            {
                $This.IPV4   += [V4Network]::New($Address)
            }

            $This.IPV4        = $This.IPV4 | Select-Object -Unique
            $This.IPV6        = @( )

            ForEach ($Address in $Interface.IPV6Address)
            {
                $This.IPV6   += [V6Network]::New($Address,"Global")
            }

            ForEach ($Address in $Interface.IPV6LinkLocalAddress)
            {
                $This.IPV6   += [V6Network]::New($Address,"Local")
            }

            ForEach ($Address in $Interface.IPV6TemporaryAddress)
            {
                $This.IPV6   += [V6Network]::New($Address,"Temp")
            }

            $This.IPV6        = $This.IPV6 | Select-Object -Unique
        }
        GetVendor([Object]$Vendor)
        {
            $This.Vendor = $Vendor.VenID[$This.MacAddress.Replace("-","").Substring(0,6)]
        }
        [String] ToString()
        {
            Return $This.Alias
        }
    }

    Class FENetworkController
    {
        [Object]               $Suffix
        Hidden [Object]    $VendorList
        [Object]                  $Nbt
        [Object[]]          $Interface
        [Object[]]             $Active
        [Object[]]            $HostMap
        [Object[]]            $NbtScan
        FENetworkController()
        {
            $Time                  = [System.Diagnostics.Stopwatch]::StartNew()
            Write-Host "[$($Time.Elapsed)] Collecting [~] FightingEntropy Network Controller"

            $This.Suffix           = [DnsSuffix]::New()
            $This.VendorList       = [VendorList]::New()
            $This.NBT              = [NbtTable]::New()
            $This.Interface        = @( )

            Write-Host "[$($Time.Elapsed)] Collecting [~] Aggregate Interface(s)"
            ForEach ($Item in Get-NetIPConfiguration | % { [FeNetworkControllerInterface]$_ })
            {
                Write-Host ("[$($Time.Elapsed)] [Index: $($Item.Index)] [Alias: $($Item.Alias)/ $($Item.Description)]" -f $Item.Index, $Item.Alias, $Item.Description)
                $Item.GetVendor($This.VendorList)
                $This.Interface   += $Item
            }

            Write-Host "[$($Time.Elapsed)] Collecting [~] Active Interface(s)"
            $This.Active           = $This.Interface | ? { $_.IPV4.Gateway }

            # Write-Host "[$($Time.Elapsed)] Running [~] Ping Sweep"
            # $This.RefreshIPv4Scan()

            Write-Host "[$($Time.Elapsed)] Loaded [+] FightingEntropy Network Controller"
        }
        [Object[]] NetStat()
        {
            Return @( [NetStat]::New().Output )
        }
    }

    # End of Class Declarations
    Switch($PSCmdLet.ParameterSetName)
    {
        0 
        { 
            $Object = [FeNetworkController]::New() 
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
