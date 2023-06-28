Class ExhibitEntry
{
    [UInt32]       $Index
    [String]        $Date
    [String]      $Length
    [String]        $Name
    [String] $DisplayName
    [String]        $Link 
    [String]     $Summary
    ExhibitEntry(
    [UInt32]       $Index,
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        $This.Index       = $Index
        $This.Date        = $Date
        $This.Length      = $Length
        $This.Name        = $Name
        $This.DisplayName = $DisplayName
        $This.Link        = $Link
        $This.Summary     = $Summary
    }
    [String] GetOutput()
    {
        $Out  = @( )
        $Out += "{0} : {1}" -f       "Index".PadRight(12," "), $This.Index
        $Out += "{0} : {1}" -f        "Date".PadRight(12," "), $This.Date
        $Out += "{0} : {1}" -f      "Length".PadRight(12," "), $This.Length
        $Out += "{0} : {1}" -f        "Name".PadRight(12," "), $This.Name
        $Out += "{0} : {1}" -f "DisplayName".PadRight(12," "), $This.DisplayName
        $Out += "{0} : {1}" -f        "Link".PadRight(12," "), $This.Link

        $Lines = $This.Summary -Split "`n"

        If ($Lines.Count -lt 2)
        {
            $Out += "{0} : {1}" -f "Summary".PadRight(12," "), $This.Summary
        }
        Else
        {
            ForEach ($X in 0..($Lines.Count-1))
            {
                If ($X -eq 0)
                {
                    $Out += "{0} : {1}" -f "Summary".PadRight(12," "), $Lines[$X]
                }
                Else
                {
                    $Out += "{0}   {1}" -f "".PadRight(12," "), $Lines[$X]
                }
            }
        }

        Return $Out -join "`n"
    }
}

