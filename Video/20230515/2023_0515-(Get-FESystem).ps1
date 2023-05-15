<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                       \\
\\  Date       : 2023-04-05 09:52:02                                                                  //
 \\==================================================================================================// 

    FileName   : Get-FESystem.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : This function performs multiple operations in order to either collect/export,
                 or import system information from a file, or memory object
                 [+] system snapshot
                 [+] BIOS information
                 [+] computer system
                 [+] operating system
                 [+] hotfixes
                 [+] features
                 [+] applications
                 [+] events
                 [+] tasks
                 [+] processor(s)
                 [+] disk(s)
                 [+] network(s)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Extend the number of possibilities for Param $Level

.Example

  [Mode] | Status | Logging | Module |
 ========|========|=========|========|
      0  |   --   |   --    |   --   |
      1  |   --   |   XX    |   --   |
      2  |   XX   |   XX    |   --   |
      3  |   XX   |   XX    |   XX   |

 [Level] | Snap | Bios | Comp | Oper | Hfix | Feat | Apps | Evnt | Task | AppX | Proc | Disk | NetW |
 ========|======|======|======|======|======|======|======|======|======|======|======|======|======|
       0 |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |  XX  |
       1 |  XX  |  XX  |  XX  |  XX  |  --  |  --  |  --  |  --  |  --  |  --  |  XX  |  XX  |  XX  |
       2 |  XX  |  XX  |  XX  |  XX  |  --  |  --  |  --  |  --  |  --  |  --  |  --  |  --  |  --  |
       3 |  XX  |  XX  |  XX  |  XX  |  --  |  XX  |  --  |  --  |  --  |  --  |  --  |  --  |  XX  |

    Get-FESystem -Mode 0 -Level 0 | [Quietly pulls all components]
    Get-FESystem -Mode 2 -Level 2 | [Logs and shows status for the main system snapshot properties]
#>

