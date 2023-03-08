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
                $Out.Add($Out.Count," ".PadLeft(116," "))
                $Line = "[Url]: {0}" -f $Item.Url

                $Out.Add($Out.Count,$Line)
                $Out.Add($Out.Count," ".PadLeft(116," "))
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
                    $Out.Add($Out.Count," ".PadRight(116," "))

                    ForEach ($Slice in $Content)
                    {
                        $Out.Add($Out.Count,"    $Slice")
                    }

                    $Out.Add($Out.Count," ".PadRight(116," "))
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

                $Out.Add($Out.Count," ".PadRight(116," "))
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

0:00
Audio log Tuesday March 7th 2023, Michael Cook speaking it is currently 2:38 PM
I'm makin this audio log to talk about, uh-

0:20
What it- what- the ideas that I choose to talk about...?

The topics of discussion and whatnot...?

And uh- the amoiunt content that I COULD be creating if I could keep up with it.

0:37
The way I see it is like this...
If I make an audio recording like this...?
And... I wanna make a video out of the audio recording that I made...?

Well, I have to have a pretty good understanding of what it is that I wanna talk about
BEFORE I start making the audio recording...

0:54
Right...? But then also, I have to transcribe it and then like spend time translating
everything so that it ya know, mee- it meets a certain standard criteria, or something
to that effect.

Right...? So like, uh-
Sometimes I'll realize that uh- I'm rushing to do something.
And then rushing to do something is gonna generate a rushed result.

1:22
Ya know, most people don't realize like, what does it take to uh-

When someone records a video and it goes viral...?
What is it that causes it to go viral...?

Well I'll tell you there are a number of factors, but typically viral videos...?
They're unexpected and they're spontaneous.

1:42
Whereas, the content that I produce...?
Sometimes it IS spontaneous, but it's also like uh-
...my ability to predict other people's behaviors, and then to capture it.

1:57
So I predict the behaviors, right...?
Because like, I'm not recording things on a constant basis.
I don't record every like every second of my life, and anything that I DO record...? 
I'm gonna have a sense of bias over what I'm gonna wanna show other people, 
or what I won't want to show to other people.

It doesn't matter who you are, you're gonna have a sense of bias.

2:21
So, being able to accurately uh- define like, what matters most to ME...?
People are gonna have an easier time, uh- if- if they see a number of exhibits
or uh... subjects and contents, they are able to see like an outline of how I 
think and how I shape things, right...?

2:53
And that I can explain it so that other people can ALSO do this.
I'm gonna start to come off a lot like George Carlin, but- ya know, he- he did
what he did for many, many years, and uh- I've been doin' this for a few years,
but not nearly as long as he had. 

3:17
Some of these, uh- comedians that go uh- on stage and they sound more of a philosopher
than just a uh- comedian...?

They develop a sense of uh- what people are gonna wanna hear...?
What's funny...?
And uh- you know, I think of funny things on a constant basis.

3:38
The thing is I have to cherry pick the things that OTHER people are gonna understand, 
and elaborate on them, and uh- it's really not... that easy, because I have to work
really hard to focus on the things that ARE worthy of attention, because, is someone
gonna wanna see a video of me takin' a poop...?

4:06
Probably not, right...?
I think everybody takes a poop.
It's not gonna be fun, for anybody else, to see me sittin' on a toilet takin' a poop.
Scrollin' through like, ya know, like uh- news feed or somethin', right...?

4:23
Fact of the matter is that some people...?
They can make that entertaining.

Ya know...?
[Somebody]: There's somebody takin' a poop.
            Uh- dude was takin' a poop for the last (5) minutes...?
            And it happens to be the coolest dude that ever lived...
            And the name of this whole scene, or skit, is
            "The coolest man who ever lived, taking the coolest poop that anyone ever took..."

4:53
And, uh... ya know...? Holy shit.
Yeah, it's- a little- it's-
It's sorta windy right now...?
It's not THAT windy...?
But- it's windy enough where uh- I know that uh- it's prolly gonna-
Uh- ah- uh- disrupt what I'm recording...

