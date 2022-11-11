# Stripped down version of the Search-Wireless function for PowerShell
# Expanded the various network sub types (physical, authentication, encryption)

$Splat               = @{

    MemberDefinition = Use-Wlanapi
    Using            = "System.Text"
    Namespace        = "WiFi"
    Name             = "ProfileManagement"
}

Add-Type @Splat -Passthru | Out-Null

Enum PhysicalType
{
    Unknown
    Fhss
    Dsss
    IRBaseband
    Ofdm
    Hrdsss
    Erp
    HT
    Vht
    Dmg
    HE
}

Class PhysicalSlot
{
    [UInt32]         $Index
    [String]          $Type
    [String[]] $Description
    PhysicalSlot([String]$Type)
    {
        $This.Type        = [PhysicalType]::$Type
        $This.Index       = [UInt32][PhysicalType]::$Type
    }
    [String] ToString()
    {
        Return $This.Type
    }
}

Class PhysicalList
{
    [Object] $Output
    PhysicalList()
    {
        $This.Output = @( ) 
        [System.Enum]::GetNames([PhysicalType]) | % { $This.Add($_) }
    }
    Add([String]$Name)
    {
        $Item             = [PhysicalSlot]::New($Name)
        $Item.Description = Switch ($Name)
        {
            Unknown     { "Unspecified physical type"                      }
            Fhss        { "(FHSS/Frequency-Hopping Spread-Spectrum)"       }
            Dsss        { "(DSSS/Direct Sequence Spread-Spectrum)"         }
            IRBaseband  { "(IR/Infrared baseband)"                         }
            Ofdm        { "(OFDM/Orthogonal Frequency Division Multiplex)" }
            Hrdsss      { "(HRDSSS/High-rated DSSS)"                       }
            Erp         { "(ERP/Extended Rate)"                            }
            HT          { "(HT/High Throughput [802.11n])"                 }
            Vht         { "(VHT/Very High Throughput [802.11ac])"          }
            Dmg         { "(DMG/Directional Multi-Gigabit [802.11ad])"     }
            HE          { "(HEW/High-Efficiency Wireless [802.11ax])"      }
        }
        $This.Output += $Item
    }
    [Object] Get([String]$Type)
    {
        Return $This.Output[[UInt32][PhysicalType]::$Type]
    }
}

Enum AuthenticationType
{
    None
    Unknown
    Open80211
    SharedKey80211
    Wpa
    WpaPsk
    WpaNone
    Rsna
    RsnaPsk
    Ihv
    Wpa3
    Wpa3Sae
    Owe
    Wpa3Enterprise
}

Class AuthenticationSlot
{
    [UInt32]         $Index
    [String]          $Type
    [String[]] $Description
    AuthenticationSlot([String]$xType)
    {
        If ($xType -eq "Wpa3Enterprise192Bits")
        {
            $xType = "Wpa3"
        }
        $This.Type        = [AuthenticationType]::$xType
        $This.Index       = [UInt32][AuthenticationType]::$xType
    }
    [String] ToString()
    {
        Return $This.Type
    }
}

Class AuthenticationList
{
    [Object] $Output
    AuthenticationList()
    {
        $This.Output  = @( )
        [System.Enum]::GetNames([AuthenticationType]) | % { $This.Add($_) }
    }
    Add([String]$Type)
    {
        $Item             = [AuthenticationSlot]::New($_)
        $Item.Description = Switch -Regex ($Item.Type)
        {
            ^None$ 
            {
                "No authentication enabled."
            }
            ^Unknown$ 
            {
                "Authentication method unknown."
            }
            ^Open80211$ 
            {
                "Open authentication over 802.11 wireless.",
                "Devices are authenticated and can connect to an access point.",
                "Communication w/ network requires matching (WEP/Wired Equivalent Privacy) key."
            }
            ^SharedKey80211$ 
            { 
                "Specifies an IEEE 802.11 Shared Key authentication algorithm.",
                "Requires pre-shared (WEP/Wired Equivalent Privacy) key for 802.11 authentication."
            }
            ^Wpa$            
            { 
                "Specifies a (WPA/Wi-Fi Protected Access) algorithm.",
                "IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server.",
                "Cipher keys are dynamically derived through the authentication process."
            }
            ^WpaPsk$ 
            {
                "Specifies a (WPA/Wi-Fi Protected Access) algorithm that uses (PSK/pre-shared key).",
                "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                "Cipher keys are dynamically derived through a PSK that is used on both the supplicant and authenticator."
            }
            ^WpaNone$ 
            {
                "Wi-Fi Protected Access."
            }
            ^Rsna$
            {
                "Specifies an IEEE 802.11i (RSNA/Robust Security Network Association) algorithm.",
                "IEEE 802.1X port authorization is performed by the supplicant, authenticator, and authentication server.",
                "Cipher keys are dynamically derived through the auth. process."
            }
            ^RsnaPsk$ 
            {
                "Specifies an IEEE 802.11i RSNA algorithm that uses (PSK/pre-shared key).",
                "IEEE 802.1X port authorization is performed by the supplicant and authenticator.",
                "Cipher keys are dynamically derived through a PSK that is used on both the supplicant and authenticator."
            }
            ^Ihv$ 
            {
                "Specifies an authentication type defined by an (IHV/Independent Hardware Vendor)."
            }
            "(^Wpa3$|^Wpa3Enterprise192Bits$)"
            {
                "Specifies a 192-bit encryption mode for (WPA3-Enterprise/Wi-Fi Protected Access 3 Enterprise) networks."
            }
            ^Wpa3Sae$ 
            {
                "Specifies (WPA3 SAE/Wi-Fi Protected Access 3 Simultaneous Authentication of Equals) algorithm.",
                "WPA3 SAE is the consumer version of WPA3. SAE is a secure key establishment protocol between devices;",
                "SAE provides: synchronous authentication, and stronger protections for users against",
                "password-guessing attempts by third parties."
            }
            ^Owe$ 
            {
                "Specifies an (OWE/Opportunistic Wireless Encryption) algorithm.",
                "OWE provides opportunistic encryption over 802.11 wireless networks.",
                "Cipher keys are dynamically derived through a (DH/Diffie-Hellman) key exchange-",
                "Enabling data protection without authentication."
            }
            ^Wpa3Enterprise$ 
            {
                "Specifies a (WPA3-Enterprise/Wi-Fi Protected Access 3 Enterprise) algorithm.",
                "WPA3-Enterprise uses IEEE 802.1X in a similar way as (RSNA/Robust Security Network Association).",
                "However, it provides increased security through the use of mandatory certificate validation and protected management frames."
            }
        }
        $This.Output += $Item
    }
    [Object] Get([String]$Type)
    {
        Return $This.Output[[UInt32][AuthenticationType]::$Type]
    }
}

Enum EncryptionType
{
    None
    Unknown
    Wep
    Wep40
    Wep104
    Tkip
    Ccmp
    WpaUseGroup
    RsnUseGroup
    Ihv
    Gcmp
    Gcmp256
}

Class EncryptionSlot
{
    [UInt32]         $Index
    [String]          $Type
    [String[]] $Description
    EncryptionSlot([String]$Type)
    {
        $This.Type  = [EncryptionType]::$Type
        $This.Index = [UInt32][EncryptionType]::$Type
    }
    [String] ToString()
    {
        Return $This.Type
    }
}

