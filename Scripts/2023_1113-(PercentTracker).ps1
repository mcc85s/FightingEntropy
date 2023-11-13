# Provides a controller that collects the number of returned percent progress items
# For instance, uploading a video to YouTube, only knowing the start time of the upload, and the remaining percentage
# Since uploading stuff can vary in time from beginning to end, this allows someone to see prior percentage progress items,
# as well as the newest or current progress. This accounts for varying estimated time of completion.

Class PercentProgress
{
    [DateTime]   $Start
    [DateTime]   $Query
    [DateTime]     $End
    [Float]    $Percent
    [TimeSpan] $Elapsed
    [TimeSpan]  $Remain
    [TimeSpan]   $Total
    PercentProgress([String]$Start,[Float]$Percent)
    {
        $This.Start   = [DateTime]$Start
        $This.Query   = [DateTime]::Now
        $This.Elapsed = [TimeSpan]($This.Query-$This.Start)
        $This.Percent = $Percent
        $This.Total   = [TimeSpan]::FromSeconds(($This.Elapsed.TotalSeconds/$This.Percent)*100)
        $This.Remain  = $This.Total - $This.Elapsed
        $This.End     = [DateTime]($This.Query + $This.Remain)
    }
}

Class PercentTracker
{
    [Object] $Start
    [Object] $Output
    PercentTracker([String]$Start)
    {
        $This.Start = $Start
        $This.Output = @( )
    }
    [Object] PercentProgress([String]$Start,[Float]$Percent)
    {
        Return [PercentProgress]::New($Start,$Percent)
    }
    Percent([Float]$Percent)
    {
        $This.Output += $This.PercentProgress($This.Start,$Percent)
    }
    [Object] ShowPercent([Float]$Percent)
    {
        $This.Percent($Percent)

        Return $This.Output[-1]
    }
}

$Ctrl      = [PercentTracker]::New("11/13/2023 03:00")

1..85 | ? { $_ % 5 -eq 0 } | % { 

    $Ctrl.Percent("$_.00")
}

$Ctrl.ShowPercent(87.00)

$Ctrl.Output | Format-Table