5:16
So there are days where uh- like, I struggle to uh- stay on point on task, and whatnot,
and uh- 

5:27
It's been a few days since I like, hunkered down and made a recording where...
...like it sounded productive, and much less, uh- like uh, I dunno, like a mind dump...?

5:39
Ya know, uh- not every one of my recordings is gonna be all that well received, right...?
That's like, what I mean by this sense of bias, and everybody exhibiting it to some extent.

5:53
Right...? When a girl...? Like- like, uh- news anchor Julie Chapman from Spectrum One, the
Spectrum News One, or, uh- I dont' remember exactly what the hell it's called...

Spectrum News.
Right...?
She has been workin' at this place for like, I think like (15) years or so...
Right...?

6:13
[Chapman]: Spectrum News, starring Julie Chapman.
           Julie Chapman...?
           Reporting to you...
           I'm Julie Chapman, and uh- 
           Today...?
           We're gonna talk about how Andrew Cuomo, sexually harassed, (11) of his aides...?
           And a whole bunch of people just, let it happen.

6:39
And, uh- ya know...
Andy Cuomo DID have a really, uh- big involvement in like, Spectrum News.

Or not Spectrum News, but like, I dunno, Spectrum in general...?

6:53
Uh- Spectrum used to be Time Warner Cable.

And then at SOME point along the way, they decided to sell out.
And... ya know, from that point forward...?
It's just been kinda like a, large conglomerate corporation of...
like... I dunno.

7:17
I really don't know how to describe it better than like, uh- 
it's basically the same thing as Comcast. Or ya know, uh- Cox.
Or, uh... I can't really think of uh- the others...

7:34
And I'm not feelin' all THAT super focused right now...?
But- I am sorta forcing myself to uh- record this.

7:44
The concepts that I wanted to talk about in the very beginning of the recording, uhm-
are the uh- the fact that I can create a lot of content, and uh- even if I am gonna
try to show, or focus on my best work...?

8:00
I STILL get overwhelmed by the amount of content that uh- occurs. Or, I can record.
Someitmes.
Sometimes what'll happen is, I'll record something...?
And then I'll need a few days, to like, get ALL of the things, in what I recorded,
documented, and then re-recorded with uh- wrapper.

8:21
And so like uh- these are the things that I start to uh- like uh- conceptualize, 
ways of telling a story. Or retelling a story, or... Ya know, these uh- these ideas
they're not intuitive... 

I'm certain that like broadcast media, they get into the nitty gritty of how to tell a story.
And so do the news agencies. 

8:48
But I think what winds up happening, is that- they just wind up doing what someone else
is doing, and then like, before you know it, the- every- everybody's like, copying each
other. 

9:00
And it's, very rarely that you get like, original works.
And even if you DO get original works, is it entertaining...?
Is it educational...?

Ya know, these are the things that I ask myself on a constant basis whenever I'm making
these things, if someone is gonna listen to this, and find it educational, and uh-
provocative, and interesting... and uh- can I keep myself, like on the level, can I keep
a cool head, a cool level head...?

9:27
Can I also uhm, come across as somebody who's historically done a pretty good job over
the years, like uh- Howard Stern, or uh Imus, or George Carlin, or Louis C.K....?

Does anyone out there think that uh- these guys, they just like, woke up one day, and 
they were like:
[Them]: You know what...?
        I'm gonna fuckin', do some cool shit...
        I'm gonna tell some stories like no one else ever did in history...

10:02
Yeah, well, I'm sure it did happen after many days of working at it.
Right...? So...

Some of the things that I notice, are uh- indicators, in the environment, or like 
just things kinda pointing me in the right direction.

10:17
And often times like uh- people, they uh- will uh- judge me based on my appearance, rather
than uh, like uh- the things that I'm talking about, or whatever.

10:29
Right...? And even if I'm like, out in public and people can see and hear me talk...?
Very rarely will someone think to like, ever engage themselves in what I'm talking about.

