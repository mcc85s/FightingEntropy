<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-SystemDetails.ps1                                                                    //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : This function is the main function that collects system information and f                //   
   \\                     ormats it all to export                                                                  \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-10-10                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 11:03:20    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>

Function Get-SystemDetails
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=1)][String]$Path,
        [Parameter(ValueFromPipeline,ParameterSetName=2)][Object]$InputObject) 

    # // _______________________
    # // | Formatting class #1 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class PropertyItem
    {
        Hidden [UInt32] $Index
        [String] $Name
        [Object] $Value
        Hidden [UInt32] $Buffer
        PropertyItem([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Value  = $Value
        }
        PropertyItem([String]$Name,[Object]$Value)
        {
            $This.Name   = $Name
            $This.Value  = $Value
        }
        SetBuffer([UInt32]$X)
        {
            If ($X -ge $This.Name.Length)
            {
                $This.Buffer = $X
            }
        }
        [String] Buff()
        {
            Return (" " * ($This.Buffer - $This.Name.Length) -join '')
        }
        [String] ToString()
        {
            If ($This.Buffer -gt $This.Name.Length)
            {
                Return "{0}{1} {2}" -f $This.Name, $This.Buff(), $This.Value
            }
            Else
            {
                Return "{0} {1}" -f $This.Name, $This.Value
            }
        }
    }

    # // _______________________
    # // | Formatting class #2 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class PropertySlot
    {
        Hidden [Object] $Control
        [UInt32] $Rank
        [UInt32] $Slot
        [Object] $Content = @( )
        [UInt32] $MaxLength
        PropertySlot([Object]$Control,[UInt32]$Rank,[UInt32]$Slot)
        {
            $This.Control = $Control
            $This.Rank    = $Rank
            $This.Slot    = $Slot
        }
        PropertySlot([UInt32]$Rank,[UInt32]$Slot)
        {
            $This.Control = @{ Count = $Null; MaxLength = 0}
            $This.Rank    = $Rank
            $This.Slot    = $Slot
        }
        PropertySlot()
        {
            $This.Control = @{ Count = $Null; MaxLength = 0}
        }
        AddItem([Object]$Property)
        {
            $This.Content += [PropertyItem]::New($This.Content.Count,$Property.Name,$Property.Value)
            $This.NameLength($Property.Name.Length)
        }
        AddItem([String]$Name,[Object]$Value)
        {
            $This.Content += [PropertyItem]::New($This.Content.Count,$Name,$Value)
            $This.NameLength($Name.Length)
        }
        [Void] NameLength([UInt32]$Length)
        {
            If ($Length -gt $This.MaxLength)
            {
                $This.MaxLength = $Length
            }
            If ($This.MaxLength -gt $This.Control.MaxLength)
            {
                $This.Control.MaxLength = $This.MaxLength
            }
        }
        [Void] SetBuffer([UInt32]$Length=$Null)
        {
            Switch (!!$Length)
            {
                $True
                { 
                    $This.Content.SetBuffer($Length)
                    $This.MaxLength = $Length
                }
                $False 
                { 
                    $This.Content.SetBuffer($This.Control.MaxLength)
                    $This.MaxLength = $This.Control.MaxLength
                }
            }            
        }
        [Object[]] GetOutput()
        {
            Return @( $This.Content | % ToString )
        }
        [String] ToString()
        {
            Return $This.Slot
        }
    }

    # // _______________________
    # // | Formatting class #3 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class PropertySet
    {
        Hidden [Object] $Control
        [UInt32] $Rank
        [String] $Title
        [String] $Mode
        [Object] $Slot      = @( )
        [UInt32] $Quantity
        [UInt32] $MaxLength
        PropertySet([Object]$Control,[Object]$Section)
        {
            $This.Control   = $Control
            $This.Rank      = $Section::GetRank()
            $This.Title     = $Section::GetTitle()
            $This.Mode      = $Section::GetMode()
            $This.Quantity  = 0
            $This.MaxLength = 0

            $This.Allocate($Section)
        }
        PropertySet([Object]$Section)
        {
            $This.Control   = @{ Count = $Null ; MaxLength = 0 }
            $This.Rank      = $Section::GetRank()
            $This.Title     = $Section::GetTitle()
            $This.Mode      = $Section::GetMode()
            $This.Quantity  = 0
            $This.MaxLength = 0

            $This.Allocate($Section)
        }
        Allocate([Object]$Section)
        {
            Switch ($This.Mode)
            {
                Prime  
                { 
                    $This.AddSlot($This.Rank,0)
                    ForEach ($Item in @($Section.PSObject.Properties))
                    {
                        $This.Designate($This.Slot[0],$Item)
                    }
                }
                Parent 
                {
                    $C = 0
                    Do
                    {
                        $This.AddSlot($This.Rank,$C)
                        ForEach ($Item in @($Section.Output[$C].PSObject.Properties))
                        {
                            $This.Designate($This.Slot[$C],$Item)
                        }
                        $C ++
                    }
                    Until ($C -eq $Section.Count)
                }
                Clone
                {
                    $This.AddSlot($This.Rank,0)
                    ForEach ($X in @(0..($Section.Output.Count-1)))
                    {
                        $This.Designate($This.Slot[0],$Section.Output[$X])
                    }
                }
            }
        }
        AddSlot([UInt32]$Rank,[UInt32]$Index)
        {
            $This.Slot     += [PropertySlot]::New($This.Control,$Rank,$Index)
            $This.Quantity ++
            $This.Control.Count ++
        }
        AddItem([Object]$Current,[String]$Name,[Object]$Value)
        {
            $Current.AddItem($Name,$Value)
            $This.NameLength($Name.Length)
        }
        AddItem([Object]$Current,[Object]$Property)
        {
            $Current.AddItem($Property)
            $This.NameLength($Property.Name.Length)
        }
        Designate([Object]$Current,[String]$Name,[String]$Value)
        {
            $This.AddItem($Current,$Name,$Value)
        }
        Designate([Object]$Current,[Object]$Property)
        {
            Switch -Regex ($Property.TypeNameOfValue)
            {
                Default 
                { 
                    $This.AddItem($Current,$Property)
                }
                "\[\]"
                {   
                    # Sets anchor for nested items
                    $Parent = $Property.Name
                    $Values = $Property.Value

                    # Drills down into the sets of values
                    ForEach ($X in 0..($Values.Count-1))
                    {
                        $This.AddItem($Current,$Parent + $X,$Null)
                        # Sets each item accoring to higher scope
                        ForEach ($Item in $Values[$X].PSObject.Properties)
                        {
                            $This.AddItem($Current,$Parent + $X + $Item.Name, $Item.Value)
                        }
                    }
                }
            }
        }
        [Void] NameLength([UInt32]$Length)
        {
            If ($Length -ge $This.MaxLength)
            {
                $This.MaxLength         = $Length
            }
            If ($This.MaxLength -ge $This.Control.MaxLength)
            {
                $This.Control.MaxLength = $This.MaxLength
            }
        }
        [Void] SetBuffer([UInt32]$Length=$Null)
        {
            Switch (!!$Length)
            {
                $True
                { 
                    $This.Slot.Content.SetBuffer($Length)
                    $This.MaxLength = $Length
                }
                $False 
                { 
                    $This.Slot.Content.SetBuffer($This.Control.MaxLength)
                    $This.MaxLength = $This.Control.MaxLength
                }
            }            
        }
        [String] Frame([String]$Char)
        {
            Return ($Char * 120 -join '')
        }
        [String[]] Header()
        {
            $Return      = @( )
            $Return     += $This.Frame("-") 
            If ($This.Rank -gt 3)
            {
                $Return += "{0}{1} {2}" -f $This.Title, (" " * ($This.MaxLength-$This.Title.Length) -join ''),@($This.Slot.Count,$This.Slot.Content.Count)[$This.Rank -eq 7]
            }
            Else
            {
                $Return += $This.Title
            }
            $Return     += $This.Frame("-") 
            $Return     += ""
            Return $Return
        }
        [String] Label([Int32]$Ct)
        {
            Return $This.Title -Replace "\(s\)",$Ct
        }
        [String] ToString()
        {
            Return $This.Title
        }
        [Object[]] GetOutput()
        {
            $Return             = @( )
            $Return            += $This.Header()
            Switch ($This.Mode)
            {
                Prime
                {
                    $Return     += @( $This.Slot.Content | % ToString )
                }
                Parent
                {
                    $C           = 0
                    Do
                    {
                        $Return += $This.Label($C)
                        $Return += @( $This.Slot[$C].Content | % ToString )
                        If ( $C + 1 -ne $This.Slot.Count )
                        {
                            $Return += ""
                        }
                        $C      ++
                    }
                    Until ($C -eq $This.Slot.Count)
                }
                Clone
                {
                    $Return     += @( $This.Slot.Content | % ToString )
                }
            }

            If ($This.Rank -ne 7)
            {
                $Return         += ""
            }
            Return $Return
        }
    }

    # // _______________________
    # // | Formatting class #4 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class PropertyControl
    {
        [Object] $Content
        [UInt32] $Count
        [UInt32] $MaxLength
        PropertyControl()
        {
            $This.Content   = @( )
        }
        Add([Object]$Section)
        {
            $This.Content += [PropertySet]::New($This,$Section)
            $This.SetBuffer($This.MaxLength)
        }
        [Void] SetBuffer([UInt32]$Length=$Null)
        {
            Switch (!!$Length)
            {
                $True
                { 
                    $This.MaxLength = $Length
                }
                $False 
                { 
                    $This.Content.Slot.Content.SetBuffer($This.MaxLength)
                }
            }
            ForEach ($X in 0..($This.Content.Count-1))
            {
                $This.Content[$X].SetBuffer($Length)
                $C = 0
                Do 
                {
                    $This.Content[$X].Slot[$C].SetBuffer($Length)
                    $C ++
                }
                Until ($C -eq $This.Content[$X].Quantity)
            }
        }
        [Object[]] GetOutput()
        {
            Return @( $This.Content | % GetOutput )
        }
        [Object] ToString()
        {
            Return $This.Content.ToString()
        }
    }

    # // _____________________________________________________________
    # // | Takes a snapshot of the system with date/time, guid, etc. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Snapshot
    {
        [String] $Start
        [String] $ComputerName
        [String] $DisplayName
        [String] $Guid
        [UInt32] $Complete
        [String] $Elapsed
        Snapshot()
        {
            $Current           = [DateTime]::Now
            $This.Start        = $Current
            $This.ComputerName = [Environment]::MachineName
            $This.DisplayName  = "{0}-{1}" -f $Current.ToString("yyyy-MMdd-HHmmss"), $This.ComputerName
            $This.Guid         = [Guid]::NewGuid().ToString()
        }
        MarkComplete()
        {
            $This.Complete     = 1 
            $This.Elapsed      = [String][Timespan]([DateTime]::Now-[DateTime]$This.Start)
        }
        Snapshot([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        Static [UInt32] GetRank()
        {
            Return 0
        }
        Static [String] GetTitle()
        {
            Return "Snapshot"
        }
        Static [String] GetMode()
        {
            Return "Prime"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}" -f $This.ComputerName
        }
    }

    # // _______________________________________________________
    # // | Bios Information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class BiosInformation
    {
        [String] $Name
        [String] $Manufacturer
        [String] $SerialNumber
        [String] $Version
        [String] $ReleaseDate
        [Bool]   $SmBiosPresent
        [String] $SmBiosVersion
        [String] $SmBiosMajor
        [String] $SmBiosMinor
        [String] $SystemBiosMajor
        [String] $SystemBiosMinor
        BiosInformation()
        {
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
        }
        BiosInformation([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        static [UInt32] GetRank()
        {
            Return 1
        }
        static [String] GetTitle()
        {
            Return "Bios Information"
        }
        static [String] GetMode()
        {
            Return "Prime"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Name
        }
    }

    # // ___________________________________________________________________
    # // | Operating system information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class OperatingSystem
    {
        [String] $Caption
        [String] $Version
        [String] $Build
        [String] $Serial
        [UInt32] $Language
        [UInt32] $Product
        [UInt32] $Type
        OperatingSystem()
        {
            $OS            = Get-CimInstance Win32_OperatingSystem
            $This.Caption  = $OS.Caption
            $This.Version  = $OS.Version
            $This.Build    = $OS.BuildNumber
            $This.Serial   = $OS.SerialNumber
            $This.Language = $OS.OSLanguage
            $This.Product  = $OS.OSProductSuite
            $This.Type     = $OS.OSType
        }
        OperatingSystem([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        static [UInt32] GetRank()
        {
            Return 2
        }
        static [String] GetTitle()
        {
            Return "Operating System"
        }
        static [String] GetMode()
        {
            Return "Prime"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0} {1}-{2}" -f $This.Caption, $This.Version, $This.Build
        }
    }

    # // __________________________________________________________________
    # // | Computer system information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ComputerSystem
    {
        [String] $Manufacturer
        [String] $Model
        [String] $Product
        [String] $Serial
        [String] $Memory
        [String] $Architecture
        [String] $UUID
        [String] $Chassis
        [String] $BiosUefi
        [Object] $AssetTag
        ComputerSystem()
        {
            $Sys               = Get-CimInstance Win32_ComputerSystem 
            $This.Manufacturer = $Sys.Manufacturer
            $This.Model        = $Sys.Model
            $This.Memory       = "{0} GB" -f ($Sys.TotalPhysicalMemory/1GB)
            $This.UUID         = (Get-CimInstance Win32_ComputerSystemProduct).UUID 
            
            $Sys               = Get-CimInstance Win32_BaseBoard
            $This.Product      = $Sys.Product
            $This.Serial       = $Sys.SerialNumber -Replace "\.",""
            
            Try
            {
                Get-SecureBootUEFI -Name SetupMode | Out-Null 
                $This.BiosUefi = "UEFI"
            }
            Catch
            {
                $This.BiosUefi = "BIOS"
            }

            $Sys               = Get-CimInstance Win32_SystemEnclosure
            $This.AssetTag     = $Sys.SMBIOSAssetTag.Trim()
            $This.Chassis      = Switch ([UInt32]$Sys.ChassisTypes[0])
            {
                {$_ -in 8..12+14,18,21} {"Laptop"}
                {$_ -in 3..7+15,16}     {"Desktop"}
                {$_ -in 23}             {"Server"}
                {$_ -in 34..36}         {"Small Form Factor"}
                {$_ -in 30..32+13}      {"Tablet"}
            }

            $This.Architecture = @{x86="x86";AMD64="x64"}[[Environment]::GetEnvironmentVariable("Processor_Architecture")]
        }
        ComputerSystem([Object[]]$Pairs)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        static [UInt32] GetRank()
        {
            Return 3
        }
        static [String] GetTitle()
        {
            Return "Computer System"
        }
        static [String] GetMode()
        {
            Return "Prime"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0} | {1}" -f $This.Manufacturer, $This.Model
        }
    }

    # // ____________________________________________________________
    # // | Processor information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Processor
    {
        Hidden [UInt32] $Mode
        Hidden [UInt32] $Rank
        [String] $Manufacturer
        [String] $Name
        [String] $Caption
        [UInt32] $Cores
        [UInt32] $Used
        [UInt32] $Logical
        [UInt32] $Threads
        [String] $ProcessorId
        [String] $DeviceId
        [UInt32] $Speed
        Processor([UInt32]$Rank,[Object]$CPU)
        {
            $This.Mode         = 0
            $This.Rank         = $Rank
            $This.Manufacturer = Switch -Regex ($CPU.Manufacturer) { Intel { "Intel" } Amd { "AMD" } }
            $This.Name         = $CPU.Name -Replace "\s+"," "
            $This.Caption      = $CPU.Caption
            $This.Cores        = $CPU.NumberOfCores
            $This.Used         = $CPU.NumberOfEnabledCore
            $This.Logical      = $CPU.NumberOfLogicalProcessors 
            $This.Threads      = $CPU.ThreadCount
            $This.ProcessorID  = $CPU.ProcessorId
            $This.DeviceID     = $CPU.DeviceID
            $This.Speed        = $CPU.MaxClockSpeed
        }
        Processor([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Mode = 1
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name) = $Pair.Value
            }
        }
        static [UInt32] GetRank()
        {
            Return 4
        }
        static [String] GetTitle()
        {
            Return "Processor(s)"
        }
        static [String] GetMode()
        {
            Return "Child"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // __________________________________________
    # // | Processor container, handles 1 or more |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Processors
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Processors()
        {
            $This.Name    = "Processor(s)"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetProcessors()
        {
            $This.Output   = @( )
            $This.Count    = 0
            ForEach ($Processor in Get-CimInstance Win32_Processor)
            {
                $This.Output += [Processor]::New($This.Output.Count,$Processor)
                $This.Count  ++
            }
        }
        AddProcessor([Object]$Processor,[Switch]$Flags)
        {
            $This.Output += [Processor]::New($This.Output.Count,$Processor,[Switch]$Flags)
            $This.Count  ++
        }
        RemoveProcessor([UInt32]$Index)
        {
            $This.Output  = $This.Output | ? Rank -ne $Index
            $This.Count  --
        }
        static [UInt32] GetRank()
        {
            Return 4
        }
        static [String] GetTitle()
        {
            Return "Processor(s)"
        }
        static [String] GetMode()
        {
            Return "Parent"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Count
        }
    }


    # // __________________________________________________________________
    # // | Drive/partition information for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Partition
    {
        [String]      $Type
        [String]      $Name
        [String]      $Size
        [UInt32]      $Boot
        [UInt32]   $Primary
        [UInt32]      $Disk
        [UInt32] $Partition
        Partition([Object]$Partition)
        {
            $This.Type       = $Partition.Type
            $This.Name       = $Partition.Name
            $This.Size       = $Partition.Size
            $This.Boot       = $Partition.BootPartition
            $This.Primary    = $Partition.PrimaryPartition
            $This.Disk       = $Partition.DiskIndex
            $This.Partition  = $Partition.Index
        }
        Partition([Object[]]$Pairs,[Switch]$Flags)
        {
            ForEach ($Pair in $Pairs)
            {
                $This.$($Pair.Name -Replace "Partition\d+", "") = $Pair.Value
            }
        }
        static [UInt32] GetRank()
        {
            Return 5
        }
        static [String] GetTitle()
        {
            Return "Partition"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "[{0}/{1}]" -f $This.Name, $This.Size
        }
    }

    # // ________________________________________________________________
    # // | Specifically for single/multiple partitions on a given drive |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Partitions
    {
        [UInt32] $Count
        [Object] $Output
        Partitions()
        {
            $This.Output = @( )
        }
        Add([Object]$Partition)
        {
            $This.Output += $Partition
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ___________________________________________________________________________________________
    # // | Specifically for a single volume on a given drive, meant for injecting with a partition |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Volume
    {
        [String] $DriveID
        [String] $Description
        [String] $Filesystem
        [Object] $Partition
        [String] $VolumeName
        [String] $VolumeSerial
        Hidden [UInt64] $FreespaceBytes
        [String] $Freespace
        Hidden [UInt64] $UsedBytes
        [String] $Used
        Hidden [UInt64] $SizeBytes
        [String] $Size
        Volume([Object]$Drive)
        {
            $This.DriveID           = $Drive.Name
            $This.Description       = $Drive.Description
            $This.Filesystem        = $Drive.Filesystem
            $This.VolumeName        = $Drive.VolumeName
            $This.VolumeSerial      = $Drive.VolumeSerial
            $This.FreespaceBytes    = $Drive.Freespace
            $This.UsedBytes         = $Drive.Size-$Drive.Freespace
            $This.SizeBytes         = $Drive.Size
        }
        [String] ToString()
        {
            Return "[{0}{1}]" -f $This.DriveID, $This.Partition.Size
        }
    }

    # // _____________________________________________________________
    # // | Specifically for single/multiple volumes on a given drive |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Volumes
    {
        [UInt32] $Count
        [Object] $Output
        Volumes()
        {
            $This.Output = @( )
        }
        Add([Object]$Volume)
        {
            $This.Output += $Volume
            $This.Count   = $This.Output.Count
        }
        [String] ToString()
        {
            Return "({0}) {1}" -f $This.Count, (($This.Output | % ToString) -join ", ")
        }
    }

    # // ________________________________________
    # // | Extended information for hard drives |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Disk
    {
        Hidden [UInt32]       $Mode
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
        Disk([UInt32]$Rank,[Object]$Disk)
        {
            $This.Mode              = 0
            $This.Rank              = $Rank
            $This.Index             = $Disk.Index
            $This.Disk              = $Disk.DeviceId
            $This.Partition         = [Partitions]::New()
            $This.Volume            = [Volumes]::New()

            $MSFTDISK               = Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $Disk.Index
            If (!$MSFTDISK)
            {
                Throw "Unable to set the drive data"
            }

            $This.Model             = $MSFTDISK.Model
            $This.Serial            = $MSFTDISK.SerialNumber.TrimStart(" ")
            $This.PartitionStyle    = $MSFTDISK.PartitionStyle
            $This.ProvisioningType  = $MSFTDISK.ProvisioningType
            $This.OperationalStatus = $MSFTDISK.OperationalStatus
            $This.HealthStatus      = $MSFTDISK.HealthStatus
            $This.BusType           = $MSFTDISK.BusType
            $This.UniqueId          = $MSFTDISK.UniqueId
            $This.Location          = $MSFTDISK.Location
            
            $DiskPartition          = Get-CimInstance Win32_DiskPartition | ? DiskIndex -eq $Disk.Index | % { [Partition]$_ }
            If (!$DiskPartition)
            {
                Throw "Unable to retrieve disk partitions" 
            }

            ForEach ($Item in $DiskPartition)
            {
                $Item.Size          = $This.GetSize($Item.Size)
                $This.Partition.Add($Item)
            }

            $LogicalDisk            = Get-CimInstance Win32_LogicalDisk | ? DriveType -eq 3 | % { [Volume]::New($_) }
            If (!$LogicalDisk)
            {
                Throw "Unable to retrieve volume information"
            }

            ForEach ($Logical in Get-CimInstance Win32_LogicalDiskToPartition | ? { $_.Antecedent.DeviceID -in $DiskPartition.Name})
            {
                $Part = $DiskPartition | ? Name    -eq $Logical.Antecedent.DeviceID
                $Item = $LogicalDisk   | ? DriveID -eq $Logical.Dependent.DeviceID
                If ($Part -and $Item)
                {
                    $Item.Partition      = $Part
                    $Item.Freespace      = $This.GetSize($Item.FreespaceBytes)
                    $Item.Used           = $This.GetSize($Item.UsedBytes)
                    $Item.Size           = $This.GetSize($Item.SizeBytes)
                    $This.Volume.Add($Item)
                }
            }
        }
        Disk([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            $This.Mode = 1
            ForEach ($Pair in $Pairs)
            {
                If ($Pair.Name -ne "Mode")
                {
                    $This.$($Pair.Name) = $Pair.Value
                }
            }
        }
        LoadPartition([UInt32]$DiskIndex,[Object]$Partition,[Switch]$Flags)
        {
            If ($This.Index -match $DiskIndex)
            {
                If ($This.Partition.Count -eq 0)
                {
                    $This.Partition  = @( )
                }

                $This.Partition     += [Partition]::New($Partition,[Switch]$Flags)
            }
        }
        [String] GetSize([Int64]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -lt 1GB}
                {
                    "{0:n2} MB" -f ($Size/1MB)
                }
                {$_ -ge 1GB -and $_ -lt 1TB}
                {
                    "{0:n2} GB" -f ($Size/1GB)
                }
                {$_ -ge 1TB}
                {
                    "{0:n2} TB" -f ($Size/1TB)
                }
            })
        }
        [Void] WriteCheck()
        {
            If ($This.Mode -ne 0)
            {
                Throw "Invalid operation"
            }
        }
        [UInt32] GetRank()
        {
            Return $This.Rank
        }
        [String] GetTitle()
        {
            Return "Disk{0}" -f $This.Rank
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}({1})" -f $This.Model, $This.Rank
        }
    }
    
    # // _____________________________________________________________________________________
    # // | Drive/file formatting information (container), for the system this tool is run on |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Disks
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Disks()
        {
            $This.Name    = "Disk(s)"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetDisks()
        {
            $This.Output   = @( )
            $This.Count    = 0
            ForEach ($Disk in Get-CimInstance Win32_DiskDrive | ? MediaType -match Fixed)
            {
                $This.Output += [Disk]::New($This.Output.Count,$Disk)
                $This.Count  ++
            }
        }
        AddDisk([Object]$Disk,[Switch]$Flags)
        {
            $This.Output += [Disk]::New($This.Output.Count,$Disk,[Switch]$Flags)
            $This.Count  ++
        }
        RemoveDisk([UInt32]$Index)
        {
            $This.Output  = $This.Output | ? Index -ne $Index
            $This.Count  --
        }
        static [UInt32] GetRank()
        {
            Return 5
        }
        static [String] GetTitle()
        {
            Return "Disk(s)"
        }
        static [String] GetMode()
        {
            Return "Parent"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Count
        }
    }

    # // ________________________________________________
    # // | Connected/Online Network adapter information |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Network
    {
        Hidden [UInt32] $Mode
        Hidden [UInt32] $Rank
        [String] $Name
        [UInt32] $Index
        [String] $IPAddress
        [String] $SubnetMask
        [String] $Gateway
        [String] $DnsServer
        [String] $DhcpServer
        [String] $MacAddress
        Network([UInt32]$Rank,[Object]$If)
        {
            $This.Mode       = 0
            $This.Rank       = $Rank
            $This.Name       = $IF.Description
            $This.Index      = $IF.Index
            $This.IPAddress  = $IF.IPAddress             | ? {$_ -match "(\d+\.){3}\d+"}
            $This.SubnetMask = $IF.IPSubnet              | ? {$_ -match "(\d+\.){3}\d+"}
            $This.Gateway    = $IF.DefaultIPGateway      | ? {$_ -match "(\d+\.){3}\d+"}
            $This.DnsServer  = ($IF.DnsServerSearchOrder | ? {$_ -match "(\d+\.){3}\d+"}) -join ", "
            $This.DhcpServer = $IF.DhcpServer            | ? {$_ -match "(\d+\.){3}\d+"}
            $This.MacAddress = $IF.MacAddress
        }
        Network([UInt32]$Rank,[Object[]]$Pairs,[Switch]$Flags)
        {
            ForEach ($Pair in $Pairs)
            {
                If ($Pair.Name -ne "Mode")
                {
                    $This.$($Pair.Name) = $Pair.Value
                }
            }
            $This.Mode = 1
        }
        static [UInt32] GetRank()
        {
            Return 6
        }
        static [String] GetTitle()
        {
            Return "Network(s)"
        }
        static [String] GetMode()
        {
            Return "Child"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ____________________________________
    # // | Network adapter container object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Networks
    {
        [Object] $Name
        [Object] $Count
        [Object] $Output
        Networks()
        {
            $This.Name    = "Network(s)"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetNetworks()
        {
            $This.Output   = @( )
            $This.Count    = 0
            ForEach ($Network in Get-CimInstance Win32_NetworkAdapterConfiguration | ? IPEnabled | ? DefaultIPGateway)
            {
                $This.Output += [Network]::New($This.Output.Count,$Network)
                $This.Count  ++
            }
        }
        AddNetwork([Object]$Network,[Switch]$Flags)
        {
            $This.Output += [Network]::New($This.Output.Count,$Network,[Switch]$Flags)
            $This.Count  ++
        }
        static [UInt32] GetRank()
        {
            Return 6
        }
        static [String] GetTitle()
        {
            Return "Network(s)"
        }
        static [String] GetMode()
        {
            Return "Parent"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Count
        }
    }

    # // ___________________________
    # // | Event log provider item |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class LogProvider
    {
        [String] $Name
        [String] $Value
        LogProvider([String]$Name,[String]$Value)
        {
            $This.Name        = $Name
            $This.Value       = $Value
        }
        LogProvider([Object]$Line)
        {
            $This.Name        = $Line.Split(" ")[0]
            $This.Value       = $Line.Replace($This.Name,"")
        }
        static [UInt32] GetRank()
        {
            Return 7
        }
        static [String] GetTitle()
        {
            Return "Log Providers"
        }
        static [String] GetMode()
        {
            Return "Array"
        }
        [String] ToString()
        {
            Return "{0} {1}" -f $This.Name, $This.Value
        }
    }

    # // ________________________________
    # // | Event log provider container |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class LogProviders
    {
        [String] $Name
        [UInt32] $Count
        [Object] $Output
        LogProviders()
        {
            $This.Name    = "Log Providers"
            $This.Count   = 0
            $This.Output  = @( )
        }
        GetLogProviders()
        {
            $Logs        = Get-WinEvent -ListLog * | % Logname | Select-Object -Unique | Sort-Object
            $Depth       = ([String]$Logs.Count).Length
            ForEach ($X in 0..($Logs.Count-1))
            {
                $This.Output += [LogProvider]::New(("Provider{0:d$Depth}" -f $X),$Logs[$X])
                $This.Count  ++
            }
        }
        AddLogProviders([Object[]]$Logs)
        {
            $Depth       = ([String]$Logs.Count).Length
            ForEach ($X in 0..($Logs.Count-1))
            {
                $This.Output += [LogProvider]::New($Logs[$X].Name,$Logs[$X].Value)
                $This.Count  ++ 
            }
        }
        static [UInt32] GetRank()
        {
            Return 7
        }
        static [String] GetTitle()
        {
            Return "Log Providers"
        }
        static [String] GetMode()
        {
            Return "Clone"
        }
        [Object] GetOutput()
        {
            Return [PropertySet]::New($This)
        }
        [String] ToString()
        {
            Return "{0}[{1}]" -f $This.Name, $This.Count
        }
    }

    # // ___________________________________________________________
    # // | Parses the outputfile back into the system object above |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ParseSystem
    {
        [Object] $Snapshot
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object] $ComputerSystem
        [Object] $Processor
        [Object] $Disk
        [Object] $Network
        [Object] $LogProviders
        ParseSystem()
        {
            $This.Processor    = [Processors]::New()
            $This.Disk         = [Disks]::New()
            $This.Network      = [Networks]::New()
            $This.LogProviders = [LogProviders]::New()
        }
        Add([Object]$Section)
        {
            $Flags = [Switch]$False
            Switch ($Section.Rank)
            {
                0 { $This.Snapshot        = [Snapshot]$Section.Output }
                1 { $This.BiosInformation = [BiosInformation]$Section.Output }
                2 { $This.OperatingSystem = [OperatingSystem]$Section.Output }
                3 { $This.ComputerSystem  = [ComputerSystem]$Section.Output }
                4 { $This.Processor.AddProcessor($Section.Output,[Switch]$Flags) }
                5 { $This.Disk.AddDisk($Section.Output,[Switch]$Flags) }
                6 { $This.Network.AddNetwork($Section.Output,[Switch]$Flags) }
                7 { $This.LogProviders.AddLogProviders($Section.Output) }
            }
        }
        [UInt32] Label([String]$Label)
        {
            Return $Label -Replace "\D+",""
        }
    }

    # // ____________________________________________________________
    # // | Parses keys from the log and sends them to system object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ParseSection
    {
        [UInt32] $Rank
        [Object] $Title
        [Object] $Output
        ParseSection([UInt32]$Rank,[String]$Title)
        {
            $This.Rank    = $Rank
            $This.Title   = $Title
            $This.Output  = @( )
        }
        Add([Object[]]$Content)
        {
            ForEach ($X in 0..($Content.Count-1))
            {
                $Content[$X] -Match "(\w+|\d+)\s+(.+)"
                $This.Output  += [PropertyItem]::New($X,$Matches[1],$Matches[2])
            }
        }
        Modify([Object[]]$Content,[String]$Label)
        {
            ForEach ($X in 0..($Content.Count-1))
            {
                $Content[$X] -Match "(\w+|\d+)\s+(.+)"
                $This.Output  += [PropertyItem]::New($Matches[1].Replace($Label,""),$Matches[2])
            }
        }
        Clear()
        {
            $This.Output = @( )
        }
    }

    # // _________________________________________________
    # // | Parses each individual line of the outputfile |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ParseLine
    {
        [UInt32] $Index
        [Int32]   $Rank
        [Int32]   $Type
        [String]  $Line
        ParseLine([UInt32]$Index,[String]$Line)
        {
            $This.Index = $Index
            $This.Line  = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    # // __________________________________________________________________
    # // | Basically does a lot of math to reproduce a master output file |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ParseTable
    {
        [Object]        $Content = @( )
        [Object]          $Total
        [Object]           $Body = [ParseSystem]::New()
        ParseTable([String]$Path)
        {
            $In           = (Get-Content $Path).TrimEnd(" ")
            $This.Insert($In)
        }
        ParseTable([Switch]$Flags,[Object]$InputObject)
        {
            $In           = ($InputObject -Split "`n").TrimEnd(" ")
            $This.Insert($In)
        }
        Insert([Object]$In)
        {
            $This.Total   = $In.Count
            $X            = 0
            $C            = -1
            Do
            {
                $Line     = $This.Line($In[$X].TrimEnd(" "))
                Switch -Regex ($Line)
                {
                    "(^\s{0}$|\-{20,})"
                    {
                        $Line.Type  = 0
                    }
                    "(^Snapshot$|^Bios Information$|^Operating System$|^Computer System$|^Processor\(s\)\s+\d+$|^Disk\(s\)\s+\d+$|^Network\(s\)\s+\d+$|^Log Providers\s+\d+$)"
                    {
                        $C ++
                        $Line.Type  = 1
                        $This.Content[$X-1].Rank = $C
                        Continue
                    }
                    "^(\w+)(\d+)\s{0}\b$"
                    {
                        $Line.Type  = 2
                        Continue
                    }
                    "^(\w+|\d+)+.+$"
                    {
                        $Line.Type  = 3
                    }
                }
                $Line.Rank          = $C
                $This.Content      += $Line
                $X                 ++
            }
            Until ($X -eq $This.Total)
            $This.ParseSections()
        }
        [Object] Line([String]$Line)
        {
            Return [ParseLine]::New($This.Content.Count,$Line)
        }
        ParseSections()
        {
            $Slot                   = $Null
            $Title                  = $Null
            $Label                  = $Null
            $List                   = $Null
            $Section                = $Null
            $Array                  = $Null
            ForEach ($Rank in 0..7)
            {
                $Slot               = $This.Content | ? Rank -eq $Rank
                $Title              = $Slot    | ? Type -eq 1
                $Label              = $Slot    | ? Type -eq 2
                $List               = $Slot    | ? Type -eq 3
                $Section            = [ParseSection]::New($Rank,$Title.Line)
                Switch ($Label.Count -gt 1)
                {
                    $False
                    {
                        $Array      = $List[0..($List.Count-1)].Line
                        $Section.Add($Array)
                        $This.Body.Add($Section)
                        $Rank ++
                    }
                    $True
                    {
                        If ($Title.Line -match "Disk\(s\)")
                        {
                            $Disk       = $Label | ? Line -match "Disk"
                            $DiskIndex  = [UInt32]($Disk.Line -Replace "\D+","")
                            If ($Disk.Count -eq 1)
                            {
                                $I         = $Label.Index + $Slot[-1].Index
                                $X         = 0
                                Do
                                {
                                    $Array = $This.Content[($I[$X]+1)..($I[$X+1]-1)].Line
                                    Switch -Regex ($Label[$X].Line)
                                    {
                                        Disk
                                        {
                                            $Section.Add($Array)
                                            $This.Body.Add($Section)
                                        }
                                        Partition
                                        {
                                            $Section.Modify($Array,$Label[$X].Line)
                                            $This.Body.Disk.Output[$DiskIndex].LoadPartition($DiskIndex,$Section.Output,[Switch]$False)
                                        }
                                    }
                                    $Section.Clear()
                                    $X ++
                                }
                                Until ($X -eq $I.Count-1)

                            }
                        }
                        Else
                        {
                            $I = $Label.Index + ($Slot | ? Type -eq 3)[-1].Index
                            $X = 0
                            Do
                            {
                                $Array = $This.Content[($I[$X]+1)..($I[$X+1]-1)] | ? Type -eq 3 | % Line
                                $Section.Add($Array)
                                $This.Body.Add($Section)
                                $X ++
                            }
                            Until ($X -eq $I.Count-1)
                        }
                        $Rank ++
                    }
                }
            }
        }
    }

    # // _____________________________________________________
    # // | System snapshot, the primary focus of the utility |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class System
    {
        Hidden [UInt32] $Mode
        [Object] $Snapshot
        [Object] $BiosInformation
        [Object] $OperatingSystem
        [Object] $ComputerSystem
        [Object] $Processor
        [Object] $Disk
        [Object] $Network
        [Object] $LogProviders
        Hidden [Object] $Output
        System()
        {
            $This.Mode             = 0
            $This.Snapshot         = [Snapshot]::New()
            $This.BiosInformation  = [BiosInformation]::New()
            $This.OperatingSystem  = [OperatingSystem]::New() 
            $This.ComputerSystem   = [ComputerSystem]::New()
            $This.Processor        = [Processors]::New()
            $This.Processor.GetProcessors()
            $This.Disk             = [Disks]::New()
            $This.Disk.GetDisks()
            $This.Network          = [Networks]::New()
            $This.Network.GetNetworks()
            $This.LogProviders     = [LogProviders]::New()
            $This.LogProviders.GetLogProviders()

        }
        System([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
            
            $Body                 = [ParseTable]::New([String]$Path).Body
            If (!$Body)
            {
                Throw "Invalid file"
            }

            $This.Insert($Body)
        }
        System([Switch]$Flags,[Object]$InputObject)
        {
            $Body                  = [ParseTable]::New($Flags,$InputObject).Body

            $This.Insert($Body)
        }
        Insert([Object]$Body)
        {
            $This.Snapshot         = $Body.Snapshot
            $This.BiosInformation  = $Body.BiosInformation
            $This.OperatingSystem  = $Body.OperatingSystem
            $This.ComputerSystem   = $Body.ComputerSystem
            $This.Processor        = $Body.Processor
            $This.Disk             = $Body.Disk
            $This.Network          = $Body.Network
            $This.LogProviders     = $Body.LogProviders
        }
        [Object[]] GetOutput()
        {
            If ($This.Snapshot.Complete -eq 0)
            {
                $This.Snapshot.Elapsed = [String][Timespan]([DateTime]::Now-[DateTime]$This.Snapshot.Start)
            }

            $This.Output = [PropertyControl]::New()
            $This.Output.Add($This.Snapshot)
            $This.Output.Add($This.BiosInformation)
            $This.Output.Add($This.OperatingSystem)
            $This.Output.Add($This.ComputerSystem)
            $This.Output.Add($This.Processor)
            $This.Output.Add($This.Disk)
            $This.Output.Add($This.Network)
            $This.Output.Add($This.LogProviders)
        
            Return $This.Output.GetOutput()
        }
        [Void] WriteOutput([String]$Path,[Bool]$Overwrite=$False)
        {
            $Parent = $Path | Split-Path -Parent
            If (!(Test-Path $Parent))
            {
                Throw "Invalid output path"
            }
            ElseIf ($Overwrite -eq $False -and (Test-Path $Path))
            {
                Throw "File already exists"
            }
            Else
            {
                $Value = $This.GetOutput()
                Set-Content -Path $Path -Value $Value -Verbose -Force
            }
        }
        [String] ToString()
        {
            Return "({0}, {1} | {2}, {3} {4}-{5})" -f $This.Snapshot.ComputerName, $This.ComputerSystem.Manufacturer, $This.ComputerSystem.Model, $This.OperatingSystem.Caption
            $This.OperatingSystem.Version, $This.OperatingSystem.Build
        }
    }

    Switch ($psCmdLet.ParameterSetName)
    {
        0 { [System]::New() } 1 { [System]::New([String]$Path) } 2 { [System]::New([Switch]$Flags,[Object]$InputObject) }
    }
}
