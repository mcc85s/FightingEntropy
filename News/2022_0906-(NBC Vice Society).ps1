
Class TranscriptLine
{
    [UInt32]   $Index
    [String] $Content
    TranscriptLine([UInt32]$Index,[String]$Content)
    {
        $This.Index   = $Index
        $This.Content = $Content
    }
    [String] ToString()
    {
        Return $This.Content
    }
}

Class Transcript
{
    [String] $Organization
    [String]       $Anchor
    [String]         $Name
    [String]         $Date
    [String]          $URL
    [Object]        $Notes
    Transcript([String]$Organization,[String]$Anchor,[String]$Name,[String]$Date,[String]$URL)
    {
        $This.Organization = $Organization
        $This.Anchor       = $Anchor
        $This.Name         = $Name
        $This.Date         = $Date
        $This.URL          = $URL
        $This.Notes        = @( )
    }
    Add([String]$Line)
    {
        $Lines = $Line -Split "`n"
        If ($Lines.Count -gt 1)
        {
            ForEach ($X in 0..($Lines.Count-1))
            {
                If ($Lines[$X].Length -le 1)
                {
                    $Lines[$X] = " " * 104 -join ""
                }

                $This.Notes += [TranscriptLine]::New($This.Notes.Count,$Lines[$X])
            }
        }
        If ($Lines.Count -eq 1)
        {
            If ($Lines.Length -le 1)
            {
                $Lines = " " * 104 -join ""
            }

            $This.Notes += [TranscriptLine]::New($This.Notes.Count,$Lines)
        }
    }
    [Object[]] Slot()
    {
        Return @( "Organization Anchor Name Date Url" -Split " " | % { $This.$_ } )
    }
    [String] Pad([UInt32]$Length,[String]$Char,[String]$String)
    {
        $Buffer  = $Length - $String.Length
        $Padding = $Char * ($Buffer-2)
        Return "{0}{1} |" -f $String, $Padding
    }
    [String[]] Output()
    {
        $Obj     = @{0="";1="";2="";3="";4="";5=""}
        $X       = ($This.Slot() | % Length | Sort-Object)[-1] + 20
        $Obj[0]  = @([char]95) * $X -join ''
        $Obj[1]  = $This.Pad($X," ","| Organization : $($This.Organization)")
        $Obj[2]  = $This.Pad($X," ","| Anchor       : $($This.Anchor)")
        $Obj[3]  = $This.Pad($X," ","| Name         : $($This.Name)")
        $Obj[4]  = $This.Pad($X," ","| Date         : $($This.Date)")
        $Obj[5]  = $This.Pad($X," ","| Url          : $($This.Url)")
        $Obj[6]  = @([char]175) * $X -join ''

        $This.Notes | % { $Obj.Add($Obj.Count,$_) }

        Return @($Obj[0..($Obj.Count-1)])
    }
    [String[]] Comment()
    {
        Return @( $This.Output() | % { "# $_ "} )
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

$News = [Transcript]::New("NBC",
                          "Tom Costello",
                          "FBI Investigating Cyber Attacks On Schools By Ransomware Group",
                          "09/06/2022",
                          "https://youtu.be/eg-2sTaSwQs")

$News.Add(@"
Costello : Tonight we're also learning about a new cybersecurity and ransomware threat 
directed toward schools nationwide. 
           
Here's what we know right now.
           
The FBI and Homeland Security have been investigating these threats for about a week or so,
they say the attacks are being carried out by a ransomware group called "Vice Society".

The alert says that schools are particularly lucrative targets because of the amount of 
sensitive data in school systems.

Homeland Security is warning cyberattacks may increase as the new school year gets underway, 
and criminal ransomware groups see opportunities in school districts with LIMITED cybersecurity 
resources. 

NBC Investigative Correspodent Tim Winter is joining us now from New York.
Tom, what more do we know about "Vice Society", who's behind it...?

Winter : Well, that's something that the authorities are still trying to figure out and determine
the exact origin of Vice Society. They APPEAR to be an overseas network. There's been some private 
security, so, this is not DHS or the FBI or CISA which is the Cybersecurity and Infrastructure
Security Agency, part of DHS (it is not part of DHS, it's based alongside the National Security 
Agency) but OTHER private online sleuths if you will. 

People in the cybersecurity space Tom, say that they MIGHT be Eastern European or perhaps ANOTHER
country MIGHT be behind them, namely Russia (probable) still trying to determine that, I'm not
suggesting that this is a state sponsored act but this kind of all came up in the course of the 
last week or so when the LA Unified School District identified themselves as being a target of a
cyberattack and ransomware and I think that's something that people are going to be LOOKING
towards, here as you alluded to, as the school year begins.

Costello : You know, you and I have both covered a lot of cyberattacks over the years and CISA 
among them is of course, leading the charge there... What OTHER attacks is THIS GROUP, allegedly 
responsible for, and WHAT are they looking for, is it MONEY...? Is it DATA...? What are they
looking for...?

Winter : Well, it's a LITTLE bit of BOTH (<- key detail, why [FightingEntropy(π)] will be useful),
one of the things that they do is NOT ONLY do they LOCK DOWN your system by putting this ransomware
up, in other words PAY US or you'll never get access to your files again, period, because they've
been encrypted. 

But ALSO, according to the information we've received today from CISA and the FBI they initially
begin by INFILTRATING the NETWORK Tom, and EXPLOITING the DATA. So, in other words, they go in,
they don't just lock it down, they TAKE all of the data and make a COPY of it, and THEN they lock
it down. 

So that's kind of a 2-PRONGED attack (<- Multi-pronged approach with a similar solution), and 
obviously the downside to that is ONE... that they have potentially your CHILDS INFORMATION, 
uh potential information about who their PARENTS are, their SCHOOL BACKGROUND, but then ALSO they
can cause, and LA alluded to this, a SIGNIFICANT DISRUPTION in their NETWORKS and their ability
to FUNCTION and OPERATE because they LOCK DOWN those FILES and make things VERY DIFFICULT for 
SCHOOLS to operate which don't an enormous budgets relatively speaking when we're talking about 
IT budgets, to operate and deal with these type of threats. (<- Why a SPONSORSHIP/INVESTMENT in 
[FightingEntropy(π)] will be useful)

Costello: We should remind the audience, CISA stands for essentially stands for cybersecurity 
in the United States, cybersecurity command. So, lets talk through some of the TIPS for the school
districts, what they can do RIGHT NOW to protect their information...?

Winter : Right, so right now, the FBI is saying "Look if you notice ANY sort of suspicious activity,
you NEED to reach out to us RIGHT AWAY, and if you can provide us with some of your logs, right,
your IT logs so the ACTIVITY on your network that can be very helpful." 

Because one of the things that they have identified Tom, are the type of "off the shelf" as they
call it, uh type of methods that they're using to attack, it's a "Hello Kitty" ransomware and all
sorts of OTHER names, people that are in the cybersecurity field will be familiar with them that
are watching us, but they know the types of signatures and the types of tools that this group uses, 
they don't appear to use any proprietary tools, so they're asking if you notice any sort of suspicious 
activity to reach out to us. But the OTHER thing is Tom, all the NORMAL precautions apply. 
Do you have all your latest updates...?
Are you using VPNs in your remote systems correctly...? 
And are you on the lookout for phishing emails...?
All important things they say can help protect, from one of these attacks.
"@)
