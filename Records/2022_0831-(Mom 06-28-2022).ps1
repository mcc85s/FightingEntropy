
# _________________________
# | Updated Transcription |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# I decided to take a deeper look at the recording I uploaded on 06-28-2022 13:02.
# I was able to locate (2) additional sections of dialogue that I didn't realize was there, which
# clearly discuss SAMMY SANTA CASSARO and my father, MICHAEL EDWARD COOK's murders.
# 
# I've transcribed everything from the moment I woke up on 06-28-2022 @11:05~, until I ended the 
# recording and uploaded it. I wasn't COMPLETELY ACCURATE with SOME of the details I reported.
# However, uh- I CAN STAND TO BE CORRECTED. 
# Even still, I wasn't completely inaccurate with most of what I stated, my mother withheld some
# incredibly particular details and what can be seen, is an incredibly malicious OMISSION from
# her statement with Trooper DeRusso. Well, MULTIPLE MALICIOUS OMISSIONS.
#
# I accused my mother of being involved with the conspiracy to commit murder to my father, and 
# the most disturbing part of the recording and the statement she made to TROOPER DERUSSO, is that
# she makes NO MENTION of my MANY ACCUSATIONS, which was the REASON for the STRUGGLE.
#
# It doesn't really change the fact that the police arrested me before they had the story straight.
# They still fuckin' did that, alright. But- as I was transcribing the audio file, I came to realize
# some things about my mother that I don't think will ever be repaired.
# _______________________________________________________________________________________________________
# | 06/28/2022 | Audio Log 16h7m54s | https://drive.google.com/file/d/1MkHiYnBnRl91Ck-ixcEhE5R1dX7B3Fve |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Now, here's a link to the last 2h 01m 32s of that file, with some specifically placed TREBLE, and VOLUME
# ENHANCEMENTS so that my mother and I can be heard throughout the entire house.
# _______________________________________________________________________________________________________
# | 06/28/2022 | Last 2h 01m 32s    | https://drive.google.com/file/d/1Z56uu5O52eAzJhUdiby_J8dQQXaOUENa |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Before I begin, I'd like the transcription output to look like this...
#
# Index Party Date      Time     Position Type   Note
# ----- ----- ----      ----     -------- ----   ----
#     0 MCCS  6/28/2022 11:05:44 00:05:12 Action Woke up
#
# Here are the classes I created to categorize and organize the TRANSCRIPTIONS.

