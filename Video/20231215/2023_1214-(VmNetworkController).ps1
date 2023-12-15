<# 
    Getting some inconsistencies when running New-VmController in relation to the networking functions.
    Would like the function to allow (creation/deletion) of virtual switches, as well as in the GUI...
    So, refactoring some of this should allow me to do that, as well as fix what's going on in Get-FENetwork
#>
    
    # [Network/Switch interface controller types]
    Class VmControllerProperty
    {
        [String]  $Name
        [Object] $Value
        VmControllerProperty([Object]$Property)
        {
            $This.Name  = $Property.Name
            $This.Value = $Property.Value -join ", "
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmController[Property]>"
        }
    }

    Enum VmNetworkAdapterStateType
    {
        Disconnected
        Connected
    }

    Class VmNetworkAdapterStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        VmNetworkAdapterStateItem([String]$Name)
        {
            $This.Index = [UInt32][VmNetworkAdapterStateType]::$Name
            $This.Name  = [VmNetworkAdapterStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class VmNetworkAdapterStateList
    {
        [Object] $Output
        VmNetworkAdapterStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VmNetworkAdapterStateItem([String]$Name)
        {
            Return [VmNetworkAdapterStateItem]::New($Name)
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([VmNetworkAdapterStateType]))
            {
                $Item             = $This.VmNetworkAdapterStateItem($Name)
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
            Return "<FEVirtual.VmNetworkAdapterState[List]>"
        }
    }

    Class VmNetworkAdapterItem
    {
        Hidden [UInt32]   $Index
        Hidden [Object] $Adapter
        [UInt32]           $Rank
        [String]           $Name
        [String]    $Description
        [Object]          $State
        [String]     $MacAddress
        [UInt32]       $Physical
        [String]         $Status
        VmNetworkAdapterItem([UInt32]$Index,[Object]$Adapter)
        {
            $This.Index       = $Index
            $This.Adapter     = $Adapter
            $This.Rank        = $Adapter.InterfaceIndex
            $This.Name        = $Adapter.Name
            $This.Description = $Adapter.InterfaceDescription
            $This.MacAddress  = $Adapter.MacAddress
            $This.Physical    = $Adapter.PnPDeviceId -match "(USB\\VID|PCI\\VEN)"
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
            Return "<FEVirtual.VmNetworkAdapter[Item]>"
        }    
    }

    Class VmNetworkAdapterController
    {
        Hidden [Object] $State
        [Object]       $Output
        VmNetworkAdapterController()
        {
            $This.State = $This.VmNetworkAdapterStateList()
        }
        [Object] VmNetworkAdapterStateList()
        {
            Return [VmNetworkAdapterStateList]::New()
        }
        [Object] VmNetworkAdapterItem([UInt32]$Index,[Object]$Adapter)
        {
            Return [VmNetworkAdapterItem]::New($Index,$Adapter)
        }
        [Object[]] GetObject()
        {
            Return Get-CimInstance Win32_NetworkAdapter | Sort-Object InterfaceIndex
        }
        [Object] New([Object]$Adapter)
        {
            $Item   = $This.VmNetworkAdapterItem($This.Output.Count,$Adapter)
            
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

    Enum VmNetworkConfigStateType
    {
        Disconnected
        Up
    }

    Class VmNetworkConfigStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        VmNetworkConfigStateItem([String]$Name)
        {
            $This.Index = [UInt32][VmNetworkConfigStateType]::$Name
            $This.Name  = [VmNetworkConfigStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class VmNetworkConfigStateList
    {
        [Object] $Output
        VmNetworkConfigStateList()
        {
            $This.Refresh()
        }
        [Object] VmNetworkConfigStateItem([String]$Name)
        {
            Return [VmNetworkConfigStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([VmNetworkConfigStateType]))
            {
                $Item             = $This.VmNetworkConfigStateItem($Name)
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
            Return "<FEVirtual.VmNetworkConfigMode[List]>"
        }
    }

    Class VmNetworkConfigItem
    {
        Hidden [UInt32]         $Index
        Hidden [Object]        $Config
        [String]                $Alias
        [UInt32]       $InterfaceIndex
        [String]          $Description
        [Object]                $State
        [String]               $CompID
        [String]      $CompDescription
        [String]           $MacAddress
        [String]                 $Name
        [String]             $Category
        [String]     $IPv4Connectivity
        [String]          $IPv4Address
        [String]           $IPv4Prefix
        [String]   $IPv4DefaultGateway
        [String]     $IPv4InterfaceMtu
        [String]    $IPv4InterfaceDhcp
        [String[]]      $IPv4DnsServer
        [String]     $IPv6Connectivity
        [String] $IPv6LinkLocalAddress
        [String]   $IPv6DefaultGateway
        [String]     $IPv6InterfaceMtu
        [String]    $IPv6InterfaceDhcp
        [String[]]      $IPv6DnsServer
        [String]               $Status
        VmNetworkConfigItem([UInt32]$Index,[Object]$Config)
        {
            $This.Index                  = $Index
            $This.Config                 = $Config
            $This.Alias                  = $Config.InterfaceAlias
            $This.InterfaceIndex         = $Config.InterfaceIndex
            $This.Description            = $Config.InterfaceDescription
            $This.CompID                 = $Config.NetCompartment.CompartmentId
            $This.CompDescription        = $Config.NetCompartment.CompartmentDescription
            $This.MacAddress             = $Config.NetAdapter.LinkLayerAddress
            $This.Status                 = $Config.NetAdapter.Status
            $This.Name                   = $Config.NetProfile.Name
            $This.Category               = $Config.NetProfile.NetworkCategory
            $This.IPv4Connectivity       = $Config.NetProfile.IPv4Connectivity
            $This.IPv4Address            = $Config.IPv4Address.IpAddress
            $This.IPv4Prefix             = $Config.IPv4Address.PrefixLength
            $This.IPv4DefaultGateway     = $Config.IPv4DefaultGateway.NextHop
            $This.IPv4InterfaceMtu       = $Config.NetIPv4Interface.NlMTU
            $This.IPv4InterfaceDhcp      = $Config.NetIPv4Interface.DHCP
            $This.IPv4DnsServer          = $Config.DNSServer | ? AddressFamily -eq 2 | % ServerAddresses
            $This.IPv6Connectivity       = $Config.NetProfile.IPv6Connectivity
            $This.IPv6DefaultGateway     = $Config.IPv6DefaultGateway.NextHop
            $This.IPv6LinkLocalAddress   = $Config.IPv6LinkLocalAddress
            $This.IPv6InterfaceMtu       = $Config.NetIPv6Interface.NlMTU
            $This.IPv6InterfaceDhcp      = $Config.NetIPv6Interface.DHCP
            $This.IPv6DnsServer          = $Config.DNSServer | ? AddressFamily -eq 23 | % ServerAddresses
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
            Return "<FEVirtual.VmNetworkConfig[Item]>"
        }
    }

    Class VmNetworkConfigController
    {
        Hidden [Object] $State
        [Object]       $Output
        VmNetworkConfigController()
        {
            $This.State = $This.VmNetworkConfigStateList()
        }
        [Object] VmNetworkConfigStateList()
        {
            Return [VmNetworkConfigStateList]::New()
        }
        [Object] VmNetworkConfigItem([UInt32]$Index,[Object]$Config)
        {
            Return [VmNetworkConfigItem]::New($Index,$Config)
        }
        [Object[]] GetObject()
        {
            Return Get-NetIPConfiguration -Detailed
        }
        [Object] New([Object]$Config)
        {
            $Item = $This.VmNetworkConfigItem($This.Output.Count,$Config)

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
            Return "<FEVirtual.VmNetworkConfig[Controller]>"
        }
    }

    Enum VmNetworkSwitchModeType
    {
        Internal
        External
        Private
    }

    Class VmNetworkSwitchModeItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        VmNetworkSwitchModeItem([String]$Name)
        {
            $This.Index = [UInt32][VmNetworkSwitchModeType]::$Name
            $This.Name  = [VmNetworkSwitchModeType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class VmNetworkSwitchModeList
    {
        [Object] $Output
        VmNetworkSwitchModeList()
        {
            $This.Refresh()
        }
        [Object] VmNetworkSwitchModeItem([String]$Name)
        {
            Return [VmNetworkSwitchModeItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([VmNetworkSwitchModeType]))
            {
                $Item             = $This.VmNetworkSwitchModeItem($Name)
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
            Return "<FEVirtual.VmNetworkSwitchMode[List]>"
        }
    }

    Class VmNetworkSwitchItem
    {
        [UInt32]         $Index
        Hidden [Object] $Switch
        [String]          $Name
        [Object]         $State
        [String]         $Alias
        [String]   $Description
        [String]        $Status
        VmNetworkSwitchItem([UInt32]$Index,[Object]$Switch)
        {
            $This.Index       = $Index
            $This.Switch      = $Switch
            $This.Name        = $Switch.Name
            $This.Alias       = "vEthernet ({0})" -f $This.Name
            $This.Description = $Switch.NetAdapterInterfaceDescription
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
            Return "<FEVirtual.VmNetworkSwitch[Item]>"
        }
    }

    Class VmNetworkSwitchController
    {
        Hidden [Object] $Mode
        [Object]      $Output
        VmNetworkSwitchController()
        {
            $This.Mode = $This.VmNetworkSwitchModeList()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] VmNetworkSwitchModeList()
        {
            Return [VmNetworkSwitchModeList]::New()
        }
        [Object] VmNetworkSwitchItem([UInt32]$Index,[Object]$Switch)
        {
            Return [VmNetworkSwitchItem]::New($Index,$Switch)
        }
        [Object] New([Object]$Switch)
        {
            $Item   = $This.VmNetworkSwitchItem($This.Output.Count,$Switch)

            $xState = $This.Mode.Output | ? Name -eq $Item.Switch.SwitchType
            $Item.SetState($xState)
            
            $Item.SetStatus()

            Return $Item
        }
        [Object[]] GetObject()
        {
            Return Get-VmSwitch | Sort-Object 
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
            Return "<FEVirtual.VmNetworkSwitch[Controller]>"
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
            Return "<FEVirtual.VmMain>"
        }
    }

    Class VmNetworkBase
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
        VmNetworkBase([Object]$Main,[Object]$Entry)
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

    Class VmNetworkRange
    {
        [UInt32]     $Index
        [String]     $Total
        [String]   $Netmask
        [String]  $Notation
        [Object]    $Output
        VmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Total,[String]$Notation)
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
            Return "<FEVirtual.VmNetwork[Range]>"
        }
    }

    Class VmNetworkHost
    {
        [UInt32]         $Index
        [UInt32]        $Status
        [String]        $Source
        [String]          $Type = "Host"
        [String]         $Class
        [String]     $IpAddress
        [String]    $MacAddress
        [String]      $Hostname
        VmNetworkHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = [UInt32]($Reply.Result.Status -match "Success")
            $This.Source         = "Sweep"
            $This.IpAddress      = $IpAddress
            $This.GetClass()
        }
        VmNetworkHost([UInt32]$Index,[String]$IpAddress)
        {
            $This.Index          = $Index
            $This.Status         = 0
            $This.Source         = "Sweep"
            $This.IpAddress      = $IpAddress
            $This.GetClass()
        }
        VmNetworkHost([Switch]$Flags,[Uint32]$Index,[String]$Line)
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
            Return "<FEVirtual.VmNetwork[Host]>"
        }
    }

    Class VmNetworkDhcp
    {
        [String]        $Name
        [String]  $SubnetMask
        [String]     $Network
        [String]  $StartRange
        [String]    $EndRange
        [String]   $Broadcast
        [String[]] $Exclusion
        VmNetworkDhcp([Object]$Base,[Object]$Hosts)
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
            Return "<FEVirtual.VmNetwork[Dhcp]>"
        }
    }

    Enum VmNetworkInterfaceModeType
    {
        LocalNetwork
        Internet
        Null
    }

    Class VmNetworkInterfaceModeItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        VmNetworkInterfaceModeItem([String]$Name)
        {
            $This.Index = [UInt32][VmNetworkInterfaceModeType]::$Name
            $This.Name  = [VmNetworkInterfaceModeType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class VmNetworkInterfaceModeList
    {
        [Object] $Output
        VmNetworkInterfaceModeList()
        {
            $This.Refresh()
        }
        [Object] VmNetworkInterfaceModeItem([String]$Name)
        {
            Return [VmNetworkInterfaceModeItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([VmNetworkInterfaceModeType]))
            {
                $Item             = $This.VmNetworkInterfaceModeItem($Name)
                $Item.Label       = @("[.]","[+]","[_]")[$Item.Index]
                $Item.Description = Switch ($Item.Name)
                {
                    LocalNetwork { "Interface is set for local area network" }
                    Internet     { "Interface is set to access the internet" }
                    Null         { "Interface is not externally connected"   }
                }

                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetworkConfigMode[List]>"
        }
    }

    Class VmNetworkInterfaceItem
    {
        [UInt32]          $Index
        [Object]           $Mode
        [String]           $Name
        [String]          $Alias
        [String]        $Display
        [String]      $IpAddress
        [UInt32] $InterfaceIndex
        [String]    $Description
        [String]     $MacAddress
        [Object]        $Adapter
        [Object]       $Physical
        [Object]         $Config
        [Object]         $Switch
        [Object]           $Base
        [Object]          $Range
        [Object]           $Host
        [Object]           $Dhcp
        [UInt32]        $Profile
        VmNetworkInterfaceItem([UInt32]$Index,[String]$Line)
        {
            # Arp discovery mode
            $This.Index          = $Index
            $This.IpAddress      = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.InterfaceIndex = [Regex]::Matches($Line,"0x([0-9a-f]){2}").Value | Invoke-Expression

            $This.Clear()
        }
        VmNetworkInterfaceItem([Switch]$Flags,[UInt32]$Index,[Object]$Switch)
        {
            # Blank switch mode
            $This.Index          = $Index
            $This.SetSwitch($Switch)

            $This.Clear()
        }
        Clear()
        {
            $This.Range          = @( )
            $This.Host           = @( )
        }
        [Object] VmNetworkHost([UInt32]$Index,[String]$IpAddress)
        {
            Return [VmNetworkHost]::New($Index,$IpAddress)
        }
        [Object] VmNetworkHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
        {
            Return [VmNetworkHost]::New($Index,$IpAddress,[Object]$Reply)
        }
        [Object] VmNetworkHost([Switch]$Flags,[Uint32]$Index,[String]$Line)
        {
            Return [VmNetworkHost]::New($False,$Index,$Line)
        }
        [Object] VmNetworkRange([UInt32]$Index,[String]$Netmask,[UInt32]$Total,[String]$Notation)
        {
            Return [VmNetworkRange]::New($Index,$Netmask,$Total,$Notation)
        }
        AddHost([String]$IpAddress)
        {
            $This.Host += $This.VmNetworkHost($This.Host.Count,$IpAddress)
        }
        AddHost([String]$IpAddress,[Object]$Reply)
        {
            $This.Host += $This.VmNetworkHost($This.Host.Count,$IpAddress,$Reply)
        }
        AddHost([Switch]$Flags,[String]$Line)
        {
            $Item       = $This.VmNetworkHost([Switch]$Flags,$This.Host.Count,$Line)
            If ($Item.Class -notin "Multicast","Broadcast")
            {
                $This.Host += $Item
            }
        }
        AddRange([UInt64]$Total,[String]$Notation)
        {
            $This.Range += $This.VmNetworkRange($This.Range.Count,$This.Base.Netmask,$Total,$Notation)
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
        [String] ToString()
        {
            Return "<FEVirtual.VmNetworkConfig[Entry]>"
        }
    }

    Class VmNetworkController
    {
        Hidden [Object] $Mode
        [Object]        $Main
        [Object]     $Adapter
        [Object]      $Config
        [Object]      $Switch
        [Object]      $Output
        VmNetworkController()
        {
            $This.Mode     = $This.VmNetworkInterfaceModeList()
            $This.Adapter  = $This.VmNetworkAdapterController()
            $This.Config   = $This.VmNetworkConfigController()
            $This.Switch   = $This.VmNetworkSwitchController()
            $This.Clear()
        }
        [Object] VmMain([String]$Domain,[String]$NetBios)
        {
            Return [VmMain]::New($Domain,$NetBios)
        }
        [Object] VmBase([Object]$Main,[Object]$Entry)
        {
            Return [VmNetworkBase]::New($Main,$Entry)
        }
        [Object] VmNetworkInterfaceModeList()
        {
            Return [VmNetworkInterfaceModeList]::New()
        }
        [Object] VmNetworkAdapterController()
        {
            Return [VmNetworkAdapterController]::New()
        }
        [Object] VmNetworkConfigController()
        {
            Return [VmNetworkConfigController]::New()
        }
        [Object] VmNetworkSwitchController()
        {
            Return [VmNetworkSwitchController]::New()
        }
        [Object] VmNetworkInterfaceItem([UInt32]$Index,[String]$Line)
        {
            Return [VmNetworkInterfaceItem]::New($Index,$Line)
        }
        [Object] VmNetworkInterfaceItem([Switch]$Flags,[UInt32]$Index,[Object]$Switch)
        {
            Return [VmNetworkInterfaceItem]::New([Switch]$Flags,$Index,$Switch)
        }
        [Object] VmControllerProperty([Object]$Property)
        {
            Return [VmControllerProperty]::New($Property)
        }
        [Object[]] Physical()
        {
            Return $This.Adapter.Output | ? Physical
        }
        [Object] New([String]$Line)
        { 
            Return $This.VmNetworkInterfaceItem($This.Output.Count,$Line)
        }
        [Object] New([Switch]$Flags,[Object]$VmSwitch)
        {
            Return $This.VmNetworkInterfaceItem([Switch]$Flags,$This.Output.Count,$VmSwitch)
        }
        Rerank()
        {
            $X = 0
            Do
            {
                $This.Output[$X].Index = $X
                $X ++
            }
            Until ($X -eq $This.Output.Count)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            $This.Adapter.Refresh()
            $This.Config.Refresh()
            $This.Switch.Refresh()

            # [Switches found using arp -a]
            ForEach ($Line in (arp -a))
            {
                Switch -Regex ($Line)
                {
                    {$_ -match "^Interface\:"}
                    {
                        $Item         = $This.New($Line)
                        
                        # [Set adapter]
                        $xAdapter     = $This.Adapter.Output | ? Rank -eq $Item.InterfaceIndex
                        $Item.SetAdapter($xAdapter)
                        
                        # [Set config]
                        $xConfig      = $This.Config.Output | ? InterfaceIndex -eq $Item.InterfaceIndex
                        $Item.SetConfig($xConfig)

                        # [Set mode based on IPv4 connectivity (for now)]
                        $Value        = $xConfig.IPv4Connectivity
                        If ($Value -eq "")
                        {
                            $Value    = "Null"
                        }
                        $Item.Mode    = $This.Mode.Output | ? Name -eq $Value

                        # [Set switch]
                        $xSwitch      = $This.Switch.Output | ? Alias -eq $Item.Alias
                        $Item.SetSwitch($xSwitch)

                        # [Set physical]
                        $xPhysical    = $This.Adapter.Output | ? Name -eq $Item.Switch.Description
                        $Item.SetPhysical($xPhysical)

                        # [Set base]
                        $xBase        = $This.VmBase($This.Main,$Item)
                        If ($xBase.Prefix -ne 0)
                        {
                            $Item.SetBase($xBase)
                        }

                        $This.Output += $Item
                    }
                    {$_ -match "^\s+(\d+\.){3}\d+"}
                    {
                        $This.Output[-1].AddHost([Switch]$False,$Line)
                    }
                    Default
                    {

                    }
                }
            }

            # [Switches not found using arp -a]
            ForEach ($VmSwitch in $This.Switch.Output | ? Name -notin $This.Output.Name)
            {
                $Item         = $This.New([Switch]$False,$VmSwitch)

                $This.Output += $Item
            }
        }
        [Object[]] Property([Object]$Object)
        {
            $List = @( )

            ForEach ($Property in $Object.PSObject.Properties | ? Name -notmatch ^PS)
            {
                $List += $This.VmControllerProperty($Property)
            }

            Return $List
        }
        SwitchConfig([Object]$Control,[Object]$Property,[Object]$Object)
        {
            $List     = $Object
            $Property = $Property.SelectedItem.Content.Replace(" ","")
            If ($Property -ne "*")
            {
                $List = $List | ? { $_.Mode.Name -match $Property }
            }

            $This.Reset($Control,$List)
        }
        [String] Escape([String]$String)
        {
            Return [Regex]::Escape($String)
        }
        SetMain([String]$Domain,[String]$NetBios)
        {
            $This.Main = $This.VmMain($Domain,$NetBios)
        }
        [String] ToString()
        {
            Return "<FEVirtual.VmNetwork[Controller]>"
        }
    }

    # Reference variables
    $Network = [VmNetworkController]::New()

    # [Refresh] <- Hitting the refresh button in the GUI has to run all of this stuff
    $Network.Clear()

    $Network.Adapter.Refresh()
    $Network.Config.Refresh()
    $Network.Switch.Refresh()
 
    $VmSwitch = Get-VMSwitch

    # [Switches not found using arp -a]
    $Network.Switch.Output | ? Name -notin $Network.Output.Name | % {

        $Item            = $Network.New([Switch]$False,$_)
        
        $Network.Output += $Item
    }

    $Ctrl = New-VmController # <- does NOT initiate the GUI
    $Ctrl.Network.SetMain("securedigitsplus.com","secured")
    $Ctrl.Network.Refresh()

# [Starting over slightly]

Class VmNetworkAdapterExtension
{
    [UInt32] $Index
    [String] $Name
    [String] $Guid
    [String] $MacAddress
    [String] $Description
    VmNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
    {
        $This.Index          = $Index
        $This.Name           = $Adapter.Name

        If ($Adapter.Guid)
        {
            $This.Guid        = $Adapter.Guid.ToLower() -Replace "(\{|\})",""
        }

        $This.MacAddress      = $Adapter.MacAddress.ToUpper()
        $This.Description     = $Adapter.Description
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class VmNetworkConfigExtension
{
    [UInt32] $Index
    Hidden [Object] $Config
    [String] $Alias
    [UInt32] $InterfaceIndex
    [String] $Description
    [String] $Status
    [String] $CompID
    [String] $CompDescription
    [String] $MacAddress
    [String] $Name
    [String] $Category
    VmNetworkConfigExtension([UInt32]$Index,[Object]$Config)
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
    }
    [String] ToString()
    {
        Return $This.Alias
    }
}

Class VmNetworkSwitchExtension
{
    [UInt32] $Index
    Hidden [Object] $Switch
    [Object] $Mode
    [String] $Name
    [String] $Type
    [String] $SwitchId
    [String] $AdapterId
    [Object] $Adapter
    [Object] $Config
    VmNetworkSwitchExtension([UInt32]$Index,[Object]$Switch)
    {
        $This.Index      = $Index
        $This.Switch     = $Switch
        $This.Name       = $Switch.Name
        $This.Type       = $Switch.SwitchType
        $This.SwitchId   = $Switch.Id
        $This.AdapterId  = $Switch.NetAdapterInterfaceGuid.Guid
    }
}

# [Adapter]
$Adapter     = Get-CimInstance Win32_NetworkAdapter | ? PnPDeviceId -match "(USB\\VID|PCI\\VEN)"
$AdapterList = @( )

ForEach ($Item in $Adapter)
{
    $AdapterList += [VmNetworkAdapterExtension]::New($AdapterList.Count,$Item)
}

# [Config]
$Config     = Get-NetIPConfiguration -Detailed 
$ConfigList = @( )
ForEach ($Item in $Config)
{
    $ConfigList += [VmNetworkConfigExtension]::New($ConfigList.Count,$Item)
}

# [Switch]
$Switch     = Get-VmSwitch
$SwitchList = @( )

ForEach ($Item in $Switch)
{
    $Item         = [VmNetworkSwitchExtension]::New($SwitchList.Count,$Item)
    $Item.Adapter = $AdapterList | ? Guid -eq $Item.AdapterId
    $Item.Config  = $ConfigList  | ? MacAddress -eq $Item.Adapter.MacAddress

    $SwitchList  += $Item
}


# [Time to add the enum and controller list objects for each of those properties]

<#
    Basically, each configuration will either have a working network configuration that
    can access network resources, or not.
#>

$Main.Switch | FT

<#
    Index Mode Name           Type     SwitchId                             AdapterId                            Adapter
    ----- ---- ----           ----     --------                             ---------                            -------
        0      External       External 0bd8956b-23c1-4b88-ab6b-32cd59bead92 593f7f7c-2698-4b57-93bb-26baabdc161a SAMSUNG Mobile USB Remote NDIS... 
        1      Default Switch Internal c08cb7b8-9b3c-408e-8e30-5e16a3aeb444

    In this list here, the switch ID is a guid for the VmSwitch.
    The AdapterId is the GUID for the particular adapter.
    The adapter itself, will have a configuration.

    In this configuration information, I can see the InterfaceAlias, InterfaceIndex, Description, Status, MacAddress,
    and basic stuff that comes up with Get-NetIPConfiguration -Detailed

    However, it is NOT that particular object that is returning, it is a customized class that is formatting the data
    in a way where I can construct the classes.

    The class that I just assembled, is the process of converting a script with various types and classes,
    into a single cohesive object that works with properties, rather than a script working with variables.

    Variables and properties are basically the same thing, the main difference between them is the scope
    in which they can be called from.
#>

$Ctrl

<#
    Module     : <FightingEntropy.Module.Controller>
    Xaml       : <FEModule.XamlWindow[VmControllerXaml]>
    Network    : <FEVirtual.VmNetwork[Controller]>
    Credential : <FEVirtual.VmCredential[Controller]>
    Image      : <FEModule.Image[Controller]>
    Template   : <FEVirtual.VmTemplate[Controller]>
    Node       : <FEVirtual.VmNode[Controller]>
    Validate   : <FEVirtual.VmValidation[Controller]>
    Flag       : {NetworkDomain, NetworkNetBios, NetworkSwitchName, CredentialUsername...}

    A lot of this is basically more complex objects that allow New-VmController to automatically allocate information
    pertaining to the networking, validation of input, and creation of file system objects that can instantiate
    a virtual machine with all of its' independent files like the vmx, vmdk, and etc.
#>

$Ctrl.Network

<#
    Main    : <FEVirtual.VmMain>
    Adapter : <FEVirtual.VmNetworkAdapter[Controller]>
    Config  : <FEVirtual.VmNetworkConfig[Controller]>
    Switch  : <FEVirtual.VmNetworkSwitch[Controller]>
    Output  : {<FEVirtual.VmNetworkConfig[Entry]>, <FEVirtual.VmNetworkConfig[Entry]>, <FEVirtual.VmNetworkConfig[Entry]>}

    Here, we are looking at information that is basically identical to the information that I created by making
    the NewVmNetworkController class. The biggest difference is that each of the properties Adapter, Config, and Switch...
#>

$Ctrl.Network.Adapter

<#
    Output
    ------
    {<FEVirtual.VmNetworkAdapter[Item]>, <FEVirtual.VmNetworkAdapter[Item]>, <FEVirtual.VmNetworkAdapter[Item]>, <FEVirtual.VmNetworkAdapter[It

    This is a nested controller object that contains other properties that are hidden.
    Particularly...
#>

$Ctrl.Network.Adapter.State

<#
    Output
    ------
    {Disconnected, Connected}
#>

$Ctrl.Network.Adapter.State.Output

<#
    Index Name         Label Description
    ----- ----         ----- -----------
        0 Disconnected [ ]   Adapter network is disabled
        1 Connected    [+]   Adapter network is enabled

    Each of the properties Adapter, Config, and Switch, have these various objects inside of them.

    These are critical to getting the XAML front end to correctly select the options when it comes time
    to (create/delete) virtual switches, hard disks, and machines.

    At least, it may not be readily apparent that this function automatically generates the correct
    information to input into the virtual machine when it is realized.
#>

Get-CimInstance Win32_NetworkAdapter

<#
    DeviceID Name                                                      AdapterType             ServiceName 
    -------- ----                                                      -----------             -----------
    0        Microsoft Kernel Debug Network Adapter                                            kdnic
    1        1x1 11bgn Wireless LAN PCI Express Half Mini Card Adapter
    2        Realtek PCIe GbE Family Controller
    3        Intel(R) Ethernet Connection I217-LM
    4        Hyper-V Virtual Switch Extension Adapter                  Ethernet 802.3          VMSMP
    5        Hyper-V Virtual Ethernet Adapter                          Ethernet 802.3          VMSNPXYMP
    6        WAN Miniport (SSTP)                                                               RasSstp
    7        WAN Miniport (IKEv2)                                                              RasAgileVpn
    8        WAN Miniport (L2TP)                                                               Rasl2tp
    9        WAN Miniport (PPTP)                                                               PptpMiniport
    10       WAN Miniport (PPPOE)                                                              RasPppoe
    11       WAN Miniport (IP)                                         Ethernet 802.3          NdisWan
    12       WAN Miniport (IPv6)                                       Ethernet 802.3          NdisWan
    13       WAN Miniport (Network Monitor)                            Ethernet 802.3          NdisWan
    14       RAS Async Adapter                                         Wide Area Network (WAN) AsyncMac
    15       Intel(R) Centrino(R) Advanced-N 6235 Driver
    16       Microsoft Wi-Fi Direct Virtual Adapter
    17       Hyper-V Virtual Ethernet Adapter #2                       Ethernet 802.3          VMSNPXYMP
    20       Hyper-V Virtual Switch Extension Adapter                  Ethernet 802.3          VMSMP
    21       Bluetooth Device (Personal Area Network)
    22       Intel(R) 82579LM Gigabit Network Connection               Ethernet 802.3          e1cexpress
    23       Broadcom 802.11n Network Adapter                          Ethernet 802.3          BCM43XX
    24       Microsoft Wi-Fi Direct Virtual Adapter #4                 Ethernet 802.3          vwifimp     
    25       Microsoft Wi-Fi Direct Virtual Adapter #5                 Ethernet 802.3          vwifimp
    27       Bluetooth Device (Personal Area Network)
    28       SAMSUNG Mobile USB Remote NDIS Network Device             Ethernet 802.3          usbrndis6

    That will get me ALL of the adapters on the system, though many of them are just different services,
    they're not PHYSICAL adapters. Whereas...
#>

Get-CimInstance Win32_NetworkAdapter | ? PnPDeviceId -match "(USB\\VID|PCI\\VEN)"

<#
    DeviceID Name                                          AdapterType    ServiceName
    -------- ----                                          -----------    -----------
    22       Intel(R) 82579LM Gigabit Network Connection   Ethernet 802.3 e1cexpress
    23       Broadcom 802.11n Network Adapter              Ethernet 802.3 BCM43XX
    28       SAMSUNG Mobile USB Remote NDIS Network Device Ethernet 802.3 usbrndis6

    This above uses Regular Expressions to look for only the network adapters that have a plug and play device
    id that matches "USB\VID" or "PCI\VEN". The extra slashes need to be used to escape that character in regex.

    Also, the "|" symbol indicates OR. This is extremely useful to do in PowerShell, using regex and property
    names with the where-object as a "?"

    However, the information seen under...
#>

$Main.Adapter | FT

<#
    Index Name                                          Guid                                 MacAddress        Description
    ----- ----                                          ----                                 ----------        -----------
        0 Intel(R) 82579LM Gigabit Network Connection   f73cfcea-f220-4535-bce4-5f32a2ee49db D4:BE:D9:3C:1C:EB Intel(R) 82579LM Gigabit Network... 
        1 Broadcom 802.11n Network Adapter              858ae5dc-bb8a-4245-bef0-c80ce86a4701 74:E5:43:02:30:BF Broadcom 802.11n Network Adapter    
        2 SAMSUNG Mobile USB Remote NDIS Network Device 593f7f7c-2698-4b57-93bb-26baabdc161a 02:5E:65:32:30:39 SAMSUNG Mobile USB Remote NDIS N...

    ...is slightly different.

    That is because the classes that I've constructed are processing the input into a slightly different object so
    that it makes the process... MORE EFFICIENT.

    Each time the user clicks "Refresh" in the graphical user interface, it has to prepare many of these objects behind
    the scene, so that the graphical user interface can be populated with the correct information, instead of outdated
    information.

    You could theoretically make the program constantly update things in the GUI, but that would IMPACT ITS PERFORMANCE.
#>

<#
    So, what I've just shown is a stripped down version of the (classes/enum) I just demonstrated...
#>

$Main.Adapter | FT

<#
    Index Name                                          Guid                                 MacAddress        Description
    ----- ----                                          ----                                 ----------        -----------
        0 Intel(R) 82579LM Gigabit Network Connection   f73cfcea-f220-4535-bce4-5f32a2ee49db D4:BE:D9:3C:1C:EB Intel(R) 82579LM Gigabit Network... 
        1 Broadcom 802.11n Network Adapter              858ae5dc-bb8a-4245-bef0-c80ce86a4701 74:E5:43:02:30:BF Broadcom 802.11n Network Adapter    
        2 SAMSUNG Mobile USB Remote NDIS Network Device 593f7f7c-2698-4b57-93bb-26baabdc161a 02:5E:65:32:30:39 SAMSUNG Mobile USB Remote NDIS N... 

    What I need to do now, is reimplement some stuff, which I will do by adding New to the beginning of each item.

    By changing the names with the prefix "New", it'll get rid of the red squiggly lines that indicate that the
    type has already been declared further up in the script.
#>

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

<#
    With THIS particular class, I have to perform a process called "cannibalization", where I pick
    apart the pieces of the original class, and implement them into the new class.
#>

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

<#
    The methods SetState() and SetStatus() are meant to be implemented from the controller
    class, not within this particular class.

    The controller class dictates what options are available to this particular object.
#>

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

<#
    Now, I can test the new controller here.
#>

$Adapter = [NewVmNetworkAdapterController]::New()
$Adapter.Output | FT

<#
    Index Name                                          State        Guid                                 MacAddress        Description
    ----- ----                                          -----        ----                                 ----------        -----------
        0 Intel(R) 82579LM Gigabit Network Connection   Disconnected f73cfcea-f220-4535-bce4-5f32a2ee49db D4:BE:D9:3C:1C:EB Intel(R) 82579LM Gi... 
        1 Broadcom 802.11n Network Adapter              Disconnected 858ae5dc-bb8a-4245-bef0-c80ce86a4701 74:E5:43:02:30:BF Broadcom 802.11n Ne... 
        2 SAMSUNG Mobile USB Remote NDIS Network Device Connected    593f7f7c-2698-4b57-93bb-26baabdc161a 02:5E:65:32:30:39 SAMSUNG Mobile USB ..

    And that is what I need to do for the Config and Switch controllers as well.
#>

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
    [String]      $Gateway
    [UInt32]          $Mtu
    [UInt32]         $Dhcp
    [String[]]        $Dns
    NewVmNetworkConfigNetwork(
    [UInt32]        $Index ,
    [UInt32]         $Type ,
    [String] $Connectivity ,
    [String]    $IpAddress ,
    [UInt32]       $Prefix ,
    [String]      $Gateway ,
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

<#
    Switch objects
#>

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

<#
    Controller class
#>


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
        $This.Main = $This.VmMain($Domain,$NetBios)
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

Class NewVmNetworkConfigNetwork
{
    [UInt32]        $Index
    [UInt32]         $Type
    [String] $Connectivity
    [String]    $IpAddress
    [String]       $Prefix
    [String]      $Gateway
    [UInt32]          $Mtu
    [UInt32]         $Dhcp
    [String[]]        $Dns
    NewVmNetworkConfigNetwork(
    [UInt32]        $Index ,
    [UInt32]         $Type ,
    [String] $Connectivity ,
    [String]    $IpAddress ,
    [UInt32]       $Prefix ,
    [String]      $Gateway ,
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

<#
    Create a new class that handles IPV4 as well as IPV6, multiple possible addresses per configuration.

    [String]     $IPv4Connectivity
    [String]          $IPv4Address
    [String]           $IPv4Prefix
    [String]   $IPv4DefaultGateway
    [String]     $IPv4InterfaceMtu
    [String]    $IPv4InterfaceDhcp
    [String[]]      $IPv4DnsServer

    [String]     $IPv6Connectivity
    [String] $IPv6LinkLocalAddress
    [String]   $IPv6DefaultGateway
    [String]     $IPv6InterfaceMtu
    [String]    $IPv6InterfaceDhcp
    [String[]]      $IPv6DnsServer
#>