Class ExhibitList
{
    [String]        $Name
    [String] $Description
    [Object]      $Output
    ExhibitList([String]$Name)
    {
        $This.Name = $Name
        $This.Clear()
    }
    SetDescription([String]$Description)
    {
        $This.Description = $Description
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] ExhibitEntry(
    [UInt32]       $Index,
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        Return [ExhibitEntry]::New($Index,
                                   $Date,
                                   $Length,
                                   $Name,
                                   $DisplayName,
                                   $Link,
                                   $Summary)
    }
    Add(
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        $This.Output += $This.ExhibitEntry($This.Output.Count,
                                           $Date,
                                           $Length,
                                           $Name,
                                           $DisplayName,
                                           $Link,
                                           $Summary)
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

$List = [ExhibitList]::New("Profiling Law Enforcement Conduct")
$List.SetDescription(@"
In this video, I'm going to examine (2) different incidents that sort of coalesce back into a
[common denominator]. That [common denominator], is when law enforcement take (1) side of a story,
and they refuse to entertain the [other side of the story].

Sometimes, I'll run into people that hear me say stuff like that, and then they'll be AMAZED,
or they will flat out tell me that I'm fuckin' [stupid] or [ridiculous] to think the things that I do.

Well, I'm here to tell you that sometimes [people are pretty careless], and in many cases, 
they don't put a lot of effort into this stuff that I've been accumulating, and it's called [evidence], 
and even [documentation]. Much like this document right here.

Here's the thick and thin of it.
People that are [participants] of the [human race], [they lie to each other] on a [daily basis].

Do they ALWAYS lie...?
No. 
But- in many cases, certain people lie at a [much higher rate] than other people would be led to believe,
and the [end result] is that when people (like me) seek to [contradict those lies]...?

They need to have some sort of [evidence] or [believable story].
Sometimes, the true story is [not very believable], even though it is [true]. 
That is because, [sometimes the truth is stranger than fiction].

Sometimes, the true story is [not very likable], even though it is [true].
That is because, [if we don't believe in free speech for those we despise, we don't believe in it at all].

Sometimes, the true story is [ignored].
That is because, people today are [incredibly distracted] by so many things.

Suffice to say, all of these things are WHY [evidence] matters.
People should really stop watching shows like [CSI: Miami] and [Law and Order].

On these FICTIONAL SHOWS, the police ALWAYS collect evidence, and they ALWAYS get the bad guy.

They never ever show themselves doing the things bad guys do.
They never show themselves [NOT collecting evidence].
They never show themselves [NOT reading people their miranda rights].
They never show themselves [making unlawful arrests].
Nah, they want all of that shit to be [incredibly difficult to believe].

Stop watching these fictional fucking shows, because they're just as credible as [One Life To Live].

If people don't [believe] a particular story, AND they're [too lazy] to consider the [supporting evidence]...?
That means that person is [fuckin' stupid], and it's [perfectly acceptable to insult them] for it.

Sometimes, [the truth is stranger than fiction], and people [lack the capacity] to know that the things
they believe are fucking [fictional]. Sometimes, the authorities are responsible for perpetuating [fictional]
stories as [fact], and they get [paid] to do this, too.

When I use these [curse words], it is typically because [formally] talking to people doesn't
actually make a difference, in many cases. If not, nearly every case. 

Talking to people [formally] isn't a bad idea, but sometimes they will use various [psychological manipulation]
techniques such as [distractions], [redirections], [excuse-having], and even your standard-issue, 
run-of-the-mill, [false statement of doom].

It is coloquially referred to as [bullshit], and some people don't really know when the
[false statement of doom] has been used against them. 

Sometimes people will assume the [truth] is the [bullshit], and the [bullshit] is the [truth].
They may even [roll their eyes] when you indicate this... cause [they're fuckin' miserable].

Simply put, the [false statement of doom] is not unlike the [flaccid penis of doom]...
They have to take something artificial, like a [Viagra/Cialis], to get it up.

That happens a lot, let me tell ya.

That's why some people will call the truth [bullshit], and then they continue to drag their lazy limp dicks
and just think of the dumbest fuckin' things they can think of, in order to get rid of somebody... 
...especially if they're [annoyed] by that person.

Nah, if somebody feels [annoyed] by a particular person coming around, asking questions and stuff...?
In many people's minds, that means the person asking questions is less important than you are, so it's okay
to (say/do) whatever you can think of, to get rid of them.

Sounds stupid, right...? Well, it is. But- that is what so many people think.
And then, they may even be stupid enough to say "I don't think that at all~!"
Yeah, well... [actions speak louder than words].

That means, they may SAY these words, but the words are [cosmetic] and [shallow]... so, they're not [genuine].
It's not unlike when someone says "I love you", but you know they don't even mean it.

It's like catching some girl blowing some other dude, and she stops for a second, pulls that dude's dick out
of her mouth and says "It's not what it looks like", or "I love you"... and then she puts that dude's dick
back into her mouth, and continues from where she left off.

Sometimes you have to call it like you see it.
If you just saw some girl blowing some other dude that isn't YOU, and then she pulled that dudes dick out
of her mouth to say "It's not what it looks like", uh- [it's **exactly** what it looks like].

In that case, the words that she said are [meaningless], because her [actions] contradict what she fuckin' said.
Unless of course, someone is pretty fuckin' stupid, and they trust a girl because of her appearance alone.

The reason why I'm bringing up all of these [analogies] is because [the police often do shit just like this].

The [action] is the [principle] that you should look at, to judge whether or not [they're fucking lying]. 

If anything, swearing causes people to realize that I get pretty [aggravated] by people who can't understand
what the hell I keep saying, or they doubt what I'm saying.

That's why I [record audio recordings] and [make videos], because people have a lot less to use
as an excuse, or to DOUBT, when I capture the stupid shit that people (say/do).

Script: How to investigate stuff, so that the police don't have to:
1) investigate stuff,
2) break a nail, 
3) ruin their mascara/cry, 
4) break a sweat, 
5) or whatever...

If you get a cop that has to do **any** of those things...?
Then, [you're screwed for the rest of eternity], and [you may as well give up on your life],
because there's no comin' back from that...

Don't expect them to be very [friendly] or [helpful] if they have to resort to DOING any of those things.

Though I'm sure they'll be ok if they have to do any of those things...?
...it's better not to have to take your chances.

Do the work FOR them, so they don't have to.
They'll thank you later.

(2) class definitions to put some exhibits together...
"@)

$List.Add("02/26/23",
"0h 52m 23s",
"2023_02_26_21_23_06.mp3",
"[SCSO K. Rossi] trespassing me at [Shoppers World Market 32]",
"https://drive.google.com/file/d/1D2tVC_kO_-SYz27eiYPrd-wyTHBI-YRd",@"
To them, that is an [isolated incident]. 
Apparently, [Jim Cannistracci] thought I was just causing problems for the
people at [Market 32], and so, even after being a resident of the fucking
town for over (35) years, and being a customer of [Price Chopper] since (1987)...?

I've been fucking trespassed from the premises, even though there is a whole other
side of the story that the cops are commonly [too lazy] to [investigate]. 
(^ They are VERY skilled at this)
"@)

$List.Add("01/22/23",
"0h 04m 35s",
"2023_01_22_16_43_58.mp3",
"[Mark] @ [Market 32 Shoppers World]",
"https://drive.google.com/file/d/1jTXlZ5oiuS3i0EWgmuoT2SMDzbr01aHc",@"
Dude named [Mark] at the [Shoppers World Market 32] customer service desk, not
knowing that [Governor Kathy Hochul] recently passed a brand new "law" that even
the [Golub Corporation] and all of the (Market 32/Market Bistro) stores are 
supposed to "follow"...

[https://www.governor.ny.gov/
news/governor-hochul-signs-package-legislation-protect-credit-and-gift-card-holders]

[Legislation S.3467-B/A.4629-C]
- allows for redemption when the remaining balance is less than five dollars
- should probably be posted next to every labor sign at every business in NYS
"@)

$List.Add("02/05/23",
"0h 33m 44s",
"2023_02_05_11_39_11.mp3",
"Market 32 Shoppers World (Precomplaint)",
"https://drive.google.com/file/d/1m8WkmxdKA_jHXGjqhPvaTjIk7TqjNw_p",@"
This contains the incident where the manager asked me to leave the building AFTER
I told him that I wanted to [submit a complaint] about the manager [Mark] trying to
steal [15 cents] from me when I went to trade a dollar in coins the night before.

The guy at the [Golub Corporation] headquarters is like "There's no way that we would
be able to look at security footage to see you counting the change..." And his name
is [Jim]. Yeah, there IS a way that one of the (3)+ cameras in the food court that has footage
of me sitting there for anywhere between (3-12)+ hours a day, saw me [counting the change]
at about [02/04/23 2100].

I know a lot about [security cameras], such as the [dome cameras] they have all over the
store. I also know about PTZ cameras that they would use to pan, tilt, and zoom over
the whole store. I also know about the [Cisco Meraki] equipment that they use to connect
everything inside the store. I also know how to [service all of the equipment] at the store
that [connects to the network], such as the [Ingenico point of sale devices] that people
use to [swipe their credit or debit cards], the [registers], the [touchscreens], all of it.

I make a lot of video content that shows my expertise with:
- Application Development
- Virtualization
- Network and Hardware Magistration
- Graphic Design
...so if I'm telling you that I've known [Michael Philipsak] for 30+ years, and that [Mark]
tried to steal [15 cents] from me the night before...? You fucks have what you need on your
end to determine that you have an employee that tried to steal my fucking money.

I also know that they have a camera positioned over every single register, such as the
location where [Mark] counted the change and tried to take my [15 cents] the night before
I made this recording. If the security dude is gonna tell me I'm watching too much CSI,
I think he should probably do a Google search for "Cisco", and figure out what the hell
they do.

The audio log also contains information about me complaining about [Eric Pearson]
who has possession of my [LTD MH400] that he adamantly refuses to give back, in addition
to a [1TB Toshiba external hard drive], a [500 GB Samsung PCI-E SSD] that I installed into
his friend's [Dell] or [Acer] laptop that I installed [Windows 10] onto, [never paid] for
any of it - those details aren't so relevant, because I also have an [audio recording] of
him refusing to give me my stuff back, in addition to a [video] of him in his garage.

[Refusing to pay me what I'm owed], or [to give my possessions back].
This is a [common theme] where people think they can just [take stuff from me].

That's why I get [really fucking pissed off with people], and why I talk about the 
[second amendment] quite a lot.
"@)

$List.Add("02/06/23",
"0h 00m 00s",
"2023_0205-(ComplaintMarket32).pdf",
"Complaint [~] Market 32 Shoppers World Plaza",
"https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0205-(ComplaintMarket32).pdf",@"
This is a document where I throw in some clever skits, while making a complaint about
the store that I'd been going to and doing work, seeing as how I recorded this video
at the library:
_________________________________________________________________________
| 10/15/22 | Intellectual Property Theft | https://youtu.be/-GScIS_PlOo |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
...and [Alexandra Gutelius] kicked me out of the [Clifton Park Halfmoon] library for the
following (90) days.

Which is why I was working at the [Price Chopper] as often as I was.

I dropped this document off with the people at the [Golub Corporation] headquarters in
Schenectady back on [02/07/23]. I also made this video later that day...
_____________________________________________________________________________
| 02/07/23 | Golub Corp - Empire State Plaza | https://youtu.be/Dj9E-eNe4Tg |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

$List.Add("02/16/23",
"0h 00m 00s",
"2023_0216-(2023Work).pdf",
"Document that I distributed in Clifton Park, Malta, Saratoga, and Ballston Spa",
"https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2023_0216-(2023Work).pdf",@"
Back on the night of 02/16/23 into the morning of 02/17/23, I distributed this document
to a bunch of places because I had anticipated that the 730 hearing that moron Joe Fodera
required me to go get, was basically meant to be a complete waste my time.
"@)

$List.Add("02/17/23",
"0h 10m 39s",
"2023_02_17_09_34_04.mp3",
"2nd conversation with [Captain/Undersheriff Jeffrey Brown]",
"https://drive.google.com/file/d/182GBCdeBN_s6R7EBWj6XrvIqiIJeKAZ3",@"
This is the [SECOND] time that I've had a conversation with [Captain Jeffrey Brown]
from the [Saratoga County Sheriffs Office], [Head Sheriffs Office].
"@)

$List.Add("02/02/21",
"0h 20m 01s",
"2021_0202-(SCSO).m4a",
"1st conversation with [Captain/Undersheriff SCSO Jeffrey Brown]",
"https://drive.google.com/file/d/1JECZXhwpXFO5B8fvFnLftESp578PFVF8",@"
This is the [FIRST] time that I've had a conversation with [Captain Jeffrey Brown]
from the [Saratoga County Sheriffs Office], [Head Sheriffs Office].

In this audio recording, I obtained a record of the night where I was almost murdered
outside of Center For Security, AND, (Catricala Funeral Home/Computer Answers).

I gave [Captain Jeffrey Brown] my statement regarding [SCSO-2020-028501], which he
found FOR me, in this phone call.
"@)

$List.Add("02/26/23",
"0h 52m 23s",
"2023_02_26_21_23_06.mp3",
"SCSO K. Rossi",
"https://drive.google.com/file/d/1D2tVC_kO_-SYz27eiYPrd-wyTHBI-YRd",
"This is the incident where I initially met [K. Rossi].")

$List.Add("02/28/23",
"1h 54m 22s",
"2023_0228-(Impressions).mp4",
"Investigating police conduct, impressions",
"https://youtu.be/BWvPCHFJwsg",@"
Readme + documents and stuff from within that video
https://github.com/mcc85s/FightingEntropy/tree/main/Video/20230228
"@)


$Doc = New-Document -Name $List.Name

$Doc.Add("Introduction",$List.Description)
$Doc.Add("Class [ExhibitEntry]",@'
Class ExhibitEntry
{
    [UInt32]       $Index
    [String]        $Date
    [String]      $Length
    [String]        $Name
    [String] $DisplayName
    [String]        $Link 
    [String]     $Summary
    ExhibitEntry(
    [UInt32]       $Index,
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        $This.Index       = $Index
        $This.Date        = $Date
        $This.Length      = $Length
        $This.Name        = $Name
        $This.DisplayName = $DisplayName
        $This.Link        = $Link
        $This.Summary     = $Summary
    }
}
'@)

$Doc.Add("Class [ExhibitList]",@'
Class ExhibitList
{
    [String]        $Name
    [String] $Description
    [Object]      $Output
    ExhibitList([String]$Name)
    {
        $This.Name = $Name
        $This.Clear()
    }
    SetDescription([String]$Description)
    {
        $This.Description = $Description
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] ExhibitEntry(
    [UInt32]       $Index,
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        Return [ExhibitEntry]::New($Index,
                                   $Date,
                                   $Length,
                                   $Name,
                                   $DisplayName,
                                   $Link,
                                   $Summary)
    }
    Add(
    [String]        $Date,
    [String]      $Length,
    [String]        $Name,
    [String] $DisplayName,
    [String]        $Link,
    [String]     $Summary)
    {
        $This.Output += $This.ExhibitEntry($This.Output.Count,
                                           $Date,
                                           $Length,
                                           $Name,
                                           $DisplayName,
                                           $Link,
                                           $Summary)
    }
    [String] ToString()
    {
        Return $This.Name
    }
}
'@)

ForEach ($Item in $List.Output)
{
    $Doc.Add($Item.Name,$Item.GetOutput())
}

$Doc.Add("Conclusion",@'
And there ya have it. Those things right there, basically pertain to how much of an investigator I am,
and how I make an effort to include and consider other details which might not have something to do
with someone trespassing at the Market 32 in Clifton Park...? But- these things indicate that people
really like to trim and dissect the total story so that they feel less bothered by things like a dude
who cares about stuff called "laws" and "principle".

Ya know...?
What if I could do [Jim Cannistracci]'s job with no training whatsoever on the first day...?
Will the people who work at [Price Chopper] have a conversation amongst themselves that goes like this...

[Guy 1]: That fuckin' Michael Cook dude who used to sit in the food court, he used to manage the
         Computer Answers shop for years and did business solutions expertise.
[Guy 2]: Yeah, that fuckin loser lookin' dude...?
[Guy 1]: *nodding* That loser lookin' dude was apparently working on something really important.
[Guy 2]: Oh really...?
         So that loser lookin' dude used to do a job where he made $175/hour...?
[Guy 1]: Yup. That loser lookin' dude that sat in the food court every day used to make $175/hour.
         Not (1) single person that works in this store makes $175/hour.
[Guy 2]: Nah... that's...
[Guy 1]: A lot of money, right...?
[Guy 2]: Yeh. That's a lot of money dude.
[Guy 1]: Yeh.
[Guy 2]: Then why the hell is he comin' in here, looking like a fucking homeless vagrant...?
[Guy 1]: Well, he claims that it is because there's a lot of careless morons with badges.
         And in state and county agencies.
         They don't really do their job, and they ignore evidence in order to force answers
         on their REPUTATION or their APPEARANCE. That's it.
[Guy 2]: LOL. YEAH RIGHT.
[Guy 1]: Dude says "seeing is believing, but appearances may be deceiving."
         Just like he did in this video with his kids...
         05/23/20 | 2020_0523-Virtual Tour | https://youtu.be/HT4p28bRhqc
[Guy 2]: Wow. So, the dude makes YouTube videos and stuff...?
[Guy 1]: *nodding* Yup.
         That's what he does.
[Guy 2]: Yeah well... We're just gonna have to trespass him from the store so that he can't
         actually continue doing work here, or whatever.
[Guy 1]: Dude actually thinks that the governor passed a law where he could get cash for
         the remaining balance on his gift cards if there's less than [$5.00] on them.
[Guy 2]: Wow. We don't do that.
[Guy 1]: I know, well... we're SUPPOSED to do that, according to this new law.
[Guy 2]: Yeah well... fat chance, dude.
[Guy 1]: *puts sunglasses on* That's right dude.
         We're fuckin' awesome, and *shaking head* he isn't.
[Guy 2]: That's right dude.
         Nobody is gonna come into OUR store, and do work faster than us on his first night.
[Guy 1]: That's... why we gotta trespass him from the store, otherwise he COULD do that.
[Guy 2]: Yeh, I'll believe it when I see it.
[Guy 1]: Nah, you won't see it if we eject him from the store permanently.
[Guy 2]: Yeah, that'll show him~!
         LOL what a dumbass~!

^ Is that a realistic conversation...?
Who knows.
More importantly...?
Who gives a shit.
'@)

$Doc.GetOutput() -join "`n" | Set-Clipboard
