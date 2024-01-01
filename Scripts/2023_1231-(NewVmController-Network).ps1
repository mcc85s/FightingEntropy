<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Generic    ]__________________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

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

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Validation ]__________________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

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
    NewVmControllerValidationPath([String]$Entry)
    {
        $This.Status       = [UInt32]($Entry -match "^\w+\:\\")
        $This.Fullname     = $Entry
        If ($This.Status -eq 1)
        {
            Try
            {
                If ([System.IO.FileInfo]::new($Entry).Attributes -match "Directory")
                {
                    $This.Type   = "Directory" 
                }
                Else
                {
                    $This.Type   = "File"
                }
                
                $This.Name       = Split-Path -Leaf $Entry

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

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Network    ]__________________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

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
    [String] ToString()
    {
        Return "<FEModule.NewVmController.Network.Master>"
    }
}

<#
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ Xaml   ]______________________________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
#>

Class NewVmControllerXaml
{
    Static [String] $Content = @(
    '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"',
    '        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"',
    '        Title="[FightingEntropy()]://(New-VmController)"',
    '        Height="510"',
    '        Width="640"',
    '        Topmost="True"',
    '        ResizeMode="NoResize"',
    '        Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\2023.4.0\Graphics\icon.ico"',
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
    '                                                Width="60"/>',
    '                            <DataGridTextColumn Header="Type"',
    '                                                Binding="{Binding Type}"',
    '                                                Width="60"/>',
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

# [Xaml subcontrols]

    # // ===============================================================================
    # // | Interface(s) DataGrid - handles the <new> template, and existing interfaces |
    # // ===============================================================================

Class NewVmControllerNetworkInterfaceGridItem
{
    [String]       $Index
    [String]        $Name
    [String]        $Type
    [UInt32]       $State
    [String]       $Alias
    [String]     $Display
    [String] $Description
    [String]        $Guid
    NewVmControllerNetworkInterfaceGridItem()
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
    NewVmControllerNetworkInterfaceGridItem([Object]$Interface)
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
        Return $This.Name
    }
}

Class NewVmControllerNetworkInterfaceGridControl
{
    [Object] $Output
    NewVmControllerNetworkInterfaceGridControl()
    {
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh([Object[]]$Interface)
    {
        $This.Clear()

        # [Default <new> template item]
        $This.Output += $This.NewVmControllerNetworkInterfaceGridItem()

        # [Adds each found interface]
        ForEach ($Item in $Interface)
        {
            $This.Output += $This.NewVmControllerNetworkInterfaceGridItem($Item)
        }
    }
    [Object] NewVmControllerNetworkInterfaceGridItem()
    {
        Return [NewVmControllerNetworkInterfaceGridItem]::New()
    }
    [Object] NewVmControllerNetworkInterfaceGridItem([Object]$Interface)
    {
        Return [NewVmControllerNetworkInterfaceGridItem]::New($Interface)
    }
    [String] ToString()
    {
        Return "<FEModule.NewVmController.Network.Interface.Grid[Control]>"
    }
}

<#
Class NewVmControllerDatagridMaster
{
    [Object] $Interface
    [Object] $Credential
    [Object] 
    [Object] $Output
    NewVmControllerDatagridMaster()
    {
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
    }
    Refresh([Object[]]$Interface)
    {
        $This.Clear()

        # [Default <new> template item]
        $This.Output += $This.NewVmControllerNetworkInterfaceGridItem()

        # [Adds each found interface]
        ForEach ($Item in $Interface)
        {
            $This.Output += $This.NewVmControllerNetworkInterfaceGridItem($Item)
        }
    }
    [Object] NewVmControllerNetworkInterfaceGridItem()
    {
        Return [NewVmControllerNetworkInterfaceGridItem]::New()
    }
    [Object] NewVmControllerNetworkInterfaceGridItem([Object]$Interface)
    {
        Return [NewVmControllerNetworkInterfaceGridItem]::New($Interface)
    }
    [String] ToString()
    {
        Return "<FEModule.NewVmController.Network.Interface.Grid[Control]>"
    }
}
#>

# [Master Controller]

Class NewVmControllerMaster
{
    [Object]     $Module
    [Object]       $Xaml
    [Object] $Validation
    [Object]    $Control
    [Object]    $Network
    NewVmControllerMaster()
    {
        # Loads module controller
        $This.Module     = $This.Get("Module")

        # Loads XAML
        $This.Xaml       = $This.Get("Xaml")

        # Loads validation master
        $This.Validation = $This.Get("Validation")

        # Controls objects sent to datagrid
        $This.Control    = $This.Get("Control")

        # Loads the network master
        $This.Network    = $This.Get("Network")

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
                $This.Update(0,"Getting [~] Validation controller")
                $Item = [NewVmControllerValidationMaster]::New()
            }
            Control
            {
                $This.Update(0,"Getting [~] GUI subcontrols")
                $Item = [NewVmControllerNetworkInterfaceGridControl]::New()
            }
            Network
            {
                $This.Update(0,"Getting [~] Network Controller")
                $Item = [NewVmControllerNetworkMaster]::New()
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
        (0,"NetworkSwitchName") | % { 

            $This.Validation.Add($_[0],$This.Xaml.Get($_[1]))
        }
    }
    ToggleSetMain()
    {
        $List = $This.Validation.Output | ? Name -match "(NetworkDomain|NetworkNetBios)"

        $This.Xaml.IO.NetworkSetMain.IsEnabled = 0 -notin $List.Status
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
    RefreshNetwork()
    {
        $This.Network.Refresh()
        $This.SwitchConfig()
    }
    NetworkRangeScan()
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
    [Object[]] GetAvailablePhysical()
    {
        Return $This.Network.Adapter.Output | ? Type -eq Physical | ? Assigned -eq 0
    }
    SwitchConfig()
    {
        $List      = $This.Network.Interface.Output
        $Property  = $This.Xaml.IO.NetworkProperty.SelectedItem.Content
        If ($Property -notmatch "^\*$")
        {
            $List  = $List | ? State -match $Property
        }

        $Available = $This.GetAvailablePhysical()

        $This.Control.Refresh($List)

        $This.Reset($This.Xaml.IO.NetworkInterface,$This.Control.Output)
        $This.Reset($This.Xaml.IO.NetworkSwitchAdapter,$Available.Name)
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
            $Ctrl.Reset($Ctrl.Xaml.IO.NetworkSwitchAdapter,$Ctrl.GetAvailablePhysical().Name)
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
                $This.Reset($This.Xaml.IO.NetworkSwitchAdapter,$This.GetAvailablePhysical().Name)
                
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

        $Ctrl.RefreshNetwork()
    }
    SwitchRemove()
    {
        $Ctrl  = $This
        $Name  = $Ctrl.Xaml.IO.NetworkSwitchName.Text

        $This.Update(0,"Removing [~] [VmSwitch]: $Name")

        Remove-VmSwitch -Name $Ctrl.Xaml.IO.NetworkSwitchName.Text -Confirm:0 -Force

        $This.Update(1,"Removed [+] [VmSwitch]: $Name")

        $Ctrl.RefreshNetwork()
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
    Initial([String]$Name)
    {
        Switch ($Name)
        {
            Network
            {
                $This.Xaml.IO.NetworkSetMain.IsEnabled = 0
                $This.Xaml.IO.NetworkRefresh.IsEnabled = 0
            }
        }
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
                    $Ctrl.RefreshNetwork()
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
                    $Ctrl.NetworkRangeScan()
                })

                $Ctrl.Xaml.IO.NetworkPanel.Add_SelectionChanged(
                {
                    $Ctrl.SwitchPanel($Ctrl.Xaml.IO.NetworkPanel.SelectedItem.Content)
                })

                $Ctrl.Xaml.IO.NetworkAssign.Add_Click(
                {
                    # Assigns the selected network(s) to the template object
                    # $Item = $Ctrl.Xaml.IO.NetworkOutput.Items | ? Profile
                    # $Ctrl.Template.SetNetwork($Item)

                    # Refreshes the UI template network object
                    # $Ctrl.Reset($Ctrl.Xaml.IO.TemplateNetworkOutput,$Ctrl.Template.Network)

                    # Shows message detailing network switch count
                    # [System.Windows.MessageBox]::Show("Interface(s) ($($Ctrl.Template.Network.Count))","Assigned [+] Network(s)")
                })
            }
        }
    }
    Handle([String]$Name)
    {
        Switch ($Name)
        {
            Network
            {

            }
        }
    }
    StageXaml()
    {
        # [Event handler stuff]
        $This.Stage("Network")

        # [Initial properties/settings]
        $This.Initial("Network")
    }
    Reload()
    {
        $This.Xaml = $This.Get("Xaml")
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

If (!(Get-Module FightingEntropy))
{
    Import-Module FightingEntropy # <- loads xaml classes and stuff
}

$Ctrl = [NewVmControllerMaster]::New()
$Ctrl.StageXaml()
$Ctrl.Invoke()
