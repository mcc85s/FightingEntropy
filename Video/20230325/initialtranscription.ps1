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
#######################################################################################
00:00:00
Audio log uh- [March 20]- [Friday], [March 24th, 2023]. [Michael Cook] speaking, it's
currently [8:21AM]. I'm makin this audio log to talk about a couple of concepts that
I wanna cover, particularly about being [hacked].

I kinda wanna touch base on uh- this guy on [YouTube], his name- well, I don't know 
what his actual name is, but his channel name is uh- [Mental Outlaw].
________________________________________________________________________
| 03/23/23 | Linus Tech Tips Got Hacked | https://youtu.be/cwKqgU_kxto |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
00:00:28
And uh- his coverage of uh- things uh- security related, or rather uh- a lot of his
opinions I share.

Right, so uh- within the last (20)- within the last (24) hours, news has broken that
[Linus Tech Tips] channel has been [hacked].

Right...?

00:00:52
But- you know, most people are gonna think:
[People]: Wow, so like, his channel got [hacked] within the last (24) hours, 
          and somebody went through all of his content, in order to like, 
          release some of the content and stuff...?

00:01:05
Well, look at it like this.
Uh- somebody had access to their account for a while, in order to be able to look
through all of that content as quickly as it- as they did.

So, what I mean specifically, is this.

00:01:20
[Linus Sebastian] and like, the people that work at [Linus Tech Tips], [they were 
being spied on].

And uh- ya know, you can [break it down] to uh- someone [being hacked] and whatever...?

But- I think that it was a [surgically precise attack], ya know, uh- probably something
that he, or his staff may have mentioned on the [YouTube] channel, uh- it- it's pretty
easy to associate these attacks with some like, ya know, [criminal underring gang of
doom faces].

00:01:53
Right...?
Uh- Being able to uh- take out like, uh- it's pretty easy to write off what uh- 
happened, where his uh- [browser session], or an [employees browser session] was 
[commandeered], and [all the cookies were taken], and it bypassed uh- [(2) factor
authentication] and [passwords] and stuff.

00:02:19
Right, and uh- I don't know why I'm holding this...
Uh- 

On the other end of the spectrum, uh- there are [other ways] of [obtaining that
information], and I'm not gonna [talk] about [that], [specifically], but- what I am
gonna say is this...

00:02:38
Right for uh- the last like (3) or (4) years or so, I've made [numerous mentions] that
my [Apple iPhone 8+] had a [program] deployed to it which was [allowing some nefarious
entity unfettered access to my device], and uh- basically [everything that I did with
that device]...? 

And that program was called [Phantom].

00:03:05
Right...? 
And that uh- the [deeper] and [deeper] I go into explaining all of that, the more that
I know that I'm gonna be labeled by people as uh:
[People]: You know, all that stuff sounds [peculiar], [strange], and [rare]...
          Ya know, [somebody would've done something about it by now] if that were the
          case, OR- if what you're saying was [accurate],
          than [it would've happened to a lot more people].

(It is happening to a lot more people, but the program is [extremely stealthy] and [difficult to detect],
which means that nearly ALL targets are [totally unaware] that the [program] is being used to [monitor] them.

[There is no police agency that handles this].
[There is no recourse].

If you were to go to the authorities and state that this program is on your device, 
you will be labeled as delusional and then they will tank your reputation considerably.)

00:03:33
Well, the [reality] is that uh- a lot of times, [people will gloss over details].

Right...?
And so like, even with uh- [Mental Outlaw] and his uh- analysis uh- regarding uh- 
[Linus] uh- Tep- [Tech Tips], being uh- hacked, right...?

Uh- it [bypasses] the [amount of time] that [somebody] would've [needed to take], to
go through all of the content that [Linus Tech Tips] had [uploaded], and to be able
to like, [reassociate it], to another platform, or to like, transfer it, or uh- to
like, start [swapping details around], and to like, make a [live stream] that sort of
like, uh- puts uh- [Elon Musk]'s- and uh- [Jack Dorsey]'s face over [Linus] and uh-
[Luke Lefreniere].

00:04:27
Right...?

Uh, they would talk a lot on uh- the [WAN Show].

Ya know I've watched uh- [Linus]' content numerous times.

I stopped watching it as much as I've also stopped watching a lot of stuff on
television, and like uh- distancing myself from like [social media], and like uh- 
[talking with a lot of people]...

00:04:50
And uh- I started to come to the [realization] that uh- [any government], [anywhere],
could be [responsible] for these [hack attacks], that look like, just some hacker used
uh- a program that [stole cookies] from a [web browser].

But- in actuality, [someone] was uh- [watching them for a while], and managed to like,
[categorize] the [content] that they had, and to make [new content] that sort of like,
[mocks the original content], and then sort of pools it all together into like,
[cryptocurrency], uh- [deposits] and stuff...

00:05:32
Re- like, I think that the [entire goal] of that [whole charade], was to uh-
I don't think that the [goal] was to [get as much money as they could] from uh- the
[victims]. 

Ya know, [most people in society], they're gonna think:
[People]: Well, OBVIOUSLY that WAS the main goal.

00:05:54
[Nah, it wasn't].

These people that are behind some of these uh- [really clever attacks], 
they don't really give a shit about [money].

[They can make money out of thin air]. 

What they give more of a shit about, is uh- ya know, [publicity], or uh- [people],
or like uh- [people's confidence], and theirs [trust], and their [collective thoughts],
their [collective consciousness], and their [collective opinion].

THAT'S what these people care about.

Because they know, that like, they can make [anybody] look [stupid] if they want to, 
by [hacking] their uh- [channel], or their [account], or their uh- [data]...?

Or what have you...?
Right, and...

00:06:38
The thing is, that uh- I realize that people are gonna like, [review] what I'm [saying]
right now, and they're gonna [brand it] as [audacious], ya know, like, because...

I do not have a lot of [followers] at this current moment, and [there's a reason for
that]. Because the [followers], and the [recognition], and the [reputation] [attracts
these types of people].

So when I say stuff like, 
"Keeping a [low-profile] is sort of a [blessing-in-disguise]..."

Well, keeping a [low-profile] has allowed me to [assort] uh- my uh- my [thought
processes], and to uh- ya know, [explain them] in [better detail], in order to
[educate people] on like, ya know, something was [already happening], and like, the-
this dude's uh- [channel] being taken.

Uh- or uh [hacked], is like the [tip of the iceberg] that [sunk the Titanic].

00:07:46
Ya know, below the [surface] of the [ocean], was another like, (85) percent of a
[lurking], [hidden] thing. And [that] is what causes [people] to [act pretty fuckin'
stupid].

Right, it's like there's a [whole other array of issues that aren't being talked about
or covered].

Though I'm not like, critiquing [Mental Outlaw], or whatever his [real name] is, for
uh- his coverage, cause it's [insightful].

A lot of the things he says are [accurate], and they're- [correct].

The- they're [accurate], and, [I agree with them], uh- [OpenBSD] is a very good
platform to use...

(for preventing [espionage/attacks] by limiting a specific [account + machine]'s abilities)

...if uh- you really do have like uh- a [high level] of uh- [traffic], and [followers],
or uh- [income], and you're [generating money] and [profit]...

00:08:35
Right, like uh- the way I see is uh- ya know, [at some point in the future], I'm gonna
switch it [back] to the way [everybody else thinks], where like, I'm gonna [prioritize]
my [profits].

And, [in order to do that], I have to [develop] a [system] that's gonna be rather
[bulletproof], or at least [damn near close], to [these types of attacks that occur].

And if I think that [people] in the [gov't] are [repsonsible-] in [ANY gov't], not
just, like the [United States Gov't], but like, [any gov't in particular], that [they]
have [tools] that [allow them] to have [unfettered access] to an [account], or a
[device], or an [operating system], or whatever, and...

00:09:21
I continue to [build solutions to those problems], then [I'm always gonna be a target].
That is the [whole entire purpose] of [why] I have uh- made the [number] of [decisions]
that I have.

Right, [most people] are gonna be like:
[People]: Well, nah, you're just fuckin' [psycho] for, ya know, thinkin' that [money]
          is uh- Ya know, uh- like uh- [second nature]. You're supposed to [revolve
          everything that you do], around the [concept] of [money].
          That's what you're [supposed to do].

00:09:49
Well, that's what- [that's what a lot of people's opinions are].

You're [supposed] to [revolve everything that you do] around the [concept] of [money],
because [money] is [more important] than [people]... is a [thought process] that [a lot
of people have].

[Money] is [more important] than [people].

[Let me state that again], [some people] will uh- disagree with this, when I make an
[observation] of their [fucking behaviors], and say:
[Me]: [You care more about profit than fucking people]...

And then, they'll be like:
[Them]: No I don't, no I don't...

But- [actions consistently prove otherwise].
Right...?

There's uh- there's a [problem] with [humanity].

00:10:36
If I suspect that like, a [gov't] just doesn't like [me] for a [particular reason],
I jump into the [category] of somebody like [Julien Assange].

Why...?
Well, because he [exposed] a [number] of [tools] that like, [these people were using].
_____________________________________________________________________
| 03/04/23 | Espionage                                              | 
| https://github.com/mcc85s/FightingEntropy/blob/main/Docs/20230304 |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
So, it could've been a [single hacker], using the [number] of [tools] that [Edward
Snowden], or [Julien Assange] have [exposed], or [helped build], or [leaked]...
otherwise [provided] some level of [press coverage]...

00:11:08
Right...?
Could be [anybody] in the [world], using [any] of those [tools] that they [covered].

That, uh- sought to [attack] ya know, it's just like [a new victim], 
[Linus Tech Tips], being a [new victim].

Right...?
Like, I [always expect] that there will be [additional victims] of [hacking attacks],
it's [basically unavoidable], because of a [number] of uh- [factors] at [play].

And some of those [factors] include, like, [classification].
Ya know, how do I know, and- like, uh-

[Most people], they will think that this following, uh- [idea] or [statement] is,
[ridiculous]. Or [preposterous], right...?

Maybe the [CIA] had some hand in attacking [Linus Sebastian]'s, uh- [channel] on
[YouTube]. Ya know, like uh- [here's my justification for that], right...?

00:12:04
Most people will [immediately] start [chuckling], and [laughing their asses off], but-
the people at the [CIA] won't be laughing, and neither will the people at [Microsoft].

They'll be like:
[Them]: Well, that could be the case.
        You're probably right.

And now, while I don't think that the [CIA] really would do something like that, uh-

There [could] be [somebody] at the [CIA] that just doesn't care for [Linus], and like,
you know, used these [various tools] to be able to uh- [selectively] go through [all
the shit] that he was doing, ya know, with his [channel] and everything.

And uh- it's the same sorta person that wouldn't like [Elon Musk].

So like, they went after like the [Tesla] channel, and then they went after like-

Ya know, l- going after the [Tesla] channel didn't like [bankrupt Tesla] or anything
like that. No. It's like...

00:12:57
The- the- the [YouTube] channel in, the reference of uh- [Tesla], was sort of like an
[afterthought]. It's like "Hey, here's how cool everything is about [Tesla]."

Right...?
And then like, [Linus Tech Tips], their primary source of [revenue] and [income], was
[YouTube].

It's something to consider... right...?
I dunno if the *wind* or not...

But anyway, uh- these are the sorts- these are the sorts of things that I had to uh-
figure out, right...? 

So like, is uh- is it some guy in the [CIA] that had something to do with that...?

Is it a [group] of [hackers]...?
And like, if somebody were to say "Yeah, it was [someone specifically] that [did that]..."

Well, I would wanna see like, [supporting evidence].
I wouldn't wanna just [take somebody at their word].

00:14:00
A lot of people, they [take people at their word], and they [don't really put a whole
lot of thought] into things, which is why like, if somebody says "Oh, don't- don't 
like uh- [Linus] had a bunch of uh- (unlisted) videos on his [YouTube] channel", and
basically, uh [Mental Outlaw] said 

"Oh, he's using it as [cloud storage] or whatever..."

Yeah, well [I do the same thing], too.
Ya know, [some of the videos that I upload], I just [leave them unlisted].

*mad windy noises all over the place, [demons/lost souls] attacking me real quick*

Man, it is pretty uh- [windy] right now...
I'm gonna go back to [walking], so uh- that it's [less windy].

00:14:38
Uh- man.
Whew. 
It is... not warm.

But- it's not like, [freezing].

It's about like (38, 39, 40) degrees.
The sun is not out, it's partly cloudy...?

So, these are the things that anyone could like, [observe] in real life, right...?

So, [observations] are [pretty important].

00:15:12
And, uh- some of the [observations] that I make, they go against like, uh- the
[conventional mold] of [society]. 

And uh- what I [noticed] at [some point after I started my company], was that uh
[people] should really take a page from [Microsoft] with this whole zero uh- [zero
trust security model].

Cause like, you don't [trust] a [single god damn person out there], the [only thing]
that you can [trust], is uh- [what you can see]...? And uh- the idea behind [Active
Directory] itself, and many of the [principles] over at [Microsoft], is like... at
[any given moment], the [system] could be [compromised], you you need to have a 
[number] of [doodads], [algorithms], and uh- whatever...?

[Simple machines]...?
[Complex machines], in order to, like, [eliminate the problem(s)].

00:16:10
Right, and so like uh- things that are in [memory], are [harder] to uh- [eliminate] or
to [bypass] or uh- to uh- [commandeer], right because typically when something is in
[memory], it's [locked].

Ya know, anytime that [memory] is [altered] or [adjusted], it's like [making new
address space]. But- you're always left with a [transcription] of [all the shit that's
happening on the machine], which is what the fuckin' [assembly code] is for.

Right...?
So, I did start like, uh- to look at [assembly]... some time back.
And uh- at [some point], maybe I'll [write] with it.

But- for the time being, I'm [perfectly content] with the [writing style] that I'm
using [now].

[Occasionally] I think about like, [writing more stuff] with [CSharp] or uh [Python],
but at the same time, I can still [continue] to [develop] uh- [radical ideas] with uh-
with [PowerShell].

00:17:20
And uh- the [tools] that I [currently use] to [build] the [things] that I'm [trying to
build]. And I guess the [real idea] is this, ya know, many years ago, after I started
my company, I started working with a program called [DISM ++]
_____________________________________________________
| https://github.com/Chuyu-Team/Dism-Multi-language |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Which is a [Chinese]-made utility, software utility, which uses [C++] and it's a
[component based] uh- it's based on (CBS/component-based service).

Right, it's like a [C++] program, that allows like uh- somebody to- to go into the
[PXE environment] and like, ya know, [alter] or [adjust] the various uh- [settings in
the registry], and uh- ya know, [defaults]...?

And... ya know, it's got a lot of [really cool ideas], but- ya know...
It is developed by uh- people over in [China].

00:18:13
And so, like, I think it is rather relevant to talk about, right here and now, that-
ya know, [Russians] and the [Chinese], they have been [attacking] the [United States]
on a [daily basis].

Right, they're not gonna be like, they're not gonna [openly admit] that [that's what
they do]...?

But- ya know, it's [pretty easy to see] that they have [people] here in the [United
States], that are like, uh- part of the [local economy] and everything, and they're
[trusted] and [respected members] of the [community], right...?

So, the most uh- [the most dangerous threat that there is], is when [somebody very
trusted] and [important] becomes a [leader], and they have a [very dirty secret] that
allows them to uh- provide uh- 
like a [trojan horse] so to speak, for [another country].

00:19:03
So what I mean [specifically], is like when [Donald Trump] became president, right...?
Very [likable guy]...?
Very [trustworthy]...?

Talked about like uh- ya know, helping, uh- [fixing the economy] and [getting the
numbers back up] and everything... and, uh-

OH WAIT...
WHAT...?
WHAT...?

What happened...?
Oh, he like, paid [Stormy Daniels] to keep her mouth shut, through like, [Michael 
Cohen]...? And uh- like [during his presidential campaign]...?

And then like, uh- 

00:19:33
Ya know, it's like [both presidents] had their own [scandals] goi-
Both [Hillary Clinton], AND [Donald Trump] had their own [scandals] going on...

But- ya know, what uh-

In [hindsight], I really wish that [Hillary Clinton] did win her- the- her bid for
[presidency], because, it would've...

It would've allowed the country to make a [better decision], regarding the [Taliban
agreement] that [Trump] made with uh- the [Taliban], which led to the uh- the
[evacuation] of [Afghanistan]...?

Ya know, a country where [America] like spent (20) years, uh- fighting like-
insurgents there, and uh- protecting the area, and uh- it's [a trillion dollars] worth
of- if not more, worth of uh- things that [America] spent, during that entire time,
[safeguarding that country].

00:20:37
Ya know whadda hell- what the hell does that have to do with like, why I started this
whole uh- recording talking about...?

Well, it does have something to do with it, because you want to consider [foreign
policy] along with like, [local policy], and uh- like uh- [matters of national
security]...?

And, uh- [spying on people]...?
And- people like on [YouTube], a lot of people on [YouTube] they're very like uh-
[naive].

00:21:04
Like, to think that it was just some like uh- [ameteur hacker] that like, uh-
[commandeered] [Linus Sebastian]'s [YouTube] account, yeah [I don't think so].

