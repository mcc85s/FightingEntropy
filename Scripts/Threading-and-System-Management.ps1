<#
.SYNOPSIS
        Allows for getting/viewing, exporting, or importing event viewer logs for a current
        or target Windows system.

.DESCRIPTION
        After many years of wondering how I could extract everything from *every* event log,
        this seems to do the trick. The utility takes a fair amount of time, but- it will
        collect every record in the event logs, as well as provide a way to export the files
        to an archive which can be loaded in far less time than it takes to build it.

        It performs a full cycle of stuff, to export logs on one system, to see a system
        snapshot on another system. I've been tweaking it over the last few weeks, and I do
        have a graphical user interface for it too.

        The newest feature writes out a very detailed master.txt file that can import all of
        the information it wrote in the primary scan/export, and, the thing formats itself.

        Not unlike Write-Theme.
        
        Still a work in progress.
.LINK
.NOTES
          FileName: EventLogs-Utility.ps1
          Solution: FightingEntropy Module
          Purpose: For exporting all of a systems event logs
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-04-08
          Modified: 2022-04-27
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression, System.IO.Compression.Filesystem, System.Windows.Forms, PresentationFramework

Function Get-EventLogConfigExtension
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

Function Get-EventLogRecordExtension
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
        [Object] ToString()
        {
            Return @( $This.Export() | ConvertFrom-Json )
        }
    }
    Switch ($PsCmdLet.ParameterSetName)
    {
        0 { [EventLogRecordExtension]::New($Record) }
        1 { [EventLogRecordExtension]::New(0,$Entry) }
    }
}

Function Get-SystemDetails
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
        [Object[]] ToString()
        {
            Return @( $This.Content | % ToString )
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
                    # Sets label for nested items

                    $This.AddItem($Current,"$Parent`s",$Values.Count)
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
        [Object[]] ToString()
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
        [Object[]] ToString()
        {
            Return @( $This.Content | % ToString )
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
            $This.DisplayName  = "{0}-{1}" -f $Current.ToString("yyyy-mmdd-HHMMss"), $This.ComputerName
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
        }
    }

    # Processor information for the system this tool is run on
    Class Processor
    {
        Hidden [UInt32] $Mode
        [UInt32] $Rank
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
        }
    }

    # Extended information for hard drives
    Class Disk
    {
        Hidden [UInt32] $Mode
        [UInt32] $Rank
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
        }
    }

    # Connected/Online Network adapter information
    Class Network
    {
        Hidden [UInt32] $Mode
        [UInt32] $Rank
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
            Return @( $This.Name, $This.Value )
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
        [Object[]] ToString()
        {
            Return $This.GetOutput().Slot.Content
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
        
            Return $This.Output.ToString()
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
    }

    # $System = [System]::New(); 
    # $System.WriteOutput("$Home\Desktop\System2022-0425.txt",$True)

    # $Path   = "$Home\Desktop\System2022-0425.txt"
    # $System = [System]::New($Path)

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

Function Get-EventLogArchive
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
        $Item          = [System.IO.FileStream]::New($This.Fullname,[System.IO.FileMode]::Open)
        $Item.Position = 0
        $Value         = "" ;
        Switch ($Item.Length)
        {
            {$_ -eq 0} { $Value += $Null }
            {$_ -eq 1} { $Value += [Char][Byte]$Item.ReadByte() }
            {$_ -gt 1} { 0..($Item.Length-1) | % { $Value += [Char][Byte]$Item.ReadByte() } }
        }
        $Item.Dispose()
        $This.Update()
        Return $Value
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
    [UInt32]     $Rank
    [String]     $Name
    [String] $Fullname
    [String]   $Parent
    [Bool]     $Exists
    [UInt32]    $Count
    [Object] $Children = @( )
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
        $This.Exists   = [System.IO.Directory]::Exists($This.Fullname)
        If ($This.Exists)
        {
            $This.Children = @( )
            $This.Count    = 0
            ForEach ($File in [System.IO.DirectoryInfo]::new($This.FullName).EnumerateFileSystemInfos())
            {
                $This.Children += [ProjectFile]::New($This.Count,$File)
                $This.Count    ++
            }
        }
    }
    [Object] Create([String]$Name)
    {
        $Path           = $This.Fullname, $Name -join '\'
        $Item           = [System.IO.File]::Create($Path).Dispose()
        $This.Update()
        Return $This.File($Name)
    }
    Delete([String]$Name)
    {
        $Item = $This.File($Name)
        $Item.Delete()
        $This.Update()
    }
    [Object] File([String]$Name)
    {
        Return $This.Children | ? Name -eq $Name
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
            $Item               = [System.IO.Directory]::CreateDirectory("$($This.Fullname)\$Entry")
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
        If ($This.Exists)
        {
            $This.Folders       = @( )
            $This.Count         = 0
            ForEach ($Folder in [System.IO.DirectoryInfo]::new($This.Fullname).EnumerateDirectories())
            {
                $This.Folders  += [ProjectFolder]::New($This.Count,$Folder)
                $This.Count    ++
            }
            If ($This.Count -gt 0)
            {
                ForEach ($Folder in $This.Folders)
                {
                    $Folder.Update()
                }
            }
        }
    }
    [Object] Slot([String]$Slot)
    {
        Return $This.Folders | ? Name -eq $Slot
    }
    [Object] Create([String]$Slot,[String]$Name)
    {
        $Item = $This.Slot($Slot)
        $This.Test($Name,$Item)

        If ($Name -in $Item.Children.Name)
        {
            Throw "Item already exists"
        }
        Else
        {
            Return $Item.Create($Name)
        }
    }
    [String] ToString()
    {
        Return $This.Fullname
    }
}

