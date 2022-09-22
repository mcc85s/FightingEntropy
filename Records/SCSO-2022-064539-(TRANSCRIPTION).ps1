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
            "^\*{1}" { "Action" } "^\:{1}" { "Statement" } "^\#{1}" { "Note" }
        }
        $This.Note     = $Note.Substring(1)
    }
    [String] ToString()
    {
        Return "[{0}] <{1}> {2}" -f $This.Time, $This.Party.Initial, $This.Note
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
    [Object[]] GetOutput()
    {
        Return $This.Output | Select-Object Index, Party, Time, Position, Note
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
$T.AddParty("Katherine Suchocki")

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ [Part 1 (00:00:00 -> 00:07:59)]: Outside (Being arrested via COMPLAINT w/out EVIDENCE)         ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

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

# _____________________________________________________________________________________________________________________________________
# | "You're aware that there's no surveillance in that aisle" <- You have to PROVE that, not ASSUME that.                             |
# | "You walked out of the store, and then went back into the store, went back to the aisle, and then pointed at where you left it."  |
# | Nah. "Did anyone SEE that...?" Nah. Nobody SAW that at all.                                                                       |
# | Which means that I left the item in that aisle when the guy from "loss prevention" pointed at me. Oh.                             |
# | So that's how I know that the LAW MEN and WALMART are CUTTING CORNERS.                                                            |
# | AKA, violating my CONSTITUTIONAL RIGHTS as a CITIZEN and MAKING ASSUMPTIONS about what was NOT SEEN BY ANYBODY.                   |
# |-----------------------------------------------------------------------------------------------------------------------------------|
# | What I can state with sheer certainty, is that there IS VIDEO FOOTAGE THAT CLEARLY SHOWS THAT NOBODY WENT BACK TO THAT AISLE      |
# | BEFORE STOPPING ME IN THE VESTIBULE. Ohhhhhhhhhhh. Shit. Nobody at Walmart Loss Prevention went back to that fucking aisle.       |
# | That's fuckin' weird, right...? But I mean, NOW since MICHAEL SHERIDAN NEVER COLLECTED THE SUPPORTING VIDEO EVIDENCE... as in,    |
# | MICHAEL SHERIDAN probably did not say "Hey, put this fuckin evidence on a thumbdrive or email it to me right now so that it can"  |
# | be entered with a SPECIFIC HASH CODE with a TIME and DATE that is UNABLE TO BE ALTERED BY ANYBODY AFTER I LEAVE TO GET A WARRANT. |
# | That's the part that I think MICHAEL SHERADIN did not do AT ALL.                                                                  |
# |-----------------------------------------------------------------------------------------------------------------------------------|
# | NOW WALMART HAS NO MEANS OF BEING ABLE TO PROVE THAT THEY SENT ANYBODY TO THAT AISLE TO FIND THE ITEM THAT NEVER LEFT THAT AISLE. |
# | But, suppose they did. NOW the (2) dudes can just put those SAME EXACT CLOTHES back on, and then like, send a guy to that aisle,  |
# | and then walk through the aisle and come out the other end, and put their arms up and be like 'Well, fuck, no item that the dude  |
# | SUPPOSEDLY took, aw shucks...' The fact of the matter is this... LAW ENFORCEMENT and the JUSTICE SYSTEM is SO CORRUPT, that they  |
# | don't actually have to PROVE a god damn thing. Otherwise, I wouldn't have been ARRESTED. Nope.                                    |
# |-----------------------------------------------------------------------------------------------------------------------------------|
# | Seems like I'm making a pretty big fuckin' deal about a fucking item that costs $18.88 right...? That's what morons will assume.  |
# | Nah, the point is a manner of PRINCIPLE about WHAT I'M BEING ACCUSED OF WITHOUT FUCKING EVIDENCE. It will CONTINUE TO HAPPEN TO   |
# | ME, because I know for a fucking fact that the police are working EXTRA HARD with the fuckin' justice system to just look for any |
# | possible means to incriminate ANYBODY for ANY fucking reason whatsoever. That's because some of them are FUCKING STUPID.          |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 2 (00:07:59 -> 00:28:11)]: Within (SEDAN 4138/SCSO Michael Sheradin)                     ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

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

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 3 (00:28:11 -> 00:28:45)]: Walking into Halfmoon (Sheriff Substation/Town Court)         ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

$T.AE(1,"28:11",":We're gonna head right in those doors, up the stairs, and to the left.")
$T.AE(1,"28:39","*shuffles with keys to open the office door")
$T.AE(1,"28:43","*Unlocks the office door")
$T.AE(1,"28:45","*Opens the office door")

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 4  (00:28:35 -> 01:03:56)]: Michael Sheradin processes my "arrest" order                 ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

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
$T.AE(0,"54:55",":So, even, whether I have to, prove it in court, or not- what's happening is, they can just make up some bullshit, and then get me in trouble.")
$T.AE(0,"55:07",":It- it- it's a serial case. One person, can tell the truth, about what happened, and another person, with more quote unquote CREDIBILITY, can say 'Oh, this OTHER story happened. Even though I have NO EVIDENCE OF IT...? I'm SAYING that that's what happened.' and-")
$T.AE(1,"55:25",":Right.")
$T.AE(0,"55:25",":-then, you arrest somebody based on THAT.")
$T.AE(1,"55:30","*entering keys*")
$T.AE(0,"55:45",":So if George Bush, and the CIA manipulated Osama Bin Laden into attacking the World Trade Center in 1993, so they could get the oil fields in Kuwait...")
$T.AE(1,"56:00",":Ok.")
$T.AE(0,"56:01",":Well, what happened is that 8 years later, Osama Bin Laden will attack AGAIN, and the CIA and whoever else, will... line the entire exoskeleton of the Twin Towers as well as World Trade Center 7 with THERMITE and EXPLOSIVE PACKAGES, whereby causing an incident known as 'CONTROLLED DEMOLITION'.")
$T.AE(0,"56:23",":And then he'll have the National Institute of Standards and Technology say that, uh- the PLANES are the reason why the buildings fell.")
$T.AE(1,"56:31",":Ok.") # It seems to me that he IS processing what I'm saying. I know he's MULTITASKING... but he's not suggesting that what I'm saying is fuckin' stupid... yet.
$T.AE(0,"56:33",":The planes are not the reason why those buildings fell. It was an act of SABOTAGE by people in the United States. So that they could have a reason to go fight a war in the middle east.")
$T.AE(1,"56:45","*entering keys*")
$T.AE(1,"57:09",":Alright... <long sigh>")
$T.AE(0,"57:16",":Uvalde Elementary, do you remember that...?")
$T.AE(1,"57:20","*entering keys*")
$T.AE(1,"57:50",":What's the zip code up there at mom's...? 12118 or 12065...?")
$T.AE(0,"57:54",":12065.")
$T.AE(1,"57:57",":That's what I thought.")
$T.AE(0,"57:54",":What I'm sayin' is like, I can have evidence, of, like, ME DOING SOMETHING...? That CONTRADICTS the STATEMENT that somebody's making to the police, and you guys never collect that, or take it seriously.")
$T.AE(1,"58:13",":Ok. What's your <clears throat> What's your social security number...?")
$T.AE(0,"58:18","*Primary party muted audio recording")
$T.AE(0,"58:24","*Primary party unmuted audio recording")
$T.AE(1,"58:25",":<entering keys> Ok.")
$T.AE(0,"58:32","So, if my mother says that uh, I, uh- had her in a chokehold, and whatever...")
$T.AE(1,"58:37",":Right.")
$T.AE(0,"58:38",":And says that to the state police, and then the, state police, attempt to arrest me...?")
$T.AE(1,"58:44",":Ok...?")
$T.AE(0,"58:46",":But I have an audio recording of the entire interaction between me and my mother, and she doesn't make any mention, that I think she had something to do with conspiring to murder my father...?")
$T.AE(1,"58:54",":Ok.")
$T.AE(0,"58:57","Why is it that my uh- evidence is never collected...? nobody's taking that seriously. If I state that my mother made a FALLACIOUS STATEMENT to the police, on June 28th, 2020 (I meant 2022), and I have an AUDIO RECORDING of what happened that morning...? And they arrest me as soon as I tell that that thing was UPLOADED BEFORE she made her 911 call...? Oh. That's how I know that there's PREJUDICE being applied to me. and you're taking part of it, right now.")
$T.AE(1,"59:25",":Ok. <pause> Well, I disagree with that, ya know...") # He's not KNOWINGLY doing this, he's TAKING PART of it. ARRESTING someone based on HEARSAY. That's PREJUDICE. Essentially, I'm GUILTY until I prove myself INNOCENT, and even if I PROVE MYSELF INNOCENT, I'm still considered GUILTY. That's PREJUDICE.
$T.AE(0,"59:29",":I'm sure you do...")
$T.AE(1,"59:31",":Cause I've tried to explain this to ya several times...") # He does not understand what I'm saying. That's the end of the argument.
$T.AE(0,"59:34",":But I understand what you're saying... (I obviously understand what he's saying) I don't think you're understanding, what I'm saying...")
$T.AE(1,"59:38",":I understand EXACTLY what you're saying... ")

# ___________________________________________________________________________________________________________________________________
# | I really do not think that he does. When I say PEOPLE have developed PREJUDICE toward me...? What that means is this...         |
# | If I am INNOCENT of something...? PEOPLE THAT HAVE DEVELOPED PREJUDICE TOWARD ME will AUTOMATICALLY treat as if I am GUILTY.    |
# | It actually falls under a genre called DISCRIMINATION. That's actually PRETTY DIFFICULT TO PROVE, unless you're ME, & it isn't. |
# | Therefore, because of the NUMEROUS PEOPLE on this RETARDED WHEEL OF PREJUDICE, it doesn't matter:                               |
# | _______________________________________________________________                                                                 |
# | | Whether I'm INNOCENT, OR, whether I can PROVE my INNOCENCE. |                                                                 |
# | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                 |
# | Wanna know why...? That's how PREJUDICE works. If I say (1) thing, and people AUTOMATICALLY assume that there MUST be some      |
# | other explanation...? In some cases, that's actually PREJUDICE, because they're treating me as if I'm ALREADY GUILTY.           |
# | It's not LEGAL for people to do this, but people do it anyway, because of how stupid a lot of people in our society really are. |
# | But- if it happens ENOUGH TIMES...? That's DISCRIMINATION. If it can be PROVEN, reliably, that there is a PATTERN, of this...?  |
# | That can result in someone's PROFILE being DAMAGED to the point where everything they say is ignored. So if someone attempts    | 
# | to MURDER SOMEBODY that has EVIDENCE of the MURDER ATTEMPT...? Then this DISCRIMINATION thing will force MICHAEL ZURLO to       |
# | commit OBSTRUCTION OF JUSTICE. Or, Pelagalli to sentence me to (20) days in the county jail when i've noticed his court sending |
# | emails for virtual appearances that were all OFFSET by (5) hours. So, appearances for 9AM will be emailed to me as 2PM, and     |
# | then I will MISS my appearances because some lazy morons failed to do their job correctly, and then they just KEPT DOING THAT.  |
# |---------------------------------------------------------------------------------------------------------------------------------|
# | So what I'm suggesting is this:                                                                                                 |
# | If a JUDGE can ORDER me to a fucking MENTAL HEALTH CLINIC to see (2) doctors that DON'T EVEN WORK THERE...                      |
# | And then I tell the judge that court order he wrote was WRITTEN IN ERROR...?                                                    |
# | He's going to SENTENCE ME TO (20) DAYS IN THE SARATOGA COUNTY JAIL for telling him that he wrote an ORDER INCORRECTLY.          |
# | So, if you think that's stupid...? Well, think again, fuckface. HE made that mistake. THAT MEANS, it's MY FAULT, not HIS...     |
# | It's just your OPINION that he made a mistake, and you're not even ALLOWED to tell the judge, what your OPINION is, either.     |
# | Because. It's against the law to tell a judge that they made a mistake, and it is INCREDIBLY OFFENSIVE, too.                    |
# | If what I'm saying sounds retarded...? Too bad.                                                                                 |
# | You HAVE to do what I do, and RECORD THE COURT INTERACTION which they MADE ILLEGAL, because a bunch of whiny bitches like       |
# | NEIL WEINER exist. They don't care about CONSTITUTIONAL RIGHTS or COURTS SENDING WRONG VIRTUAL APPEARANCE TIMES IN EMAILS, nah. |
# | NEIL WEINER thinks that shit is stupid. But, YOU...? RECORDING A COURT INTERACTION WHERE A JUDGE ADMITS HE MADE A MISTAKE...?   |
# | That's worth AT LEAST (20) DAYS IN THE COUNTY JAIL, ya fuck. Fuck you for trying to make an official judge look careless.       |
# | Cause that shit is AGAINST THE LAW, even if it really SHOULDN'T BE. "Fuck your constitutional rights, dude." -Neil Weiner       |
# | So at that point, I have to talk about how 20 * $285 = $5700 that Judge Paul Pelagalli owes me FOR THAT PARTICULAR MISHAP.      |
# | But ALSO... lets whip out the SARATOGA COUNTY RETARDED WHEEL OF PREJUDICE courtesy of SARATOGA COUNTY FAMILY COURT:             |
# |---------------------------------------------------------------------------------------------------------------------------------|
# | SARATOGA COUNTY RETARDED WHEEL OF PREJUDICE                                                                                     |
# | EVIDENCE and the INCIDENT that ALL of these RETARDED PEOPLE BELOW, NEVER INVESTIGATED...                                        |
# | https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt                                     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Person
{
    [UInt32] $Index
    [String] $Name
    [String] $Description
    Person([UInt32]$Index,[String]$Name,[String[]]$Description)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.Description = $Description -join "`n"
    }
}

Class PersonList
{
    [Object] $Output
    PersonList()
    {
        $This.Output = @( )
    }
    Add([String]$Name,[String[]]$Description)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Person already specified"
        }

        $This.Output += [Person]::New($This.Output.Count,$Name,$Description)
    }
}

$People = [PersonList]::new()
$People.Add("SCSO Scott Schelling",
            ("Dude who was the FIRST PERSON ON THE SCENE at the ZAPPONE DEALERSHIP after 2 25-30 year old white males attempted to murder me using PEGASUS/PHANTOM.",
            "Guy attempted to arrest me because he didn't understand that I tried to call 911 multiple times after almost being killed near COMPUTER ANSWERS.",
            "Asked me MULTIPLE QUESTIONS at 201D HALFMOON CIRCLE, CLIFTON PARK, NY 12065 at 0155AM and then never wrote any notes about those questions.",
            "I believe he had some hand in DESTROYING THE EVIDENCE of my 2nd 911 call at CENTER FOR SECURITY that I made at 05/26/20 0010.",
            "Caused me to believe that SCSO has some DIRTY OFFICERS ON STAFF THAT INDISCRIMINATELY COMMIT CRIMINAL ACTIVITIES and NEVER GET CAUGHT."))

