<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-26 23:40:50                                                                  //
 \\==================================================================================================// 

    FileName   : New-VmController.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : Creates a [PowerShell] object that can optionally initialize a 
                 (GUI/graphical user interface) to orchestrate the networking, credentials,
                 imaging, templatization, deployment and configuration of (a single/multiple)
                 [virtual machines] in [Hyper-V].
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-29
    Modified   : 2024-01-26
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function New-VmController
{
    [CmdLetBinding()]
    Param(
    [ValidateSet(0,1,2)]
    [Parameter()][UInt32]$Mode = 0)

    Import-Module Hyper-V -EA 0

    # // ===========
    # // | Generic |
    # // ===========

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
            Return "<FEModule.NewVmController.Property>"
        }
    }

    Class NewVmControllerMain
    {
        [String]  $Domain
        [String] $NetBios
        NewVmControllerMain([String]$Domain,[String]$NetBios)
        {
            $This.Domain  = $Domain.ToLower()
            $This.NetBios = $NetBios.ToUpper()
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Main>"
        }
    }

    # // ==============
    # // | Validation |
    # // ==============

    Enum NewVmControllerValidationSlotType
    {
        Network
        Credential
        Image
        Template
        Node
    }

    Class NewVmControllerValidationSlotItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        NewVmControllerValidationSlotItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerValidationSlotType]::$Name
            $This.Name  = [NewVmControllerValidationSlotType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerValidationSlotList
    {
        [Object] $Output
        NewVmControllerValidationSlotList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerValidationSlotItem([String]$Name)
        {
            Return [NewVmControllerValidationSlotItem]::New($Name)
        }
        [Object] Get([String]$Name)
        {
            Return $This.Output | ? Name -eq $Name
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()
            
            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerValidationSlotType]))
            {
                $Item             = $This.NewVmControllerValidationSlotItem($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    Network    { "Controls related to networking."                 }
                    Credential { "Controls related to credential management."      }
                    Image      { "Controls related to the imaging engine."         }
                    Template   { "Controls related to template fabrication."       }
                    Node       { "Controls related to virtual machine management." }
                }

                $This.Output += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Validation.Slot.List>"
        }
    }

    Class NewVmControllerValidationEntry
    {
        [UInt32]   $Index
        [Object]    $Slot
        [String]    $Name
        [String]    $Type
        [Object] $Control
        [UInt32]  $Status
        [String]  $Reason
        NewVmControllerValidationEntry([UInt32]$Index,[Object]$Slot,[Object]$Control)
        {
            $This.Index   = $Index
            $This.Slot    = $Slot
            $This.Name    = $Control.Name
            $This.Type    = $Control.Type
            $This.Control = $Control.Control
            $This.SetStatus(0)
        }
        SetStatus([UInt32]$Status)
        {
            $This.Status = $Status
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Validation.Entry>"
        }
    }

    Class NewVmControllerValidationPath
    {
        [UInt32]   $Status
        [String]     $Type
        [String]     $Name
        [Object] $Fullname
        NewVmControllerValidationPath([String]$Path)
        {
            $This.Status       = [UInt32]($Path -match "^\w+\:\\")
            $This.Fullname     = $Path
            If ($This.Status -eq 1)
            {
                Try
                {
                    If ([System.IO.FileInfo]::new($Path).Attributes -match "Directory")
                    {
                        $This.Type   = "Directory" 
                    }
                    Else
                    {
                        $This.Type   = "File"
                    }
                    
                    $This.Name       = Split-Path -Leaf $Path

                    If (!(Test-Path $This.Fullname))
                    {
                        $This.Status = 2
                    }
                }
                Catch
                {
                    
                }
            }
        }
        [String] ToString()
        {
            Return $This.Fullname
        }
    }

    Class NewVmControllerValidationMaster
    {
        Hidden [Object] $Slot
        [Object]      $Output
        NewVmControllerValidationMaster()
        {
            $This.Slot = $This.NewVmControllerValidationSlotList()
            $This.Clear()
        }
        [Object] NewVmControllerValidationSlotList()
        {
            Return [NewVmControllerValidationSlotList]::New()
        }
        [Object] NewVmControllerValidationEntry([UInt32]$Index,[Object]$Slot,[Object]$Control)
        {
            Return [NewVmControllerValidationEntry]::New($Index,$Slot,$Control)
        }
        [Object] NewVmControllerValidationPath([String]$Entry)
        {
            Return [NewVmControllerValidationPath]::New($Entry)
        }
        [String[]] Reserved()
        {
            Return "ANONYMOUS;AUTHENTICATED USER;BATCH;BUILTIN;CREATOR GROUP;CREATOR GR"+
            "OUP SERVER;CREATOR OWNER;CREATOR OWNER SERVER;DIALUP;DIGEST AUTH;IN"+
            "TERACTIVE;INTERNET;LOCAL;LOCAL SYSTEM;NETWORK;NETWORK SERVICE;NT AU"+
            "THORITY;NT DOMAIN;NTLM AUTH;NULL;PROXY;REMOTE INTERACTIVE;RESTRICTE"+
            "D;SCHANNEL AUTH;SELF;SERVER;SERVICE;SYSTEM;TERMINAL SERVER;THIS ORG"+
            "ANIZATION;USERS;WORLD" -Split ";"
        }
        [String[]] Legacy()
        {
            Return "-GATEWAY;-GW;-TAC" -Split ";"
        }
        [String[]] SecurityDescriptor()
        {
            Return "AN;AO;AU;BA;BG;BO;BU;CA;CD;CG;CO;DA;DC;DD;DG;DU;EA;ED;HI;IU;"+
            "LA;LG;LS;LW;ME;MU;NO;NS;NU;PA;PO;PS;PU;RC;RD;RE;RO;RS;RU;SA;SI;SO;S"+
            "U;SY;WD" -Split ";"
        }
        [Object] New([UInt32]$Slot,[Object]$Control)
        {
            Return $This.NewVmControllerValidationEntry($This.Output.Count,$This.Slot.Output[$Slot],$Control)
        }
        [Object] CheckPath([String]$Path)
        {
            Return $This.NewVmControllerValidationPath($Path)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Add([UInt32]$Slot,[Object]$Control)
        {
            If ($Control.Name -notin $This.Output.Name)
            {
                $This.Output += $This.New($Slot,$Control)
            }
        }
        [Object] Get([String]$Name)
        {
            $Item = $This.Output | ? Name -eq $Name

            If (!$Item)
            {
                Return $Null
            }
            Else
            {
                Return $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Validation.Master>"
        }
    }

    # // ===========
    # // | Network |
    # // ===========

    # // ==============
    # // | Adapter(s) |
    # // ==============

    Enum NewVmControllerNetworkAdapterStateType
    {
        Disconnected
        Connected
    }

    Class NewVmControllerNetworkAdapterStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        NewVmControllerNetworkAdapterStateItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerNetworkAdapterStateType]::$Name
            $This.Name  = [NewVmControllerNetworkAdapterStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerNetworkAdapterStateList
    {
        [Object] $Output
        NewVmControllerNetworkAdapterStateList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerNetworkAdapterStateItem([String]$Name)
        {
            Return [NewVmControllerNetworkAdapterStateItem]::New($Name)
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerNetworkAdapterStateType]))
            {
                $Item             = $This.NewVmControllerNetworkAdapterStateItem($Name)
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
            Return "<FEModule.NewVmController.Network.Adapter.State.List>"
        }
    }

    Class NewVmControllerNetworkAdapterExtension
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
        NewVmControllerNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
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
            Return "<FEModule.NewVmController.Network.Adapter.Extension>"
        }
    }

    Class NewVmControllerNetworkAdapterMaster
    {
        Hidden [Object] $State
        [Object]       $Output
        NewVmControllerNetworkAdapterMaster()
        {
            $This.State = $This.NewVmControllerNetworkAdapterStateList()
        }
        [Object] NewVmControllerNetworkAdapterStateList()
        {
            Return [NewVmControllerNetworkAdapterStateList]::New()
        }
        [Object] NewVmControllerNetworkAdapterExtension([UInt32]$Index,[Object]$Adapter)
        {
            Return [NewVmControllerNetworkAdapterExtension]::New($Index,$Adapter)
        }
        [Object[]] GetObject()
        {
            Return Get-CimInstance Win32_NetworkAdapter | ? { 
                
                $_.PnPDeviceId -match "(USB\\VID|PCI\\VEN|ROOT\\VMS_MP)" -or $_.Name -match "Virtual Adapter"
            }
        }
        [Object] New([Object]$Adapter)
        {
            $Item = $This.NewVmControllerNetworkAdapterExtension($This.Output.Count,$Adapter)
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
            Return "<FEModule.NewVmController.Network.Adapter.Master>"
        }
    }

    # // =================
    # // | VM Adapter(s) |
    # // =================

    Enum NewVmControllerNetworkVirtualAdapterStateType
    {
        Active
        Inactive
    }

    Class NewVmControllerNetworkVirtualAdapterStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        NewVmControllerNetworkVirtualAdapterStateItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerNetworkVirtualAdapterStateType]::$Name
            $This.Name  = [NewVmControllerNetworkVirtualAdapterStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerNetworkVirtualAdapterStateList
    {
        [Object] $Output
        NewVmControllerNetworkVirtualAdapterStateList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerNetworkVirtualAdapterStateItem([String]$Name)
        {
            Return [NewVmControllerNetworkVirtualAdapterStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerNetworkVirtualAdapterStateType]))
            {
                $Item             = $This.NewVmControllerNetworkVirtualAdapterStateItem($Name)
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
            Return "<FEModule.NewVmController.Network.VirtualAdapter.State[List]>"
        }
    }

    Class NewVmControllerNetworkVirtualAdapterExtension
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
        NewVmControllerNetworkVirtualAdapterExtension([UInt32]$Index,[Object]$Virtual)
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
            Return "<FEModule.NewVmController.Network.VirtualAdapter.Extension>"
        }
    }

    Class NewVmControllerNetworkVirtualAdapterMaster
    {
        [Object] Hidden $State
        [Object]       $Output
        NewVmControllerNetworkVirtualAdapterMaster()
        {
            $This.State = $This.NewVmControllerNetworkVirtualAdapterStateList()
        }
        [Object] NewVmControllerNetworkVirtualAdapterStateList()
        {
            Return [NewVmControllerNetworkVirtualAdapterStateList]::New()
        }
        [Object] NewVmControllerNetworkVirtualAdapterExtension([UInt32]$Index,[Object]$Config)
        {
            Return [NewVmControllerNetworkVirtualAdapterExtension]::New($Index,$Config)
        }
        [Object[]] GetObject()
        {
            Return Get-VMNetworkAdapter -All
        }
        [Object] New([Object]$Virtual)
        {
            $Item = $This.NewVmControllerNetworkVirtualAdapterExtension($This.Output.Count,$Virtual)

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
            Return "<FEModule.NewVmController.Network.VirtualAdapter.Master>"
        }
    }

    # // =============
    # // | Config(s) |
    # // =============

    Enum NewVmControllerNetworkConfigStateType
    {
        Disconnected
        Up
    }

    Class NewVmControllerNetworkConfigStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        NewVmControllerNetworkConfigStateItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerNetworkConfigStateType]::$Name
            $This.Name  = [NewVmControllerNetworkConfigStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerNetworkConfigStateList
    {
        [Object] $Output
        NewVmControllerNetworkConfigStateList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerNetworkConfigStateItem([String]$Name)
        {
            Return [NewVmControllerNetworkConfigStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerNetworkConfigStateType]))
            {
                $Item             = $This.NewVmControllerNetworkConfigStateItem($Name)
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
            Return "<FEModule.NewVmController.Network.Config.Mode[List]>"
        }
    }

    Class NewVmControllerNetworkConfigNetwork
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
        NewVmControllerNetworkConfigNetwork(
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
            Return "<FEModule.NewVmController.Network.Config.Network>"
        }
    }

    Class NewVmControllerNetworkConfigExtension
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
        NewVmControllerNetworkConfigExtension([UInt32]$Index,[Object]$Config)
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
                    $Ip = $This.NewVmControllerNetworkConfigNetwork(
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
                $Ip = $This.NewVmControllerNetworkConfigNetwork(
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
                    $Ip = $This.NewVmControllerNetworkConfigNetwork(
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
                $Ip = $This.NewVmControllerNetworkConfigNetwork(
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
        [Object] NewVmControllerNetworkConfigNetwork(
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
            Return [NewVmControllerNetworkConfigNetwork]::New($Index,$Type,$Connectivity,$IpAddress,$Prefix,$Gateway,$Mtu,$Dhcp,$Dns)
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
            Return "<FEModule.NewVmController.Network.Config.Extension>"
        }
    }

    Class NewVmControllerNetworkConfigMaster
    {
        Hidden [Object] $State
        [Object]       $Output
        NewVmControllerNetworkConfigMaster()
        {
            $This.State = $This.NewVmControllerNetworkConfigStateList()
        }
        [Object] NewVmControllerNetworkConfigStateList()
        {
            Return [NewVmControllerNetworkConfigStateList]::New()
        }
        [Object] NewVmControllerNetworkConfigExtension([UInt32]$Index,[Object]$Config)
        {
            Return [NewVmControllerNetworkConfigExtension]::New($Index,$Config)
        }
        [Object[]] GetObject()
        {
            Return Get-NetIPConfiguration -Detailed
        }
        [Object] New([Object]$Config)
        {
            $Item = $This.NewVmControllerNetworkConfigExtension($This.Output.Count,$Config)

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
            Return "<FEModule.NewVmController.Network.Config.Master>"
        }
    }

    # // ==============
    # // | Switch(es) |
    # // ==============

    Enum NewVmControllerNetworkSwitchModeType
    {
        External
        Internal
        Private
    }

    Class NewVmControllerNetworkSwitchModeItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        NewVmControllerNetworkSwitchModeItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerNetworkSwitchModeType]::$Name
            $This.Name  = [NewVmControllerNetworkSwitchModeType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerNetworkSwitchModeList
    {
        [Object] $Output
        NewVmControllerNetworkSwitchModeList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerNetworkSwitchModeItem([String]$Name)
        {
            Return [NewVmControllerNetworkSwitchModeItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerNetworkSwitchModeType]))
            {
                $Item             = $This.NewVmControllerNetworkSwitchModeItem($Name)
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
        [UInt32] GetIndex([String]$Type)
        {
            Return $This.Output | ? Name -eq $Type | % Index
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Network.Switch.Mode[List]>"
        }
    }

    Class NewVmControllerNetworkSwitchExtension
    {
        [UInt32]         $Index
        Hidden [Object] $Switch
        [String]          $Name
        [String]          $Type
        [Object]         $State
        [String]         $Alias
        [String]   $Description
        [String]         $Notes
        [String]          $Guid
        [UInt32]            $Os
        [String]     $AdapterId
        [Object]       $Adapter
        [Object]        $Config
        [String]        $Status
        NewVmControllerNetworkSwitchExtension([UInt32]$Index,[Object]$Switch)
        {
            $This.Index       = $Index
            $This.Switch      = $Switch
            $This.Name        = $Switch.Name
            $This.Type        = $Switch.SwitchType
            $This.Alias       = "vEthernet ({0})" -f $This.Name
            $This.Description = $Switch.NetAdapterInterfaceDescription
            $This.Notes       = $Switch.Notes
            $This.Guid        = $Switch.Id
            $This.Os          = $Switch.AllowManagementOs
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
            Return "<FEModule.NewVmController.Network.Switch.Extension>"
        }
    }

    Class NewVmControllerNetworkSwitchMaster
    {
        Hidden [Object] $Mode
        [Object]      $Output
        NewVmControllerNetworkSwitchMaster()
        {
            $This.Mode = $This.NewVmControllerNetworkSwitchModeList()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerNetworkSwitchModeList()
        {
            Return [NewVmControllerNetworkSwitchModeList]::New()
        }
        [Object] NewVmControllerNetworkSwitchExtension([UInt32]$Index,[Object]$Switch)
        {
            Return [NewVmControllerNetworkSwitchExtension]::New($Index,$Switch)
        }
        [Object] New([Object]$Switch)
        {
            $Item   = $This.NewVmControllerNetworkSwitchExtension($This.Output.Count,$Switch)

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
            Return "<FEModule.NewVmController.Network.Switch.Master>"
        }
    }

    # // ================
    # // | Interface(s) |
    # // ================

    Enum NewVmControllerNetworkInterfaceStateType
    {
        Null
        Local
        Internet
    }

    Class NewVmControllerNetworkInterfaceStateItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String]       $Label
        [String] $Description
        NewVmControllerNetworkInterfaceStateItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerNetworkInterfaceStateType]::$Name
            $This.Name  = [NewVmControllerNetworkInterfaceStateType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerNetworkInterfaceStateList
    {
        [Object] $Output
        NewVmControllerNetworkInterfaceStateList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerNetworkInterfaceStateItem([String]$Name)
        {
            Return [NewVmControllerNetworkInterfaceStateItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerNetworkInterfaceStateType]))
            {
                $Item             = $This.NewVmControllerNetworkInterfaceStateItem($Name)
                $Item.Label       = @("[_]","[.]","[+]")[$Item.Index]
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
            Return "<FEModule.NewVmControllerNetworkInterfaceState[List]>"
        }
    }

    Class NewVmControllerNetworkInterfaceRange
    {
        [String]    $Total
        [String]  $Netmask
        [String] $Notation
        [Object]     $Host
        NewVmControllerNetworkInterfaceRange([String]$Netmask,[UInt32]$Total,[String]$Notation)
        {
            $This.Total    = $Total
            $This.Netmask  = $Netmask
            $This.Notation = $Notation
            $This.Clear()
        }
        Clear()
        {
            $This.Host = @( )
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

            $This.Host = $HostRange[0..($HostRange.Count-1)]
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Network.Interface.Range>"
        }
    }

    Class NewVmControllerNetworkInterfaceHost
    {
        [UInt32]      $Index
        [UInt32]     $Status
        [String]     $Source
        [String]       $Type = "Host"
        [String]      $Class
        [String]  $IpAddress
        [String] $MacAddress
        [String]   $Hostname
        NewVmControllerNetworkInterfaceHost([UInt32]$Index,[String]$IpAddress)
        {
            $This.Index          = $Index
            $This.Status         = 0
            $This.Source         = "Sweep"
            $This.IpAddress      = $IpAddress
            $This.GetClass()
        }
        NewVmControllerNetworkInterfaceHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
        {
            $This.Index          = $Index
            $This.Status         = [UInt32]($Reply.Result.Status -match "Success")
            $This.Source         = "Sweep"
            $This.IpAddress      = $IpAddress
            $This.GetClass()
        }
        NewVmControllerNetworkInterfaceHost([Switch]$Flags,[Uint32]$Index,[String]$Line)
        {
            $This.Index          = $Index
            $This.Status         = 1
            $This.Source         = "Arp"
            $This.IpAddress      = [Regex]::Matches($Line,"(\d+\.){3}\d+").Value
            $This.MacAddress     = [Regex]::Matches($Line,"([a-f0-9]{2}\-){5}([a-f0-9]{2})").Value.Replace("-",":") | % ToLower
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
            Return "<FEModule.NewVmController.Network.Interface.Host>"
        }
    }

    Class NewVmControllerNetworkInterfaceDhcp
    {
        [String]        $Name
        [String]  $SubnetMask
        [String]     $Network
        [String]  $StartRange
        [String]    $EndRange
        [String]   $Broadcast
        [String[]] $Exclusion
        NewVmControllerNetworkInterfaceDhcp([Object]$Base)
        {
            $This.Name        = "{0}/{1}" -f $Base.Network, $Base.Prefix
            $This.Network     = $Base.Network
            $This.Broadcast   = $Base.Broadcast
            $This.SubnetMask  = $Base.Netmask
            $This.StartRange  = $Base.Range.Host[1]
            $This.EndRange    = $Base.Range.Host[-2]
            $This.Exclusion   = $Base.Host | ? Type -notmatch "(Network|Broadcast|Host)" | % IpAddress
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Network.Interface.Dhcp>"
        }
    }

    Class NewVmControllerNetworkInterfaceBase
    {
        [String]    $Domain
        [String]   $NetBios
        [String]      $Name
        [String]   $Network
        [String] $Broadcast
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]  $Wildcard
        [String]  $Notation
        [String]   $Gateway
        [String[]]     $Dns
        [Object]     $Range
        [Object[]]    $Host
        [Object]      $Dhcp
        NewVmControllerNetworkInterfaceBase([Object]$Main,[Object]$Entry)
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

            $This.SetRange()
        }
        [Object] NewVmControllerNetworkInterfaceHost([UInt32]$Index,[String]$IpAddress)
        {
            Return [NewVmControllerNetworkInterfaceHost]::New($Index,$IpAddress)
        }
        [Object] NewVmControllerNetworkInterfaceHost([UInt32]$Index,[String]$IpAddress,[Object]$Reply)
        {
            Return [NewVmControllerNetworkInterfaceHost]::New($Index,$IpAddress,[Object]$Reply)
        }
        [Object] NewVmControllerNetworkInterfaceHost([Switch]$Flags,[UInt32]$Index,[String]$Line)
        {
            Return [NewVmControllerNetworkInterfaceHost]::New($False,$Index,$Line)
        }
        [Object] NewVmControllerNetworkInterfaceRange([String]$Netmask,[UInt32]$Total,[String]$Notation)
        {
            Return [NewVmControllerNetworkInterfaceRange]::New($Netmask,$Total,$Notation)
        }
        [Object] NewVmControllerNetworkInterfaceDhcp([Object]$Base)
        {
            Return [NewVmControllerNetworkInterfaceDhcp]::New($Base)
        }
        AddHost([String]$IpAddress)
        {
            $This.Host += $This.NewVmControllerNetworkInterfaceHost($This.Host.Count,$IpAddress)
        }
        AddHost([String]$IpAddress,[Object]$Reply)
        {
            $This.Host += $This.NewVmControllerNetworkInterfaceHost($This.Host.Count,$IpAddress,$Reply)
        }
        AddHost([Switch]$Flags,[String]$Line)
        {
            $Item       = $This.NewVmControllerNetworkInterfaceHost([Switch]$Flags,$This.Host.Count,$Line)
            If ($Item.Class -notin "Multicast","Broadcast")
            {
                $This.Host += $Item
            }
        }
        ClearHost()
        {
            $This.Host = @( )
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
            $This.Name      = "{0}/{1}" -f $This.Network, $This.Prefix
        }
        SetRange()
        {
            $Total          = $This.Wildcard -Replace "\.","*" | Invoke-Expression
            $This.Range     = $This.NewVmControllerNetworkInterfaceRange($This.Netmask,$Total,$This.Notation)
        }
        SetDhcp()
        {
            $This.Dhcp      = $This.NewVmControllerNetworkInterfaceDhcp($This)
        }
        GetHostRange()
        {
            $This.ClearHost()
            $This.Range.Expand()
        
            $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
            $Option   = New-Object System.Net.NetworkInformation.PingOptions
            $Ping     = @{ }

            ForEach ($X in 0..($This.Range.Host.Count-1))
            {
                $Item = New-Object System.Net.NetworkInformation.Ping
                $Ping.Add($X,$Item.SendPingAsync($This.Range.Host[$X],100,$Buffer,$Option))
            }

            $Out      = $Ping[0..($Ping.Count-1)]

            ForEach ($X in 0..($Out.Count-1))
            {
                $This.AddHost($This.Range.Host[$X],$Out[$X])
            }

            ForEach ($Type in "Network","Broadcast","Trusted","Gateway")
            {
                $Item      = $This.Host | ? IpAddress -eq $This.$Type

                If (!$Item.Status)
                {
                    $Item.Status = 1
                }

                $Item.Type = $Type

                If ($Type -eq "Trusted")
                {
                    $Item.Hostname = [Environment]::GetEnvironmentVariable("ComputerName").ToLower()
                }
            }


        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Network.Interface.Base>"
        }
    }

    Class NewVmControllerNetworkInterfaceExtension
    {
        [UInt32]          $Index
        Hidden [Object]    $Main
        [String]           $Name
        [String]           $Type
        [Object]          $State
        [UInt32]             $Os
        [String]          $Alias
        [String]        $Display
        [String]    $Description
        [String]          $Notes
        [String]       $SwitchId
        [String]      $AdapterId
        [Object]        $Adapter
        [Object]         $Config
        [UInt32] $InterfaceIndex
        [String]     $MacAddress
        [Object[]]         $Base
        [Object]       $Selected
        [UInt32]        $Profile
        [String]         $Status
        NewVmControllerNetworkInterfaceExtension([Object]$Main,[Object]$Switch)
        {
            $This.Index          = $Switch.Index
            $This.Main           = $Main
            $This.Name           = $Switch.Name
            $This.Type           = $Switch.Type
            $This.Os             = $Switch.Os
            $This.Alias          = $Switch.Alias
            $This.Description    = Switch -Regex ($Switch.Description)
            {
                "^\w$" { $Switch.Description } Default { "<no description available>" }
            }

            $This.Notes          = Switch -Regex ($Switch.Notes)
            {
                "^\w$" { $Switch.Notes       } Default { "<no notes available>" }
            }

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

                ForEach ($Item in $This.Config.Network | ? Type -eq 4 | ? Connectivity -eq Internet)
                {
                    $This.AddNetworkInterfaceBase($This.Main,$Item)
                }
            }
        }
        [Object] NewVmControllerNetworkInterfaceBase([Object]$Main,[Object]$Entry)
        {
            Return [NewVmControllerNetworkInterfaceBase]::New($Main,$Entry)
        }
        AddNetworkInterfaceBase([Object]$Main,[Object]$Entry)
        {
            $This.Base += $This.NewVmControllerNetworkInterfaceBase($Main,$Entry)
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
            Return "<FEModule.NewVmController.Network.Interface.Extension>"
        }
    }

    Class NewVmControllerNetworkInterfaceMaster
    {
        Hidden [Object] $State
        [Object]       $Output
        NewVmControllerNetworkInterfaceMaster()
        {
            $This.State = $This.NewVmControllerNetworkInterfaceStateList()
        }
        [Object] NewVmControllerNetworkInterfaceStateList()
        {
            Return [NewVmControllerNetworkInterfaceStateList]::New()
        }
        [Object] NewVmControllerNetworkInterfaceExtension([Object]$Main,[Object]$Switch)
        {
            Return [NewVmControllerNetworkInterfaceExtension]::New($Main,$Switch)
        }
        [Object] New([Object]$Main,[Object]$Switch)
        {
            $Item = $This.NewVmControllerNetworkInterfaceExtension($Main,$Switch)

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
            Return "<FEModule.NewVmController.Network.Interface.Master>"
        }
    }

    # // ==================
    # // | Network Master |
    # // ==================

    Class NewVmControllerNetworkMaster
    {
        [Object]           $Main
        [Object]        $Adapter
        [Object]        $Virtual
        [Object]         $Config
        [Object]         $Switch
        [Object]      $Interface
        NewVmControllerNetworkMaster()
        {
            $This.Adapter   = $This.NewVmControllerNetworkAdapterMaster()
            $This.Virtual   = $This.NewVmControllerNetworkVirtualAdapterMaster()
            $This.Config    = $This.NewVmControllerNetworkConfigMaster()
            $This.Switch    = $This.NewVmControllerNetworkSwitchMaster()
            $This.Interface = $This.NewVmControllerNetworkInterfaceMaster()
        }
        [Object] NewVmControllerMain([String]$Domain,[String]$NetBios)
        {
            Return [NewVmControllerMain]::New($Domain,$NetBios)
        }
        [Object] NewVmControllerNetworkAdapterMaster()
        {
            Return [NewVmControllerNetworkAdapterMaster]::New()
        }
        [Object] NewVmControllerNetworkVirtualAdapterMaster()
        {
            Return [NewVmControllerNetworkVirtualAdapterMaster]::New()
        }
        [Object] NewVmControllerNetworkConfigMaster()
        {
            Return [NewVmControllerNetworkConfigMaster]::New()
        }
        [Object] NewVmControllerNetworkSwitchMaster()
        {
            Return [NewVmControllerNetworkSwitchMaster]::New()
        }
        [Object] NewVmControllerNetworkInterfaceMaster()
        {
            Return [NewVmControllerNetworkInterfaceMaster]::New()
        }
        SetMain([String]$Domain,[String]$NetBios)
        {
            $This.Main = $This.NewVmControllerMain($Domain,$Netbios)
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
        [Object[]] GetPhysical()
        {
            Return $This.Adapter.Output | ? Type -eq Physical | ? Assigned -eq 0
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Network.Master>"
        }
    }

    # // ==============
    # // | Credential |
    # // ==============

    Enum NewVmControllerCredentialSlotType
    {
        Setup
        System
        Service
        User
        Microsoft
    }

    Class NewVmControllerCredentialSlotItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        NewVmControllerCredentialSlotItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerCredentialSlotType]::$Name
            $This.Name  = [NewVmControllerCredentialSlotType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class NewVmControllerCredentialSlotList
    {
        [Object] $Output
        NewVmControllerCredentialSlotList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerCredentialSlotItem([String]$Name)
        {
            Return [NewVmControllerCredentialSlotItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerCredentialSlotType]))
            {
                $Item             = $This.NewVmControllerCredentialSlotItem($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    Setup     { "System setup account"      }
                    System    { "System level account"      }
                    Service   { "Service level account"     }
                    User      { "Local/domain user account" }
                    Microsoft { "Online Microsoft account"  }
                }

                $This.Add($Item)
            }
        }
        Add([Object]$Object)
        {
            $This.Output += $Object
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Credential.Slot.List>"
        }
    }

    Class NewVmControllerCredentialItem
    {
        [UInt32]            $Index
        [Guid]               $Guid
        [Object]             $Type
        [String]         $Username
        Hidden [String]      $Pass
        [PSCredential] $Credential
        [String]              $Pin
        [UInt32]          $Profile
        NewVmControllerCredentialItem([UInt32]$Index,[Object]$Type,[PSCredential]$Credential)
        {
            $This.Index      = $Index
            $This.Guid       = $This.NewGuid()
            $This.Type       = $Type
            $This.Username   = $Credential.Username
            $This.Credential = $Credential
            $This.Pass       = $This.Mask()
        }
        NewVmControllerCredentialItem([Object]$Serial)
        {
            $This.Index      = $Serial.Index
            $This.Guid       = $Serial.Guid
            $This.Type       = $Serial.Type
            $This.Username   = $Serial.Username
            $This.Credential = $Serial.Credential
            $This.Pass       = $This.Mask()
            $This.Pin        = $Serial.Pin
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [String] Password()
        {
            Return $This.Credential.GetNetworkCredential().Password
        }
        [String] Mask()
        {
            Return "<SecureString>"
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Credential.Item>"
        }
    }

    Class NewVmControllerCredentialMaster
    {
        Hidden [Object] $Slot
        [Object]      $Output
        NewVmControllerCredentialMaster()
        {
            $This.Slot = $This.NewVmControllerCredentialSlotList()

            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] GetSlot([String]$Index)
        {
            Return $This.Slot.Output | ? Index -eq $Index
        }
        [Object] NewVmControllerCredentialSlotList()
        {
            Return [NewVmControllerCredentialSlotList]::New()
        }
        [Object] NewVmControllerCredentialItem([UInt32]$Index,[String]$Type,[PSCredential]$Credential)
        {
            Return [NewVmControllerCredentialItem]::New($Index,$Type,$Credential)
        }
        [Object] NewVmControllerCredentialItem([Object]$Serial)
        {
            Return [NewVmControllerCredentialItem]::New($Serial)
        }
        [PSCredential] SetCredential([String]$Username,[String]$Pass)
        {
            Return [PSCredential]::New($Username,$This.SecureString($Pass))
        }
        [PSCredential] SetCredential([String]$Username,[SecureString]$Pass)
        {
            Return [PSCredential]::New($Username,$Pass)
        }
        [SecureString] SecureString([String]$In)
        {
            Return $In | ConvertTo-SecureString -AsPlainText -Force
        }
        [String] Generate()
        {
            Do
            {
                $Length          = $This.Random(10,16)
                $Bytes           = [Byte[]]::New($Length)
    
                ForEach ($X in 0..($Length-1))
                {
                    $Bytes[$X]   = $This.Random(32,126)
                }
    
                $Pass            = [Char[]]$Bytes -join ''
            }
            Until ($Pass -match $This.Pattern())
    
            Return $Pass
        }
        [String] Pattern()
        {
            Return "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[:punct:]).{10}"
        }
        [UInt32] Random([UInt32]$Min,[UInt32]$Max)
        {
            Return Get-Random -Min $Min -Max $Max
        }
        Setup()
        {
            If ("Administrator" -in $This.Output.Username)
            {
                Throw "Administrator account already exists"
            }
    
            $This.Add(0,"Administrator",$This.Generate())
        }
        Rerank()
        {
            $C = 0
            ForEach ($Item in $This.Output)
            {
                $Item.Index = $C
                $C ++
            }
        }
        Add([UInt32]$Type,[String]$Username,[String]$Pass)
        {
            If ($Type -gt $This.Slot.Output.Count)
            {
                Throw "Invalid account type"
            }
    
            $Credential   = $This.SetCredential($Username,$Pass)
            $This.Output += $This.NewVmControllerCredentialItem($This.Output.Count,$This.Slot.Output[$Type],$Credential)
        }
        Add([UInt32]$Type,[String]$Username,[SecureString]$Pass)
        {
            If ($Type -gt $This.Slot.Output.Count)
            {
                Throw "Invalid account type"
            }
            
            $Credential   = $This.SetCredential($Username,$Pass)
            $This.Output += $This.NewVmControllerCredentialItem($This.Output.Count,$This.Slot.Output[$Type],$Credential)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Credential.Master>"
        }
    }

    # // ============
    # // | Image(s) |
    # // ============

    Class NewVmControllerImageLabel
    {
        [UInt32]           $Index
        [String]            $Name
        [String]            $Type
        [String]         $Version
        [UInt32[]] $SelectedIndex
        [Object[]]       $Content
        NewVmControllerImageLabel([UInt32]$Index,[Object]$Selected,[UInt32[]]$Queue)
        {
            $This.Index         = $Index
            $This.Name          = $Selected.Fullname
            $This.Type          = $Selected.Type
            $This.Version       = $Selected.Version
            $This.SelectedIndex = $Queue
            $This.Content       = @($Selected.Content | ? Index -in $Index)
            ForEach ($Item in $This.Content)
            {
                $Item.Type      = $Selected.Type
                $Item.Version   = $Selected.Version
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Image.Label>"
        }
    }

    Class NewVmControllerImageByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        NewVmControllerImageByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Class NewVmControllerImageEdition
    {
        Hidden [Object] $ImageFile
        Hidden [Object]      $Arch
        [UInt32]            $Index
        [String]             $Type
        [String]          $Version
        [String]             $Name
        [String]      $Description
        [Object]             $Size
        [UInt32]     $Architecture
        [String]  $DestinationName
        [String]            $Label
        [UInt32]          $Profile
        NewVmControllerImageEdition([Object]$Path,[Object]$Image,[Object]$Slot)
        {
            $This.ImageFile    = $Path
            $This.Arch         = $Image.Architecture
            $This.Type         = $Image.InstallationType
            $This.Version      = $Image.Version
            $This.Index        = $Slot.ImageIndex
            $This.Name         = $Slot.ImageName
            $This.Description  = $Slot.ImageDescription
            $This.Size         = $This.SizeBytes($Slot.ImageSize)
            $This.Architecture = @(86,64)[$This.Arch -eq 9]

            $This.GetLabel()
        }
        [Object] SizeBytes([UInt64]$Bytes)
        {
            Return [NewVmControllerImageByteSize]::New("Image",$Bytes)
        }
        GetLabel()
        {
            $Number = $Null
            $Tag    = $Null
            Switch -Regex ($This.Name)
            {
                Server
                {
                    $Number               = [Regex]::Matches($This.Name,"(\d{4})").Value
                    $Edition              = [Regex]::Matches($This.Name,"(Standard|Datacenter)").Value
                    $Tag                  = @{ Standard = "SD"; Datacenter = "DC" }[$Edition]

                    If ($This.Name -notmatch "Desktop")
                    {
                        $Tag += "X"
                    }

                    $This.DestinationName = "Windows Server $Number $Edition (x64)"
                }
                Default
                {
                    $Number               = [Regex]::Matches($This.Name,"(\d+)").Value
                    $Edition              = $This.Name -Replace "Windows \d+ ",''
                    $Tag                  = Switch -Regex ($Edition)
                    {
                        "^Home$"             { "HOME"       } "^Home N$"            { "HOME_N"   }
                        "^Home Sin.+$"       { "HOME_SL"    } "^Education$"         { "EDUC"     }
                        "^Education N$"      { "EDUC_N"     } "^Pro$"               { "PRO"      }
                        "^Pro N$"            { "PRO_N"      } "^Pro Education$"     { "PRO_EDUC" }
                        "^Pro Education N$"  { "PRO_EDUC_N" } "^Pro for Work.+$"    { "PRO_WS"   }
                        "^Pro N for Work.+$" { "PRO_N_WS"   } "Enterprise"          { "ENT"      }
                    }

                    $This.DestinationName = "{0} (x{1})" -f $This.Name, $This.Architecture
                }
            }

            $This.Label           = "{0}{1}{2}-{3}" -f $Number, $Tag, $This.Architecture, $This.Version
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Image.Edition>"
        }
    }

    Class NewVmControllerImageFile
    {
        [UInt32]             $Index
        [String]              $Type
        [String]           $Version
        [String]              $Name
        [String]          $Fullname
        Hidden [String]     $Letter
        Hidden [Object[]]  $Content
        [UInt32]           $Profile
        NewVmControllerImageFile([UInt32]$Index,[String]$Fullname)
        {
            $This.Index     = $Index
            $This.Name      = $Fullname | Split-Path -Leaf
            $This.Fullname  = $Fullname
            $This.Content   = @( )
        }
        [Object] GetDiskImage()
        {
            Return Get-DiskImage -ImagePath $This.Fullname
        }
        [String] DriveLetter()
        {
            Return $This.GetDiskImage() | Get-Volume | % DriveLetter
        }
        MountDiskImage()
        {
            If ($This.GetDiskImage() | ? Attached -eq 0)
            {
                Mount-DiskImage -ImagePath $This.Fullname
            }

            Do
            {
                Start-Sleep -Milliseconds 100
            }
            Until ($This.GetDiskImage() | ? Attached -eq 1)

            $This.Letter = $This.DriveLetter()
        }
        DismountDiskImage()
        {
            Dismount-DiskImage -ImagePath $This.Fullname
        }
        [Object[]] InstallWim()
        {
            Return ("{0}:\" -f $This.Letter | Get-ChildItem -Recurse | ? Name -match "^install\.(wim|esd)")
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Image.File>"
        }
    }

    Class NewVmControllerImageObject
    {
        [Object]    $File
        [Object] $Edition
        NewVmControllerImageObject([Object]$File)
        {
            $This.File    = $File
            $This.Edition = $Null
        }
        NewVmControllerImageObject([Object]$File,[Object]$Edition)
        {
            $This.File    = $File
            $This.Edition = $Edition
        }
        [String] ToString()
        {
            Return $This.File.Fullname
        }
    }

    Class NewVmControllerImageMaster
    {
        [String]        $Source
        [String]        $Target
        [Int32]       $Selected
        [Object]         $Store
        [Object]         $Queue
        [Object]          $Swap
        [Object]        $Output
        Hidden [String] $Status
        NewVmControllerImageMaster()
        {
            $This.Source   = $Null
            $This.Target   = $Null
            $This.Selected = $Null
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        Clear()
        {
            $This.Selected = -1
            $This.Store    = @( )
            $This.Queue    = @( )
        }
        [Object] NewVmControllerImageLabel([UInt32]$Index,[Object]$Selected,[UInt32[]]$Queue)
        {
            Return [NewVmControllerImageLabel]::New($Index,$Selected,$Queue)
        }
        [Object] NewVmControllerImageEdition([Object]$Fullname,[Object]$Image,[Object]$Slot)
        {
            Return [NewVmControllerImageEdition]::New($Fullname,$Image,$Slot)
        }
        [Object] NewVmControllerImageFile([UInt32]$Index,[String]$Fullname)
        {
            Return [NewVmControllerImageFile]::New($Index,$Fullname)
        }
        [Object] NewVmControllerImageObject([Object]$Image)
        {
            Return [NewVmControllerImageObject]::New($Image)
        }
        [Object] NewVmControllerImageObject([Object]$Image,[Object]$Edition)
        {
            Return [NewVmControllerImageObject]::New($Image,$Edition)
        }
        [Object[]] GetContent()
        {
            If (!$This.Source)
            {
                Throw "Source path not set"
            }

            Return Get-ChildItem -Path $This.Source *.iso
        }
        GetWindowsImage([String]$Path)
        {
            $File         = $This.Current()
            $Image        = Get-WindowsImage -ImagePath $Path -Index 1
            $File.Version = $Image.Version

            $File.Content = ForEach ($Item in Get-WindowsImage -ImagePath $Path)
            { 
                $This.NewVmControllerImageEdition($Path,$Image,$Item) 
            }
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Store.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        SetSource([String]$Source)
        {
            If (![System.IO.Directory]::Exists($Source))
            {
                Throw "Invalid source path"
            }

            $This.Source = $Source
        }
        SetTarget([String]$Target)
        {
            If (![System.IO.Directory]::Exists($Target))
            {
                $Parent = Split-Path $Target -Parent
                If (![System.IO.Directory]::Exists($Parent))
                {
                    Throw "Invalid target path"
                }
                
                [System.IO.Directory]::CreateDirectory($Target)
            }

            $This.Target = $Target
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Item in $This.GetContent())
            {
                $This.Add($Item.Fullname)
            }
        }
        Add([String]$File)
        {
            $This.Store += $This.NewVmControllerImageFile($This.Store.Count,$File)
        }
        [Object] Current()
        {
            If ($This.Selected -eq -1)
            {
                Throw "No image selected"
            }

            Return $This.Store[$This.Selected]
        }
        Load()
        {
            If (!$This.Current().GetDiskImage().Attached)
            {
                $This.Current().MountDiskImage()
            }
        }
        Unload()
        {
            If (!!$This.Current().GetDiskImage().Attached)
            {
                $This.Current().DismountDiskImage()
            }
        }
        ProcessSlot()
        {
            $Current         = $This.Current()
            $This.Status     = "Loading [~] {0}" -f $Current.Name
            $This.Load()

            $File            = $Current.InstallWim()
            $Current.Type    = @("Non-Windows","Windows")[$File.Count -ne 0]
            $This.Status     = "Type [+] {0}" -f $Current.Type

            If ($Current.Type -eq "Windows")
            {
                If ($File.Count -gt 1)
                {
                    $File        = $File | ? Fullname -match x64
                }

                $This.GetWindowsImage($File.Fullname)
            }
            
            $This.Status     = "Unloading [~] {0}" -f $Current.Name
            $This.Unload()
        }
        Chart()
        {
            Switch ($This.Store.Count)
            {
                0
                {
                    Throw "No images detected"
                }
                1
                {
                    $This.Select(0)
                    $This.ProcessSlot()
                }
                Default
                {
                    ForEach ($X in 0..($This.Store.Count-1))
                    {
                        $This.Select($X)
                        $This.ProcessSlot()
                    }
                }
            }
        }
        AddQueue([UInt32[]]$Queue)
        {
            If ($This.Current().Fullname -in $This.Queue.Name)
            {
                Throw "Image already in the queue, remove, and reindex"
            }

            $This.Queue += $This.NewVmControllerImageLabel($This.Queue.Count,$This.Current(),$Queue)
        }
        RemoveQueue([String]$Name)
        {
            If ($Name -in $This.Queue.Name)
            {
                $This.Queue = @($This.Queue | ? Name -ne $Name)
            }
        }
        Extract()
        {
            If (!$This.Target)
            {
                Throw "Must set target path"
            }
        
            ElseIf ($This.Queue.Count -eq 0)
            {
                Throw "No items queued"
            }
        
            $X = 0
            ForEach ($Queue in $This.Queue)
            {
                $Disc        = $This.Store | ? FullName -eq $Queue.Name
                If (!$Disc.GetDiskImage().Attached)
                {
                    $This.Status = "Mounting [~] {0}" -f $Disc.Name
                    $Disc.MountDiskImage()
                    $Disc.Letter = $Disc.DriveLetter()
                }
        
                $Path         = $Disc.InstallWim()
                If ($Path.Count -gt 1)
                {
                    $Path     = $Path | ? Name -match x64
                }
        
                ForEach ($File in $Disc.Content)
                {
                    $ISO                        = @{
        
                        SourceIndex             = $File.Index
                        SourceImagePath         = $Path.Fullname
                        DestinationImagePath    = "{0}\({1}){2}\{2}.wim" -f $This.Target, $X, $File.Label
                        DestinationName         = $File.DestinationName
                    }
                    
                    $Folder                     = $Iso.DestinationImagePath | Split-Path -Parent
                    # Check + create folder
                    If (![System.IO.Directory]::Exists($Folder))
                    {
                        [System.IO.Directory]::CreateDirectory($Folder)
                    }
        
                    # Check + remove file
                    If ([System.IO.File]::Exists($Iso.DestinationImagePath))
                    {
                        [System.IO.File]::Delete($Iso.DestinationImagePath)
                    }

                    # Create the file
                    $This.Status = "Extracting [~] $($File.DestinationName)"
        
                    Export-WindowsImage @ISO | Out-Null
                    $This.Status = "Extracted [~] $($This.DestinationName)"
        
                    $X ++
                }
        
                $This.Status = "Dismounting [~] {0}" -f $Disc.Name
                $Disc.DismountDiskImage()
            }
        
            $This.Status = "Complete [+] ($($This.Queue.SelectedIndex.Count)) *.wim files Extracted"
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Image.Master>"
        }
    }

    # // ===============
    # // | Template(s) |
    # // ===============

    Enum NewVmControllerTemplateRoleType
    {
        Server
        Client
        Unix
    }
        
    Class NewVmControllerTemplateRoleItem
    {
        [UInt32]       $Index
        [String]        $Name
        [String] $Description
        NewVmControllerTemplateRoleItem([String]$Name)
        {
            $This.Index = [UInt32][NewVmControllerTemplateRoleType]::$Name
            $This.Name  = [NewVmControllerTemplateRoleType]::$Name
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
        
    Class NewVmControllerTemplateRoleList
    {
        [Object] $Output
        NewVmControllerTemplateRoleList()
        {
            $This.Refresh()
        }
        [Object] NewVmControllerTemplateRoleItem([String]$Name)
        {
            Return [NewVmControllerTemplateRoleItem]::New($Name)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Name in [System.Enum]::GetNames([NewVmControllerTemplateRoleType]))
            {
                $Item             = $This.NewVmControllerTemplateRoleItem($Name)
                $Item.Description = Switch ($Item.Name)
                {
                    Server { "Windows Server 2016/2019/2022" }
                    Client { "Windows 10/11"                 }
                    Unix   { "Linux, Unix, or FreeBSD"       }
                }

                $This.Output     += $Item
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Template.Role.List>"
        }
    }

    Class NewVmControllerTemplateByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        NewVmControllerTemplateByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }
        
    Class NewVmControllerTemplateNetworkItem
    {
        [UInt32]     $Index
        [String] $IpAddress
        [String]    $Domain
        [String]   $NetBios
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        NewVmControllerTemplateNetworkItem([Object]$Network)
        {
            $This.Index       = $Network.Index
            $Selected         = $Network.Selected

            # [IP Address]
            $This.IPAddress   = $Network.FirstAvailableIpAddress()

            $This.Domain      = $Selected.Domain
            $This.NetBios     = $Selected.NetBios
            $This.Trusted     = $Selected.Trusted
            $This.Prefix      = $Selected.Prefix
            $This.Netmask     = $Selected.Netmask
            $This.Gateway     = $Selected.Gateway
            $This.Dns         = $Selected.Dns
            $This.Dhcp        = $Selected.Dhcp
        }

        [String] ToString()
        {
            Return "<FEVirtual.NewVmController.Template.Network.Item>"
        }
    }
        
    Class NewVmControllerTemplateNetworkRangeDivisionHost
    {
        [UInt32]      $Rank
        [String] $IpAddress
        [UInt32]    $Status
        NewVmControllerTemplateNetworkRangeDivisionHost([UInt32]$Rank,[String]$IpAddress)
        {
            $This.Rank      = $Rank
            $This.IpAddress = $IpAddress
        }
        [String] ToString()
        {
            Return $This.IpAddress
        }
    }
        
    Class NewVmControllerTemplateNetworkRangeDivisionBlock
    {
        [UInt32]    $Index
        [UInt32]    $Total
        [UInt32]    $Alive
        [Object[]]   $Host
        NewVmControllerTemplateNetworkRangeDivisionBlock([UInt32]$Index,[String[]]$Range)
        {
            $This.Index  = $Index
            $This.Total  = $Range.Count
            $This.Host   = @( ) 
            
            $Hash        = @{ }
            ForEach ($Item in $Range)
            {
                $Hash.Add($Hash.Count,$This.NewVmControllerTemplateNetworkDivisionHost($Hash.Count,$Item))
            }

            $This.Host   = $Hash[0..($Hash.Count-1)]
        }
        [Object] NewVmControllerTemplateNetworkDivisionHost([UInt32]$Index,[String]$IpAddress)
        {
            Return [NewVmControllerTemplateNetworkRangeDivisionHost]::New($Index,$IpAddress)
        }
        [String] ToString()
        {
            Return "<FEVirtual.NewVmController.Template.Network.Range.Division.Block>"
        }
    }

    Class NewVmControllerTemplateNetworkRangeDivisionList
    {
        [UInt32]           $Index
        [Object]       $Interface
        [Object]        $Selected
        [Object]           $Range
        [UInt64]           $Total
        [UInt64]           $Block
        [String]            $Type
        [Object]         $Process
        [Object]          $Output
        Hidden [Object] $Runspace
        NewVmControllerTemplateNetworkRangeDivisionList([Object]$Interface)
        {
            $This.Index     = $Interface.Index
            $This.Interface = $Interface
            $This.Selected  = $Interface.Selected

            $This.Range     = $This.Selected.Range
            $This.Total     = $This.Selected.Range.Total

            If ($This.Total -le 256)
            {
                $This.Block = 1
                $This.Type  = "Single"
            }

            If ($This.Total -gt 256)
            {
                $This.Block = $This.Total/256
                $This.Type  = "Multiple"
            }

            $This.Refresh()
        }
        Clear()
        {
            $This.Process = @( )
            $This.Output  = @( )
        }
        [Object] NewVmControllerTemplateNetworkRangeDivisionBlock([UInt32]$Index,[String[]]$Range)
        {
            Return [NewVmControllerTemplateNetworkRangeDivisionBlock]::New($Index,$Range)
        }
        [Object] CreateRunspace()
        {
            Return [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
        }
        [Object] CreatePowerShell()
        {
            Return [PowerShell]::Create()
        }
        AddBlock([String[]]$Range)
        {
            $This.Process += $This.NewVmControllerTemplateNetworkRangeDivisionBlock($This.Process.Count,$Range)
        }
        Refresh()
        {
            $This.Clear()

            If ($This.Type -eq "Single")
            {
                $This.AddBlock($This.Range.Host)
                $Object        = $This.Process[0]

                $HostList      = $Object.Host.IpAddress

                $This.Runspace = $This.CreateRunspace()
                $PS            = $This.CreatePowerShell()
                $PS.Runspace   = $This.Runspace

                $This.Runspace.Open()
                [Void]$PS.AddScript(
                {
                    Param ($HostList)

                    $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
                    $Option   = [System.Net.NetworkInformation.PingOptions]::New()
                    $Ping     = @{ }
                    ForEach ($X in 0..($HostList.Count-1))
                    {
                        $Item = [System.Net.NetworkInformation.Ping]::New()
                        $Ping.Add($X,$Item.SendPingAsync($HostList[$X],100,$Buffer,$Option))
                    }

                    $Ping[0..($Ping.Count-1)]
                })

                $PS.AddArgument($HostList)
                $Async        = $PS.BeginInvoke()
                $Out          = $PS.EndInvoke($Async)
                $PS.Dispose()
                $This.Runspace.Dispose()

                ForEach ($X in 0..($Out.Count-1))
                {
                    $Object.Host[$X].Status = [UInt32]($Out[$X].Result.Status -eq "Success")
                }

                $Object.Alive = ($Object.Host | ? Status).Count
            }
            If ($This.Type -eq "Multiple")
            {
                $End             = 0
                $X               = 0
                $Count           = $This.Total/256
                $This.Process    = @( )

                Do
                {
                    $HostList      = $This.Range.Host[($X*256)..(($X*256)+255)]
                    $This.AddBlock($HostList)
                    $Object        = $This.Process[$X]
                
                    $This.Runspace = $This.CreateRunspace()
                    $PS            = $This.CreatePowerShell()
                    $PS.Runspace   = $This.Runspace
                
                    $This.Runspace.Open()
                    [Void]$PS.AddScript(
                    {
                        Param ($HostList)
                
                        $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
                        $Option   = [System.Net.NetworkInformation.PingOptions]::New()
                        $Ping     = @{ }
                        ForEach ($X in 0..($HostList.Count-1))
                        {
                            $Item = [System.Net.NetworkInformation.Ping]::New()
                            $Ping.Add($X,$Item.SendPingAsync($HostList[$X],100,$Buffer,$Option))
                        }
                
                        $Ping[0..($Ping.Count-1)]
                    })
                
                    $PS.AddArgument($Object.Host.IpAddress)
                    $Async        = $PS.BeginInvoke()
                    $Out          = $PS.EndInvoke($Async)
                    $PS.Dispose()
                    $This.Runspace.Dispose()
                
                    ForEach ($I in 0..($Out.Count-1))
                    {
                        $Object.Host[$I].Status = [UInt32]($Out[$I].Result.Status -eq "Success")
                    }
                
                    $Object.Alive = ($Object.Host | ? Status).Count
                    
                    If ($Object.Alive -eq 0)
                    {
                        $End ++
                    }

                    $X ++
                }
                Until ($End -eq 1 -or $X -eq $Count)
            }

            ForEach ($Item in "Network","Broadcast")
            { 
                $Node        = $This.Process.Host | ? IpAddress -eq $This.Interface.Selected.$Item
                $Node.Status = 1 
            }

            $This.Output = $This.Process.Host

        }
        [String] FirstAvailableIpAddress()
        {
            $Item        = ($This.Output | ? Status -eq 0)[0]
            $Item.Status = 1
            Return $Item.IpAddress
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Template.Network.Range.Division.List>"
        }
    }
        
    Class NewVmControllerTemplateItem
    {
        [UInt32]      $Index
        [Guid]         $Guid
        [String]       $Name
        [Object]       $Role
        [String]       $Root
        [Object]     $Memory
        [Object]        $Hdd
        [UInt32]        $Gen
        [UInt32]       $Core
        [Object]    $Account
        [Object]    $Network
        [Object]       $Node
        [Object]      $Image
        NewVmControllerTemplateItem(
        [UInt32]      $Index,
        [String]       $Name,
        [Object]       $Role,
        [String]       $Root,
        [Object]        $Ram,
        [Object]        $Hdd,
        [UInt32]        $Gen,
        [UInt32]       $Core,
        [Object]    $Account,
        [Object]    $Network,
        [Object]       $Node,
        [Object]      $Image)
        {
            $This.Index     = $Index
            $This.Guid      = $This.NewGuid()
            $This.Name      = $Name
            $This.Role      = $Role
            $This.Root      = $Root
            $This.Memory    = $Ram
            $This.Hdd       = $Hdd
            $This.Gen       = $Gen
            $This.Core      = $Core
            $This.Account   = $Account
            $This.Network   = $Network
            $This.Node      = $Node
            $This.Image     = $Image
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [String] ToString()
        {
            Return "<FEVirtual.NewVmController.Template.Item>"
        }
    }

    Class NewVmControllerTemplateMaster
    {
        Hidden [Object] $Role
        [String]        $Path
        [Object]     $Account
        [Object]     $Network
        [Object]       $Image
        [Object]      $Output
        NewVmControllerTemplateMaster()
        {
            $This.Role = $This.NewVmControllerTemplateRoleList()
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerTemplateRoleList()
        {
            Return [NewVmControllerTemplateRoleList]::New()
        }
        [Object] NewVmControllerTemplateNetworkItem([Object]$Network)
        {
            Return [NewVmControllerTemplateNetworkItem]::New($Network)
        }
        [Object] NewVmControllerTemplateNetworkRangeDivisionList([Object]$Interface)
        {
            Return [NewVmControllerTemplateNetworkRangeDivisionList]::New($Interface)
        }
        [Object] NewVmControllerTemplateItem(
        [UInt32] $Index,
        [String]  $Name,
        [Object]  $Role,
        [String]  $Root,
        [Object]   $Ram,
        [Object]   $Hdd,
        [UInt32]   $Gen,
        [UInt32]  $Core,
        [Object]  $Node)
        {
            Return [NewVmControllerTemplateItem]::New($Index,
            $Name,
            $Role,
            $Root,
            $Ram,
            $Hdd,
            $Gen,
            $Core,
            $This.Account,
            $This.Network,
            $Node,
            $This.Image)
        }
        [Object] NewVmControllerTemplateByteSize([String]$Name,[UInt32]$Size)
        {
            Return [NewVmControllerTemplateByteSize]::New($Name,$Size * 1GB)
        }
        SetPath([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                [System.Windows.MessageBox]::Show("Invalid path","Exception [!] Path error")
            }
            $This.Path      = $Path
        }
        SetNetwork([Object]$Interface)
        {
            $This.Network   = $This.NewVmControllerTemplateNetworkRangeDivisionList($Interface)
            ForEach ($Property in "Network","Broadcast","Gateway","Trusted")
            {
                $Item        = $This.Network.Output | ? IpAddress -eq $This.Network.Selected.$Property
                If ($Item)
                {
                    $Item.Status = 1
                }
            }
        }
        SetImage([Object]$Image)
        {
            $This.Image     = $Image
        }
        SetAccount([Object]$Account)
        {
            $This.Account   = $Account
        }
        Add(
        [String]$Name,
        [UInt32]$Role,
        [String]$Root,
        [UInt32]$Ram,
        [UInt32]$Hdd,
        [UInt32]$Gen,
        [UInt32]$Core)
        {
            If ($Name -in $This.Output.Name)
            {
                Throw "Item already exists"
            }

            $Node       = @( )

            ForEach ($Item in $This.Network)
            { 
                $Node = $This.NewVmControllerTemplateNetworkItem($Item)
            }

            $This.Output += $This.NewVmControllerTemplateItem($This.Output.Count,
            $Name,
            $This.Role.Output[$Role],
            $Root,
            $This.NewVmControllerTemplateByteSize("Memory",$Ram),
            $This.NewVmControllerTemplateByteSize("Drive",$Hdd),
            $Gen,
            $Core,
            $Node)

            $This.Rerank()
        }
        Remove([String]$Name)
        {
            $This.Output = @($This.Output | ? Name -ne $Name)
            $This.Rerank()
        }
        Export([UInt32]$Index)
        {
            If ($Index -gt $This.Output.Count)
            {
                [System.Windows.MessageBox]::Show("Invalid index","Exception [!] Index error")
            }

            ElseIf (!$This.Path)
            {
                [System.Windows.MessageBox]::Show("Path not set","Exception [!] Path error")
            }

            $Value      = $This.Output[$Index]
            $FilePath   = "{0}\{1}.fex" -f $This.Path, $Value.Name

            Export-CliXml -Path $FilePath -InputObject $Value -Depth 3

            If ([System.IO.File]::Exists($FilePath))
            {
                [Console]::WriteLine("Exported [+] File: [$FilePath]")
            }
            Else
            {
                [System.Windows.MessageBox]::Show("Something failed... bye.","Exception [!] Unknown failure")
            }
        }
        Rerank()
        {
            For ($X = 0; $X -lt $This.Output.Count; $X++)
            {
                $This.Output[$X].Index = $X
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Template.Master>"
        }
    }

    # // ===========
    # // | Node(s) |
    # // ===========

    Class NewVmControllerNodeByteSize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        NewVmControllerNodeByteSize([String]$Name,[UInt64]$Bytes)
        {
            $This.Name   = $Name
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Class NewVmControllerNodeDhcp
    {
        [String]        $Name
        [String]  $SubnetMask
        [String]     $Network
        [String]  $StartRange
        [String]    $EndRange
        [String]   $Broadcast
        [String[]] $Exclusion
        NewVmControllerNodeDhcp([Object]$Dhcp)
        {
            $This.Name       = $Dhcp.Name
            $This.SubnetMask = $Dhcp.SubnetMask
            $This.Network    = $Dhcp.Network
            $This.StartRange = $Dhcp.StartRange
            $This.EndRange   = $Dhcp.EndRange
            $This.Broadcast  = $Dhcp.Broadcast
            $This.Exclusion  = $Dhcp.Exclusion
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Dhcp>"
        }
    }

    Class NewVmControllerNodeNetworkItem
    {
        Hidden [UInt32]  $Index
        Hidden [Object] $Switch
        [String]     $IpAddress
        [String]        $Domain
        [String]       $NetBios
        [String]       $Trusted
        [String]        $Prefix
        [String]       $Netmask
        [String]       $Gateway
        [String[]]         $Dns
        [Object]          $Dhcp
        [UInt32]      $Transmit
        NewVmControllerNodeNetworkItem([Object]$Network,[Object]$Node)
        {
            $This.Index     = $Node.Index
            $This.Switch    = $Network.Interface.Name
            $This.IpAddress = $Node.IpAddress
            $This.Domain    = $Node.Domain
            $This.NetBios   = $Node.NetBios
            $This.Trusted   = $Node.Trusted
            $This.Prefix    = $Node.Prefix
            $This.Netmask   = $Node.Netmask
            $This.Gateway   = $Node.gateway
            $This.Dns       = $Node.Dns
            $This.Dhcp      = $Node.Dhcp
            $This.Transmit  = 13000
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Network.Item>"
        }
    }

    Class NewVmControllerNodeSecurity
    {
        Hidden [String]  $Name
        [Object]     $Property
        [Object] $KeyProtector
        NewVmControllerNodeSecurity([String]$Name)
        {
            $This.Name         = $Name
            $This.Refresh()
        }
        Refresh()
        {
            $This.Property     = Get-VmSecurity $This.Name -EA 0
            $This.KeyProtector = Get-VmKeyProtector -VmName $This.Name -EA 0
        }
        [Void] SetVmKeyProtector()
        {
            If ($This.KeyProtector.Length -le 4)
            {
                Set-VmKeyProtector -VmName $This.Name -NewLocalKeyProtector -Verbose
                $This.Refresh()
            }
        }
        ToggleTpm()
        {
            $This.Refresh()
            If ($This.KeyProtector.Length -le 4)
            {
                $This.SetVmKeyProtector()
            }
            Switch ([UInt32]$This.Property.TpmEnabled)
            {
                0
                {
                    Enable-VmTpm -VmName $This.Name -EA 0
                }
                1
                {
                    Disable-VmTpm -VmName $This.Name -EA 0
                }
            }
            $This.Refresh()
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Security>"
        }
    }

    Class NewVmControllerNodeTemplate
    {
        [UInt32]     $Index
        [String]      $Name
        [Object]      $Role
        [Guid]        $Guid
        [String]      $Root
        [Object]    $Memory
        [Object]       $Hdd
        [UInt32]       $Gen
        [Uint32]      $Core
        [Object]   $Account
        [Object]   $Network
        [Object]     $Image
        NewVmControllerNodeTemplate([UInt32]$Index,[Object]$File)
        {
            $This.Index     = $Index
            $Item           = Import-CliXml -Path $File.Fullname
            $This.Name      = $Item.Name
            $This.Role      = $This.NewVmControllerTemplateRoleItem($Item.Role.Name)
            $This.Guid      = $Item.Guid
            $This.Root      = $Item.Root
            $This.Memory    = $This.NewVmControllerNodeByteSize("Memory",$Item.Memory.Bytes)
            $This.Hdd       = $This.NewVmControllerNodeByteSize("Hdd",$Item.Hdd.Bytes)
            $This.Gen       = $Item.Gen
            $This.Core      = $Item.Core
    
            $This.SetAccount($Item.Account)
            $This.SetNetwork($Item.Network,$Item.Node)
            $This.SetImage($Item.Image)
        }
        [Object] NewVmControllerTemplateRoleItem([String]$Name)
        {
            Return [NewVmControllerTemplateRoleItem]::New($Name)
        }
        [Object] NewVmControllerNodeByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [NewVmControllerNodeByteSize]::New($Name,$Bytes)
        }
        [Object] NewVmControllerCredentialItem([Object]$Serial)
        {
            Return [NewVmControllerCredentialItem]::New($Serial)
        }
        [Object] NewVmControllerNodeNetworkItem([Object]$Network,[Object]$Node)
        {
            Return [NewVmControllerNodeNetworkItem]::New($Network,$Node)
        }
        [Object] NewVmControllerImageObject([Object]$File,[Object]$Edition)
        {
            Return [NewVmControllerImageObject]::New($File,$Edition)
        }
        SetAccount([Object[]]$Account)
        {
            # Deserialize the accounts
            $This.Account = @( )
            
            ForEach ($Item in $Account)
            {
                $This.Account += $This.NewVmControllerCredentialItem($Item)
            }
        }
        SetNetwork([Object[]]$Network,[Object[]]$Node)
        {
            # Merge the interface and node properties
            $This.Network = @( )
    
            If ($Network.Count -eq 1)
            {
                $This.Network += $This.NewVmControllerNodeNetworkItem($Network,$Node)
            }
        
            If ($Network.Count -gt 1)
            {
                ForEach ($X in 0..($Network.Count-1))
                {
                    $This.Network += $This.NewVmControllerNodeNetworkItem($Network[$X],$Node[$X])
                }
            }
        }
        SetImage([Object]$Image)
        {
            # Merge the image object
            $This.Image = $This.NewVmControllerImageObject($Image.File,$Image.Edition)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Template>"
        }
    }

    Class NewVmControllerNodeItem
    {
        [UInt32]      $Index
        [Guid]         $Guid
        [Object]       $Name
        [Object]     $Memory
        [Object]       $Path
        [Object]        $Vhd
        [Object]    $VhdSize
        [Object] $Generation
        [UInt32]       $Core
        [Object] $SwitchName
        [Object]    $Network
        NewVmControllerNodeItem([Object]$Node)
        {
            $This.Index      = $Node.Index
            $This.Guid       = $This.NewGuid()
            $This.Name       = $Node.Name
            $This.Memory     = $This.NewVmControllerNodeByteSize("Memory",$Node.Memory)
            $This.Path       = $Node.Base, $Node.Name -join '\'
            $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $Node.Base, $Node.Name
            $This.VhdSize    = $This.NewVmControllerNodeByteSize("HDD",$Node.HDD)
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [Object] NewVmControllerNodeByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [NewVmControllerNodeByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Item>"
        }
    }

    Class NewVmControllerNodeHost
    {
        [UInt32]      $Index
        [Guid]         $Guid
        [Object]       $Name
        [Object]     $Memory
        [Object]       $Path
        [Object]        $Vhd
        [Object]    $VhdSize
        [Object] $Generation
        [UInt32]       $Core
        [Object] $SwitchName
        NewVmControllerNodeHost([UInt32]$Index,[Object]$Node)
        {
            $This.Index      = $Node.Index
            $This.Guid       = $Node.Id
            $This.Name       = $Node.Name
            $This.Memory     = $This.NewVmControllerNodeByteSize("Memory",$Node.MemoryStartup)
            $This.Path       = $Node.Path
            $This.Vhd        = $Node.HardDrives[0].Path
            $This.VhdSize    = $This.NewVmControllerNodeByteSize("HDD",$This.Drive())
            $This.Generation = $Node.Generation
            $This.Core       = $Node.ProcessorCount
            $This.SwitchName = $Node.NetworkAdapters[0].SwitchName
        }
        [UInt64] Drive()
        {
            Return Get-Item $This.Vhd | % Length
        }
        [Object] NewVmControllerNodeByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [NewVmControllerNodeByteSize]::New($Name,$Bytes)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Host>"
        }
    }

    Class NewVmControllerNodeSlot
    {
        [String] $Index
        [Guid]    $Guid
        [String]  $Name
        [String]  $Type
        NewVmControllerNodeSlot([UInt32]$Index,[Object]$Node)
        {
            $This.Index      = $Index
            $This.Guid       = $Node.Guid
            $This.Name       = $Node.Name
            $This.Type       = Switch -Regex ($Node.GetType().Name)
            {
                "NewVmControllerNodeHost"     { "Host"     }
                "NewVmControllerNodeTemplate" { "Template" }
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Slot>"
        }
    }

    Class NewVmControllerNodeScriptBlockLine
    {
        [UInt32] $Index
        [String]  $Line
        NewVmControllerNodeScriptBlockLine([UInt32]$Index,[String]$Line)
        {
            $This.Index = $Index
            $This.Line  = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    Class NewVmControllerNodeScriptBlockItem
    {
        [UInt32]       $Index
        [UInt32]       $Phase
        [String]        $Name
        [String] $DisplayName
        [Object]     $Content
        [UInt32]     $Timeout
        [UInt32]    $Complete
        NewVmControllerNodeScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[UInt32]$Timeout,[String[]]$Content)
        {
            $This.Index       = $Index
            $This.Phase       = $Phase
            $This.Name        = $Name
            $This.DisplayName = $DisplayName
            $This.SetTimeout($Timeout)
            
            $This.Load($Content)
        }
        SetTimeOut([UInt32]$Timeout)
        {
            $This.Timeout     = $Timeout
        }
        Clear()
        {
            $This.Content     = @( )
        }
        Load([String[]]$Content)
        {
            $This.Clear()
            $This.Add("# $($This.DisplayName)")

            ForEach ($Line in $Content)
            {
                $This.Add($Line)
            }

            $This.Add('')
        }
        [Object] NewVmControllerNodeScriptBlockLine([UInt32]$Index,[String]$Line)
        {
            Return [NewVmControllerNodeScriptBlockLine]::New($Index,$Line)
        }
        Add([String]$Line)
        {
            $This.Content += $This.NewVmControllerNodeScriptBlockLine($This.Content.Count,$Line)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.ScriptBlock.Item>"
        }
    }

    Class NewVmControllerNodeScriptBlockController
    {
        [UInt32] $Selected
        [UInt32]    $Count
        [Object]   $Output
        NewVmControllerNodeScriptBlockController()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
            $This.Count  = 0
        }
        Reset()
        {
            ForEach ($Item in $This.Output)
            {
                $Item.Complete = 0
            }

            $This.Selected = 0
        }
        [Object] NewVmControllerNodeScriptBlockItem([UInt32]$Index,[UInt32]$Phase,[String]$Name,[String]$DisplayName,[UInt32]$Timeout,[String[]]$Content)
        {
            Return [NewVmControllerNodeScriptBlockItem]::New($Index,$Phase,$Name,$DisplayName,$Timeout,$Content)
        }
        Add([String]$Phase,[String]$Name,[String]$DisplayName,[UInt32]$Timeout,[String[]]$Content)
        {
            $This.Output += $This.NewVmControllerNodeScriptBlockItem($This.Output.Count,$Phase,$Name,$DisplayName,$Timeout,$Content)
            $This.Count   = $This.Output.Count
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        [Object] Current()
        {
            Return $This.Output[$This.Selected] 
        }
        [Object] Get([Object]$Value)
        {
            $Slot = Switch -Regex ($Value)
            {
                "^\d+$" { "Index" }
                Default { "Name"  }
            }

            Return $This.Output | ? $Slot -eq $Value
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.ScriptBlock.Controller>"
        }
    }

    Class NewVmControllerNodePropertyItem
    {
        [UInt32] $Index
        [String]  $Name
        [Object] $Value
        NewVmControllerNodePropertyItem([UInt32]$Index,[Object]$Property)
        {
            $This.Index = $Index
            $This.Name  = $Property.Name
            $This.Value = $Property.Value
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Property.Item>"
        }
    }

    Class NewVmControllerNodePropertyList
    {
        [String]   $Name
        [UInt32]  $Count
        [Object] $Output
        NewVmControllerNodePropertyList()
        {
            $This.Name = "Node.Property.List"
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerNodePropertyItem([UInt32]$Index,[Object]$Property)
        {
            Return [NewVmControllerNodePropertyItem]::New($Index,$Property)
        }
        Add([Object]$Property)
        {
            $This.Output += $This.NewVmControllerNodePropertyItem($This.Output.Count,$Property)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Property.List>"
        }
    }

    Class NewVmControllerNodeCheckpoint
    {
        Hidden [Object] $Checkpoint
        [UInt32]             $Index
        [String]              $Name
        [String]              $Type
        [DateTime]            $Time
        NewVmControllerNodeCheckPoint([UInt32]$Index,[Object]$Checkpoint)
        {
            $This.Checkpoint = $Checkpoint
            $This.Index      = $Index
            $This.Name       = $Checkpoint.Name
            $This.Type       = $Checkpoint.SnapshotType
            $This.Time       = $Checkpoint.CreationTime.ToString("MM/dd/yyyy HH:mm:ss")
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Checkpoint>"
        }
    }

    Class NewVmControllerNodeCheckpointMaster
    {
        [Object] $Output
        NewVmControllerNodeCheckpointMaster()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerNodeCheckPoint([UInt32]$Index,[Object]$Checkpoint)
        {
            Return [NewVmControllerNodeCheckPoint]::New($Index,$Checkpoint)
        }
        Add([Object]$Checkpoint)
        {
            $This.Output += $This.NewVmControllerNodeCheckpoint($This.Output.Count,$Checkpoint)
        }
        [Object] Get([Object]$Value)
        {
            $Item = Switch -Regex ($Value)
            {
                "^\d+$" { "Index" } Default { "Name" }
            }
            
            Return $This.Output | ? $Item -eq $Value
        }
        Remove([Object]$Value)
        {
            $Item = $This.Get($Value)
            If ($Item)
            {
                $This.Output = $This.Output | ? Name -ne $Item.Name
                $This.Rerank()
            }
        }
        Rerank()
        {
            $X = 0
            ForEach ($Checkpoint in $This.Output)
            {
                $Checkpoint.Index = $X
                $X ++
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Checkpoint.Master>"
        }
    }

    Class NewVmControllerNodeNetwork
    {
        [String]    $Domain
        [String]   $NetBios
        [String] $IPAddress
        [String]   $Network
        [String] $Broadcast
        [String]   $Trusted
        [UInt32]    $Prefix
        [String]   $Netmask
        [String]   $Gateway
        [String[]]     $Dns
        [Object]      $Dhcp
        [UInt32]  $Transmit
        NewVmControllerNodeNetwork([Object]$Node)
        {
            $This.Domain    = $Node.Domain
            $This.NetBios   = $Node.NetBios
            $This.IPAddress = $Node.IpAddress
            $This.Network   = $Node.Dhcp.Network
            $This.Broadcast = $Node.Dhcp.Broadcast
            $This.Trusted   = $Node.Trusted
            $This.Prefix    = $Node.Prefix
            $This.Netmask   = $Node.Netmask
            $This.Gateway   = $Node.Gateway
            $This.Dns       = $Node.Dns
            $This.Dhcp      = $Node.Dhcp
            $This.Transmit  = @(13000,$Node.Transmit)[!!$Node.Transmit]
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Network>"
        }
    }

    Class NewVmControllerNodeSmbShare
    {
        [String] $HostName
        [String] $ShareName
        [String] $Name
        [String] $PSProvider
        [String] $LocalPath
        [String] $RemotePath
        [String] $Description
        [Object] $Credential
        [UInt32] $Connected
        NewVmControllerNodeSmbShare([Object]$Smb,[Object]$Account)
        {
            $This.HostName    = $Env:ComputerName.ToLower()
            $This.ShareName   = $Smb.Name
            $This.Name        = $Smb.Name.TrimEnd("$")
            $This.PSProvider  = "FileSystem"
            $This.LocalPath   = $Smb.Path.TrimEnd("\")
            $This.Description = $Smb.Description
            $This.Credential  = $Account.Credential
        }
        [String] Read()
        {
            Return Get-Content $This.LocalStatusPath()
        }
        Clear()
        {
            Set-Content -Path $This.LocalStatusPath() -Value $Null
        }
        [String] LocalStatusPath()
        {
            Return "{0}\status" -f $This.LocalPath
        }
        [String] RemoteStatusPath()
        {
            Return "{0}\status" -f $This.RemotePath
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.SmbShare>"
        }
    }

    Class NewVmControllerNodeVariable
    {
        [UInt32] $Index
        [String] $Type
        [String] $Name
        [String] $Description
        NewVmControllerNodeVariable([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            $This.Index       = $Index
            $This.Type        = $Type
            $This.Name        = $Name
            $This.Description = $Description
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Variable>"
        }
    }

    Class NewVmControllerNodeVariableMaster
    {
        [Object] $Output
        NewVmControllerNodeVariableMaster()
        {
            $This.Clear()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerNodeVariable([UInt32]$Index,[String]$Type,[String]$Name,[String]$Description)
        {
            Return [NewVmControllerNodeVariable]::New($Index,$Type,$Name,$Description)
        }
        Add([String]$Type,[String]$Name,[String]$Description)
        {
            If ($Name -notin $This.Output.Name)
            {
                $This.Output += $This.NewVmControllerNodeVariable($This.Output.Count,$Type,$Name,$Description)
            }
        }
        [Object] Get([Object]$Value)
        {
            $Slot = Switch -Regex ($Value)
            {
                "^\d+$" { "Index" } Default { "Name" }
            }

            Return $This.Output | ? $Slot -eq $Value
        }
        Remove([Object]$Value)
        {
            $Item = $This.Get($Value)
            If ($Item)
            {
                $This.Output = $This.Output | ? Name -ne $Item.Name
                $This.Rerank()
            }
        }
        Rerank()
        {
            $X = 0
            ForEach ($Variable in $This.Output)
            {
                $Variable.Index = $X
                $X ++
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Variable.Master>"
        }
    }

    Class NewVmControllerNodeTransmit
    {
        [String]        $Name
        [String] $DisplayName
        [String[]]   $Content
        NewVmControllerNodeTransmit([String]$Name,[String]$DisplayName,[String[]]$Content)
        {
            $This.Name        = $Name
            $This.DisplayName = $DisplayName
            $This.Content     = $Content
        }
        [Object] JsonString()
        {
            Return ($This | ConvertTo-Json) -Split "`n"
        }
    }

    Class NewVmControllerNodeObject
    {
        Hidden [Object]   $Object
        Hidden [UInt32]     $Mode
        [Object]         $Console
        [Object]            $Name
        [Object]            $Role
        [Object]            $Guid
        [Object]            $Path
        [Object]          $Memory
        [Object]         $VhdSize
        [Object]             $Vhd
        [Object]      $Generation
        [UInt32]            $Core
        [Object]          $Switch
        [Object]        $Firmware
        [UInt32]          $Exists
        [Object]         $Account
        [Object]         $Network
        [Object]           $Image
        [Object]          $Script
        [Object]      $Checkpoint
        Hidden [Object] $Security
        Hidden [Object] $Property
        Hidden [Object]  $Control
        Hidden [Object] $Keyboard
        Hidden [Object]      $Smb
        Hidden [Object] $Variable
        NewVmControllerNodeObject([Object]$Node)
        {
            # Meant to build a new VM
            $This.Mode       = 1
            $This.Name       = $Node.Name
            $This.Role       = $Node.Role

            $This.StartConsole()
            [Void]$This.Get()

            Switch ($This.Exists)
            {
                0
                {
                    $This.Guid       = $Node.Guid
                    $This.Path       = "{0}\{1}" -f $Node.Root, $Node.Name
                    $This.Vhd        = "{0}\{1}\{1}.vhdx" -f $Node.Root, $Node.Name
                    $This.Memory     = $This.NewVmControllerNodeByteSize("Memory",$Node.Memory.Bytes)
                    $This.VhdSize    = $This.NewVmControllerNodeByteSize("Hdd",$Node.Hdd.Bytes)
                    $This.Generation = $Node.Gen
                    $This.Core       = $Node.Core
                    $This.Switch     = @($Node.Network.Switch)
                }
                1
                {
                    $This.Memory     = $This.NewVmControllerNodeByteSize("Ram",$This.Object.MemoryStartup)
                    $This.Path       = $This.Object.Path
                    $xVhd            = Get-Vhd $This.Object.HardDrives[0].Path
                    $This.Vhd        = @($xVhd.Path,$xVhd.ParentPath)[!!$xVhd.ParentPath]
                    $This.VhdSize    = $This.NewVmControllerNodeByteSize("Hdd",$xVhd.Size)
                    $This.Generation = $This.Object.Generation
                    $This.Core       = $This.Object.ProcessorCount
                    $This.Switch     = @($This.Object.NetworkAdapters.SwitchName)
                }
            }

            $This.Account    = $Node.Account
            $This.Network    = $Node.Network
            $This.Image      = $Node.Image
            $This.Script     = $This.NewVmControllerNodeScriptBlockController()
            $This.Security   = $This.NewVmControllerNodeSecurity()
            $This.Checkpoint = $This.NewVmControllerNodeCheckpointMaster()
            $This.Variable   = $This.NewVmControllerNodeVariableMaster()
        }
        StartConsole()
        {
            # Instantiates and initializes the console
            $This.Console = New-FEConsole
            $This.Console.Initialize()
            $This.Status()
        }
        Status()
        {
            # If enabled, shows the last item added to the console
            If ($This.Mode -gt 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        Error([String]$Status)
        {
            $This.Console.Update(-1,$Status)
            Throw $This.Console.Last().Status
        }
        DumpConsole()
        {
            $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
            $This.Update(100,"[+] Dumping console: [$xPath]")
            $This.Console.Finalize()
            
            $Value = $This.Console.Output | % ToString

            [System.IO.File]::WriteAllLines($xPath,$Value)
        }
        [String] LogPath()
        {
            $xPath = $This.ProgramData()

            ForEach ($Folder in $This.Author(), "Logs")
            {
                $xPath = $xPath, $Folder -join "\"
                If (![System.IO.Directory]::Exists($xPath))
                {
                    [System.IO.Directory]::CreateDirectory($xPath)
                }
            }

            Return $xPath
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [Object] Wmi([String]$Type)
        {
            Return Get-WmiObject $Type -Namespace Root\Virtualization\V2
        }
        [Object] NewVmControllerNodeByteSize([String]$Name,[UInt64]$Bytes)
        {
            Return [NewVmControllerNodeByteSize]::New($Name,$Bytes)
        }
        [Object] NewVmControllerNodeNetwork([Object]$Node)
        {
            Return [NewVmControllerNodeNetwork]::New($Node)
        }
        [Object] NewVmControllerNodePropertyList()
        {
            Return [NewVmControllerNodePropertyList]::New()
        }
        [Object] NewVmControllerNodeScriptBlockController()
        {
            Return [NewVmControllerNodeScriptBlockController]::New()
        }
        [Object] NewVmControllerNodeSecurity()
        {
            Return [NewVmControllerNodeSecurity]::New($This.Name)
        }
        [Object] NewVmControllerNodeSmbShare([Object]$Smb,[Object]$Account)
        {
            Return [NewVmControllerNodeSmbShare]::New($Smb,$Account)
        }
        [Object] NewVmControllerNodeVariableMaster()
        {
            Return [NewVmControllerNodeVariableMaster]::New()
        }
        [Object] NewVmControllerNodeCheckpointMaster()
        {
            Return [NewVmControllerNodeCheckpointMaster]::New()
        }
        [Object] Get()
        {
            $This.Object   = Get-VM -Name $This.Name -EA 0
            $This.Exists   = $This.Object.Count -gt 0
            $This.Guid     = @($Null,$This.Object.Id)[$This.Exists]

            Return @($Null,$This.Object)[$This.Exists]
        }
        [String] Hostname()
        {
            Return [Environment]::MachineName
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [String] GuestName()
        {
            Return $This.Network.Hostname()
        }
        Connect()
        {
            $This.Update(0,"[~] Connecting : $($This.Name)")
            $Splat           = @{

                Filepath     = "vmconnect"
                ArgumentList = @($This.Hostname(),$This.Name)
                Verbose      = $True
                PassThru     = $True
            }

            Start-Process @Splat
        }
        New()
        {
            $Null = $This.Get()
            If ($This.Exists -ne 0)
            {
                $This.Error("[!] Exists : $($This.Name)")
            }

            $Splat                = @{

                Name               = $This.Name
                MemoryStartupBytes = $This.Memory.Bytes
                Path               = $This.Path
                NewVhdPath         = $This.Vhd
                NewVhdSizeBytes    = $This.VhdSize.Bytes
                Generation         = $This.Generation
                SwitchName         = $This.Switch[0]
            }

            $This.Update(0,"[~] Creating : $($This.Name)")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { New-VM @Splat }
                2       { New-VM @Splat -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VMMemory -VmName $This.Name -DynamicMemoryEnabled 0 }
                2       { Set-VMMemory -VmName $This.Name -DynamicMemoryEnabled 0 -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Enable-VmResourceMetering -VmName $This.Name }
                2       { Enable-VmResourceMetering -VmName $This.Name -Verbose }
            }

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-Vm -Name $This.Name -CheckpointType Standard } 
                2       { Set-Vm -Name $This.Name -CheckpointType Standard -Verbose -EA 0 } 
            }

            $Item                  = $This.Get()
            $This.Firmware         = $This.GetVmFirmware()
            $This.SetVMProcessor()
            $This.Security.Refresh()

            $This.Script           = $This.NewVmControllerNodeScriptBlockController()
            $This.Property         = $This.NewVmControllerNodePropertyList()

            ForEach ($Property in $Item.PSObject.Properties)
            {
                $This.Property.Add($Property)
            }
        }
        Start()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error("[!] Exception : $($This.Name) [does not exist]")
            }
            
            ElseIf ($Vm.State -eq "Running")
            {
                $This.Error("[!] Exception : $($This.Name) [already started]")
            }

            Else
            {
                $This.Update(1,"[~] Starting : $($This.Name)")

                # Verbosity level
                Switch ($This.Mode) 
                { 
                    Default { $Vm | Start-VM }
                    2       { $Vm | Start-VM -Verbose }
                }
            }
        }
        Stop()
        {
            [Void]$This.Get()
            If (!$This.Object)
            {
                $This.Error("[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($This.Object.State -ne "Running")
            {
                $This.Error("[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Stopping : $($This.Name)")
            
                # Verbosity level
                Switch ($This.Mode)
                {
                    Default { $This.Get() | ? State -ne Off | Stop-VM -Force }
                    2       { $This.Get() | ? State -ne Off | Stop-VM -Force -Verbose }
                }
            }
        }
        Reset()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error("[!] Exception : $($This.Name) [does not exist]")
            }

            ElseIf ($Vm.State -ne "Running")
            {
                $This.Error("[!] Exception : $($This.Name) [not running]")
            }

            Else
            {
                $This.Update(0,"[~] Restarting : $($This.Name)")
                $This.Stop()
                $This.Start()
                $This.Idle(5,5)
            }
        }
        Remove()
        {
            $Vm = $This.Get()
            If (!$Vm)
            {
                $This.Error("[!] Exception : $($This.Name) [does not exist]")
            }

            $This.Update(0,"[~] Removing : $($This.Name)")

            If ($Vm.State -ne "Off")
            {
                $This.Update(0,"[~] State : $($This.Name) [attempting shutdown]")
                Switch -Regex ($Vm.State)
                {
                    "(^Paused$|^Saved$)"
                    { 
                        $This.Start()
                        Do
                        {
                            Start-Sleep 1
                        }
                        Until ($This.Get().State -eq "Running")
                    }
                }

                $This.Stop()
                Do
                {
                    Start-Sleep 1
                }
                Until ($This.Get().State -eq "Off")
            }

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { $This.Get() | Remove-VM -Confirm:0 -Force -EA 0 } 
                2       { $This.Get() | Remove-VM -Confirm:0 -Force -Verbose -EA 0 } 
            }
            
            $This.Firmware         = $Null
            $This.Exists           = 0

            $This.Update(0,"[~] Vhd  : [$($This.Vhd)]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Remove-Item $This.Vhd -Confirm:0 -Force -EA 0 } 
                2       { Remove-Item $This.Vhd -Confirm:0 -Force -Verbose -EA 0 } 
            }
            
            $This.Update(0,"[~] Path : [$($This.Path)]")

            # Verbosity level
            Switch ($This.Mode)
            { 
                Default { Remove-Item $This.Path -Recurse -Confirm:$False -EA 0 } 
                2       { Remove-Item $This.Path -Recurse -Confirm:$False -Verbose -EA 0 } 
            }
            
            $Parent = Split-Path $This.Path -Parent
            $Leaf   = Split-Path $Parent -Leaf
            If ($Leaf -eq $This.Name)
            {
                $This.Update(0,"[~] $Parent")

                # Verbosity level
                Switch ($This.Mode)
                { 
                    Default { Remove-Item $Parent -Recurse -Confirm:$False -EA 0 } 
                    2       { Remove-Item $Parent -Recurse -Confirm:$False -Verbose -EA 0 } 
                }

                $This.Update(1,"[ ] Removed : $Parent")
            }

            $This.DumpConsole()
        }
        [Object] Measure()
        {
            If (!$This.Exists)
            {
                Throw "Cannot measure a virtual machine when it does not exist"
            }

            Return Measure-Vm -Name $This.Name
        }
        [String] GetRegistryPath()
        {
            Return "HKLM:\Software\Policies\Secure Digits Plus LLC"
        }
        [Object] GetVmFirmware()
        {
            $This.Update(0,"[~] Getting VmFirmware : $($This.Name)")
            $Item = Switch ($This.Generation) 
            { 
                1
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    { 
                        Default { Get-VmBios -VmName $This.Name } 
                        2       { Get-VmBios -VmName $This.Name -Verbose } 
                    }
                }
                2 
                {
                    # Verbosity level
                    Switch ($This.Mode)
                    {
                        Default { Get-VmFirmware -VmName $This.Name }
                        2       { Get-VmFirmware -VmName $This.Name -Verbose }
                    }
                } 
            }

            Return $Item
        }
        [Object] GetVmDvdDrive()
        {
            $This.Update(0,"[~] Getting VmDvdDrive : $($This.Name)")
            $Item = Switch ($This.Mode)
            { 
                Default { Get-VmDvdDrive -VmName $This.Name } 
                2       { Get-VmDvdDrive -VmName $This.Name -Verbose } 
            }

            Return $Item
        }
        SetVmProcessor()
        {
            $This.Update(0,"[~] Setting VmProcessor (Count): [$($This.Core)]")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmProcessor -VMName $This.Name -Count $This.Core }
                2       { Set-VmProcessor -VMName $This.Name -Count $This.Core -Verbose }
            }
        }
        SetVmDvdDrive([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error("[!] Invalid path : [$Path]")
            }

            $This.Update(0,"[~] Setting VmDvdDrive (Path): [$Path]")

            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Path } 
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Path -Verbose }
            }
        }
        SetVmBootOrder([UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $This.Update(0,"[~] Setting VmFirmware (Boot order) : [$1,$2,$3]")

            $Fw = $This.GetVmFirmware()
                
            # Verbosity level
            Switch ($This.Mode) 
            { 
                Default { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] } 
                2       { Set-VMFirmware -VMName $This.Name -BootOrder $Fw.BootOrder[$1,$2,$3] -Verbose } 
            }
        }
        SetVmSecureBoot([String]$Template)
        {
            $This.Update(0,"[~] Setting VmFirmware (Secure Boot) On, $Template")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VMFirmware -VMName $This.Name -EnableSecureBoot On -SecureBootTemplate $Template }
                2       { Set-VMFirmware -VMName $This.Name -EnableSecureBoot On -SecureBootTemplate $Template -Verbose }
            }
        }
        AddVmDvdDrive()
        {
            $This.Update(0,"[+] Adding VmDvdDrive")

            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Add-VmDvdDrive -VMName $This.Name }
                2       { Add-VmDvdDrive -VMName $This.Name -Verbose }
            }
        }
        AddVmNetworkAdapter([String]$SwitchName,[String]$Name)
        {
            $This.Update(0,"[+] Adding VmNetworkAdapter")

            # Verbosity level

            $Splat = @{ 

                VmName     = $This.name
                SwitchName = $SwitchName
                Name       = $Name
            }

            Switch ($This.Mode)
            {
                Default { Add-VMNetworkAdapter @Splat }
                2       { Add-VMNetworkAdapter @Splat -Verbose }
            }
        }
        LoadIso()
        {
            $Item = $This.GetVmDvdDrive()
            If (!$Item.Path -or $Item.Path -ne $This.Image.File.Fullname)
            {
                $This.LoadIso($This.Image.File.Fullname)
            }
        }
        LoadIso([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                $This.Error("[!] Invalid ISO path : [$Path]")
            }

            Else
            {
                $This.SetVmDvdDrive($Path)
            }
        }
        UnloadIso()
        {
            $This.Update(0,"[+] Unloading ISO")
            
            # Verbosity level
            Switch ($This.Mode)
            {
                Default { Set-VmDvdDrive -VMName $This.Name -Path $Null }
                2       { Set-VmDvdDrive -VMName $This.Name -Path $Null -Verbose }
            }
        }
        SetIsoBoot()
        {
            If ($This.Generation -eq 2)
            {
                $This.SetVmBootOrder(2,0,1)
            }
        }
        [String[]] GetMacAddress()
        {
            $String = $This.Get().NetworkAdapters[0].MacAddress
            $Mac    = ForEach ($X in 0,2,4,6,8,10)
            {
                $String.Substring($X,2)
            }

            Return $Mac -join "-"
        }
        CheckpointNew()
        {
            $ID = "{0}-{1}" -f $This.Name, $This.Now()
            $This.Update(0,"[~] New Checkpoint [$ID]")

            # Verbosity level
            Switch ($This.Mode)
            { 
                Default { $This.Get() | Checkpoint-Vm -SnapshotName $ID }
                2       { $This.Get() | Checkpoint-Vm -SnapshotName $ID -Verbose -EA 0 } 
            }

            $This.CheckpointRefresh()
        }
        CheckpointRefresh()
        {
            $This.Update(0,"[~] Refreshing Checkpoint(s)")
            $This.Checkpoint.Clear()

            $List = Switch ($This.Mode)
            { 
                Default { Get-VmCheckpoint -VMName $This.Name -EA 0 } 
                2       { Get-VmCheckpoint -VMName $This.Name -Verbose -EA 0 } 
            }
            
            If ($List.Count -gt 0)
            {
                ForEach ($Item in $List)
                {
                    $This.Checkpoint.Add($Item)
                }
            }
        }
        [Object] CheckpointGet([Object]$Value)
        {
            $Item = $This.Checkpoint.Get($Value)
            If (!$Item)
            {
                $This.Update(0,"[!] Invalid checkpoint")
                Throw $This.Console.Last().Status
            }

            Return $Item
        }
        CheckpointRestore([Object]$Value)
        {
            $Item = $This.CheckpointGet($Value)
            If ($Item)
            {
                $This.Update(0,"[~] Restoring Checkpoint [$($Item.Name)]")

                # Verbosity level
                Switch ($This.Mode) 
                { 
                    Default { Restore-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -EA 0 }
                    2       { Restore-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -Verbose -EA 0 } 
                }
            }
        }
        CheckpointRemove([Object]$Value)
        {
            $Item = $This.Checkpoint.Get($Value)
            If ($Item)
            {
                $This.Update(0,"[~] Removing Checkpoint [$($Item.Name)]")

                # Verbosity level
                Switch ($This.Mode) 
                { 
                    Default { Remove-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -EA 0 }
                    2       { Remove-VMCheckpoint -Name $Item.Name -VMName $This.Name -Confirm:0 -Verbose -EA 0 } 
                }

                $This.Checkpoint.Remove($Item.Index)
            }
        }
        KeyEntry([Char]$Char)
        {
            $Int = [UInt32]$Char
                
            If ($Int -in @(33..38+40..43+58+60+62..90+94+95+123..126))
            {
                Switch ($Int)
                {
                    {$_ -in 65..90}
                    {
                        # Lowercase
                        $Int = [UInt32][Char]([String]$Char).ToUpper()
                    }
                    {$_ -in 33,64,35,36,37,38,40,41,94,42}
                    {
                        # Shift+number symbols
                        $Int = Switch ($Int)
                        {
                            33  { 49 } 64  { 50 } 35  { 51 }
                            36  { 52 } 37  { 53 } 94  { 54 }
                            38  { 55 } 42  { 56 } 40  { 57 }
                            41  { 48 }
                        }
                    }
                    {$_ -in 58,43,60,95,62,63,126,123,124,125,34}
                    {
                        # Non-number symbols
                        $Int = Switch ($Int)
                        {
                            58  { 186 } 43  { 187 } 60  { 188 } 
                            95  { 189 } 62  { 190 } 63  { 191 } 
                            126 { 192 } 123 { 219 } 124 { 220 } 
                            125 { 221 } 34  { 222 }
                        }
                    }
                }

                [Void]$This.Keyboard.PressKey(16)
                Start-Sleep -Milliseconds 10
                
                [Void]$This.Keyboard.TypeKey($Int)
                Start-Sleep -Milliseconds 10

                [Void]$This.Keyboard.ReleaseKey(16)
                Start-Sleep -Milliseconds 10
            }
            Else
            {
                Switch ($Int)
                {
                    {$_ -in 97..122} # Lowercase
                    {
                        $Int = [UInt32][Char]([String]$Char).ToUpper()
                    }
                    {$_ -in 48..57} # Numbers
                    {
                        $Int = [UInt32][Char]$Char
                    }
                    {$_ -in 32,59,61,44,45,46,47,96,91,92,93,39}
                    {
                        $Int = Switch ($Int)
                        {
                            32  {  32 } 59  { 186 } 61  { 187 } 
                            44  { 188 } 45  { 189 } 46  { 190 }
                            47  { 191 } 96  { 192 } 91  { 219 }
                            92  { 220 } 93  { 221 } 39  { 222 }
                        }
                    }
                }

                [Void]$This.Keyboard.TypeKey($Int)
                Start-Sleep -Milliseconds 30
            }
        }
        LineEntry([String]$String)
        {
            ForEach ($Char in [Char[]]$String)
            {
                $This.KeyEntry($Char)
            }
        }
        TypeKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Typing key : [$Index]")
            $This.Keyboard.TypeKey($Index)
            Start-Sleep -Milliseconds 125
        }
        PressKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Pressing key : [$Index]")
            $This.Keyboard.PressKey($Index)
        }
        ReleaseKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Releasing key : [$Index]")
            $This.Keyboard.ReleaseKey($Index)
        }
        SpecialKey([UInt32]$Index)
        {
            $This.Update(0,"[+] Special key : [$Index]")
            $This.Keyboard.PressKey(18)
            $This.Keyboard.TypeKey($Index)
            $This.Keyboard.ReleaseKey(18)
        }
        ShiftKey([UInt32[]]$Index)
        {
            $This.Update(0,"[+] Shift key : [$Index]")
            $This.Keyboard.PressKey(16)
            ForEach ($X in $Index)
            {
                $This.Keyboard.TypeKey($X)
            }
            $This.Keyboard.ReleaseKey(16)
        }
        AltKey([UInt32[]]$Index)
        {
            $This.Update(0,"[+] Alt key : [$Index]")
            $This.Keyboard.PressKey(16)
            ForEach ($X in $Index)
            {
                $This.Keyboard.TypeKey($X)
            }
            $This.Keyboard.ReleaseKey(16)
        }
        CtrlKey([UInt32[]]$Index)
        {
            $This.Update(0,"[+] Ctrl key : [$Index]")
            $This.Keyboard.PressKey(18)
            ForEach ($X in $Index)
            {
                $This.Keyboard.TypeKey($X)
            }
            $This.Keyboard.ReleaseKey(18)
        }
        WinKey([UInt32[]]$Index)
        {
            $This.Update(0,"[+] Win key : [$Index]")
            $This.Keyboard.PressKey(91)
            ForEach ($X in $Index)
            {
                $This.Keyboard.TypeKey($X)
            }
            $This.Keyboard.ReleaseKey(91)
        }
        TypeCtrlAltDel()
        {
            $This.Update(0,"[+] Typing (CTRL + ALT + DEL)")
            $This.Keyboard.TypeCtrlAltDel()
        }
        TypeChain([UInt32[]]$Array)
        {
            ForEach ($Key in $Array)
            {
                $This.TypeKey($Key)
                Start-Sleep -Milliseconds 125
            }
        }
        TypeLine([String]$String)
        {
            $This.Update(0,"[+] Typing line")
            $This.LineEntry($String)
        }
        TypeText([String]$String)
        {
            $This.Update(0,"[+] Typing text : [$String]")
            $This.LineEntry($String)
        }
        TypeMask([String]$String)
        {
            $This.Update(0,"[+] Typing text : [<Masked>]")
            $This.LineEntry($String)
        }
        TypePassword([Object]$Account)
        {
            $This.Update(0,"[+] Typing password : [<Password>]")
            $This.LineEntry($Account.Password())
            Start-Sleep -Milliseconds 125
        }
        Idle([UInt32]$Percent,[UInt32]$Seconds)
        {
            $This.Update(0,"[~] Idle : $($This.Name) [CPU <= $Percent% for $Seconds second(s)]")
            
            $C = 0
            Do
            {
                Switch ([UInt32]($This.Get().CpuUsage -le $Percent))
                {
                    0 { $C = 0 } 1 { $C ++ }
                }

                Start-Sleep -Seconds 1
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Idle complete")
        }
        Uptime([UInt32]$Mode,[UInt32]$Seconds)
        {
            $Mark = @("<=",">=")[$Mode]
            $Flag = 0
            $This.Update(0,"[~] Uptime : $($This.Name) [Uptime $Mark $Seconds second(s)]")
            Do
            {
                Start-Sleep -Seconds 1
                $Uptime        = $This.Get().Uptime.TotalSeconds
                [UInt32] $Flag = Switch ($Mode) { 0 { $Uptime -le $Seconds } 1 { $Uptime -ge $Seconds } }
            }
            Until ($Flag)
            $This.Update(1,"[+] Uptime complete")
        }
        Timer([UInt32]$Seconds)
        {
            $This.Update(0,"[~] Timer : $($This.Name) [Span = $Seconds]")

            $C = 0
            Do
            {
                Start-Sleep -Seconds 1
                $C ++
            }
            Until ($C -ge $Seconds)

            $This.Update(1,"[+] Timer")
        }
        Connection()
        {
            $This.Update(0,"[~] Connection : $($This.Name) [Await response]")

            Do
            {
                Start-Sleep 1
            }
            Until (Test-Connection $This.Network.IpAddress -EA 0)

            $This.Update(1,"[+] Connection")
        }
        [Void] AddScript([UInt32]$Phase,[String]$Name,[String]$DisplayName,[UInt32]$Timeout,[String[]]$Content)
        {
            $This.Script.Add($Phase,$Name,$DisplayName,$Timeout,$Content)
            $This.Update(0,"[+] Added (Script) : $Name")
        }
        [Object] GetScript([Object]$Value)
        {
            $Item = $This.Script.Get($Value)
            If (!$Item)
            {
                Return $Null
            }
            Else
            {
                Return $Item
            }
        }
        [Void] RunScript()
        {
            $Current = $This.Script.Current()

            If ($Current.Complete -eq 1)
            {
                $This.Error("[!] Exception (Script) : [$($Current.Name)] already completed")
            }

            $This.Update(0,"[~] Running (Script) : [$($Current.Name)]")

            ForEach ($Line in $Current.Content)
            {
                Switch -Regex ($Line)
                {
                    "^\<Idle\[\d+\,\d+\]\>$"
                    {
                        $X = [Regex]::Matches($Line,"\d+").Value
                        $This.Idle($X[0],$X[1])
                    }
                    "^\<Uptime\[\d+\,\d+\]\>$"
                    {
                        $X = [Regex]::Matches($Line,"\d+").Value
                        $This.Uptime($X[0],$X[1])
                    }
                    "^\<Timer\[\d+\]\>$"
                    {
                        $X = [Regex]::Matches($Line,"\d+").Value
                        $This.Timer($X)
                    }
                    "^\<Pass\[.+\]\>$"
                    {
                        $Line = $Matches[0].Substring(6).TrimEnd(">").TrimEnd("]")
                        $This.TypeMask($Line)
                        $This.TypeKey(13)
                    }
                    "^$"
                    {
                        $This.Idle(5,2)
                    }
                    Default
                    {
                        $This.TypeLine($Line)
                        $This.TypeKey(13)
                    }
                }
            }
            
            $This.Update(1,"[+] Complete (Script) : [$($Current.Name)]")

            $Current.Complete = 1
            $This.Script.Selected ++
        }
        [Void] TransmitScript()
        {
            $Current    = $This.Script.Current()

            If ($Current.Complete -eq 1)
            {
                $This.Error("[!] Exception (Script) : [$($Current.Name)] already completed")
            }

            $This.Update(0,"[~] Transmitting (Script) : [$($Current.Name)]")

            $Content = ForEach ($Line in $Current.Content.Line)
            {
                Switch -Regex ($Line)
                {
                    "^\<Idle\[\d+\,\d+\]\>$"
                    {
                        $Null
                    }
                    "^\<Uptime\[\d+\,\d+\]\>$"
                    {
                        $Null
                    }
                    "^\<Timer\[\d+\]\>$"
                    {
                        $Null
                    }
                    "^\<Pass\[.+\]\>$"
                    {
                        $Null
                    }
                    "^$"
                    {
                        $Null
                    }
                    Default
                    {
                        $Line
                    }
                }
            }

            $Source     = $This.Network.IpAddress
            $Port       = $This.Network.Transmit

            $Command    = @("`$Script = Start-TcpSession -Server -Source $Source -Port $Port",
                            '$Script.Initialize()')

            ForEach ($Item in $Command)
            {
                $This.TypeLine($Item)
                $This.TypeKey(13)
            }

            Start-TcpSession -Client -Source $Source -Port $Port -Content $Content | % Initialize

            $This.TypeLine('$Script.Content.Message -join "" | Invoke-Expression')
            $This.TypeKey(13)

            $This.Update(1,"[+] Complete (Script) : [$($Current.Name)]")

            $Current.Complete     ++
            $This.Script.Selected ++
        }
        [Object] NewVmControllerNodeTransmit([String]$Name,[String]$DisplayName,[String[]]$Scriptlet)
        {
            Return [NewVmControllerNodeTransmit]::New($Name,$DisplayName,$Scriptlet)
        }
        [String[]] TransmitScript([String]$Name,[String]$DisplayName,[String[]]$Scriptlet)
        {
            Return $This.NewVmControllerNodeTransmit($Name,$DisplayName,$Scriptlet).JsonString()
        }
        [Void] TransmitTcp([String[]]$Content)
        {
            $Splat = @{ 

                Source  = $This.Network.IpAddress
                Port    = $This.Network.Transmit
                Content = $Content
            }

            $xScript = Start-TcpSession -Client @Splat
            $xScript.Initialize()
        }
        [Void] SetSmb([Object]$Share,[Object]$Account)
        {
            $This.Smb = $This.NewVmControllerNodeSmbShare($Share,$Account)
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Object>"
        }
    }

    Class NewVmControllerNodeWindows : NewVmControllerNodeObject
    {
        NewVmControllerNodeWindows([Switch]$Flags,[Object]$Vm) : base($Flags,$Vm)
        {   
            
        }
        NewVmControllerNodeWindows([Object]$File) : base($File)
        {

        }
        [UInt32] NetworkSetupMode()
        {
            $Arp = (arp -a) -match $This.GetMacAddress() -Split " " | ? Length -gt 0

            Return !!$Arp
        }
        SetAdmin([Object]$Account)
        {
            $This.Update(0,"[~] Setting : Administrator password")
            ForEach ($X in 0..1)
            {
                $This.TypePassword($Account)
                $This.TypeKey(9)
                Start-Sleep -Milliseconds 125
            }

            $This.TypeKey(9)
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        Login([Object]$Account)
        {
            $This.Update(0,"[~] Login : [Account: $($Account.Username)")
            $This.TypeCtrlAltDel()
            $This.Timer(5)
            $This.TypePassword($Account)
            Start-Sleep -Milliseconds 125
            $This.TypeKey(13)
        }
        LaunchPs()
        {
            # Open Start Menu
            $This.PressKey(91)
            $This.TypeKey(88)
            $This.ReleaseKey(91)
            $This.Timer(2)

            Switch ($This.Role)
            {
                Server
                {
                    # Open Command Prompt
                    $This.TypeKey(65)
                    $This.Timer(2)

                    # Maximize window
                    $This.PressKey(91)
                    $This.TypeKey(38)
                    $This.ReleaseKey(91)
                    $This.Timer(1)

                    # Start PowerShell
                    If ($This.Image.Edition.DestinationName -match "Server 2016")
                    {
                        $This.TypeText("PowerShell")
                        $This.TypeKey(13)
                        $This.Timer(1)
                    }
                }
                Client
                {
                    # // Open [PowerShell]
                    $This.TypeKey(65)
                    $This.Timer(2)
                    $This.TypeKey(37)
                    $This.Timer(2)
                    $This.TypeKey(13)
                    $This.Timer(4)

                    # // Maximize window
                    $This.PressKey(91)
                    $This.TypeKey(38)
                    $This.ReleaseKey(91)
                    $This.Timer(1)
                }
            }

            # Wait for PowerShell engine to get ready for input
            $This.Idle(5,5)
        }
        [String[]] ImportFeModule()
        {
            Return 'Set-ExecutionPolicy Bypass -Scope Process -Force', 'Import-Module FightingEntropy -Force -Verbose'
        }
        SetSmbMapping()
        {
            If (!$This.Smb)
            {
                $This.Update(-1,"[!] Smb not set")
                Throw $This.Console.Last().Status
            }

            $This.TypeLine("`$Password = Read-Host `"<Enter Password>`" -AsSecureString")
            $This.TypeKey(13)
            $This.TypeMask($This.Smb.Credential.GetNetworkCredential().Password)
            $This.TypeKey(13)
            $This.TypeLine('$Credential  = [PSCredential]::New("{0}",$Password)' -f $This.Smb.Credential.Username)
            $This.TypeKey(13)

            $Scriptlet = @(
            '$Volume = Get-Volume | ? DriveLetter | % DriveLetter';
            '$Letter = "{0}:" -f ([Char[]](90..65) | ? { $_ -notin $Volume })[0]';
            '$Splat = @{';
            ' ';
            '    LocalPath  = "$Letter"';
            '    RemotePath = "\\{0}\{1}"' -f $This.Smb.HostName, $This.Smb.ShareName;
            '    Username   = $Credential.Username'
            '    Password   = $Credential.GetNetworkCredential().Password';
            '}';
            '$Share = New-SmbMapping @Splat -Verbose -EA 0';
            'If ($Share)';
            '{';
            '    Set-Content "$Letter\status" "[+] Smb mapped to ($Letter)"';
            '}')

            ForEach ($Line in $Scriptlet)
            {
                $This.TypeLine($Line)
                $This.TypeKey(13)
            }

            $This.SmbIdle(30)

            $Status = $This.Console.Last().Status
            Switch -Regex ($Status)
            {
                "^\[\!\] Smb timed out"
                { 
                    $This.Smb.Connected = 0
                } 
                "^\[\+\] Smb mapped to" 
                { 
                    $This.Smb.Connected  = 1
                    $This.Smb.RemotePath = [Regex]::Matches($Status,"\(\w\:\)").Value.Trim("(\(|\))")
                }
            }
        }
        SmbIdle([UInt32]$Timeout)
        {
            $This.Update(0,"[~] Awaiting Smb for ($Timeout) seconds")

            # Get SmbStatus block
            $Status = $Null
            $X      = 0
            Do
            {
                $Status = $This.Smb.Read()
                Start-Sleep 1
                $X ++
            }
            Until ($Status -or $X -eq $Timeout)

            If ($X -eq $Timeout)
            {
                $This.Update(0,"[!] Smb timed out")
            }
            ElseIf ($Status)
            {
                $This.Update(1,$Status)
                $This.Smb.Clear()
            }
        }
        [String] InitializeVmNode([String]$Variable)
        {
            $Line  = "`${0} = Initialize-VmNode {1} {2} {3} {4} {5} {6} {7} {8} {9} @('{10}') {11}"
            Return $Line -f $Variable.TrimStart("$"), 
                            0, 
                            $This.Name,
                            $This.Network.IpAddress,
                            $This.Network.Domain,
                            $This.Network.NetBios,
                            $This.Network.Trusted,
                            $This.Network.Prefix,
                            $This.Network.Netmask,
                            $This.Network.Gateway,
                            ($This.Network.Dns -Split ", " -join "','"),
                            $This.Network.Transmit
        }
        [String] InitializeVmNodeDhcp([String]$Variable)
        {
            $Line  = "`${0}.SetDhcp(" -f $Variable.TrimStart("$")
            $Line += "`"{0}`"," -f $This.Network.Dhcp.Name
            $Line += "`"{0}`"," -f $This.Network.Dhcp.SubnetMask
            $Line += "`"{0}`"," -f $This.Network.Dhcp.Network
            $Line += "`"{0}`"," -f $This.Network.Dhcp.StartRange
            $Line += "`"{0}`"," -f $This.Network.Dhcp.EndRange
            $Line += "`"{0}`"," -f $This.Network.Dhcp.Broadcast
            Switch ($This.Network.Dhcp.Exclusion.Count)
            {
                1
                {
                    $Line += "`"{0}`")" -f $This.Network.Dhcp.Exclusion
                }
                Default
                {
                    $Line += "@(`"{0}`"))" -f ($This.Network.Dhcp.Exclusion -join '","')
                }
            }

            Return $Line
        }
        SetTimeZone()
        {
            # [Phase 1] Set time zone
            $This.Script.Add(1,"SetTimeZone","Set time zone",5,@('Set-Timezone -Name "{0}" -Verbose' -f (Get-Timezone).Id))
        }
        SetIcmpFirewall()
        {
            $Content = Switch ($This.Role)
            {
                Server
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose'
                }
                Client
                {
                    'Get-NetFirewallRule | ? DisplayName -match "(Printer.+IcmpV4)" | Enable-NetFirewallRule -Verbose',
                    'Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -Verbose'
                }
            }

            # [Phase 2] Enable IcmpV4
            $This.Script.Add(2,"SetIcmpFirewall","Enable IcmpV4",5,@($Content))
        }
        SetWinRm()
        {
            # [Phase 3] Set WinRM (Config)
            $This.Script.Add(3,"SetWinRm","Set (WinRM Config/Self-Signed Certificate/HTTPS Listener)",30,@(
            '$Item = Get-ItemProperty "HKLM:\Software\Policies\Secure Digits Plus LLC\ComputerInfo"';
            'winrm quickconfig';
            '<Timer[2]>';
            'y';
            '<Timer[3]>';
            If ($This.Role.Name -eq "Client")
            {
                'y';
                '<Timer[3]>';
            }
            'Set-Item WSMan:\localhost\Client\TrustedHosts -Value $Item.Trusted';
            '<Timer[4]>';
            'y'))
        }
        SetWinRmFirewall()
        {
            # [Phase 4] Set WinRm (Self-Signed Certificate/HTTPS Listener/Firewall)
            $This.Script.Add(4,"SetWinRmFirewall",'Set WinRm Firewall',30,@(
            '$Item           = Get-ItemProperty "HKLM:\Software\Policies\Secure Digits Plus LLC\ComputerInfo"';
            '$IpAddress      = $Item.IpAddress'
            '$Cert           = New-SelfSignedCertificate -DnsName $IpAddress -CertStoreLocation Cert:\LocalMachine\My';
            '$Thumbprint     = $Cert.Thumbprint';
            '$Hash           = "@{Hostname=`"$IpAddress`";CertificateThumbprint=`"$Thumbprint`"}"';
            "`$Str            = `"winrm create winrm/config/Listener?Address=*+Transport=HTTPS '{0}'`"";
            'Invoke-Expression ($Str -f $Hash)'
            '$Splat          = @{';
            ' ';
            '    Name        = "WinRM/HTTPS"';
            '    DisplayName = "Windows Remote Management (HTTPS-In)"';
            '    Direction   = "In"';
            '    Action      = "Allow"';
            '    Protocol    = "TCP"';
            '    LocalPort   = 5986';
            '}';
            'New-NetFirewallRule @Splat -Verbose'))
        }
        SetRemoteDesktop()
        {
            # [Phase 5] Set Remote Desktop
            $This.Script.Add(5,"SetRemoteDesktop",'Set Remote Desktop',10,@(
            'Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0';
            'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'))
        }
        InstallFeModule()
        {
            # [Phase 6] Install [FightingEntropy()]
            $This.Script.Add(6,"InstallFeModule","Install [FightingEntropy()]",240,@(
            '[Net.ServicePointManager]::SecurityProtocol = 3072';
            'Set-ExecutionPolicy Bypass -Scope Process -Force';
            '$Link = Invoke-RestMethod "https://github.com/mcc85s/FightingEntropy/blob/main/FightingEntropy.ps1?raw=true"';
            '$Install = "{0}?raw=true" -f $Link.Trim("`n")';
            'Invoke-RestMethod $Install | Invoke-Expression';
            '$Module.Latest()';
            'Import-Module FightingEntropy'))
        }
        InstallChoco()
        {
            # [Phase 7] Install Chocolatey
            $This.Script.Add(7,"InstallChoco","Install Chocolatey",120,@(
            "Invoke-RestMethod https://chocolatey.org/install.ps1 | Invoke-Expression";
            '<Idle[10,5]>';))
        }
        InstallVsCode()
        {
            # [Phase 8] Install Visual Studio Code
            $This.Script.Add(8,"InstallVsCode","Install Visual Studio Code",120,@(
            "choco install vscode -y";
            '<Idle[10,5]>';))
        }
        InstallBossMode()
        {
            # [Phase 9] Install BossMode (vscode color theme)
            $This.Script.Add(9,"InstallBossMode","Install BossMode (vscode color theme)",60,@(
            '$FilePath     = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
            '$ArgumentList = "--install-extension SecureDigitsPlus.bossmode"';
            'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process';
            '<Idle[5,5]>';))
        }
        InstallPsExtension()
        {
            # [Phase 10] Install Visual Studio Code (PowerShell Extension)
            $This.Script.Add(10,"InstallPsExtension","Install Visual Studio Code (PowerShell Extension)",60,@(
            '$FilePath     = "$Env:ProgramFiles\Microsoft VS Code\bin\code.cmd"';
            '$ArgumentList = "--install-extension ms-vscode.PowerShell"';
            'Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow | Wait-Process';
            '<Idle[5,5]>';))
        }
        RestartComputer()
        {
            # [Phase 11] Restart computer
            $This.Script.Add(11,'Restart','Restart computer',5,@(
            'shutdown -r -t 5';
            ))
        }
        Load()
        {
            $This.SetTimeZone()
            $This.SetIcmpFirewall()
            $This.SetWinRm()
            $This.SetWinRmFirewall()
            $This.SetRemoteDesktop()
            $This.InstallFeModule()
            $This.InstallChoco()
            $This.InstallVsCode()
            $This.InstallBossMode()
            $This.InstallPsExtension()
            $This.RestartComputer()
        }
        [Object] PSSession([Object]$Account)
        {
            # Creates session object
            $This.Update(0,"[~] PSSession Token")
            $Splat = @{

                ComputerName  = $This.Network.IpAddress
                Port          = 5986
                Credential    = $Account.Credential
                SessionOption = New-PSSessionOption -SkipCACheck
                UseSSL        = $True
            }

            Return $Splat
        }
    }

    Class NewVmControllerNodeLinux : NewVmControllerNodeObject
    {
        NewVmControllerNodeLinux([Switch]$Flags,[Object]$Vm) : base($Flags,$Vm)
        {   
            
        }
        NewVmControllerNodeLinux([Object]$File) : base($File)
        {

        }
        Login([Object]$Account)
        {
            # Login
            $This.Update(0,"Login [+] [$($This.Name): $([DateTime]::Now)]")
            $This.TypeKey(9)
            $This.TypeKey(13)
            $This.Timer(1)
            $This.TypePassword($Account.Password())
            $This.TypeKey(13)
            $This.Idle(0,5)
        }
        Initial()
        {
            $This.Update(0,"Running [~] Initial Login")
            # Learn your way around...?

            $This.TypeKey(32)
            $This.Timer(1)
            $This.TypeKey(27)
            $This.Timer(1)
        }
        LaunchTerminal()
        {
            $This.Update(0,"Launching [~] Terminal")

            # // Launch terminal
            $This.TypeKey(91)
            $This.Timer(2)
            $This.TypeLine("terminal")
            $This.Timer(2)
            $This.TypeKey(13)
            $This.Timer(2)
            
            # // Maximize window
            $This.PressKey(91)
            $This.TypeKey(38)
            $This.ReleaseKey(91)
            $This.Idle(0,5)
        }
        Super([Object]$Account)
        {
            $This.Update(0,"Super User [~]")

            # // Accessing super user
            ForEach ($Key in [Char[]]"su -")
            {
                $This.LinuxKey($Key)
                Start-Sleep -Milliseconds 25
            }

            $This.TypeKey(13)
            $This.Timer(1)
            $This.LinuxPassword($Account.Password())
            $This.TypeKey(13)
            $This.Idle(5,2)
        }
        [String] RichFirewallRule()
        {
            $Line = "firewall-cmd --permanent --zone=public --add-rich-rule='"
            $Line += 'rule family="ipv4" '
            $Line += 'source address="{0}/{1}" ' -f $This.Network.Ipaddress, $This.Network.Prefix
            $Line += 'port port="3389" '
            $Line += "protocol=`"tcp`" accept'"

            Return $Line
        }
        SubscriptionInfo([Object]$User)
        {
            # [Phase 1] Set subscription service to access (yum/rpm)
            $This.Script.Add(1,"SetSubscriptionInfo","Set subscription information",@(
            "subscription-manager register";
            "<Timer[1]>";
            $User.Username;
            "<Timer[1]>";
            "<Pass[$($User.Password())]>";
            ))
        }
        GroupInstall()
        {
            # [Phase 2] Install groupinstall workgroup
            $This.Script.Add(2,"GroupInstall","Install groupinstall workgroup",@(
            "dnf groupinstall workstation -y";
            "";
            ))
        }
        InstallEpel()
        {
            # [Phase 3] (Set/Install) epel-release
            $This.Script.Add(3,"EpelRelease","Set EPEL Release Repo",@(
            'subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms';
            "<Timer[30]>";
            "";
            "dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y";
            "";
            ))
        }
        InstallPs()
        {
            # [Phase 4] (Set/Install) [PowerShell]
            $This.Script.Add(4,"InstallPs","(Set/Install) [PowerShell]",@(
            "curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo";
            "";
            "dnf install powershell -y"
            ))
        }
        InstallRdp()
        {
            # [Phase 5] Install [Remote Desktop] Tools
            $This.Script.Add(5,"InstallRdp","(Set/Install) [Remote Desktop] Tools",@(
            "dnf install tigervnc-server tigervnc -y";
            "<Timer[5]>";
            "";
            "yum --enablerepo=epel install xrdp -y";
            "<Timer[5]>";
            "";
            "systemctl start xrdp.service";
            "";
            "systemctl enable xrdp.service"
            ""
            ))
        }
        SetFirewall()
        {
            # [Phase 6] Set firewall
            $This.Script.Add(6,"SetFirewall","Set firewall rule and restart",@(
            $This.RichFirewallRule();
            "";
            "firewall-cmd --reload"
            ))
        }
        InstallVSCode()
        {
            # [Phase 7] Install [Visual Studio Code]
            $This.Script.Add(7,"InstallVsCode","(Set/Install) [Visual Studio Code]",@(
            '$Link  = "https://packages.microsoft.com"';
            '$Keys  = "{0}/keys/microsoft.asc" -f $Link';
            '$Repo  = "{0}/yumrepos/vscode" -f $Link';
            '$Path  = "/etc/yum.repos.d/vscode.repo"';
            '$Text  = @( )';
            '$Text += "[code]"';
            '$Text += "name=Visual Studio Code"';
            '$Text += "baseurl={0}" -f $Repo';
            '$Text += "enabled=1"';
            '$Text += "gpgcheck=1"';
            '$Text += "gpgkey={0}" -f $Keys';
            '[System.IO.File]::WriteAllLines($Path,$Text)';
            "";
            'rpm --import $Keys';
            "";
            'yum install code -y'
            ))
        }
        InstallPsExtension()
        {
            # [Phase 8] Install [PowerShell Extension]
            $This.Script.Add(7,"InstallPsExtension","Install [PowerShell Extension]",@(
            'code --install-extension ms-vscode.powershell'
            ))
        }
        Load([Object]$User)
        {
            $This.SubscriptionInfo($User)
            $This.GroupInstall()
            $This.InstallEpel()
            $This.InstallPs()
            $This.InstallRdp()
            $This.SetFirewall()
            $This.InstallVSCode()
            $This.InstallPsExtension()
        }
    }

    Class NewVmControllerNodeMaster
    {
        [UInt32] $Selected
        [String]     $Path
        [Object]     $Host
        [Object] $Template
        [Object]   $Object
        NewVmControllerNodeMaster()
        {
            $This.Refresh()
        }
        SetPath([String]$Path)
        {
            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Object.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        [Object] Current()
        {
            Return $This.Object[$This.Selected]
        }
        Clear([String]$Slot)
        {
            Switch -Regex ($Slot)
            {
                "Host"     { $This.Host     = @( ) }
                "Template" { $This.Template = @( ) }
                "Object"   { $This.Object   = @( ) }
            }
        }
        [Object] NewVmControllerNodeHost([UInt32]$Index,[Object]$VmNode)
        {
            Return [NewVmControllerNodeHost]::New($Index,$VmNode)
        }
        [Object] NewVmControllerNodeTemplate([UInt32]$Index,[Object]$File)
        {
            Return [NewVmControllerNodeTemplate]::New($Index,$File)
        }
        [Object] NewVmControllerNodeSlot([UInt32]$Index,[Object]$Node)
        {
            Return [NewVmControllerNodeSlot]::New($Index,$Node)
        }
        [Object] NewVmControllerNodeObject([Object]$Node)
        {
            Return [NewVmControllerNodeObject]::New($Node)
        }
        [Object] NewVmControllerNodeWindows([Object]$Node)
        {
            Return [NewVmControllerNodeWindows]::New($Node)
        }
        [Object] NewVmControllerNodeLinux([Object]$Node)
        {
            Return [NewVmControllerNodeLinux]::New($Node)
        }
        [Object[]] GetVm()
        {
            Return Get-Vm
        }
        [Object[]] GetTemplate()
        {
            Return Get-ChildItem $This.Path | ? Extension -eq .fex
        }
        [Object] Create([UInt32]$Index)
        {
            If ($Index -gt $This.Template.Count)
            {
                Throw "Invalid index"
            }

            $Temp = $This.Template[$Index]

            If ($Temp.Name -in $This.Object)
            {
                Throw "Item is already in the object list"
            }

            $Item = Switch -Regex ($Temp.Role.Name)
            {
                "(^Server$|^Client$)"
                {
                    $This.NewVmControllerNodeWindows($Temp)
                }
                "(^Unix$)"
                {
                    $This.NewVmControllerNodeLinux($Temp)
                }
            }

            Return $Item
        }
        AddTemplate([Object]$Template)
        {
            $This.Template += $This.NewVmControllerNodeTemplate($This.Template.Count,$Template)
        }
        AddHost([Object]$Node)
        {
            $This.Host     += $This.NewVmControllerNodeHost($This.Host.Count,$Node)
        }
        AddObject([Object]$Node)
        {
            $This.Object   += $This.NewVmControllerNodeSlot($This.Object.Count,$Node)
        }
        Refresh([String]$Type)
        {
            If ($Type -notin "Host","Template","Object")
            {
                Throw "Invalid type"
            }

            $This.Clear($Type)
        
            Switch ($Type)
            {
                "Host"
                {
                    ForEach ($Item in $This.GetVm())
                    {
                        $This.AddHost($Item)
                    }
                }
                "Template"
                {
                    If ($This.Path)
                    {
                        ForEach ($Item in $This.GetTemplate())
                        {
                            $This.AddTemplate($Item)
                        }
                    }
                }
                "Object"
                {
                    ForEach ($Item in $This.Host)
                    {
                        $This.Object += $This.NewVmControllerNodeSlot($This.Object.Count,$Item)
                    }

                    ForEach ($Item in $This.Template)
                    {
                        $This.Object += $This.NewVmControllerNodeSlot($This.Object.Count,$Item)
                    }
                }
            }
        }
        Refresh()
        {
            ForEach ($Item in "Host","Template","Object")
            {
                $This.Refresh($Item)
            }
        }
        [Object] Control([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                Throw "Invalid path"
            }

            Return $This.NewVmControllerNodeWindows($This.NewVmControllerNodeTemplate(0,(Get-Item $Path)))
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Node.Master>"
        }
    }

    # // ========
    # // | Xaml |
    # // ========

    Class NewVmControllerXaml
    {
        Static [String] $Content = @(
        '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
        '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
        '        Title="[FightingEntropy()]://(New-VmController)"',
        '        Height="510"',
        '        Width="640"',
        '        ResizeMode="NoResize"',
        '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2024.1.0\Graphics\icon.ico"',
        '        HorizontalAlignment="Center"',
        '        WindowStartupLocation="CenterScreen"',
        '        FontFamily="Consolas"',
        '        Background="LightYellow">',
        '    <Window.Resources>',
        '        <Style x:Key="DropShadow">',
        '            <Setter Property="TextBlock.Effect">',
        '                <Setter.Value>',
        '                    <DropShadowEffect ShadowDepth="1"/>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="ToolTip">',
        '            <Setter Property="Background" Value="#000000"/>',
        '            <Setter Property="Foreground" Value="#66D066"/>',
        '        </Style>',
        '        <Style TargetType="TabItem">',
        '            <Setter Property="Template">',
        '                <Setter.Value>',
        '                    <ControlTemplate TargetType="TabItem">',
        '                        <Border Name="Border"',
        '                                BorderThickness="2"',
        '                                BorderBrush="Black"',
        '                                CornerRadius="5"',
        '                                Margin="2">',
        '                            <ContentPresenter x:Name="ContentSite"',
        '                                              VerticalAlignment="Center"',
        '                                              HorizontalAlignment="Right"',
        '                                              ContentSource="Header"',
        '                                              Margin="5"/>',
        '                        </Border>',
        '                        <ControlTemplate.Triggers>',
        '                            <Trigger Property="IsSelected"',
        '                                     Value="True">',
        '                                <Setter TargetName="Border"',
        '                                        Property="Background"',
        '                                        Value="#4444FF"/>',
        '                                <Setter Property="Foreground"',
        '                                        Value="#FFFFFF"/>',
        '                            </Trigger>',
        '                            <Trigger Property="IsSelected"',
        '                                     Value="False">',
        '                                <Setter TargetName="Border"',
        '                                        Property="Background"',
        '                                        Value="#DFFFBA"/>',
        '                                <Setter Property="Foreground"',
        '                                        Value="#000000"/>',
        '                            </Trigger>',
        '                        </ControlTemplate.Triggers>',
        '                    </ControlTemplate>',
        '                </Setter.Value>',
        '            </Setter>',
        '        </Style>',
        '        <Style TargetType="Button">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="Padding" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Heavy"/>',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Background" Value="#DFFFBA"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="DGCombo" TargetType="ComboBox">',
        '            <Setter Property="Margin" Value="0"/>',
        '            <Setter Property="Padding" Value="2"/>',
        '            <Setter Property="Height" Value="18"/>',
        '            <Setter Property="FontSize" Value="10"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style TargetType="{x:Type TextBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="Foreground" Value="#000000"/>',
        '            <Setter Property="TextWrapping" Value="Wrap"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="{x:Type PasswordBox}" BasedOn="{StaticResource DropShadow}">',
        '            <Setter Property="TextBlock.TextAlignment" Value="Left"/>',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '            <Setter Property="Height" Value="24"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="2"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style TargetType="ComboBox">',
        '            <Setter Property="Height" Value="24"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="CheckBox">',
        '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
        '        </Style>',
        '        <Style TargetType="DataGrid">',
        '            <Setter Property="Margin"',
        '                    Value="5"/>',
        '            <Setter Property="AutoGenerateColumns"',
        '                    Value="False"/>',
        '            <Setter Property="AlternationCount"',
        '                    Value="2"/>',
        '            <Setter Property="HeadersVisibility"',
        '                    Value="Column"/>',
        '            <Setter Property="CanUserResizeRows"',
        '                    Value="False"/>',
        '            <Setter Property="CanUserAddRows"',
        '                    Value="False"/>',
        '            <Setter Property="IsReadOnly"',
        '                    Value="True"/>',
        '            <Setter Property="IsTabStop"',
        '                    Value="True"/>',
        '            <Setter Property="IsTextSearchEnabled"',
        '                    Value="True"/>',
        '            <Setter Property="SelectionMode"',
        '                    Value="Single"/>',
        '            <Setter Property="ScrollViewer.CanContentScroll"',
        '                    Value="True"/>',
        '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility"',
        '                    Value="Auto"/>',
        '        </Style>',
        '        <Style TargetType="DataGridRow">',
        '            <Setter Property="VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="VerticalContentAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="TextBlock.VerticalAlignment"',
        '                    Value="Center"/>',
        '            <Setter Property="Height" Value="20"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Style.Triggers>',
        '                <Trigger Property="AlternationIndex"',
        '                         Value="0">',
        '                    <Setter Property="Background"',
        '                            Value="White"/>',
        '                </Trigger>',
        '                <Trigger Property="AlternationIndex" Value="1">',
        '                    <Setter Property="Background"',
        '                            Value="#FFD6FFFB"/>',
        '                </Trigger>',
        '                <Trigger Property="IsMouseOver" Value="True">',
        '                    <Setter Property="ToolTip">',
        '                        <Setter.Value>',
        '                            <TextBlock TextWrapping="Wrap"',
        '                                       Width="400"',
        '                                       Background="#000000"',
        '                                       Foreground="#00FF00"/>',
        '                        </Setter.Value>',
        '                    </Setter>',
        '                    <Setter Property="ToolTipService.ShowDuration" Value="360000000"/>',
        '                </Trigger>',
        '            </Style.Triggers>',
        '        </Style>',
        '        <Style TargetType="DataGridColumnHeader">',
        '            <Setter Property="FontSize"   Value="10"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="TabControl">',
        '            <Setter Property="TabStripPlacement" Value="Top"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Setter Property="Background" Value="LightYellow"/>',
        '        </Style>',
        '        <Style TargetType="GroupBox">',
        '            <Setter Property="Foreground" Value="Black"/>',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontSize" Value="12"/>',
        '            <Setter Property="FontWeight" Value="Normal"/>',
        '        </Style>',
        '        <Style TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Gray"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="LabelGray" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="DarkSlateGray"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Center"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="LabelRed" TargetType="Label">',
        '            <Setter Property="Margin" Value="5"/>',
        '            <Setter Property="FontWeight" Value="Bold"/>',
        '            <Setter Property="Background" Value="IndianRed"/>',
        '            <Setter Property="Foreground" Value="White"/>',
        '            <Setter Property="BorderBrush" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="2"/>',
        '            <Setter Property="HorizontalContentAlignment" Value="Left"/>',
        '            <Style.Resources>',
        '                <Style TargetType="Border">',
        '                    <Setter Property="CornerRadius" Value="5"/>',
        '                </Style>',
        '            </Style.Resources>',
        '        </Style>',
        '        <Style x:Key="Line" TargetType="Border">',
        '            <Setter Property="Background" Value="Black"/>',
        '            <Setter Property="BorderThickness" Value="0"/>',
        '            <Setter Property="Margin" Value="4"/>',
        '        </Style>',
        '    </Window.Resources>',
        '    <TabControl Grid.Row="0">',
        '        <TabItem Header="Network">',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="90"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="2*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label   Grid.Column="0"',
        '                             Content="[Domain]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="NetworkDomain"/>',
        '                    <Image   Grid.Column="2"',
        '                             Name="NetworkDomainIcon"/>',
        '                    <Label   Grid.Column="3"',
        '                             Content="[NetBios]:"/>',
        '                    <TextBox Grid.Column="4"',
        '                             Name="NetworkNetBios"/>',
        '                    <Image   Grid.Column="5"',
        '                             Name="NetworkNetBiosIcon"/>',
        '                    <Button  Grid.Column="6"',
        '                             Name="NetworkSetMain"',
        '                             Content="Set"',
        '                             ToolTip="Sets the Domain and NetBios names"/>',
        '                </Grid>',
        '                <Border Grid.Row="1" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label   Grid.Column="0"',
        '                             Content="[Switch]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;Manage interfaces (adapter + config + switch)&gt;"',
        '                             IsReadOnly="True"/>',
        '                    <ComboBox Grid.Column="2"',
        '                              Name="NetworkProperty"',
        '                              SelectedIndex="0"',
        '                              IsEnabled="False">',
        '                        <ComboBoxItem Content="*"/>',
        '                        <ComboBoxItem Content="Null"/>',
        '                        <ComboBoxItem Content="Local"/>',
        '                        <ComboBoxItem Content="Internet"/>',
        '                    </ComboBox>',
        '                    <Button  Grid.Column="3"',
        '                             Content="Refresh"',
        '                             Name="NetworkRefresh"',
        '                             ToolTip="Refreshes adapters, configurations, and switches"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="3"',
        '                          Name="NetworkInterface">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="{Binding Description}"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Index"',
        '                                            Binding="{Binding Index}"',
        '                                            Width="40"/>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding Name}"',
        '                                            Width="125"/>',
        '                        <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding Type}"',
        '                                            Width="80"/>',
        '                        <DataGridTemplateColumn Header="State"',
        '                                                Width="45">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="{Binding State}"',
        '                                              IsEnabled="False"',
        '                                              Margin="0"',
        '                                              Padding="2"',
        '                                              Height="18"',
        '                                              FontSize="10"',
        '                                              VerticalContentAlignment="Center">',
        '                                        <ComboBoxItem Content="[_]"/>',
        '                                        <ComboBoxItem Content="[.]"/>',
        '                                        <ComboBoxItem Content="[+]"/>',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                        <DataGridTextColumn Header="Alias"',
        '                                            Binding="{Binding Alias}"',
        '                                            Width="*"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="4">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="60"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Type]:"/>',
        '                    <ComboBox Grid.Column="1"',
        '                              Name="NetworkSwitchType"',
        '                              SelectedIndex="0">',
        '                        <ComboBoxItem Content="External"/>',
        '                        <ComboBoxItem Content="Internal"/>',
        '                        <ComboBoxItem Content="Private"/>',
        '                    </ComboBox>',
        '                    <Label Grid.Column="2"',
        '                           Content="[Name]:"/>',
        '                    <TextBox  Grid.Column="3"',
        '                              Name="NetworkSwitchName"/>',
        '                    <Image    Grid.Column="4"',
        '                              Name="NetworkSwitchNameIcon"/>',
        '                    <Label Grid.Column="5"',
        '                           Content="[Os]:"/>',
        '                    <CheckBox Grid.Column="6"',
        '                              Name="NetworkSwitchOs"/>',
        '                </Grid>',
        '                <Grid Grid.Row="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Adapter]:"/>',
        '                    <ComboBox Grid.Column="1"',
        '                              Name="NetworkSwitchAdapter"/>',
        '                    <Button Grid.Column="2"',
        '                            Content="+"',
        '                            Name="NetworkSwitchCreate"',
        '                            ToolTip="Creates a virtual machine switch"/>',
        '                    <Button Grid.Column="3"',
        '                            Content="-"',
        '                            Name="NetworkSwitchRemove"',
        '                            ToolTip="Removes a virtual machine switch"/>',
        '                </Grid>',
        '                <Border Grid.Row="6" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="7"',
        '                      Name="NetworkBasePanel"',
        '                      Visibility="Visible">',
        '                    <Grid.RowDefinitions>',
        '                        <RowDefinition Height="*"/>',
        '                    </Grid.RowDefinitions>',
        '                    <DataGrid Name="NetworkBase">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="&lt;Connected network information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Netmask"',
        '                                                Binding="{Binding Netmask}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Notation"',
        '                                                Binding="{Binding Notation}"',
        '                                                Width="*"/>',
        '                            <DataGridTextColumn Header="Gateway"',
        '                                                Binding="{Binding Gateway}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="7"',
        '                      Name="NetworkRangePanel"',
        '                      Visibility="Collapsed">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="240"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Grid Grid.Column="0">',
        '                        <Grid.RowDefinitions>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                            <RowDefinition Height="40"/>',
        '                        </Grid.RowDefinitions>',
        '                        <Grid Grid.Row="0">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="Total:"',
        '                                   Style="{StaticResource LabelGray}"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="NetworkRangeTotal"/>',
        '                        </Grid>',
        '                        <Grid Grid.Row="1">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="90"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label Grid.Column="0"',
        '                                   Content="Notation:"',
        '                                   Style="{StaticResource LabelGray}"/>',
        '                            <TextBox Grid.Column="1"',
        '                                     Name="NetworkRangeNotation"/>',
        '                        </Grid>',
        '                        <Button Grid.Row="2"',
        '                                Content="Scan"',
        '                                Name="NetworkRangeScan"',
        '                                ToolTip="Expands notation + pings hosts + sets DHCP info"/>',
        '                    </Grid>',
        '                    <DataGrid Grid.Column="1"',
        '                              Name="NetworkRangeHost">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="&lt;Host information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="#"',
        '                                                Binding="{Binding Index}"',
        '                                                Width="35"/>',
        '                            <DataGridTextColumn Header="Status"',
        '                                                Binding="{Binding Status}"',
        '                                                Width="50"/>',
        '                            <DataGridTextColumn Header="Type"',
        '                                                Binding="{Binding Type}"',
        '                                                Width="75"/>',
        '                            <DataGridTextColumn Header="Class"',
        '                                                Binding="{Binding Class}"',
        '                                                Width="40"/>',
        '                            <DataGridTextColumn Header="IpAddress"',
        '                                                Binding="{Binding IpAddress}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="7"',
        '                      Name="NetworkDhcpPanel"',
        '                      Visibility="Collapsed">',
        '                    <DataGrid Name="NetworkDhcp"',
        '                              HeadersVisibility="None">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="&lt;DHCP information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="150"/>',
        '                            <DataGridTextColumn Header="Value"',
        '                                                Binding="{Binding Value}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="7"',
        '                      Name="NetworkAdapterPanel"',
        '                      Visibility="Collapsed">',
        '                    <DataGrid Name="NetworkAdapter"',
        '                              HeadersVisibility="None">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="&lt;Adapter information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="150"/>',
        '                            <DataGridTextColumn Header="Value"',
        '                                                Binding="{Binding Value}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="7"',
        '                      Name="NetworkConfigPanel"',
        '                      Visibility="Collapsed">',
        '                    <DataGrid Name="NetworkConfig"',
        '                              HeadersVisibility="None">',
        '                        <DataGrid.RowStyle>',
        '                            <Style TargetType="{x:Type DataGridRow}">',
        '                                <Style.Triggers>',
        '                                    <Trigger Property="IsMouseOver" Value="True">',
        '                                        <Setter Property="ToolTip">',
        '                                            <Setter.Value>',
        '                                                <TextBlock Text="&lt;IP configuration information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                            </Setter.Value>',
        '                                        </Setter>',
        '                                    </Trigger>',
        '                                </Style.Triggers>',
        '                            </Style>',
        '                        </DataGrid.RowStyle>',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Name"',
        '                                                Binding="{Binding Name}"',
        '                                                Width="150"/>',
        '                            <DataGridTextColumn Header="Value"',
        '                                                Binding="{Binding Value}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="8">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Display]:"/>',
        '                    <ComboBox Grid.Column="1"',
        '                              Name="NetworkPanel"',
        '                              SelectedIndex="0">',
        '                        <ComboBoxItem Content="Base"/>',
        '                        <ComboBoxItem Content="Range"/>',
        '                        <ComboBoxItem Content="Dhcp"/>',
        '                        <ComboBoxItem Content="Adapter"/>',
        '                        <ComboBoxItem Content="Config"/>',
        '                    </ComboBox>',
        '                    <Label Grid.Column="2"',
        '                           Content="[Network]:"/>',
        '                    <TextBox Grid.Column="3"',
        '                             Name="NetworkName"/>',
        '                    <Image Grid.Column="4"',
        '                           Name="NetworkNameIcon"/>',
        '                    <Button Grid.Column="5"',
        '                            Name="NetworkAssign"',
        '                            Content="Assign"',
        '                            ToolTip="Sets selected (interface + network) to template"/>',
        '                </Grid>',
        '            </Grid>',
        '        </TabItem>',
        '        <TabItem Header="Credential">',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                </Grid>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="130"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Credential(s)]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;Manage credential objects + accounts&gt;"',
        '                             IsReadOnly="True"/>',
        '                    <Button Grid.Column="2"',
        '                            Content="Refresh"',
        '                            Name="CredentialRefresh"',
        '                            ToolTip="Clears credentials, adds default administrator"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1"',
        '                          Name="CredentialOutput">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="&lt;Credential information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="#"',
        '                                            Binding="{Binding Index}"',
        '                                            Width="40"/>',
        '                        <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding Type}"',
        '                                            Width="90"/>',
        '                        <DataGridTextColumn Header="Username"',
        '                                            Binding="{Binding Username}"',
        '                                            Width="*"/>',
        '                        <DataGridTextColumn Header="Password"',
        '                                            Binding="{Binding Pass}"',
        '                                            Width="150"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                               Content="[Type]:"/>',
        '                    <ComboBox Grid.Column="1"',
        '                                  Name="CredentialType"',
        '                                  SelectedIndex="0">',
        '                        <ComboBoxItem Content="Setup"/>',
        '                        <ComboBoxItem Content="System"/>',
        '                        <ComboBoxItem Content="Service"/>',
        '                        <ComboBoxItem Content="User"/>',
        '                        <ComboBoxItem Content="Microsoft"/>',
        '                    </ComboBox>',
        '                    <DataGrid Grid.Column="2"',
        '                              HeadersVisibility="None"',
        '                              Name="CredentialDescription"',
        '                              Margin="10">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Description"',
        '                                                Binding="{Binding Description}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                    <Button Grid.Column="3"',
        '                            Name="CredentialCreate"',
        '                            Content="+"',
        '                            ToolTip="Create this credential"/>',
        '                    <Button Grid.Column="4"',
        '                            Name="CredentialRemove"',
        '                            Content="-"',
        '                            ToolTip="Remove this credential"/>',
        '                </Grid>',
        '                <Border Grid.Row="3" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="4">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="120"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="1"',
        '                           Content="Username:"',
        '                           Style="{StaticResource LabelGray}"/>',
        '                    <TextBox Grid.Column="2"',
        '                             Name="CredentialUsername"/>',
        '                    <Image Grid.Column="3"',
        '                           Name="CredentialUsernameIcon"/>',
        '                </Grid>',
        '                <Grid Grid.Row="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="120"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="1"',
        '                           Content="Password:"',
        '                           Style="{StaticResource LabelGray}"/>',
        '                    <PasswordBox Grid.Column="2"',
        '                                 Name="CredentialPassword"/>',
        '                    <Image Grid.Column="3"',
        '                           Name="CredentialPasswordIcon"/>',
        '                </Grid>',
        '                <Grid Grid.Row="6">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="30"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="1"',
        '                           Content="Confirm:"',
        '                           Style="{StaticResource LabelGray}"/>',
        '                    <PasswordBox Grid.Column="2"',
        '                                 Name="CredentialConfirm"/>',
        '                    <Image Grid.Column="3"',
        '                           Name="CredentialConfirmIcon"/>',
        '                    <Button Grid.Column="5"',
        '                            Name="CredentialGenerate"',
        '                            Content="Random"/>',
        '                </Grid>',
        '                <Grid Grid.Row="7">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="120"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="1"',
        '                           Content="Pin:"',
        '                           Style="{StaticResource LabelGray}"/>',
        '                    <PasswordBox Grid.Column="2"',
        '                                 Name="CredentialPin"/>',
        '                    <Image Grid.Column="3"',
        '                           Name="CredentialPinIcon"/>',
        '                </Grid>',
        '                <Border Grid.Row="8" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="9">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="1"',
        '                           Content="[Total]:"/>',
        '                    <TextBox Grid.Column="2"',
        '                             Name="CredentialCount"/>',
        '                    <Button Grid.Column="3"',
        '                        Name="CredentialAssign"',
        '                        Content="Assign"/>',
        '                </Grid>',
        '            </Grid>',
        '        </TabItem>',
        '        <TabItem Header="Image">',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="110"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0" Content="[Image]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;Select image for template to utilize&gt;"',
        '                             IsReadOnly="True"/>',
        '                    <Button Grid.Column="2"',
        '                            Content="Refresh"',
        '                            Name="ImageRefresh"',
        '                            ToolTip="Clears the image(s) stored below"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1"',
        '                          Name="ImageStore">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="&lt;(*.iso) file information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding Type}"',
        '                                            Width="90"/>',
        '                        <DataGridTextColumn Header="Version"',
        '                                            Binding="{Binding Version}"',
        '                                            Width="110"/>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding Name}"',
        '                                            Width="*"/>',
        '                        <DataGridTemplateColumn Header="[+]" Width="25">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <CheckBox IsChecked="{Binding Profile,',
        '                                              UpdateSourceTrigger=PropertyChanged}"/>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button  Grid.Column="0"',
        '                             Name="ImageImport"',
        '                             Content="Import"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="ImagePath"/>',
        '                    <Image   Grid.Column="2"',
        '                             Name="ImagePathIcon"/>',
        '                    <Button  Grid.Column="3"',
        '                             Name="ImagePathBrowse"',
        '                             Content="Browse"/>',
        '                </Grid>',
        '                <Border Grid.Row="3" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="4">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0" Content="[Edition]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;If Windows image, select edition for template to utilize&gt;"',
        '                             IsReadOnly="True"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="5"',
        '                          Name="ImageStoreContent">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="&lt;(*.wim) file information&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding DestinationName}"',
        '                                            Width="300"/>',
        '                        <DataGridTextColumn Header="Size"',
        '                                            Binding="{Binding Size}"',
        '                                            Width="80"/>',
        '                        <DataGridTextColumn Header="Label"',
        '                                            Binding="{Binding Label}"',
        '                                            Width="*"/>',
        '                        <DataGridTemplateColumn Header="[+]" Width="25">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <CheckBox IsChecked="{Binding Profile,',
        '                                              UpdateSourceTrigger=PropertyChanged}"/>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="6">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="40"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Name]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="ImageName"/>',
        '                    <Label Grid.Column="2"',
        '                           Content="[Index]:"/>',
        '                    <TextBox Grid.Column="3"',
        '                             Name="ImageIndex"/>',
        '                    <Button Grid.Column="4"',
        '                        Name="ImageAssign"',
        '                        Content="Assign"/>',
        '                </Grid>',
        '            </Grid>',
        '        </TabItem>',
        '        <TabItem Header="Template">',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="*"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="105"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0" Content="[Template]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;Set template export path&gt;"',
        '                             Name="TemplateExportPath"/>',
        '                    <Image Grid.Column="2"',
        '                           Name="TemplateExportPathIcon"/>',
        '                    <Button Grid.Column="3"',
        '                            Content="Browse"',
        '                            Name="TemplateExportBrowse"/>',
        '                    <Button Grid.Column="4"',
        '                            Content="Set"',
        '                            Name="TemplateSetPath"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1"',
        '                              Name="TemplateOutput"',
        '                              ScrollViewer.CanContentScroll="True"',
        '                              ScrollViewer.VerticalScrollBarVisibility="Auto"',
        '                              ScrollViewer.HorizontalScrollBarVisibility="Visible">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="{Binding Image}"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding Name}"',
        '                                            Width="*"/>',
        '                        <DataGridTextColumn Header="Role"',
        '                                            Binding="{Binding Role}"',
        '                                            Width="70"/>',
        '                        <DataGridTextColumn Header="Memory"',
        '                                            Binding="{Binding Memory}"',
        '                                            Width="75"/>',
        '                        <DataGridTextColumn Header="Hard Drive"',
        '                                            Binding="{Binding Hdd}"',
        '                                            Width="75"/>',
        '                        <DataGridTextColumn Header="Gen."',
        '                                            Binding="{Binding Gen}"',
        '                                            Width="40"/>',
        '                        <DataGridTextColumn Header="Cores"',
        '                                            Binding="{Binding Core}"',
        '                                            Width="40"/>',
        '                        <DataGridTemplateColumn Header="Account" Width="90">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="0"',
        '                                              Style="{StaticResource DGCombo}"',
        '                                              ItemsSource="{Binding Account}">',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                        <DataGridTemplateColumn Header="Switch" Width="90">',
        '                            <DataGridTemplateColumn.CellTemplate>',
        '                                <DataTemplate>',
        '                                    <ComboBox SelectedIndex="0"',
        '                                              Style="{StaticResource DGCombo}"',
        '                                              ItemsSource="{Binding Switch}">',
        '                                    </ComboBox>',
        '                                </DataTemplate>',
        '                            </DataGridTemplateColumn.CellTemplate>',
        '                        </DataGridTemplateColumn>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Column="0"',
        '                            Content="Create"',
        '                            Name="TemplateCreate"/>',
        '                    <Button Grid.Column="1"',
        '                            Content="Remove"',
        '                            Name="TemplateRemove"/>',
        '                    <Button Grid.Column="2"',
        '                            Content="Export"',
        '                            Name="TemplateExport"/>',
        '                </Grid>',
        '                <Border Grid.Row="3" Background="Black" Margin="4"/>',
        '                <Grid Grid.Row="4">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="105"/>',
        '                        <ColumnDefinition Width="120"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="80"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Name/Role]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="TemplateName"/>',
        '                    <Image Grid.Column="2"',
        '                           Name="TemplateNameIcon"/>',
        '                    <ComboBox Grid.Column="3" Name="TemplateRole">',
        '                        <ComboBoxItem Content="Server"/>',
        '                        <ComboBoxItem Content="Client"/>',
        '                        <ComboBoxItem Content="Unix"/>',
        '                    </ComboBox>',
        '                    <DataGrid Grid.Column="4"',
        '                              HeadersVisibility="None"',
        '                              Margin="10"',
        '                              Name="TemplateRoleDescription">',
        '                        <DataGrid.Columns>',
        '                            <DataGridTextColumn Header="Description"',
        '                                                Binding="{Binding Description}"',
        '                                                Width="*"/>',
        '                        </DataGrid.Columns>',
        '                    </DataGrid>',
        '                </Grid>',
        '                <Grid Grid.Row="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="105"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Root Path]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="TemplateRootPath"',
        '                             Text="&lt;Set virtual machine root path&gt;"/>',
        '                    <Image Grid.Column="2"',
        '                           Name="TemplateRootPathIcon"/>',
        '                    <Button Grid.Column="3"',
        '                            Name="TemplateRootPathBrowse"',
        '                            Content="Browse"/>',
        '                </Grid>',
        '                <TabControl Grid.Row="6">',
        '                    <TabItem Header="Specs">',
        '                        <Grid Height="40" VerticalAlignment="Top">',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="105"/>',
        '                                <ColumnDefinition Width="50"/>',
        '                                <ColumnDefinition Width="95"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                                <ColumnDefinition Width="110"/>',
        '                                <ColumnDefinition Width="50"/>',
        '                                <ColumnDefinition Width="95"/>',
        '                                <ColumnDefinition Width="50"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Label    Grid.Column="0"',
        '                                      Content="[Memory/GB]:"',
        '                                      Style="{StaticResource LabelRed}"/>',
        '                            <ComboBox Grid.Column="1"',
        '                                      Name="TemplateMemory"',
        '                                      SelectedIndex="0">',
        '                                <ComboBoxItem Content="2"/>',
        '                                <ComboBoxItem Content="4"/>',
        '                                <ComboBoxItem Content="8"/>',
        '                                <ComboBoxItem Content="16"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="2"',
        '                                   Content="[Drive/GB]:"',
        '                                   Style="{StaticResource LabelRed}"/>',
        '                            <ComboBox Grid.Column="3"',
        '                                      Name="TemplateHardDrive"',
        '                                      SelectedIndex="1">',
        '                                <ComboBoxItem Content="32"/>',
        '                                <ComboBoxItem Content="64"/>',
        '                                <ComboBoxItem Content="128"/>',
        '                                <ComboBoxItem Content="256"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="4"',
        '                                   Content="[Generation]:"',
        '                                   Style="{StaticResource LabelRed}"/>',
        '                            <ComboBox Grid.Column="5"',
        '                                      Name="TemplateGeneration"',
        '                                      SelectedIndex="1">',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                            </ComboBox>',
        '                            <Label Grid.Column="6"',
        '                                   Content="[CPU/Core]:"',
        '                                   Style="{StaticResource LabelRed}"/>',
        '                            <ComboBox Grid.Column="7"',
        '                                      Name="TemplateCore"',
        '                                      SelectedIndex="1">',
        '                                <ComboBoxItem Content="1"/>',
        '                                <ComboBoxItem Content="2"/>',
        '                                <ComboBoxItem Content="3"/>',
        '                                <ComboBoxItem Content="4"/>',
        '                            </ComboBox>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Switch">',
        '                        <Grid>',
        '                            <Grid.ColumnDefinitions>',
        '                                <ColumnDefinition Width="70"/>',
        '                                <ColumnDefinition Width="*"/>',
        '                            </Grid.ColumnDefinitions>',
        '                            <Grid Grid.Column="0">',
        '                                <Grid.RowDefinitions>',
        '                                    <RowDefinition Height="40"/>',
        '                                    <RowDefinition Height="*"/>',
        '                                    <RowDefinition Height="40"/>',
        '                                </Grid.RowDefinitions>',
        '                                <Button Grid.Row="0"',
        '                                        Name="TemplateNetworkUp"',
        '                                        Content="[Up]"/>',
        '                                <Button Grid.Row="2"',
        '                                        Name="TemplateNetworkDown"',
        '                                        Content="[Down]"/>',
        '                            </Grid>',
        '                            <DataGrid Grid.Column="1"',
        '                                      Name="TemplateNetworkOutput">',
        '                                <DataGrid.Columns>',
        '                                    <DataGridTextColumn Header="Alias"',
        '                                            Binding="{Binding Interface.Name}"',
        '                                            Width="125"/>',
        '                                    <DataGridTextColumn Header="Description"',
        '                                            Binding="{Binding Interface.Description}"',
        '                                            Width="*"/>',
        '                                </DataGrid.Columns>',
        '                            </DataGrid>',
        '                        </Grid>',
        '                    </TabItem>',
        '                    <TabItem Header="Credentials">',
        '                        <DataGrid Name="TemplateCredentialOutput">',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding Type}"',
        '                                            Width="90"/>',
        '                                <DataGridTextColumn Header="Username"',
        '                                            Binding="{Binding Username}"',
        '                                            Width="*"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </TabItem>',
        '                    <TabItem Header="Image">',
        '                        <DataGrid Name="TemplateImageOutput">',
        '                            <DataGrid.RowStyle>',
        '                                <Style TargetType="{x:Type DataGridRow}">',
        '                                    <Style.Triggers>',
        '                                        <Trigger Property="IsMouseOver" Value="True">',
        '                                            <Setter Property="ToolTip">',
        '                                                <Setter.Value>',
        '                                                    <TextBlock Text="{Binding Fullname}"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                                </Setter.Value>',
        '                                            </Setter>',
        '                                        </Trigger>',
        '                                    </Style.Triggers>',
        '                                </Style>',
        '                            </DataGrid.RowStyle>',
        '                            <DataGrid.Columns>',
        '                                <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding File.Type}"',
        '                                            Width="90"/>',
        '                                <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding File.Name}"',
        '                                            Width="*"/>',
        '                                <DataGridTextColumn Header="Edition"',
        '                                            Binding="{Binding Edition.Label}"',
        '                                            Width="200"/>',
        '                            </DataGrid.Columns>',
        '                        </DataGrid>',
        '                    </TabItem>',
        '                </TabControl>',
        '            </Grid>',
        '        </TabItem>',
        '        <TabItem Header="Node">',
        '            <Grid>',
        '                <Grid.RowDefinitions>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="110"/>',
        '                    <RowDefinition Height="40"/>',
        '                    <RowDefinition Height="10"/>',
        '                    <RowDefinition Height="*"/>',
        '                    <RowDefinition Height="40"/>',
        '                </Grid.RowDefinitions>',
        '                <Grid Grid.Row="0">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="90"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="90"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Label Grid.Column="0"',
        '                           Content="[Node]:"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Text="&lt;Manage virtual machine hosts + templates&gt;"',
        '                             IsReadOnly="True"/>',
        '                    <Button Grid.Column="2"',
        '                            Content="Refresh"',
        '                            Name="NodeRefresh"/>',
        '                </Grid>',
        '                <DataGrid Grid.Row="1"',
        '                          Name="NodeOutput">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="&lt;virtual machine host/template&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding Name}"',
        '                                            Width="*"/>',
        '                        <DataGridTextColumn Header="Type"',
        '                                            Binding="{Binding Type}"',
        '                                            Width="100"/>',
        '                        <DataGridTextColumn Header="Guid"',
        '                                            Binding="{Binding Guid}"',
        '                                            Width="350"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="2">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Column="0"',
        '                            Content="Create"',
        '                            Name="NodeCreate"/>',
        '                    <Button Grid.Column="1"',
        '                            Content="Remove"',
        '                            Name="NodeRemove"/>',
        '                </Grid>',
        '                <Border Grid.Row="3" Background="Black" Margin="4"/>',
        '                <DataGrid Grid.Row="4"',
        '                          Name="NodeExtension">',
        '                    <DataGrid.RowStyle>',
        '                        <Style TargetType="{x:Type DataGridRow}">',
        '                            <Style.Triggers>',
        '                                <Trigger Property="IsMouseOver" Value="True">',
        '                                    <Setter Property="ToolTip">',
        '                                        <Setter.Value>',
        '                                            <TextBlock Text="&lt;virtual machine host/template properties&gt;"',
        '                                                       TextWrapping="Wrap"',
        '                                                       FontFamily="Consolas"',
        '                                                       Background="#000000"',
        '                                                       Foreground="#00FF00"/>',
        '                                        </Setter.Value>',
        '                                    </Setter>',
        '                                </Trigger>',
        '                            </Style.Triggers>',
        '                        </Style>',
        '                    </DataGrid.RowStyle>',
        '                    <DataGrid.Columns>',
        '                        <DataGridTextColumn Header="Name"',
        '                                            Binding="{Binding Name}"',
        '                                            Width="150"/>',
        '                        <DataGridTextColumn Header="Value"',
        '                                            Binding="{Binding Value}"',
        '                                            Width="*"/>',
        '                    </DataGrid.Columns>',
        '                </DataGrid>',
        '                <Grid Grid.Row="5">',
        '                    <Grid.ColumnDefinitions>',
        '                        <ColumnDefinition Width="100"/>',
        '                        <ColumnDefinition Width="*"/>',
        '                        <ColumnDefinition Width="25"/>',
        '                        <ColumnDefinition Width="100"/>',
        '                    </Grid.ColumnDefinitions>',
        '                    <Button Grid.Column="0"',
        '                            Content="Import"',
        '                            Name="NodeImport"/>',
        '                    <TextBox Grid.Column="1"',
        '                             Name="NodePath"',
        '                             Text="&lt;Set path to import control template(s)&gt;"/>',
        '                    <Image   Grid.Column="2"',
        '                             Name="NodePathIcon"/>',
        '                    <Button  Grid.Column="3"',
        '                             Name="NodePathBrowse"',
        '                             Content="Browse"/>',
        '                </Grid>',
        '            </Grid>',
        '        </TabItem>',
        '    </TabControl>',
        '</Window>' -join "`n")
    }

    Class XamlProperty
    {
        [UInt32]   $Index
        [String]    $Name
        [Object]    $Type
        [Object] $Control
        XamlProperty([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Type    = $Object.GetType().Name
            $This.Control = $Object
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class XamlWindow
    {
        Hidden [Object]        $Xaml
        Hidden [Object]         $Xml
        [String[]]            $Names
        [Object]              $Types
        [Object]               $Node
        [Object]                 $IO
        [String]          $Exception
        XamlWindow([String]$Xaml)
        {           
            If (!$Xaml)
            {
                Throw "Invalid XAML Input"
            }

            [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

            $This.Xaml           = $Xaml
            $This.Xml            = [XML]$Xaml
            $This.Names          = $This.FindNames()
            $This.Types          = @( )
            $This.Node           = [System.Xml.XmlNodeReader]::New($This.Xml)
            $This.IO             = [System.Windows.Markup.XamlReader]::Load($This.Node)
            
            ForEach ($X in 0..($This.Names.Count-1))
            {
                $Name            = $This.Names[$X]
                $Object          = $This.IO.FindName($Name)
                $This.IO         | Add-Member -MemberType NoteProperty -Name $Name -Value $Object -Force
                If (!!$Object)
                {
                    $This.Types += $This.XamlProperty($This.Types.Count,$Name,$Object)
                }
            }
        }
        [String[]] FindNames()
        {
            Return [Regex]::Matches($This.Xaml,"( Name\=\`"\w+`")").Value -Replace "( Name=|`")",""
        }
        [Object] XamlProperty([UInt32]$Index,[String]$Name,[Object]$Object)
        {
            Return [XamlProperty]::New($Index,$Name,$Object)
        }
        [Object] Get([String]$Name)
        {
            $Item = $This.Types | ? Name -eq $Name

            If ($Item)
            {
                Return $Item
            }
            Else
            {
                Return $Null
            }
        }
        Invoke()
        {
            Try
            {
                $This.IO.Dispatcher.InvokeAsync({ $This.IO.ShowDialog() }).Wait()
            }
            Catch
            {
                $This.Exception = $PSItem
            }
        }
        [String] ToString()
        {
            Return "<FEModule.XamlWindow[VmControllerXaml]>"
        }
    }

    <#
        ____                                                                                                    ________    
    //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
    \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        ¯¯¯\\__[ DataGrid   ]__________________________________________________________________________________//¯¯¯        
            ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
    #>

        # // ================
        # // | Interface(s) |
        # // ================

    Class NewVmControllerDataGridNetworkInterfaceItem
    {
        [String]       $Index
        [String]        $Name
        [String]        $Type
        [UInt32]       $State
        [String]       $Alias
        [String]     $Display
        [String] $Description
        [String]        $Guid
        NewVmControllerDataGridNetworkInterfaceItem()
        {
            $This.Index       = ""
            $This.Name        = "<New>"
            $This.Type        = "-"
            $This.State       = 0
            $This.Alias       = "-"
            $This.Display     = "-"
            $This.Description = "-"
            $This.Guid        = "-"
        }
        NewVmControllerDataGridNetworkInterfaceItem([Object]$Interface)
        {
            $This.Index       = $Interface.Index
            $This.Name        = $Interface.Name
            $This.Type        = $Interface.Type
            $This.State       = $Interface.State.Index
            $This.Alias       = $Interface.Alias
            $This.Display     = $Interface.Display
            $This.Description = $Interface.Description
            $This.Guid        = $Interface.SwitchId
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.NetworkInterface.Item>"
        }
    }

    Class NewVmControllerDataGridNetworkInterfaceList
    {
        [Object] $Output
        NewVmControllerDataGridNetworkInterfaceList()
        {

        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerDataGridNetworkInterfaceItem()
        {
            Return [NewVmControllerDataGridNetworkInterfaceItem]::New()
        }
        [Object] NewVmControllerDataGridNetworkInterfaceItem([Object]$Interface)
        {
            Return [NewVmControllerDataGridNetworkInterfaceItem]::New($Interface)
        }
        Refresh([Object[]]$Interface)
        {
            $This.Clear()

            # [Default <new> DataGrid template]
            $This.Output += $This.NewVmControllerDataGridNetworkInterfaceItem()

            # [Adds each found interface]
            ForEach ($Item in $Interface)
            {
                $This.Output += $This.NewVmControllerDataGridNetworkInterfaceItem($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.NetworkInterface.List>"
        }
    }

        # // =================
        # // | Credential(s) |
        # // =================

    Class NewVmControllerDataGridCredentialItem
    {
        [String]    $Index
        [Guid]       $Guid
        [String]     $Type
        [String] $Username
        [String]     $Pass
        NewVmControllerDataGridCredentialItem()
        {
            $This.Index    = "-"
            $This.Type     = "<New>"
            $This.Guid     = $This.NewGuid()
        }
        NewVmControllerDataGridCredentialItem([Object]$Account)
        {
            $This.Index    = $Account.Index
            $This.Guid     = $Account.Guid
            $This.Type     = $Account.Type
            $This.Username = $Account.Username
            $This.Pass     = $Account.Pass
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.Credential.Item>"
        }
    }

    Class NewVmControllerDataGridCredentialList
    {
        [Object] $Output
        NewVmControllerDataGridCredentialList()
        {

        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerDataGridCredentialItem()
        {
            Return [NewVmControllerDataGridCredentialItem]::New()
        }
        [Object] NewVmControllerDataGridCredentialItem([Object]$Object)
        {
            Return [NewVmControllerDataGridCredentialItem]::New($Object)
        }
        Refresh([Object[]]$Object)
        {
            $This.Clear()

            # [Default <new> DataGrid template]
            $This.Output += $This.NewVmControllerDataGridCredentialItem()

            # [Adds each found credential]
            ForEach ($Item in $Object)
            {
                $This.Output += $This.NewVmControllerDataGridCredentialItem($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.Credential.List>"
        }
    }

        # // ===============
        # // | Template(s) |
        # // ===============

    Class NewVmControllerDataGridTemplateItem
    {
        [String]     $Index
        [String]      $Name
        [String]      $Role
        [String]      $Root
        [String]    $Memory
        [String]       $Hdd
        [String]       $Gen
        [String]      $Core
        [String[]] $Account
        [String[]]  $Switch
        [String]     $Image
        [Guid]        $Guid
        NewVmControllerDataGridTemplateItem()
        {
            $This.Index    = "-"
            $This.Name     = "<New>"
            $This.Account  = "-"
            $This.Switch   = "-"
            $This.Image    = "<Null template>"
            $This.Guid     = $This.NewGuid()
        }
        NewVmControllerDataGridTemplateItem([Object]$Template)
        {
            $This.Guid     = $Template.Guid
            $This.Name     = $Template.Name
            $This.Role     = $Template.Role
            $This.Root     = $Template.Root
            $This.Memory   = $Template.Memory
            $This.Hdd      = $Template.Hdd
            $This.Gen      = $Template.Gen
            $This.Core     = $Template.Core
            $This.Account  = $Template.Account.Username
            $This.Switch   = $Template.Network.Interface.Name
            $This.Image    = $Template.Image.File.Fullname
        }
        [Object] NewGuid()
        {
            Return [Guid]::NewGuid()
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.Template.Item>"
        }
    }

    Class NewVmControllerDataGridTemplateList
    {
        [Object] $Output
        NewVmControllerDataGridTemplateList()
        {

        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] NewVmControllerDataGridTemplateItem()
        {
            Return [NewVmControllerDataGridTemplateItem]::New()
        }
        [Object] NewVmControllerDataGridTemplateItem([Object]$Object)
        {
            Return [NewVmControllerDataGridTemplateItem]::New($Object)
        }
        Refresh([Object[]]$Object)
        {
            $This.Clear()

            # [Default <new> DataGrid template]
            $This.Output += $This.NewVmControllerDataGridTemplateItem()

            # [Adds each found VM template]
            ForEach ($Item in $Object)
            {
                $This.Output += $This.NewVmControllerDataGridTemplateItem($Item)
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.Template.List>"
        }
    }

        # // ==========
        # // | Master |
        # // ==========

    Class NewVmControllerDataGridMaster
    {
        [Object]    $Network
        [Object] $Credential
        [Object]   $Template
        NewVmControllerDataGridMaster()
        {
            $This.Network    = $This.NewVmControllerDataGridNetworkInterfaceList()
            $This.Credential = $This.NewVmControllerDataGridCredentialList()
            $This.Template   = $This.NewVmControllerDataGridTemplateList()
        }
        [Object] NewVmControllerDataGridNetworkInterfaceList()
        {
            Return [NewVmControllerDataGridNetworkInterfaceList]::New()
        }
        [Object] NewVmControllerDataGridCredentialList()
        {
            Return [NewVmControllerDataGridCredentialList]::New()
        }
        [Object] NewVmControllerDataGridTemplateList()
        {
            Return [NewVmControllerDataGridTemplateList]::New()
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.DataGrid.Master>"
        }
    }

    <#
        ____                                                                                                    ________    
    //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
    \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
        ¯¯¯\\__[ Master ]______________________________________________________________________________________//¯¯¯        
            ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
    #>

    Class NewVmControllerMaster
    {
        [Object]     $Module
        [Object]       $Xaml
        [Object] $Validation
        [Object]   $DataGrid
        [Object]    $Network
        [Object] $Credential
        [Object]      $Image
        [Object]   $Template
        [Object]       $Node
        NewVmControllerMaster()
        {
            # Loads module controller
            $This.Module     = $This.Get("Module")

            # Loads DataGrid master
            $This.DataGrid   = $This.Get("DataGrid")

            # Loads the network master
            $This.Network    = $This.Get("Network")

            # Loads the credential master
            $This.Credential = $This.Get("Credential")

            # Loads the image master
            $This.Image      = $This.Get("Image")

            # Loads the template master
            $This.Template   = $This.Get("Template")

            # Loads the node master
            $This.Node       = $This.Get("Node")

            $This.Reinstantiate()
        }
        Reinstantiate()
        {
            # Loads XAML
            $This.Xaml       = $This.Get("Xaml")

            # Loads validation master
            $This.Validation = $This.Get("Validation")
        
            # Creates various validation entries
            $This.SetValidation()
        }
        Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Module.Update($State,$Status)
        }
        Error([UInt32]$State,[String]$Status)
        {
            $This.Module.Update($State,$Status)
            Throw $This.Module.Console.Last().Status
        }
        DumpConsole()
        {
            $xPath = "{0}\{1}-{2}.log" -f $This.LogPath(), $This.Now(), $This.Name
            $This.Update(100,"[+] Dumping console: [$xPath]")
            $This.Console.Finalize()
            
            $Value = $This.Console.Output | % ToString

            [System.IO.File]::WriteAllLines($xPath,$Value)
        }
        [String] LogPath()
        {
            $xPath = $This.ProgramData()

            ForEach ($Folder in $This.Author(), "Logs")
            {
                $xPath = $xPath, $Folder -join "\"
                If (![System.IO.Directory]::Exists($xPath))
                {
                    [System.IO.Directory]::CreateDirectory($xPath)
                }
            }

            Return $xPath
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Author()
        {
            Return "Secure Digits Plus LLC"
        }
        [Object] Get([String]$Name)
        {
            $Item = $Null

            Switch ($Name)
            {
                Module
                { 
                    $Item = Get-FEModule -Mode 1
                    $Item.Console.Reset()
                    $Item.Mode = 0
                    $Item.Console.Initialize()
                }
                Xaml
                {
                    $This.Update(0,"Getting [~] Xaml Controller")
                    $Item = [XamlWindow][NewVmControllerXaml]::Content
                }
                Validation
                {
                    $This.Update(0,"Getting [~] Validation Master")
                    $Item = [NewVmControllerValidationMaster]::New()
                }
                DataGrid
                {
                    $This.Update(0,"Getting [~] DataGrid Master")
                    $Item = [NewVmControllerDataGridMaster]::New()
                }
                Network
                {
                    $This.Update(0,"Getting [~] Network Master")
                    $Item = [NewVmControllerNetworkMaster]::New()
                }
                Credential
                {
                    $This.Update(0,"Getting [~] Credential Master")
                    $Item = [NewVmControllerCredentialMaster]::New()
                }
                Image
                {
                    $This.Update(0,"Getting [~] Image Master")
                    $Item = [NewVmControllerImageMaster]::New()
                }
                Template
                {
                    $This.Update(0,"Getting [~] Template Master")
                    $Item = [NewVmControllerTemplateMaster]::New()
                }
                Node
                {
                    $This.Update(0,"Getting [~] Node Master")
                    $Item = [NewVmControllerNodeMaster]::New()
                }
            }

            Return $Item
        }
        [Object] NewVmControllerProperty([Object]$Property)
        {
            Return [NewVmControllerProperty]::New($Property)
        }
        [String] IconStatus([UInt32]$Flag)
        {
            Return $This.Module._Control(@("failure.png","success.png","warning.png")[$Flag]).Fullname
        }
        [Object[]] Property([Object]$Object)
        {
            Return $Object.PSObject.Properties | % { $This.NewVmControllerProperty($_) }
        }
        [Object[]] Property([Object]$Object,[UInt32]$Mode,[String[]]$Property)
        {
            $Item = Switch ($Mode)
            {
                0 { $Object.PSObject.Properties | ? Name -notin $Property }
                1 { $Object.PSObject.Properties | ? Name    -in $Property }
            }

            Return $Item | % { $This.NewVmControllerProperty($_) }
        }
        [String] Escape([String]$Entry)
        {
            Return [Regex]::Escape($Entry)
        }
        FolderBrowse([String]$Name)
        {
            $This.Update(0,"Browsing [~] Folder: [$Name]")

            $Item        = $This.Validation.Get($Name)

            $Dialog      = [System.Windows.Forms.FolderBrowserDialog]::New()

            $Dialog.ShowDialog()
        
            $Item.Control.Text = @("<Select a path>",$Dialog.SelectedPath)[!!$Dialog.SelectedPath]
        }
        FileBrowse([String]$Name)
        {
            $This.Update(0,"Browsing [~] File: [$Name]")

            $Item        = $This.Validation.Get($Name)

            $Dialog      = [System.Windows.Forms.OpenFileDialog]::New()

            $Dialog.InitialDirectory  = $Env:SystemDrive

            $Dialog.ShowDialog()
            
            If (!$Dialog.Filename)
            {
                $Dialog.Filename                = ""
            }
        
            $Item.Control.Text = @("<Select an image>",$Dialog.FileName)[!!$Dialog.FileName]
        }
        Reset([Object]$xSender,[Object]$Object)
        {
            $xSender.Items.Clear()
            ForEach ($Item in $Object)
            {
                $xSender.Items.Add($Item)
            }
        }
        SetValidation()
        {
            $This.Validation.Clear()

            # [Network = 0]
            (0,"NetworkDomain"),
            (0,"NetworkNetBios"),
            (0,"NetworkSwitchName"),
            (1,"CredentialUsername"),
            (1,"CredentialPassword"),
            (1,"CredentialConfirm"),
            (1,"CredentialPin"),
            (2,"ImagePath"),
            (3,"TemplateExportPath"),
            (3,"TemplateName"),
            (3,"TemplateRootPath"),
            (4,"NodePath")  | % { 

                $This.Validation.Add($_[0],$This.Xaml.Get($_[1]))
            }
        }
        ToggleSetMain()
        {
            $List = $This.Validation.Output | ? Name -match "Network(Domain|NetBios)"

            $This.Xaml.IO.NetworkSetMain.IsEnabled = 0 -notin $List.Status
        }
        ToggleCredentialCreate()
        {
            Switch ($This.Xaml.IO.CredentialType.SelectedIndex)
            {
                Default
                {
                    $This.CheckUsername()
                    $This.CheckPassword()
                    $This.CheckConfirm()

                    $List = $This.Validation.Output | ? Name -match "Credential(Username|Password|Confirm)"

                    $This.Xaml.IO.CredentialCreate.IsEnabled = 0 -notin $List.Status
                }
                4
                {
                    $This.CheckUsername()
                    $This.CheckPassword()
                    $This.CheckConfirm()
                    $This.CheckPin()

                    $List = $This.Validation.Output | ? Name -match "Credential(Username|Password|Confirm|Pin)"

                    $This.Xaml.IO.CredentialCreate.IsEnabled = 0 -notin $List.Status
                }
            }            
        }
        ToggleTemplateCreate()
        {
            $Ctrl = $This

            $List = $Ctrl.Validation.Output | ? Name -match Template

            $Item = $Ctrl.Validation.Get("TemplateRootPath")
            $Icon = $Ctrl.Xaml.Get("TemplateRootPathIcon")

            If (0 -in $List.Status)
            {
                $X = "[!] Invalid <template root path>"
            }
            ElseIf ($Ctrl.Xaml.IO.TemplateName.Text -in $This.Template.Output.Name)
            {
                $X = "[!] Duplicate template name"
            }
            Else
            {
                $X = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $Icon.Control.Source  = $This.IconStatus($Item.Status)
            $Icon.Control.ToolTip = $Item.Reason

            $This.Xaml.IO.TemplateCreate.IsEnabled = $Item.Status
        }
        CheckDomain()
        {
            $Item = $This.Validation.Get("NetworkDomain")
            $Text = $Item.Control.Text

            If ($Text.Length -lt 2 -or $Text.Length -gt 63)
            {
                $X = "[!] Length not between 2 and 63 characters"
            }
            ElseIf ($Text -in $This.Validation.Reserved())
            {
                $X = "[!] Entry is in reserved words list"
            }
            ElseIf ($Text -in $This.Validation.Legacy())
            {
                $X = "[!] Entry is in the legacy words list"
            }
            ElseIf ($Text -notmatch "(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)")
            { 
                $X = "[!] Invalid domain name"
            }
            ElseIf ($Text[0,-1] -match "(\W)")
            {
                $X = "[!] First/Last Character cannot be a '.' or '-'"
            }
            ElseIf ($Text.Split(".").Count -lt 2)
            {
                $X = "[!] Single label domain names are disabled"
            }
            ElseIf ($Text.Split('.')[-1] -notmatch "\w")
            {
                $X = "[!] Top Level Domain must contain a non-numeric"
            }
            Else
            {
                $X = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.NetworkDomainIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.NetworkDomainIcon.ToolTip = $Item.Reason

            $This.ToggleSetMain()
        }
        CheckNetBios()
        {
            $Item = $This.Validation.Get("NetworkNetBios")
            $Text = $Item.Control.Text

            If ($Text.Length -lt 1 -or $Text.Length -gt 15)
            {
                $X = "[!] Length not between 1 and 15 characters"
            }
            ElseIf ($Text -in $This.Validation.Reserved())
            {
                $X = "[!] Entry is in reserved words list"
            }
            ElseIf ($Text -in $This.Validation.Legacy())
            {
                $X = "[!] Entry is in the legacy words list"
            }
            ElseIf ($Text -notmatch "([\.\-0-9a-zA-Z])")
            { 
                $X = "[!] Invalid NetBIOS name"
            }
            ElseIf ($Text[0,-1] -match "(\W)")
            {
                $X = "[!] First/Last Character cannot be a '.' or '-'"
            }                        
            ElseIf ($Text -match "\.")
            {
                $X = "[!] NetBIOS cannot contain a '.'"
            }
            ElseIf ($Text -in $This.Validation.SecurityDescriptor())
            {
                $X = "[!] Matches a security descriptor"
            }
            Else
            {
                $X = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.NetworkNetBiosIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.NetworkNetBiosIcon.ToolTip = $Item.Reason

            $This.ToggleSetMain()
        }
        CheckSwitchName()
        {
            $Item = $This.Validation.Get("NetworkSwitchName")
            $Text = $Item.Control.Text

            If (!$Text -or $Text -notmatch "(\w|\d)")
            {
                $X = "[!] Switch name must have (word/digit) chars"
            }
            ElseIf ($Text -match "^\<New\>$")
            {
                $X = "[!] Switch name cannot be <New>"
            }
            ElseIf ($Text -in $This.Network.Switch.Output.Name)
            {
                $X = "[!] Switch name ($Text) already exists"
            }
            Else
            {
                $X = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.NetworkSwitchNameIcon.Source      = $This.IconStatus($Item.Status)
            $This.Xaml.IO.NetworkSwitchNameIcon.ToolTip     = $Item.Reason

            $This.Xaml.IO.NetworkSwitchCreate.IsEnabled     = $Item.Status
        }
        CheckUsername()
        {
            $Item    = $This.Validation.Get("CredentialUsername")
            $Text    = $Item.Control.Text

            If ($Text -eq "")
            {
                $X   = "[!] Username is null"
            }
            ElseIf ($Text -in $This.Credential.Output)
            {
                $X   = "[!] Username is already specified"
            }
            Else
            {
                $X   = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.CredentialUsernameIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.CredentialUsernameIcon.ToolTip = $Item.Reason
        }
        CheckPassword()
        {
            $Item     = $This.Validation.Get("CredentialPassword")
            $Password = $Item.Control.Password

            If ($Password -eq "")
            {
                $X    = "[!] Password cannot be null"
            }
            Else
            {
                $X    = "[+] Passed"
            }

            $Item.Reason  = $X
            $Item.Status  = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.CredentialPasswordIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.CredentialPasswordIcon.ToolTip = $Item.Reason
        }
        CheckConfirm()
        {
            $Password   = $This.Validation.Get("CredentialPassword")
            $Item       = $This.Validation.Get("CredentialConfirm")

            If ($Password.Status -ne 1)
            {
                $X      = "[!] Password is null"
            }
            ElseIf ($This.Escape($Password.Control.Password) -ne $This.Escape($Item.Control.Password))
            {
                $X      = "[!] Password and confirmation do not match"
            }
            Else
            {
                $X      = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $This.Xaml.IO.CredentialConfirmIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.CredentialConfirmIcon.ToolTip = $Item.Reason
        }
        CheckPin()
        {
            $Item   = $This.Validation.Get("CredentialPin")

            If ($Item.Control.Password.Length -le 3)
            {
                $X  = "[!] Insufficient pin length"    
            }
            Else
            {
                $X  = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")
            
            $This.Xaml.IO.CredentialPinIcon.Source  = $This.IconStatus($Item.Status)
            $This.Xaml.IO.CredentialPinIcon.ToolTip = $Item.Reason
        }
        CheckPath([String]$Name)
        {
            $Ctrl                 = $This

            $Item                 = $Ctrl.Validation.Get($Name)
            $Text                 = $Item.Control.Text
            $Icon                 = $Ctrl.Xaml.Get("$Name`Icon")

            $Item.Status          = $Ctrl.Validation.CheckPath($Text).Status
            $Icon.Control.Source  = $Ctrl.IconStatus($Item.Status)
        }
        CheckTemplateExportPath()
        {
            $Ctrl                 = $This

            $Item                 = $Ctrl.Validation.Get("TemplateExportPath")
            $Text                 = $Item.Control.Text
            $Icon                 = $Ctrl.Xaml.Get("TemplateExportPathIcon")

            $Item.Status          = $Ctrl.Validation.CheckPath($Text).Status
            $Icon.Control.Source  = $Ctrl.IconStatus($Item.Status)
        }
        CheckTemplateName()
        {
            $Ctrl                 = $This

            $Item                 = $Ctrl.Validation.Get("TemplateName")
            $Text                 = $Item.Control.Text
            $Icon                 = $Ctrl.Xaml.Get("TemplateNameIcon")

            $Item.Status          = [UInt32]($Text -match "[a-zA-Z]{1}[a-zA-Z0-9]{0,14}") # -and $Text -notin $This.Node.Host.Name)
            $Icon.Control.Source  = $This.IconStatus($Item.Status)

            $This.ToggleTemplateCreate()
        }
        CheckTemplateRootPath()
        {
            $Ctrl                 = $This

            $Item                 = $Ctrl.Validation.Get("TemplateRootPath")
            $Text                 = $Item.Control.Text
            $Icon                 = $Ctrl.Xaml.Get("TemplateRootPathIcon")

            $Item.Status          = $Ctrl.Validation.CheckPath($Text).Status
            $Icon.Control.Source  = $This.IconStatus($Item.Status)
        }
        CheckNodePath()
        {
            $Item         = $This.Validation.Get("NodePath")
            $Icon         = $This.Xaml.Get("NodePathIcon")

            $Item.Status  = $This.Validation.CheckPath($Item.Control.Text).Status

            $Icon.Control.Source  = $This.IconStatus($Item.Status)
        }
        SetMain()
        {
            # [GUI approach]
            $This.Network.SetMain($This.Xaml.IO.NetworkDomain.Text,
                                $This.Xaml.IO.NetworkNetBios.Text)

            $This.Xaml.IO.NetworkDomain.IsEnabled     = 0
            $This.Xaml.IO.NetworkNetBios.IsEnabled    = 0
            $This.Xaml.IO.NetworkSetMain.IsEnabled    = 0

            $This.Xaml.IO.NetworkRefresh.IsEnabled    = 1
            $This.Xaml.IO.NetworkProperty.IsEnabled   = 1
            $This.Xaml.IO.NetworkInterface.IsEnabled  = 1
        }
        SetMain([String]$Domain,[String]$NetBios)
        {
            # [CLI approach]
            $This.Xaml.IO.NetworkDomain.Text  = $Domain
            $This.Xaml.IO.NetworkNetBios.Text = $NetBios

            $This.CheckDomain()
            $This.CheckNetBios()

            $This.SetMain()
        }
        SwitchRefresh()
        {
            $This.Network.Refresh()
            $This.SwitchConfig()
        }
        SwitchRangeScan()
        {
            $Ctrl      = $This

            $Item      = $Ctrl.Xaml.IO.NetworkInterface.SelectedItem
            $Interface = $Ctrl.Network.Interface.Output | ? Name -eq $Item.Name

            $Interface.Selected.Host = @( )
            $Interface.Selected.Range.Expand()

            $Runspace     = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
            $PS           = [PowerShell]::Create()
            $PS.Runspace  = $Runspace

            $Runspace.Open()
            [Void]$PS.AddScript(
            {
                Param ($HostList)

                $Buffer   = 97..119 + 97..105 | % { "0x{0:X}" -f $_ }
                $Option   = [System.Net.NetworkInformation.PingOptions]::New()
                $Ping     = @{ }
                ForEach ($X in 0..($HostList.Count-1))
                {
                    $Item = [System.Net.NetworkInformation.Ping]::New()
                    $Ping.Add($X,$Item.SendPingAsync($HostList[$X],100,$Buffer,$Option))
                }

                $Ping[0..($Ping.Count-1)]
            })

            $PS.AddArgument($Interface.Selected.Range.Host)
            $Async        = $PS.BeginInvoke()
            $Out          = $PS.EndInvoke($Async)
            $PS.Dispose()
            $Runspace.Dispose()

            ForEach ($X in 0..($Out.Count-1))
            {
                $Interface.Selected.AddHost($Interface.Selected.Range.Host[$X],$Out[$X])
            }

            ForEach ($Type in "Network","Broadcast","Trusted","Gateway")
            {
                $Item = $Interface.Selected.Host | ? IpAddress -eq $Interface.Selected.$Type
                $Item.Type   = $Type
                $Item.Status = 1
            }

            $Interface.Selected.SetDhcp()

            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkRangeHost,$Interface.Selected.Host)
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkDhcp,$Ctrl.Property($Interface.Selected.Dhcp))
        }
        SwitchConfig()
        {
            $List      = $This.Network.Interface.Output
            $Property  = $This.Xaml.IO.NetworkProperty.SelectedItem.Content
            If ($Property -notmatch "^\*$")
            {
                $List  = $List | ? State -match $Property
            }

            $This.DataGrid.Network.Refresh($List)

            $This.Reset($This.Xaml.IO.NetworkInterface,$This.DataGrid.Network.Output)
            $This.Reset($This.Xaml.IO.NetworkSwitchAdapter,$This.Network.GetPhysical().Name)
        }
        SwitchInterface()
        {
            $Ctrl     = $This

            $Selected = $Ctrl.Xaml.IO.NetworkInterface.SelectedItem

            # [Base/Adapter/Config]
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkBase,$Null)
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkAdapter,$Null)
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkConfig,$Null)

            If ($Selected.Name -eq "<New>")
            {
                # [Type]
                $Ctrl.Xaml.IO.NetworkSwitchType.IsEnabled      = 1
                $Ctrl.Xaml.IO.NetworkSwitchType.SelectedIndex  = 0

                # [Name]
                $Ctrl.Xaml.IO.NetworkSwitchName.IsEnabled      = 1
                $Ctrl.Xaml.IO.NetworkSwitchName.Text           = ""
                $Ctrl.Xaml.IO.NetworkSwitchNameIcon.Source     = $Null

                # [OS]
                $Ctrl.Xaml.IO.NetworkSwitchOs.IsEnabled        = 1
                $Ctrl.Xaml.IO.NetworkSwitchOs.IsChecked        = 0

                # [Adapter]
                $Ctrl.Xaml.IO.NetworkSwitchAdapter.IsEnabled  = 1
                $Ctrl.Reset($Ctrl.Xaml.IO.NetworkSwitchAdapter,$Ctrl.Network.GetPhysical().Name)
                If ($Ctrl.Xaml.IO.NetworkSwitchAdapter.Items.Count -gt 0)
                {
                    $Ctrl.Xaml.IO.NetworkSwitchAdapter.SelectedIndex = 0
                }

                # [Create/Remove]
                $Ctrl.Xaml.IO.NetworkSwitchCreate.IsEnabled    = 0
                $Ctrl.Xaml.IO.NetworkSwitchRemove.IsEnabled    = 0
            }
            Else
            {
                $Interface = $Ctrl.Network.Interface.Output | ? Name -eq $Selected.Name

                # [Type]
                $Ctrl.Xaml.IO.NetworkSwitchType.IsEnabled     = 0
                $Ctrl.Xaml.IO.NetworkSwitchType.SelectedIndex = $Ctrl.Network.Switch.Mode.GetIndex($Interface.Type)

                # [Name]
                $Ctrl.Xaml.IO.NetworkSwitchName.IsEnabled     = 0
                $Ctrl.Xaml.IO.NetworkSwitchName.Text          = $Interface.Name
                $Ctrl.Xaml.IO.NetworkSwitchNameIcon.Source    = $Null

                # [OS]
                $Ctrl.Xaml.IO.NetworkSwitchOs.IsEnabled       = 0
                $Ctrl.Xaml.IO.NetworkSwitchOs.IsChecked       = $Interface.Os

                # [Adapter]
                $Ctrl.Xaml.IO.NetworkSwitchAdapter.IsEnabled  = 0
                $Ctrl.Reset($Ctrl.Xaml.IO.NetworkSwitchAdapter,$Interface.Adapter.Name)
                If ($Ctrl.Xaml.IO.NetworkSwitchAdapter.Items.Count -gt 0)
                {
                    $Ctrl.Xaml.IO.NetworkSwitchAdapter.SelectedIndex = 0
                }

                # [Create/Remove]
                $Ctrl.Xaml.IO.NetworkSwitchCreate.IsEnabled   = 0
                $Ctrl.Xaml.IO.NetworkSwitchRemove.IsEnabled   = 1

                # [Base/Adapter/Config]
                $Ctrl.Reset($Ctrl.Xaml.IO.NetworkBase,$Interface.Base)

                If (!!$Interface.Adapter)
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.NetworkAdapter,$Ctrl.Property($Interface.Adapter))
                }

                If (!!$Interface.Config)
                {
                    $Ctrl.Reset($Ctrl.Xaml.IO.NetworkConfig,$Ctrl.Property($Interface.Config))
                }
            }

            $Ctrl.Xaml.IO.NetworkPanel.SelectedIndex = 0
        }
        SwitchType()
        {
            Switch ($This.Xaml.IO.NetworkSwitchType.SelectedIndex)
            {
                0
                {
                    $This.Reset($This.Xaml.IO.NetworkSwitchAdapter,$This.Network.GetPhysical().Name)
                    
                    If ($This.Xaml.NetworkSwitchAdapter.Items.Count -gt 0)
                    {
                        $This.Xaml.NetworkSwitchAdapter.SelectedIndex = 0
                    }

                    $This.Xaml.IO.NetworkSwitchAdapter.IsEnabled = 1
                }
                Default
                {
                    $This.Reset($This.Xaml.IO.NetworkSwitchAdapter,$Null)

                    $This.Xaml.IO.NetworkSwitchAdapter.IsEnabled = 0
                }
            }
        }
        SwitchBase()
        {
            $Ctrl      = $This

            $Item      = $Ctrl.Xaml.IO.NetworkInterface.SelectedItem
            $Interface = $Ctrl.Network.Interface.Output | ? Name -eq $Item.Name

            $Ctrl.Xaml.IO.NetworkName.IsEnabled          = 0
            $Ctrl.Xaml.IO.NetworkName.Text               = ""

            $Ctrl.Xaml.IO.NetworkRangeTotal.IsEnabled    = 0
            $Ctrl.Xaml.IO.NetworkRangeTotal.Text         = ""

            $Ctrl.Xaml.IO.NetworkRangeNotation.IsEnabled = 0
            $Ctrl.Xaml.IO.NetworkRangeNotation.Text      = ""

            $Ctrl.Xaml.IO.NetworkRangeScan.IsEnabled     = 0

            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkRangeHost,$Null)
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkDhcp,$Null)
            
            If (!!$Interface)
            {
                $Interface.Selected = $Null

                Switch ($Ctrl.Xaml.IO.NetworkBase.SelectedIndex)
                {
                    -1
                    {

                    }
                    Default
                    {
                        $Interface.Selected                          = $Interface.Base | ? Name -eq $Ctrl.Xaml.IO.NetworkBase.SelectedItem.Name

                        $Ctrl.Xaml.IO.NetworkName.IsEnabled          = 1
                        $Ctrl.Xaml.IO.NetworkName.Text               = $Interface.Selected.Name

                        $Ctrl.Xaml.IO.NetworkRangeTotal.IsEnabled    = 1
                        $Ctrl.Xaml.IO.NetworkRangeTotal.Text         = $Interface.Selected.Range.Total

                        $Ctrl.Xaml.IO.NetworkRangeNotation.IsEnabled = 1
                        $Ctrl.Xaml.IO.NetworkRangeNotation.Text      = $Interface.Selected.Range.Notation

                        $Ctrl.Xaml.IO.NetworkRangeScan.IsEnabled     = 1
                    }
                }
            }
        }
        SwitchCreate()
        {
            $Ctrl  = $This
            $Name  = $Ctrl.Xaml.IO.NetworkSwitchName.Text
            $Type  = $Ctrl.Xaml.IO.NetworkSwitchType.SelectedItem.Content

            $Splat = @{ 

                Name                           = $Name
                AllowManagementOs              = [UInt32]$Ctrl.Xaml.IO.NetworkSwitchOs.IsChecked
            }

            Switch ($Type)
            {
                External
                {
                    $Splat.Add("NetAdapterInterfaceDescription",$Ctrl.Xaml.IO.NetworkSwitchAdapter.SelectedItem)
                }
                Default
                {
                    $Splat.Add("SwitchType",$Type)
                }
            }

            $This.Update(0,"Creating [~] [VmSwitch]: $Name")

            New-VmSwitch @Splat

            $This.Update(1,"Created [+] [VmSwitch]: $Name")

            $Ctrl.SwitchRefresh()
        }
        SwitchRemove()
        {
            $Ctrl  = $This
            $Name  = $Ctrl.Xaml.IO.NetworkSwitchName.Text

            $This.Update(0,"Removing [~] [VmSwitch]: $Name")

            Remove-VmSwitch -Name $Ctrl.Xaml.IO.NetworkSwitchName.Text -Confirm:0 -Force

            $This.Update(1,"Removed [+] [VmSwitch]: $Name")

            $Ctrl.SwitchRefresh()
        }
        SwitchPanel([String]$Name)
        {
            $Ctrl = $This

            $Ctrl.Xaml.IO.NetworkBasePanel.Visibility     = "Collapsed"
            $Ctrl.Xaml.IO.NetworkRangePanel.Visibility    = "Collapsed"
            $Ctrl.Xaml.IO.NetworkDhcpPanel.Visibility     = "Collapsed"
            $Ctrl.Xaml.IO.NetworkAdapterPanel.Visibility  = "Collapsed"
            $Ctrl.Xaml.IO.NetworkConfigPanel.Visibility   = "Collapsed"

            $Ctrl.Xaml.IO."Network$Name`Panel".Visibility = "Visible"
        }
        SwitchNetworkName()
        {
            $Ctrl = $This

            $Item      = $Ctrl.Validation.Get("NetworkName")
            $Button    = $Ctrl.Xaml.Get("NetworkAssign")
            $Icon      = $Ctrl.Xaml.Get("NetworkNameIcon")

            $Guid      = $Ctrl.Xaml.IO.NetworkInterface.SelectedItem.Guid
            $Interface = $Ctrl.Network.Interface.Output | ? SwitchId -eq $Guid

            If (!$Interface.Base.Dhcp)
            {
                $X     = "[!] Must have a <Dhcp object> prepared"
            }
            Else
            {
                $X     = "[+] Passed"
            }

            $Item.Reason = $X
            $Item.Status = [UInt32]($Item.Reason -eq "[+] Passed")

            $Button.Control.IsEnabled = $Item.Status
            $Icon.Control.Source = $Ctrl.IconStatus($Item.Status)
        }
        SwitchAssign()
        {
            $Ctrl = $This

            # Assigns the selected network(s) to the template object
            $Guid      = $Ctrl.Xaml.IO.NetworkInterface.SelectedItem.Guid
            $Interface = $Ctrl.Network.Interface.Output | ? SwitchId -eq $Guid
            
            If (!$Interface.Selected)
            {
                [System.Windows.MessageBox]::Show("<No selected network>","Error [!]")
            }
            Else
            {
                $Ctrl.Template.SetNetwork($Interface)

                # Refreshes the UI template network object
                $Ctrl.Reset($Ctrl.Xaml.IO.TemplateNetworkOutput,$Ctrl.Template.Network)
        
                # Shows message detailing network switch count
                [System.Windows.MessageBox]::Show("Interface(s) ($($Ctrl.Template.Network.Count))","Assigned [+] Network(s)")

                # Add logic to disable the items in this panel $Ctrl.Xaml.Types
            }
        }
        CredentialInitialize()
        {
            $Ctrl = $This

            $Ctrl.Credential.Clear()
            $Ctrl.Credential.Setup()

            $Ctrl.CredentialPopulate()
        }
        CredentialPopulate()
        {
            $Ctrl = $This

            $Ctrl.DataGrid.Credential.Refresh($Ctrl.Credential.Output)
            $Ctrl.Reset($Ctrl.Xaml.IO.CredentialOutput,$Ctrl.DataGrid.Credential.Output)

            $Ctrl.Xaml.IO.CredentialCount.Text = $Ctrl.Credential.Output.Count
        }
        CredentialType()
        {
            $Ctrl     = $This

            $Index    = $Ctrl.Xaml.IO.CredentialType.SelectedIndex
            $PinToken = [UInt32]($Index -eq 4)

            $Ctrl.Reset($Ctrl.Xaml.IO.CredentialDescription,$Ctrl.Credential.GetSlot($Index))

            $Ctrl.Xaml.IO.CredentialPin.IsEnabled          = $PinToken
            $Ctrl.Xaml.IO.CredentialPin.Visibility         = @("Collapsed","Visible")[$PinToken]
            $Ctrl.Xaml.IO.CredentialPinIcon.Visibility     = @("Collapsed","Visible")[$PinToken]
        }
        CredentialSelect()
        {
            $Ctrl     = $This

            $Item     = $Ctrl.Xaml.IO.CredentialOutput.SelectedItem
            $Selected = $Ctrl.Credential.Output | ? Guid -eq $Item.Guid

            If (!$Selected)
            {
                $Ctrl.Xaml.IO.CredentialType.IsEnabled         = 1
                $Ctrl.Xaml.IO.CredentialType.SelectedIndex     = 0

                $Ctrl.Xaml.IO.CredentialDescription.IsEnabled  = 1
                $Ctrl.Xaml.IO.CredentialCreate.IsEnabled       = 0
                $Ctrl.Xaml.IO.CredentialRemove.IsEnabled       = 0

                # [Username]
                $Ctrl.Xaml.IO.CredentialUsername.IsEnabled     = 1
                $Ctrl.Xaml.IO.CredentialUsername.Text          = ""
                
                # [Password]
                $Ctrl.Xaml.IO.CredentialPassword.IsEnabled     = 1
                $Ctrl.Xaml.IO.CredentialPassword.Password      = ""

                # [Confirm]
                $Ctrl.Xaml.IO.CredentialConfirm.IsEnabled      = 1
                $Ctrl.Xaml.IO.CredentialConfirm.Password       = ""

                $Ctrl.CredentialType()

                # [Pin]
                $Ctrl.Xaml.IO.CredentialPin.IsEnabled          = 1
                $Ctrl.Xaml.IO.CredentialPin.Password           = $Null

                # [Icons]
                $Ctrl.Xaml.IO.CredentialPinIcon.Source         = $Null
                $Ctrl.Xaml.IO.CredentialUsernameIcon.Source    = $Null
                $Ctrl.Xaml.IO.CredentialPasswordIcon.Source    = $Null
                $Ctrl.Xaml.IO.CredentialConfirmIcon.Source     = $Null
            }
            Else
            {
                $Ctrl.Xaml.IO.CredentialType.IsEnabled         = 0

                $Ctrl.Xaml.IO.CredentialDescription.IsEnabled  = 0
                $Slot = $Ctrl.Credential.Slot.Output | ? Name -eq $Ctrl.Xaml.IO.CredentialOutput.SelectedItem.Type

                $Ctrl.Xaml.IO.CredentialType.SelectedIndex     = $Slot.Index
                $Ctrl.Reset($Ctrl.Xaml.IO.CredentialDescription,$Slot)

                $Ctrl.Xaml.IO.CredentialCreate.IsEnabled       = 0
                $Ctrl.Xaml.IO.CredentialRemove.IsEnabled       = 1

                # [Username]
                $Ctrl.Xaml.IO.CredentialUsername.IsEnabled     = 0
                $Ctrl.Xaml.IO.CredentialUsername.Text          = $Selected.Username
                $Ctrl.Xaml.IO.CredentialUsernameIcon.Source    = $Ctrl.IconStatus(1)
                
                # [Password]
                $Ctrl.Xaml.IO.CredentialPassword.IsEnabled     = 0
                $Ctrl.Xaml.IO.CredentialPassword.Password      = $Selected.Password()
                $Ctrl.Xaml.IO.CredentialPasswordIcon.Source    = $Ctrl.IconStatus(1)
                
                # [Confirm]
                $Ctrl.Xaml.IO.CredentialConfirm.IsEnabled      = 0
                $Ctrl.Xaml.IO.CredentialConfirm.Password       = $Selected.Password()
                $Ctrl.Xaml.IO.CredentialConfirmIcon.Source     = $Ctrl.IconStatus(1)
                
                # [Pin]
                $Ctrl.Xaml.IO.CredentialPin.IsEnabled          = 0
                $Ctrl.Xaml.IO.CredentialPin.Password           = $Selected.Pin
                $Ctrl.Xaml.IO.CredentialPinIcon.Source         = $Ctrl.IconStatus(1)
            }
        }
        CredentialGenerate()
        {
            $Ctrl = $This

            $Entry                                    = $Ctrl.Credential.Generate()
            $Ctrl.Xaml.IO.CredentialPassword.Password = $Entry
            $Ctrl.Xaml.IO.CredentialConfirm.Password  = $Entry
        }
        CredentialRemove()
        {
            $Ctrl = $This

            If ($Ctrl.Credential.Output.Count -eq 1)
            {
                [System.Windows.MessageBox]::Show("Must have at least (1) account, use refresh to reset")
            }
            Else
            {
                $Guid = $Ctrl.Xaml.IO.CredentialOutput.SelectedItem.Guid
                $Ctrl.Credential.Output = @($Ctrl.Credential.Output | ? Guid -ne $Guid)
                $Ctrl.Credential.Rerank()
            }

            $Ctrl.CredentialPopulate()
        }
        CredentialCreate()
        {
            $Ctrl = $This

            $Ctrl.Credential.Add($Ctrl.Xaml.IO.CredentialType.SelectedIndex,
                                $Ctrl.Xaml.IO.CredentialUsername.Text,
                                $Ctrl.Xaml.IO.CredentialPassword.SecurePassword)

            If ($Ctrl.Xaml.IO.CredentialType.SelectedIndex -eq 4)
            {
                $Cred     = $Ctrl.Credential.Output | ? Username -eq $Ctrl.Xaml.IO.CredentialUsername.Text
                $Cred.Pin = $Ctrl.Xaml.IO.CredentialPin.Password
            }

            $Ctrl.Credential.Rerank()
            
            $Ctrl.CredentialPopulate()
        }
        CredentialAssign()
        {
            $Ctrl = $This

            $Ctrl.Template.SetAccount($Ctrl.Credential.Output)
            
            $Ctrl.Reset($Ctrl.Xaml.IO.TemplateCredentialOutput,$Ctrl.Template.Account)
                    
            [System.Windows.MessageBox]::Show("Accounts: ($($Ctrl.Template.Account.Count))","Assigned [+] Credential(s)")

            # Add logic to disable the items in this panel $Ctrl.Xaml.Types
        }
        ImagePathBrowse()
        {
            $Ctrl = $This

            $Ctrl.FolderBrowse("ImagePath")
        }
        ImageCheckPath()
        {
            $Ctrl = $This

            $Ctrl.CheckPath("ImagePath")

            $Item = $Ctrl.Validation.Get("ImagePath")
            $Ctrl.Xaml.IO.ImageImport.IsEnabled = $Item.Status
        }
        ImageSetPath()
        {
            $Ctrl = $This

            $Ctrl.Update(0,"Setting [~] Image source")

            $Ctrl.Image.SetSource($Ctrl.Xaml.IO.ImagePath.Text)
            $Ctrl.Image.Refresh()

            Switch ($Ctrl.Image.Store.Count)
            {
                0
                {
                    Throw "No images detected"
                }
                1
                {
                    $Ctrl.Image.Select(0)
                    $Ctrl.Update(0,"Processing [~] $($Ctrl.Image.Current().Name)")
                    $Ctrl.Image.ProcessSlot()
                }
                Default
                {
                    For ($X = 0; $X -lt $Ctrl.Image.Store.Count;$X ++)
                    {
                        $Ctrl.Image.Select($X)
                        $Ctrl.Update(0,"Processing [~] $($Ctrl.Image.Current().Name)")
                        $Ctrl.Image.ProcessSlot()
                    }
                }
            }

            $Ctrl.Reset($Ctrl.Xaml.IO.ImageStore,$Ctrl.Image.Store)

            $Ctrl.Update(1,"Complete [+] Images charted")
        }
        ImageStore()
        {
            $Ctrl    = $This

            $Ctrl.Image.Select($Ctrl.Xaml.IO.ImageStore.SelectedIndex)

            $Current = $Ctrl.Image.Current()
            $Ctrl.Reset($Ctrl.Xaml.IO.ImageStoreContent,$Current.Content)

            $Ctrl.Xaml.IO.ImageName.Text  = $Current.Name
        }
        ImageEdition()
        {
            $Ctrl    = $This
            $Current = $Ctrl.Image.Current()
            $Index   = $Ctrl.Xaml.IO.ImageStoreContent.SelectedIndex
            $Edition = $Current.Content[$Index]

            $Ctrl.Xaml.IO.ImageIndex.Text = $Edition.Index
        }
        ImageAssign()
        {
            $Ctrl  = $This

            $List  = $Ctrl.Xaml.IO.ImageStore.Items        | ? Profile
            $List2 = $Ctrl.Xaml.IO.ImageStoreContent.Items | ? Profile

            If ($List.Count -ne 1)
            {
                [System.Windows.MessageBox]::Show("Must check (1) image")
            }
            ElseIf ($List.Count -eq 1 -and $List[0].Type -eq "Windows" -and $List2.Count -ne 1)
            {
                [System.Windows.MessageBox]::Show("Must check (1) edition")
            }
            Else
            {
                $Ctrl.Template.SetImage($Ctrl.Image.NewVmControllerImageObject($List,$List2))
                $Ctrl.Reset($Ctrl.Xaml.IO.TemplateImageOutput,$Ctrl.Template.Image)

                [System.Windows.MessageBox]::Show($Ctrl.Template.Image.File.Fullname,"Assigned [+] $($Ctrl.Template.Image.Edition.DestinationName)")
            }

            # Add logic to disable the items in this panel $Ctrl.Xaml.Types
        }
        TemplatePopulate()
        {
            $Ctrl = $This

            $Ctrl.DataGrid.Template.Refresh($Ctrl.Template.Output)
            $Ctrl.Reset($Ctrl.Xaml.IO.TemplateOutput,$Ctrl.DataGrid.Template.Output)
        }
        TemplateReset()
        {
            $Ctrl = $This

            $Ctrl.DataGrid.Template.Clear()
            $Ctrl.Template.Populate()
        }
        TemplateExportPath()
        {
            $Ctrl = $This

            If ($Ctrl.Xaml.IO.TemplateExportPath.Text -eq "")
            {
                $Ctrl.Xaml.IO.TemplateExportPath.Text       = "<Set template export path>"
                $Ctrl.Xaml.IO.TemplateExportPathIcon.Source = $Null
            }
            Else
            {
                $Ctrl.CheckTemplateExportPath()
                $Ctrl.ToggleTemplateCreate()
            }

            $Item = $Ctrl.Validation.Get("TemplateExportPath")
            $Ctrl.Xaml.IO.TemplateSetPath.IsEnabled = $Item.Status
        }
        TemplateExportBrowse()
        {
            $Ctrl = $This

            $Ctrl.FolderBrowse("TemplateExportPath")
        }
        TemplateSetPath()
        {
            $Ctrl = $This

            $Item = $Ctrl.Validation.Get("TemplateExportPath")
            Switch ($Item.Status)
            {
                0
                {
                    [System.Windows.MessageBox]::Show("Invalid path designated","Exception [!] Path error")
                }
                1
                {
                    $This.Template.SetPath($Ctrl.Xaml.IO.TemplateExportPath.Text)

                    $Ctrl.Xaml.IO.TemplateExportPath.IsEnabled   = 0
                    $Ctrl.Xaml.IO.TemplateExportBrowse.IsEnabled = 0
                    $Ctrl.Xaml.IO.TemplateSetPath.IsEnabled      = 0
                    $Ctrl.Xaml.IO.TemplateOutput.IsEnabled       = 1
                }
            }

            $Ctrl.TemplatePopulate()
        }
        TemplateRootPath()
        {
            $Ctrl = $This

            If ($Ctrl.Xaml.IO.TemplateRootPath.Text -eq "")
            {
                $Ctrl.Xaml.IO.TemplateRootPath.Text = "<Set virtual machine root path>"
                $Ctrl.Xaml.IO.TemplateRootPathIcon.Source = $Null
            }
            Else
            {
                $Ctrl.CheckTemplateRootPath()
                $Ctrl.ToggleTemplateCreate()
            }
        }
        TemplateRootPathBrowse()
        {
            $Ctrl = $This

            $Ctrl.FolderBrowse("TemplateRootPath")
        }
        TemplateCreate()
        {
            $Ctrl = $This

            If ($Ctrl.Xaml.IO.TemplateName.Text -notmatch "(\w|\d)")
            {
                [System.Windows.MessageBox]::Show("Must enter a name","Error")
            }
        
            ElseIf ($Ctrl.Xaml.IO.TemplateName.Text -in $Ctrl.Template.Name)
            {
                [System.Windows.MessageBox]::Show("Duplicate name","Error")
            }
        
            Else
            {
                $Ctrl.Template.Add($Ctrl.Xaml.IO.TemplateName.Text,
                                $Ctrl.Xaml.IO.TemplateRole.SelectedIndex,
                                $Ctrl.Xaml.IO.TemplateRootPath.Text,
                                $Ctrl.Xaml.IO.TemplateMemory.SelectedItem.Content,
                                $Ctrl.Xaml.IO.TemplateHardDrive.SelectedItem.Content,
                                $Ctrl.Xaml.IO.TemplateGeneration.SelectedItem.Content,
                                $Ctrl.Xaml.IO.TemplateCore.SelectedItem.Content)
                
                $Ctrl.TemplatePopulate()
        
                $Ctrl.Xaml.Get("TemplateName").Control.Text            = ""
                $Ctrl.Xaml.Get("TemplateRootPath").Control.Text        = "<Set virtual machine root path>"
                $Ctrl.Xaml.Get("TemplateRootPathIcon").Control.Source  = $Null
            }
        }
        TemplateRemove()
        {
            $Ctrl = $This

            $Ctrl.Template.Output = @($Ctrl.Template.Output | ? Name -ne $Ctrl.Xaml.IO.TemplateOutput.SelectedItem.Name)

            $Ctrl.TemplatePopulate()
        }
        TemplateRole()
        {
            $Ctrl = $This

            $Ctrl.Reset($Ctrl.Xaml.IO.TemplateRoleDescription,
                        $Ctrl.Template.Role.Output[$Ctrl.Xaml.IO.TemplateRole.SelectedIndex])
        }
        TemplateHandle()
        {
            $Ctrl = $This

            # [Buttons]
            $Ctrl.Xaml.IO.TemplateCreate.IsEnabled              = 0
            $Ctrl.Xaml.IO.TemplateRemove.IsEnabled              = 0
            $Ctrl.Xaml.IO.TemplateExport.IsEnabled              = 0

            # [Template]
            $Ctrl.Xaml.IO.TemplateName.IsEnabled                = 0
            $Ctrl.Xaml.IO.TemplateRole.IsEnabled                = 0

            # [Root Path]
            $Ctrl.Xaml.IO.TemplateRootPath.IsEnabled            = 0
            $Ctrl.Xaml.IO.TemplateRootPathIcon.IsEnabled        = 0
            $Ctrl.Xaml.IO.TemplateRootPathBrowse.IsEnabled      = 0
            $Ctrl.Xaml.IO.TemplateRootPathIcon.Source           = $Null

            # [Specs]
            $Ctrl.Xaml.IO.TemplateMemory.IsEnabled              = 0
            $Ctrl.Xaml.IO.TemplateMemory.SelectedIndex          = 1

            $Ctrl.Xaml.IO.TemplateHardDrive.IsEnabled           = 0
            $Ctrl.Xaml.IO.TemplateHardDrive.SelectedIndex       = 1

            $Ctrl.Xaml.IO.TemplateGeneration.IsEnabled          = 0
            $Ctrl.Xaml.IO.TemplateGeneration.SelectedIndex      = 1

            $Ctrl.Xaml.IO.TemplateCore.IsEnabled                = 0
            $Ctrl.Xaml.IO.TemplateCore.SelectedIndex            = 1

            $Selected = $Ctrl.Xaml.IO.TemplateOutput.SelectedItem
            $Item     = $Ctrl.Template.Output | ? Guid -eq $Selected.Guid

            If (!$Item)
            {
                $Ctrl.Xaml.IO.TemplateName.IsEnabled            = 1
                $Ctrl.Xaml.IO.TemplateName.Text                 = ""

                $Ctrl.Xaml.IO.TemplateRole.IsEnabled            = 1
                $Ctrl.Xaml.IO.TemplateRole.SelectedIndex        = 1
                
                $Ctrl.Xaml.IO.TemplateRootPath.IsEnabled        = 1
                $Ctrl.Xaml.IO.TemplateRootPathIcon.IsEnabled    = 1
                $Ctrl.Xaml.IO.TemplateRootPathBrowse.IsEnabled  = 1

                $Ctrl.Xaml.IO.TemplateMemory.IsEnabled          = 1
                $Ctrl.Xaml.IO.TemplateHardDrive.IsEnabled       = 1
                $Ctrl.Xaml.IO.TemplateGeneration.IsEnabled      = 1
                $Ctrl.Xaml.IO.TemplateCore.IsEnabled            = 1

                $Ctrl.Xaml.IO.TemplateRootPath.Text             = "<Set virtual machine root path>"
                $Ctrl.Xaml.IO.TemplateRootPathIcon.Source       = $Null

                $Ctrl.Xaml.IO.TemplateNetworkOutput.IsEnabled    = 1
                $Ctrl.Xaml.IO.TemplateCredentialOutput.IsEnabled = 1
                $Ctrl.Xaml.IO.TemplateImageOutput.IsEnabled      = 1
            }
            If (!!$Item)
            {
                $Ctrl.Xaml.IO.TemplateCreate.IsEnabled          = 0
                $Ctrl.Xaml.IO.TemplateRemove.IsEnabled          = 1
                $Ctrl.Xaml.IO.TemplateExport.IsEnabled          = 1

                $Ctrl.Xaml.IO.TemplateName.Text                 = $Item.Name
                $Ctrl.Xaml.IO.TemplateNameIcon.Source           = $Null

                $Ctrl.Xaml.IO.TemplateRole.SelectedIndex        = $Item.Role.Index

                $Ctrl.Xaml.IO.TemplateRootPath.Text             = $Item.Root

                $Ctrl.CheckTemplateRootPath()

                $Ctrl.Xaml.IO.TemplateMemory.SelectedIndex      = Switch -Regex ($Item.Memory.Size)
                {
                    "2.00 GB" { 0 } "4.00 GB" { 1 } "8.00 GB" { 2 } "16.00 GB" { 3 }
                }

                $Ctrl.Xaml.IO.TemplateHardDrive.SelectedIndex   = Switch -Regex ($Item.Hdd.Size)
                {
                    "32.00 GB" { 0 } "64.00 GB" { 1 } "128.00 GB" { 2 } "256.00 GB" { 3 }
                }

                $Ctrl.Xaml.IO.TemplateGeneration.SelectedIndex  = @{"1"=0;"2"=1}["$($Item.Gen)"]
                $Ctrl.Xaml.IO.TemplateCore.SelectedIndex        = @{"1"=0;"2"=1;"3"=2;"4"=3}["$($Item.Core)"]

                $Ctrl.Xaml.IO.TemplateNetworkOutput.IsEnabled    = 0
                $Ctrl.Xaml.IO.TemplateCredentialOutput.IsEnabled = 0
                $Ctrl.Xaml.IO.TemplateImageOutput.IsEnabled      = 0
            }
        }
        TemplateExport()
        {
            $Ctrl = $This

            $Ctrl.Template.Export($Ctrl.Xaml.IO.TemplateOutput.SelectedItem.Index)
        }
        TemplateNetworkUp()
        {
            $Ctrl = $This

            $List    = $Ctrl.Xaml.IO.TemplateNetworkOutput.Items
            $Current = $Ctrl.Xaml.IO.TemplateNetworkOutput.SelectedItem
            $Item    = $List | ? Index -eq $Current.Index
            $Target  = $List | ? Index -eq ($Current.Index - 1)

            If ($Current.Index -ge 1)
            {
                $Item.Index --
                $Target.Index ++
                $Ctrl.Template.Network = $List | Sort-Object Index
                $Ctrl.Reset($Ctrl.Xaml.IO.TemplateNetworkOutput,$Ctrl.Template.Network)
            }
        }
        TemplateNetworkDown()
        {
            $Ctrl    = $This

            $List    = $Ctrl.Xaml.IO.TemplateNetworkOutput.Items
            $Current = $Ctrl.Xaml.IO.TemplateNetworkOutput.SelectedItem
            $Item    = $List | ? Index -eq $Current.Index
            $Target  = $List | ? Index -eq ($Current.Index + 1)

            If ($Current.Index -le ($List.Count-2))
            {
                $Item.Index ++
                $Target.Index --
                $Ctrl.Template.Network = $List | Sort-Object Index
                $Ctrl.Reset($Ctrl.Xaml.IO.TemplateNetworkOutput,$Ctrl.Template.Network)
            }
        }
        NodeRefresh()
        {
            $Ctrl = $This

            $Ctrl.Node.Refresh()
            $Ctrl.Reset($Ctrl.Xaml.IO.NodeOutput,$Ctrl.Node.Object)
            $Ctrl.Reset($Ctrl.Xaml.IO.NodeExtension,$Null)
        }
        NodePath()
        {
            $Ctrl = $This
            $Item = $This.Validation.Get("NodePath")

            $Ctrl.CheckNodePath()

            If ($Ctrl.Xaml.IO.NodePath.Text -eq "")
            {
                $Ctrl.Xaml.IO.NodePath.Text       = "<Set path to import control template(s)>"
                $Ctrl.Xaml.IO.NodePathIcon.Source = $Null
            }

            $Ctrl.Xaml.IO.NodeImport.IsEnabled = $Item.Status
        }
        NodePathBrowse()
        {
            $Ctrl = $This

            $Ctrl.FolderBrowse("NodePath")
        }
        NodeImport()
        {
            $Ctrl = $This

            $Ctrl.Update(0,"Setting [~] Node template import path")
            $Ctrl.Node.SetPath($Ctrl.Xaml.IO.NodePath.Text)
            $Ctrl.NodeRefresh()
        }
        NodeHandle()
        {
            $Ctrl = $This

            $Ctrl.Xaml.IO.NodeCreate.IsEnabled = 0
            $Ctrl.Xaml.IO.NodeRemove.IsEnabled = 0
            $Ctrl.Xaml.IO.NodeRefresh.IsEnabled = 1

            If ($Ctrl.Xaml.IO.NodeOutput.SelectedIndex -ne -1)
            {
                $Selected = $Ctrl.Xaml.IO.NodeOutput.SelectedItem
                $Mode     = $Selected.Type -eq "Template"
                $Slot     = @($Ctrl.Node.Host,$Ctrl.Node.Template)[$Mode]
                $Item     = $Slot | ? Guid -eq $Selected.Guid
                $Ctrl.Reset($Ctrl.Xaml.IO.NodeExtension,$Ctrl.Property($Item))

                $Ctrl.Xaml.IO.NodeCreate.IsEnabled = $Mode
                $Ctrl.Xaml.IO.NodeRemove.IsEnabled = 1
            }
        }
        NodeCreate()
        {
            $Ctrl = $This
            $Item = $Ctrl.Xaml.IO.NodeOutput.SelectedItem
                    
            Switch ($Item.Type)
            {
                Host
                {
                    [System.Windows.MessageBox]::Show("Invalid type","Error")
                }
                Template
                {
                    [System.Windows.MessageBox]::Show("Not yet implemented","Error")
                }
            }
        }
        NodeRemove()
        {
            $Ctrl = $This

            $Item = $Ctrl.Xaml.IO.NodeOutput.SelectedItem
            Switch ($Item.Type)
            {
                Host
                {
                    $xNode = $Ctrl.Node.Host | ? Guid -eq $Item.Guid
                    $Vm    = $Ctrl.Node.VmNodeObject($xNode)
                    $Vm.Remove()
                }
                Template
                {
                    $xNode = Get-ChildItem $Ctrl.Node.Path | ? Name -match $Item.Name
                    Remove-Item $xNode.Fullname -Verbose
                }
            }

            $Ctrl.Node.Refresh()
            $Ctrl.Reset($Ctrl.Xaml.IO.NodeOutput,$Ctrl.Node.Object)
            $Ctrl.Reset($Ctrl.Xaml.IO.NodeExtension,$Null)
        }
        Stage([String]$Name)
        {
            $This.Update(0,"Staging [~] $Name")

            $Ctrl = $This

            Switch ($Name)
            {
                Network
                {
                    $Ctrl.Xaml.IO.NetworkDomain.Add_TextChanged(
                    {
                        $Ctrl.CheckDomain()
                    })

                    $Ctrl.Xaml.IO.NetworkNetBios.Add_TextChanged(
                    {
                        $Ctrl.CheckNetBios()
                    })

                    $Ctrl.Xaml.IO.NetworkSwitchName.Add_TextChanged(
                    {
                        $Ctrl.CheckSwitchName()
                    })

                    $Ctrl.Xaml.IO.NetworkSetMain.Add_Click(
                    {
                        $Ctrl.SetMain()
                    })

                    $Ctrl.Xaml.IO.NetworkRefresh.Add_Click(
                    {
                        $Ctrl.SwitchRefresh()
                    })

                    $Ctrl.Xaml.IO.NetworkProperty.Add_SelectionChanged(
                    {
                        $Ctrl.SwitchConfig()
                    })

                    $Ctrl.Xaml.IO.NetworkInterface.Add_SelectionChanged(
                    {
                        $Ctrl.SwitchInterface()
                    })

                    $Ctrl.Xaml.IO.NetworkSwitchType.Add_SelectionChanged(
                    {
                        $Ctrl.SwitchType()
                    })

                    $Ctrl.Xaml.IO.NetworkSwitchCreate.Add_Click(
                    {
                        $Ctrl.SwitchCreate()
                    })

                    $Ctrl.Xaml.IO.NetworkSwitchRemove.Add_Click(
                    {
                        $Ctrl.SwitchRemove()    
                    })

                    $Ctrl.Xaml.IO.NetworkBase.Add_SelectionChanged(
                    {
                        $Ctrl.SwitchBase()
                    })

                    $Ctrl.Xaml.IO.NetworkRangeScan.Add_Click(
                    {
                        $Ctrl.SwitchRangeScan()
                    })

                    $Ctrl.Xaml.IO.NetworkPanel.Add_SelectionChanged(
                    {
                        $Ctrl.SwitchPanel($Ctrl.Xaml.IO.NetworkPanel.SelectedItem.Content)
                    })

                    $Ctrl.Xaml.IO.NetworkAssign.Add_Click(
                    {
                        $Ctrl.SwitchAssign()
                    })
                }
                Credential
                {
                    $Ctrl.Xaml.IO.CredentialRefresh.Add_Click(
                    {
                        $Ctrl.CredentialInitialize()
                    })

                    $Ctrl.Xaml.IO.CredentialType.Add_SelectionChanged(
                    {   
                        $Ctrl.CredentialType()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialUsername.Add_TextChanged(
                    {
                        $Ctrl.ToggleCredentialCreate()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialPassword.Add_PasswordChanged(
                    {
                        $Ctrl.ToggleCredentialCreate()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialConfirm.Add_PasswordChanged(
                    {
                        $Ctrl.ToggleCredentialCreate()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialPin.Add_PasswordChanged(
                    {
                        $Ctrl.ToggleCredentialCreate()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialGenerate.Add_Click(
                    {
                        $Ctrl.CredentialGenerate()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialOutput.Add_SelectionChanged(
                    {
                        $Ctrl.CredentialSelect()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialRemove.Add_Click(
                    {
                        $Ctrl.CredentialRemove()
                    })
                    
                    $Ctrl.Xaml.IO.CredentialCreate.Add_Click(
                    {
                        $Ctrl.CredentialCreate()
                    })

                    $Ctrl.Xaml.IO.CredentialAssign.Add_Click(
                    {
                        $Ctrl.CredentialAssign()
                    })

                    $Ctrl.Xaml.IO.CredentialType.SelectedIndex = 0

                    $Ctrl.CredentialInitialize()
                }
                Image
                {
                    $Ctrl.Xaml.IO.ImagePathBrowse.Add_Click(
                    {
                        $Ctrl.ImagePathBrowse()
                    })

                    $Ctrl.Xaml.IO.ImagePath.Add_TextChanged(
                    {
                        $Ctrl.ImageCheckPath()
                    })

                    $Ctrl.Xaml.IO.ImageImport.Add_Click(
                    {
                        $Ctrl.ImageSetPath()
                    })

                    $Ctrl.Xaml.IO.ImageStore.Add_SelectionChanged(
                    {
                        $Ctrl.ImageStore()
                    })

                    $Ctrl.Xaml.IO.ImageStoreContent.Add_SelectionChanged(
                    {
                        $Ctrl.ImageEdition()
                    })

                    $Ctrl.Xaml.IO.ImageAssign.Add_Click(
                    {
                        $Ctrl.ImageAssign()
                    })
                }
                Template
                {
                    $Ctrl.Xaml.IO.TemplateExportPath.Add_TextChanged(
                    {
                        $Ctrl.TemplateExportPath()
                    })

                    $Ctrl.Xaml.IO.TemplateExportBrowse.Add_Click(
                    {
                        $Ctrl.TemplateExportBrowse()
                    })

                    $Ctrl.Xaml.IO.TemplateSetPath.Add_Click(
                    {
                        $Ctrl.TemplateSetPath()
                    })

                    $Ctrl.Xaml.IO.TemplateName.Add_TextChanged(
                    {
                        $Ctrl.CheckTemplateName()
                        $Ctrl.ToggleTemplateCreate()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateRootPath.Add_TextChanged(
                    {
                        $Ctrl.TemplateRootPath()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateRootPathBrowse.Add_Click(
                    {
                        $Ctrl.TemplateRootPathBrowse()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateCreate.Add_Click(
                    {
                        $Ctrl.TemplateCreate()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateOutput.Add_SelectionChanged(
                    {
                        $Ctrl.TemplateHandle()
                    })

                    $Ctrl.Xaml.IO.TemplateRole.Add_SelectionChanged(
                    {
                        $Ctrl.TemplateRole()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateRemove.Add_Click(
                    {
                        $Ctrl.TemplateRemove()
                    })
                        
                    $Ctrl.Xaml.IO.TemplateExport.Add_Click(
                    {
                        $Ctrl.TemplateExport()
                    })

                    $Ctrl.Xaml.IO.TemplateNetworkUp.Add_Click(
                    {
                        $Ctrl.TemplateNetworkUp()
                    })

                    $Ctrl.Xaml.IO.TemplateNetworkDown.Add_Click(
                    {
                        $Ctrl.TemplateNetworkDown()
                    })
                        
                    $Ctrl.Reset($Ctrl.Xaml.IO.TemplateOutput,$Ctrl.DataGrid.Template.Output)
                }
                Node
                {       
                    $Ctrl.Xaml.IO.NodeRefresh.Add_Click(
                    {
                        $Ctrl.NodeRefresh()
                    })
                    
                    $Ctrl.Xaml.IO.NodePath.Add_TextChanged(
                    {
                        $Ctrl.NodePath()
                    })
                    
                    $Ctrl.Xaml.IO.NodePathBrowse.Add_Click(
                    {
                        $Ctrl.NodePathBrowse()
                    })
                    
                    $Ctrl.Xaml.IO.NodeImport.Add_Click(
                    {
                        $Ctrl.NodeImport()
                    })
                    
                    $Ctrl.Xaml.IO.NodeOutput.Add_SelectionChanged(
                    {
                        $Ctrl.NodeHandle()
                    })
                    
                    $Ctrl.Xaml.IO.NodeCreate.Add_Click(
                    {
                        $Ctrl.NodeCreate()
                    })
                    
                    $Ctrl.Xaml.IO.NodeRemove.Add_Click(
                    {
                        $Ctrl.NodeRemove()
                    })
                }
            }
        }
        Initial([String]$Name)
        {
            Switch ($Name)
            {
                Network
                {
                    $This.Xaml.IO.NetworkSetMain.IsEnabled = 0
                    $This.Xaml.IO.NetworkRefresh.IsEnabled = 0
                }
                Credential
                {
                    $This.Xaml.IO.CredentialType.SelectedIndex = 0
                    $This.Reset($This.Xaml.IO.CredentialDescription,$This.Credential.Slot.Output[0])
            
                    $This.Xaml.IO.CredentialRemove.IsEnabled   = 0
                    $This.Xaml.IO.CredentialCreate.IsEnabled   = 0
                }
                Image
                {
                    $This.Xaml.IO.ImageImport.IsEnabled        = 0
                }
                Template
                {
                    $This.Xaml.IO.TemplateCreate.IsEnabled       = 0
                    $This.Xaml.IO.TemplateRemove.IsEnabled       = 0
                    $This.Xaml.IO.TemplateExport.IsEnabled       = 0
            
                    $This.Xaml.IO.TemplateRole.SelectedIndex     = 0

                    $This.Xaml.IO.TemplateExportPathIcon.Source  = $Null
                    $This.Xaml.IO.TemplateExportBrowse.IsEnabled = 1
                    $This.Xaml.IO.TemplateOutput.IsEnabled       = 0
                }
                Node
                {
                    $This.Xaml.IO.NodeCreate.IsEnabled           = 0
                    $This.Xaml.IO.NodeRemove.IsEnabled           = 0
                    $This.Xaml.IO.NodeImport.IsEnabled           = 0
                }
            }
        }
        StageXaml()
        {
            # [Event handler stuff]
            $This.Stage("Network")
            $This.Stage("Credential")
            $This.Stage("Image")
            $This.Stage("Template")
            $This.Stage("Node")

            # [Initial properties/settings]
            $This.Initial("Network")
            $This.Initial("Credential")
            $This.Initial("Image")
            $This.Initial("Template")
            $This.Initial("Node")
        }
        Reload()
        {
            $This.Reinstantiate()
            $This.StageXaml()
            $This.Invoke()
        }
        Invoke()
        {
            $This.Update(0,"Invoking [~] Xaml Interface")
            Try
            {
                $This.Xaml.Invoke()
            }
            Catch
            {
                $This.Module.Write(1,"Exception [!] Either the user cancelled, or the dialog failed.")
            }
        }
        [String] ToString()
        {
            Return "<FEModule.NewVmController.Master>"
        }
    }

    $Ctrl = [NewVmControllerMaster]::New()
    Switch ($Mode)
    {
        0 
        {
            $Ctrl
        }
        1
        {
            $Ctrl.Reload()
            $Ctrl
        }
    }
}