10:40
I think its... I think it's a daunting concept, and a daunting task to take on, because,
ya know, uhm... Typically you would wanna have a conversation with somebody, about some
of this stuff, you're not gonna wanna, like uh- like uh-

[Somebody] : Hey, sorry to interrupt you, like I see that you were like uh-
             You know, havin' this conversation amongst yourself...
[Me]       : Oh, oh, I WAS havin' a conversation amongst myself, but it's a LECTURE.

11:07
And then the other person will be like:
[Somebody] : Well, uh-
             I would like to take part of this lecture of yours...

And then the other- and then I would say:
[Me]       : Well...
             You wanna take part of the lecture, what do you...
             What sort of questions (do you want to ask) or statements do you wanna make...?

11:22
And then the person will be like:
[Somebody] : Well, you said somethin' about, like...
             making something really cool and original...?
I'm like:
[Me]       : Yup.

11:29
And then they'll say:
[Somebody] : Well, what is it that you're...
             How do you do it...?
             Do you like, start out wiht like uh-
             like a video game, or somethin'...?
             Or do you go to like a toy store, and buy a, like a board game...?

11:47
And then I say:
[Me]       : Well, uh- i- if you wanna focus on something like THAT, sure.
             You can.
             I guess what it really comes down to, is uh-
             Are you putting your own personality into something, in order to tell
             other people about that game...?
             Or...
             Are you doing something that someone else, like expected and predicted that
             you would do, and uh- created everything along the way to be like uh-
             [Manufacturing Consent], by Noam Chomsky...?

12:22
You're manufacturing a whole bunch of things, so that people think the way that you 
want them to, or they rea- they have opinions that you want them to have, or a shared
opinion, and uh- ya know, focus on the key details, be very concise, don't ya know, uh-
explain the whole entire story...? You wanna explain portions of it, because...

12:46
People, we want people to think that like, telling the whole story...?
It's stupid. Even though, it's VERY INTERSTING when, someone decides- decides to start
telling like a story in an interesting way.

13:00
Ya know, like uh-
You tell an interesting story, you start to say things, and then uh- people, they pay 
attention to the details. They're not gonna gloss over the details or nothin' like that,
they're gonna listen, they're gonna pay attention, they're gonna ask questions and before
you know it...

13:18
You're gonna get to the point where... you start to develop uh- bullet points, and then
you talk about the bullet points, and you expand upon each bullet point, and... as long
as you remember the bullet points and you circle back...?

Then uh- then you're able to keep the conversation, or the discussion flowing.

13:38
See, right now, I'm sorta doing the same thing as freestyling...?
But, because I've done this so often, that- I uh- I have an idea, of how to explain
my thought process.

13:52
Other people, they're not gonna have an understanding of how to DO this...
unless they PRACTICE it, and, I'm warming up.

So, it's not unlike when I would pick up a guitar...?
And I'd start playing around on the neck...?
And then uh playing scales and stuff...?
Scales would be a great way to start out, but then like, maybe I'll start out with a song...?
And then I'd start playing the song...?
And after a while, people would be like...
[Person] : Hey, uh- 
           You've been playin' that song for a while...
           ...and it's really loud.

14:19
And I would say:
[Me]     : Yeh, I only play my music really loud.
           It's sorta like uh- like uh- I have to play it at like, the maximum volume.
And like:
[Person] : Yeah, well you got the volume all the way up.
           Whaddya got, it up to 10...?
And I'd be like:
[Me]     : Nah, I got it up to 11.
They'll be like:
[Person] : I didn't know that an amplifier could go up to 11...
And then I would say:
[Me]     : Well, you've never seen Spinal Tap, have you...?
And they'll be like:
[Person] : No no no, I haven't seen Spinal Tap, what's that...? What's that...?

14:46
And then I'd say:
[Me]     : Well, Spinal Tap, uh...
           They say...
           "Turn it up to 11, because it's louder than 10."
And they'll be like:
[Person] : Oh.
           Well, that's dumb.

