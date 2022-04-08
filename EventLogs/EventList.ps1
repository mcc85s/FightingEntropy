# Takes a while, but it collects all of the events in event viewer, sorts them, and exports them to a zip file.
Add-Type -Assembly System.IO.Compression.Filesystem

Class EventEntry
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
    [String[]] $Content
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
    EventEntry([UInt32]$Rank,[UInt32]$Log,[Object]$Event)
    {
        $This.Rank     = $Rank
        $This.Provider = $Event.ProviderName
        $This.DateTime = $Event.TimeCreated
        $This.Date     = $Event.TimeCreated.ToString("yyyy_MMdd-HHmmss")
        $This.Log      = $Log
        $This.Id       = $Event.Id
        $This.Type     = $Event.LevelDisplayName
        $FullMessage   = $Event.Message -Split "`n"
        Switch ($FullMessage.Count)
        {
            {$_ -gt 1}
            {
                $This.Message  = $FullMessage[0]
                $This.Content  = $FullMessage
            }
            {$_ -eq 1}
            {
                $This.Message  = $FullMessage
                $This.Content  = $FullMessage
            }
            {$_ -eq 0}
            {
                $This.Message  = "-"
                $This.Content  = "-"
            }
        }
        $This.Version              = $Event.Version
        $This.Qualifiers           = $Event.Qualifiers
        $This.Level                = $Event.Level
        $This.Task                 = $Event.Task
        $This.Opcode               = $Event.Opcode
        $This.Keywords             = $Event.Keywords
        $This.RecordId             = $Event.RecordId
        $This.ProviderId           = $Event.ProviderId
        $This.LogName              = $Event.LogName
        $This.ProcessId            = $Event.ProcessId
        $This.ThreadId             = $Event.ThreadId
        $This.MachineName          = $Event.MachineName
        $This.UserID               = $Event.UserId
        $This.ActivityID           = $Event.ActivityId
        $This.RelatedActivityID    = $Event.RelatedActivityID
        $This.ContainerLog         = $Event.ContainerLog
        $This.MatchedQueryIds      = @($Event.MatchedQueryIds)
        $This.Bookmark             = $Event.Bookmark
        $This.OpcodeDisplayName    = $Event.OpcodeDisplayName
        $This.TaskDisplayName      = $Event.TaskDisplayName
        $This.KeywordsDisplayNames = @($Event.KeywordsDisplayNames)
        $This.Properties           = @($Event.Properties.Value)
    }
}

Class EventLogProvider
{
    [UInt32] $Index
    Hidden [String] $DisplayName
    [String] $Name
    [UInt32] $Total
    [Object] $Time
    [Object] $Output
    EventLogProvider([UInt32]$Index,[String]$Name,[UInt32]$Id)
    {
        $This.Index       = $Index
        $This.DisplayName = $Name
        $This.Name        = $Name -Replace "(\/|\s)","_"
        $XTime            = [System.Diagnostics.Stopwatch]::StartNew()
        $List             = Get-WinEvent -LogName $Name -EA 0 | Sort-Object TimeCreated
        $This.Total       = $List.Count

        Write-Progress -ParentID $Id -Activity "Collecting [~] Time: [$($XTime.Elapsed)], Event Log: [$Name]" -Status Starting -PercentComplete 0

        $Hash        = @{ }
        Switch ($List.Count)
        {
            {$_ -eq 0}
            {
                Write-Progress -ParentID $Id -Activity "Collecting [~] Time: [$($XTime.Elapsed)], Event Log: [$Name - (0) entries found], " -Status "100% (0/0)" -PercentComplete 50
                $This.Output = @()
            }
            {$_ -eq 1}
            {
                Write-Progress -ParentID $Id -Activity "Collecting [~] Time: [$($XTime.Elapsed)], Event log: [$Name]" -Status "100% (1/1)" -PercentComplete 50
                $Hash.Add(0,[EventEntry]::New(0,$This.Index,$List[0]))
                $This.Output = @($Hash[0])
            }
            {$_ -gt 1}
            {
                ForEach ($X in 0..($List.Count-1))
                {
                    $Percent = $X * 100 / $List.Count
                    $Str     = "{0:n2}%" -f $Percent
                    Write-Progress -ParentID $Id -Activity "Collecting [~] Time: [$($XTime.Elapsed)], Event log: [$Name]" -Status "$Str ($X/$($List.Count))" -PercentComplete $Percent
                    $Hash.Add($X,[EventEntry]::New($X,$This.Index,$List[$X]))
                }
                $This.Output = @($Hash[0..($Hash.Count-1)])
            }
        }
        $XTime.Stop()
        $This.Time = "$($XTime.Elapsed)"
        Write-Progress -ParentID $Id -Activity "Collected [+] Time: [$($This.Time)], Event log: [$Name]" -Status Complete -Complete
    }
}

