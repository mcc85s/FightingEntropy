<#
.SYNOPSIS
    (Enumerates + Maps) [Dcom (Access + Launch) ACL Settings]
    
.DESCRIPTION
    This script is used to enumerate security settings based on WMI information from:
    [+] Win32_DcomApplication
    [+] Win32_DcomApplicationAccessAllowedSetting
    [+] Win32_DcomApplicationLaunchAllowedSetting

    For detecting potential avenues for [lateral movement] or [persistence]

    For more information on [Dcom-based lateral movement concept], refer to: 
    https://enigma0x3.net/2017/01/23/lateral-movement-via-dcom-round-2/

    For more informaiton about [Known SID]s, refer to: 
    https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems

.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-08 12:00:34                                                                  //
 \\==================================================================================================// 

    FileName   : Get-DcomSecurity.ps1
    Solution   : [FightingEntropy()][2023.8.0]
    Purpose    : (Enumerates + Maps) [Dcom (Access + Launch) ACL Settings]
    Author     : Michael C. Cook Sr. (Originally written by Matt Pichelmayer)
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-08-08
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Integrate with Active Directory, and implement original switches like -ResolveSid
                 Currently grabs [all] information, but just needs tweaking

.PARAMETER ComputerName
If using this script locally, you can direct it to run against a [remote workstation] 
using the [ComputerName] argument. If omitted, the [local workstation] is assumed.

.PARAMETER ListSIDs
Don't enumerate any settings, just list default SIDs and their groups.
For reference only.

.Example
#>

