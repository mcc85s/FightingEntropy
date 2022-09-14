# Parses the DISM log properly, not QUITE done, but close enough
Class DismLine
{
    [UInt32]    $Rank
    [String]    $Line
    DismLine([UInt32]$Rank,[String]$Line)
    {
        $This.Rank  = $Rank
        $This.Line  = $Line
    }
    [String] ToString()
    {
        Return $This.Line
    }
}

Class DismEntry
{
    Hidden [UInt32] $Index
    Hidden [UInt32] $Total
    Hidden [String]  $Line
    [String]         $Date
    [String]         $Type
    Hidden [String]   $Com
    [Object]      $Message
    DismEntry([UInt32]$Index,[String]$Line)
    {
        $This.Index       = $Index
        $This.Line        = $Line
        $This.Date        = ([DateTime]$This.Line.Substring(0,19)).ToString("MM/dd/yyyy HH:mm:ss")
        $This.SetType()
        $This.Message     = @( )
        $This.AddLine($Line.Substring(50))
    }
    AddLine([String]$Line)
    {
        $This.Message    += [DismLine]::New($This.Message.Count,$Line)
    }
    SetType()
    {
        $SetType          = $This.Line.Substring(21,29).Split(" ") | ? Length -gt 0
        If ($SetType.Count -eq 1)
        {
            $This.Type    = $SetType
        }
        If ($SetType.Count -gt 1)
        {
            $This.Type    = $SetType[0]
            $This.Com     = $SetType[1]
        }
    }
    SetTotal([UInt32]$Total)
    {
        $This.Total = $Total
    }
}

Class DismLog
{
    [String]               $Path
    Hidden [Object]     $Content
    Hidden [Object]        $Swap = @{ }
    [Object]             $Output
    DismLog([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }
        $This.Path    = $Path
        $This.Content = [System.IO.File]::ReadAllLines($Path)
        $Count        = $This.Content.Count
        $Depth        = ([String]$This.Content.Count).Length
        $Start        = [DateTime]::Now
        $Step         = [Math]::Round($Count/100)
        $Slot         = 1..100 | % { $_ * $Step }
        $Rank         = 0

        Write-Progress -Activity Processing -Status ("({0:d$Depth}/{1}) 0.00% [ETA: <unknown>]" -f 0,$Count) -PercentComplete 0
        ForEach ($X in 0..($This.Content.Count-1))
        {
            $Line = $This.Content[$X]
            If ($Line -match "^\d{4}\-\d{2}\-\d{2}\s{1}\d{2}\:\d{2}\:\d{2}")
            {
                $This.Swap.Add($This.Swap.Count,[DismEntry]::New($This.Swap.Count,$Line))
            }
            Else
            {
                $This.Swap[$This.Swap.Count-1].AddLine($Line)
            }

            If ($X -in $Slot)
            {
                $Rank ++
                $Percent    = (($X*100)/$Count)
                $Span       = [TimeSpan]([DateTime]::Now-$Start) | % TotalSeconds
                $Remain     = [TimeSpan]::FromSeconds(($Span / $Percent) * (100-$Percent))
                Write-Progress -Activity Processing -Status ("({0:d$Depth}/{1}) {2:n2}% [ETA: {3}]" -f $X,$Count,$Percent,$Remain) -PercentComplete 0
            }
        }
        Write-Progress -Activity Processing -Status ("({0}/{0}) 100.00%" -f $Count) -Complete

        $This.Output = $This.Swap[0..($This.Swap.Count-1)]
    }
}

$Path    = "C:\Windows\Logs\Dism\Dism.log"
$Dism = [DismLog]::New($Path)