Class ProjectConsole
{
    [Object]   $Time
    [String]  $Phase
    [UInt32]  $Count
    [Object] $Output = @{ }
    ProjectConsole([Object]$Time)
    {
        $This.Time   = $Time
        $This.Phase  = "Starting"
        $This.Status()
    }
    [String] Current()
    {
        Return "{0} [~] Elapsed: [{1}]" -f $This.Phase, $This.Time.Elapsed
    }
    [String] Update([String]$Phase,[String]$Message)
    {
        $This.Phase   = $Phase
        $This.Add(("{0} - {1}" -f $This.Current(), $Message))
        Return $This.ToString()
    }
    [Void] Add([String]$Line)
    {
        $This.Output.Add($This.Output.Count,$Line)
    }
    [String] Status()
    {
        $This.Add($This.Current())
        Return $This.ToString()
    }
    [Object] ToString()
    {
        Return $This.Output[$This.Output.Count-1]
    }
}

Class Project
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
    Project()
    {
        # Start system snapshot, count threads / max runspace pool size
        $This.Time          = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Console       = [ProjectConsole]::New($This.Time)
        
        $This.Update("Loading","System snapshot details")
        $This.System        = Get-SystemDetails
        
        $This.Start         = $This.System.Snapshot.Start        
        $This.DisplayName   = $This.System.Snapshot.DisplayName 
        $This.Threads       = $This.System.Processor.Output.Threads | Measure-Object -Sum | % Sum

        If ($This.Threads -lt 2)
        {
            Throw "CPU only has (1) thread"
        }

        # System snapshot has already created a Guid, to create a new folder for the threads
        $This.Guid          = $This.System.Snapshot.Guid
        $This.Base          = $This.Establish([Environment]::GetEnvironmentVariable("temp"),$This.Guid)

        $This.Update("Created","Base directory")
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
        ForEach ($X in 0..($This.Threads-1))
        {
            $Value        = 0..($Providers.Count-1) | ? { $_ % $This.Threads -eq $X } | % { $_,$Providers[$_].Value -join ',' }
            $Value        = 0..($Providers.Count-1) | ? { $_ % 8 -eq $X } | % { $_,$Providers[$_].Value -join ',' }
            $Slot         = $This.Slot("Threads")
            $File         = $Slot.Create("$X.txt")
            $File.Write($Value -join "`n")
            $File | Format-Table
        }
        $This.Update("Prepared","Event log collection split between threads")
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
    SaveMaster()
    {
        $Value        = $This.System.GetOutput()
        $Slot         = $This.Slot("Master")
        $File         = $Slot.Create("Master.txt")
        $File.Write($Value -join "`n")
        $This.Update("Success","Master file written to disk: [$File/$($File.Size)]")
    }
    SaveLogs()
    {
        $Value         = $This.Logs | Select-Object Rank,LogName,LogType,LogIsolation,IsEnabled,IsClassicLog,SecurityDescriptor,LogFilePath,
        MaximumSizeInBytes,Maximum,Current,LogMode,OwningProviderName,ProviderNames,ProviderLevel,ProviderKeywords,ProviderBufferSize,
        ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency,ProviderControlGuid | ConvertTo-Json
        $Slot          = $This.Slot("Logs")
        $File          = $Slot.Create("Logs.txt")
        $File.Write($Value)
        $This.Update("Success","Log config file written to disk: [$File/$($File.Size)]")
    }
    Delete()
    {
        $This.Update("Terminating","Process was instructed to be deleted")
        $This.Base          | Remove-Item -Recurse -Verbose
        $This.Base          = $Null
        $This.Start         = [DateTime]::FromOADate(1)
        $This.System        = $Null
        $This.DisplayName   = $Null
        $This.Guid          = [Guid]::Empty
        $This.Time          = $Null
        $This.Threads       = $Null
        $This.Base          = $Null
        $This.Logs          = $Null
        $This.Output        = $Null
    }
    [Object] ToString()
    {
        Return $This
    }
}