Function Get-DcomSecurity
{
    [CmdletBinding(DefaultParametersetName=0)]
    Param(
    [Parameter(ParameterSetName=0)][String] $ComputerName = $env:ComputerName,
    [Parameter(ParameterSetName=1)][Switch]    $ListSIDs)

    # // ==============================================
    # // | Individual reference item for the Sid List |
    # // ==============================================

    Class SidReferenceItem
    {
        Hidden [UInt32] $Index
        [String]         $Name
        [String]        $Value
        SidReferenceItem([UInt32]$Index,[String]$Name,[String]$Value)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Value = $Value
        }
    }

    # // ================================
    # // | Collection of Sid List Items |
    # // ================================

    Class SidReferenceList
    {
        [Object] $Output
        SidReferenceList()
        {
            $This.Refresh()
        }
        Clear()
        {
            $This.Output = @( )
        }
        [Object] SidReferenceItem([UInt32]$Index,[String]$Name,[String]$Value)
        {
            Return [SidReferenceItem]::New($Index,$Name,$Value)
        }
        Add([String]$Name,[String]$Value)
        {
            $This.Output += $This.SidReferenceItem($This.Output.Count,$Name,$Value)
        }
        Refresh()
        {
            $This.Clear()

            ForEach ($Item in 
            ("S-1-0"                      , "Null Authority"),
            ("S-1-0-0"                    , "Nobody"),
            ("S-1-1"                      , "World Authority"),
            ("S-1-1-0"                    , "Everyone"),
            ("S-1-2"                      , "Local Authority"),
            ("S-1-2-0"                    , "Local"),
            ("S-1-2-1"                    , "Console Logon"),
            ("S-1-3"                      , "Creator Authority"),
            ("S-1-3-0"                    , "Creator Owner"),
            ("S-1-3-1"                    , "Creator Group"),
            ("S-1-3-2"                    , "Creator Owner Server"),
            ("S-1-3-3"                    , "Creator Group Server"),
            ("S-1-3-4 Name: Owner Rights" , "SID: S-1-3-4 Owner Rights"),
            ("S-1-5-80-0"                 , "All Services"),
            ("S-1-4"                      , "Non-unique Authority"),
            ("S-1-5"                      , "NT Authority"),
            ("S-1-5-1"                    , "Dialup"),
            ("S-1-5-2"                    , "Network"),
            ("S-1-5-3"                    , "Batch"),
            ("S-1-5-4"                    , "Interactive"),
            ("S-1-5-5-X-Y"                , "Logon Session"),
            ("S-1-5-6"                    , "Service"),
            ("S-1-5-7"                    , "Anonymous"),
            ("S-1-5-8"                    , "Proxy"),
            ("S-1-5-9"                    , "Enterprise Domain Controllers"),
            ("S-1-5-10"                   , "Principal Self"),
            ("S-1-5-11"                   , "Authenticated Users"),
            ("S-1-5-12"                   , "Restricted Code"),
            ("S-1-5-13"                   , "Terminal Server Users"),
            ("S-1-5-14"                   , "Remote Interactive Logon"),
            ("S-1-5-15"                   , "This Organization"),
            ("S-1-5-17"                   , "This Organization"),
            ("S-1-5-18"                   , "Local System"),
            ("S-1-5-19"                   , "NT Authority"),
            ("S-1-5-20"                   , "NT Authority"),
            ("S-1-5-21domain-500"         , "Administrator"),
            ("S-1-5-21domain-501"         , "Guest"),
            ("S-1-5-21domain-502"         , "KRBTGT"),
            ("S-1-5-21domain-512"         , "Domain Admins"),
            ("S-1-5-21domain-513"         , "Domain Users"),
            ("S-1-5-21domain-514"         , "Domain Guests"),
            ("S-1-5-21domain-515"         , "Domain Computers"),
            ("S-1-5-21domain-516"         , "Domain Controllers"),
            ("S-1-5-21domain-517"         , "Cert Publishers"),
            ("S-1-5-21root domain-518"    , "Schema Admins"),
            ("S-1-5-21root domain-519"    , "Enterprise Admins"),
            ("S-1-5-21domain-520"         , "Group Policy Creator Owners"),
            ("S-1-5-21domain-526"         , "Key Admins"),
            ("S-1-5-21domain-527"         , "Enterprise Key Admins"),
            ("S-1-5-21domain-553"         , "RAS and IAS Servers"),
            ("S-1-5-32-544"               , "Administrators"),
            ("S-1-5-32-545"               , "Users"),
            ("S-1-5-32-546"               , "Guests"),
            ("S-1-5-32-547"               , "Power Users"),
            ("S-1-5-32-548"               , "Account Operators"),
            ("S-1-5-32-549"               , "Server Operators"),
            ("S-1-5-32-550"               , "Print Operators"),
            ("S-1-5-32-551"               , "Backup Operators"),
            ("S-1-5-32-552"               , "Replicators"),
            ("S-1-5-64-10"                , "NTLM Authentication"),
            ("S-1-5-64-14"                , "SChannel Authentication"),
            ("S-1-5-64-21"                , "Digest Authentication"),
            ("S-1-5-80"                   , "NT Service"),
            ("S-1-5-83-0"                 , "NT VIRTUAL MACHINE\Virtual Machines"),
            ("S-1-16-0"                   , "Untrusted Mandatory Level"),
            ("S-1-16-4096"                , "Low Mandatory Level"),
            ("S-1-16-8192"                , "Medium Mandatory Level"),
            ("S-1-16-8448"                , "Medium Plus Mandatory Level"),
            ("S-1-16-12288"               , "High Mandatory Level"),
            ("S-1-16-16384"               , "System Mandatory Level"),
            ("S-1-16-20480"               , "Protected Process Mandatory Level"),
            ("S-1-16-28672"               , "Secure Process Mandatory Level"),
            ("S-1-5-32-554"               , "BUILTIN\Pre-Windows 2000 Compatible Access"),
            ("S-1-5-32-555"               , "BUILTIN\Remote Desktop Users"),
            ("S-1-5-32-556"               , "BUILTIN\Network Configuration Operators"),
            ("S-1-5-32-557"               , "BUILTIN\Incoming Forest Trust Builders"),
            ("S-1-5-32-558"               , "BUILTIN\Performance Monitor Users"),
            ("S-1-5-32-559"               , "BUILTIN\Performance Log Users"),
            ("S-1-5-32-560"               , "BUILTIN\Windows Authorization Access Group"),
            ("S-1-5-32-561"               , "BUILTIN\Terminal Server License Servers"),
            ("S-1-5-32-562"               , "BUILTIN\Distributed COM Users"),
            ("S-1-5- 21domain -498"       , "Enterprise Read-only Domain Controllers"),
            ("S-1-5- 21domain -521"       , "Read-only Domain Controllers"),
            ("S-1-5-32-569"               , "BUILTIN\Cryptographic Operators"),
            ("S-1-5-21 domain -571"       , "Allowed RODC Password Replication Group"),
            ("S-1-5- 21 domain -572"      , "Denied RODC Password Replication Group"),
            ("S-1-5-32-573"               , "BUILTIN\Event Log Readers"),
            ("S-1-5-32-574"               , "BUILTIN\Certificate Service Dcom Access"),
            ("S-1-5-21-domain-522"        , "Cloneable Domain Controllers"),
            ("S-1-5-32-575"               , "BUILTIN\RDS Remote Access Servers"),
            ("S-1-5-32-576"               , "BUILTIN\RDS Endpoint Servers"),
            ("S-1-5-32-577"               , "BUILTIN\RDS Management Servers"),
            ("S-1-5-32-578"               , "BUILTIN\Hyper-V Administrators"),
            ("S-1-5-32-579"               , "BUILTIN\Access Control Assistance Operators"),
            ("S-1-5-32-580"               , "BUILTIN\Remote Management Users"))
            { 
                $This.Add($Item[0],$Item[1])
            }
        }
    }

    # // ==================================================
    # // | The collection class for Win32_DcomApplication |
    # // ==================================================

    Class DcomApp
    {
        [UInt32]       $Index
        Hidden [Object]  $Wmi
        [String]       $AppId
        [String]        $Name
        [Object]    $Property
        DcomApp([UInt32]$Index,[Object]$Wmi)
        {
            $This.Index       = $Index
            $This.Wmi         = $Wmi
            $This.AppId       = $Wmi.AppId.ToLower()
            $This.Name        = $Wmi.Name
            $This.Property    = @( )
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ======================================================================
    # // | Converts the WMI Element/Settings strings into objects, w/ parsing |
    # // ======================================================================

    Class DcomProperty
    {
        Hidden [String] $Path
        Hidden [String] $Root
        [String]      $Source
        [String]        $Name
        [String]   $Reference
        [String]       $Value
        DcomProperty([String]$Path)
        {
            $This.Path      = $Path
            $S              = $Path -Split "(\\|:|\.|=|\`")" | ? Length -gt 1
            $This.Root      = "\\{0}\{1}\{2}" -f $S[0], $S[1], $S[2]
            $This.Source    = $S[3]
            $This.Name      = $S[4]
            $This.Reference = $S[5]
        }
        [String] ToString()
        {
            Return "[{0}]: {1}" -f $This.Name, $This.Reference
        }
    }

    # // =====================================================================
    # // | Specifically meant for Win32_DcomApplicationAccessSetting objects |
    # // =====================================================================

    Class DcomAccess
    {
        [UInt32]      $Index
        Hidden [Object] $Wmi
        [Object]    $Element
        [Object]    $Setting
        DcomAccess([UInt32]$Index,[Object]$Wmi)
        {
            $This.Index   = $Index
            $This.Wmi     = $Wmi
            $This.Element = $This.DcomProperty($Wmi.Element)
            $This.Setting = $This.DcomProperty($Wmi.Setting)
        }
        [Object] DcomProperty([String]$Path)
        {
            Return [DcomProperty]::New($Path)
        }
    }

    # // =====================================================================
    # // | Specifically meant for Win32_DcomApplicationLaunchSetting objects |
    # // =====================================================================

    Class DcomLaunch
    {
        [UInt32]      $Index
        Hidden [Object] $Wmi
        [Object]    $Element
        [Object]    $Setting
        DcomLaunch([UInt32]$Index,[Object]$Wmi)
        {
            $This.Index   = $Index
            $This.Wmi     = $Wmi
            $This.Element = $This.DcomProperty($Wmi.Element)
            $This.Setting = $This.DcomProperty($Wmi.Setting)
        }
        [Object] DcomProperty([String]$Path)
        {
            Return [DcomProperty]::New($Path)
        }
    }

    # // =========================================================
    # // | This is meant to combine all of the above information |
    # // =========================================================

    Class DcomReference
    {
        [UInt32]           $Index
        [String]            $Type
        Hidden [UInt32]     $Rank
        [Object]           $AppID
        [Object]             $Sid
        Hidden [Object] $Property
        DcomReference([UInt32]$Index,[String]$Type,[Object]$Object)
        {
            $This.Index       = $Index
            $This.Type        = $Type
            $This.Rank        = $Object.Index
            $This.Property    = @( )
            $This.Property   += $Object.Element
            $This.Property   += $Object.Setting
        }
        SetApplication([Object]$Application)
        {
            $This.Application = $Application
        }
        SetSid([Object]$Sid)
        {
            $This.Sid         = $Sid
        }
    }

    # // ====================================================
    # // | This is the class factory for the entire process |
    # // ====================================================

    Class DcomController
    {
        [String] $ComputerName
        [Object] $Reference
        [Object] $Apps
        [Object] $Access
        [Object] $Launch
        DcomController()
        {
            $This.ComputerName = $This.EnvComputerName()
            $This.Main()
        }
        DcomController([String]$ComputerName)
        {
            $This.ComputerName = $ComputerName
            $This.Main()
        }
        Main()
        {
            $This.Reference = $This.SidReferenceList()
            $This.Apps      = $This.Dcom(0)
            $This.Access    = $This.Dcom(1)
            $This.Launch    = $This.Dcom(2)

            $This.Resolve()
        }
        [String] EnvComputerName()
        {
            Return [Environment]::MachineName.ToLower()
        }
        [Object] SidReferenceList()
        {
            Return [SidReferenceList]::New().Output
        }
        [Object] SecurityIdentifier([String]$Sid)
        {
            Return [System.Security.Principal.SecurityIdentifier]::New($Sid)
        }
        [Object] DcomApp([UInt32]$Index,[Object]$Wmi)
        {
            Return [DcomApp]::New($Index,$Wmi)
        }
        [Object] DcomAccess([UInt32]$Index,[Object]$Wmi)
        {
            Return [DcomAccess]::New($Index,$Wmi)
        }
        [Object] DcomLaunch([UInt32]$Index,[Object]$Wmi)
        {
            Return [DcomLaunch]::New($Index,$Wmi)
        }
        [Object] DcomReference([UInt32]$Index,[String]$Type,[Object]$Object)
        {
            Return [DcomReference]::New($Index,$Type,$Object)
        }
        [Object[]] Dcom([UInt32]$Mode)
        {
            $Name = "Win32_DcomApplication{0}" -f @("","AccessAllowedSetting","LaunchAllowedSetting")[$Mode]
            $Path = "\\{0}\Root\CimV2:$Name" -f $This.ComputerName
            $List = @([WmiClass]::New($Path).GetInstances())
            $Out  = @{ }

            [Console]::WriteLine("Retrieving [~] ($($List.Count)) $Name")

            ForEach ($X in 0..($List.Count-1))
            {
                $Item = Switch ($Mode)
                {
                    0 { $This.DcomApp($Out.Count,$List[$X]) }
                    1 { $This.DcomAccess($Out.Count,$List[$X]) }
                    2 { $This.DcomLaunch($Out.Count,$List[$X]) }
                }

                $Out.Add($Out.Count,$Item)
            }

            Return $Out[0..($Out.Count-1)]
        }
        [Object] GetUserFromSid([String]$SidString)
        {
            Try 
            {
                $Sid  = $This.SecurityIdentifier($SidString)
                $Item = $Sid.Translate([System.Security.Principal.NTAccount])
                Return $Item
            }
            Catch 
            {
                Return $Null
            }
        }
        Resolve()
        {
            $List   = @{ }

            # Populate Apps hashtable
            ForEach ($Item in $This.Apps)
            {
                $List.Add($Item.AppID,$Item)
            }
        
            # Process Access
            ForEach ($Object in $This.Access)
            {
                $Target           = $List[$Object.Element.Reference]
                $Item             = $This.DcomReference($Target.Property.Count,"Access",$Object)
                $AppID            = $Item.Property | ? Name -eq AppID
                $Item.AppID       = $AppId.Value   = $Target.Name
        
                $Sid              = $Item.Property | ? Name -eq SID
                $Item.Sid         = $Sid.Value     = $This.GetUserFromSid($Sid.Reference)
        
                $Target.Property += $Item
            }
        
            # Process Launch
            ForEach ($Object in $This.Launch)
            {
                $Target           = $List[$Object.Element.Reference]
                $Item             = $This.DcomReference($Target.Property.Count,"Launch",$Object)
                $AppID            = $Item.Property | ? Name -eq AppID
                $Item.AppID       = $AppId.Value   = $Target.Name
        
                $Sid              = $Item.Property | ? Name -eq SID
                $Item.Sid         = $Sid.Value     = $This.GetUserFromSid($Sid.Reference)
        
                $Target.Property += $Item
            }
        }
        [Void] Out([Hashtable]$Hashtable,[String]$Line)
        {
            $Hashtable.Add($Hashtable.Count,$Line)
        }
        [String[]] Draw([UInt32]$Index)
        {
            If ($Index -gt $This.Apps.Count)
            {
                Throw "Invalid index"
            }

            $Object = $This.Apps[$Index]
            $H      = @{ }
            $X      = [String][Char]175
        
            $This.Out($H,"===========================================================")
            $This.Out($H,"")
            $This.Out($H,("Index    : {0}" -f $Object.Index))
            $This.Out($H,("Name     : {0}" -f $Object.Name))
            $This.Out($H,("AppId    : {0}" -f $Object.AppId))
            $This.Out($H,("Property : ({0})" -f $Object.Property.Count))
        
            If ($Object.Property.Count -gt 0)
            {
                # Stage Outer loop
                $Max = @{
            
                    Index = 5
                    Type  = 6
                    AppId = ($Object.Property.AppID | Sort-Object Length)[-1].Length
                    Sid   = ($Object.Property.Sid   | Sort-Object Length)[-1].Length
                }

            If ($Max.AppId -eq 0)
            {
                $Max.AppId = 5
            }
        
            $MaxIndex = [String]($Object.Property.Index | Sort-Object)[-1].Length
            If ($MaxIndex -gt $Max.Index)
            {
                $Max.Index = $MaxIndex
            }
        
            ForEach ($Prop in $Object.Property)
            {
                # Header 
                $Head = "  | {0} | {1} | {2} | {3} |" -f "Index".PadLeft($Max.Index," "),
                                                       "Type".PadRight($Max.Type," "),
                                                       "AppId".PadRight($Max.AppId," "),
                                                       "Sid".PadRight($Max.Sid," ")
        
                $This.Out($H,"  ".PadRight($Head.Length,"_"))
                $This.Out($H,$Head)
        
                # Line
                $This.Out($H,("  |={0}=|={1}=|={2}=|={3}=|" -f "=====".PadLeft($Max.Index,"="),
                                                         "====".PadRight($Max.Type,"="),
                                                         "=====".PadRight($Max.AppId,"="),
                                                         "".PadRight($Max.Sid,"=")))
        
                # Data
                $This.Out($H,("  | {0} | {1} | {2} | {3} |" -f $Prop.Index.ToString().PadLeft($Max.Index," "),
                                                  $Prop.Type.PadLeft($Max.Type," "),
                                                  $Prop.AppId.PadLeft($Max.AppId," "),
                                                  $Prop.Sid.PadLeft($Max.Sid," ")))
                # Bottom
                $This.Out($H,("  ".PadRight($Head.Length,$X)))
            
                # Stage Inner loop
                $IMax = @{
            
                    Source    = ($Prop.Property.Source    | Sort-Object Length)[-1].Length
                    Name      = ($Prop.Property.Name      | Sort-Object Length)[-1].Length
                    Reference = ($Prop.Property.Reference | Sort-Object Length)[-1].Length
                    Value     = ($Prop.Property.Value     | Sort-Object Length)[-1].Length
                }
            
                # Inner Header
                $IHead = "    | {0} | {1} | {2} | {3} |" -f "Source".PadRight($IMax.Source," "),
                                                        "Name".PadRight($IMax.Name," "),
                                                        "Reference".PadRight($IMax.Reference," "),
                                                        "Value".PadRight($IMax.Value," ")
            
            
                    $This.Out($H,"    ".PadRight($IHead.Length,"_"))
                    $This.Out($H,$IHead)
                    $This.Out($H,("    |={0}=|={1}=|={2}=|={3}=|" -f "=".PadLeft($IMax.Source,"="),
                                                        "=".PadLeft($IMax.Name,"="),
                                                        "=".PadLeft($IMax.Reference,"="),
                                                        "=".PadLeft($IMax.Value,"=")))
            
                    ForEach ($Item in $Prop.Property)
                    {
                        $This.Out($H,("    | {0} | {1} | {2} | {3} |" -f $Item.Source.PadRight($IMax.Source," "),
                                                            $Item.Name.PadRight($IMax.Name," "),
                                                            $Item.Reference.PadRight($IMax.Reference," "),
                                                            $Item.Value.PadRight($IMax.Value," ")))
                    }
            
                    $This.Out($H,"    ".PadRight($IHead.Length,$X))
                }
            }

            $This.Out($H,"")

            Return $H[0..($H.Count-1)]
        }
        [String[]] Draw()
        {
            $H = @{ }
            ForEach ($X in 0..($This.Apps.Count-1))
            {
                ForEach ($Line in $This.Draw($X))
                {
                    $This.Out($H,$Line)
                }
            }

            Return $H[0..($H.Count-1)]
        }
    }
    
    If ($ListSids)
    {
        [SidReferenceList]::New().Output
    }
    Else
    {
        [DcomController]::New($ComputerName)
    }
}
