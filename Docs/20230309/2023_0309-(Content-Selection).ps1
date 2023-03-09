Function New-TranscriptionCollection
{
    [CmdLetBinding()]Param(    
    [Parameter(Mandatory)][String]$Name,
    [Parameter()][String]$Date)
    
    Class TranscriptionDateTime
    {
        [DateTime] $DateTime
        [String]       $Date
        [String]       $Time
        [TimeSpan] $Position
        TranscriptionDateTime([String]$Date,[String]$Time)
        {
            $This.Position = [TimeSpan]"00:00"
            $This.DateTime = [DateTime]"$Date $Time"
            $This.SetDateTime()
        }
        TranscriptionDateTime([Switch]$Flags,[Object]$Start,[String]$Position)
        {
            $This.Position = [TimeSpan]$Position 
            $Current       = $Start.DateTime + $This.Position
            $This.DateTime = $Current
            $This.SetDateTime()
        }
        SetDateTime()
        {
            $This.Date     = $This.DateTime.ToString("MM/dd/yyyy")
            $This.Time     = $This.DateTime.ToString("HH:mm:ss")
        }
        [String] ToString()
        {
            Return $This.DateTime.ToString("MM/dd/yyyy HH:mm:ss")
        }
    }

    Class TranscriptionParty
    {
        [Int32]    $Index
        [String]    $Name
        [String] $Initial
        TranscriptionParty([Int32]$Index,[String]$Name)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Initial = ($Name -Split " " | % { $_[0] }) -join ''
        }
        [String] ToString()
        {
            Return $This.Initial
        }
    }

    Class TranscriptionEntry
    {
        [UInt32]         $Index
        [Object]         $Party
        [String]          $Date
        [String]          $Time
        [String]      $Position
        [String]      $Duration
        [String]          $Type
        [String]          $Note
        TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            $This.Index    = $Index
            $This.Party    = $Party
            $This.Date     = $Position.Date
            $This.Time     = $Position.Time
            $This.Position = $Position.Position
            $This.Duration = [TimeSpan]$End - $This.Position
            $This.Type     = Switch -Regex ($Note)
            {
                "^\*{1}" { "Action"    }
                "^\:{1}" { "Statement" }
                "^\#{1}" { "Context"   }
            }
            $This.Note     = $Note.Substring(1)
        }
        [String] ToString()
        {
            Return "[{0}] <{1}> {2}" -f $This.Time,$This.Party.Initial, $This.Note
        }
    }

    Class TranscriptionFile
    {
        [UInt32]       $Index
        [String]        $Name
        Hidden [Object] $Time
        [String]        $Date
        [String]       $Start
        [String]         $End
        [String]    $Duration
        [String]         $Url
        [Object]       $Party
        [Object]      $Output
        TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
        {
            $This.Index    = $Index
            $This.Name     = $Name
            $This.Time     = $This.DateTime($Date,$Start)
            $This.Date     = $This.Time.Date
            $This.Start    = $This.Time.Time
            $This.Duration = $This.Position($Duration)
            $This.End      = ([DateTime]"$Date $Start" + [TimeSpan]$Duration).ToString("HH:mm:dd")
            $This.Url      = $Url
            $This.Party    = @( )
            $This.Output   = @( )
        }
        [String] Position([String]$In)
        {
            $Out = Switch -Regex ($In)
            {
                "^\d{1}:\d{2}$" { "00:0$In"} 
                "^\d{2}:\d{2}$" { "00:$In" } 
                Default { $In }
            }

            Return $Out
        }
        [Object] DateTime([String]$Date,[String]$Start)
        {
            Return [TranscriptionDateTime]::New($Date,$Start)
        }
        [Object] GetPosition([String]$Position)
        {
            $Position = $This.Position($Position)
            Return [TranscriptionDateTime]::New([Switch]$True,$This.Time,$Position)
        }
        [Object] TranscriptionParty([Int32]$Index,[String]$Name)
        {
            Return [TranscriptionParty]::New($Index,$Name)
        }
        [Object] TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            $xEnd = $This.Position($End)
            Return [TranscriptionEntry]::New($Index,$Party,$Position,$xEnd,$Note)
        }
        Write([String]$String)
        {
            [Console]::WriteLine($String)
        }
        AddParty([String]$Name)
        {
            If ($Name -in $This.Party.Name)
            {
                Throw "Party [!] [$Name] already specified"
            }

            $This.Party += $This.TranscriptionParty($This.Party.Count,$Name)

            $This.Write("Party [+] [$Name] added.")
        }
        AddEntry([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {   
            If ($Index -gt $This.Party.Count)
            {
                Throw "Party [!] [$Index] is out of bounds"
            }

            $This.Output += $This.TranscriptionEntry($This.Output.Count,
                                                     $This.Party[$Index],
                                                     $This.GetPosition($Position),
                                                     $End,
                                                     $Note)

            $This.Write("Entry [+] [$($This.Output[-1].Position)] added")
        }
        X([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $This.AddEntry($Index,$Position,$End,$Note)
        }
        [String] ToString()
        {
            Return "({0}/{1})" -f $This.Date, $This.Name
        }
    }

    Class TranscriptionHistoryItem
    {
        [UInt32]      $Index
        [UInt32]       $File
        [UInt32]       $Rank
        [String]      $Party
        [String]   $Position
        [TimeSpan] $Duration
        [String]       $Note
        TranscriptionHistoryItem([UInt32]$Index,[UInt32]$File,[Object]$Item)
        {
            $This.Index    = $Index
            $This.File     = $File
            $This.Rank     = $Item.Index
            $This.Party    = $Item.Party
            $This.Position = $Item.Position
            $This.Duration = $Item.Duration
            $This.Note     = $Item.Note
        }
        [String] ToString()
        {
            Return "{0}/{1}/{2}" -f $This.Index, $This.File, $This.Party
        }
    }

    Class TranscriptionHistoryList
    {
        [Object] $Output
        TranscriptionHistoryList()
        {
            $This.Output = @( )
        }
        [Object] TranscriptionHistoryItem([UInt32]$Index,[UInt32]$File,[Object]$Item)
        {
            Return [TranscriptionHistoryItem]::New($Index,$File,$Item)
        }
        Add([UInt32]$File,[Object]$Current)
        {
            $This.Output += $This.TranscriptionHistoryItem($This.Output.Count,$File,$Current.Output[-1])
        }
        Finalize()
        {
            $Time = [TimeSpan]::FromSeconds(0)

            ForEach ($Item in $This.Output)
            {
                $Item.Position = $Time.ToString()
                $Time          = $Time + [TimeSpan]$Item.Duration 
            }
        }
        [String] ToString()
        {
            Return "<TranscriptionHistory>"
        }
    }

    Class TranscriptionSection
    {
        [UInt32] $Index
        [String] $Name
        [String[]] $Content
        TranscriptionSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Content = $Content
        }
    }

    Class TranscriptionCollection
    {
        [String]           $Name
        [String]           $Date
        [Object]           $File
        [Object]        $History
        Hidden [Int32] $Selected
        [Object]        $Section
        TranscriptionCollection([String]$Name,[String]$Date)
        {
            $This.Name     = $Name
            $This.Date     = ([DateTime]$Date).ToString("MM/dd/yyyy")
            $This.File     = @( )
            $This.History  = $This.TranscriptionHistoryList()
            $This.Selected = -1
            $This.Section  = @( )
        }
        [Object] TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Length,[String]$Url)
        {
            Return [TranscriptionFile]::New($Index,$Name,$Date,$Start,$Length,$Url)
        }
        [Object] TranscriptionParty([Int32]$Index,[String]$Name)
        {
            Return [TranscriptionParty]::New($Index,$Name)
        }
        [Object] TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            Return [TranscriptionEntry]::New($Index,$Party,$Position,$End,$Note)
        }
        [Object] TranscriptionHistoryList()
        {
            Return [TranscriptionHistoryList]::New()
        }
        [Object] TranscriptionSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            Return [TranscriptionSection]::New($Index,$Name,$Content)
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        Check([UInt32]$Index)
        {
            If ($Index -gt $This.File.Count)
            {
                Throw "Invalid file index"
            }
        }
        [Object] Get([UInt32]$Index)
        {
            $This.Check($Index)

            Return $This.File[$Index]
        }
        [Object] Current()
        {
            If ($This.Selected -eq -1)
            {
                Throw "File not selected"
            }

            Return $This.File[$This.Selected]
        }
        Select([UInt32]$Index)
        {
            $This.Check($Index)

            $This.Selected = $Index
        }
        AddFile([String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
        {
            $Item = $This.TranscriptionFile($This.File.Count,$Name,$Date,$Start,$Duration,$Url)

            $Out  = @( ) 
            $Out += "Added [+] File     : [{0}]" -f $Item.Name
            $Out += "          Date     : [{0}]" -f $Item.Date
            $Out += "          Duration : [{0}]" -f $Item.Duration
            $Out += "          Url      : [{0}]" -f $Item.Url
            $Out += " "
            
            $Out | % { $This.Write($_) }

            $This.File += $Item
        }
        AddFile([Object]$File)
        {
            $Item = $This.TranscriptionFile($This.File.Count,$File.Name,$File.Date,$File.Start,$File.Duration,$File.Url)

            $Out  = @( ) 
            $Out += "Added [+] File     : [{0}]" -f $Item.Name
            $Out += "          Date     : [{0}]" -f $Item.Date
            $Out += "          Duration : [{0}]" -f $Item.Duration
            $Out += "          Url      : [{0}]" -f $Item.Url
            $Out += " "
            
            $Out | % { $This.Write($_) }

            $This.File += $Item
        }
        AddParty([String]$Name)
        {
            $Current = $This.Current()

            If ($Name -in $Current.Party.Name)
            {
                Throw "Party [!] [$Name] already specified"
            }

            $Current.Party += $This.TranscriptionParty($Current.Party.Count,$Name)

            $This.Write("Party [+] [$Name] added.")
        }
        AddEntry([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $Current = $This.Current()

            If ($Index -gt $Current.Party.Count)
            {
                Throw "Party [!] [$Index] is out of bounds"
            }

            $Current.Output += $This.TranscriptionEntry($Current.Output.Count,
                                                        $Current.Party[$Index],
                                                        $Current.GetPosition($Position),
                                                        $Current.Position($End),
                                                        $Note)

            $This.History.Add($This.Selected,$Current)

            $This.Write("Entry [+] [$($Current.Output[-1].Position)] added")
        }
        AddContext([String]$Note)
        {
            $Current  = $This.Current()
            $Position = $Current.Output[-1].Position

            $Current.Output += $This.TranscriptionEntry($Current.Output.Count,
                                                        $This.TranscriptionParty(-1,"T X T"),
                                                        $Current.GetPosition($Position),
                                                        $Position,
                                                        $Note)

            $This.History.Add($This.Selected,$Current)

            $This.Write("Entry [+] [$($Current.Output[-1].Position)] added")
        }
        Finalize()
        {
            $This.History.Finalize()
        }
        X([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $This.AddEntry($Index,$Position,$End,$Note)
        }
        C([String]$Note)
        {
            $This.AddContext($Note)
        }
        [String] Pad([String]$String,[UInt32]$Mode,[UInt32]$Length)
        {
            $Item = Switch ($Mode)
            {
                0 { $String.PadRight( $Length , " " ) }
                1 { $String.PadLeft(  $Length , " " ) }
            }

            Return $Item
        }
        [String] GetTitle()
        {
            Return "{0} [~] {1}" -f $This.Name, $This.Date
        }
        [String[]] GetSection()
        {
            $Out  = @( )
            $List = $This.History.Output | ? Party -eq Txt | ? Note -match "^\="

            ForEach ($Item in $List)
            {
                $Content = $Item.Note -Split "`n"
                $Out    += $Content[1].Substring(2,($Content[1].Length-4))
            }

            Return $Out
        }
        [String[]] GetFile()
        {
            $Out         = @{ }
            $Count       = $This.File.Count
            $Depth       = @{ 

                Index    = ([String]$Count).Length
                Name     = ($This.File.Name | Sort-Object Length)[-1].Length
            }

            If ($Depth.Index -lt 5)
            {
                $Depth.Index = 5
            }

            If ($Depth.Name -lt 4)
            {
                $Depth.Name = 4
            }

            ForEach ($Item in $This.File)
            {
                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad("Index",0,$Depth.Index),
                                                     $This.Pad("Name",0,$Depth.Name),
                                                     $This.Pad("Date",0,10),
                                                     $This.Pad("Start",0,8),
                                                     $This.Pad("End",0,8),
                                                     $This.Pad("Duration",0,8)
                $Out.Add($Out.Count,$Line)

                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad("-----",0,$Depth.Index),
                                                     $This.Pad("----",0,$Depth.Name),
                                                     $This.Pad("----",0,10),
                                                     $This.Pad("-----",0,8),
                                                     $This.Pad("---",0,8),
                                                     $This.Pad("--------",0,8)

                $Out.Add($Out.Count,$Line)

                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad($Item.Index,1,$Depth.Index),
                                                     $This.Pad($Item.Name,1,$Depth.Name),
                                                     $This.Pad($Item.Date,1,10),
                                                     $This.Pad($Item.Start,1,8),
                                                     $This.Pad($Item.End,1,8),
                                                     $This.Pad($Item.Duration,1,8)

                $Out.Add($Out.Count,$Line)
                $Out.Add($Out.Count,"")
                $Line = "[Url]: {0}" -f $Item.Url

                $Out.Add($Out.Count,$Line)
                $Out.Add($Out.Count,"")
            }

            Return $Out[0..($Out.Count-1)]
        }
        [String[]] GetOutput()
        {
            $Out      = @{ }
            $Count    = $This.History.Output.Count
            $Depth    = @{ 

                Index  = ([String]$Count).Length
                Party  = ($This.History.Output.Party | Sort-Object Length | Select-Object -Unique -Last 1).Length
                Buffer = 0
            }

            If ($Depth.Index -lt 5)
            {
                $Depth.Index = 5
            }

            If ($Depth.Party -lt 5)
            {
                $Depth.Party = 5
            }

            $Depth.Buffer = $Depth.Index + $Depth.Party + 10

            # Header
            $Line = "{0} {1} {2} {3}" -f $This.Pad("Index",0,$Depth.Index),
                                         $This.Pad("Party",0,$Depth.Party),
                                        "Position",
                                        "Note"
            $Out.Add(0,$Line)

            $Line = "{0} {1} {2} {3}" -f $This.Pad("-----",0,$Depth.Index),
                                         $This.Pad("-----",0,$Depth.Index),
                                        "--------",
                                        "----"

            $Out.Add(1,$Line)

            # Content
            ForEach ($X in 0..($This.History.Output.Count-1))
            {
                $Item    = $This.History.Output[$X]
                $Content = $Item.Note -Split "`n"

                If ($Item.Party -eq "TXT")
                {
                    $Line = "{0} {1} {2} " -f $This.Pad($Item.Index,0,$Depth.Index),
                                              $This.Pad($Item.Party,0,$Depth.Party),
                                              $Item.Position

                    $Line = $Line.PadRight(116,"=")

                    $Out.Add($Out.Count,$Line)
                    $Out.Add($Out.Count,"")

                    ForEach ($Slice in $Content)
                    {
                        $Out.Add($Out.Count,"    $Slice")
                    }

                    $Out.Add($Out.Count,"")
                    $Out.Add($Out.Count,"=".PadRight(116,"="))
                }

                Else
                {
                    If ($Content.Count -eq 1)
                    {
                        $Line = "{0} {1} {2} $content" -f $This.Pad($Item.Index,0,$Depth.Index),
                                                          $This.Pad($Item.Party,0,$Depth.Party),
                                                          $Item.Position
                                                    

                        $Out.Add($Out.Count,$Line)
                    }
                    If ($Content.Count -gt 1)
                    {
                        $C = 0
                        ForEach ($Slice in $Content)
                        {
                            If ($C -eq 0)
                            {
                                $Line = "{0} {1} {2} {3}" -f $This.Pad($Item.Index,0,$Depth.Index),
                                                             $This.Pad($Item.Party,0,$Depth.Party),
                                                             $Item.Position,
                                                             $Slice
                            }
                            Else
                            {
                                $Line = "{0} {1}" -f " ".PadRight($Depth.Buffer," "),
                                                    $Slice
                            }

                            $C ++
                            $Out.Add($Out.Count,$Line)
                        }
                    }
                }

                $Out.Add($Out.Count,"")
            }

            Return $Out[0..($Out.Count-1)]
        }
        [String] ToString()
        {
            Return "({0}) <TranscriptionCollection>" -f $This.File.Count
        }
    }

    If (!$Date)
    {
        $Date = [DateTime]::Now.ToString("MM/dd/yyyy")
    }

    [TranscriptionCollection]::New($Name,$Date)
}

Class RecordingFile
{
    [UInt32]           $Index
    [String]            $Name
    Hidden [String] $Fullname
    [String]            $Date
    [String]            $Time
    [String]        $Duration
    [String]             $Url
    RecordingFile([UInt32]$Index,[Object]$Folder,[Object]$Item)
    {
        $This.Index    = $Index
        $This.Name     = $Item.Name
        $This.Fullname = $Item.Fullname
        $This.Duration = $Folder.GetDetailsOf($Item,27)

        If ($This.Name -match "^\d{4}(_\d{2}){5}")
        {
            $S         = $Matches[0] -Split "_"
            $This.Date = $S[1,2,0] -join "/"
            $This.Time = $S[3,4,5] -join ":"
        }
        Else
        {
            $End       = $Folder.GetDetailsOf($Item,3)
            $Start     = [DateTime]($End - [TimeSpan]$This.Duration)
            $This.Date = $Start.ToString("MM/dd/yyyy")
            $This.Time = $Start.ToString("HH:mm:ss")
        }
    }
    SetUrl([String]$Url)
    {
        $This.Url      = $Url
    }
}

Class RecordingFolder
{
    [String]   $Path
    [Object] $Folder
    [UInt32]  $Total
    [Object]   $File
    RecordingFolder([String]$Path)
    {
        If (![System.IO.Directory]::Exists($Path))
        {
            Throw "Invalid path"
        }

        $This.Path   = $Path
        $This.Folder = $This.GetFolder()
        $This.Refresh()
    }
    Clear()
    {
        $This.File   = @( )
        $This.Total  = 0
    }
    Refresh()
    {
        $This.Clear()

        $List      = @($This.Folder.Items())
        $Step      = [Math]::Round($List.Count/100)
        $Stage     = 0..100 | % { $Step * $_ }
        $Stage[-1] = $List.Count
        $C         = 0

        Write-Progress -Activity "Collecting" -Status ("{0:p}" -f 0) -PercentComplete 0
        ForEach ($X in 0..($List.Count-1))
        {
            If ($X -in $Stage)
            {
                Write-Progress -Activity "Collecting" -Status ("{0:p}" -f ($C/100)) -PercentComplete $C
                $C ++
            }

            $This.Add($List[$X])
        }
        Write-Progress -Activity "Collected" -Status ("{0:p}" -f 100) -Complete
    }
    [Object] GetFolder()
    {
        Return (New-Object -ComObject Shell.Application).Namespace($This.Path)
    }
    [Object] GetFile([UInt32]$Index,[Object]$Item)
    {
        Return [RecordingFile]::New($Index,$This.Folder,$Item)
    }
    Add([Object]$Item)
    {
        $This.File  += $This.GetFile($This.Total,$Item)
        $This.Total  = $This.File.Count
    }
}

$Base = [RecordingFolder]::New("$Home\Documents\Recordings")
$File = $Base.File | ? Name -match 2023_03_07
$File.SetUrl("https://drive.google.com/file/d/1GKdbcmL5rTYLOtwdo-vEV_V3Zf-xBCNd")

$Ctrl = New-TranscriptionCollection -Name "Content Selection"
$Ctrl.AddFile($File)

$Ctrl.Select(0)
$Ctrl.AddParty("Michael C. Cook Sr.")

$Ctrl.X(0,"00:00:00","00:00:20", @'
:Audio log [Tuesday March 7th 2023], [Michael Cook] speaking it is currently [2:38 PM].
I'm makin this [audio log] to talk about, uh-
'@)

$Ctrl.X(0,"00:00:20","00:00:37", @'
:What it- what- the ideas that I [choose] to [talk about]...?

The [topics] of [discussion] and whatnot...?

And uh- the amount [content] that I COULD be [creating], if I could [keep up with it].
'@)

$Ctrl.X(0,"00:00:37","00:00:54", @'
:The way I see it is like this...
If I make an [audio recording] like this...?
And... I wanna make a [video] out of the [audio recording] that I made...?

Well, I have to have a [pretty good understanding] of what it is that I wanna talk about
BEFORE I start making the [audio recording]...
'@)

$Ctrl.X(0,"00:00:54","00:01:22", @'
:Right...? But then also, I have to [transcribe] it and then like spend time [translating]
everything so that it ya know, mee- [it meets a certain standard criteria], or something
to that effect.

Right...? So like, uh-

Sometimes I'll realize that uh- I'm [rushing] to do something.
And then [rushing] to do something is gonna [generate a rushed result].
'@)

$Ctrl.X(0,"00:01:22","00:01:42", @'
:Ya know, [most people] don't realize like, what does it take to uh-

When someone [records] a [video] and it [goes viral]...?
What is it that causes it to [go viral]...?

Well I'll tell you there are [a number of factors], but typically [viral videos]...?
They're [unexpected] and they're [spontaneous].
'@)

$Ctrl.X(0,"00:01:42","00:01:57", @'
:Whereas, the [content] that [I produce]...?

Sometimes it IS [spontaneous], but it's also like uh-
...[my ability] to [predict] other [people's behaviors], and then to [capture] it.
'@)

$Ctrl.X(0,"00:01:57","00:02:21", @'
:So I [predict] the [behaviors], right...?

Because like, I'm not [recording] things on a [constant basis]...

I don't [record] every single like, [second of my life].

And, anything that I DO [record]...?

I'm gonna have a [sense of bias] over [what I'm gonna wanna show other people], 
or [what I won't want to show to other people].

It- it [doesn't matter who you are], you're gonna have a [sense of bias].
'@)

$Ctrl.X(0,"00:02:21","00:02:53", @'
:So, being able to [accurately] uh- [define] like, what [matters most to ME]...?

People are gonna have an [easier time], uh- if- if they see a [number] of [exhibits]
or uh... [subjects] and [contents], they are able to see like an [outline] of how I 
[think] and how I [shape things], right...?
'@)

$Ctrl.X(0,"00:02:53","00:03:17", @'
:And that I can [explain] it so that [other people] can ALSO do this.

I'm gonna start to come off a lot like [George Carlin], but- ya know, he- he did
what he did for many, many years, and uh- ya know, I've been doin' this for a few
years, but not nearly as long as he had. 
'@)

$Ctrl.X(0,"00:03:17","00:03:38", @'
:Some of these, uh- [comedians] that go uh- on stage and they sound more of a [philosopher]
than just a uh- [comedian]...?

They develop a sense of uh- [what people are gonna wanna hear]...?
What's [funny]...?
And uh- you know, I think of [funny things] on a [constant basis].
'@)

$Ctrl.X(0,"00:03:38","00:04:06", @'
:The thing is I have to [cherry pick] the things that OTHER people are gonna [understand], 
and [elaborate] on them, and uh- 

It's really not... that easy, because, I have to [work really hard] to [focus] on the 
things that ARE [worthy of attention], because...

Is someone gonna wanna see a [video] of [me], [takin' a poop]...?
'@)

$Ctrl.X(0,"00:04:06","00:04:23", @'
:[Probably not], right...?

I think [everybody takes a poop].

It's not gonna be [fun], for [anybody else], to see me sittin' on a toilet takin' a poop.

Scrollin' through like, ya know, like uh- [news feed] or somethin', right...?
'@)

$Ctrl.X(0,"00:04:23","00:04:53", @'
:Fact of the matter is that some people...?

They can make that [entertaining].
Ya know...?
[Somebody]: There's somebody takin' a poop.
            Uh- dude was takin' a poop for the last (5) minutes...?
            And it happens to be the [coolest dude that ever lived]...
            And the name of this whole scene, or skit, is
            "The [coolest man who ever lived], taking the [coolest poop that anyone ever took]..."
'@)

$Ctrl.X(0,"00:04:53","00:05:16", @'
:And, uh... ya know...? 
Holy shit.

Yeah, it's- a little- it's-
It's sorta windy right now...?
It's not THAT windy...?

But- it's windy enough where uh- I know that uh- it's prolly gonna-
Uh- ah- uh- [disrupt] what I'm [recording]...
'@)

$Ctrl.X(0,"00:05:16","00:05:27", @'
:So, there are days where uh- like, I struggle to uh- [stay on point] on task, and whatnot,
and uh- 
'@)

$Ctrl.X(0,"00:05:27","00:05:39", @'
:It's been a few days since I like, hunkered down and made a recording where...
...like it sounded [productive], and much less, uh- like uh, I dunno, like a [mind dump]...?
'@)

$Ctrl.X(0,"00:05:39","00:05:53", @'
:Ya know, uh- not every one of my [recordings] is gonna be all that [well-received], right...?

That's like, what I mean, by this [sense of bias], and everybody exhibiting it to some extent.
'@)

$Ctrl.X(0,"00:05:53","00:06:13", @'
:Right...? 
When a girl...? 

Like- like, uh- news anchor [Julie Chapman] from [Spectrum One], the
[Spectrum News One], or, uh- I dont' remember exactly what the hell it's called...

[Spectrum News].
Right...?

She has been workin' at this place for like, I think like (15) years or so...
Right...?
'@)

$Ctrl.X(0,"00:06:13","00:06:39", @'
:[Chapman]: Spectrum News, starring [Julie Chapman].
           [Julie Chapman]...?
           Reporting to you...
           I'm [Julie Chapman], and uh- 
           Today...?
           We're gonna talk about how [Andrew Cuomo], sexually harassed, (11) of his aides...?
           And a whole bunch of people just, let it happen.
'@)

$Ctrl.X(0,"00:06:39","00:06:53", @'
:And, uh- ya know...
[Andy Cuomo] DID have a really, uh- big involvement in like, [Spectrum News].

Or not [Spectrum News], but like, I dunno, [Spectrum] in general...?
'@)

$Ctrl.X(0,"00:06:53","00:07:17", @'
:Uh- [Spectrum] used to be [Time Warner Cable].

And then at SOME point along the way, they decided to sell out.
And... ya know, from that point forward...?

It's just been kinda like a, large conglomerate corporation of...
like... I dunno.
'@)

$Ctrl.X(0,"00:07:17","00:07:34", @'
:I really don't know how to describe it better than like, uh- 
it's basically the same thing as [Comcast]. Or ya know, uh- [Cox].

Or, uh... I can't really think of uh- the others...
'@)

$Ctrl.X(0,"00:07:34","00:07:44", @'
:And I'm not feelin' all THAT [super-focused] right now...?
But- I am sorta [forcing myself] to uh- [record] this.
'@)

$Ctrl.X(0,"00:07:44","00:08:00", @'
:The concepts that I wanted to talk about in the [very beginning] of the [recording], uhm-
are the uh- the fact that [I can create a lot of content], and uh- even if I am gonna
[try to show], or [focus] on my [best work]...?
'@)

$Ctrl.X(0,"00:08:00","00:08:21", @'
:I STILL get [overwhelmed] by the [amount of content] that uh- occurs. 
Or, I can record.

Sometimes.

Sometimes what'll happen is, I'll record something...?

And then [I'll need a few days], to like, get ALL of the things, in what I [recorded],
[documented], and then [re-recorded] with uh- [wrapper].
'@)

$Ctrl.X(0,"00:08:21","00:08:48", @'
:And so like uh- these are the things that I start to uh- like uh- [conceptualize], 
[ways of telling a story]. Or [retelling] a story, or...

Ya know, these uh- these ideas, they're [not intuitive]... 

I'm certain that like [broadcast media], they get into the nitty-gritty of how to 
tell a story. And so do the [news agencies]. 
'@)

$Ctrl.X(0,"00:08:48","00:09:00", @'
:But, I think what winds up happening, is that-
They just wind up [doing] what [someone else is doing], and then like...

Before you know it, the- every- everybody's like, [copying each other]. 
'@)

$Ctrl.X(0,"00:09:00","00:09:27", @'
:And it's, [very rarely] that you get like, original works.

And even if you DO get original works, is it [entertaining]...?
Is it [educational]...?

Ya know, [these are the things that I ask myself] on a [constant basis], whenever I'm
making these things.

If [someone is gonna listen to this], and find it [educational], and uh-
[provocative], and [interesting]... and uh- can I keep myself, like [on the level], 
can I keep a [cool head], a [cool, level head]...?
'@)

$Ctrl.X(0,"00:09:27","00:10:02", @'
:Can I also uhm, come across as somebody who's historically done a pretty good job over
the years, like uh- [Howard Stern], or uh [Imus], or [George Carlin], or [Louis C.K.]...?

Does anyone out there think that uh- these guys, they just like, [woke up one day], and 
they were like:
[Them]: You know what...?
        I'm gonna fuckin', do some cool shit...
        I'm gonna [tell some stories] like [no one else ever did, in history]...
'@)

$Ctrl.X(0,"00:10:02","00:10:17", @'
:Yeah, well, I'm sure it did happen after like, [many days of working at it].

Right...? So...

Some of the things that I [notice], are uh- [indicators], in the [environment], or like 
just [things kinda pointing me in the right direction].
'@)

$Ctrl.X(0,"00:10:17","00:10:29", @'
:And often times like uh- [people], they uh- will uh- [judge me] based on my [appearance],
rather than uh, like uh- the [things that I'm talking about], or whatever.
'@)

$Ctrl.X(0,"00:10:29","00:10:40", @'
:Right...?
And even if I'm like, [out in public] and [people] can [see] and [hear] me [talk]...?

[Very rarely] will someone think to like, ever [engage themselves] in what I'm talking about.
'@)

$Ctrl.X(0,"00:10:40","00:11:07", @'
:I think its... I think it's a [daunting concept], and a [daunting task] to take on, because,
ya know, uhm... 

Typically you would wanna have a [conversation] with [somebody], about some of this stuff, 
you're not gonna wanna, like uh- like uh-

[Somebody] : Hey, sorry to interrupt you, like I see that you were like uh-
             You know, havin' this [conversation] amongst [yourself]...
[Me]       : Oh, oh, well, I WAS havin' a [conversation] amongst [myself], but it's a [LECTURE].
'@)

$Ctrl.X(0,"00:11:07","00:11:22", @'
:And then the other person will be like:
[Somebody] : Well, uh-
             I would like to take part of this [lecture] of yours...

And then the other- and then I would say:
[Me]       : Well...
             You wanna take part of the [lecture], what do you...
             What sort of [questions] (do you want to ask) or [statements] do you wanna make...?
'@)

$Ctrl.X(0,"00:11:22","00:11:29", @'
:And then the person will be like:
[Somebody] : Well, you said somethin' about, like...
             ...making something [really cool] and [original]...?
I'm like:
[Me]       : Yup.
'@)

$Ctrl.X(0,"00:11:29","00:11:47", @'
:And then they'll say:
[Somebody] : Well, what is it that you're...
             How do you do it...?

             Do you like, start out wiht like uh-
             like a [video game], or somethin'...?

             Or do you go to like a [toy store], and buy a, like a [board game]...?
'@)

$Ctrl.X(0,"00:11:47","00:12:22", @'
:And then I say:
[Me]       : Well, uh- i- if you wanna [focus] on something like [THAT], sure.
             You can.

             I guess what it really comes down to, is uh-
             Are you putting your own [personality] into [something], in order to tell
             [other people] about that game...?

             Or...
             Are you doing something that [someone else], like [expected] and [predicted] 
             that you would do, and uh- [created everything] along the way to be like uh-

             [Manufacturing Consent], by [Noam Chomsky]...?
'@)

$Ctrl.X(0,"00:12:22","00:12:46", @'
:You're [manufacturing] a whole bunch of things, so that people [think] the [way] that you 
[want] them [to], or they rea- they have [opinions] that you [want] them to [have], or a 
[shared opinion], and uh- ya know, [focus] on the [key details], be [very concise], don't
ya know, uh- [explain the whole entire story]...? 

You wanna explain like, [portions] of it, because...
'@)

$Ctrl.X(0,"00:12:46","00:13:00", @'
:People, we want people to think that like, [telling the whole story]...? It's [stupid].

Even though, it's [VERY INTERSTING] when, uh- someone decides- decides to start telling 
like a [story] in an [interesting way].
'@)

$Ctrl.X(0,"00:13:00","00:13:18", @'
:Ya know, like uh- you tell an [interesting story], you start to say things...?

And then uh- people, they [pay attention] to the [details].

They're not gonna [gloss over the details] or nothin' like that, they're gonna [listen],
they're gonna [pay attention], they're gonna [ask questions] and before you know it...
'@)

$Ctrl.X(0,"00:13:18","00:13:38", @'
:You're gonna get to the point where... you start to develop uh- [bullet points], and then
you talk about the [bullet points], and you [expand] upon each [bullet point], and... as long
as you remember the [bullet points] and you [circle back]...?

Then uh- then you're able to keep the [conversation], or the [discussion] flowing.
'@)

$Ctrl.X(0,"00:13:38","00:13:52", @'
:See, right now, I'm sorta doing the same thing as [freestyling]...?
But, because I've done this so often, that- I uh- 

I have an idea, of [how] to [explain] my [thought process].
'@)

$Ctrl.X(0,"00:13:52","00:14:19", @'
:Other people, they're not gonna have an [understanding] of how to DO this...
unless they [PRACTICE] it, and, I'm [warming up].

So, it's not unlike when I would [pick up a guitar]...?
And I'd start playing around on the neck...?

And then uh [playing scales] and stuff...?
[Scales] would be a great way to [start out], but then like...

Maybe I'll start out with a [song]...?
And then I'd start [playing] the [song]...?

And after a while, people would be like...
[Person] : Hey, uh- 
           You've been playin' that [song] for a while...
           ...and it's [really loud].
'@)

$Ctrl.X(0,"00:14:19","00:14:46", @'
:And I would say:
[Me]     : Yeh yeh yeh, I only play my music [really loud].
           It's sorta like uh- like uh- I have to play it at like, the [maximum volume].

And like:
[Person] : Yeah, well you got the [volume all the way up].
           Whaddya got, it up to (10)...?

And I'd be like:
[Me]     : No, I got it up to (11).

They'll be like:
[Person] : I didn't know that an [amplifier] could go up to (11)...

And then I would say:
[Me]     : Well, you've never seen [Spinal Tap], have you...?

And they'll be like:
[Person] : No no no, I haven't seen [Spinal Tap], what's that...? 
           What's that...?
'@)

$Ctrl.X(0,"00:14:46","00:14:58", @'
:And I would say:
[Me]     : Well, [Spinal Tap], uh...
           They say...
           "Turn it up to (11), because it's louder than (10)."

And they'll be like:
[Person] : Oh.
           Well, [that's dumb].
'@)

$Ctrl.X(0,"00:14:58","00:15:07", @'
:A lot of people WILL actually say something like:
[Person] : Well, [that's dumb].
           You know...?

           (11) IS like uh- higher than (10)...?
           But...
'@)

$Ctrl.X(0,"00:15:07","00:15:27", @'
:The idea there, is being [original].
Right...?

[Originality], I guess may be a good way to put it.

But, you know, I'm sorta meandering into [different topics], and uh- straying from
the [original reason] I began to record this.
'@)

$Ctrl.X(0,"00:15:27","00:15:46", @'
:Which was to talk about... uh, the [amount of content] that, I can [produce].
Is [overwhelming].

And then to be able to like, [translate] it. To uh- 

I dunno, like a [video], or an [audio recording], or whatever...?
'@)

$Ctrl.X(0,"00:15:46","00:15:58", @'
:Right, and [sometimes I'll need a few attempts throughout a day], to like uh- get
back into the... into the [rhythm]. 

Right...?
'@)

$Ctrl.X(0,"00:15:58","00:16:17", @'
:Sometimes, uh- I'll be [forcing myself] to talk about whatever I can, and trying to stick
to a [certain topic], which- I'm doing right now... but that's mainly because...

I dunno, I'm in a [different setting] than I normally am...?
Or, I'm not very [engaged] in what I'm talking about...?
'@)

$Ctrl.X(0,"00:16:17","00:16:36", @'
:And the topic that I'm tryin' to talk about, is [pretty difficult].
But uhm, allow me to [resort] to [observations].

There's uh- [key strategies], that I've been uh- kind of [developing], and uh-

Ya know, these [strategies]...?
Uh, they don't [need] to be in [order]...
'@)

$Ctrl.X(0,"00:16:36","00:16:52", @'
:But these [strategies], uh- someone has made it [very clear] to me, that like, they DO
think that I'm a [very intelligent person], they DO think I'm [funny] and [comedic], but 
ya know, there are some things that I might [say] or [do] that [worries them]. And, uh-
'@)

$Ctrl.X(0,"00:16:52","00:17:10", @'
:This, ya know, [happens to other people as well].

And I think that uh, [generally speaking], like, most people, aren't as [intelligent] as I am,
and I'm not saying that to [insult] people, I'm saying it because a lot of people that you'll
run into in society...?
'@)

$Ctrl.X(0,"00:17:10","00:17:30", @'
:They're not gonna like, [think about things in a deeper manner]. 

Or like, the [philosophical implications].

So like a [great way] to [showcase] this, [specifically] is...
Number 1, uh- [seeing is believing]. But [appearances can be deceiving]. 
'@)

$Ctrl.X(0,"00:17:30","00:17:50", @'
:I wrote about, uh- I wrote a [document] about uh- [Tropic Thunder], a few days ago, or maybe
last week...?

Uh, and- when I wrote this [document], I talked about uh- the skit, [The Dudes Are Emerging]
[https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0225-(TropicThunder).pdf]
'@)

$Ctrl.X(0,"00:17:50","00:18:23", @'
:So in this [skit], [the dudes are emerging], in the movie, uh- [Tropic Thunder]...

What happens is uh- [Robert Downey Jr.] plays uh- this a [dude], uh- [Kirk Lazerus] and
then he gets a skin pigmentation, uh- operation to play as [Lincoln Osiris] in the movie, 
uh- [Tropic Thunder].
'@)

$Ctrl.X(0,"00:18:23","00:18:24", @'
:And then there's this like, disclaimer, in the movie, it's like- 

[Disclaimer]: Winning an [Academy Award] for telling the most true story, about the 
              fake-true war story ever, [the most fake-true war story in existence]....
              [Tropic Thunder].
'@)

$Ctrl.X(0,"00:18:24","00:19:02", @'
:And then they like, they try to get the whole uh- like uh- [Forest Gump], [Vietnam] vibe,
when like, [Forest Gump] is like, [flying in on helicopters], and he meets [Lieutenant Dan]...?

And it's like...
'@)

$Ctrl.X(0,"00:19:02","00:19:24", @'
:They're trying to get that [feel] into the movie...
Uh- but- ya know, it comes up a little bit [short].

But that's ok, because the [movie] is actually [pretty funny]...?
It's just uh- I think that the part where [the dudes are emerging], is basically
the [climax] of the film.
'@)

$Ctrl.X(0,"00:19:24","00:19:43", @'
:So, [the dudes are emerging], is basically when uh- [Robert Downey Jr.], his character,
he's like, tryin' to like uh- rescue, uh- [Ben Stiller]'s character, and he's like...
'@)

$Ctrl.X(0,"00:19:43","00:19:57", @'
:[Blackface]: I'm a dude playin' a dude, disguised as another dude.
             I know what dude I am...
[Speedman] : Or, ARE you a dude, that claims to know what dude he is,
             by playing other dudes...?
'@)

$Ctrl.X(0,"00:19:57","00:20:10", @'
:And then like, uh- [Jack Black], his character, he's like:
[Portnoy]: What the fuck are you guys talking about...?

Cause basically, like the [conversation] that they're having...?
It SOUNDS like they're both [delusional].
'@)

$Ctrl.X(0,"00:20:10","00:20:27", @'
:But the fact of the matter, is that the [words] are [incredibly simple], and uh-
[most people in society], they're gonna HEAR something like that, they're just
gonna [start laughing], because it sounds [ridiculous].

But- there's a [reason] WHY things that sound [ridiculous] are funny, and they cause
people to [laugh].

Right...?
'@)

$Ctrl.X(0,"00:20:27","00:20:43", @'
:So, uh- about a month or two ago, I went to uh- this place, and this guy started like, 
talking like uh- like a [nervous wreck], he's like [worried] about [ju-ju spirits] in
the [church] or whatever...?
'@)

$Ctrl.X(0,"00:20:43","00:21:02", @'
:Ya know, and you know, they used to [sacrifice people] here, and they like, they probably
STILL do...?

I dunno, he was sayin' a bunch of stuff that like sounded [comedic]...?

But- the [amount] of it, or the [intensity] of it caused uh- everybody to think:
[Everybody]: Wow, this dude's, is like, a [nut job].

Right...?
'@)

$Ctrl.X(0,"00:21:02","00:21:37", @'
:So there's a [difference] between like uh- [pacing].
The [pacing] of how I talk, right now, in this [recording]...?

It's very uh- [grounded], and I would say that uh- few people are able to pull off, uh-
[speaking the way that I am right now].

And uh- this is [all dynamic], this is all like, [off the cuff].

It's not like, uh- I have a [script] to [read from] as I'm making these things, it's 
literally like, I'm comin' up with it all off the [top of my head].
'@)

$Ctrl.X(0,"00:21:37","00:22:03", @'
:And, because of how often I [practice] this, sometimes I will get into a [groove] and a
[rhythm], like, by [forcing myself] to do it.

Right...?
Not unlike how like sometimes I would... start to [practice], my [guitar], and then,
I would keep [practicing] my [guitar]...?

I would get to a point where I was [warmed up], and would [continue] to keep going, right...?
'@)

$Ctrl.X(0,"00:22:03","00:22:14", @'
:But, um, then I would have to res- re- rely on uh- [differing strategies], to continue
[playing] the [guitar], and what I'm doing right now [isn't much different], but...
'@)

$Ctrl.X(0,"00:22:14","00:22:24", @'
:The [strategy] that I'm using right now, well I'm using [MULTIPLE strategies], but the
[MAIN strategy] that I'm using right now, is [improvisation].
'@)

$Ctrl.X(0,"00:22:24","00:22:44", @'
:[Improv], uh- [improvisation].

So, there's a show called "Who's Line Is It, Anyway...?" starring like uh-
[Colin Mockery], uh the other guy from the [Drew Carey] show (Ryan Stiles), [Drew Carey], 
sometimes he will uh- [act it out]...?
On the show...?

It's very rare, though.
'@)

$Ctrl.X(0,"00:22:44","00:23:06", @'
:Uh, and then uh [Wayne Brady].
And, they've stuck with that for a while.

They have some other guy, that uh, comes on every once in a while, uh, a FEW other guys,
but they have like their [main crew]. Of uh- these uh- these guys that seem to have
[improvisation] down pat.
'@)

$Ctrl.X(0,"00:23:06","00:23:35", @'
:Now, like uh- the type of [comedian] that uh- they are, is basically [stage acting], and
[improvisation], but uh- ya know, like a [comedian] like [Louis C.K.]..?

He's gonna have a [skit] prepared [AHEAD of time], and he's gonna talk about his [observations], 
and he's gonna in- [inject] some of like, [HIS perceptions].

Same goes with like, the [other actors], the [other comedians] that I talk about a lot, too.
'@)

$Ctrl.X(0,"00:23:35","00:23:59", @'
:They're gonna talk about, like, uh... you know, uh... 
[Louis C.K.] has a skit where like, somebod- they're- they're [stuck in a traffic jam].
Right...?

And then, uh, some guy is like, [layin' on his horn], he's like:
[Some guy]: GooooOOooOOO~!
            Go~!

Right...?
There's a guy behind [Louis C.K.], in another car. 
And like, he's just [layin' on the horn]~!
'@)

$Ctrl.X(0,"00:23:59","00:24:27", @'
:And then like, uh- [Louis C.K.], he's- he's using his like hands, he's like:
[Louis C.K.]: *using hands* I can't go.
              I literally cannot go.
              ehhh... whaddya want me to do...?

And then like, the person behind him is just like:
[Some guy]: Just go~!

Ya know...?
And then, uh- I guess at [some point], like, the guy like, gets out of his car, and he's like,
he like, rushes up to like, [Louis C.K.]'s uh- car, and [Louis C.K.] rolls the window up.
'@)

$Ctrl.X(0,"00:24:27","00:24:41", @'
:He's like:
[Louis C.K.]: Ah, nah, not gonna take part of this abuse here...?
              Nah, gonna be like, I'm takin' part of this, whole charade here...?
              Nah, I don't think so, dude.

So, he rolls the window up.
'@)

$Ctrl.X(0,"00:24:41","00:24:51", @'
:And then the guy's like:
[Some guy]: Hey you~!

And then like, he's like pretendin' like...
Ehh, he knows he's there, but he's tryin' to like, [avoid the confrontation].
'@)

$Ctrl.X(0,"00:24:51","00:25:05", @'
:Right...?

And so like, this is a human- natural human instinct, right...?

Where, [somebody's pissed off], and like, people they're kinda like [terrified] or [scared], 
or something, or [they just don't wanna have a conversation with somebody], it's not a
[comfortable situation].
'@)

$Ctrl.X(0,"00:25:05","00:25:29", @'
:So... Uh... at SOME point, he's like:
[Louis C.K.]: I'm not gonna have this, [this guys' argument], here...
              If I'm gonna have an argument with him, I'm gonna have MY argument.

He's like:
[Louis C.K.]: I want my JACKET back~!

And then the guy's like:
[Some guy]  : What the...
              What jacket...?
[Louis C.K.]: I want it back, now~!
              Give me back my jacket~!
'@)

$Ctrl.X(0,"00:25:29","00:25:51", @'
:And then what this is, is... [distraction].
Right...?

It's a [distraction], because like, when people are like, [distracted], it causes
them to lose their [footing] or their [balance], right...?

And uh- ya know, the [WIND] right now is [distracting] me, and that's why I'm sorta 
confined to a certain area where I don't typically talk out loud.
'@)

$Ctrl.X(0,"00:25:51","00:26:09", @'
:But uh- ya know, the [distraction] in that scene, is, uh-
"Give me back my [jacket]", "I want my [jacket] back"...

And it caused the, the dude that he was worried about having a [conversation] with, to
like, [lose his footing], sort of be like "What the hell...?"
'@)

$Ctrl.X(0,"00:26:09","00:26:17", @'
:So like, the roles reverse, he's like:
[Some guy]: Wow, this dude's like [psycho] or somethin'...
            ...he's tellin' me he wants his [jacket] back...?
            What the hell...?
'@)

$Ctrl.X(0,"00:26:17","00:26:29", @'
:And then so like, the dude who like [originally] got out of his car, and started like,
like, uh- gettin' pissed at [Louis C.K.], he's like:
[Some guy]: What the fuck is up with this dude...?
'@)

$Ctrl.X(0,"00:26:29","00:26:40", @'
:And then like, [it works].
[It really does].

It's something that people can use in [real life], for a [varying degree of things].

Right...?
'@)

$Ctrl.X(0,"00:26:40","00:27:07", @'
:Ya know, uh- 
I was gonna make another joke about [Andrew Cuomo], but I think I've made enough
jokes about him, I was gonna say, if he wants to like [distract], like, some [girls]
or somethin', he could like, [try to whip his dick out].
'@)

$Ctrl.X(0,"00:27:07","00:27:14", @'
:Right...?

And then uh- the girls will be like:
[Girls]: Na na na, I'm- we're all set.
         Thanks, though.
'@)

$Ctrl.X(0,"00:27:14","00:27:28", @'
:And then uh- [Andrew Cuomo] will be like:
[A.C.] : You sure...?
         Sure about that...?
         I mean, fuckin'... [look at this thing]...

And then the girls will be like:
[Girls]: Na na na, don't wanna look at it.
         Ya know...?
         It's fuckin'...
'@)

$Ctrl.X(0,"00:27:28","00:28:07", @'
:This happened to him about [(11) times]. Ya know...?

[Louis C.K.], he had a situation where he was, about to release his [movie], uh-
I forget what it was called, I think it was "I Love You, Daddy"...?

Uh- and uh, ya know, he's the [director], he's a good [director], and uh- 
somebody decided to like, take a huge dump, all over what he had planned...

And they talked about how like, he was like crankin' on his pud, around a couple of uh-
female colleages.
'@)

$Ctrl.X(0,"00:28:07","00:28:24", @'
:Ya know, no- nobody... said nobody-
nothin' to nobody, like up until that movie was about to be released...?

And then [Louis C.K.] sorta lost out, big time.
And uh- that's a tragedy, cause I don't like...
'@)

$Ctrl.X(0,"00:28:24","00:28:43", @'
:I've made many comparisons between [Louis C.K.] and [Andrew Cuomo], before.
Right...

[Andrew Cuomo]...? [He is not gonna admit a god damn thing], because..
[that's what politicians do]...? 

Or at least what they tend to do...?
It's not a consistent case...?
Right...? But like...
'@)

$Ctrl.X(0,"00:28:43","00:28:58", @'
:Ya know, [Louis C.K.], he's like 
[Louis C.K.]: Yeah, I did.
              Ya know, I'm not gonna like, [lie] about what happened...
              Ya know, I asked they were like "Sure, ok..."

Right...?

At least in HIS case...?
They [facetiously] or [sarcastically] said [ok], and then [he just did it].
'@)

$Ctrl.X(0,"00:28:58","00:29:16", @'
:In [Andrew Cuomo]'s case, it was a [flat-out] fuckin' "No, dude... All set."
[(11) girls]. They all said "No."

And uh, somehow, ya know, he just [kept doin' it], he's Like:
[A.C.]: Well, fuckin' try as I might...
'@)

$Ctrl.X(0,"00:29:16","00:29:44", @'
:But anyway, uh- that's [another strategy], sorta like [bringing back], uh- [bullet points]
from the past that I've, like, [written about], uh- [written material], that's pretty good...

[Material] that I've [written], sometimes when I [write] about something a [number of times],
I will remember it...? It'll make it easier for me to [remember all the details], sorta like
I just did...?

I rattled off that story.
'@)

$Ctrl.X(0,"00:29:44","00:30:14", @'
:You'll never catch uh- a guy like [George Pataki], gettin' caught in a situation like that.
Not at all. 

Uh- nah, [George Pataki] was the governor like the entire time that I went to
[Shenendehowa School District], and it's like uh- 

Or no, I think it was like (1992), to (2006)...

Yeah and then [Eliot Spitzer] became the governor.
'@)

$Ctrl.X(0,"00:30:14","00:31:00", @'
:Anyway, uh- what else could I use, what other [strategies] could I use...
It is sorta windy right now, I could talk about the [weather]...

I could talk about [global warming]...
I could talk about [(250) mile tornado tracks]... [record].

[F4 tornado] leavin' behind a [(253) mile tornado track], or maybe, uh- it might've been
more or less... [(250) miles] for a tornado to go is [pretty staggering], and then also...
 
You've got these [hurricanes] that are showin' up and then you've got the, the [floods] 
goin' on over... uh- down south, and then you have like uh- the uh-
'@)

$Ctrl.X(0,"00:31:00","00:31:29", @'
:There really is a shit show, when it comes to the weather, and uh-
[climate change] is [definitely real], but- like, part of what the [news] DOES...?

Is like, they basically do the same thing as someone who [sits in a room] and [farts]
all the time, and just [sprays potpourri] or like [air freshener].
'@)

$Ctrl.X(0,"00:31:29","00:31:46", @'
:Like: 
[News]: Oh wow, oh no.
        Nobody's fartin' in here, smells like [vanilla].
        Or uh- ya know, [tropical flowers], or [blossoms].
        Ya know...?
        There is [nothing disgusting smelling in here].
        Not at all.
'@)

$Ctrl.X(0,"00:31:46","00:32:01", @'
:And that is sort of like, the reason why [global warming] is as bad as it is.

I'm using a [metaphor] right there, I'm using [literary devices]. 

Ya know, a lot of people, they will assume that like, what I'm sayin' is babbledy-gook.
'@)

$Ctrl.X(0,"00:32:01","00:32:34", @'
:Right...?
In many cases, some people will do that.

They will say:
[People]: What that dude is sayin'...?
          Is fuckin' babbledy-fuckin'-gook.

          He is makin' NO fuckin' sense, whatsoever.

          He's talkin' about like, the news...?
          Basically like, sittin' in a room...?
          And, chain fartin'...?

          And then like, every time they rip a fuckin' smelly-ass fart...?

          They gotta like, [spray the air freshener].

          That's...
          That's what he's sayin'...
'@)

$Ctrl.X(0,"00:32:34","00:32:53", @'
:Of course, some people will take what I'm saying a little too [literally]...
which is why there are [lit-er-ar-y de-vi-ces].

[Literary devices] are like uh- [metaphors] or [similies], ya know, using 
[like] or [as]...? [Metaphors]...? 
'@)

$Ctrl.X(0,"00:32:53","00:33:20", @'
:Uh- and then uh- also, like [hyperbole]...?
Basically an [exaggeration] of what's going on...?

So like, there might've been about (10) people, like, at a store that I was just at...?

But the [way] that they were like, like, frantically looking for the things they were
trying to buy...? They were- it- they- it act- it almost felt like there were about 
(100) of em, in there.

Right...?
So, that's an exaggeration...
'@)

$Ctrl.X(0,"00:33:20","00:33:54", @'
:But then there's also, it works in the other way, where like uh- [Louis C.K.] also, 
he's says like uh, ya know, uh- most of the people in the world, probably sucked a dick
at some point...?

Ya know...?
Like, basically half the population sucks, like, sucks a dick (cause they're females), 
sucks dick... and then uh- ya know...?

And then there's guys that are FORCED to suck a dick... 
Right...? 

And then, uh- ya know...? 
There's gotta be like (10) of us out there, somewhere, that have never sucked a dick before.
'@)

$Ctrl.X(0,"00:33:54","00:34:27", @'
:Right...? So like, there's [(7.5) billion] people on the planet, or, maybe more or less.

I can't remember the exact number, but- ya know, uh- it works in the other way, where
you're making [sheer exaggeration], that's a [hyperbole], but- instead of uh- making
something sound MORE [intense], you make it seem much more [miniscule], and then uh-
it's the [same technique], but...
'@)

$Ctrl.X(0,"00:34:27","00:34:41", @'
:Typically when people say [exaggerations], they're not thinking like uh- like turning
(1) into (10)... Uh- they're thinking (1) into (10), not like (10) into (1).
'@)

$Ctrl.X(0,"00:34:41","00:35:00", @'
:Though, it's not a consistent case.

Uhm, and then also, uh- [another strategy] would be, umh, well [observations] are f- a 
[strategic], uh- [pretty strategic choice]. 
'@)

$Ctrl.X(0,"00:35:00","00:35:29", @'
:So right now, like, I'm at a plaza.

I see some girl walking out to her vehicle.
She's... gettin' in a red truck.

She opened the door...?
She's sittin' down...?
She is... uh- put her bag down...?

She just shut the door...?

Uh- now she's gonna start her truck.
She's startin' the truck...?
Uh- it started~!

I can hear it...
She is probably lookin' at her phone real quick, before she takes off...?
'@)

$Ctrl.X(0,"00:35:29","00:35:41", @'
:And uh- ya know...?
What the hell...?

Uh- she's puttin' her seatbelt on...
Uh- she's... puttin' her seatbelt on after adjusting her glasses...?
Right...?
'@)

$Ctrl.X(0,"00:35:41","00:35:57", @'
:And uh...
Uh- there's another car comin'...

It's passin' the girl in the truck.
It's uh- [Acura]. SUV. MDX.

I'm not gonna read off the [license plate].
'@)

$Ctrl.X(0,"00:35:57","00:36:18", @'
:Uh- that, uh- [Acura] is taking a [left] out of the plaza.

The girl in the truck, has not gone anywhere yet.
She's fixin' her hair...

Uh- some older lady came out, she's gettin' into her (4) door [Honda Civic]...?

(2) other ladies comin' out from the other side of the plaza...?
'@)

$Ctrl.X(0,"00:36:18","00:36:41", @'
:Uh, te girl in the red truck hasn't gone anywhere...?
The lady with the [Civic], she just shut her door...?

She is... sorta doin' the [same maneuver] that the girl in the truck was doin' where
she's puttin' her seatbelt on, and adjusted, ready to leave...?

Uh- some dude walked out, of the other side of the plaza.
He's gettin' in HIS car, it's like a white uh, like [Subaru] somethin'.
'@)

$Ctrl.X(0,"00:36:41","00:37:00", @'
:Or maybe it's...?
I dunno.

The (2) ladies are walkin' to another store, they're not leavin'.

The red- the girl in the red truck, she's got a cigarette, she's opened her window a
little bit...? She's lighting her cigarette, and the other lady in the blue civic, she
is puttin' her seatbelt on...?
'@)

$Ctrl.X(0,"00:37:00","00:37:40", @'
:And, uh- Uh- girl in the red truck...? She is drivin' off, now...
She has no fuckin' clue, that I just narrated everything that she did.

That's ok.
Ya know...?

The dude in the white- [Toyota] somethin', he's pullin' out at the same time as this
lady in the blue [Civic], and the lady in the blue [Civic], she is just bein' very attentive
to detail...?

Red truck just turned right out of the plaza...?

Uh- the [Civic], the lady in the [Civic], she's drivin' like a grandma...?

And, the dude in the [Toyota RAV4]... the white [Toyota RAV4], he's...
They're basically goin' the [same direction].
'@)

$Ctrl.X(0,"00:37:40","00:37:58", @'
:I don't think that they're together, but they're both turnin' right, basically.

There was a r- there was a black car that pulled into the plaza as I was narrating
all that, the blue [Civic] and the white [Toyota]...?

They're gone now.
They [turned right] out of the plaza.
'@)

$Ctrl.X(0,"00:37:58","00:38:13", @'
:And then, there's like a dark blue uh- [Chevy] somethin'.

[Chevy Aveo], or whatever.
And it's- another [older lady].
'@)

$Ctrl.X(0,"00:38:13","00:38:26", @'
:She's got a hat on...?
It looks like a tophat...?

It looks like an [Englishman tophat].
Like, what [Charlie Chaplin] would wear.
And, uh...
'@)

$Ctrl.X(0,"00:38:26","00:38:49", @'
:Ya know, she's like [waddling] to the other side of the plaza...?
She... is walking into a store...?

And [short people], they look a lot like they're [waddling] when they [walk]...?
Cause they have to like, I dunno.

I think of like, how they're [gnomes].
'@)

$Ctrl.X(0,"00:38:49","00:39:00", @'
:See, there's nobody like within eye- uh- there's nobody that I can see who's like 
walking around right now, or drivin' around in the plaza...?

There's a bunch of cars drivin' around on [Route 9], but-
Ya know, uh...
'@)

$Ctrl.X(0,"00:39:00","00:39:16", @'
:It's [too many details] for me to be able to [narrate], and, further to that point, Uh-
if I don't make what I'm doing, [sounding interesting], see, I'm sorta like, getting
into the [swing of things here], uh- if uh-
'@)

$Ctrl.X(0,"00:39:16","00:39:37", @'
:If I don't [capitalize] on something that is [interesting] to tell...?

Or, there might be something that [isn't very interesting] at all, but the way I'm saying
what is happening, causes it to be [interesting]...

It might cause people to be [LESS interested] in some story going on [ELSEWHERE]...
'@)

$Ctrl.X(0,"00:39:37","00:39:55", @'
:And then like, they're payin' attention to [my story].
They're like:
[People]: Wait a minute, this fuckin' dude...
          He's just [narrating] shit...?
          And like, talking about stuff like [literary devices], and like [comedians]
          sayin' stuff, and uh- [Andrew Cuomo] bein' a [sausage wrecker]...?
          And uh...
'@)

$Ctrl.X(0,"00:39:55","00:40:07", @'
:Like, uh- I'm [recapping] and [reviewing] all of the things that I've talked about, like, 
what do I wanna talk about...?

What could be the [most interesting story] that I could tell right now...?
'@)

$Ctrl.X(0,"00:40:07","00:40:31", @'
:So, I could [backpedal] into like uh- the points that I wanted to make earlier, about [bias].
Right...?

Uhm, I do have a sense of [bias], I think [everybody does].
I think it's unavoidable that everybody has a sense of bias.

Nobody wants to talk around in their [underwear], with like, ya know, uh-
'@)

$Ctrl.X(0,"00:40:31","00:40:49", @'
:Some dude just got out of his [minivan], and he's walkin' into a store.

I just [inserted] that [observation] into uh- the [middle of a statement] that I was about
to make about [bias]. Uh- a girl, a lady walked out of the same, uh- minivan.
'@)

$Ctrl.X(0,"00:40:49","00:41:15", @'
:They're goin'- she's goin' to the [same place].
And I think... ya know...?

Uh- some- some girl is leaving another place, and...
She has a child. A girl, they're getting in- no, they're [walking] to the SUV that I've been
[standing near recording], so I'm not gonna be [rude].
'@)

$Ctrl.X(0,"00:41:15","00:41:45", @'
:I'm not gonna [narrate] what they're doin'... 
Ya know, [narration] has a- there is a bit of a [rude] aspect to, like, [narrating] what
[people] are [doing].

Right...?
So, rather than to be [openly] or [blatantly rude], take a step back, step behind the pylon...
and then like, kinda peer around the corner almost like I'm tryin' to hide...

Well, I am tryin' to hide, while I'm [narrating] what they're doin'.
'@)

$Ctrl.X(0,"00:41:45","00:42:16", @'
:Uh- a sense of bias.
So like...

I did mention that it is [pretty windy]...?
It is sorta cold...?

But- ya know, like, my [sense of bias] is gonna be a [natural thing], to where, uh-
I would [prefer] that the [environment] be a little [warmer] than it is, and not so [windy].
'@)

$Ctrl.X(0,"00:42:16","00:42:28", @'
:Cause then I would have [more liberties] to like, [go around and doing stuff], instead of
like, [standing behind this pylon], while like, people are getting in and out of their vehicles.
'@)

$Ctrl.X(0,"00:42:28","00:42:40", @'
:So, uh...
Sometimes when I'm [writing documents]...?

I have to like, [overlap] certain things.
Or, [embed] them within each other.
'@)

$Ctrl.X(0,"00:42:40","00:43:16", @'
:And uh- [one thing] that I noticed when I was [performing] like, [transcriptions] and stuff...

Is like, when [people] are having a [conversation], and like, what they're saying is
[interfering] with what the other person is saying...?

Sometimes, it seems like the [words] get [tossed around].

Or like, the [voice] or the [sounds], they sorta like [blend together]...?

And like, even though the people, when they're [talking in person], it makes [total sense]...?
'@)

$Ctrl.X(0,"00:43:16","00:43:51", @'
:Uh, when you [listen] to the [audio recording], sometimes it is [absolutely impossible], or 
[damn near impossible] to make out what the hell [somebody] is [saying].

And uh, ya know when, when listening to an [audio transcription] for the first time...?

Uh- you're gonna have a really [rough idea] of what [words] are being [stated]...?

And, then, then once you have the [initial transcription] figured out...?

Then you're gonna realize when and where [certain words] didn't make it into the 
[transcription], so you add em and tweak em like I do...?
'@)

$Ctrl.X(0,"00:43:51","00:44:06", @'
:But then also, like if you wanna add some [styling] like I do, I [format] like, the things
that I [write] uh- I use the [square brackets], and then I also use the- the [bold]...?

Right...?
'@)

$Ctrl.X(0,"00:44:06","00:44:27", @'
:I've used a [varying degree] of uh, fonts, and uh [programs], and uh [methods]...? 
Right...?

I could've like, used [PowerPoint], to like, tell a story about a [(1000) different ways] till
Sunday, or I could've gone to like, [Premiere Pro], I could've edited a whole bunch of scenes,
I could've used [OpenShot]...?

Or whatever...?

Right...?
'@)

$Ctrl.X(0,"00:44:27","00:45:03", @'
:But, out of all those programs, I think the [best way] to tell a [story]...
Well, it's my [opinion], it's like, uh [live].

Ya know...?
It's- what I'm [focusing] on right now, is a [live presentation].

Ya know, when the people listen to what I'm doing right now, it's not gonna be live...?

But- ya know, I could [very easily] go in front of a [group of people], that know what,
what I'm gonna- that- that [predict some of my behaviors], or things I'm gonna [talk about],
and then like, basically do the [same thing] that I'm doing [right now].
'@)

$Ctrl.X(0,"00:45:03","00:45:32", @'
:But- it is [very difficult] to get a [bunch of people] in the [same place] at the [same time], 
for something that is [totally unexpected] or [unscheduled]. And, I don't like the idea of
[scheduling things].

Mainly because, if I had to [schedule] what I'm doing right now...?

It would take on a [different feeling] and then it would feel more [forced] and [coerced],
rather than to be [free-flowing] and [dynamic], like it is right now.
'@)

$Ctrl.X(0,"00:45:32","00:46:05", @'
:So I'm sort of like, covering a [whole variety] of [topics].
And, something like this, is gonna [catch a lot of people by surprise].

Because a lot of people aren't gonna to [understand] what the hell I'm saying, even though
they can hear me saying the words and the words sound, like, ya know...

They're not like uh- it's not like I'm talking about [dragons flying around in the sky],
and the sky is like, [turning a bunch of different colors], and then you got [leprechauns]
and [Zebras] flying around, or uh- [unicorns]...?
'@)

$Ctrl.X(0,"00:46:05","00:46:33", @'
:You got [leprechauns], [unicorns], and uh [aliens], all like [dancing in big friggen circles]
in the sky. Nah, [I'm not talking about shit like that].

Nah, it's- eh- THOSE are [delusions].
Right...?

But- ya know, given enough like, [expansion] of those [details] and stuff, it could be that
someone is using a [metaphor], and someone is [not paying close enough attention to that].
'@)

$Ctrl.X(0,"00:46:33","00:47:06", @'
:And they don't have the [observation skills] necessary to be able to deci- to [dissect] whether
or not [somebody's using a metaphor] or not. And so, I'm

There is a [category], or [range of intelligence], where...

Most people [expect]... people in society, to [talk] about things that they saw on [TV]...
or like a [movie], or a [book] or the [news]...?

Right...?
'@)

$Ctrl.X(0,"00:47:06","00:47:19", @'
:It's like, they- they saw an [interesting story] somewhere else, and whether it was 
[syndicated] or it was [printed], or whatever, [communicated] somehow...?

Uh-
'@)

$Ctrl.X(0,"00:47:19","00:47:42", @'
:There exists like, [a number of barriers], that prevent like, [truly interesting stories]
from being told, so that like, people that like, have a really cool [personality]... 

They're, they're given a lot more uh- like uh, [screen time] or [viewing time], or whatever.
'@)

$Ctrl.X(0,"00:47:42","00:48:11", @'
:Whereas somebody like me, who's attempting to [dissect] and [examine] certain subjects, at
length, ya know, [some people have made it very clear to me], that they don't like how uh,
how [descript] I am. 

But further to that point, like, uh... 
'@)

$Ctrl.X(0,"00:48:11","00:48:42", @'
:If I were to [teach people], how to talk the way that I am- that I've, been [talking], and 
[presenting myself], I would likely be somebody like a [professor], at a [school].

[I've mentioned this numerous times before]...

What is it that made like [George Carlin] such a [really powerful speaker], was his [writing].

And [writing] is a [very important skill] to have, if you're gonna be [presenting yourself]
like I do, or really even at all. But-
'@)

$Ctrl.X(0,"00:48:42","00:49:21", @'
:But- ya know, do I think that like, most uh [reporters] or uh, [TV anchors], do I think that
they [do their own writing]...? I dunno. [I really don't think that they do]... 

I think like, they [read] a [teleprompter], and [somebody prepared] what goes into that
teleprompter [ahead of time], and, they have an idea for like, how much [time] they have...?

How long it's gonna take for them to [talk] about the [particular subject]...?

So the [teleprompter] is only gonna have a [certain maximum word limit]...?
'@)

$Ctrl.X(0,"00:49:21","00:49:45", @'
:And, sometimes the [anchors], they don't know how to [pronounce] certain words...?

([Guiliana Bruno] from WTEN was attempting to pronounce a [medication name], and she
literally said "Uh, what...?", but this is pretty rare.)

So like, uh- being considerate of all those things, um...
Being an [anchor] on a, [news station], is a bit of a [choreographed] uh- situation...
'@)

$Ctrl.X(0,"00:49:45","00:50:01", @'
:Whereas what I'm doing is [a lot harder to do]... [without question]...

What I'm doing is [a lot more difficult to do], than [what they do]...

But that doesn't mean that what they do isn't difficult, cause it is...?
'@)

$Ctrl.X(0,"00:50:01","00:50:23", @'
:It has to be [syncopated]...?
It has to be in [rhythm]...?
It has to be, uh- [short] and to the [point]...?

Because most people are gonna have a hard time wrapping their heads around like, 
a lot of [rich content].

But- ya know, that varies.
Depends on what the [content] is.
'@)

$Ctrl.X(0,"00:50:23","00:50:59", @'
:So when I ask the quqestion like uh- what do I wanna talk about, or uh- if I say, even
me, I convey a [sense of bias] to [some degree], with uh- the things that I will... 

Like, I can say for certain that [this particular audio recording]...?

Uh, I'm gonna go and make it [publicly available], because I've gotten to the point where
I'm [a lot more comfortable], uh- with the things that I'm talking about. 

And, though I am still [improvising] to a large extent...?

I've talked about a number of, [constructive things] so far.
'@)

$Ctrl.X(0,"00:50:59","00:51:20", @'
:And most notably, like uh- [strategies].

And, [one strategy] that I uh- wanted to- to, get around to, is this, right...?

Uhm, when I'm [programming], when I'm sittin' in front of the computer screen and I'm
like, actually [programming] something...? 
'@)

$Ctrl.X(0,"00:51:20","00:51:47", @'
:Uh- I think about the [number of ways to dissect], uh the [properties], or the [task at hand],
and I [stick with the rather simple building blocks]. 

I don't uh- try to get- there are [some cases] where I'll go to [extreme lengths] to make
things that are [pretty complicated], but I've gotten to the point where I can [dissect] the
idea of what I wanna build, pretty easily...?
'@)

$Ctrl.X(0,"00:51:47","00:52:07", @'
:And then have a way to [showcase] it pretty easily, too.

And then like, ya know, I've written a [fair amount of programming] already, so like, 
I will know:
[Me]: Ok, in the [one function] I wrote, I did this...?
      I'd like to [copy] and [paste] it, but I ALSO wanna like, [rebuild it] from the ground up.
'@)

$Ctrl.X(0,"00:52:07","00:52:37", @'
:And so, that's what I'll do. 

I'll uh- [rebuild something from the ground up], and I'll just continue to go at the same
thing that I did already, right...?

Not to the degree where I'm spending like, like [weeks] or [months], uh [building] something...
But- to the degree where, uh- I'll [start to refine the edges a little bit more].

Or I'll [sand the edges down].
'@)

$Ctrl.X(0,"00:52:37","00:53:25", @'
:And, instead of it being a [harsh 90 degree corner], [right angle]...?
It'll be a [smooth beveled surface], ya know...? Like a [curve].

So, when I used to build maps for [Quake III Arena], one uh- relatively new concept was uh-
[curves]. So, prior to [Quake III Arena], in order to make [curves], you had to like, chisel
out like, [brushes].

And, you know, if you wanted to make like a [beveled surface]...?
You'd have to- like you- you'd have to uh- I dunno, I'll have to [expand] upon this concept
a bit more, but- 
'@)

$Ctrl.X(0,"00:53:25","00:54:16", @'
:Uh, [Quake III Arena] and [Doom], well, [Quake] and [Doom], the way that they calculated like,
the [space of a room], or the [area] of uh, or was uh- considered the [playable area]...?

Uh- it had to use a number of [techniques] that like, divided the [non-playable area], from
the [playable area], and then like, whatever the [geometry] was...? Uh- it would have to break 
everything down to [triangles].

And, when [Quake III Arena] came out, it took the idea of brushes, and then it inserted this
idea of like, [curves], to where the [curves] could be like uh- [generated by the hardware].
'@)

$Ctrl.X(0,"00:54:16","00:55:15", @'
:And then it would be able to [dynamically adjust], whether or not the [curve] was [complex] or
[simple]. And, uh- another term for this is basically the uh- [draw distance].

So like, uhm, if I'm like, compared to real life, right, uh- 

If I'm walking down the road, and I see like, the [golden arches] for [McDonalds] like (3)
miles away down the road...? 

Well, chances are that I could get away with using some really cheap uh, [geometry] to reflect
that. You don't want it to look like, awful, but you're not anywhere near the [golden arches]
to be able to determine whether that thing has like [thousands of polygons], or just like a 
[handful].
'@)

$Ctrl.X(0,"00:55:15","00:55:30", @'
:Whereas uh, you know, if you're like- you know, about like, a [quarter mile away] from the
[golden arches]...? You're gonna be able to see [a lot more detail].

And then once you get like, about [(10) feet] to the damn sign...?
Then, you're gonna see a [HELL of a lot more detail].

Then you're really gonna wa- probably not gonna wanna use [thousands] of uh, [triangles], or
uh [polygons], but- ya know, uh- these are the things that uh- [tesselation] addresses.
'@)

$Ctrl.X(0,"00:55:30","00:56:22", @'
:[Tesselation] uh- is something that- I don't know if [Nvidia] pioneered [tesselation], but- uh,
it's a pretty cool idea, is this uh- [graphics demonstration], I think it was [Heaven]...?

It might've been uh- called something else, I can't remember exactly.
([Unigine Heaven], with the dragon. It's not a [game], its a [benchmark utility].)

But, it's like uh- you could turn the [tesselation] on...?
And, the higher the [tesselation], the more [polygons] it would draw...?
'@)

$Ctrl.X(0,"00:56:22","00:56:47", @'
:So like, the [programming] for the [game] hadn't changed at all, but the [level of detail] uh
was [raised immensely]. And that's what LOD stands for, LOD bias or uh, [distance]... these
are all like, uh- [property] or uh something terms...? 

Right, and...
'@)

$Ctrl.X(0,"00:56:47","00:57:16", @'
:Running something through like, a [game engine], uh everything has [properties], right...?

So like, the [game engine] has to load a whole bunch of [details], not unlike how uh...

When I start to [play music], or I start to like, uh- rattle off one of these [lectures],
I'm talking about a bunch of, like, [details].

So, [asset management]. 
And [asset management] comes down to like, [documentation].
'@)

$Ctrl.X(0,"00:57:16","00:57:32", @'
:And, uh [recording myself], and knowing how to [present] it, and...
being able to make it [consumable], and making sure that people [understand] it.

And uh- the things that seem rather [simple] and [intuitive]...?
'@)

$Ctrl.X(0,"00:57:32","00:58:11", @'
:Like in the real world...?

You find out pretty quickly, that even something as simple as what I'm doing right now,
it isn't that simple, but further to that point... uh-

[A lot of people take things for granted].

So what I mean is this, like I have put a lot of [effort] into trying to like uh...
[Shape my voice], and my [narrative], when making these things...?

Right, so like, there's a lady in a SUV, it's a [Honda SUV]...?

She's pullin' up to the, the parking spot...?
She just stopped.
'@)

$Ctrl.X(0,"00:58:11","00:58:27", @'
:Uh- no, she's rollin' up a lil b-
Uh- now she stopped.

Alright...?
She's lookin' left...?
She's lookin' right...?

She is making sure her jacket's zipped up all the way...?
And, she's about to get out...?
Uh- somebody in a truck just drove up...?
'@)

$Ctrl.X(0,"00:58:27","00:58:45", @'
:See, what I'm doing right now, is I'm using ar [distaction technique].
But I'm also, like, using [observations], right...?

So, in a [conversation] that I would be having with somebody, I could use one of these
[distraction techniques], if I want to [distract] from uh, the point that I was just about
to make.
'@)

$Ctrl.X(0,"00:58:45","00:59:09", @'
:But- the point that I was about to make, is gonna be [harder] for me to reach, unless...
Uh- I can remember walking down a path, or where my por- [point of origin] was. 

And so, with [most people], they're not go- they're gonna have a really rough time, being
able to [comprehend] all the things that I stated so far in this [audio recording]...
'@)

$Ctrl.X(0,"00:59:09","00:59:30", @'
:[Hearing it], they'll [understand] it just fine.
But [comprehending] it, is a [different thing].

You can [hear] somebody talk, you can [listen] to somebody talk, you can [hear] them talk,
but to [comprehend] it, requires being able to like, uh- [understand] what was stated, and
then [repeat it back].
'@)

$Ctrl.X(0,"00:59:30","01:00:00", @'
:And [comprehension] is, fucking difficult. Lemme tell ya.
Because, ya know, most people, like, go on [autopilot], right...?

So like I'm- I haven't been- like, on [autopilot] at all in this entire uh, [recording].

Like I'm- I would say it sorta falls in line with [performance acting], but I'm not [acting].

I'm- [being myself].
So, it's more like, [performance profession].
'@)

$Ctrl.X(0,"01:00:00","01:00:21", @'
:Right...?
Dude in his [Range Rover]...? [Gray Range Rover] just pulled up.
He's got his (sun)glasses on, and his winter hat.

He just turned his, [Range Rover] off...?
And, ya know...?

[He looks like a cool dude].
With his [glasses] on.
And, those are [observation tehcniques].
'@)

$Ctrl.X(0,"01:00:21","01:00:53", @'
:And then, it's another [distraction]...?
It's another [strategy].

Uh- really, the [beginning] and the [end] of this whole [lecture] comes down to, telling an
[interesting story] and then like, [knowing what to say], to cause the story to BE
[interesting]...

...they're [(2) totally different subjects], and I have to tape em together as I'm making
these things, because it's not really all that [intuitive].
'@)

$Ctrl.X(0,"01:00:53","01:01:24", @'
:And uh- few people are gonna be able to [appreciate] somethin' like this.

Ya know, maybe like [hundreds of years] in the future...?
People will like, listen to some of my [audio recordings], and they'll be like:
[People]: Wow, this dude...?
          Ya know...?
          He is like a- he was like the [Shakespeare] of ya know, (2000). (23).
          How did he not get [standing ovations] like, every time that he hit the record 
          button...?
'@)

$Ctrl.X(0,"01:01:24","01:02:10", @'
:Well, I can tell ya, it's because uh- the way our [society] is [shaped] now, is sort of like,
[on demand]. 

Ya know like, when people watch [primetime television], they're like:
[People]: Well, we'll put [primetime television] on because like, most people work like (9-5).

          And then when they get outta work, they wanna like, [watch the news].

          Some people work (8-4) though, [Michael Cook].
          So, we'll have like an [hour long session of news]...?
          
          And then we'll have [ANOTHER hour long session of news] that's sorta like covers
          the same topics that they just covered... the [last hour]...?
          
          And then while people are like, watchin' the news...?
          They'll be able to like, [cook themselves dinner and shit].
'@)

$Ctrl.X(0,"01:02:10","01:02:27", @'
:And that's basically what the [news companies] do.
Ya know...?

It's what they do.

Most people in society, they work (9-5), because, [that is when people feel like doin' shit].
'@)

$Ctrl.X(0,"01:02:27","01:02:54", @'
:Ya know, what if [everybody] worked at night...?

Nah, that's fuckin' stupid, cause ya know, the [circadian rhythm], [Michael Cook].

You wanna talk about your [circadian rhythm], you don't wanna [fight] the urge to wanna
[fall asleep], because if you do...? 

Then you might be awake all night. 
And you ddn't want that...
'@)

$Ctrl.X(0,"01:02:54","01:03:16", @'
:Not if you want to be able to, uh- have a uh- have a [healthy routine]...?
Or a [healthy lifestyle] or whatever...?

You wanna make damn certain that you're [well-rested], in order to [comprehend] stuff...?
And that, uh-
'@)

$Ctrl.X(0,"01:03:16","01:03:35", @'
:Yeah, there's a lot goin' on right now, looks like the guy in his [Range Rover] is takin' off.
There's a guy like, talkin to some girl...?

Have- having a bag...?
And, uh- he's got a red car...?
And then some third dude got into another [SUV]...?

A fuckin' [Subaru] or whatever...?
'@)

$Ctrl.X(0,"01:03:35","01:04:03", @'
:Dude in the [Range Rover], he stopped.

He's like "What the hell...?"

But uh- yeah, how do I tell, these- these details that I'm rattling off, what the hell
do they mean for anybody else...?

And so like, it all comes down to like, the [presentation].
Right...?
'@)

$Ctrl.X(0,"01:04:03","01:04:24", @'
:The [presentation], is something that [few people] are gonna be able to [appreciate], because...
Uh- if they wanna [learn something] from some of my [observation skills], they're gonna have
a [fun time] doing it.

They're gonna like, [learn some cool shit], and then they're also gonna like, 
[see some cool shit], too...
'@)

$Ctrl.X(0,"01:04:24","01:04:43", @'
:They're gonna be like:
[Them]: Wow.
        That fuckin' [Michael Cook] dude worked really hard, to like, be a cut above the rest.

But the problem is like, most people, they're [not gonna appreciate] what I'm doing, unless
they [know] what the hell I'm tryin' to do.
'@)

$Ctrl.X(0,"01:04:43","01:04:59", @'
:Whereas, someone like [George Carlin], he spent years doin' this.
I- I would imagine...

I would imagine, like, he probably had a [tape recorder].
And then he [listened] to himself [all the time], he's like:
[Carlin]: You know what, dude...?
          I'm gonna buy a tape...?
          And then [record myself] just talkin' about a [whole bunch of shit] that wrote about...?
'@)

$Ctrl.X(0,"01:04:59","01:05:24", @'
:And then, ya know, at some point...?

He started to like, uh- [get in front of people], talking about those things that he 
[wrote about], and [recorded]...? And then, eventually [things took off].

But- I gotta say, it probably took [a lot of fucking work]. 
'@)

$Ctrl.X(0,"01:05:24","01:05:51", @'
:Whereas like, uhm...

Let me go out on a limb here, and say that guys like [Bill Burr], or uh- [Louis C.K.]...?

Uh- they probably too, [have done this same thing], right...?

And like, what the hell was it that caused [Bill Burr] to go from being this relatively
unknown person, to like [suddenly being the one of the best names in comedy]...?
'@)

$Ctrl.X(0,"01:05:51","01:06:17", @'
:Well, I think is [appearance] on [Breaking Bad], was uh- definitely uh- helpful...
Right...?

Playing [Kubee] on [Breaking Bad]...? It's like:
[Somebody]     : Wow, that dude that played the fuckin' [Huell]'s like, sidekick...?
                 In [Breaking Bad]...?
                 He's a fuckin' comedian...?
[Someone Else] : Yeah, he's a fuckin' really GOOD comedian, too.
                 Talks about smashin' muffins, and shit.
'@)

$Ctrl.X(0,"01:06:17","01:06:39", @'
:Smashin' the muffins...?
Right...?

He asks himself the same sorts of [questions] that like [Louis C.K.] and [George Carlin] do.

He's like:
[Burr] : How many muffins, could I [destroy], before anybody did anything about it...?
         Ya know...?
         If I destroy (1) muffin, will the lady like, freak out and be like:
         "What the hell did you do THAT, for...?"
'@)

$Ctrl.X(0,"01:06:39","01:06:48", @'
:And then like, 
Ya know, that's- that's sort of a question that I ask myself.

Was like, inter- [interjecting into his joke], and [expanding upon it].
Or [extending] it, right...?
'@)

$Ctrl.X(0,"01:06:48","01:07:06", @'
:[Me]   : Well, I just destroyed one of your muffins, lady.

And then the lady would be like:
[Lady] : Well, what the fuck...
         Why would you DO that...?

And then I would be Like:
[Me]   : Well, just to see what you would do.
'@)

$Ctrl.X(0,"01:07:06","01:07:33", @'
:And so what I'm doing, is I'm sorta [slowing down] the [whole scene] in my head.

It's making the whole situation seem rather [unrealistic], but- 
Ya know, it's making it [comedic].

[Slowing down a situation] is a [tactic] that I have learned to use, to describe the 
[innate nature] of something, right...?

So, if uh- if you start havin' a conversation with this uh- this muffin lady...
'@)

$Ctrl.X(0,"01:07:33","01:08:34", @'
:Say:
[Me]: You know what...?
      I destroyed one of your muffins, because I just felt like it.
      I wanted to see what you would do.

And then the lady would be like:
[Lady]: Well that's- rather rude of you.
        Do you know how long I take, to make these fucking muffins, buddy...?

And then I would say:
[Me]: I dunno.
      How long do you take to make those muffins...?

And the lady will be like, put her hand on her hip and be like:
[Lady]: I fuckin' slave over the stove, to make these god damn muffins...
        ...and you're just gonna walk up, and then smash one of my fuckin' muffins...?
        How dare you...?

And then I would say:
[Me]: Well, what if I smash another one...?
      
And then the lady would be like:
[Lady]: You better not do it...
        Better not do it...

And then I would be like:
[Me]: Well, what are you gonna do if I do do that...?

And then the lady would be like:
[Lady]: Well, ya know I'm gonna be pissed...

And then, I would say:
[Me]: Well, how much more pissed would you be, than you are right now...?
      Twice as pissed...?
'@)

$Ctrl.X(0,"01:08:34","01:08:43", @'
:Lady'll be like:
[Lady]: Well, I dunno.
        Maybe not TWICE as pissed, I would just still be the same amount of pissed...
        but just slightly more...
'@)

$Ctrl.X(0,"01:08:43","01:09:20", @'
:Right...?
So these things all touch on [philosophy].

Am I gonna like [capitalize] on a bit that [Bill Burr] did...?
Well, I have [expanded] upon what made that [skit] as [funny] as it is...

And sort of [coalescing] it into uh- the same sort of conversation that uh-
[Lincoln Osiris] slash [Kirk Lazerus] has with [Tugg Speedman] in, [Tropic Thunder].

He's just a dude, playin' a dude, disguised as another dude.
'@)

$Ctrl.X(0,"01:09:20","01:09:47", @'
:Well, or are you a dude, that claims to know what dude he is, or that- that does NOT
know what dude he is, but claims to know what dude he is, by playing other dudes...?

Because, ya know, the [reality] is this, right...?
Uhm, in [programming]...?
[I'm gonna tie all these things together here], right now.
'@)

$Ctrl.X(0,"01:09:47","01:10:25", @'
:In [programming], you really have to deal with the concept of [(0), (1), or more than (1)].

So if there is (0) of something...?
Then you're gonna have 'no'.

If you have (1)...? 
Then you have 'an' or 'a'.

If you have more than (1)...?
You're gonna have 'some', or 'many' or 'most'...?

And then, like if you have, like the [maximum number] that you could [possibly have],
of something, you're gonna have 'all'.
'@)

$Ctrl.X(0,"01:10:25","01:10:49", @'
:Right, so...

Those terms right there, [illuminate] a [spectrum] between like, ya know, uh- [defining]
the [least amount] of things that could be [had]... 

...to the, the [approximate], or uh [sensible amount] of things that could be [had],
[talked about]...

...to the [most amount] of things that could be [had], or [talked about], or [seen], or 
[observed]...
'@)

$Ctrl.X(0,"01:10:49","01:11:22", @'
:So like, these things are gonna [sound non-sensical], because, I'm [literally] throwing
out a bunch of [mathematical operators], with [language].

And, this is how [comedy] gets its' [comedic feel] to it.

It all comes down to [math], and generally speaking, a [punchline] or
something that [makes] something [funny]...?

Is, is, [the amount of time that goes into it].

(Whether that is the amount of time that goes into writing the joke, or delivering
it, OR, the amount of time that passes within the joke. It all applies.)
'@)

$Ctrl.X(0,"01:11:22","01:12:04", @'
:Ya know, like uh- 
[You]   : (1), (2), skip a few, (99), (100).

Like, 
[Person]: Well, you didn't count (1) to (100).
[You]   : Yeah, I did.
[Person]: No you didn't, you said (1), (2), (99), (100).

And then you're like:
[You]   : Nope, I said 'skip a few'... as well.

And the person'll be like:
[Person]: Yeah, but that's not even- that's not a number...
          that's like you're skipping a few.

And then you're like:
[You]   : Well yeah, I am skippin' a few.
          I'm skippin' like, (3) to (98).

          Ya know...?
          Who the hell are you...?

          You're NOT skippin' like, (3) to (98).
          Ya know...?
          (3) to (98).
'@)

$Ctrl.X(0,"01:12:04","01:12:35", @'
:(1), (2), skip a few, (99), (100).
(3) to (98) is [bypassed].
There's no need to say all that with that [shorthand methodology].

And [programming] works in the same way.
Where like, if you have a [pattern], that can be arrived at...?
With a rather [adamant conclusion]...?

Then you can [aggregate] what the- you can [project] what that [mathematical formula]
might turn out to be, and that's like 'level of detail', and that's also like uh-
[complexity].
'@)

$Ctrl.X(0,"01:12:35","01:12:56", @'
:Like uh- the [news], they want [all the details]- they want everybody to see a [McDonalds] 
as like the [lowest detail possible] from like [(3) miles away] with the [least amount] of
[polygons], but- that's because they're gonna talk about like [hundreds of subjects] 
like that.
'@)

$Ctrl.X(0,"01:12:56","01:13:25", @'
:Whereas, like, somebody like [Bill Burr], [Louis C.K.], or [George Carlin]... they're
gonna be like:
[Them]: Well, we're gonna talk a litle bit more like uh- [Noam Chomsky] here...
        about like the [muffin lady], or like uh- the amount of people on the planet
        that have [sucked a dick]... or the concept of [money], [bullshit], 
        [politics], [religion]...
'@)

$Ctrl.X(0,"01:13:25","01:13:47", @'
:[George Carlin] talked about [a lot of subjects], that were [pretty difficult] to talk about.

Ya know, some guy told me:
[Some guy]: One thing that you never wanna do is talk about like, [money] and [politics], 
            or [religion]

And I was like:
[Me]: Well, why...?

He's like:
[Some guy]: Because [nobody agrees] on anything.
            When- in [any of those subjects].
            So, if you [steer clear] of those [subjects], you'll be fine.
'@)

$Ctrl.X(0,"01:13:47","01:14:14", @'
:But, somebody like [George Carlin], he's gonna be like:

[Carlin]: You know what, I'm gonna talk about [money], [religion], and [politics] in the
          [same fucking joke]...

Right...?
And he's like, "Uh- the fuckin' government...? Like..."

Ya know, I'm not gonna recap any of his skits.

Because, uh- if I were to like recap skits by [George Carlin] and I'd be emulating
[George Carlin], and I don't wanna do that.
'@)

$Ctrl.X(0,"01:14:14","01:14:29", @'
:There are [some components] of uh some of the things that he did, that were [very interesting]
that I would like to [capitalize] on, but- I don't want to [reintroduce] other people's skits
or bits, ya know, I don't wanna be uh- like uh- [high on potneuse]...?
'@)

$Ctrl.X(0,"01:14:29","01:15:04", @'
:Where uh- a [dude] steals a joke, and then like, the one- the one kid, played by uh- what's
his name, played by [Jordan Peele], "I'd like get [high on potneuse]~!"

And then everbody's like "Shut the hell up, dude. You're annoying."
And then the other guy's like "I'd like to get [high on potneuse]~!"
And then the whole entire room of people, like laughs at the joke.

He's like:
[Peele]: But you just like, stole my joke, dude...
'@)

$Ctrl.X(0,"01:15:04","01:15:19", @'
:Oh no, hold on a second, that's not how it unfolds.

He says the joke to his buddy that's sittin' next to him, quietly...
And his buddy just says it like, [louder].

And then [everybody laughs at it].
'@)

$Ctrl.X(0,"01:15:19","01:15:49", @'
:Ya know, the [interesting thing] about [that particular skit], is that- that is how 
people [treat each other], in [society]. Is like, [somebody] that is [really liked] is
gonna [repeat something] that like, the [original author] came up with...?

And the [original author] is gonna be told:
[People]: You know what...? 
          No one fuckin' likes you, dude.

          So what, you came up with a funny joke...
          And that COOL kid that didn't come up with it...?
          He said it.

          And everybody laughed.
          Oh well, woe is you, dude.
'@)

$Ctrl.X(0,"01:15:49","01:16:25", @'
:Yeah, that is like, that is the uh bit of uh- [sadistic] way to look at it.

There is a lot of [grotesque] things, that [occur in humanity], but there's also
a lot of uh- [really cool], [awe-inspiring], [awesome things], and I think that-
being able to [blend them together], requires a [sense of finesse], in being able
to talk about these things.
'@)

$Ctrl.X(0,"01:16:25","01:16:57", @'
:Like, uh- yeah, I dunno.

Uhm, being able to talk about these things, requires a bit of uh- [practice], and 
[reexamination], of everything that I said. 

So, chances are, that I've spoken about, uh- a lot of uh, [useful things] in this 
[audio recording]. But-
'@)

$Ctrl.X(0,"01:16:57","01:17:06", @'
:I may very well, like, end this [recording], and [listen] to it...?
Like a bit- the pair of [recordings] that I made the other day...?
'@)

$Ctrl.X(0,"01:17:06","01:17:17", @'
:And uh- when I end this [recording] and I [listen] to it...?

I'm gonna think of [additional concepts] that I wanted to tal- that I wanna talk about.
That maybe I didn't include.

Right...?
In the [prior iteration].
'@)

$Ctrl.X(0,"01:17:17","01:17:40", @'
:And this is [important], because if I wanna talk about, uh- if I wanna make like a
[curriculum] or [teach people], or, make it seem [interesting] and [comedic], and to let
it flow on its own right...

Well, [how would I go about doing that], without like, uh- making a bunch of [failed attempts]
first...?
And that's just it.
'@)

$Ctrl.X(0,"01:17:40","01:18:11", @'
:Some people, like uh- [they will fail so many times], but at [some point] they [eventually]...

They, they start to get it right, and they start to [spread out their legs].

And then, their own [sense of identity], uh- their own [uniqueness], their [unique character],
or their [point] or their [view of the world], is able to be [capitalized on].

And, these are the things that [George Carlin] talked about.
'@)

$Ctrl.X(0,"01:18:11","01:19:11", @'
:Ya know, uh- he has an [interview] with uh- I think it was uh- [David Letterman]...?
I'm not sure, but- ya know, he's like:
[Letterman]: So, [George Carlin]...

And then [George Carlin]'s like
[Carlin]: Hello, [David Letterman], how ya doin'...?

And, [David Letterman]'s like:
[Letterman]: I dunno, dude.
             I'm- I'm doin' alright.
             Ya know...?

             You got this uh- 
             You got this friggen uh- [standup special], or whatever...?

And then [George Carlin]'s like:
[Carlin]: Yeh yeh yeh, I got this [standup special], uh- I got it- ya know, uh-
          Ya know, it's like I did (7) things that you don't wanna talk about on the TV...?
          Or that you'll never hear on the TV...?
          And I did well with that skit...?
          But- ya know, I, uh- spent a while thinkin' about some other stuff...?
          And I wanted to like, capitalize on some [other subjects]...?
          That were [harder] to talk about...?
          Like [money], [religion], and [politics]...?
'@)

$Ctrl.X(0,"01:19:11","01:19:31", @'
:And then, ohhhhhh boy.
What the hell was it-
[Brain Droppings]... that's when he comes up with [Brain Droppings].

[Brain Droppings] wasn't the thing that they were talking about, but ya know, like, 
ya know I am sorta like, skipping around in like, [George Carlin]'s like, history...

Of uh- being a comedian and stuff, right...?
'@)

$Ctrl.X(0,"01:19:31","01:19:44", @'
:He's like, this is... 
[It's Bad For Ya].
Or, [Brain Droppings].
Or, uh- [The (7) Words That You'll Never Hear on the fuckin' TV], nah.
'@)

$Ctrl.X(0,"01:19:44","01:20:03", @'
:Now you'll hear like at least like (5) of those words on the TV...

You might not hear all (7)...?
But you'll hear (5) of em.

Ya know, like uh- in the show [Breaking Bad], you know, on like [AMC]...?
Uh-
'@)

$Ctrl.X(0,"01:20:03","01:20:42", @'
:The [FCC] allowed these shows, to have (1) F-Bomb per season.

I can't remember another time in [Breaking Bad] where they use the F-word like on TV, 
but um, I remember like uh- the [Nazi] dudes, they were like, standin' over Hank..

(Ozymandias)
And they were like:
[Nazi]: So, you got any last words there, dude...?

And then Hank's like:
[Hank]: I'm ASAC Shraeder, and you can go fuck yourself.

And then he gets popped, right in the head.
'@)

$Ctrl.X(0,"01:20:42","01:20:58", @'
:Or uh- it's [assumed] that he gets shot in the head, but you know, [it happens off camera].

But um- ya know...?
Like, you'll [hear] some of these words on the TV from time to time.
'@)

$Ctrl.X(0,"01:20:58","01:21:28", @'
:You'll never hear the- you'll- it- it- if it is ever, like, heard on [primetime TV]...?
Oh my god, you're gonna like, be [fired].

You're gonna be [fired]...?
You're gonna be like, thrown into a [pit of despair]...?

You're never gonna be expected to ever crawl your way out of that [pit of despair]...?
And you're gonna have to [give up on your life], and [everything you have ever done]...
...in order to like, [get over the (1) time that you swore on TV].
'@)

$Ctrl.X(0,"01:21:28","01:21:57", @'
:It's gonna look sooo bad...?
And then like, people are gonna be like:
[People]: Oh my god, it's the guy that [swore] on [primetime TV]...?
          Right...?

          Oh my god, it's the guy that [swore] on [primetime TV]...
          Oh my god.

          Whatever will we do...?
          The guy [swore], [once], on [primetime TV].
'@)

$Ctrl.X(0,"01:21:57","01:22:25", @'
:And then [the whole entire world], came to a [grinding halt].

And then, a whole bunch of, like uh- [nuclear weapons] started flying all over the 
fuckin' place...? Like on [X-Men Apocalypse]...?

And then, uh- ya know holy shit.
And then everybody, on the [face of the planet died], because...

Some dude said the F-word on [primetime TV].
'@)

$Ctrl.X(0,"01:22:25","01:22:42", @'
:Yeah, nah.
That's fuckin' stupid, right...?

[Nobody's gonna die by sayin' the F-word].
But- the media...?

They like to make it [appear] as if they actually [issue these fines] for like, swearing
on TV or whatever... Or, [maybe they do actually fine the people], or whatever.
'@)

$Ctrl.X(0,"01:22:42","01:23:02", @'
:I have uh- come to the [conclusion], that [they probably don't fine anybody] for [swearing]
on [primetime TV], they just want people to [believe] that that's there, because ya know,
[when people can't swear in public], or like, or whatever...?

It causes people to be [more obedient].
'@)

$Ctrl.X(0,"01:23:02","01:23:24", @'
:The- then when you start to [swear] and stuff...?
It's like:
"Uh~! He's a [delinquent], and that means that he's a [fuckface]..."

Yep.
It is a bit of uh- like uh- like uh- [hypocritical] way to look at it. Um...
'@)

$Ctrl.X(0,"01:23:24","01:23:51", @'
:Yeah, so I think uh- I'm all done with this [particular audio log], uhm...

In closing...
I would like to say, that- being able to [focus] on [something] that's [interesting] and to
keep the [lecture] going...?

It can be [pretty difficult] to do sometimes, but sometimes I will [force myself] to do it,
like I did in the [very beginning] of this [audio recording].
'@)

$Ctrl.X(0,"01:23:51","01:24:11", @'
:Ya know, and then, once I get into the [swing of things]...?
I might start to use [strategies] that I've [rattled off]...?

Though, like- I've really only [cracked the surface] of the number of [strategies]
that COULD be used, and the [varying degrees] of uh- [perceptions] that people may have
when they hear it...
'@)

$Ctrl.X(0,"01:24:11","01:24:29", @'
:Uhm, I have to be [considerate] that like, [anybody]... uh- throughout society, that has
been [cradled], and like [sheltered] from like the [(7) words] that you'll never hear on
the TV... Nah, its- those words are [BAD]...
'@)

$Ctrl.X(0,"01:24:29","01:24:54", @'
:If you say those words...?
You're gonna be branded as a [douchebag], right off the rip.

You're not gonna be allowed at anybody's birthday party...?
And, uh...
Then uh- after... people stop inviting you to their birthday parties...?

Then people are gonna say:
[People]: Oh, there's that dude that we don't invite to our birthday parties, anymore...
          What a douchebag~!
'@)

$Ctrl.X(0,"01:24:54","01:25:28", @'
:And then, eventually, uh- people'll be like:
[Person 1]: Hey, remember that dude that we stopped inviting to our birthday parties
            because he swore that (1) time...?
            Out loud...?
            In front of a bunch of people...?

And then they'll be like:
[Person 2]: Yeh yeh yeh, I remember that guy.

And they'll be like:
[Person 1]: Well, that guy has his own standup special, and he's like, really famous now.
            How the hell did that happen...?

And then they'll be like:
[Person 2]: Well, uh...
            Maybe, uh...
            He worked at it...?

And then they'll be like:
[Person 1]: Yeah, he did work at it, didn't he...?
'@)

$Ctrl.X(0,"01:25:28","01:25:54", @'
:So like, guys like uh- [Free Beer and Hot Wings]...
[Free Beer and Hot Wings], I've talked about them before.

Even THEY will struggle to keep up with me, in these [audio recordings]...

Wanna know why...?
Because they have to [watch their language].

And, further to that point, they have like a [team] of [people] that [help] them [talk]
about stuff.
'@)

$Ctrl.X(0,"01:25:54","01:26:14", @'
:[Howard Stern] ALSO has, like a team of people that help him talk about stuff.
[Joe Rogan] ALSO has a team of people that help him talk about stuff.

Though, to be perfectly clear...?

They have this down to a [science], and, they have those people there for a reason
to keep the, conversation [flowing] and [moving], and non- [not so tangential].
'@)

$Ctrl.X(0,"01:26:14","01:26:37", @'
:Right...? Comparing me to any of the people that I just rattled off, including
like even [Imus], or uh- [Louis C.K.], or [George Carlin], or [Bill Burr], or uh-
Professors like uh- [Robert Sopolsky], or [Jordan Peterson], or uh- [Jeremy Rifkin]...?
'@)

$Ctrl.X(0,"01:26:37","01:27:02", @'
:Right...?
A lot of- uh- they- uh, I'm really like chiseling out, like, a [pretty large array] of 
[smart bastards], that uh- seem to have this [gift of gab]...

But, there's more to it than just a [gift of gab], they have [material] they wanna
[talk about] and [discuss], and I can guarantee you, that *every single one* of the
people that I rattled off...
'@)

$Ctrl.X(0,"01:27:02","01:27:17", @'
:[They have written a whole bunch of shit].
And if they don't continue to write stuff...?

They will talk about it with people, and someone else will write it, and then they'll...
I dunno. It's like... 
'@)

$Ctrl.X(0,"01:27:17","01:27:38", @'
:The way I see it, is like this...

If I [walk up to somebody], and I have a [conversation], uh- where I talk about [some] of
this stuff, I'm gonna be [distracted] by some of the [questions] that they ask.

However- uh, it'll take on a [totally new characteristic] where, I'll be like [answering]
some of the things that they're [asking] me.
'@)

$Ctrl.X(0,"01:27:38","01:27:59", @'
:I might not know the [answer] to [every question] that [somebody] asks me, ya know, I don't
think [anybody] really does. But, [sometimes] people that have [no fucking clue] how to
[answer] certain questions...?

Like, they will... [bullshit people].
And be like, well...
'@)

$Ctrl.X(0,"01:27:59","01:28:22", @'
:Like... like [Tucker Carlson] does.
From [Fox News].

Ya know, like, I saw something today where it says [Tucker Carlson Investigates]...

What the hell does [Tucker Carlson] investigate...?

[He doesn't investigate a god damn thing].
Ya know, I'm pretty sure that he has [written] his own shit, and I'm pretty sure, that he is
not an idiot...? But uh- 
'@)

$Ctrl.X(0,"01:28:22","01:28:34", @'
:[Make direct comparisons] between some of the things that I talk about, and what 
[Tucker Carlson] talks about. And [Sean Hannity]. And what you'll find, is that like...
'@)

$Ctrl.X(0,"01:28:34","01:28:50", @'
:Eh- I'm not gonna... I'm not gonna say it.
I'm not gonna [introduce my opinion], to uh- to them, and try to make [comparisons] between
myself and uh- these (2) guys on [Fox News].
'@)

$Ctrl.X(0,"01:28:50","01:29:08", @'
:What I can say for certain, is that like...

[I really don't know how the hell they managed to get where they are].

With [John Oliver], [it makes a hell of a lot of sense].
Where- [how he got to where he is].
'@)

$Ctrl.X(0,"01:29:08","01:29:22", @'
:I don't think he walked around, and talked about the same subjects that I do...?
Uh- but I do think that like, he was rather [comedic], and [very thought provoking]
about the things that he- felt like [showcasing].
'@)

$Ctrl.X(0,"01:29:22","01:29:56", @'
:And ya know, it started with uh- the [Today (Daily) Show].

Ya know, back on [Saturday Night Live]...?
Back when [Adam Sandler] was a regular cast member...?

He's like:
[Sandler]: You know what, dude...?

And then [Jon Stewart] was like:
[Stewart]: What, [Adam Sandler]...?

And then [Adam Sandler] was like:
[Sandler]: We're gonna talk about the fuckin' news today...

And then [Jon Stewart] was like:
[Stewart]: Oh really, we're gonna talk about the fuckin' news...?

And then [Adam Sandler]'s like:
[Sandler]: Yup.
           We're gonna fuckin' talk about the god damn news.
'@)

$Ctrl.X(0,"01:29:56","01:30:07", @'
:And then before you know it, like, they're talkin'- not only are they talkin' about the news, 
but they're like, ya know, like sayin':

[Stewart]: Some dude did this, and, holy shit.
           Everybody's just amazed by it, aren't they...?
'@)

$Ctrl.X(0,"01:30:07","01:30:19", @'
:And then they would, uh-
Ya know I can't really remember, like, that far back with the [Today (Daily) Show], but-
Eventually [Jon Stewart] was like:

[Stewart]: Ya know, we could really make somethin' outta this...
'@)

$Ctrl.X(0,"01:30:19","01:30:41", @'
:And then [Jon Stewart] was like:
[Stewart]: You know what I'm gonna fuckin' do...?

And then, uh- he answered his own question, he's like:
[Stewart]: I'm gonna fuckin' approach [Comedy Central]... 
           And what I'm gonna do, is, I'm-

And he started usin' his finger, to like, to tap do- to point down at the ground...
He's like:
[Stewart]: I'm gonna make my own fuckin' show on [Comedy Central],
           and it's gonna be the shit.
'@)

$Ctrl.X(0,"01:30:41","01:30:54", @'
:And then like, everybody was blown away, they're like:
[Everybody]: Whoa whoa whoa whoa, [Jon Stewart], chill out, dude...
             Don't need ta, don't need to fuckin' uh- like, ya know, act like [Tarzan]
             all of a sudden...
'@)

$Ctrl.X(0,"01:30:54","01:31:08", @'
:And then [Jon Stewart] would be like:
[Stewart]: Na na, I'm not actin' like fuckin' [Tarzan], nah...
           There's some real newsworthy shit goin' on, on this fuckin' mock news channel/show.

And then people were like:
[People]: Whoa.
          You're right there...
'@)

$Ctrl.X(0,"01:31:08","01:31:30", @'
:And then like, [Jon Stewart] started this whole, like uh- [expedition] into like, uhm-
[sort of mocking the news], not unlike how [Jay Leno] would do sometimes, or uh- 
[David Letterman], and uh- like uh- what's his name, uh... 
'@)

$Ctrl.X(0,"01:31:30","01:31:48", @'
:What the hell is uh- the guy's name on [TBS], I can't remember his god damn name...
Oh my god... [Conan O'Brian]...? Yeah, [Conan O'Brian], that's it.

Ya know...?
I can't believe I forgot his name for a second... Uh...
'@)

$Ctrl.X(0,"01:31:48","01:32:05", @'
:But these guys, like, they're like casual talkers, they're not gonna like come out with bits
that are [controversial] like I do, because [controversial] stuff is [very scary] to talk 
about in public, if you're [expecting people to like you].
'@)

$Ctrl.X(0,"01:32:05","01:32:31", @'
:But- um, ya know try to make [comparisons] between like uh- the [varying people] that I've
rattled off, um... [Jon Stewart] gave guys like [John Oliver], [Samantha Bee (girl)], and uh-
I don't think [Trevor Noah] was on the show all that early... but, maybe he was.
'@)

$Ctrl.X(0,"01:32:31","01:33:25", @'
:There's a- like uh- bunch of other people that've been on the [Daily Show], right...?
And like, [Stephen Colbert]...?

I think he was on the [Daily Show], and then he got his own show, [The Colbert Report].

And then you would have like, fuckin' [Jon Stewart], for like, a while, then you'd have
[Stephen Colbert], and they'd be like, doin' the fist bump between commercials n' shit.

And be like:
[Stewart]: Yo, take it- take it from here, [Stephen Colbert].

And then [Stephen Colbert] would come out with his fuckin' [Americone Dream], and be like:
[Colbert]: You know what, dude...?
           Fuckin'... [Stephen Colbert] show.
           What do you know about it...?

Have his ar- hands, outstretched and he'd be like:
[Colbert]: Ya know, uh- I'm god damn [Stephen fuckin' Colbert].
           And, I'm gonna talk about some shit.

And he'd adjust his glasses, and then uh- guys like [Jon Stewart (Oliver)]
were like:
[Oliver]: Pfft.
          I can do that shit too, dude.
          No problem.
'@)

$Ctrl.X(0,"01:33:25","01:33:34", @'
:And like, [Jon Stewart (Oliver)], he had to like, keep it inside for a while.
He's like:
[Oliver]: You know what...?
          This fuckin' [Colbert] dude...?
          Got his own show.

          What do I get...?
          Nothin' dude, what the fuck...?
'@)

$Ctrl.X(0,"01:33:34","01:34:05", @'
:But- then he was like:
[Oliver]: You know what I'm gonna do...?

And then [John Oliver], or [Jon Stewart] said to himself, uh, yeah, [John Oliver], 
not [Jon Stewart]...

[Jon Stewart], like uh- was like a [protege (mentor)] for these guys, right...?

And then, uh- [John Oliver] he's like, pointin' down, and he's like:
[Oliver]: You know what I'm gonna fuckin' do...?
          I'm gonna pull off [one of the most amazing fuckin' moves, in TV history...]
          I'm gonna confront [HBO].
'@)

$Ctrl.X(0,"01:34:05","01:34:33", @'
:And then [HBO] was like:
[HBO]: But we already have J- uh, [Bill Maher].
       And we had [Dennis Miller].
       We also had like, [Real Sports with Bryant Gumbel].

And like, [Bryant Gumbel] wasn't really like a [comedian], so much as like a:
[Gumbel]: Ya know, I'm a fuckin'... news like- uh, a [sports news anchor].
          Ya know, serious... as a fuckin' heart attack...
          I'm [Bryant Gumbel]
'@)

$Ctrl.X(0,"01:34:33","01:34:53", @'
:But, ya know, uh- ya know, [Bill Maher], he's like:
[Maher]: Well...?
         That's not a bad idea, because, ya know, what if...
         like, ya know, me AND [John Oliver] have the fuckin' the fist bump
         between commercial breaks, like... uh, [Jon Stewart] and uh-
         [Stephen Colbert] had...?
'@)

$Ctrl.X(0,"01:34:53","01:35:29", @'
:And then before you know it, like, [Jon Stewart], er- [John Oliver] has his own show.
[Last Week Tonight] on [HBO].

And then from that point forward, [John Oliver], took things to a totally new level, because
he had a lot more [freedom], with [what he could say]. He didn't have to worry about like, 
[casually uttering off swear words]... while pulling off, like, [one of the most controversial]
ways of [telling the news].
'@)

$Ctrl.X(0,"01:35:29","01:36:04", @'
:And then you had like [John Oliver], like basically [going around the world], and meeting
guys like [Edward Snowden] over in [Russia].

And then [Edward Snowden] would be like:
[Snowden]: Hey.

And then [John Oliver] would be like:
[Oliver]: Hey.

Then, they would say...
[Oliver]: Ya know, like, what is it that caused you, to wanna leak all of those documents,
          from the [National Security Agency], because, ya know, that was a very ballsy
          move, [Edward Snowden]...
'@)

$Ctrl.X(0,"01:36:04","01:36:20", @'
:And then [Edward Snowden], he's like:
[Snowden]: Well, ya know, Like uh- I saw you...?
           Like, ya know, on the [Today (Daily) Show],
           and I saw you struggling to make a name for yourself...
'@)

$Ctrl.X(0,"01:36:20","01:36:58", @'
:And then, uh- [John Oliver], he's like, listening to like his life story being told by
[Edward Snowden], and then [Edward Snowden]'s like:

[Snowden]: And, uh- what I realized was that, uh- 
           Our freedom's in jeopa-
           Our [freedoms], and [constitutional liberties], and [rights]...?
           [They're in jeopardy].

           And then like, I wanted to make sure that like, the next [John]-
           [John Oliver], would have a way to become [John Oliver], because,
           what I actually saw, was like...

           Some people were like, killing the idea of [comedy], AND, 
           people having, uh- [the ability to speak freely about the world], 
           and what's going on in it...
'@)

$Ctrl.X(0,"01:36:58","01:37:17", @'
:Ya know, like this whole situation with [Julien Assange] being in prison, over uh-
uh- what happened with uh- [Afghanistan war logs], and the [Iraq war logs], and
[Cablegate], and uh- [Collateral Murder], and uh- leaking [Vault 7]...
'@)

$Ctrl.X(0,"01:37:17","01:37:55", @'
:Y- all of these things, like- they're [very important].

Because, heh. 
What it says is that like, uhm, people like [John Oliver] are gonna be- the reason why they
are so [rare], is because of how hard people work against the idea of uh- [comedy].

Or making- [ridiculing], like [people in charge], or people that have a lot of [money], or 
people that have uh- a lot of [credibility], and then they- get their dick sucked by women 
like [Monica Lewinsky], and then they say:
[Clinton]: I never had sexual relations with that woman...?
'@)

$Ctrl.X(0,"01:37:55","01:38:17", @'
:And then people are like "Wow"...

Fuckin' president like- [avoided being impeached] for like, [lying to people] and like, 
ya know, his [wife] will [later] be able to get away with [leaking classified documents],
and then [Julien Assange] will get [(175) years] in prison for basically uh- 
ya know, uh-
'@)

$Ctrl.X(0,"01:38:17","01:38:17", @'
:Doing something very similar to what [Edward Snowden] did, right...?
So, I'll tell ya, here's what it all comes down to, is this.

Ya know, uh- [bravery], uh- changes, from uh- [perspective] to [perspective], but-
'@)

$Ctrl.X(0,"01:38:17","01:38:57", @'
:[George Carlin] was brave in the sense that like, he- he knew that what he was doing, was 
not much different than what, uh, [Benjamin Franklin] and the other [founding fathers] did.

And what I'm doing is not much different from what the [founding fathers] did, and even 
though I said that I was gonna end the [audio log], a while ago...?
'@)

$Ctrl.X(0,"01:38:57","01:39:14", @'
:I kept going with it, because... I found something that [inspired] me to talk about
something [interesting], in real life, and [tangential]...

I've covered a number of [subjects]...
I've covered a number of [people]...
I've also, recalled a bunch of [ideas] that I've had...?
'@)

$Ctrl.X(0,"01:39:14","01:39:29", @'
:And, uh- ya know, where I am standing right now, is where [Tailgators] used to be.

It's not [Tailgators] anymore, it's [Saigon Spring].

It's a [Vietnamese] restaurant.
'@)

$Ctrl.X(0,"01:39:29","01:39:55", @'
:Back in like, (2008)...?

And I think (2012), me and my friends, like, were at this bar...
And uh- we just had a lot of fun, watchin' the [Giants] beat the [New England Patriots].

And uh- ya know...?
That was like...
'@)

$Ctrl.X(0,"01:39:55","01:40:35", @'
:I dunno, like fuckin' (10) years ago. 
(10) to (15) years ago.

Ya know...?
A lot has changed in the last (10-15) years, but what I can say, is that...
Over the last (10) to (15) years, it went from like... uh...

Being a- the... 
[Today (Daily) Show] and the [Colbert Report] on [Comedy Central], to like, uh...
[John Stewart (Oliver)] on [Last Week Tonight] on [HBO].

And, ya know, talking about like, varying degrees of like, uh...
'@)

$Ctrl.X(0,"01:40:35","01:40:51", @'
:[Atrocities unfolding].

And like, it all boil- like si- simply put, uh- basically [every single story], or seemingly
[every single story] that, uh- [John Oliver] talks about on [Last Week Tonight]...?
'@)

$Ctrl.X(0,"01:40:51","01:41:14", @'
:Has to do, with... some people doin' some [real evil shit].
And, a lot of times, it boils right down to [money].

But- ya know, what causes it to be such an [evil thing], is the fact that...
[A lot of people just continue to let this shit happen]...
...and they like, [think that it's normal].
'@)

$Ctrl.X(0,"01:41:14","01:41:37", @'
:Right...? So like, uh- [Wrongful Convictions], and uh- uh- like uh- [Interrogations]...?

Uh- are a [couple of topics] that he has taken on over the [last year], and uh-
A lot of that stuff is covered on [Audit the Audit].
'@)

$Ctrl.X(0,"01:41:37","01:41:50", @'
:Right, and I don't wanna say that like, [every interaction] that's [recorded] on [video],
gets to be shown on [Audit the Audit], right- this, whoever that dude is from 
[Audit the Audit]...?
'@)

$Ctrl.X(0,"01:41:50","01:42:10", @'
:He is, raking in [a LOT of views].
He is raking in [a lot of views]...?
A lot of-

He's making a lot of [content]...?
And mainly because he's probably bombarded with [so many examples], of like, cops doing
[stupid fuckin' shit] on like a [daily basis]...?
'@)

$Ctrl.X(0,"01:42:10","01:42:34", @'
:That he's got a full-time job.
[He's never gonna be able to keep up with all it, either].
Nah.

So, that is the reason why I started making this [recording], actually, is because like-
even with uh- the [amount of time] that I have to [focus] on the things that I think are 
most important, like I'm not gonna be able to keep up with [every single story] that I wanna
keep up with.
'@)

$Ctrl.X(0,"01:42:34","01:42:54", @'
:And the- like, it will derive a [sense of bias]...

Whether, uh- like, it's a good [sense of bias] or not...?

Ya know, I think it really depends on like, who is, [who] is able to [make that judgement]...?
Or whatever...?
Right...?
'@)

$Ctrl.X(0,"01:42:54","01:43:10", @'
:[Bias] can be [good] or [bad], but typically, uhm, when [bias] is the same- like, resorts to
like [prejudice]...? 
Or it resorts to uh- like, uh- I dunno, [slavery]...? 
Or uh, [discrimination]...?
Or...
'@)

$Ctrl.X(0,"01:43:10","01:43:27", @'
:I dunno.
I really am kinda reachin' for uh- somethin' to close this out now,
because I sorta [lost my pacing]. But uh- [consider this].
'@)

$Ctrl.X(0,"01:43:27","01:44:14", @'
:What is it that REALLY got [Julien Assange] thrown in prison...?

Well, I will tell you, uh-

I think that what really got [Julien Assange] thrown in prison...
Are a [bunch of fuckin' morons] that have [control of society]...

And, they have like, caused [so many people] in society to become like, [numb] and like, uh-
[indifferent] to the amount, or [varying degrees of control] that [certain people] have.

And this [level of control is rather hidden], right...?
It's like...
'@)

$Ctrl.X(0,"01:44:14","01:44:36", @'
:Uh- it's [caused by people being in denial], but further to that point...

It's ALSO caused by like, just people [expecting] things to be, ya know, like the same
thing as they were. So like, take this into consideration...
'@)

$Ctrl.X(0,"01:44:36","01:44:46", @'
:A lot of people, they go and [watch movies] at the [movie theater] and stuff, right...?
And then they'll see like a [brand-new movie]...?

They'll be like "Oh, that movie is really cool..."
'@)

$Ctrl.X(0,"01:44:46","01:45:05", @'
:Like, when I saw this fuckin' like, uh- [Batman] movie, like uh- last month or whatever, 
uh- [Christopher Nolan]'s [Batman] movies were awesome.

And I think it's gonna be [REALLY DIFFICULT], to pull off a [convincing upgrade] over those
films.
'@)

$Ctrl.X(0,"01:45:05","01:45:38", @'
:And the reason being, is because [Christopher Nolan] is a fucking [great director].

He was great with [Interstellar], he was great with [Inception], and I'm pretty sure, 
that the dude, [wrote a lot].

Uh- and then like, ya know, [James Cameron].

Is also like a [really good director].
Ya know...?

For what it's worth, like the guys at [Marvel] that take inspiration from [Stan Lee]...?
[Stan Lee] was a great director, too.
Great storyteller.
Ya know...?
'@)

$Ctrl.X(0,"01:45:38","01:46:00", @'
:Uhm, [all these stories] sorta boil down to uh- ya know, there- there's fuckin' [evil] out
there [already], [currently]... You know, talking about the [evil], is, [dangerous], because...

The [evil] will be like "Well, it's just your [opinion] that I'm [evil]..."
And then they'll have you thrown in jail, like [Julien Assange] for (175) years.
'@)

$Ctrl.X(0,"01:46:00","01:46:16", @'
:Or, they'll just fuckin' put ya on a [blacklist], and then you're not allowed to say
nothin' to nobody... Nah, no nothin', dude.

Nah, everybody else gets- like, rights and stuff...?
Except you.

You get nothin'.
No nothin'.
'@)

$Ctrl.X(0,"01:46:16","01:46:35", @'
:Ya know, I keep thinkin' about this like uh- hash tag campaign.
#NoNothin'

Most people get somethin'...?
But you get #NoNothin'
#NoNothin' for the win.

Ya know, not unlike #TopDeckAwareness.
'@)

$Ctrl.X(0,"01:46:35","01:46:45", @'
:#TopDeckAwareness
'@)

$Ctrl.X(0,"01:46:45","01:46:51", @'
:End log.
'@)
