Class DocumentLine
{
    [UInt32]   $Index
    [String] $Content
    DocumentLine([UInt32]$Index,[String]$Content)
    {
        $This.Index   = $Index
        $This.Content = $Content
    }
    [String] ToString()
    {
        Return $This.Content
    }
}

Class DocumentSection
{
    [UInt32]   $Index
    [String]    $Name
    [UInt32]  $Height
    [Object]  $Output
    DocumentSection([UInt32]$Index,[String]$Name,[String[]]$Content)
    {
        $This.Index   = $Index
        $This.Name    = $Name
        $This.Clear()

        ForEach ($Line in $Content)
        {
            $This.Add($Line)
        }
    }
    Clear()
    {
        $This.Output = @( )
        $This.Height = 0
    }
    [Object] DocumentLine([UInt32]$Index,[String]$Line)
    {
        Return [DocumentLine]::New($Index,$Line)
    }
    Add([String]$Line)
    {
        $This.Output += $This.DocumentLine($This.Output.Count,$Line)
        $This.Height  = $This.Output.Count
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class DocumentController
{
    [String]    $Name
    [String]    $Date
    [Object] $Section
    DocumentController([String]$Name,[String]$Date)
    {
        $This.Name    = $Name
        $This.Date    = $Date
        $This.Clear()
        $This.Add("Title","")
    }
    [Object] DocumentSection([UInt32]$Index,[String]$Name,[String[]]$Content)
    {
        Return [DocumentSection]::New($Index,$Name,$Content)
    }
    Out([Hashtable]$Hash,[String]$Line)
    {
        $Hash.Add($Hash.Count,$Line)
    }
    Add([String]$Name,[String]$Content)
    {
        $H       = @{ }

        If ($Name -eq "Title")
        {
            $This.Out($H,"")
            ForEach ($Line in $This.GetTitle())
            {
                $This.Out($H,$Line)
            }

            $This.Out($H,"")

            ForEach ($Line in $This.Top())
            {
                $This.Out($H,$Line)
            }
        }

        If ($Name -ne "Title")
        {
            # [Head]
            ForEach ($Line in $This.Head($Name))
            {
                $This.Out($H,$Line)
            }

            $This.Out($H,"")

            # [Content]
            ForEach ($Line in $Content -Split "`n")
            {
                $This.Out($H,"    $Line")
            }

            # [Foot]
            ForEach ($Line in $This.Foot($Name))
            {
                $This.Out($H,$Line)
            }

            # [Bottom]
            If ($Name -eq "Conclusion")
            {
                ForEach ($Line in $This.Bottom())
                {
                    $This.Out($H,$Line)
                }
            }
        }

        $This.Section += $This.DocumentSection($This.Section.Count,$Name,$H[0..($H.Count-1)])
    }
    [String] Top()
    {
        Return "\".PadRight(119,[String][Char]95) + "/"
    }
    [String] Bottom()
    {
        Return "/".PadRight(119,[String][Char]175) + "\"
    }
    [String[]] Head([String]$String)
    {
        $Out  = @( )
        $X    = [String][Char]175
        $1    = $String.Length
        $0    = 115 - $1

        $Out += "  {0} /{1}\" -f $String, $X.PadLeft($0,$X)
        $Out +=   "/{0} {1} " -f $X.PadLeft(($1+2),$X), " ".PadLeft($0," ")

        Return $Out
    }
    [String[]] Foot([String]$String)
    {
        $Out  = @( )
        $X    = [String][Char]95
        $1    = $String.Length
        $0    = 115 - $1
    
        $Out += " {0} _{1}_/" -f " ".PadLeft($0," "), $X.PadLeft($1,"_")
        $Out += "\{0}/ {1}  " -f $X.PadLeft($0,$X), $String

        Return $Out
    }
    Clear()
    {
        $This.Section  = @( )
    }
    [String[]] GetTitle()
    {
        Return (Write-Theme "$($This.Name) [~] $($This.Date)" -Text) -Replace "#",""
    }
    [String[]] GetOutput()
    {
        Return $This.Section.Output.Content
    }
}
