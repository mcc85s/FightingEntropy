<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-05-24 17:40:05                                                                  //
 \\==================================================================================================// 

   FileName   : Get-FEModule.ps1
   Solution   : [FightingEntropy()][2023.4.0]
   Purpose    : Loads the FightingEntropy module
   Author     : Michael C. Cook Sr.
   Contact    : @mcc85s
   Primary    : @mcc85s
   Created    : 2023-04-06
   Modified   : 2023-05-24
   Demo       : N/A
   Version    : 0.0.0 - () - Finalized functional version 1
   TODO       : Have the hash values restore themselves from registry
                Now includes the console logger by default

.Example
#>
Function Get-FEModule
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
        [Parameter(ParameterSetName=0)][UInt32]      $Mode = 0,
        [Parameter(ParameterSetName=1)][Switch]   $Control ,
        [Parameter(ParameterSetName=2)][Switch] $Functions ,  
        [Parameter(ParameterSetName=3)][Switch]  $Graphics )

    # // =======================================================
    # // | Used to track console logging, similar to Stopwatch |
    # // =======================================================

    Class ConsoleTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        ConsoleTime([String]$Name)
        {
            $This.Name = $Name
            $This.Time = [DateTime]::MinValue
            $This.Set  = 0
        }
        Toggle()
        {
            $This.Time = [DateTime]::Now
            $This.Set  = 1
        }
        [String] ToString()
        {
            Return $This.Time.ToString()
        }
    }

    # // ========================================
    # // | Single object that displays a status |
    # // ========================================

    Class ConsoleEntry
    {
        [UInt32]         $Index
        [String]       $Elapsed
        [Int32]          $State
        [String]        $Status
        Hidden [String] $String
        ConsoleEntry([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
        {
            $This.Index   = $Index
            $This.Elapsed = $Time
            $This.State   = $State
            $This.Status  = $Status
            $This.String  = $This.ToString()
        }
        [String] ToString()
        {
            Return "[{0}] (State: {1}/Status: {2})" -f $This.Elapsed, $This.State, $This.Status
        }
    }

    # // =========================================================================
    # // | A collection of status objects, uses itself to create/update messages |
    # // =========================================================================

    Class ConsoleController
    {
        [Object]  $Start
        [Object]    $End
        [String]   $Span
        [Object] $Status
        [Object] $Output
        ConsoleController()
        {
            $This.Reset()
        }
        [String] Elapsed()
        {
            Return @(Switch ($This.End.Set)
            {
                0 { [Timespan]([DateTime]::Now-$This.Start.Time) }
                1 { [Timespan]($This.End.Time-$This.Start.Time) }
            })         
        }
        [Object] ConsoleTime([String]$Name)
        {
            Return [ConsoleTime]::New($Name)
        }
        [Object] ConsoleEntry([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
        {
            Return [ConsoleEntry]::New($Index,$Time,$State,$Status)
        }
        [Object] Collection()
        {
            Return [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        [Void] SetStatus()
        {
            $This.Status = $This.ConsoleEntry($This.Output.Count,
                                              $This.Elapsed(),
                                              $This.Status.State,
                                              $This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = $This.ConsoleEntry($This.Output.Count,
                                              $This.Elapsed(),
                                              $State,
                                              $Status)
        }
        Initialize()
        {
            If ($This.Start.Set -eq 1)
            {
                $This.Update(-1,"Start [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.Start.Toggle()
            $This.Update(0,"Running [~] ($($This.Start))")
        }
        Finalize()
        {
            If ($This.End.Set -eq 1)
            {
                $This.Update(-1,"End [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.End.Toggle()
            $This.Span = $This.Elapsed()
            $This.Update(100,"Complete [+] ($($This.End)), Total: ($($This.Span))")
        }
        Reset()
        {
            $This.Start  = $This.ConsoleTime("Start")
            $This.End    = $This.ConsoleTime("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = $This.Collection()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.SetStatus($State,$Status)
            $This.Write()
            Return $This.Last()
        }
        [Object] Current()
        {
            $This.Update($This.Status.State,$This.Status.Status)
            Return $This.Last()
        }
        [Object] Last()
        {
            Return $This.Output[$This.Output.Count-1]
        }
        [Object] DumpConsole()
        {
            Return $This.Output | % ToString
        }
        [String] ToString()
        {
            If (!$This.Span)
            {
                Return $This.Elapsed()
            }
            Else
            {
                Return $This.Span
            }
        }
    }

    # // =====================================================================
    # // | This is a 1x[track] x 4[char] chunk of information for Write-Host |
    # // =====================================================================

    Class ThemeBlock
    {
        [UInt32]   $Index
        [Object]  $String
        [UInt32]    $Fore
        [UInt32]    $Back
        [UInt32]    $Last
        ThemeBlock([Int32]$Index,[String]$String,[Int32]$Fore,[Int32]$Back)
        {
            $This.Index  = $Index
            $This.String = $String
            $This.Fore   = $Fore
            $This.Back   = $Back
            $This.Last   = 1
        }
        Write([UInt32]$0,[UInt32]$1,[UInt32]$2,[UInt32]$3)
        {
            $Splat = @{ 

                Object          = $This.String
                ForegroundColor = @($0,$1,$2,$3)[$This.Fore]
                BackgroundColor = $This.Back
                NoNewLine       = $This.Last
            }

            Write-Host @Splat
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ThemeBlock>"
        }
    }

    # // ===============================================
    # // | Represents a 1x[track] in a stack of tracks |
    # // ===============================================

    Class ThemeTrack
    {
        [UInt32] $Index
        [Object] $Content
        ThemeTrack([UInt32]$Index,[Object]$Track)
        {
            $This.Index   = $Index
            $This.Content = $Track
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ThemeTrack>"
        }
    }

    # // =============================================
    # // | Generates an actionable write-host object |
    # // =============================================

    Class ThemeStack
    {
        Hidden [Object]  $Face
        Hidden [Object] $Track
        ThemeStack([UInt32]$Slot,[String]$Message)
        {
            $This.Main($Message)
            $Object = $This.Palette($Slot)
            $This.Write($Object)
        }
        ThemeStack([String]$Message)
        {
            $This.Main($Message)
            $Object = $This.Palette(0)
            $This.Write($Object)
        }
        Main([String]$Message)
        {
            $This.Face = $This.Mask()
            $This.Reset()
            $This.Insert($Message)
        }
        [UInt32[]] Palette([UInt32]$Slot)
        {
            If ($Slot -gt 35)
            {
                Throw "Invalid entry"
            }

            Return @( Switch ($Slot) 
            {  
                00 {10,12,15,00} 01 {12,04,15,00} 02 {10,02,15,00} # Default, R*/Error,   G*/Success
                03 {01,09,15,00} 04 {03,11,15,00} 05 {13,05,15,00} # B*/Info, C*/Verbose, M*/Feminine
                06 {14,06,15,00} 07 {00,08,15,00} 08 {07,15,15,00} # Y*/Warn, K*/Evil,    W*/Host
                09 {04,12,15,00} 10 {12,12,15,00} 11 {04,04,15,00} # R!,      R+,         R-
                12 {02,10,15,00} 13 {10,10,15,00} 14 {02,02,15,00} # G!,      G+,         G-
                15 {09,01,15,00} 16 {09,09,15,00} 17 {01,01,15,00} # B!,      B+,         B-
                18 {11,03,15,00} 19 {11,11,15,00} 20 {03,03,15,00} # C!,      C+,         C-
                21 {05,13,15,00} 22 {13,13,15,00} 23 {05,05,15,00} # M!,      M+,         M-
                24 {06,14,15,00} 25 {14,14,15,00} 26 {06,06,15,00} # Y!,      Y+,         Y-
                27 {08,00,15,00} 28 {08,08,15,00} 29 {00,00,15,00} # K!,      K+,         K-
                30 {15,07,15,00} 31 {15,15,15,00} 32 {07,07,15,00} # W!,      W+,         W-
                33 {11,06,15,00} 34 {06,11,15,00} 35 {11,12,15,00} # Steel*,  Steel!,     C+R+
            })
        }
        [Object] Mask()
        {
            Return ("20202020 5F5F5F5F AFAFAFAF 2020202F 5C202020 2020205C 2F202020 5C5F5F2F "+
            "2FAFAF5C 2FAFAFAF AFAFAF5C 5C5F5F5F 5F5F5F2F 205F5F5F" -Split " ") | % { $This.Convert($_) }
        }
        [String] Convert([String]$Line)
        {
            Return [Char[]]@(0,2,4,6 | % { "0x$($Line.Substring($_,2))" | IEX }) -join ''
        }
        Add([String]$Mask,[String]$Fore)
        {
            # // ____________________________
            # // | Expands the mask strings |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Object        = Invoke-Expression $Mask | % { $This.Face[$_] }
            $FG            = Invoke-Expression $Fore
            $BG            = @(0)*30

            # // ____________________________
            # // | Generates a track object |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Hash          = @{ }
            ForEach ($X in 0..($Object.Count-1))
            {
                $Item      = [ThemeBlock]::New($X,$Object[$X],$FG[$X],$BG[$X])
                If ($X -eq $Object.Count-1)
                {
                    $Item.Last = 0
                }
                $Hash.Add($Hash.Count,$Item)
            }
            $This.Track  += [ThemeTrack]::New($This.Track.Count,$Hash[0..($Hash.Count-1)])
        }
        [Void] Reset()
        {
            $This.Track = @( )

            # // ____________________________
            # // | Generates default tracks |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Add("0,1,0+@(1)*25+0,0","@(0)*30")
            $This.Add("3,8,7,9+@(2)*23+10,11,0","0,1,0+@(1)*25+0,0")
            $This.Add("5,7,9,13+@(0)*23+12,8,4","0,1,1+@(2)*24+1,1,0")
            $This.Add("0,10,11+@(1)*23+12+8,7,6","0,0+@(1)*25+0,1,0")
            $This.Add("0,0+@(2)*25+0,2,0","@(0)*30")
        }
        Insert([String]$String)
        {
            $This.Reset()
            $String = " $String"
            Switch ($String.Length)
            {
                {$_ -lt 84}
                {
                    $String += (@(" ") * (84 - ($String.Length+1)) -join '' )
                }
                {$_ -ge 84}
                {
                    $String  = $String.Substring(0,84) + "..."
                }
            }
            $Array = [Char[]]$String
            $Hash  = @{ }
            $Block = ""
            ForEach ($X in 0..($Array.Count-1))
            {
                If ($X % 4 -eq 0 -and $Block -ne "")
                {
                    $Hash.Add($Hash.Count,$Block)
                    $Block = ""
                }
                $Block += $Array[$X]
            }
            
            ForEach ($X in 0..($Hash.Count-1))
            {
                $This.Track[2].Content[$X+3].String = $Hash[$X]
            }
        }
        [Void] Write([UInt32[]]$Palette)
        {
            $0,$1,$2,$3 = $Palette
            ForEach ($Track in $This.Track)
            {
                ForEach ($Item in $Track.Content)
                {
                   $Item.Write($0,$1,$2,$3)
                }
            }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ThemeStack>"
        }
    }
    
    # // ===================================================
    # // | Property object which includes source and index |
    # // ===================================================

    Class OSProperty
    {
        [String] $Source
        Hidden [UInt32] $Index
        [String] $Name
        [Object] $Value
        OSProperty([String]$Source,[UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Source = $Source
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Value  = $Value
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OSProperty>"
        }
    }

    # // ==========================================================
    # // | Container object for indexed OS (property/value) pairs |
    # // ==========================================================
    
    Class OSPropertySet
    {
        Hidden [UInt32] $Index
        [String] $Source
        [Object] $Property
        OSPropertySet([UInt32]$Index,[String]$Source)
        {
            $This.Index     = $Index
            $This.Source    = $Source
            $This.Property  = @( )
        }
        Add([String]$Name,[Object]$Value)
        {
            $This.Property += [OSProperty]::New($This.Source,$This.Property.Count,$Name,$Value)
        }
        [String] ToString()
        {
            $D = ([String]$This.Property.Count).Length
            Return "({0:d$D}) <FightingEntropy.Module.OSPropertySet[{1}]>" -f $This.Property.Count, $This.Source
        }
    }

    # // =====================================================================================================
    # // | Collects various details about the operating system specifically for cross-platform compatibility |
    # // =====================================================================================================

    Class OS
    {
        Hidden [String] $Name
        [Object]     $Caption
        [Object]    $Platform
        [Object]   $PSVersion
        [Object]        $Type
        [Object]      $Output
        OS()
        {
            $This.Name   = "Operating System"
            $This.Output = @( )

            # // _______________
            # // | Environment |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Environment")

            Get-ChildItem Env:              | % { $This.Add(0,$_.Key,$_.Value) }
            
            # // ____________
            # // | Variable |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Variable")

            Get-ChildItem Variable:         | % { $This.Add(1,$_.Name,$_.Value) }

            # // ________
            # // | Host |
            # // ¯¯¯¯¯¯¯¯

            $This.AddPropertySet("Host")

            (Get-Host).PSObject.Properties  | % { $This.Add(2,$_.Name,$_.Value) }
            
            # // ______________
            # // | PowerShell |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.AddPropertySet("PowerShell")

            (Get-Variable PSVersionTable | % Value).GetEnumerator() | % { $This.Add(3,$_.Name,$_.Value) }

            If ($This.Tx("PowerShell","PSedition") -eq "Desktop")
            {
                Get-CimInstance Win32_OperatingSystem | % { $This.Add(3,"OS","Microsoft Windows $($_.Version)") }
                $This.Add(3,"Platform","Win32NT")
            }

            # // ____________________________________
            # // | Assign hashtable to output array |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Caption   = $This.Tx("PowerShell","OS")
            $This.Platform  = $This.Tx("PowerShell","Platform")
            $This.PSVersion = $This.Tx("PowerShell","PSVersion")
            $This.Type      = $This.GetOSType()
        }
        [Object] Tx([String]$Source,[String]$Name)
        {
            Return $This.Output | ? Source -eq $Source | % Property | ? Name -eq $Name | % Value
        }
        Add([UInt32]$Index,[String]$Name,[Object]$Value)
        {
            $This.Output[$Index].Add($Name,$Value)
        }
        AddPropertySet([String]$Name)
        {
            $This.Output += [OSPropertySet]::New($This.Output.Count,$Name)
        }
        [String] GetWinCaption()
        {
            Return "[wmiclass]'Win32_OperatingSystem' | % GetInstances | % Caption"
        }
        [String] GetWinType()
        {
            Return @(Switch -Regex (Invoke-Expression $This.GetWinCaption())
            {
                "Windows (10|11)" { "Win32_Client" } "Windows Server" { "Win32_Server" }
            })
        }
        [String] GetOSType()
        {
            Return @( If ($This.Version.Major -gt 5)
            {
                If (Get-Item Variable:\IsLinux | % Value)
                {
                    (hostnamectl | ? { $_ -match "Operating System" }).Split(":")[1].TrimStart(" ")
                }

                Else
                {
                    $This.GetWinType()
                }
            }

            Else
            {
                $This.GetWinType()
            })
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.OS>"
        }
    }

    # // ============================================================
    # // | Meant to determine longest file name and provide spacing |
    # // ============================================================

    Class ManifestListItem
    {
        [UInt32]  $Index
        [String] $Source
        [String]   $Name
        [String]   $Hash
        ManifestListItem([UInt32]$Index,[String]$Source,[String]$Name,[String]$Hash)
        {
            $This.Index  = $Index
            $This.Source = $Source
            $This.Name   = $Name
            $This.Hash   = $Hash
        }
    }

    # // ==============================================================
    # // | Manifest file -> filesystem object (collection/validation) |
    # // ==============================================================

    Class ManifestFile
    {
        Hidden [UInt32]    $Index
        Hidden [UInt32]     $Mode
        [String]            $Type
        [String]            $Name
        [String]            $Hash
        [UInt32]          $Exists
        Hidden [String] $Fullname
        Hidden [String]   $Source
        Hidden [UInt32]    $Match
        Hidden [Object]  $Content
        ManifestFile([Object]$Folder,[String]$Name,[String]$Hash,[String]$Source)
        {
            $This.Index    = $Folder.Item.Count
            $This.Mode     = 0
            $This.Type     = $Folder.Type
            $This.Name     = $Name
            $This.Fullname = "{0}\$Name" -f $Folder.Fullname
            $This.Source   = "{0}/{1}/{2}?raw=true" -f $Source, $Folder.Name, $Name
            $This.Hash     = $Hash
            $This.TestPath()
        }
        TestPath()
        {
            $This.Exists   = [System.IO.File]::Exists($This.Fullname)
        }
        [Void] Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                [System.IO.File]::Create($This.Fullname).Dispose()
                $This.Exists = 1
            }
        }
        [Void] Remove()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                [System.IO.File]::Delete($This.Fullname)
                $This.Exists = 0
            }
        }
        Download()
        {
            Try
            {
                $xContent = Invoke-WebRequest $This.Source -UseBasicParsing | % Content

                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    $This.Content = $xContent
                }
                ElseIf ($This.Name -match "\.+(txt|xml|cs)")
                {
                    $Array = $xContent -Split "`n"
                    $Ct    = $Array.Count
                    Do
                    {
                        If ($Array[$Ct] -notmatch "\w")
                        {
                            $Ct --
                        }
                    }
                    Until ($Array[$Ct] -match "\w")

                    $This.Content = $Array[0..($Ct)] -join "`n"
                }
                Else
                {
                    $This.Content = $xContent
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error occurred"
            }
        }
        Write()
        {
            If (!$This.Content)
            {
                Throw "Exception [!] Content not assigned, cannot (write/set) content."
            }

            If (!$This.Exists)
            {
                $This.Create()
            }

            Try
            {
                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    [System.IO.File]::WriteAllBytes($This.Fullname,[Byte[]]$This.Content)
                }
                ElseIf ($This.Name -match "\.+(txt|xml|cs)")
                {
                    [System.IO.File]::WriteAllText($This.Fullname,$This.Content)
                }
                Else
                {
                    [System.IO.File]::WriteAllText($This.Fullname,
                                                   $This.Content,
                                                   [System.Text.UTF8Encoding]$False)
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error has occurred"
            }
        }
        GetContent()
        {
            If (!$This.Exists)
            {
                Throw "Exception [!] File does not exist, it needs to be created first."
            }

            Try
            {
                If ($This.Name -match "\.+(jpg|jpeg|png|bmp|ico)")
                {
                    $This.Content = [System.IO.File]::ReadAllBytes($This.Fullname)
                }
                ElseIf ($This.Name -match "\.+(xml|txt|cs)")
                {
                    $This.Content = [System.IO.File]::ReadAllText($This.Fullname,
                                                                  [System.Text.UTF8Encoding]$False)
                }
                Else
                {
                    $This.Content = [System.IO.File]::ReadAllLines($This.Fullname,
                                                                   [System.Text.UTF8Encoding]$False)
                }
            }
            Catch
            {
                Throw "Exception [!] An unspecified error has occurred"
            }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ManifestFile>"
        }
    }

    # // ========================================
    # // | Manifest folder -> filesystem object |
    # // ========================================

    Class ManifestFolder
    {
        Hidden [UInt32]    $Index
        Hidden [UInt32]     $Mode
        [String]            $Type
        [String]            $Name
        [String]        $Fullname
        [UInt32]          $Exists
        Hidden [Object]     $Item
        Hidden [String]   $Source
        ManifestFolder([UInt32]$Index,[String]$Type,[String]$Parent,[String]$Name)
        {
            $This.Index     = $Index
            $This.Mode      = 1
            $This.Type      = $Type
            $This.Name      = $Name
            $This.Fullname  = "$Parent\$Name"
            $This.Item      = @( )
            $This.TestPath()
        }
        Add([Object]$File)
        {
            If ($File.Exists)
            {
                $Hash       = Get-FileHash $File.Fullname | % Hash
                If ($Hash -eq $File.Hash)
                {
                    $File.Match = 1
                }
                If ($Hash -ne $File.Hash)
                {
                    $File.Match = 0
                }
            }

            $This.Item     += $File
        }
        [Object] Get([String]$Name)
        {
            Return $This.Output | ? Name -eq $Name
        }
        TestPath()
        {
            If (!$This.Fullname)
            {
                Throw "Exception [!] Resource path not set"
            }

            $This.Exists = [System.IO.Directory]::Exists($This.Fullname)
        }
        [Void] Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                [System.IO.Directory]::CreateDirectory($This.Fullname)
                $This.Exists = 1
            }
        }
        [Void] Remove()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                [System.IO.Directory]::Delete($This.Fullname)
                $This.Exists = 0
            }
        }
        [String] ToString()
        {
            Return "({0}) <FightingEntropy.Module.ManifestFolder[{1}]>" -f $This.Item.Count, $This.Name
        }
    }

    # // =====================================================================
    # // | File manifest container, laid out for hash (insertion+validation) |
    # // =====================================================================

    Class ManifestController
    {
        Hidden [String]    $Name
        [String]         $Source
        [String]       $Resource
        Hidden [UInt32]   $Depth
        Hidden [UInt32]   $Total
        [Object]         $Output
        ManifestController([String]$Source,[String]$Resource)
        {
            $This.Name     = "Module Manifest"
            $This.Source   = $Source
            $This.Resource = $Resource
            $This.Output   = @( )
        }
        [Object] Get([String]$Name)
        {
            Return $This.Output | ? Name -eq $Name | % Output
        }
        [Object[]] Refresh()
        {
            $Out = @( )
            ForEach ($List in $This.Output)
            {
                $List.TestPath()
                $Out += $List
                If ($List.Exists)
                {
                    ForEach ($Item in $List.Item)
                    {
                        $Item.TestPath()
                        $Out += $Item
                    }    
                }
            }

            Return $Out
        }
        [Object] Files([UInt32]$Index)
        {
            Return $This.Output[$Index] | % Item
        }
        [Object] Full()
        {
            $D = "Index Type Name Hash Exists Fullname Source Match" -Split " "
            Return $This.Output | % Item | Select-Object $D
        }
        Validate()
        {
            ForEach ($Folder in $This.Output)
            {
                $Folder.Exists = [System.IO.Directory]::Exists($Folder.Fullname)
                If ($Folder.Exists)
                {
                    ForEach ($File in $Folder.Item)
                    {
                        $File.Exists = [System.IO.File]::Exists($File.Fullname)
                        If ($File.Exists)
                        {
                            $File.GetContent()
                        }
                    }
                }
            }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.ManifestController>"
        }
    }

    # // ===================================
    # // | Template for registry injection |
    # // ===================================

    Class RegistryTemplate
    {
        [String]      $Source
        [String]        $Name
        [String] $Description
        [String]      $Author
        [String]     $Company
        [String]   $Copyright
        [Guid]          $Guid
        [DateTime]      $Date
        [String]     $Version
        [String]     $Caption
        [String]    $Platform
        [String]        $Type
        [String]    $Registry
        [String]    $Resource
        [String]      $Module
        [String]        $File
        [String]    $Manifest
        RegistryTemplate([Object]$Module)
        {
            $This.Source      = $Module.Source
            $This.Name        = $Module.Name
            $This.Description = $Module.Description
            $This.Author      = $Module.Author
            $This.Company     = $Module.Company
            $This.Copyright   = $Module.Copyright
            $This.Guid        = $Module.Guid
            $This.Date        = $Module.Date
            $This.Version     = $Module.Version
            $This.Caption     = $Module.OS.Caption
            $This.Platform    = $Module.OS.Platform
            $This.Type        = $Module.OS.Type
            $This.Registry    = $Module.Root.Registry
            $This.Resource    = $Module.Root.Resource
            $This.Module      = $Module.Root.Module
            $This.File        = $Module.Root.File
            $This.Manifest    = $Module.Root.Manifest
        }
    }

    # // ==================================================
    # // | Represents individual paths to the module root |
    # // ==================================================

    Class RootProperty
    {
        Hidden [UInt32] $Index
        [String]         $Type
        [String]         $Name
        [String]     $Fullname
        [UInt32]       $Exists
        Hidden [String]  $Path
        RootProperty([UInt32]$Index,[String]$Name,[UInt32]$Type,[String]$Fullname)
        {
            $This.Index    = $Index
            $This.Type     = Switch ($Type) { 0 { "Directory" } 1 { "File" } }
            $This.Name     = $Name
            $This.Fullname = $Fullname
            $This.Path     = $Fullname
            $This.TestPath()
        }
        TestPath()
        {
            $This.Exists   = Test-Path $This.Path
        }
        Create()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                Switch ($This.Name)
                {
                    {$_ -in "Resource","Module"}
                    {
                        [System.IO.Directory]::CreateDirectory($This.Fullname)
                    }
                    {$_ -in "File","Manifest"}
                    {
                        [System.IO.File]::Create($This.Fullname).Dispose()
                    }
                }

                $This.TestPath()
            }
        }
        Remove()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                Switch ($This.Name)
                {
                    {$_ -in "Resource","Module"}
                    {
                        [System.IO.Directory]::Delete($This.Fullname)
                    }
                    {$_ -in "File","Manifest","Shortcut"}
                    {
                        [System.IO.File]::Delete($This.Fullname)
                    }
                }

                $This.Exists = 0
            }
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    # // ========================================================
    # // | Represents a collection of paths for the module root |
    # // ========================================================

    Class Root
    {
        Hidden [String] $Name
        [Object]    $Registry
        [Object]    $Resource
        [Object]      $Module
        [Object]        $File
        [Object]    $Manifest
        [Object]    $Shortcut
        Root([String]$Version,[String]$Resource,[String]$Path)
        {
            $This.Name     = "Module Root"
            $SDP           = "Secure Digits Plus LLC"
            $FE            = "FightingEntropy"
            $This.Registry = $This.Set(0,0,"HKLM:\Software\Policies\$SDP\$FE\$Version")
            $This.Resource = $This.Set(1,0,"$Resource")
            $This.Module   = $This.Set(2,0,"$Path\$FE")
            $This.File     = $This.Set(3,1,"$Path\$FE\$FE.psm1")
            $This.Manifest = $This.Set(4,1,"$Path\$FE\$FE.psd1")
            $This.Shortcut = $This.Set(5,1,"$Env:Public\Desktop\$FE.lnk")
        }
        [String] Slot([UInt32]$Type)
        {
            Return @("Registry","Resource","Module","File","Manifest","Shortcut")[$Type]
        }
        [Object] Set([UInt32]$Index,[UInt32]$Type,[String]$Path)
        {
            Return [RootProperty]::New($Index,$This.Slot($Index),$Type,$Path)
        }
        [Void] Refresh()
        {
            $This.List() | % { $_.TestPath() }
        }
        [Object[]] List()
        {
            Return $This.PSObject.Properties.Name | % { $This.$_ }
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.Root>"
        }
    }

    # // ===========================================
    # // | Works as a PowerShell Registry provider |
    # // ===========================================

    Class RegistryKeyTemp
    {
        Hidden [Microsoft.Win32.RegistryKey] $Key
        Hidden [Microsoft.Win32.RegistryKey] $Subkey
        [String]            $Enum
        [String]            $Hive
        [String]            $Path
        [String]            $Name
        Hidden [String] $Fullname
        RegistryKeyTemp([String]$Path)
        {
            $This.Fullname = $Path
            $Split         = $Path -Split "\\"
            $This.Hive     = $Split[0]
            $This.Name     = $Split[-1]
            $This.Enum     = Switch -Regex ($This.Hive)
            {
                HKLM: {"LocalMachine"} HKCU: {"CurrentUser"} HKCR: {"ClassesRoot"} 
            }
            $This.Path     = $Path -Replace "$($This.Hive)\\", "" | Split-Path -Parent
        }
        Open()
        {
            $X             = $This.Enum
            $This.Key      = [Microsoft.Win32.Registry]::$X.CreateSubKey($This.Path)
        }
        Create()
        {
            If (!$This.Key)
            {
                Throw "Must open the key first."
            }

            $This.Subkey = $This.Key.CreateSubKey($This.Name)
        }
        Add([String]$Name,[Object]$Value)
        {
            If (!$This.Subkey)
            {
                Throw "Must create the subkey first."
            }

            $This.Subkey.SetValue($Name,$Value)
        }
        [Void] Remove()
        {
            If ($This.Key)
            {
                $This.Key.DeleteSubKeyTree($This.Name)
            }
        }
        [Void] Dispose()
        {
            If ($This.Subkey)
            {
                $This.Subkey.Flush()
                $This.Subkey.Dispose()
            }

            If ($This.Key)
            {
                $This.Key.Flush()
                $This.Key.Dispose()
            }
        }
    }
    
    # // ========================================================
    # // | Represents an individual registry key for the module |
    # // ========================================================

    Class RegistryKeyProperty
    {
        Hidden [UInt32] $Index
        [String]         $Name
        [Object]        $Value
        [UInt32]       $Exists
        RegistryKeyProperty([UInt32]$Index,[Object]$Property)
        {
            $This.Index = $Index
            $This.Name  = $Property.Name
            $This.Value = $Property.Value
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.RegistryKeyProperty>"
        }
    }

    # // ===========================================================
    # // | Represents a collection of registry keys for the module |
    # // ===========================================================

    Class RegistryKey
    {
        Hidden [String] $Name
        [String]        $Path
        [UInt32]      $Exists
        [Object]    $Property
        RegistryKey([Object]$Module)
        {
            $This.Name         = "Module Registry"
            $This.Path         = $Module.Root.Registry.Path
            $This.TestPath()
            If ($This.Exists)
            {
                $Object        = Get-ItemProperty $This.Path
                $This.Property = $This.Inject($Object)
            }
            Else
            {
                $Object        = $Module.Template()
                $This.Property = $This.Inject($Object)
            }
        }
        [Object] Inject([Object]$Object)
        {
            $Hash              = @{ }
            ForEach ($Property in $Object.PSObject.Properties | ? Name -notmatch ^PS)
            { 
                $Item          = $This.Key($Hash.Count,$Property)
                $Item.Exists   = $This.Exists
                $Hash.Add($Hash.Count,$Item)
            }

            Return $Hash[0..($Hash.Count-1)]
        }
        TestPath()
        {
            $This.Exists = Test-Path $This.Path
        }
        Create()
        {
            $This.TestPath()

            If ($This.Exists)
            {
                Throw "Exception [!] Path already exists"
            }

            $Key            = $This.RegistryKeyTemp($This.Path)
            $Key.Open()
            $Key.Create()

            $This.Exists    = 1
            
            ForEach ($X in 0..($This.Property.Count-1))
            {
                $Item        = $This.Property[$X]
                $Key.Add($Item.Name,$Item.Value)
                $Item.Exists = 1
            }
            $Key.Dispose()
        }
        Remove()
        {
            $This.TestPath()

            If (!$This.Exists)
            {
                Throw "Exception [!] Registry path does not exist"
            }

            $Key             = $This.RegistryKeyTemp($This.Path)
            $Key.Open()
            $Key.Create()
            $Key.Delete()

            ForEach ($Item in $This.Property)
            {
                $Item.Exists = 0
            }

            $This.Exists     =   0
            $Key.Dispose()
        }
        [Object[]] List()
        {
            Return $This.Output
        }
        [Object] Key([UInt32]$Index,[Object]$Property)
        {
            Return [RegistryKeyProperty]::New($Index,$Property)
        }
        [Object] KeyTemp([String]$Path)
        {
            Return [RegistryKeyTemp]::New($Path)
        }
        [String] ToString()
        {
            Return "<FightingEntropy.Module.RegistryKey>"
        }
    }

    # // ===========================================
    # // | Collects/creates versions of the module |
    # // ===========================================

    Class FEVersion
    {
        [Version]      $Version
        Hidden [DateTime] $Time
        [String]          $Date
        [Guid]            $Guid
        FEVersion([String]$Line)
        {
            $This.Version = $This.Tx(0,$Line)
            $This.Time    = $This.Tx(1,$Line)
            $This.Date    = $This.MilitaryTime()
            $This.Guid    = $This.Tx(2,$Line)
        }
        FEVersion([Switch]$New,[String]$Version)
        {
            $This.Version = $Version
            $This.Time    = [DateTime]::Now
            $This.Date    = $This.MilitaryTime()
            $This.Guid    = [Guid]::NewGuid()
        }
        [String] MilitaryTime()
        {
            Return $This.Time.ToString("MM/dd/yyyy HH:mm:ss")
        }
        [String] Tx([UInt32]$Type,[String]$Line)
        {
            $Pattern = Switch ($Type)
            {
                0 { "\d{4}\.\d{1,}\.\d{1,}" }
                1 { "\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2}" }
                2 { @(8,4,4,4,12 | % { "[a-f0-9]{$_}" }) -join '-' }
            }

            Return [Regex]::Matches($Line,$Pattern).Value
        }
        [String] ToString()
        {
            Return "| {0} | {1} | {2} |" -f $This.Version, 
                                            $This.Date.ToString("MM/dd/yyyy HH:mm:ss"), 
                                            $This.Guid
        } 
    }

    # // ========================================================
    # // | Specifically used for file hash validation/integrity |
    # // ========================================================

    Class ValidateFile
    {
        [UInt32]           $Index
        [String]            $Type
        [String]            $Name
        [String]            $Hash
        [String]         $Current
        Hidden [String] $Fullname
        Hidden [String]   $Source
        [UInt32]          $Exists
        [UInt32]           $Match
        ValidateFile([Object]$File)
        {
            $This.Index    = $File.Index
            $This.Type     = $File.Type
            $This.Name     = $File.Name
            $This.Hash     = $File.Hash
            $This.Current  = $This.GetFileHash($File.Fullname)
            $This.Exists   = $File.Exists
            $This.Fullname = $File.Fullname
            $This.Source   = $File.Source
            $This.Match    = [UInt32]($This.Hash -eq $This.Current)
            $File.Match    = $This.Match
        }
        [String] GetFileHash([String]$Path)
        {
            If (![System.IO.File]::Exists($Path))
            {
                [System.IO.File]::Create($Path).Dispose()
            }

            Return Get-FileHash $Path | % Hash
        }
    }

    # // ===============================================================
    # // | Specifically meant to categorize available version archives |
    # // ===============================================================

    Class MarkdownArchiveEntry
    {
        Hidden [DateTime]   $Real
        [String]            $Date
        [String]            $Name
        [String]            $Link
        Hidden [String] $NameLink
        [String]            $Hash
        MarkdownArchiveEntry([String]$Date,[String]$Name,[String]$Hash,[String]$Link)
        {
            $This.Date     = $Date
            $This.Real     = [DateTime]$This.Date
            $This.Name     = $Name
            $This.Link     = $Link
            $This.NameLink = "[**{0}**]({1})" -f $This.Name,$This.Link
            $This.Hash     = $Hash
        }
        MarkdownArchiveEntry([String]$Line)
        {
            $This.Date     = [Regex]::Matches($Line,"\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2}").Value
            $This.Real     = [DateTime]$This.Date
            $This.Name     = [Regex]::Matches($Line,"\*\*\d{4}\-\d{2}\-\d{2}_\d{6}.zip\*\*").Value.Trim("*")
            $This.Link     = [Regex]::Matches($Line,"https.+.zip").Value
            $This.NameLink = "[**{0}**]({1})" -f $This.Name,$This.Link
            $This.Hash     = [Regex]::Matches($Line,"[A-F0-9]{64}").Value
        }
        [String] Prop([String]$Property,[String]$Char)
        {
            $Prop = $This.$Property
            Return $Prop.PadRight($Prop.Length,$Char)
        }
        [String[]] GetOutput()
        {
            Return "| {0} | {1} | {2} |" -f $This.Prop("Date"," "),
                                            $This.Prop("NameLink"," "),
                                            $This.Prop("Hash"," ")
        }
    }

    # // ______________________________________________________________
    # // | Factory class to control all of the aforementioned classes |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ModuleController
    {
        Hidden [UInt32]    $Mode
        Hidden [Object] $Console
        [String]         $Source = "https://www.github.com/mcc85s/FightingEntropy"
        [String]           $Name = "[FightingEntropy($([Char]960))]"
        [String]    $Description = "Beginning the fight against ID theft and cybercrime"
        [String]         $Author = "Michael C. Cook Sr."
        [String]        $Company = "Secure Digits Plus LLC"
        [String]      $Copyright = "(c) 2023 (mcc85s/mcc85sx/sdp). All rights reserved."
        [Guid]             $Guid = "75f64b43-3b02-46b1-b6a2-9e86cccf4811"
        [DateTime]         $Date = "04/03/2023 18:53:49"
        [Version]       $Version = "2023.4.0"
        [Object]             $OS
        [Object]           $Root
        [Object]       $Manifest
        [Object]       $Registry
        ModuleController([Switch]$Flags)
        {
            $This.Mode = 0
            $This.Main()
        }
        ModuleController()
        {
            $This.Mode = 0
            $This.Main()
        }
        ModuleController([UInt32]$Mode)
        {
            $This.Mode = $Mode
            $This.Main()
        }
        Main()
        {
            # Initialize console
            $This.StartConsole()
            
            # Display module
            $This.Display()

            # Operating system
            $This.OS       = $This.New("OS")

            # Root
            $This.Root     = $This.New("Root")

            # Manifest
            $This.Manifest = $This.New("Manifest")

            # Registry
            $This.Registry = $This.New("Registry")

            $This.Update(0," ".PadLeft(103," "))

            # Load the manifest
            $This.LoadManifest()
        }
        StartConsole()
        {
            # Instantiates and initializes the console
            $This.Console = [ConsoleController]::New()
            $This.Console.Initialize()
            $This.Status()
        }
        [Void] Status()
        {
            # If enabled, shows the last item added to the console
            If ($This.Mode -eq 0)
            {
                [Console]::WriteLine($This.Console.Last())
            }
        }
        [Void] Update([Int32]$State,[String]$Status)
        {
            # Updates the console
            $This.Console.Update($State,$Status)
            $This.Status()
        }
        [Void] Write([String]$Message)
        {
            # Writes a standard stylized message to the console
            [ThemeStack]::New($Message)
        }
        [Void] Write([UInt32]$Slot,[String]$Message)
        {
            # Writes a selected stylized message to the console
            [ThemeStack]::New($Slot,$Message)
        }
        Display()
        {
            If ($This.Mode -eq 0)
            {
                $This.Update(0,"Loading [~] $($This.Label())")
                $This.Write($This.Console.Last().Status)
            }
        }
        [String] Now()
        {
            Return [DateTime]::Now.ToString("yyyy-MMdd_HHmmss")
        }
        [String] ProgramData()
        {
            Return [Environment]::GetEnvironmentVariable("ProgramData")
        }
        [String] Label()
        {
            # Returns the module name and version as a string
            Return "{0}[{1}]" -f $This.Name, $This.Version.ToString()
        }
        [String] SourceUrl()
        {
            # Returns the (base url + version) as a string
            Return "{0}/blob/main/Version/{1}" -f $This.Source, $This.Version
        }
        [String] Env([String]$Name)
        {
            # Returns named environment variable as a string
            Return [Environment]::GetEnvironmentVariable($Name)
        }
        [String] GetResource()
        {
            # Returns the resource path as a string
            Return $This.Env("ProgramData"), $This.Company, "FightingEntropy", $This.Version.ToString() -join "\"
        }
        [String] GetRootPath()
        {
            # Selects and returns the root module path as a string
            $Path     = Switch -Regex ($This.OS.Type)
            {
                ^Win32_ { $This.Env("PSModulePath") -Split ";" -match [Regex]::Escape($This.Env("Windir")) }
                Default { $This.Env("PSModulePath") -Split ":" -match "PowerShell"                         }
            }

            Return $Path
        }
        [Object] GetFEVersion()
        {
            # Returns parsed FEModule version object 
            Return [FEVersion]::New("| $($This.Version) | $($This.Date) | $($This.Guid) |")
        }
        [Object] ManifestFolder([UInt32]$Index,[String]$Type,[String]$Resource,[String]$Name)
        {
            # Instantiates a new manifest folder, and can be used externally
            Return [ManifestFolder]::New($Index,$Type,$Resource,$Name)
        }
        [Object] ManifestFile([Object]$Folder,[String]$Name,[String]$Hash)
        {
            # Instantiates a new manifest file, and can be used externally
            Return [ManifestFile]::New($Folder,$Name,$Hash,$This.SourceUrl())
        }
        [Object] NewVersion([String]$Version)
        {
            # Tests a version input string, and if it passes, returns a version object
            If ($Version -notmatch "\d{4}\.\d{2}\.\d+")
            {
                Throw "Invalid version entry"
            }

            Return [FEVersion]::New($True,$Version)
        }
        [Object[]] Versions()
        {
            # Obtains the available versions from the project site
            $Markdown = Invoke-RestMethod "$($This.Source)/blob/main/README.md?raw=true"
            Return $Markdown -Split "`n" | ? { $_ -match "^\|\s\*\*\d{4}\.\d{2}\.\d+\*\*" } | % { [FEVersion]$_ }
        }
        [Object] Template()
        {
            # Instantiates a new registry template to generate a registry key set
            Return [RegistryTemplate]::New($This)
        }
        [Object] New([String]$Name)
        {
            # (Selects/instantiates) selected object
            $Item = Switch ($Name)
            {
                OS
                {
                    [OS]::New()
                }
                Root
                {
                    [Root]::New($This.Version,$This.GetResource(),$This.GetRootPath())
                }
                Manifest
                {
                    [ManifestController]::New($This.Source,$This.Root.Resource)
                }
                Registry
                {
                    [RegistryKey]::New($This)
                }
            }

            # Logs the instantiation of the named (function/class)
            Switch ([UInt32]!!$Item)
            {
                0 { $This.Update(-1,"[!] <$($Item.Name)> ") }
                1 { $This.Update( 1,"[+] <$($Item.Name)> ") }
            }

            Return $Item
        }
        [Object] GetFolder([String]$Type)
        {
            # Returns the named folder from the manifest controller
            Return $This.Manifest.Output | ? Type -eq $Type
        }
        [Object] GetFolder([UInt32]$Index)
        {
            # Returns the indexed folder from the manifest controller
            Return $This.Manifest.Output | ? Index -eq $Index
        }
        [String] GetFolderName([String]$Type)
        {
            # Returns the formal name of a given (type/folder) as a string
            $xName = Switch ($Type)
            { 
                Control  {   "Control" }
                Function { "Functions" }
                Graphic  {  "Graphics" }
            }

            Return $xName
        }
        [Object] ManifestListItem([UInt32]$Index,[String]$Source,[String]$Name,[String]$Hash)
        {
            Return [ManifestListItem]::New($Index,$Source,$Name,$Hash)
        }
        [Object[]] GetManifestList([String]$Name)
        {
            $List = Switch ($Name)
            {
                Control
                {
                    ("Computer.png"                    , "87EAB4F74B38494A960BEBF69E472AB0764C3C7E782A3F74111F993EA31D1075") ,
                    ("DefaultApps.xml"                 , "EEC0F0DFEAC1B4172880C9094E997C8A5C5507237EB70A241195D7F16B06B035") ,
                    ("failure.png"                     , "59D479A0277CFFDD57AD8B9733912EE1F3095404D65AB630F4638FA1F40D4E99") ,
                    ("FEClientMod.xml"                 , "326C8D3852895A3135144ACCBB4715D2AE49101DCE9E64CA6C44D62BD4F33D02") ,
                    ("FEServerMod.xml"                 , "3EA9AF3FFFB5812A3D3D42E5164A58EF2FC744509F2C799CE7ED6D0B0FF9016D") ,
                    ("header-image.png"                , "38F1E2D061218D31555F35C729197A32C9190999EF548BF98A2E2C2217BBCB88") ,
                    ("MDTClientMod.xml"                , "B2BA25AEB67866D17D8B22BFD31281AFFF0FFE1A7FE921A97C51E83BF46F8603") ,
                    ("MDTServerMod.xml"                , "C4B12E67357B54563AB042617CEC2B56128FD03A9C029D913BB2B6CC65802189") ,
                    ("MDT_LanguageUI.xml"              , "8968A07D56B4B2A56F15C07FC556432430CB1600B8B6BBB13C332495DEE95503") ,
                    ("PSDClientMod.xml"                , "C90146EECF2696539ACFDE5C2E08CFD97548E639ED7B1340A650C27F749AC9CE") ,
                    ("PSDServerMod.xml"                , "C90146EECF2696539ACFDE5C2E08CFD97548E639ED7B1340A650C27F749AC9CE") ,
                    ("success.png"                     , "46757AB0E2D3FFFFDBA93558A34AC8E36F972B6F33D00C4ADFB912AE1F6D6CE2") ,
                    ("vendorlist.txt"                  , "A37B6652014467A149AC6277D086B4EEE7580DDB548F81B0B2AA7AC78C240874") ,
                    ("warning.png"                     , "CC05A590DE7AD32AEB47E117AA2DD845F710080F9A3856FBCDC9BC68106C562F") ,
                    ("Wifi.cs"                         , "405226234D7726180C0F9C97DF3C663CA0028A36CBCD00806D6517575A6F549F") ,
                    ("zipcode.txt"                     , "E471E887F537FA295A070AB41E21DEE978181A92CB204CA1080C6DC32CBBE0D8") 
                }
                Function
                {
                    ("Copy-FileStream.ps1"             , "02A752EB77E36D83CB1DA4CAE9F9FD99681DCF1FA06B7F62230585CC00D235DE") ,
                    ("Get-AssemblyList.ps1"            , "63EDB49C2FE80B93BD3FA6085EA1CE87927B70F5932EC15C3B6D88D4D3D81978") ,
                    ("Get-ControlExtension.ps1"        , "82E3493A8B654FC4C11B2F0AE6F62E8B043E7A805FE0EA91639381C486D2C331") ,
                    ("Get-DCOMSecurity.ps1"            , "C0F71EC9788324C10C68B8DC042B378BA88BC185B0DAEA9F34C7855474C27B18") ,
                    ("Get-EnvironmentKey.ps1"          , "C9755AF12D6E1B4BBD5D898563CB0D205BF2A8CFC78F96B0887BC828DE153D7D") ,
                    ("Get-EventLogArchive.ps1"         , "FEB6F04221BDF827E932C5BAD3A7470A1ED557A36F8C025665A5C2C174B11E29") ,
                    ("Get-EventLogConfigExtension.ps1" , "E19AFE2CD3FD89074835E3338A208FEBCA970E4755FC87DFC0E36F71F902D50B") ,
                    ("Get-EventLogController.ps1"      , "17F1F8865719592D60CF5AF51771CE9FE775878BFA9DFF7897044A17E00379C4") ,
                    ("Get-EventLogProject.ps1"         , "211F62139ADB5E4BA957A12B11E5BC6F55B7862E63F60BA921832410E7114BA4") ,
                    ("Get-EventLogRecordExtension.ps1" , "C8773C24AA850021C2B15584C7198FA65C736F7F38B902D91FA1290A9E3F9CB0") ,
                    ("Get-EventLogXaml.ps1"            , "89F96497DD3050104A63D536602F12864A8FEDA7E95E4DDB39B85E30A1F9FB80") ,
                    ("Get-FEADLogin.ps1"               , "D60DDE95DCEC1596951DDC687CF83BECC32EF8218BF3E97522A30BE7F35CEDE0") ,
                    ("Get-FEDCPromo.ps1"               , "99E9BF0BC2CB55260267DFA3E203C936016BB99051EB2301BBFC6CFD8D128095") ,
                    ("Get-FEImageManifest.ps1"         , "2D1D8896C36AF6F1FB4677D1648AEBC3B9873CFF505D5B94E04AD6D81CB6B444") ,
                    ("Get-FEModule.ps1"                , "19FE0FB51A95D8259C8952C9920705F2E6A627BE1F3E8B0D7593E71C44EDA612") ,
                    ("Get-FENetwork.ps1"               , "7A68ADF6AFF12661E036E1405F8655BE07B6B547F05141603A32BCC8FE5A5F75") ,
                    ("Get-FERole.ps1"                  , "220808D891851845B16366B470EB6A85FF030CA4266DBF35E760CEAE2730A145") ,
                    ("Get-FESystem.ps1"                , "1EC3E7029BC25BF15805EE632A8C2377677397B6D3FC1F0B8AB7133E800E5C3F") ,
                    ("Get-MDTModule.ps1"               , "AA9BB135FADFC5D2FA3FEF4B7258EFC01CCAA42100134725AFF9D6273782ADF9") ,
                    ("Get-PowerShell.ps1"              , "8504FF74C78BC486E0242689A70CFAD6EDD8F8130ED123DE88B09D2B6D560063") ,
                    ("Get-PropertyItem.ps1"            , "758B68FC38B0D71B27866EAB67C69B2A40E4AAD803636E61C885E83A87E33C9D") ,
                    ("Get-PropertyObject.ps1"          , "D5090E35819F149D03654C61BAEB9818BB7D8BCF7DCAB2F715DE55C13DC5CFCA") ,
                    ("Get-PSDLog.ps1"                  , "C8A2E2B91EADF76A58C2D2054A82EE171A1338E405FD4E828D0AF5A78644987D") ,
                    ("Get-PSDLogGUI.ps1"               , "30A5C2B92FA6F8293A362BA870C66432FB86F9029ED2F69F1473A9D324E0A550") ,
                    ("Get-PSDModule.ps1"               , "CD83DA3B18F706174C9D65969938B85F730D36479A42D1D71EDE2C0CA9BE8024") ,
                    ("Get-ThreadController.ps1"        , "3DFA549D11BB239E63B1E114C4C86CFA7A92B83C95F114B5BD66DDC33778E545") ,
                    ("Get-UserProfile.ps1"             , "97FF1186827FDE6A84B66C67036B3018F61624C92ECA37F89AC70077B717A6C6") ,
                    ("Get-ViperBomb.ps1"               , "A103F674B4278ABFD07B95D985F930197EF13BFA19B2CE0259CFBA836F6D7ADE") ,
                    ("Get-WhoisUtility.ps1"            , "BFE480D46157A0A0F541A4A14E12D85F834592DA8243A5BCE4D24EDADDB4BE9A") ,
                    ("Initialize-FeAdInstance.ps1"     , "0EEF28E919AE410A405DB87C4124239C63026192E188D26B23885A23C6388477") ,
                    ("Install-BossMode.ps1"            , "E7D53EF50DB9B226C3213F5A2FE66671F12FDD450FBE9629DFED78FE3683FB19") ,
                    ("Install-IISServer.ps1"           , "CAFE22024A7B0E398CDB9BA556EC1B5ED776F38FEACF35FBFB4C38C311E1EBE2") ,
                    ("Install-PSD.ps1"                 , "7CA2FFB284B9D9A12CC43D43E324FC71C77CF07412E0B5EC47D241965DEEACD0") ,
                    ("Invoke-cimdb.ps1"                , "97134F3F6918288B0AB177615F5CC7F78C5F188E8368F1CF8B597419E272C435") ,
                    ("New-Document.ps1"                , "7B21B34EB98C96A93A54639F0A05028B7B1738399EBB391B86EFB0404F851D10") ,
                    ("New-EnvironmentKey.ps1"          , "9577B80E2A2309C1A100859370B7979FBDC504F78BCD8ECF0E4A110585F9C848") ,
                    ("New-FEConsole.ps1"               , "6909B10D29F99EC565B714F31BBD5BE04E5FAE350DC397FE94018988E056E2F1") ,
                    ("New-FEFormat.ps1"                , "549EC35DCB88F4C48ED7C14F06FB0DA05375AF64BFF5C1344A1403E249CE24F2") ,
                    ("New-FEInfrastructure.ps1"        , "3918611F5026D910A1F4D404CEA7D72A70B3DDD2B40CF2D57CFF39CF0E9F0D12") ,
                    ("New-MarkdownFile.ps1"            , "17F2298DF8523E8B9A19AA4DE512E5E8BAA0E282F714A1630283966F76AC7E27") ,
                    ("New-TranscriptionCollection.ps1" , "D3A5F59E17A71B9D6983F5C4F1F32B88B7634FA4910B2DB4A840D97D2B459C6B") ,
                    ("New-VmController.ps1"            , "70F3DB5EE74D52DBA590D23C2EC5320316AB8EBC26F07030BE77ADA79F4137CC") ,
                    ("Search-WirelessNetwork.ps1"      , "52FDA296BDB480C4248C182825545C988BE1A6A23A298A8E94507AFB42FAB032") ,
                    ("Set-AdminAccount.ps1"            , "1B18B8A399A14F85F65B8A78FF2FF5E360F69A887F980E788E99F59D908C7582") ,
                    ("Set-ScreenResolution.ps1"        , "8FA4D6D0BB1B2C0FDE8EE05C1114682AB54E7FE238F70409C45333AE0002E3C5") ,
                    ("Show-ToastNotification.ps1"      , "BEE09485C8E68B7DD2BEAA317B67401EB87E80BCCA6F54B9965725C2F0500409") ,
                    ("Start-TCPSession.ps1"            , "6ED5305A4E239BD839B611B986DDF1701C1DB0FB4FDE18B04B2FE6812610D9F9") ,
                    ("Update-PowerShell.ps1"           , "4510EB6E34553E58393D8EDCBCFE34D8D11DFB6AF049D9C4CD4A6934DBCE779A") ,
                    ("Write-Element.ps1"               , "07D040C9749E6AAF56BD827238CF69DDFFF1A7123A4EE96D98249554FEC10610") ,
                    ("Write-Theme.ps1"                 , "01070281F24BE58928A1146EF89B3AE56F3FAE100BE178ED11A5FEF710724C00") ,
                    ("Write-Xaml.ps1"                  , "F233F0E56889F7825615DE597D940EB9F5461158B57510E68E2F894B12722908")
                }
                Graphic
                {
                    ("background.jpg"                  , "94FD6CB32F8FF9DD360B4F98CEAA046B9AFCD717DA532AFEF2E230C981DAFEB5") ,
                    ("banner.png"                      , "057AF2EC2B9EC35399D3475AE42505CDBCE314B9945EF7C7BCB91374A8116F37") ,
                    ("icon.ico"                        , "594DAAFF448F5306B8B46B8DB1B420C1EE53FFD55EC65D17E2D361830659E58E") ,
                    ("OEMbg.jpg"                       , "D4331207D471F799A520D5C7697E84421B0FA0F9B574737EF06FC95C92786A32") ,
                    ("OEMlogo.bmp"                     , "98BF79CAE27E85C77222564A3113C52D1E75BD6328398871873072F6B363D1A8") ,
                    ("PSDBackground.bmp"               , "05ABBABDC9F67A95D5A4AF466149681C2F5E8ECD68F11433D32F4C0D04446F7E") ,
                    ("sdplogo.png"                     , "87C2B016401CA3F8F8FAD5F629AFB3553C4762E14CD60792823D388F87E2B16C") 
                }
            }

            Return $List
        }
        LoadManifest()
        {
            $Out = @( )

            # Collects all of the files and names
            ForEach ($Type in "Control","Function","Graphic")
            {
                ForEach ($Item in $This.GetManifestList($Type))
                {
                    $Out += $This.ManifestListItem($Out.Count,$Type,$Item[0],$Item[1])
                }
            }

            # Determines maximum name length
            $Max = ($Out.Name | Sort-Object Length)[-1]

            ForEach ($Type in "Control","Function","Graphic")
            {
                # Adds + selects specified folder object
                $This.LoadFolder($Type)
                $Folder = $This.GetFolder($Type)

                # Loads each file + hash
                ForEach ($File in $Out | ? Source -eq $Type)
                {                            
                    $This.LoadFile($Folder,$Max.Length,$File)
                }

                $This.Update(0," ".PadLeft(102," "))
            }
        }
        LoadFolder([String]$Type)
        {
            # Selects the correct folder name
            $ID   = $This.GetFolderName($Type)

            # Instantiates the specified folder
            $Item = $This.ManifestFolder($This.Manifest.Output.Count,$Type,$This.Root.Resource,$ID)

            # Logs validation of its existence, and adds if it does not
            Switch ([UInt32]!!$Item)
            {
                0
                {
                    $This.Update( 0,"-".PadLeft(102,"-"))
                    $This.Update( 0,("[!] {0} : {1}" -f $Item.Type.PadLeft(8," "), $Item.Fullname))
                    $This.Update( 0,"-".PadLeft(102,"-"))
                    $This.Update( 0," ".PadLeft(102," "))
                }
                1
                {
                    $This.Manifest.Output += $Item
                    $This.Update( 0,"-".PadLeft(102,"-"))
                    $This.Update( 0,("[+] {0} : {1}" -f $Item.Type.PadLeft(8," "), $Item.Fullname))
                    $This.Update( 0,"-".PadLeft(102,"-"))
                    $This.Update( 0," ".PadLeft(102," "))
                }
            }
        }
        LoadFile([Object]$Folder,[UInt32]$Max,[Object]$File)
        {
            $ID   = $File.Name
            $Hash = $File.Hash

            # Adds a specified file + hash into a specified folder object
            If ($ID -in $Folder.Item.Name)
            {
                Throw "Item already added"
            }

            # Instantiates the specified file
            $Item   = $This.ManifestFile($Folder,$ID,$Hash)
            $Label  = $ID.PadRight($Max," ")

            # Logs validation of its existence, and adds if it does not
            Switch ([UInt32]($ID -notin $Folder.Item.Name))
            {
                0 
                {
                    $This.Update(-1,"[!] $Label")
                }
                1
                {
                    $Folder.Add($Item)
                    $This.Update( 1,"[o] $Label | $Hash ")
                }
            }
        }
        [Object] File([String]$Type,[String]$Name)
        {
            Return $This.GetFolder($Type).Item | ? Name -eq $Name
        }
        [Object] File([UInt32]$Index,[String]$Name)
        {
            Return $This.GetFolder($Index).Item | ? Name -eq $Name
        }
        [Object] _Control([String]$Name)
        {
            Return $This.File("Control",$Name)
        }
        [Object] _Function([String]$Name)
        {
            Return $This.File("Function",$Name)
        }
        [Object] _Graphic([String]$Name)
        {
            Return $This.File("Graphic",$Name)
        }
        [Void] WriteAllLines([String]$Path,[Object]$Object)
        {
            [System.IO.File]::WriteAllLines($Path,$Object,[System.Text.UTF8Encoding]$False)
        }
        [Void] Refresh()
        {
            # // ____________________________________________
            # // | Tests all manifest (folder/file) entries |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            ForEach ($Item in $This.Module.Root.List() | Sort-Object Index -Descending)
            {
                Switch ($Item.Name)
                {
                    Registry 
                    {
                        $This.Registry.TestPath()
                        $This.Root.Registry.Exists = $This.Registry.Exists
                    }
                    Resource
                    {
                        $This.Root.Resource.TestPath()
                        $This.Manifest.Refresh() | Out-Null
                    }
                    Module
                    {
                        $This.Root.Module.TestPath()
                    }
                    File
                    {
                        $This.Root.File.TestPath()
                    }
                    Manifest
                    {
                        $This.Root.Manifest.TestPath()
                    }
                    Shortcut
                    {
                        $This.Root.Shortcut.TestPath()
                    }
                }
            }
        }
        InstallItem([Object]$Item)
        {
            $Item.TestPath()

            Switch ($Item.Exists)
            {
                0
                {
                    Switch ($Item.Name)
                    {
                        Resource
                        {
                            $Item.Create()

                            $List       = $This.Manifest.Output | % Item

                            $Max        = ($List.Name | Sort-Object Length)[-1]
                            $C          = $List.Count + $This.Manifest.Output.Count
                            $I          = -1
            
                            $This.Update(1,"[@] Resource : $($Item.Fullname) ")
                            $This.Update(1,"               ($C) [directories/files] ")
            
                            ForEach ($Sx in $This.Manifest.Output)
                            {
                                $Sx.TestPath()
                                If (!$Sx.Exists)
                                {
                                    $I ++
                                    $St = "{0:p}" -f ($I/$C)

                                    $Sx.Create()
                                    
                                    $This.Update( 1,"-".PadLeft(102,"-"))
                                    $This.Update( 1,("[~] {0} : {1} [$St] " -f $Sx.Type.PadRight(9," "), $Sx.FullName))
                                    $This.Update( 1,"-".PadLeft(102,"-"))
                                    $This.Update( 0," ".PadLeft(102," "))
                                }

                                ForEach ($File in $Sx.Item)
                                { 
                                    $I ++
                                    $St = "{0:p}" -f ($I/$C)

                                    Switch ($File.Exists)
                                    {
                                        0
                                        {
                                            $File.Create()
                                            $File.Download()
                                            $File.Write()
                                            $This.Update(1,("[+] {0} [$St] " -f $File.Name.PadRight($Max.Length," ")))
                                        }

                                        1
                                        {
                                            $This.Update(0,("[!] {0} [$St] " -f $File.Name.PadRight($Max.Length," ")))
                                        }
                                    }
                                }

                                $This.Update(0," ".PadLeft(102," "))
                            }
                        }
                        Registry
                        {
                            $This.Update(1,"[@] Registry : $($Item.Fullname) ")
                            $This.Update(0," ".PadLeft(102," "))
    
                            $Key = $This.Registry.KeyTemp($Item.Fullname)
                            $Key.Open()
                            $Key.Create()
            
                            $Max = @{ 
                                
                                Name = ($This.Registry.Property.Name | Sort-Object Length)[-1].Length
                            }

                            ForEach ($X in 0..($This.Registry.Property.Count-1))
                            {
                                $Prop        = $This.Registry.Property[$X]
                                $Key.Add($Prop.Name,$Prop.Value)
            
                                $This.Update(1,"[+] $($Prop.Name.PadRight($Max.Name," ")) : $($Prop.Value)")
                                $Item.Exists = 1
                            }
            
                            $Key.Dispose()
                            $Item.TestPath()
                            $This.Update(0," ".PadLeft(102," "))
                        }
                        Module
                        {
                            $Item.Create()

                            $This.Update(1,"[+] PSModule : $($Item.Fullname) ")
                        }
                        File
                        {
                            $Item.Create()
                            $This.WriteAllLines($Item.Fullname,$This.Psm())
                            $Item.TestPath() 
                            $This.Update(1,"[+] *.psm1   : $($Item.Fullname) ")
                        }
                        Manifest
                        {
                            $Splat = $This.PSDParam()
                            New-ModuleManifest @Splat
                            $Item.TestPath()
                            $This.Update(1,"[+] *.psd1   : $($Item.Fullname) ")
                        }
                        Shortcut
                        {
                            $Com                 = New-Object -ComObject WScript.Shell
                            $Object              = $Com.CreateShortcut($Item.Fullname)
                            $Object.TargetPath   = "PowerShell"
                            $Object.Arguments    = "-NoExit -ExecutionPolicy Bypass -Command `"Get-FEModule -Mode 1`""
                            $Object.Description  = $This.Description
                            $Object.IconLocation = $This._Graphic("icon.ico").Fullname
                            $Object.Save()
    
                            $Bytes               = [System.IO.File]::ReadAllBytes($Item.Fullname)
                            $Bytes[0x15]         = $Bytes[0x15] -bor 0x20

                            [System.IO.File]::WriteAllBytes($Item.Fullname,$Bytes)

                            $Item.TestPath()
                            $This.Update(1,"[+] *.lnk    : $($Item.Fullname) ")
                        }
                    }
                }
                1
                {
                    Switch ($Item.Name)
                    {
                        Resource
                        {
                            $This.Update(-1,"[!] Resource : $($Item.Fullname) [exists]")
                        }
                        Registry
                        {
                            $This.Update(-1,"[!] Registry : $($Item.Fullname) [exists]")
                        }
                        Module
                        {
                            $This.Update(-1,"[!] PSModule : $($Item.Fullname) [exists]")
                        }
                        File
                        {
                            $This.Update(-1,"[!] *.psm1   : $($Item.Fullname) [exists]")
                        }
                        Manifest
                        {
                            $This.Update(-1,"[!] *.psd1   : $($Item.Fullname) [exists]")
                        }
                        Shortcut
                        {
                            $This.Update(-1,"[!] *.lnk    : $($Item.Fullname) exists")
                        }
                    }
                }
            }
        }
        [Void] Install()
        {
            $This.Write(2,"Installing [~] $($This.Label())")

            $Setting = [System.Net.ServicePointManager]::SecurityProtocol
                       [System.Net.ServicePointManager]::SecurityProtocol = 3072

            $This.Update(0,"=".PadLeft(102,"="))
            $This.InstallItem($This.Root.Resource)
            $This.Update(0,"-".PadLeft(102,"-"))

            $This.InstallItem($This.Root.Registry)
            $This.Update(0,"-".PadLeft(102,"-"))
            $This.InstallItem($This.Root.Module)
            $This.InstallItem($This.Root.File)
            $This.InstallItem($This.Root.Manifest)
            $This.InstallItem($This.Root.Shortcut)
            $This.Update(0,"=".PadLeft(102,"="))

            [System.Net.ServicePointManager]::SecurityProtocol = $Setting

            $This.Write(2,"Installed [+] $($This.Label())")
        }
        RemoveItem([Object]$Item)
        {
            $Item.TestPath()

            Switch ($Item.Exists)
            {
                0
                {
                    Switch ($Item.Name)
                    {
                        Resource 
                        {
                            $This.Update(1,"[_] Resource : $($Item.Fullname) ")
                        }
                        Registry
                        {
                            $This.Update(0,"[_] Registry : $($Item.Fullname) ")
                            
                        }
                        Module
                        {
                            $This.Update(0,"[_] PSModule : $($Item.Fullname) ")
                        }
                        File     
                        {
                            $This.Update(0,"[_] *.psm1   : $($Item.Fullname) ")
                        }
                        Manifest 
                        {
                            $This.Update(0,"[_] *.psd1   : $($Item.Fullname) ")
                        } 
                        Shortcut 
                        {
                            $This.Update(0,"[_] *.lnk    : $($Item.Fullname)")
                        }
                    }
                }
                1
                {
                    Switch ($Item.Name)
                    {
                        Resource
                        {
                            $List       = $This.Manifest.Refresh()

                            $Max        = ($List.Name | Sort-Object Length)[-1]
                            $C          = $List.Count
                            $I          = -1
            
                            $This.Update(1,"[_] Resource : $($Item.Fullname) ")
                            $This.Update(1,"               ($C) [directories/files] ")
            
                            ForEach ($Sx in $This.Manifest.Output)
                            {
                                $I ++
                                $St = "{0:p}" -f ($I/$C)

                                $This.Update(1,"-".PadLeft(102,"-"))
                                $This.Update(1,("[_] {0} : {1} [$St] " -f $Sx.Type.PadRight(9," "), $Sx.FullName))
                                $This.Update(1,"-".PadLeft(102,"-"))
                                $This.Update(0," ".PadLeft(102," "))

                                ForEach ($File in $Sx.Item)
                                {
                                    $I ++
                                    $St = "{0:p}" -f ($I/$C)
                                    
                                    $File.Remove()
                                    $This.Update($File.Exists,("[_] {0} [$St] " -f $File.Name.PadRight($Max.Length," ")))
                                }
                                
                                $This.Update(0," ".PadLeft(102," "))
                                $Sx.Remove()
                            }
    
                            $Item.Remove()
                        }
                        Registry
                        {
                            $Object         = $This.Registry

                            $This.Update(1,"[ ] Registry : $($Item.Fullname) ")
                            $This.Update(0," ".PadLeft(102," "))

                            $Key            = $This.Registry.KeyTemp($Object.Path)
                            $Key.Open()
                            $Key.Create()
                            $Key.Remove()

                            $Max = @{ 
                                
                                Name = ($This.Registry.Property.Name | Sort-Object Length)[-1].Length
                            }
                            
                            ForEach ($Property in $Object.Property)
                            {
                                $This.Update(1,"[ ] $($Property.Name.PadRight($Max.Name," ")) : $($Property.Value)")
                                $Property.Exists = 0
                            }
        
                            $Object.Exists   = 0
                            $Key.Dispose()
                            $Item.Remove()

                            $This.Update(0," ".PadLeft(102," "))

                        }
                        Module
                        {
                            $Item.Remove()
                            $This.Update(1,"[_] PSModule : $($Item.Fullname) ")
                        }
                        File
                        {
                            $Item.Remove()
                            $This.Update(1,"[_] *.psm1   : $($Item.Fullname)")
                        }
                        Manifest
                        {
                            $Item.Remove()
                            $This.Update(1,"[_] *.psd1   : $($Item.Fullname)")
                        }
                        Shortcut
                        {
                            $Item.Remove()
                            $This.Update(1,"[_] *.lnk    : $($Item.Fullname)")
                        }
                    }
                }
            }
        }
        [Void] Remove()
        {
            $This.Update(0,"Removing [~] $($This.Label())")
            $This.Write(1,$This.Console.Last().Status)
            
            $This.Update(0,"=".PadLeft(102,"="))
            ForEach ($Item in "Shortcut","Manifest","File","Module")
            {
                $This.RemoveItem($This.Root.$Item)
            }
            $This.Update(0,"-".PadLeft(102,"-"))
            $This.RemoveItem($This.Root.Registry)
            $This.Update(0,"-".PadLeft(102,"-"))
            $This.RemoveItem($This.Root.Resource)
            $This.Update(0,"=".PadLeft(102,"="))

            $This.Write(1,"Removed [+] $($This.Label())")
        }
        [String] Psm()
        {
            $F      = @( )
            $Member = @( )

            # // __________
            # // | Header |
            # // ¯¯¯¯¯¯¯¯¯¯

            $F += "# Downloaded from {0}" -f $This.Source
            $F += "# {0}" -f $This.Resource
            $F += "# {0}" -f $This.Version.ToString()
            $F += "# <Types>"
            $This.Binaries() | % { $F += "Add-Type -AssemblyName $_" }

            # // _____________
            # // | Functions |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯

            $F += "# <Functions>"
            ForEach ($File in $This.GetFolder("Function").Item)
            {
                $Base = $File.Name -Replace ".ps1",""
                If ($Member.Count -eq 0)
                {
                    $Member += "Export-ModuleMember -Function $Base," 
                }
                ElseIf ($Member.Count -gt 0)
                {
                    $Member += "$Base,"
                }
                
                $F += "# <{0}/{1}>" -f $File.Type, $File.Name
                $F += "# {0}" -f $File.Fullname
                If (!$File.Content)
                {
                    $File.GetContent()
                }
                $F += $File.Content
                $F += "# </{0}/{1}>" -f $File.Type, $File.Name
            }
            $Member[-1] = $Member[-1].TrimEnd(",")

            $F     += "# </Functions>"
            $F     += ""
            $Member | % { $F += $_ }
            $F     += ""
            $F     += "Write-Theme -InputObject `"Module [+] [FightingEntropy(`$([char]960))][$($This.Version)]`" -Palette 2"

            Return $F -join "`n"
        }
        [String[]] Binaries()
        {
            $Out = "PresentationFramework", 
            "System.Runtime.WindowsRuntime",
            "System.IO.Compression", 
            "System.IO.Compression.Filesystem",
            "System.Windows.Forms"

            Return $Out
        }
        [Hashtable] PSDParam()
        {
            Return @{  

                GUID                 = $This.GUID
                Path                 = $This.Root.Manifest
                ModuleVersion        = $This.Version
                Copyright            = $This.Copyright
                CompanyName          = $This.Company
                Author               = $This.Author
                Description          = $This.Description
                RootModule           = $This.Root.File
                RequiredAssemblies   = $This.Binaries()
            }
        }
        Latest()
        {
            $This.Write(2,"Installing [~] $($This.Label())")

            If (![System.IO.Directory]::Exists($This.Root.Resource))
            {
                $This.Root.Resource.Create()
            }

            $String    = "{0}/blob/main/Version/{1}/readme.md?raw=true" -f $This.Source, $This.Version.ToString()
            $Content   = (Invoke-RestMethod $String).Split("`n")
            $List      = @( )

            ForEach ($Line in $Content)
            {
                If ($Line -match "https.+\.zip")
                {
                    $List += $This.ArchiveEntry($Line)
                }
            }

            $Item      = ($List | Sort-Object Real)[-1]

            $This.Update(0,"====[Downloading Latest Archive]====".PadRight(102,"="))
            $This.Update(0,"")
            $This.Update(0,"    Date : $($Item.Date)")
            $This.Update(0,"    Name : $($Item.Name)")
            $This.Update(0,"    Link : $($Item.Link)")
            $This.Update(0,"    Hash : $($Item.Hash)")
            $This.Update(0,"")

            $Src       = "{0}?raw=true" -f $Item.Link
            $Target    = "{0}\{1}" -f $This.Root.Resource.Fullname, $Item.Name

            Start-BitsTransfer -Source $Src -Destination $Target

            $Hash      = Get-FileHash $Target | % Hash
            If ($Item.Hash -notmatch $Hash)
            {
                $This.Update(-1,"Error       [!] Invalid hash")
                [System.IO.File]::Delete($Target)
                Throw $This.Console.Status
            }

            Expand-Archive $Target -DestinationPath $This.Root.Resource -Force
            [System.IO.File]::Delete($Target)
            $This.Manifest.Validate()

            $This.Update(0,"=".PadLeft(102,"="))
            $This.Update(0,"[@] Resource : $($This.Root.Resource)")
            $Ct = $This.Manifest | % { $_.Output.Count + $_.Full().Count }
            $This.Update(0,"               ($Ct) [directories/files]")
            ForEach ($Folder in $This.Manifest.Output)
            {
                $This.Update(0,"-".PadLeft(102,"-"))
                $This.Update(0,("[~] {0} : {1}" -f $Folder.Type.PadRight(9," "), $Folder.Fullname))
                $This.Update(0,"-".PadLeft(102,"-"))
                $This.Update(0," ".PadLeft(102," "))

                ForEach ($File in $Folder.Item)
                {
                    $This.Update(0,"[+] $($File.Name)")
                }

                $This.Update(0," ".PadLeft(102," "))
            }

            $This.Update(0,"-".PadLeft(102,"-"))

            If ($This.Root.Registry.Exists -eq 0)
            {
                $This.InstallItem($This.Root.Registry)
            }

            $This.Update(0,"-".PadLeft(102,"-"))

            $This.UpdateManifest()

            $This.Update(0,"=".PadLeft(102,"="))
            $This.Write(2,"Installed [+] $($This.Label())")
        }
        UpdateManifest()
        {
            $List = $This.Validation()
            $Pull = $List | ? Match -eq 0

            If ($Pull.Count -ne 0)
            {
                ForEach ($ID in "Shortcut","Manifest","File","Module")
                {
                    $Item = $This.Root.$ID
                    If ($Item.Exists)
                    {
                        $This.RemoveItem($Item)
                    }
                }

                ForEach ($File in $Pull)
                {
                    $Folder = $This.Manifest.Output | ? Type -eq $File.Type
                    $Item   = $Folder.Item | ? Name -eq $File.Name
                    $Item.Download()
                    $Item.Write()
                    $Item.Exists = 1
                }

                ForEach ($Item in "Module","File","Manifest","Shortcut")
                {
                    $This.InstallItem($This.Root.$Item)
                }
            }
        }
        [Object] ArchiveEntry([String]$Line)
        {
            Return [MarkdownArchiveEntry]::New($Line)
        }
        [Object] ValidateFile([Object]$File)
        {
            Return [ValidateFile]::New($File)
        }
        [Object[]] Validation()
        {
            Return $This.Manifest.Full() | % { $This.ValidateFile($_) }
        }
        Validate()
        {
            $xList = $This.Validation()
            $This.Validate($xList)
        }
        Validate([Object[]]$xList)
        {
            $This.Write(3,"Validation [~] Module manifest")
            $Ct   = $xList | ? Match -eq 0

            Switch ($Ct.Count)
            {
                {$_ -eq 0}
                {
                    $This.Write(3,"Validation [+] All files passed validation")
                }
                {$_ -ne 0}
                {
                    $This.Write(1,"Validation [!] ($($Ct.Count)) files failed validation")
                }
            }
        }
        [String] ToString()
        {
            Return "<FEModule.ModuleController>"
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 
        { 
            [ModuleController]::New($Mode)
        } 
        1
        {
            [ModuleController]::New(1).GetFolder("Control").Item
        }
        2
        {
            [ModuleController]::New(1).GetFolder("Function").Item
        }
        3
        {
            [ModuleController]::New(1).GetFolder("Graphic").Item
        }
    }
}
