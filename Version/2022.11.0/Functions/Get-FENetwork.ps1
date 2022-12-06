<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-FENetwork.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : For collecting network adapters, interfaces, as well as a network service                //   
   \\                     controller.                                                                              \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-12-06                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : IPV6 Type stuff, Ping Sweep (IPV4), NBT scan remote addresses                            \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 12-06-2022 00:09:42    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example

    ___________________________________________
    | 00 | [ ] Vendor [ ] Arp/Nbt [ ] Netstat |
    | 01 | [ ] Vendor [ ] Arp/Nbt [X] Netstat |
    | 02 | [ ] Vendor [X] Arp/Nbt [ ] Netstat |
    | 03 | [ ] Vendor [X] Arp/Nbt [X] Netstat |
    | 04 | [X] Vendor [ ] Arp/Nbt [ ] Netstat |
    | 05 | [X] Vendor [ ] Arp/Nbt [X] Netstat |
    | 06 | [X] Vendor [X] Arp/Nbt [ ] Netstat |
    | 07 | [X] Vendor [X] Arp/Nbt [X] Netstat |
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#>
Function Get-FENetwork
{
    [CmdLetBinding()]Param([Parameter()][UInt32]$Mode=0)

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

    Class VendorList
    {
        Hidden [Object]    $File
        [String[]]          $Hex
        [String[]]        $Names
        [String[]]         $Tags
        [Hashtable]          $ID
        [Hashtable]       $VenID
        VendorList()
        {
            $Base            = "$Env:ProgramData\Secure Digits Plus LLC\FightingEntropy"
            $Path            = Get-ChildItem $Base | ? Name -match "^\d{4}\.\d{2}\.\d+$" | % Fullname
            If ($Path.Count -gt 1)
            {
                $Path        = $Path[0]
            }
            
            $Vendor          = "$Path\Control\vendorlist.txt"

            If (![System.IO.File]::Exists($Vendor))
            {
                Throw "Unable to locate the vendorlist file"
            }

            $This.File           = Get-Content $Vendor
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
        [String] ToString()
        {
            Return "<FENetwork.VendorList>"
        }
    }

    #  ____________________________________________
    # /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    # |        __        _________    ________     /
    # |       /_/\      /________/\  /_______/\    \
    # |      /A\  \     |RRRRRRRR\/  |PPPPPPP\/    /
    # |     /A_A\  \    |RR|__|RR/   |PP/__/PP     \
    # |    /AAAAA\  \   |RRRRRRRR/\  |PPPPPPP/     / 
    # |   /A/¯¯¯\A\  \  |RR|¯¯\RR\ \ |PP|¯¯¯¯      \
    # |  /A/     \A\__\ |RR|   \RR\/ |PP|          /
    # | ¯¯¯       ¯¯¯¯¯ ¯¯¯¯    ¯¯¯  ¯¯¯¯          \
    # \____________________________________________/
    #  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

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
        [String] ToString()
        {
            Return "<FENetwork.ArpEntry>"
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
        [Object]       $Output
        ArpAdapter([UInt32]$Index,[String]$Line)
        {
            $This.Index     = $Index
            $This.IPAddress = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.Type      = @("Public","Private")[$This.IPAddress -match 169.254]
            $This.Adapter   = [Regex]::Matches($Line,"(0x\d+)").Value
            $This.Output    = @( )
        }
        AddEntry([String]$Line)
        {
            $This.Output   += [ArpEntry]::New($Line)
        }
        [String] ToString()
        {
            Return "[Index: {0}, Type: {1}, Address: {2}, Rank: {3}, Entries: ({4})]" -f $This.Index, 
            $This.Type, $This.IPAddress, $This.Adapter, $This.Output.Count
        }
    }

    # // _________________________________________
    # // | Collects/Formats the entire ARP table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ArpTable
    {
        Hidden [Object] $Query
        [Object]       $Output
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
    }

    #  _____________________________________________________________________________________ 
    # /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    # \     ___    ___   ________    ________    _______   ________     __      ________    /
    # /    /__/\  /__/| /_______/\  /_______/|  /______/| /_______/|   /_/\    /_______/|   \
    # \    |NN\ \|NN| | |BBBBBBB\/ |TTTTTTT/   /SSSSSS|/  |TTTTTTT/   /A\  \   |TTTTTT|/    /
    # /    |NNN\ |NN| | |BB|__BB/  ¯¯|TT|¯¯    |SS\____   ¯¯|TT|¯¯   /A_A\  \  ¯¯|TT|¯¯     \
    # \    |NN|\N\NN| | |BBBBBB|/\   |TT| |     \SSSSSS\    |TT|    /AAAAA\  \   |TT|       /
    # /    |NN| \NNN| | |BB|__BB\/   |TT| |     ____/SS|    |TT|   /A/¯¯¯\A\  \  |TT|       \
    # \    |NN|  \NN|/  |BBBBBBB/    |TT|/     |SSSSSS/     |TT|  /A/     \A\__\ |TT|       /
    # /    ¯¯¯¯   ¯¯¯   ¯¯¯¯¯¯¯¯     ¯¯¯¯       ¯¯¯¯¯       ¯¯¯¯ ¯¯¯       ¯¯¯¯¯ ¯¯¯¯       \
    # \_____________________________________________________________________________________/
    #  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
            ForEach ($String in $This.String)
            { 
                $This.Output += [NbtReferenceObject]::New($String)
            }
        }
    }

    # // ________________________________________
    # // | Information about detected NBT hosts |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtHost
    {
        [UInt32] $Interface
        [UInt32] $Rank
        [String] $Name
        [String] $Id
        [String] $Type
        [String] $Service
        NbtHost([UInt32]$Interface,[Uint32]$Rank,[String]$Name,[String]$Id,[String]$Type)
        {
            $This.Interface = $Interface
            $This.Rank      = $Rank
            $This.Name      = $Name
            $This.Id        = $Id
            $This.Type      = $Type
        }
    }

    # // __________________________________
    # // | Information from netstat table |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtSection
    {
        [UInt32]    $Interface
        [String]         $Name
        Hidden [String] $Label
        [String]         $Type
        [String]    $IPAddress
        [String]         $Node
        [Object]       $Output
        NbtSection([UInt32]$Interface,[String]$Name,[String]$Type)
        {
            $This.Interface = $Interface
            $This.Name      = $Name.TrimEnd(":")
            $This.Label     = $Name
            $This.Type      = $Type
            $This.Output    = @( )
        }
        [Object] AddHost([String]$Name,[String]$Id,[String]$Type)
        {
            Return [NbtHost]::New($This.Interface,$This.Output.Count,$Name,$Id,$Type)
        }
        AddSwap([Object]$Content)
        {
            ForEach ($X in 0..($Content.Count-1))
            {
                $Line    = $Content[$X].Value
                Switch -Regex ($Line)
                {
                    "^Node IpAddress"
                    {
                        $X         = [Regex]::Matches($Line,"\[(\d|\w|\.)*\]").Value | % Trim "(\[|\])"
                        If ($X.Count -eq 2)
                        {
                            $This.IPAddress = $X[0]
                            $This.Node      = $X[1]
                            If (!$This.Node)
                            {
                                $This.Node = "-"
                            }
                        }
                    }
                    Registered
                    {
                        $X         = $Line -Split " " | ? Length -gt 0
                        If ($X.Count -eq 4)
                        {
                            $This.Output += $This.AddHost($X[0],$X[1],$X[2])
                        }
                    }
                    Default
                    {

                    }
                }

                $X     = $Null
            }
        }
    }

    # // _______________________________
    # // | For concise netstat parsing |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtStack
    {
        [Int32] $Interface
        [UInt32]     $Rank
        [String]    $Value
        NbtStack([Int32]$Interface,[UInt32]$Rank,[String]$Value)
        {
            $This.Interface = $Interface
            $This.Rank      = $Rank
            $This.Value     = $Value
        }
    }

    # // _____________________________________________________________
    # // | Collects the local NBT table (can be modified for remote) |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NbtLocal
    {
        [Object] $Reference
        [Object] $Output
        NbtLocal([String[]]$List)
        {
            # // _________________________________________________
            # // | Get NBT Reference table, and collect NBT info |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Reference   = [NbtReference]::New().Output
            $This.Output      = @( )
            $Stack            = nbtstat -N
            $List             = $Stack -match ".+\:$"
            ForEach ($Item in $List)
            {
                $This.Output += [NbtSection]::New($This.Output.Count,$Item,"Local")
            }

            # // _________________________________________
            # // | Use multiple tokens to chart NBT info |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Swap             = @( )
            $Interface        = -1
            $Rank             = 0
            ForEach ($X in 0..($Stack.Count-1))
            {
                If ($Stack[$X].TrimEnd(" ") -in $This.Output.Label)
                {
                    $Interface ++
                    $Rank      = 0
                }
            
                $Swap          += [NbtStack]::New($Interface,$Rank,$Stack[$X].TrimEnd(" "))
                $Rank          ++
            }

            # // ___________________________________________________________________
            # // | Assign (each section its own table + detected hosts w/ service) |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Max              = ($Swap.Interface | Select-Object -Unique)[-1]
            ForEach ($X in 0..$Max)
            {
                $Item         = $Swap   | ? Interface -eq $X
                $Slot         = $This.Output | ? Label -eq $Item[0].Value
                $Slot.AddSwap($Item)
                ForEach ($Object in $Slot.Output)
                {
                    $Object | % { $_.Service = $This.Reference | ? ID -eq $_.ID | ? Type -eq $_.Type | % Service } 
                }
            }
        }
    }

    #  ______________________________________________________________________________________ 
    # /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    # \     ___    ___   _________   ________    _______    ________     __      ________    /
    # /    /__/\  /__/| /_______/|  /_______/|  /______/|  /_______/|   /_/\    /_______/|   \
    # \    |NN\ \|NN| | |EEEEEEE|/  |TTTTTTT/  /SSSSSS|/   |TTTTTT|/   /A\  \   |TTTTTTT/    /
    # /    |NNN\ |NN| | |EE|_____    ¯¯|TT|¯¯  |SS\____    ¯¯|TT|¯¯   /A_A\  \  ¯¯|TT|¯¯     \
    # \    |NN|\N\NN| | |EEEEEEE/      |TT| |    \SSSSSS\    |TT|    /AAAAA\  \   |TT|       /
    # /    |NN| \NNN| | |EE|____/|     |TT| |    ____/SS|    |TT|   /A/¯¯¯\A\  \  |TT|       \
    # \    |NN|  \NN|/  |EEEEEEE|/     |TT|/    |SSSSSS/     |TT|  /A/     \A\__\ |TT|       /
    # /    ¯¯¯¯   ¯¯¯   ¯¯¯¯¯¯¯¯¯      ¯¯¯¯      ¯¯¯¯¯       ¯¯¯¯ ¯¯¯       ¯¯¯¯¯ ¯¯¯¯       \
    # \______________________________________________________________________________________/
    #  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    #  ___________________________________________
    # /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
    # \     ___    ___   _________   ________     /
    # /    /__/\  /__/| /_______/|  /_______/|    \
    # \    |NN\ \|NN| | |EEEEEEE|/  |TTTTTTT/     /
    # /    |NNN\ |NN| | |EE|_____    ¯¯|TT|¯¯     \
    # \    |NN|\N\NN| | |EEEEEEE/      |TT| |     /
    # /    |NN| \NNN| | |EE|____/|     |TT| |     \
    # \    |NN|  \NN|/  |EEEEEEE|/     |TT|/      /
    # /    ¯¯¯¯   ¯¯¯   ¯¯¯¯¯¯¯¯¯      ¯¯¯¯       \
    # \___________________________________________/
    #  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    # // _____________________________________________________
    # // | Represents properties for a NetworkAdapter object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkAdapterProperty
    {
        [String] $Adapter
        [UInt32] $Rank
        [String] $Name
        [Object] $Value
        NetworkAdapterProperty([UInt32]$Adapter,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Adapter  = $Adapter
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Value    = $Value
        }
    }

    # // ______________________________________
    # // | Represents a NetworkAdapter object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    # // ___________________________________________________________
    # // | Represents a list of (0 or more) NetworkAdapter objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkAdapterList
    {
        [Object] $Output
        NetworkAdapterList()
        {
            $This.Output      = @( )
            $List             = Get-CimInstance Win32_NetworkAdapter
            ForEach ($Adapter in $List)
            {
                $This.Output += [NetworkAdapter]::New($Adapter)
            }

            $This.Output      = $This.Output | Sort-Object Rank
        }
    }

    # // __________________________________________________________________
    # // | Represents properties for a NetworkAdapterConfiguration object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkAdapterConfigurationProperty
    {
        [String] $Adapter
        [UInt32] $Rank
        [String] $Name
        [Object] $Value
        NetworkAdapterConfigurationProperty([UInt32]$Adapter,[String]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Adapter  = $Adapter
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Value    = $Value
        }
    }

    # // ___________________________________________________
    # // | Represents a NetworkAdapterConfiguration object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkAdapterConfiguration
    {
        [UInt32] $Index
        [UInt32] $Rank
        [String] $Name
        [String] $Service
        [UInt32] $Dhcp
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
                $This.Output += [NetworkAdapterConfiguration]::New($Item)
            }
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
            Return "<FENetwork.NetworkRoute>"
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

    # // _______________________________________________________
    # // | Represents properties for a NetworkInterface object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
    }

    # // ________________________________________
    # // | Represents a NetworkInterface object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkInterface
    {
        [Object]    $Index
        [String]    $Alias
        [UInt32]     $Type
        [UInt32]     $Dhcp
        [UInt32]     $Open
        [Object]       $Ip
        [Object]    $Route
        [Object] $Property
        NetworkInterface([Object]$Interface)
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
            $This.Property += [NetworkInterfaceProperty]::New($This.Index,$This.Property.Count,$This.Type,$Name,$Value)
        }
        [String] ToString()
        {
            Return $This.Ip
        }
    }

    # // _____________________________________________________________
    # // | Represents a list of (0 or more) NetworkInterface objects |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkInterfaceList
    {
        [Object] $Output
        NetworkInterfaceList()
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
            $This.Output += [NetworkInterface]::New($Interface)
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
        [String]         $Vendor = "-"
        [Object]           $IPv4
        [Object]           $IPv6
        Hidden [Object]     $Arp
        Hidden [Object]     $Nbt
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
        AddInterface([Object]$Interface)
        {
            Switch ($Interface.Type)
            {
                4
                {
                    $This.IPv4 = $Interface
                }
                6
                {
                    $This.IPv6 = $Interface
                }
            }
        }
        AddRoute([Object]$Route)
        {
            $Item = $This.Interface | ? Type -eq $Route.Type

            If (!$Item)
            {
                Throw "Interface not added yet"
            }
        }
        AddArp([Object]$Arp)
        {
            $This.Arp = $Arp
        }
        AddNbt([Object]$Nbt)
        {
            $This.Nbt = $Nbt
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

    # // _______________________________________________________________________________
    # // | Combines all aspects of the above classes to create a factory subcontroller |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NetworkSubcontroller
    {
        [Object]   $Adapter
        [Object]    $Config
        [Object]     $Route
        [Object] $Interface
        [Object]        $IP
        [Object]  $Template = @( )
        NetworkSubcontroller()
        {

        }
        [Object] NewTemplate([UInt32]$Index,[Object]$Adapter,[Object]$Config)
        {
            Return [NetworkControllerTemplate]::New($Index,$Adapter,$Config)
        }
        Refresh()
        {
            $This.Adapter   = [NetworkAdapterList]::New().Output
            $This.Config    = [NetworkAdapterConfigurationList]::New().Output
            $This.Route     = [NetworkRouteList]::New().Output
            $This.Interface = [NetworkInterfaceList]::New().Output
            $This.IP        = [NetworkIpList]::New().Output
            $This.Template  = @( )
            $Object         = @{ }

            $C              = $This.Adapter.Count             
            $D              = ([String]$C).Length

            Write-Progress -Activity Refreshing -Status ("({0:d$D}/$C)" -f 0) -PercentComplete 0
            ForEach ($X in 0..($This.Adapter.Count-1))
            {
                $Id                         = @{  }
                $Id.Index                   = $This.Config[$X].Property | ? Name -eq InterfaceIndex | % Value
                $Id.Template                = $This.NewTemplate($Id.Index,$This.Adapter[$X],$This.Config[$X])
        
                ForEach ($Type in 4,6)
                {
                    $Id.Interface           = $This.Interface | ? Index -eq $Id.Index | ? Type -eq $Type
                    If ($Id.Interface)
                    {
                        $Id.Interface.IP    = $This.Ip        | ? Index -eq $Id.Index | ? Type -eq $Type
                        $Id.Interface.Route = $This.Route     | ? Index -eq $Id.Index | ? Type -eq $Type
                        $Id.Template.AddInterface($Id.Interface)
                    }
                }
                Write-Progress -Activity Refreshing -Status ("({0:d$D}/$C)" -f $X) -PercentComplete (($X/$C)*100)
        
                $Object.Add($Object.Count,$Id.Template)
            }
            Write-Progress -Activity Refreshing -Status "($C/$C)" -Complete
        
            $This.Template = $Object[0..($Object.Count-1)] | Sort-Object Index
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
        [UInt32]                   $Prefix
        [String]                  $Netmask
        Hidden [Object]             $Route
        [String]                  $Network
        [String]                  $Gateway
        [String]                    $Range
        [String]                $Broadcast
        V4Network([NetworkInterface]$Interface)
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
        [String] ToString()
        {
            Return "{0}/{1}" -f $This.IPAddress, $This.Prefix
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
        [Object] $Arp
        [Object] $Nbt
        NetworkControllerExtension([Object]$Interface)
        {
            $This.Index       = $Interface.Index
            $This.Name        = $Interface.Name
            $This.MacAddress  = $Interface.MacAddress
            $This.Vendor      = $Interface.Vendor
            If ($Interface.IPv4)
            {
                $This.IPv4    = $This.V4Network($Interface.IPv4)
            }
            If ($Interface.IPv6)
            {
                $This.IPv6    = $This.V6Network($Interface.IPv6)
            }
            $This.Arp         = $Interface.Arp
            $This.Nbt         = $Interface.Nbt
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

    Class NetworkController
    {
        Hidden [UInt32] $Mode
        Hidden [Object] $Vendor
        Hidden [Object] $Sub
        Hidden [Object] $Arp
        Hidden [Object] $Nbt
        Hidden [Object] $Netstat
        Hidden [Hashtable] $Hash
        [Object] $Suffix
        [Object] $Hostname
        [Object] $Count
        [Object] $Output = @( )
        NetworkController()
        {
            $This.Mode = 0
            $This.Main()
        }
        NetworkController([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Main()
        }
        Main()
        {
            If ($This.Mode -ge 4)
            {
                $This.GetVendorList()
            }
            $This.Sub        = [NetworkSubcontroller]::New()
            $This.Suffix     = [DnsSuffix]::New()
            $This.Hostname   = $This.Suffix | % { $_.ComputerName, $_.Domain -join "." }
            $This.Refresh()
        }
        [Void] GetVendorList()
        {
            $This.Vendor     = [VendorList]::New()
        }
        [Void] GetNetstat()
        {
            $This.Netstat    = [Netstat]::New().Output
        }
        [Void] GetArpNbt()
        {
            $List            = $This.Sub.Template | ? IPV4 | % { $_.IPV4.Alias } | Select-Object -Unique 
            $This.Arp        = [ArpTable]::New().Output
            $This.Nbt        = [NbtLocal]::New($List).Output
    
            ForEach ($Table in $This.Arp)
            {
                $Item        = $This.Sub.Template | ? {$_.IPV4.IP.IPAddress -eq $Table.IPAddress }
                If ($Item)
                {
                    $Item.AddArp($Table.Output)
                }
            }
    
            ForEach ($Table in $This.Nbt | ? Output)
            {
                $Item        = $This.Sub.Template | ? { $_.IPv4.IP.IPAddress -eq $Table.IPAddress }
                If ($Item)
                {
                    $Item.AddNbt($Table.Output)
                }
            }
        }
        Refresh()
        {
            $This.Output     = @( )
            $This.Sub.Refresh()
            ForEach ($Template in $This.Sub.Template)
            {
                Switch ($This.Mode)
                {
                    0
                    {
                        $Template.Vendor = "-"
                    }
                    1
                    {
                        $Template.SetVendor($This.Vendor)
                    }
                    2
                    {
                        $Template.SetVendor
                    }
                }
            }

            If ($This.Mode -in 1,3,5,7)
            {
                $This.GetNetstat()
            }
            If ($This.Mode -in 2,3,6,7)
            {
                $This.GetArpNbt()
            }

            $This.Output     = $This.Sub.Template | % { [NetworkControllerExtension]::New($_) }
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
                # // __________________
                # // | Section Header |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $This.Add($Out,$Section.Draw($X))
        
                # // ___________________
                # // | Section Content |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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

    [NetworkController]::New($Mode)
}
