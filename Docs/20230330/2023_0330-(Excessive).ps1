Function New-Document
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][String]$Name,
    [ValidateScript({ Try { [DateTime]$_ } Catch { Throw "Invalid date" }})]
    [Parameter()][String]$Date=([DateTime]::Now.ToString("MM/dd/yyyy")))

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

            $H            = @{ }

            If ($Name -eq "Title")
            {
                $This.Add("")
                ForEach ($Line in $Content)
                {
                    $This.Add($Line)
                }
                $This.Add("")
                ForEach ($Line in $This.Top())
                {
                    $This.Add($Line)
                }
            }

            If ($Name -ne "Title")
            {
                # [Head]
                ForEach ($Line in $This.Head($Name))
                {
                    $This.Add($Line)
                }

                $This.Add("")

                # [Content]
                ForEach ($Line in $Content -Split "`n")
                {
                    If ($Line.Length -gt 112)
                    {
                        $Array         = [Char[]]$Line
                        $Block         = ""
                        $X             = 0
                        Do
                        {
                            $Block    += $Array[$X]
                            If ($Block.Length -eq 112)
                            {
                                $This.Add("    $Block")
                                $Block = ""
                            }
                            $X        ++
                        }
                        Until ($X -eq $Array.Count)
        
                        If ($Block -ne "")
                        {
                            $This.Add("    $Block")
                        }
                    }
                    Else
                    {
                        $This.Add("    $Line")
                    }
                }

                # [Foot]
                ForEach ($Line in $This.Foot($Name))
                {
                    $This.Add($Line)
                }

                # [Bottom]
                If ($Name -eq "Conclusion")
                {
                    ForEach ($Line in $This.Bottom())
                    {
                        $This.Add($Line)
                    }
                }
            }
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
            $This.Add("Title",$This.GetTitle())
        }
        [Object] DocumentSection([UInt32]$Index,[String]$Name,[String]$Content)
        {
            Return [DocumentSection]::New($Index,$Name,$Content)
        }
        Out([Hashtable]$Hash,[String]$Line)
        {
            $Hash.Add($Hash.Count,$Line)
        }
        Add([String]$Name,[String]$Content)
        {
            $This.Section += $This.DocumentSection($This.Section.Count,$Name,$Content)
        }
        Clear()
        {
            $This.Section  = @( )
        }
        [String] GetTitle()
        {
            Return (Write-Theme "$($This.Name) [~] $($This.Date)" -Text) -Replace "#","" -join "`n"
        }
        [String[]] GetOutput()
        {
            Return $This.Section.Output.Content
        }
    }

    [DocumentController]::New($Name,$Date)
}