Function Get-FESystem
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [ValidateSet(0,1,2)]
        [Parameter(ParameterSetName=0)]
        [Parameter(ParameterSetName=1)]
        [Parameter(ParameterSetName=2)]
        [Parameter(ParameterSetName=3)][UInt32]$Mode = 0,
        [ValidateSet(0,1,2,3)]
        [Parameter(ParameterSetName=0)]
        [Parameter(ParameterSetName=1)]
        [Parameter(ParameterSetName=2)]
        [Parameter(ParameterSetName=3)][UInt32]$Level = 0,
        [Parameter()]
        [ValidateScript({Test-Path $_})]
        [Parameter(Mandatory,ParameterSetName=1)][String]$Path,
        [Parameter(Mandatory,ParameterSetName=2)][Object]$InputObject
    )

    # // =============================================
    # // | For scalable control over the output file |
    # // =============================================

    Class SystemProperty
    {
        [UInt32]  $Index
        [UInt32]   $Rank
        [String] $Source
        [String]   $Name
        [UInt32] $Buffer
        [Object]  $Value
        SystemProperty([UInt32]$Index,[UInt32]$Rank,[String]$Source,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.Source = $Source
            $This.Name   = $Name
            $This.Buffer = $Name.Length
            $This.Value  = $Value
        }
        SetBuffer([UInt32]$Width)
        {
            If ($This.Buffer -lt $Width)
            {
                $This.Buffer = $Width
            }
        }
        [String] ToString()
        {
            Return "{0} {1}" -f $This.Name.PadRight($This.Buffer," "), $This.Value
        }
    }

    # // =========================================
    # // | Classifies each line of an input file |
    # // =========================================

    Class InputLine
    {
        [Int32]         $Rank = -1
        [UInt32]       $Index
        [String]        $Slot
        [String]        $Line
        InputLine([UInt32]$Index,[String]$Line)
        {
            $This.Index = $Index
            $This.Slot  = $This.GetSlot($Line)
            $This.Line  = $Line.TrimEnd(" ")
        }
        [String] GetSlot($Line)
        {
            Return @( Switch -Regex ($Line)
            {
                "^ $"                            { "Space"    }
                "^\={120}$"                      { "Line"     }
                "^\[\w+\]$"                      { "Header"   }
                "^[a-zA-Z]+\d+\s+$"              { "Label"    }
                "^[a-zA-Z]+\d+.[a-zA-Z]+\d+\s*$" { "Sublabel" }
                "^[a-zA-Z]+\s+\:"                { "Property" }
                "^[a-zA-Z]+\d+\s+\:"             { "Item"     }
            })
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    # // =====================================================================
    # // | Organizes properties for individual input file (sections + items) |
    # // =====================================================================

    Class InputProperty
    {
        [UInt32]  $Rank
        [String]  $Name
        [String] $Value
        InputProperty([UInt32]$Rank,[Object]$Property)
        {
            $This.Rank  = $Rank
            $This.Name  = $Property.Name
            $This.Value = $Property.Value
        }
    }

    # // =======================================================
    # // | Contains nested items for sections of an input file |
    # // =======================================================

    Class InputItem
    {
        [UInt32]     $Rank
        [String]     $Name
        [Object] $Property
        InputItem([UInt32]$Rank,[String]$Name)
        {
            $This.Rank     = $Rank
            $This.Name     = $Name
            $This.Property = @( )
        }
    }

    # // ==============================================
    # // | Contains a single section of an input file |
    # // ==============================================

    Class InputSection
    {
        [UInt32]       $Index
        [String]        $Name
        [UInt32]        $Slot
        [Object]    $Property
        [Object]        $Item
        InputSection([UInt32]$Index,[Object[]]$Content)
        {
            $This.Index    = $Index
            $This.Name     = ($Content | ? Slot -eq Header).Line -Replace "(\[|\])",""
            $This.Property = @( )
            $This.Item     = @( )

            $Hash          = @{ 
                
                Label      = $Content | ? Slot -match Label
                Item       = $Content | ? Slot -match Item
            }

            # If the content is (1) object with multiple properties
            If ($Hash.Label.Count -eq 0 -and $Hash.Item.Count -eq 0)
            {
                $This.Slot = 0

                ForEach ($Item in $Content | ? Slot -eq Property)
                {
                    $Note           = $This.NoteProperty($Item.Line)
                    $This.Property += $This.InputProperty($This.Property.Count,$Note)
                }
            }

            # If the content is (1+) objects with (1) property
            If ($Hash.Item.Count -gt 0)
            {
                $This.Slot = 1

                ForEach ($Item in $Content | ? Slot -eq Item)
                {
                    $Note           = $This.NoteProperty($Item.Line)
                    $This.Item     += $This.InputProperty($This.Item.Count,$Note)
                }
            }

            # If the content is numerous items with their own properties
            If ($Hash.Label.Count -gt 0)
            {
                $This.Slot               = 2

                ForEach ($Item in $Content)
                {
                    If ($Item.Slot -match "Label")
                    {
                        $This.Item      += $This.InputItem($This.Item.Count,$Item.Line)
                    }

                    If ($Item.Slot -match "Property")
                    {
                        $Note            = $This.NoteProperty($Item.Line)
                        $xItem           = $This.LastItem()
                        $xItem.Property += $This.InputProperty($xItem.Property.Count,$Note)
                    }
                }
            }
        }
        [Object] LastItem()
        {
            If ($This.Item.Count -eq 0)
            {
                Throw "No current items"
            }

            Return $This.Item[$This.Item.Count-1]
        }
        [Object] NoteProperty([String]$Line)
        {
            $X = $Line.IndexOf(":")[0]
            $Y = $Line.Substring(0,$X).TrimEnd(" ")
            $Z = $Line.Substring($X+1).TrimStart(" ")

            Return [PSNoteProperty]::New($Y,$Z)
        }
        [String] GetItemName([String]$Line)
        {
            Return [Regex]::Matches($Line,"[a-zA-Z]+[0-9]+").Value
        }
        [String] GetName([String]$Line)
        {
            Return [Regex]::Matches($Line,"^\w+").Value
        }
        [String] GetValue([String]$Line)
        {
            Return $Line -Replace "^\w+\s+:\s*",""
        }
        [Object] InputProperty([UInt32]$Rank,[Object]$Property)
        {
            Return [InputProperty]::New($Rank,$Property)
        }
        [Object] InputItem([UInt32]$Rank,[String]$Name)
        {
            Return [InputItem]::New($Rank,$Name)
        }
    }

    # // ======================================
    # // | Turns an input file into an object |
    # // ======================================

    Class InputObject
    {
        [Object] $Process
        [Object] $Section
        InputObject([Object]$Content)
        {
            $This.Process = @( )
            $This.Section = @( )

            $Rank = -1
            ForEach ($Line in $Content)
            {
                $Item = $This.InputLine($This.Process.Count,$Line)

                If ($Item.Slot -eq "Header")
                {
                    $Rank ++
                    $This.Process[-1].Rank = $Rank
                }

                $Item.Rank = $Rank

                $This.Add($Item)

                $This.Separate()
            }
        }
        [Object] InputLine([UInt32]$Index,[String]$Line)
        {
            Return [InputLine]::New($Index,$Line)
        }
        [Object] InputSection([UInt32]$Index,[Object[]]$Content)
        {
            Return [InputSection]::New($Index,$Content)
        }
        Add([Object]$Object)
        {
            $This.Process += $Object
        }
        Separate()
        {
            $Range = $This.Process | Select-Object Rank -Unique | % Rank
            ForEach ($X in $Range)
            {
                $Slot          = $This.Process | ? Rank -eq $X
                $This.Section += $This.InputSection($X,$Slot)
            }
        }
        [Object] Get([UInt32]$Index)
        {
            $Name = Switch ($Index)
            {
                0  { "Snapshot"        }
                1  { "BiosInformation" }  
                2  { "ComputerSystem"  }
                3  { "OperatingSystem" }
                4  { "HotFix"          }
                5  { "Feature"         }
                6  { "Application"     }
                7  { "Event"           }
                8  { "Task"            }
                9  { "AppX"            }
                10 { "Processor"       }
                11 { "Disk"            }
                12 { "Network"         }
            }

            Return $This.Section | ? Name -eq $Name
        }
    }

    # // ================================
    # // | For preparing an output file |
    # // ================================

    Class OutputProperty
    {
        [String] $Source
        [UInt32] $Rank
        [Object] $Name
        [Object] $Value
        OutputProperty([String]$Source,[UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            $This.Source  = $Source
            $This.Rank    = $Rank
            $This.Name    = $Name
            $This.Value   = $Value
        }
        [String] ToString()
        {
            Return "<FESystem.OutputProperty>"
        }
    }

    # // ========================================================================
    # // | Allows each section of an output file to be formatted with precision |
    # // ========================================================================

    Class OutputSection
    {
        [UInt32]  $Index
        [String]   $Name
        [UInt32]   $Slot
        [UInt32]  $Count
        [Object] $Output
        OutputSection([UInt32]$Index,[String]$Name,[UInt32]$Slot)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Slot    = $Slot
            $This.Clear()
        }
        Clear()
        {
            $This.Count   = 0
            $This.Output  = @( )
        }
        [Object] OutputProperty([UInt32]$Rank,[String]$Name,[Object]$Value)
        {
            Return [OutputProperty]::New($This.Name,$Rank,$Name,$Value)
        }
        Add([String]$Name,[Object]$Value)
        {
            $This.Output += $This.OutputProperty($This.Output.Count,$Name,$Value)
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.OutputSection>" -f $This.Count
        }
    }

    # // ==================================================================
    # // | Orchestrates the necessary operations to format an output file |
    # // ==================================================================

    Class OutputFile
    {
        [Object] $Max
        [Object] $Output
        OutputFile([Object[]]$Object)
        {
            $This.Output = @( )
            $This.Max    = ($Object.Output.Name | Sort-Object Length)[-1]
            $Hash        = @{ }
            ForEach ($Item in $Object)
            {
                $This.Add($Hash,$This.Line())
                $This.Add($Hash,"[$($Item.Name)]")
                $This.Add($Hash,$This.Line())
                $This.Add($Hash," ")

                ForEach ($Prop in $Item.Output)
                {
                    If ($Prop.Value -match "^:$")
                    {
                        If ($Hash[$Hash.Count-1] -ne " ")
                        {
                            $This.Add($Hash," ")
                        }

                        $This.Add($Hash,$Prop.Name.PadRight($This.Max.Length," "))
                    }
                    Else
                    {
                        $This.Add($Hash,("{0} : {1}" -f $Prop.Name.PadRight($This.Max.Length," "), $Prop.Value))   
                    }
                }

                $This.Add($Hash," ")
            }

            $This.Output = @($Hash[0..($Hash.Count-1)])
        }
        Add([Object]$Hash,[String]$Line)
        {
            $Hash.Add($Hash.Count,$Line)
        }
        [String] Line()
        {
            Return "=".PadLeft(120,"=")
        }
    }

    # // ========================================================================================
    # // | Collection of properties such as hostname, basic network info, date/time, guid, etc. |
    # // ========================================================================================

    Class Snapshot
    {
        Hidden [UInt32]         $Lock
        Hidden [Object]           $OS
        Hidden [Object]           $CS
        [String]               $Start
        [String]        $ComputerName
        [String]                $Name
        [String]         $DisplayName
        [String]                 $DNS
        [String]             $NetBIOS
        [String]            $Hostname
        [String]            $Username
        [Object]           $Principal
        [Bool]               $IsAdmin
        [String]             $Caption
        [Version]            $Version
        [UInt32]           $ReleaseID
        [UInt32]               $Build
        [String]                $Code
        [String]         $Description
        [String]                 $SKU
        [String]             $Chassis
        [String]                $Guid
        [UInt32]            $Complete
        [String]             $Elapsed
        Hidden [Object]     $Property
        Snapshot()
        {
            $This.Lock          = 0
            $Current            = $This.Get("DateTime")
            $This.OS            = $This.Get("OperatingSystem")
            $This.CS            = $This.Get("ComputerSystem")
            $This.Start         = $Current
            $This.ComputerName  = $This.Get("MachineName")
            $This.Name          = $This.ComputerName.ToLower()
            $This.DisplayName   = "{0}-{1}" -f $Current.ToString("yyyy-MMdd-HHmmss"), $This.ComputerName
            $This.DNS           = @($Env:UserDNSDomain,"-")[!$env:USERDNSDOMAIN]
            $This.NetBIOS       = $This.Get("UserDomainName").ToLower()
            $This.Hostname      = @($This.Name;"{0}.{1}" -f $This.Name, $This.DNS)[$This.CS.PartOfDomain].ToLower()
            $This.Username      = $This.Get("UserName")
            $This.Principal     = $This.Get("Principal")
            $This.IsAdmin       = $This.Principal.IsInRole("Administrator") -or $This.Principal.IsInRole("Administrators")
            $This.Caption       = $This.OS.Caption
            $This.GetFields()
            $This.Guid          = $This.Get("NewGuid")

            $This.Property      = @( )

            ForEach ($Item in $This.PSObject.Properties)
            {
                $This.Property       += $This.SystemProperty($Item)
            }
        }
        Snapshot([Object]$Section)
        {
            $This.Lock = 1
            $This.Load($Section.Property)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] Get([String]$Name)
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Item = Switch ($Name)
            {
                MachineName
                {
                    [Environment]::MachineName
                }
                UserDomainName
                {
                    [Environment]::UserDomainName
                }
                Username
                { 
                    [Environment]::UserName
                }
                UserDNSDomain
                {
                    [Environment]::GetEnvironmentVariable("UserDNSDomain")
                }
                DateTime
                { 
                    [DateTime]::Now 
                }
                NewGuid
                { 
                    [Guid]::NewGuid() 
                }
                Principal 
                { 
                    [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() 
                }
                ComputerSystem
                {
                    Get-CimInstance Win32_ComputerSystem
                }
                OperatingSystem
                {
                    Get-CimInstance Win32_OperatingSystem
                }
                CurrentVersion
                {
                    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
                }
                Host
                {
                    Get-Host
                }
                Edition
                {

                }
            }

            Return $Item
        }
        [String] GetEdition()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Out = ("10240,Threshold 1,Release To Manufacturing;10586,Threshold 2,November {1};1439"+
            "3,{0} 1,Anniversary {1};15063,{0} 2,{2} {1};16299,{0} 3,Fall {2} {1};17134,{0} 4,Apri"+
            "l 2018 {1};17763,{0} 5,October 2018 {1};18362,19H1,May 2019 {1};18363,19H2,November 2"+
            "019 {1};19041,20H1,May 2020 {1};19042,20H2,October 2020 {1}") -f 'Redstone','Update',
            'Creators' 
            
            $ID = Switch ($This.ReleaseID) 
            { 
                1507 {0} 1511 {1} 1607 {2} 1703 {3} 1709 {4} 1803 {5} 
                1809 {6} 1903 {7} 1909 {8} 2004 {9} 2009 {10} 
            }

            Return $Out.Split(";")[$Id]
        }
        [String] GetSku()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Out = ("Undefined,Ultimate {0},Home Basic {0},Home Premium {0},{3} {0},Home Basic N {"+
            "0},Business {0},Standard {2} {0},Datacenter {2} {0},Small Business {2} {0},{3} {2} {0"+
            "},Starter {0},Datacenter {2} Core {0},Standard {2} Core {0},{3} {2} Core {0},{3} {2} "+
            "IA64 {0},Business N {0},Web {2} {0},Cluster {2} {0},Home {2} {0},Storage Express {2} "+
            "{0},Storage Standard {2} {0},Storage Workgroup {2} {0},Storage {3} {2} {0},{2} For Sm"+
            "all Business {0},Small Business {2} Premium {0},TBD,{1} {3},{1} Ultimate,Web {2} Core"+
            ",-,-,-,{2} Foundation,{1} Home {2},-,{1} {2} Standard No Hyper-V Full,{1} {2} Datacen"+
            "ter No Hyper-V Full,{1} {2} {3} No Hyper-V Full,{1} {2} Datacenter No Hyper-V Core,{1"+
            "} {2} Standard No Hyper-V Core,{1} {2} {3} No Hyper-V Core,Microsoft Hyper-V {2},Stor"+
            "age {2} Express Core,Storage {2} Standard Core,{2} Workgroup Core,Storage {2} {3} Cor"+
            "e,Starter N,Professional,Professional N,{1} Small Business {2} 2011 Essentials,-,-,-,"+
            "-,-,-,-,-,-,-,-,-,Small Business {2} Premium Core,{1} {2} Hyper Core V,-,-,-,-,-,-,-,"+
            "-,-,-,-,-,-,-,-,-,-,-,--,-,-,{1} Thin PC,-,{1} Embedded Industry,-,-,-,-,-,-,-,{1} RT"+
            ",-,-,Single Language N,{1} Home,-,{1} Professional with Media Center,{1} Mobile,-,-,-"+
            ",-,-,-,-,-,-,-,-,-,-,{1} Embedded Handheld,-,-,-,-,{1} IoT Core") -f "Edition",("Wind"+
            "ows"),"Server","Enterprise"
            
            Return $Out.Split(",")[$This.OS.OperatingSystemSku]
        }
        [String] GetChassis()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Tag  = "N/A Desktop Mobile/Laptop Workstation {0} {0} Appliance {0} Max" -f "Server"
            Return $Tag.Split(" ")[$This.CS.PCSystemType]
        }
        GetFields()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Version             = $This.Get("Host").Version.ToString()
            $This.ReleaseID           = $This.Get("CurrentVersion").ReleaseID

            $This.Build, $This.Code, $This.Description = $This.GetEdition() -Split ","

            $This.SKU                = $This.GetSKU()
            $This.Chassis            = $This.GetChassis()
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,"Snapshot",$Property.Name,$Property.Value)
        }
        MarkComplete()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Complete     = 1 
            $This.Elapsed      = [String][Timespan]([DateTime]::Now-[DateTime]$This.Start)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "{0}" -f $This.ComputerName
        }
    }

    # // =======================================================
    # // | Bios Information for the system this tool is run on |
    # // =======================================================

    Class BiosInformation
    {
        Hidden [UInt32]     $Lock
        [String]            $Name
        [String]    $Manufacturer
        [String]    $SerialNumber
        [String]         $Version
        [String]     $ReleaseDate
        [Bool]     $SmBiosPresent
        [String]   $SmBiosVersion
        [String]     $SmBiosMajor
        [String]     $SmBiosMinor
        [String] $SystemBiosMajor
        [String] $SystemBiosMinor
        Hidden [Object] $Property
        BiosInformation()
        {
            $This.Lock            = 0
            $Bios                 = Get-CimInstance Win32_Bios
            $This.Name            = $Bios.Name
            $This.Manufacturer    = $Bios.Manufacturer
            $This.SerialNumber    = $Bios.SerialNumber
            $This.Version         = $Bios.Version
            $This.ReleaseDate     = $Bios.ReleaseDate
            $This.SmBiosPresent   = $Bios.SmBiosPresent
            $This.SmBiosVersion   = $Bios.SmBiosBiosVersion
            $This.SmBiosMajor     = $Bios.SmBiosMajorVersion
            $This.SmBiosMinor     = $Bios.SmBiosMinorVersion
            $This.SystemBiosMajor = $Bios.SystemBiosMajorVersion
            $This.SystemBIosMinor = $Bios.SystemBiosMinorVersion

            $This.Property        = @( )

            ForEach ($Item in $Bios.PSObject.Properties)
            {
                $This.Property   += $This.SystemProperty($Item)
            }
        }
        BiosInformation([Object]$Section)
        {
            $This.Lock = 1
            $This.Load($Section.Property)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Invalid mode"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,"BiosInformation",$Property.Name,$Property.Value)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Name
        }
    }

    # // ==================================================================
    # // | Computer system information for the system this tool is run on |
    # // ==================================================================

    Class ComputerSystem
    {
        Hidden [UInt32]     $Lock
        [String]    $Manufacturer
        [String]           $Model
        [String]         $Product
        [String]          $Serial
        [String]          $Memory
        [String]    $Architecture
        [String]            $UUID
        [String]         $Chassis
        [String]        $BiosUefi
        [Object]        $AssetTag
        Hidden [Object] $Property
        ComputerSystem()
        {
            $This.Lock         = 0

            $Computer          = @{ 
             
                System         = $This.Get("ComputerSystem")
                Product        = $This.Get("ComputerSystemProduct")
                Board          = $This.Get("BaseBoard")
                Form           = $This.Get("SystemEnclosure")
            }

            $This.Manufacturer = $Computer.System.Manufacturer
            $This.Model        = $Computer.System.Model
            $This.Memory       = "{0:n2} GB" -f ($Computer.System.TotalPhysicalMemory/1GB)
            $This.UUID         = $Computer.Product.UUID 
            $This.Product      = $Computer.Product.Version
            $This.Serial       = $Computer.Board.SerialNumber -Replace "\.",""
            $This.BiosUefi     = $This.Get("SecureBootUEFI")

            $This.AssetTag     = $Computer.Form.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$Computer.Form.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[$This.Get("Architecture")]

            $This.Property     = @( )

            ForEach ($Object in $Computer | % { $_.System, $_.Product, $_.Board, $_.Form})
            {
                ForEach ($Item in $Object.PSObject.Properties)
                {
                    $This.Property += $This.SystemProperty($Item)
                }
            }
        }
        ComputerSystem([Object]$Section)
        {
            $This.Lock = 1
            $This.Load($Section.Property)
        }
        Load([Object]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable: [Object lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] Get([String]$Name)
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Item = Switch ($Name)
            {
                ComputerSystem
                {
                    Get-CimInstance Win32_ComputerSystem 
                }
                ComputerSystemProduct
                {
                    Get-CimInstance Win32_ComputerSystemProduct
                }
                Baseboard
                {
                    Get-CimInstance Win32_Baseboard
                }
                SystemEnclosure
                {
                     Get-CimInstance Win32_SystemEnclosure
                }
                SecureBootUEFI
                {
                    Try
                    {
                        Get-SecureBootUEFI -Name SetupMode
                        "UEFI"
                    }
                    Catch
                    {
                        "BIOS"
                    }
                }
                Architecture
                {
                    [Environment]::GetEnvironmentVariable("Processor_Architecture")
                }
            }

            Return $Item
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,"ComputerSystem",$Property.Name,$Property.Value)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Model
        }
    }

    # // ===================================================================
    # // | Operating system information for the system this tool is run on |
    # // ===================================================================

    Class OperatingSystem
    {
        Hidden [UInt32]     $Lock
        Hidden [Object]       $Os
        [String]         $Caption
        [String]         $Version
        [String]           $Build
        [String]          $Serial
        [UInt32]        $Language
        [UInt32]         $Product
        [UInt32]            $Type
        Hidden [Object] $Property
        OperatingSystem()
        {
            $This.Lock          = 0

            $This.OS            = Get-CimInstance Win32_OperatingSystem

            $This.Caption       = $This.OS.Caption
            $This.Version       = $This.OS.Version
            $This.Build         = $This.OS.BuildNumber
            $This.Serial        = $This.OS.SerialNumber
            $This.Language      = $This.OS.OSLanguage
            $This.Product       = $This.OS.OSProductSuite
            $This.Type          = $This.OS.OSType

            $This.Property      = @( ) 
            
            ForEach ($Item in $This.OS.PSObject.Properties)
            {
                $This.Property += $This.SystemProperty($This.Property.Count,$Item)
            }
        }
        OperatingSystem([Object]$Section)
        {
            $This.Mode = 1
            $This.Load($Section.Property)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Mode -eq 0)
            {
                Throw Throw "Method unavailable [Template lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] SystemProperty([UInt32]$Index,[Object]$Property)
        {
            Return [SystemProperty]::New(0,$Index,"OperatingSystem",$Property.Name,$Property.Value)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "{0} {1}-{2}" -f $This.Caption, $This.Version, $This.Build
        }
    }

    # // =================================================================
    # // | For enumerating installed Windows (Updates/Packages/HotFixes) |
    # // =================================================================

    Class HotFixItem
    {
        Hidden [UInt32]  $Index
        Hidden [Object] $HotFix
        Hidden [String] $Source
        [String]      $HotFixID
        [String]   $Description
        [String]   $InstalledBy
        [String]   $InstalledOn
        HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            $This.Index       = $Index
            $This.HotFix      = $HotFix
            $This.Source      = $HotFix.PSComputerName
            $This.Description = $HotFix.Description
            $This.HotFixID    = $HotFix.HotFixID
            $This.InstalledBy = $HotFix.InstalledBy
            $This.InstalledOn = ([DateTime]$HotFix.InstalledOn).ToString("MM/dd/yyyy")
        }
        HotFixItem([UInt32]$Index,[String]$Line,[Switch]$Flags)
        {
            $Trim             = $Line -Split "\|"
            $This.Index       = $Index
            $This.Source      = $Trim[0]
            $This.Description = $Trim[1]
            $This.HotFixId    = $Trim[2]
            $This.InstalledBy = $Trim[3]
            $This.InstalledOn = $Trim[4]
        }
        [String] Tag()
        {
            Return "HotFix{0}" -f $This.Index
        }
        [String] Value()
        {
            Return "{0}|{1}|{2}|{3}|{4}" -f $This.Source,
                                            $This.Description,
                                            $This.HotFixID,
                                            $This.InstalledBy,
                                            $This.InstalledOn
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.HotFixItem>"
        }
    }

    # // =================================================================
    # // | For enumerating installed Windows (Updates/Packages/HotFixes) |
    # // =================================================================

    Class HotFixList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        HotFixList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        HotFixList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name = "HotFix"
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($HotFix in Get-HotFix)
            {
                $This.Add($HotFix)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Item in $Items)
            {
                $This.Add($Item.Value,[Switch]$True)
            }
        }
        [Object] HotFixItem([UInt32]$Index,[Object]$HotFix)
        {
            Return [HotFixItem]::New($Index,$Hotfix)
        }
        [Object] HotFixItem([UInt32]$Index,[String]$Line,[Switch]$Flags)
        {
            Return [HotFixItem]::New($Index,$Line,$Flags)
        }
        Add([Object]$Hotfix)
        {
            $This.Output += $This.HotFixItem($This.Output.Count,$HotFix)
            $This.Count   = $This.Output.Count
        }
        Add([String]$Line,[Switch]$Flags)
        {
            $This.Output += $This.HotFixItem($This.Output.Count,$Line,$Flags)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.HotFixList>" -f $This.Count
        }
    }

    # // =====================================================
    # // | For enumerating Windows optional feature(s) state |
    # // =====================================================
    
    Enum WindowsOptionalStateType
    {
        Disabled
        DisabledWithPayloadRemoved
        Enabled
    }

    # // =====================================================
    # // | For enumerating Windows optional feature(s) state |
    # // =====================================================

    Class WindowsOptionalStateSlot
    {
        [UInt32] $Index
        [String] $Type
        [String] $Symbol
        [String] $Description
        WindowsOptionalStateSlot([String]$Type)
        {
            $This.Type   = [WindowsOptionalStateType]::$Type
            $This.Index  = [UInt32][WindowsOptionalStateType]::$Type
            $This.Symbol = @("[ ]","[!]","[+]")[$This.Index]
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    # // =====================================================
    # // | For enumerating Windows optional feature(s) state |
    # // =====================================================

    Class WindowsOptionalStateList
    {
        [Object] $Output
        WindowsOptionalStateList()
        {
            $This.Output = @( ) 
            [System.Enum]::GetNames([WindowsOptionalStateType]) | % { $This.Add($_) }
        }
        Add([String]$Name)
        {
            $Item             = [WindowsOptionalStateSlot]::New($Name)
            $Item.Description = Switch ($Name)
            {
                Disabled                   { "Feature is disabled"                     }
                DisabledWithPayloadRemoved { "Feature is disabled, payload is removed" }
                Enabled                    { "Feature is enabled"                      }
            }
            $This.Output += $Item
        }
        [Object] Get([String]$Type)
        {
            Return $This.Output | ? Type -eq $Type
        }
    }

    # // ===============================================
    # // | For enumerating Windows optional feature(s) |
    # // ===============================================

    Class WindowsOptionalFeatureItem
    {
        Hidden [UInt32]            $Index
        Hidden [Object]          $Feature
        [String]             $FeatureName
        [Object]                   $State
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [String]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        WindowsOptionalFeatureItem([UInt32]$Index,[Object]$Feature)
        {
            $This.Index            = $Index
            $This.Feature          = $Feature
            $This.FeatureName      = $Feature.FeatureName
            $This.Path             = $Feature.Path
            $This.Online           = $Feature.Online
            $This.WinPath          = $Feature.WinPath
            $This.SysDrivePath     = $Feature.SysDrivePath
            $This.RestartNeeded    = $Feature.RestartNeeded
            $This.LogPath          = $Feature.LogPath
            $This.ScratchDirectory = $Feature.ScratchDirectory
            $This.LogLevel         = $Feature.LogLevel
        }
        WindowsOptionalFeatureItem([UInt32]$Index,[Object]$State,[String]$Feature)
        {
            $This.Index            = $Index
            $This.State            = $State
            $This.FeatureName      = $Feature
        }
        [String] StateLabel()
        {
            Return @("[ ]","[!]","[+]")[$This.State.Index]
        }
        [String] Tag()
        {
            Return "Feature{0}" -f $This.Index
        }
        [String] Value()
        {
            Return "{0} {1}" -f $This.StateLabel(), $This.FeatureName
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.WindowsOptionalFeatureItem>"
        }
    }

    # // ===============================================
    # // | For enumerating Windows optional feature(s) |
    # // ===============================================

    Class WindowsOptionalFeatureList
    {
        Hidden [UInt32]  $Lock
        Hidden [Object] $State
        [String]         $Name
        [UInt32]        $Count
        [Object]       $Output
        WindowsOptionalFeatureList()
        {
            $This.Lock   = 0
            $This.Main()
            $This.Refresh()
        }
        WindowsOptionalFeatureList([Object]$Section)
        {
            $This.Lock   = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name   = "Optional Features"
            $This.State  = $This.GetWindowsOptionalStateList()
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Feature in Get-WindowsOptionalFeature -Online | Sort-Object FeatureName)
            {
                $This.Add($Feature)
                $This.Output[-1].State = $This.State | ? Type -eq $This.Output[-1].Feature.State
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Item in $Items)
            {
                $xState  = $This.State | ? Symbol -match ([Regex]::Matches($Item.Value,"\[\W\]").Value)
                $This.Add($Item.Rank,$xState,$Item.Value.Substring(4))
            }
        }
        [Object] WindowsOptionalFeatureItem([UInt32]$Index,[Object]$Feature)
        {
            Return [WindowsOptionalFeatureItem]::New($Index,$Feature)
        }
        [Object] WindowsOptionalFeatureItem([UInt32]$Index,[Object]$State,[String]$Name)
        {
            Return [WindowsOptionalFeatureItem]::New($Index,$State,$Name)
        }
        [Object] GetWindowsOptionalStateList()
        {
            Return [WindowsOptionalStateList]::New().Output
        }
        Add([Object]$Feature)
        {
            $This.Output += $This.WindowsOptionalFeatureItem($This.Output.Count,$Feature)
            $This.Count   = $This.Output.Count
        }
        Add([String]$Index,[Object]$State,[String]$Name)
        {
            $This.Output += $This.WindowsOptionalFeatureItem($Index,$State,$Name)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.WindowsOptionalFeatureList>" -f $This.Count
        }
    }

    # // =================================================
    # // | For enumerating installed applications (Item) |
    # // =================================================

    Class ApplicationItem
    {
        Hidden [UInt32]           $Index
        Hidden [Object]     $Application
        [String]                   $Type
        [String]            $DisplayName
        [String]         $DisplayVersion
        Hidden [String]         $Version
        Hidden [Int32]         $NoRemove
        Hidden [String]      $ModifyPath
        Hidden [String] $UninstallString
        Hidden [String] $InstallLocation
        Hidden [String]     $DisplayIcon
        Hidden [Int32]         $NoRepair
        Hidden [String]       $Publisher
        Hidden [String]     $InstallDate
        Hidden [Int32]     $VersionMajor
        Hidden [Int32]     $VersionMinor
        ApplicationItem([UInt32]$Index,[Object]$App)
        {
            $This.Index            = $Index
            $This.Type             = @("MSI","WMI")[$App.UninstallString -imatch "msiexec"]
            $This.DisplayName      = @("-",$App.DisplayName)[!!$App.DisplayName]
            $This.DisplayVersion   = @("-",$App.DisplayVersion)[!!$App.DisplayVersion]
            $This.Version          = @("-",$App.Version)[!!$App.Version]
            $This.NoRemove         = $App.NoRemove
            $This.ModifyPath       = $App.ModifyPath
            $This.UninstallString  = $App.UninstallString
            $This.InstallLocation  = $App.InstallLocation
            $This.DisplayIcon      = $App.DisplayIcon
            $This.NoRepair         = $App.NoRepair
            $This.Publisher        = $App.Publisher
            $This.InstallDate      = $App.InstallDate
            $This.VersionMajor     = $App.VersionMajor
            $This.VersionMinor     = $App.VersionMinor
        }
        ApplicationItem([UInt32]$Index,[String]$Type,[String]$DisplayName,[String]$DisplayVersion)
        {
            $This.Index            = $Index
            $This.Type             = $Type
            $This.DisplayName      = $DisplayName
            $This.DisplayVersion   = $DisplayVersion
        }
        [String] Tag()
        {
            Return "Application{0}" -f $This.Index
        }
        [String] Value()
        {
            Return "{0}|{1}|{2}" -f $This.Type, $This.DisplayName, $This.DisplayVersion
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.ApplicationItem>"
        }
    }

    # // ======================================================
    # // | For enumerating installed applications (Container) |
    # // ======================================================

    Class ApplicationList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        ApplicationList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        ApplicationList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name = "Application"
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Application in $This.GetApplications())
            {
                $This.Add($Application)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Item in $Items)
            {
                $Trim           = $Item.Value -Split "\|"
                $Type           = $Trim[0]
                $DisplayName    = $Trim[1]
                $DisplayVersion = $Trim[2]

                $This.Add($Type,$DisplayName,$DisplayVersion)
            }
        }
        [Object] GetApplications()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Item = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
            $Slot = Switch ([Environment]::GetEnvironmentVariable("Processor_Architecture"))
            {
                AMD64   { 0,1 } Default { 0 }
            }

            Return $Item[$Slot] | % { Get-ItemProperty $_ } | ? DisplayName | Sort-Object DisplayName
        }
        [Object] Application([UInt32]$Index,[Object]$Application)
        {
            Return [ApplicationItem]::New($Index,$Application)
        }
        [Object] Application([UInt32]$Index,[String]$Type,[String]$DisplayName,[String]$DisplayVersion)
        {
            Return [ApplicationItem]::New($Index,$Type,$DisplayName,$DisplayVersion)
        }
        Add([Object]$Application)
        {
            $This.Output += $This.Application($This.Output.Count,$Application)
            $This.Count   = $This.Output.Count
        }
        Add([String]$Type,[String]$DisplayName,[String]$DisplayVersion)
        {
            $This.Output += $This.Application($This.Output.Count,$Type,$DisplayName,$DisplayVersion)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.ApplicationList>" -f $This.Count
        }
    }

    # // ==================================================================================
    # // | For enumerating all available Windows event log files (names/providers) (Item) |
    # // ==================================================================================

    Class EventLogProviderItem
    {
        Hidden [UInt32] $Index
        [String]         $Name
        [String]  $DisplayName
        EventLogProviderItem([UInt32]$Index,[String]$Name)
        {
            $This.Index       = $Index
            $This.Name        = "Provider$Index"
            $This.DisplayName = $Name
        }
        [String] Tag()
        {
            Return $This.Name
        }
        [String] Value()
        {
            Return $This.DisplayName
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.EventLogProviderItem>"
        }
    }

    # // =======================================================================================
    # // | For enumerating all available Windows event log files (names/providers) (Container) |
    # // =======================================================================================

    Class EventLogProviderList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        EventLogProviderList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        EventLogProviderList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name   = "Event Logs"
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Item in Get-WinEvent -ListLog * | % LogName | Sort-Object)
            {
                $This.Add($Item)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Item in $Items)
            {
                $This.Add($Item.Value)
            }
        }
        [Object] EventLogProviderItem([UInt32]$Index,[String]$Name)
        {
            Return [EventLogProviderItem]::New($Index,$Name)
        }
        Add([String]$Name)
        {
            $This.Output += $This.EventLogProviderItem($This.Output.Count,$Name)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.EventLogProviderList>" -f $This.Count
        }
    }

    # // =========================================
    # // | For enumerating scheduled task states |
    # // =========================================

    Enum ScheduledTaskStateType
    {
        Disabled
        Ready
        Running
    }
    
    # // =====================================================================
    # // | For providing an index and description for a scheduled task state |
    # // =====================================================================

    Class ScheduledTaskStateItem
    {
        [UInt32]       $Index
        [String]        $Type
        [String] $Description
        ScheduledTaskStateItem([String]$Type)
        {
            $This.Type  = $Type
            $This.Index = [UInt32][ScheduledTaskStateType]::$Type        
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    # // =========================================
    # // | For enumerating scheduled task states |
    # // =========================================

    Class ScheduledTaskStateList
    {
        [Object] $Output
        ScheduledTaskStateList()
        {
            $This.Output = @( )

            ForEach ($Name in [System.Enum]::GetNames([ScheduledTaskStateType]))
            {
                $This.Add($Name)
            }
        }
        Add([String]$Type)
        {
            $Item             = [ScheduledTaskStateItem]::New($Type)
            $Item.Description = Switch ($Type)
            {
                Disabled { "The scheduled task is currently disabled."        }
                Ready    { "The scheduled task is enabled, and ready to run." }
                Running  { "The scheduled task is currently running."         }
            }

            $This.Output     += $Item
        }
    }

    # // =====================================
    # // | For enumerating scheduled task(s) |
    # // =====================================

    Class ScheduledTaskItem
    {
        Hidden [UInt32] $Index
        Hidden [Object]  $Task
        [String]         $Path
        [String]         $Name
        [Object]        $State
        ScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            $This.Index = $Index
            $This.Task  = $Task
            $This.Path  = $Task.TaskPath
            $This.Name  = $Task.TaskName
        }
        ScheduledTaskItem([UInt32]$Index,[String]$Path,[String]$Name,[Object]$State)
        {
            $This.Index = $Index
            $This.Path  = $Path
            $This.Name  = $Name
            $This.State = $State
        }
        [String] Tag()
        {
            Return "Task{0}" -f $This.Index
        }
        [String] Value()
        {
            Return "{0}|{1}|{2}" -f $This.Path, $This.Name, $This.State.ToString()
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.ScheduledTaskItem>"
        }
    }

    # // =====================================
    # // | For enumerating scheduled task(s) |
    # // =====================================

    Class ScheduledTaskList
    {
        Hidden [UInt32]  $Lock
        Hidden [Object] $State
        [String]         $Name
        [UInt32]        $Count
        [Object]       $Output
        ScheduledTaskList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        ScheduledTaskList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name   = "ScheduledTaskList"
            $This.State  = $This.ScheduledTaskStateList()
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Task in Get-ScheduledTask)
            {
                $This.Add($Task)
                $This.Output[-1].State = $This.State | ? Type -eq $Task.State
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Item in $Items)
            {
                $Trim   = $Item.Value -Split "\|"
                $Path   = $Trim[0]
                $xName  = $Trim[1]
                $xState = $This.State | ? Type -eq $Trim[2]

                $This.Add($Path,$xName,$xState)
            }
        }
        [Object] ScheduledTaskStateList()
        {
            Return [ScheduledTaskStateList]::New().Output
        }
        [Object] GetScheduledTaskItem([UInt32]$Index,[Object]$Task)
        {
            Return [ScheduledTaskItem]::New($Index,$Task)
        }
        [Object] GetScheduledTaskItem([UInt32]$Index,[String]$Path,[String]$Name,[Object]$State)
        {
            Return [ScheduledTaskItem]::New($Index,$Path,$Name,$State)
        }
        Add([Object]$Task)
        {
            $This.Output += $This.GetScheduledTaskItem($This.Output.Count,$Task)
            $This.Count   = $This.Output.Count
        }
        Add([String]$Path,[String]$Name,[Object]$State)
        {
            $This.Output += $This.GetScheduledTaskItem($This.Output.Count,$Path,$Name,$State)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.ScheduledTaskList>" -f $This.count
        }
    }

    # // =======================================================
    # // | # For enumerating AppX packages, like MS Edge, etc. |
    # // =======================================================

    Class AppXItem
    {
        Hidden [UInt32]            $Index
        Hidden [Object]             $AppX
        [String]             $DisplayName
        [Version]                $Version
        [String]             $PublisherID
        [String]             $PackageName
        Hidden [UInt32]     $MajorVersion
        Hidden [UInt32]     $MinorVersion
        Hidden [UInt32]            $Build
        Hidden [UInt32]         $Revision
        Hidden [UInt32]     $Architecture
        Hidden [String]       $ResourceID
        Hidden [String]  $InstallLocation
        Hidden [Object]          $Regions
        Hidden [String]             $Path
        Hidden [UInt32]           $Online
        Hidden [String]          $WinPath
        Hidden [string]     $SysDrivePath
        Hidden [UInt32]    $RestartNeeded
        Hidden [String]          $LogPath
        Hidden [String] $ScratchDirectory
        Hidden [String]         $LogLevel
        AppXItem([UInt32]$Index,[Object]$AppX)
        {
            $This.Index            = $Index
            $This.AppX             = $AppX
            $This.DisplayName      = $AppX.DisplayName
            $This.Version          = $AppX.Version
            $This.PublisherId      = $AppX.PublisherId
            $This.PackageName      = $AppX.PackageName
            $This.MajorVersion     = $AppX.MajorVersion
            $This.MinorVersion     = $AppX.MinorVersion
            $This.Build            = $AppX.Build
            $This.Revision         = $AppX.Revision
            $This.Architecture     = $AppX.Architecture
            $This.ResourceId       = $AppX.ResourceId
            $This.InstallLocation  = $AppX.InstallLocation
            $This.Regions          = $AppX.Regions
            $This.Path             = $AppX.Path
            $This.Online           = $AppX.Online
            $This.WinPath          = $AppX.WinPath
            $This.SysDrivePath     = $AppX.SysDrivePath
            $This.RestartNeeded    = $AppX.RestartNeeded
            $This.LogPath          = $AppX.LogPath
            $This.ScratchDirectory = $AppX.ScratchDirectory
            $This.LogLevel         = $AppX.LogLevel
        }
        AppXItem([UInt32]$Index,[String]$DisplayName,[String]$Version,[String]$PublisherID,[String]$PackageName)
        {
            $This.Index       = $Index
            $This.DisplayName = $DisplayName
            $This.Version     = $Version
            $This.PublisherID = $PublisherId
            $This.PackageName = $PackageName
        }
        [String] Tag()
        {
            Return "Application{0}" -f $This.Index
        }
        [String] Value()
        {
            Return "{0}|{1}|{2}|{3}" -f $This.DisplayName, $This.Version, $this.PublisherID, $This.PackageName
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "<FESystem.AppXItem>"
        }
    }
    
    # // =====================================================
    # // | For enumerating AppX packages, like MS Edge, etc. |
    # // =====================================================
    
    Class AppXList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        AppXList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        AppXList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name = "AppXList"
            $This.Clear()
        }
        Clear()
        {
            $This.Count  = 0
            $This.Output = @( )
        }
        Refresh()
        {
            If ($This.Mode -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }
    
            $This.Clear()
    
            ForEach ($AppX in Get-AppxProvisionedPackage -Online)
            {    
                $This.Add($AppX)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()
    
            ForEach ($Item in $Items)
            {
                $Trim        = $Item.Value -Split "\|"
                $DisplayName = $Trim[0]
                $Version     = $Trim[1]
                $PublisherId = $Trim[2]
                $PackageName = $Trim[3]
        
                $This.Add($DisplayName,$Version,$PublisherId,$PackageName)
            }
        }
        [Object] AppXItem([UInt32]$Index,[Object]$AppX)
        {
            Return [AppXItem]::New($Index,$AppX)
        }
        [Object] AppXItem([UInt32]$Index,[String]$DisplayName,[String]$Version,[String]$PublisherID,[String]$PackageName)
        {
            Return [AppXItem]::New($Index,$DisplayName,$Version,$PublisherID,$PackageName)
        }
        Add([Object]$AppX)
        {
            $This.Output += $This.AppXItem($This.Output.Count,$AppX)
            $This.Count   = $This.Output.Count
        }
        Add([String]$DisplayName,[String]$Version,[String]$PublisherID,[String]$PackageName)
        {
            $This.Output += $This.AppXItem($This.Output.Count,$DisplayName,$Version,$PublisherID,$PackageName)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.AppXList>" -f $This.Count
        }
    }

    # // ============================================================
    # // | Processor information for the system this tool is run on |
    # // ============================================================

    Class ProcessorItem
    {
        Hidden [UInt32]     $Lock
        [UInt32]            $Rank
        [String]    $Manufacturer
        [String]            $Name
        [String]         $Caption
        [UInt32]           $Cores
        [UInt32]            $Used
        [UInt32]         $Logical
        [UInt32]         $Threads
        [String]     $ProcessorId
        [String]        $DeviceId
        [UInt32]           $Speed
        Hidden [Object] $Property
        ProcessorItem([UInt32]$Rank,[Object]$CPU)
        {
            $This.Lock         = 0
            $This.Rank         = $Rank
            $This.Manufacturer = Switch -Regex ($CPU.Manufacturer) 
                                 {
                                    Intel   {           "Intel" }
                                    Amd     {             "AMD" }
                                    Default { $Cpu.Manufacturer }
                                 }
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.Cores        = $CPU.NumberOfCores
            $This.Used         = $CPU.NumberOfEnabledCore
            $This.Logical      = $CPU.NumberOfLogicalProcessors 
            $This.Threads      = $CPU.ThreadCount
            $This.ProcessorID  = $CPU.ProcessorId
            $This.DeviceID     = $CPU.DeviceID
            $This.Speed        = $CPU.MaxClockSpeed

            $This.Property     = @( )

            ForEach ($Item in $CPU.PSObject.Properties)
            {
                $This.Property += $This.SystemProperty($Item)
            }
        }
        ProcessorItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Mode         = 1
            $This.Rank         = $Rank
            $This.Load($Pairs)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,"Processor$($This.Rank)",$Property.Name,$Property.Value)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ==========================================
    # // | Processor container, handles 1 or more |
    # // ==========================================

    Class ProcessorList
    {
        Hidden [UInt32] $Lock
        [Object]        $Name
        [Object]       $Count
        [Object]      $Output
        ProcessorList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        ProcessorList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name    = "Processor(s)"
            $This.Clear()
        }
        Clear()
        {
            $This.Output  = @( )
            $This.Count   = 0
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Processor in Get-CimInstance Win32_Processor)
            {
                $This.Add($This.Output.Count,$Processor)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()
            
            ForEach ($Item in $Items)
            {
                $This.Add($Item.Rank,$Item.Property,[Switch]$True)
            }
        }
        [Object] ProcessorItem([UInt32]$Rank,[Object]$Processor)
        {
            Return [ProcessorItem]::New($Rank,$Processor)
        }
        [Object] ProcessorItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            Return [ProcessorItem]::New($Rank,$Pairs,$Flags)
        }
        Add([UInt32]$Rank,[Object]$Processor)
        {
            $This.Output  += $This.ProcessorItem($Rank,$Processor)
            $This.Count    = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output  += $This.ProcessorItem($Rank,$Pairs,$Flags)
            $This.Count    = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.ProcessorList>" -f $This.Count
        }
    }

    # // =======================================================================
    # // | Used to convert the byte size of a drive or partition into a string |
    # // =======================================================================

    Class Size
    {
        [UInt64]  $Bytes
        [String] $String
        Size([UInt64]$Bytes)
        {
            $This.Bytes  = $Bytes
            $This.String = $This.GetSize($Bytes)
        }
        [String] GetSize([Int64]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -lt 1KB}                 {     "{0} B" -f $Size }
                {$_ -ge 1KB -and $_ -lt 1MB} { "{0:n2} KB" -f ($Size/1KB) }
                {$_ -ge 1MB -and $_ -lt 1GB} { "{0:n2} MB" -f ($Size/1MB) }
                {$_ -ge 1GB -and $_ -lt 1TB} { "{0:n2} GB" -f ($Size/1GB) }
                {$_ -ge 1TB}                 { "{0:n2} TB" -f ($Size/1TB) }
            })
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    # // ==================================================================
    # // | Drive/partition information for the system this tool is run on |
    # // ==================================================================

    Class PartitionItem
    {
        Hidden [UInt32]     $Lock
        Hidden [String]    $Label
        [UInt32]            $Rank
        [String]            $Type
        [String]            $Name
        [Object]            $Size
        [UInt32]            $Boot
        [UInt32]         $Primary
        [UInt32]            $Disk
        [UInt32]       $Partition
        Hidden [Object] $Property
        PartitionItem([UInt32]$Rank,[Object]$Partition)
        {
            $This.Lock       = 0
            $This.Label      = $Partition.Name -Replace "( |#)", "" -Replace ",","."
            $This.Rank       = $Rank
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.Size       = $This.GetSize($Partition.Size)
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.Partition  = $Partition.Index

            $This.Property   = @( )

            ForEach ($Item in $Partition.PSObject.Properties)
            {
                $This.Property += $This.SystemProperty($Item)
            }
        }
        PartitionItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Lock = 1
            $This.Rank = $Rank
            $This.Load($Pairs)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,"Disk$($This.Disk).Partition$($This.Partition)",$Property.Name,$Property.Value)
        }
        [Object] GetSize([UInt64]$Bytes)
        {
            Return [Size]::New($Bytes)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "[{0}/{1}]" -f $This.Name, $This.Size
        }
    }

    # // ================================================================
    # // | Specifically for single/multiple partitions on a given drive |
    # // ================================================================

    Class PartitionList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        PartitionList()
        {
            $This.Lock = 0
            $This.Main()
        }
        PartitionList([Object[]]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section)
        }
        Main()
        {
            $This.Name = "Partition(s)"
            $This.Clear()
        }
        Clear()
        {
            $This.Count   = 0
            $This.Output  = @( )
        }
        Load([Object[]]$Section)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Partition in $Section | ? Name -match Partition)
            {
                $Rank = $Partition.Name -Replace "Disk\d+\.Partition", ""
                $This.Add($Rank,$Partition.Property,[Switch]$True)
            }
        }
        [Object] PartitionItem([UInt32]$Rank,[Object]$Partition)
        {
            Return [PartitionItem]::New($Rank,$Partition)
        }
        [Object] PartitionItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            Return [PartitionItem]::New($Rank,$Pairs,$Flags)
        }
        Add([UInt32]$Rank,[Object]$Partition)
        {
            $This.Output += $This.PartitionItem($Rank,$Partition)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output += $This.PartitionItem($Rank,$Pairs,[Switch]$Flags)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ===========================================================================================
    # // | Specifically for a single volume on a given drive, meant for injecting with a partition |
    # // ===========================================================================================

    Class VolumeItem
    {
        Hidden [UInt32]     $Lock
        Hidden [String]    $Label
        [UInt32]            $Rank
        [String]         $DriveID
        [String]     $Description
        [String]      $Filesystem
        [Object]       $Partition
        [String]      $VolumeName
        [String]    $VolumeSerial
        [Object]            $Size
        [Object]       $Freespace
        [Object]            $Used
        Hidden [Object] $Property
        VolumeItem([UInt32]$Rank,[String]$Partition,[Object]$Drive)
        {
            $This.Lock              = 0
            $This.Label             = "{0}.Volume$Rank" -f ($Partition -Split ",")[0] -Replace "( |#)",""
            $This.Rank              = $Rank
            $This.DriveID           = $Drive.Name
            $This.Description       = $Drive.Description
            $This.Filesystem        = $Drive.Filesystem
            $This.Partition         = $Partition
            $This.VolumeName        = $Drive.VolumeName
            $This.VolumeSerial      = $Drive.VolumeSerialNumber
            $This.Size              = $This.GetSize($Drive.Size)
            $This.Freespace         = $This.GetSize($Drive.Freespace)
            $This.Used              = $This.GetSize(($This.Size.Bytes - $This.Freespace.Bytes))
            
            $This.Property          = @( )

            ForEach ($Item in $This.PSObject.Properties)
            {
                $This.Property += $This.SystemProperty($Item)
            }
        }
        VolumeItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Lock = 1
            $This.Rank = $Rank
            $This.Load($Pairs)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [Object] SystemProperty([Object]$Property)
        {
            Return [SystemProperty]::New(0,$This.Property.Count,$This.Label,$Property.Name,$Property.Value)
        }
        [Object] GetSize([UInt64]$Bytes)
        {
            Return [Size]::New($Bytes)
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return "[{0}\ {1}]" -f $This.DriveID, $This.Size
        }
    }

    # // =============================================================
    # // | Specifically for single/multiple volumes on a given drive |
    # // =============================================================

    Class VolumeList
    {
        Hidden [UInt32] $Lock
        [String]        $Name
        [UInt32]       $Count
        [Object]      $Output
        VolumeList()
        {
            $This.Lock = 0
            $This.Main()
        }
        VolumeList([Object[]]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section)
        }
        Main()
        {
            $This.Name = "Volumes"
            $This.Clear()
        }
        Clear()
        {
            $This.Count   = 0
            $This.Output  = @( )
        }
        Load([Object[]]$Section)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $This.Clear()

            ForEach ($Volume in $Section | ? Name -match Volume)
            {
                $Rank = $Volume.Name -Replace "Disk\d+\.Volume", ""
                $This.Add($Rank,$Volume.Property,[Switch]$True)
            }
        }

        [Object] VolumeItem([UInt32]$Rank,[String]$Partition,[Object]$Drive)
        {
            Return [VolumeItem]::New($Rank,$Partition,$Drive)
        }
        [Object] VolumeItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            Return [VolumeItem]::New($Rank,$Pairs,$Flags)
        }
        Add([UInt32]$Rank,[String]$Partition,[Object]$Drive)
        {
            $This.Output += $This.VolumeItem($Rank,$Partition,$Drive)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output += $This.VolumeItem($Rank,$Pairs,$Flags)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ========================================
    # // | Extended information for hard drives |
    # // ========================================

    Class DiskItem
    {
        Hidden [UInt32]       $Lock
        Hidden [UInt32]       $Rank
        [UInt32]             $Index
        [String]              $Disk
        [String]             $Model
        [String]            $Serial
        [String]    $PartitionStyle
        [String]  $ProvisioningType
        [String] $OperationalStatus
        [String]      $HealthStatus
        [String]           $BusType
        [String]          $UniqueId
        [String]          $Location
        [Object]         $Partition
        [Object]            $Volume
        DiskItem([UInt32]$Rank,[Object]$Disk)
        {
            $This.Lock     = 0
            $This.Rank     = $Rank
            $This.Index    = $Disk.Index
            $This.Disk     = $Disk.DeviceId
    
            $This.Init()
            $This.Refresh()
        }
        DiskItem([UInt32]$Rank,[Object[]]$Section,[Switch]$Flags)
        {
            $This.Lock    = 1
            $This.Rank    = $Rank
            $This.Load($Section)
        }
        Load([Object[]]$Section)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            # [Properties]
            ForEach ($Pair in $Section | ? Name -match ^Disk\d+$ | % Property)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
            
            # [Partition(s) + Volume(s)]
            $This.Init($Section)
        }
        [Object] Get([String]$Name)
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Item = Switch -Regex ($Name)
            {
                MsftDisk
                {
                    Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $This.Index
                }
                DiskPartition
                {
                    Get-CimInstance Win32_DiskPartition | ? DiskIndex -eq $This.Index
                }
                LogicalDisk
                {
                    Get-CimInstance Win32_LogicalDisk | ? DriveType -eq 3
                }
                LogicalDiskToPartition
                {
                    Get-CimInstance Win32_LogicalDiskToPartition
                }
            }

            Return $Item
        }
        [Object] GetPartitionList()
        {
            Return [PartitionList]::New()
        }
        [Object] GetPartitionList([Object[]]$Section,[Switch]$Flags)
        {
            Return [PartitionList]::New($Section,$Flags)
        }
        [Object] GetVolumeList()
        {
            Return [VolumeList]::New()
        }
        [Object] GetVolumeList([Object[]]$Section,[Switch]$Flags)
        {
            Return [VolumeList]::New($Section,$Flags)
        }
        Init()
        {
            $This.Partition = $This.GetPartitionList()
            $This.Volume    = $This.GetVolumeList()
        }
        Init([Object[]]$Section)
        {
            $This.Partition = $This.GetPartitionList($Section,[Switch]$True)
            $This.Volume    = $This.GetVolumeList($Section,[Switch]$True)
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $MSFTDISK               = $This.Get("MsftDisk")
            If (!$MSFTDISK)
            {
                Throw "Unable to set the drive data"
            }
    
            $This.Model             = $MSFTDISK.Model
            $This.Serial            = $MSFTDISK | ? SerialNumber | % { $_.SerialNumber.TrimStart(" ") }
            $This.PartitionStyle    = $MSFTDISK.PartitionStyle
            $This.ProvisioningType  = $MSFTDISK.ProvisioningType
            $This.OperationalStatus = $MSFTDISK.OperationalStatus
            $This.HealthStatus      = $MSFTDISK.HealthStatus
            $This.BusType           = $MSFTDISK.BusType
            $This.UniqueId          = $MSFTDISK.UniqueId
            $This.Location          = $MSFTDISK.Location

            $DiskPartition          = $This.Get("DiskPartition")
            $LogicalDisk            = $This.Get("LogicalDisk")
            $LogicalPart            = $This.Get("LogicalDiskToPartition")
    
            Switch ($DiskPartition.Count)
            {
                0
                {
                    Write-Warning "[Disk:($($This.Rank))] [!] No disk partitions detected [!]"
                }
                Default
                {
                    ForEach ($Item in $DiskPartition)
                    {
                        $This.Partition.Add($This.Partition.Output.Count,$Item)
                    }
                }
            }
    
            Switch ($LogicalDisk.Count)
            {
                0
                {
                    Write-Warning "[Disk: $($This.Rank)] [!] No disk volumes detected [!]"
                }
                Default
                {
                    ForEach ($Logical in $LogicalPart | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name})
                    {
                        $Part = $DiskPartition | ? Name     -eq $Logical.Antecedent.DeviceID
                        $Item = $LogicalDisk   | ? DeviceID -eq $Logical.Dependent.DeviceID
                        If ($Part -and $Item)
                        {
                            $This.Volume.Add($This.Volume.Output.Count,$Part.Name,$Item)
                        }
                    }
                }
            }
        }
        [UInt32] GetSlot()
        {
            Return 2
        }
        [String] ToString()
        {
            Return "{0}({1})" -f $This.Model, $This.Rank
        }
    }
    
    # // =====================================================================================
    # // | Drive/file formatting information (container), for the system this tool is run on |
    # // =====================================================================================

    Class DiskList
    {
        Hidden [UInt32] $Lock
        [Object]        $Name
        [Object]       $Count
        [Object]      $Output
        DiskList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        DiskList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name     = "Disk(s)"
            $This.Clear()
        }
        Clear()
        {
            $This.Count    = 0
            $This.Output   = @( )
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()
            
            ForEach ($Disk in Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed)
            {
                $This.Add($Disk)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Mode -ne 1)
            {
                Throw "Method unavailable [Object lock]"
            }

            # Queues the number of unique disks            
            ForEach ($DiskName in $Items | ? Name -match ^Disk\d+$ | % Name)
            {
                # Selects ALL of the items belonging to the current disk name
                $Current   = $Items | ? Name -match $DiskName
                $Rank      = $Diskname -Replace "Disk",""

                $This.Add($Rank,$Current)
            }
        }
        [Object] DiskItem([UInt32]$Rank,[Object]$Disk)
        {
            Return [DiskItem]::New($Rank,$Disk)
        }
        [Object] DiskItem([UInt32]$Rank,[Object[]]$Items,[Switch]$Flags)
        {
            Return [DiskItem]::New($Rank,$Items,$Flags)
        }
        Add([Object]$Disk)
        {
            $This.Output += $This.DiskItem($This.Output.Count,$Disk)
            $This.Count   = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Items)
        {
            $This.Output += $This.DiskItem($Rank,$Items,[Switch]$True)
            $This.Count   = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 2
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.DiskList>" -f $This.Count
        }
    }

    # // ==================================================
    # // | Network adapter information (Online + Offline) |
    # // ==================================================

    Class NetworkItem
    {
        Hidden [UInt32] $Lock
        [UInt32]        $Rank
        [String]        $Name
        [UInt32]      $Status
        [String]   $IPAddress
        [String]  $SubnetMask
        [String]     $Gateway
        [String]   $DnsServer
        [String]  $DhcpServer
        [String]  $MacAddress
        NetworkItem([UInt32]$Rank,[Object]$If)
        {
            $This.Lock                = 0
            $This.Rank                = $Rank
            $This.Name                = $If.Description
            $This.Status              = [UInt32]$If.IPEnabled

            Switch ($This.Status)
            {
                0
                {
                    $This.IPAddress   = "-"
                    $This.SubnetMask  = "-"
                    $This.Gateway     = "-"
                    $This.DnsServer   = "-"
                    $This.DhcpServer  = "-"
                }
                1
                {
                    $This.IPAddress   = $If.IPAddress             | ? {$_ -match "(\d+\.){3}\d+"}
                    $This.SubnetMask  = $If.IPSubnet              | ? {$_ -match "(\d+\.){3}\d+"}
                    If ($If.DefaultIPGateway)
                    {
                        $This.Gateway = $If.DefaultIPGateway      | ? {$_ -match "(\d+\.){3}\d+"}
                    }
                    $This.DnsServer   = ($If.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}) -join ", "
                    $This.DhcpServer  = $If.DhcpServer            | ? {$_ -match "(\d+\.){3}\d+"}
                }     
            }

            $This.MacAddress          = ("-",$If.MacAddress)[!!$If.MacAddress]
        }
        NetworkItem([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Lock                = 1
            $This.Rank                = $Rank
            $This.Load($Pairs)
        }
        Load([Object[]]$Pairs)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object mode]"
            }

            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        [UInt32] GetSlot()
        {
            Return 0
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ====================================
    # // | Network adapter container object |
    # // ====================================

    Class NetworkList
    {
        Hidden [UInt32] $Lock
        [Object]        $Name
        [Object]       $Count
        [Object]      $Output
        NetworkList()
        {
            $This.Lock = 0
            $This.Main()
            $This.Refresh()
        }
        NetworkList([Object]$Section)
        {
            $This.Lock = 1
            $This.Main()
            $This.Load($Section.Item)
        }
        Main()
        {
            $This.Name       = "Network(s)"
            $This.Clear()
        }
        Clear()
        {
            $This.Output      = @( )
            $This.Count       = 0
        }
        Refresh()
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $This.Clear()

            ForEach ($Network in Get-CimInstance Win32_NetworkAdapterConfiguration)
            {
                $This.Add($Network)
            }
        }
        Load([Object[]]$Items)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            ForEach ($Item in $Items)
            {
                $Rank = $Item.Name -Replace "Network",""
                $This.Add($Rank,$Item.Property,[Switch]$True)
            }
        }
        [Object] NetworkItem([UInt32]$Index,[Object]$Network)
        {
            Return [NetworkItem]::New($Index,$Network)
        }
        [Object] NetworkItem([UInt32]$Index,[Object[]]$Pairs,[Object]$Flags)
        {
            Return [NetworkItem]::New($Index,$Pairs,$Flags)
        }
        Add([Object]$Network)
        {
            $This.Output     += $This.NetworkItem($This.Output.Count,$Network)
            $This.Count       = $This.Output.Count
        }
        Add([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Output     += $This.NetworkItem($Rank,$Pairs,$Flags)
            $This.Count       = $This.Output.Count
        }
        [UInt32] GetSlot()
        {
            Return 1
        }
        [String] ToString()
        {
            Return "({0}) <FESystem.NetworkList>" -f $This.Count
        }
    }

    # // =====================================================
    # // | System snapshot, the primary focus of the utility |
    # // =====================================================

    Class System
    {
        Hidden [UInt32]     $Lock
        Hidden [UInt32]     $Mode
        Hidden [UInt32]    $Level
        Hidden [Object]  $Console
        [Object]        $Snapshot
        [Object] $BiosInformation
        [Object]  $ComputerSystem
        [Object] $OperatingSystem
        [Object]          $HotFix
        [Object]         $Feature
        [Object]     $Application
        [Object]           $Event
        [Object]            $Task
        [Object]            $AppX
        [Object]       $Processor
        [Object]            $Disk
        [Object]         $Network
        System([UInt32]$Mode,[UInt32]$Level)
        {
            $This.Lock             = 0
            $This.Establish($Mode,$Level)

            If ($This.Level -in 0,1,2,3)
            {
                $This.Update(0,"Loading [~] (System/Bios/Computer/OS)")

                $This.Snapshot         = $This.New(00)
                $This.BiosInformation  = $This.New(01)
                $This.ComputerSystem   = $This.New(02)
                $This.OperatingSystem  = $This.New(03)
            }
            
            If ($This.Level -in 0,3)
            {
                $This.Update(0,"Loading [~] (Updates/Features/Apps/Events/Tasks)")

                If ($This.Level -eq 0)
                {
                    $This.HotFix           = $This.New(04)
                }
                
                $This.Feature              = $This.New(05)

                If ($This.Level -eq 0)
                {
                    $This.Application      = $This.New(06)
                    $This.Event            = $This.New(07)
                    $This.Task             = $This.New(08)
                    $This.AppX             = $This.New(09)
                }
            }

            If ($This.Level -in 0,1,3)
            {
                $This.Update(0,"Loading [~] (Processor/Disk/Network)")

                If ($This.Level -in 0,1)
                {
                    $This.Processor        = $This.New(10)
                    $This.Disk             = $This.New(11)
                }

                $This.Network              = $This.New(12)
            }

            $This.Update(100,"Loaded [+] System Snapshot")
        }
        System([UInt32]$Mode,[UInt32]$Level,[Object]$In)
        {
            $This.Lock             = 1
            $This.Establish($Mode,$Level)

            If ($This.Level -in 0,1,2,3)
            {
                $This.Update(0,"Importing [~] (System/Bios/Computer/OS)")

                $This.Snapshot         = $This.Load(00,$In.Get(00))
                $This.BiosInformation  = $This.Load(01,$In.Get(01))
                $This.ComputerSystem   = $This.Load(02,$In.Get(02))
                $This.OperatingSystem  = $This.Load(03,$In.Get(03))
            }

            If ($This.Level -in 0,3)
            {
                $This.Update(0,"Importing [~] (Updates/Features/Apps/Events/Tasks)")

                If ($This.Level -eq 0)
                {
                    $This.HotFix           = $This.Load(04,$In.Get(04))
                }
                
                $This.Feature              = $This.Load(05,$In.Get(05))

                If ($This.Level -eq 0)
                {
                    $This.Application      = $This.Load(06,$In.Get(06))
                    $This.Event            = $This.Load(07,$In.Get(07))
                    $This.Task             = $This.Load(08,$In.Get(08))
                    $This.AppX             = $This.Load(09,$In.Get(09))
                }
            }

            If ($This.Level -in 0,1,3)
            {
                $This.Update(0,"Importing [~] (Processor/Disk/Network)")

                If ($This.Level -in 0,1)
                {
                    $This.Processor        = $This.Load(10,$In.Get(10))
                    $This.Disk             = $This.Load(11,$In.Get(11))
                }

                $This.Network              = $This.Load(12,$In.Get(12))
            }

            $This.Update(100,"Imported [+] System snapshot")
        }
        System([Object]$Module)
        {
            
        }
        Establish([UInt32]$Mode,[UInt32]$Level)
        {
            $This.Mode             = $Mode
            If ($This.Mode -gt 0)
            {
                $This.NewConsole()
            }

            $This.Level            = $Level
            If ($This.Mode -gt 0)
            {
                $This.Update(1,"Level set to [$Level]")
            }
        }
        [String] Id([UInt32]$Rank)
        {
            $Item = Switch ($Rank)
            {
                00 {         "Snapshot" }
                01 {  "BiosInformation" }
                02 {   "ComputerSystem" }
                03 {  "OperatingSystem" }
                04 {           "HotFix" }
                05 {          "Feature" }
                06 {      "Application" }
                07 {            "Event" }
                08 {             "Task" }
                09 {             "AppX" }
                10 {        "Processor" }
                11 {             "Disk" }
                12 {          "Network" }
                13 {            "Event" }
            }

            Return $Item
        }
        [Object] New([UInt32]$Rank)
        {
            If ($This.Lock -eq 1)
            {
                Throw "Method unavailable [Template lock]"
            }

            $Item = Switch ($Rank)
            {
                00 {                   [Snapshot]::New() }
                01 {            [BiosInformation]::New() }
                02 {             [ComputerSystem]::New() }
                03 {            [OperatingSystem]::New() }
                04 {                 [HotFixList]::New() }
                05 { [WindowsOptionalFeatureList]::New() }
                06 {            [ApplicationList]::New() }
                07 {       [EventLogProviderList]::New() }
                08 {          [ScheduledTaskList]::New() }
                09 {                   [AppXList]::New() }
                10 {              [ProcessorList]::New() }
                11 {                   [DiskList]::New() }
                12 {                [NetworkList]::New() }
            }

            Switch (!!$Item)
            {
                $True  { $This.Update( 1,"Loaded [+] $($This.Id($Rank))") }
                $False { $This.Update(-1,"Failed [!] $($This.Id($Rank))") }
            }

            Return $Item
        }
        [Object] Load([UInt32]$Rank,[Object]$Object)
        {
            If ($This.Lock -eq 0)
            {
                Throw "Method unavailable [Object lock]"
            }

            $Item = Switch ($Rank)
            {
                00 {                   [Snapshot]::New($Object) }
                01 {            [BiosInformation]::New($Object) }
                02 {             [ComputerSystem]::New($Object) }
                03 {            [OperatingSystem]::New($Object) }
                04 {                 [HotFixList]::New($Object) }
                05 { [WindowsOptionalFeatureList]::New($Object) }
                06 {            [ApplicationList]::New($Object) }
                07 {       [EventLogProviderList]::New($Object) }
                08 {          [ScheduledTaskList]::New($Object) }
                09 {                   [AppXList]::New($Object) }
                10 {              [ProcessorList]::New($Object) }
                11 {                   [DiskList]::New($Object) }
                12 {                [NetworkList]::New($Object) }
            }

            Switch (!!$Item)
            {
                $True  { $This.Update( 1,"Imported [+] $($This.Id($Rank))") }
                $False { $This.Update(-1,"Failed [!] $($This.Id($Rank))") }
            }

            Return $Item
        }
        [Object] Get([UInt32]$Index)
        {
            $Item = Switch ($Index)
            {
                00 { $This.Snapshot           }
                01 { $This.BiosInformation    }
                02 { $This.ComputerSystem     }
                03 { $This.OperatingSystem    }
                04 { $This.HotFix.Output      }
                05 { $This.Feature.Output     }
                06 { $This.Application.Output }
                07 { $This.Event.Output       }
                08 { $This.Task.Output        }
                09 { $This.AppX.Output        }
                10 { $This.Processor.Output   }
                11 { $This.Disk.Output        }
                12 { $This.Network.Output     }
                13 { $This.Event.Output       }
            }

            Return $Item
        }
        NewConsole()
        {
            If ($This.Mode -eq 0)
            {
                Throw "Console not available in this mode"
            }

            ElseIf (!!$This.Console)
            {
                Throw "Console already exists"
            }

            Else
            {
                $This.Console = New-FEConsole
                $This.Console.Initialize()
                $This.Status()
            }
        }
        [Void] Status()
        {
            If ($This.Mode -eq 2)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        [Void] Update([UInt32]$State,[String]$Status)
        {
            If ($This.Mode -ne 0)
            {
                $This.Console.Update($State,$Status)
                $This.Status()
            }
        }
        [Object] SystemProperty([UInt32]$Index,[UInt32]$Rank,[String]$Source,[String]$Name,[Object]$Value)
        {
            Return [SystemProperty]::New($Index,$Rank,$Source,$Name,$Value)
        }
        [Object] OutputSection([String]$Index,[String]$Name,[UInt32]$Slot)
        {
            Return [OutputSection]::New($Index,$Name,$Slot)
        }
        [Object] OutputFile()
        {
            $This.Update(0,"Generating [~] Output file")

            $Out = @( )  
            ForEach ($Name in $This.PSObject.Properties.Name)
            {
                $Slot    = Switch -Regex ($Name) { "(^Snap|^Bios|^Comp|^Oper)" { 0 } Default { 1 } "^Disk" { 2 } }
                $Section = $This.OutputSection($Out.Count,$Name,$Slot)

                Switch ($Name)
                {
                    Snapshot
                    {
                        ForEach ($Item in $This.Snapshot[0].PSObject.Properties)
                        {
                            $Section.Add($Item.Name,$Item.Value) 
                        }
                    }
                    BiosInformation
                    {
                        ForEach ($Item in $This.BiosInformation[0].PSObject.Properties)
                        {
                            $Section.Add($Item.Name,$Item.Value)
                        }
                    }
                    ComputerSystem
                    {
                        ForEach ($Item in $This.ComputerSystem[0].PSObject.Properties)
                        {
                            $Section.Add($Item.Name,$Item.Value)
                        }
                    }
                    OperatingSystem
                    {
                        ForEach ($Item in $This.OperatingSystem[0].PSObject.Properties)
                        {
                            $Section.Add($Item.Name,$Item.Value)
                        }
                    }
                    HotFix
                    {
                        ForEach ($Item in $This.HotFix.Output)
                        {
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    Feature
                    {
                        ForEach ($Item in $This.Feature.Output)
                        {
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    Application
                    {
                        ForEach ($Item in $This.Application.Output)
                        {
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    Event
                    {
                        ForEach ($Item in $This.Event.Output)
                        { 
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    Task
                    {
                        ForEach ($Item in $This.Task.Output)
                        {
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    AppX
                    {
                        ForEach ($Item in $This.AppX.Output)
                        {
                            $Section.Add($Item.Tag(),$Item.Value())
                        }
                    }
                    Processor
                    {
                        $Rank = 0
                        ForEach ($Processor in $This.Processor.Output)
                        {
                            $Section.Add("Processor$Rank",":")
                            ForEach ($Item in $Processor.PSObject.Properties)
                            {
                                $Section.Add($Item.Name,$Item.Value)
                            }
                            $Rank ++
                        }
                    }
                    Disk
                    {
                        $Rank = 0
                        ForEach ($Disk in $This.Disk.Output)
                        {
                            $Section.Add("Disk$Rank",":")
                            ForEach ($Item in $Disk.PSObject.Properties)
                            {
                                Switch ($Item.Name)
                                {
                                    Partition
                                    {
                                        $Part = 0
                                        ForEach ($Partition in $Disk.Partition.Output)
                                        {
                                            $Section.Add("Disk$Rank.Partition$Part",":")
                                            ForEach ($Prop in $Partition.PSObject.Properties)
                                            {
                                                $Section.Add($Prop.Name,$Prop.Value)
                                            }
                                            $Part ++
                                        }
                                    }
                                    Volume
                                    {
                                        $Vol = 0
                                        ForEach ($Volume in $Disk.Volume.Output)
                                        {
                                            $Section.Add("Disk$Rank.Volume$Vol",":")
                                            ForEach ($Prop in $Volume.PSObject.Properties)
                                            {
                                                $Section.Add($Prop.Name,$Prop.Value)
                                            }
                                            $Vol ++
                                        }
                                    }
                                    Default
                                    {
                                        $Section.Add($Item.Name,$Item.Value)
                                    }
                                }
                            }
                        }
                    }
                    Network
                    {
                        $Rank = 0
                        ForEach ($Network in $This.Network.Output)
                        {
                            $Section.Add("Network$Rank",":")
                            ForEach ($Item in $Network.PSObject.Properties)
                            {
                                $Section.Add($Item.Name,$Item.Value)
                            }
                            $Rank ++
                        }
                    }
                }
                $Out += $Section
            }
            
            $Item = [OutputFile]::New($Out).Output

            Switch (!!$Item)
            {
                $True  { $This.Update( 1,"Generated [+] Output file") }
                $False { $This.Update(-1,"Failed [!] Output file") }
            }

            Return $Item
        }
        WriteOutput()
        {
            If ($This.Mode -ne 0)
            {
                Throw "Invalid mode"
            }

            $Target = "{0}\{1}.txt" -f [Environment]::GetEnvironmentVariable("Temp"), $This.Snapshot.DisplayName
            $This.WriteOutput($Target)
        }
        WriteOutput([String]$Target)
        {
            $Parent = $Target | Split-Path

            If ($This.Mode -ne 0)
            {
                Throw "Invalid mode"
            }

            ElseIf (![System.IO.Directory]::Exists($Parent))
            {
                Throw "Invalid path"
            }

            ElseIf ([System.IO.File]::Exists($Target))
            {
                Throw "File already exists"
            }

            $Value = $This.OutputFile()

            Try
            {
                [System.IO.File]::WriteAllLines($Target,$Value)
                If (![System.IO.File]::Exists($Target))
                {
                    $This.Update(-1,"Exception [!] File [$Target] not saved.")
                }
                Else
                {
                    $This.Update(100,"File [$Target] saved.")
                }
            }
            Catch
            {
                $This.Update(-1,"Exception [!] File [$Target] not saved.")
            }
        }
        [String] ToString()
        {
            Return "{0}, {1} | {2}, {3} {4}-{5}" -f $This.Snapshot.ComputerName, 
            $This.ComputerSystem.Manufacturer, 
            $This.ComputerSystem.Model, 
            $This.OperatingSystem.Caption, 
            $This.OperatingSystem.Version, 
            $This.OperatingSystem.Build
        }
    }

    If (!$Path -and !$InputObject)
    {
        [System]::New($Mode,$Level)
    }

    Else
    {
        If ($Path)
        {
            $InputObject = [System.IO.File]::ReadAllLines($Path)
        }

        $Section = [InputObject]::New($InputObject)
        [System]::New($Mode,$Level,$Section)
    }
}