14:58
A lot of people WILL actually say something like:
[Person] : Well, that's dumb.
           You know...?
           11 IS like uh- higher than 10...?
           But...

15:07
The idea there, is being original.
Right...?

Originality, I guess may be a good way to put it.
But, you know, I'm sorta meandering into different topics, and uh- straying from
the original reason I began to record this.

15:27
Which was to talk about... uh, the amount of content that, I can produce.
Is overwhelming.
And then to be able to like, translate it. To uh- 

I dunno, like a video or an audio recording or whatever...?

15:46
Right, and sometimes I'll need a few attempts throughout a day, to like uh- get
back into the... into the rhythm. Right...?

15:58
Sometimes, uh- I'll be forcing myself to talk about whatever I can, and trying to stick
to a certain topic, which- I'm doing right now... but that's mainly because, well
I'm in a different setting than I normally am...? Or, I'm not very engaged in what I'm
talking about...?

16:17
And the topic that I'm tryin' to talk about, is pretty difficult.
But uhm, allow me to resort to observations.

These uh- key strategies, that I've been uh- kind of developing, and uh- ya know, these
strategies...? Uh, they don't need to be in order...

16:36
But these strategies, uh- someone has made it very clear to me, that like, they DO think
that I'm a rather intelligent person, they DO think I'm funny and comedic, but there
are some things that might say or do that worries them. And, uh-

16:52
This, happens to other people as well.
And I think that uh, generally speaking, like, most people, aren't as intelligent as I am,
and I'm not saying that to insult people I'm saying it because a lot of people that you'll
run into in society...

17:10
They're not gonna like, think about things in a deeper manner. Or like, the philosophical
implications, so like a great way to showcase this, specifically is, number 1, uh- seeing is
believing. But appearances can be deceiving. 

17:30
I wrote about, uh- I wrote a document about uh- Tropic Thunder, a few days ago, or maybe
last week... uh, and- when I wrote this document, I talked about uh- the skit, 
[The Dudes Are Emerging]
[https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0225-(TropicThunder).pdf]

17:50
So in this skit, the dudes are emerging, in the movie, uh- Tropic Thunder, what happens
is uh- [Robert Downey Jr.] plays uh- this uh- dude, uh- [Kirk Lazerus] and then he gets
a skin pigmentation, uh- operation to play as [Lincoln Osiris] in the movie, uh-
[Tropic Thunder].

18:23
And then there's this like, disclaimer, in the movie, it's like- 
[Disclaimer]: Winning an Academy Award for telling the most true story, about the 
              fake-true war story ever, the most fake-true war story in existence....
              Tropic Thunder.

18:24
And then they like, they try to get the whole uh- like uh- Forest Gump, Vietnam vibe,
when like, Forest Gump is like, flying in on a helicopter, and he meets Lieutenant Dan...?
And it's like...

19:02
They're trying to get that feel into the movie...
Uh- but- it comes up a little bit short.
But that's ok, because the movie is actually pretty funny...?
It's just uh- I think that the part where the dudes are emerging, is basically
the climax of the film.

19:24
So, the dudes are emerging, is basically when uh- [Robert Downey Jr.], his character,
he's like, tryin' to like uh- rescue, uh- [Ben Stiller]'s character, and he's like...

19:43
[Blackface]: I'm a dude playin' a dude, disguised as another dude.
             I know what dude I am...
[Speedman] : Or, ARE you a dude, that claims to know what dude he is,
             by playing other dudes...?

19:57
And then like, uh- [Jack Black], his character, he's like:
[Portnoy]: What the fuck are you guys talking about...?

Cause basically, like the conversation that they're having...?
It SOUNDS like they're both delusional.

20:10
But the fact of the matter, is that the words are incredibly simple, and uh-
most people in society, they're gonna HEAR something like that, they're just
gonna start laughing because it sounds ridiculous, but- there's a reason WHY
things that sound ridiculous are funny, and they cause people to laugh.

Right...?

