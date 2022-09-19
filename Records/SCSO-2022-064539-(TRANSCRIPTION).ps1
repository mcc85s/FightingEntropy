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
    [Object]       $File
    [String]      $Title
    [DateTime]    $Start
    [DateTime]      $End
    [TimeSpan] $Duration
    [String]        $URL
    [Object]      $Party
    [Object]     $Output
    Transcription([Object]$File,[String]$Title,[String]$URL)
    {
        $This.Name     = $File.Name
        $This.File     = $File
        $This.Title    = $Title
        $This.Start    = $File.Start
        $This.End      = $File.End
        $This.Duration = $File.Duration
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
    AddEntry([UInt32]$Index,[Object]$Position,[String]$Note)
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
    Hidden [Object]       $App
    Hidden [Object]      $Root
    [String]             $Name
    [String]         $FullName
    [DateTime]           $Date
    Hidden [UInt64] $SizeBytes
    [String]             $Size
    [UInt32]         $Channels
    [UInt32]       $SampleRate
    [String]        $Precision
    [Object]         $Duration
    [Object]          $Samples
    [Object]      $CDDASectors
    [String]         $FileSize
    [String]          $BitRate
    [String]         $Encoding
    [Object]            $Start
    [Object]              $End
    TranscriptionFile([Object]$Com)
    {
        $This.Name        = $Com.Name
        $This.Fullname    = $Com.Path
        $Item             = Get-Item $This.Fullname
        $This.Date        = $Item.LastWriteTime
        $This.SizeBytes   = $Item.Length
        $This.Size        = "{0:n3} MB" -f ($This.SizeBytes/1MB)

        Set-Alias sox "C:\Program Files (x86)\sox-14-4-2\sox.exe"
        $Sx               = sox --i $Item.Fullname | ? Length -gt 0 | % Substring 17
        $This.Channels    = $Sx[1]
        $This.SampleRate  = $Sx[2]
        $This.Precision   = $Sx[3]
        $Tx               = $Sx[4] -Split " = "
        $This.Duration    = [TimeSpan]$Tx[0]
        $This.Samples     = $Tx[1]
        $This.CDDASectors = $Tx[2]
        $This.FileSize    = $Sx[5]
        $This.BitRate     = $Sx[6]
        $This.Encoding    = $Sx[7]
        $T                = [Regex]::Matches($Item.Name,"^\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}").Value -Split "_"
        $This.Start       = [DateTime]("{0} {1}" -f ($T[0..2] -join "/"), ($T[3..5] -join ":"))
        $This.End         = $This.Start+$This.Duration
    }
    [Object] Detail([Object]$Com,[UInt32]$Var)
    {
        Return $Com.Parent.GetDetailsOf($Com,$Var)
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
        $This.Item          = @($This.Root.Self.GetFolder.Items())
        $This.Count         = $This.Item.Count
    }
    [Object] GetChildItem([String]$Name)
    {
        Return @( $This.Item | ? Name -match $Name | % { [TranscriptionFile]::New($_) } )
    }
}

$path         = "C:\Users\mcadmin\Documents\Recordings"
$Base         = [Shell]::New($Path)
$File         = $Base.GetChildItem("Treble")
$T            = [Transcription]::New($File,
                                     "Walmart/Katherine Suchocki order SCSO to arrest me with NO EVIDENCE",
                                     "https://drive.google.com/file/d/1tfiupbdhTcFz0fXcgfxykDFW2d5w1Wyb")
$T.AddParty("Michael C. Cook Sr.")
$T.AddParty("Michael Sheradin")
$T.AddParty("Clayton Brownell")
$T.AddParty("Michael Whiteacre")
$T.AddParty("SCSO VARIOUS")
$T.AddParty("E N V")