Class EventLogList
{
    [String[]] $Names
    [Object]   $Time
    [Object[]] $Log
    [Object]   $Hash
    [UInt32]   $Total
    [Object]   $Output
    EventLogList()
    {
        $This.Time   = [System.Diagnostics.Stopwatch]::StartNew()
        $This.Names  = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
        $Ct          = $This.Names.Count
        $This.Log    = @( )
        $This.Hash   = @{ }
        $This.Output = @( )
        Write-Progress -Id 1 -Activity "Extracting [~] Time: [$($This.Time.Elapsed)], Event logs ($Ct total)" -Status Starting -PercentComplete 0
        ForEach ($X in 0..($Ct-1))
        {
            $Name         = $This.Names[$X]
            $Percent      = $X * 100 / $Ct
            $Str          = "{0:n2}%" -f $Percent
            Write-Progress -Id 1 -Activity "Extracting [~] Time: [$($This.Time.Elapsed)], Event log: [$Name]" -Status "$Str ($X/$Ct)" -PercentComplete $Percent

            If ($Name -ne "Security")
            {
                Write-Host "Processing [~] ($X/$Ct) Time: [$($This.Time.Elapsed)], Event log: [$Name]"
            }
            If ($Name -eq "Security")
            {
                Write-Host "Processing [~] ($X/$Ct) Time: [$($This.Time.Elapsed)], Event log: [$Name - may take several minutes to begin]"
            }

            $Current      = [EventLogProvider]::New($This.Log.Count,$Name,1)
            $This.Log    += $Current
            ForEach ($Entry in $Current.Output)
            {
                $This.Hash.Add($This.Hash.Count,$Entry)
            }
        }
        Write-Progress -Id 1 -Activity "Extracted [~] Time: [$($This.Time.Elapsed)], Event logs" -Status Complete -Complete

        $This.Total       = $This.Hash.Count
        $Ct               = $This.Total
        Write-Host "Sorting [~] Event logs by (date/time), ($Ct) entries found."
        $This.Output      = $This.Hash[0..($This.Hash.Count-1)] 
        $This.Output      = $This.Output | Sort-Object DateTime

        $This.Time.Stop()
        Write-Host "Sorted [+] Time: [$($This.Time.Elapsed)], Event logs"
    }
    SetIndexName()
    {
        $This.Time.Start()
        $Ct               = $This.Output.Count
        $Depth            = ([String]$Ct).Length

        Write-Progress -Activity "Indexing [~] Event log list, ($Ct) entries found." -Status Starting -PercentComplete 0
        ForEach ($X in 0..($Ct-1))
        {
            $Item         = $This.Output[$X]
            $Percent      = $X * 100 / $Ct
            $Str          = "{0:n2}%" -f $Percent
            Write-Progress -Activity "Indexing [~] Time: [$($This.Time.Elapsed)], Event log list" -Status "$Str ($X/$Ct)" -PercentComplete $Percent
            $Item.Index   = $X
            $Item.Name    = "({0:d$Depth})-{1}-({2}-{3})" -f $X, $Item.Date, $Item.Log, $Item.Rank
        }
        $This.Time.Stop()
        Write-Progress -Activity "Indexed [+] Time: [$($This.Time.Elapsed)], Event log list" -Status Complete -Complete
    }
}

Class EventLogOutput
{
    [String] $Path
    [String] $Name
    [String] $Destination
    [Object] $Provider
    [Object] $Output
    EventLogOutput([String]$Path,[Object]$EventList)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid target path"
        }

        If ($EventList.GetType().Name -ne "EventLogList")
        {
            Throw "Invalid input"
        }

        If ($EventList.Output.Count -eq 0)
        {
            Throw "Invalid input"
        }

        $This.Path        = $Path
        $This.Name        = "$([DateTime]::Now.ToString("yyyy_MMdd-HHmmss"))-$Env:ComputerName"
        $This.Destination = "{0}\{1}" -f $This.Path, $This.Name
        $This.Provider    = $EventList.Names
        $This.Output      = $EventList.Output
        $This.Establish()
        $Ct               = $This.Output.Count
        $Zip              = [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","create")
        $Zip.Dispose()
        $Compression      = [System.IO.Compression.CompressionLevel]::Fastest
        $Zip              = [System.IO.Compression.ZipFile]::Open("$($This.Destination).zip","update")
        $Time             = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Progress -Activity "Writing [~] Time: [$($Time.Elapsed)], Output: [$($This.Destination)]" -Status Starting -PercentComplete 0 
        ForEach ($X in 0..($This.Output.Count-1))
        {
            $Item            = $This.Output[$X]
            $PercentComplete = $X * 100 / $Ct
            $Str             = "{0:n2}%" -f $PercentComplete
            $PercentRemain   = ($Ct-$X)/100
            $TimeElapsed     = $Time.Elapsed.TotalSeconds
            $TimeUnit        = "{0:n2}" -f ($TimeElapsed / $PercentComplete)
            $TimeRemain      = "{0:n2}" -f ($TimeUnit * $PercentRemain)
            Write-Progress -Activity "Writing [~] Time: [$($Time.Elapsed)], Output: [$($This.Destination)]" -Status "$Str ($X/$Ct) [Elapsed: $($TimeElapsed)/sec], [Estimate: $($TimeRemain)/sec]" -PercentComplete $PercentComplete
            $TargetPath      = "{0}\{1}.log" -f $This.Destination, $Item.Name
            $TargetValue     = ConvertTo-Json -InputObject $Item
            Set-Content $TargetPath $TargetValue
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$Item.Fullname,$Item.Name,$Compression) | Out-Null
        }
        $Zip.Dispose()
        $Time.Stop()
        Write-Progress -Activity "Writing [+] Time: [$($Time.Elapsed)], Output" -Status Complete -Complete

    }
    Establish()
    {
        New-Item -Path $This.Destination -ItemType Directory -Verbose
        Set-Content "$($This.Destination)\Providers.txt" -Value @($This.Provider) -Verbose
    }
}

$EventList = [EventLogList]::New()
$EventList.SetIndexName()
$Ctrl      = [EventLogOutput]::New("C:\EventLogs",$EventList)