Class TranscriptionParty
{
    [UInt32] $Index
    [String] $Name
    [String] $Initial
    TranscriptionParty([UInt32]$Index,[String]$Name)
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

Class TranscriptionTime
{
    [Object]     $Date
    [Object]     $Time
    [Object] $Position
    TranscriptionTime([Object]$Start,[String]$Position)
    {
        $This.Position = [TimeSpan]$Position
        $Real          = ($Start+$This.Position).ToString() -Split " "
        $This.Date     = $Real[0]
        $This.Time     = $Real[1]
    }
    [String] ToString()
    {
        Return $This.Time
    }
}

Class TranscriptionEntry
{
    [UInt32] $Index
    [Object] $Party
    [Object] $Date
    [Object] $Time
    [Object] $Position
    [String] $Type
    [String] $Note
    TranscriptionEntry([UInt32]$Index,[Object]$Person,[Object]$Time,[String]$Note)
    {
        $This.Index    = $Index
        $This.Party    = $Person
        $This.Date     = $Time.Date
        $This.Time     = $Time.Time
        $This.Position = $Time.Position
        $This.Type     = Switch -Regex ($Note)
        {
            "^\*{1}" { "Action"    }
            "^\:{1}" { "Statement" }
        }
        $This.Note     = $Note.Substring(1)
    }
    [String] ToString()
    {
        Return "[{0}] <{1}> {2}" -f $This.Time,$This.Party.Initial, $This.Note
    }
}

Class Transcription
{
    [String]    $Name
    [DateTime] $Start
    [DateTime]   $End
    [Object]   $Party
    [Object]  $Output
    Transcription([String]$Name,[String]$End,[String]$Length)
    {
        $This.Name   = $Name
        $This.End    = [DateTime]$End
        $This.Start  = $This.End-[TimeSpan]$Length
        $This.Party  = @( )
        $This.Output = @( )
    }
    AddParty([String]$Name)
    {
        If ($Name -in $This.Party.Name)
        {
            Throw "Party [!] [$Name] already specified"
        }

        $This.Party += [TranscriptionParty]::New($This.Party.Count,$Name)
        Write-Host "Party [+] [$Name] added."
    }
    AddEntry([UInt32]$Index,[String]$Position,[String]$Note)
    {   
        If ($Index -gt $This.Party.Count)
        {
            Throw "Party [!] [$Index] is out of bounds"
        }
        If ($Position -match "^\d{2}\:\d{2}$")
        {
            $Position = "00:$Position"
        }
        $Person       = $This.Party[$Index]
        $Time         = [TranscriptionTime]::New($This.Start,$Position)
        $This.Output += [TranscriptionEntry]::New($This.Output.Count,$Person,$Time,$Note)
        Write-Host "Entry [+] [$Position] added"
    }
    Ae([UInt32]$Index,[String]$Position,[String]$Note)
    {
        $This.AddEntry($Index,$Position,$Note)
    }
    [Object] Tx([String]$Position)
    {
        Return [TranscriptionTime]::New($This.Start,$Position)
    }
}

$Hash     = @{ 

    End   = "6/28/2022 01:02:04 PM"
    Start = "6/28/2022 11:00:32 AM"
    # Portions Bass Reduce, Treble boost, Volume boost 
}

$T = [Transcription]::New("Mom Altercation",$Hash.End,"2:01:32")
$T.AddParty("Michael C. Cook Sr.")
$T.AddParty("Fabienne S. K. Cook")
$T.AddParty("E N V")

# [Section 1]
$T.Ae(0,"05:12","*Woke up")
$T.Ae(0,"21:20",":Can you open the door for a sec?")
$T.Ae(0,"21:24",":Can you open the door for a second...?")
$T.Ae(1,"21:29","*Opens door")
$T.Ae(0,"21:33",":Two things I'm gonna say to you right now.")
$T.Ae(0,"21:36",":The reason why the (3) guys never named the trigger man...?")
$T.Ae(0,"21:39",":Because they were keepin their mouths shut because a larger crime was involved.")
$T.Ae(0,"21:45",":The larger crime involved means that the (3) of them get to go")
$T.Ae(2,"21:47","*(2) taps heard on my computer") 
$T.Ae(0,"21:47",":to a NEW trial,")
$T.Ae(2,"21:48","*(2) taps heard on my computer")
$T.Ae(0,"21:49",":where they face the SAME fuckin' charges they already faced")
$T.Ae(2,"21:52","*(2) taps heard on my computer") 
$T.Ae(0,"21:53",":and the time served doesn't matter... in addition to OTHER people.")
$T.Ae(0,"21:56",":Cause guess what...?")
$T.Ae(0,"21:58",":That means it's a more HEINOUS CRIME, than it SOUNDS like.")
$T.Ae(0,"22:02",":And the clues are right in front of everybody's face.")
$T.Ae(0,"22:06",":My father said this, BEFORE he was killed...")
$T.Ae(0,"22:07",":'If those niggers come after me-'")
$T.Ae(0,"22:10",":'I'm gonna put my foot to the floor and take those niggers with me to hell.'")
$T.Ae(0,"22:13",":That means, it was PREMEDITATED.")
$T.Ae(1,"22:16",":He didn't say 'niggers' he said ANYBODY tried to rob him.")
$T.Ae(0,"22:18",":He said 'niggers'...*overlap* I heard him, mom.")
$T.Ae(0,"22:22",":That- that's another thing, you've done this to me my WHOLE life,")
$T.Ae(0,"22:24",":like, when I remember certain things like that, you say-")
$T.Ae(0,"22:26",":'Nah, that's wrong'.")
$T.Ae(0,"22:30",":You DO that. I remember what my dad, said.")
$T.Ae(1,"22:33",":And then he said that around YOU...?")
$T.Ae(0,"22:35",":He probably did, and I- I'm just sayin, I remember him SAYING that.")
$T.Ae(0,"22:39",":But- y'know, I'm sure my son and my daughter bein'")
$T.Ae(1,"22:43",":He was stickin' up for... black fuckin' people, there.")
$T.Ae(0,"22:46",":I KNOW he was, but they were also LOOKIN' for him because,")
$T.Ae(0,"22:49",":somebody was listening to my dad, and the dispatcher on the radio.")
$T.Ae(0,"22:54",":Wanna know how I know that...?")
$T.Ae(0,"22:57",":Because the SAME dispatcher was involved in SAMMY's death, and my FATHER's death.")
$T.Ae(1,"23:01",":Cause they BOTH worked for the same company.")
$T.Ae(0,"23:04",":Right, but- that's a CLUE. *pause* *interrupted*")
$T.Ae(1,"23:07",":It wasn't just THEM, there was a couple OTHER cab drivers TOO that got killed.")
$T.Ae(0,"23:11",":You have to understand the possibility, that there are MULTIPLE REASONS and EXPLANATIONS for things.")
$T.Ae(0,"23:17",":So, the SAME DISPATCHER, and the SAME CAB COMPANY being involved")
$T.Ae(2,"23:23","*(2) taps heard on my computer, followed by a toast notification")
$T.Ae(0,"23:23",":doesn't NECESSARILY MEAN that there's a LARGER CRIME involved...?")
$T.Ae(0,"23:24",":But what it DOES mean, is that...")
$T.Ae(0,"23:27",":There's a possibility that the (2) crimes were related for a HIGHER reason that YOU'RE NOT CONSIDERING.")
$T.Ae(0,"23:34",":That's what I'm trying to tell you. Because if it was a DIFFERENT cab company-")
$T.Ae(1,"23:37",":I get it.")
$T.Ae(0,"23:38",":...it was a DIFFERENT... OK, you don't- you GET it,")
$T.Ae(0,"23:43",":but you're crossing your arms and like, getting DEFENSIVE about it.")
$T.Ae(0,"23:45",":I'm trying to TELL you that I have actually DONE this, like a fuckin' investigator from the police.")
$T.Ae(1,"23:50",":Yeah, but you're not gettin' PAID for it.")
$T.Ae(0,"23:51",":Doesn't MATTER- That means- That DOESN'T mean")
$T.Ae(1,"23:53",":Put your energy towards something that's gonna RESULT in something") 
$T.Ae(0,"23:55",":No, I AM putting my energy toward something that's gonna result in something.")
$T.Ae(0,"23:59",":You're UNDERMINING me. You think, you don't realize, I have the GUY-")
$T.Ae(1,"24:04",":I've had enough, Mike.")
$T.Ae(0,"24:05",":The guy who RUNS Saratoga County Sheriffs Office, TRIED, TO HAVE, ME, MURDERED, ON MAY 26th, 2020")
$T.Ae(1,"24:12",":Then get a god damn lawyer that believes you.")
$T.Ae(0,"24:17",":I have to like, CONVINCE people, like- my MOTHER.")
$T.Ae(0,"24:19","*pause")
$T.Ae(0,"24:22",":Because I can't BUY a lawyer. Wanna know why I can't BUY a lawyer...?")
$T.Ae(0,"24:26",":Because I'm on a NATIONAL SECURITY WATCHLIST, so I can't get a fuckin' job.")
$T.Ae(0,"24:29",":Cause (1) asshole worked with the fuckin' police officer who RUNS Saratoga County,")
$T.Ae(0,"24:34",":and THEY, they didn't answer my 911 calls.")
$T.Ae(0,"24:38",":You don't get it, there is, (7) FELONIES OCCURRED TO ME, that night.")
$T.Ae(0,"24:41",":And then I got arrested for cutting a kayak strap.")
$T.Ae(0,"24:45",":Not for calling 911 because (2) kids were trying to KILL me, and...")
$T.Ae(0,"24:48",":you SEEM to think I'm makin' that up.")
$T.Ae(1,"24:51",":NO. YOU'RE NOT. AND I'M SICK AND TIRED OF HEARIN' IT~!")
$T.Ae(0,"24:55",":Well, hold on. Hold on. Hold on.")
$T.Ae(1,"24:56",":I'm not goin' THROUGH this crap.")
$T.Ae(1,"24:57","*Shuts the door")
$T.Ae(0,"24:59",":Fuckin'... god damnit.")
# [Section 2]
$T.Ae(0,"59:26","*Knock on door")
$T.Ae(0,"59:29",":Can you open the door...?")
$T.Ae(1,"59:30","*Silent")
$T.Ae(0,"59:39",":Hey...!")
$T.Ae(1,"59:40",":What...?")
$T.Ae(0,"59:40",":Can you open the door...?")
$T.Ae(1,"59:41",":Why...?")
$T.Ae(0,"59:42",":Cause I need to tell you somethin very serious.")
$T.Ae(1,"59:45","*Silent*")
$T.Ae(0,"59:52",":You suggested that I just leave the state, right...?")
$T.Ae(0,"1:00:00",":You know why that would be a stupid idea...?")
$T.Ae(1,"1:00:02","*Silent*")
$T.Ae(0,"1:00:05",":Cause then people I won't know who are after me will wind up getting me.")
$T.Ae(1,"1:00:10",":Whatever.")
# [Section 3]
$T.Ae(0,"1:53:46",":Hey")
$T.Ae(0,"1:53:46","*Knocks on door")
$T.Ae(1,"1:53:48",":What...?")
$T.Ae(0,"1:53:48",":Come here.")
$T.Ae(0,"1:53:50",":I gotta show you something, right now.")
$T.Ae(0,"1:53:53",":Come here, it's VERY important. It's SO important, I need ya to see it.")
$T.Ae(0,"1:53:59",":C'mon ma, please.")
$T.Ae(0,"1:54:03",":Mom can you PLEASE stand up and look at this fuckin' thing right now...?")
$T.Ae(1,"1:54:06",":God damnit.")
$T.Ae(1,"1:54:15","*Opens door")
$T.Ae(0,"1:54:17",":I'm about to show ya")
$T.Ae(1,"1:54:20",":I'm cool.")
$T.Ae(0,"1:54:20",":C'mere")
$T.Ae(0,"1:54:21","*Walks from Mom's room to Son's room")
$T.Ae(1,"1:54:21","*Walks from Mom's room to Son's room also")
$T.Ae(0,"1:54:21",":I'm about to show you that the Saratoga County, fuckin' cobbled together illegal charges.")
$T.Ae(0,"1:54:32",":You see this line, right here...? Look at it very closely.")
$T.Ae(0,"1:54:36",":You gotta look at it closely. You can't be lookin at something closely from 5 feet away.")
$T.Ae(0,"1:54:41",":As in, move your head, closer...? You see that line...?")
$T.Ae(1,"1:54:44",":Are you fuckin' kidding...? God damn you...")
$T.Ae(0,"1:54:45",":Look at this line right here, I'm trying to get you to fuckin' look at it.")
$T.Ae(1,"1:54:47",":I AM~!")
$T.Ae(0,"1:54:48",":You see how THAT line has an EXTRA LINE OF PIXELS there...?")
$T.Ae(0,"1:54:52",":You see THAT...?")
$T.Ae(1,"1:54:54",":No.")
$T.Ae(0,"1:54:54",":You don't see how THAT is SLIGHTLY DIFFERENT than EVERY OTHER LINE...?")
$T.Ae(1,"1:54:59",":No.")
$T.Ae(0,"1:55:01",":Are you retarded...?")
$T.Ae(1,"1:55:02",":Nope.")
$T.Ae(0,"1:55:04",":THAT, right there, you see...? Look at the very BOTTOM of the letter S")
$T.Ae(1,"1:55:08",":Yeah...?")
$T.Ae(0,"1:55:08",":Okay...? Look at the very BOTTOM of the letter S THERE.")
$T.Ae(0,"1:55:12",":See how it's DIFFERENT...?")
$T.Ae(1,"1:55:14",":Yeah...?")
$T.Ae(0,"1:55:15",":That's because somebody's trying to COMMUNICATE with me")
$T.Ae(0,"1:55:18",":THIS TICKET right here (SCSO-2020-003173 1212), is the, it says 'Suspect of an earlier complaint made by Zachary Karel'")
$T.Ae(0,"1:55:25",":The EARLIER complaint they made (SCSO-2020-003177 1414), was at 1414.")
$T.Ae(0,"1:55:31",":So, they're literally writing in a fuckin' document that they arrested me for, that an EARLIER complaint was made...")
$T.Ae(0,"1:55:38",":AFTER, 1212. I HAVE the other fuckin' ticket.")
$T.Ae(0,"1:55:42",":The other ticket, is right here.")
$T.Ae(0,"1:55:45",":1414 Oh yeah, no, this is an earlier <complaint>")
$T.Ae(0,"1:55:48",":That's what fuckin' Saratoga County Sheriffs Office did to me")
$T.Ae(0,"1:55:51",":An EARLIER complaint was made at 1414, THAT'S NOT EARLIER THATS LATER.")
$T.Ae(1,"1:55:58",":Why are you fuckin' yellin' at me...?")
$T.Ae(0,"1:55:59",":Because I spent the last (2) years telling you this, and you keep thinkin' I'm INSANE~!")
$T.Ae(1,"1:56:05",":You better, you better... get the fuck outta my house.")
$T.Ae(1,"1:56:09",":Get away, get the hell away from me, Mike.")
$T.Ae(0,"1:56:12",":You're treating me like I'm insane. I'll stop yelling-")
$T.Ae(1,"1:56:15",":You're ACTING like you're insane.") # Gee, I wonder WHY. Huh.
$T.Ae(0,"1:56:17",":I'm acting that way because I spent the last (2) years trying to-")
$T.Ae(1,"1:56:19",":Alright~! Whatever~!")
$T.Ae(0,"1:56:21",":It's so important.")
$T.Ae(1,"1:56:22",":Get the fuck outta my face.")
$T.Ae(0,"1:56:23",":What can you DO about it...?")
$T.Ae(0,"1:56:25",":YOU don't understand-")
$T.Ae(1,"1:56:26",":YOU need to get the fuck outta my face~!")
$T.Ae(0,"1:56:29",":I'm not IN your face. I'm asking you for help. You're NOT helping.")
$T.Ae(1,"1:56:33",":I AM~!")
$T.Ae(0,"1:56:34",":No you're not.")
$T.Ae(1,"1:56:35",":Get the fuck outta here.")
$T.Ae(0,"1:56:37",":You might as well just grab a knife and stab me in the back.")
$T.Ae(1,"1:56:38",":Get the fuck")
$T.Ae(0,"1:56:39",":That's YOUR idea of")
$T.Ae(1,"1:56:40","*Mother closing her bedroom door while son is standing in doorway")
$T.Ae(0,"1:56:40",":Don't shut this fuckin' door on me,")
$T.Ae(1,"1:56:42",":Get the fuck AWAY from me.")
$T.Ae(0,"1:56:42",":No. *pause* Look, listen to me.")
$T.Ae(0,"1:56:46",":You treat me like I'm 10 years old (when dad was killed and she started acting this way)")
$T.Ae(1,"1:56:47",":No~! I'm not!")
$T.Ae(0,"1:56:49",":Yeah you are.")
$T.Ae(1,"1:56:49",":I'm treatin' you like a 37 idiot.")
$T.Ae(1,"1:56:56",":Get the fuck away from me.")
$T.Ae(0,"1:56:58",":You- You're helping the police, commit a crime.")
$T.Ae(1,"1:57:02",":I'M NOT HELPING NOTHING~!")
$T.Ae(0,"1:57:04",":You are~! You're being INDIFFERENT, you're not doing anything to HELP me, you're not GOING to-")
$T.Ae(1,"1:57:07",":GET. THE. FUCK. OUT. OF. MY. FAAAAACE~!")
$T.Ae(0,"1:57:11","*standing there speechless, thinking of a new strategy to pivot to")
$T.Ae(0,"1:57:17",":You LIKE the fact that my father's gone, don't you...?")
$T.Ae(1,"1:57:18",":Yes I do, Mike. I am SO fuckin' happy, ain't I...?")
$T.Ae(0,"1:57:24",":You are~!")
$T.Ae(1,"1:57:25",":Stupid bitch~!")
$T.Ae(0,"1:57:26",":You would LOVE it if I got shot to death just like my father.")
$T.Ae(1,"1:57:30",":YES, I WOULD.")
$T.Ae(0,"1:57:32",":Good.")
$T.Ae(0,"1:57:35",":That's why it's totally fine for me to fuckin' embarrass you in front of your friends.")
$T.Ae(0,"1:57:40",":They'll stick up for you.")
$T.Ae(1,"1:57:42",":You didn't EMBARRASS me.")
$T.Ae(0,"1:57:43",":You SHOULDN'T walk away from me...")
$T.Ae(0,"1:57:48",":I'm gonna record ALL this shit, about how you like fuckin' walk away, BECAUSE...")
$T.Ae(0,"1:57:53",":Now I think that you're involved in this fuckin' conspiracy to commit murder against my father")
$T.Ae(1,"1:57:59","*Tries to slam the kitchen door in my face")
$T.Ae(0,"1:58:01",":No, I think you conspired to murder my father, now.")
$T.Ae(1,"1:58:02","*Keeps walking away from me, indicates MALICIOUS INTENT")
$T.Ae(0,"1:58:03",":YOU KEEP WALKING AWAY FROM ME, AND IT INDICATES THAT YOU'RE GUILTY FOR SOMETHIN'~!")
$T.Ae(0,"1:58:07",":THAT'S WHY, YOU'RE NOT GOIN' ANYWHERE")
$T.Ae(1,"1:58:10",":Now you're-")
$T.Ae(0,"1:58:10",":I'M GONNA HAVE YOU FUCKIN' ARRESTED. YOU HAD MY FUCKIN' FATHER MURDERED, DIDN'T YOU YOU FUCKIN' DUMBASS CUNT.")
$T.Ae(2,"1:58:15","*Son grabbed mother's wrists and placed mother against the wall*")
$T.Ae(1,"1:58:15","*Mother makes a fake choking noise*")
# I never had my arms around my mothers neck or had her in a headlock, 
# but she makes a noise right here that sounds like she's choking.
# She's not actually choking.
# I'm gonna state this again, I never had my arms or hands around my mothers neck.
# I had both of my hands around her wrists and had her up against the wall 
# adjacent to the kitchen door.
# I'll expand upon this shortly.
$T.Ae(0,"01:58:16",":Didn't you...? YOU HAD MY FATHER MURDERED DIDN'T YOU...?")
$T.Ae(0,"01:58:21",":Yeah you fuckin' did")
$T.Ae(0,"01:58:22",":Admit it, right now, and I will have you fuckin' arrested.")
$T.Ae(0,"01:58:27",":Stop fuckin' walkin' away from me.")
$T.Ae(0,"01:58:31",":No, I'll have you arrested.")
$T.Ae(1,"01:58:32",":I'm gonna have YOU arrested.")
$T.Ae(0,"01:58:33",":No you're not.")
$T.Ae(0,"01:58:36",":Now, I have- I suspect that you had")
$T.Ae(1,"01:58:40",":Alright, this is the last time you touch me.")
$T.Ae(0,"01:58:42",":No.")
$T.Ae(1,"01:58:45",":This is the LAST TIME... you FUCKIN' TOUCH ME...")
$T.AE(0,"01:58:45",":I'll have you arrested.")
$T.AE(0,"01:58:47",":I will have you arrested.")
$T.AE(0,"01:58:49",":I will have you, fucking, arrested.")
$T.AE(0,"01:58:51",":Don't you fuckin' understand what the hell I'm saying...?")
$T.AE(0,"01:58:54",":YOU'RE NOT HEARIN' A FUCKIN' WORD I'M SAYING YOU STUPID CUNT~!")
$T.AE(0,"01:58:59",":YOU HAD MY FATHER MURDERED, DIDN'T YOU...?")
$T.AE(1,"01:59:01",":NO~! OH, NOW IT'S-")
$T.AE(0,"01:59:03",":Then stop fuckin' walkin' away from me")
$T.AE(1,"01:59:05",":GET THE FUCK OFF OF ME.")
$T.AE(0,"01:59:07",":STOP FUCKIN' WALKIN' AWAY FROM ME")
$T.AE(1,"01:59:08",":GET THE FUCK OFF OF ME.")
$T.AE(0,"01:59:09",":STOP FUCKIN' WALKIN' AWAY FROM ME")
$T.AE(1,"01:59:10",":GET OFF OF ME~!")
$T.AE(1,"01:59:13",":HELP~!")
$T.AE(1,"01:59:15",":HELP~!")
$T.AE(0,"01:59:15",":Nobody gives a shit about you. You let my father die, DIDN'T YOU...?")
$T.AE(1,"01:59:19",":<I'm gonna KILL you.>")
$T.AE(1,"01:59:21",":God damnit~! Alright, that's it... That's it...")
$T.AE(1,"01:59:25",":That's it... this is the LAST TIME,")
$T.AE(0,"01:59:28",":No, you're gonna")
$T.AE(1,"01:59:29",":This is the LAST TIME")
$T.AE(0,"01:59:30",":You're gonna go to prison.")
$T.AE(1,"01:59:33",":Go ahead, call the cops. Go ahead. Go ahead.")
$T.AE(1,"01:59:40",":Alright, I'm chill.")
$T.AE(0,"01:59:45",":You had my father murdered")
$T.AE(1,"01:59:45",":No you ass~!")
$T.AE(0,"01:59:47",":Then why do you keep walking away from me...?")
$T.AE(1,"01:59:48",":It has nothin' to do with-")
$T.AE(0,"01:59:50",":STOP WALKIN' AWAY, and stop fuckin' fightin'.")
$T.AE(1,"01:59:52",":Every single fuckin' time that you fucking SQUIRM...?")
$T.AE(1,"01:59:59",":You're hurtin' my leg~!")
$T.AE(0,"01:59:59",":Well, guess what...?")
$T.AE(0,"02:00:00",":No.")
$T.AE(1,"02:00:03",":LEAVE ME ALONE~!")
$T.AE(0,"02:00:09",":No.")
$T.AE(1,"02:00:12",":God damnit~!")
$T.AE(0,"02:00:14",":I'm not even hurting you, I'm RESTRAINING you, I'm not HURTING you.")
$T.AE(1,"02:00:17",":No, you ARE hurtin' me.")
$T.AE(0,"02:00:22",":I'm not hurting you. You're lying. I'm restraining you.")
$T.AE(1,"02:00:30",":LET GO OF ME~!")
$T.AE(0,"02:00:31",":You need to UNDERSTAND something, you are GUILTY of conspiring to murder my father.")
$T.AE(1,"02:00:37",":No I'm NOT.")
$T.AE(0,"02:00:39",":You're gonna go to prison.")
$T.AE(1,"02:00:40",":You're hurting me~!")
$T.AE(1,"02:00:41",":God damnit~!")
$T.AE(1,"02:00:44",":God damnit Michael~!")
$T.AE(1,"02:00:47",":Let GO of me, motherfucker.")
$T.AE(1,"02:00:49",":LET GO OF ME~!")
$T.AE(1,"02:00:53",":LET GO OF ME~!")
$T.AE(0,"02:00:56",":Stop walkin' out the fuckin' door.")
$T.AE(1,"02:00:57",":LET GO OF ME~!")
$T.AE(0,"02:00:58",":You're guilty of conspiring to murder my father. (unsure)")
$T.AE(1,"02:01:00",":No I'm NOT, you ass~!")
$T.AE(0,"02:01:07",":You deserve a lot more than that.")
$T.AE(1,"02:01:11","*Slams front door")
$T.AE(0,"02:01:20",":Fuck")
$T.AE(0,"02:01:32","*Ends recording")

<#
$T.Output | FT

I'm going to break this down into (3) sections, and provide commentary in particular locations.

The first section happened at some point between 11:00 and 11:30.
The second section was rather short and concise, and happened around noon.
The third section is the main attraction. This one is pretty gruesome for both sides, but I'm being transparent here.

Index Party Date      Time     Position Type      Note
----- ----- ----      ----     -------- ----      ----
    0 MCCS  6/28/2022 11:05:44 00:05:12 Action    Woke up

    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Section 1                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯   

    1 MCCS  6/28/2022 11:21:52 00:21:20 Statement Can you open the door for a sec?
    2 MCCS  6/28/2022 11:21:56 00:21:24 Statement Can you open the door for a second...?
    3 FSKC  6/28/2022 11:22:01 00:21:29 Action    Opens door
    4 MCCS  6/28/2022 11:22:05 00:21:33 Statement Two things I'm gonna say to you right now.
    5 MCCS  6/28/2022 11:22:08 00:21:36 Statement The reason why the (3) guys never named the trigger man...?
    6 MCCS  6/28/2022 11:22:11 00:21:39 Statement Because they were keepin their mouths shut because a larger crime was involved.
    7 MCCS  6/28/2022 11:22:17 00:21:45 Statement The larger crime involved means that the (3) of them get to go
    8 ENV   6/28/2022 11:22:19 00:21:47 Action    (2) taps heard on my computer
    9 MCCS  6/28/2022 11:22:19 00:21:47 Statement to a NEW trial,
   10 ENV   6/28/2022 11:22:20 00:21:48 Action    (2) taps heard on my computer
   11 MCCS  6/28/2022 11:22:21 00:21:49 Statement where they face the SAME fuckin' charges they already faced
   12 ENV   6/28/2022 11:22:24 00:21:52 Action    (2) taps heard on my computer
   _______________________________________________________________________________________
   | I believe that the TIMING of these (TAPS/notification sounds), were by CONTEXT.     |
   | As in, they did not arrive at the time they did, as merely COINCIDENCE.             |
   | My computer and the device recording this audio, was in MY ROOM, next to my laptop. |
   | My mother and I are in the OTHER room, nowhere near either device.                  |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   13 MCCS  6/28/2022 11:22:25 00:21:53 Statement and the time served doesn't matter... in addition to OTHER people.
   14 MCCS  6/28/2022 11:22:28 00:21:56 Statement Cause guess what...?
   15 MCCS  6/28/2022 11:22:30 00:21:58 Statement That means it's a more HEINOUS CRIME, than it SOUNDS like.
   16 MCCS  6/28/2022 11:22:34 00:22:02 Statement And the clues are right in front of everybody's face.
   17 MCCS  6/28/2022 11:22:38 00:22:06 Statement My father said this, BEFORE he was killed...
   18 MCCS  6/28/2022 11:22:39 00:22:07 Statement 'If those niggers come after me-'
   19 MCCS  6/28/2022 11:22:42 00:22:10 Statement 'I'm gonna put my foot to the floor and take those niggers with me to hell.'
   20 MCCS  6/28/2022 11:22:45 00:22:13 Statement That means, it was PREMEDITATED.
   21 FSKC  6/28/2022 11:22:48 00:22:16 Statement He didn't say 'niggers' he said ANYBODY tried to rob him.
   ___________________________________________________________________________________________________________________________
   | My mother constantly argues with me about things I remember. My dad knew that MULTIPLE BLACK KIDS were looking for HIM. |
   | My mother is trying to convey how my father wasn't racist, and- he really wasn't, he very rarely threw that word around |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   22 MCCS  6/28/2022 11:22:50 00:22:18 Statement He said 'niggers'...*overlap* I heard him, mom.
   23 MCCS  6/28/2022 11:22:54 00:22:22 Statement That- that's another thing, you've done this to me my WHOLE life,
   24 MCCS  6/28/2022 11:22:56 00:22:24 Statement like, when I remember certain things like that, you say-
   25 MCCS  6/28/2022 11:22:58 00:22:26 Statement 'Nah, that's wrong'.
   26 MCCS  6/28/2022 11:23:02 00:22:30 Statement You DO that. I remember what my dad, said.
   27 FSKC  6/28/2022 11:23:05 00:22:33 Statement And then he said that around YOU...?
   28 MCCS  6/28/2022 11:23:07 00:22:35 Statement He probably did, and I- I'm just sayin, I remember him SAYING that.
   29 MCCS  6/28/2022 11:23:11 00:22:39 Statement But- y'know, I'm sure my son and my daughter bein'
   30 FSKC  6/28/2022 11:23:15 00:22:43 Statement He was stickin' up for... black fuckin' people, there.
   31 MCCS  6/28/2022 11:23:18 00:22:46 Statement I KNOW he was, but they were also LOOKIN' for him because,
   32 MCCS  6/28/2022 11:23:21 00:22:49 Statement somebody was listening to my dad, and the dispatcher on the radio.
   33 MCCS  6/28/2022 11:23:26 00:22:54 Statement Wanna know how I know that...?
   34 MCCS  6/28/2022 11:23:29 00:22:57 Statement Because the SAME dispatcher was involved in SAMMY's death, and my FATHER's death.
   35 FSKC  6/28/2022 11:23:33 00:23:01 Statement Cause they BOTH worked for the same company.
   36 MCCS  6/28/2022 11:23:36 00:23:04 Statement Right, but- that's a CLUE. *pause* *interrupted*
   37 FSKC  6/28/2022 11:23:39 00:23:07 Statement It wasn't just THEM, there was a couple OTHER cab drivers TOO that got killed.
   38 MCCS  6/28/2022 11:23:43 00:23:11 Statement You have to understand the possibility, that there are MULTIPLE REASONS and EXPLANATIONS for things.
   39 MCCS  6/28/2022 11:23:49 00:23:17 Statement So, the SAME DISPATCHER, and the SAME CAB COMPANY being involved
   40 ENV   6/28/2022 11:23:55 00:23:23 Action    (2) taps heard on my computer, followed by a toast notification
   ______________________________________________________________________
   | ^ Coincidence...? Or can my father speak from beyond the grave...? |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   41 MCCS  6/28/2022 11:23:55 00:23:23 Statement doesn't NECESSARILY MEAN that there's a LARGER CRIME involved...?
   42 MCCS  6/28/2022 11:23:56 00:23:24 Statement But what it DOES mean, is that...
   43 MCCS  6/28/2022 11:23:59 00:23:27 Statement There's a possibility that the (2) crimes were related for a HIGHER reason that YOU'RE NOT CONSIDERING.
   44 MCCS  6/28/2022 11:24:06 00:23:34 Statement That's what I'm trying to tell you. Because if it was a DIFFERENT cab company-
   45 FSKC  6/28/2022 11:24:09 00:23:37 Statement I get it.
   ______________________________________________________________________________
   | ^ My mother starts to act rather DISMISSIVE and MINIMIZING what I'm doing. |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   46 MCCS  6/28/2022 11:24:10 00:23:38 Statement ...it was a DIFFERENT... OK, you don't- you GET it,
   47 MCCS  6/28/2022 11:24:15 00:23:43 Statement but you're crossing your arms and like, getting DEFENSIVE about it.
   ________________________________________________________
   | ^ Body language, developing a pattern of RESISTANCE. |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   48 MCCS  6/28/2022 11:24:17 00:23:45 Statement I'm trying to TELL you that I have actually DONE this, like a fuckin' investigator from the police.
   49 FSKC  6/28/2022 11:24:22 00:23:50 Statement Yeah, but you're not gettin' PAID for it.
   50 MCCS  6/28/2022 11:24:23 00:23:51 Statement Doesn't MATTER- That means- That DOESN'T mean
   51 FSKC  6/28/2022 11:24:25 00:23:53 Statement Put your energy towards something that's gonna RESULT in something
   ________________________________________________________
   | ^ Body language, developing a pattern of RESISTANCE. |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   52 MCCS  6/28/2022 11:24:27 00:23:55 Statement No, I AM putting my energy toward something that's gonna result in something.
   53 MCCS  6/28/2022 11:24:31 00:23:59 Statement You're UNDERMINING me. You think, you don't realize, I have the GUY-
   54 FSKC  6/28/2022 11:24:36 00:24:04 Statement I've had enough, Mike.
   55 MCCS  6/28/2022 11:24:37 00:24:05 Statement The guy who RUNS Saratoga County Sheriffs Office, TRIED, TO HAVE, ME, MURDERED, ON MAY 26th, 2020
   56 FSKC  6/28/2022 11:24:44 00:24:12 Statement Then get a god damn lawyer that believes you.
   57 MCCS  6/28/2022 11:24:49 00:24:17 Statement I have to like, CONVINCE people, like- my MOTHER.
   58 MCCS  6/28/2022 11:24:51 00:24:19 Action    pause
   59 MCCS  6/28/2022 11:24:54 00:24:22 Statement Because I can't BUY a lawyer. Wanna know why I can't BUY a lawyer...?
   60 MCCS  6/28/2022 11:24:58 00:24:26 Statement Because I'm on a NATIONAL SECURITY WATCHLIST, so I can't get a fuckin' job.
   61 MCCS  6/28/2022 11:25:01 00:24:29 Statement Cause (1) asshole worked with the fuckin' police officer who RUNS Saratoga County,
   62 MCCS  6/28/2022 11:25:06 00:24:34 Statement and THEY, they didn't answer my 911 calls.
   63 MCCS  6/28/2022 11:25:10 00:24:38 Statement You don't get it, there is, (7) FELONIES OCCURRED TO ME, that night.
   64 MCCS  6/28/2022 11:25:13 00:24:41 Statement And then I got arrested for cutting a kayak strap.
   65 MCCS  6/28/2022 11:25:17 00:24:45 Statement Not for calling 911 because (2) kids were trying to KILL me, and...
   66 MCCS  6/28/2022 11:25:20 00:24:48 Statement you SEEM to think I'm makin' that up.
   67 FSKC  6/28/2022 11:25:23 00:24:51 Statement NO. YOU'RE NOT. AND I'M SICK AND TIRED OF HEARIN' IT~!
   68 MCCS  6/28/2022 11:25:27 00:24:55 Statement Well, hold on. Hold on. Hold on.
   69 FSKC  6/28/2022 11:25:28 00:24:56 Statement I'm not goin' THROUGH this crap.
   70 FSKC  6/28/2022 11:25:29 00:24:57 Action    Shuts the door
   71 MCCS  6/28/2022 11:25:31 00:24:59 Statement Fuckin'... god damnit.
   ___________________________________________________________________________________________________________
   | ^ Body language, developing a pattern of RESISTANCE -> Explained                                        |
   | My mother is exhibiting EVASIVE/DISMISSIVE behaviors that she USUALLY does, when it concerns my father. |
   | I believe there is a sinister reason for that.                                                          |
   | Every time I talk about my father, and saying stuff like "CLUES" and "NEW TRIALS" where OTHER PEOPLE    |
   | WERE INVOLVED...? Oh. Ma dukes starts to show some RESISTANCE. Hm. Keep this pinned in memory.          | 
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Section 2                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯   
   72 MCCS  6/28/2022 11:59:58 00:59:26 Action    Knock on door
   73 MCCS  6/28/2022 12:00:01 00:59:29 Statement Can you open the door...?
   74 FSKC  6/28/2022 12:00:02 00:59:30 Action    Silent
   75 MCCS  6/28/2022 12:00:11 00:59:39 Statement Hey...!
   76 FSKC  6/28/2022 12:00:12 00:59:40 Statement What...?
   77 MCCS  6/28/2022 12:00:12 00:59:40 Statement Can you open the door...?
   78 FSKC  6/28/2022 12:00:13 00:59:41 Statement Why...?
   79 MCCS  6/28/2022 12:00:14 00:59:42 Statement Cause I need to tell you somethin' very serious.
   80 FSKC  6/28/2022 12:00:17 00:59:45 Action    Silent
   81 MCCS  6/28/2022 12:00:24 00:59:52 Statement You suggested that I just leave the state, right...?
   82 MCCS  6/28/2022 12:00:32 01:00:00 Statement You know why that would be a stupid idea...?
   83 FSKC  6/28/2022 12:00:34 01:00:02 Action    Silent
   84 MCCS  6/28/2022 12:00:37 01:00:05 Statement Cause then people I won't know who are after me will wind up getting me.
   85 FSKC  6/28/2022 12:00:42 01:00:10 Statement Whatever.
   ______________________________________
   | ^ Pattern of RESISTANCE continued. |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ Section 3                                                                                      ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯   

   86 MCCS  6/28/2022 12:54:18 01:53:46 Statement Hey
   87 MCCS  6/28/2022 12:54:18 01:53:46 Action    Knocks on door
   88 FSKC  6/28/2022 12:54:20 01:53:48 Statement What...?
   89 MCCS  6/28/2022 12:54:20 01:53:48 Statement Come here.
   90 MCCS  6/28/2022 12:54:22 01:53:50 Statement I gotta show you something, right now.
   91 MCCS  6/28/2022 12:54:25 01:53:53 Statement Come here, it's VERY important. It's SO important, I need ya to see it.
   92 MCCS  6/28/2022 12:54:31 01:53:59 Statement C'mon ma, please.
   93 MCCS  6/28/2022 12:54:35 01:54:03 Statement Mom can you PLEASE stand up and look at this fuckin' thing right now...?
   94 FSKC  6/28/2022 12:54:38 01:54:06 Statement God damnit.
   95 FSKC  6/28/2022 12:54:47 01:54:15 Action    Opens door
   96 MCCS  6/28/2022 12:54:49 01:54:17 Statement I'm about to show ya
   97 FSKC  6/28/2022 12:54:52 01:54:20 Statement I'm cool.
   98 MCCS  6/28/2022 12:54:52 01:54:20 Statement C'mere
   99 MCCS  6/28/2022 12:54:53 01:54:21 Action    Walks from Mom's room to Son's room
  100 FSKC  6/28/2022 12:54:53 01:54:21 Action    Walks from Mom's room to Son's room also
  101 MCCS  6/28/2022 12:54:53 01:54:21 Statement I'm about to show you that the Saratoga County, fuckin' cobbled together illegal charges.
  102 MCCS  6/28/2022 12:55:04 01:54:32 Statement You see this line, right here...? Look at it very closely.
  103 MCCS  6/28/2022 12:55:08 01:54:36 Statement You gotta look at it closely. You can't be lookin at something closely from 5 feet away.
  104 MCCS  6/28/2022 12:55:13 01:54:41 Statement As in, move your head, closer...? You see that line...?
  105 FSKC  6/28/2022 12:55:16 01:54:44 Statement Are you fuckin' kidding...? God damn you...
  106 MCCS  6/28/2022 12:55:17 01:54:45 Statement Look at this line right here, I'm trying to get you to fuckin' look at it.
  107 FSKC  6/28/2022 12:55:19 01:54:47 Statement I AM~!
  108 MCCS  6/28/2022 12:55:20 01:54:48 Statement You see how THAT line has an EXTRA LINE OF PIXELS there...?
  109 MCCS  6/28/2022 12:55:24 01:54:52 Statement You see THAT...?
  110 FSKC  6/28/2022 12:55:26 01:54:54 Statement No.
  111 MCCS  6/28/2022 12:55:26 01:54:54 Statement You don't see how THAT is SLIGHTLY DIFFERENT than EVERY OTHER LINE...?
  112 FSKC  6/28/2022 12:55:31 01:54:59 Statement No.
  113 MCCS  6/28/2022 12:55:33 01:55:01 Statement Are you retarded...?
  114 FSKC  6/28/2022 12:55:34 01:55:02 Statement Nope.
  115 MCCS  6/28/2022 12:55:36 01:55:04 Statement THAT, right there, you see...? Look at the very BOTTOM of the letter S
  116 FSKC  6/28/2022 12:55:40 01:55:08 Statement Yeah...?
  117 MCCS  6/28/2022 12:55:40 01:55:08 Statement Okay...? Look at the very BOTTOM of the letter S THERE.
  118 MCCS  6/28/2022 12:55:44 01:55:12 Statement See how it's DIFFERENT...?
  119 FSKC  6/28/2022 12:55:46 01:55:14 Statement Yeah...?
  120 MCCS  6/28/2022 12:55:47 01:55:15 Statement That's because somebody's trying to COMMUNICATE with me
  121 MCCS  6/28/2022 12:55:50 01:55:18 Statement THIS TICKET right here (SCSO-2020-003173 1212), is the, it says 'Suspect of an earlier complaint made by Zachary Karel'
  122 MCCS  6/28/2022 12:55:57 01:55:25 Statement The EARLIER complaint they made (SCSO-2020-003177 1414), was at 1414.
  123 MCCS  6/28/2022 12:56:03 01:55:31 Statement So, they're literally writing in a fuckin' document that they arrested me for, that an EARLIER complaint was made...
  124 MCCS  6/28/2022 12:56:10 01:55:38 Statement AFTER, 1212. I HAVE the other fuckin' ticket.
  125 MCCS  6/28/2022 12:56:14 01:55:42 Statement The other ticket, is right here.
  126 MCCS  6/28/2022 12:56:17 01:55:45 Statement 1414 Oh yeah, no, this is an earlier <complaint>
  127 MCCS  6/28/2022 12:56:20 01:55:48 Statement That's what fuckin' Saratoga County Sheriffs Office did to me
  128 MCCS  6/28/2022 12:56:23 01:55:51 Statement An EARLIER complaint was made at 1414, THAT'S NOT EARLIER THATS LATER.
  129 FSKC  6/28/2022 12:56:30 01:55:58 Statement Why are you fuckin' yellin' at me...?
  130 MCCS  6/28/2022 12:56:31 01:55:59 Statement Because I spent the last (2) years telling you this, and you keep thinkin' I'm INSANE~!
   ________________________________________________________________________________________________________________
   | Now I've shown my mother that she has a SINGLE REASON to ACTUALLY BELIEVE ME...? But- chooses not to.        |
   | Whether she detects this SCRIBBLES exploit or not...? Most people won't detect it. It is meant to be elusive |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  131 FSKC  6/28/2022 12:56:37 01:56:05 Statement You better, you better... get the fuck outta my house.
  132 FSKC  6/28/2022 12:56:41 01:56:09 Statement Get away, get the hell away from me, Mike.
  133 MCCS  6/28/2022 12:56:44 01:56:12 Statement You're treating me like I'm insane. I'll stop yelling-
  134 FSKC  6/28/2022 12:56:47 01:56:15 Statement You're ACTING like you're insane.
  135 MCCS  6/28/2022 12:56:49 01:56:17 Statement I'm acting that way because I spent the last (2) years trying to-
  136 FSKC  6/28/2022 12:56:51 01:56:19 Statement Alright~! Whatever~!
  137 MCCS  6/28/2022 12:56:53 01:56:21 Statement It's so important.
  138 FSKC  6/28/2022 12:56:54 01:56:22 Statement Get the fuck outta my face.
  139 MCCS  6/28/2022 12:56:55 01:56:23 Statement What can you DO about it...?
  140 MCCS  6/28/2022 12:56:57 01:56:25 Statement YOU don't understand-
  141 FSKC  6/28/2022 12:56:58 01:56:26 Statement YOU need to get the fuck outta my face~!
  142 MCCS  6/28/2022 12:57:01 01:56:29 Statement I'm not IN your face. I'm asking you for help. You're NOT helping.
  143 FSKC  6/28/2022 12:57:05 01:56:33 Statement I AM~!
  144 MCCS  6/28/2022 12:57:06 01:56:34 Statement No you're not.
  145 FSKC  6/28/2022 12:57:07 01:56:35 Statement Get the fuck outta here.
  146 MCCS  6/28/2022 12:57:09 01:56:37 Statement You might as well just grab a knife and stab me in the back.
  147 FSKC  6/28/2022 12:57:10 01:56:38 Statement Get the fuck
  148 MCCS  6/28/2022 12:57:11 01:56:39 Statement That's YOUR idea of
  149 FSKC  6/28/2022 12:57:12 01:56:40 Action    Mother closing her bedroom door while son is standing in doorway
  150 MCCS  6/28/2022 12:57:12 01:56:40 Statement Don't shut this fuckin' door on me,
   __________________________________________________________________________________________________________________
   | ^ Pattern of RESISTANCE continued - While it's not ILLEGAL to shut a door in someone's face...?                |
   | The pattern of resistance becomes pretty questionable. My mother has done this to me since I was 10 years old. |
   | She started treating me like an emotional punching bag after my father was killed... I'll elaborate shortly.   |
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  151 FSKC  6/28/2022 12:57:14 01:56:42 Statement Get the fuck AWAY from me.
  152 MCCS  6/28/2022 12:57:14 01:56:42 Statement No. *pause* Look, listen to me.
  153 MCCS  6/28/2022 12:57:18 01:56:46 Statement You treat me like I'm 10 years old (when dad was killed and she started acting this way)
  154 FSKC  6/28/2022 12:57:19 01:56:47 Statement No~! I'm not!
  155 MCCS  6/28/2022 12:57:21 01:56:49 Statement Yeah you are.
  156 FSKC  6/28/2022 12:57:21 01:56:49 Statement I'm treatin' you like a 37 idiot.
  157 FSKC  6/28/2022 12:57:28 01:56:56 Statement Get the fuck away from me.
  158 MCCS  6/28/2022 12:57:30 01:56:58 Statement You- You're helping the police, commit a crime.
  159 FSKC  6/28/2022 12:57:34 01:57:02 Statement I'M NOT HELPING NOTHING~!
  160 MCCS  6/28/2022 12:57:36 01:57:04 Statement You are~! You're being INDIFFERENT, you're not doing anything to HELP me, you're not GOING to-
  161 FSKC  6/28/2022 12:57:39 01:57:07 Statement GET. THE. FUCK. OUT. OF. MY. FAAAAACE~!
  162 MCCS  6/28/2022 12:57:43 01:57:11 Action    standing there speechless, thinking of a new strategy to pivot to
   ____________________________________________________________________________________________________________________
   | They say it takes a village to raise a child, right...? But my mother left me alone FAR too often, and didn't    |
   | spend a lot of time with me growing up. If anything, I felt emotionally abandoned, developed a case of PTSD, and |
   | had undiagnosed mental conditions such as ADHD and Autism Spectrum Disorder. My mother didn't do a good job of   |
   | taking care of me, AND... I think it might be because she did something evil to my father AND me.                |
   | My mother's responses from here on out show a rising level of DETACHMENT, and making me feel DISPOSABLE.         | 
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  163 MCCS  6/28/2022 12:57:49 01:57:17 Statement You LIKE the fact that my father's gone, don't you...?
  164 FSKC  6/28/2022 12:57:50 01:57:18 Statement Yes I do, Mike. I am SO fuckin' happy, ain't I...?
  165 MCCS  6/28/2022 12:57:56 01:57:24 Statement You are~!
  166 FSKC  6/28/2022 12:57:57 01:57:25 Statement Stupid bitch~!
  167 MCCS  6/28/2022 12:57:58 01:57:26 Statement You would LOVE it if I got shot to death just like my father.
  168 FSKC  6/28/2022 12:58:02 01:57:30 Statement YES, I WOULD.
  ________________________________________________________________________________________________________________________
  | My mother is usually sarcastic and facetious, however, I don't think she's being facetious or sarcastic at all here. |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  169 MCCS  6/28/2022 12:58:04 01:57:32 Statement Good.
  170 MCCS  6/28/2022 12:58:07 01:57:35 Statement That's why it's totally fine for me to fuckin' embarrass you in front of your friends.
  171 MCCS  6/28/2022 12:58:12 01:57:40 Statement They'll stick up for you.
  172 FSKC  6/28/2022 12:58:14 01:57:42 Statement You didn't EMBARRASS me.
  173 MCCS  6/28/2022 12:58:15 01:57:43 Statement You SHOULDN'T walk away from me...
  174 MCCS  6/28/2022 12:58:20 01:57:48 Statement I'm gonna record ALL this shit, about how you like fuckin' walk away, BECAUSE...
  175 MCCS  6/28/2022 12:58:25 01:57:53 Statement Now I think that you're involved in this fuckin' conspiracy to commit murder against my father
  __________________________________________________________________________________________________________________________
  | And here we go. I think my mother had something to do with my father being killed, and has tried to do the same to me. |
  | The COOL thing is, NONE OF THIS STUFF BELOW ABOUT MY FATHER WAS REPORTED TO SARA DERUSSO. Weird, right...?             |
  | First thing you would typically want to do if you're making a complaint about your adult son having a physical         |
  | confrontation with, is the REASON WHY THE CONFRONTATION STARTED. LEAVING THAT CRITICAL THING OUT OF THE REPORT...?     |
  | It says "LYING BY OMISSION"                                                                                            |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  176 FSKC  6/28/2022 12:58:31 01:57:59 Action    Tries to slam the kitchen door in my face
  177 MCCS  6/28/2022 12:58:33 01:58:01 Statement No, I think you conspired to murder my father, now.
  178 FSKC  6/28/2022 12:58:34 01:58:02 Action    Keeps walking away from me, indicates MALICIOUS INTENT
  179 MCCS  6/28/2022 12:58:35 01:58:03 Statement YOU KEEP WALKING AWAY FROM ME, AND IT INDICATES THAT YOU'RE GUILTY FOR SOMETHIN'~!
  180 MCCS  6/28/2022 12:58:39 01:58:07 Statement THAT'S WHY, YOU'RE NOT GOIN' ANYWHERE
  181 FSKC  6/28/2022 12:58:42 01:58:10 Statement Now you're-
  182 MCCS  6/28/2022 12:58:42 01:58:10 Statement I'M GONNA HAVE YOU FUCKIN' ARRESTED. YOU HAD MY FUCKIN' FATHER MURDERED, DIDN'T YOU YOU FUCKIN' DUMBASS CUNT.
  ______________________________________________________________________________________________________________________________
  | I really do think that now, after this INCIDENT and this REPORT                                                            |
  | Wanna know why...?                                                                                                         |
  | Because then it starts to explain her RESISTANT BEHAVIOR EVERY TIME I TALK ABOUT INVESTIGATING MY FATHERS MURDER.          |
  | AND, HOW MORE PEOPLE WERE INVOLVED IN KILLING HIM.                                                                         |
  | If she LOVED my father, she would probably want to hear my theories and conjecture regarding what I've uncovered.          |
  | But INSTEAD, she starts to HEM and HAW, and INTERRUPT ME, TALK OVER ME, BELITTLE ME, DISTRACT ME...                        |
  | ...and the fact that she said NOTHING ABOUT MY ACCUSATIONS IN HER REPORT tells me that it's MORE THAN JUST A FUCKIN HUNCH. |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  183 ENV   6/28/2022 12:58:47 01:58:15 Action    Son grabbed mother's wrists and placed mother against the wall*
  184 FSKC  6/28/2022 12:58:47 01:58:15 Action    Mother makes a fake choking noise*
  185 MCCS  6/28/2022 12:58:48 01:58:16 Statement Didn't you...? YOU HAD MY FATHER MURDERED DIDN'T YOU...?
  186 MCCS  6/28/2022 12:58:53 01:58:21 Statement Yeah you fuckin' did
  187 MCCS  6/28/2022 12:58:54 01:58:22 Statement Admit it, right now, and I will have you fuckin' arrested.
  188 MCCS  6/28/2022 12:58:59 01:58:27 Statement Stop fuckin' walkin' away from me.
  189 MCCS  6/28/2022 12:59:03 01:58:31 Statement No, I'll have you arrested.
  190 FSKC  6/28/2022 12:59:04 01:58:32 Statement I'm gonna have YOU arrested.
  191 MCCS  6/28/2022 12:59:05 01:58:33 Statement No you're not.
  192 MCCS  6/28/2022 12:59:08 01:58:36 Statement Now, I have- I suspect that you had
  193 FSKC  6/28/2022 12:59:12 01:58:40 Statement Alright, this is the last time you touch me.
  194 MCCS  6/28/2022 12:59:14 01:58:42 Statement No.
  195 FSKC  6/28/2022 12:59:17 01:58:45 Statement This is the LAST TIME... you FUCKIN' TOUCH ME...
  196 MCCS  6/28/2022 12:59:17 01:58:45 Statement I'll have you arrested.
  197 MCCS  6/28/2022 12:59:19 01:58:47 Statement I will have you arrested.
  198 MCCS  6/28/2022 12:59:21 01:58:49 Statement I will have you, fucking, arrested.
  199 MCCS  6/28/2022 12:59:23 01:58:51 Statement Don't you fuckin' understand what the hell I'm saying...?
  200 MCCS  6/28/2022 12:59:26 01:58:54 Statement YOU'RE NOT HEARIN' A FUCKIN' WORD I'M SAYING YOU STUPID CUNT~!
  201 MCCS  6/28/2022 12:59:31 01:58:59 Statement YOU HAD MY FATHER MURDERED, DIDN'T YOU...?
  202 FSKC  6/28/2022 12:59:33 01:59:01 Statement NO~! OH, NOW IT'S-
  __________________________________________________________________________________________________________________________
  | Here's why this is critical. If she had nothing to do with my dad being killed, then why did it take SEVERAL ATTEMPTS  |
  | and me making these ACCUSATIONS, BEFORE she even says NO the FIRST TIME...? WELL, she hasn't OUTRIGHT DENIED IT YET.   |
  | It is BECAUSE she keeps TRYING to WALK AWAY from the THING that she KNOWS she DID, OTHERWISE, it would've been her     |
  | FIRST RESPONSE, INSTEAD OF, WALKING AWAY. WALKING AWAY doesn't indicate INNOCENCE, LOVE, or ANYTHING like that. Nah.   |
  | WALKING AWAY IS A DISTRACTION. IT INDICATES GUILT or EVASIVENESS. Everyone deals with losing people differently,       |
  | however- uh... Ma dukes seems to have this QUESTIONABLE FUCKING BEHAVIOR that's supported by QUESTIONABLE RESPONSES,   |
  | as well as a QUESTIONABLE FUCKING STATEMENT TO THE POLICE.                                                             |
  |                                                                                                                        |
  | I'm gonna go out on a LIMB here, and say, when YOUR CHILD HAS ACCUSED YOU of having SOMETHING to do with your HUSBAND  | 
  | being killed...? WALKING AWAY sure as fuck doesn't indicate that she's fuckin' INNOCENT, I'll tell ya much.            |                                |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  203 MCCS  6/28/2022 12:59:35 01:59:03 Statement Then stop fuckin' walkin' away from me
  204 FSKC  6/28/2022 12:59:37 01:59:05 Statement GET THE FUCK OFF OF ME.
  205 MCCS  6/28/2022 12:59:39 01:59:07 Statement STOP FUCKIN' WALKIN' AWAY FROM ME
  206 FSKC  6/28/2022 12:59:40 01:59:08 Statement GET THE FUCK OFF OF ME.
  207 MCCS  6/28/2022 12:59:41 01:59:09 Statement STOP FUCKIN' WALKIN' AWAY FROM ME
  208 FSKC  6/28/2022 12:59:42 01:59:10 Statement GET OFF OF ME~!
  209 FSKC  6/28/2022 12:59:45 01:59:13 Statement HELP~!
  210 FSKC  6/28/2022 12:59:47 01:59:15 Statement HELP~!
  211 MCCS  6/28/2022 12:59:47 01:59:15 Statement Nobody gives a shit about you. You let my father die, DIDN'T YOU...?
  212 FSKC  6/28/2022 12:59:51 01:59:19 Statement <I'm gonna KILL you.>
  _______________________________________________________________________________________________________________________
  | My mother just threatened to kill me. I mean, it MAY have been like a "I'm gonna HURT ya..." but- considering the   | 
  | context, I think she was VERY serious about that. Regardless, if I SAID THAT SHIT...? OH BOY. WOULD'VE BEEN TAKEN   | 
  | TO JAIL OR THE HOSPITAL. But, because SHE said it...? It's fine. No big deal. She can threaten to kill me, and then |
  | say nothing to SARA DERUSSO about my HUNDRED ACCUSATIONS. That's fuckin' weird, right...? Hm. But, here's an idea.  |
  | If my SON or my DAUGHTER EVER accused ME of killing their mother... somehow...?                                     |
  | I wouldn't WALK AWAY, nor would I refuse to SAY ANYTHING like my mother is doing here, unless I was guilty.         |
  | I would literally stand face to face with them, look them in the eye, and tell them that they must be outside of    |
  | their mind, to think I would do such a thing. AND- do whatever it takes to prove that I love them and her. I'd ALSO |
  | tell them how much I actually loved their mother, and would never do such a thing to someone I LOVE... but to be    |
  | perfectly clear, their mother and I had many heated arguments and altercations... However- that shit ALL stemmed    |
  | from the WAY that my MOTHER FAILED TO RAISE ME... Maladaptive coping mechanisms. That's what mom taught me. I'm not |
  | saying it's all my mother's fault, but she is the reason why I became a drug addict, no question about that. Also   |
  | the reason why I was never diagnosed or got counseling or good grades in school. While their mother DID upset me SO |
  | MANY TIMES...?                                                                                                      |
  | I realized that to prove I loved her, I had to let her go. NOT to let her DIE, BUT- to let her do what SHE wanted.  |
  | And as for my children...? They mean everything to me. As I was writing this, I realized how many things I miss     |
  | about the both of them, BUT- I'm surrounded by morons, assholes, and liars that like to take credit for shit that I |
  | did right...? And then tell people that I'm a degenerate fuckface that never did a fuckin thing with his life. My   |
  | mother happens to be one of those people, by the way. Nah, I dont' think people get it. I was almost killed. If my  |
  | mother seems to think I'm makin' that up...? Then she's not a very good mother to think that. If anything, my mom   |
  | has been SO INCREDIBLY CRUEL TO ME, and my kids... as can be read/heard in this transcription.                      |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  213 FSKC  6/28/2022 12:59:53 01:59:21 Statement God damnit~! Alright, that's it... That's it...
  214 FSKC  6/28/2022 12:59:57 01:59:25 Statement That's it... this is the LAST TIME,
  215 MCCS  6/28/2022 1:00:00  01:59:28 Statement No, you're gonna
  216 FSKC  6/28/2022 1:00:01  01:59:29 Statement This is the LAST TIME
  217 MCCS  6/28/2022 1:00:02  01:59:30 Statement You're gonna go to prison.
  218 FSKC  6/28/2022 1:00:05  01:59:33 Statement Go ahead, call the cops. Go ahead. Go ahead.
  219 FSKC  6/28/2022 1:00:12  01:59:40 Statement Alright, I'm chill.
  220 MCCS  6/28/2022 1:00:17  01:59:45 Statement You had my father murdered
  221 FSKC  6/28/2022 1:00:17  01:59:45 Statement No you ass~!
  222 MCCS  6/28/2022 1:00:19  01:59:47 Statement Then why do you keep walking away from me...?
  223 FSKC  6/28/2022 1:00:20  01:59:48 Statement It has nothin' to do with-
  224 MCCS  6/28/2022 1:00:22  01:59:50 Statement STOP WALKIN' AWAY, and stop fuckin' fightin'.
  225 FSKC  6/28/2022 1:00:24  01:59:52 Statement Every single fuckin' time that you fucking SQUIRM...?
  226 FSKC  6/28/2022 1:00:31  01:59:59 Statement You're hurtin' my leg~!
  227 MCCS  6/28/2022 1:00:31  01:59:59 Statement Well, guess what...?
  228 MCCS  6/28/2022 1:00:32  02:00:00 Statement No.
  229 FSKC  6/28/2022 1:00:35  02:00:03 Statement LEAVE ME ALONE~!
  230 MCCS  6/28/2022 1:00:41  02:00:09 Statement No.
  231 FSKC  6/28/2022 1:00:44  02:00:12 Statement God damnit~!
  232 MCCS  6/28/2022 1:00:46  02:00:14 Statement I'm not even hurting you, I'm RESTRAINING you, I'm not HURTING you.
  233 FSKC  6/28/2022 1:00:49  02:00:17 Statement No, you ARE hurtin' me.
  234 MCCS  6/28/2022 1:00:54  02:00:22 Statement I'm not hurting you. You're lying. I'm restraining you.
  235 FSKC  6/28/2022 1:01:02  02:00:30 Statement LET GO OF ME~!
  236 MCCS  6/28/2022 1:01:03  02:00:31 Statement You need to UNDERSTAND something, you are GUILTY of conspiring to murder my father.
  ____________________________________________________________________________________________________________
  | There's a chance that despite the fact that I say it to her and it leads to this altercation...?         |
  | People will make up excuses for my mother. Idk though, maybe they'll be ALARMED by what's goin' on here. |
  | Is my behavior the best...? Nah, but my mother is acting like the fucking devil in this whole recording. |
  | She DID say that I took her PHONE out of her hands, right...? Well, where the hell is that in this       |
  | transcription...? OH... It's because that NEVER HAPPENED.                                                |
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  237 FSKC  6/28/2022 1:01:09  02:00:37 Statement No I'm NOT.
  238 MCCS  6/28/2022 1:01:11  02:00:39 Statement You're gonna go to prison. (I really hope she does, because I am convinced.)
  239 FSKC  6/28/2022 1:01:12  02:00:40 Statement You're hurting me~!
  240 FSKC  6/28/2022 1:01:13  02:00:41 Statement God damnit~!
  241 FSKC  6/28/2022 1:01:16  02:00:44 Statement God damnit Michael~!
  242 FSKC  6/28/2022 1:01:19  02:00:47 Statement Let GO of me, motherfucker.
  243 FSKC  6/28/2022 1:01:21  02:00:49 Statement LET GO OF ME~!
  244 FSKC  6/28/2022 1:01:25  02:00:53 Statement LET GO OF ME~!
  245 MCCS  6/28/2022 1:01:28  02:00:56 Statement Stop walkin' out the fuckin' door.
  246 FSKC  6/28/2022 1:01:29  02:00:57 Statement LET GO OF ME~!
  247 MCCS  6/28/2022 1:01:30  02:00:58 Statement You're guilty of conspiring to murder my father. (Unsure if that's what I said.)
  248 FSKC  6/28/2022 1:01:32  02:01:00 Statement No I'm NOT, you ass~!
  249 MCCS  6/28/2022 1:01:39  02:01:07 Statement You deserve a lot more than that.
  250 FSKC  6/28/2022 1:01:43  02:01:11 Action    Slams front door
  251 MCCS  6/28/2022 1:01:52  02:01:20 Statement Fuck
  252 MCCS  6/28/2022 1:02:04  02:01:32 Action    Ends recording
