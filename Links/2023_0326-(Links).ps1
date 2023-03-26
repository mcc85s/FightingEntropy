# [Date: 03/26/2023]
#
# Here's an idea that I have to [organize links].
# I'll add more to it at some point to generate a [markdown file].

Class LinkItem
{
    [String]          $Date
    [String]          $Name
    [String]          $Link
    [String] $Description
    LinkItem([String]$Date,[String]$Name,[String]$Link,[String]$Description)
    {
        $This.Date        = $Date
        $This.Name        = $Name
        $This.Link        = $Link
        $This.Description = $Description
    }
}

Class LinkLibrary
{
    [String]   $Date
    [Object] $Output
    LinkLibrary()
    {
        $This.Date = $This.GetDate()
        $This.Clear()
    }
    [String] GetDate()
    {
        Return [DateTime]::Now.ToString("MM/dd/yyyy")
    }
    [Object] LinkItem([String]$Date,[String]$Name,[String]$Link,[String]$Description)
    {
        Return [LinkItem]::New($Date,$Name,$Link,$Description)
    }
    Write([String]$Line)
    {
        [Console]::WriteLine($Line)    
    }
    Clear()
    {
        $This.Output = @( )
    }
    Add([String]$Name,[String]$Link,[String]$Description)
    {
        $This.Output += $This.LinkItem($This.Date,$Name,$Link,$Description)
        $This.Write("Added [+] $Name")
    }
    Add([String]$Date,[String]$Name,[String]$Link,[String]$Description)
    {
        $This.Output += $This.LinkItem($Date,$Name,$Link,$Description)
        $This.Write("Added [+] $Name")
    }
}

$Links = [LinkLibrary]::New()

$Links.Add("Supermassive Black Hole",
"https://www.msn.com/en-us/news/technology/scientists-discover-supermassive-black-hole-that-now-faces-earth/ar-AA1965j4",
@'
[Royal Astronomical Society] reports [PBC J2333.9-2343] a [galaxy] that is [(657) million]
light-years away, needed [reclassification], as a [supermassive black hole] that faces
our [solar system], was [discovered] and it [interfered] with the [observations] of 
that [galaxy], and [affected] its' [original classification].
'@)

$Links.Add("Gordon Moore",
"https://www.msn.com/en-us/money/companies/silicon-valley-loses-a-giant/ar-AA194Lni",
@'
The co-founder of [Intel] passed away on [March 24th, 2023] at the age of (94).

What will [Intel] put [inside], from here forward...?
Nobody knows...

My mother always said...
[Mom]: [Moore's Law]
       If something CAN go wrong...?
       Something WILL go wrong.
       
Pretty sure that's not what [Moore's Law] is.
Nah, [Gordon Moore] is the guy who came out with a [paper] for a [magazine] back in the
[late (60)]'s regarding the number of [transistors] on a [chip], as well as their [size].

[Gordon Moore] [predicted] in that [article], that for the [next (10) years], that for 
each [(2) years] that went by, [chips]' fabricated would have [doubled performance], or
its [cost] cut in [half], or... [some combination or variation of the two].

This was mainly because the [transistors] they were able to pack onto a chip were getting
[smaller] and [smaller], whereby allowing their:
[+] [capacity]
[+] [complexity] 
[+] [capabilities] 
...to be [increased]. 

THAT is [Moore's Law].
'@)

$Links.Add("Potential Banking Armageddon",
"https://www.msn.com/en-us/money/personalfinance/close-to-190-banks-could-face-silicon-valley-bank-s-fate-according-to-a-new-study/ar-AA18OzZ9",
@'
After [Silicon Valley Bank] failed, it was quickly determined that close to (190)
additional banks may:
[+] [collapse]
[+] [fail]
[+] [go bankrupt]
[+] [go the way of the Dodo bird]
[+] [join Lehman Brothers and Bear Sterns]
...even if only [half] of their [depositors] decide to [withdraw] their [funds].

Though, that has a lot to do with the fact that a lot of [banks] have invested into [bonds]
and [mortgages], and the [Federal Reserve]'s aggressive [interest rate] hikes to tamp down 
[inflation] have [eroded the value of those assets].
'@)

$Links.Add("Twitter loses about 24B in value",
"https://www.msn.com/en-us/money/companies/elon-musk-suffers-a-huge-loss/ar-AA195SSE",
@'
As to be expected, [Twitter] lost a lot of value because the company, under [Elon Musk]'s
management, has slashed many of it's [employees], [expenses], and [income], because the
new direction has eliminated some of the [malicious policies] that [Twitter] had 
regarding [censorship] and [advertising].

However, this [new direction] has also spilled over into changing the policies at other
companies such as [Facebook], and has also caused many other issues in [Silicon Valley].

It is enirely possible that since [Elon Musk] purchased [Twitter], that the entire
landscape in [Silicon Valley] has been drastically changed, whereby causing a total
collapse of banks such as [Silicon Valley Bank], and potentially another < 190 more.
'@)

$Links.Add("Keanu Reeves (Digital Edits)",
"https://www.insider.com/keanu-reeves-contracts-clause-banning-digital-tweaks-2023-2",
@'
The man who has literally chased down psychos that build bombs, and install them on
buses (just kidding), has a policy against digitally editing his performances.

In every contract he has with a particular film, there is a clause that states that
his performances may not be digitally altered without his permission.

This has a lot to do with the current controversy regarding [artificial intelligence]
and [deepfakes].
'@)
