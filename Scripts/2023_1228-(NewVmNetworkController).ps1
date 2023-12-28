Class NewVmNetworkControllerProperty
{
    [String]  $Name
    [Object] $Value
    NewVmNetworkControllerProperty([Object]$Property)
    {
        $This.Name  = $Property.Name
        $This.Value = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Controller.Property>"
    }
}

Class NewVmNetworkMain
{
    [String]  $Domain
    [String] $NetBios
    NewVmNetworkMain([String]$Domain,[String]$NetBios)
    {
        $This.Domain  = $Domain.ToLower()
        $This.NetBios = $NetBios.ToUpper()
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Main>"
    }
}

Class NewVmNetworkBase
{
    [String]    $Domain
    [String]   $NetBios
    [String]   $Network
    [String] $Broadcast
    [String]   $Trusted
    [UInt32]    $Prefix
    [String]   $Netmask
    [String]  $Wildcard
    [String]  $Notation
    [String]   $Gateway
    [String[]]     $Dns
    NewVmNetworkBase([Object]$Main,[Object]$Entry)
    {
        If ($Entry.Type -ne 4)
        {
            Throw "Invalid address family (IPV6 not available yet)"
        }

        $This.Domain    = $Main.Domain
        $This.NetBios   = $Main.NetBios

        $This.Trusted   = $Entry.IPAddress
        $This.Prefix    = $Entry.Prefix

        $This.GetNetwork()

        $This.Gateway   = $Entry.Gateway | Select-Object -First 1
        $This.Dns       = $Entry.Dns -join ", "
    }
    GetNetwork()
    {
        # Convert IP and PrefixLength into binary, netmask, and wildcard
        $xBinary       = 0..3 | % { (($_*8)..(($_*8)+7) | % { @(0,1)[$_ -lt $This.Prefix] }) -join '' }
        $This.Netmask  = ($xBinary | % { [Convert]::ToInt32($_,2 ) }) -join "."
        $This.Wildcard = ($This.Netmask.Split(".") | % { (256-$_) }) -join "."

        $xNetwork      = [UInt32[]]$This.Trusted.Split(".")
        $xWildCard     = [UInt32[]]$This.Wildcard.Split(".")
        $yNetwork      = @( )
        $yBroadcast    = @( )
        $yNotation     = @( )

        For ($X = 0; $X -lt 4; $X ++)
        {
            $Array += @(Switch ($xWildCard[$X])
            {
                {$_ -eq 1}
                {
                    $yNetwork   += $xNetwork[$X]
                    $yBroadcast += $xNetwork[$X]
                    $yNotation  += $xNetwork[$X]
                }
                {$_ -gt 1 -and $_ -lt 256}
                {
                    $Count       = 256/$xWildcard[$X]
                    $List        = 0..($Count-1) | % { $xWildcard[$X] * $_ }
                    $yNetwork   += $List  | ? { $xNetwork[$X] -in $_..($_+($xWildCard[$X]-1)) }
                    $yBroadcast += $yNetwork[-1] + ($xWildcard[$X]-1)
                    $yNotation  += "{0}..{1}" -f $yNetwork[-1], $yBroadcast[-1]
                }
                {$_ -eq 256}
                {
                    $yNetwork   += 0
                    $yBroadcast += 255
                    $yNotation  += "0..255"
                }
            })
        }

        $This.Network   = $yNetwork -join "."
        $This.Broadcast = $yBroadcast -join "."
        $This.Notation  = $yNotation -join "/"
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Base>"
    }
}

Class NewVmNetworkRange
{
    [UInt32]     $Index
    [String]     $Total
    [String]   $Netmask
    [String]  $Notation
    [Object]    $Output
    NewVmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Total,[String]$Notation)
    {
        $This.Index    = $Index
        $This.Total    = $Total
        $This.Netmask  = $Netmask
        $This.Notation = $Notation
        $This.Clear()
    }
    Clear()
    {
        $This.Output   = @( )
    }
    Expand()
    {
        $Split     = $This.Notation.Split("/")
        $HostRange = @{ }
        ForEach ($0 in $Split[0] | Invoke-Expression)
        {
            ForEach ($1 in $Split[1] | Invoke-Expression)
            {
                ForEach ($2 in $Split[2] | Invoke-Expression)
                {
                    ForEach ($3 in $Split[3] | Invoke-Expression)
                    {
                        $HostRange.Add($HostRange.Count,"$0.$1.$2.$3")
                    }
                }
            }
        }

        $This.Output    = $HostRange[0..($HostRange.Count-1)]
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Range>"
    }
}

