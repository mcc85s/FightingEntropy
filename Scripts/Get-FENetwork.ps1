Function Get-FENetwork
{
    Import-Module FightingEntropy 

    # // ______________________________________________________
    # // | Meant to adjust the (width/display) of output data |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatValue
    {
        Hidden [UInt32] $Width
        [Object]        $Value
        FormatValue([String]$String)
        {
            $This.Value = $String
            $This.Width = $This.Value.Length
        }
        SetBuffer([UInt32]$Width)
        {
            $This.Width = $Width
        }
        [String] ToString()
        {
            If ($This.Value.Length -lt $This.Width)
            {
                Return "{0}{1}" -f $This.Value, (@(" ") * ($This.Width-$This.Value.Length) -join "")
            }
            Else
            {
                Return $This.Value
            }
        }
    }

    # // _________________________________________________________________
    # // | Meant to contain and adjust the (width/display) of properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatColumn
    {
        [UInt32]  $Index
        [String]   $Name
        [UInt32]    $Max
        [Object] $Output
        FormatColumn([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Output = @( )

            $This.AddHeader($Name)
        }
        AddHeader([String]$Name)
        {
            ForEach ($Item in @($Name;@("-") * $Name.Length -join ''))
            {
                $This.AddItem($Item)
            }
        }
        AddItem([String]$Item)
        {
            $Prop = [FormatValue]::New($Item)
            If ($Prop.Width -gt $This.Max)
            {
                $This.Max = $Prop.Width
            }

            $This.Output += $Prop
        }
        SetBuffer([UInt32]$Width)
        {   
            $This.Output | % SetBuffer $Width
        }
    }

    # // ____________________________________________________________________
    # // | Provides a scalable structure for multiple columns of properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatTable
    {
        [UInt32]  $Count
        [Object] $Output
        FormatTable([Object]$Object,[String[]]$Header)
        {
            $This.Count  = $Object.Count + 2
            $This.Output = @( )

            ForEach ($Name in $Header)
            {
                $Container = [FormatColumn]::New($This.Output.Count,$Name)
                ForEach ($Item in $Object.$Name)
                {
                    $Container.AddItem($Item)
                }

                $Container.SetBuffer($Container.Max)

                $This.Output += $Container
            }
        }
        [Object[]] Draw()
        {
            $Swap   = @{ }
            $Select = 0..($This.Output.Count-1)
            ForEach ($X in 0..($This.Count-1))
            {
                $Swap.Add($Swap.Count,($Select | % { $This.Output[$_].Output[$X] }) -join " | ")
            }
        
            $Out    = @{ }
            $Out.Add($Out.Count,(@([char]95)*($Swap[0].Length+4) -join ""))
            $Swap[0..($Swap.Count-1)] | % { $Out.Add($Out.Count,"| $_ |") }
            $Out.Add($Out.Count,(@([char]175)*($Swap[0].Length+4) -join ""))
        
            Return @($Out[0..($Out.Count-1)])
        }
    }

    # // ____________________________________________________________
    # // | Converts an existing PSObject into an individual section |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatMaster
    {
        [UInt32]  $Index
        [String]   $Name
        [UInt32]    $Max
        [Object] $Output
        FormatMaster([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Output = @( )

            ForEach ($Item in $Object)
            {
                $Prop = [FormatValue]::New($Item)
                If ($Prop.Width -gt $This.Max)
                {
                    $This.Max = $Prop.Width
                }

                $This.Output += $Prop
            }

            $This.SetBuffer($This.Max)
        }
        AddItem([String]$Item)
        {
            $Prop = [FormatValue]::New($Item)
            If ($Prop.Width -gt $This.Max)
            {
                $This.Max = $Prop.Width
            }

            $This.Output += $Prop
        }
        SetBuffer([UInt32]$Width)
        {   
            $This.Output | % SetBuffer $Width
        }
    }

    # // __________________________________________________________
    # // | Provides a scalable structure for a particular section |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class FormatSection
    {
        [UInt32]  $Count
        [Object] $Output
        FormatSection([Object]$Object,[String[]]$Header)
        {
            $This.Count  = $Object.Count
            $This.Output = @( )

            ForEach ($Name in $Header)
            {
                $Container = [FormatMaster]::New($This.Output.Count,$Name,$Object.$Name)

                $This.Output += $Container
            }
        }
        [Object[]] Draw([UInt32]$Rank)
        {
            $Out   = @{ }
            $Array = $This.Output.Index | % {
            
                "{0}: {1}" -f $This.Output[$_].Name, $This.Output[$_].Output[$Rank]
            }
            $Line  = $Array -join " | "
    
            $Out.Add($Out.Count,(@([Char]95) * ($Line.Length + 4) -join ''))
            $Out.Add($Out.Count,"| $Line |")
            $Out.Add($Out.Count,(@([Char]175) * ($Line.Length + 4) -join ''))

            Return $Out[0..($Out.Count-1)]
        }
    }

    # // ________________________________________________
    # // | Collects DNS Suffix/registration information |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ____________________________________________________
    # // | Collects vendor information from the vendor list |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // _________________________________________
    # // | Used for associating a netstat object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
    }

    # // _________________________________________
    # // | Used for each line of a netstat table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetStatObject
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

    # // __________________________________
    # // | Parses an entire netstat table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetStat
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

    # // _____________________________________________________
    # // | Represents properties for a NetworkAdapter object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ______________________________________
    # // | Represents a NetworkAdapter object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ___________________________________________________________
    # // | Represents a list of (0 or more) NetworkAdapter objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // __________________________________________________________________
    # // | Represents properties for a NetworkAdapterConfiguration object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ___________________________________________________
    # // | Represents a NetworkAdapterConfiguration object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ________________________________________________________________________
    # // | Represents a list of (0 or more) NetworkAdapterConfiguration objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ________________________________________________
    # // | Represents properties for a NetworkIp object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // _________________________________
    # // | Represents a NetworkIp object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkIp
    {
        [UInt32] $Index
        [UInt32] $Type
        [Object] $IPAddress
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
        [String] ToString()
        {
            Return $This.IpAddress
        }
    }

    # // ______________________________________________________
    # // | Represents a list of (0 or more) NetworkIp objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
    
    # // ________________________________________________
    # // | Represents properties for a NetworkIp object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
    }

    # // ____________________________________
    # // | Represents a NetworkRoute object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
            $This.Type              = @{ IPv4 = 4; IPv6 = 6}[$Route.AddressFamily.ToString()]
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
            Return $This.IpAddress
        }
    }

    # // ___________________________________________________________
    # // | Represents a list of (0 or more) NetworkRoute object(s) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkRouteList
    {
        [Object] $Output
        NetworkRouteList()
        {
            $This.Output = @( )
            $List        = Get-CimInstance MSFT_NetRoute -Namespace ROOT/StandardCimv2

            ForEach ($Item in $List)
            {
                $This.Add($Item)
            }

            $This.Output = $This.Output | Sort-Object Index
        }
        Add([Object]$Item)
        {
            $This.Output += [NetworkRoute]::New($Item)
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

    # // _____________________________________________________
    # // | Represents properties for a NetIpInterface object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ______________________________________
    # // | Represents a NetIpInterface object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetIpInterface
    {
        [Object]    $Index
        [String]    $Alias
        [UInt32]     $Type
        [UInt32]     $Dhcp
        [UInt32]     $Open
        [Object]       $Ip
        [Object]    $Route
        [Object] $Property
        NetIpInterface([Object]$Interface)
        {
            $This.Index     = $Interface.InterfaceIndex
            $This.Alias     = $Interface.InterfaceAlias
            $This.Type      = @{ IPv4 = 4; IPv6 = 6 }[$Interface.AddressFamily.ToString()]
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
            $This.Property += [NetIpInterfaceProperty]::New($This.Index,$This.Property.Count,$This.Type,$Name,$Value)
        }
        [String] ToString()
        {
            Return $This.Ip
        }
    }

    # // ___________________________________________________________
    # // | Represents a list of (0 or more) NetIpInterface objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ______________________________________________________________________
    # // | Template object meant to assemble individual controller properties |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkControllerTemplate
    {
        [UInt32]          $Index
        Hidden [Object] $Adapter
        Hidden [Object]  $Config
        [String]           $Name
        [String]     $MacAddress
        [String]         $Vendor
        [Object]      $Interface
        NetworkControllerTemplate([UInt32]$Index,[Object]$Adapter,[Object]$Config)
        {
            $This.Index      = $Index
            $This.Adapter    = $Adapter
            $This.Config     = $Config
            $This.Name       = $Adapter.Property | ? Name -eq Name | % Value
            $This.MacAddress = $Config.Property  | ? Name -eq MacAddress | % Value
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
        AddRoute([Object]$Route)
        {
            $Item = $This.Interface | ? Type -eq $Route.Type

            If (!$Item)
            {
                Throw "Interface not added yet"
            }
        }
        SetVendor([String]$Vendor)
        {
            $This.Vendor = $Vendor
        }
    }

    # // ____________________________________________________________________________
    # // | Combines all aspects of the above classes to create a factory controller |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkController
    {
        [Object]           $Suffix = [DnsSuffix]::New()
        Hidden [Object]    $Vendor = [Vendor]::New()
        Hidden [Object]       $Nbt = [NbtTable]::New()
        Hidden [Object] $Interface = [NetIPInterfaceList]::New().Output
        Hidden [Object]   $Adapter = [NetworkAdapterList]::New().Output
        Hidden [Object]    $Config = [NetworkAdapterConfigurationList]::New().Output
        Hidden [Object]        $IP = [NetworkIpList]::New().Output
        Hidden [Object]     $Route = [NetworkRouteList]::New().Output
        [Object]           $Output = @( )
        NetworkController()
        {
            If ($This.Adapter.Count -gt 1)
            {
                ForEach ($X in 0..($This.Adapter.Count-1))
                {
                    $ID          = @{ }
                    $Template    = [NetworkControllerTemplate]::New($X,$This.Adapter[$X],$This.Config[$X])
                    $ID.Vendor   = Switch -Regex ($Template.MacAddress)
                    {
                        ^- { "-" } Default { $This.Vendor.Find($Template.MacAddress) }
                    }
                    $Template.SetVendor($ID.Vendor)
            
                    If ($X -in $This.Interface.Index)
                    {
                        ForEach ($I in 4,6)
                        {
                            $ID.Interface       = $This.Interface | ? Index -eq $X | ? Type -eq $I
                            If ($ID.Interface)
                            {
                                $ID.Interface.IP    = $This.Ip    | ? Index -eq $X | ? Type -eq $I
                                $ID.Interface.Route = $This.Route | ? Index -eq $X | ? Type -eq $I
                                $Template.AddInterface($ID.Interface)
                            }
                            $ID.Interface    = $Null
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
        [Object] Section([Object]$Object,[String[]]$Names)
        {
            Return [FormatSection]::New($Object,$Names)
        }
        [Object] Table([Object]$Object,[String[]]$Names)
        {
            Return [FormatTable]::New($Object,$Names)
        }
        [Object] List()
        {
            $Prop         = @{
                
                Config    = "Index","Name","MacAddress","Vendor"
                Interface = "Alias","Type","Dhcp","Open","Ip"
                Route     = "DestinationPrefix","NextHop","RouteMetric","State"
            }

            $Section      = $This.Section($This.Output,$Prop.Config)
            $Out          = @{ }
        
            ForEach ($X in 0..($Section.Count-1))
            {
                # // __________________
                # // | Section Header |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $Section.Draw($X) | % { $Out.Add($Out.Count,$_) }
        
                # // ___________________
                # // | Section Content |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $Object = $This.Output[$X]
        
                If ($Object.Interface.Count -gt 0)
                {
                    ForEach ($Interface in $Object.Interface)
                    {
                        $This.Table($Interface,$Prop.Interface).Draw()   | % { $Out.Add($Out.Count,$_) }
                        $This.Table($Interface.Route,$Prop.Route).Draw() | % { $Out.Add($Out.Count,$_) }
                    }
                }
            }

            Return $Out[0..($Out.Count-1)]
        }
    }

    # // ____________________________________________
    # // | Object returned from a ping (sweep/scan) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class V4PingObject
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

    # // ______________________________________________________________
    # // | Provisions an entire IPV4 network range, information, etc. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class V4Network
    {
        Hidden Static [String[]]  $Classes = @('N/A';@('A')*126;'Local';@('B')*64;@('C')*32;@('MC')*16;@('R')*15;'BC')
        Hidden Static [Object]    $Options = [System.Net.NetworkInformation.PingOptions]::new()
        Hidden Static [String[]]   $Buffer = @(97..119 + 97..105 | % { "0x{0:X}" -f $_ })
        [String]                $IPAddress
        [String]                    $Class
        [Int32]                    $Prefix
        [String]                  $Netmask
        [Object]                    $Route
        [String]                  $Network
        [String]                  $Gateway
        [String]                    $Range
        [String]                $Broadcast
        V4Network([NetIpInterface]$Interface)
        {
            $This.IPAddress   = $Interface.Ip.IPAddress
            If ($This.IPAddress -match "^169.254")
            {
                $This.Class   = "APIPA"
            }
            Else
            {
                $This.Class       = [V4Network]::Classes[$This.IPAddress.Split(".")[0]]
            }
            $This.Prefix      = $Interface.Ip.Prefix

            # // _______________
            # // | Get Netmask |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Str              = "{0}{1}" -f ("1" * $This.Prefix -join ''),("0" * (32-$This.Prefix) -join '')
            $This.Netmask     = @(0,8,16,24 | % { [Convert]::ToInt32($Str.Substring($_,8),2) }) -join "."

            $This.Route       = $Interface.Route

            $This.Network     = $This.Route | ? DestinationPrefix -match "/$($This.Prefix)" | % DestinationPrefix
            If (!$This.Network)
            {
                $This.Network = "-"
            }

            $This.Gateway     = $This.Route | ? DestinationPrefix -match 0.0.0.0/0 | % NextHop
            If (!$This.Gateway)
            {
                $This.Gateway = "-"
            }
            
            $This.GetHostRange()
            $This.GetBroadcast()
        }
        [Void] GetHostRange()
        {
            $This.Range      = @( Switch ($This.Network)
            {
                "-"
                {
                    "N/A"
                }
                Default
                {
                    $X = [UInt32[]]$This.Network.Split("/")[0].Split(".")
                    $Y = [UInt32[]]$This.Netmask.Split(".") | % { (256 - $_) - 1 }
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
        [Void] GetBroadcast()
        {
            If ($This.Network -ne "-")
            {
                $Split   = $This.Range.Split("/")
                $T       = @{ }
                0..3     | % { $T.Add($_,(Invoke-Expression $Split[$_])) }

                $This.Broadcast  = Switch -Regex ($This.Class)
                {
                    "(^A$|^Local$)" { $T[0], $T[1][-1], $T[2][-1], $T[3][-1] -join "." }
                    "(^Apipa$|^MC$|^R$'|^BC$)" { "-" }
                    ^B$             { $T[0], $T[1]    , $T[2][-1], $T[3][-1] -join "." }
                    ^C$             { $T[0], $T[1]    , $T[2]    , $T[3][-1] -join "." }
                }
            }
            Else
            {
                $This.Broadcast = "-"
            }
        }
    }

    # // _____________________________________
    # // | Provisions an entire IPV6 network |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class V6Network
    {
        [String] $IPAddress
        [UInt32]    $Prefix
        [String]      $Type
        V6Network([Object]$Interface)
        {
            $This.IPAddress = $Interface.Ip.IPAddress
            $This.Prefix    = $Interface.Ip.Prefix
            $This.Type      = $Null
        }
        [String] ToString()
        {
            Return ("{0}/{1}" -f $This.IPAddress, $This.Prefix)
        }
    }

    # // ____________________________________________________________________________
    # // | Used to extend the functionality of the NetworkController output objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkControllerExtension
    {
        [UInt32] $Index
        [String] $Name
        [String] $MacAddress
        [String] $Vendor
        [Object] $IPv4
        [Object] $IPv6
        NetworkControllerExtension([Object]$Interface)
        {
            $This.Index       = $Interface.Index
            $This.Name        = $Interface.Name
            $This.MacAddress  = $Interface.MacAddress
            $This.Vendor      = $Interface.Vendor

            $Hash             = @{ 

                IPv4          = $Interface.Interface | ? Type -eq 4
                IPv6          = $Interface.Interface | ? Type -eq 6
            }

            # // ____________________
            # // | IPV4 Information |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ($Hash.IPv4)
            {
                $This.IPv4    = $This.V4Network($Hash.IPv4)
            }

            # // ____________________
            # // | IPV6 Information |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
            
            If ($Hash.IPv6)
            {
                $This.IPv6   = $This.V6Network($Hash.IPv6)
            }
        }
        [Object] V4Network([Object]$Interface)
        {
            Return [V4Network]::New($Interface)
        }
        [Object] V6Network([Object]$Interface)
        {
            Return [V6Network]::New($Interface)
        }
        [String] Elapsed([Object]$Start)
        {
            Return [TimeSpan]([DateTime]::Now-$Start)
        }
        [Object] PingSweep()
        {
            Throw "Not implemented yet"

            $Process  = @{ }
            $Response = @( )
            $Output   = @( )
            $Start    = [DateTime]::Now
            $List     = $Null
            $List     = $This.Range -Split "`n"
            
            Write-Host "Scanning [~] ($($List.Count)) Hosts [$($This.Elapsed($Start))]"
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
    }

    # // ______________________________________________________________________
    # // | Probably redundant, but acts as a (filtration/expansion) mechanism |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkMain
    {
        [Object] $Main
        [Object] $Hostname
        [Object] $Count
        [Object] $Output
        NetworkMain()
        {
            $This.Main     = [NetworkController]::New()
            $This.Hostname = $This.Main.Suffix | % { $_.ComputerName, $_.Domain -join "." }
            $This.Output   = @( )

            ForEach ($Interface in $This.Main.Output | ? Interface)
            {
                $This.Add($Interface)
            }

            $This.Count    = $This.Output.Count
        }
        Add([Object]$Interface)
        {
            $This.Output += [NetworkControllerExtension]::New($Interface)
        }
        [Object] Section([Object]$Object,[String[]]$Names)
        {
            Return [FormatSection]::New($Object,$Names)
        }
        [Object] Table([Object]$Object,[String[]]$Names)
        {
            Return [FormatTable]::New($Object,$Names)
        }
        [Object] List()
        {
            $Prop         = @{

                Config    = "Index","Name","MacAddress","Vendor"
                IPv4      = "IPAddress","Class","Prefix","Netmask","Network","Gateway","Range","Broadcast"
                IPv4Route = "DestinationPrefix","NextHop","RouteMetric","State"
                IPv6      = "IPAddress","Prefix","Type"
            }

            $Section      = $This.Section($This.Output,$Prop.Config)
            $Out          = @{ }
        
            ForEach ($X in 0..($Section.Count-1))
            {
                # // __________________
                # // | Section Header |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $Section.Draw($X) | % { $Out.Add($Out.Count,$_) }
        
                # // ___________________
                # // | Section Content |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $This.Table($This.Output[$X].IPv4,$Prop.IPv4).Draw()            | % { $Out.Add($Out.Count,$_) }
                $This.Table($This.Output[$X].IPv4.Route,$Prop.IPv4Route).Draw() | % { $Out.Add($Out.Count,$_) }
                $This.Table($This.Output[$X].IPv6,$Prop.IPv6).Draw()            | % { $Out.Add($Out.Count,$_) }
            }

            Return $Out[0..($Out.Count-1)]
        }
    }

    # Todo: IPV6 Type stuff, Ping Sweep (IPV4)
    [NetworkMain]::New()

}