# (00:00:00 -> 00:07:59) # Part 1 - Outside (Being arrested via COMPLAINT with NO EVIDENCE PROVIDED)
$T.AE(0,"00:01",":Ok go ahead")
$T.AE(2,"00:01",":Ok, you're good...?")
$T.AE(0,"00:02",":Yeah.")
$T.AE(2,"00:02",":So... uh, we went back to the Walmart, and um... The guy, adamant, he saw you take these things, and he's adamant, he's signed a complaint saying that, uhm, you did. So, uh, we want to prosecute, uh, my partner got a warrant, and you're gonna have to go do a little bit of paperwork with him, and then you'll get an appearance ticket, and then you'll have to go back to court, and tell the court, basically, you know, that you DID steal it, and that you're, you know, you DID pass the point of purchase.")
$T.AE(0,"00:38",":Well I understand that, but- you know, uh- I gave him my story, I was pretty honest about it-")
$T.AE(2,"00:44",":I know, I'm not giving you any issue with it, that's why I'm telling you you're gonna be out here, we gotta, unfortunately we have to what we have to do, cause he filed a complaint sayin that you usually-")
$T.AE(0,"00:52",":Am I being arrested...?")
$T.AE(2,"00:53",":Yeah, you're gonna have to come with us... you'll go with my partner, we'll figure out your bike, I don't wanna lose your bike. Um, we'll figure that out for ya, alright?")
$T.AE(0,"01:01",":Is there an ULTERIOR MOTIVE for this...?")
$T.AE(2,"01:04",":No, there really isn't, Mike. You're gonna be out in, you're gonna be out in prolly, I dunno, half hour Mike...?") # <- Yeah there is. 
$T.AE(0,"01:09",":I understand that.")
$T.AE(2,"01:10",":A half hour, 45 minutes, give or take.")
$T.AE(0,"01:12",":However, uh- I think the story isn't matching up.")
$T.AE(1,"01:15",":The story, what...?")
$T.AE(0,"01:16",":I think the STORY isn't matching up.")
$T.AE(1,"01:20",":The stories are matching up...?")
$T.AE(0,"01:21",":No, what I'm suggesting is that I don't think the STORIES are matching up.") # As in, LAW ENFORCEMENT 101, COLLECT EVIDENCE OF A CRIME. NOT TESTIMONY. EVIDENCE.
$T.AE(2,"01:24",":Ok.")
$T.AE(1,"01:24",":Well, uh- I've got the- The story that I've got NOW, with the VIDEO EVIDENCE, is that...") # <- what video evidence...?
$T.AE(1,"01:29",":YOU went in there, and you took a mouse...")
$T.AE(0,"01:33",":Right. Two of em.")
$T.AE(1,"01:33",":and you went over in the toy aisle. Two of em, put one back or whatever you did with it, went over to the toy aisle, put one in your backpack-")
$T.AE(0,"01:44",":Uh- what- No.")
$T.AE(1,"01:44",":Ok, and then.")
$T.AE(0,"01:46",":Did YOU see that...?")
$T.AE(1,"01:47",":What...?")
$T.AE(0,"01:17",":Did you SEE me put-")
$T.AE(1,"01:47",":No, because you're well aware there's no camera coverage in there- but, hold on. Hold on...") # <- When I saw the WHITE KID POINTING AT ME from the HOUSEWARES area, I left the mouse in that aisle. I am ABSOLUTELY CERTAIN that they did NOT send a SINGLE PERSON to that aisle to LOOK for the item. But they had (2) dudes watching me. Hm. I wonder why that is.
$T.AE(0,"01:53",":I DO have, 2 loss prevention guys that DID see it, ok...?")
$T.AE(1,"01:58",":No.")
$T.AE(0,"02:00",":And then you started to exit the store, they stopped you in the vestibule, where there's video, you turned around and went BACK into the store, went BACK over to the toy aisle...")
$T.AE(1,"02:10",":I was showing them where it was.")
$T.AE(0,"02:11",":Put it back up there, and said 'There it is right there.'")
$T.AE(1,"02:13",":There's no video of that.")
$T.AE(1,"02:15",":Of you putting it back up there, cause there's no video in that aisle.")
$T.AE(0,"02:19",":No, its-")
$T.AE(1,"02:18",":But apparently they SAW you.")
$T.AE(0,"02:21",":But NO they DIDN'T.")
$T.AE(1,"02:21",":Alright.")
$T.AE(0,"02:22",":That's what I'm saying, is you might wanna look at the footage again.")
$T.AE(1,"02:24",":Ok, but THEY signed a complaint.")
$T.AE(0,"02:26",":I'm recording this interaction.")
$T.AE(1,"02:29",":That's fine, THEY signed a complaint, I put it in front of the judge...")
$T.AE(0,"02:32",":Ok.")
$T.AE(1,"02:33",":Ok, and the judge signed an arrest warrant.")
$T.AE(0,"02:35",":What is the judges name...?")
$T.AE(1,"02:37",":Suchocki.")
$T.AE(0,"02:38",":Katherine Suchocki.") 
$T.AE(2,"02:40",":Female judge here in town.") # <- Yeah, I just said her first name. I know who she is. She handled the DWAYNE O. COONRADT bullshit 911 call that went to his BUDDY who works as a 911 dispatcher. Oh shit.
$T.AE(1,"02:44",":We've got to arrest you, based on the JUDGES ORDER...")
$T.AE(0,"02:45",":Ok.")
$T.AE(1,"02:46",":The arrest warrant.")
$T.AE(0,"02:47",":Yup.") # <- A complaint with no evidence that I had the item IN the backpack. Just testimony.
$T.AE(1,"02:48",":Ok...? And again, all we're gonna do is process you, write you an appearance ticket so you can reappear in the court.")
$T.AE(0,"02:54",":Right.")
$T.AE(1,"02:55",":Then out the door you go.")
$T.AE(0,"02:58",":Ok.")
$T.AE(1,"02:59",":Ok...? So, you got TWO options here, you can ride your bike down there right now, and meet me, and we'll take care of it, or we can lock it to the guiderail here, you can come with me, and I'll bring you back.")
$T.AE(0,"03:16",":Guess I don't really have a-")
$T.AE(2,"03:16",":But you've got a bike lock, you can lock it right to your guardrail.")
$T.AE(0,"03:19",":I understand I don't have an option, so I'll leave it-") 
$T.AE(5,"03:20","*REMOTE PARTY MUTED THE MICROPHONE ON MY DEVICE")
$T.AE(5,"03:32","*REMOTE PARTY UNMUTED THE MICROPHONE ON MY DEVICE")
$T.AE(1,"03:33",":They signed the complaint, it's not me.")
$T.AE(0,"03:36",":Right, it's based on hearsay.")
$T.AE(2,"03:39",":Well, if you can prove that's erroneous...?")
$T.AE(0,"03:43",":Look, I've been trying to do that.")
$T.AE(2,"03:43",":I'm just sayin', if you can prove that's err-")
$T.AE(0,"03:44",":I have a- I been having a PATTERN")
$T.AE(2,"03:46",":Yeah, but listen-")
$T.AE(0,"03:47",":Remember July 14th, 2020 you came to my house and the group of people that I live near they had me wrapped around and they were like 'Oh, you're gonna go to jail for stealin' this lady's laptop', there's PREJUDICE from the community.")
$T.AE(2,"04:00",":And you DIDN'T, you DIDN'T do that, did I...? Did I take you to jail for that...?")
$T.AE(0,"04:03",":No, you didn't.") # <- The way you phrased it is as if you EXPECTED to take me to jail. That's PREJUDICE.
$T.AE(2,"04:04",":I didn't, right...? We talked about this.")
$T.AE(0,"04:05",":You're right.")
$T.AE(2,"04:05",":But listen, but listen-")
$T.AE(0,"04:04",":The statement I'm tryin' to make is that there are people in the community that have developed PREJUDICE toward me,")
$T.AE(2,"04:10",":Ok.") # <- ...that would include from YOU, which I didn't THINK that until I had to TRANSCRIBE this AUDIO...
$T.AE(0,"04:14",":And the- these guys are making this shit up.")
$T.AE(2,"04:15",":I understand, but can you listen to me for one minute...?")
$T.AE(0,"04:16",":Sure...")
$T.AE(2,"04:16",":Listen, if you can PROVE this is ERRONEOUS, not only will the charges be DISMISSED, you can go after WALMART, for, for uh, for wrongful prosecution, ok...?")
$T.AE(0,"04:26",":Ok.")
$T.AE(2,"04:28",":It's CIVIL. It's not CRIMINAL, but it's CIVIL. Ok...?")
$T.AE(0,"04:29",":Right...")
$T.AE(2,"04:30",":So... we can do that. We just have to do our job, because-")
$T.AE(0,"04:33",":Yeah, but I'm being charged with WHAT...?")
$T.AE(2,"04:35",":Petit Larceny.")
$T.AE(0,"04:36",":<Indiscernable due to passing traffic>")
$T.AE(2,"04:38",":Correct. You're not going to jail, you're not gettin' arraigned in front of a judge, today, (GARBLED WORD) of that. You're an appearance ticket, and you're gonna be on your way.") # <- I think Clayton Brownell may have an underlying mental condition because he said "You're an appearance ticket."
$T.AE(0,"04:39",":Yeah.")
$T.AE(2,"04:46",":Ok...?")
$T.AE(0,"04:48",":<Indiscernable due to passing traffic>")
$T.AE(2,"04:50",":<Indiscernable due to passing traffic> (Family court...?) <something>'s not available with this, anyways.")
$T.AE(0,"04:53",":Ok, I just")
$T.AE(2,"04:53",":So you don't even have to worry about that stuff.")
$T.AE(0,"04:55",":That's not what- I'm not really worried about this particular incid-")
$T.AE(2,"04:57",":Put it around your frame, buddy, so no one can take your bike.")
$T.AE(0,"05:00",":Yeah, I know, I'm just")
$T.AE(2,"05:15",":You ARE gonna have to take your backpack off, though.")
$T.AE(1,"05:17",":We can just leave it in the front-")
$T.AE(2,"05:21",":We'll leave it in the front seat, ok...?")
$T.AE(1,"05:23",":You don't have anything else in your pockets, or anything like that, right...?")
$T.AE(0,"05:26",":Well, I DO have a KNIFE on me...")
$T.AE(1,"05:28",":Ok.")
$T.AE(2,"05:28",":Can you put it in the backpack...?")
$T.AE(1,"05:29",":Put it in the backpack.")
$T.AE(0,"05:36",":<Indiscernable noises and such>")
$T.AE(5,"05:39","*REMOTE PARTY MUTED THE MICROPHONE ON MY DEVICE")
$T.AE(5,"06:16","*REMOTE PARTY UNMUTED THE MICROPHONE ON MY DEVICE")
$T.AE(2,"06:17",":No, I know, I know and you've never given me a problem, so, no worries, alright...? Like I said it's gonna be quick and easy. You'll be out before you know it, alright...?")
$T.AE(2,"06:40",":Where are ya stayin' right now...? Are ya in the woods?")
$T.AE(0,"06:41",":I'm homeless.")
$T.AE(2,"06:42",":Huh...?")
$T.AE(0,"06:43",":I'm homeless.")
$T.AE(2,"06:44",":Yeah, Yeah, I knew that, I knew that, but are you stayin', where abouts are ya stayin, in the woods right now, or your friends house...?")
$T.AE(0,"06:50",":Friends house.")
$T.AE(2,"06:51",":Friends house...?")
$T.AE(4,"06:51",":<checking pockets> Is this change...?")
$T.AE(0,"06:53",":Yeah.")
$T.AE(2,"06:55",":Just verify his change, bud. Don't take it out, just make sure it's change.")
$T.AE(0,"07:06",":People have been remotely interacting with my device, it happens a lot. They've been doin this for the last couple years. They tried to murder me on May 26th, 2020")
$T.AE(0,"07:19",":Yeah, I think Michael Zurlo attempted-")
$T.AE(1,"07:21",":Good...?")
$T.AE(4,"07:21",":Yep.")
$T.AE(0,"07:21",":-facilitated an attempted murder")
$T.AE(1,"07:22",":Alright.")
$T.AE(2,"07:23",":In the front...?")
$T.AE(1,"07:24",":Uh, yeah I dunno, yeah, he's been good.")
$T.AE(2,"07:26",":Yeah, he's")
$T.AE(1,"07:27",":I've never had an issue-")
$T.AE(2,"07:28",":No, no.")
$T.AE(1,"07:28",":-with him. Here's your phone back.")
$T.AE(2,"07:30",":We're gonna take your stuff and we're gonna put it in the front of your car.")
$T.AE(0,"07:32",":Ok.")
$T.AE(2,"07:33",":Come grab your stuff for him.")
$T.AE(0,"07:34",":My uh- ID is on the ground...")
$T.AE(4,"07:35",":Yeah.")
$T.AE(2,"07:36",":Oop~!")
$T.AE(1,"07:36",":Oop~! I dropped it, alright.")
$T.AE(1,"07:40",":If you wanna finish eatin' your thing on the way over, that's fine.")
$T.AE(0,"07:42",":Sure.")
$T.AE(1,"07:43",":Finish eatin' your lunch.")
$T.AE(2,"07:43",":We're gonna walk right over here, Mike. The second car.")
$T.AE(2,"07:56",":In and out, okay bud...?")
$T.AE(0,"07:57",":Yeah.")

# "You're aware that there's no surveillance in that aisle" <- You have to PROVE that, not ASSUME that.
# "You walked out of the store, and then went back into the store, went back to the aisle, and then pointed at where you left it."
# Nah. "Did anyone SEE that...?" Nah. Nobody SAW that at all. Which means that I left the item in that aisle when the guys
# from "loss prevention" pointed at me. Oh. So that's how I know that the LAW MEN and WALMART are CUTTING CORNERS.
# AKA, violating my rights as a CITIZEN and MAKING ASSUMPTIONS about what was NOT SEEN BY ANYBODY.
# What I can state with sheer certainty, is that there IS VIDEO FOOTAGE THAT CLEARLY SHOWS THAT NOBODY WENT BACK TO THAT AISLE 
# BEFORE STOPPING ME IN THE VESTIBULE. Ohhhhhhhhhhh. Shit. Nobody at Walmart Loss Prevention went back to that fucking aisle.
# Weird. But I mean, NOW since MICHAEL SHERIDAN NEVER COLLECTED THE SUPPORTING VIDEO EVIDENCE...
# NOW, WALMART HAS NO MEANS OF BEING ABLE TO PROVE THAT THEY SENT ANYBODY TO THAT AISLE TO FIND THE ITEM THAT NEVER LEFT THAT AISLE.
# But, suppose they did. NOW the (2) dudes can just put those SAME EXACT CLOTHES back on, and then like, send a guy to that aisle,
# and then walk through the aisle and come out the other end, and put their arms up and be like 'Well, fuck, no item that the dude
# SUPPOSEDLY took, aw shucks...' 