20:27
So, uh- about a month or two ago, I went to uh- this place, and this guy
started like, talking like uh- like a nervous wreck, he's like worried about
ju-ju spirits in the church or whatever...?

20:43
Ya know, and you know, they used to sacrifice people here, and they like, they probably
STILL do...?

I dunno, he was sayin' a bunch of stuff that like sounded comedic...?
But- the amount of it, or the intensity of it caused uh- everybody to think:
[Everybody]: Wow, this dude's, is like, a nut job.

Right...?

21:02
So there's a difference betwene like uh- pacing.
The pacing of how I talk, right now, in this recording...?

It's very uh- grounded, and I would say that uh- few people are able to pull off, uh-
speaking the way that I am right now, and uh- this is all dynamic, this is all like,
off the cuff. It's not like, uh- I have a script to read from as I'm making these
things, it's literally like, I'm comin' up with it all off the top of my head.

21:37
And, because of how often I practice this, sometimes I will get into a groove and a
rhythm, like, by forcing myself to do it.

Right...? Not unlike how like sometimes I would... start to practice, my guitar, and
then I would keep practicing my guitar...?
I would get to a point where I was warmed up, and would continue to keep going, right...?

22:03
But, um, then I would have to res- re- rely on uh- differing strategies, to continue
playing the guitar, and what I'm doing right now isn't much different, but...

22:14
The strategy that I'm using right now, well I'm using MULTIPLE strategies, but the
MAIN strategy that I'm using right now, is [improvisation].

22:24
[Improv], uh- [improvisation].
So, there's a show called "Who's Line Is It, Anyway...?" starring like uh-
Colin Mockery, uh the other guy from the Drew Carey show, Drew Carey, sometimes he
will uh- act it out...? On the show...? It's very rare, though.

22:44
Uh, and then uh Wayne Brady. And they've stuck with that for a while, they have some
other guy, that uh, comes on every once in a while, uh, a FEW other guys, but they
have like their main crew. Of uh- these guys that seem to have [improvisation] down
pat.

23:06
Now, like uh- the type of comedian that uh- they are, is basically stage acting, and
[improvisation], but uh- ya know, like a comedian like Louis C.K...?

He's gonna have a skit prepare AHEAD of time, and he's gonna talk about his observations, 
and he's gonna in- inject some of like, HIS perceptions. Same goes with like, the other
actors, the other comedians that I talk about a lot, too.

23:35
They're gonna talk about, like, uh... you know, uh... 
Louis C.K. has a skit where like, somebod- they're stuck in a traffic jam.
Right...?

And then, uh, some guy is like, layin' on his horn, he's like:
[Some guy]: GooooOOooOOO~!
            Go~!

Right...?
There's a guy behind Louis C.K., in another car. And like, he's just layin' on the horn~!

23:59
And then like, uh- Louis C.K., he's- he's using his like hands, he's like:
[Louis C.K.]: *using hands* I can't go.
              I literally cannot go.
              ehhh... whaddya want me to do...?

And then like, the person behind him is just like:
[Some guy]: Just go~!

Ya know...?
And then, uh- I guess at some point, like, the guy like, gets out of his car, and he's like,
and then he rushes up to like, [Louis C.K.]'s car, and [Louis C.K.] rolls the window up.

24:27
He's like:
[Louis C.K.]: Ah, nah, not gonna take part of this abuse here...?
              Nah, gonna be like, I'm takin' part of this, whole charade here...?
              Nah, I don't think so, dude.

So he rolls the window, up.

24:41
And then the guy's like:
[Some guy]: Hey you~!

And then like, he's like pretendin' like...
Ehh, he knows he's there, but he's tryin' to like, [avoid the confrontation].

24:51
Right...?
And so like, this is a human- natural human instinct, right...?
Where somebody's pissed off, and like, people they're kinda like terrified or scared, or
something, or they just don't wanna have a conversation with somebody, it's not a
comfortable situation.

25:05
So... Uh... at SOME point, he's like:
[Louis C.K.]: I'm not gonna have this, this guys' argument, here...
              If I'm gonna have an argument with him, I'm gonna have MY argument.