$People.Add("SCSO Mark Sheehan",
            ("I do not believe that this dude is a MALICIOUS cop, based on multiple interactions, however, on 06/13/20, this man IGNORED my STORY about how ",
            "my neighbor, WILLIAM MOAK, threatened to kill me from his kitchen window, and then ran onto my property with a baseball bat in his hand out of 'FEAR',",
            "except there was no 'out of FEAR' aspect, there was an 'out of FRUSTRATION' aspect where this man attempted to assault me with that baseball bat",
            "on my fucking property, and then my STEPFATHER MICHAEL H. STREETER, and JANET MOAK, had to RESTRAIN WILLIAM MOAK from ASSAULTING ME WITH THE BAT...",
            "on my fucking property... not HIS... and then (3) people provided FALSE TESTIMONY on a WRITTEN INSTRUMENT, AKA committed PERJURY.",
            "Also, same guy came to my house on 08/31/20 when I called the police because I suspected that my MOTHER, FABIENNE S. COOK, had something to do",
            "with conspiring to murder my father, MICHAEL EDWARD COOK, because she kept WALKING AWAY FROM ME when I talked about my father's murder.",
            "Here's a link to the AUDIO transcription from JUNE 28th, 2022 that sorta suggests the same fucking thing...",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Records/2022_0831-(Mom%2006-28-2022).ps1 <- Aw. My poor mother committed PERJURY on 06/28/22."))

$People.Add("NYSP Trooper Borden",
            ("Dude who somehow works with the NEW YORK STATE POLICE, but is incredibly fucking stupid. Doesn't know what ESPIONAGE or PHANTOM/PEGASUS are.",
            "Dude actually doesn't CARE if I keep calling him STUPID, or that SCSO CLAYTON BROWNELL heard the ENTIRE INTERACTION between us on 06/17/20 at GT Toys.",
            "Basically, I asked TROOPER BORDEN for an ESCORT to the local FBI FIELD OFFICE or a MILITARY FACILITY because I had EVIDENCE in the EVIDENCE LIST...",
            "But he thought that shit was retarded. Evidence is stupid in his eyes, and THAT'S what makes him such a reliable NYSP Trooper.",
            "Here's a link to the EVIDENCE LIST that TROOPER BORDEN IGNORED...",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt <- Aw. A lot of morons exist in SARATOGA COUNTY."))

$People.Add("Laura Hughes",
            ("Some bitch from SARATOGA COUNTY CHILDRENS PROTECTIVE SERVICES who wrote a FRAUDULENT LETTER OF INDICATION on June 18th, 2020",
            "Probably never looked at a SINGLE EXHIBIT on this list...",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt"))

$People.Add("SCSO Michael Whiteacre",
            ("Dude who came to my house with SCSO MARK SHEEHAN on 06/18/20 when Laura Hughes was there, asking questions about the 2 dudes on 05/26/20.",
            "Dude has probably never looked at an entire list of evidence either, so when I paste...",
            "https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt",
            "...he's gonna have no idea how to look at any of that shit... and that's why he's such a reliable police officer isn't he...?",
            "He will later have a conversation in this transcription that I'll have to UNPACK and EXAMINE in order to POTENTIALLY INCRIMINATE HIM..."))

$People.Add("Heather Corey Mongue",
            ("Some bitch that I sent an EMAIL to, about WHO I was investigating, SUPPOSEDLY practices law, but needs a MENTAL HANDICAP applied...",
            "Probably doesn't understand this exhibit here:",
            "https://drive.google.com/file/d/1y05kPm-CjVIALi6r8CNPMlIRnXvMtPpD <- Aw. Heather Corey-Mongue was told about this before this FAMILY COURT case."))

$People.Add("SCSO Michael Zurlo",
            "Guy who supposedly runs SARATOGA COUNTY SHERIFFS OFFICE, but ALSO needs a MENTAL HANDICAP applied, commits OBSTRUCTION OF JUSTICE indiscriminately")

$People.Add("SCSO James Leonard",
            "Plays with his dick in a bathtub all day, and calls that being a COUNTY SHERIFF, also commits OBSTRUCTION OF JUSTICE indiscriminately")

$People.Add("Eric Catricala",
            "Supposedly a STATE ASSEMBLYMAN, runs a FUNERAL HOME that is ACROSS THE STREET FROM COMPUTER ANSWERS, lived at 20 ANCHOR DRIVE")

$People.Add("Bruce Tanski",
            "Gay bastard who owns the TANSKI CORPORATION and FAIRWAYS OF HALFMOON, commits BANK FRAUD, PAYS PEOPLE like MICHAEL ZURLO to shut the fuck up alot.")

$People.Add("John Hoffman",
            "Gay bastard that my SON and I ran into on MAY 25th, 2020 BEFORE I recorded IMG_0625.mov walking to my aunt TERRI COOK's house, talked about COIN MAGIC")

$People.Add("Terri Cook",
            "Goes around and arrests people's dogs indiscriminately... used to live at 10 INNISBROOK, worked with law firms and district attorneys in Albany")

$People.Add("Thomas Cook",
            "My uncle that doesn't realize that his building that he used to own at 46 STATE STREET, ALBANY, was basically taken by the KGB, and AUNT TERRI.")

$People.Add("Paul Pelagalli",
            "Guy who literally ordered me to go see (2) doctors (Berger|Grodin) at SARATOGA COUNTY MENTAL HEALTH, but neither of them worked there...")

$People.Add("Sarah Schellinger",
            "Some bitch that was apppointed to be my PUBLIC DEFENDER, but sorta sucked ass at it so badly that I TERMINATED HER in AUGUST 2020.")

$People.Add("John Delong",
            ("Another public defender that had no right to be my DEFENSE ATTORNEY on 10/5/2021 or 11/4/2021, advised me my TRIAL DATE was on 11/7/2021.",
            "The case that I'm making is that if I have EVIDENCE OF HAVING TERMINATED SARAH SCHELLINGER in AUGUST 2020...",
            "But then, my TERMINATED PUBLIC DEFENDER just so happened to have TRANSFERRED HER CASELOAD TO ANOTHER PUBLIC DEFENDER...",
            "How the fuck could she do that with MY SPECIFIC CASE, if I have EVIDENCE of TERMINATING HER, in AUGUST of 2020...?",
            "Well, it's because some morons exist in the SARATOGA COUNTY PUBLIC DEFENDERS OFFICE. Are they ALL morons...? Nah. But, SOME of them ARE.",
            "Because lets look at it like this... If I'm the kid from PET CEMETERY, and my fuckin' cat dies...? I'm gonna go bury my cat.",
            "However, uh- apparently if you decide to do that to a PUBLIC DEFENDER, they're gonna return from the seventh circle of hell, right...?",    
            "And NOW... that fuckin' dead cat that you buried is BACK from the dead. 'How DARE you fire my ass... I'm your FREE LAWYER...'",
            "Now you're REAL fucked, dude... cause. They're gonna HAUNT you for the rest of your days... taunting you from behind mirrors and shit."))

<#
Index Name                   Description
----- ----                   -----------
    0 SCSO Scott Schelling   Dude who was the FIRST PERSON ON THE SCENE at the ZAPPONE DEALERSHIP after 2 25-30 year old white males attempted to murder me 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   using PEGASUS/PHANTOM. Guy attempted to arrest me because he didn't understand that I tried to call 911 multiple times after 
                             almost being killed near COMPUTER ANSWERS. 

                             Asked me MULTIPLE QUESTIONS at 201D HALFMOON CIRCLE, CLIFTON PARK, NY 12065 at 0155AM and then never wrote any notes about those 
                             questions. I believe he had some hand in DESTROYING THE EVIDENCE of my 2nd 911 call at CENTER FOR SECURITY that I made at:
                             05/26/20 0010. Caused me to believe that SCSO has some DIRTY OFFICERS ON STAFF THAT INDISCRIMINATELY COMMIT CRIMINAL ACTIVITIES 
                             and NEVER GET CAUGHT.

    1 SCSO Mark Sheehan      I do not believe that this dude is a MALICIOUS cop, based on multiple interactions, however, on 06/13/20, this man IGNORED my 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      STORY about how my neighbor, WILLIAM MOAK, threatened to kill me from his kitchen window, and then ran onto my property with a 
                             baseball bat in his hand out of 'FEAR', except there was no 'out of FEAR' aspect, there was an 'out of FRUSTRATION' aspect where 
                             this man attempted to assault me with that baseball bat on my fucking property, and then my STEPFATHER MICHAEL H. STREETER, and 
                             JANET MOAK, had to RESTRAIN WILLIAM MOAK from ASSAULTING ME WITH THE BAT...  on my fucking property... not HIS... and then (3) 
                             people provided FALSE TESTIMONY on a WRITTEN INSTRUMENT, AKA committed PERJURY.

                             Also, same guy came to my house on 08/31/20 when I called the police because I suspected that my MOTHER, FABIENNE S. COOK, had 
                             something to do with conspiring to murder my father, MICHAEL EDWARD COOK, because she kept WALKING AWAY FROM ME when I talked 
                             about my father's murder.
                             
                             Here's a link to the AUDIO transcription from JUNE 28th, 2022 that sorta suggests the same fucking thing...
                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/2022_0831-(Mom%2006-28-2022).ps1 
                             (^ Aw. My poor mother FABIENNE SILVIE KIVLEN-COOK committed PERJURY on 06/28/22.)

                             I don't really have anything against this dude, apparently he works for COHOES POLICE DEPARTMENT last time I checked.

    2 NYSP Trooper Borden    Dude who somehow works with the NEW YORK STATE POLICE, but is incredibly fucking stupid. Doesn't know what ESPIONAGE or PEGASUS
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     or PHANTOM, are. Dude actually doesn't CARE if I keep calling him STUPID, or that SCSO CLAYTON BROWNELL heard the ENTIRE 
                             INTERACTION between us on 06/17/20 at GT Toys.

                             Basically, I asked TROOPER BORDEN for an ESCORT to the local FBI FIELD OFFICE or a MILITARY FACILITY because I had EVIDENCE in 
                             the EVIDENCE LIST... But he thought that shit was retarded. Evidence is stupid in his eyes, and THAT'S what makes him such a 
                             reliable NYSP Trooper.

                             Here's a link to the EVIDENCE LIST that TROOPER BORDEN IGNORED...
                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt 
                             (^ Aw. A lot of morons exist in SARATOGA COUNTY.)
                             
    3 Laura Hughes           Some bitch from SARATOGA COUNTY CHILDRENS PROTECTIVE SERVICES who wrote a FRAUDULENT LETTER OF INDICATION on June 18th, 2020
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯           Probably never looked at a SINGLE EXHIBIT on this list...
                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt

    4 SCSO Michael Whiteacre Dude who came to my house with SCSO MARK SHEEHAN on 06/18/20 when Laura Hughes was there, asking questions about the 2 dudes 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ on 05/26/20. Dude has probably never looked at an entire list of evidence either, so when I paste...
                             
                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt
                             
                             ...he's gonna have no idea how to look at any of that shit... and that's why he's such a reliable police officer isn't he...?
                             He will later have a conversation in this transcription that I'll have to UNPACK and EXAMINE in order to POTENTIALLY 
                             INCRIMINATE HIM... (which is the polar opposite of how I wrote about him in my book...)

                             Apparently started dating some girl named BRIANNA DYER, who I believe is associated with TATIANA CLEVELAND.
                             Ya know...? My cousin RYAN "BOOKIE/PENCILDICK" WARD's ex-girlfriend...? There's no way all these people could possibly KNOW
                             each other, is there...? No fuckin' way, dude... Nah. People...? Knowing each other...? That's preposterous. 

    5 Heather Corey-Mongue   Some bitch that I sent an EMAIL to, about WHO I was investigating, SUPPOSEDLY practices law, but needs a MENTAL HANDICAP 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯   applied... Probably doesn't understand this exhibit here:

                             https://drive.google.com/file/d/1y05kPm-CjVIALi6r8CNPMlIRnXvMtPpD 
                             (^ Aw. Heather Corey-Mongue was told about this before this FAMILY COURT case. Sorta links MICHAEL EDWARD COOK and
                             JESSE PICKETT, which means NFRASTRUCTURE. Doh~! Morons all over the place OVERLOOKED THAT FACTOID~!)

    6 SCSO Michael Zurlo     Guy who supposedly runs SARATOGA COUNTY SHERIFFS OFFICE, but ALSO needs a MENTAL HANDICAP applied, commits OBSTRUCTION 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     OF JUSTICE indiscriminately, and has been OBSERVED BEING INVOLVED IN PROCEDURALLY SMEARING ME IN MULTIPLE RECORDS.

    7 SCSO James Leonard     Plays with his dick in a bathtub all day indiscriminately, and calls that being a COUNTY SHERIFF.
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     Also commits OBSTRUCTION OF JUSTICE indiscriminately, probably WHILE playing with his dick in a bathtub all day.
                             In the end, who knows...?

    8 Eric Catricala         Supposedly a STATE ASSEMBLYMAN, runs a FUNERAL HOME that is ACROSS THE STREET FROM COMPUTER ANSWERS, lived at:
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯         20 ANCHOR DRIVE. Basically friends with the ol' Leonardmeister extraordinaire. Doesn't realize how retarded he looks by
                             attempting to merge multiple incidents into the same ticket, so May 24th 2020 ~ 7pm, and May 25th 2020 ~ 1130pm, in 
                             the same ticket doesn't look suspicious at all to either JAMES LEONARD, or SCOTT CARPENTER. Nah. That's cause they're
                             fuckin' morons that backdated a ticket SCSO-003177 from May 27th, 2020 at 1414, to like, reported on May 24th, 2020.
                             That's stupid, right...? Well, think again ya fuck. It's not that stupid at all. These clues slipped by EVERYBODY.

    9 Bruce Tanski           Gay bastard who owns the TANSKI CORPORATION and FAIRWAYS OF HALFMOON, commits BANK FRAUD, PAYS PEOPLE like MICHAEL 
    ¯ ¯¯¯¯¯¯¯¯¯¯¯¯           ZURLO to shut the fuck up alot, and hangs out with JOHN HOFFMAN a lot behind closed door meetings. Probably does the
                             same exact thing that James Leonard does in his favorite bath tub at 9 MEYER ROAD.

   10 John Hoffman           Gay bastard that my SON and I ran into on MAY 25th, 2020 BEFORE I recorded IMG_0625.mov walking to my aunt TERRI 
   ¯¯ ¯¯¯¯¯¯¯¯¯¯¯¯           COOK's house, talked about COIN MAGIC. IMG_0625.MOV and IMG_0627.MOV are BOTH in the EXHBIT LIST...

                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt

                             Michael Whiteacre doesn't realize how stupid he looks for not looking into these events on that list.

   11 Terri Cook             Goes around and arrests people's dogs indiscriminately... If your dog is running around without a leash...?
   ¯¯ ¯¯¯¯¯¯¯¯¯¯             She has to show up and arrest your dog for walking around without one. That means, dog jail.
                             She used to live at 10 INNISBROOK, worked with law firms and district attorneys in Albany.
                             
                             I think she has worked with RUSSIAN INTELLIGENCE and had involvement in: CONSPIRACY TO MURDER MICHAEL EDWARD COOK.
                             I also talk about her in the EVIDENCE that I told SCOTT SCHELLING I had UPLOADED, at COMPUTER ANSWERS...

                             https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt
                             Notice how I keep posting that link...? Well, that's because of how many stupid people exist on planet earth.
                             I keep trying to provide this shit to the AUTHORITIES...? But, they do what MICHAEL WHITEACRE does, and ignore it.

                             Does anybody understand why I have to INSULT guys like MICHAEL WHITEACRE...? It's cause he isn't DOING HIS JOB.

   12 Thomas Cook            My uncle that doesn't realize that his building that he used to own at 46 STATE STREET, ALBANY, was basically taken 
   ¯¯ ¯¯¯¯¯¯¯¯¯¯¯            by the KGB, and AUNT TERRI.

                             My uncle did NOTHING as far as I know, in attempting to have me killed for any reason, nor my father.
                             However, UH- HE OBVIOUSLY TRUSTS PEOPLE THAT ARE A SIGNIFICANT FUCKING THREAT.
                             
   13 Paul Pelagalli         Guy who literally ordered me to go see (2) doctors (Berger|Grodin) at SARATOGA COUNTY MENTAL HEALTH, but neither of 
   ¯¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯         them worked there... Seems to be so oblivious to the notion that DIRTY COPS and SOCIAL SERVICE WORKERS caused him to
                             REVOKE CUSTODY OF MY FUCKING CHILDREN, and he doesn't understand that I had to work harder than all these people...
                             ...at compiling this fuckin' evidence list, and searching for a way to CLEAR MY FUCKING NAME.

                             Probably has no idea that the people who CONSPIRED TO MURDER MY FATHER, ATTEMPTED TO DO THE SAME THING TO ME.
                             Cool...? Cool. That's what happened, broski. Thanks for nothin'.

   14 Sarah Schellinger      Some bitch that was apppointed to be my PUBLIC DEFENDER, but sorta sucked ass at it so badly that I TERMINATED HER 
   ¯¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯      in AUGUST 2020.

   15 John Delong            Another public defender that had no right to be my DEFENSE ATTORNEY on 10/5/2021 or 11/4/2021, advised me my TRIAL 
   ¯¯ ¯¯¯¯¯¯¯¯¯¯¯            DATE was on 11/7/2021. The case that I'm making is that if I have EVIDENCE OF HAVING TERMINATED SARAH SCHELLINGER 
                             in AUGUST 2020... 
                             
                             But then, my TERMINATED PUBLIC DEFENDER just so happened to have TRANSFERRED HER CASELOAD TO ANOTHER PUBLIC DEFENDER.

                             How the fuck could she do that with MY SPECIFIC CASE, if I have EVIDENCE of TERMINATING HER, in AUGUST of 2020...?

                             Well, it's because some morons exist in the SARATOGA COUNTY PUBLIC DEFENDERS OFFICE. Are they ALL morons...? Nah. 
                             But, SOME of them ARE. Because lets look at it like this... 
                             
                             If I'm the kid from PET CEMETERY, and my fuckin' cat dies...? I'm gonna go bury my cat, and cry like a little bitch.

                             However, uh- apparently if you decide to do that to a PUBLIC DEFENDER, they're gonna return from the seventh circle 
                             of hell, right...? And NOW... that fuckin' dead cat that I buried...? Cat's BACK from the dead. 
                             'How DARE you fire my ass... I'm your FREE LAWYER...'
                             
                             Now you're REAL fucked, dude... cause. 
                             They're gonna HAUNT you for the rest of your days... taunting you from behind mirrors and shit.
#>

# ____________________________________________________________________________________________________________________________________________
# | With me so far...? Laura Hughes wrote a FRAUDULENT LETTER OF INDICATION on 06/18/20 because she's stupid.                                |
# | For the most part, so is everyone else in this list. Because they're too busy having PREJUDICE and NOT HAVING THEIR FACTS STRAIGHT...    |
# | That when someone attempts to CORRECT their INCORRECT FACTS... they will say 'That's just your opinion, dude. Now fuck off, errand boy.' |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$CPSDATE = "06/18/20"

$Days       = @{ 

    Elapsed = [TimeSpan]([DateTime]"09/20/22"-[DateTime]$CPSDATE)
    Remain  = [TimeSpan]([DateTime]"11/04/23"-[DateTime]"09/20/22")

}

$EarthDays = $Days.Elapsed.Days + $Days.Remain.Days

# ____________________________________________________________________________________________________________________________________________
# | $Earth Days = 1234                                                                                                                        |
# | 1,234 days that I had custody of my children taken away because a NUMBER OF PEOPLE IN THE COMMUNITY, have developed PREJUDICE toward me. |
# | and that's mainly because SOMEONE LIKE ME, isn't ALLOWED to tell people how fuckin' stupid they ARE, or SOUND. Because, that's MEAN.     |
# | Even if I am correct...? The WAY in which I tell someone how fuckin' stupid they are, CANNOT BE 1) MEAN, or 2) INCORRECT.                |
# |------------------------------------------------------------------------------------------------------------------------------------------|
# | Ultimately what that means is this...                                                                                                    |
# | The SARATOGA COUNTY RETARDED WHEEL OF PREJUDICE courtesy of MULTIPLE SARATOGA COUNTY SERVICES...                                         |
# | They're not going to come right out and say "Well, maybe we ARE retarded after all" or...                                                |
# | ..."Maybe we took custody of this dude's kids in error", even though I told NYSP Trooper Borden that-                                    |
# | SOMEONE WAS COMMITTING ESPIONAGE TO ME ON MY IPHONE 8+ and I have MULTIPLE FUCKING EXHIBITS OF THAT.                                     |
# | And, that's ok. That's why I have a fucking REALLY LARGE ($300M) LAWSUIT to file against SARATOGA COUNTY                                 |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(1,"59:41",":You think I'm doin' this because I'm prejudice, which I'm not.") # Nah, I'm not saying that HE has prejudice, but the JUDGE apparently does.
$T.AE(0,"59:44",":Nope. That's not what I'm saying. That isn't what I'm saying at all. What I'm saying is that the people that wrote this statement, have prejudice toward me. Because they decided to write this statement that YOU think is PROBABLE CAUSE, but it could be a FIGMENT of their imagination. And then, on the OTHER END of the SPECTRUM, when SOMETHING happens to ME, and I'm NOT making shit up, and I have EVIDENCE to support my, uh- STATEMENT... It's not COLLECTED... ")

# ___________________________________________________________________________________________________________________________________________
# | But also, the people at WALMART are EXHIBITING that they DEFINITELY have PREJUDICE toward me because why would they be WATCHING ME...?  |
# | They don't watch EVERYBODY that walks in there, there's no fucking way that they could do that.                                         |
# | In order to watch EVERYBODY that walks in there, and leaves the store with 1) something or 2) nothing...                                |
# | ...they'd have to be PREPPED AND READY AHEAD OF TIME. Sorta like a MILITARY OPERATION. Sorta like VIOLATING SOMEONE'S RIGHTS...         |
# | ...in order to DETERMINE when someone is exhibiting SUSPICIOUS BEHAVIORS. Just like the TWIN TOWERS and WTC 7 were rigged with THERMITE |
# | and EXPLOSIVES on Tuesday, September 11th, 2001...? These guys at WALMART LOSS PREVENTION saw a reason to WATCH MY EVERY MOVE.          |
# | How did they know how to prepare for that AHEAD of time...? It's because the SURVEILLANCE SYSTEM probably FLAGGED MY ACTIVITY.          |
# | That's actually UNCONSTITUTIONAL. The SURVEILLANCE SYSTEM THAT THEY HAVE, has a FACIAL RECOGNITION SOFTWARE that identifies EVERY       | 
# | individual that walks into the store... and they'll have this cool little BOX that floats above somebody's face as they walk around the |
# | store. People don't have to be exhibiting ANY SUSPICIOUS ACTIVITY AT ALL, and they can just watch a PARTICULAR INDIVIDUAL WALK IN, and  |
# | WALK OUT... and then that person can be FLAGGED AS SOMEONE SUSPICIOUS. That's SYSTEMATIC PREJUDICE right there.                         |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(1,"01:00:15",":I'm not sayin' you're makin' ANYTHING up, to be honest with ya, I mean...")
$T.AE(0,"01:00:19",":Ok. Uh- Thats beside the point. You don't have to SAY that at all, your ACTIONS can prove that.")
$T.AE(1,"01:00:26","*Silent for 10 seconds")
$T.AE(0,"01:00:37",":Look, I'm gonna level with you...I'm very aware of the fact that, you know, that you have some DIRTY OFFICERS on your unit. And MICHAEL ZURLO is one of them, and BRUCE TANSKI has been committing BANK FRAUD with JOHN HOFFMAN. And he was investigated by, uh- people in an FBI probe, but the people in the FBI are also si- in on it. So I'm aware that SOME people in your unit are involved, in committing CRIMINAL ACTIVITIES, and, you can keep doing it, uh- THEY can keep doing it, I'm not gonna ASSUME that you're, PART of this ring of people, but- your unit- the people in it, that are complicit, they can continue to perform these activities... and then, you know, you'll process me based on some people at Walmart Loss Prevention, making a, imagined scenario up. But, the REAL scenarios that I've been reporting, to the police, they go un... unaddressed.")
$T.AE(0,"01:01:33",":So, it leads to incidents such as Uvalde Elementary, where uh- someone winds up taking a gun and shooting 19 kids and 2 teachers, meanwhile Ted Cruz gets a whole bunch of money from ExxonMobil. You know, that's mu- that's bribery, by the way.")
$T.AE(0,"01:01:50",":Did you kno- do you know what BRIBERY is...? That's a- LAW, right...?")
$T.AE(1,"01:01:53",":Yup.")
$T.AE(0,"01:01:50",":You said, you uphold, the law, EQUALLY, right...? <pauses> That's a thing. Is that, that's not, ACCURATE if... Ted Cruz can accept BRIBERY from ExxonMobil, and nobody does anything about it.")
$T.AE(0,"01:02:12",":Or, well... people DO something about it, they just ALLOW it to happen. So, 19 kids and 2 teachers get shot down, and then- and in another month it'll be another HEINOUS event, and then the month after that'll be another HEINOUS event...")
$T.AE(0,"01:02:24",":Meanwhile, uh- guys like BRUCE TANSKI, they own FAIRWAYS OF HALFMOON, and they basically tell you guys WHAT TO DO, and THEY can steal money from the bank, and, some od you guys... will HELP. Or, per- if someone makes a phone call saying 'Hey I see SOME suspicious activity', and it has something to do with BRUCE TANSKI...? Oh, well, it's BRUCE TANSKI, so let's just, ignore THAT...")
$T.AE(1,"01:02:49",":Why's this-")
$T.AE(0,"01:02:50",":So, the thing I'm alluding to here is that, you're taking action on something rather insignificant and miniscule, in the grand scheme of things... while WORSE things are happening, they're being REPORTED, but- they're not being enforced.")
$T.AE(1,"01:03:06",":Do me a favor then, if you would, stand in front of that GRAY WALL...")
$T.AE(5,"01:03:21","*camera shutter making noises*")
$T.AE(0,"01:03:37",":<Indiscernable, clothing shuffling>")
$T.AE(1,"01:03:41",":What's that...?")
$T.AE(0,"01:03:42",":Do I need to continue standing here...?")
$T.AE(1,"01:03:41",":Uhhhh, nope, I'm gonna have you come over here, so I can take your fingerprints. You got all your fingers...?")
$T.AE(0,"01:03:48",":Yeh.")
$T.AE(1,"01:03:51",":Alright, come out here...")
$T.AE(1,"01:03:54","*Opens door latch")

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 5 (01:03:56 -> 01:17:58)]: Sheradin processes my fingerprints but needs help             ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

$T.AE(0,"01:03:57",":This is ridiculous. <Indiscernable, clothing shuffling, movement>")
$T.AE(1,"01:04:05",":C'mon over here...")
$T.AE(0,"01:04:05",":So if I run into a billionaires knife... and I get it all bloody, you guys are gonna arrest me for that.")
$T.AE(1,"01:04:11",":Do... do WHAT now...?")
$T.AE(0,"01:04:13",":If I run into a BILLIONAIRES BLOODY KNIFE, and I get myself hurt and I'm injured badly, you guys are gonna arrest me for that.")
$T.AE(1,"01:04:23",":Why would we arrest you for that...?")
$T.AE(0,"01:04:25",":I'm trying to make a, comparison or a metaphor. So what you're- you're- what you're doing right now, is not TOO DIFFERENT, from what I just said.")
$T.AE(0,"01:04:49",":OJ Simpson can kill Ron Goldman and his, and uh- Nicole Simpson, right...? Dude can commit a HEINOUS CRIME.")
$T.AE(1,"01:05:17",":Put four fingers out flat...")
$T.AE(0,"01:05:08",":Where someone innocent gets to be, recorded... ya know...? Well, he was, recorded.")
$T.AE(1,"01:05:30",":Alright, next right thumb...")
$T.AE(0,"01:05:38",":Ya know...? George Bush should be like, charged for fuckin' TREASON. Why isn't he...? Or, OJ Simpson should be IN PRISON for murdering his wife and Ron Goldman. Why isn't he...?")
$T.AE(1,"01:05:53",":Cause they took it to trial, and the jury ACQUITTED him.") # I'm aware of that, I'm asking rhetorical questions that pertain to answers such as 1) MONEY and 2) IMPORTANCE.
$T.AE(0,"01:05:57",":Right")
$T.AE(1,"01:05:58",":Because the prosecution could NOT PROVE that he did what he did.")
$T.AE(0,"01:06:03",":K.") # That is NOT the correct answer. The correct answer is that 1) MONEY OJ Simpson had, and 2) IMPORTANCE of JOHNNY COCHRAN, overrode the evidence. That's it. That's why the PROSECUTION could not "prove" that OJ Simpson did, what he did. A lot of people were PRETTY FUCKING PISSED about the OUTCOME of the trial. but that is the POWER of MONEY, ladies and gentlemen. The truth is fuckin' stupid.
$T.AE(0,"01:06:19",":Nah, the reason he got away with it is because he was rich enough to do it. He had JOHNNY COCHRAN as his defense. 'If the glove don't fit...? You must acquit.' So what's happening is like, uh- Hillary Clinton can LEAK classified information, and be investigated by the FBI, what I'm saying is that the law enforcement administration, or system, is SELECTIVE about enforcing the law, and so is the justice system.")
$T.AE(0,"01:06:49",":Uh, if it's somebody that you guys LIKE, they don't ever get in trouble, they can literally KILL people, in COLD BLOOD, and then-")
$T.AE(1,"01:07:00",":Why is there no match found...? <long sigh>")
$T.AE(0,"01:07:25",":I'm gonna tell you the REAL REASON why I'm here. You're not arresting me for the mouse, that I didn't steal. You're arresting me because, someone ordered you to do this.")
$T.AE(1,"01:07:34",":<chuckles> Do you know how stupid that fuckin' sounds...?")
$T.AE(0,"01:07:38",":Well...")
$T.AE(1,"01:07:39",":Do you have any idea how dumb that fuckin' sounds...?") # KATHERINE SUCHOCKI ordered the arrest with her WARRANT. It SOUNDS dumb, but it's ACCURATE.
$T.AE(0,"01:07:38",":Meh, it's spot on.")
$T.AE(1,"01:07:44",":Nah, I disagree...")
$T.AE(0,"01:07:46",":Somebody wanted-")
$T.AE(1,"01:07:46",":And so far you-, you've pretty much basically told me I don't know how to do my job...")
$T.AE(0,"01:07:51",":Not saying that at all.")
$T.AE(1,"01:07:51",":Or that I REFUSE to do my job CORRECTLY...")
$T.AE(0,"01:07:53",":Not saying that at all.")
$T.AE(1,"01:07:54",":And I'm REALLY taking offense to that...")
$T.AE(0,"01:07:57",":Well...")
$T.AE(1,"01:07:54",":K, so... <exasperated sigh>")
$T.AE(0,"01:07:59",":What I'm saying is uh-")
$T.AE(1,"01:08:00",":<clears throat> Nobody ORDERED me to do this (except WALMART LOSS PREVENTION, and KATHERINE SUCHOCKI...). This is my job, like I told you BEFORE, I do my job REGARDLESS of WHO YOU ARE.")

# __________________________________________________________
# | This man does his job REGARDLESS of WHO YOU ARE. So... |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ________________________________________________________________________________________________________
# | If you are...      | And you have...             | And HE has...               | You are...          |
# |--------------------|-----------------------------|-----------------------------|---------------------|
# |      the President | Broken the law              | What he NEEDS to do his JOB | Fucked, pal. So...  |
# |    Michael C. Cook | Doesn't steal something     | What he NEEDS to do his JOB | Fucked, pal. So...  |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# ______________________________________________________________________________
# | DON'T PISS THIS DUDE OFF... FOR ANY REASON... WHATSOEVER.                  |
# | So, if you're in a fuckin' plane, flying over Saratoga County...           |
# | flying on AIR FORCE ONE for christ sake...                                 |
# | And, you literally break the law in this dude's jurisdiction...?           |
# | AND... he finds out that you did it...?                                    |
# | WELL... if he has what he NEEDS to do his JOB...?                          |
# | You're fucked. End of the conversation. It's over. Done. Jail time, dude.  |
# | At the end of the day, don't break the law, and you'll never have to worry |
# | about THIS particular dude, flying in on a blaze of glory, to arrest you.  |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:08:11",":Ok.")
$T.AE(1,"01:08:11",":Ok...? And I really take offense...") # Believe it or not, this is a GOOD attribute to this dude. Cause someone who IS offended will get pissy about it.
$T.AE(0,"01:08:15",":But what I'm saying, is there' NO EVIDENCE, that says I did this.")
$T.AE(1,"01:08:19",":Ok~! I'm gonna- I'm... <sighs>")
$T.AE(0,"01:08:21",":Even if I- look, what I'm trying to suggest is this... I can be some innocent person, that didn't commit a crime, and someone can write an AFFADAVIT, and basically provide a RECORD of FALSE TESTIMONY on a written instrument.")
$T.AE(1,"01:08:36",":Do you think people don't do that every day...?") # I'm aware that they do that every day. But it KEEPS HAPPENING TO ME. SPECIFICALLY. JUDGES AND SHIT DOING IT TOO.
$T.AE(0,"01:08:38",":I'm- I am CERTAIN, that they do it every day.")
$T.AE(1,"01:08:40",":Ok...? And don't you think my job is to INVESTIGATE and SEE, whatever it is they're claiming somebody did...? Is that my job...?")
$T.AE(0,"01:08:49",":If you're saying, that YOU investigated this...? What I'm saying is WHAT did you investigate...?")
$T.AE(1,"01:08:54",":I'm saying, well, number 1 you were in the store, cause I got all the video, number 2, you walked out of the store, went back in the store, and went back to that same aisle, ok...?")
$T.AE(0,"01:09:05",":I didn't-") # I have provided testimony that LINES UP with that. He's not hearing me. Never did I ARGUE that I was there... 
$T.AE(1,"01:09:05",":Now...")
$T.AE(0,"01:09:06",":Ok...?")
$T.AE(1,"01:09:06",":Ok...?")
$T.AE(0,"01:09:06",":That's where I- that's where the item was left...")
$T.AE(1,"01:09:09",":Ok. Whatever. I didn't sign the complaint. I did not sign the complaint.") # Whatever, dude. Whether the ITEM was left there, or not...? Doesn't matter cause... you wouldn't have guys following you for no reason.
$T.AE(0,"01:09:14",":But-")
$T.AE(1,"01:09:15",":Walmart, signed the complaint.")
$T.AE(0,"01:09:17",":I understand that...")
$T.AE(1,"01:09:18",":Based on a Walmart complaint (which is as trustworty as a US Savings Bond), we take the paperwork, and s- ubmit it to the court.")
$T.AE(0,"01:09:25",":I understand all that.")
$T.AE(1,"01:09:25",":That is our job.")

# ______________________________________________________________________________________
# | Analogy: How CREDIBLE is a COMPLAINT from WALMART, without VIDEO...? It isn't.     |
# |------------------------------------------------------------------------------------|
# | It is AS CREDIBLE, as a WHORES WORD from a WHOREHOUSE...                           |
# | So if a WHORE says "I love you", but then she goes and fucks some OTHER DUDE...?   |
# | That's basically the definition of LOVE right there.                               |
# |------------------------------------------------------------------------------------|
# | If that sounds RETARDED...? Too bad. That's just YOUR OPINION, and NOBODY ELSES.   |
# | The only reason it SOUNDS retarded, is because you're an idiot to think otherwise. |
# | Legally speaking, you're not even ALLOWED to say that shit sounds RETARDED.        |
# | So technically, at any fucking moment whatsoever...?                               |
# | I could LEGALLY be ARRESTED, and charged for having an UNLAWFUL STUPID OPINION...  |
# | ...for saying all of this.                                                         |
# | Because, it's ILLEGAL to have an opinion, or draw up clever metaphors/comparisons. |
# | WAY illegal, dude.                                                                 |
# |------------------------------------------------------------------------------------|
# | Cause when she's right in the MIDDLE of being pounded out by some OTHER DUDE...?   |
# | That's the moment where she's thinkin' about how much she LOVES ya.                |
# | What a fuckin' sweetheart.                                                         |
# |------------------------------------------------------------------------------------|
# | That's how CREDIBLE a COMPLAINT from WALMART actually is, without VIDEO.           |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:09:25",":I understand all of that.")
$T.AE(1,"01:09:26",":Then, why do you keep trying to blame ME...")
$T.AE(0,"01:09:28",":I'm NOT blaming you.")
$T.AE(1,"01:09:29",":For not doin' my job, and...")
$T.AE(0,"01:09:31",":What I'm saying that the job you did, wasn't very thorough.")
$T.AE(1,"01:09:35",":It WAS thorough.")
$T.AE(0,"01:09:36",":There's NO EVIDENCE that suggest that I did what they did.") # The evidence actually incriminates THEM, if that isn't CLEAR enough.
$T.AE(1,"01:09:39",":Ok, and again, I'm not pursuing the charges. Walmart is. I am ONLY making the ARREST.") # That's what I have a problem with.
$T.AE(0,"01:09:46",":Ok.")
$T.AE(1,"01:09:47",":Based on the judges order.")
$T.AE(0,"01:09:49",":Hold on, let me make- let me make a statement. To- to make this perfectly clear. If I say, that 2 guys, tried to murder me...")
$T.AE(1,"01:10:01",":Alright, you got- you gotta get off that, ye- <sigh>") # People are making the TRAUMATIC SITUATION WHERE I STILL HAVE EVIDENCE, seem RIDICULOUS.
$T.AE(0,"01:10:04",":Why...?")
$T.AE(1,"01:10:05",":It's- it's TOTALLY irrelevant.") 

# ____________________________________________________________________________________________________________________________________
# | It isn't IRRELEVANT at all. I have EVIDENCE of that ATTACK, and my statement was NEVER TAKEN.                                    |
# | People are IGNORING IT, TREATING IT AS IF IT'S FUCKING RIDICULOUS...                                                             |
# | Meanwhile, WALMART SAYS "fuck this guy. Here's what I say." and THAT is NOT being treated as if it's FUCKING RIDICULOUS AT ALL.  |
# | That's basically PREJUDICE 101.                                                                                                  |
# |----------------------------------------------------------------------------------------------------------------------------------|
# | If WALMART says SOMETHING about somebody and HAS  NO EVIDENCE...? POLICE AND JUDGES (DO     TAKE ACTION/   MANUFACTURE EVIDENCE) |
# | If I       say  SOMETHING about somebody and HAVE    EVIDENCE...? POLICE AND JUDGES (DO NOT TAKE ACTION/DESTROY+IGNORE EVIDENCE) |
# |----------------------------------------------------------------------------------------------------------------------------------|
# | The ONLY reason that people think that whole above diagram might be RIDICULOUS...? Is because they're stupid. That's it.         |
# | They might be STUPID if they can't determine that my FATHER, MICHAEL EDWARD COOK, had this SAME EXACT PROBLEM with the POLICE... |
# | Where the POLICE just treated my father as if HE was fucking ridiculous all the time, and then his 911 calls went ignored...     |
# | So if my father called 911 on October 23rd, 1995...? The police obviously thought that was fucking ridiculous, and thus those    |
# | calls from his MCI phone card went right into the trash. Certain 911 calls are stupid.                                           |
# | "Oh, it's Michael Cook calling 911, that is fucking stupid." <- What actually happened to my father, AND ME... but people are    |
# | FAILING TO TAKE MY STATEMENT AND EVIDENCE SERIOUSLY. That's why I have to resort to calling people fucking stupid.               |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:10:07",":It- it IS relevant. Because, eh- something happened to me...? And nobody DOES anything about it. Or, they DID do something about it, but they ignored it.")
$T.AE(0,"01:10:26",":I can tell um- you're feeling rather insulted, and think that I'm underestimating your ability to do your job, and that's NOT what I'm saying.")
$T.AE(1,"01:10:35",":You're underme- you're BASICALLY sayin' I'm a crook like the rest of the fuckin' clowns that you're claimin'. And I'm NOT.")
$T.AE(0,"01:10:42",":No, what I'm saying is, ")
$T.AE(1,"01:10:42",":My integrity.")
$T.AE(0,"01:10:44",":Selective.")
$T.AE(1,"01:10:45",":And I'm not one of em.")
$T.AE(0,"01:10:46",":Ok.")
$T.AE(1,"01:10:47",":Ok...? So, basically you're insultin' my integrity, and I REALLY, have an issue with that.")
$T.AE(0,"01:10:53",":Ok.")
$T.AE(1,"01:10:53",":Not to be a dick, bud... <clears throat> and it's not y- all- since I picked ya up, you've indicated pretty much, that I don't-")
$T.AE(0,"01:11:03",":I'm trying to be, very- <indiscernable>-")
$T.AE(1,"01:11:05",":I get it.")
$T.AE(0,"01:11:05",":-about what I'm saying, I'm not trying to ruffle your feathers, and I think that's what's happening. You're emotionally reacting to what I'm saying, but you're not processing the words.")
$T.AE(1,"01:11:11",":Because you're continuing to INSULT my integrity. And THAT'S... <scoffs>")
$T.AE(0,"01:11:17",":Ok.")
$T.AE(1,"01:11:18",":Ya know...? And-")
$T.AE(0,"01:11:20",":Well, if YOU believe that you have integrity, what I'm suggesting is this... after, this is done... will you investigate what happened in multiple incidents...?")
$T.AE(1,"01:11:28",":Didn't I already tell ya that...? What did I tell ya...?")
$T.AE(0,"01:11:30",":Ok, well if-")
$T.AE(1,"01:11:31",":I said I gotta get this done first-")
$T.AE(0,"01:11:32",":Ok.")
$T.AE(0,"01:11:33",":So that I'm not holdin' you past your unconstitutional, uh- time...")
$T.AE(0,"01:11:39",":Sure.")
$T.AE(0,"01:12:22",":Eh, I dunno. Maybe I deserved to be killed that night. <pauses> I dunno, I think I've been a fuckin', shitty person my whole life, basically.")
$T.AE(1,"01:12:34",":I don't think you're a shitty person...")
$T.AE(0,"01:12:38",":Well, everyone else seems to think I am.")
$T.AE(1,"01:12:41",":Well... again, I'm not everybody else. I don't judge a book by it's cover, or anything.")
$T.AE(5,"01:12:49","*<indiscernable chatter, clothing and occasional tapping until 01:13:17>")
$T.AE(1,"01:13:17",":<indiscernable> Left little finger again... <more hard to hear chatter>")
$T.AE(0,"01:13:47",":I used to do this for Fieldprint.")
$T.AE(1,"01:13:48",":Huh...?")
$T.AE(0,"01:13:50",":I used to do this for Fieldprint.")
$T.AE(1,"01:13:53",":What is Field print...?")
$T.AE(0,"01:13:54",":It's a Federal service that takes peoples' fingerprints.") # I think, not totally positive of that.
$T.AE(1,"01:13:58",":Oh.")
$T.AE(0,"01:13:59",":Cause I used to use- do this same thing.")
$T.AE(1,"01:14:16",":I don't know WHY we're having such a hard time here...") # Taking people's fingerprints is a pain in the ass. (CIA/Express Lane) has high demands.
$T.AE(0,"01:14:28",":Want me to try to do it...? I used to do this. Go ahead, try it again.")
$T.AE(1,"01:14:37",":I'm just gonna do this... delete it.")
$T.AE(0,"01:14:37",":Well, I can-")
$T.AE(1,"01:14:42",":No match found... right index.")
$T.AE(0,"01:14:45",":Right index...?")
$T.AE(1,"01:14:46",":Yep, that's what they're tellin' me...")
$T.AE(1,"01:15:08",":Try one more time...")
$T.AE(0,"01:15:20",":Here, let me try.")
$T.AE(1,"01:15:22",":Alright... whatever.")
$T.AE(0,"01:15:26",":Ready...?")
$T.AE(1,"01:15:26",":Yup.") # Dude was probably BORN ready.
$T.AE(5,"01:15:33","*<indiscernable, clothing shuffling around>")
$T.AE(0,"01:15:47",":Yeah, hold on, try it again.")
$T.AE(1,"01:15:51",":Alright...")
$T.AE(0,"01:16:14",":There ya go.")
$T.AE(1,"01:16:15",":Nah, it says it's a... it said it was a different finger... <indiscernable> It wants the right ring finger.")
$T.AE(0,"01:16:23",":Oh, the right ring finger, sorry. I thought that was uh- (little finger/pinky)")
$T.AE(1,"01:16:38",":What was this one, no match found... left index.")
$T.AE(1,"01:16:52",":Insufficient roll. <pauses> I dunno, try it one more time.")
$T.AE(1,"01:17:02",":Too dark. Don't push down as hard.")
$T.AE(0,"01:17:06",":Ok.")
$T.AE(1,"01:17:14",":<Indiscernable, noises> Alright, beautiful. Alright.")
$T.AE(1,"01:17:24",":Alright, that takes care of that. Now, if you want <indiscernable> sign that these are your fingerprints. <indiscernable> Hold on.")
$T.AE(1,"01:17:37",":Alright, that's all you're signing is that these are your fingerprints that I just took.")
$T.AE(1,"01:17:44",":Alright... Have a seat back in there. <Opens latch> Get ya outta here <indiscernable>.")
$T.AE(1,"01:17:55","*Closes door latch")

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 6 (01:17:58 -> 01:30:48)]: Sheradin finalizes processing my arrest                       ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

$T.AE(1,"01:19:39",":Hello judge, deputy sheriff from Saratoga County Sheriffs Office. Today is *checks watch* Friday the SIXTEENTH of SEPTEMBER...? At about 10 after 2. I was tryin' to get ahold of judge Suchocki, uh- she's not answerin' her phone, I've called several times, I have Michael Cook here on a warrant and I was looking to HOPEFULLY release him on an appearance ticket, my number's FIVE ONE EIGHT FOUR FIVE ZERO NINE NINE FOUR EIGHT. Thank you.")
# ________________________________________________________________________________________________________________________________
# | I mean, just imagine if this dipshit MICHAEL ZURLO did the same fucking thing for me, right...?                              |
# | Called my ass to discuss the events of SCSO-2020-028501...? But, that's fuckin' stupid...                                    |
# | cause why would this dude ever think to call me back regarding a night where I was almost killed to death...?                |
# | Ya know...? Multiple 911 calls not making it to the dispatch station...? MAYBE, maybe... pretending it didn't happen         |
# | doesn't incriminate him at all, and therefore, calling ME delusional...? Rather than EVER HAVING A CONVERSATION ABOUT IT...? |
# | Maybe it just means he's WAY too busy doin' some shit, being the top notch Saratoga County Sheriff that he is.               |
# |------------------------------------------------------------------------------------------------------------------------------|
# | Michael Zurlo: Hello, Michael Cook, headmaster sheriff from Saratoga County Sheriffs Office.                                 |
# |                Today is it-doesn't-actually-fuckin'-matterday, and it doesn't matter what fuckin' time it is...              |
# |                I was just calling you to tell you what a stupid son-of-a-bitch you are...?                                   |
# |                You suck at life...? Your mother...?                                                                          |
# |                Everything about you is fuckin' stupid, including how you look, and you're a real dumb motherfucker...        |
# |                You vain son-of-a-bitch...                                                                                    |
# |                Stop throwing my name all over the fuckin' place.                                                             |
# |                I'm busy.                                                                                                     |
# |                Fuck off.                                                                                                     |
# |------------------------------------------------------------------------------------------------------------------------------|
# | Ya know...? I'd respect the dude a whole lot more if he at least left me a message on my voicemail that said that.           |
# | Then, I would have this story to tell about how Michael Zurlo literally left a voicemail that told me to fuck off.           |
# | He and I both know that Michael Zurlo would LOVE to leave me a voicemail just like that...? But then, at the same time, it'd |
# | be a real stupid idea because he and I both know that it would make him look like an ASSHOLE, and therefore... it's stupid.  |
# | Doesn't change the fact that he does, in fact, feel that way toward me. Why...? Cause he's killed a lot of people. So...     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$T.AE(1,"01:20:09",":Alright, hopefully the judge calls me back... <pauses> One of em... <pauses> Alright, here's your ID.")
$T.AE(0,"01:20:26",":Thank you.")
$T.AE(0,"01:20:27",":Yep. <pauses> Do you believe that there's serial killers here, in uh- in town...?")
$T.AE(1,"01:20:32",":There MIGHT be some in the county, somewhere... They're all over the place...")
$T.AE(0,"01:20:26",":There're some of em in, your uh- unit.")
$T.AE(1,"01:20:51","*Keyboard -> tappity tap, tap, tapperoo, dude.")
$T.AE(1,"01:21:32",":C'mon judge... <indiscernable>")
$T.AE(0,"01:21:50",":What's Deputy Pirrone's first name, do you know...?")
$T.AE(1,"01:21:52",":Anthony.") # (Traffic Safety/Scrotum chin/Shoulder-phone) cop the 5th, Anthony Pirrone was stalking me on June 17th, 2020 at Boomer McCloud Plaza.

# ____________________________________________________________________________________________________________________________________
# | About shoulder-phone cop the 5th, AKA "Anthony Pirrone"...                                                                       |
# | I'm gonna tell ya a short story about this dude. Looks like the type of dude who could EVISCERATE a set of bag-pipes in          |
# | his Scottish Kilt... with his fuckin' eyebrows. Probably sounds IMPOSSIBLE...? But this man knows how to get it done.            |
# | The ONLY reason I would ever suggest or state as such...? Is because I told this dude how fuckin lazy he was on June 1st, 2020   |
# | when DJ Thompson was processing my arrest over the fucking kayak strap that Zachary Karel, bleeding from between his legs, filed |
# | an arrestable complaint over... but made no fucking mention of the PHONE LINE being cut at all.                                  |
# |                                                                                                                                  |
# | Also, the police (like CAPTAIN SHELLEY ZEITSKE) are so fuckin' retarded, that they see NOTHING SUSPICIOUS about how this dipshit |
# | offset the time that I cut the from MY ALIBI (SCSO-2020-028501 @ 05/26/20 0130) to (SCSO-2020-003173 @ 05/27/20 1212 but,        |
# | occuring way back on 05/26/20 0545). Look- the only reason that what I just said LOOKS stupid...? Is because, that's just your   |
# | opinion. Who cares if the police never have their facts straight, or commit obstruction of justice...? Nobody. Not (1) soul.     |
# |                                                                                                                                  |
# | Now, because of how fuckin stupid JAMES LEONARD truly is... you have to do what I do, and whip out the fuckin' forensic level    |
# | analysis kit from hell. It requires multiple hail mary's, several adult virgins, and a hallway of vampires that drink blood like |
# | count fuckin' dracula... to summon the wisdom of a GENIUS, and determine that SCSO has some fuckin' OBLIVIOUS MORONS on staff.   |
# |                                                                                                                                  |
# | There's no other explanation, i'm afraid. James Leonard looks like a fuckin moronic individual that huffs paint thinner or       |
# | glue...? And then shows up in his SCSO uniform dragging innocent people around like a fuckin' rag doll on a minimap...           |
# | ...like in the web browser for Google fucking maps. If that sounds stupid...? oh well. You're stupid, not him. Nah.              |
# | Its fucking ILLEGAL to call someone like ERIC CATRICALA, or JAMES LEONARD... fucking stupid.                                     |
# |                                                                                                                                  |
# | The punishment for choosing to do such a thing...? Is death. Or, some bullshit charge where an oral admission is stapled to a    |
# | false report. Whereby causing a fucking moron to receive his full pension and benefits, for not knowing he has BRAIN DAMAGE...   |
# |                                                                                                                                  |
# | If friends don't let friends drive drunk...?                                                                                     |
# | Then, cop friends don't let cop friends continue being cops, when they act like they have brain damage every day.                |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:21:53",":Anthony Pirrone...? I think he's a bad dude.")
$T.AE(0,"01:21:57","*clothing shuffling around")
$T.AE(0,"01:22:00",":If you're not gonna say anything, <Indiscernable, clothing shuffling around>")
$T.AE(0,"01:22:15",":Yeah, I think Anthony Pirrone uses that program, that I was talking about. And I think that he, uh- was involved with uh- Eric Catricala. Doing something shady to me on June 18th, 2020. Or June 17th, 2020.")
$T.AE(1,"01:22:35",":What's the name of the program...?")
$T.AE(0,"01:22:37",":PEGASUS.")
$T.AE(1,"01:22:38",":PEGASUS...?")
$T.AE(0,"01:22:39",":Yeah.")
$T.AE(1,"01:23:06","*Phone ringing*")
$T.AE(1,"01:23:12",":Hello...?")
$T.AE(6,"01:23:14",":<Indiscernable> Sheriff...?")
$T.AE(1,"01:23:15",":Yes...? Judge, how are ya...?")
$T.AE(6,"01:23:17",":<Indiscernable>")
$T.AE(1,"01:23:18",":Yup. Oh~! Oh, I'm sorry.")
$T.AE(6,"01:23:20",":<Indiscernable>")
$T.AE(1,"01:23:24",":Alright, so, uhh- ok. I'll do that, 6 o'clock...?")
$T.AE(6,"01:23:20",":<Indiscernable>")
$T.AE(1,"01:23:29",":Ok. I'll make that happen, thank you~!")
$T.AE(6,"01:23:31",":<Indiscernable>")
$T.AE(1,"01:23:32",":Bye. <pauses> Judge says issue an appearance ticket for ya. Let me get this typed up... outta here.")
$T.AE(0,"01:23:43",":You're willing to stick around and talk to me about a number of incidents...?")
$T.AE(1,"01:23:48",":Yeah.")
$T.AE(1,"01:23:51","*Keyboard -> tappity tap, tap, tapperoo, dude.")
$T.AE(0,"01:25:14",":Yeah, I spoke to, Mr. Gurney about this a couple years ago. Cause I came here looking to request records.")
$T.AE(1,"01:25:25",":Yeah.")
$T.AE(0,"01:25:27",":Uh- Mr. Gurney.")
$T.AE(1,"01:25:28",":Gurney...?")
$T.AE(0,"01:25:28",":Yeah, I don't know his first name. G. Gurney.")
$T.AE(1,"01:25:32",":He came here looking for records...?")
$T.AE(0,"01:25:34",":No, I did.")
$T.AE(1,"01:25:36",":Oh.")
$T.AE(0,"01:25:34",":Back in 2020.")
$T.AE(1,"01:25:37",":Ok.")
$T.AE(1,"01:25:40","*Keyboard -> tappity tap, tap, tapperoo, dude.")
$T.AE(1,"01:27:03",":<sighs> This isn't right... <Makes a sound like a kid whose sandcastle just got washed away> Alright...")
$T.AE(1,"01:27:16","*Keyboard -> tappity tap, tap, tapperoo, dude.")
$T.AE(5,"01:29:10","*Printer starts printing documents")

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 7 (01:30:38 -> 01:33:07)]: Sheradin issues paperwork, grabs my stuff from car            ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

$T.AE(1,"01:30:38",":Alright, I already gave you back your ID, correct...?")
$T.AE(0,"01:30:40",":<Indiscernable> Yeah.")
$T.AE(1,"01:30:42",":Alright, c'mon out here... <Open door> Open right up.")
$T.AE(1,"01:30:55",":Ok, so this is what we call an appearance ticket. It's got YOUR name up here, I know I used mom's address, this is for petit (PEH-TEE <- proper pronunciation) larceny, alright...? You gotta come back here on... 09/28/2022 at 6PM at night. K...? There's the charge that WALMART had filed against you.")
$T.AE(0,"01:31:14",":Ok.")
$T.AE(1,"01:31:14",":Ok...? There's all of that, lets get your stuff out of my car, so that you are free to go. You wanna throw that out, or you done with that...? Or you takin' it with ya...?")
$T.AE(0,"01:31:20",":Um-")
$T.AE(1,"01:31:24",":The oatmeal stuff...?")
$T.AE(0,"01:31:25",":I don't need it, I'll throw it out.")
$T.AE(1,"01:31:27",":If you're done with it, that's fine. If you wanna keep it...? Keep it~!")
$T.AE(0,"01:31:29",":I'm more concerned with uh- the incident I was talking with-")
$T.AE(1,"01:31:32",":Yep~!")
$T.AE(0,"01:31:33",":You're, tellin' me that you'll look into all this stuff...?")
$T.AE(1,"01:31:35",":Yeah.")
$T.AE(0,"01:31:35",":This is a serious case.")
$T.AE(1,"01:31:37",":Yeah, I will. I will, let's get your- I just wanna take your stuff outta the car so you can't say that I'm holdin' you here-")
$T.AE(0,"01:31:42",":Ok.")
$T.AE(1,"01:31:42",":-cause your stuff is locked up.")
$T.AE(0,"01:31:43",":Alright, sure.")
$T.AE(1,"01:31:45",":So... Yeah, we'll go grab it, and...")
$T.AE(5,"01:31:45","*Walking to sedan 4138")
$T.AE(1,"01:32:18",":Here's your sweatshirt and your backpack. Alright...? You've got your cell phone and your ID, right...?")
$T.AE(0,"01:32:25",":Yep.")
$T.AE(1,"01:32:26",":Alright, you wanna go back inside...?")
$T.AE(0,"01:32:27",":Yes.")
$T.AE(1,"01:32:27",":Alright.")
$T.AE(1,"01:32:31","*closes door")
$T.AE(1,"01:32:34",":Just so we're clear, you ARE free to go anytime you want.") # 
$T.AE(0,"01:32:38",":I get it.")
$T.AE(1,"01:32:39",":Okay. Alright.")
$T.AE(0,"01:32:42",":<Indiscernable, chatter>")
$T.AE(1,"01:32:58","*Opens substation door")
$T.AE(1,"01:33:00",":<Indiscernable, chatter>")
$T.AE(1,"01:33:07","*Closes substation door")

#    ____    ____________________________________________________________________________________________________
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___
#   \\__//¯¯¯ [Part 8 (01:33:07 -> )]: I make an OFFICIAL STATEMENT for (SCSO-2020-028501)                   ___//¯¯\\
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯

$T.AE(1,"01:33:29",":Alright, now you were spewin' out numbers earlier...")
$T.AE(0,"01:33:32",":Yeh.")
$T.AE(1,"01:33:32",":About a call for service, or a case number...?")
$T.AE(0,"01:33:34",":I have, uh- a nu- a couple of records, um-")
$T.AE(1,"01:33:35",":Yep.")
$T.AE(0,"01:33:39",":I have the records saved as PDF files on my GitHub project.")
$T.AE(1,"01:33:42",":Ok.")
$T.AE(0,"01:33:42",":Uh, I can give you an addr- I can give you a link to that.")
$T.AE(1,"01:33:46",":Oh- we- I can look em up, if they're in there...?")
$T.AE(0,"01:33:48",":Uh, the individual record numbers are all, uh- I don't know them all-")
$T.AE(1,"01:33:42",":Ok.")
$T.AE(0,"01:33:53",":-off the top of my head, but the (1) main record, that's the most important of them all, is ESS SEE ESS OH, TWO ZERO TWO ZERO, ZERO TWO EIGHT, FIVE ZERO ONE.")
$T.AE(1,"01:34:04",":Ok.")
$T.AE(0,"01:34:05",":That involves SCOTT SCHELLING, JEFFREY KAPLAN, and JOSHUA WELCH.")
$T.AE(1,"01:34:10",":And what was, you had a DATE too, MAY somethin'...?")
$T.AE(0,"01:34:13",":Yup. MAY TWENTY-SIXTH...")
$T.AE(1,"01:34:15",":Yup")
$T.AE(0,"01:34:16",":TWO THOUSAND TWENTY")

# ______________________________________________________________________________________________________________________________________________
# | I may occasionally get pretty pissed off about the way the people in the community treat me, as well as how people talk about me-          |
# | However, this is the EXACT TYPE OF INTERROGATION I've been WAITING for a POLICE OFFICER to HAVE with ME, since SCSO-2020-028501 0130-0155. |
# |--------------------------------------------------------------------------------------------------------------------------------------------|
# | Because the ALLEGATION that I am MAKING, I would like to CONVERT into an ACCUSATION where SCSO SCOTT SCHELLING is either:                  |
# | CHARGED WITH OBSTRUCTION OF JUSTICE, for destroying the SURVEILLANCE FOOTAGE AT CENTER FOR SECURITY... Or...                               |
# | He fuckin' spills the beans on who ordered him to do such a thing, OR... someone else at SCSO is INVESTIGATED for doing such a thing.      |
# |--------------------------------------------------------------------------------------------------------------------------------------------|
# | That's why I've been REPEATING MYSELF THOUSANDS OF TIMES FOR THE LAST COUPLE OF YEARS. Cool...? Cool.                                      |
# | If I've INSULTED MICHAEL SHERADIN at all by making this document or any of my audio logs...? IT IS NOT HIM THAT I AM PISSED ABOUT.         |
# | Nah. It's the DIPSHITS THAT HE WORKS WITH THAT KEPT IGNORING ME AND HIDING THE FUCKING CRIMES THEY COMMITTED SINCE THEN.                   |
# | Because what I've been ALLEGING is that the CRIMINAL BEHAVIORS that SCSO units have been performing, is ON PAR WITH DEREK CHAUVIN.         |
# | Oh... THAT'S why my IPHONE 8+ was REMOTELY DISABLED on MAY 27th, 2020.                                                                     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(1,"01:34:18",":Ok, well, where did all this, take place...?")
$T.AE(0,"01:34:20",":So, it took place, uh- THAT particular incident...?")
$T.AE(1,"01:34:24",":Yup.")
$T.AE(0,"01:34:24",":Took place at the tail end, of the uh, attack. Which was at, uh- He, uh- the call for service arrived at about 130AM. The attack BEGAN, on FOOT, at around midnight.")
$T.AE(1,"01:34:38",":Mmkay.")
$T.AE(0,"01:34:39",":Near the Computer Answers shop. So-")
$T.AE(1,"01:34:41",":On Route 9...?")
$T.AE(0,"01:34:42",":Yes.")
$T.AE(1,"01:34:43",":Uh- do you know what the address is there, on Route 9...?")
$T.AE(0,"01:34:45",":Yup, so it was- between 1597, and uh- 1602 Route 9.")
$T.AE(1,"01:34:51",":Mmkay.")
$T.AE(0,"01:34:51",":All the way to, uh- 1780 Route 9.")
$T.AE(1,"01:34:55",":Okay.")
$T.AE(0,"01:34:56",":Which is the Z- the Zappone dealership, where they showed up.")
$T.AE(1,"01:34:59",":Ok. Where WE met...? WE showed up...? Or, the people you're talkin' about...?") 

# __________________________________________________________________________________________________________________________________________
# | He means SCSO SCHELLING, KAPLAN, WELCH, not my attackers.                                                                              |
# | But also, this is a COMPLEX QUESTION which I discuss in my book, TOP DECK AWARENESS - NOT NEWS.                                        |
# | He's not droning on, making false assurances or really any tactic where I would think he's not paying attention at all.                |
# | He's asking questions that are taking portions of what I'm talking about, and forming a SOPHISTICATED INQUISITION about what happened. |
# | THAT MEANS, this dude fuckin honestly gives a shit about the story.                                                                    |
# | Total time taken for (1) police officer to do this...? Lets use some PowerShell mathematics and dateTime objects to get the answer.    |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Incident
{
    [String] $Name
    [DateTime] $Date
    [Timespan] $Elapsed
    Incident([String]$Name,[String]$Date)
    {
        $This.Name = $Name
        $This.Date = [DateTime]$Date
    }
    SetElapsed([Object]$Start)
    {
        If ($Start -ne $This.Date)
        {
            $This.Elapsed = $This.Date-$Start
        }
        Else
        {
            $This.Elapsed = [TimeSpan]::FromSeconds(0)
        }
    }
}

Class IncidentList
{
    [Object] $Output
    IncidentList()
    {
        $This.Output = @( )
    }
    Add([String]$Name,[String]$Date)
    {
        If ($Date -notmatch "\d{2}\/\d{2}\/\d{2} \d{2}\:\d{2}")
        {
            Throw "Invalid date entry, must use 'mm/dd/yy HH:MM' format" 
        }

        $This.Output += [Incident]::New($Name,$Date)
    }
    SetElapsed()
    {
        If ($This.Output.Count -gt 0)
        {
            $This.Output | % { $_.SetElapsed($This.Output[0].Date) }
        }
    }
}

$Incident       = [IncidentList]::New()
$Incident.Add("Attack began","05/25/20 23:43")
$Incident.Add("Attack over","05/26/20 01:30")
$Incident.Add("Now","09/16/22 14:30")
$Incident.SetElapsed()

<#
    [SCSO-2020-028501]: https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf
    Evidence List     : https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt

    Name         Date                  Elapsed
    ----         ----                  -------
    Attack began 5/25/2020 11:43:00 PM   0d 00h 00m 00s
    Attack over  5/26/2020 1:30:00 AM    0d 01h 47m 00s
    Now          9/16/2022 2:30:00 PM  843d 14h 47m 00s

    Check that shit out. Michael Depresso from the SARATOGA COUNTY PUBLIC DEFENDERS OFFICE should take note of this shit.
    Why...? Uh, cause doing so will showcase a living example of how far up his own ass, his head is.
    It'll ALSO illuminate how fuckin' stupid he is. As well as like, other people that work for SARATOGA COUNTY
    that like, either 1) don't care if they're lied to, or 2) don't know when they're lied to.
    
    I guess in life, some people are lazy fucks.
    Other people are just morons who believe what they're told.
    But there are rare people such as myself, that can detect when there's a HIDDEN AGENDA that sorta explains
    how PUBLIC DEFENDERS aren't all that helpful, because they're on the SAME FUCKING TEAM as the DIRTY POLICE.

    You know, when I go around telling people that there are SERIAL KILLERS in the town of Clifton Park/Halfmoon...
    ...and like, NOBODY SEEMS TO BELIEVE ME...? I have to start calling people fuckin' stupid, repeatedly, over and over,
    and not let up on calling people fucking morons willy-nilly, because some people were just NOT BORN to be INTELLIGENT.
    Nor to like, ASK QUESTIONS. That's how I know I'm surrounded by fucking morons.
#>

$T.AE(0,"01:35:04",":Oh, the- my ATTACKERS showed up around the FIRST address there.")
$T.AE(1,"01:35:08",":Ok.")
$T.AE(0,"01:35:09",":Between the first pair of addresses.")
$T.AE(1,"01:35:08",":Alright...")
$T.AE(0,"01:35:11",":And then, uh- they followed me for about 90 minutes.")
$T.AE(1,"01:35:15",":Yup.")
$T.AE(0,"01:35:16",":Uh-")
$T.AE(1,"01:35:16",":Yup.")
$T.AE(0,"01:35:18",":So, the attack BEGAN like, right after midnight...? ") # It actually BEGAN at about 2343, but it wasn't TOTALLY APPARENT to me until 0004 
$T.AE(1,"01:35:21",":Mhmm.")
$T.AE(0,"01:35:22",":They followed me, uh- I tried to call 911 at about 1204, the FIRST time. And, uh- that was near the, uh- the Clifton Park Eye Care...? Or uh-")
$T.AE(1,"01:35:34",":Yup.")
$T.AE(0,"01:35:34",":-the Halfmoon Sandwich and Sub Shop. And, when I hit the SEND button, and 911... what was happening was, is the TIMER kept rising, there was NO SOUND emanating from the device. So which indicates the- uh- the call failed to complete, or the call was being disrupted. Or my phone was disrupted. I believe, uh- I'll tell you AFTERWARD, what my beliefs are. I'm gonna try to stick to what ACTUALLY happened. Uh- I continue to walk on, and these two individuals, uh- it was just (1) individual at first, both the, the SECOND individual was in a BLACK DODGE CHARGER, or a BLACK DODGE DART, they LEFT the laundromat and was headed SOUTH on Route 9, past Walmart. Um- Then, uh- the SECOND guy who was IN the laundromat, came out, and started yellin' at me, and then he started following me, so I KNEW that he was trying to ATTACK ME, and, the SECOND individual who got in the BLACK CAR...? Managed to find some way to park the car that he was IN, somewhere near like TWIN LAKES or something, and he came out near WILSCOT, or near the place where I FIRST called 911, or, Grecian Gardens")
$T.AE(1,"01:36:45",":Ok.")
$T.AE(0,"01:36:46",":And, uh- I had a SUSPICION that they were FOLLOWING me, to- MURDER me. And the REASON why I BELIEVED that, is BECAUSE, I had RECORDED a video of the FIRST individual comin- approaching me from my left.")
$T.AE(1,"01:36:59",":Mhmm.")
$T.AE(0,"01:36:59",":Near the Halfmoon Sandwich and Sub Shop. And, uh- he had a PAIR OF GLASSES, he had a BACKPACK with a NEON LIGHT in it, and, uh- like I said, I had a conversation with him, I said, uh- 'Hey, are you from around here...?' and he said uh- 'I am, but I moved away and I came back.' And then I said, 'Well, uh- did you k-, do you know this ERIC CATRICALA guy...?' and he said 'No.' And, uh- then I sa- I- I was tryin' to like, test, like- whether this was- a suspicious person or not, so I said 'Did you know that ERIC CATRICALA puts bodies into concrete foundations...?' And, uh- you know, he didn't- he was caught off guard... And, uh- then he continued to walk on, uh- well I said 'Alright thanks a lot, you've been helpful.' And then he continued to walk on, and then I like, I was inconspicuously recording him, with, my device. With THIS device RIGHT HERE, actually.")
$T.AE(0,"01:37:56",":I don't typically carry this around with me all the time, but- this PHONE was DISABLED on MAY 27th, 2020")
$T.AE(1,"01:38:02",":Ok.")
$T.AE(0,"01:38:03",":And I haven't formatted it, I haven't removed anything from this, uh- I can, at ANY MOMENT, like, CLEAR THIS OUT and use it all over again. But there's FORENSIC EVIDENCE on this device, and I REFUSE to do anything with it, until I can get it off.")
$T.AE(1,"01:38:16",":Ok.")
$T.AE(0,"01:38:02",":Forensic evidence is the VIDEO I'm talking about.")
$T.AE(1,"01:38:16",":Ok.")
$T.AE(0,"01:38:20",":Uh- the- the individual continued to walk on, past me, and then um, I like, pulled down the TEXT MESSAGE thing, and I was typing something to him because I believe that he had a REMOTE CONNECTION to my device, and he was SPYING on me.")

# ______________________________________________________________________________________________________________________________________________________
# | I believe I was actually performing a SCREEN CAPTURE of that exact moment, a SCREEN CAPTURE during a VIDEO RECORDING, w/ PEGASUS was on my device. |
# | To guys like MICHAEL DEPRESSO and SARAH SCHELLINGER... a "SCREEN CAPTURE" is sorta like a "SCREEN SHOT", but a "SCREEN SHOT" is just (1) picture.  |
# | Whereas a 'SCREEN CAPTURE' is when a VIDEO is being RECORDED of the CONTENT on the fuckin DISPLAY of the DEVICE. Apple doesn't make SHIT PRODUCTS. |
# | They just happen to have someone in their company that is leaking ZERO DAY VULNERABILITIES FOR A PROFIT... to the NSO GROUP in ISRAEL... which is  |
# | fucking DANGEROUS.                                                                                                                                 |
# |                                                                                                                                                    |
# | That's how I was INCREDIBLY SUSPICIOUS of this fuckin dude, I almost got hit by a car about 20 minutes BEFOREHAND...?                              |
# | Figured that I had someone spying on me like the little faggot(s) they are.                                                                        |
# | Ever since 01/15/2019 CVE-2019-8936, I've SORTA been on the lookout for some fagboy extraordinaire to come along,                                  |
# | prancing along the fuckin' beaten path, looking as if he's got a whole entire 15 inch dildo in his rectal cavity.                                  |
# |                                                                                                                                                    |
# | And that's exactly what I recorded in IMG_0647.MOV from 05/25/20 2343 -> 05/26/20 0004... someone matching this exact description.                 |
# | Actually (2) separate dudes who look like they're BROTHERS, both matching the above description... is what I recorded. in IMG_0647.MOV             |
# |                                                                                                                                                    |
# | They are FORMER CUSTOMERS of COMPUTER ANSWERS. But also, it's hard to imagine them ever scoring with Christina Czaikowski with how GAY they look.  |
# | They were talking about this girl at the computer shop back in 2017 when they sold the shop a WHITE ANDROID SMARTPHONE, as well as a BLUE ANDROID  |
# | SMARTHONE, so, (2) smartphones sold by (2) queer bastards. I literally used a PHOTO COPIER to like, make a BACKUP COPY... of this kids face, name, |
# | identity, basically his fuckin ID, because that was our policy, to take SCANS of people's IDS in case the PROPERTY being SOLD to the SHOP was      |
# | STOLEN. So, this cocksuckers face was actually saved to the COMPUTER ANSWERS database of bought items.                                             |
# |                                                                                                                                                    |
# | So, I started a SCREEN RECORDING while I was RECORDING A VIDEO, and had the CAMERA LENS pointed at this QUEER-AUSTIN-EVANS'LOOKIN'-SON-OF-A-BITCH, |
# | and in the TEXT MESSAGE I basically called him something DERROGATORY and also that I had fucking CAUGHT HIS ASS... That is the EXACT MOMENT when   |
# | he was standing in front of the CATRICALA FUNERAL HOME, LOOKED AT HIS DEVICE WHILE I WAS RECORDING HIM, and as SOON AS HE DID...? He knows damn    |
# | well that he was LOOKING AT HIMSELF being recorded on fucking video, BUSTED. <- THAT IS WHY MY DEVICE WAS DISABLED.                                |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:38:44",":So, I typed something up to TAUNT him, and uh- when he was in front of the CATRICALA FUNERAL HOME, he LOOKED AT HIS PHONE, and then he LOOKED UP, like, pretty upset with himself, I didn't realize what I recorded on video, but it was INCREDIBLY RARE, I believe that he was using PEGASUS, and that HE, is a SERIAL KILLER, and that HE, is ASSOCIATED with DEPUTY COOPER.")
$T.AE(1,"01:39:09",":Ok.")
$T.AE(0,"01:39:10",":And I think he has an OLDER or YOUNGER BROTHER, and they're ASSOCIATED with CHRISTINA CZAIKOWSKI.")
$T.AE(1,"01:39:09",":Mkay.")
$T.AE(0,"01:39:22",":Deputy Cooper, uh- I'll- i'll- return in a mo- the point about him, momentarily, uhm- after this FIRST incident, and then I, like, realized what I caught on VIDEO, I was THINKING of ending the recording and UPLOADING it across the street. Uhm, if you wanna know more about THAT event, I've written, uh- an entire CHAPTER in my BOOK, about what happened, and I've put ALL of the documents and everything, but I don't wanna overwhelm you, and overload you with, uh- what happened, I'm trying to stick to THAT record right there, and what happened PRIOR to that.")
$T.AE(0,"01:39:55",":After he made this expression on his face, you know his body language told me, like `"Yeah, he was like, watchin' me`", uh- I went across the street, and, I- I continued to record the video, I believe, uh- and uh, he like, walked down the street, and like, cut over to like Walmart, or- he didn't cut over to Walmart, he cut over to Mobil station, and then, uh- a minute or two AFTER THAT, a SECOND white male coming from the the OPPOSITE SIDE of Route 9, same direction, was coming from the GRECIAN GARDENS area. And uh- he had the same type of backpack on him...? But he had a wireless bluetooth speaker, and uh- I think he had like a MOBILE BATTERY CHARGER on him too, because it looked like something was- something REALLY HEAVY was in his backpack. So, uhm- he lik, said something to me...? But I wasn't really paying attention to what he was saying, because the music was distracting. I was keeping my eyes on like, BOTH of these individuals, bcause, uh- moments prior, someone in a vehicle appeared to almost strike me, and it didn't look like it was accidental. You know, I could tell if it was ACCIDENTAL, like, if someone sees me at the last second, and they like oversteer, or whatever, someone was GUNNING for me, I had to like, run onto the grass, so it was like, PRETTY INTENTIONAL... At any rate, the SECOND INDIVIDUAL, walks into Wal- the, the laundromat. Once they were in the laundromat, I kinda like, take a look around, and I don't remember EXACTLY what happened, but I remember there was a GIRL in there, and I remember this TALL DUDE was in there, and he was like TEXTING somebody. And, uh- he was probably in there for a few minutes, and I walked away a fair distance, near like the surgery center there, and, uh- eventually the OTHER KID gets into the BLACK CAR, which was either a DODGE CHARGER or a DODGE DART. And then he drives SOUTH on ROUTE 9, towards WALMART, if not PAST that, and the video I was recording recorded that whole entire event with him getting in his car and then driving off.")
$T.AE(0,"01:42:10",":Uh- at which point, the car, somehow got out of the view of the camera, and then the OTHER kid came out from the LAUNDROMAT, and he's like 'HEY~! WHAT'S THE BIG IDEA...?' or SOMETHING like that, I don't remember exactly what he said, but I knew that like, he was about to chase me, and that's EXACTLY what he did, uh- for a moment I thought about ending the recording and uploading it, but I didn't think I had enough time...? And I had a pretty strong suspicion that this dude was about to kill me. Uh, I didn't see a WEAPON or anything...? But- I believe they were using this PROGRAM, to like, watch me and follow me around, so, uh- I didn't THINK to call 911 until the SECOND kid came back out from the woods, like, near GRECIAN GARDENS. So, thats when I called 911 the FIRST time, uhm- with *THIS DEVICE*... and when I say I called 911, I hit NINE ONE ONE and then I hit the SEND button, and then the TIMER started rising.")
$T.AE(1,"01:43:10",":Mhmm.")
$T.AE(0,"01:43:12",":No sound emanating from the device.")

# _________________________________________________________________________________________________________________________________________________
# | Pretty easy to see how the PHONE companies might've been involved in this MURDER ATTEMPT, considering the things I was POSTING all that week. |
# | Like, I kept saying SPECTRUM/VERIZON/BELL ATLANTIC, CLASS ACTION LAWSUIT, SHERMAN ANTI-TRUST, and RACKETEER INFLUENCED CRIMINAL ORGANIZATION. |
# | All that shit sorta goes right together like PEANUT BUTTER and JELLY.                                                                         |
# |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# | Thing #1                         | Thing #2                                       |
# |----------------------------------|------------------------------------------------|
# | PEANUT BUTTER                    => JELLY                                         |
# | THEODORE ROOSEVELT               => KICKING THE SHIT OUT OF MONOPOLIES            |
# | SHERMAN ANTI-TRUST               => MONOPOLY                                      |
# | INTERNET NEUTRALITY              => CORPORATIONS OWNING THE INTERNET              |
# | CORPORATIONS OWNING THE INTERNET => GEORGE ORWELL 1984                            |
# | GAY GUY INVOLVEMENT              => TIM COOK + APPLE, TANSKI + HOFFMAN + KEY BANK |
# |__________________________________|________________________________________________|_________________________________________________________
# | If they were fuckin' INNOCENT, then they WOULDN'T be performing a fucking MAN-IN-THE-MIDDLE attack, and would HOLD THEMSELVES ACCOUNTABLE. |
# | That's not what I was observing all throughout that entire week. Not saying that gay guys just so happened to be in every direction...?    |
# | But, I saw a VERY questionable amount of them in certain places that seemed to be MORE than just "coincidental"... ya know...?             |
# |--------------------------------------------------------------------------------------------------------------------------------------------|
# | Now, look. I have nothing against homosexuals at all. I just PREFER not to watch them when they do what they do.                           |
# | A girl and a guy...? That's fine. I'm cool with seeing something like that from time to time.                                              |
# | A girl and a girl...? That's fine too. Totally legit.                                                                                      |
# | A guy and another guy...? That's where I draw the line. Not interested in that at all... but-                                              |
# | sometimes they don't care what I think, and they just show up anyway.                                                                      |
# |--------------------------------------------------------------------------------------------------------------------------------------------|
# | Look to my left...? A couple gay guys pounding it out in a fuckin' shadowy alcove... I immediately look away, to respect their privacy.    |
# | Look to my right...? There's another couple gay guys pounding it out in ANOTHER shadowy alcove. So I'll cup my hand over my eyes and keep  |
# | movin... but then suddenly, a car will show up and stop right in front of me, and then, guess what happens...?                             |
# | WELL, multiple gay guys were in that car, and they decided it was time to stop right in front of me, and start pounding it out... but it   |
# | didn't happen in some shadowy alcove this time, just, right in the open, right on Route 9 for cryin' out loud.                             |
# | This is all a METAPHOR, for TELECOM COMPANIES being like, in bed with each other, trying to be INCONSPICUOUS about their activites...?     |
# | But, failing miserably.                                                                                                                    |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"01:43:14",":So, I put 2 and 2 together, with the thing that I recorded on video, and the events of these two guys following me around, and uh- ya know, I was kinda scared shitless, because- I knew what was goin on. You know, uh- few times in my life, I've tried to call 911 or any number, and the phone will do that, but- ya know, it's RARE. But- this happened TWICE in like, FIVE MINUTES. And, you know, it happened, like someone would say 'How do you know they were tryin' to kill ya...?' That's LITERALLY what TROOPER CARTER was tellin' me, was like 'How do you know they were tryin' to kill ya...?' Well, I don't know for SURE that they were trying to kill me, but, there were a number of OTHER coincidences that occurred that night. they had a car parked at the Lowes Home Improvement parking lot, like AHEAD of time. So they were expecting to hit me with their car...? Or like, stab me to death, and then drive away in their SECOND car that they had down the road. the point being, uhm, I got to uh- CENTER FOR SECURITY, and I knew that they had SECURITY CAMERAS, so I did the SAME EXACT THING that I just described...? In front of the CAMERA. About 10 inches from the SCREEN or the LENS or whatever. And then, uh- the same thing happened. They were on the other side of the road, but I knew that they were trying to corner me. And I wasn't uh- giving them that opportunity. There's TWO of them, ONE of me, all they need to do is just BOX ME IN and I'm done. So, I stayed on the OTHER side of the road, I took (3) pictures which I have the LINKS to, uh- and uh- that was- those were the LAST PICTURES I took until my PHONE had just about died. I had turned it off, because, I turned *THIS PHONE* off because I suspected that they were TRACKING ME, and they had a little BEACON on their- um, I don't know if this sounds hard to believe, but I believe that the SOFTWARE they were using, allows them to have like a PINPOINT ACCURACY, like a TELEMETRY LOCATION.")
$T.AE(1,"01:45:09",":Mhmm.")
$T.AE(0,"01:45:10",":Like, you know, uh- longitude and latitude, so, uh- pretty hard to run away from somebody that's got acce- like, uh- when you're dangling as bait, or whatever. I, uh- was scared shitless, that I uh- I had a BAD FEELING that if I KEPT WALKING DOWN ROUTE 9, something BAD was gonna happen, I cou- I couldn't explain how I KNEW something bad was gonna happen if I went that way, I didn't. So like, I cut into the Lowes Home Improvement parking lot, one of the lights was like, flashing, and uh- you know I like, kinda crept around the parking lot for a while, and then, about like 5-10 minutes after I walked into the parking lot...? The 2 kids are walking into the parking lot, from like, the Fortune Wok entrance So, that told me that, they were DEFINITELY following me, they definitely like, had some TELEMETRY FOOTPRINT of where I was going with the phone. And, uh- these are the things I was trying to tell my MOTHER, and my STEPFATHER, back on MAY 19th, 2020, which uh- led to TWO ZERO TWO ZERO, ZERO ZERO T- uh, ZERO ZERO TWO, NINE NINE EIGHT...? Uh- it had ANTHONY AGRESTA, JOHN HILDRETH, and, I don't know COACH LYON'S first name, but I know that he USED to work in the Mechanicville Police Department.")
$T.AE(1,"01:46:38",":Mkay.")
$T.AE(0,"01:46:41",":And, I spoke to them about this program, the USA-PATRIOT Act THAT NIGHT, after the altercation with my stepfather. The ALTERCATION that occurred with my STEPFATHER, on MAY 19th, 2020, was RESULTANT to, uh- some BLUE TRUCK was STALKING ME, following me around, I was scared shitless. Like, uh- anytime I carry this device around on me, I would see this blue truck. And this started happening after I contacted the FBI in January 2020 (01/27/20). I had contacted the FBI a number of times, because SOMEBODY was attacking my EQUIPMENT (disrupting my ability to do business), and you know my company is based with digital security. Essentially the SAME THING as COMPUTER ANSWERS, BUT- I started doing APPLICATION DEVELOPMENT. Uh- I don't wanna get lost in THOSE details, but- there was a- there was a- suspicious truck following me around, I got into an altercation with my stepfather, because I told him I was worried that I would go missing and never be found. And he LAUGHED at me, and I was so insulted by it, that I wound up, assaulting him. Now, I understand I shouldn't have assaulted him, but I was like 'Hey dad, I'm fuckin' scared shitless I'm gonna get killed', and he's like 'Oh, well, that's STUPID, kid.' You know...? The same type of reaction. So, uh- Anthony Agresta takes a report, and then he suggests that I go to a friends house for the night, and that's what I did. And, uh- I walked all the way to my buddy's house who lives, who- at the time lived at uh- Twin Lakes, and uh- he wasn't home. and, uh- I was scared shitless, so I- dialed 911 to test a theory that I had, and then uh- Anthony Agresta, the same guy that was the location, at my house...?")
$T.AE(1,"01:48:24",":Yup.")
$T.AE(0,"01:48:26",":Uh- he responded to that 911 call, I hit 911, and then I like, turned the phone off right afterward. Cause I was testing a theory.")
$T.AE(0,"01:48:34",":Uh, Anthony Agresta found me, within like 3 minutes.")
$T.AE(1,"01:48:37",":Ok.")
$T.AE(0,"01:48:34",":On Sitterly Road, near 30 Sitterly Road. I mentioned some of this stuff to JOHN HILDRETH in an email. Uh- the point being, there was a suspicious vehicle that was following me around, and suspicious activity that caused me to believe that I was being followed around, so- uh- that night on MAY 26th, 2020 when I was in the Lowes Home Improvement parking lot, these two kids got back into their car, and I was, uh- basically paralyzed with fear, for a good 10 or 20 minutes, tryin' to stay out of view, trying to stay near LIT AREAS, because I was worried that if I went into an UNLIT AREA with my PHONE, regardless of whether it was DEAD or not, that I was gonna get killed.")
$T.AE(0,"01:49:21",":I eventually walked out onto, uh- Route 146. And, uh- when I did, they pulled out of the Lowes Home Improvement parking lot, and then they tried to hit me, between AUTO ZONE, and uh- ADVANCE AUTO PARTS. And they drove OVER the double yellow line to try to hit me, and they MISSED...? And then, they took a RIGHT onto Route 9 near the Key Bank, headed up Route 9, toward 1769 Route 9.")

# ________________________________________________________________________________________________________________________________________________
# | I believe that I had powered my device OFF before going into the LOWES parking lot.                                                          |
# | At some point between EXITING the Lowes Home Improvement parking lot, and geting to the INTERSECTION of (146/9), I turned my device back on. |
# | It WAS just about DEAD, but it had a sliver of battery life remaining.                                                                       |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$T.AE(0,"01:49:51",":I said something into my phone, which I believe was RECORDING ME, even though I wasn't hitting the record button. And, SCOTT SCHELLING asked me a question, about what I said. And, it seemed like he had knowledge, of what it was that I said into my device. And it scared the fuckin' shit outta me, because it told me that they had been watching me for some time. This PROGRAM, or somebody in your department, or, maybe it was the FBI, maybe its- maybe it's a GROUP of people that's not- they're made up of uh- Sheriffs, and State Troopers, FBI guys, but- the orginatio- organizations themselves aren't AWARE of this, uh- RICO. Or, GANG.") # RACKETEER INFLUENCED CRIMINAL ORGANIZATION
$T.AE(0,"01:50:34",":You know, it's like- it's probably not hard to believe, maybe some of the guys that work on your team, are GANG members.")
$T.AE(1,"01:50:43",":<Indiscernable, I know he looked at me with alarm at this point>")
$T.AE(0,"01:50:44",":So anyway, side point... I started to think about, uh- why would somebody do all this to me, and uh- the only thing I could come up with is, that it has something to do with my fathers murder in 1995. Because my father had a suspicion that he was gonna wind up getting killed, and then he did, my father was murdered by Zontell Gordon on October 23rd, 1995, and uh, he-, he- made statements that caused me- caused everyone- caused me to believe that he knew what was gonna happen. (3) guys that killed my dad, they, uh- they were all tried for FIRST DEGREE MURDER, but- I don't think the OTHER TWO GUYS that were involved, had any knowledge whatsoever, that the guy who shot my father, uh- he had no intention of letting my father survive.")
$T.AE(1,"01:51:42",":Hm. What'd you say this guy's name was...?") # Maybe he finds the story somewhat plausible, hence the question. Though, it's still a bit of a STRETCH.
$T.AE(0,"01:51:44",":Zontell Gordon.")
$T.AE(1,"01:51:45",":Zontell...?")
$T.AE(0,"01:51:47",":Yeh, he's- he's in prison.")
$T.AE(1,"01:51:49",":Zontell Gordon...?")
$T.AE(0,"01:51:50",":Yep. <pauses> I believe that he was paid to EXECUTE my father.")
$T.AE(1,"01:51:57",":And, what's your dad's name...?")
$T.AE(0,"01:51:58",":Michael Edward Cook.")
$T.AE(1,"01:52:03",":Ok.")
$T.AE(0,"01:52:06",":So, uhm- what I believe is that uh- this group of CRIMINALS, or uh- call it a MAFIA, I think it's the RUSSIAN MAFIA, but- you know, I don't have ENOUGH to s- ss- specifically suggest as such, uhm <pausing for radio chatter> I believe that my aunt was involved, in his- uh, murder. And I believe that my MOTHER was ALSO involved, in his murder. I didn't think that for like 25 years, but- on June 28th, 2022, about 3 months ago, I got in an argument with my mother, and for some reason, I recorded the entire thing, I didn't realize the phone was recording it, and then uh- the police arrested me AS SOON AS I TOLD THEM ABOUT THE AUDIO RECORDING EXISTING, and I thought that was screwed up. Uh- side point. Um- as for that particular night, uh- I walked all the way from where Key Bank was, and I was trying to flag people down for help. Because, my phone was dead, and, I didn't wanna uh- I didn't wanna risk- I DID try to turn it back on, but I knew that had I turned it back on to try and call 911 again, that, they would just know where I was. So, I walked all the way to uh, like uh, near Zachary Karels house. I saw like a couple of vehicles, driving by, but they were on the other side of the road so I couldn't get attention from them. And uh, I got to this house, uh- 1769 Route 9, apparently a guy named Zackary Karel lives there, and I've been keeping eyes on that residence for a while because it used to be a DOCTORS OFFICE, and then all of a sudden...? Uh, it wasn't a doctors office anymore, it was just, uh- couple cars parked in the driveway, there was a Honda Civic parked in the driveway for like over a year, and I thought it was weird. It was like, at the very least, why not move the vehicle...?")
$T.AE(1,"01:54:06",":Mhmm.")
$T.AE(0,"01:54:08",":So, uhm, what I suspected THAT NIGHT, was that the 2 guys that drove up the road...? Were in that house. And, when I was there, uh- I- I was kinda like listening, through the window to try and hear if people were walking around inside, you know...? Were the guys that tried to hit me, and like followed me, in this house...? And I thought they WERE, because they had the AIR CONDITIONER running, and they kept turning it OFF, so...")
$T.AE(0,"01:54:34",":So, I didn't have a way to call 911. I cut that houses' phone line, because I was PRETTY SURE, that whoever tried to HIT ME was in that house. Then I ALSO cut the ZACH-, the KAK-, the- KAYAK STRAP. You know, cause it was like 'Alright, well, this asshole's gonna like, try to run me over or whatever...? Cut the KAYAK STRAP.' Uh, I later got a charge for CRIMINAL MISCHIEF of, of- CRIMINAL MISCHIEF of the FOURTH DEGREE which uh, was uh- defended by FREDERICK RENCH, but I tried to EXPLAIN to him what happened this entire night. About 5 or 10 minutes later, about 5 minutes later, I made it to the uh- Feiden Appliance Center, and I knew that ZACKARY KAREL, or the PERSON that LIVED IN THAT HOUSE, was working at that building, because they drive a Black Cadillac. And so, I moved the sign across the street to a vacant mailbox pole, for MATCHLESS STOVE AND CHIMNEY. I had taken pictures earlier that night, because I was walking around the area, during the AUDIO RECORDINGS I had recorded EARLIER that night, I thought it was SUSPICIOUS that uh- MATCHLESS STOVE AND CHIMNEY, uh- like, neve rhad any cars parked at it, but the lights are always on. Or whatever, I couldn't remember EXACTLY what it was, but the AUDIO RECORDINGS reveal more DETAILS.")
$T.AE(1,"01:55:49",":Mhmm.")
$T.AE(0,"01:55:51",":I uh, wound up walking PAST Matchless Stove and Chimney, and then I got to like the uh- billboard, the LAMAR ADVERTISING billboard, right in front of the Zappone dealership. And, uh- ya know, I was tryin' to get ahold of 911 SOMEHOW, so I went to like, the base of the board there, and there's like an electrical meter. And I pulled out a module, thinkin' that maybe- maybe it could set off an ALARM or something... and then, SCOTT SCHELLING was there within a minute or two. I was like 'Oh yes! Whatever I did got a cop to show up~!' And then, he shows up, and then he's like, shining the flashlight in my face, he's like uh, 'We got a report of somebody jumping in front of vehicles, or whatever' and I said 'Well, uh- I was trying to flag people down for help. I was trying to call 911.' And he's like 'You didn't call 911, caus eif you did we would've- we would've gotten the call.'")
$T.AE(0,"01:56:42",":He was actually pretty snippy with me, and uh- I convinced him, of WHO I WAS, and a moment or two after he showed up, uh- JEFFREY KAPLAN and JOSHUA WELCH showed up. And, uh- whatever I said caused SCOTT SCHELLING to like, be the COOL guy. And then JEFFREY KAPLAN showed up, and he was kinda like, bein' the bad cop. Good cop, bad cop. Joshua Welch was just kinda like observing from the distance.")
$T.AE(3,"01:57:12","*enters the Halfmoon Sheriff Substation*") # Timing seems PRETTY FUCKING COINCIDENTAL
$T.AE(0,"01:57:14",":Michael Whiteacre")
$T.AE(0,"01:57:19",":And, uh- what happened was, uh- I explained what was going on, I told him that uh- a couple guys were following me, I tried to call 911 a couple times, and neither one of my calls made it to the DISPATCH STATION, and uh- as soon as I told him that, uh- he realized that I was the guy that walked to STRATTON AIR NATIONAL GUARD a few nights beforehand. The events between MAY 19th, and MAY 26th, are ALL in a CHAPTER in my BOOK called 'The Week'.Uh- I won't go into FULL detail about ALL of it, but what I WILL say, is this. Uh, that interaction right there, SCOTT SCHELLING asked for my ID, and then when I SHOWED him the ID, he didn't need to run it. And then as soon as he looked at it, he wasn't running the ID and JEFF KAPLAN said to him 'Well, why aren't you runnin' it...?' and SCOTT SCHELLING said, 'Well, this is the guy that walked to STRATTON 3 nights ago.' And then all of a sudden the roles reversed, so JEFF KAPLAN was the GOOD COP, and then SCOTT SCHELLING started to be a dick.")
$T.AE(0,"01:58:35",":Scott was looking for any reason-")
$T.AE(3,"01:58:35",":<Interrupts me>, Did you read the police report...?")
$T.AE(0,"01:58:37",":No.")
$T.AE(3,"01:58:38",":Oh. Mike, you've already told all of us this.") # Haven't told THIS guy, dude.
$T.AE(0,"01:58:40",":Right.")
$T.AE(3,"01:58:41",":What, what are you looking for...?") # PROSECUTE YOUR ORGANIZATION, that's what I'm looking to do. Ya know...?
$T.AE(0,"01:58:44",":Well...") # It should be pretty fuckin' obvious what I'm lookin' to do, buddy. Ya know...?
$T.AE(4,"01:58:45","*Multiple officers enter the office*")
$T.AE(3,"01:58:46",":Cause we all, like I've read your notes, multiple times that you've left on buildings... and, I'm not sure what else we can do for ya.") # Give me $300M when I file a lawsuit against SCSO, and some officers go to prison.)
$T.AE(3,"01:58:54",":Don't you think-")
$T.AE(0,"01:58:55","<Interrupts M. Whiteacre> The case that I'm trying to make here is that uh-")
$T.AE(0,"01:58:57",":Uh, I think there are some dirty officers on your unit.")
$T.AE(3,"01:59:02",":<Knife sound> You've made that aware, you've made us aware of that." )
$T.AE(0,"01:59:04",":Right. Well, I'm getting in trouble at Walmart, for something I didn't do, and people are basically fabricating things, and I'm getting arrested for it. And then when some things happen to ME, uh- then I tell the story, it is heard, and NO ACTION IS TAKEN.") # That's PREJUDICE
$T.AE(0,"01:59:22",":So, what I'm noticing is that the END RESULT is, THIS GUY (MICHAEL SHERADIN) IS WRITING DOWN INFORMATION, and I believe that the-")
$T.AE(0,"01:59:30",":and I believe that the event has something to do with the-")
$T.AE(3,"01:59:32",":This is like a FEW YEARS AGO") # I know buddy, that's why you should probably remain silent, cause it shows how LAZY YOUR OFFICE IS.
$T.AE(0,"01:59:34",":Right.") # I'm basically insulting this dude by AGREEING with his statements.
$T.AE(0,"01:59:35",":Well, what happened was, is that you showed up on June 19th with Mark Sheehan...")
$T.AE(3,"01:59:41",":Yep.")
$T.AE(0,"01:59:41",":Uh, well, I specified that uh, NFRASTRUCTURE was involved in THAT event right there")

# ________________________________________________________________________________________________________________________________
# | 07/21/89 | 785-3221 JESSE PICKETT | https://github.com/mcc85s/FightingEntropy/blob/main/Docs/2021_0414-(Jesse%20Pickett).pdf |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$T.AE(3,"01:59:47",":Yep, I'm aware")
$T.AE(1,"01:59:53",":Is this the truth...?")
$T.AE(3,"01:59:53",":This- this was like, a couple years ago...") 

# ________________________________________________________________________________________________________________________________
# | Indicates that IN HIS OPINION, his failure to collect evidence that directly links the former owners of NFRASTRUCTURE to     |
# | ESPIONAGE TOOLS is really NOTHING to be TOO concerned with, whereby downplaying the SEVERITY of MICHAEL WHITEACRE's LAZINESS |
# | to COLLECT EVIDENCE and stuff like that. Ya know...?                                                                         |
# |                                                                                                                              |
# | While MICHAEL WHITACRES demeanor and words doesn't indicate MALICIOUS INTENT...?                                             |
# | His INACTION certainly fucking does.                                                                                         |
# | If he's aware that I IMPLICATED NFRASTRUCTURE, and then SCSO COOPER had to SWOOP IN LIKE A DOUCHEBAG VERSIN OF BATMAN...     |
# | it means that I had some bitch write a letter of indication that led to me losing custody of my children for BEING CORRECT.  |
# | It ALSO means that I have YOU to thank for, you know, being TOO LAZY to collect the EVIDENCE I just posted above. Ya know?   |
# | It's not really an OPINION so much as it's like this:                                                                        |
# |------------------------------------------------------------------------------------------------------------------------------|
# | VICTIM : Mr. police officer, a crime happened to me...                                                                       |
# | COP    : Crimes happen all the time dude, grow the fuck up.                                                                  |
# |          You'll be fine.                                                                                                     |
# |          Just drink your milk, buy gas, and pay your bills.                                                                  |
# |          I really, am not even remotely concerned about this SUPPOSED crime that you say happened to ya.                     |
# |          Really, there's not much more we can do for ya at this point, cause... shit happened so long ago.                   |
# |------------------------------------------------------------------------------------------------------------------------------|
# | I don't think MICHAEL WHITEACRE realizes how stupid he sounds right now, but his rhetoric sounds like this dialog above.     |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(1,"01:59:54",":Oh.")
$T.AE(0,"01:59:54",":Yeah.")
$T.AE(3,"01:59:55",":Well THIS was, yeah.")
$T.AE(0,"01:59:57",":I was dragged through the mud regarding custody of my children, I was accused of stuff at Family Court... and then people played games with me at family court.")

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

$T.AE(0,"02:00:04",":They didn't send me uh- my APPEARANCES with the CORRECT TIME, so...")
$T.AE(0,"02:00:12",":What I'm suggesting is that uh, <you're fuckin' LAZY bruh =)>...")
$T.AE(0,"02:00:14",":I believe that THAT event was RELATED to my fathers murder in 1995 <Me, doing Michael Whiteacre's job, since he's not doing it>")
$T.AE(1,"02:00:19",":Ok.")
$T.AE(0,"02:00:19",":And then MICHAEL WHITEACRE wrote a report about how he was showing up because OLIVER ROBINSON made a complaint, uh-")

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

$T.AE(0,"02:00:26",":What Michael Whiteacre wrote on the REPORT <SCSO-2020-003688> is that, the reason he was at my house was UNRELEATED to the CPS case.")
$T.AE(0,"02:00:33",":But it fucking definitely WAS related, and he wasn't aware of it.")
$T.AE(0,"02:00:40",":So, what I have come to determine is that I have to be pretty ADAMANT about the story...")
$T.AE(0,"02:00:45",":...because SOMEBODY might have their FACTS incorrect, and then walk in, and then ask questions like...")
$T.AE(0,"02:00:53",":...why are you talking about a case from a couple years ago, so...")
$T.AE(3,"02:00:54",":Ok.") # Michael Whiteacre admitting that I'm openly insulting his [integrity/due-diligence] to his face.)
$T.AE(0,"02:00:56",":So...")
$T.AE(3,"02:00:56",":Alright.") # Making an admission that he might've fucked up after all. Sounds IDENTICAL to JUDGE PELAGALLI on 4/6/21.)
$T.AE(0,"02:00:58",":The reason why uh, I'm talking about it with you right now, is because...")
$T.AE(0,"02:01:01",":Uh- like I said, I believe that my AUNT TERRI was INVOLVED with the MURDER ATTEMPT on MAY 26th, 2020, and SO WAS SCOTT SCHELLING")
$T.AE(0,"02:01:13",":Because, THAT RECORD (SCSO-2020-028501) indicates that uh, SCOTT SCHELLING had me in custody along with JEFFREY KAPLAN AND WROTE NO NOTES ABOUT THE INTERACTION.")
$T.AE(3,"02:01:26",":Ok.")
$T.AE(0,"02:01:27",":...and then, uh, I had a FEELING that SCOTT SCHELLING was gonna do something BAD to me, and...")
$T.AE(0,"02:01:33",":when he offered me this ULTIMATUM, either I arrest you and bring you to the JAIL with THIS DEVICE here that I had evidence of calling 911 on...")
$T.AE(0,"02:01:44",":Or... you can... allow ME to bring you home.")
$T.AE(3,"02:01:52",":Mike, when you told ME about this, didn't I tell you to go to the supervisor...?")

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

$T.AE(0,"02:01:53",":I did.") # It's [hard/impossible] to condense those boxes ABOVE into a single 2 second statement, without causing CONFUSION.
$T.AE(3,"02:01:54",":Ok, cause there's NOTHING WE CAN DO about that.") # I disagree, there certainly is, buddy.
$T.AE(0,"02:01:58",":Well, I think this guy CAN do something about it.")
$T.AE(1,"02:01:59",":Well, I told ya I'd look into it, and see what the deal was, but yeah.")
$T.AE(3,"02:02:02",":Did you reach out to, I believe it was SGT WELCH at the time...?")
$T.AE(0,"02:02:05",":Yes.") # Mentioned in the box above, it's how I got the record for the ZAPPONE DEALERSHIP incident.
$T.AE(3,"02:02:06",":Did you reach out to him...?")
$T.AE(0,"02:02:06",":I did. So, uhm...")
$T.AE(0,"02:02:12",":Allow me collect my thoughts here, uh-")

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
# | Here's a guy from SCSO that LITERALLY asked me to clue him in on this book I was writing back on...           |
# | 06/23/2022 | SCSO SPEZIALE | https://drive.google.com/file/d/1Q5JgJ_LLf4PYsil54_hHVo90kG7gViU6                |
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

$T.AE(1,"02:02:26",":Let me look into this, and I'll check with Sergeant Welch, he'll back probably Monday or Tuesday... he's not in today.")
$T.AE(0,"02:02:33",":In reference to what happened that night, I did follow up with Sergeant Welch a couple times.") # It's how I obtained records.
$T.AE(1,"02:02:39",":Yep.")
$T.AE(0,"02:02:42",":Uh- the case that I'm making here, is that uh- I suspected FOUL PLAY with SCOTT SCHELLING cause he said something...")
$T.AE(0,"02:02:46",":...that he would've ONLY KNOWN... if he had a tap into my phone.") # ESPIONAGE with PEGASUS
$T.AE(1,"02:02:50",":Alright.")
$T.AE(0,"02:02:51",":So I mentioned something to you EARLIER, I won't repeat that-")
$T.AE(0,"02:02:58",":but- I asked JEFF- I asked- uh, when SCOTT SCHELLING made this uh- ULTIMATUM, either I arrest you and bring you to the jail, with this device that has your 911 calls on it... or... I bring you home. And, when I said 'Well, if you're gonna bri- if you're gonna give me an ULTIMATUM, uh- 'how about THIS GUY, JEFFREY KAPLAN follow you...?'")
$T.AE(0,"02:03:17",":Well, uh- JEFFREY KAPU- JEFFREY KAPLAN, followed SCOTT SCHELLING TO my house, so there's a SECONDARY LOCATION on THAT INCIDENT, and, THAT INCIDENT was LEFT OUT OF MY RECORDS REQUEST.")
$T.AE(0,"02:03:31",":I submitted a FOIL REQUEST for ALL OF THE RECORDS I WAS INVOLVED IN between MAY 19th (2020) and SEPTEMBER 4th (2020)")
$T.AE(0,"02:03:38",":So I was able to obtain the record that HE WAS INVOLVED IN, 1 or 2 of them, uh, as well as uh, the record with uh... the ONE record that I wanted the MOST, was THAT ONE RIGHT THERE, and...")
$T.AE(0,"02:03:53",":...when I got it I realized that there were NO NOTES attached to it, and uh- what I'm noticing is that if I try to call 911 a couple times, and it doesn't make it to the DISPATCH STATION, oh well.")
$T.AE(0,"02:04:04",":There was a CRIME that was COMMITTED TO ME, but I REPORTED IT TO A POLICE OFFICER, and HE DID NOTHING ABOUT IT.")

# ___________________________________________________________________________________________________________________________________
# | Well, he DID do something about it, and so did MICHAEL ZURLO.                                                                   |
# | They both committed OBSTRUCTION OF JUSTICE: DESTRUCTION OF EVIDENCE, and charged me with CRIMINAL MISCHIEF OF THE FOURTH DEGREE |
# | Pretty cool, huh...?                                                                                                            |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"02:04:07",":And then, I suspected that the POLICE OFFICER in SPECIFIC, uh, HAD UH- SOME NEFARIOUS INTENT, and then...")
$T.AE(0,"02:04:16",":And then, when he brought me back to my house, JEFFREY KAPLAN was remained in HIS VEHICLE, uh-")
$T.AE(0,"02:04:24",":And then, SCOTT SCHELLING came (around his car) to let me OUT, and he ASKED ME MULTIPLE QUESTIONS.")
$T.AE(0,"02:04:28",":The QUESTIONS that he asked me, (are in the book, CHAPTER - THE WEEK), were...")
$T.AE(0,"02:04:32",":(Schelling) So you made 911 calls...?")
$T.AE(0,"02:04:33",":And I said 'Yes, if you GO TO CENTER FOR SECURITY, THEY SHOULD BE ABLE TO CORROBORATE THAT STORY or the EVIDENCE.'")
$T.AE(0,"02:04:40",":Well, uh... I think that SCOTT SCHELLING went there, and DESTROYED the evidence.")
$T.AE(0,"02:04:44",":And then ALSO, uh- I told him that I UPLOADED THE AUDIO RECORDINGS AT COMPUTER ANSWERS and he seemed to be INCREDIBLY, uh...")
$T.AE(0,"02:04:55",":...CONCERNED about that. Cause I think that SOMEBODY had an AUDIO TAP to my phone.")
$T.AE(0,"02:05:05",":And, I think that, uh- the REASON he never COLLECTED any of the EVIDENCE from my phone, uh-")
$T.AE(0,"02:05:12",":...indicates MALICIOUS INTENT. And that I think it was an ORDER FROM HIS SUPERVISOR.") # Not JOSHUA WELCH... MICHAEL ZURLO.
$T.AE(1,"02:05:18",":Alright.")
$T.AE(0,"02:05:19",":I have ALL OF THE EXHIBITS and the PICTURES, as well as uh, the DATE THEY WERE TAKEN...")
$T.AE(1,"02:05:24",":Can you get em on a THUMBDRIVE...?")

# _____________________________________________________________________________________________________________________
# | They are ALL in my book, Top Deck Awareness - Not News as well as a FILE on my GitHub project in a file named...  |
# | https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt                       |
# |-------------------------------------------------------------------------------------------------------------------|
# | The LAST SEVERAL ENTRIES of THAT PARTICULAR FILE, are the FILES that I (RECORDED/TOOK) immediately BEFORE the     |
# | MURDER ATTEMPT, [1597/1602 US-9] 05/25/20 2343 -> [1780 US-9] 05/26/20 0130. The VERY LAST ONE is the SCREENSHOT  |
# | of my 911 calls that FAILED TO MAKE IT TO THE DISPATCH STATION... So... Those were ALL UPLOADED IMMEDIATELY AFTER |
# | SCOTT SCHELLING DROPPED ME OFF AT THE SECONDARY LOCATION IN THAT TICKET, SCSO-2020-028501.                        |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$T.AE(0,"02:05:26",":Hey, I have uh- (they're all in the book) an EVIDENCE LIST.")
$T.AE(0,"02:05:29",":I can even give ya, I can write down my uh- GitHub project that's got all of this information.")
$T.AE(0,"02:06:00",":So, that's the SITE right there, there's a FOLDER on it that says EVIDENCE") # I meant RECORDS
$T.AE(0,"02:06:06",":Now, some of the LANGUAGE in some of my DOCUMENTS, will... seem... PRETTY OFFENSIVE...")
$T.AE(0,"02:06:14",":I'm gonna come right out and say that, ")
$T.AE(1,"02:06:14",":Is this TEE EIGHTCH YOU BEE...?")
$T.AE(0,"02:06:17",":Yes.")
$T.AE(1,"02:06:24",":... dot com, EM SEE SEE EIGHT ESS ESS")
$T.AE(0,"02:06:28",":EM SEE SEE EIGHT FIVE ESS")
$T.AE(1,"02:06:34",":Ok, it's FRIGHTNING ENTROPY")
$T.AE(0,"02:06:36",":Yep- uhm, FIGHTING ENTROPY, capital EFF, if you don't use the capital letters, it won't get to it, but uh-")
$T.AE(1,"02:06:44",":Ok.")
$T.AE(0,"02:06:45",":I can uhm, I could always EMAIL it to you, too, if you want.")
$T.AE(1,"02:06:49",":I'll go in there and take a look... ain't gonna hurt.") # It won't hurt YOU, it'll probably hurt someone's CREDIBILITY, though.
$T.AE(0,"02:06:52",":So, in uhm- on that website there's a FOLDER that says EVIDENCE") # I misspoke, it's not EVIDENCE, it's called RECORDS
$T.AE(1,"02:06:56",":Yep.")
$T.AE(0,"02:06:58",":And in that folder I have a file named SCSO-2020-028501-(EVIDENCE).txt, and what it has is like videos from the last several years. Of, ME, managing the COMPUTER ANSWERS shop, and uh- uh SUSPICIONS regarding the people that live across the street from me, uh, working with CAPITAL DIGITRONICS, CAPITAL DIGITRONICS provides the RADIO COMMUNICATIONS EQUIPMENT for the STATE POLICE. And then I recorded a couple videos of the STATE POLICE leaving multiple police cruisers running idle unattended outside of the station at the CLIFTON PARK PUBLIC SAFETY BUILDING, and then I recorded a video of me walking to my AUNTS HOUSE, on MAY 25th, 2020 abot 12 HOURS BEFORE THAT EVENT HAPPENED (SCSO-2020-028501), and SOMEBODY was preventing some of my files from making it to my GOOGLE DRIVE account. So, what's happening is, like I have VIDEOS of someone committing some obstruction to my device. So like, if I take a picture of uh- if I take a video of a police officer trying to SHOOT me to death, well, a police officer SOMEWHERE is gonna prevent that FILE from making it to the internet. And, uh- I believe, uh- I don't have- I didn't have a VIDEO of THAT, but the VIDEO that I DID have, that WAS ON THIS DEVICE...? Was, ALMOST AS BAD, and then I SHOWED the video to NEW YORK STATE TROOPER (SHAEMUS) LEAVEY on MAY 27th, 2020 at about NINE A.M., and (5) minutes AFTER I SHOWED IT TO HIM...? My device was REMOTELY DISABLED. (the White Apple iPhone 8+ that I showed him)")
$T.AE(1,"02:08:23",":Hm. Ok.")
$T.AE(0,"02:08:26",":So, I know it's been a couple of years, but I've uh- suspected that there is a RING OF CRIMINALS that work at the FBI, and the STATE POLICE, and the SHERIFFS OFFICE. and I am CERTAIN that MICHAEL ZURLO is involved.")
$T.AE(1,"02:08:40",":Ok. Well, let's get you back over to your bicycle.")