# (00:07:59 -> 00:28:11) # Part 2 - Within (SEDAN 4138/SCSO Michael Sheradin)
$T.AE(2,"08:00",":Just gotta put your seatbelt on, alright...?")
$T.AE(2,"08:07",":Just gotta put your seatbelt on.")
$T.AE(0,"08:09","*Enters rear of SCSO 4138")
$T.AE(2,"08:14","*Closes rear passenger side door of SCSO 4138")
$T.AE(0,"08:20",":Ah, fuckin' damnit.")
$T.AE(1,"08:29","*Opens driver door")
$T.AE(1,"08:36","*Closes driver door")
$T.AE(1,"08:38",":Ah, ok.")
$T.AE(0,"08:43",":When did they sign that...?")
$T.AE(1,"08:46",":What's that...?")
$T.AE(0,"08:47",":When did they sign that...?")
$T.AE(1,"08:48",":Uh, the next morning... when he came back in.")
$T.AE(1,"08:56","*Cruiser computer says NEW MESSAGE*")
$T.AE(1,"09:00","*Cruiser computer says NEW MESSAGE (bro)*")
$T.AE(1,"09:01","*Cruiser computer says NEW MESSAGE (bro)*")
$T.AE(2,"09:02",":<Radio> 4814, 4138, do you have the call for service number for this...?")
$T.AE(1,"09:09",":Standby, *echo* standby.")
$T.AE(0,"09:11",":You know there's guys in your department that have been, uh- havin' an axe to grind against me.")
$T.AE(1,"09:16",":Well, I'm not one of em, and I don't-")
$T.AE(0,"09:18",":I know you're not.")
$T.AE(1,"09:19",":I don't hold grudges against anybody.")
$T.AE(0,"09:21",":Well, May 26th, 2020, 2 guys were trying to murder me for about 90 minutes, and then Scott Schelling, Joshua Welch, and Jeffrey Kaplan all found me outside of the Zappone dealership. I made 2 911 calls and went to Center for Security and left footage of uh- me attempting to dial 911... someone was using a program on my device called 'Phantom', or 'Pegasus', which uh- prevented my calls from making it to the dispatch station.")
$T.AE(1,"09:49",":<Opened radio comm, inaudible>")
$T.AE(0,"09:49",":I made records requests.")
$T.AE(2,"09:56",":<Radio> Go ahead, Mike.")
$T.AE(1,"09:58",":The call for service is ZERO SIX FOUR, FIVE THREE NINE")
$T.AE(2,"10:08",":<Radio> Great.")
$T.AE(0,"10:13",":It seems to happen, like every time I run into the police.")
$T.AE(2,"10:33",":<Radio> 481<indiscernable>... 4138's gonna have that male in custody, we'll be quick.")
$T.AE(0,"10:50","*sighs")
$T.AE(1,"10:51",":We're clear to get it done and when we are I'll bring you back.")
$T.AE(0,"10:56",":Listen man, I need help from somebody in your department, and I think you're the person I need help from.")
$T.AE(1,"11:03",":<Opened radio comm> 4138 Sheriffs Office")
$T.AE(0,"11:07",":<Radio> Sheriffs dispatch")
$T.AE(1,"11:09",":<Opened radio comm> I have that male on an arrest warrant in the Town of Halfmoon station for processing.")
$T.AE(1,"11:35",":Michael C. <Radio> DEE OH BEE is ZERO FIVE TWO FOUR EIGHT FIVE")
$T.AE(0,"12:03",":You know, uh- this is a serial case with uh- your department. Uh- probably.")
$T.AE(1,"12:08",":Which case...?")
$T.AE(0,"12:09",":I'm saying that this seems to be a recurring case with the Saratoga County Sheriffs Office")
$T.AE(1,"12:15",":Which case...?")
$T.AE(0,"12:17",":Several cases. Like a SERIAL case, means that- THERE'S A PATTERN, where I like say things that happens to ME, and then, they get ignored. And then other people are basically able to say whatever, and I get in trouble. Like the 911 call that I made on June 13th, 2020, Mark Sheehan showed up, I reported on the 911 call that my neighbor attempted to hit me with his baseball bat on my property.")
$T.AE(1,"12:40",":Yup.")
$T.AE(0,"12:41",":Well, uh- the report that uh- Mark Sheehan wrote, uh stated that I went over to their lot shouting obscenities on their property.")
$T.AE(1,"12:49",":Went over to their lot and did what...?")
$T.AE(0,"12:51",":Shouting obscenities to them on their property, and on their lot. They all lied. And they- ugh, it doesn't make much sense here")
$T.AE(0,"13:12",":What I'm saying is that people can make up some bullshit about me, and then, you guys ACTUALLY DO STUFF...")
$T.AE(1,"13:21",":Well, <chears throat> here again... I mean, you were in the store, they claim that they SAW you do it, uhm, and they signed the complaint, not us. Not the police, the loss prevention people down here.")
$T.AE(0,"13:39",":Right...")
$T.AE(1,"13:40",":Signed a complaint. We then take it and put it in front of the judge, and if the judge thinks there's enough there, then they issue the warrant.")
$T.AE(0,"13:51",":If they did that based on HEARSAY, without providing EVIDENCE, right...? That's what you're telling me.")
$T.AE(1,"13:58",":No, what I'm tellin' you is, THEY DID IT ON (DIRECT KNOWLEDGE/IMAGINATION/HEARSAY)")
$T.AE(0,"14:02",":Right but what I'm saying, is THAT direct knowledge, is HEARSAY.")
$T.AE(1,"14:06",":How is it HEARSAY if he signed a complaint, saying he SAW you do it...?")
$T.AE(1,"14:10",":How is that HEARSAY...?")
$T.AE(0,"14:10",":Because an employee can just SAY that. That's what you're telling me. That's what that AFFA- AFFADAVIT, is.")
$T.AE(0,"14:19",":There's no- The- There's a video- there's video footage throughout the whole entire store. Nobody saw me DO anything, they've made it up, they were doing this as a form of PREJUDICE, that's what I'm telling you.")
$T.AE(1,"14:32",":Ok. And if there's some way that you can PROVE that...?")
$T.AE(0,"14:37",":How am I gonna PROVE it, they- they- they're not even- they don't have to prove that I TOOK anything from the store.")
$T.AE(1,"14:42",":They signed the complaint, not me.")
$T.AE(0,"14:44",":Right, but what I'm saying is that they don't have to PROVE anything.")
$T.AE(1,"14:47",":Yeah, they DO.")
$T.AE(0,"14:51",":They don't have any FOOTAGE of it, and you're ARRESTING me. It's ALL based on HEARSAY, you took an AFFADAVIT based on HEARSAY.") # Even though they recorded a video of me using their personal smart phones... Ohhhhhh.
$T.AE(1,"14:56",":Ok.")
$T.AE(0,"15:03",":Right...?")
$T.AE(1,"15:03",":No.")
$T.AE(0,"15:05",":But, did they SUBMIT any EVIDENCE of this...?")
$T.AE(1,"15:08",":Me-")
$T.AE(0,"15:08",":You know this- what happened on June 28th 2020 (2022*) was that my mother and I had an argument that morning...")
$T.AE(1,"15:13",":Yup.")
$T.AE(0,"15:15",":And uh, she failed to tell the police an accurate statement about what happened between me and her. And then the POLICE attempted to arrest me before reading me my miranda rights, you know this is a case of like police officers ignoring what I say. And, not- Taking action on STORIES rather than EVIDENCE.")
$T.AE(0,"15:37",":And that's what that AFFADAVIT is, cause if they had EVIDENCE of me TAKING something, I would've been on video surveillance.")
$T.AE(1,"15:42",":Ok, so... Let me make sure I got what you're sayin', straight here...")
$T.AE(0,"15:46",":Sure...")
$T.AE(1,"15:47",":<clears throat> So if you SEE somebody take a baseball bat to your car...")
$T.AE(0,"15:52",":Yeah, right.")
$T.AE(1,"15:52",":Right...? And, YOU call the police-") # This is exactly what happened to me on June 13th, 2020. Basically the police minimized my 911 call and ignored the dent on the SIDE of BILL MOAKS HOUSE that he LEFT with his BASEBALL BAT... and then MARK SHEEHAN WROTE DOWN a FICTIONAL STORY of what fucking happened. My 911 call...? It was told to fuck off. The dent on the side of WILLIAM MOAKS HOUSE which CONTRADICTS HIS FUCKING STORY...? Ignored. That's what the police at SARATOGA COUNTY SHERIFFS OFFICE do.
$T.AE(0,"15:56",":That's DIFFERENT, that's EVIDENCE, leaving it behind on the car. There's NO EVIDENCE of me TAKING anything.")
$T.AE(1,"16:03",":But you're claiming SO AND SO DID IT, right...?") # Like I did in a 911 call on 06/13/2020.
$T.AE(0,"16:06",":Right...") # June 13th, 2020. Basically this dude is telling me my 911 call was fucking stupid. Because that's exactly what happened. SCSO said that my call, was fucking stupid. Because BILL MOAK is a fuckin WICKED COOL DUDE, in the eyes of the SHERIFFS OFFICE.
$T.AE(1,"16:07",":And you signed a complaint sayin' that so and so did it, there's no EVIDENCE that he did it (except an ALIBI, which would be found during CORROBORATION) other than what YOU said...")
$T.AE(0,"16:15",":But what I'm suggesting is that, I know what p- I know what POINT you're tryin' to make...? But what I'M suggesting is that on- like, there's a SERIAL CASE of like, situations happening to ME, where I'M NOT BEING OFFERED A CHANCE TO SIGN A COMPLAINT, or a STATEMENT, or PEOPLE AREN'T TAKING ACTION ON MY STATEMENTS. You know...? So when I say that my neighbor, I called 911 on June 13th, 2020. Because my NEIGHBOR threatened to kill me with his baseball bat and ran onto my property and tried to hit me... and my STEPFATHER, and my NEIGHBORS WIFE, held him back, from HITTING ME ON MY PROPERTY. And then, I called 911, and then I reported everything that I just said...")
$T.AE(1,"16:54",":Yep.")
$T.AE(0,"16:54",":And then the cop showed up, and then what happened was that MULTIPLE PEOPLE had a different story (because they all provided false testimony on a written instrument which is called 'PERJURY'.")
$T.AE(1,"17:02",":Did your STEPFATHER and whoever support it...?")
$T.AE(0,"17:06",":Yeah, he ran up to the-")
$T.AE(1,"17:07",":Support your story...?")
$T.AE(0,"17:08",":No.")
$T.AE(1,"17:09",":Oh.")
$T.AE(0,"17:09",":He was one of the people trying to hold my neighbor back. What I'm saying is there's PREJUDICE being APPLIED TO ME. Like right now, you're taking a report based on somebody saying that they SAW me DO something, but there's no EVIDENCE of it. And then when I'm in trouble, I can't get HELP because I will SAY SOMETHING and it falls on DEAF EARS.") # <- Exactly what happened to my father before he was MURDERED.
$T.AE(0,"17:32",":Might not fall on deaf ears, but- there's, ya know, if I worked in the loss prevention pre- ah, I dunno it doesn't really make much sense. I used to work at Computer Answers and I was trying to tell people that my employer was STEALING MONEY from the company, and NOBODY OFFERED ME A CHANCE TO SIGN A AFFADAVIT, or a DISCLAIMER or whatever.")
$T.AE(0,"18:23",":I'm gonna be honest. It just seems like people don't CARE about anything I say.")
$T.AE(0,"18:42",":And then you're bringing me before a judge.")
$T.AE(1,"18:45",":What...? No, I'm not bringing you before the judge. I told you what was gonna happen...")
$T.AE(0,"18:50",":Well...")
$T.AE(1,"18:51",":I'm gonna process ya, write you an appearance ticket to come back. And out the door you're gonna go. Ah I'll give ya a ride back over to get your bicycle.")
$T.AE(1,"19:17",":<Open radio comm>FOUR ONE THREE EIGHT to SHERIFFS DISPATCH")
$T.AE(4,"19:23",":<Radio>Sheriffs dispatch")
$T.AE(1,"19:25",":<Open radio comm>I'll be at the Halfmoon Sheriff Substation...")
$T.AE(0,"19:27",":Before we go in,")
$T.AE(1,"19:35",":<Open radio comm><Indiscernable>")
$T.AE(0,"19:36",":Before we go in, uh- do you mind if I talk with you about the events of May 25th into May 26th, 2020...?")
$T.AE(1,"19:43",":Sure.")
$T.AE(0,"19:43",":Alright. SCSO-2020-028501, that's the incident record for SCOTT SCHELLING, JEFFREY KAPLAN, and JOSHUA WELCH.")
$T.AE(1,"19:55",":Ok.")
$T.AE(0,"19:58",":On May 25th, 2020, I was walking around and I was making audio recordings with my phone. I made 3 audio recordings, and then I uploaded them at the Computer Answers shop. During the THIRD audio recording, someone attempted to strike me with their vehicle, near the CENTER FOR SECURITY, uh- building. Uh, when I got to the CENTER FOR SECURITY building uh- or I apologize, when I got to COMPUTER ANSWERS, I made some uploads, and then I heard a noise in the woods over behind ERIC CATRICALA's funeral home, so I walked behind there and I took some pictures (that TROOPER BORDEN ASKED ABOUT). And uh- And then I wal- I took a picture of the Boomer-McCloud Plaza, and I started recording a video. And then all of a sudden a suspicious white male came from the Halfmoon Sandwich and Sub Shop side, and uh- he showed up at a pretty suspicious moment, he was following me around. I uh- recorded an interaction on video of me speaking with him, and uh, it is my FIRM ESTIMATION and BELIEF, that he had a PROGRAM that was remotely deployed to my smartphone that was TRACKING ME, and allowing him to uh- see where I was going, and uh- record my uh, the environment, basically committing ESPIONAGE. Anyway, uh, he began- he and I spoke for a moment and I said uh, 'Are you from around here...?', and he said 'I am from around here, but I moved away and came back.' And then I said 'Oh, alright. Well uh- do you know this ERIC CATRICALA guy...?', and he says like 'Uh, no.'. And I say 'Well, uh, did you know he's like throwin' bodies into concrete foundations and stuff...?' And the reason why I said that was because I was tryin' to figure out if this dude was doin' something suspicious, and when I said that to him, uh- he seemed to be pretty inquisitive about it. He's like 'What...? I don't understand...?' Well, I was like 'Alright, well, thanks a lot, I appreciate it.' And then I ran across the street, or I STARTED running across the street (but didn't), and then HE started walking away, and then uh- I rec- I uh- was able to capture an interaction of him checking his smartphone and then I had uhm, a suspicion right there and then that HE was watching me on my device. And he was attempting to murder me, and I believe that HE was coordinating an attack with SOMEONE at the FEDERAL BUREAU OF INVESTIGATION.")
$T.AE(1,"22:19",":Ok.")
$T.AE(0,"22:22",":I believe that my COUSIN RYAN WARD, and my AUNT TERRI COOK, uh- were, COMPLICIT with uh- CONSPIRING TO, ATTEMPT TO MURDER ME. And that MICHAEL ZURLO, the COUNTY SHERIFF HEADMASTER, FACILITATED this event.")
$T.AE(1,"22:37",":Ok.")
$T.AE(0,"22:38",":The rest of what happened that night, AFTER that moment...?")
$T.AE(1,"22:42",":The rest that happened, what...?")
$T.AE(0,"22:44",":Well, that was just the BEGINNING of what happened that night...")
$T.AE(1,"22:46",":Yup.")
$T.AE(0,"22:50",":Uh, several moments later, another individual passed me, like, uh- another white male. Basically, al- almost IDENTICAL description, had a backpack with a neon light in it's backpack, it was a satchel type backpack with a mesh, mesh type backpack...")
$T.AE(1,"23:07",":Mhm.")
$T.AE(0,"23:08",":And uh- he had a wirele- a bluetooth speaker, and he had walked past me, or he had- it- it- it appeared as if he was trying to walk up to me, uh, without raising any suspicion, or like, distracting me with the music or something, so I think he WAS trying to STAB me or something, and he was trying to get very close. But I had my eyes on him, so I saw BOTH of these guys. Anyway, uh- after... Uh- I don't remember what I said to him, but it wasn't very long at all, and then he walked to the laundromat. Both of those kids went to the laundromat, which is the 24-hour laundromat.")
$T.AE(1,"23:43",":Yup.")
$T.AE(0,"23:45",":Uh- one of them was driving a black Dodge. And I can't remember if it was a black Dodge Dart, or a black Dodge Charger. But I found that vehicle at the New York State, uh, Corrections Academy, later, uh- on Fathers Day 2020.")
$T.AE(0,"24:06",":After these two, got on foot and everything, I was RECORDING them on VIDEO, and, it was like a 20 minute long video, and, this 1 kid got in his black car, and he started driving down the road. And then the OTHER kid, ran out of the laundromat and he said, 'Whats the big idea...?' Well, it was at that moment that I realized that they had some type of program that was remotely watching me, or accessing my device. So they were tracking me for months, they did this when I worked at Computer Answers, I think they're associated with my cousin RYAN WARD, and CHRISTINA CZAIKOWSKI. Uh, look, CHRISTINA CZAIKOWSKI is not my cousin, uh- and I believe that they are responsible for uh- pulling an ARMED ROBBERY of MEGHAN ALEXANDER in STILLWATER, in HILLSIDE TRAILER PARK, back in like 2011 or 2012 I believe... and uh, what they did was they went to uh HER fathers house (Guy Alexander) in SKI MASKS and there were 3 of them. And uh, they held her at GUNPOINT, and then they took all of my cousin THOMAS' MONEY, and I believe that this has something to do with the murder of my father back in 1995. I think the same group of people were involved in this, as well as the murder of SAMMY SANTA CASSARO (in 1996).")
$T.AE(0,"25:21",":So I think there is a GROUP of CRIMINALS, or uh- a GANG, I think they're working with the RUSSIAN MAFIA, and they have been CLOSELY WATCHING AND MONITORING ME...")
$T.AE(1,"25:32",":Right.")
$T.AE(0,"25:33",":And when I worked at Computer Answers, they attacked me with a CYBERATTACK on JANUARY 15th, 2019, and I believe they used that attack by using this program called Pegasus.")
$T.AE(1,"25:44",":Ok.")
$T.AE(0,"25:46",":So, uhm- as for the 26th, of May 2020, after uh- the kid started running out of the laundromat...? I believe I ended the recording, and I didn't think I had enough time to upload it at the Computer Answers shop. I uh, attempted to dial 911. When I dialed 911 and hit the send button...?")
$T.AE(1,"26:08",":Yup.")
$T.AE(0,"26:09",":The TIMER kept rising, but there was no sound emanating from the device. So, I was unable to reach the dispatch station. Uh, I had a feeling that there was NO COINCIDENCE that I had a couple dudes FOLLOWING me, on foot. The- The one dude drove away in his black Dodge Charger, or uh, it was either a Charger or a Dodge Dart, I can't remember which make/vehicle it was, but uh- I later uhm- uh- he, somehow popped out bakc near Grecian Gardens, so the one dude that drove out towards Walmart must've found some BACK WAY to get, like, on foot, near me, and then they had another vehicle parked in the Lowes Home Improvement parking lot. So they had a PREMEDITATED plan, where they were like following me and expected me where I was gonna go and everything. They followed me, and I- I went- I uh, knew what they were doing, I- wasn't- I- I was, very certain they were attempting to murder mem, and uh- I uh- wasn't gonna run becuase I knew I was gonna run out of steam. I uh- got all the way to CENTER FOR SECURITY, and I di the SAME EXACT THING where I dialed 911 and hit the SEND button, and the TIMER kept rising...")
$T.AE(0,"27:19",":And, uh- I did this in front of the- view of the camera at CENTER FOR SECURITY. And I told SCOTT SCHELLING about that, later that night. SCOTT SCHELLING never wrote it in ANY of his, uh- any of those notes in his report.")
$T.AE(1,"27:34",":Ok.")
$T.AE(0,"27:34",":So I think that SCOTT SCHELLING, uh- went back and destroyed the footage of me dialing 911 at that location.")
$T.AE(1,"27:42",":Hm... Ok. Alright, lets go inside, and continue while I do my paperwork here, and get ya outta here a little bit quicker.")
$T.AE(1,"27:51","*Closes driver door")
$T.AE(1,"28:00","*Opens front passenger door")
$T.AE(1,"28:02","*Hits the unlock button")
$T.AE(1,"28:04","*Opens rear passenger door")
$T.AE(0,"28:05","*Unbuckles seat belt, exits sedan 4138")
$T.AE(1,"28:11","*Shuts the rear passenger door")