He's like:
[Louis C.K.]: I want my JACKET back~!
And then the guy's like:
[Some guy]: What the...
            What jacket...?
[Louis C.K.]: I want it back, now~!
              Give me back my jacket~!

25:29
And then what this is, is... [distraction].
Right...?

It's a [distraction] because like, when people are like, [distracted], it causes
them to lose their [footing] or their [balance], right...? And uh- ya know, the
WIND right now is distracting me, and that's why I'm sorta confined to a certain
area where I don't typically talk out loud.

25:51
But uh- ya know, the [distraction] in that scene, is, uh-
"Give me back my jacket", "I want my jacket back"...

and it caused the dude that he was worried about having a conversation with, to
like, lose his footing sort of be like "What the hell...?"

26:09
So like, the roles reverse, he's like:
[Some guy]: Wow, this dude's like psycho or somethin'...
            ...he's tellin' me he wants his jacket back...?
            What the hell...?

26:17
And then so like the dude who like originally got out of his car, and started like,
like, uh- gettin' pissed at Louis C.K., he's like:
[Some guy]: What the fuck is up with this dude...?

26:29
And then like, it works.
It really does.
It's something that people can use in real life, for a varying degree of things.
Right...?

26:40
Ya know, uh- 
I was gonna make another joke about [Andrew Cuomo], but I think I've made enough
jokes about him, I was gonna say, if he wants to like distract, like, some girls
or somethin', he could like, try to whip his dick out.

27:07
Right...?
And then the girls will be like:
[Girls]: Na na na, I'm- we're all set.
         Thanks, though.

27:14
And then uh- [Andrew Cuomo] will be like:
[A.C.] : You sure...?
         Sure about that...?
         I mean, fuckin'... look at this thing.
And then the girls will be like:
[Girls]: Na na na, don't wanna look at it.
         Ya know...?
         It's fuckin'...

27:28
This happened to him about (11) times. Ya know...?
Louis C.K., he had a situation where he was, about to release his movie, uh-
I forget what it was called, I think it was "I Love You, Daddy"...?

Uh- and uh, ya know, he's the director, he's a good director, and uh- 
somebody decided to like, take a huge dump, all over what he had planned..
and they talked about how like he was like crankin' on his pud,
around a couple of uh- female colleages.

28:07
Ya know, no- nobody... said nobody-
nothin' to nobody, like up until that movie was about to be released...?
And then Louis C.K. lost out, big time.
And uh- that's a tragedy, cause I don't like...

28:24
I've made many comparisons between [Louis C.K.] and [Andrew Cuomo], before.
Right...

[Andrew Cuomo]...? He is not gonna admit a god damn thing, because that's
what politicians do...? Or at least what they tend to do...?

It's not a consistent case...?
Right...? But like...

28:43
Ya know, [Louis C.K.], he's like 
[Louis C.K.]: Yeah, I did.
              Ya know, I'm not gonna like, lie about what happened...
              Ya know, I asked they were like "Sure, ok..."

Right...?
At least in HIS case...?
They facetiously or sarcastically said ok, and then he just did it.

28:58
In [Andrew Cuomo]'s case, it was a flat out fuckin' "No, dude... All set."
(11) girls. They all said "No."

And uh, somehow, ya know, he just kept doin' it, he's Like:
[A.C.]: Well, fuckin' try as I might...

29:16
Anyway, uh- that's another strategy, sorta like bringing back, uh- bullet points from the
past that I've like written about, uh- written material, that's pretty good...

Material that I've written, sometimes when I write about something a number of times, I
will remember it...? It'll make it easier for me to remember all the details, sorta like
I just did...? I rattled off that story.

29:44
You'll never catch uh- a guy like George Pataki, gettin' caught in a situation like that.
Not at all. Uh- nah, George Pataki was the governor like the entire time that I went to
Shenendehowa School District, and it's like uh- 