#>


# I have to consider the theory, that maybe she DID have a hand in greenlighting my father
# for murder... Most people wouldn't even CONSIDER the theory, and they'll do what my aunt 
# Nancy did, get so OFFENDED by the IDEA, that anyone who mentioned it is told to fuck off.

# Some people will actually use this as an ADVANTAGE, because it's a PERFECT DISGUISE.
# Mom taught me SOME USEFUL STUFF AFTER ALL OVER THE YEARS...
# ____________________________________________________________________
# | Oh what tangled webs we weave when we first practice to deceive. |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# If people would never even think to consider something...? The strategy is perfect.
# 
# Basically, playing into the role of the innocent widow SO WELL, that people DEFEND her.
# For the first 25 years, I never thought to suspect my mother at all.
#
# The reason I would TRY to suspect as such NOW, is this simple...
# First off, I told her about my fear of going missing and never being found BEFORE these
# dudes were following me around all over the place. 
#
# Second, she seems to have a pretty hard time believing me. I think there's an ulterior motive for her to not believe me.
#
# I don't think she had anything to do with the (2) guys that tried to kill me outside of Computer Answers.
# Because in the audio recording on 4/4/2021, I tried to use that technique and it actually manipulated her to 
# come out of her bedroom. 
#
# However, she's been using DISTRACTION TECHNIQUES my whole life.
# Then she'll tell me that I'm smart, but that I'm a stupid bitch...? Cool. 
#
# Every time I talk about how MORE PEOPLE WERE INVOLVED in my FATHER'S murder, she UNDERMINES me, or tries to slam
# the door shut in my face, or walk away, or be facetious... so, she's hiding SOMETHING.
#
# I really do honestly believe there is SOME PLAUSIBILITY, that my mother could've had me for a
# quick cash-grab, based on how she's treated me over the years. Have a kid, kill the husband after a while, 
# and hope that the kid grows up and becomes successful without paying any attention to his needs. 
#
# That's exactly what my mom did. She emotionally abandoned me after my father passed away. They argued A LOT.
# It could be the case that she was never emotionally there to begin with, and I just NOTICED it a lot more
# after he was gone... 
#
# Sure, she's taken care of me, she's been the parent, she's paid the bills, and did what she could... but
# ultimately, my mother has done a lot of fucked up shit to me and SAID a lot of fucked up shit, too. 
# I wouldn't begin playing with the idea if I didn't think she had some ulterior motive that whole time. 
# I'm not TOTALLY SOLD on the idea though.
#
# Still, if I CONSIDER the theory, she may have been using all of these distraction techniques
# because she's HAPPY with the RESULT of the (3) trials. Except when I start talking about how
# there were MORE people involved...? It does begin to feel like she may have gotten away with
# it scott free, and every time I bring it up she's gotta pretend it's such a fucking ridiculous
# idea for me to investigate my father's murder even MORE, cause... the experts did that already.
# They totally missed out on an entire box worth of evidence that says other people were involved.
#
# I have begun to believe that there may be an ULTERIOR MOTIVE for her to be using these
# TECHNIQUES to cause me to DOUBT myself, or feel like the investigation is a lost cause.
# Because. If she DID have something to do with it, she would do these things to throw me
# off course, AND, she would say something like "Stupid bitch" because I was just a little
# dog to her that whole. Not a son, just a little pet. Keep up appearances, tell everybody
# how cute your dog is, and then take off. Over and done.
#  
# She doesn't appear to want ANYBODY, to 1) talk to her about the murder, and 2) DO ANY MORE
# DIGGING. I don't think it's because she gets emotional when I talk about it. I think there's
# a rather CALLOUSED reason why.
# 
# Because she works incredibly hard to thwart me off course, or to DOUBT MYSELF. 
# 
# When I asked her "You LIKE the fact that my father's gone, don't you...?"
# She does respond facetiously, to some degree. And then I BOLSTER her agreement, and she just
# calls me a stupid bitch. THAT RIGHT THERE means that my mother has always thought I was stupid.
# For a LOVING MOTHER to FACETIOUSLY AGREE to something that FUCKED UP, and then say STUPID BITCH...
# Uh- I wonder what that tells anybody else.
# 
# When I try to talk to her about my fathers murder, she will shut the door in my face at SPECIFIC 
# MOMENTS, and her BODY LANGUAGE and DEMEANOR supports this theory.
#
# [23:27]...
# Me  : There's a possibility that the (2) crimes were related for a HIGHER reason that 
#       YOU'RE NOT CONSIDERING. (<- opening up an old wound. 25 years of keeping a secret hidden.)
#       That's what I'm trying to tell you. 
#       Because if it was a DIFFERENT cab company-
# Her : I get it. (<- She's being DISMISSIVE.)
# ________________________________________________________________________________________
# | A loving wife would want to know if MORE PEOPLE WERE INVOLVED.                       |
# | Not to mention, the MOTORCYCLE he was struck by when I was 2 months old...           |
# | Mom made up excuses for that lady who SUPPOSEDLY didn't have any MONEY or anything.  |
# | But also, she had a friend named KRYSTAL who used to live in VOSBURGH who died on a  |
# | motorcycle, she had RED HAIR, and a friend named DIANE, she she dated some dude in   |
# | Round Lake named Dave or something. Sometimes my mother would leave me at HER HOUSE. |
# | Weird how I remember all of this stuff from when I was 4 years old, huh...?          |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Me  : ...it was a DIFFERENT... OK, you don't- you GET it,
#       but you're crossing your arms and like, getting DEFENSIVE about it. (<- Body language, guarded)
#       I'm trying to TELL you that I have actually DONE this, like a fuckin' investigator from the police.
# _________________________________________________________________________________________________
# | The bottom line being, she isn't concerned with the NUMEROUS coincidental CLUES, and she will |
# | flat out walk away from me and not SAY anything, which is pretty malicious OR, dysfunctional  |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Her : Yeah, but you're not gettin' PAID for it. (<- DISTRACTION/I'm "wasting my time")
# Me  : Doesn't MATTER- That means- That DOESN'T mean...
# Her : Put your energy towards something that's gonna RESULT in something (<- SUSPICIOUS) 
# Me  : No, I AM putting my energy toward something that's gonna result in something.
#       You're UNDERMINING me. You think, you don't realize, I have the GUY-...
# 
# Whether the guy from Saratoga County Sherrifs Office and I have some outstanding chess match...?
# My mother's mentality has taken top priority. 
#
# Whatever's going on in my mother's head, what is the most damning, is that she mentions none of these 
# things about how I accused her of conspiring to murder my father on her statement to SARA DERUSSO. And,
# my mother lied NUMEROUS TIMES ON THAT STATEMENT. AT NO POINT DID I TAKE HER PHONE FROM HER, at no point
# did I have her in a headlock. At no point was I doing ANYTHING to her, to cause her INJURY, or HARM.
#
# If anything, I was determined to figure out WHY she seems to have such LITTLE EMPATHY, or doesn't 
# believe me, that I was almost killed outside of the computer answers shop. 
# 
# A loving mother wouldn't outright ignore something her child was saying, but she's done this since I was 10.
#
# My mother emotionally abandoned me after my father was killed, she drank more, spent more time working, I
# wound up having to cook myself food a lot, and passed out many times before she'd ever get home.
# 
# She SEEMED very distraught, and I do believe she was DEVASTATED over it...
# But- I find the prospect pretty chilling, that she might've actually been playing stupid with my father.
# A guy my mother worked with lived off on Grand Street, near lower Madison.
# A black dude named John, I believe.
# He had a son and I spent a fair amount of time there.
# They also had a friend on Park St...? A woman named Pauline who cut my hair all the time.
# I remember a number of these details that she has spent so many years trying to say...
# "You don't remember THAT~!" but- uh, yeh I do bitch.
#
# My mother and father argued constantly.
# My father told me and my mother what RACE his killers would be.
# My father was pretty sure ahead of time that it wouldn't be a robbery.
#
# She seems to keep calling it a robbery, and seems TOTALLY CONVINCED that's ALL it was.
# BUT CALLING IT A FOILED ROBBERY DOESN'T MAKE A LOT OF FUCKING SENSE FOR SEVERAL REASONS.
# 
# The killers had more money in their pockets than he had on him.
# Guys with more money than a cab driver aren't gonna put their lives in jeopardy and go to prison for $63 bucks...
# EVEN IF A CABBIE HAD LIKE $500 bucks on him, WHO THE FUCK IS GOING TO KILL SOMEONE OVER $500 BUCKS...?
# And that's just it, man. Nobody in their RIGHT MIND, would take someone's life, for that little.
#
# Unless that person was just really fuckin' stupid, or very fucked up on drugs, or whatever.
# For my father to wind up getting shot to death, it would've barely made any sense at all, if he was thousands
# of dollars in debt, OR, he was pissing off the mafia in Albany PD.
# 
# Especially when there was a WITNESS, a guy who was in the cab with my dad when he picked these (3) dudes up.
#
# Even if they thought they would get away with a robbery, doesn't make much sense to show up with a loaded gun
# unless you're planning to kill the target. So, I firmly believe that MONEY was NOT THE GOAL.
# This was a HIT. An EXECUTION. Ultimately, the trigger man was never named.
#
# Lastly, when I went to Sing Sing Correctional Facility, I spoke with Tyrell Crawford for like an hour.
# No one in my family has spoken to any of these inmates.
#
# Except me, I had plans to see Clifton, but never followed through.
# Tyrell Crawford had a look on his face when I mentioned that my father predicted that night.
#
# The look on his face when I said that, was of HORROR. It actually looked like a face that saw a possibility
# that he might be charged for additional crimes and be tried AGAIN, and do even MORE time in prison.
# That's the look I saw on this dudes face, and I still remember it quite clearly.
#
# Uh, however...? 
# If other people were involved, then they're a LOT more important. He and Clifton Williamson could help 
# themselves out, big time... because neither one of them is the guy who pulled the trigger, nor the one who
# gave the order.
#
# I kept asking myself questions about why TYRELL responded to what I'd said, and though I don't remember
# the EXACT questions I'd asked...? I do distinctly remember the look on his face that told me something else
# was going on.
#
# Regardless, my mother SHOULD want to talk to me about all of these things, BUT- doesn't.
# Is it for reasons that are fucking EVIL...? Well, based on the fucking report she filed...
# ...seems fuckin' likely. Not sure how she would've forgotten WHAT the hell I was accusing her of,
# and made NO FUCKING MENTION OF IT TO SARA DERUSSO. 

