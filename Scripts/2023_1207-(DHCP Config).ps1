<# [DHCP Configuration]: Server options and scope options differ, the server options will propogate
to ALL scopes on the DHCP server, whereas the scope options will only be for that particular scope.

Will make differentiations at some later point.
_______________________________________
| Server  : dsc1.securedigitsplus.com |
| ScopeID : 192.168.42.0/24           |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
ID Name                 Value
-- ----                 -----
 3 Router               {192.168.42.129}
 4 Time Server(s)       {104.131.155.175}
 6 Dns Server(s)        {1.1.1.1, 1.0.0.1}
28 Broadcast Address    {192.168.42.255}
32 Router Solicit       {192.168.42.129}
40 NIS Domain Name      {securedigitsplus.com}
64 NIS+ Domain Name     {securedigitsplus.com}
66 Boot Server Hostname {dsc1.securedigitsplus.com}
#>

Class DhcpServerV4ScopeOptionItem
{
    [UInt32]      $ID
    [String]    $Name
    [String[]] $Value
    DhcpServerV4ScopeOptionItem([UInt32]$ID,[String]$Name,[String[]]$Value)
    {
        $This.ID    = $ID
        $This.Name  = $Name
        $This.Value = $Value
    }
}

Class DhcpServerV4ScopeRangeItem
{
    [UInt32]      $Index
    [String]  $IPAddress
    [UInt32]  $Available
    [UInt32]    $Reserve
    [String] $MacAddress
    DhcpServerV4ScopeRangeItem([UInt32]$Index,[String]$IPAddress)
    {
        $This.Index     = $Index
        $This.IPAddress = $IPAddress
        $This.Available = 1
    }
    [String] ToString()
    {
        Return $This.IPAddress
    }
}

