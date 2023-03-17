Class VideoDate
{
    Hidden [String] $Date
    Hidden [UInt32] $Day
    Hidden [UInt32] $Month
    Hidden [UInt32] $Year
    VideoDate([String]$Date)
    {
        $This.Day   = $Date.Substring(4,2)
        $This.Month = $Date.Substring(6,2)
        $This.Year  = $Date.Substring(0,4)
        $This.Date  = "{0:d2}/{1:d2}/{2:d4}" -f $This.Day, 
                                                $This.Month, 
                                                $This.Year
    }
    [String] ToString()
    {
        Return $This.Date
    }
}

Class VideoEntry
{
    [UInt32]         $Index
    [String]          $Date
    [String]          $Name
    [String]           $Url
    [String]   $Description
    VideoEntry([UInt32]$Index,[String]$Name,[String]$Url,[String]$Description)
    {
        $This.Index       = $Index
        $This.Date        = $This.GetDate($Name)
        $This.Name        = $Name
        $This.Url         = $Url
        $This.Description = $Description
    }
    [String] GetDate([String]$Name)
    {
        Return [VideoDate]($Name.Substring(0,9).Replace("_",""))
    }
}

Class VideoReel
{
    [String]   $Name
    [String]   $Date
    [Object] $Output
    VideoReel([String]$Name,[String]$Date)
    {
        $This.Name = $Name
        $This.Date = $Date
        $This.Clear()
    }
    Clear()
    {
        $This.Output = @( )
    }
    [Object] VideoEntry([UInt32]$Index,[String]$Name,[String]$Url,[String]$Description)
    {
        Return [VideoEntry]::New($Index,$Name,$Url,$Description)
    }
    Add([String]$Name,[String]$Url,[String]$Description)
    {
        $This.Output += $This.VideoEntry($This.Output.Count,$Name,$Url,$Description)
    }
    Review([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        $Item   = $This.Output[$Index]
        $Title  = "Date: {0}, Name: {1}" -f $Item.Date, $Item.Name
        $Prompt = "Url: {0}" -f $Item.Url

        Write-Theme -Title $Title -InputObject $Item.Description -Prompt $Item.Url

        (Get-Host).UI.PromptForChoice($Item.Name,"Launch [$($Item.Url)]...?",@("&Yes","&No"),0)
        {
            0 
            {
                Start $Item.Url
            }
            1
            {
                [Console]::WriteLine("Skipping")
            }
        }
    }
    [String] GetTitle()
    {
        Return "{0} [~] {1}" -f $This.Name, $This.Date
    }
}

$Ctrl = [VideoReel]::New("Shenendehowa Central Schools","03/17/2023")

$Ctrl.Add("2021_0207-(Buffer Overflow)",
"https://youtu.be/H4MlJnMh9Q0",
@'
[Cable modem] subjected to a [buffer overflow attack].
Notice the [ethernet cable] is NOT plugged in...?

That's because my [internet] just [suddenly stopped].
This happened [dozens] of times between [July 2019] and [May 2020],
prompting me to DISCONNECT the SERVICE that I was expected to PAY for.

Imagine if your car needs service, right...?
You bring the car to the mechanic, and they charge you money to 
fix a problem they claim the vehicle has, right...?

But- as soon as you get the vehicle BACK from the mechanic, 
it still has the same exact issue.

So, you just wasted your money by trusting some lazy douchebag who lied
about fixing your car.

This is the same thing that I experienced at [Northstar Chevrolet], 
and it is a metaphor for my experience with [Spectrum].
'@)

$Ctrl.Add("2017_0817-(Spectrum Cable Modem Reset)",
"https://youtu.be/LfZW-s0BMow",
@'
[Cable modem] subjected to buffer overflow attack (off screen).

I didn't know that is [exactly] what was happening to this
[cable modem] back in [2017] when I managed the [Computer Answers] 
shop at: [1602 Route 9, Clifton Park, NY 12065].

By the way, [the month that this video was recorded], was...
[the month where I set the highest sales record at that shop].
Which- probably remains as being the most profitable month in it's 
history.
'@)

$Ctrl.Add("2021_0207-(HDMI Interference)",
"https://youtu.be/in7IrkoLOHo",
@'
What this is, is the manufacturer of my device, [Asus], playing games
with my equipment. They also manufactuer the [Chromebooks] for
[Shenendehowa Central Schools].
'@)

$Ctrl.Add("2021_0207-(Twitter BSOD)",
"https://youtu.be/12x8TrO9B5Q",
@'
This is what was happening whenever I would log in to [Twitter],
which is called a [Blue Screen of Death], basically a relic of an era
where [Windows], developed by the [Microsoft Corporation], would often
[crash] as a result of whatever was listed in the [error screen].

[Microsoft] was eventually able to [eliminate] the [frequency] of this 
[Blue Screen of Death] occurring to a [nearly nonexistent number] with
the release of [Windows 10].

Each iteration of [Windows] from [7], [8], and [10] allowed for
[Microsoft] to make a bigger, better operating system that could
theoretically withstand [hurricanes], [tornados], [lighting]...

What will they think of next...?

Anyway, if a [Blue Screen of Death] happens in this day and age, it
is usually a [hardware], [driver], or [kernel] error. 

NOW they're used to commit: 
[+] [ESPIONAGE]
[+] [DENIAL OF SERVICE]
[+] [CYBERATTACKS]
'@)

$Ctrl.Add("2018_0517-(Computer Answers Albany, NY)",
"https://youtu.be/TKDHzHiO1k4",
@'
This is a video of [Computer Answers] at:
[818 Central Ave, Albany NY 12206]

In this particular video, the hard drive in the DVR was going bad,
and all of the camera feeds were failing to line up...

However, what can be seen is:
1) the owner of [Team Tech], [Michael DeGioralmo], 
   wearing a [Asurion] shirt
2) the owner of [IFixUrI], [JD Williams], 
   not wearing an [Asurion] shirt
3) [Michael DeGioralmo] lying to a staff member named [Dahl Todd] about
   being from [Asurion]
4) [Michael DeGioralmo] taking the inventory for [Team Tech]
   to acquire without explicitly stating that he was from [Team Tech]
5) [Michael DeGioralmo] and [JD Williams] committing:
   [theft], and [impersonation]

Here's the argument I'm making.
There was an explicitly written contract between [Computer Answers]
and [IFixUrI], and though I was pretty upset with [Pavel Zaichenko]
about how he was spending the income from [IFixUrI]...

...these (2) dudes had to lie to [Dahl Todd] and steal the inventory
from [Computer Answers] without giving anybody a heads up at the
company, what was happening.

That's the thick and thin of this recording.
But also, that I know how to:
1) deploy security cameras,
2) manage the network, 
3) access the interface,
4) compile an exhibit for a lawsuit,
5) repair smarphones and anything else at [Computer Answers]
6) repair any device at the [Apple Store]