# So... ultimately, yeah. I think my mother is hiding something, and that something... is her involvement
# in my father's murder. Because the BIGGEST QUESTION that people should ask...? 
# Is, "...the audio recording doesn't quite match up with the story she gave the police..."

# So, when I start to ACCUSE her of it, she doesn't SAY anything in response. She's not DEFENDING 
# herself, she's not getting fuckin' PISSED at me, she's trying to get away from me because...
# ...I think she actually poisoned me when I was 4 years old and she had to bring me to Medicall.
#
# I felt like I had the WORST CASE of CONSTIPATION IN THE WORLD, and truly felt like was going to 
# die. I was SO SICK and she had to spend like $50 for me to be seen, I found the returned check she
# wrote and the doctor bill.

# But- I survived. When I was going through all of the stuff in the box of documents in 2020 from
# the old desk, I found the receipt, along with the Dr. Kite appointment card with 785-3221 Jesse 
# Pickett. I told her that I think she poisoned me. The WAY in which she snatched the documents I
# was looking at sorta gave me the impression that she probably fuckin' did. 
# 
# My mother seemed EXACTLY LIKE THIS RECORDING, with the YELLING/SCREAMING, even THEN when I was 10.
# So, the theory seems PLAUSIBLE to me in these moments, where she's just walking away from me.

