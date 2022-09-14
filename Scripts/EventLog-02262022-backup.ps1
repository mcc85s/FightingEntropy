# Specifically meant to recover logs from 02/26/2022
Class EventLogRecord
{
    [UInt32]                  $Index
    [Int64]                      $Id
    [Int64]                 $Version
    [Object]             $Qualifiers
    [Int64]                   $Level
    [Int64]                    $Task
    [Int64]                  $Opcode
    [Int64]                $Keywords
    [Int64]                $RecordId
    [String]           $ProviderName
    [String]             $ProviderId
    [String]                $LogName
    [Int64]               $ProcessId
    [Int64]                $ThreadId
    [String]            $MachineName
    [Object]                 $UserId
    [DateTime]          $TimeCreated
    [Object]             $ActivityId
    [Object]      $RelatedActivityId
    [String]           $ContainerLog
    [Object[]]      $MatchedQueryIds
    [Object]               $Bookmark
    [String]       $LevelDisplayName
    [String]      $OpcodeDisplayName
    [Object]        $TaskDisplayName
    [Object[]] $KeywordsDisplayNames
    [Object[]]           $Properties
    [String]                $Message
    EventLogRecord([UInt32]$Index,[Object]$Obj)
    {
        $This.Index                = $Index
        $This.Id                   = $Obj.Id
        $This.Version              = $Obj.Version
        $This.Qualifiers           = $Obj.Qualifiers
        $This.Level                = $Obj.Level
        $This.Task                 = $Obj.Task
        $This.Opcode               = $Obj.Opcode
        $This.Keywords             = $Obj.Keywords
        $This.RecordId             = $Obj.RecordId
        $This.ProviderName         = $Obj.ProviderName
        $This.ProviderId           = $Obj.ProviderId
        $This.LogName              = $Obj.LogName
        $This.ProcessId            = $Obj.ProcessId
        $This.ThreadId             = $Obj.ThreadId
        $This.MachineName          = $Obj.MachineName
        $This.UserId               = $Obj.UserId
        $This.TimeCreated          = $Obj.TimeCreated
        $This.ActivityId           = $Obj.ActivityId
        $This.RelatedActivityId    = $Obj.RelatedActivityId
        $This.ContainerLog         = $Obj.ContainerLog
        $This.MatchedQueryIds      = $Obj.MatchedQueryIds
        $This.Bookmark             = $Obj.Bookmark
        $This.LevelDisplayName     = $Obj.LevelDisplayName
        $This.OpcodeDisplayName    = $Obj.OpcodeDisplayName
        $This.TaskDisplayName      = $Obj.TaskDisplayName
        $This.KeywordsDisplayNames = $Obj.KeywordsDisplayNames
        $This.Properties           = $Obj.Properties
        $This.Message              = $Obj.Message
    }
}

Class EventLogProvider
{
    [UInt32] $Index
    [String]  $Name
    [Object]  $Logs
    EventLogProvider([UInt32]$Index,[String]$Name)
    {
        $This.Index = $Index
        $This.Name  = $Name
        $This.Logs  = @( )
    }
    AddLog([Object]$Object)
    {
        $This.Logs += [EventLogRecord]::New($This.Logs.Count,$Object)
    }
}

Class EventLogSwap
{
    [UInt32]    $Index
    [String]     $Name
    [String] $Provider
    [Object]  $Content
    [Object]   $Object
    EventLogSwap([String]$Path)
    {
        $This.Name     = $Path | Split-Path -Leaf
        $This.Index    = [Regex]::Matches($This.Name,"^\(\d+\)").Value -Replace "(\(|\))",""
        $This.Provider = $This.Name -Replace "^\(\d+\)", ""
        $This.Content  = [System.IO.File]::ReadAllLines($Path)
        $This.Object   = $This.Content | ConvertFrom-Json
    }
}

Class EventLogContainer
{
    [String]        $Path
    [Hashtable] $Provider
    [Object]        $Logs
    EventLogContainer($Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }
        
        $This.Path          = $Path
        $This.Provider      = @{ }
        $List               = @([System.IO.Directory]::EnumerateFiles($Path))
        $Depth              = ([String]$List.Count).Length
        $Segment            = [Math]::Round($List.Count/100)
        $Slot               = 1..100 | % { $_ * $Segment }
        $Hash               = @{ }

        $Start              = [DateTime]::Now
        $Rank               = $This.GetRank($Depth,0,$List.Count)
        $Remain             = $Null
        Write-Progress -Activity Processing -Status ("{0} 0.00% [ETA: unknown]" -f $Rank) -PercentComplete 0
        ForEach ($X in 0..($List.Count-1))
        {
            If ($X -in $Slot)
            {
                $Rank       = $This.GetRank($Depth,$X,$List.Count)
                $Percent    = (($X*100)/$List.Count)
                $Span       = [TimeSpan]([DateTime]::Now-$Start) | % TotalSeconds
                $Remain     = [TimeSpan]::FromSeconds(($Span / $Percent) * (100-$Percent))
                Write-Progress -Activity Processing -Status ("{0} {1:n2}% [ETA: {2}]" -f $Rank, $Percent, $Remain) -PercentComplete $Percent
            }

            $Item = [EventLogSwap]::New($List[$X])
            If (!$This.Provider[$Item.Provider])
            {
                $This.AddProvider($Item.Provider)
            }
            $Hash.Add($X,$Item)
        }
        $Rank = "({0}/{0})" -f $List.Count
        Write-Progress -Activity Processing -Status ("{0} 100.00% [ETA: 00:00:00.0000000]" -f $List.Count) -Complete

        $This.Logs = @($Hash[0..($Hash.Count-1)]) | Sort-Object Index
    }
    [String] GetRank([Uint32]$Depth,[UInt32]$Count,[UInt32]$Total)
    {
        Return ("({0:d$Depth}/{1})" -f $Count, $Total)
    }
    AddProvider([String]$Name)
    {
        $This.Provider.Add($Name,[EventLogProvider]::New($This.Provider.Count,$Name))
    }
}

$Event         = [EventLogContainer]::New("C:\backups\2022_0226-(Scan)\EventLogs")
