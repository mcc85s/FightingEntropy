# Updating Get-FENetwork (11/05/22)
# To-Do: V4Network, V4NetworkPingSweep, V6Network

    Class DNSSuffix
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

    Class Vendor
    {
        Hidden [Object]    $File
        [String[]]          $Hex
        [String[]]        $Names
        [String[]]         $Tags
        [Hashtable]          $ID
        [Hashtable]       $VenID
        Vendor()
        {
            $This.File           = Get-FEModule -Control | ? Name -match vendorlist.txt | % { Get-Content $_.FullName }
            $This.Hex            = $This.File -Replace "(\t){1}.*","" -Split "`n"
            $This.Names          = $This.File -Replace "([A-F0-9]){6}\t","" -Split "`n"
            $This.Tags           = $This.Names | Sort-Object
            $This.ID             = @{ }

            ForEach ($I in 0..($This.Tags.Count-1))
            {
                If (!$This.ID[$This.Tags[$I]])
                {
                    $This.ID.Add($This.Tags[$I],$I)
                }
            }

            $This.VenID          = @{ }
            ForEach ($I in 0..($This.Hex.Count-1))
            {
                $This.VenID.Add($This.Hex[$I],$This.Names[$I])
            }
        }
        [String] Find([String]$Mac)
        {
            $xID  = $Mac -Replace "(-|:)","" | % Substring 0 6
            $Item = $This.VenID[$xID]

            If (!$Item)
            {
                $Item = "-"
            }

            Return $Item
        }
    }

    # // _____________________________________________________
    # // | Collects/formats the information for an ARP entry |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ArpEntry
    {
        [String]    $IPAddress
        [String]     $Physical
        [String]         $Type
        ArpEntry([String]$Line)
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
    }

    # // _________________________________________________________________
    # // | Collects/formats information for an adapter in the ARP table  |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ArpAdapter
    {
        [UInt32]        $Index
        [String]         $Type
        [String]    $IPAddress
        [UInt32]      $Adapter
        [Object[]]     $Output
        ArpAdapter([UInt32]$Index,[String]$Line)
        {
            $This.Index     = $Index
            $This.IPAddress = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Type      = @("Public","Private")[$This.IPAddress -match 169.254]
            $This.Adapter   = [Regex]::Matches($line,"(0x\d+)").Value
            $This.Output    = @( )
        }
        AddEntry([String]$Line)
        {
            $This.Output   += [ArpEntry]::New($Line)
        }
        [String] ToString()
        {
            Return "[Index: {0}, Type: {1}, Address: {2}, Rank: {3}, Entries: ({4})]" -f $This.Index, 
            $This.Slot, $This.Address, $This.Adapter, $This.Output.Count
        }
    }

    # // _________________________________________
    # // | Collects/Formats the entire ARP table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ArpTable
    {
        Hidden [Object] $Query
        [Object[]] $Output
        ArpTable()
        {
            $This.Query   = arp -a
            $This.Output = @( )
            ForEach ($X in 0..($This.Query.Count-1))
            {
                $Line = $This.Query[$X]
                Switch -Regex ($Line)
                {
                    "^Interface"
                    {
                        $This.Output += [ArpAdapter]::New($This.Output.Count,$Line)
                    }
                    "^\s{2}\d"
                    {
                        $This.Output[$This.Output.Count-1].AddEntry($Line)
                    }
                }
            }
        }
        [String[]] ToString()
        {
            Return @( 

                ForEach ($Object in $This.Output)
                {
                    $Object.ToString()
                }
            )
        }
        [Object] List()
        {
            $Max = @{ 

                Index         = ($This.Output.Index            | Sort-Object Length)[-1]
                IPAddress     = ($This.Output.IPAddress        | Sort-Object Length)[-1]
                Adapter       = ($This.Output.Adapter          | Sort-Object Length)[-1]
            }

            $Out = @{ }

            ForEach ($Adapter in $This.Output)
            {
                
                # // __________________
                # // | Section Header |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $0, $1, $2, $3, $4 = $Adapter | % { $_.Index, $_.Type, $_.IPAddress, $_.Adapter, $_.Output.Count }

                If ($0.Length -lt $Max.Index.Length)
                {
                    $0 = "{0}{1}" -f (@(" ") * ($Max.Index.Length - $0.Length) -join ''), $0
                }

                If ($1 -eq "Public")
                {
                    $1 = " Public"
                }

                If ($2.Length -lt $Max.IPAddress.Length)
                {
                    $2 = "{0}{1}" -f (@(" ") * ($Max.IPAddress.Length - $2.Length) -join ''), $2
                }

                If ($3.Length -lt $Max.Adapter.Length)
                {
                    $3 = "{0}{1}" -f (@(" ") * ($Max.Adapter.Length - $3.Length) -join ''), $3
                }


                $Line = "Index: {0} | Type: {1} | IPAddress: {2} | Adapter: {3} | ({4}) entries ..." -f $0, $1, $2, $3, $4

                $Out.Add($Out.Count,(@([Char]95) * ($Line.Length + 4) -join ''))
                $Out.Add($Out.Count,"| $Line |")
                $Out.Add($Out.Count,(@([Char]175) * ($Line.Length + 4) -join ''))

                # // ___________________
                # // | Section Content |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $Hash         = @{ 

                    IPAddress = "IPAddress","---------"
                    Physical  = "Physical","--------"
                    Type      = "Type","----"
                }

                ForEach ($Prop in "IPAddress","Physical","Type")
                {
                    $Adapter.Output.$Prop | % { $Hash.$Prop += $_ }
                }

                $Sub          = @{ 

                    IPAddress = ($Hash.IPAddress | Sort-Object Length)[-1]
                    Physical  = ($Hash.Physical  | Sort-Object Length)[-1]
                    Type      = ($Hash.Type      | Sort-Object Length)[-1]
                }

                $Slot         = @( )

                ForEach ($X in 0..($Hash.IPAddress.Count-1))
                {
                    $I        = $Hash.IPAddress[$X]
                    $P        = $Hash.Physical[$X]
                    $T        = $Hash.Type[$X]

                    If ($I.Length -lt $Sub.IPAddress.Length)
                    {
                        $I    = "{0}{1}" -f $I, (@(" ") * ($Sub.IPAddress.Length - $I.Length) -join '')
                    }
                    If ($P.Length -lt $Sub.Physical.Length)
                    {
                        $P    = "{0}{1}" -f $P, (@(" ") * ($Sub.Physical.Length - $P.Length) -join '')
                    }
                    If ($T.Length -lt $Sub.Type.Length)
                    {
                        $T    = "{0}{1}" -f $T, (@(" ") * ($Sub.Type.Length - $T.Length) -join '')
                    }

                    $Slot    += "| {0} | {1} | {2} |" -f $I, $P, $T
                }

                $Out.Add($Out.Count,(@([char]95) * $Slot[0].Length -join ''))
                $Slot         | % { $Out.Add($Out.Count,$_) }
                $Out.Add($Out.Count,(@([Char]175) * $Slot[0].Length -join ''))
            }

            Return $Out[0..($Out.Count-1)]
        }
    }

    # // ______________________________________________
    # // | Object to populate the NBT Reference Table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtReferenceObject
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

    # // _________________________________________________________
    # // | Reference object to map NetBIOS ID's to service names |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtReference
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

    # // _________________________________________________________________________________
    # // | Used to identify NBT network hosts and any NetBIOS services it may be running |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtEntry
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

    # // ____________________________________________________
    # // | Collects/formats a remote or local Nbtstat table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtSection
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

    # // _______________________________________________________
    # // | Collects node entries and converts to a table entry |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtNode
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

    # // _______________________________________________
    # // | Retrieves Domain Controllers from Arp stack |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtDc
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

    # // ___________________________________
    # // | Combines the ARP stack with NBT |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtTable
    {
        [Object] $Reference
        [Object]       $Arp
        [Object]     $Local
        [Object]    $Remote
        [Object]      $Swap
        [Object]    $Output
        NbtTable()
        {
            Write-Host "Collecting [~] Arp Table"

            $This.Reference = [NbtReference]::New().Output
            $This.Arp       = [ArpTable]::New()
            $This.Local     = @( )
            $This.Remote    = @( )
            $This.GetLocal()
            ForEach ($Section in $This.Arp.Section)
            {
                Write-Host ("Scanning [~] [Index: {0}] [Slot: {1}] [Address: {2}] [Adapter: {3}]" -f $Section.Index, $Section.Slot, $Section.Address, $Section.Adapter)
                ForEach ($Entry in $Section.Entry | ? Type -eq Host)
                {
                    Write-Host ("[Entry: {0}]" -f $Entry.Address)
                    $This.GetRemote($Entry.Address)
                }
            }
            ForEach ($Section in $This.Remote | ? {$_.Entry.Count -gt 0})
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
            $This.Output = @( )
            ForEach ($Item in $This.Swap | ? ID -match "1b|1c")
            {
                If ($Item.Address -notin $This.Output.IPAddress)
                {
                    $This.Output += [NbtDc]::New($Item)
                }
            }
            $This.Output = $This.Output | Sort-Object IPAddress
        }
    }

    Class NetIpInterfaceProperty
    {
        [UInt32]  $Index
        [UInt32]   $Rank
        [UInt32]   $Type
        [String]   $Name
        [Object]  $Value
        NetIpInterfaceProperty([UInt32]$Index,[UInt32]$Rank,[UInt32]$Type,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.Type   = $Type
            $This.Name   = $Name
            $This.Value  = $Value
        }
    }

    Class NetIpInterface
    {
        [Object]    $Index
        [String]    $Alias
        [UInt32]     $Type
        [UInt32]     $Dhcp
        [UInt32]     $Open
        [String]       $Ip
        [Object] $Property
        NetIpInterface([Object]$Interface)
        {
            $This.Index    = $Interface.InterfaceIndex
            $This.Alias    = $Interface.InterfaceAlias
            $This.Type     = @{ IPv4 = 4; IPv6 = 6 }[$Interface.AddressFamily.ToString()]
            $This.Dhcp     = $Interface.Dhcp -eq "Enabled"
            $This.Open     = $Interface.ConnectionState -eq "Connected"
            $This.Ip       = @( )
            $This.Property = @( )

            ForEach ($Item in $Interface.PSObject.Properties)
            {
                $This.AddProperty($Item.Name,$Item.Value)
            }
        }
        SetIpAddress([String]$String)
        {
            $This.IP       = $String 
        }
        AddProperty([String]$Name,[Object]$Value)
        {
            $This.Property += [NetIpInterfaceProperty]::New($This.Index,$This.Property.Count,$This.Type,$Name,$Value)
        }
        [String] ToString()
        {
            Return $This.IP
        }
    }

    Class NetIpInterfaceList
    {
        [Object] $Output
        NetIpInterfaceList()
        {
            $This.Output = @( )
            $List        = Get-CimInstance MSFT_NetIPInterface -Namespace ROOT\StandardCimv2
            ForEach ($Interface in $List)
            {
                $This.Add($Interface)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Interface)
        {
            $This.Output += [NetIpInterface]::New($Interface)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Output[$Index]
        }
        [Object[]] Get([String]$Name)
        {
            Return $This.Output | ? Name -match $Name
        }
                [Object[]] List()
        {
            Return $This.Output
        }
    }

    Class NetworkAdapterProperty
    {
        [String]  $Index
        [UInt32]   $Rank
        [String]   $Name
        [Object]  $Value
        NetworkAdapterProperty([UInt32]$Index,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.Name   = $Name
            $This.Value  = $Value
        }
    }

    Class NetworkAdapter
    {
        [UInt32]    $Index
        [String]     $Name
        [String]     $Type
        [Object] $Property
        NetworkAdapter([Object]$Adapter)
        {
            $This.Index    = $Adapter.DeviceId
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
            $This.Property += [NetworkAdapterProperty]::New($This.Index,$This.Property.Count,$Name,$Value)
        }
    }

    Class NetworkAdapterList
    {
        [Object] $Output
        NetworkAdapterList()
        {
            $This.Output = @( )
            $List        = Get-CimInstance Win32_NetworkAdapter
            ForEach ($Adapter in $List)
            {
                $This.Add($Adapter)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Adapter)
        {
            $This.Output += [NetworkAdapter]::New($Adapter)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Output[$Index]
        }
        [Object[]] Get([String]$Name)
        {
            Return $This.Output | ? Name -match $Name
        }
        [Object[]] List()
        {
            Return $This.Output
        }
    }

    Class NetworkAdapterConfigurationProperty
    {
        [UInt32] $Index
        [String] $Rank
        [String] $Name
        [Object] $Value
        NetworkAdapterConfigurationProperty([UInt32]$Index,[UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class NetworkAdapterConfiguration
    {
        [UInt32] $Index
        [String] $Name
        [String] $Service
        [UInt32] $Dhcp
        [Object] $Property
        NetworkAdapterConfiguration([Object]$Config)
        {
            $This.Index    = $Config.Index
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
    }

    Class NetworkAdapterConfigurationList
    {
        [Object] $Output
        NetworkAdapterConfigurationList()
        {
            $This.Output = @( )
            $List        = Get-CimInstance Win32_NetworkAdapterConfiguration

            ForEach ($Item in $List)
            {
                $This.Add($Item)
            }
        }
        Add([Object]$Adapter)
        {
            $This.Output += [NetworkAdapterConfiguration]::New($Adapter)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Output[$Index]
        }
        [Object[]] Get([String]$Name)
        {
            Return $This.Output | ? Name -match $Name
        }
        [Object[]] List()
        {
            Return $This.Output
        }
    }

    Class NetworkIpProperty
    {
        [UInt32] $Index
        [UInt32] $Rank
        [String] $Name
        [Object] $Value
        NetworkIpProperty([UInt32]$Index,[UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    Class NetworkIp
    {
        [UInt32] $Index
        [UInt32] $Type
        [String] $IPAddress
        [UInt32] $Prefix
        [Object] $Property
        NetworkIp([Object]$Ip)
        {
            $This.Index     = $Ip.InterfaceIndex
            $This.Type      = @{ IPv4 = 4; IPv6 = 6 }[$Ip.AddressFamily.ToString()]
            $This.IpAddress = $Ip.IpAddress.ToString()
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
    }

    Class NetworkIpList
    {
        [Object] $Output
        NetworkIpList()
        {
            $This.Output = @( )
            $List        = Get-NetIpAddress

            ForEach ($Item in $List)
            {
                $This.Add($Item)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$IP)
        {
            $This.Output += [NetworkIp]::New($Ip)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Output[$Index]
        }
        [Object[]] Get([String]$Name)
        {
            Return $This.Output | ? Name -match $Name
        }
        [Object[]] List()
        {
            Return $This.Output
        }
    }

    Class NetworkControllerTemplate
    {
        [UInt32] $Index
        Hidden [Object] $Adapter
        Hidden [Object] $Config
        [String] $Name
        [String] $MacAddress
        [String] $Vendor
        [Object] $Interface
        NetworkControllerTemplate([UInt32]$Index,[Object]$Adapter,[Object]$Config)
        {
            $This.Index      = $Index
            $This.Adapter    = $Adapter
            $This.Config     = $Config
            $This.Name       = $Adapter.Property | ? Name -eq Name | % Value
            $This.MacAddress = $Config.Property | ? Name -eq MacAddress | % Value
            If (!$This.MacAddress)
            {
                $This.MacAddress = "-"
            }
            $This.Interface  = @( )
        }
        AddInterface([Object]$Interface)
        {
            $This.Interface += $Interface
        }
        SetVendor([String]$Vendor)
        {
            $This.Vendor = $Vendor
        }
    }

    Class NetworkController
    {
        [Object]           $Suffix = [DnsSuffix]::New()
        Hidden [Object]    $Vendor = [Vendor]::New()
        Hidden [Object]       $Nbt = [NbtTable]::New()
        Hidden [Object] $Interface = [NetIPInterfaceList]::New().Output
        Hidden [Object]   $Adapter = [NetworkAdapterList]::New().Output
        Hidden [Object]    $Config = [NetworkAdapterConfigurationList]::New().Output
        Hidden [Object]        $IP = [NetworkIpList]::New().Output
        [Object]           $Output = @( )
        NetworkController()
        {
            If ($This.Adapter.Count -gt 1)
            {
                ForEach ($X in 0..($This.Adapter.Count-1))
                { 
                    $Cfg      = $This.Config | ? Index -eq $X
                    $Template = [NetworkControllerTemplate]::New($X,$This.Adapter[$X],$Cfg)
                    $Mac      = $Template.MacAddress
                    $xVendor  = Switch -Regex ($Mac)
                    {
                        ^- { "-" } Default { $This.Vendor.Find($Mac) }
                    }
                    $Template.SetVendor($xVendor)
        
                    If ($X -in $This.Interface.Index)
                    {
                        ForEach ($xInterface in $This.Interface | ? Index -eq $X)
                        {
                            $xInterface.Ip = $This.Ip | ? Index -eq $X | ? Type -eq $xInterface.Type | % IpAddress
                            $Template.AddInterface($xInterface)
                        }
                    }
                    
                    $This.Output += $Template
                }
            }
        }
        [Object] Prop([String]$Prop)
        {
            Return ($This.Output.$Prop | Sort-Object Length)[-1]
        }
        [Object] List()
        {
            $Max = @{ 

                Index      = $This.Prop("Index")
                Name       = $This.Prop("Name")
                MacAddress = $This.Prop("MacAddress")
                Vendor     = $This.Prop("Vendor")
            }

            $Out = @{ }

            ForEach ($Object in $This.Output)
            {
                
                # // __________________
                # // | Section Header |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $0, $1, $2, $3, $4 = $Object | % { $_.Index, $_.Name, $_.MacAddress, $_.Vendor, $_.Interface.Count }

                If ($0.Length -lt $Max.Index.Length)
                {
                    $0 = "{0}{1}" -f (@(" ") * ($Max.Index.Length - $0.Length) -join ''), $0
                }

                If ($1.Length -lt $Max.Name.Length)
                {
                    $1 = "{0}{1}" -f (@(" ") * ($Max.Name.Length - $1.Length) -join ''), $1
                }
                
                If ($2.Length -lt $Max.MacAddress.Length)
                {
                    $2 = "{0}{1}" -f (@(" ") * ($Max.MacAddress.Length - $2.Length) -join ''), $2
                }

                If ($3.Length -lt $Max.Vendor.Length)
                {
                    $3 = "{0}{1}" -f (@(" ") * ($Max.Vendor.Length - $3.Length) -join ''), $3
                }

                $Line = "Index: {0} | Name: {1} | Mac: {2} | Vendor: {3} | ({4}) interface(s) ..." -f $0, $1, $2, $3, $4

                $Out.Add($Out.Count,(@([Char]95) * ($Line.Length + 4) -join ''))
                $Out.Add($Out.Count,"| $Line |")
                $Out.Add($Out.Count,(@([Char]175) * ($Line.Length + 4) -join ''))
            }

            Return $Out[0..($Out.Count-1)]
        }
    }