Class NewVmNetworkHost
{
    [UInt32]         $Index
    [UInt32]        $Status
    [String]        $Source
    [String]          $Type = "Host"
    [String]         $Class
    [String]     $IpAddress
    [String]    $MacAddress
    [String]      $Hostname
    NewVmNetworkHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
    {
        $This.Index          = $Index
        $This.Status         = [UInt32]($Reply.Result.Status -match "Success")
        $This.Source         = "Sweep"
        $This.IpAddress      = $IpAddress
        $This.GetClass()
    }
    NewVmNetworkHost([UInt32]$Index,[String]$IpAddress)
    {
        $This.Index          = $Index
        $This.Status         = 0
        $This.Source         = "Sweep"
        $This.IpAddress      = $IpAddress
        $This.GetClass()
    }
    NewVmNetworkHost([Switch]$Flags,[Uint32]$Index,[String]$Line)
    {
        $This.Index          = $Index
        $This.Status         = 1
        $This.Source         = "Arp"
        $This.IpAddress      = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
        $This.MacAddress     = [Regex]::Matches($Line,"([a-f0-9]{2}\-){5}([a-f0-9]{2})").Value.Replace("-","").ToUpper()
        $This.GetClass()
    }
    GetClass()
    {
        If ($This.IpAddress -match "^169.254")
        {
            $This.Class = "APIPA"
        }
        Else
        {
            $First      = $This.IpAddress -Split "\."
            $This.Class = Switch ([UInt32]$First[0])
            {
                {$_ -in        0} { "N/A"       }
                {$_ -in   1..126} { "A"         }
                {$_ -in      127} { "Local"     }
                {$_ -in 128..191} { "B"         }
                {$_ -in 192..223} { "C"         }
                {$_ -in 224..239} { "Multicast" }
                {$_ -in 240..254} { "Reserved"  }
                {$_ -in      255} { "Broadcast" }
            }
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Host>"
    }
}

Class NewVmNetworkDhcp
{
    [String]        $Name
    [String]  $SubnetMask
    [String]     $Network
    [String]  $StartRange
    [String]    $EndRange
    [String]   $Broadcast
    [String[]] $Exclusion
    NewVmNetworkDhcp([Object]$Base,[Object]$Hosts)
    {
        $This.Network     = $Base.Network   = $Hosts[0].IpAddress
        $This.Broadcast   = $Base.Broadcast = $Hosts[-1].IpAddress
        $This.Name        = "{0}/{1}" -f $This.Network, $Base.Prefix
        $This.SubnetMask  = $Base.Netmask
        $Range            = $Hosts | ? Type -eq Host
        $This.StartRange  = $Range[0].IpAddress
        $This.EndRange    = $Range[-1].IpAddress
        $This.Exclusion   = $Range | ? Status | % IpAddress
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Dhcp>"
    }
}

# [Adapter]
Enum NewVmNetworkAdapterStateType
{
    Disconnected
    Connected
}

Class NewVmNetworkAdapterStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]       $Label
    [String] $Description
    NewVmNetworkAdapterStateItem([String]$Name)
    {
        $This.Index = [UInt32][NewVmNetworkAdapterStateType]::$Name
        $This.Name  = [NewVmNetworkAdapterStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class NewVmNetworkAdapterStateList
{
    [Object] $Output
    NewVmNetworkAdapterStateList()
    {
        $This.Refresh()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] NewVmNetworkAdapterStateItem([String]$Name)
    {
        Return [NewVmNetworkAdapterStateItem]::New($Name)
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([NewVmNetworkAdapterStateType]))
        {
            $Item             = $This.NewVmNetworkAdapterStateItem($Name)
            $Item.Label       = @("[ ]","[+]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                Disconnected { "Adapter network is disabled" }
                Connected    { "Adapter network is enabled"  }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Adapter.State[List]>"
    }
}

Class NewVmNetworkAdapterExtension
{
    [UInt32]          $Index
    Hidden [Object] $Adapter
    [String]           $Name
    [String]           $Type
    [Object]          $State
    [String]           $Guid
    [String]     $MacAddress
    [String]    $Description
    [UInt32]       $Assigned
    [String]         $Status
    NewVmNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
    {
        $This.Index          = $Index
        $This.Adapter        = $Adapter
        $This.Name           = $Adapter.Name

        If ($Adapter.PnPDeviceId -match "(USB\\VID|PCI\\VEN)")
        {
            $This.Type       = "Physical"
        }
        ElseIf ($Adapter.PnPDeviceId -match "(ROOT\\VMS_MP)" -or $Adapter.Name -match "Virtual Adapter")
        {
            $This.Type       = "Virtual"
        }
        Else
        {
            $This.Type       = "Unspecified"
        }

        If ($Adapter.Guid)
        {
            $This.Guid        = $Adapter.Guid.ToLower() -Replace "(\{|\})",""
        }

        $This.MacAddress      = $Adapter.MacAddress | % ToLower
        $This.Description     = $Adapter.Description
    }
    SetState([Object]$State)
    {
        $This.State       = $State
    }
    SetStatus()
    {
        $This.Status      = "[Adapter]: {0} {1}" -f $This.State.Label, $This.Name
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Adapter.Extension>"
    }
}

Class NewVmNetworkAdapterController
{
    Hidden [Object] $State
    [Object]       $Output
    NewVmNetworkAdapterController()
    {
        $This.State = $This.NewVmNetworkAdapterStateList()
    }
    [Object] NewVmNetworkAdapterStateList()
    {
        Return [NewVmNetworkAdapterStateList]::New()
    }
    [Object] NewVmNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
    {
        Return [NewVmNetworkAdapterExtension]::New($Index,$Adapter)
    }
    [Object[]] GetObject()
    {
        Return Get-CimInstance Win32_NetworkAdapter | ? { 
            
            $_.PnPDeviceId -match "(USB\\VID|PCI\\VEN|ROOT\\VMS_MP)" -or $_.Name -match "Virtual Adapter"
        }
    }
    [Object] New([Object]$Adapter)
    {
        $Item = $This.NewVmNetworkAdapterExtension($This.Output.Count,$Adapter)
        $Item.SetState($This.State.Output[[UInt32]$Item.Adapter.NetEnabled])
        $Item.SetStatus()

        Return $Item
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Adapter in $This.GetObject())
        {
            $Item = $This.New($Adapter)

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Adapter.Controller>"
    }
}

# [Virtual Adapter]
Enum NewVmNetworkVirtualAdapterStateType
{
    Active
    Inactive
}

Class NewVmNetworkVirtualAdapterStateItem
{
    [UInt32] $Index
    [String] $Name
    [String] $Label
    [String] $Description
    NewVmNetworkVirtualAdapterStateItem([String]$Name)
    {
        $This.Index = [UInt32][NewVmNetworkVirtualAdapterStateType]::$Name
        $This.Name  = [NewVmNetworkVirtualAdapterStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class NewVmNetworkVirtualAdapterStateList
{
    [Object] $Output
    NewVmNetworkVirtualAdapterStateList()
    {
        $This.Refresh()
    }
    [Object] NewVmNetworkVirtualAdapterStateItem([String]$Name)
    {
        Return [NewVmNetworkVirtualAdapterStateItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([NewVmNetworkVirtualAdapterStateType]))
        {
            $Item             = $This.NewVmNetworkVirtualAdapterStateItem($Name)
            $Item.Label       = @("[X]","[_]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                Active   { "Virtual network adapter is active."   }
                Inactive { "Virtual network adapter is inactive." }
            }

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.VirtualAdapter.State[List]>"
    }
}

Class NewVmNetworkVirtualAdapterExtension
{
    [UInt32]          $Index
    Hidden [Object] $Virtual
    [String]           $Name
    [Object]          $State
    [UInt32]         $MgmtOS
    [String]     $SwitchName
    [String]     $MacAddress
    [String]       $DeviceId
    [String]      $AdapterId
    [String]       $SwitchId
    [String]         $Status
    NewVmNetworkVirtualAdapterExtension([UInt32]$Index,[Object]$Virtual)
    {
        $This.Index      = $Index
        $This.Virtual    = $Virtual
        $This.Name       = $Virtual.Name
        $This.MgmtOs     = $Virtual.IsManagementOs
        $This.SwitchName = $Virtual.SwitchName
        $This.MacAddress = $This.GetMacAddress($Virtual.MacAddress)
        $This.DeviceId   = $Virtual.DeviceId -replace "(\{|\})", "" | % ToLower
        $This.AdapterId  = $Virtual.AdapterId | % ToLower
        $This.SwitchId   = $Virtual.SwitchId.Guid  | % ToLower
        $This.Status     = $Virtual.Status
    }
    [String] GetMacAddress([String]$MacAddress)
    {
        If ($MacAddress -match "(\w|\d){12}")
        {
            Return "{0}{1}:{2}{3}:{4}{5}:{6}{7}:{8}{9}:{10}{11}" -f ([Char[]]$MacAddress.ToLower())[0..11]
        }

        Else
        {
            Return $Null
        }
    }
    SetState([Object]$State)
    {
        $This.State                  = $State
    }
    SetStatus()
    {
        $This.Status                 = "[VmAdapter]: {0} {1}" -f $This.State.Label, $This.Name
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.VirtualAdapter.Extension>"
    }
}

Class NewVmNetworkVirtualAdapterController
{
    [Object] Hidden $State
    [Object]       $Output
    NewVmNetworkVirtualAdapterController()
    {
        $This.State = $This.NewVmNetworkVirtualAdapterStateList()
    }
    [Object] NewVmNetworkVirtualAdapterStateList()
    {
        Return [NewVmNetworkVirtualAdapterStateList]::New()
    }
    [Object] NewVmNetworkVirtualAdapterExtension([UInt32]$Index,[Object]$Config)
    {
        Return [NewVmNetworkVirtualAdapterExtension]::New($Index,$Config)
    }
    [Object[]] GetObject()
    {
        Return Get-VMNetworkAdapter -All
    }
    [Object] New([Object]$Virtual)
    {
        $Item = $This.NewVmNetworkVirtualAdapterExtension($This.Output.Count,$Virtual)

        $Flag = Switch -Regex ($Item.Virtual.Status)
        {
            "^Ok$" 
            {
                "Active"
            }
            Default
            {
                "Inactive"
            }
        }

        $Item.SetState(($This.State.Output | ? Name -eq $Flag))
        $Item.SetStatus()

        Return $Item
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Virtual in $This.GetObject())
        {
            $This.Output += $This.New($Virtual)
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.VirtualAdapter.Controller>"
    }
}


# [Config]
Enum NewVmNetworkConfigStateType
{
    Disconnected
    Up
}

Class NewVmNetworkConfigStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]       $Label
    [String] $Description
    NewVmNetworkConfigStateItem([String]$Name)
    {
        $This.Index = [UInt32][NewVmNetworkConfigStateType]::$Name
        $This.Name  = [NewVmNetworkConfigStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class NewVmNetworkConfigStateList
{
    [Object] $Output
    NewVmNetworkConfigStateList()
    {
        $This.Refresh()
    }
    [Object] NewVmNetworkConfigStateItem([String]$Name)
    {
        Return [NewVmNetworkConfigStateItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([NewVmNetworkConfigStateType]))
        {
            $Item             = $This.NewVmNetworkConfigStateItem($Name)
            $Item.Label       = @("[_]","[+]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                Disconnected { "Configuration is disconnected" }
                Up           { "Configuration is connected"    }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Config.Mode[List]>"
    }
}

Class NewVmNetworkConfigNetwork
{
    [UInt32]        $Index
    [UInt32]         $Type
    [String] $Connectivity
    [String]    $IpAddress
    [String]       $Prefix
    [String[]]    $Gateway
    [UInt32]          $Mtu
    [UInt32]         $Dhcp
    [String[]]        $Dns
    NewVmNetworkConfigNetwork(
    [UInt32]        $Index ,
    [UInt32]         $Type ,
    [String] $Connectivity ,
    [String]    $IpAddress ,
    [UInt32]       $Prefix ,
    [String[]]    $Gateway ,
    [UInt32]          $Mtu ,
    [UInt32]         $Dhcp ,
    [String[]]        $Dns )
    {
        $This.Index        = $Index
        $This.Type         = $Type
        $This.Connectivity = $Connectivity
        $This.IpAddress    = $IpAddress
        $This.Prefix       = $Prefix
        $This.Gateway      = $Gateway
        $This.Mtu          = $Mtu
        $This.Dhcp         = $Dhcp
        $This.Dns          = $Dns
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Config.Network>"
    }
}

Class NewVmNetworkConfigExtension
{
    [UInt32]           $Index
    Hidden [Object]   $Config
    [String]           $Alias
    [UInt32]  $InterfaceIndex
    [String]     $Description
    [Object]           $State
    [String]          $Status
    [String]          $CompID
    [String] $CompDescription
    [String]      $MacAddress
    [String]            $Name
    [String]        $Category
    [String]       $AdapterId
    [Object]         $Network
    NewVmNetworkConfigExtension([UInt32]$Index,[Object]$Config)
    {
        $This.Index           = $Index
        $This.Config          = $Config
        $This.Alias           = $Config.InterfaceAlias
        $This.InterfaceIndex  = $Config.InterfaceIndex
        $This.Description     = $Config.InterfaceDescription
        $This.CompID          = $Config.NetCompartment.CompartmentId
        $This.CompDescription = $Config.NetCompartment.CompartmentDescription
        
        If ($Config.NetAdapter)
        {
            $This.MacAddress  = $Config.NetAdapter.LinkLayerAddress.ToUpper() -replace "-",":"
            $This.Status      = $Config.NetAdapter.Status
        }
        Else
        {
            $This.Status      = $Null
        }

        $This.Name            = $Config.NetProfile.Name
        $This.Category        = $Config.NetProfile.NetworkCategory
        $This.AdapterId       = $Config.NetAdapter.DeviceId -Replace "(\{|\})","" | % ToLower

        $This.Network         = @( )

        $IPV4Connectivity     = $This.GetConnectivity($Config.NetProfile.IPv4Connectivity)
        $IPV6Connectivity     = $This.GetConnectivity($Config.NetProfile.IPv6Connectivity)

        # [IPV4Addresses]
        If ($Config.IPV4Address.Count -gt 1)
        {
            ForEach ($X in 0..($Config.IPV4Address.Count-1))
            {
                $Ip = $This.NewVmNetworkConfigNetwork(
                $This.Network.Count,
                4,
                $IPV4Connectivity,
                $Config.IPV4Address[$X].IPAddress,
                $Config.IPV4Address[$X].PrefixLength,
                $Config.IPv4DefaultGateway[$X].Nexthop,
                $Config.NetIPv4Interface.NlMTU,
                $This.GetDhcp($Config.NetIPv4Interface.DHCP),
                $This.GetDns($Config.DNSServer,2))

                $This.Network += $Ip
            }
        }
        Else
        {
            $Ip = $This.NewVmNetworkConfigNetwork(
            $This.Network.Count,
            4,
            $IPV4Connectivity,
            $Config.IPV4Address.IPAddress,
            $Config.IPV4Address.PrefixLength,
            $Config.IPv4DefaultGateway.Nexthop,
            $Config.NetIPv4Interface.NlMTU,
            $This.GetDhcp($Config.NetIPv4Interface.DHCP),
            $This.GetDns($Config.DNSServer,2))

            $This.Network += $Ip
        }

        # [IPv6 Addresses]
        If ($Config.IPV6Address.Count -gt 1)
        {
            ForEach ($X in 0..($Config.IPV6Address.Count-1))
            {
                $Ip = $This.NewVmNetworkConfigNetwork(
                $This.Network.Count,
                6,
                $IPV6Connectivity,
                $Config.IPV6Address[$X].IPAddress,
                $Config.IPV6Address[$X].PrefixLength,
                $Config.IPv6DefaultGateway[$X].Nexthop,
                $Config.NetIPv6Interface.NlMTU,
                $This.GetDhcp($Config.NetIPv6Interface.DHCP),
                $This.GetDns($Config.DNSServer,23))

                $This.Network += $Ip
            }
        }
        Else
        {
            $Ip = $This.NewVmNetworkConfigNetwork(
            $This.Network.Count,
            6,
            $IPV6Connectivity,
            $Config.IPV6Address.IPAddress,
            $Config.IPV6Address.PrefixLength,
            $Config.IPv6DefaultGateway.Nexthop,
            $Config.NetIPv6Interface.NlMTU,
            $This.GetDhcp($Config.NetIPv6Interface.DHCP),
            $This.GetDns($Config.DNSServer,23))

            $This.Network += $Ip
        }
    }
    [UInt32] GetDhcp([Object]$Dhcp)
    {
        Return $Dhcp -eq "Enabled"
    }
    [String[]] GetDns([Object]$Dns,[UInt32]$Type)
    {
        Return $Dns | ? AddressFamily -eq $Type | % ServerAddresses
    }
    [String] GetConnectivity([Object]$Connectivity)
    {
        Return @($Connectivity,"NoTraffic")[!$Connectivity]
    }
    [Object] NewVmNetworkConfigNetwork(
    [UInt32]        $Index ,
    [UInt32]         $Type ,
    [String] $Connectivity ,
    [String]    $IpAddress ,
    [UInt32]       $Prefix ,
    [String[]]    $Gateway ,
    [UInt32]          $Mtu ,
    [UInt32]         $Dhcp ,
    [String[]]        $Dns )
    {
        Return [NewVmNetworkConfigNetwork]::New($Index,$Type,$Connectivity,$IpAddress,$Prefix,$Gateway,$Mtu,$Dhcp,$Dns)
    }
    SetState([Object]$State)
    {
        $This.State                  = $State
    }
    SetStatus()
    {
        $This.Status                 = "[Config]: {0} {1}" -f $This.State.Label, $This.Alias
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Config.Extension>"
    }
}

Class NewVmNetworkConfigController
{
    Hidden [Object] $State
    [Object]       $Output
    NewVmNetworkConfigController()
    {
        $This.State = $This.NewVmNetworkConfigStateList()
    }
    [Object] NewVmNetworkConfigStateList()
    {
        Return [NewVmNetworkConfigStateList]::New()
    }
    [Object] NewVmNetworkConfigExtension([UInt32]$Index,[Object]$Config)
    {
        Return [NewVmNetworkConfigExtension]::New($Index,$Config)
    }
    [Object[]] GetObject()
    {
        Return Get-NetIPConfiguration -Detailed
    }
    [Object] New([Object]$Config)
    {
        $Item = $This.NewVmNetworkConfigExtension($This.Output.Count,$Config)

        $xState = $This.State.Output[[UInt32]($Item.Config.NetAdapter.Status -eq "Up")]
        $Item.SetState($xState)

        $Item.SetStatus()

        Return $Item
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Config in $This.GetObject())
        {
            $This.Output += $This.New($Config)
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Config.Controller>"
    }
}

# [Switch]
Enum NewVmNetworkSwitchModeType
{
    External
    Internal
    Private
}

Class NewVmNetworkSwitchModeItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]       $Label
    [String] $Description
    NewVmNetworkSwitchModeItem([String]$Name)
    {
        $This.Index = [UInt32][NewVmNetworkSwitchModeType]::$Name
        $This.Name  = [NewVmNetworkSwitchModeType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class NewVmNetworkSwitchModeList
{
    [Object] $Output
    NewVmNetworkSwitchModeList()
    {
        $This.Refresh()
    }
    [Object] NewVmNetworkSwitchModeItem([String]$Name)
    {
        Return [NewVmNetworkSwitchModeItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([NewVmNetworkSwitchModeType]))
        {
            $Item             = $This.NewVmNetworkSwitchModeItem($Name)
            $Item.Label       = @("[E]","[I]","[P]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                External { "Switch is connected to an external network."                   }
                Internal { "Switch is connected internally on the host, but can be seen."  }
                Private  { "Switch is connected internally on the host, and is invisible." }
            }

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Switch.Mode[List]>"
    }
}

Class NewVmNetworkSwitchExtension
{
    [UInt32]         $Index
    Hidden [Object] $Switch
    [String]          $Name
    [String]          $Type
    [Object]         $State
    [String]         $Alias
    [String]   $Description
    [String]          $Guid
    [String]     $AdapterId
    [Object]       $Adapter
    [Object]        $Config
    [String]        $Status
    NewVmNetworkSwitchExtension([UInt32]$Index,[Object]$Switch)
    {
        $This.Index       = $Index
        $This.Switch      = $Switch
        $This.Name        = $Switch.Name
        $This.Type        = $Switch.SwitchType
        $This.Alias       = "vEthernet ({0})" -f $This.Name
        $This.Description = $Switch.NetAdapterInterfaceDescription
        $This.Guid        = $Switch.Id
        $This.AdapterId   = $Switch.NetAdapterInterfaceGuid.Guid
    }
    SetState([Object]$State)
    {
        $This.State       = $State
    }
    SetStatus()
    {
        $This.Status      = "[VmSwitch]: {0} {1}" -f $This.State.Label, $This.Name
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Switch.Extension>"
    }
}

Class NewVmNetworkSwitchController
{
    Hidden [Object] $Mode
    [Object]      $Output
    NewVmNetworkSwitchController()
    {
        $This.Mode = $This.NewVmNetworkSwitchModeList()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] NewVmNetworkSwitchModeList()
    {
        Return [NewVmNetworkSwitchModeList]::New()
    }
    [Object] NewVmNetworkSwitchExtension([UInt32]$Index,[Object]$Switch)
    {
        Return [NewVmNetworkSwitchExtension]::New($Index,$Switch)
    }
    [Object] New([Object]$Switch)
    {
        $Item   = $This.NewVmNetworkSwitchExtension($This.Output.Count,$Switch)

        $xState = $This.Mode.Output | ? Name -eq $Item.Switch.SwitchType
        $Item.SetState($xState)
        
        $Item.SetStatus()

        Return $Item
    }
    [Object[]] GetObject()
    {
        Return Get-VmSwitch
    }
    Refresh()
    {
        $This.Clear()
        
        ForEach ($VmSwitch in $This.GetObject())
        {
            $Item = $This.New($VmSwitch)

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Switch.Controller>"
    }
}

# [Interface]

Enum NewVmNetworkInterfaceStateType
{
    Null
    Local
    Internet
}

Class NewVmNetworkInterfaceStateItem
{
    [UInt32]       $Index
    [String]        $Name
    [String]       $Label
    [String] $Description
    NewVmNetworkInterfaceStateItem([String]$Name)
    {
        $This.Index = [UInt32][NewVmNetworkInterfaceStateType]::$Name
        $This.Name  = [NewVmNetworkInterfaceStateType]::$Name
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class NewVmNetworkInterfaceStateList
{
    [Object] $Output
    NewVmNetworkInterfaceStateList()
    {
        $This.Refresh()
    }
    [Object] NewVmNetworkInterfaceStateItem([String]$Name)
    {
        Return [NewVmNetworkInterfaceStateItem]::New($Name)
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh()
    {
        $This.Clear()

        ForEach ($Name in [System.Enum]::GetNames([NewVmNetworkInterfaceStateType]))
        {
            $Item             = $This.NewVmNetworkInterfaceStateItem($Name)
            $Item.Label       = @("[.]","[+]","[_]")[$Item.Index]
            $Item.Description = Switch ($Item.Name)
            {
                Null     { "Interface is not externally connected"   }
                Local    { "Interface is set for local area network" }
                Internet { "Interface is set to access the internet" }
            }

            $This.Output     += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetworkInterfaceState[List]>"
    }
}

Class NewVmNetworkInterfaceExtension
{
    [UInt32]          $Index
    Hidden [Object]    $Main
    [String]           $Name
    [String]           $Type
    [Object]          $State
    [String]          $Alias
    [String]        $Display
    [String]    $Description
    [String]       $SwitchId
    [String]      $AdapterId
    [Object]        $Adapter
    [Object]         $Config
    [UInt32] $InterfaceIndex
    [String]     $MacAddress
    [Object[]]         $Base
    [Object]          $Range
    [Object]           $Host
    [Object]           $Dhcp
    [UInt32]        $Profile
    [String]         $Status
    NewVmNetworkInterfaceExtension([Object]$Main,[Object]$Switch)
    {
        $This.Index          = $Switch.Index
        $This.Main           = $Main
        $This.Name           = $Switch.Name
        $This.Type           = $Switch.Type
        $This.Alias          = $Switch.Alias
        $This.Description    = $Switch.Description
        $This.SwitchId       = $Switch.Guid

        If ($Switch.AdapterId)
        {
            $This.AdapterId  = $Switch.AdapterId
            $This.Adapter    = $Switch.Adapter
            $This.MacAddress = $Switch.Adapter.MacAddress
        }

        If ($Switch.Config)
        {
            $This.Config         = $Switch.Config
            $This.Display        = $Switch.Config.Description
            $This.InterfaceIndex = $Switch.Config.InterfaceIndex
        }
    }
    [Object] NewVmNetworkBase([Object]$Entry)
    {
        Return [NewVmNetworkBase]::New($This.Main,$Entry)
    }
    AddNetworkBase([Object]$Entry)
    {

    }
    [Object] NewVmNetworkHost([UInt32]$Index,[String]$IpAddress)
    {
        Return [NewVmNetworkHost]::New($Index,$IpAddress)
    }
    [Object] NewVmNetworkHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
    {
        Return [NewVmNetworkHost]::New($Index,$IpAddress,[Object]$Reply)
    }
    [Object] NewVmNetworkHost([Switch]$Flags,[Uint32]$Index,[String]$Line)
    {
        Return [NewVmNetworkHost]::New($False,$Index,$Line)
    }
    [Object] NewVmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Total,[String]$Notation)
    {
        Return [NewVmNetworkRange]::New($Index,$Netmask,$Total,$Notation)
    }
    AddHost([String]$IpAddress)
    {
        $This.Host += $This.NewVmNetworkHost($This.Host.Count,$IpAddress)
    }
    AddHost([String]$IpAddress,[Object]$Reply)
    {
        $This.Host += $This.NewVmNetworkHost($This.Host.Count,$IpAddress,$Reply)
    }
    AddHost([Switch]$Flags,[String]$Line)
    {
        $Item       = $This.NewVmNetworkHost([Switch]$Flags,$This.Host.Count,$Line)
        If ($Item.Class -notin "Multicast","Broadcast")
        {
            $This.Host += $Item
        }
    }
    AddRange([UInt64]$Total,[String]$Notation)
    {
        $This.Range += $This.NewVmNetworkRange($This.Range.Count,$This.Base.Netmask,$Total,$Notation)
    }
    GetNetworkRange()
    {
        $Address       = $This.Base.Trusted.Split(".")
        $xNetmask      = $This.Base.Netmask  -Split "\."
        $xWildCard     = $This.Base.Wildcard -Split "\."
        $Total         = $xWildcard -join "*" | Invoke-Expression

        # Convert wildcard into total host range
        $Hash          = @{ }
        ForEach ($X in 0..3)
        { 
            $Value = Switch ($xWildcard[$X])
            {
                1       
                { 
                    $Address[$X]
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

        # Build host range
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

        Switch ($xRange.Count)
        {
            0
            {
                "Error"
            }
            1
            {
                $This.AddRange($Total,$xRange[0])
            }
            Default
            {
                ForEach ($X in 0..($xRange.Count-1))
                {
                    $This.AddRange($Total,$xRange[$X])
                }
            }
        }

        # Subtract network + broadcast addresses
        ForEach ($Range in $This.Range)
        {
            $Range.Expand()
            If ($This.Base.Trusted -in $Range.Output)
            {
                $This.Base.Network   = $Range.Output[ 0]
                $This.Base.Broadcast = $Range.Output[-1]
                $This.Base.Notation  = $Range.Notation
            }
            Else
            {
                $Range.Output        = @( )
            }
        }
    }
    SetAdapter([Object]$Adapter)
    {
        $This.Adapter     = $Adapter
        $This.MacAddress  = $Adapter.MacAddress -Replace ":",""
    }
    SetPhysical([Object]$Physical)
    {
        $This.Physical    = $Physical
    }
    SetConfig([Object]$Config)
    {
        $This.Config      = $Config
        $This.Alias       = $Config.Alias
        $This.Display     = $Config.Name
        $This.Description = $Config.Description
    }
    SetMode([Object]$Mode)
    {
        $This.Mode        = $Mode
    }
    SetSwitch([Object]$Switch)
    {
        $This.Switch      = $Switch
        $This.Name        = $Switch.Name
    }
    SetBase([Object]$Base)
    {
        $This.Base        = $Base
        $This.GetNetworkRange()
    }
    SetDhcp()
    {
        $This.Dhcp     = $This.VmNetworkDhcp($This.Base,$This.Hosts)
    }
    SetState([Object]$State)
    {
        $This.State          = $State
    }
    SetStatus()
    {
        $This.Status         = "[Interface]: {0} {1}" -f $This.State.Label, $This.Name
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Interface.Extension>"
    }
}

Class NewVmNetworkInterfaceController
{
    Hidden [Object] $State
    [Object]       $Output
    NewVmNetworkInterfaceController()
    {
        $This.State = $This.NewVmNetworkInterfaceStateList()
    }
    [Object] NewVmNetworkInterfaceStateList()
    {
        Return [NewVmNetworkInterfaceStateList]::New()
    }
    [Object] NewVmNetworkInterfaceExtension([Object]$Main,[Object]$Switch)
    {
        Return [NewVmNetworkInterfaceExtension]::New($Main,$Switch)
    }
    [Object] New([Object]$Main,[Object]$Switch)
    {
        $Item = $This.NewVmNetworkInterfaceExtension($Main,$Switch)

        If (!$Switch.Config)
        {
            $Flag = "Null"
        }
        ElseIf ($Switch.Config.Network | ? Type -eq 4 | ? Connectivity -ne Internet)
        {
            $Flag = "Local"
        }
        Else
        {
            $Flag = "Internet"
        }

        $Item.SetState(($This.State.Output | ? Name -eq $Flag))
        $Item.SetStatus()

        Return $Item
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh([Object]$Main,[Object[]]$SwitchList)
    {
        $This.Clear()

        ForEach ($Switch in $SwitchList)
        {
            $This.Output += $This.New($Main,$Switch)
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Interface.Controller>"
    }
}

# [Controller]
Class NewVmNetworkController
{
    [Object] $Main
    [Object] $Adapter
    [Object] $Virtual
    [Object] $Config
    [Object] $Switch
    [Object] $Interface
    NewVmNetworkController()
    {
        $This.Adapter   = $This.NewVmNetworkAdapterController()
        $This.Virtual   = $This.NewVmNetworkVirtualAdapterController()
        $This.Config    = $This.NewVmNetworkConfigController()
        $This.Switch    = $This.NewVmNetworkSwitchController()
        $This.Interface = $This.NewVmNetworkInterfaceController()
    }
    [Object] NewVmNetworkMain([String]$Domain,[String]$NetBios)
    {
        Return [NewVmNetworkMain]::New($Domain,$NetBios)
    }
    [Object] NewVmNetworkAdapterController()
    {
        Return [NewVmNetworkAdapterController]::New()
    }
    [Object] NewVmNetworkVirtualAdapterController()
    {
        Return [NewVmNetworkVirtualAdapterController]::New()
    }
    [Object] NewVmNetworkConfigController()
    {
        Return [NewVmNetworkConfigController]::New()
    }
    [Object] NewVmNetworkSwitchController()
    {
        Return [NewVmNetworkSwitchController]::New()
    }
    [Object] NewVmNetworkInterfaceController()
    {
        Return [NewVmNetworkInterfaceController]::New()
    }
    SetMain([String]$Domain,[String]$Netbios)
    {
        $This.Main = $This.NewVmNetworkMain($Domain,$Netbios)
    }
    Refresh()
    {
        [Console]::WriteLine("Refreshing [~] Network adapter(s)")
        $This.Adapter.Refresh()

        [Console]::WriteLine("Refreshing [~] VM adapter(s)")
        $This.Virtual.Refresh()

        [Console]::WriteLine("Refreshing [~] IP configuration(s)")
        $This.Config.Refresh()

        [Console]::WriteLine("Refreshing [~] Virtual switch(es)")
        $This.Switch.Refresh()

        # [Set adapter(s) + config(s) to -> switch(es)]
        ForEach ($Item in $This.Switch.Output)
        {
            $Item.Adapter = $This.Adapter.Output | ? Guid      -eq $Item.AdapterId
            If ($Item.Adapter)
            {
                $Item.Adapter.Assigned = 1
            }
            
            $Item.Config  = $This.Config.Output  | ? MacAddress -eq $Item.Adapter.MacAddress
        }

        [Console]::WriteLine("Refreshing [~] (Adapter + Config + Switch) Interface(s)")
        $This.Interface.Refresh($This.Main,$This.Switch.Output)
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmNetwork.Controller>"
    }
}

$Main = [NewVmNetworkController]::New()
$Main.SetMain("securedigitsplus.com","secured")
$Main.Refresh()

# [Working with selected]
$Entry = $Main.Interface.Output[0]
ForEach ($Item in $Entry.Config.Network | ? Type -eq 4 | ? Connectivity -eq Internet)
{
    $Entry.Base += $Entry.NewVmNetworkBase($Item)

    <# todo
    - integrate [range] and [hosts] into the $base (property/class), elim from interface
    - create another handler for IPV6
    #>
}

<#
[Object] NewVmNetworkBase([Object]$Entry)
{
    Return [NewVmNetworkBase]::New($This.Main,$Entry)
}
AddNetworkBase([Object]$Entry)
{

}
#>