Or no, I think it was like 1992, to 2006...
Yeah and then Eliot Spitzer became the governor.

30:14
Anyway, uh- what else could I use, what other strategies could I use...
It is sorta windy right now, I could talk about the weather...

I could talk about global warming...
I could talk about 250 mile tornado tracks... record.
F4 tornado leavin' behind a 253 mile tornado track, or maybe, uh- it might've been more
or less... 250 miles for a tornado to go is pretty staggering, but then also you've
got these hurricanes that are showin' up and then you've got the, the floods goin' on
over... uh- down south, and then you have like uh- the uh-

31:00
There really is a shit show, when it comes to the weather, and uh-
[climate change] is [definitely real], but- like, part of what the news DOES, is like,
they basically do the same thing as someone who sits in a room and farts all the time,
and just sprays potpourri or like air freshener.

31:29
Like: 
[News]: Oh wow, oh no.
        Nobody's fartin' in here, smells like vanilla.
        Or uh- ya know, tropical flowers, or blossoms.
        Ya know...?
        There is nothing disgusting smelling in here.
        Not at all.

31:46
And that is sort of like the reason why global warming is as bad as it is.
I'm using a metaphor right there, I'm using [literary devices]. Ya know, a lot
of people, they will assume that like, what I'm sayin' is babbledy-gook.

32:01
Right...? In many cases, some people will do that.
They will say:
[People]: What that dude is sayin'...?
          Is fuckin' babbledy-fuckin'-gook.
          He is makin' NO fuckin' sense, whatsoever.
          He's talkin' about like, the news...?
          Basically like, sittin' in a room...?
          And, chain fartin'...?
          And then like, every time they rip a fuckin' smelly-ass fart...?
          They gotta like, spray the air freshener.
          That's...
          That's what he's sayin'...

32:34
Of course, some people will take what I'm saying a little too [literally]...
which is why there are [literary devices].

[Literary devices] are like uh- [metaphors] or [similies], ya know, using 
[like] or [as]...? [Metaphors]...? 

32:53
Uh- and then uh- also, like [hyperbole]...?
Basically an exaggeration of what's going on...?

So like, there might've been about (10) people, like, at a store that I was just at...?
But the [way] that they were like, like, frantically looking for the things they were
trying to buy...? They were- it- they- it act- it almost felt like there were about 
(100) of em, in there.

Right...? So, that's an exaggeration...

