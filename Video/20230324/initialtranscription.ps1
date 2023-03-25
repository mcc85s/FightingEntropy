<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Script                                                                                            \\
\\  Date       : 2023-03-19 14:21:44                                                                  //
 \\==================================================================================================// 

    FileName   : New-TranscriptionCollection
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : For categorizing transcriptions of (a single/multiple) audio recording(s)
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-03-19
    Modified   : 2023-03-19
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

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
        TranscriptionFile([UInt32]$Index,[Object]$File)
        {
            $This.Index    = $Index
            $This.Name     = $File.Name
            $This.Time     = $This.DateTime($File.Date,$File.Start)
            $This.Date     = $This.Time.Date
            $This.Start    = $This.Time.Time
            $This.Duration = $This.Position($File.Duration)
            $This.End      = ([DateTime]"$($File.Date) $($File.Start)" + [TimeSpan]$File.Duration).ToString("HH:mm:dd")
            $This.Url      = $File.Link
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
        [UInt32]     $Index
        [String]      $Name
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
        [Object] TranscriptionFile([UInt32]$Index,[Object]$File)
        {
            Return [TranscriptionFile]::New($Index,$File)
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
            $Item = $This.TranscriptionFile($This.File.Count,$File)

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

<#
#############################################################################################################
00:00
Audio log uh- March 20- Friday, March 24th, 2023. Michael Cook speaking, it's currently 8:21AM.
I'm makin this audio log to talk about a couple of concepts that I wanna cover, particualrly about being
hacked.

I kinda wanna touch base on uh- this guy on YouTube, his name- well, I don't know what his actual name is, 
but his channel name is uh- Mental Outlaw.
________________________________________________________________________
| 03/23/23 | Linus Tech Tips Got Hacked | https://youtu.be/cwKqgU_kxto |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
00:28
And uh- his coverage of uh- things uh- security related, or rather uh- a lot of his opinions
I share.

Right, so uh- within the last 20- within the last 24 hours, news has broken that Linus Tech Tips channel
has been hacked. Right...?

00:52
But- you know, most people are gonna think:
[People]: Wow, so like his channel got hacked within the last 24 hours, 
          and somebody went through all of his content, in order to like, 
          release some of the content and stuff...?

01:05
Well, look at it like this.
Uh- somebody had access to their account for a while, in order to be able to look through all of that
content as quickly as it- as they did.

So, what I mean specifically, is this.

01:20
Linus Sebastian and like, the people that work at Linus Tech Tips, they were being spied on.
And uh- ya know, you can break it down to uh- someone being hacked and whatever...?

But- I think that it was a surgically precise attack, ya know, uh- probably something that he,
or his staff may have mentioned on the YouTube channel, uh- it- it's pretty easy to associate
these attacks with some like, ya know, criminal underring gang of doom faces.

01:53
Right...? Uh- Being able to uh- take out like, uh- it's pretty easy to write off what uh- happened, 
where his uh- browser session, or an employees browser session was commandeered, and all the cookies
were taken, and it bypassed uh- (2) factor authentication and passwords and stuff.

02:19
Right, and uh- I don't know why I'm holding this...
Uh- 

On the other end of the specturm, uh- there are other ways of obtaining that information,
and I'm not gonna talk about that specifically, but what I am gonna say is this...

02:38
Right for uh- the last like (3) or (4) years or so, I've made numerous mentions that my
Apple iPhone 8+ had a program deployed to it which was allowing some nefarious entity unfettered
access to my device, and uh- basically everything that I did with that device...? 

And that program was called "Phantom".

03:05
Right...? 
And that uh- the deeper and deeper I go into explaining all of that, 
the more that I know that I'm gonna be labeled by people as uh:
[People]: You know, all that stuff sounds peculiar, strange, and rare...
          Ya know, somebody would've done something about it by now if that were the case, 
          OR- if what you're saying was accurate,
          than it would've happened to a lot more people.

03:33
Well, the reality is that uh- a lot of times, people will gloss over details.
Right...? And so like, even with uh- Mental Outlaw and his uh- analysis uh- regarding uh-
Linus uh- Tep- Tech Tips, being uh- hacked, right...?

Uh- it bypasses the amount of time that somebody would've needed to take, to go through
all of the content that Linus Tech Tips had uploaded, and to be able to like, reassociate it, to
another platform, or to like, transfer it, or uh- to like, start swapping details around,
and to like, make a live stream that sort of like, uh- puts uh- [Elon Musk]'s- and uh-
[Jack Dorsey]'s face over [Linus] and uh [Luke Lefreniere].

04:27
Right...?
Uh, they would talk a lot on uh- the [Wan Show].

Ya know I've watched uh- Linus' content numerous times.
I stopped watching it as much as I've also stopped watching a lot of stuff on television, and like uh-
distancing myself from like social media, and like uh- talking with a lot of people...

04:50
And uh- I started to come to the realization that uh- any government, anywhere, could be responsible
for these hack attacks, that look like, just some hacker used uh- a program that stole cookies from a
web browser, but in actuality, someone was uh- watching them for a while, and managed to like,
categorize the content that they had, and to make new content that sort of like, mocks the original 
content, and then sort of pools it all together into like, cryptocurrency, uh- deposits and stuff...

05:32
Re- like I think that the entire goal of that whole charade, was to uh- I don't think that the goal
was to get as much money as they could from uh- the victims. 

Ya know, most people in society, they're gonna think:
[People]: Well, OBVIOUSLY that WAS the main goal.

05:54
Nah, it wasn't.
These people that are behind some of these uh- really clever attacks, they don't really give a
shit about money. They can make money out of thin air. What they give more of a shit about, is
uh- ya know, publicity, or uh- people, or like uh- people's confidence, and theirs trust, and
their collective thoughts, their collective consciousness, and their collective opinion.

THAT'S what these people care about.

Because they know, that like, they can make anybody look stupid if they want to, by hacking their
uh- channel, or their account, or their uh- data...? Or what have you...? Right, and...

06:38
The thing is, that uh- I realize that people are gonna like, review what I'm saying right now,
and they're gonna brand it as audacious, ya know, like, because...

I do not have a lot of followers at this current moment, and there's a reason for that.
Because the followers, and the recognition, and the reputation attracts these types of people.

So when I say stuff like, "Keeping a low profile is sort of a blessing in disguise"

Well, keeping a low profile has allowed me to assort uh- my uh- my thought processes,
and to uh- ya know, explain them in better detail, in order to educate people on like, 
ya know, something was already happening, and like, the- this dude's uh- channel being taken.

Uh- or uh hacked, is like the tip of the iceberg that sunk the Titanic.

07:46
Ya know, below the surface of the ocean, was another like, 85 percent of a lurking, hidden
thing. And that is what causes people to act pretty fuckin' stupid.

Right, it's like there's a whole other array of issues that aren't being talked about or covered.
Though I'm not like, critiquing Mental Outlaw, or whatever his real name is, for uh- his coverage,
cause it's insightful. A lot of the things he says are accurate, and they're- correct.

The- they're accurate, and, I agree with them, uh- OpenBSD is a very good platform to use...
(for preventing [espionage/attacks] by limiting a specific [account + machine]'s abilities)
...if uh- you really do have like uh- a high level of uh- traffic, and followers, or uh- income,
and you're generating money and profit...

08:35
Right, like uh- the way I see is uh- ya know, at some point in the future, I'm gonna switch it 
back to the way everybody else thinks, where like, I'm gonna prioritize my profits.

And, in order to do that, I have to develop a system that's gonna be rather bulletproof,
or at least damn near close, to these types of attacks that occur.

And if I think that people in the government are repsonsible- in ANY government, not just, like
the United States Government, but like, any government in particular, that they have tools that 
allow them to have unfettered access to an account, or a device, or an operating system, or 
whatever, and...

09:21
I continue to build solutions to those problems, then I'm always gonna be a target.
That is the whole entire purpose of why I have uh- made the number of decisions that I have.

Right, most people are gonna be like:
[People]: Well, nah, you're just fuckin' psycho for, ya know, thinkin' that money is uh-
          Ya know, uh- like uh- second nature.
          You're supposed to revolve everything that you do, around the concept of money.
          That's what you're supposed to do.

09:49
Well, that's what- that's what a lot of people's opinions are. 
You're supposed to revolve everything that you do around the concept of money,
because money is more important than people... is a thought process that a lot of people have.

Money is more important than people.

Let me state that again, some people will uh- disagree with this, when I make an observation
of their fucking behaviors, and say:
[Me]: You care more about profit than fucking people...

And then, they'll be like:
[Them]: No I don't, no I don't...

But- actions consistently prove otherwise.
Right...?

There's uh- trhere's a problem with humanity.

10:36
If I suspect that like, a government just doesn't like me for a particular reason, I jump into
the category of somebody like Julien Assange.

Why...?
Well, because he exposed a numnber of tools that like, these people were using.
____________________________________________________________________________________________
| 03/04/23 | Espionage | https://github.com/mcc85s/FightingEntropy/blob/main/Docs/20230304 |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
So, it could've been a single hacker, using the number of tools that [Edward Snowden], or 
[Julien Assange] have [exposed], or [helped build], or [leaked]... otherwise [provided] some
level of [press coverage]...

11:08
Right...?
Could be anybody in the world, using any of those tools that they covered.

That, uh- sought to attack ya know, it's just like a new victim, [Linus Tech Tips], being a
new victim.

Right...? Like, I always expect that there will be additional victims of hacking attacks, it's
basically unavoidable, because of a number of uh- factors at play.

And some of those factors include, like, classification.
Ya know, how do I know, and- like, uh-

Most people, they will think that this following, uh- idea or statement is, ridiculous.
Or preposterous, right...?

Maybe the [CIA] had some hand in attacking Linus Sebastians, uh- channel on YouTube.
Ya know, like uh- here's my justification for that, right...?

12:04
Most people will immediately start chuckling, and laughing their asses off, but- the people at the
[CIA] won't be laughing, and neither will the people at [Microsoft].

They'll be like:
[Them]: Well, that could be the case.
        You're probably right.

And now, while I don't think that the [CIA] really would do something like that, uh-

There could be somebody at the [CIA] that just doesn't care for [Linus], and like, you know, used these
various tools to be able to uh- selectively go through all the shit that he was doing, ya know, with his 
channel and everything, and uh- it's the same sorta person that wouldn't like [Elon Musk].

So like, they went after like the [Tesla] channel, and then they went after like-

Ya know, l- going after the [Tesla] channel didn't like [bankrupt Tesla] or anything like that.
No.
It's like...

12:57
The- the- the YouTube channel in, the reference of uh- [Tesla], was sort of like an afterthought.
It's like "Hey, here's how cool everything is about [Tesla]."

Right...?
And then like, [Linus Tech Tips], their primary source of [revenue] and [income], was [YouTube].

It's something to consider... right...?
I dunno if the *wind* or not...

But anyway, uh- these are the sorts- these are the sorts of things that I had to uh- figure out, 
right...? So like, is uh- is it some guy in the [CIA] that had something to do with that...?

Is it a group of hackers...?
And like, if somebody were to say "Yeah, it was someone specifically that did that..."

Well, I would wanna see like, supporting evidence.
I wouldn't wanna just take somebody at their word.

14:00
A lot of people, they take people at their word, and they don't really put a whole lot of thought into
things, which is why like, if somebody says :Oh, don't- don't like uh- [Linus] had a bunch of uh- 
(unlisted) videos on his [YouTube] channel, and basically, uh [Mental Outlaw] said "Oh, he's using
it as cloud storage or whatever..."

Yeah, well I do the same thing, too.
Ya know, some of the videos that I upload, I just leave them unlisted.

*mad windy noises all over the place, demons and lost souls attacking me real quick*

Man, it is pretty uh- windy right now...
I'm gonna go back to walking, so uh- that it's less windy.

14:38
Uh- man. Whew. It is... not warm. 
But- it's not like, freezing.

It's about like 38, 39, 40 degrees.
The usn is not out, it's partly cloudy...?

So these are the things that anyone could like, observe in real life, right...?

So observations are pretty important.

15:12
And, uh- some of the observations that I make, they go against like, uh- the conventional mold of society. 
And uh- what I noticed at some point after I started my company, was that uh people should really take a
page from Microsoft with this whole zero uh- [zero trust security model].
_____________________________________________________________________________________________________
| 05/21/20 | Microsoft Security | https://drive.google.com/file/d/1cAUZNgct_m7q3byf4qoZasriIe4EyITw |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Cause like, you don't trust a single god damn person out there, the only thing that you can trust, is
uh- what you can see...? And uh- the idea behind [Active Directory] itself, and many of the principles
over at [Microsoft], is like... at any given moment, the system could be compromised, you you need to
have a number of doodads, algorithms, and uh- whatever...?

Simple machines...? Complex machines, in order to, like, eliminate the problem.

16:10
Right, and so like uh- things that are in memory, are harder to uh- eliminate or to bypass or uh-
to uh- commandeer, right because typically when something is in memory, it's locked.

Ya know, anytime that memory is altered or adjusted, it's like making new address space.
But you're always left with a transcription of all the shit that's happening on the machine, which is
what the fuckin' assembly code is for.

Right...?
So, I did start like, uh- to look at assembly... some time back.
And uh- at some point, maybe I'll write with it.

But- for the time being, I'm perfectly content with the writing style that I'm using now.
Occasionally I think about like, writing more stuff with CSharp or uh Python, but at the same time, 
I can still continue to develop uh- radical ideas with uh- with Powershell.

17:20
And uh- the tools that I currently use to build the things that I'm trying to build.
And I guess the real idea is this, ya know, many years ago, after I started my company, I started
working with a program called DISM ++
_____________________________________________________
| https://github.com/Chuyu-Team/Dism-Multi-language |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Which is a [Chinese]-made utility, software utility, which uses C++ and it's a component based
uh- it's based on (CBS/component based service).

Right, it's like a C++ program, that allows like uh- somebody to- to go into the [PXE environment]
and like, ya know, alter or adjust the various uh- settings in the registry, and uh- ya know, 
defaults...?

And... ya know, it's got a lot of really cool ideas, but- ya know, it is developed by uh- people
over in [China].

18:13
And so, like, I think it is rather relevant to talk about, right here and now, that- ya know, [Russians]
and the [Chinese], they have been [attacking] the [United States] on a daily basis.

Right, they're not gonna be like, they're not gonna openly admit that that's what they do...?
But- ya know, it's pretty easy to see that they have people here in the [United States], that are like, uh-
part of the local economy and everything, and they're trusted and respected members of the community, 
right...?

So, the most uh- the most dangerous threat that there is, is when somebody very trusted and important
becomes a leader, and they have a very dirty secret that allows them to uh- provide uh- like a trojan
horse so to speak, for another country.

19:03
So what I mean specifically, is like when [Donald Trump] became president, right...?
Very likable guy...?
Very trustworthy...?

Talked about like uh- ya know, helping, uh- fixing the economy and getting the numbers back up and
everything... and, uh-

OH WAIT... WHAT...? WHAT...?
What happened...? Oh, he like, paid [Stormy Daniels] to keep her mouth shut, through like,
[Michael Cohen]...? And uh- like during his presidential campaign...?

And then like, uh- 

19:33
Ya know, it's like both presidents had their own scandals goi-
Both [Hillary Clinton], AND [Donald Trump] had their own scandals going on...

But- ya know, what uh-

In hindsight, I really wish that [Hillary Clinton] did win her- the- her bid for presidency, 
because, it would've...

It would've allowed the country to make a better decision, regarding the [Taliban agreement] that
[Trump] made with uh- the [Taliban], which led to the uh- the evacuation of [Afghanistan]...?

Ya know, a country where [America] like spent (20) years, uh- fighting like- insurgents there, and uh-
protecting the area, and uh- it's a trillion dollars worth of- if not more, worth of uh- things that
[America] spent, during that entire time, safeguarding that country.

20:37
Ya know whadda hell- what the hell does that have to do with like, why I started this whole uh-
recording talking about...?

Well, it does have something to do with it, because you want to consider [foreign policy] along with
like, [local policy], and uh- like uh- [matters of national security]...?

And, uh- [spying on people]...?
And- people like on [YouTube], a lot of people on [YouTube] they're very like uh- [naive].

21:04
Like, to think that it was just some like uh- ameteur hacker that like, uh- commandeered
[Linus Sebastian]'s [YouTube] account, yeah I don't think so.

I think it was someone uh- with a lot of ex- expertise, or experience, and they managed to find a way
uh- to- surveil them, right...?

And they may have been able to watch them for a while, and then they were able to uh-
when they were watching them, they deployed like, this [Candy Crush Saga], or whatever
[Mental Outlaw] suggested that it was, it- basically like, searching for something on [Google],
and then coming up with uh- ya know, a page that links to uh- basically a 100% identical version
of a website, these are all things that [HIVE] does.

21:56
I'll tell you what HIVE is.
HIVE is a program that was talked about within Vault 7 which allows like uh- basically to create a
fake website that's 100% real...? And like, the program is so advanced that it looks exactly like
the real website, and its sole purpose, is to uh- uh- reflect the DNS traffic to a different address,
and then like, it's basically 100% identical to the original website.

Because it's pulling everything off the website, including even it's like, uh- uh- it's encryption,
like uh- the security certificates and everything, right...?

Like, we've gotten to a point in uh- in history, where you're just gonna see a lot of things that look
more and more like [DeepFakes].

22:47
The [DeepFakes] are a thing that I talked about, uh- a while back, regarding how like artificial
intelligence is being used to uh- create these videos, where they mock like ya know like celebrities
or people or whatever, like uh- [Jordan Peele], like, does a [DeepFake] video where he pretends he's
like [Barack Obama]...?
_________________________________________________________
| 04/17/18 | Obama/Peele | https://youtu.be/cQ54GDm1eL0 |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Right...? It looks, pretty... damn good.
And, uh- ya know, without like studying it for a while, and comparing it, side by side with OTHER
videos...?

Most people are NOT gonna be able to tell the difference.

23:22
Right...? So like, when I tell people that someone used [Pegasus], or uh- [Phantom], to like,
try to murder me on [May 26th, 2020] outside of the [Computer Answers] shop, I know that it was an
[act of war] and it had something to do with the [Russians].

But- good luck trying to tell that to other people, because like, they are gonna be confused by the
other- the [DeepFake] videos.

Ya know, I'm using that as a metaphor. The [DeepFake] videos, or it could've been somebody here in the
[United States], that like, I dunno... I still like- I have like an array of uh- uh- theories.

On what happened, how it happened, why it happened, it involved certain companies, it involves matters
of national security, and uh- ya know, like if I try to walk around and tell this story to certain
people, they're gonna be like, they're gonna think that I lost my fuckin' mind.

24:25
But some people at, like the, the Central Intelligence Agency, or like the CIA, they are gonna be
the only ones that put any thought to anything that I'm saying, and then, they're gonna be left with
the same sort of situation where, they might be looking at a coworker of theirs...?

And then they start to think:
[Them]: Ya know, is this fuckin' person right here, like, behind all the things that Michael Cook
        was talking about...?
        Did this dude, or this woman, like literally attempt to try to have [Michael Cook] killed...?
        And is this person literally working with [Russian Intelligence]...?
        Ya know...?
        Is he behind like, cyber attacks and everything...?
_____________________________________________________________________________
| Charles McGonigal (FBI) | https://en.wikipedia.org/wiki/Charles_McGonigal |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
25:05
Ya know, as long as like uh- somebody maintains, uh- keeps up appearances and things of that nature,
people are gonna find it very doubtful, most people are gonna find it very doubtful, even the highest
ranking officers at the CIA are gonna find some components of this story to be rather doubtful...

But- it's not their job to doubt things, it's their job to investigate things.
And, this is what caused me to believe that like, at any given moment, any device could be compromised.

25:35
Right, because like, the layers of deception are rather deep.
And, uh- the only way to get around like, the idea of losing something, like [Linus Sebastian] right
now, I can guarantee that like, the way he's feeling, is like, he's got this feeling in the pit of his
fucking stomach, where like "Oh my god, everything that I ever worked for, is gone..."

Yeah. I fucking know how that feels.
And I talked about it, like a number of fucking times, over the last (4) years.
But- ya know, here I am, having to like, uh- deal with uh- things that at very small component lay-
level.

26:18
Right...?
I do have reasons to suspect that the [Chinese], and/or, the [Russians], or both...
(I was using [DISM++] developed by the [Chinese] and [Snappy Driver Utility] developed by [Russians].
But also, [Computer Answers] is owned by a [Russian] named [Pavel Zaichenko] who constantly had 
[trojans] on his networks at his stores and in the tool vaults on the thumb drives and server shares.)

...had something to do with various attacks that I've like, recorded on video.
But it's not just them, its also like, I also have to worry about like, people in my own government
that like to abuse their authority, or just kick people around, because ya know, if someone doesn't
have enough followers or money, or uh- isn't like, liked by a lot of people... they're gonna have, it's
basically easy pickings for them, to do this.

26:52
However, it develo- like, when they do this to someone that knows what the fuck is goin' on, it
causes that person to develop a higher level of awareness than everybody else.

Which is why I started writing the book, [Top Deck Awareness - Not News].
Right...?
_______________________________________________________________________________________
| 10/08/22 | Top Deck Awareness - Not News                                            |
| https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2022_1008_TDA_Not_News.pdf |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
So...
Let me backpedal, a number of points that I just made.
[TikTok]. Ya know, it's basically doing the same exact thing that like [YouTube], and [Facebook]
and [Amazon], and et cetera and so forth...?

27:28
Why is it that like, when [Mark Zuckerberg] goes in front of [Congress]...
[Congress] will [believe] every fuckin' thing that this dude says, 
but like, if it's like, like [TikTok]...?
The representative of [TikTok]...?

Oh, well, ya know, if it's a [different government behind stuff], then they won't believe what
that person is saying.

28:06
Yeah, it really comes down to this.

Anything within the domestic [United States]...?
Is like, easy pickings for these companies that have a lot of [followers], [people], or [money]...?
Right...?

And then like, if you're from like outside of the country, and you happen to be like a political enemy,
like eh- to call like uh- to call [China] an enemy of the [United States], is not accurate, but to call
them our friend, that's not accurate either... they're just basically [neutral].

And with [neutrality], comes [reasons] and [motivations] for [remaining neutral].

28:42
Ya know, like uh- [TikTok] is allowing the [Chinese] government to get data on uh- people in the
[United States]. But- so is [Facebook], so is [Twitter], so is like a bunch of other fuckin' programs...

It's like the best way that I can state it, is like this...

Like, some people will be like:
[People]: Oh oh oh, well [Facebook] would never do that~!
          Nah, [Mark Zuckerberg] like, ya know, told us, flat out...
          He would never ever ever sell data to [Cambridge Analytica].
          No way, dude.
          No, he is one of the most trustworthy people that ever lived.
          And I- my god, I will find anybody that thinks that [Mark Zuckerberg] is a bad guy...?
          As [absolutely reprehensible]...?
          And [preposterous]...
          However...
          Oh my god, if some company like [TikTok] goes in front of [Congress] and tries to defend
          themselves for doin' the 100% identical thing that [Facebook] does...?
          Oh my god, that's... bullshit.
          Ya know I'm gonna find everything that they say...?
          As [absolutely preposterous], and [reprehensible].
          There's [no way] that they're not leaking data, to the [Chinese] government...

30:12
Ya know, on the other end of the spectrum, take a good long look at the fuckin' devices that everybody
uses, they're all like made over in [China] and [Taiwan].

Ya know this whole entire war about [Taiwan] is really about like, having control over the semiconductors
that are going into the devices that allow the software to be able to, ya know, eavesdrop on people more.

The hardware is a component, of all of this.
And it's being written off.

It's being written off because, I dunno.
I really don't know what to say.
The hardware itself.
Is being, like...

30:47
It's not being like seen as uh- 
the threat that it is.
Right...?

So, I have a number of exploits, performed by [Asus], the [Asus Corporation].
Ya know, [Asus] like supported [Linus Sebastian] and [Linus Tech Tips] for a really long time, right...?

And like, oh well maybe someone else caught onto this whole charade.
Maybe, like, some people should read the document that I put together called "Espionage".

Maybe I'll add it to a link in the description.
Maybe what I'll do is, I dunno.

I don't wanna really be too descript about like, every single step that I'm gonna take or make, because
I know that like, the enemy could be listening to me, or my recording, at some point later, after I 
record this.

31:44
And over- they'll listen to it, and they'll be like:
[Them]: I'm gonna look for any possible way to exploit this dude...?
        And his psychology...?
        And everything...?
        Because I have a lot of [money], [friends], and [power]...
        And I'm not gonna let this dude [outsmart me again]...

Yeah, key word [again].

32:07
Ya know I might be in the position that I'm in right now, but- somebody that I just rattled off, 
like, they under- they- sorely underestimated me, and so has a lot- so have a lot of other people.

And, in order for me to like, continue, with this uh- this mission of mine, I have to basically blend 
in with the environment and operate on the same notion that everybody else does.

Appear- like, seeing is believing, ya know, because if you see something...?
That means that you can believe it.

Eh, sometimes what you can see, isn't necessarily what you get.
Like so, what you see is what you get...?

Well, I think that like what happened was, like uh- [Linus Tech Tips], his fuckin' channel, being hacked,
is like a case of like, what you see is not always necessarily what you fuckin' get.

33:01
Oh... So, you're not allowed to like, rant and rave about like, uh- ya know, somebody that was 
successful with their [YouTube] venture, and like...

It's basically like this.
Right uhm...

Somebody who's older and wiser, had a lot of uh- more problems or issues in their life...
was up against the ropes, knew what they were up against, meanwhile a bunch of people that were 
younger than them... 

They were capitalizing on an opportunity to become very rich and wealthy and successful, and they ignored
the person who was older and wiser, and had a lesson to teach people.

Right...?
And what happens is throughout time, this pole position is constantly like, shuffled around.

33:56
And every once in a while...?
Like, somebody really important or famous, will wind up being victimized, and then at that point, people
will be like:
[People]: Oh my god... 
          Oh my god...
          There's no way, that [Linus Sebastian] would ever let his [Tech Tips] channel 
          ever ever be hacked by people...
          No, he's... 
          He's like the [Tech Tips] master.
          He knows what he's doin'...
          He employs a whole bunch of people...?
          And, you're out of line to think that [Linus] would ever do, would ever like, uh-
          miss something [critical]...

34:46
Yeah, no uhm...
The fact of the matter, is that a lot of people miss things that are, like, right in plain-
hidden in plain sight. Ya know, like uh, the things that uh- [Mental Outlaw] talks about, like...

He talked about this recently, uh- where people like uh-

What was it, uh- the uh... [NFT God]...?
Like, lost the uh- picture, uh- lost all of his shit...?

It's like:
[ML]: NFT God, he's like, lookin' for like, OBS, recording studio software...
      And when he downloaded it...?
      It downloaded... something, malware onto his machine.

35:31
Right, and so like, one thing to consider is, what if like, [everything is malware]...?
If you treat everything as if it might be malware...?
And you take certain security precautions...?

It's gonna be a lot harder for these high level attacks to get you.

Right...?
Ya know, like, treating everything as if it COULD be malware, is pretty difficult to do, but-
Ya know with the tool that I've been building, that like spins up like a, ya know, a network of machines
or a domain...?

It's as if like it- it just refreshes the entire structure of the domain and whatnot.
Ya know, if it's compromised at all...?
Wipe and reload everybody's permissions.

36:09
Right, and then like, also... measurement of how to- how to measure when a network is compromised is
pretty difficult to do, because uh- everybody's uh- mind, is like a [lambda box].

Or a [lambda function].
Where like, you don't know what the fuck is goin' on inside that persons mind, all they have to do is
just keep something to themselves, and never talk about it with other people, and then uh- at some poment-
at som- at some point or moment where they can just, cash in on the knowledge that they have, to do
something really sinister, shitty, trollmeister-like, and uh- destructive...

Ya know...?
They're gonna t- they're gonna cash in.

37:00
And that- that person could be anybody.
It could be anybody...? It could be uh- somebody behind, uh- somebody within a classified file...?

Like, I know some people will think it's fuckin' preposterous to think that like, uh- the
Central Intelligence Agency has a classified file somewhere that's named somethin' stupid, like uh-
ya know, [Whole Room Water-Cooling Project].

And then, in this classified file, [Whole Room Water-Cooling Project]...?
Is basically like, we're gonna li- we're gonna watch [Linus Sebastian]...?
And we're gonna just take out his [Tech Tips] channel, and really screw him over...

37:46
And then like, ya know there'll only be like (2) people in that classified file.
[Whole Room Water-Cooling Project].
Ya know...? It's like, what the fuck...?

I really don't think that like, they deserved what they went through, but- at the same time...?
Like, this is what it- what I mean by like, people being naive. 

Like, all of the work that they did...?
Was totally trumped by something very small and minor, right, but that very small and minor thing
allowed for ALL of their hard work to be taken from them, forcibly, right...?

38:18
Ya know, uh-
On the other hand...?

Ya know, think about like uh-

Think about ways to like, uh- aggregate like uh- someone's [suspicions] or [intent], to do something, 
could it have been like, as easy as like, an employee like took a cash payment from somebody...?
To wipe out [Linus Sebastian]'s fuckin' [Tech Tips] channel...?

And now, like he's gonna have to pace back and forth through the office, like, he's prolly doin' that.
He's like pacing back and forth through the office, wondering how the fuck he's gonna manage to pay
his rent, or his bills...? Or take care of his kids, or his family...?

Ya know, because like, his fuckin' revenue has just been shunted to a fucking halt, right...?

They were livin' life on easy street for a while, though, I really wouldn't call it easy street so much
as uh- like, they were being pretty like, uh- short sighted.

39:29
Short sighted is a way to put it.
So like, if uh- if my channel, my (1) channel, or my multiple channels were like uh-
attacked or commandeered...?

It's not gonna set me back anything.
Because, number 1...
A lot of those videos I still have backups of.

So, if [Linus Sebastian] isn't an idiot, he's gonna have backups too.
Because, ya know, he did like, go around and like, building servers for uh- like what the hells her
name... ah I can't remember.

40:06
Uh- building backup servers for people. And uh- bulding storage arrays.
He's got backups of the shit.
The problem is like, a lot of his content, is garbage.

And he needs to hit the fuckin' delete button on it.
Ya know, I need to do the same thing too...
With some of my content.

Some of it holds up longer than other content.
Right...? But also, sometimes you really have to go back to the drawing board,
and reinvent the entire thing from top to bottom.

40:44
It's just basically uh- the idea that I came across a while back, uh-
[Mental Outlaw] sounds like the type of dude that understands a lot of these
things, but I'm not gonna make uh- speculations or assumptions about like uh-
what he thinks or knows or whatever, right...?

41:03
If anything, uh, he presents himself as a very sophisticated individual, much
like [Louis Rossman] does...? And uh- their uh- their insight, is pretty
realistic, believe it or not.

Ya know, you're not gonna run into- like, when you run into somebody that like
never ever swears and is always worried about like, almost uttering a swear word...?

You really gotta be, uh- you gotta be careful about like, what sort of things their- 
that they have in their closet. What sort of skeletons that they have in their closet.

41:39
Ya know, when it comes to like uh- [Michael Stevens] or uh- [Adam Savage] or uh-
[Neil DeGrasse Tyson], or like a bunch of these other smart people on [YouTube],
like I'm not thinkin' that like, they went around like having dog fights.

Ya know, having their dogs fight to the death...
And like, ya know, they never like- it'd be like a comedic skit in my mind, is like,
[Michael Stevens] caught for having an [unlawful dog fighting contest] with
[Adam Savage].

42:13
And then they'd be like:
[Stevens]: Well, [Adam]...

And then [Adam] would say to [Michael Stevens]:
[Savage]: Well, [Michael]...

Or uh- [Michael Stevens] would say to [Adam]:
[Stevens]: Well, [Adam]...

And then uh- they'd be like:
[Them]: Well, we shouldn't have had this illegal dog-fighting contest...

And then, the other will be like:
[Them]: Nah, we shouldn't have had that at all, cause now look where we're at...
        Look where we ended up.
        Ya know...?
        Maybe having our dogs fight to the death is a bad thing...

And then they're like:
[Them]: Yeah, it is a bad thing, we shouldn't have done this...

42:49
Like I'm not thinkin' that at all, but- it is a comedic skit, that I just thought up on the spot.
Right...?

I don't think that people like them, are goin' around havin' fuckin' illegal dog fighting contests
and stuff... right...?

But- ya know, heh, I remember seeing [Michael Stevens] as a guest on [Joe Rogan]'s show.
And [Joe Rogan] was like, havin' a conversation with [Michael Stevens] and he's like:
[Rogan]: Fuckin', da da da da da...

And then as soon as he said the first F-word...?
You see the look on [Michael Steven]'s face...
Like "Ah... damnit, now I can't..."

Ya know...? Like, there are people in society that do not like when profanities are uh- uttered, because
it prevents a whole target audience from being able to enjoy the content.

Ya know...?
That's what they want.
They want all of their content that is recorded, to be consumed by people.
Of any age.

43:48
But it causes the content to feel unrealistic, (because it sanitizes the concept of being [informal])
and so like, I am gonna like segue out of the original content, uh- subject of uh- what I was talking
about for a moment, for a shade.

The idea of innocence...?
Has been perpetuated by people that want to limit the first amendment of the Constitution.

And, people's right to free speech.

44:14
Now, I don't know how exactly I feel about like, the idea of like, people on Nickelodeon or
Cartoon Network like, uttering off profanities like "Fuck this", "Shitbag that", and "Holy fuck"

Right...?
I don't know how I feel about that.
But at the same time...?

This is [America],  and it is pretty realistic for people to occasionally toss around an F-bomb.
Ya know I had this uh- coach in high school, his name was [Coach Careese], and anytime you ever
uttered off like, the F-word...?

He's like:
[Careese]: I heard that F-bomb, dude...
           Time to do a few laps.

44:55
And then the person who threw the F-bomb, would be like:
[Person]: Fuckin' god damnit...

And then [Coach Careese] would be like:
[Careese]: Uh- make that twice.
           Ya know...?
           Run around, do a few laps twice in a row now, dude...
           Second F-bomb...
           You wanna go for a hat trick...?
           You wanna go for a third F-bomb...?
           Go right ahead, dude...
           You'll be runnin' for the whole entire class.

And then the kid would be like:
[Kid]: Da- eh.

And then he's like:
[Careese]: That was almost a D-bomb right there, dude.
           You're really...
           You're pushin' your luck...

45:28
Right, so like, [Coach Careese] would have that conver- bleh.
Wouldn't exactly have that verbatim conversation with somebody, who like,
tossed around an F-bomb here or there...?

But like, the idea that I'm getting at, is this...
Right at some point people grow up and they become adolescents, and they're gonna hear the F-bomb 
tossed around a lot anyway.

Right, like my kids, my son and my daughter, uh- I know that they heard these words on like [YouTube]
and stuff. And sometimes I would hear, like my son say an expletive and I'd be like:
[Me]: What the hell did you just say, kid...?

46:07
The thing is, is like, the kids pick up on this from their adul- from adults.
Ya know...? Anybody who like, doesn't swear at like, claims that they never ever swear...?
They're lying.

Everybody swears.
Ya know, maybe there is like a limited selection of people that never ever swear, but the idea of
swearing, is, it causes the words that are stated to be like, considered reprehensible and
deplorable and and ru- like, bad. Those words are bad...

Yeah, that's the connotation that you get.
Saying words like that is not gonna kill people.

But- ya know, let me bring this all around back to the original point.

46:53
Ya know, the original point that I was gonna make is...?
That, you piss somebody off, they're gonna find some way to screw you over...
Number 1... it'll come out like uh- as news like [Linus Sebastian]'s [YouTube] channel got hacked.

Or like, [John Hammond]'s [YouTube] channel got hacked...
Or like, uh- ya know I wouldn't be surprised if like [Dave Bombal]'s fuckin' page got hacked.

Ya know, [Dave Bombal]'s a guy that used to work at the [National Security Agency], he does a lot
of cool stuff too...? So does [John Hammond].

These guys, uh- they've been in the field for a pretty long time.
Uhm, probably in the- the cybersecurity industry, far longer than I have...

Right...?
I really wouldn't consider myself uh- the same sort of cybersecurity experts that they are...
Because, the fields of study that they have studied, like, have to do with uh- CVE's, and 
reverse engineering like uh- code and stuff...?

And- basically a lot of the concepts that they cover, it's basically synonomous with the amount of things
that I cover, and I programmatically build...

48:15
And I think a lot of people get lost in particulars when really, you wanna start thinking about
like, aggregating uhm, making generalizations and stuff.

Ya know, like, artificial general intelligence is ya know, the idea that like, artificial intelligence
can think basically like a human does, where they generalize stuff, and they break things down and
they aggregate results based on what they can deduce logically, or make speculations and do detective
work, and investigate stuff...

These are the things that any police officer, lawyer, doctor, uh- these sorts of people in uh- bureacracy,
ya know, even politicians do this to some degree. They have to do various levels of what I just said, in
order to continue doing what they do.

49:07
Right, and uh- are they gonna get into the nitty gritty of like, binary and hexadecimal and like, uh- 
obfuscation and deobfuscation, and uh- introducing malware and threading, and runspacing, and
parallelization, and like, virtualization and running tasks across multiple machines and clustering and
uh- ya know, database management, and like, graphical user interface design and stuff...?

Nah, prolly not.

49:39
Are these things that are covered on like, [Linus Tech Tips]...?
Maybe on a very minor scale.
What they do, is they focus on the hardware, typically.

But that doesn't mean that they don't occasionally have something to say about like, software, like
they'll talk about like [Terry Davis] for a little bit, or they'll uh- review somebody's code...?

Or like, what they've done and everything...?
Really, at the beginning and the end of it, is that uh- there's a lot of people in the world that know
what the hell they're saying or doing, and somebody wants to find a way to control everybody.

50:13
They wanna find some way to control everybody.
But it's like a supertask.

Ya know, taking a page from [Michael Stevens].
It's like a supertask, to be able to uh control everything.

Because, if you control everyhting...?
Then basically you would be god.

And being god means that, you could no longer be human, you would be- you'd either be all knowing, 
or all evil... Or, all good.

Ya know, I've talked about this before, the uh- the number of topics that I'm talking about...?
It's mainly because uh- after I started my company, I started to invest a lot of time ans thought
into how these things like, correlate. Right...?

It's gonna sound rather bonkers to someone who's not paying attention...

It's gonna sound like I'm uh- bantering, or what's uh- babbling.
It's gonna sound like I'm babbling.

51:15
But- ya know, given enough thought and enough distancing from how people typically think...?
They're gonna realize how like, astute my observations skills really are, and they're gonna start to make
the same sorts of correlations at some point in the future, when they review a number of the content,
the amount of things I've covered in my content.

Right...? So, allow me to spin things back even further.
Back to the original point of discussion, right...?

Was it even a person that broke into [Linus Sebastian]'s account, ya know, what evidence is there
that suggests that it was a browser thing...? And not necessarily like uh- ya know who came up with
the evidence to say that that was the intrusion route...?

Ya know, how do you know that it wasn't a quantum computer that broke the encryption of the password
or the login, or whatever...?

52:10
And like, it happened at [Google]...?
Much less, at uh- [Linus Tech Tips]...
Maybe the problem was at [Google]...
Not at [Linus Tech Tips]...

Ya know, what if that's the case...?
I guess it really comes down to this...

Uh- the coverage of uh- these channels, right...?
Um, some people are gonna get lost in the particulars.

However, what I can say for certain, is that some people, some shady trollmeisters out there somewhere,
they're performing high level attacks that are extremely sophisticated, and, some of the residue that they
leave behind, is just for appearances, to make it, to be like a red herring.

52:56
Right...? So like, it very well could've been like an attack by the [Russian] government, to attack
[Linus Tech Tips] channel. And much less, the [CIA]. And they wanted to make it appear as if somebody
had used a program to uh- like uh- to rick roll someone into clicking on a link that went somewhere...

However, ya know, that's just a speculation.
These are the sorts of- these are the sorts of speculations that I make when like, not all of the evidence
is there...? And I don't have a- access to the resources that they had, in order to make the investigation
that they did.

But- one of my other observations is that, even if you have a whole bunch of evidence, some people are
gonna take a really long time to figure things out. So if the channel got hacked, like, and the news broke
about it 24 hours ago, or less than 24 hours ago, and like, there's already a whole bunch of information
or adamant conclusions about what happened...?

Some people are bullshitting each other.
And uh- ya know, um, for me to come right out and say that that's what's goin on...?
Ya know, uh, that's what causes me to be like, branded as an outcast, or uh- delusional by people.

Because, ya know, I am correct...?
But...?
If people admit that I'm correct...?

Then it's gonna cause their reputation to tank, considerably.

54:30
Right...?
Right.
So, the idea of [DeepFakes].

From here on out, people are gonna have to deal with the idea of like, getting a phone call from somebody
that sounds like the person that they would normally talk to. But- the way that they're talking is gonna
sorta sound a little bit different than usual, and then they're gonna sound a lot like the Terminator
talking to John, in the movie [Terminator 2: Judgement Day].

And then like, uh-
Ya know, [Arnold Shwarzenegger], the T-800...?
He's like: 
[T800]: Here, give me the phone...

And then he pretends he's like [John Connor], using the voice and stuff...
And uh- then uh- the Terminator says:
[T800]: What's the- What

...covers the phone, and he's like:
[T800]: What's the dogs name...?

And then, [John Connor] says uh- I can't remember what the dogs name is...
And then like, the [Terminator] says the wrong dogs name...?
He's like:
[T800]: How's Woofie...?

And then the [T800] (meant [T1000]) she's like:
[T1000]: Woofie's just fine, honey.
         Woofie's just fine...
         Where are you...?

And then the [T800] hangs up.
And then he says:
[T800]: Both of your parents are dead...
        And maybe the dog is dead too...
        Ya know...?
        It's time to go.
        Don't ever go back there...
        Because, the [T800]...? (meant [T1000])
        Was the person we were just talking to...

56:08
Right...?
So these are the things that were foreshadowed, as far back as like 1984...
Well, [Judgement Day], [Terminator 2: Judgement Day] was in like 91 I think...?
But-

The idea I'm alluding to, is that uh- [mimicry].
Being able to [mimic] one another, to the degree to where like, you really can't tell the difference
between one thing or another.

56:33
And so, [Michael Stevens] talks about this in uh- like the ship of [Theudi]- it's not [Theudissises]
[Theudiss], [Theudidisys Trap]- uh- it's not that, uh- it's basically like uhm, you take- you have-
you start with a ship, right...?

And then over time, you slo- you slowly change every part of the ship.
Is it still the same ship...?

Well, no it's not the same ship.

It IS the same ship, because it has changed...?
But it is NOT the same ship, because it has also changed...

57:06
This is the idea of like, humanity.
And the population.
Ya know, as uh- people are born...?

They live, and then, people die.
And this is basically is it still the same [America]...?
No, it's not.
But it is.

It's a- contradiction or a paradox, right...?
These are sort of- these are the things that I sorta covered...?

Like in the video where I blasted Linus Sebastian, or Linus Tech Tips, when they banned me from their
forum, back in like uh- February or March 2019...?

57:40
Right, this is (4) fuckin' years ago, right...?
So, here's the thick and thin of it.

People should not be trusted as easily as they are, mainly because, in order to earn people's trust,
you have to give them a test, where you can know for certain whether you can continue to trust them or not.

And in order to trust people, and to know they're telling you the truth...?
They have to fear something.
Yeah, they have to fear something.

Whatever thing is that they fear, ya know, it's gotta be like uh- it's gota shift around, ya know...?
Are they gonna be afraid of the notion nof death in the immediate vicinity...?

58:29
Well if that's the case, then they're like afraid of that person, and so like, that's gonna affect
their responses, and they're not gonna be trusted, because if they're gonna be- if they're afraid of 
dying, then of course they're gonna fucking lie.

But ya know, if it's fear of losing the things that they have...?
Then, they're gonna tell you the fuckin' truth.

Well, I dunno.
I mean, it's difficult to say for certain, but anywhere in that range of uh- that uh spectrum of
possibilities, needs to be considered because like, uh-

Ya know, [T800]'s (meant [T1000]'s), sounding like [Sarah Connor]'s- uh- [John Connor]'s stepmother.

Ya know, [John Connor] was about to like, go right into a trap and get himself killed, ya know cause
the [T800] (meant [T1000]) was able to mimic his stepmother's voice.

It's really that simple.

59:31
[DeepFakes].
Ya know, [Michael Baker], talkin' with [Joe Rogan].

Goin' back to [Joe Rogan], here.
[Deepfakes] and [artificial intelligence], they're on a scale of magnitude that is absolutely fightening
and it is causing people to trust something that doesn't have to explain itself at all...?

It doesn't have to be- it's just openly trusted, [artificial intelligence].
Ya know, why is it openly trusted...?

Oh, because a bunch of people like, made it, and they were [responsible] in the [way] they went about
[making] that [artificial intelligence].

Ohhhh, they were [responsible] in the [way] they went about [creating] that [artificial intelligence]...?

Yeah, yeh, they were [very responsible], in the [way] they went about,
[creating] that [artificial intelligence].

01:00:24

#>