Class DhcpServerV4Scope
{
    [String]      $Server
    [String]     $ScopeID
    [Object]       $Range
    [Object]      $Option
    DhcpServerV4Scope([String]$Server,[String]$ScopeID)
    {
        $This.Server  = $Server
        $This.ScopeID = $ScopeID
        $This.SetRange()
        $This.Option  = @( )
    }
    [Object] DhcpServerV4ScopeRangeItem([UInt32]$Index,[String]$IPAddress)
    {
        Return [DhcpServerV4ScopeRangeItem]::New($Index,$IPAddress)
    }
    [Object] DhcpServerV4ScopeOptionItem([UInt32]$ID,[String]$Name,[String[]]$Value)
    {
        Return [DhcpServerV4ScopeOptionItem]::New($ID,$Name,$Value)
    }
    AddOption([UInt32]$ID,[String]$Name,[String[]]$Value)
    {
        $This.Option += $This.DhcpServerV4ScopeOptionItem($ID,$Name,$Value)
    }
    AddReservation([String]$IPAddress,[String]$MacAddress)
    {
        If ($IPAddress -notin $This.Range.IPAddress)
        {
            Throw "Invalid IP Address"
        }

        $Item            = $This.Range | ? IPAddress -eq $IPAddress
        
        If ($Item.Reserve)
        {
            Throw "Address already reserved"
        }
        
        $Item.Available  = 0
        $Item.Reserve    = 1
        $Item.MacAddress = $MacAddress
    }
    RemoveReservation([String]$IPAddress)
    {
        If ($IPAddress -notin $This.Range.IPAddress)
        {
            Throw "Invalid IP Address"
        }

        $Item            = $This.Range | ? IPAddress -eq $IPAddress

        $Item.Available  = 1
        $Item.Reserve    = 0
        $Item.MacAddress = ""
    }
    SetRange()
    {
        $This.Range      = @( )

        # [Determine Netmask from prefix]
        $Start           = $This.ScopeID -Split "\/"
        $Prefix          = [UInt32]$Start[1]
        $X               = 0
        $Array           = Do
        {
            @("0","1")[$X -lt $Prefix]
            If ($X -in 7,15,23)
            {
                "."
            }
            $X        ++
        }
        Until ($X -eq 32)

        $Netmask       = @($Array -join "" -Split "\." | % { [Convert]::ToInt32($_,2 ) }) -join "."

        # [Determine wildcard from netmask]
        $Wildcard      = @($Netmask -Split "\." | % { 256-$_ }) -join "."

        # [Split netmask, wildcard, and address]
        $xAddress      = $Start[0] -Split "\."
        $xNetmask      = $Netmask -Split "\."
        $xWildcard     = $Wildcard -Split "\."

        # [Convert wildcard into total host range]
        $Hash          = @{ }
        ForEach ($X in 0..3)
        { 
            $Value = Switch ($xWildcard[$X])
            {
                1       
                { 
                    $xAddress[$X]
                }
                Default
                {
                    ForEach ($Item in 0..255 | ? { $_ % $xWildcard[$X] -eq 0 })
                    {
                        "{0}..{1}" -f $Item, ($Item+($xWildcard[$X]-1))
                    }
                }
                255
                {
                    "{0}..{1}" -f $xNetmask[$X],($xNetmask[$X]+$xWildcard[$X])
                }
            }

            $Hash.Add($X,$Value)
        }

        # [Build host range]
        $xRange   = @{ }
        ForEach ($0 in $Hash[0])
        {
            ForEach ($1 in $Hash[1])
            {
                ForEach ($2 in $Hash[2])
                {
                    ForEach ($3 in $Hash[3])
                    {
                        $xRange.Add($xRange.Count,"$0/$1/$2/$3")
                    }
                }
            }
        }

        $Complete  = @{ }
        # [Expand host range]
        If ($xRange.Count -eq 1)
        {
            $List = $xRange[0]
        }
        Else
        {
            $List = $xRange[0..($xRange.Count-1)]
        }

        ForEach ($Item in $List)
        {
            $Split     = $Item -Split "\/"
            ForEach ($0 in $Split[0] | Invoke-Expression)
            {
                ForEach ($1 in $Split[1] | Invoke-Expression)
                {
                    ForEach ($2 in $Split[2] | Invoke-Expression)
                    {
                        ForEach ($3 in $Split[3] | Invoke-Expression)
                        {
                            $Complete.Add($Complete.Count,"$0.$1.$2.$3")
                        }
                    }
                }
            }
        }

        If ($Complete.Count -eq 1)
        {
            $List = $Complete[0]
        }
        Else
        {
            $List = $Complete[0..($Complete.Count-1)]
        }

        ForEach ($X in 0..($List.Count-1))
        {
            $This.Range += $This.DhcpServerV4ScopeRangeItem($X,$List[$X])
        }

        # [Sets first/network and last/broadcast]
        ForEach ($Item in $This.Range[0,-1])
        {
            $Item.Available  = 0
            $Item.Reserve    = 1
            $Item.MacAddress = "FFFFFFFFFFFF"
        }
    }
}

$Config     = Get-NetIPConfiguration -Detailed
$Server     = "dsc1.securedigitsplus.com"
$ScopeID    = "192.168.42.0/24"
$IPAddress  = "192.168.42.1"
$MacAddress = $Config.NetAdapter.Linklayeraddress -Replace "-",""
$Ctrl       = [DhcpServerV4Scope]::New($Server,$ScopeID)

# [Add reservations]

# Server
$Ctrl.AddReservation($IPAddress,$MacAddress)

# Switch
$Ctrl.AddReservation("192.168.42.24","025E65323039")

# Gateway/Switch
$Ctrl.AddReservation("192.168.42.129","7633B416DF8B")

# [Add options]
$Ctrl.AddOption(3,"Router","192.168.42.129")
$Ctrl.AddOption(4,"Time Server(s)","104.131.155.175")
$Ctrl.AddOption(6,"Dns Server(s)",@("1.1.1.1","1.0.0.1"))
$Ctrl.AddOption(28,"Broadcast Address","192.168.42.255")
$Ctrl.AddOption(32,"Router Solicit","192.168.42.129")
$Ctrl.AddOption(40,"NIS Domain Name","securedigitsplus.com")
$Ctrl.AddOption(64,"NIS+ Domain Name","securedigitsplus.com")
$Ctrl.AddOption(66,"Boot Server Hostname","dsc1.securedigitsplus.com")
