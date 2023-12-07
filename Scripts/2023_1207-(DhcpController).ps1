Class DhcpServerv4Reservation
{
    [UInt32]       $Index
    [String]   $IPAddress
    [String]    $ClientID
    [String]        $Name
    [String] $Description
    DhcpServerv4Reservation([UInt32]$Index,[Object]$Reservation)
    {
        $This.Index       = $Index
        $This.IPAddress   = $Reservation.IPAddress
        $This.ClientID    = $Reservation.ClientID
        $This.Name        = $Reservation.Name
        $This.Description = $Reservation.Description
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServerV4Reservation>"
    }
}

Class DhcpServerV4OptionValue
{
    [UInt32]    $Index
    [UInt32] $OptionID
    [String]     $Name
    [String]     $Type
    [String]    $Value
    DhcpServerV4OptionValue([UInt32]$Index,[Object]$Option)
    {
        $This.Index    = $Index
        $This.OptionID = $Option.OptionID
        $This.Name     = $Option.Name
        $This.Type     = $Option.Type
        $This.Value    = $Option.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServerV4Reservation>"
    }
}

Class DhcpServerv4ScopeItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]     $ScopeID
    [String]  $SubnetMask
    [UInt32]       $State
    [String]  $StartRange
    [String]    $EndRange
    [Object]      $Option
    [Object] $Reservation
    DhcpServerv4ScopeItem([UInt32]$Index,[Object]$Scope)
    {
        $This.Index        = $Index
        $This.Name         = $Scope.Name
        $This.ScopeID      = $Scope.ScopeID
        $This.SubnetMask   = $Scope.SubnetMask
        $This.State        = @(0,1)[$Scope.State -eq "Active"]
        $This.StartRange   = $Scope.StartRange
        $This.EndRange     = $Scope.EndRange

        $This.GetOptions()
        $This.GetReservations()
    }
    [Object] DhcpServerV4OptionValue([UInt32]$Index,[Object]$Option)
    {
        Return [DhcpServerV4OptionValue]::New($Index,$Option)
    }
    [Object] DhcpServerv4Reservation([UInt32]$Index,[Object]$Reservation)
    {
        Return [DhcpServerv4Reservation]::New($Index,$Reservation)
    }
    GetOptions()
    {
        $xOptions = Get-DhcpServerV4OptionValue -ScopeID $This.ScopeID
        $This.Option = @( )

        ForEach ($xOption in $xOptions)
        {
            $This.Option += $This.DhcpServerV4OptionValue($This.Option.Count,$xOption)
        }
    }
    GetReservations()
    {
        $xReservations = Get-DhcpServerV4Reservation -ScopeID $This.ScopeID
        $This.Reservation = @( )

        ForEach ($xReservation in $xReservations)
        {
            $This.Option += $This.DhcpServerV4Reservation($This.Reservation.Count,$xReservation)
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServerV4Scope[Item]>"
    }
}

Class DhcpServerItem
{
    [UInt32]     $Index
    [UInt32]    $Active
    [String] $IpAddress
    [String]   $DnsName
    [Object]    $Option
    [Object]   $V4Scope
    [Object]   $V6Scope
    DhcpServerItem([UInt32]$Index,[Object]$Server)
    {
        $This.Index     = $Index
        $This.IpAddress = $Server.IpAddress
        $This.DnsName   = $Server.DnsName
        $This.Active    = [UInt32](!!(Test-Connection -ComputerName $Server.IpAddress -Count 1))
        $This.GetOptions()
        $This.V4Scope   = @( )
        $This.V6Scope   = @( )
    }
    [Object] DhcpServerV4OptionValue([UInt32]$Index,[Object]$Option)
    {
        Return [DhcpServerV4OptionValue]::New($Index,$Option)
    }
    GetOptions()
    {
        $xOptions = Get-DhcpServerV4OptionValue
        $This.Option = @( )

        ForEach ($xOption in $xOptions)
        {
            $This.Option += $This.DhcpServerV4OptionValue($This.Option.Count,$xOption)
        }
    }
    [String] ToString()
    {
        Return $This.DnsName
    }
}

Class DhcpServerController
{
    [Object] $Server
    DhcpServerController()
    {
        $This.GetDhcpServer()
    }
    [Object] DhcpServerItem([UInt32]$Index,[Object]$Server)
    {
        Return [DhcpServerItem]::New($Index,$Server)
    }
    [Object] DhcpServerv4ScopeItem([UInt32]$Index,[Object]$Scope)
    {
        Return [DhcpServerv4ScopeItem]::New($Index,$Scope)
    }
    GetDhcpServer()
    {
        $xServer              = @(Get-DhcpServerInDc)
        $This.Server          = @( )

        If ($xServer.Count -gt 1)
        {
            ForEach ($X in 0..($xServer.Count-1))
            {
                $Item         = $This.DhcpServerItem($This.Server.Count,$xServer[$X])
                $This.Server += $Item
                If ($Item.Active)
                {
                    $This.GetDhcpServerScope($Item.Index)
                }
            }
        }
        Else
        {
            $Item             = $This.DhcpServerItem(0,$xServer[0])
            $This.Server     += $Item
            If ($Item.Active)
            {
                $This.GetDhcpServerScope($Item.Index)
            }
        }
    }
    GetDhcpServerScope([UInt32]$Index)
    {
        If ($Index -gt $This.Server.Count)
        {
            Throw "Invalid index"
        }

        $Item = $This.Server[$Index]

        If ($Item.Active)
        {
            # [V4 Scopes]
            $xScopeV4          = Get-DhcpServerV4Scope -ComputerName $Item.DnsName
            $Item.V4Scope      = @( )

            ForEach ($xScope in $xScopeV4)
            {
                $Item.V4Scope += $This.DhcpServerv4ScopeItem($Item.V4Scope.Count,$xScope)
            }

            # [V6 Scopes]
            # <todo>
        }
    }
    [String] ToString()
    {
        Return "<FEInfrastructure.DhcpServer[Controller]>"
    }
}

$Ctrl = [DhcpServerController]::New()