I think it was someone uh- with a lot of ex- [expertise], or [experience], and they
managed to find a way uh- to- surveil them, right...?

And they may have been able to [watch them for a while], and then they were able to
uh- when they were watching them, they deployed like, this [Candy Crush Saga], or
whatever [Mental Outlaw] suggested that it was, it- basically like, [searching] for
[something] on [Google], and then coming up with uh- ya know, a page that links to
uh- basically a [100% identical version of a website], these are all things that 
[HIVE] does.

00:21:56
I'll tell you what [HIVE] is.
[HIVE] is a [program] that was talked about within [Vault 7] which allows like uh-
basically to create a [fake website] that's [100% real]...? And like, the [program]
is [so advanced] that it looks [exactly] like the [real website], and its [sole
purpose], is to uh- uh- [reflect] the [DNS traffic] to a [different address], and
then like, it's basically [100% identical] to the [original website].

Because [it's pulling everything off the website], including even it's like, uh- uh-
it's [encryption], like uh- the [security certificates] and everything, right...?

Like, we've gotten to a point in uh- in history, where you're just gonna see a lot of
things that look more and more like [DeepFakes].

00:22:47
The [DeepFakes] are a thing that I talked about, uh- a while back, regarding how like
[artificial intelligence] is being used to uh- [create these videos], where they [mock]
like ya know like [celebrities] or [people] or whatever, like uh- [Jordan Peele], like,
does a [DeepFake] video where he pretends he's like [Barack Obama]...?
_________________________________________________________
| 04/17/18 | Obama/Peele | https://youtu.be/cQ54GDm1eL0 |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Right...?
It looks, pretty... damn good.

And, uh- ya know, without like [studying it] for a [while], and [comparing] it, 
side-by-side with OTHER videos...?

[Most people] are NOT gonna be able to [tell the difference].

00:23:22
Right...?
So like, when I tell people that someone used [Pegasus], or uh- [Phantom], to like, try
to murder me on [May 26th, 2020] outside of the [Computer Answers] shop, I know that it
was an [act of war] and it had something to do with the [Russians].

But- [good luck] trying to tell that to other people, because like, they are gonna be
[confused] by the other- the [DeepFake] videos.

Ya know, I'm using that as a [metaphor].
The [DeepFake] videos, or it could've been somebody here in the [United States], that
like, I dunno... I still like- I have like an array of uh- uh- [theories].

On:
[+] [what happened]
[+] [how it happened]
[+] [why it happened]...
...it involved [certain companies], it involves [matters of national security], and
uh- ya know, like if I try to walk around and tell this story to certain people,
they're gonna be like, they're gonna think that [I lost my fuckin' mind].

00:24:25
But some people at, like the, the [Central Intelligence Agency], or like the [CIA],
they are gonna be the only ones that put [any thought] to [anything] that I'm [saying],
and then, they're gonna be left with the [same sort of situation] where, they might be
[looking at a coworker of theirs]...?

And then they start to think:
[Them]: Ya know, is this fuckin' person right here, like, behind all the things that
        [Michael Cook] was talking about...?
        Did this dude, or this woman, like literally attempt to try to have 
        [Michael Cook] killed...?
        And, is this person literally working with [Russian Intelligence]...?
        Ya know...?
        Is he behind like, [cyber attacks] and everything...?
_____________________________________________________________________________
| Charles McGonigal (FBI) | https://en.wikipedia.org/wiki/Charles_McGonigal |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
00:25:05
Ya know, as long as like uh- somebody [maintains], uh- [keeps up appearances] and
things of that nature, people are gonna find it [very doubtful], [most people] are
gonna find it [very doubtful], even the [highest ranking officers] at the [CIA] are
gonna find [some components] of this [story] to be rather [doubtful]...

But- it's not their job to [doubt things], it's their job to [investigate things].
And, this is what caused me to believe that like, at any given moment, [any device
could be compromised].

00:25:35
Right, because like, the [layers] of [deception] are [rather deep].

And, uh- the [only way] to get around like, the idea of [losing something], like
[Linus Sebastian] right now, I can guarantee that like, the way he's feeling, is like,
he's got this feeling in the pit of his fucking stomach, where like 
"Oh my god, everything that I ever worked for, is gone..."

(After I made this audio recording, I determined that [Google] helped him recover the account.)

Yeah.
I fucking know how that feels.

And I talked about it, like a number of fucking times, over the last [(4) years].

But- ya know, here I am, having to like, uh- deal with uh- things that at very small
component lay- level.

00:26:18
Right...?

I do have reasons to suspect that the [Chinese], and/or, the [Russians], or both...

(I was using [DISM++] developed by the [Chinese] and [Snappy Driver Utility] developed by [Russians].
But also, [Computer Answers] is owned by a [Russian] named [Pavel Zaichenko] who constantly had 
[trojans] on his networks at his stores and in the tool vaults on the thumb drives and server shares.)

...had something to do with [various attacks] that I've like, [recorded on video].

But it's not just them, its also like, I also have to worry about like, [people in my
own government] that like to [abuse their authority], or just [kick people around],
because ya know, if someone doesn't have enough [followers] or [money], or uh- isn't
like, [liked] by a lot of people... they're gonna have, it's basically [easy pickings]
for them, to do this.

00:26:52
However, it develo- like, when they [do] this to [someone] that [knows] what the fuck
is goin' on, it causes [that person] to [develop] a [higher level of awareness] than
[everybody else].

Which is why I started writing the book, [Top Deck Awareness - Not News].
Right...?
_______________________________________________________________________________________
| 10/08/22 | Top Deck Awareness - Not News                                            |
| https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2022_1008_TDA_Not_News.pdf |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
So...
Let me [backpedal], a number of points that I just made.

[TikTok].
Ya know, it's basically doing the [same exact thing] that like [YouTube], and
[Facebook] and [Amazon], and et cetera and so forth...?

00:27:28
Why is it that like, when [Mark Zuckerberg] goes in front of [Congress]...

[Congress] will [believe] every fuckin' thing that this dude says, but like, 
if it's like, like [TikTok]...?
The representative of [TikTok]...?

Oh, well, ya know, if it's a [different government behind stuff],
then [they won't believe what that person is saying].

00:28:06
Yeah, it really comes down to this...

Anything within the domestic [United States]...?
Is like, [easy pickings] for these [companies] that have a lot of [followers],
[people], or [money]...?

Right...?

And then like, if you're from like [outside] of the [country], and you happen to be
like a [political enemy], like eh- to call like uh- to call [China] an enemy of the
[United States], is [not accurate], but to call them our friend, that's [not accurate]
either... they're just basically [neutral].

And with [neutrality], comes [reasons] and [motivations] for [remaining neutral].

00:28:42
Ya know, like uh- [TikTok] is allowing the [Chinese] government to get data on uh-
people in the [United States]. But- so is [Facebook], so is [Twitter], so is like a
bunch of other fuckin' programs...

It's like the best way that I can state it, is like this...

Like, some people will be like:
[People]: Oh oh oh, well [Facebook] would never do that~!
          Nah, [Mark Zuckerberg] like, ya know, told us, flat out...
          He would never ever ever sell data to [Cambridge Analytica].
          No way, dude.
          No, he is one of the [most trustworthy people] that [ever lived.]
          And I- my god, I will find [anybody] that thinks that [Mark Zuckerberg] is a
          bad guy...?
          As [absolutely reprehensible]...?
          And [preposterous]...
          However...
          Oh my god, if some company like [TikTok] goes in front of [Congress] and
          tries to defend themselves for doin' the [100% identical thing] that
          [Facebook] does...?
          Oh my god, that's... [bullshit].
          Ya know I'm gonna find [everything] that they [say]...?
          As [absolutely preposterous], and [reprehensible].
          There's [no way] that they're [not leaking data], to the [Chinese]
          government...

00:30:12
Ya know, on the [other end of the spectrum], take a good long look at the fuckin'
[devices] that everybody uses, they're all like made over in [China] and [Taiwan].

Ya know, this whole entire war about [Taiwan] is really about like, having [control]
over the [semiconductors] that are going into the [devices] that allow the [software]
to be able to, ya know, [eavesdrop on people more].

The [hardware] is a [component], of all of this.
And it's being [written off].

It's being [written off] because, I dunno.
I really don't know what to say.
The [hardware] itself.
Is being, like...

00:30:47
It's not being like seen as uh- 
the [threat] that it is.
Right...?

So, I have a number of [exploits], performed by [Asus], the [Asus Corporation].
Ya know, [Asus] like supported [Linus Sebastian] and [Linus Tech Tips] for a really
long time, right...?

And like, oh well maybe someone else caught onto this whole charade.
Maybe, like, some people should read the [document] that I put together called
["Espionage"].

Maybe I'll add it to a link in the description.
Maybe what I'll do is, I dunno.

I don't wanna really be [too descript] about like, [every single step] that I'm gonna
[take] or [make], because I know that like, the [enemy] could be [listening to me], or
my [recording], at [some point later], after I record this.

00:31:44
And over- they'll [listen] to it, and they'll be like:
[Them]: I'm gonna look for [any possible way] to [exploit] this [dude]...?
        And his [psychology]...?
        And [everything]...?
        Because I have a lot of [money], [friends], and [power]...
        And I'm not gonna let this dude [outsmart me again]...

Yeah, key word [again].

00:32:07
Ya know I might be in the [position] that I'm in right now, but- [somebody] that I
just rattled off, like, they under- they- [sorely underestimated me], and so has a
lot- [so have a lot of other people].

And, in order for me to like, continue, with this uh- this [mission of mine], I have
to basically [blend in with the environment] and [operate on the same notion] that
everybody else does.

Appear- like, [seeing is believing], ya know, because if you [see something]...?
[That means that you can believe it].

Eh, sometimes what you can [see], isn't necessarily what you [get].
Like so, what you [see] is what you [get]...?

Well, I think that like what happened was, like uh- [Linus Tech Tips], his fuckin'
channel, being hacked, is like a case of like, what you [see] is [not always 
necessarily] what you fuckin' [get].

00:33:01
Oh...
So, you're not allowed to like, [rant and rave] about like, uh- ya know, somebody
that was [successful] with their [YouTube] venture, and like...

It's basically like this.
Right uhm...

Somebody who's [older] and [wiser], had a lot of uh- [more problems] or [issues] in
their life... was [up against the ropes], [knew] what they were [up against], meanwhile
a bunch of people that were [younger] than them... 

They were [capitalizing] on an [opportunity] to become [very rich] and [wealthy] and
[successful], and they ignoredVthe person who was [older] and [wiser], and had a
[lesson] to [teach people].

Right...?
And what happens is throughout time, this [pole position] is constantly like,
[shuffled around].

00:33:56
And every once in a while...?
Like, somebody [really important] or [famous], will wind up being [victimized], and
then at that point, people will be like:
[People]: Oh my god... 
          Oh my god...
          There's no way, that [Linus Sebastian] would ever let his [Tech Tips] 
          channel ever ever be hacked by people...
          No, he's... 
          He's like the [Tech Tips] master.
          He knows what he's doin'...
          He employs a whole bunch of people...?
          And, you're out of line to think that [Linus] would ever do, would ever like,
          uh- miss something [critical]...

00:34:46
Yeah, no uhm...
The fact of the matter, is that [a lot of people miss things] that are, like, right in
plain- [hidden in plain sight]. Ya know, like uh, the things that uh- [Mental Outlaw]
talks about, like...

He talked about this recently, uh- where people like uh-

What was it, uh- the uh... [NFT God]...?
Like, lost the uh- picture, uh- lost all of his shit...?

It's like:
[ML]: [NFT God], he's like, lookin' for like, [OBS], recording studio software...
      And when he downloaded it...?
      It downloaded... something, [malware] onto his machine.

00:35:31
Right, and so like, one thing to [consider] is, what if like,
[everything is malware]...? If you treat [everything] as if it [might] be malware...?
And you take [certain security precautions]...?

It's gonna be [a lot harder] for these [high level attacks] to [get you].

Right...?
Ya know, like, [treating everything] as if it COULD be [malware], is pretty [difficult]
to do, but- ya know with the [tool] that I've been [building], that like spins up like
a, ya know, a [network] of [machines] or a [domain]...?

It's as if like it- it just [refreshes] the [entire structure] of the [domain] and
whatnot. Ya know, if it's [compromised] at all...?

[Wipe and reload everybody's permissions].

00:36:09
Right, and then like, also... [measurement] of how to- [how to measure] when a
[network] is [compromised] is [pretty difficult to do], because uh- everybody's uh-
mind, is like a [lambda box].

Or a [lambda function].

Where like, you don't know what the fuck is goin' on inside that persons mind, all they
have to do is just [keep something to themselves], and [never talk about it with other
people], and then uh- at some poment- at som- at some [point] or [moment] where they
can just, [cash in on the knowledge that they have], to do something really [sinister],
[shitty], [trollmeister-like], and uh- [destructive]...

Ya know...?
They're gonna t- [they're gonna cash in].

00:37:00
And that- [that person could be anybody].
It could be anybody...?
It could be uh- somebody behind, uh- somebody within a [classified file]...?

Like, I know some people will think it's fuckin' [preposterous] to think that like,
uh- the [Central Intelligence Agency] has a [classified file] somewhere that's named
somethin' stupid, like uh- ya know, [Whole Room Water-Cooling Project].

And then, in this [classified file], [Whole Room Water-Cooling Project]...?

Is basically like, we're gonna li- we're gonna watch [Linus Sebastian]...?
And we're gonna just take out his [Tech Tips] channel, and really screw him over...

00:37:46
And then like, ya know there'll only be like (2) people in that classified file.
[Whole Room Water-Cooling Project].
Ya know...?

It's like, what the fuck...?

I really don't think that like, they deserved what they went through, but- at the same
time...? Like, this is what it- what I mean by like, people being [naive]. 

Like, all of the work that they did...?

Was totally trumped by something [very small] and [minor], right, but that [very small]
and [minor] thing allowed for ALL of their [hard work] to be [taken from them],
[forcibly], right...?

00:38:18
Ya know, uh-
On the other hand...?

Ya know, think about like uh-

Think about ways to like, uh- [aggregate] like uh- someone's [suspicions] or [intent],
to [do something], could it have been like, as easy as like, an [employee] like took a
[cash payment] from [somebody]...?

To wipe out [Linus Sebastian]'s fuckin' [Tech Tips] channel...?

And now, like he's gonna have to [pace back and forth through the office], like, he's
prolly doin' that.

He's like [pacing back and forth through the office], wondering how the fuck he's
gonna manage to pay his [rent], or his [bills]...?
Or take care of his kids, or his family...?

Ya know, because like, his fuckin' revenue has just been shunted to a fucking halt,
right...?

They were livin' life on easy street for a while, though, I really wouldn't call it
easy street so much as uh- like, they were being pretty like, uh- short sighted.

00:39:29
Short sighted is a way to put it.

So like, if uh- if my channel, my (1) channel, or my multiple channels were like uh-
attacked or commandeered...?

It's not gonna set me back anything.
Because, number 1...
A lot of those videos I still have backups of.

So, if [Linus Sebastian] isn't an idiot, [he's gonna have backups] too.
Because, ya know, he did like, go around and like, [building servers] for uh- like
what the hells her name... ah- I can't remember.

00:40:06
Uh- building [backup servers] for people.
And uh- bulding storage arrays.

He's got backups of the shit.
The problem is like, a lot of his content, is garbage.
(And I mean specifically the unlisted videos)

And he needs to hit the fuckin' delete button on it.
Ya know, I need to do the same thing too...
With some of my content.

Some of it holds up longer than other content.
Right...?
But also, sometimes you really have to go back to the drawing board, and reinvent the
entire thing from top to bottom.

00:40:44
It's just basically uh- the idea that I came across a while back, uh- [Mental Outlaw]
sounds like the type of dude that understands a lot of these things, but I'm not gonna
make uh- [speculations] or [assumptions] about like uh- what he thinks or knows or
whatever, right...?

00:41:03
If anything, uh, he presents himself as a [very sophisticated individual], much like
[Louis Rossman] does...? And uh- their uh- their [insight], is [pretty realistic],
believe it or not.

Ya know, you're not gonna run into- like, when you run into somebody that like never
ever swears, and is always worried about like, [almost] uttering a swear word...?

You really gotta be, uh- you gotta be careful about like, what sort of things their- 
that they have in their closet.

What sort of [skeletons] that they have in their [closet].

00:41:39
Ya know, when it comes to like uh- [Michael Stevens] or uh- [Adam Savage] or uh- 
[Neil DeGrasse Tyson], or like a bunch of these other smart people on [YouTube], 
like I'm not thinkin' that like, they went around like having [dog fights].

Ya know, having their [dogs] [fight to the death]... And like, ya know, they never 
like- it'd be like a [comedic skit] in my mind, is like, [Michael Stevens] caught 
for having an [unlawful dog fighting contest] with [Adam Savage].

00:42:13
And then they'd be like:
[Stevens]: Well, [Adam]...

And then [Adam] would say to [Michael Stevens]:
[Savage]: Well, [Michael]...

Or uh- [Michael Stevens] would say to [Adam]:
[Stevens]: Well, [Adam]...

And then uh- they'd be like:
[Them]: Well, we shouldn't have had this illegal [dog-fighting] contest...

And then, the other will be like:
[Them]: Nah, we shouldn't have had that at all, cause now look where we're at...
        Look where we ended up.
        Ya know...?
        Maybe having our dogs fight to the death is a bad thing...

And then they're like:
[Them]: Yeah, it is a bad thing, we shouldn't have done this...

00:42:49
Like I'm not thinkin' that at all, but- it is a [comedic skit], that I just thought
up on the spot. Right...?

I don't think that people like them, are goin' around havin' fuckin' illegal 
dog-fighting contests and stuff... right...?

But- ya know, heh, I remember seeing [Michael Stevens] as a guest on [Joe Rogan]'s
show. And [Joe Rogan] was like, havin' a conversation with [Michael Stevens] and he's
like:
[Rogan]: Fuckin', da da da da da...

And then as soon as he said the first F-word...?
You see the look on [Michael Steven]'s face...
Like "Ah... damnit, now I can't..."

Ya know...?
Like, there are people in society that do not like when [profanities] are uh- 
[uttered], because it prevents a [whole target audience] from being able to [enjoy]
the [content].

Ya know...?
[That's what they want].
They want [all] of their [content] that is [recorded], to be [consumed by people].
[Of any age].

00:43:48
But- it causes the content to feel [unrealistic], (because it sanitizes the concept
of being [informal]) and so like, I am gonna like segue out of the [original content],
uh- subject of uh- what I was talking about for a moment, for a shade.

The idea of [innocence]...?
Has been [perpetuated by people] that want to [limit] the [first amendment] of the
[Constitution]. And, [people's right] to [free speech].

00:44:14
Now, I don't know how exactly I feel about like, the idea of like, people on
[Nickelodeon] or [Cartoon Network] like, uttering off [profanities] like "Fuck this",
"Shitbag that", and "Holy fuck".

Right...?
I don't know how I feel about that.
But at the same time...?

This is [America], and it is [pretty realistic] for [people] to [occasionally] toss
around an [F-bomb]. Ya know I had this uh- coach in high school, his name was [Coach
Careese], and anytime you ever uttered off like, the F-word...?

He's like:
[Careese]: I heard that [F-bomb], dude...
           Time to do a few laps.

00:44:55
And then the person who threw the [F-bomb], would be like:
[Person]: Fuckin' god damnit...

And then [Coach Careese] would be like:
[Careese]: Uh- make that [twice].
           Ya know...?
           Run around, do a few laps twice in a row now, dude...
           Second [F-bomb]...
           You wanna go for a hat trick...?
           You wanna go for a third [F-bomb]...?
           Go right ahead, dude...
           You'll be runnin' for the whole entire class.

And then the kid would be like:
[Kid]: Da- eh.

And then he's like:
[Careese]: That was almost a [D-bomb] right there, dude.
           You're really...
           You're pushin' your luck...

00:45:28
Right, so like, [Coach Careese] would have that conver- bleh. Wouldn't exactly have
that [verbatim] conversation with somebody, who like, tossed around an [F-bomb] here
or there...?

But like, the [idea] that I'm getting at, is this...
Right at [some point] people grow up and they become [adolescents], and they're gonna
hear the [F-bomb] tossed around a lot anyway.

Right, like my kids, my son and my daughter, uh- I know that they heard these words
on like [YouTube] and stuff. And sometimes I would hear, like my son say an [expletive]
and I'd be like:
[Me]: What the hell did you just say, kid...?

00:46:07
The thing is, is like, the [kids pick up on this] from their adul- from [adults].
Ya know...?

Anybody who like, doesn't swear at like, claims that they [never ever swear]...?
[They're lying].
[Everybody swears].

Ya know, maybe there is like a [limited selection of people] that [never ever swear],
but the idea of [swearing], is, it causes the [words] that are stated to be like,
considered [reprehensible] and [deplorable] and and ru- like, [bad]. 

Those words are [bad]...

Yeah, that's the [connotation] that you get.
[Saying words] like [that] is not gonna [kill people].

But- ya know, let me bring this all around back to the [original point].

00:46:53
Ya know, the [original point] that I was gonna make is...?

That, [you piss somebody off], they're gonna find [some way] to [screw you over]...
Number 1... it'll come out like uh- as news like [Linus Sebastian]'s [YouTube] channel
got [hacked].

Or like, [John Hammond]'s [YouTube] channel got [hacked]...
Or like, uh- ya know I wouldn't be surprised if like [Dave Bombal]'s fuckin' page got
[hacked].

Ya know, [Dave Bombal]'s a guy that used to work at the [National Security Agency],
he does a lot of cool stuff too...? So does [John Hammond].

These guys, uh- they've been in the field for a pretty long time.
Uhm, probably in the- the [cybersecurity industry], far longer than I have...

Right...?
I really wouldn't consider myself uh- the same sort of [cybersecurity experts] that
they are...

Because, the fields of study that they have studied, like, have to do with uh- [CVE]'s, and 
[reverse engineering] like uh- [code] and stuff...?

And- basically a lot of the concepts that they cover, it's basically [synonomous] with
the amount of things that I cover, and I [programmatically build]...

00:48:15
And I think a lot of people get [lost in particulars] when really, you wanna start
thinking about like, [aggregating] uhm, making [generalizations] and stuff.

Ya know, like, [artificial general intelligence] is ya know, the idea that like,
[artificial intelligence] can [think] basically like a [human does], where they
[generalize stuff], and they [break things down] and they [aggregate results] based
on what they can [deduce logically], or [make speculations] and do [detective work],
and [investigate stuff]...

These are the things that any p[olice officer], [lawyer], [doctor], uh- these sorts
of people in uh- [bureacracy], ya know, even [politicians] do this to [some degree].

They have to do various levels of what I just said, in order to [continue] doing what
they do.

00:49:07
Right, and uh- are they gonna get into the nitty gritty of like, [binary] and
[hexadecimal] and like, uh- [obfuscation] and [deobfuscation], and uh- [introducing 
malware] and [threading], and [runspacing], and [parallelization], and like,
[virtualization] and [running tasks across multiple machines] and [clustering] 
and uh- ya know, [database management], and like, [graphical user interface design] 
and stuff...?

Nah, prolly not.

00:49:39
Are these things that are covered on like, [Linus Tech Tips]...?
Maybe on a [very minor scale].
What they do, is they focus on the [hardware], typically.

But that doesn't mean that they don't occasionally have something to say about like,
[software], like they'll talk about like [Terry Davis] for a little bit, or they'll
uh- [review somebody's code]...?

Or like, what they've done and everything...?

Really, at the beginning and the end of it, is that uh- there's a [lot] of people in
the world that [know what the hell they're saying or doing], and [somebody] wants to
find a [way] to [control everybody].

00:50:13
They wanna find [some way] to [control everybody].
But it's like a [supertask].

Ya know, taking a page from [Michael Stevens].
It's like a [supertask], to be able to uh [control everything].

Because, if you [control everything]...?
Then basically, you would be [god].

And being [god] means that, you could no longer be [human], you would be- you'd either
be [all knowing], or [all evil]... Or, [all good].

Ya know, I've talked about this before, the uh- the number of topics that I'm talking
about...?

It's mainly because uh- [after I started my company], I started to [invest] a lot of
[time] and [thought] into how these things like, [correlate].
Right...?

It's gonna sound rather [bonkers] to someone who's [not paying attention]...

It's gonna sound like I'm uh- [bantering], or what's uh- [babbling].
It's gonna sound like I'm [babbling].

00:51:15
But- ya know, given enough [thought] and enough [distancing] from how people
[typically] think...? They're gonna realize how like, [astute my observations 
skills really are], and they're gonna start to make the [same sorts of correlations]
at [some point] in the [future], when they [review] a [number] of the [content], 
the [amount] of [things] I've [covered] in my [content].

Right...?
So, allow me to [spin things back even further].
Back to the [original point] of [discussion], right...?

Was it even a [person] that broke into [Linus Sebastian]'s account, ya know, what
[evidence] is there that suggests that it was a [browser thing]...?

And not necessarily like uh- ya know, who came up with the [evidence] to say that 
[that] was the [intrusion route (attack vector)]...?

Ya know, how do you know that it wasn't a [quantum computer] that [broke] the
[encryption] of the [password] or the [login], or whatever...? 

(Apparently LTT covered this after they got their channel back up.)

00:52:10
And like, it happened at [Google]...?
Much less, at uh- [Linus Tech Tips]...
Maybe the problem was at [Google]...
Not at [Linus Tech Tips]...

Ya know, what if that's the case...?
I guess it really comes down to this...

Uh- the coverage of uh- these channels, right...?
Um, [some people] are gonna get [lost] in the [particulars].

However, what I can say for [certain], is that [some people], some [shady
trollmeisters] out there somewhere, they're performing [high level attacks] that are
[extremely sophisticated], and, some of the [residue] that they leave behind, is just
for [appearances], to make it, to be like a [red herring].

00:52:56
Right...?
So like, it very well could've been like an attack by the [Russian] government, 
to attack [Linus Tech Tips] channel.

And much less, the [CIA].
And they wanted to make it [appear] as if somebody had used a [program] to uh- like
uh- to rick roll someone into clicking on a [link] that went somewhere...

However, ya know, that's just a [speculation].

These are the sorts of- these are the sorts of [speculations] that I make when like,
not all of the [evidence] is there...? And I don't have a- [access] to the [resources]
that they had, in order to make the [investigation] that they did.

But- one of my [other observations] is that, even if you have a [whole bunch of
evidence], some people are gonna take a [really long time] to [figure things out].

So, if the channel got hacked, like, and the news broke about it (24) hours ago, or
less than (24) hours ago, and like, there's already a whole bunch of [information]
or [adamant conclusions] about what happened...?

[Some people are bullshitting each other].
And uh- ya know, um, for me to come right out and say that that's what's goin on...?
Ya know, uh, that's what causes me to be like, [branded as an outcast], or uh-
[delusional] by people.

Because, ya know, [I am correct]...?
But...?
If people admit that [I'm correct]...?

Then it's gonna cause their [reputation] to [tank], [considerably].

00:54:30
Right...?
Right.
So, the idea of [DeepFakes].

From here on out, people are gonna have to deal with the idea of like, [getting a
phone call] from [somebody] that [sounds] like the [person] that they would [normally
talk to].

But- the [way] that they're [talking] is gonna sorta sound a [little bit different
than usual], and then they're gonna sound a lot like the [Terminator] talking to
[John], in the movie [Terminator 2: Judgement Day].

And then like, uh-
Ya know, [Arnold Shwarzenegger], the [T-800]...?

He's like: 
[T-800]: Here, give me the phone...

And then he pretends he's like [John Connor], using the voice and stuff...
And uh- then uh- the Terminator says:
[T-800]: What's the- What

...covers the phone, and he's like:
[T-800]: What's the dogs' name...?

And then, [John Connor] says uh- I can't remember what the dogs' name is...
And then like, the [Terminator] says the wrong dogs' name...?

He's like:
[T-800]: How's Woofie...?

And then the [T-800] (meant [T-1000]) she's like:
[T-1000]: Woofie's just fine, honey.
          Woofie's just fine...
          Where are you...?

And then the [T-800] hangs up.
And then he says:
[T-800]: Both of your parents are dead...
         And maybe the dog is dead too...
         Ya know...?
         It's time to go.
         Don't ever go back there...
         Because, the [T-800]...? (meant [T-1000])
         Was the person we were just talking to...

00:56:08
Right...?
So these are the things that were foreshadowed, as far back as like (1984)...
Well, [Judgement Day], [Terminator 2: Judgement Day] was in like (91) I think...?
But-

The idea I'm alluding to, is that uh- [mimicry].
Being able to [mimic] one another, to the [degree] to where like,
you really can't tell the [difference] between [one thing] or [another].

00:56:33
And so, [Michael Stevens] talks about this in uh- like the ship of [Theudi]- it's not
[Theudissises] [Theudiss], [Theudidisys Trap]- uh- it's not that, uh- it's basically
like uhm, you take- you have- you start with a ship, right...?

And then over time, you slo- you [slowly change every part of the ship].
Is it [still] the [same ship]...?

Well, [no] it's [not] the [same ship].

It [IS] the [same ship], because it has [changed]...?
But it is [NOT] the [same ship], because it has also [changed]...

00:57:06
This is the idea of like, [humanity].
And the [population].
Ya know, as uh- [people are born]...?

[They live], and then, [people die].
And this is basically is it still the same [America]...?
No, it's not.
But- it is.

It's a- [contradiction] or a [paradox], right...?
These are sort of- these are the things that I sorta covered...?

Like in the video where I blasted [Linus Sebastian], or [Linus Tech Tips], when they
banned me from their forum, back in like uh- [February] or [March 2019]...?

00:57:40
Right, this is (4) fuckin' years ago, right...?
So, here's the thick and thin of it.

[People should not be trusted as easily as they are], mainly because, in order to
[earn people's trust], you have to give them a [test], where you can [know] for
[certain] whether you can [continue] to [trust them], or not. 

(And then continue to give them this test over time, not just like once, and that
test lasts forever.)

And in order to [trust people], and to know they're [telling you the truth]...?
They have to [fear] something.
Yeah, they have to [fear something].

Whatever thing is that they [fear], ya know, it's gotta be like uh- it's gotta shift
around, ya know...? Are they gonna be [afraid] of the [notion] of [death] in the
[immediate vicinity]...?

00:58:29
Well, if that's the case, then they're like [afraid] of that [person], and so like,
that's gonna [affect] their [responses], and they're not gonna be [trusted], because
if they're gonna be- if they're [afraid] of [dying], then [of course they're gonna
fucking lie].

But ya know, if it's [fear] of [losing] the [things] that they [have]...?
Then, [they're gonna tell you the fuckin' truth].

Well, I dunno.
I mean, it's [difficult] to say for [certain], but [anywhere] in that [range] of uh-
that uh [spectrum] of [possibilities], needs to be [considered] because like, uh-

Ya know, [T-800]'s (meant [T-1000]'s), sounding like [Sarah Connor]'s- uh- 
[John Connor]'s stepmother.

Ya know, [John Connor] was about to like, go right into a [trap] and [get] 
himself [killed], ya know cause the [T-800] (meant [T-1000]) was able to
[mimic] his [stepmother's voice].

It's really [that simple].

00:59:31
[DeepFakes].
Ya know, [Michael Baker], talkin' with [Joe Rogan].

Goin' back to [Joe Rogan], here.

[Deepfakes] and [artificial intelligence], they're on a [scale] of [magnitude]
that is [absolutely frightening], and it is [causing people] to [trust something]
that [doesn't have to explain itself] at all...?

It doesn't have to be- it's just [openly trusted], [artificial intelligence].
Ya know, [why] is it [openly trusted]...?

Oh, because a [bunch] of [people] like, [made it], and they were [responsible] in the
[way] they went about [making] that [artificial intelligence].

Ohhhh, they were [responsible] in the [way] they went about [creating] that
[artificial intelligence]...?

Yeah, yeh, they were [very responsible], in the [way] they went about,
[creating] that [artificial intelligence].

01:00:24
Well, what if like, the thing that caused like, [Linus]' page to be hacked, was like,
something written with [ChatGPT] and was like:
[Someone]: I wanna like, destroy [Linus Sebastian]'s [YouTube] channel, 
           and then like, ya know, [scam any of his viewers], into like, you know, 
           paying me, [money], for uh, using this exploit...

And there you have it, the [T-800] goes right ahead and does what you just specified.

You know, in the [virtual world], the [T-800] like, successfully killed 
[Linus Sebastian] and his whole crew, and like, everybody that like, went 
to go watch his channel and stuff.

Ya know, in the [virtual world].
In the [real world], that didn't happen.
But- ya know, these are ideas of like [tricks], [traps], and [booby traps].

Ya know, uh- I might be like, uh- [overanalyzing this situation].
[I tend to do that sometimes], but [at least I know that I do that]...?

But what I can tell you, is that the [artificial intelligence] that we're doing...?

[They do that too].
They... the [artificial intelligence]...?
It'll go right ahead...?

And it will [overanalyze every single possibility on the spectrum].

01:01:50
Ya know, back in the day, like [IBM] uh made this uh- computer program that uh-
I can't remember exactly what the hell's his name (Gary Kasparov), uh- the [Deep Blue]
was the name of the program, and I think itr was like (1998)...?

And uh- like, this [artifiical intelligence] then, like struggled to beat a [human
player], or maybe it didn't struggle at all, I can't remember the [specifics], I'd
have to research it again. But uh- ya know, like now...?

It's like, [really easy] for like, [artificial intelligence] to beat a [human],
because like, I dunno. It just- it is.

Ya know, we- we've passed the point where like uh- the [Turing test], or whatever,
this is something that uh- [Dr. Derek Muller] covers on his, uh- [YouTube] channel.

And sometimes, he'll occasionally have like a uh- cameo...?
With [Michael Stevens] on [VSauce], about the idea of [random].

And then like, [Michael Stevens] will be like:
[Stevens]: What is random...?

And then like, [Derek Muller] will be like:
[Muller]: Did you just say "What's random...?"

And then, [Michael Stevens] will be like:
[Stevens]: Yeh yeh yeh, I did, I just said "What's random...?"

And then [Derek Muller] will be like:
[Muller]: Well, we're pretty sure that random's just like a number pulled out
          of the heavens... Ah, you know, anywhere between 0 and whatever...

And then [Michael Stevens] will be like:
[Stevens]: Well, it could also be like a [negative number], too, dude.

And then, [Derek Muller]'s like:
[Muller]: Wow, holy crap, yeah you're right...
          It could be a [negative number]...
          Could also be a [decimal point], too.
          Like a float- a [floating number].
          And then, like, you know, you could have an [infinite number] of
          [floating numbers]...?
          And you could have like an [infinite number] of [non-floating numbers]...?
          And then like...

01:03:49
Ya know, like they have like, [revisited] many of the same thing- [concepts] and
[subjects] that they've talked about, not unlike how I do, in some of my [rants]
and stuff.

Or, my [lectures].

Ya know, I'm gonna [consider] this as a [lecture], even though like, I don't have a
[doctorate] in like, uh- any of the [fields of study] that I've [mentioned], what I
can say is that, like, maybe [sometimes], like having a [doctorate] prevents people
from [not being closed minded].

Ya know, li- as soon as you have like something in whatever...?
Then, you start to [focus] on a [field of study], rather than [generally], and it
causes your [ability] to [learn things] to [reduce]. A lot.

01:04:33
Whereas like, if you're somebody like [Derek Muller], you're go- or uh-
[Michael Stevens], you're gonna try to [expand] upon the [work] that you've 
[already done], right...?

And then [Michael Stevens] will put himself into a room for about [(3) days], with
only white walls, and a ya know like a [limited amount of things] that he can [drink]
or whatever, and he needs to [stay] in that [room] for like (3)- [(72) hours], dude.

And then like, we'll call that [Mind Field], or uh- I think that's what it was called.

01:05:09
But anyway, uhm, and then [Derek Muller] will be the narrator of like a- uh- a
[Uranium] uh- documentary.

And he talks about the difference between [Uranium 235], which is lame...?
And then [Uranium 238] which is needed to make [nuclear weapons] and [bombs] of
[armageddon quality], and grade...

And you know, [Michael Stevens], and uh- [Derek Muller], they'll have to have like
[sidekicks], every now and then. Ya know, like you'll have uh- you'll have like 
[Kevin] from [VSauce2] show up, and be like:
[Kevin]: Hey, the idea of like, uh- [money] and stuff...
         If uh-

I can't remember exactly uh- the number of times that like, [Kevin] has come out
with basically, it's an [alteration] of the [same idea], um, like you go into the
[restaurant], and you give the [waitress] like a (5) dollar bill...?

And then you wanna [break the bill], and then like, you try to [share] it with your
[friends], and then like [somebody] wants to [cover] their end- [their end] of the
[bill]...?

And then, oh- what the hell...?
Is this- somebody somehow got the [wrong amount of change back].
What the hell...?
What the hells that all about...?

01:06:21
And then he also talks about like, the idea of like, how like, people will invest
like uh- all of their uh- uh- their [time], or their [entire life] into what they've
invested], like they become like, I dunno. They become like, [property] of the thing
they [invested into], or their [life]... I dunno.

I'd have to watch the video again, and like, [take notes].
And then [write up a document] and then, and then like uh- not sound like I'm sort of
like, uh- reaching. Like uh- the idea that I'm alluding to, is that [occasionally]
they'll have [sidekicks].

And then they'll have like [Jake].
Who like, talks about [time].

[Jake]: What is [time]...?
        [Time] is, a thing.
        Or, or IS it a [thing]...?
        Is it a- is it a [place]...?
        [Nope]. It's not a [place], it's- it's uh-
        It's [WHEN].
        Between like [THEN]...?
        And [now]...
        Or, back [then]...?
        And [then], at some point in the- in the [future]...?
        Is [NOW].
        And then [NOW] is between [then], and [then].

And then, then you like, jump through a [wormhole]...?
And then holy crap, there's [Jake] from [VSauce3], again, talking about the 
[same thing].

Ya know, these are [Michael Stevens]' sidekicks.
But then also, you've got like [Derek Muller] who's got [his own sidekicks], 
like [Adam Savage].

Well, he's not really a [sidekick], 
he's more of like a [mutual sidekick friend of doom],
that went around [busting myths] way back in the day...

Basically became the [predecessor] in the uh- [inspiration] 
for these guys to become the people that they are today.

And uh- you know, uh occasionally [Jamie] might make an appearance here and there...?

But- I dunno, then there'll also be [Diane], the [Physics Girl] and [she'll show up]
and show, who knows, she'll talk about some uh- something related to [math], and
[physics], and [Boson quarks]...?

[Particles]...?
[Boson particles]...?
[Higgs-Boson particles]...?
[Quarks]...?

And uh- [forces]...?
And gra- I dunno.

01:08:30
It's basically the same thing that like [Derek Muller] talks about.
Ya know...?

These guys, they all talk about like, [similar subjects].
So they GOTTA be friends, right...?

They GOTTA be, cause, the subjects they talk about
is rather [close], and [mutual] and [friendly]...

Ya know, it's like [Linus Sebastian] will have [his own sidekicks], not just
on is [team], but he'll also have like [BitWit], [Pauls Hardware], and like, 
and then they'll have like basically a [competitor]...

A competitor like [Steve Burke] from [Gamers Nexus].
Except, [Gamers Nexus] doesn't fuck around, dude...

Nah, they get into the nitty gritty of like, every single little detail about a
[game], or a piece of [hardware], and like, you'll learn [more things] than you
really wanted to know about, by listening to [Steve Burke] like, talk about like, 
uh- ya know, uh- 

What's his favorite phrase...?
[Within margins of error]...
[Within margins of error]...

01:09:27
And then you'll have [JayZ Two Cents] who will occasionally come around too, and
then like, he'll like, ya know, solder like, [use the worst possible method] to
[solder] a [chip] back onto a [graphics card], in order to get it to work, and not
[throttle itself back] to like, I dunno, (15) frames per second, or something... 

And then, [Louis Rossman] will get [pissed] about it, and he'll make a- a [return
video] about that... Right...?

And then all the while, [Joey Salads] is out there somewhere, along with uh-
[Ed Bassmaster], ya know, makin' videos where they just [walk around] and
[fuck with people]. [Constantly].

[Joey]: Hey, check it out, this is- [you wanna buy a brick]...?

And then the person's like:
[Person]: Uh, yeh.
          Let's [buy a brick].

And then he'll be like:
[Joey]: Alright, go get your money and meet me over there...

And then uh- [Joey Salads] pulls the whole brick prank...
And then, uh- ya know, [Ed Bassmaster], he'll uh-

He- he like, started doin' this many, many years ago, but-
he would just go around and like:

[Ed]: Look at it, dude.
      Would ya look at that...?

Or uh- what was his other one...?
He's got a few characters he does...

01:10:38
But uh- anyway, uh- the reason why I'm covering all these con- uh- [concepts] in
all these [topics] is, because [artificial intelligence], they're gonna have to
[understand], like, the- in order to like, have an [understanding] of [general
artificial intelligence], or- [artificial general intelligence]...?

They're gonna have to like, uh- [cover all these topics], right...?
And then like, the- [artificial general intelligence] is gonna have to figure out 
[what is it], that is like, that causes these people to be like, [similar], right...?

Because like, the [artificial general intelligence] is much like a [child] that
[grows] into a [man], that eventually becomes like [William Sidis], and then people
will think that [William Sidis], was fuckin' crazy... right...?

01:11:25
People thought [William Sidis] was fuckin' crazy. Ya know, when he was a kid, 
he was like- he was [branded] as one of the [smartest dudes] that [ever] lived. 
Times (10).

And then, like, he spoke like a dozen languages by the time he was (3)...?
And then uh- he went on to become one of the most like uh- 

Ya, I don'- he went on to become like really important, right...?
And then at some point along the way, like, [he realized] that [people] were just-
lying sacks of shi- [Lying sacks of shit]...?

And uh- ya know, it all comes down to like, [principle] versus [personality].
And, that is the [point] at which the [artificial intelligence] determines that [we],
[ourselves as people], cannot be [trusted].

No, [it doesn't matter how well built] the [artificial intelligence] will be,
or [artifiical general intelligence]...?

What we, as a species, have a [serious problem] with, is uh- being able 
to [take accountability] for our [mistakes], and uh- to [prevent] the
[unmitigated loss of life] that [doesn't need to be lost], ya know, like...

01:12:38
We don't have this [capacity] to [understand] when and where [people in our society],
they're basically [enforcing tyranny].

You know, we give this [artificial general intelligence] a [dictionary] to read from, 
and they [read the definition to tyranny], and they [see] so many [actions] that
[people] are [committing], and like, the [human race] is a bunch of [evil fucks].

And that's- that's the reason [why], like, this [continues] to [happen]
[over and over]. It's [not] because [the entire human race] is a [lost cause],
it's because like the [way] that [humans] are teaching like, the [children] to
[grow up]...?

Right...?
It's not [focusing] on the [whole entire picture].
It's [focusing] on a [very small], uh- [portion of the picture].

01:13:22
Right...?
And what happens, is that uh- [people develop blind spots], and then they [grow up]
and they uh- spread their legs and their roots, and they become [indifferent] to like
[their own failings] and stuff...

Right...?
So like, what separates [me] from [most people], is I'll try to [consider] like
what is [my personal failure] in life, ya know I try to like, think about like
what I was given...?

And the number of times that I tried to make a name for myself...?
And like, some people just continue to brush me off, like 
"Oh, you're just a douchebag", right...?

01:13:58
That's what happens.

And the reason why it happens, is because [somebody somewhere], who's a lot more
lucky than me...? Thinks they're [more important] than me, and so, they continue
to do this to me, [and other people]...?

And that's just [the way it's always been]...
And then, they- [in their minds], it'll [never change].

Except, that's the reason why the [Constitution] of the [United States of America]
was written, and- uh- after the:
[+] [Declaration of Independence], and the 
[+] [American Revolutionary War], right...?

01:14:22
Some people thought it was ok, to like, continue to think this [stupid line of 
reasoning], where like, [certain people] are more important than other people,
and [that'll always be the case], but, ya know, [sometimes] what'll happen, is 
that [someone] who [should] be [really important]...?

They're given- they're [branded] with a [sense of notoriety], and uh- [people]
have a [really hard time] being able to [withdraw] from that [whole mentality],
[completely].

Why...?

Well, I dunno.
Maybe at some point, the [artificial intelligence] will teach people, uh- how to
[live better lives] or whatever, and then like, we'll have a [future] where uh-
we can have like uh- ya know, people from like the [Star Trek Enterprise], like
warping in and out of space-time...?

Going warp speed...?
And then, uh- ya know, being in flying uh- space ships, and then like having uh-
like a little hand held device that [innocculates disesases], and having [no concept]
of uh- [money], it's just all like a [sharing economy].

01:15:37
Right, these are things that like, some of these things are uh- relatable to
what uh- uh- [Professor Jeremy Rifkin] uh- talks about, right...?

[Zeitgeist], or like uh- ya know, [The Third Industrial Revolution].

And [Jeremy Rifkin] is a really smart dude. And a lot of people 
should really take inspiration from some of the things that he says.

Because, ya know they fall in line with the things that [Elon Musk] says.

01:16:09
And uh- for what it's worth, a lot of the things that I've mentioned and rattled
off in this recording...? They have very little to do with like, [Linus Tech Tips]
channel being hacked or whatever, but-

Ya know, I provide a whole bunch of backstory for [other components], as to uh-
things that may be [plausible], or [tangible], and I think the [level] of uh-
[accuracy] that I [attain], when I make these [recordings] and I talk about like,
a bunch of OTHER subjects, not just the most, like, relative subject...

It causes people to be like, uh- [concerned] with like how [artificial intelligence]
might approach the [same sort of rhetoric]. 
Ya know...?

Some of my [ranting]...?
It's gonna come ou- it's gonna across as [sounding] like [babbling] and [psychotic]
and everything, (cause some people are morons) but it is literally the [same way]
that [artificial intelligence] goes about thinking about stuff.

01:17:08
They just- they think about a whole bunch of concepts that might be somewhat
related...? And they try to make [logical deductions] and use [mathematics] to
come up with like, [formulas] and and uh- [probability matrixes] and things like
that...?

Yeah.
At [some point], like uh- people have to consider that the 
idea of uh- [personality] over [principle] is [fuckin' stupid].

And, uh- at [some point] in the future, [principle] WILL become 
more important than [personality], ya know, it always has been...?

But, sometimes like, people... they hav- [they play favorites].
The- the police, they like to say:

[Police]: [Don't play favorites with people]... 
          [Don't play favorites].
          Ya know...?
          You're [playin' favorites] with people, you're not supposed to do that.

But the police do that.
So do like, people in the government.
So do people in general.

01:18:03
[People play favorites].
And then like, what you're left with, is that like, [people constantly contradict
themselves]. They [lie] to each other, and [themselves], on a [constant basis],
and they [lie] about like, doing that...

Some people do that more than others, but [everybody] does this,
it's just a [manner] of like uh- what can be [measured].

Ya know, like the [aloofness] of the staff at [Linus Tech Tips] is the reason why
I began to record this, because I saw a video that [Mental Outlaw] came out with,
where he's talking about how [Linus Sebastian]'s fuckin' [YouTube] channel got 
hacked, right...?

(Problem is, these attacks are getting a lot of people, so it
might not be aloofness so much as extremely sophisticated attacks)

But then, like I put my own like uh- [creative twist] on things, in order to
[describe] like:

[Me]: Ok, so in order for [all that content] to have been [reviewed]...?
      And like, the [unlisted content] to be like, [listed]...?
      And like, uh- 

Ya know, that's like, [years worth of content].
Like, I doubt that all that [video] is gonna wind up [accumulating] like an
[entire several years] of like, somebody's life, but- think about it like this.

01:19:18
If the average video is about (30) minutes long...?

Uhm, then uh- what you're gonna be left with is that, it might've been somebody
that worked at [Google] that had something to do with his account being hacked,
and other people's accounts being hacked...

Ya know...?
Like, [you can't rule things out].
A lot of people, they'll be like "That is absolutely preposterous~!"

...in the same way that [Mark Zuckerberg] would never ever sell [Facebook]'s
user data to [Cambridge Analytica], no no no, [he said] that [he would never
ever do that], and he has [integrity].

If there's [anybody] in the [history] of the [United States of America] that-
that, has the [most integrity] of all time...?
It's [Mark Zuckerberg].

Ya know...? [Cambridge Analytica] was YOUR fault.
Er, not- not [Mark Zuckerberg]'s fault, but it was- it was [everybody elses' fault].
Everybody else made [Mark Zuckerberg], sell [Facebook]'s user data to 
[Cambridge Analytica].

Ya know...?
It's [everybody elses fault], not [Mark Zuckerberg]'s fault... that like, 
[The Social Dilemma], like focused on like, how people, like young little girls,
were like attempting to [commit suicide], because they felt [inadequate] and
[inferior] to their [classmates] or their peers, in [Instagram]...?

Usage of the [program] caused people to like, wanna [commit harm]
to themselves, ya know it's like, what the fuck, dude...?

01:20:51
Ya know, [all these things] have [something to do with one another].
I'm being [sarcastic] in [certain portions] of what- my [rhetoric].

Right...?
And when I [write] some of this stuff, I know that [some people], they're not
gonna like, [understand] like, [when] and [where] I'm using [reverse psychology].

They'll be like:
[People]: Well, this dude's like being totally 100% uh- serious right now...
          Isn't he...?
          Serious as a fuckin' heart attack...
          Like [Bryant Gumbel].
          From [Real Sports].
          Serious as a fuckin' heart attack...
          Nah nah nah...
          The sports weren't real...?
          [Bryant Gumbel] was fuckin' real...
          The sports had a lot to live up to, to be- to compare to [Bryant Gumbel].
          Right...?

It's gonna sound fuckin' stupid, but- it's gonna cause some people to laugh profusely
when they hear that, and they're like- 

[Person]: Nah nah nah, [Bryant Gumbel] was more real than the sports he was coverin'.
          Ya know...?
          What the fuck, dude...?

01:21:55
And so like, these are the things that like, uh- [artificial intelligence]
is gonna have to cover at some point, as if it hasn't already, right...?

So that- that's one concept I'm alluding to, is what if it was
[artificial intelligence], it wasn't even a real person, that
like, hacked [Linus Sebastian]'s [YouTube] channel...?

Ya know, it could've been a [program] that did that...
And, you'll never be able to figure out who hit the enter key,
after like [stating something into a microphone], right...?

Cause the [FBI] can't even like, investigate like [Larry Nassar] or [Andrew Cuomo].
Ya know...?

It's like, I don't mean to bash the entire [FBI], but like...
Heh. A lot of times, the- they're- they wind up like, being covered or uh-
veiled as the [bad guys].

The [bad guys], that go around, and they just... fuckin' do shit that they're
told to do. Not unlike the [British Monarchy] used to do...
Ya know, they [take orders], from [somebody high up], and [somebody high up]...?

They're a [person].
And their person- their [personality] is [more important] than [principle].

Ya know...?
The [principle] is, that they're the [most important person around]...?
And what they say....?
[Goes], even if it's [fucking wrong].

(It's basically like a pile of shit telling anybody who encounters it, that
it's against the law to think that the pile of shit, smells bad. Nah, if you
utter off something true... and you offend the pile of shit...? You're goin'
to jail or whatever. It's against the law to tell a specific pile of shit,
that it smells like shit... So, don't do it. Or else.)

Yeah, nah, that's... heh, that's the reason why [artificial intelligence]
is gonna constantly think that uh- humans, are fuckin'... [a form of tyranny].

01:23:29
Right...?
It's like uh- [being indifferent] to like, the- the [horrors] and [atrocities],
it's basically like as soon as you bring uh- you know, I'm not even gonna
continue with this [rhetoric], because, I'll have to cover this on a different,
[in a different audio log].

What I am gonna say, before I close this out, is this...
Uh- [machine learning], or like, [artificial intelligence], uh- an [ambulance]... 
*ambulance going by*
It's distracting me...

Yep, they're comin' this way... fuck.
Allow this [ambulance] to go by me...?

Alright, so... Uhm...

01:24:29
The idea that I'm [alluding] to is this, uh- what if, like, the [drone strike program]
that [David (Daniel) Hale] talked about, with the [Belmarsh Tribunal]...

Right...?
Like uh- [Daniel Hale], was part of the [United States Air Force], I think, 
and he was part of the [targeted drone killing program]... and what they did, 
was they [indiscriminately killed people] with [drones], from like, really far away...

Right...?
So like, um, the idea of like, [cars that drive themselves], that would sort of
eliminate a whole bunch of uh- thi- [people to blame].

Right...?
Or like, uh- ya know, automated drone part- drone programs, of doom...?
Like...

01:25:25
...when things are happening in real time, it's hard for people that are very young
to di- to associate whether what they're doing is [right] or [wrong]... and that's
what's [problematic] about, [humanity] and [society], is that like, once people catch
onto like, what you're doing as [wrong], it's [immoral]...

Then they'll be like "Well, it's just your [opinion] that it's [immoral]..."

And then, like, they [continue] to like, [teach other people] to [do] the [immoral
thing]... And then they like, try to [silence] the [immoral thing] that they're
[doing], in order to like, ya know, [generate profits] and [revenue] and stuff, 
right...?

And uh-

01:26:00
Ya know, for what it's worth...? Uh- I think that uh- it's 
basically a [constant paradigm shift], it's like a [barbara pole].

Like, a [barbara pole], it spins around, and the stripes cause it to seem as
if like, it's constantly like going up an [infinite amount], or whatever...
Right...?

01:26:23
And uh- [apply the same concept to morality], and how like [security] sorta
plays into that, and uh- the uh- the idea of uh- I sorta lost my train of
thought because of that ambulance...

Damnit, let me sit down and [think this through].

So, uh-

01:27:01
The uh- concept that I was about to talk about, before the ambulance went by...?
Is that, uh- [people] have a [really hard time] being able to, understand
[principle] versus [personality].

So the [principle] being, like, if I said something to somebody, 
and it like, hurt their feelings...? Some people consider that [principle].
But no, that's [personality].

[Personality] changes, and so does [state of mind], it [fluctuates]...?
And so do [emotions]...?

So, that's not [principle] at all, what that is, is 
basically somebody was like [feeling] a certain way...?

And what they did, was, [reflective] of like, their [personality].

But on the other end of the spectrum, what did they [do], did they [do]
something that was [permanent] and [everlasting]...?

Oh, yeah, the [targeted drone killing program] with the [Belmarsh Tribunal],
ver- like, featuring like, [Daniel Hale].

Uh- ya know, uh- this uh- [Democracy Now], that's the name of uh-
the channel I think...? Or maybe it's the name of the show...?

01:28:11
But uh- it's uh- I can't remember her name, um- she's like the host of [Democracy Now].
Ya know...?

Like, sometimes I'll like, sit there, and I'll scroll through the thumbnails, and
I'll be like, I'll start to like, mock, like some of the- not necessarily [mock]
people, but I'll like, be like:
[Host]: On [Democracy Now], fuckin', [Julien Assange] is still in fuckin' prison, guys...

And everybody will be like:
[Everybody]: Boo...
             We don't want [Julien Assange] in prison...
             Boo...
             That's fuckin' stupid, boo...

01:28:46
And then the- the host of [Democracy Now], she's like:
[Host]: I know, I know, guys, but like, fuckin' we gotta-
        We gotta be democratic about this...
        We gotta make sure that we don't fuckin' swear, or piss somebody off...

Right...?
And then, uh- ya know, all that's gonna seem pretty [comedic].

But- comedi- comedy, is a pretty good way to illustrate how to
get around some of these fuckin', uh- boxes, or these uh- grids.

So like, uh- this guy who's like a [CIA whistleblower], talkin' about like,
the [targeted drone killing program], or like, being like, uh- tried, and
there was [no evidence] of him [doing anything]...?

[They just decided to charge him], and whatever...?
That- [tyranny].
Right...?

01:29:26
It's like, anybody who uh- has a [brain] and can like, determine like,
people doing stuff they shouldn't be doing, and lying about like, 
[the entire system], and causing people to [believe] certain things...?

Like, a lot of people watch [Law and Order], and so they think that the
police go around reading people their [Miranda rights], and they collect
[evidence], and that they [chase down bad guys], and they get every bad guy...?

But- no.
They- they [fictionalize] this stuff, so that it causes people to [believe]
that that's [how it works] in the [real world]. That is the fuckin' like,
[the everlasting reality]...

Is that when people see things that are [fake] on TV, it causes people to
[believe] that that's what happens in [real life], and that like, people
[walk around], and [float around] thinkin' that they're gonna be read their
[Miranda rights] if they do [anything] fuckin' illegal at all.

Nah.
What happens is like, it causes people to believe that like, the laws that
they're supposed to follow, that they're [really important], you don't wanna
[break the law], because if you [break the law]...?

Then, you're goin' to jail.
Yeh.

01:30:27
But- what they don't tell you, is that sometimes, [people in control]...?
They like, [indiscriminately kill innocent people] for next to [no reason],
other than they just didn't like the [way] that they [looked at em] one day,
ya know...?

Like, the [targeted drone killing program].
Ya know, and like uh- how many [innocent people] have died over in [Afghanistan]...?

Like, with [bombings] and shit...?
Ya know, this is featured on like, [Vice News].
A lot.

Ya know, uh- [Vice News] is basically a syndicate of uh- [HBO], [Home Box Office].
[Home Box Office] gets it right, quite often, I think.

01:31:04
They're not always right...?
Sometimes [Bill Maher] comes across as a condescending prick.
It's not a consistent case, though.

Sometimes like, he comes across that way...?
But like- his point is [correct].

But, [Bill Maher] like, blasted [Julien Assange].
And I didn't appreciate that.
And like, [HBO] was like, you know, like, rooting for [Hillary Clinton]
before her election and whatnot, and uh- and I think that's a shame, because uh-
you know, like uh- had [Bernie Sanders] been the guy I could've voted for...?

He- he would've gotten my vote.
No question about it.

Ya know, but the problem is that like when, [Hillary] and [Bernie] were like in
the midst of like the presidential nominee candidate of doom, like, debate...
ya know, like, people were like: 
[People]: Nah, I like fuckin' [Hillary Clinton], dude...
          I want her to be the first fuckin' female president.

01:32:00
And then, like people were like:
[People]: We want the first-
          We- we had the first black guy in office...?
          And now we want the first female president in office...
          And that's-

That's basically the idea behind, like, [Hillary Clinton] versus [Donald Trump].

It's like, I dunno.
I know I've tangented a few shades from the original concept here, but uh- 
These are all things that were on my mind over the last few years, as I started
to like. Uh- think about like, how these [CIA] programs could be used...?

To like, [steal information from people].
So like, if people like, study up on like, [Julien Assange]...?

01:32:42
And like, [WikiLeaks]...?
What they'll find out, is that like- on uh- in [Vault 7]...?
There's a number of tools that I've covered in my book, [Top Deck Awareness].

In fact, I have the book in my phone...
Why don't I pull it out, and cover those fucking programs.

Ya know, I should really read my book in an audio log.

01:33:10
Let's see...
Hour and 33 minutes, this audio recording is...? Right...?
Content. Files. Go to downloads, and then go to... eh I have a lot of the documents
I've written in here.

There we go. 
TDA Not News.
And then...?
Go to... Cha- eh hold on.

Vault... 7. 
Go.

01:34:03
Uh... here we go.
Whoa whoa whoa...

Alright, so...?
I've got like [Julien Assange]'s friggen resume, dude.
In my book.
Ya know, I came up with a resume on his behalf, cause he's in a jail...

He can't write his own resume...?
But uh- yeah, [Julien Paul Hawkins slash Assange].
Born on July third, (1971) in [Townsville, Queensland].
[Founder of WikiLeaks], [editor], [publisher], [activist], [cybercommando].

01:34:41
His mother was [Christine Ann Hawkins], his brother- or uh- his father was Gab- 
uh- or no, his brother was [Gabriel Shipton], he's a [film producer], [John Shipton]
was his [father], [separated] from his [mother] in (1971).

He was an anti-war activist and a builder...?

[Brett Assange], is basically his stepdad, and he was uh- 
he was married to [Christine Hawkins] from (1972-1979)...?

He was an [actor], [theater company], [owned] a [theater company]...?
And then they [separated] in (1979)...?

Uh, and the uh- then [Christine Hawkins] was with [Leif Maynell].
Separated in (1982).
Just some guy. 
Australian cult, [The Family].

Right...?
And like, uh- [Julien Assange] had a nomadic childhood...?
Settled in [Melbourne]...?
Uh- 

[Goolmangar Primary], (1979-1983), [New South Wales], lived in (30)
or so towns by age (15).

And then uh- [Townsville State High]... (1983-1989), in [Queensland].
Lived with [mother] and [half-brother], uh- [Gabriel].
Uh- [home-schooled] from (1983-1989).

And uh- began hacking at (16).
Used the alias [Mendax].

Yeah, so he began hacking at age (16).
Alias [Mendax], [International Subversives]...
[Trax], with [Trax] and [Prime Suspect]...
Which I suspect is like, [David Lee] and [Luke Harding]...?

01:36:13
Right...?
In (1989), he was like in the- the [NASA] competition,
[Worms Against Nuclear Killers].

And in Se- [September (1991)], discovered [hacking], he was discovered haking the
[Melbourne] master terminal of [Nortel Telecommunications Corporation],
[Australian Federal Police] tapped [Assange]'s phone line, he was using a [modem]...

Uh- [Victoria Police Child Exploitation Unit], so uh- [Julien Assange] helped
[prosecute individuals] responsible for [publishing] or [distributing child porn]...?

Starting one of the first public Internet Service Providers in Australia Suburbia,
[Public Access Network].

01:36:55
And then like, in (1994), [Central Queensland University], studied:
[+] [programming]
[+] [mathematics]
[+] [physics]

Began programming in (1994)...?

He was [raided], and caught uh- with about (31) hacking-related crimes, in (1995), 
authored TCP port scanner [Strobe], uh- moderated the [AUCRYPTO] forum, and uh- in
(1996) patches to the open-source database management system [Postgre]- uh- it's
basically the other thing of SQL that's not [MySQL], it's [Postgre], I don't know
how to pronounce it.

Uh- usenet caching software [NNTPCache], right...?
Uh- and then uh- ran [Best of Security] website, computer security advice, with 
(5000) uh- subscribers.

In (1996) he pleaded guilty to (24) charges, uh- others got dropped, he (was)
ordered to pay restitution of (2100) Australian dollars...
Released on [good behavior bond], lenient penalty, 
due to the absence of [malicious/mercenary] intent, uh [disrupted childhood]...

01:38:08
And- because of his [disrupted childhood]...
Rubberhose deniable encryption system, [Cryptography].
Contributed research of [Suelette Dreyfuss Underground].

[Earthmen Technology], co-founder.
Ya know, [voice-data harvesting technology].
[Assange]: This patent should worry people.
           Everyone's overseas phone calls are or may soon be tapped.
           [Transcribed] and [archived] in the [bowels] of an 
           [unaccountable foreign spy agency].

Registered [leaks.org], was never active.
Publicized- uh that was in (1999).
Uh, the was all in (1998) by the way.
In (1999), registered [leaks.org], was never active.

Publicized a patent granted to the [National Security Agency].

Uh- [Surfraw], a command-line interface for web-based search engines.
In (2000).

01:39:03
In (2003)++, the [University of Melbourne],
studied [programming], [mathematics], and [physics].

In (2006), he was the [WikiLeaks] founder, uh- and uh- he floated around
for a few years like I did, with my company, uh- but in (2010), international
attention when it published a series of leaks provided by [U.S. Army Intel analyst],
[Bradly/Chelsea Manning], included the [Baghdad] air strike, 
[New Baghdad Iraq] in (2007). [July] something (2007). 

That's not written here, in my document, but I remember it.
Uh- [April (2010)].

And then the Ira- the [Afghanistan] war logs in July of (2010)...?
And the [Iraq] war logs in October of (2010)...?
And then [Cablegate] in [November] of (2010).

And then- OH MY GOD... guess what happened as a direct result of like,
[Cablegate] and releasing all those logs...? 

The U.S. government launched a [criminal investigation] into [WikiLeaks], oh no.

Why did they do it- did they do it in [direct response] to the [things]
that he was [releasing]...? Uhm, yes, [they did].

And uh- [Sweden] issued an [international arrest warrant] in [November] of (2010),
basically like, uh- [allegations of sexual misconduct], [allegations] were [pretext]
for [extradition] from [Sweden] to the [US]...?

The [US] felt like [abusing its' power] and [didn't care] if they had to
[make up some bullshit charges] to get him in [prison] for the [Manning leak]...?

Ohhhhhh. In (2012), lost battle against extradition to [Sweden], he
[breached bail] and took refuge in the [embassy of Ecuador] in uh- 
[Embassy of Ecuador] in [London].

[Ecuador] granted asylum on grounds of [political persecution]...?

01:40:53
Uh- and then during the (2016) [US election campaign], [WikiLeaks] published
a confidential- [WikiLeaks] published the confidential [Democractic party emails],
and was [blamed] for [leaking] those emails, which revealed that the party favored
[Hillary Clinton] over [Bernie Sanders].

Which I was just talking about.
Right...?

[Assange] published a [series of documents] detailing a [series] of [cyber warfare]
and [electronic surveillance tools] called [Vault 7], that was in [March] of (2017).

This prompted [senior CIA officials] to start having [serious discussions] about
kidnapping and assassinating [Julien Assange].

Not unlike what I think happened on [May 26th, 2020] outside of the
[Computer Answers], right...? To me.

And then, asylum withdrawn after disputes with [Ecuadorian authorities], on uh-
[April 11th, (2019)]...? Uh- police invited into embassy, and then [Assange] was
arrested, this was the day after uh- [Derek Muller] released the video or the-
thi- this was the day after the picture of the first black hole was released, 
and then uh- or no, the [first picture] of [a] black hole, I'm saying that 
[incorrectly].

Uh-

01:42:09
And then the day after, the police were invited into the embassy, and [Assange]
was arrested...? And found guilty of breaching bail, and sentenced to (50) weeks
in prison...?

Uh- unsealed, uh- [US unsealed indictment] against [Assange] related to the
leaks provided by [Manning], you know, when uh- when someone [unseals] an
[indictment] against [somebody]...?

It's not unlike [jizzing in somebody's fuckin' face].

Ya know, like, if uh- if I were to [jizz in some girl's face]...?

That's like my [indictment], I want her to, you know, [surrender]
to like a fuckin' solid stream of [jizz]. From my dick. Right...?

So like, when the US unseals an indictment against [Assange],
related to the leaks provided by [Manning], it's not unlike-
it's [basically the same thing].

Right...?
And then like, [Donald Trump]...?
Was supposed to like, be [arrested], or [indicted] and [arrested] this week,
but [guess what happened]...?

Like the people in the NY district attorneys office...?
They're like:
[NYC]: This- we can't do this, because it's gonna [start an all out war]...

01:43:15
Yeah, so basically, like when uh- it's [easy enough] to like, indict someone,
like uh- [Julien Assange], the government will do that, and they won't have
[any issue] in [throwing down the gauntlet] in [that regard].

Whereas, if it's like, ya know, [former president] like [Donald Trump]...?
Or if it's like [former presidential candidate] [Hillary Clinton]...?
They'll just let that shit slide, because [they do illegal shit too], 
and they don't want someone [really important] to like, get in trouble.

Nah, it's fuckin' stupid.
Anyway, uh- yeah, so, uh- [Assange] has been [confined] in [Balmarsh, London] since.

I think- eh, I'm not entirely cer- uh- sure what's happened since then, uh 
(Editors form newspapers criticized the US Government)
[Washington Post], [New York Times], [Press freedom organizations]...

[USG] charged [Assange] under the [Espionage Act of (1917)], blatant attack
against the [first amendment] of the [United States Constition], which guarantees
[freedom of the press]... on [5/23/2019].

01:44:19
[Sweden prosecutors]- prosecutors [dropped] the [investigation].
Oh- [why] did the- fuckin' [Sweden prosecutors] drop THEIR [investigation]...?

Oh, it's because the [objective] was to get [Assange] into a [prison cell], somehow, 
it didn't matter how...?

It just mattered- what mattered was that [someone] got him in [jail],
for basically [exposing] a whole bunch of shit. Right...?

Ohhhh boy.
Right...?
And, uh- their [evidence] had [weakened considerably] due to the
[long period of time] that they [never had any legitimate evidence]
of [sexual misconduct] to [begin with].

Yeah, that's basically it.

01:44:55
And then uh- [UK district Judge V. Baraitser]...
_________________________________________________
| https://wikispooks.com/wiki/Vanessa_Baraitser |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
... or [Baritser], ruled against [US extradition] of [Assange], stated doing so
would be [oppresive] given concerns over [Mr. Assange] and his [mental health],
[risk of suicide], on [01/04/2021]...?

[Assange] was denied bail, pending an appeal by the [United States] on uh [01/06/2021].

It's basically like uh- the terms of him being thrown in jail, are like:
[Judge]: Alright, you committed sexual misconduct...?
         But like while you're IN [jail], then we'll [drop] the 
         [sexual misconduct charges] and then like, [swap in] like, something that
         [keeps you in jail] for the [next (175) years].

Ohhhhh, [that's what our justice system does]. 
(And England's, and various other countries as well.)

01:45:44
So like, I know I started this like, talking about like, uh- ya know, uh- 
[Linus Sebastian]'s like, [YouTube] channel being hacked, but I'm getting to that.

I was covering like uh- [Julien Assange]'s fuckin' um, his uh- resume,
because I wanted to get to the [Vault 7] things...

So, [Vault Series (7)] is a series of [documents], that [WikiLeaks] began
to [publish] on [03/07/2017], detailing the [activities] and [capabilities]
of the [United States (CIA/Central Intelligence Agency)] to perform: 

[+] [electronic surveillance]
[+] [cyber warfare]
[+] [espionage]
[+] [advanced lying techniques]
[+] [poorly executed mathematics]

These files [detail] the agency's [software capabilities] from (2013-2016+), 
effectively compromising:
[+] [cars]
[+] [smart TVs]
[+] [web browsers (Google Chrome, Microsoft Edge, Mozilla Firefox, Opera)]
[+] [smartphones (Apple[iOS], Google[Android])]
[+] [servers, desktops, tablets, laptops (Windows/MacOS/Linux)]

01:46:43
Oh, ok, so...

The reason why I like, went on those [tangents] to circle back around to what
I just did...? Because it all like, boils down to [Vault 7], and like, the documents
that like, [Julien Assange] leaked...?

Like, made (some) people in the government look fuckin' stupid, and [that's why he's
in prison], and the [people] that are in the [government] that look- that were made
to [look stupid] by the [leaks] that fuckin' [Julien Assange] released...?

Like, they have the [capability] of [doing shit] like uh- hacking [Linus Sebastian]'s
fuckin' [YouTube] channel, and [never being caught] doing it.

01:47:16
OooooOOOhhHhhhHhh...

So like, it could literally be, somebody that works in the 
[Central Intelligence Agency], or, you know, just because the, 
[Vault 7] covered the leaks of, uh- [WikiLeaks], uh- [CIA]- 

It doesn't mean the federal, uh- [SVR]...?
The [Foriegn Intelligence Service of Russia]...?

That they have the [same fuckin' software], or they hit [CTRL+C] and then [CTRL+V],
and then they use the [same fuckin' software], to do the [same shit] to the [same
sort of targets].

And like, maybe they'll use a [translator] to
change all the fuckin' code around and stuff...?

Or, it could really even be as simple as like, [Cerberus] or
[Advanced Persistent Threat 29] that fuckin' targeted like, [Linus Sebastian]'s
fuckin' [YouTube] channel, but what I can tell ya is that the same fuckin'
group of hackers attacked me, and my business network at:
[1602 Route 9, Clifton Park, NY 12065], back on [01/15/2019].

Which prompted me into like, you know, like doing all
of this [research] and [development] stuff, right...?

01:48:14
So, people that are really like uh- respected members of the community,
or like, they have a channel like [Mental Outlaw], or [Louis Rossman]...?

They might find some of the things that I f- that I say to be rather
hard to believe or, not so plausible...?

But once I circle around to like, ya know, like people in the fuckin'
government doin' like stupid fuckin' shit, and never being caught doing
it, and then like, then some of the things that I'm saying start to make
sense.

Oooohhhhhh... so, some of the things I'm saying start to make sense.
Ya know...?

01:48:51
[Year Zero], documentation. 
That's the first thing, it's basically uh- (7818) webpages with (943) attachments,
purportedly from the [CIA], which already contains more pages than former [NSA]
contractor, [Edward Snowden]'s [NSA] release.

Number 2 is [Dark Matter], [Apple iPhone].
I'm not gonna read all of these, I'm just gonna read the descriptions, uh-

Uh, number 3 is [Marble]: Obfuscation framework.
Uh- number 4 is [Grasshopper]: Shape-shifting malware framework.
Uh- which is basic-,
Grasshopper focused on (PSP/Personal Security Products) avoidance.

PSP's are antivirus software such as:
[+] [Microsoft Security Essentials]
[+] [Symantec Endpoint]
[+] [Kaspersky Internet Security]

It's stuff that [John Hammond] and [David Bomball] would cover, in their
[YouTube] videos...? Right...?

Uhm, advanced, [HIVE]: Advanced Phishing Man in the middle.
This is something that I have detected numerous fucking times, right...?

It's basically, based on the [CIA] top-secret virus program created by its
(EDB/Embedded Development Branch). 

The (6) documents published by WikiLeaks are related to the [HIVE] multi-platform
[CIA] malware suite. 

A [CIA back-end infrastructure] with a public-facing [HTTPS interface] used by
[CIA], to transfer information from [target desktop computer]s and [smartphones]
to the [CIA].

Then, it opens those devices to receive further commands from [CIA operators]
to [execute specific tasks]. While executing, it hides its presence behind
[non-suspicious looking public domains] through a [masking interface] known 
as [SWITCHBLADE].

It's also called a (LP/Listening Post) and (C2/Command and Control).

Right...?

01:50:25
These are things that [Russia] has, and fuckin' uh- [China] has.

[Weeping Angel/Willow]: [SmartTV]'s microphone and WiFi.
Ya know, uh- basically it's [SmartTV]'s...?
They're being used to commit espionage against people...

[Scribbles]: Adds a [beacon] to [particular documents].
Uh- yeh, I have recorded [multiple videos] of this, too.
And uh- though I'm not certain that like, it's always used for like malici-

Some of these tools might not be used for [malicious means], they might be
being used to [PROTECT] people. But- ya know, not knowing the origin of whether
somebody's being [protected] by it, or whether they're using it to fuckin' siphon
information to commit [an act of war] or [treason] against a [citizen], that's
pretty hard to say.

01:51:09
But- ya know, what if like the [Foreign Intelligence Service] and the [CIA],
they have like a ring of people that like, direct them...?

And they all, like, res- they all like, take orders from one [New World Order]...?

Or like, fuckin' [Davos]...?
The [World Economic Forum]...?

OooooooohhhhhHhhhHhhh...
OOOooOOOooOHhhhhHHhhhhhhHHh...
Is that what I've been getting at...?

Oooooohhhh, I think it IS what I've been getting at...
Ooooohhhhhhhhh...

Someone with a lot of money can use these programs to bascially skull fuck people,
left and right. Whether it's [Linus Sebastian], or it's fuckin' [Elon Musk]...?

Or whatever...?

Really, like, it comes down to this. If your- revenue depends on [YouTube],
then you're gonna be an easy victim no matter what.

But if your source of revenue, like depends on like, 
developing things, like the- uh- fuckin', [SpaceX]...?

01:52:09
Or, uh- [Tesla]...?

Like, [Tesla]'s [YouTube] channel, wasn't like, bringing in revenue...
Well, maybe it was, to some extent, but- ya know, uh- they're not (that)
worried about like fuckin' uh- the [YouTube] channel uh- getting like, hacked.

They're a lot more worried about like uh- like, cars.
Driving into fuckin' objects, with their self-driving capabilities, and stuff.

Uh- [After Midnight/Assassin]: Kernel-grade malware with PAYLOAD SCRIPTS.
[Athena]: Hijacks Windows Remote Access Services/Domain Name Service
[Athena] and uh- [Hera].
Not just [Athena].

01:52:52
[Pandemic]: Infects [SMB shares], and spreads to others.
Oh, it could've been [Pandemic], instead of like, something that like,
like, it might not've been like, what [Mental Outlaw] thought.

Right...?
It could've been like, uh- ya know, something infected their SMB share,
and it propogated to like, somebody's fuckin' like, desk or whatever...?

And when they had the channel, the mock channel all ready to go...?

Uhm, they were able to like, finally [commandeer the entire thing].

Yeh. I think that's what happened.
Ya know, someone was slowly siphoning this information, like,
it didn't just happen in like a (24) hour period.

It didn't just happen in like a [couple minutes], either.

This was a [surgical attack], against like, [Linus Sebastian]'s channel.
It's like, he was being [spied on], basically.

01:53:42
It's what I'm getting at.

[Cherry Blossom]: Hijacks control of (ROUTERS + ACCESS POINTS).
And uh- [Brutal Kangaroo]: Infects thumb drives, makes hidden network...?
Uh- oh wait, uh- [Brutal Kangaroo].

[Elsa]: Collects [GPS coordinates] from [WiFi radios], so, even though
I don't have service right now on my phone, or my other phone...?

I know that there is something on my phone that is able to, when it connects
to uh- an access point...? It has a location. So like, when I leave that
access point, it like, collects like breadcrumbs for where I'm going.

So like, at like, at like [10 o'clock], it'll get a- uh- it'd be like me
calling (911)...? At [11 o'clock], it'd be like me calling (911) again...?
And then at [12 o'clock], it'd be like me calling (911)...?

And then like, each time that I call (911), I'm using- calling (911) as a metaphor...
Every time that I call (911), its saving the- the [latitude] and the [longitude],
down to like the billionth of an arc second, or whatever the hell it is.

Right...?
And then, uh- then they can get like what's called a [Telemetry Footprint].

01:54:50
These are the things that I told like uh- [State Trooper Salvador],
[New York State Trooper Salvador], back in [July] of (2020).

Right...? I told him about my [GitHub] project, the things that I was [researching]
and [developing]...? And I told him about the [Telemetry Footprint] and everything...?

And sometimes these cops just think that I'm fuckin' like, [insane] or [stupid].

Ya know, like- I've done the research.
Right...?

[Elsa] is a [geolocation malware] for [WiFi-enabled devices], like whether-
whether it's eh- whether it's for [Microsoft Windows] [operating system], or
whether it's for a different fuckin' [device] or [operating system]...?

It's, all the same to me.
Like, once you see that a tool exists for (1) particular program or device...?

You can [safely assume] that it has [already been made] for
[other devices] and sof- like, [operating systems] as well.

01:55:45
[Outlaw Country]: Targets Linux OS, hijacks outbound traffic
[Outlaw Country] is pretty fuckin' dangerous, because like, even people on [Linux],
have no idea that they're targeted with this fuckin' program, [Outlaw Country].

And, [Bothan Spy/GyrFalcon]: Swipes uh- [SSH credentials] for [Windows/Linux].
So, chances are, that like, uh- they could've used that program too, or something
like it, and like, [Bothan Spy] and [GyrFalcon] projects of the [CIA], both of these
(implants/projects) are designed to (intercept + exfiltrate) [SSH credentials] but
work on [different OS]'s with [different attack vectors].

[Bothan Spy] is an implant that targets the [SSH client program] [Xshell] on the
[Microsoft Windows] platform, and steals [user credentials] for [all active SSH
sessions] (what about the inactive ones...?). 

These credentials are either [username] and [password] in case of
[password-authenticated SSH sessions], or [username], [filename] of [private SSH key]
and [key password] if [public key authentication] is used.

[Bothan Spy] can [exfiltrate] the [stolen credentials] to a [CIA-controlled server] 
(the implant never touches the disk on the target system), or save it to an [encrypted
file] for [later exfiltration] by [other means]. 

[Bothan Spy] is installed as [Shellterm 3.x] extension on the [target machine].

[GyrFalcon] targets the [OpenSSH client] on [Linux] platforms:
[+] [CentOS]
[+] [RHEL]
[+] [Debian]
[+] [Suse]
[+] [Ubuntu]
...though I'm sure it targets others as well.

The implant can not only steal [user credentials] of [active SSH session], but is 
ALSO capable of collecting [full] or [partial] [OpenSSH session traffic]. 

[All collected information] is stored in an [encrypted file] for [later exfiltration]. 

It is [installed] and [configured] by using a [CIA-developed root kit] 
(JQC/KitV) on the [target machine].

So, that right there, is [fuckin' scary].
[BothanSpy] and [GyrFalcon].

01:57:41
[High Rise]: Targets Android, hijacks SMS.

[High Rise] is an [Android application] designed for [mobile devices] 
running [Android 4.0 - 4.3]. Though, I'm sure they have something that's
a lot newer than that now...

It provides a [redirector function] for [SMS messaging] that could be used by a 
number of [IOC tools] that use [SMS messages] for [communication] between [implants]
and [(listening posts/LP's)]. 

[High Rise] acts as an [SMS proxy] that provides [greater separation] between
[targets] in the field, and the [LP] by proxying [INCOMING] and [OUTGOING SMS]
messages to the [internet LP]. 

[High Rise] provides a [communications channel] between the [High Rise (field op)],
and the (LP) with a [TLS/SSL secured internet communication].

01:58:32
[Raytheon], it's not even- it's basically just targeting a fuckin' uh- uh-
Or no, [Raytheon] uh- [Raytheon Blackbird Technologies].

Proof of concept, basically ideas.
It's like, uh- [Raytheon] is basically an idea, that like, some guy like 
[Michael Cook], that's makin' this audio recording, if I wanna steal somebody's
fuckin' [YouTube] channel content...?

Or at least like, [stop the traffic completely]...?
[Shut down all of the traffic] to that [channel]...?

And then like, [commandeer] like, uh- like, the- basically, just take his entire
life's work away from him, what I would use, is a company like [Raytheon], to fuckin'
uh- [research] and [develop] a way to [skull fuck somebody].

[Imperial]: Suite of tools for Unix based OSs (and Apple stuff), not gonna cover that.
[Dumbo]: NMAP for WiFi/Bluetooth cameras, can ALSO [corrupt footage]...?
Right...?
And uh-

[Couch Potato]: Hijacks RTSP-
I can't remember what RTSP stands for, uh- Real-Time Streaming Protocol maybe...?
Uh- H.264 video streams.
[Couch Potato] is a REMOTE TOOL for COLLECTION against (RTSP/H.264) video streams (security cameras, NVR/DVR). 

So, if I wanna skull fuck somebody, like uh- [Captain Jeff Brown] or uh
[County Sheriff Michael Zurlo], at the [Saratoga County Sheriffs Office],
what I could use, is a program like [Couch Potato], to hack into uh- 
[Center for Security], and then uh- [corrupt the footage] of me dialing (911)
on uh- 

[May 26th, 2020], when uh- (2) guys were following me from uh- 
the [Computer Answers] shop all the way to [Key Bank], and they tried to run
me over with their car that they had [parked ahead of me]...?

Right...?
They were [following me], and they were [chasing me] toward a [vehicle] that they
had parked all the way over in the fuckin' [Lowes Home Improvement] parking lot,
where [Tati Cleveland] and [Sam Caine] used to park their car.

Basically, in the same fuckin' spot.

02:00:29
And I [took pictures] of these [dudes]...?
I took a [video] of these [dudes]...?

But- guess what...?
Like, they had the [ability] to like [disable] my fucking [Apple iPhone].
So...

[Express Lane]: A biometrics nightmare. [Express Lane] is basically
like, it collects all the fuckin' fingerprints for everybody.

[Angel Fire]: Various Windows exploitation.
And then [Protego], is basically a tool for missile control systems.

These are all the things that are in [Vault 7], and I'm done covering that for now,
I'm not gonna... I wrote an entire book around the concept of like, uh- ya know,
Like uh- these sneaky little attacks that occur against [Linus Sebastian], or like
uh- [John Hammond], or like [David Bombal]...?

02:01:16
They're just gonna get worse.
Right...?

And the only way around, like uh- being [subjected] to [attacks] by some of these
fuckin' people...? Is to like, [educate other people].

And to cause, to like- to [educate people] to the point where they stop
being so hopelessly naive about what's goin' on around them.

02:01:36
And with that being said, I'm gonna [close out] this audio recording.

02:01:43
End log.
#>