Class EncryptionList
{
    [Object] $Output
    EncryptionList()
    {
        $This.Output = @( )
        [System.Enum]::GetNames([EncryptionType]) | % { $This.Add($_) }
    }
    Add([String]$Type)
    {
        $Item             = [EncryptionSlot]::New($Type)
        $Item.Description = Switch ($Item.Type)
        {
            None
            { 
                "No encryption enabled."
            }
            Unknown
            {
                "Encryption method unknown."
            }
            Wep
            {
                "Specifies a WEP cipher algorithm with a cipher key of any length."
            }
            Wep40
            {
                "Specifies an RC4-based (WEP/Wired Equivalent Privacy) algorithm specified in IEEE 802.11-1999.",
                "This enumerator specifies the WEP cipher algorithm with a 40-bit cipher key."
            }
            Wep104
            {
                "Specifies a (WEP/Wired Equivalent Privacy) cipher algorithm with a 104-bit cipher key."
            }
            Tkip
            {
                "Specifies an RC4-based cipher (TKIP/Temporal Key Integrity Protocol) algorithm",
                "This cipher suite that is based on algorithms defined in WPA + IEEE 802.11i-2004 standards.",
                "This cipher also uses the (MIC/Message Integrity Code) algorithm for forgery protection."
            }
            Ccmp
            {
                "Specifies an [IEEE 802.11i-2004 & RFC 3610] AES-CCMP algorithm standard.",
                "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
            }
            WpaUseGroup
            {
                "Specifies a (WPA/Wifi Protected Access) Use Group Key cipher suite.",
                "For more information about the Use Group Key cipher suite, refer to:",
                "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
            }
            RsnUseGroup
            {
                "Specifies a (RSN/Robust Security Network) Use Group Key cipher suite.",
                "For more information about the Use Group Key cipher suite, refer to:",
                "Clause 7.3.2.25.1 of the IEEE 802.11i-2004 standard."
            }
            Ihv
            {
                "Specifies an encryption type defined by an (IHV/Independent Hardware Vendor)."
            }
            Gcmp
            {
                "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 128-bit key.",
                "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
            }
            Gcmp256
            { 
                "Specifies an [IEEE 802.11-2016] AES-GCMP algorithm w/ 256-bit key.",
                "(AES/Advanced Encryption Standard) is the encryption algorithm defined in FIPS PUB 197."
            }
        }
        $This.Output     += $Item
    }
    [Object] Get([String]$Type)
    {
        Return $This.Output[[UInt32][EncryptionType]::$Type]
    }
}

Class SsidSubcontroller
{
    [Object] $Physical
    [Object] $Authentication
    [Object] $Encryption
    SsidSubcontroller()
    {
        $This.Physical       = [PhysicalList]::New()
        $This.Authentication = [AuthenticationList]::New()
        $This.Encryption     = [EncryptionList]::New()
    }
    Load([Object]$Ssid)
    {
        $Ssid.Physical       = $This.Physical.Get($Ssid.Ssid.PhyKind)
        $Ssid.Uptime         = $This.GetUptime($Ssid.Ssid.Uptime)
        $Ssid.Authentication = $This.Authentication.Get($Ssid.Ssid.SecuritySettings.NetworkAuthenticationType)
        $Ssid.Encryption     = $This.Encryption.Get($Ssid.Ssid.SecuritySettings.NetworkEncryptionType)
    }
    [String] GetUptime([Object]$Uptime)
    {
        Return @( Switch ($Uptime)
        {
            {$_.Days -gt 0}
            {
                $Uptime | % { "{0}d {1}h {2}m {3}s" -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds }
            }
            {$_.Days -eq 0 -and $_.Hours -gt 0}
            {
                $Uptime | % { "{0}h {1}m {2}s" -f $_.Hours, $_.Minutes, $_.Seconds }
            }
            {$_.Hours -eq 0 -and $_.Seconds -gt 0}
            {
                $Uptime | % { "{0}m {1}s" -f $_.Minutes, $_.Seconds }
            }
        })
    }
}