Class DivisionItem
{
    [UInt32] $Index
    [String] $Rank
    [UInt32] $Thread
    [UInt32] $File
    DivisionItem([UInt32]$Index,[UInt32]$Depth,[UInt32]$Threads,[UInt32]$Label)
    {
        $This.Index  = $Index
        $This.Rank   = "0x{0:X$Depth}" -f $Index
        $This.Thread = $Index % $Threads
        $This.File   = $Label
    }
    [String] ToString()
    {
        Return "{0}/{1}/{2}/{3}" -f $This.Index, $This.Rank, $This.Thread, $This.File
    }
}

Class DivisionList
{
    [Double] $Total
    [UInt32] $Depth
    [UInt32] $Threads
    [UInt32] $MaxEntry
    [UInt32] $Count
    [Object] $Output
    DivisionList([UInt32]$Total,[UInt32]$Threads,[UInt32]$MaxEntry)
    {
        $This.Total    = $Total
        $This.Depth    = [String]("{0:x}" -f $Total).Length
        $This.Threads  = $Threads
        $This.MaxEntry = $MaxEntry
        $Max           = $This.Total % $This.MaxEntry
        $This.Count    = ($This.Total - $Max) / $This.MaxEntry
    }
    GetOutput()
    {
        $Hash     = @{ }
        $Label         = -1
        ForEach ($X in 0..($This.Total-1))
        {
            If ($X % $This.MaxEntry -eq 0)
            {
                $Label ++
                $Percent = [Math]::Round(($Label*100/$This.Count),2)
                [Console]::WriteLine("Completed: $("{0:n2}" -f $Percent)%")
            }
            $Hash.Add($Hash.Count,[DivisionItem]::New($X,$This.Depth,$This.Threads,$Label))
        }
        [Console]::WriteLine("Processing output...")
        $This.Output = $Hash[0..($Hash.Count-1)]
    }
    Create([Object]$Root)
    {
        $Time = [System.Diagnostics.Stopwatch]::StartNew()
        $Hash = @( )
        ForEach ($X in 0..($This.Output.Count-1))
        {
            $Item = $This.Output[$X]
            If (!$Hash[$Item.File])
            {
                $Hash += [Hashtable]@{ }
            }
            $Hash[$Item.File].Add($Hash[$Item.File].Count,$Item)
        }

        [Console]::WriteLine("$($time.Elapsed) Path: [$Root]")
        ForEach ($X in 0..($This.Count))
        {
            ForEach ($File in $Hash[$X][0..($Hash[$X].Count-1)])
            {
                $FilePath = "{0}\{1}.txt" -f $Root, $File.Rank
                [System.IO.File]::Create($FilePath).Dispose()
            }
            [Console]::WriteLine("$($time.Elapsed) Files: $($X * $This.MaxEntry)")
        }
    }
    [Object[]] Work()
    {
        $Time = [System.Diagnostics.Stopwatch]::StartNew()
        $Hash = @( )
        ForEach ($X in 0..($This.Output.Count-1))
        {
            $Item = $This.Output[$X]
            If (!$Hash[$Item.Thread])
            {
                $Hash += [Hashtable]@{}
            }
            $Hash[$Item.Thread].Add($Hash[$Item.Thread].Count,$Item)
        }
        Return $Hash
    }
}

