<#
.SYNOPSIS
        Allows for getting all of the event log events from ALL event log providers.
.DESCRIPTION
        After many years of wondering how I could extract everything from *every* event log,
        this seems to do the trick. The utility takes a *really* long time, but it will
        collect *every* record in the event logs.
.LINK

.NOTES
          FileName: EventLogs.ps1
          Solution: FightingEntropy Module
          Purpose: For (getting/exporting/importing) event logs.
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-04-08
          Modified: 2022-04-12
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression.Filesystem

Function EventLogs
{
    Class Progress
    {
        [Object] $Rank
        [Object] $Total
        Hidden [UInt32] $Depth
        [Double] $Percent
        [String] $Status
        [Object] $Time
        [Object] $Elapsed
        [Object] $Remain
        [Object] $Estimate
        [Bool]   $Complete
        Progress([Object]$Workload)
        {
            If ($Workload.Count -le 1)
            {
                Throw "Invalid workload, must be more than a single item"
            }
            $This.Rank         = 0
            $This.Total        = $Workload.Count
            $This.Depth        = ([String]$This.Total).Length
            $This.Time         = [System.Diagnostics.Stopwatch]::New()
            $This.Calculate()
            $This.Complete     = $False
        }
        Calculate()
        {
            $This.Percent      = $This.Rank * 100 / $This.Total
            $This.Elapsed      = $This.Time.Elapsed 
            $This.Remain       = ($This.Time.Elapsed.TotalSeconds / $This.Percent) * (100-$This.Percent)
            If ($This.Rank -ne 0)
            {
                $This.Estimate = [Timespan]::FromSeconds($This.Remain)
            }
            If ($This.Rank -eq 0)
            {
                $This.Estimate = [Timespan]::FromSeconds(0)
            }
            $This.Status       = $This.GetFullStatus()
            If ($This.Rank -eq $This.Total - 1)
            {
                $This.Complete = $True
            }
        }
        [String] GetPercent()
        {
            Return "{0:n2}%" -f $This.Percent
        }
        [String] GetRank()
        {
            Return ("({0:d$($This.Depth)}/$($This.Total-1))" -f $This.Rank)
        }
        [String] GetElapsed()
        {
            Return "$($This.Time.Elapsed)"
        }
        [String] GetRemain()
        {
            Return "$($This.Estimate)"
        }
        [String] GetFullStatus()
        {
            Return "{0} {1} [~] Elapsed: [{2}], Remain: [{3}]" -f $This.GetPercent(), $This.GetRank() , $This.GetElapsed(), $This.GetRemain()
        }
        Increment()
        {
            $This.Rank        += 1
            $This.Calculate()
        }
        Start()
        {
            $This.Time.Start()
        }
        Stop()
        {
            $This.Time.Stop()
        }
    }

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
            $This.InsertEvent($Event)
        }
        EventEntry([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
            $Event                     = Get-Content $Path | ConvertFrom-Json
            $This.Index                = $Event.Index
            $This.Name                 = $Event.Name
            $This.DateTime             = [DateTime]$Event.DateTime
            $This.Date                 = $Event.Date
            $This.Log                  = $Event.Log
            $This.Rank                 = $Event.Rank
            $This.Provider             = $Event.Provider
            $This.Id                   = $Event.Id
            $This.Type                 = $Event.Type
            $This.InsertEvent($Event)
        }
        EventEntry([Object]$Entry)
        {
            $Stream                    = $Entry.Open()
            $Reader                    = [System.IO.StreamReader]::New($Stream)
            $Event                     = $Reader.ReadToEnd() | ConvertFrom-Json
            $Reader.Close()
            $Stream.Close()
            $This.Index                = $Event.Index
            $This.Name                 = $Event.Name
            $This.DateTime             = [DateTime]$Event.DateTime
            $This.Date                 = $Event.Date
            $This.Log                  = $Event.Log
            $This.Rank                 = $Event.Rank
            $This.Provider             = $Event.Provider
            $This.Id                   = $Event.Id
            $This.Type                 = $Event.Type
            $This.InsertEvent($Event)
        }
        InsertEvent([Object]$Event)
        {
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
        SetIndex([UInt32]$Index,[UInt32]$Depth)
        {
            $This.Index                = $Index
            $This.Name                 =  "({0:d$Depth})-{1}-({2}-{3})" -f $Index, $This.Date, $This.Log, $This.Rank
        }
        [Object] Export()
        {
            Return @( $This | ConvertTo-Json )
        }
        [Object] ToString()
        {
            Return @( $This.Export() | ConvertFrom-Json )
        }
        [Void] SetContent([String]$Path)
        {
            [System.IO.File]::WriteAllLines($Path,$This.Export())
        }
    }

    Class EventLogProvider
    {
            [UInt32] $Index
            [String] $Name
            [Object] $List
            [UInt32] $Total
            [Object] $Time
            [Object] $Output
            EventLogProvider([UInt32]$Index,[String]$Name)
            {
                $This.Index       = $Index
                $This.Name        = $Name
                $This.List        = Get-WinEvent -LogName $Name -EA 0 | Sort-Object TimeCreated
                $This.Total       = $This.List.Count
                $This.Time        = [System.Diagnostics.Stopwatch]::New()
            }
            EventLogProvider([Uint32]$Index,[String]$Name,[UInt32]$Option)
            {
                $This.Index       = $Index
                $This.Name        = $Name
                $This.List        = @( )
                $This.Total       = 0
                $This.Time        = [System.Diagnostics.Stopwatch]::New()
            }
            Collect()
            {
                $This.Time.Start()
                $Hash             = @{ }
                Write-Progress -ParentId 1 -Activity "Extracting [~] Log: [$($This.Name)]" -Status "0.00% [~] Elapsed: [$($This.Time.Elapsed)], Starting" -PercentComplete 0
                Switch ($This.Total)
                {
                    {$_ -eq 0}
                    {
                        Write-Progress -ParentID 1 -Activity "Extracting [~] Event: (0) entries found." -Status "50.00% (0/0) [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 50
                        $This.Output = @( )
                    }
                    {$_ -eq 1}
                    {
                        $Hash.Add(0,[EventEntry]::New(0,$This.Index,$This.List[0]))
                        Write-Progress -ParentID 1 -Activity "Extracting [~] Event: [$($Hash[0].Date)]" -Status "50.00% (1/1) [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 50
                        $This.Output = @($Hash[0])
                    }
                    {$_ -gt 1}
                    {
                        $P           = [Progress]::New($This.List)
                        $P.Start()
                        ForEach ($X in 0..($This.List.Count-1))
                        {
                            $Hash.Add($X,[EventEntry]::New($X,$This.Index,$This.List[$X]))
                            Write-Progress -ParentID 1 -Activity "Extracting [~] Event: [$($Hash[$X].Date)]" -Status $P.Status -PercentComplete $P.Percent
                            $P.Increment()
                        }
                        $P.Stop()
                        $This.Output = @($Hash[0..($Hash.Count-1)])
                    }
                }
                $This.Time.Stop()
                Write-Progress -ParentId 1 -Activity "Extracted [+] Log: [$($This.Name)]" -Status "100.00% [~] Elapsed: [$($This.Time.Elapsed)], Complete" -Complete
            }
    }

    Class EventList
    {
        [String]   $Title
        [String]   $Destination
        Hidden [Object] $Zip
        [Object]   $Time
        [UInt32]   $Total
        Hidden [Object[]] $Phase 
        [String[]] $Providers
        [Object[]] $Log
        [Object[]] $Output
        EventList()
        {
            $This.Title       = "{0}-{1}" -f [DateTime]::Now.ToString("yyyy_MMdd-HHmmss"), $Env:ComputerName
            $This.Destination = "$Env:Temp\{0}" -f $This.Title
            $This.Time        = [System.Diagnostics.Stopwatch]::New()
            $This.Providers   = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
            $This.Phase       = @( )
        }
        EventList([String]$ZipFile)
        {
            If (!(Test-Path $Zipfile) -or $ZipFile.Split(".")[-1] -notmatch "zip")
            {
                Throw "Invalid Path"
            }
            
            $This.Title       = (Get-Item $ZipFile).BaseName
            $This.Destination = $ZipFile
            $This.Time        = [System.Diagnostics.Stopwatch]::StartNew()
            $This.Zip         = [System.IO.Compression.ZipFile]::Open($ZipFile,"Read")
            
            # Get provider strings
            $Provider         = $This.Zip.Entries | ? Name -match Providers
            $ProviderPath     = "$Env:Temp\Providers.txt"
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($Provider,$ProviderPath,$True)
            $This.Providers   = Get-Content $ProviderPath
            Remove-Item $ProviderPath
            
            $Ct               = $This.Providers.Count
            $Depth            = ([String]$Ct).Length
            $This.Log         = @( )
            $This.Output      = @( )
            $Hash             = @{ }
            $LHash            = @{ }
            $RHash            = @{ }
            
            # Collect Logs and sub items
            ForEach ($X in 0..($Ct-1))
            {
                $Name            = $This.Providers[$X]
                $RankStr         = "{0:d$Depth}/$Ct" -f $X
                Write-Host "Opening [~] Elapsed: [$($This.Time.Elapsed)], Rank: ($RankStr), Event log: [$Name]"
                $Current         = [EventLogProvider]::New($This.Log.Count,$Name,0)
                $LHash.Add($Name,@{ })
                $This.Log       += $Current
            }
            # Collect Files
            $Files               = $This.Zip.Entries | ? Name -notmatch Providers
            $This.Total          = $Files.Count
            $P                   = [Progress]::New($Files)
            $P.Start()
            Write-Progress -Activity "Opening [~] Files: ($($Files.Count)" -Status $P.Status -PercentComplete 0
            ForEach ($X in 0..($Files.Count-1))
            {
                $File            = $Files[$X]
                $Item            = [EventEntry]$File
                Write-Progress -Activity "Opening [~] File: [$($Item.Name)]" -Status $P.Status -PercentComplete $P.Percent
                $Hash.Add($X,$Item)
                $LHash["$($Item.LogName)"].Add($Item.Rank,$Item.Index)
                $P.Increment()
            }
            $P.Stop()
            Write-Progress -Activity "Opened [+] Files" -Status $P.Status -Complete
            $This.Output         = $Hash[0..($Hash.Count-1)]
            $P                   = [Progress]::New($This.Providers)
            $P.Start()
            Write-Progress -Activity "Sorting [~] Logs" -Status $P.Status -PercentComplete 0
            ForEach ($X in 0..($This.Providers.Count-1))
            {
                $LogName         = $This.Providers[$X]
                Write-Progress -Activity "Sorting [~] Log: [$LogName]" -Status $P.Status -PercentComplete $P.Percent
                $LogItem         = $This.Log | ? Name -eq $LogName
                $Slot            = $LHash["$($LogName)"].GetEnumerator() | Sort-Object Name | % Value
                $LogItem.Time.Start()
                Switch ($Slot.Count)
                {
                    {$_ -eq 0} 
                    {
                        $LogItem.Output = @( )
                    } 
                    {$_ -eq 1} 
                    { 
                        $RHash = @{ }
                        $RHash.Add(0,$This.Output[$Slot[0]])
                        $LogItem.Output = @($RHash[0])
                    }
                    {$_ -gt 1}
                    {
                        $RHash = @{ }
                        ForEach ($X in 0..($Slot.Count-1))
                        {
                            $RHash.Add($X,$This.Output[$Slot[$X]])
                        }
                        $LogItem.Output = @($RHash[0..($RHash.Count-1)])
                    }
                }
                $LogItem.Total = $LogItem.Output.Count
                $LogItem.Time.Stop()
            }
            $P.Stop()
            Write-Progress -Activity "Sorted [+] Logs" -Status $P.Status -Complete
            $This.Time.Stop()
            Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Logs (imported/sorted)"
        }
        GetProvider()
        {
            # Phase 1
            $This.Time.Start()
            $Ct               = $This.Providers.Count
            $Depth            = ([String]$Ct).Length
            $P                = [Progress]::New($This.Providers)
            Write-Progress -Activity "Collecting [~] Event logs: ($($This.Providers.Count)) found." -Status "$($P.Status), Starting" -PercentComplete $P.Percent
            $P.Start()
            ForEach ($X in 0..($This.Providers.Count-1))
            {
                $Item         = $This.Providers[$X]
                $Label        = @(""," - this log takes several minutes")[$Item -eq "Security"]
                Write-Progress -Activity "Collecting [~] Event log: [$Item$Label]" -Status $P.Status -PercentComplete $P.Percent
                Write-Host "Collecting [~] Elapsed: [$($This.Time.Elapsed)], Rank: $($P.GetRank()), Name: [$Item$Label]"
                $Current      = [EventLogProvider]::New($X,$Item)
                $This.Log    += $Current
                $P.Increment()
            }
            $P.Stop()
            Write-Progress -Activity "Collected [+] Event logs" -Status $P.Status -Complete
            $This.Total       = $This.Log.Total -join "+" | Invoke-Expression
            Write-Host "Found [+] Total events: ($($This.Total))"
            $This.Time.Stop()
            $This.Phase      += "Phase 1: [$($This.Time.Elapsed)]"
        }
        GetOutput()
        {
            # Phase 2
            $Hash             = @{ }
            $Ct               = $This.Log.Count
            $Depth            = ([String]$Ct).Length
            $This.Time.Start()
            $P                = [Progress]::New($This.Log.List)
            $P.Start()
            Write-Progress -Id 1 -Activity "Processing [~] Event logs: ($($P.Total)), Events: ($($This.Total))" -Status $P.Status -PercentComplete 0
            ForEach ($X in 0..($This.Log.Count-1))
            {
                $Item            = $This.Log[$X]
                $RankStr         = "{0:d$Depth}/$($This.Log.Count-1)" -f $X
                Write-Progress -Id 1 -Activity "Processing [~] Rank: ($RankStr), Name: [$($Item.Name)]" -Status $P.Status -PercentComplete $P.Percent
                $Item.Collect()
                ForEach ($Entry in $Item.Output)
                {
                    $Hash.Add($Hash.Count,$Entry)
                    $P.Increment()
                }
            }
            $P.Stop()
            Write-Progress -Id 1 -Activity "Processed [+] Event logs: ($($P.Total))" -Status $P.Status -Complete
            Write-Host "Sorting [~] Elapsed: [$($This.Time.Elapsed)], ($($This.Total)) entries found- Sorting event logs by (date/time)"
            $This.Output      = $Hash[0..($Hash.Count-1)] | Sort-Object DateTime
            Write-Host "Sorted [+] Elapsed: [$($This.Time.Elapsed)], Event logs sorted"
            $This.Time.Stop()
            $This.Phase      += "Phase 2: [$($This.Time.Elapsed)]"
        }
        SetIndex()
        {
            # Phase 3A
            $This.Time.Start()
            $P = [Progress]::New($This.Output)
            $P.Start()
            Write-Progress -Activity "Indexing [~] Events: ($($P.Count)) found." -Status "$($P.Status), Starting" -PercentComplete $P.Percent
            ForEach ($X in 0..($This.Output.Count-1))
            {
                $Item       = $This.Output[$X]
                $Item.SetIndex($X,$P.Depth)
                Write-Progress -Activity "Indexing [~] Event: [$($Item.Name)]" -Status $P.Status -PercentComplete $P.Percent
                $P.Increment()
            }
            Write-Progress -Activity "Indexed [+] Events: ($($P.Count))" -Status "$($P.Status), Complete" -PercentComplete $P.Percent
            $P.Stop()
            $This.Time.Stop()
            $This.Phase      += "Phase 3: [$($This.Time.Elapsed)]"
        }
        Write()
        {
            # Phase 3A.2
            If (Test-Path $This.Destination)
            {
                Throw "Destination path [$($This.Destination)] already exists, manually (delete/move) it, and try again."
            }
            
            $ZipDest = "$($This.Destination).zip"
            If (Test-Path $ZipDest)
            {
                Throw "Destination file [$ZipDest] already exists, manually (delete/move) it, and try again."
            }
            $This.Time.Start()
            # Path
            New-Item -Path $This.Destination -ItemType Directory -Verbose
            Set-Content -Path "$($This.Destination)\Providers.txt" -Value @($This.Providers) -Verbose
            
            # Zip file
            [System.IO.Compression.ZipFile]::Open($ZipDest,"Create").Dispose()
            $This.Zip = [System.IO.Compression.ZipFile]::Open($ZipDest,"Update")
            
            # Add Provider log list to zip
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,"$($This.Destination)\Providers.txt","Providers",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
            # Add individual logs to zip file
            $P = [Progress]::New($This.Output)
            $P.Start()
            Write-Progress -Activity "Indexing [~] Events: ($($P.Count)) found." -Status "$($P.Status), Starting" -PercentComplete $P.Percent
            ForEach ($X in 0..($This.Output.Count-1))
            {
                $Item       = $This.Output[$X]
                If (!$Item.Name)
                {
                    Throw "Item(s) haven't had an (index/name) applied."
                    $This.Zip.Dispose()
                    Remove-Item $ZipDest -Verbose
                }
                Write-Progress -Activity "Indexing [~] Event: [$($Item.Name)]" -Status $P.Status -PercentComplete $P.Percent
                $TargetPath      = "{0}\{1}.log" -f $This.Destination, $Item.Name
                $Item.SetContent($TargetPath)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,$TargetPath,$Item.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
                $P.Increment()
            }
            Write-Progress -Activity "Indexed [+] Events: ($($P.Count))" -Status "$($P.Status), Complete" -PercentComplete $P.Percent
            $P.Stop()
            Write-Host "Saving [~] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest] (Please wait, the process may appear to freeze while it is saving)"
            $This.Zip.Dispose()
            $Item = Get-Item $ZipDest
            Switch ($Item)
            {
                $True
                {
                    Write-Host "Success [+] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest], Size: [$("{0:n3}MB" -f ($Item.Length/1MB))]"
                }
                $False
                {
                    Write-Host "Failure [!] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest], the file does not exist."
                }
            }
            Write-Host "Removing [~] Elapsed: [$($This.Time.Elapsed)], Folder: [$($This.Destination)] (Please wait, the process is removing the swap folder)"
            Remove-Item $This.Destination -Recurse -Confirm:$False
            Switch ($Item)
            {
                $True
                {
                    Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive saved: [$ZipDest]"
                }
                $False
                {
                    Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive failed: [$ZipDest]"
                }
            }
            $This.Time.Stop()
            $This.Phase      += "Phase 3B: [$($This.Time.Elapsed)]"
        }
        SetIndexWrite()
        {
            # Phase 3B
            If (Test-Path $This.Destination)
            {
                Throw "Destination path [$($This.Destination)] already exists, manually (delete/move) it, and try again."
            }
            
            $ZipDest = "$($This.Destination).zip"
            If (Test-Path $ZipDest)
            {
                Throw "Destination file [$ZipDest] already exists, manually (delete/move) it, and try again."
            }
            $This.Time.Start()
            # Path
            New-Item -Path $This.Destination -ItemType Directory -Verbose
            Set-Content -Path "$($This.Destination)\Providers.txt" -Value @($This.Providers) -Verbose
            
            # Zip file
            [System.IO.Compression.ZipFile]::Open($ZipDest,"Create").Dispose()
            $This.Zip = [System.IO.Compression.ZipFile]::Open($ZipDest,"Update")
            
            # Add Provider log list to zip
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,"$($This.Destination)\Providers.txt","Providers",[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
            
            # Add individual logs to zip file
            $P = [Progress]::New($This.Output)
            $P.Start()
            Write-Progress -Activity "Indexing [~] Events: ($($P.Count)) found." -Status "$($P.Status), Starting" -PercentComplete $P.Percent
            ForEach ($X in 0..($This.Output.Count-1))
            {
                $Item       = $This.Output[$X]
                $Item.SetIndex($X,$P.Depth)
                Write-Progress -Activity "Indexing [~] Event: [$($Item.Name)]" -Status $P.Status -PercentComplete $P.Percent
                $TargetPath      = "{0}\{1}.log" -f $This.Destination, $Item.Name
                $Item.SetContent($TargetPath)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Zip,$TargetPath,$Item.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
                $P.Increment()
            }
            Write-Progress -Activity "Indexed [+] Events: ($($P.Count))" -Status "$($P.Status), Complete" -PercentComplete $P.Percent
            $P.Stop()
            Write-Host "Saving [~] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest] (Please wait, the process may appear to freeze while it is saving)"
            $This.Zip.Dispose()
            $Item = Get-Item $ZipDest
            Switch ($Item)
            {
                $True
                {
                    Write-Host "Success [+] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest], Size: [$("{0:n3}MB" -f ($Item.Length/1MB))]"
                }
                $False
                {
                    Write-Host "Failure [!] Elapsed: [$($This.Time.Elapsed)], File: [$ZipDest], the file does not exist."
                }
            }
            Write-Host "Removing [~] Elapsed: [$($This.Time.Elapsed)], Folder: [$($This.Destination)] (Please wait, the process is removing the swap folder)"
            Remove-Item $This.Destination -Recurse -Confirm:$False
            Switch ($Item)
            {
                $True
                {
                    Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive saved: [$ZipDest]"
                }
                $False
                {
                    Write-Host "Complete [+] Elapsed: [$($This.Time.Elapsed)], Archive failed: [$ZipDest]"
                }
            }
            $This.Time.Stop()
            $This.Phase      += "Phase 3B: [$($This.Time.Elapsed)]"
        }
    }

    Class EventControl
    {
        EventControl()
        {

        }
        [Object] GetEventList()
        {
            $EventList = [EventList]::New()
            $EventList.GetProvider()
            $EventList.GetOutput()
            $EventList.SetIndex()
            Return $EventList
        }
        [Void] ExportEventList()
        {
            $EventList = [EventList]::New()
            $EventList.GetProvider()
            $EventList.GetOutput()
            $EventList.SetIndexWrite()
        }
        [Void] ExportEventList([Object]$EventList)
        {
            $EventList.Write()
        }
        [Object] ImportEventList([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
            Return [EventList]::New($Path) 
        }
    }

    [EventControl]::New()
}

Function Get-EventLogs
{
    Return (EventLogs).GetEventList()
}

Function Export-EventLogs
{
    [CmdletBinding(DefaultParameterSetName = 0)]
    Param (
        [Parameter(ParameterSetName = 0)][EventList]$EventList,
        [Parameter(ParameterSetName = 1)][Switch]$New
    )

    Switch ($PsCmdLet.ParameterSetName)
    {
        0
        {
            (EventLogs).ExportEventList($EventList)
        }
        1
        {
            (EventLogs).ExportEventList()
        }
    }
}

Function Import-EventLogs
{
    [CmdLetBinding()]
    Param([Parameter(Mandatory)][ValidateScript({Test-Path $_})][String]$Path)

    Return (EventLogs).ImportEventList($Path)
}
