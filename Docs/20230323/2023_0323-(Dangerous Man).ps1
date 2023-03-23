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

$Doc = [DocumentController]::New("The most dangerous man that ever lived","03/23/2023")
$Doc.Add("Introduction",@'
Once upon a time, there lived a [man] who led such an [exhilarating] life...?
That, for [many generations], [telling] the [tale] of [any chapter] of [his life], [at all]...
has been [strictly forbidden] by [many people], [all around] the [world].

Why...?
Because of how [dangerous] it is to [say] anything about [him], [out loud].

When [people hear stories] that are [truly breathtaking]...?
They typically mean that [metaphorically].

But, the reason why telling [anyone] about [any aspect] of [this man]'s life, 
is as [dangerous] as it is...?

It's because doing so, is [literally breathtaking].
Like the [vacuum of space].

So, [don't do it].
Don't say anything about this man's life at all...
You just- read about things he probably did...?
And that's about as safe anyone can really be, when it comes to [his story].
'@)

$Doc.Add("Legend Has It... (1)",@'
Legend has it, that [many people] have [suffocated] from how [breathtaking] the
[details] of [this man]'s life, [truly are].

In other words, it is [dangerous] to even [know] about [this man], at all.
How dangerous...?

Well, imagine if you would, that the [very moment] that you were to [hear] the mans name...?
You [suddenly], could [no longer actually breathe].

Why...?
Because, like I said, merely [mentioning] any aspect of:
[+] [him],
[+] [his life], or 
[+] [any chapter of his life] at all...

...is [literally breathtaking].

As a [direct result] of [how breathtaking] it is...?
Merely mentioning the mans name, has [killed people], according to [legends].
'@)

$Doc.Add("He, Himself",@'
It's not so much that the [man], [himself], was dangerous...
Nah.
He [himself], was a rather [respectable man].
There was [never] really an air about [him], that [caused people] to [quiver] in [fear].

However, [hearing] about [his life], or [his story]...?
[That] is what is [so dangerous]...

Because really, [what the hell] could [this man] have done in [his life], to have been [supposedly] considered 
[the most dangerous man that ever lived], if [he himself], was [not] really all that [dangerous], to begin with...?

That is a [great question].
It remains [unanswered].

Some people may even ask...
[People]: Well, was he [dangerous looking]...?

[Nobody really knows].

It was such a [long time ago], that [the man] lived his [life]...
...that it is [difficult] to [pinpoint], [exactly] when [the man] lived... 
...because [knowing] that [information] could be [fatal].

So, he may have been [dangerous looking]...? 
But, may not have been [dangerous looking].

Might've been a [normal looking guy]... 
...one who lived approximately [X] number of years ago...

That's about [as close as anyone could ever truly get], to [knowing] the [exact number of years]
that [the man] lived his life, without [risking certain death]...
...from how [breathtaking] it has been [designated] as being...
...to [know that information].
'@)

$Doc.Add("Legend Has It... (2)",@'
However, the [legend] of the man, is about the [safest way] to go about [knowing]
a [god damn thing], about [the man], without [risking certain death].

Some may even ask:
[People]: What if he was some [Lord Farquad] lookin' motherf*****...
          Ya know...?
          The dude from [Shrek]...

Well, [that] remains a [mystery].

[Legend] has it that [the man] was [tall]... but, how tall...?
Nobody [knows] how [tall] [the man] was.

Nobody really knows what [the man]'s name was, either.
What people [do] generally know, according to [legend], is that [the man]
had [powers beyond measure].

The powers that this man had, were...
[+] [the innate ability to snap his fingers], and
[+] [instantly drown anyone foolish enough to stand before him]... 
[+] ...[in a sea of beer]

[Legend] has it, that the man had [struggled] to [control] his [ability].

He [may] or [may not] have gotten [angry] or [frustrated], but whether he did
or didn't... he would unexpectedly cause total chaos to those around him.

Because, he would either accidentally or even in some cases, intentionally drown
those around him in beer, even if anybody even sneezed around him, or startled him
slightly...

That [person], or [those people], were [immediately drowned in beer].
[Dead on arrival].
'@)

$Doc.Add("His Quest and the Monks",@'
According to the legend...

He embarked upon a [quest], to be able to [control his powers]. 

At some point along the way, [the man] supposedly met a group of [monks].

These weren't your ordinary, run-of-the-mill type of [monks] either.
Ohhhhh no.

They were [powerful], [sacred], [legendary monks], [descendants] of those who lived
with great [Chinese warlords] who battled the [Mongolians] deep within the [Himalayan] 
moutains, before the [Great Wall of China] was built.

Those types of [monks].

The [monks] were able to teach the man how to [meditate] and [control] his [emotions].
From that day forward, [the man] was finally able to [harness] his [power].
'@)

$Doc.Add("Legend Has It... (3)",@'
Legend has it, that as [the man] grew [older], he realized that his [power] could be
used for [good]... or [evil].

[The man] supposedly decided to become a [vigilante], using his [power] to fight [evil]
and [protect innocent people]. [The man] would often [snap his fingers], and the
[evil doers], without a chance to defend themselves...

...would be [swept away] in a [flood] of [beer], typically [drowning] them to [death].
In some cases, when [the man]'s foes were [strong enough] to [survive] the [onslaught]
of the [river of beer]...?

It still left them [too disoriented] to [fight back].
Effectively like [shooting fish in a barrel].

That was supposedly [the man]'s legacy.
'@)

$Doc.Add("Wanted Man",@'
Despite his good intentions, [the man] was a [wanted man].
A [fugitive]...

[People] from [all around the world] saw him as a [threat], and tried to [capture him],
whereby causing [the man] to be [constantly on the move], and never truly being able to 
[sleep] without (1) eye open... in order to stay a step ahead of those seekinng to 
[capture] and [imprison] him.

Legend has it, that one day, [the man] was told about a [group of warlords] who had taken
over a [small village] in [Africa], and the [villagers] were being [held captive].

In a battle against time...?
[The man] knew he had to help...
Because if he didn't...?
Then, nobody would.

And so, he immediately set off to [rescue] the [villagers].

When [the man] arrived, the [warlords] were [waiting for him]. 

Word had spread all over, and they heard about [the man]'s power, and were [determined] to
[capture him], as he had a [bounty] on his [head]. 

However, the most dangerous man that ever lived...
...was [too fast], and [too powerful] for them. 

That's when he [snapped his fingers]... 
...and the [warlords] were [engulfed] in a [river of beer].
'@)

$Doc.Add("Conclusion",@'
Of course, this is all according to [legend], and [nobody knows for certain],
whether or not the [legend] is [actually true].

Frankly, if the [legend] IS [actually true], perhaps that's what caused the man
to be considered [the most dangerous man that ever lived]. 

It would make [total sense].

[The man] could most certainly have theoretically been the type of dude, who
would go around, recklessly [snapping] his [fingers] whenever someone [casually]
looked at him the wrong way...

...and then [that person], or [those people], would be [drowned in beer].
For lookin' at [the most dangerous man that ever lived], the wrong way.

And that is the legend behind, [the most dangerous man that ever lived].

And, [nobody knows] whether or not the [legend] is [true] or [false].
Everyone just has to assume that it could be...
...and don't dare [venture] into the [depths] of [knowing much more than that].

Because of how [dangerous] it would be, to [know that information].
If it were [true].
Because it would be [literally breathtaking].
'@)