# Used to display properties (names/values) in the thread classes
Class ThreadProperty
{
    [String] $Name
    [Object] $Value
    ThreadProperty([String]$Name,[Object]$Value)
    {
        $This.Name = $Name
        $This.Value = $Value
    }
}

# Thread object for runspace invocation 
Class ThreadObject
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

# Thread collection object to track and chart progress (single/grouped) thread objects
Class ThreadCollection
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
        Get-Runspace | ? InstanceId in $This.Threads.PowerShell.InstanceId | % Dispose
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

# Thread Controller
Class ThreadControl
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

# Start a project instance
$Ctrl    = [Project]::New()
$Base    = $Ctrl.Base

# Assign variables to slots
$Master  = $Ctrl.Slot("Master")
$Logs    = $Ctrl.Slot("Logs")
$Events  = $Ctrl.Slot("Events")
$Threads = $Ctrl.Slot("Threads")

# Save the system master snapshot
$Ctrl.SaveMaster()

# Open the runspacepool
$Ctrl.Update("Opening","Runspace pool")
$TC      = [ThreadControl]::New("RunspacePool",8)

# Create initial session state object, function above is immediately available to any thread in the runspace pool
$Ctrl.Update("Creating","Initial session state object")
$TC.CreateInitial()
$TC.LoadSessionObject("Function","Get-EventLogConfigExtension")
$TC.LoadSessionObject("Function","Get-EventLogRecordExtension")

# Create runspace pool, and open it
$TC.RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$Ctrl.Threads,$TC.Session,$Host)
$TC.RunspacePool.Open()

# Declare the FIRST thread collection object
$Ctrl.Update("Opening","Thread collection object to track runspace progress")
$TC.SetCollection("Event Log Configuration Collection")

# Declare the scriptblock each runspace will run independently
$Ctrl.Update("Creating","Scriptblock for each thread to process")
$ScriptBlock     = {
    Param ($File,$LogPath)
    $List        = Get-Content -Path $File
    $Return      = @( )
    ForEach ($X in 0..($List.Count-1))
    {
        $Rank    = $List[$X].Split(",")[0]
        $Name    = $List[$X].Split(",")[1]
        $Item    = Get-EventLogConfigExtension -Rank $Rank -Name $Name
        $Item.GetEventLogRecord()
        $Return += $Item
        $Temp   = [System.IO.Filestream]::new("$LogPath\$Rank.tmp",[System.IO.FileMode]::CreateNew)
        $Bytes  = [Byte[]]([Char[]]$Name)
        $Temp.Dispose()
    }
    Return $Return
}

# Initialize the threads, add the scriptblock, insert an argument for filepath
0..($Ctrl.Threads-1) | % {

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($Scriptblock).AddArgument($Threads.Children[$_]).AddArgument($Logs) | Out-Null

    $PowerShell.RunspacePool = $TC.RunspacePool

    $TC.Collection.AddThread($_,$PowerShell)
}

$TC.Collection.BeginInvoke()

# Code to run while waiting for threads to finish
$Total            = $Ctrl.System.LogProviders.Count
$Ctrl.Update("Collecting","Event logs (0/$Total)")
While ($TC.Collection.Query())
{
    $TC.Collection.Threads | Format-Table
    $Logs.Update()
    If (!$Last -or $Logs.Count -ne $Last)
    {
        $Percent = [Math]::Round($Logs.Count*100/$Total,2)
        $Ctrl.Update("Collecting","($Percent%) Event logs ($($Logs.Count)/$Total)")
    }
    Else
    {
        $Ctrl.Current()
    }
    $Last = $Logs.Count
    Start-Sleep 5
    Clear-Host
    $TC.Collection.IsComplete()
}
$Ctrl.Update("Complete","Log collection completed, sorting")
$TC.Collection.IsComplete()