# If she DID have something to do with my dad being killed...
# She obviously didn't do it alone.
# I think my Aunt Terri helped her, if she did.
#
# Because I remember how Terri picked me up from my aunt Debbie Brozowski's house on Lasher Road 
# on the day my father was killed. Then, I was at Terri's house for a few days, I remember being
# in the Daniel Keegan Funeral Home for the wake, when Alex Philipsak and his dad showed up, and
# Principal Dr. Lewis, among many others. I'm not sure if it was his dad or his grandmother Vita...
# but I remember him showing up. 
#
# I also remember the drive from THERE on the day of the funeral, to Calvary Cemetery where he was
# buried. I remember the dozens of cabs that followed us the whole way, driving past 200 McCarty Ave,
# down 9W, past the Petrol station, and... the poem my cousin Shawn wrote, the YakBak that I left
# in his coffin, and the last time I'd ever see his face ever again, covered with makeup. I remember
# going to the church off of 9W in Glenmont right down the road from Lasher Road, for the post
# funeral services. 
# 
# Here's the thing... I didn't do anything to hurt my mother in this incident.
# I didn't do anything to deserve being almost killed on May 26th, 2020 EXCEPT FOR...
# ...stumbling onto probably the biggest story of the century. Surveillance Capitalism, allows some
# people to be able to watch everybody else, and make up the rules as to how rich they get to be, how 
# poor everyone else is, who's OWNED as a product, and that if you have a cool idea, it will be taken
# and someone else will become very rich off of it, just like what happened with Nikola Tesla.
#
# As for my mother...? What she decided to say to me, AND, the way she acted, AND, what she reported to
# the police, tells me that there's something fucked up going on in my mother's head. She lied to the
# police, and she made NO MENTION that I accused her of having my father killed.
# 
# That accusation was the fucking reason why I grabbed her wrists and had to restrain her against 
# the wall until she calmed the fuck down. I didn't have her in a headlock, I had her wrists pinned 
# against the wall. For somebody who CLAIMED over and over again that I was "hurting her", she didn't
# need any medical assistance. The truth is, the reason I was trying to restrain her is because I wanted
# an answer, because I DO think she saw a way to get $50K and then wipe her hands clean of my father.
# 
# I wasn't trying to hurt her at all. Hell, I didn't even tighten my grip on her I just had her wrists 
# against the wall, in front of her face, and she had been doing ALL of this LONG before she denied 
# conspiring to kill my father. I mean, that's just it... if she had nothing to do with it, why constantly
# run away, or be evasive...? She made NO MENTION OF IT TO THE TROOPER. That SHOULD BE A BIG RED FLAG.
# 
# On top of that, she made NO MENTION of the MULTIPLE DIALOGUES she and I had regarding the Saratoga 
# County Sheriffs Office butchering up tickets.
#
# Lastly...? I never SAY anything about people in the trailer park conspiring to kill me. Nah.
# I really hope somebody reads this, looks at her statement, and listens to the audio recording, 
# because there's something really fucked up happening in all of them. 
