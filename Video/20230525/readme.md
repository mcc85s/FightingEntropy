# Get-ViperBomb Development (Part 3) [05/25/2023]

| Description |
|:------------|
| In this video, I continue to develop an application called [**Get-ViperBomb**], which is formally called the [**System Control Extension Utility**] for the time being. This utility will be able to perform various system management tasks in a similar fashion to group policy objects, and other security related stuff. |

[[Video](#video)] - [[Script](#script)] - [[Picture](#picture)] - [[Link](#link)]

<p align="center" width="100%">
    <img width="66%" src="https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/thumbnail.jpg">
</p>

## Video

| Index | Date         | Name/Link                                                                          | Duration      |
|:------|:-------------|:-----------------------------------------------------------------------------------|:--------------|
| 0     | `05/25/2023` | **[2023_0525-(Get-ViperBomb Development (Part 3))](https://youtu.be/qvvomJPfquI)** | `04h 55m 52s` |

## Script

| Index | Date         | Name/Link                                                                                                                             |
|:------|:-------------|:--------------------------------------------------------------------------------------------------------------------------------------|
| 0     | `05/25/2023` | **[2023_0525-(Get-ViperBomb).ps1](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/2023_0525-(Get-ViperBomb).ps1)** |

## Picture

| Index | Image                                                                                     |
|:------|:------------------------------------------------------------------------------------------|
| 0     | ![01.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/01.jpg) |
| 1     | ![02.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/02.jpg) |
| 2     | ![03.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/03.jpg) |
| 3     | ![04.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/04.jpg) |
| 4     | ![05.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/05.jpg) |
| 5     | ![06.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/06.jpg) |
| 6     | ![07.jpg](https://github.com/mcc85s/FightingEntropy/blob/main/Video/20230525/Pics/07.jpg) |

## Link

| Index | Date         | Name/Link                                                                          |
|:------|:-------------|:-----------------------------------------------------------------------------------|
| 0     | `05/09/2023` | **[2023_0509-([FightingEntropy()][Development])](https://youtu.be/VUkZ1YLzyn8)**   |
| 1     | `05/09/2023` | **[2023_0511-(Get-ViperBomb Development (Part 1))](https://youtu.be/iCk-7IRfVqc)** |
| 2     | `05/09/2023` | **[2023_0515-(Get-ViperBomb Development (Part 2))](https://youtu.be/qcbTe2wGdUY)** |

## Annotation
```
    [Mission]: Continue to develop [Get-ViperBomb] over RDP to the other system using passthru LAN cable.

    Having (2) systems directly connected to one another eliminates potential [bad guy] attack vectors.

    Don't allow [bad guys] to hang out with you, or whatever.
    They're dumb.
    You're not.

    Sometimes [bad guys] claim to be [good guys], who expect to be taken seriously (cause they're lame morons).
    Sometimes [good guys] claim to be [bad guys], but they're kidding around (cause they're cool geniuses).

    Knowing [good guys] from [bad guys] is a life-long process that results in situations like:

    09/11/2001 - [Terrorist Attack of September 11th, 2001],
                 [(3) buildings in Manhattan subjected to (controlled demolition)],
                 [hypersonic missile struck the Pentagon],
                 [911 calls from plane passengers came from the (ground)],
                 [multiple F-16's sitting on the runway for nearly an hour before WTC was struck]
                 
                 Same day...?
                 Different events. 
                 The terrorist attack was expected ahead of time. 
                 That's why (3) buildings were subjected to controlled demolition on 9/11/2001 by treasonists in the USA.
                 [Good guys] will agree with me, [bad guys] will immediately label this story as [delusional].

                 Kickstarted the process of fighting a war with the [middle east], as well as [terrorists].

    10/25/2001 - [Microsoft CEO William Gates] released [Windows XP] 
                 A day that will live on in (XP/expanded productivity).
                 [Windows XP] relied on the [Windows 2000] architecture which provided many improvements over the 
                 Win9X architecture which was based on (DOS/disk operating system).

                 This kickstarted the (CEIP/Customer Experience Improvement Program) which allows the developers to collect
                 various forensic data related to the [functionality] and [security] of the features within the operating system. 
                 
                 It also allows them to reproduce content on any given device that the operating system is installed to 
                 (VSS/Volume Shadow Copying), which means they technically own the data on every operating system that uses
                 the NT 6.0+ kernel and whatnot.
                 
                 Many of these tools are circumvented by [cyberterrorists], [foreign intelligence agents], and 
                 [nation state actors] to this day... though [Microsoft] doesn't play games when it comes to [security].

    10/26/2001 - [Uniting + Strengthening America - Providing Appropriate Tools Required to Intercept + Obstruct Terrorism]
                 [U.S.A. P.A.T.R.I.O.T. (acronym) Act of 2001]:  Allows [federal investigators] to follow highly sophisticated
                 terrorists trained to evade detection, without ever having to tip them off as to whether or not they are in
                 the process of investigating them.
                 
                 Which means a lot of things, including but not limited to:
                 - (warrantless/lawless) monitoring and surveillance of all internal US communication data (OAKSTAR + Stormbrew)
                 - copying and replicating data to reproduce objects in real-time (xKeyScore)
                 
                 Kickstarted the age of [mass surveillance], [surveillance capitalism], and [technological tyranny].

                 Stupid people ignore what this law does and allows.
                 The law has been updated numerous times, particularly with the [PRISM] program.
                 Reading between the lines of this document suggests that people who lack integrity and lie a lot,
                 they may become very powerful, and [absolute power corrupts absolutely].

    05/01/2003 - [Mission Accomplished]: When [Donald Rumsfeld] wrote a stupid speech for [George W. Bush] to state on
                 a Nimitz-class battleship to congratulate the "completion" of a mission that wasn't even supposed to be
                 a priority... the capture of [Saddam Hussein].

                 [George W. Bush] accused [Saddam Hussein] of harboring weapons of mass destruction after the espionage
                 powers in [Europe] particularly [Italy] + [Britain], of [Iraq] purchasing [uranium yellowcake] from [Niger]
                 to build weapons of mass destruction.

                 [That was all bullshit], it was strictly meant to get the [US] to invade the [middle east] to acquire the
                 [Kuwait] oil fields that they attempted to acquire during [Desert Storm] under [George H. W. Bush].

    05/01/2011 - [Assassination of Osama Bin Laden]: [CIA Director Leon Panetta] + [President Barack Obama] led a strike
                 force into a compound that was suspected of being [Osama Bin Laden]'s residence. They were able to obtain
                 this information by using stealthy phone technology related programs that obtain telemetry locations of
                 target devices by using their MAC address and radio frequencies. The same technology is used by 
                 [cyberterrorists], [foreign intelligence agents], and [nation state actors] to this day.

    There are various other highly relevant events in history related to [mass surveillance], [surveillance capitalism],
    and [technological tyranny], like this:
    
    [April 24, 2023 : Fox News fires Tucker Carlson amid $787M defamation lawsuit victory]
    What happened...? Uh, an organization that calls itself a "news organization" had the highest ratings in the industry
    which were attributed to this guy [Tucker Carlson] boasting [Donald Trump] and his fight to overthrow the election results,
    whereby prompting rioters to storm the US capital on [January 6th, 2021].

    https://www.npr.org/2023/04/24/1171641969/fox-news-fires-tucker-carlson-in-stunning-move-a-week-after-787-million-settleme

    The moral of the story is this.

    Sometimes [bad guys] claim to be [good guys], like [George W. Bush] and [Michael Hayden].
    Sometimes [good guys] have to do [bad things] in order to get the [bad guys]... like [Barack Obama] and [Leon Panetta].
    Sometimes [good guys] tell the world about the [bad things] that [bad guys] do... like [Julien Assange], and [Edward Snowden].
    ...and for whatever reason everybody has to just go along with whatever the hell the press, media, and government "say".

    "I did  not have sexual relations with that woman." -Bill Clinton
    "Fool me once...? Shame on you. Fool me twice...? Ya just can't get fooled again." -George W. Bush
    "Have a healthy dose of skepticism." -Barack Obama
    "If you just spray some Lysol all over the place, it'll get rid of the COVID. No problem." -Donald Trump
    "Those who do not remember the past are condemned to repeat it." -George Santanaya
```
