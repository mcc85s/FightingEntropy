Function Write-Book
{
    [CmdletBinding()]Param([Parameter(Mandatory,Position=0)][String]$Name)

    Class PageDimension
    {
        [UInt32] $Width
        [UInt32] $Height
        [UInt32] $Characters
        PageDimension()
        {
            $This.Width      = 120
            $This.Height     = 80
            $This.Characters = $This.Width * $This.Height
        }
    }

    Class Line
    {
        [UInt32] $Index
        [String] $Content
        Line([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
    }

    Class Section
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Line
        Section([UInt32]$Index,[String]$Name)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Line    = @( )
        }
        AddContent([String[]]$Content)
        {
            Switch ($Content.Count)
            {
                {$_ -eq 1}
                {
                    $This.Line += [Line]::New($This.Line.Count,$Content)
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($Content.Count-1))
                    { 
                        $This.Line += [Line]::New($This.Line.Count,$Content[$X]) 
                    }
                }
            }
            $This.Rerank()
        }
        RemoveContent([UInt32]$Index)
        {
            If ($Index -gt $This.Line.Count)
            {
                Throw "Invalid line index"
            }

            $This.Line = $This.Line | ? Index -ne $Index

            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Line.Count -eq 1)
            {
                $This.Line[0].Index = 0
            }
            ElseIf ($This.Line.Count -gt 1)
            {
                ForEach ($X in 0..($This.Line.Count-1))
                {
                    $This.Line[$X].Index = $X
                }
            }
        }
    }

    Class Chapter
    {
        [UInt32] $Index
        [String] $Label
        [UInt32] $Page
        [String] $Name
        [Object] $Header
        [Object] $Section
        Chapter([Int32]$Index,[String]$Name)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Header  = @( )
            $This.Section = @( )
        }
        SetLabel([String]$Label)
        {
            $This.Label   = $Label
            $This.Header  = Write-Theme ("{0} - {1}" -f $This.Label, $This.Name) -Text | % { $_.TrimStart("#") }
        }
        AddSection([String]$Name,[String[]]$Content)
        {
            If ($Name -in $This.Section.Name)
            {
                Throw "Section already exists"
            }

            $This.Section += [Section]::New($This.Section.Count,$Content)
            
            $This.Rerank()
        }
        RemoveSection([String]$Name)
        {
            If ($Name -notin $This.Section.Name)
            {
                Throw "Invalid section name"
            }

            $This.Section = $This.Section | ? Name -ne $Name

            $This.Rerank()
        }
        RemoveSection([UInt32]$Index)
        {
            If ($Index -gt $This.Section.Count)
            {
                Throw "Invalid section index"
            }

            $This.Section = $This.Section | ? Index -ne $Index

            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Section.Count -eq 1)
            {
                $This.Section[0].Index = 0
            }
            ElseIf ($This.Section.Count -gt 1)
            {
                ForEach ($X in 0..($This.Section.Count-1))
                {
                    $This.Section[$X].Index = $X
                }
            }
        }
    }

    Class Book
    {
        [String] $Name
        [Object] $Cover
        [Object] $Flag
        [Object] $Table
        [Object] $Chapter
        Book([String]$Name)
        {
            Write-Host "Assembling book... $Name"
            $This.Name    = $Name
            $This.Cover   = $This.Resource("Not%20News%20(001-Cover).txt")
            $This.Flag    = $This.Resource("Not%20News%20(002-Flag).txt")
            $This.Table   = $This.Resource("Not%20News%20(003-Table%20of%20Content).txt")
            $This.Chapter = @( )
            $This.LoadChapters()
        }
        [String[]] Resource([String]$File)
        {
            Write-Host "Loading ($File)"
            Return @( Invoke-RestMethod "https://github.com/mcc85s/FightingEntropy/blob/main/Framing/$File`?raw=true" )
        }
        LoadChapters()
        {
            $Chapters = ($This.Table -Split "`n")[3..14] | % { $_.Substring(28).Replace("|"," ").TrimEnd(" ") }
            ForEach ($Chapter in $Chapters)
            {
                Write-Host "Loading Chapter ($Chapter)"
                $This.AddChapter($Chapter)
            }
        }
        AddChapter([String]$Name)
        {
            If ($Name -in $This.Chapter.Name)
            {
                Throw "Chapter already exists"
            }
            
            $This.Chapter += [Chapter]::New($This.Chapter.Count,$Name)
        }
        RemoveChapter([String]$Name)
        {
            If ($Name -notin $This.Chapter.Name)
            {
                Throw "Invalid chapter name"
            }

            $This.Chapter = @($This.Chapter | ? Name -ne $Name)

            $This.Rerank()
        }
        RemoveChapter([Int32]$Index)
        {
            If ($Index -gt $This.Chapter.Count)
            {
                Throw "Invalid chapter index"
            }

            $This.Chapter = @($This.Chapter | ? Index -ne $Index)

            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Chapter.Count -eq 1)
            {
                $This.Chapter[0].Index = 0
            }
            ElseIf ($This.Chapter.Count -gt 1)
            {
                ForEach ($X in 0..($This.Chapter.Count-1))
                {
                    $This.Chapter[$X].Index = $X
                }
            }
        }
    }

    [Book]::New($name)
}

$Book = Write-Book "Top Deck Awareness - Not News"

$Book.Chapter[0].SetLabel("Prologue")