# (00:28:11 -> 00:28:45) # Part 3 - Walking into Halfmoon (Sheriff Substation/Town Court)
$T.AE(1,"28:11",":We're gonna head right in those doors, up the stairs, and to the left.")
$T.AE(1,"28:39","*shuffles with keys to open the office door")
$T.AE(1,"28:43","*Unlocks the office door")
$T.AE(1,"28:45","*Opens the office door")

# (00:28:35 -> 01:03:56) # Part 4 - Michael Sheradin processes my "arrest" order
$T.AE(1,"28:47",":There we go. come right in here, and have a seat.")
$T.AE(0,"29:01",":Mind if I stand...?")
$T.AE(1,"29:01",":No, sit down. Relax.")
$T.AE(0,"29:04","*Sits down")
$T.AE(1,"29:08",":Alright, so, continue on... with that- what you were sayin'...")
$T.AE(0,"29:23",":These guys tried to hit me with their vehicle multiple times.")
$T.AE(1,"29:24",":Yup")
$T.AE(0,"29:28",":They were, uh- stalking me. ...using this program that I was talking about. I told SCOTT SCHELLING about all this (minus the PROGRAM part)<indiscernable, phone in pocket movement> report, that incident report that I gave you.")
$T.AE(1,"30:27",":Alright, lets get rippin', here.")
$T.AE(0,"30:34",":See, uh- I haven't ran into any officers from your unit that have been the least bit concerned about that story.")
$T.AE(1,"30:41",":Ran, what...?")
$T.AE(0,"30:43",":I haven't ran into any officers from your unit, that seem to be the least bit concerned about that story. About why, uh- I reported to SCOTT SCHELLING that, I had video evidence of 2 guys trying to murder me.")
$T.AE(1,"30:56",":Right.")
$T.AE(0,"30:58",":And then, he tried to arrest me.")
$T.AE(1,"31:02",":He tried to arrest ya...?")
$T.AE(0,"31:03",":Yeah.")
$T.AE(1,"31:04",":Ok. <processing what I said, doesn't make sense> W- what was that- what was he trying to arrest you FOR...?")
$T.AE(0,"31:07",":Well, uh- the guys that were trying to hit me with their car...")
$T.AE(1,"31:12",":Yup.")
$T.AE(0,"31:12",":...called 911, or called the dispatch station, to say that I was JUMPING in front of the car.")
$T.AE(1,"31:17",":Oh, ok.")
$T.AE(0,"31:22",":I mean, it sounds pretty ridiculous, right...?")
$T.AE(1,"31:23",":Oh, listen, I don't pass judgement on anybody, I mean anything's possible.")
$T.AE(0,"31:29",":Right...")
$T.AE(1,"31:32",":I mean...")
$T.AE(0,"31:34",":My phone was dead, I was trying to hand SCOTT SCHELLING the EVIDENCE of me dialing 911...")
$T.AE(1,"31:38",":Yup.")
$T.AE(0,"31:39",":And I told him that there was evidence that he could CORROBORATE at CENTER FOR SECURITY, and then- Oh. Well, he never got back to me about that. So what I'm saying is that uhm, some people from your unit were committing OBSTRUCTION OF JUSTICE, and they DESTROYED EVIDENCE")
$T.AE(1,"31:55",":<clears throat> Ok.")
$T.AE(0,"32:02",":But- then they'll go ahead and arrest me for cutting some dude's kayak strap, when my 911 calls were being blocked.")
$T.AE(0,"32:12",":I don't know if you're hearin' what I'm sayin', dude...")
$T.AE(1,"32:15",":Yeah, I HEAR what you're sayin'...")
$T.AE(0,"32:20",":I dunno, maybe it's just illegal for me to call 911 or ask for help, that's what it feels like. Ya know...? It's not ILLEGAL for people to just say whatever, and then I get in trouble.")
$T.AE(0,"32:33",":So if I call 911 like I did on June 13th (2020) and then Mark Sheehan showed up, in 003564, SCSO-2020-003564, ya know...?")
$T.AE(0,"32:45",":So if I call 911 and I say that some dude came onto my property trying to hit me with his baseball bat, and then, my neighbor, his wife, and my stepfather, commit perjury, on a statement, to Mark Sheehan, you guys don't take any action on that. Because I have AUDIO RECORDINGS of my MOTHER and my STEPFATHER admitting that the DETAILS on THAT REPORT are FALSE. Ya know...?")
$T.AE(0,"33:13",":So what I'm saying is that the DOCUMENTS that you guys ISSUE to people...? It says that it's a MISDEMEANOR, to (knowingly) provide false statement on a written instrument.")
$T.AE(1,"33:22",":Yup. It does, right at the bottom.")
$T.AE(0,"33:25",":Right but you... the police RARELY ever, uh- ARREST anybody for that. Or, investigate it, for that matter. So I'm tryin' to tell ya.")
$T.AE(1,"33:32",":Uhm, believe it or not, I have.")
$T.AE(0,"33:35",":I'm sure you have, but-")
$T.AE(1,"33:36",":I have.")
$T.AE(0,"33:38",":How rare, is it...?")
$T.AE(1,"33:41",":Well that's- it IS rare... but normally, uh... <pauses> What am I doin' here...")
$T.AE(0,"33:53",":I'm sayin' is, like what you're doing right now...? Is taking HEARSAY, and havin' me arrested, for an AFFADAVIT, that they wrote (signed). And NOBODY'S offering ME an AFFADAVIT for ANY of the things I keep experiencing. So what I'm suggesting is that EVERYBODY seems to be MORE IMPORTANT than me. I think uh- maybe I DESERVED to have my father murdered when I was a 10 year old kid, and then my mother EMOTIONALLY ABANDONED ME, and didn't like RAISE ME or TEACH ME, like HOW TO LIVE MY LIFE...?")
$T.AE(1,"34:27",":Yup.") # <- He's absent mindedly agreeing with me. 
$T.AE(0,"34:26",":And then people develop PREJUDICE toward me, because you know, I must've done SOMETHING to deserve having my DAD killed. That's how people treat me.")
$T.AE(0,"34:41",":I'm not trying to give you a guilt trip or whatever... But- <indiscernable, phone shifting in pocket> 2 guys that work at Walmart, can just FABRICATE something.")
$T.AE(0,"34:55",":And then you're handing me PAPERWORK to arrest me.")
$T.AE(0,"34:59",":But hey~! A couple guys can attempt to MURDER ME, and I can have EVIDENCE OF IT, I can show it to TROOPER LEAVEY, like I did on MAY 27th, 2020. And uh, MICHAEL ZURLO, your SUPERIOR, he can FACILITATE an ATTEMPTED MURDER and then like, cover it up and his tracks. And then, FUDGE ALL THE RECORDS AT THE RECORDS OFFICE. That's what's been happening. I have RECORDS on my GitHub project, and I've bene putting it all together. You guys have CRIMINALS in your department.")
$T.AE(1,"35:26",":Ok.") # <- Dude SEEMS pretty vacant or absent minded, or PREOCCUPIED. He's only responding to CERTAIN PHRASES. "You guys have criminals in your department." -> "Ok."
$T.AE(1,"35:28",":Hang on a second, just let me make this quick phone call up to our dispatch, they were lookin' for me.") 
$T.AE(1,"35:45",":Hello, Michael here. <other end> I do. <other end> I have everything. Yeah, well they just handed it to me this morning. So... <other end> Oh, it did, hot off the press. Hot~! So, alright...? <other end> Nope, it's not even, I don't believe it's in the justice yet, nope. So...")
$T.AE(0,"36:14",":DHS...?")
$T.AE(1,"36:18",":Yeah, ok. Thanks. Bye. What's that...?")
$T.AE(0,"36:22",":Was that related to me...? That call...? I dunno.")
$T.AE(1,"36:27",":Do what now...?")
$T.AE(0,"36:28",":I thought you said something about DHS.")
$T.AE(1,"36:30",":No, no, no, no, no, no, no. No, no, no, no. No <slight chuckle> Heh, DHS has got nothin' to do with THIS...") # They should be INTERESTED in the EVENTS OF 05/25/20 -> 05/26/20.
$T.AE(0,"36:37",":Yeah, I know. DHS, and uh- the NSA, the CIA, and the FBI have been keeping tabs on me, and sending you guys around to SMEAR me.") # Pretty fuckin' sure of it... unless I'm wrong.
$T.AE(1,"36:49",":Ok. Liste- I've gotta ask you some questions... How tall are ya...?")
$T.AE(0,"36:52",":FIVE ELEVEN")
$T.AE(1,"36:53",":How much you weigh, around...")
$T.AE(0,"36:54",":Or, FIVE TEN, I'm sorry.")
$T.AE(1,"36:55",":Alright")
$T.AE(0,"36:56",":Uh, I dunno, 150...? 160...?")
$T.AE(1,"36:58",":150...? Ok. Your eyes are blue...?")
$T.AE(0,"37:00",":Yup.")
$T.AE(1,"37:01",":Brown hair...?")
$T.AE(0,"37:01",":Yup.")
$T.AE(1,"37:03",":Okay... you wear glasses, or contacts...?")
$T.AE(0,"37:06",":No.")
$T.AE(1,"37:06",":No...? Ok... Right handed, or left handed...")
$T.AE(0,"37:12",":Right handed.")
$T.AE(1,"37:13",":or ambidextrous...?")
$T.AE(0,"37:15",":Right handed.")
$T.AE(1,"37:16",":Ok. You're single, and never married...?")
$T.AE(0,"37:19",":Single.")
$T.AE(1,"37:19",":Yup. Born in Albany...?")
$T.AE(0,"37:22",":Yes.")
$T.AE(1,"37:23",":Ok. Highest grade of education... ")
$T.AE(0,"37:31",":Associate degree. Certifications, I'm Micro- soft- I'm Microsoft certified.")
$T.AE(1,"37:35",":Ok. Is that like an associates, or whatever...?")
$T.AE(0,"37:38",":I have a college degree, an associate degree, but I also have certifications so I don't know how to answer that. It's equivalent-")
$T.AE(1,"37:43",":I'm- I'm just lookin' for like, 14 years, so-")
$T.AE(0,"37:46",":It's equivalent to a bachelors degree.")
$T.AE(1,"37:50",":Ok... <pauses> I see you've got a tattoo on your right arm...")
$T.AE(0,"37:57",":Yep.")
$T.AE(1,"37:57",":Alright, hold on... <pauses> Let's see... right. And what is that, just a flaming skull or somethin'...?")
$T.AE(0,"38:23",":Yep.")
$T.AE(1,"38:24",":Is that what it is...?")
$T.AE(0,"38:25",":Yeah.")
$T.AE(0,"39:09",":Someone with a lot of money, can watch what I'm doing, watch me whereever I go and whatnot, that gives them more rights than me, right...?")
$T.AE(1,"39:17",":Well, maybe uh, somebody with a LOT of money can do a LOT of things like that.")
$T.AE(0,"39:24",":Right")
$T.AE(1,"39:24",":I'm not one of those people.")
$T.AE(0,"39:28",":I understand that, I can- I can- I can derive intent. I don't think you have any malicious intent, but I think that you're, um- not paying attention to the details.")
$T.AE(0,"39:48",":And, not for nothing, but- ")
$T.AE(5,"39:50","*Windows toast notification")
$T.AE(1,"39:54",":I'm listenin'")
$T.AE(0,"39:59",":This is, uh- a pattern. Of behavior. From your department")
$T.AE(1,"40:03",":Ok.")
$T.AE(0,"40:11",":And I'm not saying that uh, YOU'RE doing anything, malicious, by any means, but- <clears throat> what's happening is uh, certain things hit the permanent record, and some things don't. So if a couple kids that are part of the police unit that you work with, uh- if they're going around committing crimes, uh they have a means of being able to prevent any of those records from hitting the permanent record. But- hey. Anything can say- Anybody can apparently say whatever, HEARSAY, and then THAT will hit the permanent record.")
$T.AE(0,"40:47",":So, a couple of guys from loss prevention, CLAIM that they SAW me DO something, I would wager that they probably do this a LOT, where they don't have to PROVIDE any evidence, of uh- what they're signing a statement to.")
$T.AE(1,"41:02",":Well...")
$T.AE(0,"41:03",":So that means that a lot of people are getting charged with crimes that AREN'T being proven.")
$T.AE(1,"41:10","*clears throat")
$T.AE(0,"41:11",":You can't ask uh- the accused to prove themselves when the supermarket has all the recording footage, and they're not providing ANY recorded footage whatsoever, uh- of someone leaving the store WITH the device or merchandise.")
$T.AE(1,"41:29",":I'm still listenin'... <pauses> Well... fact is, back to why we're here, once again, uh- THEY signed a complaint, NOT US.") # Maybe he is NOT absent mindedly agreeing with me after all.
$T.AE(0,"41:39",":Right, I understand that. But if they-") # It is not like I don't understand the situation. I understand the situation TOO WELL...
$T.AE(1,"41:39",":Ok, so... if I signed the complaint, if it was ME, as a POLICE OFFICER, then I would have EVERYTHING that I need, to support what I was charging.") # I get what he's saying. He isn't getting what I'm saying.
$T.AE(0,"41:52",":Right, but you're not hearin' me.")
$T.AE(1,"41:54",":I am hearin' ya.")
$T.AE(0,"41:54",":They don't ha- They don't have to provide any evidence, they can just make up hearsay, and put it on a piece of paper.")
$T.AE(1,"42:00",":If they physically SAW it, it's not HEARSAY.")
$T.AE(0,"42:04",":It IS hearsay.")
$T.AE(1,"42:05",":How is it hearsay, if they physically saw you do whatever it is they claiming that you're di- you did...? How is that hearsay...?")
$T.AE(0,"42:11",":So like... <pauses> Like what I was saying, is that- they can just make it up.")
$T.AE(1,"42:17",":Ok. So they LIED, it's not HEARSAY, but they lied. Ok.") # So he IS actually understanding what I'm saying.
# _____________________________________________________________________________________________________________________________________________
# | If I went around telling people that MICHAEL SHERIDAN made this statement WITHOUT SUPPORTING EVIDENCE- it WOULD be HEARSAY.               |
# | But, BECAUSE I have this AUDIO RECORDING...? It is SUPPORTING EVIDENCE, and NOW, it's not HEARSAY, it's a TRANSCRIPTION.                  |
# | With the AUDIO RECORDING, it became a literal, 100% truly, qualified, piece of EVIDENCE, a RECORD, that SOMETHING WAS STATED BY A PERSON, |
# | and that I'm not basing things on HEARSAY.                                                                                                |
# | I'm basing things on a truly, actual, factual, 100% digital file that EXISTS, and can be PROVIDED to ANYBODY as a REFERENCE of something  |
# | having HAPPENED, or TAKEN PLACE. Lets draw up a DIAGRAM to make it easier to UNDERSTAND...                                                |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# _________________________________________________
# | Situation                    | Result         |
# |------------------------------|----------------|
# | Without the AUDIO RECORDING =>       HEARSAY  | 
# | With    the AUDIO RECORDING =>  TRANSCRIPTION |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# ____________________________________________________________________________________________________________________________________________
# | See the difference in the diagram above...? That's why JUDGE KATHERINE SUCHOCKI (even JOE FEDORA) should consider the DIFFERENCE between |
# | the TWO SCENARIOS... and drop their case(s) ENTIRELY.                                                                                    |
# | Because here's how I should PHRASE the situation...                                                                                      |
# | WALMART, a STORE with HUNDREDS OF CAMERAS... signed an AFFADAVIT with NO SUPPORTING EVIDENCE... when clearly, MICHAEL SHERIDAN was SHOWN |
# | the FOOTAGE of how I walked back into the same exact aisle that the LOSS PREVENTION GUYS saw me standing in, right...?                   |
# | But MAGICALLY, the PRODUCT was IN THEIR HANDS, afterward. OOoooOHhhHHHhhhHHhh... that means that the item was in that aisle.             |
# | Since there is NO EVIDENCE WHATSOEVER to SUGGEST that it EVER LEFT THAT AISLE...? NOBODY SHOULD BE ARRESTING ANYBODY FOR ANYTHING AT ALL |
# | Oh. Cool.                                                                                                                                |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ____________________________________________________________________________________________________________________________________________
# | Look, if former NYS governor ANDREW CUOMO can indiscriminately suck random dudes' dicks or vice versa, and then sexually harass females, |
# | then it stands to reason that there needs to be some pretty powerful evidence on hand that he's GUILTY of (something/being gay).         |
# | While there's no EVIDENCE of ANDREW CUOMO...                                                                                             |
# |------------------------------------------------------------------------------------------------------------------------------------------|
# | 1) being pounded in the butt                                                                                                             |
# | 2) pounding some dude in the butt                                                                                                        |
# | 3) blowing some dude                                                                                                                     |
# | 4) being blown by a dude                                                                                                                 |
# |------------------------------------------------------------------------------------------------------------------------------------------|
# | ...it stands to reason that (11) females got GROSSED OUT when ANDREW CUOMO tried to make SEXUAL PROPOSITIONS (for instance, BRITANNY     |
# | COMMISSO), that those SEXUAL PROPOSITIONS were ALL just SUSPICIOUS ACTIVITY, and that the REASON he didn't get in TROUBLE, is because    |
# | of how (IMPORTANT/GAY) he is. Because of how (IMPORTANT/GAY) he is, CRAIG APPLE felt really bad that ANDREW CUOMO can't get laid.        |
# | Therefore, didn't feel like there was a suitable condition where he should be PROSECUTED for SEXUALLY HARASSING (11) women. Nah.         |
# | It doesn't change the fact that CRAIG APPLE, and MILLIONS of other people know just how (IMPORTANT/GAY) ANDREW CUOMO really is.          |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ____________________________________________________________________________________________________________________________________________
# | There IS EVIDENCE that the LOSS PREVENTION GUYS POINTED AT ME SEVERAL MINUTES PRIOR, from the HOUSEWARES area, THEN, they never sent a   |
# | guy to that AISLE to LOOK FOR THE ITEM THAT I LEFT THERE. Even if they DID...? Oh wow. They could just hide it and STILL incriminate     |
# | someone if that's what they felt like doing. Why were they watching me...? Oh. Maybe they (SAW SOMETHING SUSPICIOUS/HAD PREJUDICE)       |
# | Weird. And then KATHERINE SUCHOCKI authorized an ARREST WARRANT because SHE has PREJUDICE. Just like how ROBERT RYBAK had PREJUDICE and  |
# | ignored MICHAEL ZURLO having (PREJUDICE/COMMITTING OBSTRUCTION OF JUSTICE) on MAY 26th, 2020... you know...?                             |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ____________________________________________________________________________________________________________________________________________
# | Looks like the JUDGES can (have PREJUDICE/act like a fucking COMMUNIST PARTY). Because with PREJUDICE...? Who cares about EVIDENCE...?   |
# | NOBODY. Not (1) soul, cares about EVIDENCE when people have DEVELOPED PREJUDICE towards a SPECIFIC INDIVIDUAL. ACTUALLY, here's another  |
# | diagram of how EVIDENCE works when you're like me, dealing with a long list of lazy fucks, right...?                                     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# __________________________________________________________________________________________________
# | Person         | When the evidence...     | it is...     | Result                              |
# |----------------|--------------------------|--------------|-------------------------------------|
# | Michael Cook   | DOES     INCRIMINATE HIM |     PROVIDED | ARREST WARRANT IS           ORDERED |
# |                | DOES NOT INCRIMINATE HIM | NOT PROVIDED | ARREST WARRANT IS STILL     ORDERED |
# |----------------|--------------------------|--------------|-------------------------------------|
# | Andrew Cuomo   | DOES     INCRIMINATE HIM |     PROVIDED | ARREST WARRANT IS       NOT ORDERED |
# |                | DOES NOT INCRIMINATE HIM |     PROVIDED | ARREST WARRANT IS STILL NOT ORDERED |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ____________________________________________________________________________________________________________________________________________
# | That's COMMUNISM 101, folks. Fuck how the law typically works. What they have...? Is a PEN, and a SIGNATURE... that's all they need.     |
# | If JUDGE PAUL PELAGALLI can order me to see (2) doctors that don't even work at the place he ordered me to go to...?                     |
# | Katherine Suchocki can order an arrest warrant with no evidence to support the reason for the arrest whatsoever.                         |
# | That's how JUDGES can get down, because facts are fuckin' stupid, folks.                                                                 |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"42:04",":So hearsay and lying sorta falls into the same s- hemisphere, because- they can provide FALSE TESTIMONY and it's never able to be proven. In fact, uh- the fact of the matter is that, uh-")
$T.AE(1,"42:32",":So then...")
$T.AE(0,"42:33",":You're saying, that if I can PROVE that I didn't take it, how would I be able to do that...? I don't have access to the CAMERA SYSTEM that they do.")
$T.AE(1,"42:32",":It's not so much that YOU have to PROVE that they lied, THEY have to PROVE that YOU DID, what they CLAIM YOU DID, just like if I had arrested you-") # You are processing my arrest... there's no "JUST LIKE..."
$T.AE(0,"42:49",":Right.")
$T.AE(1,"42:50",":...or signed a complaint...")
$T.AE(0,"42:49",":But that's what I'm saying...")
$T.AE(1,"42:52",":...I would be have- I would have to be able to prove, IN COURT-")
$T.AE(0,"42:55",":Right.")
$T.AE(1,"42:56",":...that you did, what you did.")
$T.AE(0,"42:58",":So THEY have to come to court and PROVE that I took something.")
$T.AE(1,"43:00",":That's gonna be up- the ADA has to prove that, yes.")
$T.AE(0,"43:03",":Ok.")
$T.AE(1,"43:00",":The ADA has to prove that you did what you (supposedly) did.") # I'm fairly certain that they don't have to do that at all.
$T.AE(0,"43:07",":Ok.")
$T.AE(1,"43:09",":Ok...? <pauses> Not us. And that's between HER, and WALMART, and YOU. Not the Sheriffs office.") 
$T.AE(0,"43:19",":Alright.")
$T.AE(1,"43:21",":Alright... hold on a second, let me make another phone call.")
$T.AE(1,"43:32",":You gonna come to court if I write you an appearance ticket...?")
$T.AE(0,"43:19",":Yeah, I'm not gonna, flee.")
$T.AE(1,"43:35",":Huh...?")
$T.AE(0,"43:36",":I'm not gonna flee or whatever")
$T.AE(1,"43:38",":Ok.")
$T.AE(5,"43:43",":<phone system>FIVE ONE EIGHT THREE THREE ZERO FIVE FIVE EIGHT THREE")
$T.AE(1,"43:51",":Hello judge, Deputy Sheriff from the Saratoga County Sheriffs Office, it's uh- Friday the sixteenth at about one-thirty in the afternoon...? Um, I have mister Cook here, he's been very cooperative, it's on your arrest warrant from Wednesday from the larceny out of Walmart <clears throat>, wondering what you wanna do, um- you can give my cell phone a call FIVE ONE EIGHT FOUR FIVE ZERO NINE NINE FOUR EIGHT. FIVE ONE EIGHT FOUR FIVE ZERO NINE NINE FOUR EIGHT, thank you. <hangs up the phone> See what the judge has got to say. More than likely it'll be (1) write you an appearance ticket, and (2) kick you free. <pauses> Alright...")
$T.AE(1,"44:35","*starts typing away at keyboard")
$T.AE(0,"44:42",":You know this system is uh- quite corrupt, right...?") # And, he does, because he later mentions something to that effect.
$T.AE(0,"44:47",":Like, in order to be able to ARREST somebody, a police officer is supposed to be able to CORROBORATE a story. So, if people are providing testimony-") 
$T.AE(1,"44:54",":If- again- again...")
$T.AE(0,"44:56",":Right.")
$T.AE(1,"44:57",":Again... ")
$T.AE(0,"44:58",":Even if the ADA-")
$T.AE(1,"44:58",":If it was US, if it was the police, signing the complaint, yeah. In this instance, it is NOT us signing the complaint, it is the WALMART LOSS PREVENTION guy, who signed the complaint. All WE basically did, was file the paperwork.")
$T.AE(0,"45:17",":Right.")
$T.AE(1,"45:18",":K...? Just so we, for us-")
$T.AE(0,"45:19",":What I'm saying, like- but what I'm saying is this... What if WALMART P- LOSS PREVENTION, just says 'Hey, that guy right there...? He stole somethin' from the store.' And then, they do that THOUSANDS OF TIMES to get INNOCENT PEOPLE in trouble. That's what I'm saying, is like, and then, there's a very real possibility-")
$T.AE(1,"45:37",":Well, at SOME point it's gonna come back to bite em, if they're not doin' their jobs correctly,") # This case IS that "point". That's my point. This case is gonna blow up in their face. I'm CERTAIN OF IT.
$T.AE(0,"45:41",":Ok, but what I'm saying is, if- the person... that's being ACCUSED... can't PROVE that they're innocent... and then, the party that IS making the accusation, seems to- I dunno.")
$T.AE(1,"45:59",":Well, that's- that's where the ATTORNEY comes in.")
$T.AE(0,"46:02",":Right, but if I don't HAVE money for an ATTORNEY, then I have to rely on a PUBLIC DEFENDER-")
$T.AE(1,"46:04",":Then you should be able to get- you should be able to get the, uh...")
$T.AE(0,"46:08",":Public defender.")
$T.AE(1,"46:10",":Public defender.")
$T.AE(0,"46:08",":Right, the public defenders office...? I seem to have a pretty, uh- hit-or-miss, circumstance with them. I had a FAMILY COURT case back in 2020 until November 4th, 2021.")
$T.AE(1,"46:24",":Yup.")
$T.AE(0,"46:25",":Uh- some woman, wrote a petition to the Family Court, which SLANDERED ME a bunch of different ways, it was AT or ABOUT THE TIME that my neighbor tried to hit me with his BASEBALL BAT, and then, ya know HE didn't get in trouble for that, even though I called 911 on him... So, uh- like I have an AUDIO RECORDING of my mother stating that I never went over onto that dude's property shouting obscenities, or that my neighbor grabbed the baseball bat out of FEAR, but you know, uh- even if I SEND the AUDIO RECORDING of my STEPFATHER ADMITTING THAT and my MOTHER ADMITTING THAT, to like, JOHN HILDRETH, the guy that was the uh- the SUPERIOR OFFICER, above James- er, above MARK SHEEHAN- what I'm SAYING, is that PEOPLE CAN COMMIT PERJURY TO ME, even if I LEGALLY CALL 911, and say my neighbor tried to hit me with his baseball bat, and then OTHER PEOPLE can just make up some OTHER BULLSHIT STORY, to get me in trouble. It seems to be a SERIAL case. Ya know...? Someone can try to MURDER ME on MAY 26th, and I call 911, but BOTH of my calls FAIL to make it to the dispatch station, and then someone can call 911 and say that I was jumping in front of their car, and that person could be the person trying to kill me. That's what I'm trying to say.")
$T.AE(1,"47:40",":Ok.")
$T.AE(0,"47:42",":And, when I tell SCOTT SCHELLING, JEFFREY KAPLAN, and JOSHUA WELCH, well, SCOTT SCHELLING asked me if he wanted- if I wanted to be arrested and brought to the jail, OR, he would ESCORT ME to my house. So- that's what I'm saying, is uh-")
$T.AE(0,"48:04",":I mean, like, look at it this way... if I wanna KILL somebody, right...?")
$T.AE(1,"48:08",":Yup.")
$T.AE(0,"48:08",":And, I call the police and say 'Yeah, this dude just jumped in front of my car', well...? I'm gonna- and I- if I worked IN the police, and I KNOW these tricks, right? Like these 2 kids DO, and I call the police and say 'Yeah, this kid just jumped in front of my car, and now I hit him. He's on the side of the road.' Well...? They're not gonna get in trouble, are they...?")
$T.AE(1,"48:34",":<makes exasperated sound> Well...") # Yeah, I think this guy knows I'm not faking this shit, now. Probably has to keep the thought to himself.
$T.AE(0,"48:36",":Right, dude just ran right in front of my car, and now he's dead. <pauses> Committed suicide, it was an ACCIDENT. I think you know what I'm tryin' to say.")
$T.AE(1,"48:55","*typing on keyboard")
$T.AE(0,"49:11",":This is what happened to my dad. <pauses> I dunno, there's something you're thinkin' and you're not verbalizing it, and that's- scaring me.")
$T.AE(1,"49:27",":You know what I'm thinkin' and I'm not verbalizing it...? Is that what you just said...?") # This is the first time that he's FULLY MIRRORED something I've stated, though it is NOT quite verbatim.
$T.AE(0,"49:32",":I'm uh- I'm making SPECULATIONS. I'm not ASSUMING that you're hearing me, and droning it out.") # I did at first, but NOW, I'm not thinking that.
$T.AE(0,"49:38",":I think you're processing some of what I'm saying, but I don't think you know how to REACT to it.") 
$T.AE(0,"49:50",":Like if I was wearin' a suit right now, and I had like uh- a golden watch, and uh, you know I had, a bunch of stuff that said 'this dude is incredibly rich', I don't even think I'd be here right now...")
$T.AE(1,"50:02",":Well, <clears throat> ok. Obviously you don't know me, and I don't know you, but I'm only gonna tell you this one time.")
$T.AE(0,"50:10",":Sure.")
$T.AE(1,"50:10",":I don't care what you wear, how much money you got, I really don't care.")
$T.AE(0,"50:16",":Ok.")
$T.AE(1,"50:16",":What I do, is I enforce the law. Evenly... Equally... Across the board...")
$T.AE(0,"50:22",":It doesn't SEEM that way.")
$T.AE(1,"50:22",":Huh...?")
$T.AE(0,"50:23",":I'm tryin' to tell you crimes that have been happening TO me, and nobody's DOING anything about that.")
$T.AE(1,"50:29",":Ok.")
$T.AE(0,"50:22",":But you're telling me- you're telling me that you're-")
$T.AE(1,"50:31",":But you- you want me to stop this and look into all of this stuff that you're tellin' me about, right now...? Right this second...?")
$T.AE(0,"50:35",":It would be helpful.")
$T.AE(1,"50:36",":I've gotta finish this FIRST,")
$T.AE(0,"50:39",":Ok.")
$T.AE(1,"50:39",":So that, YOU can be released, so I DON'T hold you ANY LONGER than I should...")
$T.AE(0,"50:44",":Right.")
$T.AE(1,"50:45",":Because of YOUR CONSTITUTIONAL RIGHTS...")
$T.AE(0,"50:47",":Sure, so I mean I respect that. I mean, I do understand.")
$T.AE(1,"50:50",":...and THEN, I can look into, whatever else, the 19 uh- or the, 2020 incident, and SCOTT SCHILLING, and WELCH, and all the rest of em, but FIRST-")
$T.AE(0,"51:04",":Ok.")
$T.AE(1,"51:05",":I need to complete THIS, again, so I don't hold you ANY longer than I have to, and I don't VIOLATE your CONSTITUTIONAL RIGHTS by doing that.")
$T.AE(0,"51:15",":Ok.")
$T.AE(1,"51:16",":So, I'm- I AM listening-")
$T.AE(0,"51:18",":Ok.")
$T.AE(1,"51:18",":I'm ALSO trying to multitask... <pauses> And again, I- I don't care WHAT you wear, how- HOW important you are, ye- YOU could be the president sittin' there, if you violated the law, and I have what I need, to do my job... I'm gonna do my job.")
$T.AE(0,"51:35",":Ok.")
$T.AE(1,"51:36",":Regardless...")
# ________________________________________________________________________________________
# | So, just to put it into context...? The man just told me the fuckin' game plan.      |
# | He literally just told me who's who, what's what, and... that's that.                |
# | So, if the bad guys are out there, reading this...? That means it's game over, dude. |
# | Time for you fucks to wave a white flag, cause... you just lost right there.         |
# | Here's a diagram of what this man just said...                                       |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ________________________________________________________________________________________________________
# | If you are...      | And you have...             | And HE has...               | You are...          |
# |--------------------|-----------------------------|-----------------------------|---------------------|
# |        COOL enough | Broken the law              | What he NEEDS to do his JOB | Fucked, pal.        |
# |    NOT COOL enough | Broken the law              | What he NEEDS to do his JOB | Still fucked, pal.  |
# |      the President | Broken the law              | What he NEEDS to do his JOB | STILL fucked, pal.  |
# | Hillary R. Clinton | Leaked classified docs      | What he NEEDS to do his JOB | Fucked, lady.       |
# |       Andrew Cuomo | sexually harasses 11 women  | What he NEEDS to do his JOB | REAL fucked, dude.  |
# |  Julien P. Assange | exposed gov't breaking laws | What he NEEDS to do his JOB | WICKED fucked, pal. |
# |  Edward J. Snowden | exposed gov't breaking laws | What he NEEDS to do his JOB | WICKED fucked, pal. |
# |    Michael C. Cook | Doesn't steal something     | What he NEEDS to do his JOB | A douchebag, dude.  |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ________________________________________________________________________________________________________
# | Dude's probably gonna catch wind of this and think that I'm TEASING him, but no. I'm not.            |
# | I'm just certain that it's gonna come off as if I'm teasing him when I'm being serious.              |
# | In "LAW ENFORCEMENT 101", cops are supposed to have this attitude. However, uh-                      |
# | What does an OFFICER OF THE LAW NEED TO DO THEIR JOB...? Evidence. Or an order.                      |
# | Or like, a pyramid of labyrinthian laden textbooks that outline STATUTES, LAWS, and REGULATIONS...   |
# | basically a PHD in SARATOGA COUNTY SHERIFFS OFFICE CODE and CONDUCT, which doesn't exist.            |
# | If you're in an AIRPLANE, and that AIRPLANE is flying over SARATOGA COUNTY... and this dude finds    | 
# | out that you committed a crime in that airplane...? THEN, you're fucked.                             | 
# | I am kidding around, here. I am actually teasing this guy a fair amount, not because I'm poking fun  |
# | at HIM, but I know for a god damn fact that OTHER OFFICERS in HIS UNIT, they THINK OF WAYS TO BREAK  |
# | THE LAW... legally. Because, why the hell not...? Breaking the law, LEGALLY... is stupid. But, that  |
# | is ACTUALLY WHAT SOME OF HIS COWORKERS DO.                                                           |
# | Regardless, IF THIS GUY MEANS WHAT HE SAYS, and SAYS WHAT HE MEANS...? I'll take it.                 |
# | Because, that mentality means that he DOES HAVE INTEGRITY.                                           |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"51:37",":Alright, I believe you.")
$T.AE(1,"51:40",":And you know, it's nothin' against YOU...<pauses>")
$T.AE(1,"51:48",":How much did you say you weigh...?")
$T.AE(0,"51:50",":About 150 pounds.")
$T.AE(1,"51:51",":150...? Ok.")
$T.AE(0,"51:53",":The only counterpoint I'm gonna made to what-")
$T.AE(1,"51:55",":Yup.")
$T.AE(0,"51:55",":-make to what you just said... I don't think you have anything against me, but- the end result is uh- <sigh> this is, uh-")
$T.AE(1,"52:04",":Well... you- you're basically, correct in the aspect that I do not- uh, the only thing that I have, is an arrest warrant signed by a sitting judge, here in the town of Halfmoon. Ok...?")
$T.AE(0,"52:19",":Right.")
$T.AE(1,"52:20",":Based on the information (hearsay) that they were provided by WALMART... ok...?")
$T.AE(0,"52:28",":Right.")
$T.AE(1,"52:28",":Is what she based on, she based the warrant on.") # Every time I hear him repeat this, it makes me laugh. Not his fault, but because of how stupid it is.