Get-ChildItem $Logs    | Remove-Item
Get-ChildItem $Threads | Remove-Item
$Base.Update()
$Ctrl.Logs             = $TC.Collection.Threads.Data | Sort-Object Rank
$Ctrl.SaveLogs()

# Now we have all of the log entries on the system for each individual log
$Ctrl.Update("Sorting","(Logs/Output)")
$Ctrl.Output           = $Ctrl.Logs.Output | Sort-Object TimeCreated



# Now they're ranked, as well as sorted in chronological order
$Ctrl.Update("Disposing","First runspace pool")
$TC.RunspacePool.Dispose()

# This will split the workload among the number of threads, and preallocate files
$List = [DivisionList]::New($Ctrl.Output.Count,$Ctrl.Threads,1000)
$List.GetOutput()
$List.Create($Events)
$Work = $List.Work()

# Almost time to index the files...
$Ctrl.Update("Indexing","(Output)")
$Count                 = $Ctrl.Output.Count
$Depth                 = ([String]$Count).Length

# Set up hashtable for threads and $T variable for threads (an error kept occurring) 
$Load                  = @{ }
$T                     = [Environment]::GetEnvironmentVariable("Number_of_processors")

# Autocalc the # of hashtables respective to cores available
ForEach ($X in 0..($T-1))
{
    $Load.Add($X,[Hashtable]@{ })
}

# Now perform (indexing/naming) as well as distributing the workload to the separate hashtables
$Ctrl.Update("Distributing","workload among separate (hashtables/threads)")

ForEach ($X in 0..($Ctrl.Output.Count-1))
{
    # (Name/Index applied)
    $Item              = $Ctrl.Output[$X]
    $Item.Index        = $X
    $Item.Name         = "{0:d$Depth}-{1}" -f $X, $Item.Name

    # The remainder function ($X % $T) denotes:
    # Hashtable Prime: You know what...? For each iteration of the loop... 
    # ...I'm gonna automatically switch the bracketed index...
    # ...to populate the corresponding hashtable based on the remainder...
    # Hashtable Clone[0]: Cool bro.
    # Hashtable Clone[5]: Yeah~! Do it. I dare ya...
    # Hashtable Clone[6]: C'mon guys. We're just hashtables...
    # Hashtable Clone[3]: ...yeah. Hashtables don't talk.
    # Hashtable Clone[1]: Oh. Man. It's a cool idea though... 
    $Load[$X%$T].Add($Load[$X%$T].Count,$Ctrl.Output[$X])
}

# Open the runspacepool
$Ctrl.Update("Opening","Second runspacepool")

$TC.RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$TC.Throttle,$TC.Session,$Host)
$TC.RunspacePool.Open()

# Declare new thread collection object
$Ctrl.Update("Starting","New ThreadCollection")
$TC.SetCollection("Event log exfiltration")
$Ctrl.Update("Adding","Scriptblock")

# Class to handle the back & forth
Class ThreadProgression
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
        Return "[{0}] : ({1}%) ({1}/{2})" -f $This.Index, $This.Percent, $This.Current, $This.Total
    }
}

Class ThreadProgressionList
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
        $This.Percent = [Math]::Round($TotalPercent/($This.Output.Count*100),2)
        $This.Time    = $This.Timer.Elapsed.ToString()
        Return @( 
            $This;
            $This.Output | % ToString
        )
    }
}

# Manage Progress
$Progress         = [ThreadProgressionList]::New()
ForEach ($X in 0..($Ctrl.Threads-1))
{
    $File         = $Threads.Create("$X.txt")
    $Progress.Load($X,$Events,$Load[$X],$File)
}

# Add Scriptblock
$ScriptBlock = {

    Param ($Target,$Work,$Load,$File)

    $Segment = [Math]::Round($Work.Count/100)
    $Slot    = 0..($Work.Count-1) | ? { $_ % $Segment -eq 0 }
    ForEach ($X in 0..($Work.Count-1))
    {
        $Item = Get-EventLogRecordExtension -Record $Load[$X] | % Export
        $Id   = $Work[$X].Rank
        [System.IO.File]::WriteAllLines("$Target\$Id.txt",$Item)
        If ($X -in $Slot)
        {
            $Percent = ($X*100/$Work.Count)
            $String  = "({0:n2}%) ({1}/{2})" -f $Percent, $X, $Work.Count
            $Bytes   = [Byte[]]([Char[]]([String]$String))
            $Item    = [System.IO.File]::Open($File.Fullname,[System.IO.FileMode]::Truncate)
            $Item.Write($Bytes,0,$Bytes.Length)
            $Item.Dispose()
        }
    }
}

