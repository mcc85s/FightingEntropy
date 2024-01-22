<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2024.1.0]                                                        \\
\\  Date       : 2024-01-21 17:18:05                                                                  //
 \\==================================================================================================// 

    FileName   : Get-EventLogProject.ps1
    Solution   : [FightingEntropy()][2024.1.0]
    Purpose    : A subcontroller for the EventLog Utility
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2024-01-21
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-EventLogProject
{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory)][ValidateScript({$_.GetType().Name -match "ThreadSlot"})][Object]$ThreadSlot,
        [Parameter(ParameterSetName=0,Mandatory)][Switch]$New,
        [Parameter(ParameterSetName=1,Mandatory)][Object]$Restore
    )

    Class Percent
    {
        [Uint32]   $Index
        [Uint32]    $Step
        [Uint32]   $Total
        [UInt32] $Percent
        [String]  $String
        Percent([UInt32]$Index,[UInt32]$Step,[Uint32]$Total)
        {
            $This.Index   = $Index
            $This.Step    = $Step
            $This.Total   = $Total
            $This.Calc()
        }
        Calc()
        {
            $Depth        = ([String]$This.Total).Length
            $This.Percent = ($This.Step/$This.Total)*100
            $This.String  = "({0:d$Depth}/{1}) {2:n2}%" -f $This.Step, $This.Total, $This.Percent
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    # // ===================================================================================================
    # // | This is a progress container, meant for dividing the work evenly, though < 100 doesn't work yet |
    # // ===================================================================================================

    Class Progress
    {
        [String]  $Activity
        [String]    $Status
        [UInt32]   $Percent
        [DateTime]   $Start
        [Uint32]     $Total
        [Uint32]      $Step
        [Object[]]    $Slot
        [Uint32[]]   $Range
        Progress([String]$Activity,[UInt32]$Total)
        {
            $This.Activity      = $Activity
            $This.Start         = [DateTime]::Now
            $This.Total         = $Total
            $This.Step          = [Math]::Round($Total/100)
            $This.Slot          = @( )
            ForEach ($X in 0..100)
            {
                $Count          = @($This.Step * $X;$Total)[$X -eq 100]

                $This.AddSlot($X,$Count,$Total) 
            }
            $This.Range         = $This.Slot.Step
            $This.Current()
        }
        AddSlot([UInt32]$Index,[UInt32]$Multiple,[UInt32]$Total)
        {
            $this.Slot         += [Percent]::New($Index,$Multiple,$Total)
        }
        Increment()
        {
            $This.Percent ++
            $This.Current()
        }
        [UInt32] Elapsed()
        {
            Return ([TimeSpan]([DateTime]::Now-$This.Start)).TotalSeconds
        }
        [TimeSpan] Remain()
        {
            $Remain = Switch ($This.Percent)
            {
                0 { 0 } Default { ($This.Elapsed() / $This.Percent) * (100-$This.Percent) }
            }
            
            Return [TimeSpan]::FromSeconds($Remain)
        }
        Current()
        {
            $This.Status = $This.Slot[$This.Percent]
            If ($This.Percent -ne 0)
            {
                $This.Status = "{0} [{1}]" -f $This.Status, $This.Remain()
            }
        }
        SetStatus([Object]$Percent)
        {
            $This.Status  = $Percent
            $This.Percent = $Percent.Percent
            $This.Current()
        }
    }

    Class ProjectProgressIndex
    {
        [UInt32]  $Index
        [UInt32]   $Slot
        [Float] $Percent
        [String] $String
        [Object]   $Time
        [Object] $Remain
        ProjectProgressIndex([UInt32]$Index,[UInt32]$Segment,[UInt32]$Total)
        {
            $This.Index   = $Index
            $This.Slot    = $Index * $Segment
            If ($This.Slot -gt 0)
            {
                $This.Percent = [Math]::Round($This.Slot*100/$Total,2)
            }
            Else
            {
                $This.Percent = 0
            }
            $This.String  = $This.GetString($Total)
        }
        ProjectProgressIndex([Switch]$Last,[UInt32]$Total)
        {
            $This.Index   = 101
            $This.Slot    = $Total
            $This.Percent = 100.00
            $This.String  = $This.GetString($Total)
        }
        [String] GetString([UInt32]$Total)
        {
            Return "({0:n2}%) ({1}/{2})" -f $This.Percent, $This.Slot, $Total
        }
        [String] ToString()
        {
            Return $This.Slot
        }
        [String] Line()
        {
            Return "{0} Elapsed: [{1}], Remain: [{2}]" -f $This.String, $This.Time, $This.Remain
        }
    }

    Class ProjectProgress
    {
        [DateTime]  $Phase
        [UInt32]    $Total
        [UInt32]  $Segment
        [Object]    $Index = @( )
        ProjectProgress([Object]$Work)
        {
            $This.Phase      = [DateTime]::Now
            $This.Total      = $Work.Count
            $This.Segment    = [Math]::Round($This.Total/100)
            0..100           | % { $This.AddIndex($_,$This.Segment,$This.Total) }
            $This.AddLast($This.Total)
        }
        AddIndex([UInt32]$Index,[UInt32]$Segment,[UInt32]$Total)
        {
            $This.Index     += [ProjectProgressIndex]::New($Index,$This.Segment,$This.Total)    
        }
        AddLast([UInt32]$Total)
        {
            [Switch]$Last    = $True
            $Item            = [ProjectProgressIndex]::New($Last,$This.Total)
            $Item.Index      = 101
            $Item.Slot       = $This.Total
            $Item.Percent    = 100.00
            $Item.Time       = $This.Time()
            $Item.Remain     = [Timespan]::FromTicks(1)
            $This.Index     += $Item
        }
        [Object] Time()
        {
            Return [TimeSpan]([DateTime]::Now-$This.Phase)
        }
        [Object] Slot([UInt32]$Token)
        {
            $Item            = $This.Index[$Token/$This.Segment]
            $Item.Time       = $This.Time()
            If ($Item.Index -eq 0)
            {
                $Item.Remain = [Timespan]::FromTicks(1)
            }
            If ($Item.Index -ne 0) 
            { 
                $Item.Remain = ($Item.Time.TotalSeconds / $Item.Percent) * (100-$Item.Percent) | % { [Timespan]::FromSeconds($_) } 
            }
    
            Return $Item
        }
    }

    Class ProjectFileEntry
    {
        [String]  $Name
        [Object] $Entry
        [String]  $Path
        ProjectFileEntry([String]$Name,[Object]$Archive,[String]$Path)
        {
            $This.Name  = $Name
            $This.Entry = $Archive.GetEntry($Name)
            $This.Path  = "$Path\$Name"
        }
        Extract()
        {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($This.Entry,$This.Path,$True)
        }
        [String] ToString()
        {
            Return $This.Path
        }
    }

    Class ProjectConsoleLine
    {
        [UInt32]   $Index
        [String]   $Phase
        [String]    $Type
        [String]    $Time
        [String] $Message
        ProjectConsoleLine([UInt32]$Index,[String]$Phase,[UInt32]$Type,[String]$Time,[String]$Message)
        {
            $This.Index   = $Index
            $This.Phase   = $Phase
            $This.Type    = Switch ($Type) { 0 { "[~]" } 1 { "[+]" } 2 { "[!]" } }
            $This.Time    = $Time
            $This.Message = $Message
        }
        [String] ToString()
        {
            Return @( Switch (!!$This.Message)
            {
                $True  { "{0} {1} {2}" -f $This.Phase, $This.Type, $This.Message }
                $False { "{0} {1} Elapsed: [{2}]" -f $This.Phase, $This.Type, $This.Time }
            })
        }
    }

    Class ProjectConsole
    {
        [Object]    $Time
        [String]   $Phase
        [UInt32]    $Type
        [String] $Message
        [UInt32]   $Count
        [Object]  $Output
        ProjectConsole([Object]$Time)
        {
            $This.Time    = $Time
            $This.Phase   = "Starting"
            $This.Type    = 0
            $This.Message = $Null
            $This.Count   = 0
            $This.Output  = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
    
            $This.Status()
        }
        AddLine([String]$Line)
        {
            $This.Output.Add([ProjectConsoleLine]::New($This.Output.Count,$This.Phase,$This.Type,$This.Time.Elapsed,$Line))
            $This.Count  ++
        }
        [String] Status()
        {
            $This.AddLine($Null)
            Return $This.Last()
        }
        [String] Update([String]$Phase,[String]$Message)
        {
            $This.Phase   = $Phase
            $This.Message = $Message
            $This.AddLine($Message)
            Return $This.Last()
        }
        [String] Update([String]$Phase,[UInt32]$Type,[String]$Message)
        {
            $This.Phase   = $Phase
            $This.Type    = $Type
            $This.Message = $Message
            $This.AddLine($Message)
            Return $This.Last()
        }
        [Object] Last()
        {
            Return $This.Output[$This.Count-1]
        }
        [Object[]] ToString()
        {
            Return @( $This.Output[0..($This.Count-1)] )
        }
    }

    Class ProjectFile
    {
        [UInt32]         $Index
        [String]          $Name
        [String]      $Fullname
        Hidden [String] $Parent
        [Bool]          $Exists
        [Double]        $Length
        [String]          $Size
        ProjectFile([UInt32]$Index,[Object]$File)
        {
            $This.Index    = $Index
            $This.Fullname = $File.Fullname
            $This.Name     = $File.Name
            $This.Parent   = $File.Fullname | Split-Path -Parent
            $This.Exists   = $File.Exists
            $This.Length   = $File.Length
            $This.Update()
        }
        Write([String[]]$In)
        {
            $Out     = $In -join "`n"
            $Bytes   = [Byte[]]([Char[]]$Out)
            $Item    = [System.IO.Filestream]::new($This.Fullname,[System.IO.FileMode]::Append)
            $Item.Write($Bytes,0,$Bytes.Count)
            $Item.Dispose()
            $This.Update()
        }
        Write([String]$In)
        {
            $Out   = $In -join "`n"
            $Bytes = [Byte[]]@([Char[]]$Out)
            $Item  = [System.IO.Filestream]::new($This.Fullname,[System.IO.FileMode]::Append)
            $Item.Write($Bytes,0,$Bytes.Count)
            $Item.Dispose()
            $This.Update()
        }
        Clear()
        {
            $Item = [System.IO.Filestream]::new($This.Fullname,[System.IO.FileMode]::Truncate)
            $Item.Write(0,0,0)
            $Item.Dispose()
            $This.Update()
        }
        [Object] Get()
        {
            $Item = [System.IO.File]::ReadAllLines($This.Fullname)
            $This.Update()
            Return $Item
        }
        [Void] Delete()
        {
            $Item = [System.IO.File]::Delete($This.Fullname)
            $Item.Dispose()
            $This.Update()
        }
        [Void] Update()
        {
            $This.Exists   = [System.IO.File]::Exists($This.Fullname)
            If (!$This.Exists)
            {
                $This.Length   = 0
                $This.Size     = "0.00 KB"
            }
            If ($This.Exists)
            {
                $This.Length   = [System.IO.File]::ReadAllBytes($This.Fullname).Count
                $This.Size     = Switch ($This.Length)
                {
                    {$_ -eq   0 } { "0.00 KB" }
                    {$_ -gt   0 -and $_ -lt 800kb}   { "{0:n2} KB" -f ($This.Length/1KB) }
                    {$_ -ge 800kb -and $_ -lt 800mb} { "{0:n2} MB" -f ($This.Length/1MB) }
                    {$_ -ge 800mb -and $_ -lt 800gb} { "{0:n2} GB" -f ($This.Length/1GB) }
                    {$_ -ge 800gb }                  { "{0:n2} TB" -f ($This.Length/1TB) }
                }
            }
        }
        [String] ToString()
        {
            Return $This.FullName
        }
    }

    Class ProjectFolder
    {
        [UInt32]             $Rank
        [String]             $Name
        [String]         $Fullname
        [String]           $Parent
        [Bool]             $Exists
        [UInt32]            $Count
        Hidden [Double] $SizeBytes
        [String]             $Size
        Hidden [Hashtable]  $Index = @{ }
        Hidden [Hashtable]   $Hash = @{ }
        [Object]         $Children = @( )
        ProjectFolder([UInt32]$Rank,[Object]$Folder)
        {
            $This.Rank     = $Rank
            $This.Name     = $Folder.Name
            $This.Fullname = $Folder.Fullname
            $This.Parent   = $Folder.Parent.Fullname
            $This.Update()
        }
        [Void] Update()
        {
            $This.Exists        = [System.IO.Directory]::Exists($This.Fullname)
            $This.SizeBytes     = 0
            $This.Size          = "0.00 KB"
            $This.Hash          = @{ }
            $This.Index         = @{ }
            If ($This.Exists)
            {
                $This.Children  = @([System.IO.DirectoryInfo]::new($This.FullName).EnumerateFileSystemInfos()) | Sort-Object Name
                $This.Count     = $This.Children.Count
                If ($This.Count -gt 0)
                {
                    $C = 0
                    $X = 0
                    Do
                    {
                        $This.Hash.Add($This.Children[$C].Name,$This.Children[$C])
                        $This.Index.Add($This.Children[$C],$C)
                        $X = $X + $This.Children[$C].Length
                        $C ++
                    }
                    Until ($C -eq $This.Count)
                    $This.SizeBytes = [Double]$X
                }
                $This.Size      = $This.GetSize($This.SizeBytes)
            }
        }
        [String] GetSize([Double]$Size)
        {
            Return @( Switch ($Size)
            {
                {$_ -eq   0 } { "0.00 KB" }
                {$_ -gt   0 -and $_ -lt 800kb}   { "{0:n2} KB" -f ($_/1KB) }
                {$_ -ge 800kb -and $_ -lt 800mb} { "{0:n2} MB" -f ($_/1MB) }
                {$_ -ge 800mb -and $_ -lt 800gb} { "{0:n2} GB" -f ($_/1GB) }
                {$_ -ge 800gb }                  { "{0:n2} TB" -f ($_/1TB) }
            })
        }
        Create([String]$Name)
        {
            $Path           = $This.Fullname, $Name -join '\'
            If (![System.IO.File]::Exists($Path))
            {
                [System.IO.File]::Create($Path).Dispose()
                [Console]::WriteLine("Created [+] ($($Name.Count)) item(s).")
            }
            Else
            {
                [Console]::WriteLine("Exception [!] ($($Name.Count)) exists.")
            }
            $This.Update()
        }
        Create([Object[]]$Name)
        {
            If ($Name.Count -gt 1)
            {
                $Work    = @(ForEach ($X in 0..($Name.Count-1)) { $This.Fullname, $Name[$X] -join "\" })
                $Segment = [Math]::Round($Work.Count/100)
                $Slot    = 0..($Work.Count-1) | ? { $_ % $Segment -eq 0 }
                ForEach ($X in 0..($Work.Count-1))
                {
                    [System.IO.File]::Create($Work[$X]).Dispose()
                    If ($X -in $Slot)
                    {
                        $Percent = ($X*100/$Work.Count)
                        $String  = "({0:n2}%) ({1}/{2})" -f $Percent, $X, $Work.Count
                        [Console]::WriteLine("Creating [~] $String")
                    }
                }
            }
            Else
            {
                [System.IO.File]::Create("$($This.Fullname)\$Name").Dispose()
            }
            $This.Update()
            [Console]::WriteLine("Created [+] ($($Name.Count)) item(s).")
        }
        Delete([String]$Name)
        {
            $Item = $This.File($Name)
            $Item.Delete()
            $This.Update()
            [Console]::WriteLine("Deleted [$Name]")
        }
        [Object] File([String]$Name)
        {
            $File = $This.Hash[$Name]
            If (!$File)
            {
                Throw "Invalid file"
            }
            Return [ProjectFile]::New($This.Index[$Name],$File)
        }
        Flush()
        {
            If ($This.Exists)
            {
                [Console]::WriteLine("Enumerating [~] files")
                $Work = @([System.IO.DirectoryInfo]::new($This.FullName).EnumerateFileSystemInfos()) | Sort-Object LastWriteTime
                If ($Work.Count -gt 1)
                {
                    $Segment = [Math]::Round($Work.Count/100)
                    $Slot    = 0..($Work.Count-1) | ? { $_ % $Segment -eq 0 }
                    ForEach ($X in 0..($Work.Count-1))
                    {
                        $Work[$X].Delete()
                        If ($X -in $Slot)
                        {
                            $Percent = ($X*100/$Work.Count)
                            $String  = "({0:n2}%) ({1}/{2})" -f $Percent, $X, $Work.Count
                            [Console]::WriteLine("Deleting [~] $String")
                        }
                    }
                }
                If ($Work.Count -eq 1)
                {
                    $Work.Delete()
                }
                [Console]::WriteLine("All files deleted")
            }
            $This.Update()
        }
        [String] ToString()
        {
            Return $This.Fullname
        }
    }

    Class ProjectBase
    {
        [String]       $Name
        [String]   $Fullname
        [String]     $Parent
        [Bool]       $Exists
        [UInt32]      $Count
        [DateTime]     $Date
        [Object]    $Folders = @( )
        ProjectBase([String]$Path)
        {
            $This.Parent            = $Path | Split-Path -Parent
            If (![System.IO.Directory]::Exists($This.Parent))
            {
                Throw "Invalid path"
                $This.Parent        = $Null
            }
            $This.Name              = $Path | Split-Path -Leaf
            $This.FullName          = $Path
            If ([System.IO.Directory]::Exists($Path))
            {
                Throw "This path already exists"
            }
            ForEach ($Entry in "Master","Logs","Events","Threads")
            {
                [System.IO.Directory]::CreateDirectory("$($This.Fullname)\$Entry")
            }
            $This.Update()
        }
        Static [String[]] Subfolders()
        {
            Return "Master","Logs","Events","Threads"
        }
        [Void] Update()
        {
            $This.Exists            = [System.IO.Directory]::Exists($This.Fullname)
            $This.Date              = [System.IO.Directory]::GetCreationTime($This.Fullname)
            $This.Folders           = @( )
            If ($This.Exists)
            {
                $Directories        = @([System.IO.DirectoryInfo]::new($This.Fullname).EnumerateDirectories())
                $This.Count         = $Directories.Count
                If ($This.Count -gt 0)
                {
                    ForEach ($Folder in $Directories)
                    {
                        $This.Folders += [ProjectFolder]::New($This.Folders.Count,$Folder)
                    }
                }
            }
        }
        [Object] Slot([String]$Slot)
        {
            Return $This.Folders | ? Name -eq $Slot
        }
        Flush()
        {
            $This.Update()
            ForEach ($Folder in $This.Folders)
            {
                $Folder.Flush()
            }
        }
        [String] ToString()
        {
            Return $This.Fullname
        }
    }

    Class Project
    {
        [Object]           $Console
        [Object]              $Time
        [DateTime]           $Start
        [Object]            $System
        [String]       $DisplayName
        [UInt32]           $Threads
        [Guid]                $Guid
        [String]              $Base
        [Object]              $Logs = @( )
        [Object]            $Output = @( )
        Hidden [Object]    $Archive
        Hidden [Object]        $Zip
        Hidden [Object] $ThreadSlot
        Hidden [UInt32] $MaxThreads
        Project()
        {
            $This.Time           = [System.Diagnostics.Stopwatch]::New()
            $This.Console        = [ProjectConsole]::New($This.Time)
        }
        Prime([Object]$Archive,[Object]$ThreadSlot)
        {
            If (!$Archive)
            {
                $This.Error("Archive entry was (null/invalid)")
            }
            ElseIf (!$ThreadSlot)
            {
                $This.Error("ThreadSlot entry was (null/invalid")
            }
            Else
            {
                $This.Archive    = $Archive
                $This.ThreadSlot = $ThreadSlot
                $This.MaxThreads = $ThreadSlot.MaxThreads
            }
        }
        GetEventLogs()
        {
            $This.Time.Start()
            $This.Update("(0.0) Loading", 0, "System snapshot details")

            $This.System         = Get-SystemDetails
            $This.Start          = $This.System.Snapshot.Start
            $This.DisplayName    = $This.System.Snapshot.DisplayName

            # -------------------------------------------------- #
            # MaxThreads needs to consider (2) possible sources: #
            #   1) the current system running the tool           #
            #   2) the next system that will load the archive    #
            # -------------------------------------------------- #

            If (!$This.Threads)
            {
                $This.Threads    = $This.System.Processor.Output.Threads | Measure-Object -Sum | % Sum
            }
    
            If ($This.Threads -lt 2)
            {
                $This.Error("CPU only has (1) thread (selected/available)")
            }
    
            # ------------------------------------------------------------------------ #
            # System snapshot created a unique Guid, create a temporary base directory #
            # ------------------------------------------------------------------------ #

            $This.Guid           = $This.System.Snapshot.Guid
            $This.Base           = [ProjectBase]::New([String](Get-Item Env:\Temp).Value,$This.System.Snapshot.Guid)
    
            $This.Update("(0.1) Created", 1, "Base directory")
            
            # ------------------------------------------------------------------ #
            # Loads the names of each provider log from Get-SystemDetails cmdlet #
            # ------------------------------------------------------------------ #

            $Providers           = $This.System.LogProviders.Output
            $Slot                = $This.Slot("Threads")
            $Depth               = ([String]$This.MaxThreads).Length
            $Names               = 0..($This.MaxThreads-1) | % { "{0:d$Depth}.txt" -f $_ }
            $Slot.Create($Names)

            ForEach ($X in 0..($This.MaxThreads-1))
            {
                $File            = $Slot.File($Names[$X])
                $Value           = 0..($Providers.Count-1) | ? { $_ % $This.MaxThreads -eq $X } | % { $_, $Providers[$_].Value -join ',' }
                $File.Write($Value -join "`n")
                $Slot.Update()
            }
            $This.Update("(0.2) Prepared",1,"Event log collection split between threads")
        }
        Import()
        {
            $This.Time.Start()
    
            # Restore the zip file
            # --------------------
            $This.Update("(0.0) Testing",0,"Zip file path input")
            If ($This.Archive.State -ne 0)
            {
                Throw [System.Windows.MessageBox]::Show($This.Archive.Status)
            }
            $This.Base       = $This.Archive.Path -Replace ".zip",""
            $This.Update("(0.0) Tested",1,$This.Archive.Status)
    
            # Zip path exists, is it a zip file?
            # ----------------------------------
            $This.Update("(0.1) Opening",0,"Zip file")
            $This.Archive.Open()
            If ($This.Archive.State -ne 1)
            {
                Throw [System.Windows.MessageBox]::Show($This.Archive.Status)
            }
            $This.Update("(0.1) Opened",1,$This.Archive.Status)
    
            # Get Entries
            # -----------
            $This.Update("(0.2) Populating",0,"Table Entries")
            $This.Archive.PopulateEntryTable()
            $This.Update("(0.2) Populated",1,"Table Entries")
            
            # Master file
            # -----------
            $This.Update("(0.2) Extracting",0,"Master.txt")
            $File                = $This.Archive.File("Master.txt")
            $Stream              = $File.Open()
            $Reader              = [System.IO.StreamReader]::New($Stream)
            $Master              = $Reader.ReadToEnd()
            $Reader.Close()
            $Stream.Close()
            $This.Update("(0.2) Extracted",1,"Master.txt")
            
            # Restore system details
            # ----------------------
            $This.Update("(0.3) Restoring",0,"(Captured) system details")
            If ($Master)
            {
                $This.System      = $Master | Get-SystemDetails
                If (!$This.System)
                {
                    Throw [System.Windows.MessageBox]::Show($This.Error("Failed to restore captured system details"))
                }
                $This.Start       = $This.System.Snapshot.Start
                $This.DisplayName = $This.System.Snapshot.DisplayName
                $This.Threads     = $This.System.Processor.Output.Threads
                $This.Guid        = $This.System.Snapshot.Guid
            }
            $This.Update("(0.3) Restored",1,"System details")
    
            # Extract Logs.txt/Provider Configurations
            # ----------------------------------------
            $This.Update("(0.4) Extracting",0,"Logs.txt")
            $File                 = $This.Archive.File("Logs.txt")
            $Stream               = $File.Open()
            $Reader               = [System.IO.StreamReader]::New($Stream)
            $LogsFile             = $Reader.ReadToEnd() | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Update("(0.4) Extracted",1,"Logs.txt")
    
            # Process the log files
            # ---------------------
            $This.Update("(0.5) Restoring",0,"(Captured) Event log providers")
            $This.Logs            = @( )
            $Stash                = @{ }
            $Hash                 = @{ }
            ForEach ($X in 0..($LogsFile.Count-1))
            {
                $Item             = Get-EventLogConfigExtension -Config $LogsFile[$X]
                If (!$Item)
                {
                    $This.Error("Unable to retrieve log configuration extension for Logs.txt[$X]")
                }
                $Item.Output      = @( )
                $Stash.Add($Item.LogName,@{ })
                $This.Logs       += $Item
            }
            $This.Update("(0.5) Restored",1,"Event log providers")
    
            # Process the events
            # ------------------
            $This.Update("(0.6) Importing",0,"(Captured) Events")
            $Events               = $This.Archive.Zip.Entries | ? Name -notmatch "(Master|Logs).txt"
            $Id                   = [ProjectProgress]::New($Events)
            $This.Update("(1.0) Importing",0,"(0.00%) Events: ($($Id.Total)) found.")
            ForEach ($X in 0..($Id.Total-1))
            {
                $Item             = Get-EventLogRecordExtension -Index $X -Entry $Events[$X]
                $Hash.Add($X,$Item)
                $Stash[$Item.LogName].Add($Stash[$Item.LogName].Count,$X)
                If ($X -in $Id.Index.Slot)
                {
                    $This.Update("(1.0) Importing",0,$Id.Slot($X).Line())
                }
                If ($X -eq $Id.Total)
                {
                    $This.Update("(1.0) Importing",0,$Id.Index[-1].Line())
                }
            }
            $This.Update("(1.0) Imported",1,"(100.00%) [+] Events: ($($Id.Total)) found.")
            $This.Output          = $Hash[0..($Hash.Count-1)]
    
            # Dispose the zip file
            $This.Archive.Zip.Dispose()
    
            # Sort the logs
            $This.Update("(1.1) Restoring",0,"Events for each log provider")
    
            $Id                   = [ProjectProgress]::New($This.Logs)
            $This.Update("(1.1) Sorting",0,"(0.00%) [~] Logs: ($($Id.Total)) found.")
            ForEach ($X in 0..($Id.Total-1))
            {
                $Name             = $This.Logs[$X].LogName
                $This.Logs[$X].Output  = Switch ($Stash[$Name].Count)
                {
                    0 { @( ) } 1 { @($This.Output[$Stash[$Name][0]]) } Default { @($This.Output[$Stash[$Name][0..($Stash[$Name].Count-1)]]) }
                }
                $This.Logs[$X].Total   = $This.Logs[$X].Output.Count
                If ($X -in $Id.Index.Slot)
                {
                    $This.Update("(1.1) Sorting",0,$Id.Slot($X).Line())
                }
                If ($X -eq $Id.Total)
                {
                    $This.Update("(1.1) Sorting",0,$Id.Index[-1].Line())
                }
            }
            $This.Update("(1.1) Sorted",1,"(100.00%) [+] Logs: ($($Id.Total)) found.")
            $This.Time.Stop()
        }
        Current()
        {
            $This.Console.Status()
        }
        Update([String]$Phase,[String]$Message)
        {
            $This.Console.Update($Phase,$Message)
        }
        Update([String]$Phase,[UInt32]$Type,[String]$Message)
        {
            $This.Console.Update($Phase,$Type,$Message)
        }
        [Void] Error([String]$Message)
        {
            $This.Update("Exception", 2, $Message)
            $This.Console.ToString()
        }
        [Object] Slot([String]$Slot)
        {
            Return $This.Base.Folders | ? Name -eq $Slot
        }
        [Object] Establish([String]$Base,[String]$Name)
        {
            Return [ProjectBase]::New("$Base\$Name")
        }
        [Object] Progress([Object]$Work)
        {
            Return [ProjectProgress]::New($Work)
        }
        [Object[]] GetConsole()
        {
            Return $This.Console.Output[0..($This.Console.Output.Count-1)]
        }
        [String] ToString()
        {
            Return "(EventLogs-UtilityRunspace[Project])"
        }
    }

    Class ShellPercent
    {
        [Uint32]   $Index
        [Uint32]    $Step
        [Uint32]   $Total
        [UInt32] $Percent
        [String]  $String
        ShellPercent([UInt32]$Index,[UInt32]$Step,[Uint32]$Total)
        {
            $This.Index   = $Index
            $This.Step    = $Step
            $This.Total   = $Total
            $This.Calc()
        }
        Calc()
        {
            $Depth        = ([String]$This.Total).Length
            $This.Percent = ($This.Step/$This.Total)*100
            $This.String  = "({0:d$Depth}/{1}) {2:n2}%" -f $This.Step, $This.Total, $This.Percent
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    # // ===================================================================================================
    # // | This is a progress container, meant for dividing the work evenly, though < 100 doesn't work yet |
    # // ===================================================================================================

    Class ShellProgress
    {
        [String] $Activity
        [String]   $Status
        [UInt32]  $Percent
        [Uint32]    $Total
        [Uint32]    $Depth
        [Uint32]     $Step
        [Object[]]   $Slot
        [Uint32[]]  $Range
        ShellProgress([String]$Activity,[UInt32]$Total)
        {
            $This.Activity      = $Activity
            $This.Total         = $Total
            $This.Step          = [Math]::Round($Total/100)
            $This.Slot          = @( )
            ForEach ($X in 0..100)
            {
                $Count          = @($This.Step * $X;$Total)[$X -eq 100]

                $This.AddSlot($X,$Count,$Total) 
            }
            $This.Range         = $This.Slot.Step
            $This.Current()
        }
        AddSlot([UInt32]$Index,[UInt32]$Multiple,[UInt32]$Total)
        {
            $this.Slot         += [ShellPercent]::New($Index,$Multiple,$Total)
        }
        Increment()
        {
            $This.Percent ++
            $This.Current()
        }
        Current()
        {
            $This.Status = $This.Slot[$This.Percent]
        }
    }
    
    Class Project2
    {
        [Object]           $Console
        [Object]              $Time
        [DateTime]           $Start
        [Object]            $System
        [String]       $DisplayName
        [UInt32]           $Threads
        [Guid]                $Guid
        [ProjectBase]         $Base
        [Object]              $Logs = @( )
        [Object]            $Output = @( )
        Hidden [Object]    $Archive
        Hidden [Object]        $Zip
        Hidden [Object] $ThreadSlot
        Hidden [UInt32] $MaxThreads
        Project2([Object]$ThreadSlot)
        {
            # Start system snapshot, count threads / max runspace pool size
            $This.Time           = [System.Diagnostics.Stopwatch]::New()
            $This.Console        = [ProjectConsole]::New($This.Time)
            $This.Archive        = Get-EventLogArchive -New
            $This.ThreadSlot     = $ThreadSlot
            $This.MaxThreads     = $ThreadSlot.Count
        }
        Init()
        {
            $This.Time.Start()
    
            $This.Update("(0.0) Loading",0,"System snapshot details")
            $This.System        = Get-SystemDetails
            $This.Start         = $This.System.Snapshot.Start
            $This.DisplayName   = $This.System.Snapshot.DisplayName
            If (!$This.Threads)
            {
                $This.Threads   = $This.System.Processor.Output.Threads | Measure-Object -Sum | % Sum
            }
    
            If ($This.Threads -lt 2)
            {
                $This.Error("CPU only has (1) thread (selected/available)")
            }
    
            # System snapshot has already created a Guid, to create a new folder for the threads
            $This.Guid          = $This.System.Snapshot.Guid
            $This.Base          = $This.Establish([Environment]::GetEnvironmentVariable("temp"),$This.Guid)
    
            $This.Update("(0.1) Created",1,"Base directory")
            $This.Providers()
        }
        [Object] Establish([String]$Base,[String]$Name)
        {
            Return [ProjectBase]::New("$Base\$Name")
        }
        Providers()
        {
            # Loads the provider names
            $Providers        = $This.System.LogProviders.Output
            $Slot             = $This.Slot("Threads")
            $Depth            = ([String]$This.MaxThreads).Length
            $Names            = 0..($This.MaxThreads-1) | % { "{0:d$Depth}.txt" -f $_ }
            $Slot.Create($Names)
            ForEach ($X in 0..($This.MaxThreads-1))
            {
                $File         = $Slot.File($Names[$X])
                $Value        = 0..($Providers.Count-1) | ? { $_ % $This.MaxThreads -eq $X } | % { $_,$Providers[$_].Value -join ',' }
                $File.Write($Value -join "`n")
                $Slot.Update()
            }
            $This.Update("(0.2) Prepared",1,"Event log collection split between threads")
        }

        [Object] Slot([String]$Slot)
        {
            Return $This.Base.Folders | ? Name -eq $Slot
        }
        Current()
        {
            $This.Console.Status()
        }
        Update([String]$Phase,[String]$Message)
        {
            $This.Console.Update($Phase,$Message)
        }
        Update([String]$Phase,[UInt32]$Type,[String]$Message)
        {
            $This.Console.Update($Phase,$Type,$Message)
        }
        [Void] Error([String]$Message)
        {
            $This.Update("Exception",2,$Message)
            Throw $This.Console.ToString()
        }
        SaveMaster()
        {
            $Value        = $This.System.GetOutput()
            $Slot         = $This.Slot("Master")
            $Slot.Create("Master.txt")
            $File         = $Slot.File("Master.txt")
            $File.Write($Value -join "`n")
            $This.Update("Success",1,"Master file: [$File], Size: [$($File.Size)]")
        }
        SaveLogs()
        {
            $Value         = $This.Logs | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,
            MaximumSizeInBytes,Maximum,Current,LogMode,OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,
            ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,ProviderControlGuid | ConvertTo-Json
            
            $Slot          = $This.Slot("Logs")
            $Slot.Create("Logs.txt")
            $File          = $Slot.File("Logs.txt")
            $File.Write($Value)
            $This.Update("Success",1,"Log config file: [$File], Size: [$($File.Size)]")
        }
        [String] Destination()
        {
            Return "{0}\{1}.zip" -f ($This.Base | Split-Path -Parent), $This.DisplayName
        }
        [Object] Progress([String]$Activity,[UInt32]$Count)
        {
            Return [Progress]::New($Activity,$Count)
        }
        Delete()
        {
            $This.Update("Terminating",2,"Process was instructed to be deleted")
            $This.Base.Flush()
            $This.Start         = [DateTime]::FromOADate(1)
            $This.System        = $Null
            $This.DisplayName   = $Null
            $This.Guid          = [Guid]::Empty
            $This.Time          = $Null
            $This.Threads       = $Null
            $This.Base          = $Null
            $This.Logs          = $Null
            $This.Output        = $Null
            $This.GetConsole()
        }
        [Object[]] GetConsole()
        {
            Return @( $This.Console.GetOutput() )
        }
        [Object] ToString()
        {
            Return $This
        }
    }

    Switch ($Pscmdlet.ParameterSetName)
    {
        0 
        { 
            [Project2]::New($ThreadSlot)                 
        }
        1 
        { 
            [ProjectRestore]::New($ThreadSlot,$Restore) 
        }
    }
}