# ________________________________________________________________________________________________________________
# | So if WALMART LOSS PREVENTION GUY typically has EVIDENCE to provide in a COMPLAINT to make it LEGITIMATE...? |
# | They didn't NEED that this time, nah. It SOUNDS STUPID, right...? But, in THIS case, it isn't cause it's ME. |
# | It is probably because THEY think I'm stupid, and that MUST mean that since they FEEL like I'm stupid? I am. |
# | And, they're NOT stupid at all... especially if they don't feel like they are. Nah. So, it is what it is.    |
# | I'm stupid, they're not, it's over. Argument basically over and done. However, uh- here's the problem.       |
# | If they didn't NEED EVIDENCE in THIS CASE...? Why would they ever NEED EVIDENCE in ANY case...? Ya know...?  |
# |--------------------------------------------------------------------------------------------------------------|
# | Basically, if a judge is handed a COMPLAINT based on HEARSAY, then the WARRANT based on HEARSAY is why I was |
# | ARRESTED. Because, you know, APPARENTLY I've SUPPOSEDLY been known for stealing things, and have never been  |
# | caught. Even now. Not caught. Suspected. No evidence. Suspiscion and evidence...? Not equal, dude.           |
# | Which means that they just see a guy that looks suspicious. That's it. That's (PREJUDICE -> DISCRIMINATION). |
# |--------------------------------------------------------------------------------------------------------------|
# | Which means, no evidence led to that WARRANT being written. Just someone making up a story.                  |
# | That's strange, right...? In a store where many people are caught taking stuff ON VIDEO...? I wasn't caught  | 
# | taking anything on video... so, if I wasn't caught on video, then they can just say that I took something in |
# | a complaint, because it FELT like they PRACTICALLY SAW ME, taking something... and THAT'S effectively worth  |
# | writing a fucking arrest warrant.                                                                            |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"52:32",":The question, that I have here, is this.")
$T.AE(1,"52:33",":Yup.")
$T.AE(0,"52:36",":If WALMART can, you know, uh- have me ARRESTED, for this in- particular incident, why am I not able to do that, when people commit more serious crimes to me, and I have EVIDENCE of it...? That's what I'm sayin', saying.")
$T.AE(1,"52:55",":Well, I can't- I can't answer that question, because I was not there at the time that this happened, so...")
$T.AE(0,"53:02",":Ok. But- uh, you weren't at WALMART at the time that they made this, complaint.")
$T.AE(1,"53:10",":Correct, I was. Ok, and you're not, apparently I'm not explaining it correct.")
$T.AE(0,"55:19",":Or, when they made the complaint, you were there. What I'm saying is that when the incident supposedly occurred-")
$T.AE(1,"53:28",":Yup.")
$T.AE(0,"53:28",":You were not there.")
$T.AE(1,"53:28",":What about it...?")
$T.AE(0,"53:28",":I guess um, this- we're getting lost in SPECIFICS, here... but- what I'm suggesting is that, if there IS an incident, where uh- a police officer, has arrived, and a crime is reported to them, and no action is taken by the police officer, in support of what I have provided as testimony, and INSTEAD what happens is, three people provide false testimony, to the police officer that shows up, well what happens is that a crime is committed, and then an additional crime is committed, and then, uh- I wind up paying the piper for calling 911. Or, someone has remote access to my phone, and I dial 911 and they prevent the call from making it to the dispatch station, I believe that what's happening is people must think that I'm FABRICATING that, that I called 911, and that I had evidence of it, and I told SCOTT SCHELLING about the evidence of my 911 call being at CENTER FOR SECURITY.")
$T.AE(0,"54:36",":What I'm saying is that a SERIAL KILLER, is covering their tracks. And, you're going around following uh- the- the- phone call of somebody at WALMART that probably, you know, saw me, and decided to write the statement they did. And they didn't have to prove it.")
$T.AE(0,"54:55",":So, even, whether I have to prove it in court, or not- what's happening is they can just make up some bullshit, and then get me in trouble.")

$T.AE(0,"00:00",":")
$T.AE(1,"00:00",":")
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
# 01:04:25, 0,, "I'm trying to make a comparison or a metaphor. What you're doing right now is not too different from what I just said."
# 01:04:49, 0,, "OJ Simpson can kill Ron Goldman and his, and uh- Nicole Simpson, and can commit a heinous crime"

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