# Initialize the threads, add the scriptblock, insert an argument for filepath

0..($Ctrl.Threads-1) | % {  

    $PowerShell = [PowerShell]::Create()
    $PowerShell.AddScript($Scriptblock)             | Out-Null                             
    $PowerShell.AddArgument($Events.Fullname)       | Out-Null
    $PowerShell.AddArgument($Work[$_])              | Out-Null
    $PowerShell.AddArgument($Load[$_])              | Out-Null
    $PowerShell.AddArgument($Threads.Children[$_])  | Out-Null
    $PowerShell.RunspacePool = $TC.RunspacePool

    $TC.Collection.AddThread($_,$PowerShell)
}

$TC.Collection.BeginInvoke()
$Progress.Start()

# Code to run while waiting for threads to finish
While ($TC.Collection.Query())
{
    $TC.Collection.Threads | Format-Table
    $Progress.Update()
    If (!$Last -or $Progress.Percent -ne $Last)
    {
        $Ctrl.Update($Progress.Status,"($($Progress.Percent)%)")
    }
    Else
    {
        $Ctrl.Current()
    }
    $Last = $Progress.Percent
    Start-Sleep 5
    Clear-Host
    $TC.Collection.IsComplete()
}
$Ctrl.Update("Completed","Process sending files to compression engine")
$TC.Collection.IsComplete()

# Dispose the runspace
$TC.Collection.Dispose()

# Get ready to archive the files
Add-Type -Assembly System.IO.Compression.Filesystem

$Phase       = [System.Diagnostics.Stopwatch]::StartNew()
$Destination = "$($Ctrl.Path)\$($Ctrl.DisplayName).zip"
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Create").Dispose()
$Zip         = [System.IO.Compression.ZipFile]::Open($Destination,"Update")

# Inject master file
$MasterPath  = "$($Ctrl.Path)\Master\Master.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$MasterPath,"Master.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Inject logs file
$LogPath     = "$($Ctrl.Path)\Logs\Logs.txt"
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$LogPath,"Logs.txt",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null

# Prepare event files
$EventPath   = "$($Ctrl.Path)\Events"
$EventFiles  = Get-ChildItem $EventPath

# Create progress loop
$Complete   = @( )
$Count      = $EventFiles.Count
ForEach ($X in 0..($EventFiles.Count-1))
{
    $File    = $EventFiles[$X]
    $Percent = [Math]::Round($X*100/$Count)
    If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
    {
        $Complete += $Percent
        If ($Percent -ne 0)
        {
            $Remain    = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
        }
        
        Write-Host "Exporting ($Percent.00%) [~] Elapsed: [$($Phase.Elapsed)], Remain: [$Remain]"
    }
    # Inject event files
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$File.Fullname,$File.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
}

# Archive creation just about complete
Write-Host "Saving (100.00%) [~] Elapsed: $($Phase.Elapsed), (Please wait, the program is writing the file to disk)"
$Zip.Dispose()

# Get the zip file information
$Zip = Get-Item $Destination
Switch (!!$Zip)
{
    $True
    {
        Write-Host ("Saved (100.00%) [+] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], Size: [$("{0:n3}MB" -f ($Zip.Length/1MB))]")
    }
    $False
    {
        Write-Host ("Failed (100.00%) [!] Elapsed [$($Ctrl.Timer.Elapsed)], File: [$Destination], the file does not exist.")
    }
}
$Ctrl.Timer.Stop()

# At this point, deleting the makeshift directories/files might be a good idea outside of development


