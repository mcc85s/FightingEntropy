<#
.SYNOPSIS
        Allows for exporting all of the event viewer logs on a Windows system.
.DESCRIPTION
        After many years of wondering how I could extract everything from *every* event log,
        this seems to do the trick. The utility takes a *really* long time, but it will
        collect every record in the event logs. Then, it will sort them and pipe each one
        over to a secondary record which can be used to exfiltrate the records as a bunch
        of .json files. They are log files, but .json does some good object conversion in 
        a pinch. Once all of the log files are in a hash table, they're all sorted by date
        and time- then cast into an array. At which point, the utility will reindex every
        file and keep the ranking for each entry in a particular log. Once all of the files 
        are reindexed, it will set-content to json and then import into a zip file. 
.LINK

.NOTES
          FileName: Export-EventLogs.ps1
          Solution: FightingEntropy Module
          Purpose: For exporting all of a systems event logs
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2022-04-08
          Modified: 2022-04-08
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:
.Example
#>

Add-Type -Assembly System.IO.Compression.Filesystem

Function Export-EventLogs
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][ValidateScript({Test-Path -Path $_})][String]$Path)

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
        Hidden [Object] $List
        [UInt32] $Total
        [Object] $Time
        [Object] $Output
        EventLogProvider([UInt32]$Index,[String]$Name)
        {
            $This.Index       = $Index
            $This.DisplayName = $Name
            $This.Name        = $Name -Replace "(\/|\s)","_"
            $This.List        = Get-WinEvent -LogName $Name -EA 0 | Sort-Object TimeCreated
            $This.Total       = $This.List.Count
            $This.Time        = [System.Diagnostics.Stopwatch]::New()
        }
        Collect()
        {
            $Remain           = $Null
            $This.Time.Start()
            Write-Progress -ParentID 1 -Activity "Extracting [~] Event: <Beginning>" -Status "0.00% [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 0
            $Hash             = @{ }

            Switch ($This.List.Count)
            {
                {$_ -eq 0}
                {
                    Write-Progress -ParentID 1 -Activity "Extracting [~] Event: (0) entries found" -Status "50.00% (0/0) [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 50
                    $This.Output = @()
                }
                {$_ -eq 1}
                {
                    Write-Progress -ParentID 1 -Activity "Extracting [~] Event: $($This.List[0].TimeCreated.ToString("yyyy_MMdd-HHmmss"))" -Status "50.00% (1/1) [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 50
                    $Hash.Add(0,[EventEntry]::New(0,$This.Index,$This.List[0]))
                    $This.Output = @($Hash[0])
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($This.List.Count-1))
                    {
                        $PercentComplete = $X * 100 / $This.List.Count
                        $Str             = "{0:n2}%" -f $PercentComplete
                        $PercentRemain   = 100-$PercentComplete
                        $TimeElapsed     = $This.Time.Elapsed.TotalSeconds
                        $TimeUnit        = $TimeElapsed / $PercentComplete
                        $TimeRemain      = $TimeUnit * $PercentRemain

                        If ($X -ne 0)
                        {
                            $Remain      = [TimeSpan]::FromSeconds($TimeRemain)
                        }
                        If ($X -eq 0)
                        {
                            $Remain      = [TimeSpan]::FromSeconds(0)
                        }
                        Write-Progress -ParentID 1 -Activity "Extracting [~] Event: $($This.List[$X].TimeCreated.ToString("yyyy_MMdd-HHmmss"))" -Status "$Str ($X/$($This.List.Count)) [~] Elapsed: [$($This.Time.Elapsed)], Remaining: [$Remain]" -PercentComplete $PercentComplete
                        $Hash.Add($X,[EventEntry]::New($X,$This.Index,$This.List[$X]))
                    }
                    $This.Output = @($Hash[0..($Hash.Count-1)])
                }
            }
            $This.Time.Stop()
            Write-Progress -ParentID 1 -Activity "Extracting [+] Event: <Ending>" -Status "100.00% [~] Elapsed: [$($This.Time.Elapsed)], Complete" -Complete
        }
    }

    Class EventLogList
    {
        [String[]] $Names
        [Object]   $Time
        [Object[]] $Log
        [UInt32]   $Total
        [Object]   $Output
        EventLogList()
        {
            $This.Time   = [System.Diagnostics.Stopwatch]::StartNew()
            $This.Names  = Get-WinEvent -ListLog * | % LogName | Select-Object -Unique | Sort-Object
            $Ct          = $This.Names.Count
            $Depth       = ([String]$Ct).Length
            $This.Log    = @( )
            $This.Output = @( )

            # Collect Logs and sub items
            ForEach ($X in 0..($Ct-1))
            {
                $Name        = $This.Names[$X]
                $Rank        = "{0:d$Depth}" -f $X
                If ($Name -eq "Security")
                {
                    Write-Host "Loading [~] Time: [$($This.Time.Elapsed)], Rank: ($Rank/$Ct), Event log: [$Name - this log can take several minutes]"
                }
                If ($Name -ne "Security")
                {
                    Write-Host "Loading [~] Time: [$($This.Time.Elapsed)], Rank: ($Rank/$Ct), Event log: [$Name]"
                }
                
                $Current     = [EventLogProvider]::New($This.Log.Count,$This.Names[$X])
                $This.Log   += $Current
            }

            $This.Total      = ($This.Log | % { $_.Total }) -join "+" | Invoke-Expression
            $This.Time.Stop()
            Write-Host "Loaded [~] Time: [$($This.Time.Elapsed)]"
        }
        Collect()
        {
            $This.Time.Reset()
            $This.Time.Start()
            $Ct                  = $This.Names.Count
            $Depth               = ([String]$Ct).Length
            $Hash                = @{ }
            $Remain              = $Null

            # Collect more details
            Write-Progress -Id 1 -Activity "Processing [~] Event logs: ($Ct), Events: ($($This.Total))" -Status "0.00% [~] Elapsed: [$($This.Time.Elapsed)]" -PercentComplete 0
            ForEach ($X in 0..($Ct-1))
            {
                $Name            = $This.Names[$X]
                $PercentComplete = $Hash.Count * 100 / $This.Total
                $Str             = "{0:n2}%" -f $PercentComplete
                $PercentRemain   = 100-$PercentComplete
                $TimeElapsed     = $This.Time.Elapsed.TotalSeconds
                $TimeUnit        = $TimeElapsed / $PercentComplete
                $TimeRemain      = $TimeUnit * $PercentRemain

                If ($X -gt 0)
                {
                    $Remain      = [TimeSpan]::FromSeconds($TimeRemain)
                }
                If ($X -eq 0)
                {
                    $Remain      = [TimeSpan]::FromSeconds(0)
                }

                Write-Progress -Id 1 -Activity ( "Processing [~] Event log: [$Name], Rank: ({0:d$Depth}/$Ct)" -f $X) -Status "$Str ($($Hash.Count)/$($This.Total)) [~] Elapsed: [$($This.Time.Elapsed)], Remaining: [$Remain]" -PercentComplete $PercentComplete

                Write-Host ("Processing [~] Elapsed: [$($This.Time.Elapsed)], Rank: ({0:d$Depth}/$Ct), Event log: [$Name]" -f $X)

                $This.Log[$X].Collect()
                ForEach ($Entry in $This.Log[$X].Output)
                {
                    $Hash.Add($Hash.Count,$Entry)
                }
            }
            Write-Progress -Id 1 -Activity "Processed [+] Event logs" -Status "100.00% [~] Elapsed: [$($This.Time.Elapsed)]" -Complete

            Write-Host "Sorting [~] Elapsed: [$($This.Time.Elapsed)], ($($This.Total)) entries found- Sorting event logs by (date/time)"
            $This.Output      = $Hash[0..($Hash.Count-1)] | Sort-Object DateTime

            $This.Time.Stop()
            Write-Host "Sorted [+] Elapsed: [$($This.Time.Elapsed)], Event logs sorted"
        }
        Export([String]$PathDir)
        {
            If (!(Test-Path $PathDir))
            {
                Throw "Invalid target path"
            }

            $This.Time.Reset()
            $This.Time.Start()
            $Ct                  = $This.Output.Count
            $Depth               = ([String]$Ct).Length
            $Remain              = $Null
            $PathName            = "{0}-{1}" -f [DateTime]::Now.ToString("yyyy_MMdd-HHmmss"), $Env:ComputerName
            $Destination         = "{0}\{1}" -f $PathDir, $PathName

            # Create Path and Providers
            New-Item -Path $Destination -ItemType Directory -Verbose
            Set-Content "$Destination\Providers.txt" -Value @($This.Names) -Verbose

            $Zip                 = [System.IO.Compression.ZipFile]::Open("$Destination.zip","create")
            $Zip.Dispose()
            $Zip                 = [System.IO.Compression.ZipFile]::Open("$Destination.zip","update")

            # Update the (index/name), write the content to file, and import to zip archive
            Write-Progress -Activity "Exporting [~] Event logs, ($Ct) entries found." -Status "0.00% [~] Elapsed: [$($This.Time.Elapsed)], Starting" -PercentComplete 0
            ForEach ($X in 0..($Ct-1))
            {
                $Item            = $This.Output[$X]
                $PercentComplete = $X * 100 / $Ct
                $Str             = "{0:n2}%" -f $PercentComplete
                $PercentRemain   = 100-$PercentComplete
                $TimeElapsed     = $This.Time.Elapsed.TotalSeconds
                $TimeUnit        = $TimeElapsed / $PercentComplete
                $TimeRemain      = $TimeUnit * $PercentRemain
                If ($X -ne 0)
                {
                    $Remain      = [TimeSpan]::FromSeconds($TimeRemain)
                }
                If ($X -eq 0)
                {
                    $Remain      = [TimeSpan]::FromSeconds(0)
                }
                
                $Item.Index      = $X
                $Item.Name       = "({0:d$Depth})-{1}-({2}-{3})" -f $X, $Item.Date, $Item.Log, $Item.Rank

                Write-Progress -Activity "Exporting [~] Event: $($Item.Name)" -Status "$Str ($X/$Ct) [~] Elapsed: [$($This.Time.Elapsed)], Remaining: [$Remain]" -PercentComplete $PercentComplete

                $TargetPath      = "{0}\{1}.log" -f $Destination, $Item.Name
                $TargetValue     = ConvertTo-Json -InputObject $Item
                Set-Content $TargetPath $TargetValue
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Zip,$TargetPath,$Item.Name,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
            }
            Write-Progress -Activity "Exporting [+] Event log list" -Status "100.00% [~] Elapsed: [$($This.Time.Elapsed)], Complete" -Complete

            Write-Host "Saving [~] Elapsed: [$($This.Time.Elapsed)],  File: $Destination.zip [~] Please wait, the process may appear to freeze."
            $Zip.Dispose()
            $Item = Get-Item "$Destination.zip"
            If ($Item)
            {
                Write-Host "Success [+] File: [$Destination.zip], Size: [$("{0:n3}MB" -f ($Item.Length/1MB))]"
            }
            If (!$Item)
            {
                Write-Host "Failure [!] File: [$Destination.zip], the file does not exist."
            }
            $This.Time.Stop()
        }
    }

    $EventList = [EventLogList]::New()
    Try 
    {
        $EventList.Collect()    
        If ($EventList.Output.Count -gt 0)
        {
            $EventList.Export($Path)
        }
        Else
        {
            Throw "Error [!] Unable to collect <any> records from event logs"
        }
    }
    Catch
    {
        Throw "Error [!] Unable to collect <all> records from event logs"
    }
}
