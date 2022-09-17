#  _____________________________________________________________________________________________  
# //¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\ 
# || Call for Service [SCSO-2022-064539]                                                       || 
# || Audio recording of the entire interaction between me and the                              || 
# || SARATOGA COUNTY SHERIFFS OFFICE on: 09/16/2022                                            || 
# || https://drive.google.com/file/d/1tfiupbdhTcFz0fXcgfxykDFW2d5w1Wyb                         || 
# || To SUMMARIZE the CONTENT of this RECORDING...?                                            || 
# || KATHERINE SUCHOCKI AUTHORIZED AN ARREST WARRANT WITH NO EVIDENCE OF ME COMMITTING A CRIME || 
# || NO EVIDENCE means, just "testimony", in a fucking SUPERMARKET with HUNDREDS OF CAMERAS.   || 
# || COOL...? This lady had me arrested for an incident on 08-05-2020...?                      || 
# || Dwayne Coonradt at COMPUTER ANSWERS steals HARD DRIVES from CUSTOMERS DEVICES as well as  || 
# || SOFTWARE from SOFTWARE DISTRIBUTORS...? Yeah.                                             || 
# || I actually HAVE EVIDENCE THAT HE DOES THAT. It's called a BACKUP of a HARD DRIVE from     || 
# || COMPUTER ANSWERS ZALMAN DRIVES that CONTAINS HACKING TOOLS to HACK WINDOWS ACTIVATIONS.   || 
# || Wanna know who gives a shit about that...? NOT KATHERINE SUCHOCKI. Cool.                  || 
# \\___________________________________________________________________________________________// 
#  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  
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
    [String]       $Name
    [DateTime]    $Start
    [DateTime]      $End
    [TimeSpan] $Duration
    [String]        $URL
    [Object]      $Party
    [Object]     $Output
    Transcription([String]$Name,[String]$End,[String]$Length,[String]$URL)
    {
        $This.Name     = $Name
        $This.End      = [DateTime]$End
        $This.Duration = [TimeSpan]$Length
        $This.Start    = $This.End-$This.Duration
        $This.URL      = $URL
        $This.Party    = @( )
        $This.Output   = @( )
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

Class TranscriptionFile
{
    Hidden [Object] $App
    Hidden [Object] $Root
    [String] $Name
    [String] $FullName
    [Object] $Date
    [UInt32] $Size
    [String] $SizeMB
    #[UInt32] $Channels
    #[UInt32] $SampleRate
    #[String] $Precision
    #[Object] $Duration
    #[Object] $Samples
    #[Object] $CDDASectors
    #[String] $FileSize
    #[String] $BitRate
    #[String] $Encoding
    [Object] $Start
    [Object] $End
    TranscriptionFile([Object]$Com)
    {
        $This.Name        = $Com.Name
        $This.Fullname    = $Com.Path
        $This.Date        = $Com.ModifyDate
        $This.Size        = $Com.Length
        $This.SizeMb      = "{0:n3} MB" -f ($Com.Length/1MB)
        #$This.Channels    = $Sx[1]
        #$This.SampleRate  = $Sx[2]
        #$This.Precision   = $Sx[3]
        # $Tx               = $Sx[4] -Split " = "
        # $This.Duration    = [Timespan]$Tx[0]
        #$This.Samples     = $Tx[1]
        #$This.CDDASectors = $Tx[2]
        #$This.FileSize    = $Sx[5]
        #$This.BitRate     = $Sx[6]
        #$This.Encoding    = $Sx[7]
        #$This.Start       = $Com.LastWriteTime-$This.Duration
        #$This.End         = $Item.LastWriteTime
    }
}

Class ComFile
{
    Hidden [Object]       $Com
    Hidden [String]   $DevPath
    [String]             $Type
    [DateTime]  $LastWriteTime
    Hidden [Int64]     $Length
    [String]             $Size
    Hidden [String]    $Parent
    Hidden [String] $Extension
    [String]             $Name
    [String]         $Fullname
    [UInt32]            $Count
    ComFile([Object]$Com)
    {
        $This.Com           = $Com
        $This.DevPath       = $Com.Path
        $This.Type          = "File"
        #$This.LastWriteTime = [DateTime]$This.Detail(3)
        $This.Size          = $This.Detail(2)
        #$This.GetSize()
        #$This.Parent        = $Parent
        $This.Extension     = ($Com.Type -Split " ")[0].ToLower()
        $This.Name          = "{0}.{1}" -f $Com.Name, $This.Extension
        $This.Fullname      = "{0}\{1}" -f $This.Parent, $This.Name
    }
    [Object] Detail([UInt32]$Var)
    {
        Return $This.Com.Parent.GetDetailsOf($This.Com,$Var)
    }
    [UInt64] GetSize()
    {
        $Swap = Switch -Regex ($This.Size)
        {
            Default { " " } bytes { " bytes" }

        }
        
        Return $This.Size -Replace $Swap,"" | Invoke-Expression
    }
}

Class Shell
{
    Hidden [Object]      $App
    Hidden [Object]     $Root
    Hidden [Object]      $Com
    Hidden [String]  $DevPath
    [String]            $Type
    [DateTime] $LastWriteTime
    [Int64]           $Length
    Hidden [String]   $Parent
    [String]            $Name
    [String]        $Fullname
    [Object]            $Item
    [UInt32]           $Count
    Shell([String]$Path)
    {
        If (!(Test-Path $Path))
        {
            Throw "Invalid path"
        }

        $This.Fullname      = $Path
        $This.App           = New-Object -ComObject Shell.Application
        $This.Root          = $This.App.Namespace($Path)
        $This.Com           = $This.Root.Self
        $This.DevPath       = $This.Com.Path
        $This.Type          = @("File","Folder")[[UInt32]$This.Com.IsFolder]
        $This.LastWriteTime = $This.Com.ModifyDate
        $This.Length        = $This.Com.Size
        $This.Parent        = $This.Fullname | Split-Path -Parent 
        $This.Name          = $This.Com.Name
        #$This.Item          = $This.GetChildItem()
        #$This.Count         = $This.Item.Count
    }
    [Object] NewFile([Object]$Root,[String]$Parent,[Object]$Object)
    {
        Return [ComFile]::New($Root,$Parent,$Object)
    }
    [Object] GetChildItem()
    {
        Return @( $This.Root.Self.GetFolder.Items() | % { $This.NewFile($This.Parent,"",$_) } )
    }
}

$path         = "C:\Users\mcadmin\Documents\Recordings"
$Base         = [Shell]::new($Path)


$shell        = New-Object -ComObject Shell.Application

$Properties   = @(0,1,2,12,13,14,15,16,17,18,19,20,21,22,27,28,36,220,223) # How THOMAS EDISON thought to do everything in life
$Properties   = @(0..2+12..22+27,28,36,220,223)                            # How NIKOLA TESLA thought to do everything in life
                                                                           # See the difference...? 
                                                                           # THOMAS EDISON was fuckin' lazy.
                                                                           # NIKOLA TESLA was a genius.
                                                                           # Did THOMAS EDISON develop ALTERNATING CURRENT...?
                                                                           # Nah. He developed DIRECT CURRENT, which was SLOWER,
                                                                           # MORE EXPENSIVE, A WASTE OF EVERYONES TIME AND MONEY...
                                                                           # And then NIKOLA TESLA said "Here, let an expert show you how it's done."
                                                                           # About 90 years later, everyone on the planet uses ALTERNATING CURRENT...
                                                                           # Localized power sources use DIRECT CURRENT, such as COMPUTERS and stuff.
                                                                           # But the POLICE OFTEN THINK EXACTLY LIKE THOMAS EDISON.
                                                                           # Not like NIKOLA TESLA


$Details      = $Properties | % { $ObjDir.GetDetailsOf($ObjDir, $_) }

$Base   = [Shell]$Path

$Base.Com.GetFolder.Items() | ? Name -match 2022_09_16_12_52_40 

$Start  = [DateTime]"09/16/2022 12:52:40"
$Length = "02:35:33"
$End    = $Start+[TimeSpan]"02:35:33"

$T = [Transcription]::New("Walmart/Katherine Suchocki order SCSO to arrest me with NO EVIDENCE","09/16/2022 15:28:13","2:35:30")
$T.AddParty("Michael C. Cook Sr.")
$T.AddParty("Michael Sheradin")
$T.AddParty("Clayton Brownell")
$T.AddParty("Michael Whiteacre")
$T.AddParty("SCSO VARIOUS")

# (00:00:00 -> 00:07:59) # Part 1 - Outside (Being arrested via COMPLAINT with NO EVIDENCE PROVIDED)
#                          "You're aware that there's no surveillance in that aisle" <- You have to PROVE that, not ASSUME that.
#                          "You walked out of the store, and then went back into the store, went back to the aisle, and then pointed at where you left it."
#                          Nah. "Did anyone SEE that...?" Nah. Nobody SAW that at all. Which means that I left the item in that aisle when the guys
#                          from "loss prevention" pointed at me. Oh. So that's how I know that the LAW MEN and WALMART are CUTTING CORNERS.
#                          AKA, violating my rights as a CITIZEN and MAKING ASSUMPTIONS about what was NOT SEEN BY ANYBODY.
#                          What I can state with sheer certainty, is that there IS VIDEO FOOTAGE THAT CLEARLY SHOWS THAT NOBODY WENT BACK TO THAT AISLE 
#                          BEFORE STOPPING ME IN THE VESTIBULE. Ohhhhhhhhhhh. Shit. Nobody at Walmart Loss Prevention went back to that fucking aisle.
#                          Weird. 
# (00:07:59 -> 00:28:11) # Part 2 - Within (SEDAN 4138/SCSO Michael Sheradin)
# (00:28:11 -> 00:28:35) # Part 3 - Walking into Halfmoon Town Court
# (00:28:35 -> 01:03:56) # Part 4 - Michael Sheradin processes my "arrest" order
# (01:03:56 -> 01:17:58) # Part 5 - Michael Sheradin processes my fingerprints but needs some help
# (01:17:58 -> 01:30:48) # Part 6 - Michael Sheradin finalizes processing my arrest
# (01:30:48 -> 01:33:07) # Part 7 - Michael Sheradin issues paperwork, then grabs my belongings from his cruiser. (which was left running that whole time, by the way.)
# (01:33:07 -> ) # Part 8 - I provide an OFFICIAL COMPLAINT to MICHAEL SHERADIN, that is to be ATTACHED to (SCSO-2020-028501 05/26/20 0130-0155)

# [Part 4]
# 00:51:25 -> 
# 00:52:22 -> MICHAEL SHERADIN CONFIRMS THAT HE WAS ORDERED TO ARREST ME (later says, do you have any idea how fuckin' stupid that sounds...?)
# 00:52:59 -> I cannot answer that question because I was not there at the time that this happened, so...
# 00:53:03 "But uh, you weren't at Walmart at the time they made this complaint."
# 00:53:10 "Correct. I was." <- Michael Sheradin says "Correct", but has it backwards. What I just said was INCORRECT, and he said CORRECT.
# 00:53:29 -> 
# 00:58:14 "What's your- *ahem* What's your social security number...?"
# 00:58:19 - 58:24 -> insert silence

# [Part 5]
# 01:04:05, 1, "C'mon over here"
# 01:04:06, 0, "So, if I run into a billionaires knife and get it all bloody, you're gonna arrest me for that."
# 01:04:12, 1, "Do what now...?"
# 01:04:14, 0, "If I run into a billionaires bloody knife, and get myself injured badly, you guys are gonna arrest me for that."
# 01:04:23, 1, "Why would we arrest you for that...?"
# 01:04:25, 0, "I'm trying to make a comparison or a metaphor. What you're doing right now is not too different from what I just said."
# 01:04:49, 0, "OJ Simpson can kill Ron Goldman and his, and uh- Nicole Simpson, and can commit a heinous crime"

# [Part 7 - Start 01:33:07]
# 01:57:12, 3, *enters the Halfmoon Sheriff Substation* (<- timing seems PRETTY FUCKING COINCIDENTAL)
# 01:57:14, 0, "Michael Whiteacre" 
# 01:57:35, 0, "Scott was looking for any reason-"
# 01:58:35, 3, *Interrupts me, UNINTELLIGIBLE
# 01:58:37, 0, "No."
# 01:58:38, 3, "Oh. Mike, you've already told all of us this."
# 01:58:40, 0, "Right."
# 01:58:41, 3, "What are you looking to do...?" (<- PROSECUTE YOUR ORGANIZATION, that's what I'm looking to do. Ya know...?)
# 01:58:44, 0, "Well..." (<- It should be pretty fuckin' obvious what I'm lookin' to do, buddy. Ya know...?)
# 01:58:45, 4, *Multiple officers enter the office*
# 01:58:46, 3, "Cause we all, like I've read your notes, multiple times that you've left on buildings..."
# 01:58:51, 3, "I'm not sure what else we can do for ya." (<- Give me $300M when I file a lawsuit against SCSO, and some officers go to prison.)
# 01:58:54, 3, "Don't you think-"
# 01:58:55, 0, "<Interrupts M. Whiteacre> The case that I'm trying to make here is that uh-"
# 01:58:57, 0, "Uh, I think there are some dirty officers on your unit."
# 01:59:02, 3, "<Knife sound> You've made that aware, you've made us aware of that." 
# 01:59:04, 0, "Right."
# 01:59:05, 0, "Well, I'm getting in trouble at Walmart for something I didn't do, people are fabricating things and I'm getting arrested for it."
# 01:59:15, 0, "And then when something happens to ME, then I tell the story, and it is heard, and <NO ACTION IS TAKEN>" (<- INDICATES PREJUDICE)
# 01:59:22, 0, "So, what I'm noticing is that the <END RESULT> is, THIS GUY (MICHAEL SHERADIN) IS WRITING DOWN INFORMATION, and I believe that the-"
# 01:59:30, 0, "and I believe that the event has something to do with the-"
# 01:59:32, 3, "This is like a FEW YEARS AGO" (<- I know buddy, that's why you should probably remain silent, cause it shows how LAZY YOUR OFFICE IS.)
# 01:59:34, 0, "Right." (<- I'm basically insulting this dude by AGREEING with his statements.)
# 01:59:35, 0, "Well, what happened was, is that you showed up on June 19th with Mark Sheehan..."
# 01:59:41, 3, "Yep."
# 01:59:41, 0, "Uh, well, I specified that uh, NFRASTRUCTURE was involved in THAT event right there"
# ________________________________________________________________________________________________________________________________
# | 07/21/89 | 785-3221 JESSE PICKETT | https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2021_0414-(Jesse%20Pickett).pdf |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 01:59:47, 3, "Yep, I'm aware <that I was TOO LAZY to collect the EVIDENCE you just posted right there and then LAURA HUGHES 
#               wrote a letter of indication that led to you losing custody of your children>. I <fuckin' DEFINITELY> remember that."
# 01:59:53, 1, "Is this the truth...?"
# 01:59:53, 3, "This- this was like, a couple years ago..." (<- Indicates that IN HIS OPINION, his failure to collect evidence that
#              directly links the former owners of NFRASTRUCTURE to ESPIONAGE TOOLS is really NOTHING to be TOO concerned with,
#              whereby downplaying the SEVERITY of MICHAEL WHITEACRE's LAZINESS to COLLECT EVIDENCE and stuff like that. Ya know...?)
# 01:59:54  1, "Oh."
# 01:59:54, 0, "Yeah."
# 01:59:55, 3, "Well THIS was, yeah."
# 01:59:57, 0, "I was dragged through the mud regarding custody of my children, 
# 01:59:59, 0, "I was accused of stuff at Family Court..."
# 02:00:01, 0, "And then people played games with me at family court."
# ________________________________________________________________________________________________________________________________
# | 08/18/20 | Email to HEATHER COREY-MONGUE                                                                                     |
# |          | https://github.com/mcc85s/FightingEntropy/blob/main/Records/2022_0818-(Heather%20Corey-Mongue%20Email).pdf        |
# | 02/01/21 | Family Court (Appearances off by 5 hours)   | https://drive.google.com/file/d/1lxynSuFw8S4qMtMusEkB4SK4CDvIh1s9   |
# | 04/06/21 | Weiner + Schellinger + Pelagalli being lazy | https://drive.google.com/file/d/1CYflcm7kEawNP2jz_osXmtMJF1KL06Uc   |
# | <See how I collected this shit called EVIDENCE...? Try it sometime Mr. Whiteacre. You might not SOUND like a careless moron. |
# | "I've read your notes multiple times, had a dildo in my asshole, and did nothing about those notes I read multiple times..." |
# | That's how you sound. Ya know...? Dildos being in one's asshole is a METAPHOR for YOU not doing YOUR fucking job. So...      |
# | Shut the fuck up, and stop interrupting me and Michael Sheradin. Thanks.                                                     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:00:04, 0, "They didn't send me uh- my APPEARANCES with the CORRECT TIME, so..."
# 02:00:12, 0, "What I'm suggesting is that uh, <you're fuckin' LAZY bruh =)>..."
# 02:00:14, 0, "I believe that THAT event was RELATED to my fathers murder in 1995 <Me, doing Michael Whiteacre's job, since he's not doing it>"
# 02:00:19, 1, "Ok."
# 02:00:19, 0, "And then MICHAEL WHITEACRE wrote a report about how he was showing up because OLIVER ROBINSON made a complaint, uh-"
# _____________________________________________________________________________________________________________________________________
# | I had SUBMITTED this thing called a fuckin' TICKET, for a MOBILE HOTSPOT, so like my CHILDREN, could like, do their SCHOOLWORK... |
# | ...with this person called the RECEPTIONIST, who was at the FRONT DESK, of 5 CHELSEA PLACE, cause I went to IMS on the CAMPUS...  |
# | ...and I kept getting some fuckin' MORONS pointing me in directions to do stuff I couldn't do.                                    |
# |-----------------------------------------------------------------------------------------------------------------------------------|
# | IMS : Sign into the account and submit a ticket.                                                                                  |
# | Me  : Can't, cause I don't have the device.                                                                                       |
# | IMS : Ok, GO GET THE DEVICE and come back.                                                                                        |
# | Me  : Fine.                                                                                                                       |
# | <I go get the device and come back.>                                                                                              |
# | Me  : Here, I have the device.                                                                                                    |
# | IMS : We're closed now, you're gonna have to fuck off, and come back tomorrow.                                                    |
# | Me  : Ya know, that's pretty rude...                                                                                              |
# | IMS : Oh well, dude. I have a dildo I have to get to, alright...? So, grow up.                                                    |
# | Me  : I am trying to get INTERNET ACCESS so my kids can do their schoolwork.                                                      |
# | IMS : *checks watch* Dildo time is more important. Come back tomorrow.                                                            |
# |-----------------------------------------------------------------------------------------------------------------------------------|
# | In hindsight, I didn't realize how RUDE I was being, walking back and forth to the IMS office on campus, to get my kids internet. |
# | To do their schoolwork and shit. Ya know...? The school resource officer, Mr. Muller directed me to go there...? But- MAYBE...    |
# | MAYBE... I was RUDE in the WAY that I WALKED TO THE SCHOOL CAMPUS MULTIPLE TIMES... And that means...? No help.                   |
# | So, that's when I went to the fuckin' DISTRICT OFFICE and SUBMITTED A TICKET FROM THERE. And, then I later GAVE THAT NUMBER TO    |
# | OLIVER ROBINSON and his ASSISTANT, and WHEN I GAVE THEM THAT NUMBER, that woman IMMEDIATELY exited the CONFERENCE ROOM...         |
# | And I believe that she DELETED THAT TICKET. IF SHE DIDN'T...? Then, THAT is the EVIDENCE that MICHAEL WHITEACRE should GO BACK IN |
# | TIME, to CORRECT the fucking job that he did INCORRECTLY. Ya know? "This was a COUPLE YEARS AGO" (<- indicates how lazy he is)    |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:00:26, 0, "What Michael Whiteacre wrote on the REPORT <SCSO-2020-003688> is that, the reason he was at my house was UNRELEATED to the CPS case."
# 02:00:33, 0, "But it fucking definitely WAS related, and he wasn't aware of it."
# 02:00:40, 0, "So, what I have come to determine is that I have to be pretty ADAMANT about the story..."
# 02:00:45, 0, "...because SOMEBODY might have their FACTS incorrect, and then walk in, and ask questions like..."
# 02:00:53, 0, "...why are you talking about a case from a couple years ago, so..."
# 02:00:54, 3, "Ok." (<- Michael Whiteacre admitting that I'm openly insulting his [integrity/due-diligence] to his face.)
# 02:00:56, 0, "So..."
# 02:00:56, 3, "Alright." (<- Making an admission that he might've fucked up after all. Sounds IDENTICAL to JUDGE PELAGALLI on 4/6/21.)
# 02:00:58, 0, "The reason why uh, I'm talking about it with you right now, is because..."
# 02:01:01, 0, "Uh- like I said, I believe that my AUNT TERRI was INVOLVED with the MURDER ATTEMPT on MAY 26th, 2020, and SO WAS SCOTT SCHELLING"
# 02:01:13, 0, "Because THAT RECORD (SCSO-2020-028501) indicates that uh, SCOTT SCHELLING had me in custody along with JEFFREY KAPLAN"
# 02:01:24, 0, "AND WROTE NO NOTES ABOUT THE INTERACTION."
# 02:01:26, 3, "Ok."
# 02:01:27, 0, "...and then, uh, I had a FEELING that SCOTT SCHELLING was gonna do something BAD to me, and..."
# 02:01:33, 0, "when he offered me this ULTIMATUM, either I arrest you and bring you to the JAIL with THIS DEVICE right here that I had evidence of calling 911 on..."
# 02:01:44, 0, "Or... you can... allow ME to bring you home."
# 02:01:52, 3, "Mike, when you told ME about this, didn't I tell you to go to the supervisor...?"
# _________________________________________________________________________________________________________________________________________
# | Yeah, I went and spoke to JOSHUA WELCH, and when I did, he told me the incident number for 05/23/20 SCSO-027797 which was the         |
# | WRONG INCIDENT, THAT was related to the INCIDENT where SCOTT SCHELLING responded to a CALL FROM ROTTERDAM POLICE.                     |
# | It is STRANGE how STRATTON AIR NATIONAL GUARD would GO RIGHT AHEAD... and call the ROTTERDAM POLICE... ya know...? Weird.             | 
# | ME -> NOT IN ROTTERDAM -> IN SCOTIA -> AT STRATTON AIR NATIONAL GUARD AT LIKE 11 or 12 o'clock -> TOLD THEM ABOUT AUDIO I RECORDED -> |
# | ROTTERDAM POLICE CALLS SCSO -> SCSO SENDS SCOTT SCHELLING TO MY HOUSE -> SCOTT SCHELLING WRITES DOWN MOM'S LICENSE PLATE -> FUCKS OFF |
# |---------------------------------------------------------------------------------------------------------------------------------------|
# | 02/02/21 | CAPT. JEFFREY BRON | https://drive.google.com/file/d/1JECZXhwpXFO5B8fvFnLftESp578PFVF8                                     |
# |---------------------------------------------------------------------------------------------------------------------------------------|
# | Yeah, so what MICHAEL WHITEACRE doesn't realize, is that I've had to CHASE THIS FUCKING RECORD DOWN and basically INTERROGATE CAPT.   |
# | JEFFREY BROWN, who's like, above ALL these guys... including JOSHUA WELCH. Not that JOSHUA WELCH was UNHELPFUL, because he told me... |
# | "Yeh, I remember, that incident in front of Zappone, I was there." (<- That's how I obtained this RECORD that wasn't in my RECORDS    |
# | request. Ya know...? Basically, IN ORDER FOR ME TO HAVE THE FUCKING RECORD, SCSO-2020-028501...? I HAD TO DO MICHAEL WHITACRES JOB.   |
# | I ALREADY SUBMITTED A RECORDS REQUEST WAY BACK ON 09/04/20 and it DID NOT HAVE THE FUCKING RECORD I WAS LOOKING FOR. Cool..? Cool.    |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:01:53, 0, "I did." (<- It's [hard/impossible] to condense those boxes ABOVE into a single 2 second statement, without causing CONFUSION.)
# 02:01:54, 3, "Ok, cause there's NOTHING WE CAN DO about that." (<- I disagree, there certainly is, buddy. You're gonna find out the hard way.)
# 02:01:58, 0, "Well, I think this guy CAN do something about it."
# 02:01:59, 1, "Well, I told ya I'd look into it, and see what the deal was, but yeah."
# 02:02:02, 3, "Did you reach out to, I believe it was SGT WELCH at the time...?"
# 02:02:05, 0, "Yes." (<- mentioned in the box above, it's how I got the record for the ZAPPONE DEALERSHIP incident.)
# 02:02:06, 3, "Did you reach out to him...?"
# 02:02:06, 0, "I did. So, uhm..."
# 02:02:12, 0, "Allow me collect my thoughts here, uh-" 
# _________________________________________________________________________________________________________________
# | I had no way to compress all of that into a single statement. I was thinking of all this shit above.          |
# | MICHAEL WHITEACRE's questions DISTRACTED me, so I was unable to make the CORRELATIONS and provide             | 
# | my step-by-step guide on: How to perform PROPER (LAW ENFORCEMENT/INVESTIGATION).                              |
# | It's why I wrote this thing called a BOOK. I did mention that I wrote this thing called a BOOK...             |
# | Ya know...? A BOOK is a LOT MORE than just some NOTES... It's like a 750-fucking-page BOOK.                   |
# |---------------------------------------------------------------------------------------------------------------|
# | Top Deck Awareness - Not News - Used to be news...? Now it's Not News. Not News. Part of the Not News Network |
# | https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2022_0823_TDA_Not_News.pdf                           |
# |---------------------------------------------------------------------------------------------------------------|
# | Ya know, I mean, maybe MICHAEL WHITEACRE should like, read that fuckin' book sometime... it's FREE.           |
# | I know that 750 pages is a lot to read...? But, I made damn certain to make it (INTERESTING/ENTERTAINING).    |
# | Cause, that'd be SOMETHING he could like, DO... ya know...?                                                   |
# |---------------------------------------------------------------------------------------------------------------|
# | 1) Read a book sometime.                                                                                      |
# | 2) Learn how to perform law enforcement correctly.                                                            |
# | 3) Discover that I outperform people at being intelligent quite often.                                        |
# | 4) Stop providing resistance.                                                                                 |
# | 5) Prepare to write me a check for $300M when I file a lawsuit against SCSO.                                  |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:02:26, 1, "Let me look into this, and I'll check with Sergeant Welch, he'll back probably Monday or Tuesday..."
# 02:02:33, 0, "In reference to what happened that night, I did follow up with Sergeant Welch a couple times." (It's how I obtained records.)
# 02:02:39, 1, "Yep."
# 02:02:42, 0, "The case that I'm making here, is that uh- I suspected FOUL PLAY with SCOTT SCHELLING cause he said something..."
# 02:02:46, 0, "...that he would've ONLY KNOWN... if he had a tap into my phone." (<- ESPIONAGE with PEGASUS)
# 02:02:50, 1, "Ok."
# 02:02:51, 0, "So I mentioned something to you EARLIER, I won't repeat that, but-"
# 02:02:58, 0, "I asked JEFF- I asked- uh, when SCOTT SCHELLING made this uh- ULTIMATUM,"
# 02:03:04, 0, "Either I arrest you and bring you to the jail, with this device that has your 911 calls on it..."
# 02:03:08, 0, "or... I bring you home."
# 02:03:11, 0, "and, when I said 'Well, if you're gonna bri- if you're gonna give me an ULTIMATUM, uh-'"
# 02:03:15, 0, "'how about THIS GUY, JEFFREY KAPLAN follow you...?'"
# 02:03:17, 0, "Well, uh- JEFFREY KAPU- JEFFREY KAPLAN, followed SCOTT SCHELLING TO my house,"
# 02:03:24, 0, "So there's a SECONDARY LOCATION on THAT INCIDENT, and, THAT INCIDENT was LEFT OUT OF MY RECORDS REQUEST."
# 02:03:31, 0, "I submitted a FOIL REQUEST for ALL OF THE RECORDS I WAS INVOLVED IN between MAY 19th (2020)..."
# 02:03:36, 0, "...and SEPTEMBER 4th (2020)"
# 02:03:38, 0, "So I was able to obtain the record that HE WAS INVOLVED IN, 1 or 2 of them, uh, as well as uh, the record with uh,..."
# 02:03:47, 0, "The ONE record that I wanted the MOST, was THAT ONE RIGHT THERE, and..."
# 02:03:53, 0, "...when I got it I realized that there were NO NOTES attached to it, and uh-"
# 02:03:58, 0, "What I'm noticing is that if I try to call 911 a couple times, and it doesn't make it to the DISPATCH STATION, oh well."
# 02:04:04, 0, "There was a CRIME that was COMMITTED TO ME, but I REPORTED IT TO A POLICE OFFICER, and HE DID NOTHING ABOUT IT."
# ___________________________________________________________________________________________________________________________________
# | Well, he DID do something about it, and so did MICHAEL ZURLO.                                                                   |
# | They both committed OBSTRUCTION OF JUSTICE: DESTRUCTION OF EVIDENCE, and charged me with CRIMINAL MISCHIEF OF THE FOURTH DEGREE |
# | Pretty cool, huh...?                                                                                                            |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:04:07, 0, "And then, I suspected that the POLICE OFFICER in SPECIFIC, uh, HAD UH- SOME NEFARIOUS INTENT, and then..."
# 02:04:16, 0, "And then, when he brought me back to my house, JEFFREY KAPLAN was remained in HIS VEHICLE, uh-"
# 02:04:24, 0, "And then, SCOTT SCHELLING came (around his car) to let me OUT, and he ASKED ME MULTIPLE QUESTIONS."
# 02:04:28, 0, "The QUESTIONS that he asked me, (are in the book, CHAPTER - THE WEEK)", were..."
# 02:04:32, 0, "(Schelling) So you made 911 calls...?"
# 02:04:33, 0, "And I said 'Yes, if you GO TO CENTER FOR SECURITY, THEY SHOULD BE ABLE TO CORROBORATE THAT STORY or the EVIDENCE.'"
# 02:04:40, 0, "Well, uh... I think that SCOTT SCHELLING went there, and DESTROYED the evidence."
# 02:04:44, 0, "And then ALSO, uh- I told him that I UPLOADED THE AUDIO RECORDINGS AT COMPUTER ANSWERS and he seemed to be INCREDIBLY, uh..."
# 02:04:55, 0, "...CONCERNED about that. Cause I think that SOMEBODY had an AUDIO TAP to my phone."
# 02:05:05, 0, "And, I think that, uh- the REASON he never COLLECTED any of the EVIDENCE from my phone, uh-"
# 02:05:12, 0, "...indicates MALICIOUS INTENT. And that I think it was an ORDER FROM HIS SUPERVISOR." (<- not JOSHUA WELCH... MICHAEL ZURLO.)
# 02:05:18, 1, "Alright."
# 02:05:19, 0, "I have ALL OF THE EXHIBITS and the PICTURES, as well as uh, the DATE THEY WERE TAKEN..."
# 02:05:24, 1, "Can you get em on a THUMBDRIVE...?"
# _____________________________________________________________________________________________________________________
# | They are ALL in my book, Top Deck Awareness - Not News as well as a FILE on my GitHub project in a file named...  |
# | https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt                       |
# |-------------------------------------------------------------------------------------------------------------------|
# | The LAST SEVERAL ENTRIES of THAT PARTICULAR FILE, are the FILES that I (RECORDED/TOOK) immediately BEFORE the     |
# | MURDER ATTEMPT, [1597/1602 US-9] 05/25/20 2343 -> [1780 US-9] 05/26/20 0130. The VERY LAST ONE is the SCREENSHOT  |
# | of my 911 calls that FAILED TO MAKE IT TO THE DISPATCH STATION... So... Those were ALL UPLOADED IMMEDIATELY AFTER |
# | SCOTT SCHELLING DROPPED ME OFF AT THE SECONDARY LOCATION IN THAT TICKET, SCSO-2020-028501.                        |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 02:05:26, 0, "Hey, I have uh- (they're all in the book) an EVIDENCE LIST."
# 02:05:29, 0, "I can even give ya, I can write down my uh- GitHub project that's got all of this information."
# 02:06:00, 0, "So that's the SITE right there, there's a FOLDER on it that says EVIDENCE" (I meant RECORDS)
# 02:06:06, 0, "Now, some of the LANGUAGE in some of my DOCUMENTS, will... seem... PRETTY OFFENSIVE..."
# 02:06:14, 0, "I'm gonna come right out and say that, "
# 02:06:14, 1, "Is this 'THUB'...?"
# 02:06:17, 0, "Yes."
# 02:06:24, 1, "... dot com, EM SEE SEE EIGHT ESS ESS"
# 02:06:28, 0, "EM SEE SEE EIGHT FIVE ESS"
# 02:06:34, 1, "Ok, it's FRIGHTNING ENTROPY"
# 02:06:36, 0, "Yep- uhm, FIGHTING ENTROPY, capital EFF, if you don't use the capital letters, it won't get to it, but uh-"
# 02:06:44, 1, "Ok."
# 02:06:45, 0, "I can uhm, I could always EMAIL it to you, too, if you want."
# 02:06:49, 1, "I'll go in there and take a look... and gonna hurt." (<- It won't hurt YOU, it'll probably hurt someone's CREDIBILITY, though.)
# 02:06:52, 0, "So, in uhm- on that website there's a FOLDER that says EVIDENCE (<- I misspoke, it's not EVIDENCE, it's called RECORDS)"
