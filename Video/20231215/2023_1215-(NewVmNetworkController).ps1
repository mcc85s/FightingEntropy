Class NewVmControllerProperty
{
    [String]  $Name
    [Object] $Value
    NewVmControllerProperty([Object]$Property)
    {
        $This.Name  = $Property.Name
        $This.Value = $Property.Value -join ", "
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmController[Property]>"
    }
}

Class NewVmMain
{
    [String]  $Domain
    [String] $NetBios
    NewVmMain([String]$Domain,[String]$NetBios)
    {
        $This.Domain  = $Domain.ToLower()
        $This.NetBios = $NetBios.ToUpper()
    }
    [String] ToString()
    {
        Return "<FEVirtual.NewVmMain>"
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
        $This.Domain    = $Main.Domain
        $This.NetBios   = $Main.NetBios

        $This.Trusted   = $Entry.IPAddress
        $This.Prefix    = $Entry.Config.IPV4Prefix

        # Binary
        $This.GetConversion()

        $This.Gateway   = $Entry.IPV4DefaultGateway
        $This.Dns       = $Entry.IPv4DnsServer
    }
    GetConversion()
    {
        # Convert IP and PrefixLength into binary, netmask, and wildcard
        $xBinary       = 0..3 | % { (($_*8)..(($_*8)+7) | % { @(0,1)[$_ -lt $This.Prefix] }) -join '' }
        $This.Netmask  = ($xBinary | % { [Convert]::ToInt32($_,2 ) }) -join "."
        $This.Wildcard = ($This.Netmask.Split(".") | % { (256-$_) }) -join "."
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetwork[Base]>"
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
        Return "<FEVirtual.NewVmNetwork[Range]>"
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
        Return "<FEVirtual.NewVmNetwork[Host]>"
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
        Return "<FEVirtual.NewVmNetwork[Dhcp]>"
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
        Return "<FEVirtual.NewVmNetworkAdapterState[List]>"
    }
}

Class NewVmNetworkAdapterExtension
{
    [UInt32]          $Index
    Hidden [Object] $Adapter
    [String]           $Name
    [Object]          $State
    [String]           $Guid
    [String]     $MacAddress
    [String]    $Description
    [String]         $Status
    NewVmNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
    {
        $This.Index          = $Index
        $This.Adapter        = $Adapter
        $This.Name           = $Adapter.Name

        If ($Adapter.Guid)
        {
            $This.Guid        = $Adapter.Guid.ToLower() -Replace "(\{|\})",""
        }

        $This.MacAddress      = $Adapter.MacAddress.ToUpper()
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
        Return "<FEVirtual.NewVmNetworkAdapter[Extension]>"
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
        Return Get-CimInstance Win32_NetworkAdapter | ? PnPDeviceId -match "(USB\\VID|PCI\\VEN)"
    }
    [Object] New([Object]$Adapter)
    {
        $Item   = $This.NewVmNetworkAdapterExtension($This.Output.Count,$Adapter)
        
        $xState = $This.State.Output[[UInt32]$Item.Adapter.NetEnabled]

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

        ForEach ($Adapter in $This.GetObject())
        {
            $Item = $This.New($Adapter)

            $This.Output += $Item
        }
    }
    [String] ToString()
    {
        Return "<FEVirtual.VmNetworkAdapter[Controller]>"
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
        Return "<FEVirtual.NewVmNetworkConfigMode[List]>"
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
        Return "<FEVirtual.NewVmNetworkConfig[Network]>"
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
        Return "<FEVirtual.NewVmNetworkConfig[Extension]>"
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
        Return "<FEVirtual.NewVmNetworkConfig[Controller]>"
    }
}

# [Switch]
Enum NewVmNetworkSwitchModeType
{
    Internal
    External
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
        Return "<FEVirtual.NewVmNetworkSwitchMode[List]>"
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
    [String]      $SwitchId
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
        $This.SwitchId    = $Switch.Id
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
        Return "<FEVirtual.NewVmNetworkSwitch[Extension]>"
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
        Return "<FEVirtual.NewVmNetworkSwitch[Controller]>"
    }
}

# [Controller]
Class NewVmNetworkController
{
    [Object] $Main
    [Object] $Adapter
    [Object] $Config
    [Object] $Switch
    [Object] $Output
    NewVmNetworkController()
    {
        $This.Adapter = $This.NewVmNetworkAdapterController()
        $This.Config  = $This.NewVmNetworkConfigController()
        $This.Switch  = $This.NewVmNetworkSwitchController()
    }
    [Object] NewVmMain([String]$Domain,[String]$NetBios)
    {
        Return [NewVmMain]::New($Domain,$NetBios)
    }
    [Object] NewVmNetworkAdapterController()
    {
        Return [NewVmNetworkAdapterController]::New()
    }
    [Object] NewVmNetworkConfigController()
    {
        Return [NewVmNetworkConfigController]::New()
    }
    [Object] NewVmNetworkSwitchController()
    {
        Return [NewVmNetworkSwitchController]::New()
    }
    SetMain([String]$Domain,[String]$Netbios)
    {
        $This.Main = $This.NewVmMain($Domain,$NetBios)
    }
    Refresh()
    {
        $This.Adapter.Refresh()
        $This.Config.Refresh()
        $This.Switch.Refresh()

        # [Set adapter(s) + config(s) to -> switch(es)]
        ForEach ($Item in $This.Switch.Output)
        {
            $Item.Adapter = $This.Adapter.Output | ? Guid -eq $Item.AdapterId
            $Item.Config  = $This.Config.Output  | ? MacAddress -eq $Item.Adapter.MacAddress
        }
    }
    [String] ToString()
    {
        Return "<NewVmNetwork[Controller]>"
    }
}

$Main = [NewVmNetworkController]::New()
$Main.SetMain("securedigitsplus.com","secured")
$Main.Refresh()