# This is specifically for restoring an archive of another machine, or the current machine.
Class RestoreArchive
{
    [Object] $Time
    [Object] $Start
    [Object] $System
    [Object] $DisplayName
    [UInt32] $Threads
    [String] $Guid
    [String] $Path
    [Object] $Files
    [Object] $Object
    [Object] $Logs
    [Object] $Output
    Hidden [Object] $Zip
    RestoreArchive([String]$ZipPath)
    {
        # Restore the zip file
        If (!(Test-Path $ZipPath) -or $ZipPath.Split(".")[-1] -notmatch "zip")
        {
            Throw "Invalid Path"
        }

        $This.Time         = [System.Diagnostics.Stopwatch]::StartNew()

        # Get zip content, pull master file
        $This.Zip          = [System.IO.Compression.Zipfile]::Open($ZipPath,"Read")
        $This.Path         = $ZipPath | Split-Path -Parent

        # Extract Master file
        $MasterEntry       = $This.Zip.GetEntry("Master.txt")
        $MasterPath        = "$($This.Path)\Master.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($MasterEntry,$MasterPath,$True)
        $MasterFile        = Get-Content $MasterPath

        # Extract Logs file
        $LogEntry          = $This.Zip.GetEntry("Logs.txt")
        $LogPath           = "$($This.Path)\Logs.txt"
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($LogEntry,$LogPath,$True)
        $LogFile           = Get-Content $LogPath | ConvertFrom-Json

        # Parse Master.txt
        $This.Start        = $MasterFile[0].Substring(9)
        $This.DisplayName  = $MasterFile[1].Substring(15)
        $Lines             = @( )
        ForEach ($X in 0..($MasterFile.Count-1))
        {
            $Line = [Regex]::Matches($MasterFile[$X],"\[Provider \d+\].+").Value
            If (!!$Line)
            { 
                $Lines    += $Line.Substring(16)
            }
        }
        $This.Object       = $Lines
        $This.System       = $MasterFile[($Lines.Count + 2)..($MasterFile.Count-1)]
        $This.Threads      = ($This.System | ? { $_ -match "Threads" }).Substring(18)

        # Parse Logs.txt
        $This.Logs         = @( )
        $Stash             = @{ }
        ForEach ($X in 0..($LogFile.Count-1))
        {
            $Item          = $LogFile[$X]
            $This.Logs    += Get-EventLogConfigExtension -Config $Item
            $Stash.Add($Item.LogName,@{ })
        }

        $Hash              = @{ }
        $Remain            = $Null

        # Collect Files
        $FileEntry            = $This.Zip.Entries | ? Name -notmatch "(Master|Logs).txt"

        # Create progress loop
        $Complete             = @( )
        $Phase                = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Importing (0.00%) [~] Files: ($($FileEntry.Count)) found."
        ForEach ($X in 0..($FileEntry.Count-1))
        {
            $Item             = Get-EventLogRecordExtension -Index $X -Entry $FileEntry[$X]
            $Hash.Add($X,$Item)

            $Stash[$Item.LogName].Add($Stash[$Item.LogName].Count,$X)
            
            $Percent          = [Math]::Round($X*100/$FileEntry.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain= ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Importing ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        $Phase.Stop()
        Write-Host "Imported (100.00%) [+] Files: ($($FileEntry.Count)) found."
        $This.Output      = $Hash[0..($Hash.Count-1)]

        # Sort the logs
        $Complete          = @( )
        $Phase.Reset()
        Write-Host "Sorting (0.00%) [~] Logs: ($($This.Logs.Count)) found."
        ForEach ($X in 0..($This.Logs.Count-1))
        {
            $Name = $This.Logs[$X].LogName
            Switch ($Stash[$Name].Count)
            {
                0 
                {  
                    $This.Logs[$X].Output = @( )
                }
                1 
                {  
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0]])
                }
                Default
                { 
                    $This.Logs[$X].Output = @($This.Output[$Stash[$Name][0..($Stash[$Name].Count-1)]])
                }
            }
            $This.Logs[$X].Total          = $This.Logs[$X].Output.Count

            $Percent                      = [Math]::Round($X*100/$This.Logs.Count)
            If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
            {
                $Complete += $Percent
                If ($Percent -ne 0)
                {
                    $Remain = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
                }
                Write-Host "Sorting ($Percent%) [~] Elapsed: [$($This.Time.Elapsed)], Remain: [$Remain]"
            }
        }
        Write-Host "Sorted (100.00%) [+] Logs: ($($This.Logs.Count)) found."
        $This.Time.Stop()
    }
}

