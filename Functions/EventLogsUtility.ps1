<#
.SYNOPSIS
        Allows for getting/viewing and exporting system snapshot and event viewer logs for 
        a current or target Windows system.

.DESCRIPTION
        Attempting to combine PowerShell class structures with Extensible Application
        Markup Language + Multithreading & PowerShell Runspaces, and various system
        management capabilities for accessing any given Windows' system's event logs.
        Also includes a customized system snapshot utility that can export a 1) system
        state, 2) event logs, 3) other things that are planned, but not yet implemented. 
        System snapshot allows many properties from many WMI/CIM objects to be added to
        a series of property sheets that automatically scale proportionally to multiple
        1) processors, 2) disks, 3) partitions, 4) NIC's, and the tables are able to be
        saved to a file that can be used to import on another given system.

        Still a work in progress.
.LINK
.NOTES
          FileName: EventLogsUtility.ps1
          Solution: FightingEntropy Module
          Purpose: For exporting all of a systems event logs
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-04-08
          Modified: 2022-05-01
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression.Filesystem, System.Windows.Forms, PresentationFramework

# ______________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__[ <Functions> ]__/
#                                                                           ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#\__________________________________              ______________________________________________
Function Get-EventLogConfigExtension             #\_[ Extracts event log configuration files ]_/
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][UInt32]$Rank,
        [Parameter(Mandatory,ParameterSetName=0)][String]$Name,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Config)

    Class EventLogConfigExtension
    {
        [UInt32] $Rank
        [String] $LogName
        [Object] $LogType
        [Object] $LogIsolation
        [Boolean] $IsEnabled
        [Boolean] $IsClassicLog
        Hidden [String] $SecurityDescriptor
        [String] $LogFilePath
        Hidden [Int64] $MaximumSizeInBytes
        [Object] $Maximum
        [Object] $Current
        [Object] $LogMode
        Hidden [String] $OwningProviderName
        [Object] $ProviderNames
        Hidden [Object] $ProviderLevel
        Hidden [Object] $ProviderKeywords
        Hidden [Object] $ProviderBufferSize
        Hidden [Object] $ProviderMinimumNumberOfBuffers
        Hidden [Object] $ProviderMaximumNumberOfBuffers
        Hidden [Object] $ProviderLatency
        Hidden [Object] $ProviderControlGuid
        Hidden [Object[]] $EventLogRecord
        [Object[]] $Output
        [UInt32] $Total
        EventLogConfigExtension([UInt32]$Rank,[Object]$Name)
        {
            $This.Rank                           = $Rank
            $Event                               = [System.Diagnostics.Eventing.Reader.EventLogConfiguration]::New($Name)
            $This.LogName                        = $Event.LogName 
            $This.LogType                        = $Event.LogType 
            $This.LogIsolation                   = $Event.LogIsolation 
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath -Replace "%SystemRoot%", [Environment]::GetEnvironmentVariable("SystemRoot")
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = "{0:n2} MB" -f ($Event.MaximumSizeInBytes/1MB) 
            $This.Current                        = If (!(Test-Path $This.LogFilePath)) { "0.00 MB" } Else { "{0:n2} MB" -f (Get-Item $This.LogFilePath | % { $_.Length/1MB }) }
            $This.LogMode                        = $Event.LogMode
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        EventLogConfigExtension([Object]$Event)
        {
            $This.Rank                           = $Event.Rank
            $This.Logname                        = $Event.LogName
            $This.LogType                        = $This.GetLogType($Event.LogType)
            $This.LogIsolation                   = $This.GetLogIsolation($Event.LogIsolation)
            $This.IsEnabled                      = $Event.IsEnabled 
            $This.IsClassicLog                   = $Event.IsClassicLog 
            $This.SecurityDescriptor             = $Event.SecurityDescriptor
            $This.LogFilePath                    = $Event.LogFilePath 
            $This.MaximumSizeInBytes             = $Event.MaximumSizeInBytes
            $This.Maximum                        = $Event.Maximum
            $This.Current                        = $Event.Current
            $This.LogMode                        = $This.GetLogMode($Event.LogMode)
            $This.OwningProviderName             = $Event.OwningProviderName
            $This.ProviderNames                  = $Event.ProviderNames 
            $This.ProviderLevel                  = $Event.ProviderLevel 
            $This.ProviderKeywords               = $Event.ProviderKeywords 
            $This.ProviderBufferSize             = $Event.ProviderBufferSize 
            $This.ProviderMinimumNumberOfBuffers = $Event.ProviderMinimumNumberOfBuffers 
            $This.ProviderMaximumNumberOfBuffers = $Event.ProviderMaximumNumberOfBuffers 
            $This.ProviderLatency                = $Event.ProviderLatency 
            $This.ProviderControlGuid            = $Event.ProviderControlGuid
        }
        GetEventLogRecord()
        {
            $This.Output = Get-WinEvent -Path $This.LogFilePath -EA 0 | Sort-Object TimeCreated
            $This.Total  = $This.Output.Count
            $Depth       = ([String]$This.Total.Count).Length
            If ($This.Total -gt 0)
            {
                $C = 0
                ForEach ($Record in $This.Output)
                {
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    Index -Value $Null
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Rank -Value $C 
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name    LogId -Value $This.Rank
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name DateTime -Value $Record.TimeCreated
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Date -Value $Record.TimeCreated.ToString("yyyy-MMdd-HHMMss")
                    Add-Member -InputObject $Record -MemberType NoteProperty -Name     Name -Value ("$($Record.Date)-$($This.Rank)-{0:d$Depth}" -f $C)
                    $C ++
                }
            }
        }
        [Object] GetLogType([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogType]::Administrative }
                1 { [System.Diagnostics.Eventing.Reader.EventLogType]::Operational }
                2 { [System.Diagnostics.Eventing.Reader.EventLogType]::Analytical }
                3 { [System.Diagnostics.Eventing.Reader.EventLogType]::Debug }  
            }
            Return $Return
        }
        [Object] GetLogIsolation([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Application }
                1 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::System }
                2 { [System.Diagnostics.Eventing.Reader.EventLogIsolation]::Custom }
            }
            Return $Return
        }
        [Object] GetLogMode([UInt32]$Index)
        {
            $Return = Switch ($Index)
            {
                0 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular   }
                1 { [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup }
                2 { [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain     }
            }
            Return $Return
        }
        [Object] Config()
        {
            Return $This | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,MaximumSizeInBytes,Maximum,Current,LogMode,
            OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,
            ProviderControlGuid
        }
        [String] ToString()
        {
            Return "({0}/{1}/{2})" -f $This.Rank, $This.LogName, $This.Total
        }
    }
    
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogConfigExtension]::New($Rank,$Name) }
        1 { [EventLogConfigExtension]::New($Config)     }
    }
}
#\__________________________________                          __________________________________
Function Get-EventLogRecordExtension                         #\_[ Extracts event log records ]_/
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][Object]$Record,
        [Parameter(Mandatory,ParameterSetName=1)][UInt32]$Index,
        [Parameter(Mandatory,ParameterSetName=1)][Object]$Entry)

    Class EventLogRecordExtension
    {
        [UInt32]   $Index
        Hidden [String] $Name
        Hidden [Object] $DateTime
        [String]   $Date
        [String]   $Log
        [UInt32]   $Rank
        [String]   $Provider
        [UInt32]   $Id
        [String]   $Type
        [String]   $Message
        Hidden [String[]] $Content
        Hidden [Object] $Version
        Hidden [Object] $Qualifiers
        Hidden [Object] $Level
        Hidden [Object] $Task
        Hidden [Object] $Opcode
        Hidden [Object] $Keywords
        Hidden [Object] $RecordId
        Hidden [Object] $ProviderId
        Hidden [Object] $LogName
        Hidden [Object] $ProcessId
        Hidden [Object] $ThreadId
        Hidden [Object] $MachineName
        Hidden [Object] $UserID
        Hidden [Object] $ActivityID
        Hidden [Object] $RelatedActivityID
        Hidden [Object] $ContainerLog
        Hidden [Object] $MatchedQueryIds
        Hidden [Object] $Bookmark
        Hidden [Object] $OpcodeDisplayName
        Hidden [Object] $TaskDisplayName
        Hidden [Object] $KeywordsDisplayNames
        Hidden [Object] $Properties
        EventLogRecordExtension([Object]$Record)
        {
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.ProviderName
            $This.DateTime    = $Record.TimeCreated
            $This.Date        = $Record.Date
            $This.Log         = $Record.LogId
            $This.Id          = $Record.Id
            $This.Type        = $Record.LevelDisplayName
            $This.InsertEvent($Record)
        }
        EventLogRecordExtension([UInt32]$Index,[Object]$Entry)
        {
            $Stream           = $Entry.Open()
            $Reader           = [System.IO.StreamReader]::New($Stream)
            $RecordEntry      = $Reader.ReadToEnd() 
            $Record           = $RecordEntry | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Index       = $Record.Index
            $This.Name        = $Record.Name
            $This.DateTime    = [DateTime]$Record.DateTime
            $This.Date        = $Record.Date
            $This.Log         = $Record.Log
            $This.Rank        = $Record.Rank
            $This.Provider    = $Record.Provider
            $This.Id          = $Record.Id
            $This.Type        = $Record.Type
            $This.InsertEvent($Record)
        }
        InsertEvent([Object]$Record)
        {
            $FullMessage   = $Record.Message -Split "`n"
            Switch ($FullMessage.Count)
            {
                {$_ -gt 1}
                {
                    $This.Message  = $FullMessage[0] -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 1}
                {
                    $This.Message  = $FullMessage -Replace [char]13,""
                    $This.Content  = $FullMessage -Replace [char]13,""
                }
                {$_ -eq 0}
                {
                    $This.Message  = "-"
                    $This.Content  = "-"
                }
            }
            $This.Version              = $Record.Version
            $This.Qualifiers           = $Record.Qualifiers
            $This.Level                = $Record.Level
            $This.Task                 = $Record.Task
            $This.Opcode               = $Record.Opcode
            $This.Keywords             = $Record.Keywords
            $This.RecordId             = $Record.RecordId
            $This.ProviderId           = $Record.ProviderId
            $This.LogName              = $Record.LogName
            $This.ProcessId            = $Record.ProcessId
            $This.ThreadId             = $Record.ThreadId
            $This.MachineName          = $Record.MachineName
            $This.UserID               = $Record.UserId
            $This.ActivityID           = $Record.ActivityId
            $This.RelatedActivityID    = $Record.RelatedActivityID
            $This.ContainerLog         = $Record.ContainerLog
            $This.MatchedQueryIds      = @($Record.MatchedQueryIds)
            $This.Bookmark             = $Record.Bookmark
            $This.OpcodeDisplayName    = $Record.OpcodeDisplayName
            $This.TaskDisplayName      = $Record.TaskDisplayName
            $This.KeywordsDisplayNames = @($Record.KeywordsDisplayNames)
            $This.Properties           = @($Record.Properties.Value)
        }
        [Object] Export()
        {
            Return @( $This | ConvertTo-Json )
        }
        [Object] Config()
        {
            Return $This | Select-Object Index,Name,DateTime,Date,Log,Rank,Provider,Id,Type,Message,Content,
            Version,Qualifiers,Level,Task,Opcode,Keywords,RecordId,ProviderId,LogName,ProcessId,ThreadId,MachineName,
            UserID,ActivityID,RelatedActivityID,ContainerLog,MatchedQueryIds,Bookmark,OpcodeDisplayName,TaskDisplayName,
            KeywordsDisplayNames,Properties
        }
        [Void] SetContent([String]$Path)
        {
            [System.IO.File]::WriteAllLines($Path,$This.Export())
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogRecordExtension]::New($Record) }
        1 { [EventLogRecordExtension]::New(0,$Entry) }
    }
}
#\________________________                      ________________________________________________
Function Get-SystemDetails                     #\_[ Gathers, formats, and parses system info ]_/
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(ParameterSetName=1)][String]$Path) 

    # Formatting classes
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

    # This takes a snapshot of the system with date/time, guid, etc.
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

    # Bios Information for the system this tool is run on
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

    # Operating system information for the system this tool is run on
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

    # Computer system information for the system this tool is run on
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

    # Processor information for the system this tool is run on
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

    # Drive/partition information for the system this tool is run on.
    Class Partition
    {
        [String]      $Type
        [String]      $Name
        [String]      $Size
        [Bool]        $Boot
        [Bool]     $Primary
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
            Return "({0} {1}) {2}" -f $This.Type, $This.Size, $This.Name
        }
    }

    # Extended information for hard drives
    Class Disk
    {
        Hidden [UInt32] $Mode
        Hidden [UInt32] $Rank
        [UInt32] $Index
        [String] $Name
        [String] $DriveLetter
        [String] $Description
        [String] $Filesystem
        [String] $VolumeName
        [String] $VolumeSerial
        Hidden [UInt64] $FreespaceBytes
        [String] $Freespace
        Hidden [UInt64] $UsedBytes
        [String] $Used
        Hidden [UInt64] $SizeBytes
        [String] $Size
        [Bool] $Compressed
        [String] $Disk
        [String] $Model
        [String] $Serial
        [String] $PartitionStyle
        [String] $ProvisioningType
        [String] $OperationalStatus
        [String] $HealthStatus
        [String] $BusType
        [String] $UniqueId
        [String] $Location
        [UInt32] $Partitions
        [Object[]] $Partition
        Disk([UInt32]$Rank,[Object]$Disk)
        {
            $This.Mode              = 0
            $This.Rank              = $Rank
            $This.Index             = $Disk.Index
            $This.Disk              = $Disk.DeviceId

            $This.SetMetadata()
            $This.SetPartitions()
            $This.SetDrive()
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
        [Object] GetMetadata()
        {
            $This.WriteCheck()

            Return Get-CimInstance MSFT_Disk -Namespace Root/Microsoft/Windows/Storage | ? Number -eq $This.Index
        }
        SetMetadata()
        {
            $This.WriteCheck()

            $Object                 = $This.GetMetadata()
            If (!$Object)
            {
                Throw "Unable to set the drive data"
            }

            $This.Model             = $Object.Model
            $This.Serial            = $Object.SerialNumber
            $This.PartitionStyle    = $Object.PartitionStyle
            $This.ProvisioningType  = $Object.ProvisioningType
            $This.OperationalStatus = $Object.OperationalStatus
            $This.HealthStatus      = $Object.HealthStatus
            $This.BusType           = $Object.BusType
            $This.UniqueId          = $Object.UniqueId
            $This.Location          = $Object.Location
        }
        [Object] GetPartitions()
        {
            $This.WriteCheck()

            Return @( Get-CimInstance Win32_DiskPartition | ? DiskIndex -eq $This.Index )
        }
        SetPartitions()
        {
            $This.WriteCheck()

            $Object = $This.GetPartitions() | % { [Partition]$_ }
            If (!$Object)
            {
                Throw "Unable to retrieve disk partitions" 
            }

            $Object | % { $_.Size   = $This.GetSize($_.Size) }
            $This.Partition         = $Object
            $This.Partitions        = $This.Partition.Count
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
        [String] GetLogicalDrive()
        {
            $This.WriteCheck()

            Return Get-CimInstance Win32_LogicalDiskToPartition | ? { $_.Antecedent.DeviceId -in $This.Partition.Name } | % { $_.Dependent.DeviceId }
        }
        [Object] GetDrive()
        {
            $This.WriteCheck()

            Return Get-CimInstance Win32_LogicalDisk | ? DeviceId -eq $This.GetLogicalDrive()
        }
        SetDrive()
        {
            $This.WriteCheck()

            $Drive                  = $This.GetDrive()
            If (!$Drive)
            {
                Throw "Unable to find associated drive"
            }

            $This.Name              = $Drive.Name
            $This.DriveLetter       = $Drive.Name -Replace ":",""
            $This.Description       = $Drive.Description
            $This.Filesystem        = $Drive.Filesystem
            $This.VolumeName        = $Drive.VolumeName
            $This.VolumeSerial      = $Drive.VolumeSerial
            $This.FreespaceBytes    = $Drive.Freespace
            $This.Freespace         = $This.GetSize($Drive.Freespace)
            $This.UsedBytes         = $Drive.Size - $Drive.Freespace
            $This.Used              = $This.GetSize($This.UsedBytes)
            $This.SizeBytes         = $Drive.Size
            $This.Size              = $This.GetSize($Drive.Size)
            $This.Compressed        = $Drive.Compressed
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
    
    # Drive/file formatting information (container), for the system this tool is run on.
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

    # Connected/Online Network adapter information
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

    # List of the event log providers
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

    # Parses the outputfile back into the system object above.
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

    # Parses keys from the log and sends them to system object
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

    # Parses each individual line of the outputfile
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

    # Basically does a lot of math.
    Class ParseTable
    {
        [Object]        $Content = @( )
        [Object]          $Total
        [Object]           $Body = [ParseSystem]::New()
        ParseTable([String]$Path)
        {
            $In           = (Get-Content $Path).TrimEnd(" ")
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

    # System snapshot, the primary focus of the utility.
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
            
            [Console]::WriteLine("Snapshot")
            $This.Snapshot         = [Snapshot]::New()

            [Console]::WriteLine("BiosInformation")
            $This.BiosInformation  = [BiosInformation]::New()

            [Console]::WriteLine("OperatingSystem")
            $This.OperatingSystem  = [OperatingSystem]::New() 

            [Console]::WriteLine("ComputerSystem")
            $This.ComputerSystem   = [ComputerSystem]::New()

            [Console]::WriteLine("Processors")
            $This.Processor        = [Processors]::New()
            $This.Processor.GetProcessors()

            [Console]::WriteLine("Disks")
            $This.Disk             = [Disks]::New()
            $This.Disk.GetDisks()

            [Console]::WriteLine("Networks")
            $This.Network          = [Networks]::New()
            $This.Network.GetNetworks()

            [Console]::WriteLine("Log Providers")
            $This.LogProviders     = [LogProviders]::New()
            $This.LogProviders.GetLogProviders()

        }
        System([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
            
            $Body                 = [ParseTable]::New($Path).Body
            If (!$Body)
            {
                Throw "Invalid file"
            }

            [Console]::WriteLine("Snapshot")
            $This.Snapshot         = $Body.Snapshot

            [Console]::WriteLine("BiosInformation")
            $This.BiosInformation  = $Body.BiosInformation

            [Console]::WriteLine("OperatingSystem")
            $This.OperatingSystem  = $Body.OperatingSystem

            [Console]::WriteLine("ComputerSystem")
            $This.ComputerSystem   = $Body.ComputerSystem

            [Console]::WriteLine("Processor(s)")
            $This.Processor        = $Body.Processor

            [Console]::WriteLine("Disk(s)")
            $This.Disk             = $Body.Disk

            [Console]::WriteLine("Network(s)")
            $This.Network          = $Body.Network

            [Console]::WriteLine("Log Providers")
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
        0 
        { 
            [System]::New()
        }
        1 
        { 
            [System]::New($Path)
        }
    }
}
#\__________________________                         ___________________________________________
Function Get-EventLogArchive                        #\_[ Model for the GUI to expand archive ]_/
{
    [CmdLetBinding(DefaultParameterSetName=0)]
    Param(
        [Parameter(Mandatory,ParameterSetName=0)][ValidateScript({Test-Path $_})][String]$Path,
        [Parameter(Mandatory,ParameterSetName=1)][Switch]$New
    )

    Class EventLogArchive
    {
        [String]     $Mode
        [String] $Modified
        [UInt32]   $Length
        [String]     $Size 
        [String]     $Name
        [String]     $Path
        EventLogArchive([String]$Fullname)
        {
            $File          = Get-Item $Fullname
            $This.Mode     = $File.Mode
            $This.Modified = $File.LastWriteTime.ToString()
            $This.Length   = $File.Length
            $This.Size     = "{0:n2} MB" -f ($File.Length/1MB)
            $This.Name     = $File.Name
            $This.Path     = $File.Fullname
        }
        EventLogArchive()
        {
            $This.Mode     = "-"
            $This.Modified = "-"
            $This.Length   = 0
            $This.Size     = "0.00 MB"
            $This.Name     = "-"
            $This.Path     = "-"
        }
    }

    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogArchive]::New($Path) }
        1 { [EventLogArchive]::New()      }
    }
}
#                                                                         ______________________
#\________________________________________________________________________\__[ </Functions> ]__/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 


# ______________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__[ <UI Classes> ]__/
#                                                                          ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#\________________                                                 _____________________________
Class PropertyItem                                                #\_[ Property Names/Values ]_/
{
    [String]$Name
    [Object]$Value
    PropertyItem([String]$Name,[Object]$Value)
    {
        $This.Name  = $Name
        $This.Value = Switch ($Value.Count) { 0 { "" } 1 { $Value } Default { $Value -join "`n" } }
    }
}
#\______________                                            ____________________________________
Class XamlWindow                                           #\_[ Instantiates a chunk of Xaml ]_/
{
    Hidden [Object]        $Xaml
    Hidden [Object]         $Xml
    [String[]]            $Names
    [Object[]]            $Types
    [Object]               $Node
    [Object]                 $IO
    [Object]         $Dispatcher
    [Object]          $Exception
    [String] FormatXaml([String]$Xaml)
    {
        $StringWriter          = [System.IO.StringWriter]::New()
        $XmlWriter             = [System.Xml.XmlTextWriter]::New($StringWriter)
        $XmlWriter.Formatting  = "indented"
        $XmlWriter.Indentation = 4
        ([Xml]$Xaml).WriteContentTo($XmlWriter)
        $XmlWriter.Flush()
        $StringWriter.Flush()
        Return $StringWriter.ToString()
    }
    [String[]] FindNames()
    {
        Return [Regex]::Matches($This.Xaml,"((\s*Name\s*=\s*)('|`")(\w+)('|`"))").Groups | ? Name -eq 4 | % Value | Select-Object -Unique
    }
    XamlWindow([String]$Xaml)
    {
        $This.Xaml               = $This.FormatXaml($Xaml)   
        If (!$This.Xaml)
        {
            Throw "Invalid Xaml Input"
        }
        
        [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
        
        $This.Xml                = [Xml]$Xaml
        $This.Names              = $This.FindNames()
        $This.Types              = @( )
        $This.Node               = [System.Xml.XmlNodeReader]::New($This.Xml)
        $This.IO                 = [System.Windows.Markup.XamlReader]::Load($This.Node)
        $This.Dispatcher         = $This.IO.Dispatcher

        ForEach ($I in 0..($This.Names.Count - 1))
        {
            $Name                = $This.Names[$I]
            $This.IO             | Add-Member -MemberType NoteProperty -Name $Name -Value $This.IO.FindName($Name) -Force
            If ($This.IO.$Name)
            {
                $This.Types     += [PropertyItem]::New($Name,$This.IO.$Name.GetType().Name)
            }
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
            $This.Exception     = $PSItem
        }
    }
}
#\_______________                                          _____________________________________
Class EventLogGUI                                         #\_[ XAML/Graphical user interface ]_/
{
    Static [String] $Tab = @('<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="[FightingEntropy]://Event Log Utility" Width="800" Height="650" HorizontalAlignment="Center" Topmost="False" ResizeMode="CanResizeWithGrip" Icon="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\icon.ico" WindowStartupLocation="CenterScreen">',
    '    <Window.Resources>',
    '        <Style TargetType="GroupBox">',
    '            <Setter Property="Margin" Value="10"/>',
    '            <Setter Property="Padding" Value="10"/>',
    '            <Setter Property="TextBlock.TextAlignment" Value="Center"/>',
    '            <Setter Property="Template">',
    '                <Setter.Value>',
    '                    <ControlTemplate TargetType="GroupBox">',
    '                        <Border CornerRadius="10" Background="White" BorderBrush="Black" BorderThickness="3">',
    '                            <ContentPresenter x:Name="ContentPresenter" ContentTemplate="{TemplateBinding ContentTemplate}" Margin="5"/>',
    '                        </Border>',
    '                    </ControlTemplate>',
    '                </Setter.Value>',
    '            </Setter>',
    '        </Style>',
    '        <Style TargetType="Button">',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="Padding" Value="5"/>',
    '            <Setter Property="Height" Value="30"/>',
    '            <Setter Property="FontWeight" Value="Semibold"/>',
    '            <Setter Property="FontSize" Value="12"/>',
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
    '        <Style TargetType="DataGridCell">',
    '            <Setter Property="TextBlock.TextAlignment" Value="Left" />',
    '        </Style>',
    '        <Style TargetType="DataGrid">',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="AutoGenerateColumns" Value="False"/>',
    '            <Setter Property="AlternationCount" Value="3"/>',
    '            <Setter Property="HeadersVisibility" Value="Column"/>',
    '            <Setter Property="CanUserResizeRows" Value="False"/>',
    '            <Setter Property="CanUserAddRows" Value="False"/>',
    '            <Setter Property="IsTabStop" Value="True"/>',
    '            <Setter Property="IsReadOnly" Value="True"/>',
    '            <Setter Property="IsTextSearchEnabled" Value="True"/>',
    '            <Setter Property="SelectionMode" Value="Extended"/>',
    '            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>',
    '            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>',
    '            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>',
    '        </Style>',
    '        <Style TargetType="DataGridRow">',
    '            <Setter Property="BorderBrush" Value="Black"/>',
    '            <Style.Triggers>',
    '                <Trigger Property="AlternationIndex" Value="0">',
    '                    <Setter Property="Background" Value="White"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex" Value="1">',
    '                    <Setter Property="Background" Value="#FFC5E5EC"/>',
    '                </Trigger>',
    '                <Trigger Property="AlternationIndex" Value="2">',
    '                    <Setter Property="Background" Value="#FFFDE1DC"/>',
    '                </Trigger>',
    '            </Style.Triggers>',
    '        </Style>',
    '        <Style TargetType="DataGridColumnHeader">',
    '            <Setter Property="FontSize"   Value="10"/>',
    '            <Setter Property="FontWeight" Value="Medium"/>',
    '            <Setter Property="Margin" Value="2"/>',
    '            <Setter Property="Padding" Value="2"/>',
    '        </Style>',
    '        <Style TargetType="ComboBox">',
    '            <Setter Property="Height" Value="24"/>',
    '            <Setter Property="Margin" Value="5"/>',
    '            <Setter Property="FontSize" Value="12"/>',
    '            <Setter Property="FontWeight" Value="Normal"/>',
    '        </Style>',
    '        <Style TargetType="CheckBox">',
    '            <Setter Property="VerticalContentAlignment" Value="Center"/>',
    '            <Setter Property="HorizontalAlignment" Value="Center"/>',
    '            <Setter Property="Height" Value="24"/>',
    '            <Setter Property="Margin" Value="5"/>',
    '        </Style>',
    '        <Style x:Key="DropShadow">',
    '            <Setter Property="TextBlock.Effect">',
    '                <Setter.Value>',
    '                    <DropShadowEffect ShadowDepth="1"/>',
    '                </Setter.Value>',
    '            </Setter>',
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
    '        <Style TargetType="TabItem">',
    '            <Setter Property="Template">',
    '                <Setter.Value>',
    '                    <ControlTemplate TargetType="TabItem">',
    '                        <Border Name="Border" BorderThickness="2" BorderBrush="Black" CornerRadius="2" Margin="2">',
    '                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Right" ContentSource="Header" Margin="5"/>',
    '                        </Border>',
    '                        <ControlTemplate.Triggers>',
    '                            <Trigger Property="IsSelected" Value="True">',
    '                                <Setter TargetName="Border" Property="Background" Value="#4444FF"/>',
    '                                <Setter Property="Foreground" Value="#FFFFFF"/>',
    '                            </Trigger>',
    '                            <Trigger Property="IsSelected" Value="False">',
    '                                <Setter TargetName="Border" Property="Background" Value="#DFFFBA"/>',
    '                                <Setter Property="Foreground" Value="#000000"/>',
    '                            </Trigger>',
    '                            <Trigger Property="IsEnabled" Value="False">',
    '                                <Setter TargetName="Border" Property="Background" Value="#6F6F6F"/>',
    '                                <Setter Property="Foreground" Value="#9F9F9F"/>',
    '                            </Trigger>',
    '                        </ControlTemplate.Triggers>',
    '                    </ControlTemplate>',
    '                </Setter.Value>',
    '            </Setter>',
    '        </Style>',
    '    </Window.Resources>',
    '    <Grid>',
    '        <Grid.Background>',
    '            <ImageBrush Stretch="Fill" ImageSource="C:\ProgramData\Secure Digits Plus LLC\FightingEntropy\Graphics\background.jpg"/>',
    '        </Grid.Background>',
    '        <GroupBox>',
    '            <Grid>',
    '                <Grid.RowDefinitions>',
    '                    <RowDefinition Height="40"/>',
    '                    <RowDefinition Height="*"/>',
    '                </Grid.RowDefinitions>',
    '                <Grid Grid.Row="0">',
    '                    <Grid.ColumnDefinitions>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                        <ColumnDefinition Width="*"/>',
    '                    </Grid.ColumnDefinitions>',
    '                    <Button Grid.Column="0" Name="MainTab"   Content="Main"/>',
    '                    <Button Grid.Column="1" Name="LogTab"    Content="Log(s)" IsEnabled="False"/>',
    '                    <Button Grid.Column="2" Name="OutputTab" Content="Output" IsEnabled="False"/>',
    '                    <Button Grid.Column="3" Name="ViewTab"   Content="View" IsEnabled="False"/>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="MainPanel" Visibility="Visible">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="80"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Mode]:"/>',
    '                        <ComboBox Grid.Column="1" Name="Mode" SelectedIndex="0">',
    '                            <ComboBoxItem Content="(Get/View) Event logs on this system"/>',
    '                            <ComboBoxItem Content="(Import/View) Event logs from an archive"/>',
    '                        </ComboBox>',
    '                        <Button Grid.Column="2" Content="Continue" Name="Continue"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Time]:"/>',
    '                        <TextBox Grid.Column="1" Name="Time" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Start]:"/>',
    '                        <TextBox Grid.Column="1" Name="Start" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="300"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[DisplayName]:"/>',
    '                        <TextBox Grid.Column="1" Name="DisplayName" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="4">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Destination]:"/>',
    '                        <TextBox Grid.Column="1" Name="Destination" IsEnabled="False"/>',
    '                        <Button Grid.Column="2" Content="Export" Name="Export" IsEnabled="False"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="5">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="380"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Providers]:"/>',
    '                        <ComboBox Grid.Column="1" Name="Providers" IsEnabled="False"/>',
    '                        <Label Grid.Column="2" Content="[Count]:"/>',
    '                        <TextBox Grid.Column="3" Name="ProviderCount" IsEnabled="False"/>',
    '                        <CheckBox Grid.Column="4" IsEnabled="False" Content="Console" IsChecked="True"/>',
    '                    </Grid>',
    '                    <TextBox Grid.Row="6" Margin="5" Height="Auto" Name="Console" TextWrapping="NoWrap" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Auto" TextAlignment="Left" VerticalContentAlignment="Top" FontFamily="Cascadia Code" FontSize="10"/>',
    '                    <DataGrid Grid.Row="7" Name="Archive" IsEnabled="False">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Mode"     Binding="{Binding Mode}"           Width="40"/>',
    '                            <DataGridTextColumn Header="Modified" Binding="{Binding Modified}"       Width="150"/>',
    '                            <DataGridTextColumn Header="Size"     Binding="{Binding Size}"           Width="75"/>',
    '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"           Width="225"/>',
    '                            <DataGridTextColumn Header="Path"     Binding="{Binding Path}"           Width="600"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="8">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="100"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[File Path]:"/>',
    '                        <TextBox Grid.Column="1" Name="FilePath" IsEnabled="False"/>',
    '                        <Button Grid.Column="2"  Name="FilePathBrowse" Content="Browse" IsEnabled="False"/>',
    '                    </Grid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="LogPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="110"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Log Main]:"/>',
    '                        <ComboBox Grid.Column="1" Name="LogMainProperty" SelectedIndex="1">',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Name"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Path"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="LogMainFilter"/>',
    '                        <Button Grid.Column="3" Name="LogMainRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Name="LogMainResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Rank"       Binding="{Binding Rank}"         Width="40"/>',
    '                            <DataGridTextColumn Header="Name"       Binding="{Binding LogName}"      Width="500"/>',
    '                            <DataGridTextColumn Header="Total"      Binding="{Binding Total}"        Width="100"/>',
    '                            <DataGridTextColumn Header="Type"       Binding="{Binding LogType}"      Width="100"/>',
    '                            <DataGridTextColumn Header="Isolation"  Binding="{Binding LogIsolation}" Width="100"/>',
    '                            <DataGridTextColumn Header="Enabled"    Binding="{Binding IsEnabled}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Classic"    Binding="{Binding IsClassicLog}" Width="50"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="2">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="50"/>',
    '                            <ColumnDefinition Width="50"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label   Grid.Column="0" Content="[Selected]:"/>',
    '                        <TextBox Grid.Column="1" Name="LogSelected"/>',
    '                        <Label   Grid.Column="2" Content="[Ct]:"/>',
    '                        <TextBox Grid.Column="3" Name="LogTotal"/>',
    '                        <Button Grid.Column="4" Name="LogClear" Content="Clear"/>',
    '                    </Grid>',
    '                    <Grid Grid.Row="3">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="70"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Output]:"/>',
    '                        <ComboBox Grid.Column="1" Name="LogOutputProperty" SelectedIndex="1">',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Log"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Provider"/>',
    '                            <ComboBoxItem Content="Id"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Message"/>',
    '                            <ComboBoxItem Content="Content"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="LogOutputFilter"/>',
    '                        <Button Grid.Column="3" Name="LogOutputRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="4" Name="LogOutputResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="350"/>',
    '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="OutputPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="40"/>',
    '                        <RowDefinition Height="*"/>',
    '                    </Grid.RowDefinitions>',
    '                    <Grid Grid.Row="0">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="85"/>',
    '                            <ColumnDefinition Width="150"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="80"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Label Grid.Column="0" Content="[Output]:"/>',
    '                        <ComboBox Grid.Column="1" Name="OutputProperty" SelectedIndex="0">',
    '                            <ComboBoxItem Content="Index"/>',
    '                            <ComboBoxItem Content="Date"/>',
    '                            <ComboBoxItem Content="Log"/>',
    '                            <ComboBoxItem Content="Rank"/>',
    '                            <ComboBoxItem Content="Provider"/>',
    '                            <ComboBoxItem Content="Id"/>',
    '                            <ComboBoxItem Content="Type"/>',
    '                            <ComboBoxItem Content="Message"/>',
    '                        </ComboBox>',
    '                        <TextBox Grid.Column="2" Name="OutputFilter"/>',
    '                        <Button Grid.Column="3" Name="OutputRefresh" Content="Refresh"/>',
    '                    </Grid>',
    '                    <DataGrid Grid.Row="1" Name="OutputResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Index"    Binding="{Binding Index}"    Width="50"/>',
    '                            <DataGridTextColumn Header="Date"     Binding="{Binding Date}"     Width="120"/>',
    '                            <DataGridTextColumn Header="Log"      Binding="{Binding Log}"      Width="50"/>',
    '                            <DataGridTextColumn Header="Rank"     Binding="{Binding Rank}"     Width="50"/>',
    '                            <DataGridTextColumn Header="Provider" Binding="{Binding Provider}" Width="350"/>',
    '                            <DataGridTextColumn Header="Id"       Binding="{Binding Id}"       Width="50"/>',
    '                            <DataGridTextColumn Header="Type"     Binding="{Binding Type}"     Width="100"/>',
    '                            <DataGridTextColumn Header="Message"  Binding="{Binding Message}"  Width="500"/>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                </Grid>',
    '                <Grid Grid.Row="1" Name="ViewPanel" Visibility="Collapsed">',
    '                    <Grid.RowDefinitions>',
    '                        <RowDefinition Height="*"/>',
    '                        <RowDefinition Height="40"/>',
    '                    </Grid.RowDefinitions>',
    '                    <DataGrid Grid.Row="0" Name="ViewResult">',
    '                        <DataGrid.Columns>',
    '                            <DataGridTextColumn Header="Name"     Binding="{Binding Name}"     Width="200"/>',
    '                            <DataGridTextColumn Header="Value"    Binding="{Binding Value}"    Width="*">',
    '                                <DataGridTextColumn.ElementStyle>',
    '                                    <Style TargetType="TextBlock">',
    '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                    </Style>',
    '                                </DataGridTextColumn.ElementStyle>',
    '                                <DataGridTextColumn.EditingElementStyle>',
    '                                    <Style TargetType="TextBox">',
    '                                        <Setter Property="TextWrapping" Value="Wrap"/>',
    '                                        <Setter Property="AcceptsReturn" Value="True"/>',
    '                                    </Style>',
    '                                </DataGridTextColumn.EditingElementStyle>',
    '                            </DataGridTextColumn>',
    '                        </DataGrid.Columns>',
    '                    </DataGrid>',
    '                    <Grid Grid.Row="1">',
    '                        <Grid.ColumnDefinitions>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                            <ColumnDefinition Width="*"/>',
    '                        </Grid.ColumnDefinitions>',
    '                        <Button Grid.Column="0" Name="ViewCopy"  Content="Copy to clipboard"/>',
    '                        <Button Grid.Column="2" Name="ViewClear" Content="Clear"/>',
    '                    </Grid>',
    '                </Grid>',
    '            </Grid>',
    '        </GroupBox>',
    '    </Grid>',
    '</Window>' -join "`n")
}
#                                                                        _______________________
#\_______________________________________________________________________\__[ </UI Classes> ]__/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ______________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\__[ <Project Classes> ]__/
#                                                                     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#\______________________                          ______________________________________________
Class ProjectConsoleLine                         #\_[ Flexibility for [Console]::WriteLine() ]_/
{
    [UInt32] $Index
    [String] $Phase
    [String] $Type
    [String] $Time
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
#\__________________                                ____________________________________________
Class ProjectConsole                               #\_[ Pseudo console for logging/debugging ]_/
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
        $This.Output  = @( )
        $This.Status()
    }
    AddLine([String]$Line)
    {
        $This.Output += [ProjectConsoleLine]::New($This.Output.Count,$This.Phase,$This.Type,$This.Time.Elapsed,$Line)
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
#\_______________                            ___________________________________________________
Class ProjectFile                           #\_[ Adds more granular control over file system ]_/
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
#\_________________               ______________________________________________________________
Class ProjectFolder              #\_[ Adds more granular control over project subdirectories ]_/
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
            Else
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
#\_______________                        _______________________________________________________
Class ProjectBase                       #\_[ Adds more control over temporary base directory ]_/
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
#\___________                          _________________________________________________________
Class Project                         #\_[ Orchestrates all of the (classes/functions) above ]_/
{
    [Object]        $Console
    [Object]           $Time
    [DateTime]        $Start
    [Object]         $System
    [String]    $DisplayName
    [UInt32]        $Threads
    [Guid]             $Guid
    [ProjectBase]      $Base
    [Object]           $Logs = @( )
    [Object]         $Output = @( )
    Project([UInt32]$Throttle)
    {
        $This.Threads = $Throttle
        $This.Init()
    }
    Project()
    {
        $This.Init()
    }
    Init()
    {
        # Start system snapshot, count threads / max runspace pool size
        $This.Time          = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Console       = [ProjectConsole]::New($This.Time)
        
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
    [String[]] Itemize([Object[]]$ItemList,[String]$Extension)
    {
        $Range = 0..($ItemList.Count-1)
        $Depth = ([String]$Range.Count).Length
        Return @( $Range | % { "{0:d$Depth}.$Extension" -f $_ })
    }
    Providers()
    {
        # Loads the provider names
        $Providers        = $This.System.LogProviders.Output
        $Slot             = $This.Slot("Threads")
        $Names            = $This.Itemize(@(0..($This.Threads-1)),"txt")
        $Slot.Create($Names)
        ForEach ($X in 0..($This.Threads-1))
        {
            $File         = $Slot.File($Names[$X])
            $Value        = 0..($Providers.Count-1) | ? { $_ % $This.Threads -eq $X } | % { $_,$Providers[$_].Value -join ',' }
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
        [Console]::WriteLine($This.Console.Status())
    }
    Update([String]$Phase,[String]$Message)
    {
        [Console]::WriteLine($This.Console.Update($Phase,$Message))
    }
    Update([String]$Phase,[UInt32]$Type,[String]$Message)
    {
        [Console]::WriteLine($This.Console.Update($Phase,$Type,$Message))
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
#                                                                     __________________________
#\____________________________________________________________________\_[ </Project Classes> ]_/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 



# ______________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\_[ <Thread Classes> ]_/
#                                                                        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#\__________________                      ______________________________________________________
Class ThreadProperty                     #\_[ Meant to display properties of a thread object ]_/
{
    [String] $Name
    [Object] $Value
    ThreadProperty([String]$Name,[Object]$Value)
    {
        $This.Name = $Name
        $This.Value = $Value
    }
}
#\_____________________                    _____________________________________________________
Class ThreadProgression                   #\_[ Handles specific files written in scriptblock ]_/
{
    [UInt32] $Index
    [Object] $Target
    Hidden [Object] $Load
    [Object] $File
    [UInt32] $Current
    [UInt32] $Total
    [Float] $Percent
    ThreadProgression([UInt32]$Index,[String]$Target,[Object]$Load,[Object]$File)
    {
        $This.Index   = $Index
        $This.Target  = $Target
        $This.Load    = $Load
        $This.File    = $File
        $This.Total   = $Load.Keys.Count
        $This.Percent = 0.00
    }
    Update()
    {
        $Bytes         = [System.IO.File]::ReadAllBytes($This.File)
        If (!$Bytes)
        {
            $This.Percent = 0.00
            $This.Current = 0
        }
        Else
        {
            $String       = ([Char[]]($Bytes) -join '') -Replace "\(|\)|\%","" -Split " "
            $This.Current = $String[1].Split("/")[0]
            $This.Percent = [Math]::Round($This.Current*100/$This.Total,2)
        }
    }
    [String] ToString()
    {
        Return "[{0}] : ({1}%) ({2}/{3})" -f $This.Index, $This.Percent, $This.Current, $This.Total
    }
}
#\_________________________                   __________________________________________________
Class ThreadProgressionList                  #\_[ Maintains thread comm. w/ controller class ]_/
{
    Hidden [Object]  $Timer = [System.Diagnostics.Stopwatch]::New()
    [String]          $Time
    [String]        $Status
    [Float]        $Percent
    Hidden [Object] $Output = @( )
    ThreadProgressionList()
    {
        $This.Time   = $This.Timer.Elapsed.ToString()
        $This.Status = "Awaiting initialization"
    }
    Load([UInt32]$Index,[String]$Target,[Object[]]$Load,[Object]$File)
    {
        $This.Output += [ThreadProgression]::New($Index,$Target,$Load,$File)
    }
    Start()
    {
        $This.Timer.Start()
        $This.Status = "Processing"
        $This.Update()
    }
    Complete()
    {
        $This.Timer.Stop()
        $This.Update()
    }
    [Object] Update()
    {
        ForEach ($Item in $This.Output)
        {
            $Item.Update()
        }
        $TotalPercent = ( $This.Output.Percent -join "+" ) | Invoke-Expression
        $This.Percent = [Math]::Round($TotalPercent/$This.Output.Count,2)
        $This.Time    = $This.Timer.Elapsed.ToString()
        Return @( 
            $This;
            $This.Output | % ToString
        )
    }
}
#\________________                                ______________________________________________
Class ThreadObject                                #\_[ Thread object for runspace invocation ]_/ 
{
    [UInt32] $Id 
    Hidden [Object] $PowerShell
    Hidden [Object] $Handle
    Hidden [Object] $Timer
    [String] $Time
    [UInt32] $Complete
    Hidden [Object] $Data
    ThreadObject([UInt32]$Id,[Object]$PowerShell)
    {
        $This.Id             = $Id
        $This.PowerShell     = $PowerShell
        $This.Handle         = $Null
        $This.Timer          = [System.Diagnostics.Stopwatch]::New()
        $This.Time           = $This.Timer.Elapsed.ToString()
        $This.Complete       = 0
        $This.Data           = $Null
    }
    BeginInvoke()
    {
        $This.Timer.Start()
        $This.TIme           = $This.Timer.Elapsed
        $This.Handle         = $This.PowerShell.BeginInvoke()
    }
    IsComplete()
    {
        If ($This.Handle.IsCompleted)
        {
            $This.Complete   = 1
            $This.Timer.Stop()
            $This.Data       = $This.PowerShell.EndInvoke($This.Handle)
            $This.PowerShell.Dispose()
        }
        If (!$This.Handle.IsCompleted)
        {
            $This.Time       = $This.Timer.Elapsed
        }
    }
    [Object] Config()
    {
        Return @( $This | Select-Object Id, Timer, PowerShell, Handle, Time, Complete)
    }
}
#\____________________                     _____________________________________________________
Class ThreadCollection                    #\_[ Administers runspaces, (track/chart) progress ]_/
{
    [String] $Name
    [Object] $Time
    [UInt32] $Complete
    [UInt32] $Total
    [Object] $Threads  = @( )
    ThreadCollection([String]$Name)
    {
        $This.Name     = $Name
        $This.Time     = [System.Diagnostics.Stopwatch]::New()
        $This.Threads  = @( )
    }
    [Bool] Query()
    {
        Return @( $False -in $This.Threads.Handle.IsCompleted )
    }
    AddThread([UInt32]$Index,[Object]$PowerShell)
    {
        $This.Threads += [ThreadObject]::New($_,$PowerShell)
        $This.Total    = $This.Threads.Count
    }
    BeginInvoke()
    {
        $This.Time.Start()
        ForEach ($Item in $This.Threads)
        {
            $Item.BeginInvoke()
        }
    }
    IsComplete()
    {
        $This.Threads.IsComplete()
        $This.Complete = ($This.Threads | ? Complete -eq $True).Count

        If ($This.Complete -eq $This.Total)
        {
            $This.Time.Stop()
        }
        $This.Time.Elapsed.ToString()
        $This.ToString()
    }
    [Void] Dispose()
    {
        Get-Runspace | ? InstanceId -in $This.Threads.PowerShell.InstanceId | % Dispose
    }
    [Object] GetOutput()
    {
        Return @(
        "                "
        "ThreadCollection";
        "----------------";
        $This | Select-Object Time, Complete, Total, Threads | Format-Table
        $This.Threads | Select-Object Id, Time, Complete | Format-Table
        " ")
    }
    [Object] GetFullOutput()
    {
        Return @(
        "                ";
        "ThreadCollection";
        "----------------";
        $This | Select-Object Time, Complete, Total, Threads | Format-Table;
        $This.Threads | Select-Object  Id, Timer, PowerShell, Handle, Time, Complete | Format-Table;
        " ")
    }
    [String] ToString()
    {
        Return ( "Elapsed: [{0}], Completed ({1}/{2})" -f $This.Timer.Elapsed, $This.Complete, $This.Total )
    }
}
#\_________________                     ________________________________________________________
Class ThreadControl                    #\_[ Interfaces with runspace/pool/factory, ISS, etc. ]_/
{
    [System.Management.Automation.Runspaces.RunspaceFactory] $RunspaceFactory
    [System.Management.Automation.Runspaces.RunspacePool]       $RunspacePool
    [System.Management.Automation.Runspaces.Runspace]               $Runspace
    [Object]             $Slot
    [Object]         $Throttle
    [Object]          $Session
    [Object]        $Functions = @( )
    [Object]        $Arguments = @( )
    [Object]          $Command = @( )
    [Object]         $Assembly = @( )
    [Object]         $Variable = @( )
    [Object]       $Collection
    [Object]      $ScriptBlock
    [Object]      $ActionBlock
    Hidden [Bool]  $IsDisposed
    Hidden [Uint32] $MinThread
    Hidden [UInt32] $MaxThread
    ThreadControl([String]$Slot,[UInt32]$Throttle)
    {
        If ($Slot -notin "Runspace","RunspacePool")
        {
            Throw "Invalid entry, (Runspace/RunspacePool)"
        }
        If ($Throttle -gt [Environment]::GetEnvironmentVariable("Number_Of_Processors"))
        {
            Throw "Invalid entry, not enough (cores/processors)" 
        }
        $This.Slot      = $Slot
        $This.Throttle  = $Throttle
        $This.MaxThread = $Throttle
    }
    CreateInitial()
    {
        $This.Session = $This.SessionState()
    }
    [Object] SessionState()
    {
        Return [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    }
    LoadSessionObject([String]$Slot,[Object]$Name)
    {
        Switch ($Slot)
        {
            Function 
            {
                If ($Name -in (Get-ChildItem Function:\).Name)
                {
                    $Content    = Get-Content Function:\$Name -ErrorAction Stop
                    $Object     = [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::New($Name,$Content)
                    $This.Session.Commands.Add($Object)
                    $This.Functions += $Object
                }
            }
            Argument { }
            Command  { }
            Assembly { }
            Variable { }
        }
    }
    CreateRunspacePool()
    {
        $This.CheckRunspacePool()
        $This.SetRunspacePool()
    }
    CreateRunspacePool([UInt32]$MinRunspaces,[UInt32]$MaxRunspaces)
    {
        $This.CheckRunspacePool()
        $This.CheckMinMaxRunspaces($MinRunspaces,$MaxRunspaces)
        $This.SetRunspacePool()
    }
    CreateRunspacePool([System.Management.Automation.Runspaces.InitialSessionState]$InitialSessionState)
    {
        If (!$InitialSessionState) { $This.CreateInitial() }
    }
    CreateRunspacePool([UInt32]$MinRunspaces,[UInt32]$MaxRunspaces,[System.Management.Automation.Host.PSHost]$host)
    {
        $This.CheckRunspacePool()
        $This.CheckMinMaxRunspaces($MinRunspaces,$MaxRunspaces)
        $This.SetRunspacePool()
    }
    CreateRunspacePool([UInt32]$minRunspaces,[UInt32]$maxRunspaces,[System.Management.Automation.Runspaces.Initialsessionstate]$initialSessionState,[System.Management.Automation.Host.PSHost]$host)
    {
        If (!$InitialSessionState) { $This.CreateInitial() }
        $This.CheckRunspacePool()
        $This.CheckMinMaxRunspaces($MinRunspaces,$MaxRunspaces)
        $This.SetRunspacePool()
    }
    [Bool] CheckMinMaxRunspaces([UInt32]$MinRunspaces,[UInt32]$MaxRunspaces)
    {
        If ($MinRunspaces -lt 1 -or $MaxRunSpaces -gt [Environment]::GetEnvironmentVariable("Number_Of_Processors"))
        {
            Throw "Invalid (minimum/maximum) runspaces set"
        }
        Else
        {
            Return $True
        }
    }
    [Bool] CheckRunspacePool()
    {
        If ($This.Slot -eq "RunspacePool") { Return $True } Else { Throw "Invalid type selection" }
    }
    SetRunspacePool()
    {
        $This.RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::New()

        If ($This.RunspacePool)
        {
            $This.Runspace    = "-"; $This.IsDisposed = 0
        }
    }
    CreateRunspace()
    {

    }
    CreateRunspace([System.Management.Automation.Host.PSHost]$host)
    {
        
    }
    CreateRunspace([System.Management.Automation.Runspaces.RunspaceConfiguration]$runspaceConfiguration)
    {
        $This.CheckRunspaceConfiguration($runspaceConfiguration)
    }
    CreateRunspace([System.Management.Automation.Host.PSHost]$host,[System.Management.Automation.Runspaces.RunspaceConfiguration]$runspaceConfiguration)
    {
        $This.CheckRunspaceConfiguration($runspaceConfiguration)
    }
    CreateRunspace([System.Management.Automation.Runspaces.initialsessionstate]$initialSessionState)
    {
        If (!$InitialSessionState) { $This.CreateInitial() }
    }
    CreateRunspace([System.Management.Automation.Host.PSHost]$host,[System.Management.Automation.Runspaces.initialsessionstate]$initialSessionState)
    {
        If (!$InitialSessionState) { $This.CreateInitial() }
    }
    [Bool] CheckRunspace()
    {
        If ($This.Slot -eq "Runspace") { Return $True } Else { Throw "Invalid type selection" }
    }
    SetRunspace()
    {
        $This.Runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::New()

        If ($This.Runspace)
        {
            $This.RunspacePool = "-"; $This.IsDisposed   = 0
        }
    }
    Dispose()
    {
        Switch ($This.Slot)
        {
            Runspace     
            { 
                $This.Runspace.Dispose()

                If ($This.Runspace.IsDisposed)
                {
                    $This.Runspace    = $Null; $This.IsDisposed  = 1
                }
            }
            RunspacePool
            { 
                $This.RunspacePool.Dispose()

                If ($This.RunspacePool.IsDisposed)
                {
                    $This.RunspacePool = $Null; $This.IsDisposed   = 1 
                }
            }
        }
    }
    Config()
    {
        Switch ($This.Slot)
        {
            Runspace     { $This.ShowProperties($This.Runspace) }
            RunspacePool { $This.ShowProperties($This.RunspacePool)  }
        }
    }
    [Object[]] ShowProperties([Object]$Object)
    {
        Return @( ForEach ($Property in $Object.PSObject.Properties)
        {
            [ThreadProperty]::New($Property.Name,$Property.Value)
        })
    }
    SetCollection([String]$Name)
    {
        $This.Collection = [ThreadCollection]::New($Name)
    }
}
#                                                                      _________________________
#\_____________________________________________________________________\_[ </Thread Classes> ]_/
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 


# ______________________________________________________________________________________________
#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\_[ <Controller Classes> ]_/
#                                                                    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
#\_____________________                                            _____________________________
Class ProjectController                                           #\_[ Main controller class ]_/
{
    [Hashtable]        $Sync
    [Object]           $Xaml
    [Object]  $ThreadControl = [ThreadControl]::New("RunspacePool")
    [Object]        $Project
    ProjectController()
    {
        $This.Sync    = [Hashtable]::Synchronized(@{})
        $This.Xaml    = [XamlWindow][EventLogGUI]::Tab
        $This.Main(0)
    }
    Main([UInt32]$Slot)
    {
        ForEach ($X in 0..($This.Panel.Count-1))
        {
            $Item                 = $This.Xaml.IO."$($This.Panel[$X])Tab"
            $Item.Background      = "#DFFFBA"
            $Item.Foreground      = "#000000"
            $Item.BorderBrush     = "#000000"

            If ($X -eq $Slot)
            {
                $Item.Background  = "#4444FF"
                $Item.Foreground  = "#FFFFFF"
                $Item.BorderBrush = "#111111"
            }

            $Item                 = $This.Xaml.IO."$($This.Panel[$X])Panel"
            $Item.Visibility      = "Collapsed"

            If ($X -eq $Slot)
            {
                $Item.Visibility  = "Visible"
            }
        }

        $This.Menu = $Slot
    }
    GetLogOutput()
    {
        $Flag                                     = @(0,1)[$This.Xaml.IO.LogTotal.Text -gt 0]
        $This.Reset($This.Xaml.IO.LogOutputResult.Items,$This.Event.Log[$This.LogMainIndex].Output)
        $This.Xaml.IO.LogOutputProperty.IsEnabled = $Flag
        $This.Xaml.IO.LogOutputFilter.Text        = ""
        $This.Xaml.IO.LogOutputFilter.IsEnabled   = $Flag
        $This.Xaml.IO.LogOutputRefresh.IsEnabled  = $Flag
        $This.Xaml.IO.LogOutputResult.IsEnabled   = $Flag
    }
    Initialize()
    {
        $This.Main(0)

        $This.Xaml.IO.Time.Text          = $This.Event.Time.Elapsed
        $This.Xaml.IO.Start.Text         = $This.Event.Start.ToString()
        $This.Xaml.IO.Title.Text         = $This.Event.Title
        $This.Xaml.IO.Destination.Text   = $This.Event.Destination
        $This.Reset($This.Xaml.IO.Providers.Items,$This.Event.Providers)
        $This.Xaml.IO.ProviderCount.Text = $This.Event.Providers.Count
        If ($This.Event.Providers.Count -gt 0)
        {
            $This.Xaml.IO.Providers.SelectedIndex = 0
        }

        $This.Reset($This.Xaml.IO.LogMainResult.Items,$This.Event.Log)
        $This.Reset($This.Xaml.IO.OutputResult.Items,$This.Event.Output)
        ForEach ($Item in $This.Event.Output)
        {
            $This.Hash.Add($This.Hash.Count,$Item)
        }
    }
    InsertEventLogs([Object]$EventLogObject)
    {
        $This.EventInsertEventLogs($EventLogObject)
        $This.Xaml.IO.ModeSelect.SelectedIndex = 0
        $This.Initialize()
    }
    GetEventLogs()
    {
        $This.Event.Start()
        $This.Xaml.IO.ModeSelect.SelectedIndex = 1
        $This.Initialize()
    }
    ImportEventLogs([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }
        $This.Event.Start($Path)
        $This.Xaml.IO.ModeSelect.SelectedIndex = 2
        $This.Initialize()
    }
    ExportEventLogs()
    {
        $This.Event.Export()
    }
    ExportEventLogs([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }
        $This.Event.Destination = "$Path\$($This.Title)"
        $This.Event.Export()
    }
    Reset([Object]$Sender,[Object[]]$Content)
    {
        $Sender.Clear()
        ForEach ($Item in $Content)
        {
            $Sender.Add($Item)
        }
    }
    [Object[]] ViewProperties([Object]$Object)
    {
        Return @( $Object.PSObject.Properties | % { [DGList]::New($_.Name,$_.Value) } )
    }
    [String] CleanString([String]$String)
    {
        Return "({0})" -f [Regex]::Escape($String) 
    }
    [String] LogProperty([String]$Slot)
    {
        Return @( Switch ($Slot)
        {
            Rank { "Rank" } Name { "LogName" } Type { "LogType" } Path { "LogFilePath" }
        })
    }
    [Object] ViewCopy()
    {
        $Return = @( )
        $Buffer = ($This.Xaml.IO.ViewResult.Items | % Name | Sort-Object Length)[-1].Length
        ForEach ($Item in $This.Xaml.IO.ViewResult.Items)
        {
            $Split  = $Item.Value -Split "`n"
            If ($Split.Count -eq 1)
            {
                $Return += "{0}{1} : {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''), $Item.Value
            }
            If ($Split.Count -gt 1)
            {
                ForEach ($X in 0..($Split.Count-1))
                {
                    If ($X -eq 0)
                    {
                        $Return += "{0}{1} : {2}" -f $Item.Name,(@(" ")*($Buffer-$Item.Name.Length) -join ''),$Split[$X]
                    }
                    Else
                    {
                        $Return += "{0}   {1}" -f ( " " * $Buffer -join ""), $Split[$X]
                    }
                }
            }
        }
        Return $Return
    }
    [Void] ViewClear()
    {
        $This.Xaml.IO.ViewResult.Items.Clear()
    }
    Current()
    {
        [Console]::WriteLine($This.Console.Status())
    }
    Update([String]$Phase,[String]$Message)
    {
        [Console]::WriteLine($This.Console.Update($Phase,$Message))
    }
    Update([String]$Phase,[UInt32]$Type,[String]$Message)
    {
        [Console]::WriteLine($This.Console.Update($Phase,$Type,$Message))
    }
    [Void] Error([String]$Message)
    {
        $This.Update("Exception",2,$Message)
        Throw $This.Console.ToString()
    }
}

# Begin
$Ctrl = [ProjectController]::New()