Questions...?
Comments...?
securedigitsplus@gmail.com
'@)

$Ctrl.Add("2020_0523-(Virtual Tour)",
"https://youtu.be/HT4p28bRhqc",
@'
In this video, I am [home schooling] my kids on what happens
when people just go around lying willy nilly, as well as why
correctly documenting stuff is really important.

I also cover my trip to [Stratton Air National Guard], though I 
never explained to my children that the "bird" that I recorded
was in [direct response] to the (3) audio recordings that I recorded
on (May 19th, 2020), (May 20th, 2020), and (May 21st, 2020).
'@)

$Ctrl.Add("2019_1021-(Spectrum)",
"https://youtu.be/zs0C_ig-4CQ",
@'
In this video, what can be seen are about (10) trucks from [Spectrum]
fixing the fiber optic lines for [Verizon].

They needed (10) trucks and (20) guys to do what they were doing,
to make it APPEAR as if what they do is: [difficult].

They really only needed like (2) trucks and (4) guys to do the job
they did, AND, the line was conveniently cracked right next to 
[Bruce Tanski]'s offices, [1-2 Cemetery Road, Halfmoon NY 12065].
'@)

$Ctrl.Add("2019_0125-(Computer Answers - MDT)",
"https://youtu.be/5Cyp3pqIMRs",
@'
In this particular video, I was using the Microsoft Deployment Toolkit
to deploy [Windows] to [virtual machines] in a similar manner to how I
also do this in the video [FightingEntropy()][FEInfrastructure].
'@)

$Ctrl.Add("2021_1205-([FightingEntropy(π)][FEInfrastructure])",
"https://youtu.be/6yQr06_rA4I",
@'
[FEInfrastructure] is a part of the [FightingEntropy(π)] module
/modification for [Windows PowerShell], that has been many months
in the making.

The tool allows a [system administrator] to perform 
[advanced system administration] of:
[+] [DHCP]
[+] [DNS]
[+] [Active Directory]
[+] [Hyper-V]
[+] [Windows Deployment Services]
[+] [Deployment and Imaging Service Module]
[+] [Microsoft Deployment Toolkit]
[+] [Internet Information Services]
...though not every aspect is shown in this video.

The tool showcases a [graphical user interface] that ties all
of these components together, to build an [Active Directory]
topology, and then using [ADDS], building a [virtual machine
topology] that can be [managed] and [deployed] using [Hyper-V]... 

...to then be installed using the [Microsoft Deployment Toolkit]
featuring both [vanilla installation method], AND, 
the [FriendsOfMDT method PowerShell Deployment].

However, the [PowerShell Deployment] method by [FriendsofMDT] has
been [extended] to provide [more options] within a [PXE environment],
to [fully install said virtual machines].

The utility ALSO provides the ability to spin up:
[+] [gateways]
[+] [servers]
[+] [other workstations]
[+] [other AD site-to-site ISTG connections]
[+] [subnets]
[+] [networks], etc. 

However, the [implementation] of [those] will be [featured]...
...in a [future video].
'@)

$Ctrl.Add("2023_0112-(PowerShell | Virtualization Lab + FEDCPromo)",
"https://youtu.be/9v7uJHF-cGQ",
@'
This is installing an instance of [Windows Server 2016] on a machine
that has [Hyper-V], over a [Remote Desktop Connection], by using
[PowerShell Direct], and the custom (script/function) that I wrote to
deploy the operating system from an ISO file.

This is pretty complicated stuff and it exhibits that I am performing
[senior level system administration] as well as [senior level 
application development].

Updated version of this video found here:
https://www.youtube.com/watch?v=nqTOmNIilxw
'@)