$Path    = "C:\Users\mcadmin\AppData\Local\Temp\34ba7453-89b7-44a5-92ab-9e5967be11b0\2022-0825-160422-DESKTOP-GSJF6AC.zip"
$Restore = [RestoreArchive]::New($Path)

# Restore the zip file
If (!(Test-Path $ZipPath) -or $ZipPath.Split(".")[-1] -notmatch "zip")
{
    Throw "Invalid Path"
}

$Time              = [System.Diagnostics.Stopwatch]::StartNew()

# Get zip content, pull master file
$Zip               = [System.IO.Compression.Zipfile]::Open($ZipPath,"Read")
$Path              = $ZipPath | Split-Path -Parent

# Extract Master file
$MasterEntry       = $Zip.GetEntry("Master.txt")
$MasterPath        = "$($Path)\Master.txt"
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($MasterEntry,$MasterPath,$True)

# Extract Logs file
$LogEntry          = $Zip.GetEntry("Logs.txt")
$LogPath           = "$($Path)\Logs.txt"
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($LogEntry,$LogPath,$True)

# Provide system detail restoration
$System            = Get-SystemDetails -Path $MasterPath
$Start             = $System.Snapshot.Start
$DisplayName       = $System.Snapshot.DisplayName
$Object            = $System
$Threads           = $System.Processor.Output.Threads

# Pull log file/parse Logs.txt
$LogFile           = Get-Content $LogPath | ConvertFrom-Json
$Logs              = @( )
$Stash             = @{ }
ForEach ($X in 0..($LogFile.Count-1))
{
    $Item          = $LogFile[$X]
    $Logs         += Get-EventLogConfigExtension -Config $Item
    $Stash.Add($Item.LogName,@{ })
}

$Hash              = @{ }
$Remain            = $Null

# Collect Files
$FileEntry            = $Zip.Entries | ? Name -notmatch "(Master|Logs).txt"

# Create progress loop
$Complete             = @( )
$Phase                = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "Importing (0.00%) [~] Files: ($($FileEntry.Count)) found."
ForEach ($X in 0..($FileEntry.Count-1))
{
    $Item             = Get-EventLogRecordExtension -Index $X -Entry $FileEntry[$X]
    $Hash.Add($X,$Item)

    $Stash[$Item.LogName].Add($Stash[$Item.LogName].Count,$X)
    
    $Percent          = [Math]::Round($X*100/$FileEntry.Count)
    If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
    {
        $Complete += $Percent
        If ($Percent -ne 0)
        {
            $Remain= ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
        }
        Write-Host "Importing ($Percent%) [~] Elapsed: [$($Time.Elapsed)], Remain: [$Remain]"
    }
}
$Phase.Stop()
Write-Host "Imported (100.00%) [+] Files: ($($FileEntry.Count)) found."
$Output         = $Hash[0..($Hash.Count-1)]

# Sort the logs
$Complete          = @( )
$Phase.Reset()
Write-Host "Sorting (0.00%) [~] Logs: ($($Logs.Count)) found."
ForEach ($X in 0..($Logs.Count-1))
{
    $Name = $Logs[$X].LogName
    Switch ($Stash[$Name].Count)
    {
        0 
        {  
            $Logs[$X].Output = @( )
        }
        1 
        {  
            $Logs[$X].Output = @($Output[$Stash[$Name][0]])
        }
        Default
        { 
            $Logs[$X].Output = @($Output[$Stash[$Name][0..($Stash[$Name].Count-1)]])
        }
    }
    $Logs[$X].Total          = $Logs[$X].Output.Count

    $Percent                      = [Math]::Round($X*100/$Logs.Count)
    If ($Percent % 5 -eq 0 -and $Percent -notin $Complete)
    {
        $Complete += $Percent
        If ($Percent -ne 0)
        {
            $Remain = ($Phase.Elapsed.TotalSeconds / $Percent) * (100-$Percent) | % { [Timespan]::FromSeconds($_) }
        }
        Write-Host "Sorting ($Percent%) [~] Elapsed: [$($Time.Elapsed)], Remain: [$Remain]"
    }
}
Write-Host "Sorted (100.00%) [+] Logs: ($($Logs.Count)) found."
$Time.Stop()