# // _____________________________________________________________________________________________
# // | Provides an accurate representation of the information collected by the wireless radio(s) |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Ssid
{
    [UInt32]            $Index
    Hidden [Object]      $Ssid
    [String]             $Name
    [Object]            $Bssid
    [Object]         $Physical
    [Object]          $Network
    [Object]           $Uptime
    [Object]   $Authentication
    [Object]       $Encryption
    [UInt32]         $Strength
    [String]   $BeaconInterval
    [Double] $ChannelFrequency
    [Bool]       $IsWifiDirect
    Ssid([UInt32]$Index,[Object]$Object)
    {
        $This.Index              = $Index
        $This.Ssid               = $Object
        $This.Name               = $Object.Ssid
        $This.Bssid              = $Object.Bssid.ToUpper()
        $This.Network            = $Object.NetworkKind
        $This.Strength           = $Object.SignalBars
        $This.BeaconInterval     = $Object.BeaconInterval
        $This.ChannelFrequency   = $Object.ChannelCenterFrequencyInKilohertz
        $This.IsWiFiDirect       = $Object.IsWiFiDirect
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

# // _______________________________
# // | Handles the profile objects |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class WiFiProfile
{
    [Object] $Interface
    [String] $Name
    [String] $Flags
    [Object] $Detail
    WiFiProfile([Object]$Interface,[Object]$ProfileInfo)
    {
        $This.Interface = $Interface
        $This.Name      = $ProfileInfo.strProfileName
        $This.Flags     = $ProfileInfo.ProfileFlags
        $This.Detail    = $Null
    }
    [String[]] ToString()
    {
        Return @(
        " ",
        "Interface       : $($This.Interface.Name)",
        "Guid            : $($This.Interface.Guid)",
        "Description     : $($This.Interface.Description)",
        "IfIndex         : $($This.Interface.ifIndex)",
        "Status          : $($This.Interface.Status)",
        "MacAddress      : $($This.Interface.MacAddress)",
        "LinkSpeed       : $($This.Interface.LinkSpeed)",
        "State           : $($This.Interface.State)",
        "----"
        "SSID            : $($This.Name)",
        "Flags           : $($This.Flags)",
        "ProfileName     : $($This.Detail.ProfileName)",
        "ConnectionMode  : $($This.Detail.ConnectionMode)",
        "Authentication  : $($This.Detail.Authentication)",
        "Encryption      : $($This.Detail.Encryption)",
        "Password        : $($This.Detail.Password)",
        "HiddenSSID      : $($This.Detail.ConnectHiddenSSID)",
        "EAPType         : $($This.Detail.EAPType)",
        "ServerNames     : $($This.Detail.ServerNames)",
        "TrustedRootCA   : $($This.Detail.TrustedRootCA)",
        "----",
        "XML             : $($This.Detail.Xml)",
        " "
        )
    }
}

# // ____________________________________________________________
# // | Represents an individual wireless interface on the host. |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class InterfaceObject
{
    [String] $Name
    [String] $Guid
    [String] $Description
    [UInt32] $ifIndex 
    [String] $Status
    [String] $MacAddress
    [String] $LinkSpeed
    [String] $State
    InterfaceObject([Object]$Info,[Object]$Interface)
    {
        $This.Name        = $Interface.Name
        $This.Guid        = $Info.Guid
        $This.Description = $Info.Description
        $This.ifIndex     = $Interface.ifIndex
        $This.Status      = $Interface.Status
        $This.MacAddress  = $Interface.MacAddress.Replace("-",":")
        $This.LinkSpeed   = $Interface.LinkSpeed
        $This.State       = $Info.State
    }
}

# // ____________________________________________________________
# // | Parses WLAN adapter information returned from the netsh. |
# // | Not nearly as CLEAN as accessing wlanapi.dll...?         |
# // | But- it is included as a FALLBACK MECHANISM.             |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class WlanInterface
{
    Hidden [String[]] $Select
    [String] $Name
    [String] $Description
    [String] $Guid
    [String] $MacAddress
    [String] $InterfaceType
    [String] $State
    [String] $Ssid
    [String] $Bssid
    [String] $NetworkType
    [String] $RadioType
    [String] $Authentication
    [String] $Cipher
    [String] $Connection
    [String] $Band
    [UInt32] $Channel
    [Float]  $Receive
    [Float]  $Transmit
    [String] $Signal
    [String] $Profile
    WlanInterface([String[]]$Select)
    {
        $This.Select                 = $Select
        $This.Name                   = $This.Find("Name")
        $This.Description            = $This.Find("Description")
        $This.GUID                   = $This.Find("GUID")
        $This.MacAddress             = $This.Find("Physical address")
        $This.InterfaceType          = $This.Find("Interface type")
        $This.State                  = $This.Find("State")
        $This.Ssid                   = $This.Find("SSID")
        $This.Bssid                  = $This.Find("BSSID") | % ToUpper
        $This.NetworkType            = $This.Find("Network type")
        $This.RadioType              = $This.Find("Radio type")
        $This.Authentication         = $This.Find("Authentication")
        $This.Cipher                 = $This.Find("Cipher")
        $This.Connection             = $This.Find("Connection mode")
        $This.Band                   = $This.Find("Band")
        $This.Channel                = $This.Find("Channel")
        $This.Receive                = $This.Find("Receive rate \(Mbps\)")
        $This.Transmit               = $This.Find("Transmit rate \(Mbps\)")
        $This.Signal                 = $This.Find("Signal")
        $This.Profile                = $This.Find("Profile")
    }
    [String] Find([String]$String)
    {
        Return @(($This.Select | ? { $_ -match "(^\s+$String\s+\:)" }).Substring(29))
    }
}

# // _____________________________________________________________
# // | Specifically for selecting/filtering a Runtime IAsyncTask |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class RtMethod
{
    [String] $Name
    [Object] $Params
    [Object] $Count
    [Object] $Object
    RtMethod([Object]$Object)
    {
        $This.Object = $Object
        $This.Params = $Object.GetParameters()
        $This.Count  = $This.Params.Count
        $This.Name   = $This.Params[0].ParameterType.Name
    }
}

# // ___________________________
# // | Better than a hashtable |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class ConnectionModeResolver
{
    [String] $Profile           = "WLAN_CONNECTION_MODE_PROFILE"
    [String] $TemporaryProfile  = "WLAN_CONNECTION_MODE_TEMPORARY_PROFILE"
    [String] $DiscoverySecure   = "WLAN_CONNECTION_MODE_DISCOVERY_SECURE"
    [String] $Auto              = "WLAN_CONNECTION_MODE_AUTO"
    [String] $DiscoveryUnsecure = "WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE"
}

# // __________________________________________________________________________________
# // | Controller class for the function, this encapsulates the XAML/GUI, as well as  |
# // | ALL of the various classes and functions necessary to access the radios.       |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Wireless
{
    Hidden [Object] $Module
    Hidden [String] $OEMLogo
    Hidden [Object] $Sub
    [Object] $Adapters
    [Object] $Request
    [Object] $Radios
    [Object] $List
    [Object] $Output
    [Object] $Selected
    [Object] $Connected
    [Object] Task()
    {
        Return [System.WindowsRuntimeSystemExtensions].GetMethods() | ? Name -eq AsTask | % { 
               [RtMethod]$_ } | ? Count -eq 1 | ? Name -eq IAsyncOperation``1 | % Object
    }
    [Object] RxStatus()
    {
        Return [Windows.Devices.Radios.RadioAccessStatus]
    }
    [Object[]] RxAsync()
    {
        Return [Windows.Devices.Radios.Radio]::RequestAccessAsync()
    }
    [Object] RsList()
    {
        Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]]
    }
    [Object[]] RsAsync()
    {
        Return [Windows.Devices.Radios.Radio]::GetRadiosAsync()
    }
    [Object] RaList()
    {
        Return [System.Collections.Generic.IReadOnlyList[Windows.Devices.WiFi.WiFiAdapter]]
    }
    [Object[]] RaAsync()
    {
        Return [Windows.Devices.WiFi.WiFiAdapter]::FindAllAdaptersAsync()
    }
    [Object] RadioRequestAccess()
    {
        Return $This.Task().MakeGenericMethod($This.RxStatus()).Invoke($Null,$This.RxAsync())
    }        
    [Object] RadioSynchronization()
    {
        Return $This.Task().MakeGenericMethod($This.RsList()).Invoke($Null, $This.RsAsync())
    }
    [Object] RadioFindAllAdaptersAsync()
    {
        Return $This.Task().MakeGenericMethod($This.RaList()).Invoke($Null, $This.RaAsync())
    }
    [Object] NetshShowInterface([String]$Name)
    {
        Return [WlanInterface]::New((netsh wlan show interface $Name))
    }
    [String] Win32Exception([UInt32]$RC)
    {
        # // __________________
        # // | RC: ReasonCode |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[System.ComponentModel.Win32Exception]::new($RC)" | IEX
    }
    [Object] WlanReasonCodeToString([UInt32]$RC,[UInt32]$BS,[Object]$SB,[IntPtr]$Res)
    {
        # // _______________________________________________________________________
        # // | RC: ReasonCode | BS: BufferSize | SB: StringBuilder | Res: Reserved |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanReasonCodeToString($RC,$BS,$SB,$Res)" | IEX
    }
    [Void] WlanFreeMemory([IntPtr]$P)
    {
        # // ______________
        # // | P: Pointer |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        "[WiFi.ProfileManagement]::WlanFreeMemory($P)" | IEX
    }
    [Object] WlanOpenHandle([UInt32]$CV,[IntPtr]$PR,[UInt32]$NV,[IntPtr]$CH)
    {
        # // ________________________________________________________________________________
        # // | CV: ClientVersion | PR: pReserved | NV: NegotiatedVersion | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanOpenHandle($CV, $PR, $NV, $CH)" | IEX
    }
    [Object] WlanCloseHandle([IntPtr]$CH,[IntPtr]$Res)
    {
        # // ____________________________________
        # // | CH: ClientHandle | Res: Reserved |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanCloseHandle($CH, $Res)" | IEX
    }
    [Object] WlanEnumInterfaces([IntPtr]$CH,[IntPtr]$PR,[IntPtr]$IL)
    {
        # // __________________________________________________________
        # // | CH: ClientHandle | PR: pReserved | IL: ppInterfaceList |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanEnumInterfaces($CH, $PR, $IL)" | IEX
    }
    [Object] WlanInterfaceList([IntPtr]$IIL)
    {
        # // ____________________________
        # // | IIL: ppInterfaceInfoList |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+WLAN_INTERFACE_INFO_LIST]::new($IIL)" | IEX
    }
    [Object] WlanInterfaceInfo([Object]$II)
    {
        # // _________________________
        # // | II: WlanInterfaceInfo |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+WLAN_INTERFACE_INFO]$II" | IEX
    }
    [Object] WlanGetProfileList([IntPtr]$CH,[guid]$IG,[IntPtr]$PR,[IntPtr]$PL)
    {
        # // __________________________________________________________________________
        # // | CH: ClientHandle | IG: InterfaceGuid | PR: pReserved | PL: ProfileList |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanGetProfileList($CH,$IG,$PR,$PL)" | IEX
    }
    [Object[]] WlanGetProfileListFromPtr([IntPtr]$PLP)
    {
        # // ___________________________
        # // | PLP: ProfileListPointer |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+WLAN_PROFILE_INFO_LIST]::new($PLP).ProfileInfo" | IEX
    }
    [Object] WlanGetProfile([IntPtr]$CH,[Guid]$IG,[String]$PN,[IntPtr]$PR,[String]$X,[UInt32]$F,[UInt32]$A)
    {
        # // __________________________________________________________
        # // | CH: ClientHandle | IG: InterfaceGuid | PN: ProfileName |
        # // | PR: pReserved | X: Xml | F: Flags | A: Access          |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanGetProfile($CH,$IG,$PN,$PR,$X,$F,$A)" | IEX
    }
    [Object] WlanProfileInfoObject()
    {
        Return "[WiFi.ProfileManagement+ProfileInfo]::New()" | IEX
    }
    [Object] WlanConnectionParams()
    {
        Return "[WiFi.ProfileManagement+WLAN_CONNECTION_PARAMETERS]::new()" | IEX
    }
    [Object] WlanConnectionMode([String]$CM)
    {
        # // ______________________
        # // | CM: ConnectionMode |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+WLAN_CONNECTION_MODE]::$CM" | IEX
    }
    [Object] WlanDot11BssType([String]$D)
    {
        # // ___________________
        # // | D: Dot11BssType |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+DOT11_BSS_TYPE]::$D" | IEX
    }
    [Object] WlanConnectionFlag([String]$F)
    {
        # // ___________
        # // | F: Flag |
        # // ¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement+WlanConnectionFlag]::$F" | IEX
    }
    [Object] WlanSetProfile([UInt32]$CH,[Guid]$IG,[UInt32]$F,[IntPtr]$PX,[IntPtr]$PS,
                            [Bool]$O,[IntPtr]$PR,[IntPtr]$pdw)
    {
        # // ___________________________________________________________________________
        # // | CH: ClientHandle | IG: InterfaceGuid | F: Flags | PX: ProfileXml        |
        # // | PS: ProfileSecurity | O: Overwrite | PR: pReserved | PDW: pdwReasonCode |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return "[WiFi.ProfileManagement]::WlanSetProfile($CH,$IG,$F,$PX,$PS,$O,$PR,$PDW)" | IEX
    }
    [Void] WlanDeleteProfile([IntPtr]$CH,[Guid]$IG,[String]$PN,[IntPtr]$PR)
    {
        # // __________________________________________________________________________
        # // | CH: ClientHandle | IG: InterfaceGuid | PN: ProfileName | PR: pReserved |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        "[WiFi.ProfileManagement]::WlanDeleteProfile($CH,$IG,$PN,$PR)" | IEX
    }
    [Void] WlanDisconnect([IntPtr]$HCH,[Guid]$IG,[IntPtr]$PR)
    {
        # // __________________________________________________________
        # // | HCH: hClientHandle | IG: InterfaceGuid | PR: pReserved |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        "[WiFi.ProfileManagement]::WlanDisconnect($HCH,$IG,$PR)" | IEX
    }
    [Void] WlanConnect([IntPtr]$HCH,[Guid]$IG,[Object]$CP,[IntPtr]$PR)
    {
        # // _____________________________________________________________________________________
        # // | HCH: hClientHandle | IG: InterfaceGuid | CP: ConnectionParameters | PR: pReserved |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        "[WiFi.ProfileManagement]::WlanConnect($HCH,$IG,$CP,$PR" | IEX
    }
    [String] WiFiReasonCode([IntPtr]$RC)
    {
        # // __________________
        # // | RC: ReasonCode |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $SB          = [Text.StringBuilder]::New(1024)
        $result      = $This.WlanReasonCodeToString($RC.ToInt32(),$SB.Capacity,$SB,[IntPtr]::zero)

        If ($result -ne 0)
        {
            Return $This.Win32Exception($result)
        }

        Return $SB.ToString()
    }
    [IntPtr] NewWifiHandle()
    {
        # // ____________________________________________________________
        # // | MC: MaxClient | NV: NegotiatedVersion | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $MC       = 2
        [Ref] $NV = 0
        $CH       = [IntPtr]::zero
        $result   = $This.WlanOpenHandle($MC,[IntPtr]::Zero,$NV,[Ref]$CH)

        If ($result -eq 0)
        {
            Return $CH
        }
        Else
        {
            Throw $This.Win32Exception($Result)
        }
    }
    [Void] RemoveWifiHandle([IntPtr]$CH)
    {
        # // ____________________
        # // | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $Result = $This.WlanCloseHandle($CH,[IntPtr]::zero)

        If ($Result -ne 0)
        {
            Throw $This.Win32Exception($Result)
        }
    }
    [Object] GetWiFiInterfaceGuid([String]$WFAN)
    {
        # // _____________________________________________________________________
        # // | WFAN: WiFiAdapterName | IG: InterfaceGuid | WFAI: WiFiAdapterInfo |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $IG   = $Null
        Switch ([Environment]::OSVersion.Version -ge [Version]6.2)
        {
            $True
            {
                $IG   = Get-NetAdapter -Name $WFAN -EA 0 | % InterfaceGuid
            }
            $False
            {
                $WFAI = Get-WmiObject Win32_NetworkAdapter | ? NetConnectionID -eq $WFAN
                $IG   = Get-WmiObject Win32_NetworkAdapterConfiguration | ? { 

                    $_.Description -eq $WFAI.Name | % SettingID
                }
            }
        }

        Return [System.Guid]$IG
    }
    [Object[]] GetWiFiInterface()
    {
        # // _____________________________________________________________________________________
        # // | IL: InterfaceListPtr | CH: ClientHandle | WFIL: WiFiInterfaceList | IF: Interface |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $IL            = 0
        $CH            = $This.NewWiFiHandle()
        $This.Adapters = $This.RefreshAdapterList()
        $Return        = @( )
        Try
        {
            [Void]$This.WlanEnumInterfaces($CH,[IntPtr]::zero,[ref]$IL)
            $WFIL = $This.WlanInterfaceList($IL)
            ForEach ($wlanInterfaceInfo in $WFIL.wlanInterfaceInfo)
            {
                $Info      = $this.WlanInterfaceInfo($wlanInterfaceInfo)
                $Interface = $This.Adapters | ? InterfaceDescription -eq $Info.Description
                $Return   += [InterfaceObject]::New($Info,$Interface)
            }
        }
        Catch
        {
            Write-Host "No wireless interface(s) found"
            $Return += $Null
        }
        Finally
        {
            $This.RemoveWiFiHandle($CH)
        }

        Return @($Return)
    }
    [Object[]] GetWiFiProfileList([String]$Name)
    {
        # // ________________________________________________________________________________
        # // | PLP: ProfileListPointer | IF: Interface | CH: ClientHandle | PL: ProfileList |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $PLP    = 0
        $IF     = $This.GetWifiInterface() | ? Name -match $Name
        $CH     = $This.NewWifiHandle()
        $Return = @( )

        $This.WlanGetProfileList($CH,$IF.GUID,[IntPtr]::zero,[Ref]$PLP)
        
        $PL     = $This.WlanGetProfileListFromPtr($PLP)

        ForEach ($ProfileName in $PL)
        {
            $Item           = [WiFiProfile]::New($IF,$ProfileName)
            $Item.Detail    = $This.GetWiFiProfileInfo($Item.Name,$IF.Guid)
            $Return        += $Item
        }

        $This.RemoveWiFiHandle($CH)

        Return $Return
    }
    [Object] GetWiFiProfileInfo([String]$PN,[Guid]$IG,[Int16]$WPF)
    {
        # // __________________________________________________________________________________
        # // | PN: ProfileName | IG: InterfaceGuid | WPF: WlanProfileFlags | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        [IntPtr]$CH              = $This.NewWifiHandle()
        $WlanProfileFlagsInput   = $WPF
        $Return                  = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
        $This.RemoveWiFiHandle($CH)
        Return $Return
    }
    [Object] GetWifiProfileInfo([String]$PN,[Guid]$IG)
    {
        # // __________________________________________________________
        # // | PN: ProfileName | IG: InterfaceGuid | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        [IntPtr]$CH            = $This.NewWifiHandle()
        $WlanProfileFlagsInput = 0
        $Return                = $This.WiFiProfileInfo($PN,$IG,$CH,$WlanProfileFlagsInput)
        $This.RemoveWiFiHandle($CH)
        Return $Return
    }
    [Object] WiFiProfileInfo([String]$PN,[Guid]$IG,[IntPtr]$CH,[Int16]$WPFI)
    {
        # // __________________________________________________________________________________
        # // | PN: ProfileName | IG: IntGuid | CH: ClientHandle | WPFI: WlanProfileFlagsInput |
        # // | PS: pstrProfileXml | WA: WlanAccess | WlanPF: WlanProfileFlags | PW: Password  | 
        # // | CHSSID: ConnectHiddenSSID | EAP: EapType | X: XmlPtr | SN: ServerNames         |
        # // | TRCA: TrustedRootCA | WP: WlanProfile
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        [String] $PS = $null
        $WA          = 0
        $WlanPF      = $WPFI
        $result      = $This.WlanGetProfile($CH,$IG,$PN,[IntPtr]::Zero,[Ref]$PS,[Ref]$WlanPF,[Ref]$WA)
        $PW          = $Null
        $CHSSID      = $Null
        $Eap         = $Null
        $xmlPtr      = $Null
        $SN          = $Null
        $TRCA        = $Null
        $Return      = $Null

        If ($result -ne 0)
        {
            Return $This.Win32Exception($Result)
        }

        $WP          = [Xml]$PS

        # // __________________
        # // | Parse password |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If ($WPFI -eq 13)
        {
            $PW      = $WP.WLANProfile.MSM.security.sharedKey.keyMaterial
        }
        If ($WPFI -ne 13)
        {
            $PW            = $Null
        }

        # // ___________________________
        # // | Parse nonBroadcast flag |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If ([bool]::TryParse($WP.WLANProfile.SSIDConfig.nonBroadcast,[Ref]$null))
        {
            $CHSSID = [bool]::Parse($WP.WLANProfile.SSIDConfig.nonBroadcast)
        }
        Else
        {
            $CHSSID = $false
        }

        # // __________________
        # // | Parse EAP type |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If ($WP.WLANProfile.MSM.security.authEncryption.useOneX -eq $true)
        {
            $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.EapMethod.Type.InnerText | % { 

                $EAP   = Switch ($_) { 13 { 'TLS'  } 25 { 'PEAP' }  Default { 'Unknown' } }
                                         # 13: EAP-TLS | 25: EAP-PEAP (MSCHAPv2)
            }
        }
        Else
        {
            $EAP = $null
        }

        # // ________________________________
        # // | Parse Validation Server Name |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If (!!$Eap)
        {
            $Cfg = $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config 
            Switch ($Eap)
            {
                PEAP
                {

                    $SN   = $Cfg.Eap.EapType.ServerValidation.ServerNames
                } 

                TLS
                {
                    $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                    $SN   = $Node[0].InnerText
                }
            }
        }

        # // __________________________________
        # // | Parse Validation TrustedRootCA |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If (!!$EAP)
        {
            $Cfg = $WP.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config
            Switch ($EAP)
            {
                PEAP
                {
                    $TRCA = $Cfg.Eap.EapType.ServerValidation.TrustedRootCA.Replace(' ','') | % ToLower
                }
                TLS
                {
                    $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                    $TRCA = $Node[0].InnerText.Replace(' ','') | % ToLower
                }
            }
        }

        $Return                   = $This.WlanProfileInfoObject()
        $Return.ProfileName       = $WP.WlanProfile.SSIDConfig.SSID.name
        $Return.ConnectionMode    = $WP.WlanProfile.ConnectionMode
        $Return.Authentication    = $WP.WlanProfile.MSM.Security.AuthEncryption.Authentication
        $Return.Encryption        = $WP.WlanProfile.MSM.Security.AuthEncryption.Encryption
        $Return.Password          = $PW
        $Return.ConnectHiddenSSID = $CHSSID
        $Return.EAPType           = $EAP
        $Return.ServerNames       = $SN
        $Return.TrustedRootCA     = $TRCA
        $Return.Xml               = $PS

        $xmlPtr                   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAuto($PS)
        $This.WlanFreeMemory($xmlPtr)

        Return $Return
    }
    [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
    {
        # // ____________________________________________________________________
        # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType | F: Flag |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return $This.WifiConnectionParameter($PN,$CM,$D,$F)
    }
    [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM,[String]$D)
    {
        # // __________________________________________________________
        # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return $This.WifiConnectionParameter($PN,$CM,$D,"Default")
    }
    [Object] GetWiFiConnectionParameter([String]$PN,[String]$CM)
    {
        # // ________________________________________
        # // | PN: ProfileName | CM: ConnectionMode |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return $This.WifiConnectionParameter($PN,$CM,"Any","Default")
    }
    [Object] GetWiFiConnectionParameter([String]$PN)
    {
        # // ___________________
        # // | PN: ProfileName |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return $This.WifiConnectionParameter($PN,"Profile","Any","Default")
    }
    [Object] WifiConnectionParameter([String]$PN,[String]$CM,[String]$D,[String]$F)
    {
        # // __________________________________________________________
        # // | PN: ProfileName | CM: ConnectionMode | D: Dot11BssType |
        # // | F: Flag | CMR: ConnectionModeResolver | P: Profile     |
        # // | CP: ConnectionParameters                               |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        
        Try
        {

            $CMR                   =  [ConnectionModeResolver]::New()

            $CP                    = $This.WlanConnectionParams()
            $CP.StrProfile         = $PN
            $CP.WlanConnectionMode = $This.WlanConnectionMode($CMR[$CM])
            $CP.Dot11BssType       = $This.WlanDot11BssType($D)
            $CP.dwFlags            = $This.WlanConnectionFlag($F)
        }
        Catch
        {
            Throw "An error occurred while setting connection parameters"
        }

        Return $CP
    }
    [Object] FormatXml([Object]$Content)
    {
        $StringWriter          = [System.IO.StringWriter]::New()
        $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
        $XmlWriter.Formatting  = "Indented"
        $XmlWriter.Indentation = 4
        ([Xml]$Content).WriteContentTo($XmlWriter)
        $XmlWriter.Flush()
        $StringWriter.Flush()
        Return $StringWriter.ToString()
    }
    [Object] XmlTemplate([UInt32]$Type)
    {
        $xList = (0,"Personal"),(1,"EapPeap"),(2,"EapTls") | % { "($($_[0]): $($_[1]))" }

        If ($Type -notin 0..2)
        {
            Throw "Select a valid type: [$($xList -join ", ")]"
        }
    
        $P = "http://www.microsoft.com/provisioning"
        
        $xProfile = Switch ($Type)
        {
            0 # WiFiProfileXmlPersonal
            {
                '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                'uthentication>'),'<encryption>{4}</encryption>','<useOneX>false</useOneX>',('</authEncry'+
                'ption>'),'<sharedKey>','<keyType>passPhrase</keyType>','<protected>false</protected>',
                '<keyMaterial>{5}</keyMaterial>','</sharedKey>','</security>','</MSM>',('<MacRandomizatio'+
                'n xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">'),('<enableRandomization>'+
                'false</enableRandomization>'),"</MacRandomization>",'</WLANProfile>'
            }
            1 # WiFiProfileXmlEapPeap
            {
                '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                'me>'),'</SSID>',('</SSIDConfig>'),'<connectionType>ESS</connectionType>',('<connectionMo'+
                'de>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}<'+
                '/authentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncr'+
                'yption>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMK'+
                'CacheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http'+
                '://www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPC'+
                'onfig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapH"+
                "ostConfig'>25</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns"+
                "='$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMe'+
                'thod>'),"<Config xmlns='$P/EapHostConfig'>",("<Eap xmlns='$P/BaseEapConnectionProperties"+
                "V1'>"),'<Type>25</Type>',"<EapType xmlns='$P/MsPeapConnectionPropertiesV1'>",('<ServerVa'+
                'lidation>'),('<DisableUserPromptForServerValidation>false</DisableUserPromptForServerVal'+
                'idation>'),'<ServerNames></ServerNames>','<TrustedRootCA></TrustedRootCA>',('</ServerVal'+
                'idation>'),'<FastReconnect>true</FastReconnect>',('<InnerEapOptional>false</InnerEapOpti'+
                'onal>'),"<Eap xmlns='$P/BaseEapConnectionPropertiesV1'>",'<Type>26</Type>',("<EapType xm"+
                "lns='$P/MsChapV2ConnectionPropertiesV1'>"),('<UseWinLogonCredentials>false</UseWinLogonC'+
                'redentials>'),'</EapType>','</Eap>',('<EnableQuarantineChecks>false</EnableQuarantineChe'+
                'cks>'),'<RequireCryptoBinding>false</RequireCryptoBinding>','<PeapExtensions>',("<Perfor"+
                "mServerValidation xmlns='$P/MsPeapConnectionPropertiesV2'>true</PerformServerValidation>"+
                ""),"<AcceptServerName xmlns='$P/MsPeapConnectionPropertiesV2'>true</AcceptServerName>",
                "<PeapExtensionsV2 xmlns='$P/MsPeapConnectionPropertiesV2'>",("<AllowPromptingWhenServerC"+
                "ANotFound xmlns='$P/MsPeapConnectionPropertiesV3'>true</AllowPromptingWhenServerCANotFou"+
                "nd>"),'</PeapExtensionsV2>','</PeapExtensions>','</EapType>','</Eap>','</Config>',('</Ea'+
                'pHostConfig>'),'</EAPConfig>','</OneX>','</security>','</MSM>',('<MacRandomization xmlns'+
                '="http://www.microsoft.com/networking/WLAN/profile/v3">'),("<enableRandomization>false</"+
                "enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
            }
            2 # WiFiProfileXmlEapTls
            {
                '<?xml version="1.0"?>',('<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/pr'+
                'ofile/v1">'),'<name>{0}</name>','<SSIDConfig>','<SSID>','<hex>{1}</hex>',('<name>{0}</na'+
                'me>'),'</SSID>','</SSIDConfig>','<connectionType>ESS</connectionType>',('<connectionMode'+
                '>{2}</connectionMode>'),'<MSM>','<security>','<authEncryption>',('<authentication>{3}</a'+
                'uthentication>'),'<encryption>{4}</encryption>','<useOneX>true</useOneX>',('</authEncryp'+
                'tion>'),'<PMKCacheMode>enabled</PMKCacheMode>','<PMKCacheTTL>720</PMKCacheTTL>',('<PMKCa'+
                'cheSize>128</PMKCacheSize>'),'<preAuthMode>disabled</preAuthMode>',('<OneX xmlns="http:/'+
                '/www.microsoft.com/networking/OneX/v1">'),'<authMode>machineOrUser</authMode>',('<EAPCon'+
                'fig>'),"<EapHostConfig xmlns='$P/EapHostConfig'>",'<EapMethod>',("<Type xmlns='$P/EapHos"+
                "tConfig'>13</Type>"),"<VendorId xmlns='$P/EapCommon'>0</VendorId>",("<VendorType xmlns='"+
                "$P/EapCommon'>0</VendorType>"),"<AuthorId xmlns='$P/EapCommon'>0</AuthorId>",('</EapMeth'+
                'od>'),("<Config xmlns:baseEap='$P/BaseEapConnectionPropertiesV1' xmlns:eapTls='$P/EapTls"+
                "ConnectionPropertiesV1'>"),'<baseEap:Eap>','<baseEap:Type>13</baseEap:Type>',('<eapTls:E'+
                'apType>'),'<eapTls:CredentialsSource>','<eapTls:CertificateStore />',('</eapTls:Credenti'+
                'alsSource>'),'<eapTls:ServerValidation>',('<eapTls:DisableUserPromptForServerValidation>'+
                'false</eapTls:DisableUserPromptForServerValidation>'),('<eapTls:ServerNames></eapTls:Ser'+
                'verNames>'),'<eapTls:TrustedRootCA></eapTls:TrustedRootCA>','</eapTls:ServerValidation>',
                '<eapTls:DifferentUsername>false</eapTls:DifferentUsername>','</eapTls:EapType>',('</base'+
                'Eap:Eap>'),'</Config>','</EapHostConfig>','</EAPConfig>','</OneX>','</security>','</MSM>',
                '<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">',("<enabl"+
                "eRandomization>false</enableRandomization>"),"</MacRandomization>",'</WLANProfile>'
            }
        }
    
        Return $This.FormatXml($xProfile)
    }
    [String] Hex([String]$PN)
    {
        # // ___________________
        # // | PN: ProfileName |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return ([Char[]]$PN | % { '{0:X}' -f [Int]$_ }) -join ''
    }
    [String] NewWiFiProfileXmlPsk([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                  [SecureString]$PW)
    {
        # // ___________________________________________________________________________________________
        # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | PW: Password |
        # // | PP: PlainPassword | PX: ProfileXml | SS: SecureStringToBstr | RN: RefNode | XN: XmlNode | 
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $PP           = $Null
        $PX           = $Null
        $Hex          = $This.Hex($PN)
        Try
        {
            If ($PW)
            {
                $SS   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PW)
                $PW   = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($SS)
            }
            
            $PX       = [XML]($This.XmlTemplate(0) -f $PN, $Hex, $CM, $A, $E, $PP)
            If (!$PP)
            {
                $Null = $PX.WLANProfile.MSM.security.RemoveChild($PX.WLANProfile.MSM.security.sharedKey)
            }

            If ($A -eq 'WPA3SAE')
            {
                # // ____________________________________________
                # // | Set transition mode as true for WPA3-SAE |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $N  = [System.Xml.XmlNamespaceManager]::new($PX.NameTable)
                $N.AddNamespace('WLANProfile',$PX.DocumentElement.GetAttribute('xmlns'))
                $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                $XN = $PX.CreateElement('transitionMode', 
                                        'http://www.microsoft.com/networking/WLAN/profile/v4')
                $XN.InnerText = 'True'
                $null         = $RN.AppendChild($XN)
            }

            Return $This.FormatXml($PX.OuterXml)
        }
        Catch
        {
            Throw "Failed to create a new profile"
        }
    }
    [String] NewWifiProfileXmlEap([String]$PN,[String]$CM='Auto',[String]$A='WPA2PSK',[String]$E='AES',
                                  [String]$Eap,[String[]]$SN,[String]$TRCA)
    {
        # // ___________________________________________________________________________________________
        # // | PN: ProfileName | CM: ConnectionMode | A: Authentication | E: Encryption | EAP: EapType |
        # // | SN: ServerNames | TRCA: TrustedRootCa | PX: ProfileXml |  RN: RefNode | XN: XmlNode     | 
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $Px  = $Null
        $Hex = $This.Hex($PN)
        Try
        {
            If ($Eap -eq 'PEAP')
            {
                $Px = [Xml]($This.XmlTemplate(1) -f $PN, $Hex, $CM, $A, $E)
                $Cfg = $PX.WLANProfile.MSM.security.OneX.EAPConfig.EapHostConfig.Config

                If ($SN)
                {
                    $Cfg.Eap.EapType.ServerValidation.ServerNames = $SN
                }

                If ($TRCA)
                {
                    $Cfg.Eap.EapType.ServerValidation.TrustedRootCA = $TRCA.Replace('..','$& ')
                }
            }
            ElseIf ($Eap -eq 'TLS')
            {
                $PX  = [Xml]($This.XmlTemplate(2) -f $PN, $Hex, $CM, $A, $E)
                $Cfg = $PX.WLANProfile.MSM.security.OneX.EapConfig.EapHostConfig.Config

                If ($SN)
                {
                    $Node = $Cfg.SelectNodes("//*[local-name()='ServerNames']")
                    $Node[0].InnerText = $SN
                }

                If ($TRCA)
                {
                    $Node = $Cfg.SelectNodes("//*[local-name()='TrustedRootCA']")
                    $Node[0].InnerText = $TRCA.Replace('..','$& ')
                }
            }

            If ($A -eq 'WPA3SAE')
            {
                # // ____________________________________________
                # // | Set transition mode as true for WPA3-SAE |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                $N = [System.Xml.XmlNamespaceManager]::new($PX.NameTable)
                $N.AddNamespace('WLANProfile', $PX.DocumentElement.GetAttribute('xmlns'))
                $RN = $PX.SelectSingleNode('//WLANProfile:authEncryption', $N)
                $XN = $PX.CreateElement('transitionMode', 
                                        'http://www.microsoft.com/networking/WLAN/profile/v4')
                $XN.InnerText = 'true'
                $null = $RN.AppendChild($XN)
            }

            Return $This.FormatXml($PX.OuterXml)
        }
        Catch
        {
            Throw "Failed to create a new profile"
        }
    }
    [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$WFAN)
    {
        # // _______________________________________________________________________________
        # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
        # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $CM = 'auto'
        $A  = 'WPA2PSK'
        $E  = 'AES'
        $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$PW)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$WFAN)
    {
        # // _______________________________________________________________________________
        # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
        # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $A  = 'WPA2PSK'
        $E  = 'AES'
        $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$WFAN)
    {
        # // _______________________________________________________________________________
        # // | PN: ProfileName | PW: Password | WFAN: WiFiAdapterName | CM: ConnectionMode |
        # // | A: Authentication | E: Encryption | PT: ProfileTemp                         |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $E  = 'AES'
        $PT = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWiFiProfilePsk([String]$PN,[String]$PW,[String]$CM,[String]$A,[String]$E,[String]$WFAN)
    {
        # // ___________________________________________________________________________
        # // | PN: ProfileName | PW: Password | CM: ConnectionMode | A: Authentication |
        # // | E: Encryption | WFAN: WiFiAdapterName | PT: ProfileTemp                 |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $PT     = $This.NewWifiProfileXmlPsk($PN,$CM,$A,$E,$WFAN)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$EAP,[String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $CM   = 'Auto'
        $A    = 'WPA2PSK'
        $E    = 'AES'
        $SN   = ''
        $TRCA = $Null
        $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$EAP,[String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $A    = 'WPA2PSK'
        $E    = 'AES'
        $SN   = ''
        $TRCA = $Null
        $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$EAP,[String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $E    = 'AES'
        $SN   = ''
        $TRCA = $Null
        $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$EAP,[String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $SN   = ''
        $TRCA = $Null
        $PT   = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                               [String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $TRCA     = $Null
        $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileEap([String]$PN,[String]$CM,[String]$A,[String]$E,[String]$Eap,[String[]]$SN,
                               [String]$TRCA,[String]$WFAN)
    {
        # // ________________________________________________________________________________
        # // | PN: ProfileName | EAP: EapType | WFAN: WiFiAdapterName | CM: ConnectionMode  |
        # // | A: Authentication | E: Encryption | SN: ServerNames | TRCA: TrustedRootCA    |
        # // | PT: ProfileTemp                                                              |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $PT       = $This.NewWifiProfileXmlEap($PN,$CM,$A,$E,$EAP,$SN,$TRCA)
        Return $This.NewWifiProfile($PT,$WFAN)
    }
    [Object] NewWifiProfileXml([String]$PX,[String]$WFAN,[Bool]$O)
    {
        # // _________________________________________________________
        # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Return $This.NewWifiProfile($PX,$WFAN)
    }
    NewWifiProfile([String]$PX,[String]$WFAN,[Bool]$O)
    {
        # // _____________________________________________________________________________
        # // | PX: ProfileXml | WFAN: WiFiAdapterName | O: Overwrite | IG: InterfaceGuid |
        # // | CH: ClientHandle | F: Flags | PP: ProfilePointer                          |
        # // | RSC: ReasonCode | RSCM: ReasonCodeMessage                                 |
        # // | RTC: ReturnCode | RTCM: ReturnCodeMessage                                 |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Try
        {
            $IG   = $This.GetWiFiInterfaceGuid($WFAN)
            $CH   = $This.NewWiFiHandle()
            $F    = 0
            $RSC  = [IntPtr]::Zero
            $PP   = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($PX)    
            $RTC  = $This.WlanSetProfile($CH,[Ref]$IG,$F,$PP,[IntPtr]::Zero,$O,[IntPtr]::Zero,[Ref]$RSC)
            $RTCM = $This.Win32Exception($RTC)
            $RSCM = $This.WiFiReasonCode($RSC)

            If ($RTC -eq 0)
            {
                Write-Verbose -Message $RTCM
            }
            Else
            {
                Throw $RTCM
            }

            Write-Verbose -Message $RSCM
        }
        Catch
        {
            Throw "Failed to create the profile"
        }
        Finally
        {
            If ($CH)
            {
                $This.RemoveWiFiHandle($CH)
            }
        }
    }
    RemoveWifiProfile([String]$PN)
    {
        # // ______________________________________
        # // | PN: ProfileName | CH: ClientHandle |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $CH = $This.NewWiFiHandle()
        $This.WlanDeleteProfile($CH,[Ref]$This.Selected.Guid,$PN,[IntPtr]::Zero)
        $This.RemoveWifiHandle($CH)
    }
    Select([String]$D)
    {
        # // __________________
        # // | D: Description |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        # // ___________________________________________
        # // | Select the adapter from its description |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Selected = $This.GetWifiInterface() | ? Description -eq $D
        $This.Update()
    }
    Unselect()
    {
        $This.Selected = $Null
        $This.Update()
    }
    Disconnect()
    {
        If (!$This.Selected)
        {
            Write-Host "No network selected"
        }
        If ($This.Selected.State -eq "CONNECTED")
        {
            $CH                      = $This.NewWiFiHandle()
            $This.WlanDisconnect($CH,[Ref]$This.Selected.Guid,[IntPtr]::Zero)
            $This.RemoveWifiHandle($CH)

            $This.Connected                    = $Null

            $Splat                             = @{

                Type    = "Image"
                Mode    = 2
                Image   = $This.OEMLogo
                Message = "Disconnected: $($This.Selected.SSID)"
            }

            Show-ToastNotification @Splat

            $Link                              = $This.Selected.Description
            $This.Unselect()
            $This.Select($Link)
        }
    }
    Connect([String]$SSID)
    {
        If (!$This.Selected)
        {
            Write-Host "Must select an active interface"
        }

        If ($This.Selected)
        {
            $Link                              = $This.Selected.Description
            $This.Unselect()
            $This.Select($Link)

            If ($This.Selected.State -ne "CONNECTED")
            {
                $Result = $This.GetWifiProfileInfo($SSID,$This.Selected.Guid)
                If ($Result)
                {
                    $Param = $This.GetWiFiConnectionParameter($SSID)
                    $CH    = $This.NewWiFiHandle()
                    $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
                    $This.RemoveWifiHandle($CH)

                    $Link   = $This.Selected.Description
                    $This.Unselect()
                    $This.Select($Link)
                    
                    $This.Update()

                    $Splat                             = @{

                        Type    = "Image"
                        Mode    = 2
                        Image   = $This.OEMLogo
                        Message = "Connected: $SSID"
                    }

                    Show-ToastNotification @Splat
                }
                If (!$Result)
                {
                    $Network = $This.Output.SelectedItem
                    If ($Network.Authentication -match "psk")
                    {
                        $This.Passphrase($Network)
                    }
                    Else
                    {
                        Write-Host "Eas/Peap not yet implemented"
                    }
                }
            }
        }
    }
    Passphrase([Object]$NW)
    {
        $PW    = Read-Host -AsSecureString -Prompt "Enter passphrase for Network: [$($NW.SSID)]"
        $A     = $Null
        $E     = $Null

        If ($NW.Authentication -match "RsnaPsk")
        {
            $A = "WPA2PSK"
        }
        If ($NW.Encryption -match "Ccmp")
        {
            $E = "AES"
        }

        $PX    = $This.NewWifiProfileXmlPsk($NW.Name,"Manual",$A,$E,$PW)
        $This.NewWifiProfile($PX,$This.Selected.Name,$True)
            
        $Param = $This.GetWiFiConnectionParameter($NW.Name)
        $CH    = $This.NewWiFiHandle()
        $This.WlanConnect($CH,[Ref]$This.Selected.Guid,[Ref]$Param,[IntPtr]::Zero)
        $This.RemoveWifiHandle($CH)

        Start-Sleep 3
        $Link  = $This.Selected.Description
        $This.Unselect()
        $This.Select($Link)

        $This.Update()
        If ($This.Connected)
        {
            $Splat                             = @{

                Type    = "Image"
                Mode    = 2
                Image   = $This.OEMLogo
                Message = "Connected: $($NW.Name)"
            }

            Show-ToastNotification @Splat
        }
        If (!$This.Connected)
        {
            $This.RemoveWifiProfile($NW.Name)

            $Splat                             = @{

                Type    = "Image"
                Mode    = 2
                Image   = $This.OEMLogo
                Message = "Unsuccessful: Passphrase failure"
            }
            Show-ToastNotification @Splat
        }
    }
    Update()
    {
        "Determine/Set connection state" | Write-Comment -I 12 | Set-Clipboard
        Switch -Regex ($This.Selected.Status)
        {
            Up
            {
                $This.Connected = $This.NetshShowInterface($This.Selected.Name)
            }
            Default
            {
                $This.Connected = $Null
            }
        }
    }
    Wireless()
    {
        # // ____________________________
        # // | Load the module location |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Module  = Get-FEModule
        $This.OEMLogo = $This.Module.Graphics | ? Name -eq OEMLogo.bmp | % Fullname

        # // _______________________________
        # // | Load the Ssid Subcontroller |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Sub     = [SsidSubcontroller]::New()

        # // __________________________
        # // | Load the runtime types |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        ForEach ($X in "","AccessStatus","State")
        { 
            $Item = "[Windows.Devices.Radios.Radio$X, Windows.System.Devices, ContentType=WindowsRuntime]"
            "$Item > `$Null" | Invoke-Expression
        }

        # // _______________________________________
        # // | Get access to any wireless adapters |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Adapters = $This.RefreshAdapterList()

        # // __________________________________________
        # // | Throw if no existing wireless adapters |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If ($This.Adapters.Count -eq 0)
        {
            Throw "No existing wireless adapters on this system"
        }

        # // ___________________________
        # // | Requesting Radio Access |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Request = $This.RadioRequestAccess()
        $This.Request.Wait(-1) > $Null

        # // _______________________________________
        # // | Throw if unable to ascertain access |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If ($This.Request.Result -ne "Allowed")
        {
            Throw "Unable to request radio access"
        }

        # // ___________________________________
        # // | Establish radio synchronization |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        $This.Radios = $This.RadioSynchronization()
        $This.Radios.Wait(-1) > $Null

        # // _________________________________________
        # // | Throw if unable to synchronize radios |
        # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        If (!($This.Radios.Result | ? Kind -eq WiFi))
        {
            Throw "Unable to synchronize wireless radio(s)"
        }

        $This.Refresh()
    }
    [Object[]] RefreshAdapterList()
    {
        Return Get-NetAdapter | ? PhysicalMediaType -match "(Native 802.11|Wireless (W|L)AN)"
    }
    Scan()
    {
        $This.List               = @( )
        $This.Output             = @( )

        [Windows.Devices.WiFi.WiFiAdapter, Windows.System.Devices, ContentType=WindowsRuntime] > $Null
        $This.List               = $This.RadioFindAllAdaptersAsync()
        $This.List.Wait(-1) > $Null
        $This.List.Result

        $This.List.Result.NetworkReport.AvailableNetworks | % {

            $Item                = [Ssid]::New($This.Output.Count,$_)
            $This.Sub.Load($Item)
            $This.Output        += $Item
        }

        $This.Output             = $This.Output | Sort-Object Strength -Descending
        Switch ($This.Output.Count)
        {
            {$_ -gt 1}
            { 
                ForEach ($X in 0..($This.Output.Count-1))
                {
                    $This.Output[$X].Index = $X
                }
            }
            {$_ -eq 1}
            {
                $This.Output[0].Index = 0
            }
            {$_ -eq 0}
            {
                Throw "No networks detected"
            }
        }
    }
    Refresh()
    {
        Start-Sleep -Milliseconds 150
        $This.Scan()

        Write-Progress -Activity Scanning -Status Starting -PercentComplete 0  

        $C = 0
        $This.Output | % { 
            
            $Status  = "($C/$($This.Output.Count-1)"
            $Percent =  ([long]($C * 100 / $This.Output.Count))

            Write-Progress -Activity Scanning -Status $Status -PercentComplete $Percent
            
            $C ++
        }

        Write-Progress -Activity Scanning -Status Complete -Completed
        Start-Sleep -Milliseconds 50
    }
}

$Wifi = [Wireless]::New()