33:20
But then there's also, it works in the other way, where like uh- [Louis C.K.] also, 
he's says like uh, ya know, uh- most of the people in the world, probably sucked a dick
at some point...? Ya know...? Like, basically half the population sucks, like, sucks
a dick (cause they're females), sucks dick... and then uh- ya know...? And then there's
guys that are FORCED to suck a dick... Right...? And then, uh- ya know...? There's
gotta be like (10) of us out there, somewhere, that have never sucked a dick before...?

33:54
Right...? So like, there's 7.5 billion people on the planet, or, maybe more or less.
I can't remember the exact number, but- ya know, uh- it works in the other way, where
you're making sheer exaggeration, that's a hyperbole, but- instead of uh- making
something sound MORE [intense], you make it seem much more [miniscule], and then uh-
it's the [same technique], but...

34:27
Typically when people say [exaggerations], they're not thinking like uh- like turning
(1) into (10)... Uh- they're thinking (1) into (10), not (10) into (1).

34:41
Though, it's not a consistent case.
Uhm, and then also, uh- another strategy would be, umh, well observations are f- a 
strategic, uh- pretty strategic choice. 

35:00
So right now, like, I'm at a plaza.
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

35:29
And uh- ya know...?
What the hell...?
Uh- she's puttin' her seatbelt on...
Uh- she's... puttin' her seatbelt on after adjusting her glasses...?
Right...?

35:41
And uh...
Uh- there's another car comin'...
It's passin' the girl in the truck.
It's uh- Acura. SUV. MDX.
I'm not gonna read off the license plate.

35:57
Uh- that, uh- Acura is taking a left out of the plaza.
The girl in the truck, has not gone anywhere yet.
She's fixin' her hair...
Uh- some lady came out, she's gettin' into her (4) door Honda Civic...?
(2) other ladies comin' out from the other side of the plaza...?

36:18
Uh, that girl in the red truck hasn't gone anywhere...?
The lady with the Civic, she just shut her door...?
She is... sorta doin' the same maneuver that the girl in the truck was doin'.
She's puttin' her seatbelt on...?
And adjusted, ready to leave...?
Uh- some dude walked out, of the other side of the plaza.
He's gettin' in HIS car, it's like a white uh, like Subaru somethin'.

36:41
Or maybe it's...? I dunno.
The (2) ladies are walkin' to another store, they're not leavin'.
The red- the girl in the red truck, she's got a cigarette, she's opened her window a
little bit...? She's lighting her cigarette, and the other lady in the blue civic, she
is puttin' her seatbelt on...?

37:00
And, uh- Uh- the girl in the red truck...? She is drivin' off, now...
She has no fuckin' clue, that I just narrated everything that she did.

That's ok.
Ya know...?
The dude in the white- Toyota somethin', he's pullin' out at the same time as this
lady in the blue Civic, and the lady in the blue Civic, she is just bein' very attentive
to detail...?
Red truck just turned right out of the plaza...?
Uh- the Civic, the lady in the Civic, she's drivin' like a grandma...?
And, the dude in the Toyota RAV4... the white Toyota RAV4, he's...
They're basically goin' the same direction.

37:40
I don't think that they're together, but they're both turnin' right, basically.
There was a r- there was a black car that pulled into the plaza as I was narrating
all that, the blue Civic and the white Toyota...? They're gone now.

They turned right out of the plaza.

37:58
And then, there's like a dark blue uh- Chevy somethin'.
Chevy Aveo, or whatever.
And it's- another older lady.

38:13
She's got a hat on...?
It looks like a tophat...?
It looks like an englishman tophat.
Like, what Charlie Chaplin would wear.
And, uh...

38:26
Ya know, she's like waddling to the other side of the plaza...?
She... is walking into a store...?

And short people, they look a lot like they're waddling when they walk...?
Cause they have to like, I dunno.
I think of how like they're gnomes.

38:49
See, there's nobody like within eye- uh- there's nobody that I can see who's like 
walking around right now, or drivin' around in the plaza...?

There's a bunch of cars drivin' around on Route 9, but-
Ya know, uh...

39:00
It's too many details for me to be able to narrate, and, further to that point, Uh-
if I don't make what I'm doing, sounding interesting, see, I'm sorta like, getting
into the swing of things here, uh- if uh-

39:16
If I don't capitalize on something that is [interesting] to tell...?
Or, there might be something that isn't very interesting at all, but the way I'm saying
what is happening, causes it to be [interesting]. It might cause people to be LESS 
interested in some story going on ELSEWHERE...

39:37
And then like they're payin' attention to my story.
They're like:
[People]: Wait a minute, this fuckin' dude...
          He's just narrating shit...?
          And like, talking about stuff like [literary devices], and like comedians
          sayin' stuff, and uh- [Andrew Cuomo] bein' a sausage wrecker...?
          And uh...

39:55
Like, uh- I'm recapping and reviewing all of the things that I've talked about, like, 
what do I wanna talk about...?
What could be the most interesting story that I could tell right now...?

40:07
So, I could backpedal into like uh- the points that I wanted to make earlier, about [bias].
Right...? Uhm, I do have a sense of [bias], I think everybody does, I think it's unavoidable
that everybody has a sense of bias. Nobody wants to talk around in their underwear, with
like, ya know, uh-

40:31
Some dude just got out of his minivan, and he's walkin' into a store.
I just inserted that observation into uh- the middle of a statement that I was about to make
about bias. Uh- a girl, a lady walked out of the same, uh- minivan.

40:49
They're goin'- she's goin' to the same place.
And I think... ya know...?
Uh- some- some girl is leaving another place...
and...