$Doc = New-Document -Name "RESTRICT Act" -Date "03/30/2023"
$Doc.Add("Introduction",@'
RESTRICT Act
[https://www.msn.com/en-us/news/technology/new-restrict-act-could-mean-20-years-in-prison-for-using-a-vpn-to-access-banned-apps/ar-AA19exSd]

We don't live in a [communist country].
Nah, not at all.
'@)

$Doc.Add("We Live In A Democracy",@'
Because... we live in a [democracy].
And THAT means, [*everyone's voice matters*].

[Unless] you [do something] to [piss off certain people] who are [in] a [position] of [authority],
and they [just so happen] to be [really careless] and [stupid]...?
...[THEN], it isn't a [fully qualified democracy].

Nah, cause at that point, you'll begin to see the cracks where people's logic begins to break down.

So, [until] you [do something] that [pisses] them off...?
Then, you [won't] really [understand] how [our country] appears to be [virtually identical]
to a [communist state] or a [monarchy].

[After] that point, however...?
Then you will see it [pretty fucking clearly].

Here's a little [skit] that [demonstrates] their [thought processes]...

'@)

$Doc.Add("What the government thinks",@'
[Government]: If you even think about using a [VPN] to access [banned applications]...?
              Then, [you] will be [sent to prison] for [(20) fucking years].

              No [if]'s, [and]'s, or [but]'s...
              If that sounds fuckin' stupid...?
              It just means that YOU'RE fuckin' stupid.
              [We're the people in charge].

              If [you] don't [trust us], that's too bad because [we don't give a shit].
              It's really not [required] for people to [trust us], either.

              [You have to trust us whether you like it or not].

              The truth is, they're [spying] on [us]...
              And, we have [absolutely zero tolerance] for [other countries spying] on [Americans].
              We have a [100 percent tolerance] for [our own country spying] on [Americans], because
              [they pay us] to [fulfil their agenda]. [Sometimes].

              Not [always]...?
              But- [most of the time], to nearly [all of the time],
              that is what we do, in the [United States government].

              If you think that is rather [communist] or [totalitarian], that's just your fuckin' opinion, chum.
              [Kick rocks].

              By the way, make sure you [get out] and [vote] in the [next election].
              Even though it doesn't really matter who you vote for, anyway...?
              We [continue] to [allow people] to [go out] and [vote], as a [distraction].

              [Buy gasoline].
              [Global warming doesn't exist].
              Bye.
'@)

$Doc.Add("Actions Speak Louder Than Words",@'
Yeah so, that's probably a rather [bleak outlook] on the [people in charge], right...?
They would never ever [say] something THAT [audacious], but- [that is irrelevant].

[Their actions consistently DO say those things and override their senseless fucking words].
Ya know...?
[Actions speak louder than words]...?
[Actions speak louder than words]...

Anyway, it isn't until [after] you have [pissed them off] for [whatever reason], that they
will fucking [make up whatever bullshit they feel like], to [get people] in [trouble] for
[things they didn't do].

It's not a consistent case where they'll do this, because if it looks really fucking
obvious to people who are paying attention, then, people with [rifles] and [handcuffs]
are likely to start kicking in doors and [arresting police officers] and [politicians]...

So, they have to keep a rather [low profile].

Realistically, even if you [legally express yourself] and use your [constitutional liberties]
and [freedoms]...? They have [all the right people] in [all the right places], to [mislabel]
people who are [aware] of their [constitutional liberties], [freedoms], and [rights].

As for [some] of the [people in charge], their [actions] consistently prove that our 
[constitutional liberties], [freedoms] and [rights] are [very imaginary] if you're [indigent].

Which means that they have a system in place that [incriminates people] that have [no money],
[even if they have done nothing criminal] at all, AND, they have [EVIDENCE] of their [innocence].

When you have [no money], the [constitutional liberties] and [freedoms] that [every American]
supposedly has, are there as a [decoration].
'@)

$Doc.Add("The Constitution's Just A Decoration",@'
[Decorations] like, the things you put on a [Christmas tree], or like whatever.

[Government] : You have constitutional liberties and freedoms.
[Me]         : (20) fucking years in [prison] for using a [VPN] to access a [banned app]...?
[Government] : Yeah, we have [zero tolerance] for [spies] n' shit.
[Me]         : [You people spy on Americans all the time] with [Prism], [Pegasus/Phantom], 
               [USA-PATRIOT Act], [ThinThread], the [Terrorist Surveillance Program], the
               [President's Surveillance Program], among hundreds to thousands of others.
               Like what the fuck...?
[Government] : [We] can [legally do that], though.
[Me]         : Nah, ya see, [some of you people] are [fuckin' stupid].

[Constitutional liberties] and [freedoms] are basically [Christmas tree decorations].
They're [fake].
They don't exist.
'@)

$Doc.Add("Mass Shootings",@'
I mean, they sure as hell tell us on a daily basis that our [rights] and [freedoms] matter and stuff, right...?

But when their [actions consistently prove otherwise], and...
...they fucking suck ass at stopping people like:
______________________________________________________________________
| 12/02/2015 | (2) Rizwan Farook, Tashfeen Malik | San Bernardino CA |
| 07/07/2016 | Micah Xavier Johnson              | Dallas TX         |
| 10/01/2017 | Stephen Craig Paddock             | Paradise NV       |
| 05/18/2018 | Dimitrios Pagourtzis              | Santa Fe TX       |
| 08/03/2019 | Patrick Wood Crusius              | El Paso TX        |
| 08/04/2019 | Connor Stephen Betts              | Dayton OH         |
| 05/14/2022 | Payton S. Gendron                 | Buffalo NY        |
| 05/24/2022 | Salvador Rolando Ramos            | Uvalde TX         |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
'@)

$Doc.Add("Class [Incident]",@"

"@)

$Doc.Add("Class [IncidentList]",@"

"@)

$Doc.Add("Script",@'

'@)

$Doc.Add("Output",@'

'@)

$Doc.Add("Priorities",@'
Allow me to phrase things like this...

Maybe [some] of the things I mentioned [earlier] in this [document] are [a bit excessive].
However, uh- (20) years for using a [VPN] to access [blocked apps]...?

That sounds fucking [excessive] too.
You know what also sounds fucking [excessive]...?
The [laziness factor] of [a lot of people] that [aren't paying attention] to shit like
these [mass shootings].

I'm particularly referring to [Dr. Glosman], [Dr. Gurbek], [Dr. Loeber],
[Susan McDermott], among various other entities at [Saratoga County].

Some of you people are [fuckin' lazy], [careless], and [ignorant].

If the [doctors] I [just rattled off] weren't too busy [fast-tracking] [inaccurate] and
[misleading diagnosis], whereby committing [medical fraud], then they would have [all]
the [time] in the [world] to [accurately diagnose people]...
...like the [perpetrators] I [rattled off]...
...[BEFORE] these [untimely events occur].

That would be a [great way] to go about being a [psychiatrist] that isn't a [lazy fuck].
[Stop committing medical fraud] and [jumping] to [conclusions]...
...[start being more proactive] in the [needs] of the [community] and [people in general].

Like, [thoroughly reviewing the following exhibits]:
10/04/22 | God Mode Cursor (Someone remotely accessing computer) | https://youtu.be/dU_5rdVkCD8
09/26/22 | God Mode Cursor (someone remotely accessing computer) | https://youtu.be/tW80Zj_H6Fw
02/15/22 | A Matter of National Security                         | https://youtu.be/e4VnZObiez8

[Ignoring] people like [me], isn't being [proactive] at all...
...it's just you, being [fucking lazy] and [ignorant].

It probably sounds [excessive], the number of times that I'm saying stuff like "you people
are fuckin' lazy fucks". Well, check it out.

When people like YOU [fail] to [do your jobs properly], what winds up happening, is that someone
with a lot less [self-control], [they're gonna go shoot up a bunch of people].

Why...? Cause you people are [fuckin' stupid], that's why.

A number of people who work for [Saratoga County], *cough* [Michael Depresso], 
*cough* [Paul Pelagalli]... you people should pay more attention to the very key critical
details that I keep talking about.

For instance: [corruption in the government].

These things are [fucking excessive].

[All of those events I just rattled off], are [happening] because [people] like [YOU],
are all [very casually obtuse], and you [care more about your reputation], than 
[taking accountability for lapses in judgement], as well as [various levels of oversight].

Those [(3) videos] should [clearly indicate] that I'm not fuckin' [delusional].
You're just [wicked lazy] and that's really, [the best explanation].

Each of those videos right there [directly contradict] all of your [PhD]'s.

Allow me to drop one more link...
03/15/23 | Observe and Report | https://youtu.be/tPMwAM366go
'@)

$Doc.Add("Conclusion",@'
Yeh. There's a [fair amount] of [egregiousness] and [laziness] going on, and I think that
[throwing people in prison or jail] for [(20) years] for using a [VPN] to access [blocked apps],
that's [fuckin' extremely excessive].

So is taking [custody] of [my children] from me.
So is [ignoring] a [murder attempt] on [05/26/20].
So is [ignoring] the [audio recording] that I told [Cameron Missenis] and [Sgt. Bosco] about
in the [body camera footage] from the [illegal arrest that they made] on [06/28/22].
So is [sending me to (2) quacks] that didn't really care how much [evidence] I have on hand.

[Some of you people are fuckin' stupid].
'@)

$Doc.GetOutput()
