Function Get-PSDLog
{
    Param ($Path)

    Class PSDLogItem
    {
        [String] $Message
        [String] $Time
        [String] $Date
        [String] $Component
        [String] $Context
        [String] $Type
        [String] $Thread
        [String] $File
        PSDLogItem([String]$Line)
        {
            $InputObject      = $Line -Replace "(\>\<)", ">`n<" -Split "`n"
            $This.Message     = $InputObject[0] -Replace "((\<!\[LOG\[)|(\]LOG\]!\>))",""
            $Body             = ($InputObject[1] -Replace "(\<|\>)", "" -Replace "(\`" )", "`"`n").Split("`n")
            $This.Time        = $Body[0] -Replace "(^time\=|\`")" ,""
            $This.Date        = $Body[1] -Replace "(^date\=|\`")" ,""
            $This.Component   = $Body[2] -Replace "(^component\=|\`")" ,""
            $This.Context     = $Body[3] -Replace "(^context\=|\`")" ,""
            $This.Type        = $Body[4] -Replace "(^type\=|\`")" ,""
            $This.Thread      = $Body[5] -Replace "(^thread\=|\`")" ,""
            $This.File        = $Body[6] -Replace "(^file\=|\`")" ,""
        }
    }
    
    Class PSDLog
    {
        [Object] $Output
        PSDLog([String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
    
            $This.Output = @( )
            ForEach ($Line in Get-Content $Path)
            {
                $This.Output += $This.Line($Line)
            }
        }
        [Object] Line([String]$Line)
        {
            Return [PSDLogItem]::New($Line)
        }
    }
    If (!(Test-Path $Path))
    {
        Throw "Invalid path"
    }
    Else
    {
        [PSDLog]::New($Path)
    }
}
