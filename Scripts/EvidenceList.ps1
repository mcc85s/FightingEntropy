# // _________________________________________________________________________________
# // | How to make fun of people that call themselves POLICE OFFICERS/INVESTIGATORS  |
# // |===============================================================================|
# // | Create some classes that can CLASSIFY and ORGANIZE the amount of EVIDENCE     | 
# // | that the LAW ENFORCEMENT SYSTEM, JUSTICE SYSTEM, and SARATOGA COUNTY SERVICES |
# // | FUCKIN' SUCK AT COLLECTING/REVIEWING/SUBMITTING TO A COURTROOM                |
# // |===============================================================================|
# // | HEATHER COREY-MONGUE, PAUL PELAGALLI, <take notice>                           |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Class Evidence
{
    [UInt32] $Index
    [String] $Name
    [String] $Date
    [String] $Url
    Hidden [UInt64] $Size
    [String] $SizeMb
    [Object] $Hash
    Hidden [Object] $Content
    Evidence([UInt32]$Index,[String]$Name,[String]$Date,[String]$URL)
    {
        $This.Index   = $Index
        $This.Name    = $Name
        $This.Date    = $Date

        $This.URL     = $URL
        Write-Host "Invoking [~] [$($this.URL)]"
        $This.Content = Invoke-RestMethod $This.URL
        $This.Size    = $This.Content.Length
        $This.SizeMb  = "{0:n3} MB" -f ($This.Size/1MB)

        Write-Host "Creating [~] Temp file"
        $Temp    = New-TemporaryFile

        Write-Host "Setting [~] Content"
        Set-Content $Temp.Fullname $This.Content
        
        Write-Host "Getting [~] File hash"
        $This.Hash    = Get-FileHash $Temp.Fullname | % Hash
        
        Write-Host "Removing [~] File"
        Remove-Item $Temp
    }
    [String] Padding([UInt32]$Length,[String]$String)
    {
        $Padding = @(" ") * ($Length - $String.Length) -join ''
        Return ("{0}{1}" -f $String,$Padding)
    }
    [String[]] ToString()
    {
        $Obj     = @{0="";1="";2="";3="";4="";5="";6=""}
        $Length  = [UInt32]($This.PSObject.Properties.Value | % Length | Sort-Object)[-1].Length
        
        $Obj[0]  = @([char]95) * $Length -join ''

        $Obj[1]  = "| Index : {0}" -f $This.Index
        $Obj[1] += $This.Padding($Length,$Obj[1])

        $Obj[2]  = "| Name  : {0}" -f $This.Name
        $Obj[2] += $This.Padding($Length,$Obj[2])

        $Obj[3]  = "| Date  : {0}" -f $This.Date
        $Obj[3] += $This.Padding($Length,$Obj[3])

        $Obj[4]  = "| Url   : {0}" -f $This.Url
        $Obj[4] += $This.Padding($Length,$Obj[4])

        $Obj[5]  = "| Size  : {0}" -f $This.SizeMb
        $Obj[5] += $This.Padding($Length,$Obj[5])

        $Obj[6] = "| Hash  : {0}" -f $This.Hash
        $Obj[6] += $This.Padding($Length,$Obj[6])

        $Obj[7] = @([char]175) * $Length -join ''

        Return @($Obj[0..7])
    }
}

