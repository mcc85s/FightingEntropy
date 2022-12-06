# Parses the DISM logs
Class DismLine
{
    [UInt32] $Index
    [UInt32] $Rank
    [String] $Content
    DismLine([UInt32]$Index,[Uint32]$Rank,[String]$Content)
    {
        $This.Index   = $Index
        $This.Rank    = $Rank
        $This.Content = $Content
    }
    [String] ToString()
    {
        Return $This.Content
    }
}

Class DismEntry
{
    [UInt32]     $Index
    [DateTime]    $Date
    [Object]   $Content
    DismEntry([UInt32]$Index,[String]$Line)
    {
        $This.Index   = $Index
        $This.Date    = $Line.Substring(0,19)
        $This.Content = @( )
        $This.Add($Line.Substring(21))
    }
    Add([String]$Line)
    {
        $This.Content += [DismLine]::New($This.Index,$This.Content.Count,$Line)
    }
}

Class DismFile
{
    [String] $Path
    [Object] $Output
    DismFile()
    {
        $This.Path    = "$Env:Windir\Logs\CBS\CBS.log"
        $Content      = [System.IO.File]::ReadAllLines($This.Path)
        $This.Output  = @( )

        ForEach ($X in 0..($Content.Count-1))
        {
            Switch -Regex ($Content[$X])
            {
                "^\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2}"
                {
                    $This.Add($Content[$X])
                }
                Default
                {
                    $This.Output[-1].Add($Content[$X])
                }
            }
        }
    }
    Add([String]$Entry)
    {
        $This.Output += [DismEntry]::New($This.Output.Count,$Entry)
    }
}

$Dism = [DismFile]::New()