Class EvidenceList
{
    [Object] $Output
    EvidenceList()
    {
        $This.Output = @( )
    }
    AddEntry([String]$Name,[String]$Date,[String]$URL)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Evidence name already exists"
        }
        ElseIf ($Url -in $This.Output.URL)
        {
            Throw "Evidence URL already exists"
        }

        Write-Host "Adding [+] $Name"
        $This.Output += [Evidence]::New($This.Output.Count,$Name,$Date,$URL)

        $This.Rerank()
    }
    RemoveEntry([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        $This.Output  = $this.Output | ? Index -ne $Index

        $This.Rerank()
    }
    [Object] Get([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        Return $This.Output[$Index]
    }
    Rerank()
    {
        Switch ($This.Output.Count)
        {
            {$_ -eq 1}
            {
                $This.Output[0].Index = 0
            }
            {$_ -gt 1}
            {
                ForEach ($X in 0..($This.Output.Count-1))
                {
                    $This.Output[$X].Index = $X
                }
            }
        }
    }
}

$Evidence = [EvidenceList]::new()

# // _____________________________________________________________________________________________
# // | Tab #1 / Original file that I got from the SCSO Records department, SEPTEMBER 04, 2020    |
# // |===========================================================================================| (Admittedly has a lot of records that I didn't need.)
# // | Note: This is a PDF file that is <MISSING the MOST IMPORTANT RECORD> from 05/26/2020 0130 |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Evidence.AddEntry("SCSO Records Request #1","09/04/2020","https://drive.google.com/file/d/12JmI7Qsg1Ohcl7s_Asui9QuQxHq6wJJE")

$Item = $Evidence.Get(0)

Index : 0
Name  : SCSO Records Request #1
Date  : 09/04/2020
Url   : https://drive.google.com/file/d/12JmI7Qsg1Ohcl7s_Asui9QuQxHq6wJJE
Hash  : C6CFBC2788B3C587E130383D675A260F3E872F1477CF96ADD98C2C7FA947BA85

# // _____________________________________________________________________________________________
# // | Tab #2 / Original file that I got from the SCSO Records department, FEBRUARY 08, 2021     |
# // |===========================================================================================| (Makes all of ^ those records totally irrelevant/meaningless)
# // | Note: This is <the MOST IMPORTANT RECORD> from 05/26/2020 0130 when I was ALMOST MURDERED |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Evidence.AddEntry("SCSO Records Request #2","02/03/2021","https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA")

# // _____________________________________________________________________________________________
# // | Tab #3 / ALTERED FILE that somehow got ADDED TO MY GOOGLE DRIVE ACCOUNT on JUNE 12, 2022  |
# // |===========================================================================================| (Anomaly that's [MATHEMATICS & COMPUTER] RELATED...)
# // | Note: This particular file has a GIGANTIC array of DIFFERING FONT SIZES, CHARACTERS, etc. |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Evidence.AddEntry("CICADA/ANONYMOUS #1","06/12/2022","https://docs.google.com/document/d/18d7JOeC5WJvDE2LumnoNReOzFZ2gu0dGw5p8KPgiapY")


# // __________________________
# // | Check out this ANOMALY |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Evidence.Get(2).Content
# (^ This particular file is PROOF/EVIDENCE that someone from...)
# _____________
# |    CICADA | A collective of (HACKERS/BRAINIACS/GENIUSES/WIZARDS)... pretty sure they're not the bad guys.
# |-----------|
# | ANONYMOUS | A legion of smart bastards that are often highly misunderstood by people in SOCIETY
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

# Either way you look at it, smart bastards. 
# They're basically CYBERCOMMANDOS... but, even more top notch than that.
# THEY have been trying to GUAGE how I pick up on PATTERNS.

# ____________             _________________     ____________
# | PATTERNS | Things that | INVESTIGATORS | are | SUPPOSED | to pick up on when they're DOING their JOB.
# ¯¯¯¯¯¯¯¯¯¯¯¯             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     ¯¯¯¯¯¯¯¯¯¯¯¯                            ¯¯¯¯¯       ¯¯¯
# SUPPOSED to, being the key term. Maybe (I'm) the ASSHOLE, for thinking they're SUPPOSED to do a god damn thing...
# 
# /¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\
# 
# Investigators : *chuckles* Heh.
#                 Yeh right, Michael Cook.
#                 We don't HAVE to do shit, bro.
#                 YOU do.
# Me            : Whatever dude.
# Investigators : *chuckles* Buddy, you gotta do whatever.
#                 ...cause if ya don't...?
#                 *shakes head* ...won't be too good for ya.
# Me            : Nah.
#                 You do it.
#                 I'm all set.
# 
# \__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/

# Normally, an investigator from like, fuckin' IDK man...
# ...maybe investigators are too lazy to pick up on this shit.

# IN each of the pictures in this folder...
# $SCRIBBLES = "https://drive.google.com/drive/folders/1wukJYJanYKBfUX34WIhEeoamnsfuTDlg"
# ...there's a LINE OF CHARACTERS that is being ALTERED a SLIGHT AMOUNT, so that it appears
# as if someone who's a very skilled programmer can communicate with me via these lines of text.

# I even uploaded a thing called a VIDEO...
# If you've never heard of the word called VIDEO...?
# Well, it's a FILE that you can access by entering a fucking link into a web browser.
# THEN what happens is that a MOTION PICTURE shows up on the display of that device.
# This is stuff that SOME PEOPLE GET PAID A LOT OF MONEY TO 1) ORGANIZE, 2) SHOWCASE, and 3) BUILD for a CASE/TRIAL.
# Typically this type of shit can even land people in PRISON after it is brought into a COURTROOM.

# https://www.youtube.com/watch?v=e4VnZObiez8
# (^ What EVIDENCE looks like)

$Evidence.Get(2)

# // ___________________________________________________________________________________________
# // | Index : 2                                                                               |
# // | Name  : CICADA/ANONYMOUS #1                                                             |
# // | Date  : 06/12/2022                                                                      |
# // | Url   : https://docs.google.com/document/d/18d7JOeC5WJvDE2LumnoNReOzFZ2gu0dGw5p8KPgiapY |
# // | Hash  : BAF22BE2E889BFA830B783170A380F93262048CFFBAF712F5728B69FC1CA7E3B                |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# I was gonna say, NORMALLY, an investigator might consider something like ^ THIS...
# as this SPECIFIC THING that they are SUPPOSED to (DETECT/COLLECT), otherwise known as (EVIDENCE/CLUES).

# _________
# | CLUES |
# ¯¯¯¯¯¯¯¯¯
# Things that allow INVESTIGATORS or POLICE OFFICERS, or really, whoever ... to like, figure something out.
# They're not supposed to IGNORE clues... cause that's not being a very good INVESTIGATOR.
# Nah.

# From what I can tell...? 
# The INVESTIGATORS that I used to think exist...? 
#                          ¯¯¯¯ 
# They don't actually exist...
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Nah.
# Not at *ANY* police (station/building) from what I currently understand.

# You can show them EVIDENCE and CLUES...?
# But they will probably arrest you for doing something that DANGEROUS.
# Yeah, showing people EVIDENCE...?
# It can cause some people to be violently killed by the police.
# Totally fuckin serious about that.
# In MOST cases, the police will take the evidence...?
# And then throw it in the trash. (<- All I've ever seen them do.)

# Cause if they looked for EVIDENCE and CLUES...? 

# They could see that SOMEBODY who APPEARS to have the behavior of smoking some fuckin' bath salts...
# came up with this brilliant plan to EXTRACT the data from the PDF file I received from SCSO RECORDS, 
# waaaaaaaaay back on SEPTEMBER 04, 2020. (Appearances can be deceiving, because there's a PATTERN in
# the $CONTENT up above... So.)

# I don't know if it's a BAD guy, or a GOOD guy... but the FEELING that I got when I FIRST saw it, 
# was NOT good. Nah. Felt like somebody wants to kill me again.

# Might not even be a guy.
# Might be a girl.
# Smart girl, or guy.
# Who the hell knows...?

# Then, (6) months later, I contacted the SCSO ADMINISTRATIVE OFFICE, and spoke to a guy named
# CAPTAIN JEFF BROWN, and he like, gave me the INCIDENT NUMBER that I was looking for in my original 
# request...

# So that ENTIRE (6) months...? A lot of retarded people accused me of shit that I never did.
#                               ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# They STILL like to do stuff like this, because of how retarded they are (like on 06/28/22)
# They can't help it, though... because, how could they...?
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# Planet Earth has a LOT of retarded people on it.
# I'm not talking about MENTALLY CHALLENGED PEOPLE, either. (<- I'm not poking fun at these people)

# I'm talking about people that think they're intelligent...? But, aren't. (<- like BRUCE TANSKI)
# They talk in a way where they constantly say things that sound like "Screen door on a submarine"
# Basically this means they're RETARDED and they use FALLACIOUS LOGIC on a CONSTANT BASIS.

# For instance, WILLIAM MOAK who lives at 200D Halfmoon Circle, Clifton Park, NY 12065.
# My mother, FABIENNE SILVIE KIVLEN COOK, who lives at 201D Halfmoon Circle, Clifton Park, NY 12065.

# These people literally argue with things called FACTS.
# Sometimes they'll even argue with DEFINTIONS in a god damn DICTIONARY.
# ...
# Then they'll LIE TO POLICE OFFICERS to get someone in trouble.
# Mainly because of how RETARDED they are.

# A lot of these creatures exist in SARATOGA COUNTY, NEW YORK.

# MORE retarded people, than NON-retarded people, from what I can tell.
# Otherwise, somebody could've like, investigated this shit, right...?
# But- nah bro. 

# Stupid people exist in large numbers, in CLIFTON PARK, NEW YORK.
# But they ALSO exist in OTHER adjacent towns, such as:
# ____________________________________________
# | MALTA | HALFMOON | BALLSTON SPA | ALBANY | The list goes on, actually, for a while.
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#              ______________
# They like to | CONGREGATE | at places like:
#              ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 1) Clifton Park Public Safety Building 
#    (Trooper entrance [i.e. RUFFAS, BOSCO, MESSINES, DERUSSO, BORDEN])
# 2) Clifton Park Fire Department
#    (many of the Sheriffs from SCSO that think MICHAEL ZURLO is an AWESOME DUDE... [he isn't])
# 3) 6010 County Farm Road
#    (where Michael Zurlo hangs out and does no work all week long)
# 4) 1597 US-9/Catricala Funeral Home
# 5) 1 Cemetery Road
# 6) 2 Cemetery Road
# 7) 9 Meyer Road 
# 8) Fairways of Halfmoon
# 9) Wherever else that BRUCE TANSKI hangs out, being as gay as he is

# Even...
# IDK man. 
# Maybe at some point some of these fuckin idiots tha call themselves INVESTIGATORS...
# MAYBE... some of them will make an effort to
# _____________________________________________
# | pull their heads out of their ASSHOLES... | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Right...? 
# THEN, they can LOOK AT all this fuckin' EVIDENCE I've been ACCUMULATING...

# Some of the EVIDENCE is this fuckin array of characters right below...
