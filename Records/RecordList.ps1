Class EntryItem
{
    [UInt32] $Index
    [String] $Name
    [String] $Url
    EntryItem([UInt32]$Index,[String]$Name,[String]$Url)
    {
        $This.Index = $Index
        $This.Name  = $Name
        $This.Url   = $Url
    }
    [String] ToString()
    {
        Return "| {0} | {1} | {2} |" -f $This.Index, $This.Name, $This.Url
    }
}

Class EntryList
{
    [UInt32]  $Count
    [Object] $Output
    EntryList()
    {
        $This.Output = @() 
    }
    Add([String]$Record,[String]$Name,[String]$Url)
    {
        If ($Name -in $this.Output.Name)
        {
            Throw "Entry already specified"
        }

        $This.Output += [EntryItem]::New($This.Output.Count,$Name,$Url)
        Write-Host ("Added [+] [Record: {0}, Responder: ({1}), Name: {2}]" -f $Record, $This.Count, $Name)
        $This.Count  ++
    }
    [String] ToString()
    {
        $Str = $Null
        If ($This.Count -eq 0)
        {
            $Str = "<Empty>"
        }
        Else
        {
            $Str = $This.Output -join "`n"
        }
        Return "({0})`n{1}" -f $This.Count, $Str
    }
}

Class ResponderItem
{
    [UInt32]            $Index
    [String]             $Name
    [String]             $Unit
    [DateTime]     $Dispatched
    [DateTime]        $Enroute
    [TimeSpan] $EnrouteElapsed
    [DateTime]        $Arrival
    [TimeSpan] $ArrivalElapsed
    [TimeSpan]   $TotalElapsed
    ResponderItem([UInt32]$Index,[String]$Name,[String]$Unit)
    {
        $This.Index          = $Index
        $This.Name           = $Name
        $This.Unit           = $Unit
    }
    Set([Object]$Dispatched,[Object]$Enroute,[Object]$Arrival)
    {
        $This.Dispatched     = $Dispatched
        $This.Enroute        = $Enroute
        $This.EnrouteElapsed = $Dispatched+$Enroute
        $This.Arrival        = $Arrival
        $This.ArrivalElapsed = $Enroute+$Arrival
        $This.TotalElapsed   = $Dispatched+$Arrival
    }
    [String] ToString()
    {
        Return "| {0} | {1} | {2} |" -f $This.Index, $This.Name, $This.Unit
    }
}

Class ResponderList
{
    [UInt32] $Count
    [Object] $Output
    ResponderList()
    {
        $This.Output = @( )
    } 
    Add([String]$Record,[String]$Name,[String]$Unit)
    {
        $This.Output += [ResponderItem]::New($This.Count,$Name,$Unit)
        Write-Host ("Added [+] [Record: {0}, Responder: ({1}), Name: {2}]" -f $Record, $This.Count, $Name)
        $This.Count  ++
    }
    [String] ToString()
    {
        $Str = $Null
        If ($This.Count -eq 0)
        {
            $Str = "<Empty>"
        }
        Else
        {
            $Str = $This.Output -join "`n"
        }
        Return "({0})`n{1}" -f $This.Count, $Str
    }
}

Class NarrativeItem
{
    [UInt32] $Index
    [String] $Content
    NarrativeItem([Uint32]$Index,[String]$Content)
    {
        $This.Index   = $Index
        $This.Content = $Content
    }
    [String] ToString()
    {
        Return $This.Content
    }
}

Class NarrativeList
{
    [UInt32] $Count
    [Object] $Output
    NarrativeList()
    {
        $This.Output = @( )
    }
    Add([String]$Name,[String]$String)
    {
        $Content = $String -Split "`n"
        $Content | % { 
            
            $This.Output += [NarrativeItem]::New($This.Output.Count,$_)
            $This.Count  ++ 
        }

        Write-Host ("Added [+] [Record: {0}, Narrative: ({1})]" -f $Name, $Content.Count)
    }
    [String] ToString()
    {
        $Str = $Null
        If ($This.Count -eq 0)
        {
            $Str = "<Empty>"
        }
        Else
        {
            $Str = $This.Output.Content -join "`n"
        }
        Return "({0})`n{1}" -f $This.Count, $Str
    }
}

Class Record
{
    [UInt32]         $Index
    [String]          $Name
    [String]          $Date
    [DateTime]     $Receive
    [DateTime]    $Transmit
    [TimeSpan]     $Elapsed
    [Object]     $Responder
    [Object]         $Entry
    [Object]     $Narrative
    Record([UInt32]$Index,[String]$Name,[String]$Date,[String]$Transmit)
    {
        $This.Index     = $Index
        $This.Name      = $Name
        $This.Date      = $Date.Split(" ")[0]
        $This.Receive   = [DateTime]$Date
        $This.Transmit  = [DateTime]$Transmit
        $This.Elapsed   = [TimeSpan]($This.Transmit-$This.Receive)
        $This.Responder = [ResponderList]::New()
        $This.Entry     = [EntryList]::New()
        $This.Narrative = [NarrativeList]::New()
    }
    AddResponder([String]$Name,[String]$Unit)
    {
        If ($Name -in $This.Responder.Output.Name)
        {
            Throw "Responder already specified"
        }

        $This.Responder.Add($This.Name,$Name,$Unit)
        
    }
    AddEntry([String]$Name,[String]$Url)
    {
        If ($Name -in $This.Entry.Output.Name)
        {
            Throw "Entry already added"
        }

        $This.Entry.Add($This.Name,$Name,$Url)
    }
    AddNarrative([String]$String)
    {
        $This.Narrative.Add($This.Name,$String)
    }
}

Class RecordList
{
    [String] $Name
    [Object] $Output
    RecordList([String]$Name)
    {
        $This.Name   = $Name
        $This.Output = @( )
    }
    AddRecord([String]$Name,[String]$Receive,[String]$Transmit)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Record already exists"
        }

        If ($Receive -notmatch "\d{2}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}")
        {
            Throw "Invalid received date/time"
        }

        If ($Transmit -notmatch "\d{2}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}")
        {
            Throw "Invalid transmitted date/time"
        }

        $This.Output += [Record]::New($This.Output.Count,$Name,$Receive,$Transmit)
        Write-Host ("Added [+] [Record: {0}, Name: {1}]" -f ($This.Output.Count-1), $Name)
    }
    [Object] Get([Uint32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Invalid index"
        }

        Return $This.Output[$Index]
    }
}

$List   = [RecordList]::New("SCSO Record List")

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-002998 [05/19/20]                                                                    ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name   = "SCSO-2020-002998"
$List.AddRecord($Name,"05/19/20 20:18:59","05/19/20 20:19:00")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("Anthony Agresta","<UNSPECIFIED>"),
("Sean Lyons","<UNSPECIFIED>"),
("John Hildreth","<UNSPECIFIED>") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-002998 (1).JPG","https://drive.google.com/file/d/1ykNZKM_VS0NWdckqVToSmL-ujjTBl4zz"),
("SCSO-2020-002998 (2).JPG","https://drive.google.com/file/d/1i4s7_tiT5bdNWsydqIMDMFFRRrOx1-zZ"),
("SCSO-2020-002998 (3).JPG","https://drive.google.com/file/d/17K2GMKn6hx3CF_HrSuB8Z_HfPlUKmNkQ") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
Someone was stalking me in a blue truck, they did this whenever I carried around my Apple iPhone 8 Plus.
I told my stepfather about it and he laughed in my face, because he didn't understand WHY someone
would be stalking me.

Here's why:
___________________________________________________________________________________________________________
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0001 | Facebook Post #1 | 05/19/20 0840                                                                 |
|______|__________________|_______________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Class Action Lawsuit vs Spectrum/Charter Communications, Verizon Communications, and more...            |
|          ___________________________________________________________________________________            |
|          | 10/04/19 1600 | 2021 0207 Buffer Overflow Attack | https://youtu.be/H4MlJnMh9Q0 |            |
|          | 10/04/19 1200 | HDMI Interfere                   | https://youtu.be/in7IrkoLOHo |            |
|          | 10/21/19 1144 | 2019-10-21...                    | https://youtu.be/zs0C_ig-4CQ |            |
|          | 12/09/19 1600 | TWITTER BSOD/CIA/Assassin        | https://youtu.be/12x8TrO9B5Q |            |
|          ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            |
|_________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
That's what's called a FACEBOOK POST with some INFORMATION as to WHY I was saying the things I was 
saying. It does under certain conditions, when there aren't MORONS who work at the local police department
involved, COUNT AS EVIDENCE... in what they ALSO have a hard time knowing how to do...
"PERFORMING AN INVESTIGATION".

Cool shit, huh...? I'm sure there are SOME officers that'll take offense to being told that they suck
ass at their job... But, guess what...? I've literally talked to MICHAEL HOSCHEK from SPECTRUM SECURITY,
as well as CHRISTOPHER MURPHY from the FEDERAL BUREAU OF INCOMPETENCE... Yeah, back on like 01/27/20.
I have contacted the FBI numerous times regarding the shit that you see in those links up above.

Guess how fucking amazingly helpful they are...?
They're not.
___________________________________________________________________________________________________________
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0002 | Facebook Post #2 | 05/19/20 0951                                                                 |
|______|__________________|_______________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Spectrum/Verizon, w/ pictures. I've been collecting SPECULATIONS/EVIDENCE of these two organizations    |
| working directly with Nfrastructure... As I talk about throughout my BOOK and stuff...                  |
| NFRASTRUCTURE...? Had employee perks for VERIZON contracts. If you worked for NFRASTRUCTURE...?         |
| You got a WICKED NICE DISCOUNT on VERIZON SERVICE. Guess what else...?                                  |
|                                                                                                         |
| VERIZON basically owns the content of your device, so if you send TEXT MESSAGES, or make PHONE CALLS,   |
| or make certain SOCIAL MEDIA UPDATES, or WHATEVER...? Dan Pickett can fire your ass if he doesn't like  |
| what he sees. Which is EXACTLY what I believe they did. AND, they can do this shit with SPRINT.         |
|                                                                                                         |
| Since I sent a MESSAGE to Matthew Roerig (former Computer Answers, was at Nfrastructure on 01/15/19),   |
| about an AUDIO RECORDING I had made on my APPLE iPHONE 8+, SOMEHOW MR. PICKETT GOT A HOLD OF THAT FILE. |
| The recording was recorded on the 8th anniversary of when I was FIRED, 01/11/11.                        |
|                                                                                                         |
| Audio recording talking about Mr. Pickett on 01/11/19...?                                               |
| Highly sophisticated cyberattack involving CVE-2019-8936, DDOS, WannaCry RANSOMWARE, and ESPIONAGE.     |
|                                                                                                         |
| Also involving the CISCO WIRELESS ACCESS POINT (LAP 1142 or whatever) THAT I PURCHASED FROM             |
| NFRASTRUCTURE. Coincidence...? Well, if you consider like 12 things COINCIDENTAL...? Then, yeah.        |
| But, (12) COINCIDENTAL LOOKING THINGS doesn't actually APPEAR to be COINCIDENTAL, ya know...?           |
| Nah, if anything, you would have to be a fucking TOTAL MORON, to think all that shit was COINCIDENTAL.  |
|                  _____________________________________________________________________                  |
|                  | Side 1 | MICHAEL COOK, DR. KITE, ST. PETERS, July 21, 1989        |                  |
|                  | Side 2 | Jesse Pickett 785-3221 ← written by my dead father.      |                  |
|                  | https://drive.google.com/file/d/1y05kPm-CjVIALi6r8CNPMlIRnXvMtPpD |                  |
|                  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                  |
| Oh, by the way... DAN PICKETT lived on CEMETERY ROAD, which is the same road that TIM BERLIN lives, as  |
| well as where BRUCE TANSKI's fuckin' office is. That's GOTTA be COINCIDENTAL as well, right...?         |
| Yeah, all this shit would be COINCIDENTAL if you're a fucking moron, like my stepfather is.             |
|_________________________________________________________________________________________________________|
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| #### | Name     | Date/Time     | % | URL                                                               |
|______|__________|_______________|___|___________________________________________________________________|
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0001 | IMG_0352 | 05/19/20 0853 | 0 | https://drive.google.com/file/d/1CwjZnISueJRPXKuD-44G6s74AeFN8jqW |
| 0002 | IMG_0353 | 05/19/20 0853 | 0 | https://drive.google.com/file/d/1zM3bf2VP_j3RzjvxrcX9Ax-nDykfGFd5 |
| 0003 | IMG_0354 | 05/19/20 0859 | 0 | https://drive.google.com/file/d/1DzL5Nw2HZUEoAj3z1L6eAogZe5YIEXRf |
| 0004 | IMG_0355 | 05/19/20 0903 | 0 | https://drive.google.com/file/d/1vkFywPIlU4LPaMjd3wmiwAJHjdqqN5xx |
| 0005 | IMG_0356 | 05/19/20 0907 | 0 | https://drive.google.com/file/d/1q1l1bXvxqZQvGjtK6kxKQoLXmnr5e6tj |
| 0006 | IMG_0357 | 05/19/20 0908 | 0 | https://drive.google.com/file/d/19MiE3SAjFahgooXy7Iobd18vmYK9gA5- |
|_________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
___________________________________________________________________________________________________________
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0003 | Facebook Post #3 | 05/19/20 1249                                                                 |
|______|__________________|_______________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Theodore Roosevelt was the 26th President of the United States of America.                              |
| Before that, he was part of the Civil Service, then he became an assemblyman, governor of NYS, and then |
| eventually became president of the United States between 1900-1908.                                     |
|                                                                                                         |
| He established the FOOD AND DRUG ADMINISTRATION, as well as the BUREAU OF INVESTIGATION which           |
| eventually became the (FBI/FEDERAL BUREAU OF INVESTIGATION) where it's mission statement is as follows: |
| TO UPHOLD THE CONSTITUTION OF THE UNITED STATES OF AMERICA.                                             |
|                                                                                                         |
| He also helped build the PANAMA CANAL, told lazy fuckstains to fuck off here and there, and then he     |
| also had a famous quote "Walk softly, but carry a big stick."                                           |
| He didn't finish that quote in PUBLIC, but the rest of the sentence goes:                               |
| "...because you never know when you'll have to crack it over somebody's head for lying to your face."   |
|_________________________________________________________________________________________________________|
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| #### | Name     | Date/Time     | % | URL                                                               |
|______|__________|_______________|___|___________________________________________________________________|
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0001 | IMG_0360 | 05/19/20 1035 | 0 | https://drive.google.com/file/d/1MzYGAsDvTKuQ2oWuJBzd0kppymtFXlaa |
| 0002 | IMG_0361 | 05/19/20 1035 | 0 | https://drive.google.com/file/d/1_s5uK7tqEUak8iSJezERQM5njhQbzTfW |
| 0003 | IMG_0362 | 05/19/20 1055 | 0 | https://drive.google.com/file/d/1bRnZWSk8JjwA8jvX-WP_VHB_sqGFuu5Z |
| 0004 | IMG_0363 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/1u29vbEoFZAYQ5QfN2Q05bL1NzXAFljda |
| 0005 | IMG_0364 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/1-z2gTDPSFuChBevH-pn9aBStK4h3-cmZ |
| 0006 | IMG_0365 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/13YA9h7EoCqV0YTe2dOtKX5mZKAPdLgVP |
| 0007 | IMG_0366 | 05/19/20 1059 | 0 | https://drive.google.com/file/d/1SyNFeOBZiqxRh8uFJ_l6pdStqEZRzoLW |
| 0008 | IMG_0367 | 05/19/20 1103 | 0 | https://drive.google.com/file/d/1l2MKEDRpHtf91F8JAzM0sjy8Ixmq-GCz |
| 0009 | IMG_0368 | 05/19/20 1105 | 0 | https://drive.google.com/file/d/1LZXbcKCNXj6WVD5dvB_1CYzEOCMnqARl |
| 0010 | IMG_0369 | 05/19/20 1105 | 0 | https://drive.google.com/file/d/1t_V6BoYO0qRukl03_4bzJJEF39N0UQNE |
| 0011 | IMG_0370 | 05/19/20 1106 | 0 | https://drive.google.com/file/d/1pSD6_XUGoslaRqj8TbQtCsJie5xTpxq5 |
| 0012 | IMG_0371 | 05/19/20 1108 | 0 | https://drive.google.com/file/d/14MGHNPwyrIVumyKEZk_kMxPdA2B7qHKD |
| 0013 | IMG_0372 | 05/19/20 1109 | 0 | https://drive.google.com/file/d/1AsVOl3RSGstfC_QGCP-uC7SfYD3ACD4b |
| 0014 | IMG_0373 | 05/19/20 1110 | 0 | https://drive.google.com/file/d/1zHE9NnbprpQdCrXzMk4CAS0FusaA1ebW |
| 0015 | IMG_0374 | 05/19/20 1111 | 0 | https://drive.google.com/file/d/1wrPF5gZZccU1vWl_HUD5HvtRU8sDSTK2 |
| 0016 | IMG_0375 | 05/19/20 1119 | 0 | https://drive.google.com/file/d/1ZsaEMlzXUFmUEjPj1dSNknVpZ7_spo5L |
| 0017 | IMG_0376 | 05/19/20 1120 | 0 | https://drive.google.com/file/d/1bAosuht9bP-gfjWbG95scD8h3WrxPF0_ |
| 0018 | IMG_0377 | 05/19/20 1122 | 0 | https://drive.google.com/file/d/1e3ihFjE522_wtcnyD9X6kV98XI6sf8D_ |
| 0019 | IMG_0378 | 05/19/20 1122 | 0 | https://drive.google.com/file/d/1rFcbTnB3Z8IyHIwaUvatdSgfANhUK78b |
| 0020 | IMG_0379 | 05/19/20 1123 | 0 | https://drive.google.com/file/d/1ntxzwl4nB-p2xCYsXLVfsLQ28de8wjdE |
|_________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
___________________________________________________________________________________________________________
|¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 0004 | Facebook Post #4 | 05/19/20 1644                                                                 |
|______|__________________|_______________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| In order to be taken seriously, sometimes you have to make an audio recording that someone gets to      |
| listen to. I probably shouldn't make this public...? But, I don't fucking care.                         |
|_________________________________________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 05/19/20 1400 | Live Redaction | https://drive.google.com/file/d/186dv0z0YLfafQT_tlJYYy9AhorERuSPw      |
|_______________|________________|________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
All of those things are the reason why someone in a BLUE TRUCK was STALKING ME, and following me around.
You know...?

Sometimes you have to be willing to offend people in UNIFORMS, or in SUITS, or who sit behind a fuckin'
office desk or like a fuckin', IDK man... sometimes you HAVE TO BE WILLING TO TELL PEOPLE HOW STUPID 
THEY ARE.

Sometimes they're INCREDIBLY RESPECTED PEOPLE, too.

What happens if someone who is INCREDIBLY RESPECTED, happens to be a fucking total oblivious moron...?
Well, legally speaking, you're not even ALLOWED to say ANYTHING BAD ABOUT THEM AT ALL.
ESPECIALLY if they're like, a JUDGE, or a POLICE OFFICER, or whatever.

Wanna know why...?
That shit, is totally uncalled for in their eyes.
That's what STUPIDITY will do to you, though.
STUPIDITY will prevent someone from seeing how something was DEFINITELY CALLED FOR AFTER ALL...?
But, being that ignorant prevents them from being able to make these things called...
CORRELATIONS.

Correlations.
Sorta like CONNECT-THE-DOTS.
You look for the number 1...?
Then, you look for number 2...?
And draw a fucking line from 1 to 2. Then, you CONTINUE THIS PROCESS all the way until the HIGHEST NUMBER.
At which point...? Well, holy shit. There's a picture of something that is pretty fuckin' easy to see.

Is it a TRANSFORMER, or an AMBULANCE...?
Or, is it a CORPORATE MONOPOLY where the government rolls over everybody's rights and calls it a FREE COUNTRY...?

Unfortunately, the police have a REALLY HARD TIME DOING THIS...
It's why I started writing a fucking book.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-027797 [05/23/20]                                                                    ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-027797"
$List.AddRecord($Name,"05/23/20 01:00:17","05/23/20 01:06:30")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddResponder("S43460SS Scott Schelling","SL4184")

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-027797 (1).jpg","https://drive.google.com/file/d/19Vkh-Uc_7yR9HJcmQnsttIo6H5tmUYzK"),
("SCSO-2020-027797 (2).jpg","https://drive.google.com/file/d/1CjjAS46TX-RfeSYkhKmXVKsD94pwBX7b"),
("SCSO-2020-027797 (3).jpg","https://drive.google.com/file/d/1CQjwnrFkAxL9meg63z1ttdyz5Hczs5RM"),
("SCSO-2020-027797 (4).jpg","https://drive.google.com/file/d/1dfL4ca_lwe_CBDO1ttfYcL5d4_koopWC"),
("SCSO-2020-027797 (5).jpg","https://drive.google.com/file/d/1yGBIQbo20b6sPovrJkOOM9EXIUdPF2zQ"),
("SCSO-2020-027797 (6).JPG","https://drive.google.com/file/d/1pfbyK6dlsFKC1JTDaKxdvdCJQl1HX_3W") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
Here's what I actually went to STRATTON AIR NATIONAL GUARD for.
________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 05/21/20 2358 [Originally recorded]                                                  |
|______________________________________________________________________________________|
|¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index | Info     | Hyperlink                                                         |
|_______|__________|___________________________________________________________________|
|¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
|     1 | Original | https://drive.google.com/file/d/1kl_zBSSEqGKk3ri3WKuiF9ISVZoyxErx |
|     2 | Treble+  | https://drive.google.com/file/d/13NPoJyRENfdy7_kwMVCjfrJccoU3MxUU |
|_______|__________|___________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Not only did these people think I was insane...? But they took the reason I went there, out of context.
That's because, of how stupid people actually are when I talk to them.

I can tell them "HEY, CHECK OUT THIS AUDIO RECORDING", and they'll be CONFUSED, and somehow
think that I said DRONES DISGUISED AS BIRDS.
That's how stupid people actually are, when I talk to them, on a daily fucking basis.

To make matters even more compelling...? 
I was able to collect ADDITIONAL EVIDENCE THAT THEY DIDN'T REALLY TAKE A GOOD LOOK AT, after I made it
to Schenectady.

It truly is such a RECURRING THEME... 
______________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Who is who | What is what                                                                                  |
|____________|_______________________________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Me      -> | Being more intelligent than most people                                                       |
| Them    -> | Thinking I'm insane, because they've been lied to so many times their entire life             |
| Me      -> | Not (lying/insane)... just being a LOT more (intelligent + observant + informed)...           |
| Them    -> | Failing to admit that's what it is, because my intelligence constantly bruises people's egos  |
|____________|_______________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"Never underestimate the power of stupid people in large groups." -George Carlin

How many dozens of ways should I slice this...? I'm not insane... 
I'm just a lot more intelligent than most people. That's ALL it is.
Am I the SMARTEST DUDE THAT EVER LIVED...? Nah.
Do I go around saying "HEY, SMARTEST DUDE YOU'LL EVER MEET IN YOUR LIFE, BRO~!"
Nope. I don't do that at all.
I just say "HEY, CHECK OUT THIS EVIDENCE I HAVE OF SOMETHING REALLY STRANGE~!"
And people immediately CONFUSE what the fuck I just said, like on a constant, every-day basis.
______________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Them : OoooOoOoHhHHhhhHHh Michael Cook said "Check out this audio recording of a bird."                    |
| Me   : Yeah, so what...?                                                                                   |
| Them : WOW BRO, THAT'S A REAL BIRD RIGHT THERE, DUDE.                                                      |
|        YOU'RE A FUCKIN' WHACK JOB~!                                                                        |
| Me   : I'm pretty sure it's not a real bird at all, because it sounds like it's ARTIFICIAL INTELLIGENCE.   |
| Them : YEA RIGHT BRO, IT'S NOT ARTIFICIAL INTELLIGENCE, GO EAT A DICK~!                                    |
| Me   : Whatever you fuckin' moron.                                                                         |
|        I'd be willing to bet money on it, that DARPA made a project that does that.                        |
|        And, that they were interested in my activities because of these (3) audio logs...                  |
|____________________________________________________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Date/Time     | # | Info            | Hyperlink                                                            |
|_______________|___|_________________|______________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 05/19/20 1400 | 1 | Live Redaction  | https://drive.google.com/file/d/186dv0z0YLfafQT_tlJYYy9AhorERuSPw    |
| 05/20/20 1655 | 2 | Audio Log       | https://drive.google.com/file/d/13aIAjzp37cdiOmCljgsCFwdyfOLVcYi_    |
| 05/21/20 1044 | 3 | Audio Log       | https://drive.google.com/file/d/1-gbfcvZROeF0T-Z0-FWCzWBBLGdJPc6z    |
| 05/21/20 2358 | 4 | Bird 1 Original | https://drive.google.com/file/d/1kl_zBSSEqGKk3ri3WKuiF9ISVZoyxErx    |
| 05/21/20 2358 | 5 | Bird 1 Treble   | https://drive.google.com/file/d/13NPoJyRENfdy7_kwMVCjfrJccoU3MxUU    |
|_______________|___|_________________|______________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-028501 [05/26/20]                                                                    ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-028501"
$List.AddRecord($Name,"05/26/20 01:28:57","05/26/20 01:31:14")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("S4192JW Joshua Welch","SL4197"),
("S41925JK Jeffrey Kaplan","SL4138"),
("S43460SS Scott Schelling","SL4184") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-028501 (1).JPG","https://drive.google.com/file/d/1adfRlVCkUn5H-eauU8pNtPogGlnsVwbP"),
("SCSO-2020-028501 (2).JPG","https://drive.google.com/file/d/1fxb8zTS2v19W5_iIjA3jaGxEaYpFROdO"),
("SCSO-2020-028501 (3).JPG","https://drive.google.com/file/d/1R14NXV0ziULhhv3tCfzxBuH-TDYv0iWy"),
("SCSO-2020-028501 (4).JPG","https://drive.google.com/file/d/1XvlYs2OHS0j6jbV5kYqhyYPb5JomMGH-"),
("SCSO-2020-028501 (5).JPG","https://drive.google.com/file/d/1ghOYtzKZxUYnY4qQp1ZexcQtT2KxZZDk"),
("SCSO-2020-028501 (6).JPG","https://drive.google.com/file/d/1ukn4TLWoXdH-hFeDBOqyMujxxOXyZf2M") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
From the very moment that I went to STRATTON AIR NATIONAL GUARD...
...to the very moment that SCSO SCOTT SCHELLING ARRIVED ON SCENE...?

I like, used basically the SAME DEVICE that I tried to hand him... 
...in front of the Zappone dealership...
...at 1780 US-9... 
...after I was nearly killed...
...to record nearly 100% of the following exhibits.

Same device.
There's like (2) exhibits below that I didn't use THAT device, to create these exhibits.

That DEVICE, is called "an Apple iPhone 8 Plus"
It's WHITE, it's like, a fuckin' 8th generation of an Apple iPhone...?
When it's not REMOTELY DISABLED by the GOVERNMENT, it can do some REALLY COOL SHIT, dude...

It can:
1) record audio recordings,
2) take pictures, 
3) record videos,
4) record telemetry locations into each particular HEIC file,
5) be subjected to ESPIONAGE by a DOMESTIC ENEMY,
6) be subjected to ESPIONAGE by a FOREIGN ENEMY, 
7) be subjected to ESPIONAGE by a CORPORATION,
8) be subjected to ESPIONAGE by a MONOPOLY,
9) allow certain people to commit INSIDER TRADING,
10) allow SERIAL KILLERS to track a SPECIFIC TARGET for EXECUTION,
11) allow people to access their ONLINE BANKING,
12) allow people to make these things called "PHONE CALLS", 
13) allow people to combine all of this shit into a NARRATIVE,
14) record video of a couple of guys using PHANTOM/PEGASUS to try and MURDER somebody,
15) allow a malicious entity to DISABLE A PARTICULAR DEVICE BECAUSE OF A PARTICULAR VIDEO I RECORDED AT 05/26/20 2343,
16) it can even ACCESS THE INTERNET,
17) upload various files recorded with the device to the INTERNET,
18) allow a remote party to basically provide an UPLINK without paying to activate the service on the device,
19) allow people to write these things called NOTES,
20) allow guys to take a quick picture of their DICK so they can send it to a GIRL they wanna have sex with,

I gotta tell ya, these fuckin' things, they do A LOT.
They can also be used as a WEAPON.

Unfortunately...?
I keep running into incredibly ignorant people that have these things called BADGES, or like, DOCTORATES,
or MASTERS DEGREES, or even like, a fuckin' GAVEL... They don't get it.

I do.
They think I'm just blowing off steam, trying to be mad cool, or whatever.
There's really NOTHING COOL about the CIRCUMSTANCES I'VE BEEN IN, SINCE THIS PARTICULAR EVENT.
Nah.

I'm just a lot more intelligent than people FEEL like giving me credit for...?
And that's just the end of the conversation.
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Date/Time     | ### | Name            | / | % | Url (#: Index, /: Type, %: Clarity/Censorship)                    |
|_______________|_____|_________________|___|___|___________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 05/23/20 0132 | 000 | IMG_0394        | P | 0 | https://drive.google.com/file/d/1fZRCFjw2bw6BGoWcmyaYvLkMAOLsJVb_ |
| 05/23/20 0133 | 001 | IMG_0395        | V | 0 | https://youtu.be/3twiZEsyQf0                                      |
| 05/23/20 0141 | 002 | IMG_0396        | P | 0 | https://drive.google.com/file/d/1oHaFO_1ZSw8Gwx62Yyfla2yw6DB-VF4j |
| 05/23/20 0150 | 003 | Item[2]-Orig..  | A | 0 | https://drive.google.com/file/d/1QS6HETkJu-9nbnm84auzjOc8j8vAwSHG |
| 05/23/20 0150 | 004 | Item[2]-Treble  | A | 0 | https://drive.google.com/file/d/1J6b5AiIt8p5vswuzLflpzslK4N3DFrC7 |
| 05/23/20 0203 | 005 | IMG_0397        | V | 0 | https://youtu.be/V-_YqedKZb8                                      |
| 05/23/20 0214 | 006 | IMG_0398        | P | 0 | https://drive.google.com/file/d/1gFH2Y5CZSWeTdqMkUD7S7TqZhgCoygtm |
| 05/23/20 0326 | 007 | IMG_0399        | P | 0 | https://drive.google.com/file/d/1jhrDsc_iyILUxs_zkqzJFhUOuQcNPvjz |
| 05/23/20 0326 | 008 | IMG_0400        | P | 0 | https://drive.google.com/file/d/16Cd437RbCWho7nITf6uxRMRH5KvXPUng |
| 05/23/20 0326 | 009 | IMG_0401        | P | 0 | https://drive.google.com/file/d/1lvON1Gqu-RFFbGQr6LcF13teNOBUC_mu |
| 05/23/20 1715 | 010 | IMG_0402        | P | 0 | https://drive.google.com/file/d/1zm1jZDyCq_TLmyllwu_S4r8hNcIqS0M4 |
| 05/23/20 1200 | 011 | Virtual Tour    | V | 0 | https://youtu.be/HT4p28bRhqc                                      |
| 05/23/20 1717 | 012 | IMG_0403        | V | 0 | https://youtu.be/5guDmpaCyAM                                      |
| 05/23/20 1734 | 013 | IMG_0404        | V | 0 | https://youtu.be/16dOquXbOrk                                      |
| 05/23/20 1747 | 014 | IMG_0404        | V | 0 | https://youtu.be/g0ACtMIPrRo                                      |
| 05/23/20 1755 | 015 | IMG_0404        | V | 0 | https://youtu.be/3rWdDtYC1Ac                                      |
| 05/23/20 1808 | 016 | IMG_0407        | P | 0 | https://drive.google.com/file/d/1XdS2qBXYoEML4EbuZK_BDQkSU2VLlei_ |
| 05/23/20 1808 | 017 | IMG_0408        | P | 0 | https://drive.google.com/file/d/1T4ReQ5dfr5SQ3r6XGnE3al3eDF99plc5 | 
| 05/23/20 1808 | 018 | IMG_0409        | V | 0 | https://drive.google.com/file/d/1iZWZyXNJROfHaYCboY1CreK0VrWTMwsQ |
| 05/23/20 2015 | 019 | IMG_0410        | P | 0 | https://drive.google.com/file/d/17A8VrKhf6FoijaCqYz3ElKh7KXCtmAIe |
| 05/23/20 2015 | 020 | IMG_0411        | P | 0 | https://drive.google.com/file/d/1gYQRrg1bl7M2OyxcS4N65ttcF2L-x1PY |
| 05/23/20 2022 | 021 | IMG_0412        | V | 0 | https://drive.google.com/file/d/1Exs2UsfQ13CKS4BE2CZU8kvMNpqH0tld |
| 05/23/20 2040 | 022 | IMG_0413        | V | 0 | https://youtu.be/OZD6rBbDboA                                      |
| 05/23/20 2109 | 023 | IMG_0414        | P | 1 | https://drive.google.com/file/d/1c7Ffv6EO0Jw9d1Jv-zYWNMmnoVrdI2-C |
| 05/23/20 2115 | 024 | IMG_0415        | P | 2 | https://drive.google.com/file/d/13W3kV7PQtq8QfoENrHeWIomwIdyNvFFc |
| 05/23/20 2118 | 025 | IMG_0416        | V | 0 | https://drive.google.com/file/d/1jJh0rG2KUtEhvqw-0FEoZ6lBXsnkyjBO |
| 05/23/20 2209 | 026 | IMG_0418        | P | 0 | https://drive.google.com/file/d/1o0EN-_zJ2NFMpIJ62TEXt_ZzhTpIcP-J |
| 05/23/20 2227 | 027 | IMG_0419        | P | 1 | https://drive.google.com/file/d/1ylXx3-_yqXO1aZgxs591WCkw97aGNXoJ |
| 05/23/20 2227 | 028 | IMG_0420        | P | 1 | https://drive.google.com/file/d/1aotzEtVIzOWZpHNGBGAiKMu4ptd83RUV |
| 05/23/20 2234 | 029 | IMG_0421        | P | 1 | https://drive.google.com/file/d/10EMq8WVC0i1JeBunE1kL6-gKe7wEB2Ah |
| 05/23/20 2246 | 030 | IMG_0422        | P | 1 | https://drive.google.com/file/d/1soT3MzZ0kZa_wmIj-EhXtiKL5zuAZ-hr |
| 05/23/20 2246 | 031 | IMG_0423        | P | 0 | https://drive.google.com/file/d/1k_X9QtxzjRZGVPVUHaA-gZLoPST5Bdmc |
| 05/23/20 2246 | 032 | IMG_0424        | P | 3 | https://drive.google.com/file/d/1GBjx1ErbzNXOxJo0Uqa8TZ1YnJbhZJVe |
| 05/23/20 2247 | 033 | IMG_0425        | P | 0 | https://drive.google.com/file/d/1o4a0TPY-FMDgRisNjd20VWvHv2sPVBVP |
| 05/23/20 2303 | 034 | IMG_0426        | P | 1 | https://drive.google.com/file/d/1JHKgCHT7kgT3cLiAJw1qbk2auIT5EZIt |
| 05/23/20 2304 | 035 | IMG_0427        | P | 1 | https://drive.google.com/file/d/1WFAOMoUl8H0e22r4Q2vo0hEc0JgxGBoz |
| 05/23/20 2314 | 036 | IMG_0428        | V | 0 | https://drive.google.com/file/d/1uyWjou_6Yadc-RKI3kIqvV7PtIJZekk5 | 
| 05/23/29 2314 | 037 | IMG_0429        | P | 2 | https://drive.google.com/file/d/1YlOSkwqNxHNOKHo-JKqKiCp-iaPYetqt |
| 05/23/20 2316 | 038 | IMG_0430 (1/2)  | V | 1 | https://youtu.be/7ZjLXsW-USc                                      |
| 05/23/20 2316 | 039 | IMG_0430 (2/2)  | V | 1 | https://drive.google.com/file/d/1kuaybwEfIUYTd06wf76WRHIBZtdtphBV |
| 05/23/20 2320 | 040 | IMG_0431        | P | 2 | https://drive.google.com/file/d/1yfQd_p5XBCLVtt9Uoryac49BPopGvu3O |
| 05/23/20 2323 | 041 | IMG_0432        | V | 0 | https://drive.google.com/file/d/1K16SXHJhaFeive21taFWquLioLSEjc6i |
| 05/23/20 2325 | 042 | IMG_0433        | P | 0 | https://drive.google.com/file/d/1eU83YqoKOlgpqcPImmey3DuIljwaZmGi |
| 05/23/20 2325 | 043 | IMG_0434        | P | 0 | https://drive.google.com/file/d/1rNCcFKCxH2QVdaW3moQbtYYFTCFGVzpd |
| 05/23/20 2328 | 044 | IMG_0435        | P | 0 | https://drive.google.com/file/d/17qBZGnwK3TEQUNHlExOzBnSA9Me_Atqf |
| 05/23/20 2329 | 045 | IMG_0436        | P | 0 | https://drive.google.com/file/d/17DDVj9j29oa0HMMEc_DXZv1kYNu2wfzy |
| 05/23/20 2332 | 046 | IMG_0437        | P | 0 | https://drive.google.com/file/d/1f_bCTTUwcncWfVWFI4GgeoDAkmVwx-eX |
| 05/23/20 2332 | 047 | IMG_0438        | P | 0 | https://drive.google.com/file/d/1IIr21Z94r9YNMhciVKr47jlwqrXETPk8 |
| 05/23/20 2333 | 048 | IMG_0439        | P | 0 | https://drive.google.com/file/d/19SeWplJxmZ8X0t1lkKxIqTHzXAeOBTem |
| 05/23/20 2339 | 049 | IMG_0440        | P | 0 | https://drive.google.com/file/d/1OXsTi4B0fwproUMHJYEnGGav0toGGyAY |
| 05/23/20 2339 | 050 | IMG_0441        | P | 0 | https://drive.google.com/file/d/1mfVdLqrSMN1bpCyFtK4Iu9wPnBAEmVYs |
| 05/23/20 2339 | 051 | IMG_0442        | P | 0 | https://drive.google.com/file/d/1rmRrmNMu0-FJuuP1Xc0K6aCMYop5N5Vq | 
| 05/23/20 2357 | 052 | IMG_0443        | P | 0 | https://drive.google.com/file/d/1d4U_CbDqZCQYDaFKsVDhnah2sk7GTVET |
| 05/23/20 2357 | 053 | IMG_0444        | P | 0 | https://drive.google.com/file/d/18yhgrBqZMNpmtrwU1xs9g-FosXJcbUa1 |
| 05/23/20 2357 | 054 | IMG_0445        | P | 2 | https://drive.google.com/file/d/1mLIfSI1htx_jts6gOomS5aos70nmqbcF |
| 05/23/20 2357 | 055 | IMG_0446        | P | 0 | https://drive.google.com/file/d/1hZqArWA8Juvw1WySSD1J5gfx9xGALq9Z |
| 05/23/20 2359 | 056 | IMG_0447        | P | 0 | https://drive.google.com/file/d/1R-6g3k3ZIaIM6pvoJPFmCDdKy6N2cpAD |
| 05/23/20 2359 | 057 | IMG_0448        | P | 0 | https://drive.google.com/file/d/1ob_d2qtZi5hyo7ROD3CuAh7ehejFKsy3 |
| 05/23/20 2359 | 058 | IMG_0449        | P | 0 | https://drive.google.com/file/d/1CzPZ5M59yWuwguyYVVu921CHFDHA1c3y |
| 05/23/20 2359 | 059 | IMG_0453        | P | 3 | https://drive.google.com/file/d/1W6gJhjCKDtbuq9lTnQPzJZereAnga3zT |
| 05/24/20 0000 | 060 | IMG_0455        | P | 1 | https://drive.google.com/file/d/1Tu5ft89sJ_tR6RayQ79bSOk7F_QxsbOK |
| 05/24/20 0001 | 061 | IMG_0456        | P | 0 | https://drive.google.com/file/d/12VV2ObukK_3DXED23Nsi1GxMbzkm9aLN |
| 05/24/20 0002 | 062 | IMG_0457        | P | 0 | https://drive.google.com/file/d/1EabOp3qnFkaRR_GYmStsJUkbugud1zom |
| 05/24/20 0003 | 063 | IMG_0458        | P | 0 | https://drive.google.com/file/d/115TRiUsJS55zya6qyVv1ZaQZ3lVUpGkh |
| 05/24/20 0003 | 064 | IMG_0459        | P | 0 | https://drive.google.com/file/d/1kWVkx2wsxyQOxihEI-oHTwVEQbKFcVnW |
| 05/24/20 0004 | 065 | IMG_0460        | P | 1 | https://drive.google.com/file/d/1d0sTQLvJSuobxgKw5j4FVVDnhBqxXdzo |
| 05/24/20 0005 | 066 | IMG_0461        | P | 0 | https://drive.google.com/file/d/14LiGWkW4hTZvk6JfkfFyPZyIhxGEBK-_ |
| 05/24/20 1341 | 067 | 2020 05 24 1341 | V | 0 | https://youtu.be/i88AJb_5zY4                                      |
| 05/24/20 1759 | 068 | IMG_0468        | P | 0 | https://drive.google.com/file/d/1fNYPWpuJgyVfLsZd3Ha_0GfaPGWimvYc | 
| 05/24/20 1800 | 069 | IMG_0469        | P | 0 | https://drive.google.com/file/d/1vgeZIIVmzBiJIOzXWfrb45qnmV_WQAwI |
| 05/24/20 1801 | 070 | IMG_0470        | P | 0 | https://drive.google.com/file/d/1R7VNKSRzuKM-tIJwzdo7td2h6ev74j0K |
| 05/24/20 1801 | 071 | IMG_0471        | P | 0 | https://drive.google.com/file/d/1KLSxinDnryuHw9sgwLJtPa87A0BW2Se5 |
| 05/24/20 1802 | 072 | IMG_0472        | P | 0 | https://drive.google.com/file/d/1yjmMBTRHoC5wSRMWWrDDmGbGgkkyUx7A |
| 05/24/20 1803 | 073 | IMG_0473        | P | 0 | https://drive.google.com/file/d/1Dwrvg_lk-uYfLVRALKGiLo756SMgwWE- |
| 05/24/20 1810 | 074 | IMG_0477        | P | 0 | https://drive.google.com/file/d/1ex0klAW_MeYpdd5Q1trtVcLJFp2tlTUx |
| 05/24/20 1849 | 075 | IMG_0493        | P | 0 | https://drive.google.com/file/d/1r_LYeBOis15QpVtW5WQFEB7IRoMjPgGr |
| 05/24/20 1850 | 076 | IMG_0495        | P | 0 | https://drive.google.com/file/d/1AZcx41RWlG7nDg9EcEfYxpasPiUny3eL |
| 05/24/20 1853 | 077 | IMG_0496        | P | 0 | https://drive.google.com/file/d/1bi8tB-eidAFVxbhdVpvyI-9OESmPhk0o |
| 05/24/20 1854 | 078 | IMG_0497        | P | 0 | https://drive.google.com/file/d/1cUV8oy8TIciNC4mLYnAKsjHVd8KtHly_ |
| 05/24/20 1854 | 079 | IMG_0498        | P | 0 | https://drive.google.com/file/d/1paLMRKq5YmDHt2ClWUgzXeEtpbJWpFEm |
| 05/24/20 1904 | 080 | IMG_0499        | P | 0 | https://drive.google.com/file/d/13cG66dGN3M9kcdBex4yo7Nca5-tPFgLH |
| 05/24/20 1904 | 081 | IMG_0500        | P | 0 | https://drive.google.com/file/d/1f6NM20A3PfRtb54wOQrU3Vq5wM_LGz14 |
| 05/24/20 1907 | 082 | IMG_0501        | P | 0 | https://drive.google.com/file/d/1QIhQQa_Zq-lrR5qdtlfxJqkj9j9TErYy |
| 05/24/20 1907 | 083 | IMG_0502        | P | 0 | https://drive.google.com/file/d/1W8A-OEX3fJn6J253TPhvd_Ps8A5w_pIT |
| 05/24/20 1907 | 084 | IMG_0503        | P | 0 | https://drive.google.com/file/d/1yDZ4O_YK8UXc-prEGVNE_4o4pWweG6_z |
| 05/24/20 1907 | 085 | IMG_0504        | P | 0 | https://drive.google.com/file/d/1Ds8pxZOpGYbkxmyAPxAw7aA-N1ngw3pe |
| 05/24/20 1910 | 086 | IMG_0505        | P | 0 | https://drive.google.com/file/d/1agONCE8WPnlM_MLc9hEEinygOxHdPdKJ |
| 05/24/20 1910 | 087 | IMG_0506        | P | 0 | https://drive.google.com/file/d/1tazuzEVemWTZTRJmjyF-_s_-w_Afj4SU |
| 05/24/20 1925 | 088 | IMG_0508        | P | 0 | https://drive.google.com/file/d/1CywfAKtQQy7wm_6kBE442dk8wlN0GcCF |
| 05/24/20 1952 | 089 | IMG_0512        | P | 0 | https://drive.google.com/file/d/1ow1cCPgUDENOvW16afXsxXzkQyJTZOQr |
| 05/24/20 1952 | 090 | IMG_0513        | P | 0 | https://drive.google.com/file/d/1M73qUy8w7HXqL0cdIGl7_WLdDJPmOHiS |
| 05/24/20 2049 | 091 | IMG_0525        | P | 0 | https://drive.google.com/file/d/1Ymm3YpKgYlSMs58B6z-2HeqYmQXYIVgt |
| 05/24/20 2049 | 092 | IMG_0537        | P | 1 | https://drive.google.com/file/d/1_cWYuUbVfw-7TYH6sQAwfv_rpP5Mp1QY |
| 05/24/20 2050 | 093 | IMG_0538        | P | 2 | https://drive.google.com/file/d/1E9hqXeb8RbyJKYgI94KtiGB79_fY5_03 |
| 05/24/20 2050 | 094 | IMG_0539        | P | 1 | https://drive.google.com/file/d/1rmjA0c5duSUDkk5K8CNc7Wt3GQr7u4hG |
| 05/24/20 2050 | 095 | IMG_0540        | P | 0 | https://drive.google.com/file/d/1sxauHH3gInbUg2s-gueRANRhHtVih6WD |
| 05/24/20 2052 | 096 | IMG_0541        | P | 0 | https://drive.google.com/file/d/1J6hPh8i_8ko7A0Eqb8m8u8rb15gzveCj |
| 05/24/20 2052 | 097 | IMG_0542        | P | 1 | https://drive.google.com/file/d/1gxtf0rjhwnwyHVUnEmi3Xgg7ACkRGFEP |
| 05/24/20 2055 | 098 | IMG_0543        | P | 1 | https://drive.google.com/file/d/10mahQTnFZ4Yq3gysEVGjrajuELEXiSXu |
| 05/24/20 2055 | 099 | IMG_0544        | P | 1 | https://drive.google.com/file/d/1t8g1PuC2TZ0dJv2-cjWal9sHfgR1ut5f |
| 05/24/20 2149 | 100 | IMG_0546        | P | 0 | https://drive.google.com/file/d/1Kzn8IPwaaP1aHUL2yv4BmsMStyNWLpNX |
| 05/24/20 2159 | 101 | IMG_0549        | P | 3 | https://drive.google.com/file/d/1VvOtkA8bT2Un20kWQA5xbp5P7F1n1i9E |
| 05/24/20 2159 | 102 | IMG_0550        | P | 0 | https://drive.google.com/file/d/1MlrZx1HlqygJV2oh9VPz7n-OR7DBpl1H |
| 05/24/20 2159 | 103 | IMG_0551        | P | 0 | https://drive.google.com/file/d/1v-AYHZAaUn2wKboy_ShX5wBIfpTZc4fL | 
| 05/24/20 2159 | 104 | IMG_0552        | P | 3 | https://drive.google.com/file/d/1zNC_LckOws3yXsJThY4ZrdW1o1jgBmJX |
| 05/24/20 2159 | 105 | IMG_0553        | P | 3 | https://drive.google.com/file/d/1OYLrWTKvkISFaCMENCpXh7TBqQ5HqTae |
| 05/24/20 2159 | 106 | IMG_0554        | P | 1 | https://drive.google.com/file/d/1WJ-7AfxRYOhhJ96ebnl5jwVXjpCX5pWg |
| 05/24/20 2200 | 107 | IMG_0555        | P | 0 | https://drive.google.com/file/d/127CAZ15c51ei5MSegvnPM0HuUSABFfNq |
| 05/24/20 2200 | 108 | IMG_0556        | P | 0 | https://drive.google.com/file/d/1ivlJB0sh9Yh0YMn9GgV_-XWTg-2dJNel |
| 05/24/20 2200 | 109 | IMG_0557        | P | 1 | https://drive.google.com/file/d/1iEbmL6pUM6qKvEIIVERJX0MFwsLOpozi |
| 05/24/20 2200 | 110 | IMG_0558        | P | 0 | https://drive.google.com/file/d/1_lTBCXldsNe4kN92mlvTveSpIOlqQqo_ |
| 05/24/20 2200 | 111 | IMG_0560        | P | 1 | https://drive.google.com/file/d/1GIyTQ8xyWUSZfzfuFl5Y7NgfR7TgQdno |
| 05/24/20 2200 | 112 | IMG_0564        | P | 3 | https://drive.google.com/file/d/1ZoOpMLbj19tsPDj3RwVRsdtkaWT_WomD |
| 05/24/20 2201 | 113 | IMG_0565        | P | 1 | https://drive.google.com/file/d/1gx9F_QPd2uzU5UPqCYife46AHgyAYDHV |
| 05/24/20 2201 | 114 | IMG_0566        | P | 0 | https://drive.google.com/file/d/1zFvWcgV3ojqsohWjDiQBdj0myvw6JDpQ |
| 05/24/20 2201 | 115 | IMG_0567        | P | 0 | https://drive.google.com/file/d/1qjj5mCE_bG9PLauJNJTAPfVPmigUcKb3 |
| 05/24/20 2239 | 116 | IMG_0585        | P | 0 | https://drive.google.com/file/d/1y4f8SmcgZf_vJ8ohXVSFFWQlC19QEDZe |
| 05/24/20 2242 | 117 | IMG_0590        | P | 0 | https://drive.google.com/file/d/1_QUY6XrDIBIJJvjaYw02B-1OdEOXm5zk |
| 05/24/20 2243 | 118 | IMG_0591        | P | 3 | https://drive.google.com/file/d/1BrGQnWB2xPNudtUdItlJm29PqQMVltGh |
| 05/24/20 2248 | 119 | IMG_0594        | P | 1 | https://drive.google.com/file/d/10r3SnCMggf2BRmlST4fdX5f104mwNxau |
| 05/24/20 2249 | 120 | IMG_0595        | P | 1 | https://drive.google.com/file/d/1BnoTT0-IHk0TNvIDIYPj_H4q6fk4EkF7 |
| 05/24/20 2249 | 121 | IMG_0596        | P | 1 | https://drive.google.com/file/d/1aZFTnKVwQXakRMHbCt9WIpKxpJUV2Q8G |
| 05/24/20 2249 | 122 | IMG_0597        | P | 0 | https://drive.google.com/file/d/11GDlXvkiMVnt4iu8zqhzphbEjogAkvqY |
| 05/24/20 2249 | 123 | IMG_0598        | P | 0 | https://drive.google.com/file/d/1eaT4t3viNY_j02BMbV_TxJJ-e2zCPtjq |
| 05/24/20 2250 | 124 | IMG_0599        | P | 0 | https://drive.google.com/file/d/1VqlgtK2ER65_28Bpr7dJboIg8nzNOzMY |
| 05/24/20 2250 | 125 | IMG_0600        | P | 1 | https://drive.google.com/file/d/1fElcWAHc6GdZVw6XsDfJZSMeM6f0e6EN |
| 05/24/20 2250 | 126 | IMG_0601        | P | 1 | https://drive.google.com/file/d/15ZtekTtGuKWTrJ2brozUabQhlcURu7Xe |
| 05/24/20 2250 | 127 | IMG_0602        | P | 0 | https://drive.google.com/file/d/13KQTzbTLQ7NNzS7OZ4Zmx63pgU9gF7au |
| 05/24/20 2250 | 128 | IMG_0603        | P | 0 | https://drive.google.com/file/d/1HPdGPltH9_Nyr9GtFqYKn509z6i5ZoGF |
| 05/24/20 2251 | 129 | IMG_0604        | P | 0 | https://drive.google.com/file/d/1p_tdU-9lQ391UxsNfixLg71F_M3aGchz |
| 05/24/20 2251 | 130 | IMG_0605        | P | 0 | https://drive.google.com/file/d/18DeG9RcavSV42907L1kcHuTgnfC59LfG |
| 05/24/20 2251 | 131 | IMG_0606        | P | 1 | https://drive.google.com/file/d/1U0A_lsgspUeU7AJQ9m-KebOPdkKHJsRS |
| 05/24/20 2253 | 132 | IMG_0607        | P | 1 | https://drive.google.com/file/d/1jNHmvr66KZMoX0JiT3Cbs43Buu6zADIE |
| 05/24/20 2255 | 133 | IMG_0608        | P | 1 | https://drive.google.com/file/d/1hv3JhYKD--0BQg-x66sO0fomgAy3kFFi |
| 05/24/20 2255 | 134 | IMG_0609        | P | 1 | https://drive.google.com/file/d/1shrLewHORf86sf4TIp3ykAe6WosZ4Q2J |
| 05/24/20 2256 | 135 | IMG_0611        | P | 1 | https://drive.google.com/file/d/1UfA4j-wAO1VfehUwUUJWOGJc6N9SCMFl |
| 05/24/20 2256 | 136 | IMG_0612        | P | 0 | https://drive.google.com/file/d/1qhhH-kHGxCqUuR-8BLWjBzONOWvoEoMB |
| 05/24/20 2256 | 137 | IMG_0613        | P | 1 | https://drive.google.com/file/d/1RzZixkCkQrD4raxRBDmehTLwTzgRLoee |
| 05/24/20 2256 | 138 | IMG_0614        | P | 0 | https://drive.google.com/file/d/154R8Vpi-v72jyEG7Roh8hE_Ds5jLiqCm |
| 05/24/20 2256 | 139 | IMG_0615        | P | 0 | https://drive.google.com/file/d/1d4LjeUQ-XqsiQMayFxdfq6ecC1wGWgH9 |
| 05/24/20 2256 | 140 | IMG_0616        | P | 1 | https://drive.google.com/file/d/1M83c0dFf6HxY8YgOc68O8ydE_pLrvU7i |
| 05/24/20 2257 | 141 | IMG_0617        | P | 0 | https://drive.google.com/file/d/1lk98_0EvCmYMaew4KY2f50iE6gfJRM92 |
| 05/24/20 2257 | 142 | IMG_0618        | P | 1 | https://drive.google.com/file/d/1vHsJwwj-9E135C2jR1v5Elo6I65tnNCG |
| 05/24/20 2257 | 143 | IMG_0619        | P | 0 | https://drive.google.com/file/d/1mtARlTxYGR7_UvkTBoz31Alfh6EyR9dO |
| 05/24/20 2257 | 144 | IMG_0620        | P | 0 | https://drive.google.com/file/d/1iun2RJ-pToqMlUUQMdKl_yWvJWxKioON |
| 05/24/20 2310 | 145 | IMG_0621        | P | 1 | https://drive.google.com/file/d/19qa9qfALiWRJQwTHwvMhmyZldxBmuEZT |
| 05/24/20 2310 | 146 | Solar Drive     | V | 0 | https://youtu.be/ZgVTHK172O8                                      |
| 05/25/20 1016 | 147 | IMG_0622        | P | 0 | https://drive.google.com/file/d/1BIO3h4RZxxokfhJmq3BOfgmj4gE6TQ5q |
| 05/25/20 1016 | 148 | IMG_0623        | P | 0 | https://drive.google.com/file/d/1bpicQ6EP9ndq0DIdIy9mAAhk1X3A1GHq |
| 05/25/20 1016 | 149 | IMG_0624        | P | 0 | https://drive.google.com/file/d/1cjJLLS8j0Zkwzvy716gCIdx1VW5TU23G |
| 05/25/20 1028 | 150 | IMG_0625        | V | 0 | https://drive.google.com/file/d/1SDTqxE12WiYfD3WhgYHzXXlVJ2h9aU-D |
| 05/25/20 1054 | 151 | IMG_0627        | V | 0 | https://drive.google.com/file/d/1zhiwa9hvh5Lg58gHTjDT9TpM0k6NRZVx |
| 05/25/20 2135 | 152 | Capital Digi.   | A | 0 | https://drive.google.com/file/d/1Hq-CkA-K3aN5i6uYs6Tle_sLCX5SLHQY |
| 05/25/20 2205 | 153 | IMG_0629        | P | 0 | https://drive.google.com/file/d/15oD2mMphIvsUCO9hDNUh8EJvQfmWUu5_ |
| 05/25/20 2205 | 154 | IMG_0630        | P | 0 | https://drive.google.com/file/d/1lIx0RI0ew189GcY5YYYqKPfhNDSkn69g |
| 05/25/20 2205 | 155 | IMG_0631        | P | 0 | https://drive.google.com/file/d/1BLC2V1WRTRSzJYZWuX7eBFXz37K4CHEP |
| 05/25/20 2213 | 156 | IMG_0633        | P | 0 | https://drive.google.com/file/d/1mX-iOHH0mew1_iwm7nn3b4ROm4lboreM |
| 05/25/20 2230 | 157 | Matchless Stove | A | 0 | https://drive.google.com/file/d/14bAzf7pzM_t67Exxm1NoqgHUnYV86pX7 |
| 05/25/20 2246 | 158 | IMG_0634        | P | 0 | https://drive.google.com/file/d/1OloZklvgG_mbAz9Qc4eNKTrWSTqWwfT0 |
| 05/25/20 2300 | 159 | Computer Ans.   | A | 0 | https://drive.google.com/file/d/1dmTkiCzgyGwG9q5BO9hIn_SSeFWPcrIs |
| 05/25/20 2329 | 160 | IMG_0636        | P | 0 | https://drive.google.com/file/d/1a-lb9MOUKi1wy9c4cEEyuclH_rQIMhNo |
| 05/25/20 2329 | 161 | IMG_0637        | P | 0 | https://drive.google.com/file/d/1ZNmufDVX7Xkyf4pHqQfPk2Ww2tvkwGCL |
| 05/25/20 2329 | 162 | IMG_0638        | P | 0 | https://drive.google.com/file/d/1uIxufETfzgpM1uLp9mclF4quMkWak4LY |
| 05/25/20 2329 | 163 | IMG_0639        | P | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP |
| 05/25/20 2335 | 164 | IMG_0640        | P | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP |
| 05/25/20 2336 | 165 | IMG_0641        | P | 0 | https://drive.google.com/file/d/1g-tOe4lBQcKaip8ZaHGg7lQmOF7ufSDS |
| 05/25/20 2337 | 166 | IMG_0642        | P | 0 | https://drive.google.com/file/d/1e_KKi6oMfJcqQSLtXCIwES9jKShaK8Vf |
| 05/25/20 2337 | 167 | IMG_0643        | P | 0 | https://drive.google.com/file/d/1GYlnixSrS-_C4BY04zx__I4LznrIFJjU |
| 05/25/20 2337 | 168 | IMG_0644        | P | 0 | https://drive.google.com/file/d/1je8w77DYiUosmS5G3L-4ORgGG1ve7ahI |
| 05/25/20 2337 | 169 | IMG_0645        | P | 0 | https://drive.google.com/file/d/1TIuFj7RcyWtADqpSYavDpP9UcdlyHNvA |
| 05/25/20 2343 | 170 | IMG_0646        | P | 0 | https://drive.google.com/file/d/1Lb8RLYUsJnnKnTOHbunlyBmidIXycjVD |
| 05/25/20 2343 | 171 | IMG_0647        | Q | 0 | (OBSTRUCTION OF JUSTICE -> 05/26/20 0005 (MISSING VIDEO)          |
| 05/26/20 0005 | 172 | IMG_0648        | P | 0 | https://drive.google.com/file/d/18xllhtJW6XZhxJOZXWtesywn-Ph37KK9 |
| 05/26/20 0011 | 173 | IMG_0649        | P | 1 | https://drive.google.com/file/d/1W0234ojNChSpwDZWnWPzjjZRBQ2CQm0L |
| 05/26/20 0011 | 174 | IMG_0650        | P | 1 | https://drive.google.com/file/d/1vu2bhSSCv2HO-HCeCCh5-iqcYpiiqC2l |
| 05/26/20 0011 | 175 | IMG_0651        | P | 1 | https://drive.google.com/file/d/1imYzaTA--eVDMeSM-dHfYBfC2tiAHsLV |
| 05/26/20 0348 | 176 | IMG_0652        | P | 0 | https://drive.google.com/file/d/1w0Q6lhLYH9ACwQfUosucUE9x5-uAsNzI |
|_______________|_____|_________________|___|___|___________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
The narrative goes like this, SCOTT SCHELLING arrived on scene FIRST, though in the RECORDS, it says JOSHUA WELCH
arrived FIRST. However- THAT IS TOTAL BULLSHIT. SCOTT SCHELLING was the FIRST GUY ON SCENE, and I literally tried
to show him INDEX 171, as well as INDEX 176.

SCOTT SCHELLING SOMEHOW KNEW ABOUT THE AUDIO RECORDINGS, INDEX 152, INDEX 157, and INDEX 159...
...cause he like, ASKED ME A QUESTION THAT HE WOULD'VE ONLY KNOWN TO HAVE ASKED ME...
...if he was DISPATCHED, EN ROUTE, AND ARRIVED AT THE SCENE FIRST...
...because it was an UNDERCOVER OPERATION that his FELLOW OFFICERS HAD NO KNOWLEDGE OF.

HE LOOK VISUALLY UPSET WHEN I TOLD HIM I HAD UPLOADED THEM AT THE COMPUTER ANSWERS NETWORK.
Wanna know why...?
Uh- it's cause in the particular audio recording that I recorded, I said:
"OooOOoohHh, I'm gonna break into the network~!"

But I was already on the fucking network.
Then I uploaded it to my Google Drive account, and then the VPN somehow changed the file creation date to...
...PACFIC STANDARD TIME.

Oh wow.

I talk about this entire interaction in CHAPTER 4, THE WEEK, SECTION, HOME STRETCH.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-003173                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-003173"
$List.AddRecord($Name,"05/27/20 12:12:00","06/01/20 12:19:00")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("Michael Smith","<UNSPECIFIED>"),
("DJ Thompson","<UNSPECIFIED>"),
("James Leonard","<UNSPECIFIED>") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-003173 (1).JPG","https://drive.google.com/file/d/14Ajb2y93NEJ6YC255-lHe361KoCF7OxP"),
("SCSO-2020-003173 (2).JPG","https://drive.google.com/file/d/1KsriWjDat6F2mz9Vy8FJMUWLRF6ViYO4"),
("SCSO-2020-003173 (3).JPG","https://drive.google.com/file/d/1l_fs1BP1FmQiuoQ7rJZQAh3dvpw5o-bQ"),
("SCSO-2020-003173 (4).JPG","https://drive.google.com/file/d/1cDq5H8QpzvowOJ1C3rLbraiNCJaoscTW"),
("SCSO-2020-003173 (5).JPG","https://drive.google.com/file/d/13zr1gip9mkaJSsXRnxU8lhZiR5cNYTKj"),
("SCSO-2020-003173 (6).JPG","https://drive.google.com/file/d/17ZvRkZWwxDTHCnrhbHOL7hh_L2MCnF7t") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
So, RIGHT BEFORE SOMEONE CALLED SCSO at EXACTLY 05/26/20 01:28:57 leading to SCSO-2020-028501...?
I spent (90) minutes being CHASED BY TWO GUYS.
After I uploaded AUDIO RECORDINGS at COMPUTER ANSWERS.

I called (911) on the same fucking Apple iPhone 8 Plus that I've been talkin' about, TWICE...
...during that 90 minute encounter with NEARLY CERTAIN DEATH...
...and BOTH of those CALLS were SUBJECTED to this THING called a TELEPHONY DENIAL OF SERVICE ATTACK.
That's what PEGASUS/PHANTOM can actually do, ladies and gentlemen.

If these SERIAL KILLERS are looking to KILL YOU...?
WELL, there's a FALSE SENSE OF SECURITY in the notion that you can take your phone...
...and just, call 911.

Because what these FUCKING MORONS FROM THE SARATOGA COUNTY SHERIFFS OFFICE DON'T SEEM TO GET...
...is that IF THIS IS HAPPENING, and you go to call 911...?

YOUR FUCKING 911 CALL WON'T MAKE IT TO THEIR FUCKING DISPATCH STATION.
COOL...? Cool.
So like, at which point, MOST PEOPLE WILL BE KILLED.
ME on the other hand...? I sorta KNEW THAT IT WAS GONNA HAPPEN and I was SUSPICIOUS, 
EVER SINCE JANUARY 15th, 2019, when my NETWORK that I used to MANAGE at COMPUTER ANSWERS
was SUBJECTED to an EXTREMELY SOPHISTICATED CYBERATTACK... right...?

Somehow, the fuckin' morons over at SCSO aren't making the CORRELATION here.
So I gotta do it for em.

The REASON why I cut this fuckin' dude's PHONE LINE was because I was trying to call 911.
I had SUSPECTED that the GUYS that had DRIVEN NORTH UP ROUTE 9, AFTER THEY TRIED TO RUN ME OVER
WITH THEIR FUCKING VEHICLE FOR THE SECOND TIME... were in ZACHARY KARELS HOUSE, at 1769 Route 9.

THEN, when I cut the phone line, I thought to myself, "Let's cut the fuckin' kayak strap too."
Wouldn't you know...?

The guys at the SARATOGA COUNTY SHERIFFS OFFICE that handled this incident, SCSO-2020-003173,
they were ASSISTING in COVERING UP THE MURDER ATTEMPT AND THE SEVERAL FELONIES THAT OCCURRED TO ME.

That's pretty COOL, huh...?
Well, not so fast, tough guy.
Nah.

They had to WAIT until AFTER I SHOWED THE VIDEO I RECORDED, of those (2) guys attempting to kill me,
OUTSIDE OF THE CATRICALA FUNERAL HOME... to NEW YORK STATE TROOPER SHAEMUS LEAVEY, who is now retired.

Yeah, here's how this ticket went down...
1) SCSO-2020-028501 happened, 
2) SCSO SCOTT SCHELLING went and destroyed the surveillance footage of my 2nd 911 call at:
   CENTER FOR SECURITY
3) Wrote no notes whatsoever about the interaction nor the questions he asked me at my house
4) I wrote a post on FACEBOOK about how the MILITARY was RECORDING that interaction
5) FACEBOOK immediately BANNED ME for like, 30 fuckin' days
6) I was pretty stressed out about the whole ordeal and started walking around after the SUN CAME UP
   on 05/26/20 ~ 700AM
7) TROOPER SHAEMUS LEAVEY drove into the area behind the LAQUINTA INN hotel, and had a conversation
   with me, I tried to tell him about what happened but I wasn't sure how to EXPLAIN IT...
8) He told me to go home, get some rest/sleep, and he'd follow up with me on FRIDAY.
9) I went home, couldn't sleep, I then thought to go talk to my buddy ROGER at SUNOCO.
10) On the way there, I stopped at NYSEG because I had recorded a VIDEO of NYSEG giving the
    CELL PHONE TOWER OWNERS FREE POWER.
11) NYSEG apparently called in an incident and said that whatever happened occurred at GrayBar.
12) I was never at GrayBar, but that's what happens when morons don't validate who's calling 
    stuff into DISPATCH...
13) I went to SUNOCO and realized that ROGER doesn't work there anymore
14) I saw TURKEY VULTURES flying above Henry Pelo's land, and then walked into the woods
15) I had recorded multiple videos of TURKEY VULTURES a few days beforehand, and my friend
    KRIS WACIKOWSKI told me that they feed on CARRION
16) I looked around in the WOODS to see if there might be any FRESHLY DUG GRAVES since
    I was ADAMANTLY CERTAIN BY THIS POINT that I was ALMOST KILLED BY SERIAL KILLERS
17) I didn't find any BODIES or FRESH GRAVES, however I did find the TREE behind a 
    NEW YORK STATE TROOPER'S PROPERTY on a TRAIL, and the CARVINGS on the TREE date back
    to 1989
18) I was talking mad shit about JOHN PICKETT into my DEVICE the whole time I was walking
    in the woods where the TREE was.
19) When I came OUT of the woods onto BARN OWL DRIVE, there was a WOMAN JOGGING ALONGSIDE
    ME on the other side of the ROAD, and it looked like the SAME ONE that I saw in
    IMG_0627.mov
20) (2) NYSP Trooper Girls showed up, and then NYSP Trooper Shaemus Leavey showed up
21) Whoever worked the MORNING SHIFT in SCSO SL4184 on 05/26/20 at the time of this
    INCIDENT had a conversation with TROOPER LEAVEY
22) I told the TROOPER GIRLS that I believed that someone was using COVID as a FRONT
    to kill people, that I was looking for signs that CURTAINS hadn't MOVED, or CARS
    had POLLEN on them, or various other key signs that a house had NO ACTIVITY
23) Leavey told me to "Chill out tough guy, go home and get some sleep."
24) I woke up on 05/27/20 0900, and showed my DAUGHTER and my SON, the BEGINNING OF 
    THE VIDEO I RECORDED, IMG_0647.mov
25) My mother said at some point "Michael, a POLICE OFFICER is here, looking for you."
26) I could not get the fucking video off of my device before this interaction with
    TROOPER SHAEMUS LEAVEY because of this video: https://youtu.be/i88AJb_5zY4 
27) I went outside and talked with SHAEMUS, and wasn't sure what the hell to say.
    I told him that I thought that some of the people up the street from me had been
    killed. I think I said "80% of the people up the street have been killed."
    Then I also said that there's a place in the back of the neighborhood that's
    collecting equipment from victims houses or whatever.
28) I also showed him the video that I showed my SON and my DAUGHTER...
    IMG_0647.mov
29) LEE DAVENPORT SR. was in a WHITE VAN behind SHAEMUS LEAVEY, during our talk.
30) When SHAEMUS LEAVEY left, he made no attempt to drive up the street where I 
    pointed, which was PADDOCK TURN. I stayed outside for a few moments, and then
    SHAEMUS came driving back the same exact way, and he still did not go up the
    street, PADDOCK TURN.
31) At which point, I decided to go and talk to the people at the Feiden Appliance
    Center, and asked about their SECURITY FOOTAGE. 
32) I grabbed my LAPTOP (which died after I got home from talking to SHAEMUS and
    the (2) TROOPER GIRLS at STONECREST/WERNER ROAD the day before), and my 
    SMARTPHONE, and I'm fairly certain that at some point, my smartphone was
    DISABLED REMOTELY.
33) When I got to the FEIDEN APPLIANCE CENTER at some point BEFORE 1212...? 
    The guy told me to go to the LATHAM CIRCLE location, because that's where the
    SECURITY FOOTAGE would be.
34) JAMES LEONARD took a call from ZACHARY KAREL, where the ticket was called in
    like, (2) days late. 
35) JAMES LEONARD didn't feel like investigating a god damn thing.
36) JAMES LEONARD decided to perform the equivalent of jerking off into a kleenex, 
    and call that his job when he took ZACHARY KARELS' complaint... instead of taking
    action on the cocksuckers that tried to kill me.
37) I managed to walk all the way to Walmart near LATHAM CIRCLE at about 1:00-1:30PM,
    and never actually stopped at the FEIDEN APPLIANCE CENTER in LATHAM... because I
    continued to walk until I got to the FBI Field Office, in ALBANY.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-003177                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-003177"
$List.AddRecord($Name,"05/27/20 14:14:00","05/24/20 19:05:00")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("Scott Carpenter","<UNSPECIFIED>"),
("James Leonard","<UNSPECIFIED>") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-003177 (1).JPG","https://drive.google.com/file/d/1xritPqOI-ng04v_yp203zM_3sG2-_Jb2"),
("SCSO-2020-003177 (2).JPG","https://drive.google.com/file/d/119rBz3sGpt6lPF4qQ90nWwALZ2W1iWJ3"),
("SCSO-2020-003177 (3).JPG","https://drive.google.com/file/d/1FfcBWZZlkmf88XOtq0xBIvgK6m_3qwkP"),
("SCSO-2020-003177 (4).JPG","https://drive.google.com/file/d/1WkNbhqgvDIWZJYbCObEI-j12Mz_g2CDJ"),
("SCSO-2020-003177 (5).JPG","https://drive.google.com/file/d/1rjCU9yHzIo6gFw41aPAtAMmr42-iAG1I") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}


# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
JAMES LEONARD didn't feel like looking at ANY OF THESE PICTURES which sorta make:
______________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 1) ERIC CATRICALA  |
| 2) JAMES LEONARD   |
| 3) SCOTT SCHELLING |
| 4) MICHAEL ZURLO   |
| 5) SCOTT CARPENTER |
| 3) THIS TICKET...  |
|____________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
...ALL look pretty fuckin' stupid.
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Date/Time     | ### | Name            | / | % | Url (#: Index, /: Type, %: Clarity/Censorship)                    |
|_______________|_____|_________________|___|___|___________________________________________________________________|
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯|¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| 05/24/20 1849 | 001 | IMG_0493        | P | 0 | https://drive.google.com/file/d/1r_LYeBOis15QpVtW5WQFEB7IRoMjPgGr |
| 05/24/20 1850 | 002 | IMG_0495        | P | 0 | https://drive.google.com/file/d/1AZcx41RWlG7nDg9EcEfYxpasPiUny3eL |
| 05/24/20 1854 | 003 | IMG_0497        | P | 0 | https://drive.google.com/file/d/1cUV8oy8TIciNC4mLYnAKsjHVd8KtHly_ |
| 05/24/20 1910 | 004 | IMG_0505        | P | 0 | https://drive.google.com/file/d/1agONCE8WPnlM_MLc9hEEinygOxHdPdKJ |
| 05/24/20 1910 | 005 | IMG_0506        | P | 0 | https://drive.google.com/file/d/1tazuzEVemWTZTRJmjyF-_s_-w_Afj4SU |
| 05/24/20 1925 | 006 | IMG_0508        | P | 0 | https://drive.google.com/file/d/1CywfAKtQQy7wm_6kBE442dk8wlN0GcCF |
| 05/25/20 2135 | 007 | Capital Digi.   | A | 0 | https://drive.google.com/file/d/1Hq-CkA-K3aN5i6uYs6Tle_sLCX5SLHQY |
| 05/25/20 2205 | 008 | IMG_0629        | P | 0 | https://drive.google.com/file/d/15oD2mMphIvsUCO9hDNUh8EJvQfmWUu5_ |
| 05/25/20 2205 | 009 | IMG_0630        | P | 0 | https://drive.google.com/file/d/1lIx0RI0ew189GcY5YYYqKPfhNDSkn69g |
| 05/25/20 2205 | 010 | IMG_0631        | P | 0 | https://drive.google.com/file/d/1BLC2V1WRTRSzJYZWuX7eBFXz37K4CHEP |
| 05/25/20 2213 | 011 | IMG_0633        | P | 0 | https://drive.google.com/file/d/1mX-iOHH0mew1_iwm7nn3b4ROm4lboreM |
| 05/25/20 2230 | 012 | Matchless Stove | A | 0 | https://drive.google.com/file/d/14bAzf7pzM_t67Exxm1NoqgHUnYV86pX7 |
| 05/25/20 2246 | 013 | IMG_0634        | P | 0 | https://drive.google.com/file/d/1OloZklvgG_mbAz9Qc4eNKTrWSTqWwfT0 |
| 05/25/20 2300 | 014 | Computer Ans.   | A | 0 | https://drive.google.com/file/d/1dmTkiCzgyGwG9q5BO9hIn_SSeFWPcrIs |
| 05/25/20 2329 | 015 | IMG_0636        | P | 0 | https://drive.google.com/file/d/1a-lb9MOUKi1wy9c4cEEyuclH_rQIMhNo |
| 05/25/20 2329 | 016 | IMG_0637        | P | 0 | https://drive.google.com/file/d/1ZNmufDVX7Xkyf4pHqQfPk2Ww2tvkwGCL |
| 05/25/20 2329 | 017 | IMG_0638        | P | 0 | https://drive.google.com/file/d/1uIxufETfzgpM1uLp9mclF4quMkWak4LY |
| 05/25/20 2329 | 018 | IMG_0639        | P | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP |
| 05/25/20 2335 | 019 | IMG_0640        | P | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP |
| 05/25/20 2336 | 020 | IMG_0641        | P | 0 | https://drive.google.com/file/d/1g-tOe4lBQcKaip8ZaHGg7lQmOF7ufSDS |
| 05/25/20 2337 | 021 | IMG_0642        | P | 0 | https://drive.google.com/file/d/1e_KKi6oMfJcqQSLtXCIwES9jKShaK8Vf |
| 05/25/20 2337 | 022 | IMG_0643        | P | 0 | https://drive.google.com/file/d/1GYlnixSrS-_C4BY04zx__I4LznrIFJjU |
| 05/25/20 2337 | 023 | IMG_0644        | P | 0 | https://drive.google.com/file/d/1je8w77DYiUosmS5G3L-4ORgGG1ve7ahI |
| 05/25/20 2337 | 024 | IMG_0645        | P | 0 | https://drive.google.com/file/d/1TIuFj7RcyWtADqpSYavDpP9UcdlyHNvA |
| 05/25/20 2343 | 025 | IMG_0646        | P | 0 | https://drive.google.com/file/d/1Lb8RLYUsJnnKnTOHbunlyBmidIXycjVD |
| 05/25/20 2343 | 026 | IMG_0647        | Q | 0 | (OBSTRUCTION OF JUSTICE -> 05/26/20 0005 (MISSING VIDEO)          |
| 05/26/20 0005 | 027 | IMG_0648        | P | 0 | https://drive.google.com/file/d/18xllhtJW6XZhxJOZXWtesywn-Ph37KK9 |
| 05/26/20 0011 | 028 | IMG_0649        | P | 1 | https://drive.google.com/file/d/1W0234ojNChSpwDZWnWPzjjZRBQ2CQm0L |
| 05/26/20 0011 | 029 | IMG_0650        | P | 1 | https://drive.google.com/file/d/1vu2bhSSCv2HO-HCeCCh5-iqcYpiiqC2l |
| 05/26/20 0011 | 030 | IMG_0651        | P | 1 | https://drive.google.com/file/d/1imYzaTA--eVDMeSM-dHfYBfC2tiAHsLV |
| 05/26/20 0348 | 031 | IMG_0652        | P | 0 | https://drive.google.com/file/d/1w0Q6lhLYH9ACwQfUosucUE9x5-uAsNzI |
|_______________|_____|_________________|___|___|___________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
These above exhibits clearly show a lot more information than some dipshit cornoner decided to complain about to 
SCOTT CARPENTER, like fuckin' (3) FULL DAYS LATE.

Wanna know WHY this happened...?
It's because I went to CENTER FOR SECURITY and asked the dude who works there, to review the footage, on:
05/27/20 after I went to the FEIDEN APPLIANCE CENTER.

Blonde haired kid said: "You got a badge...?"
And I said "No."
Then he BASICALLY told me to piss off.
Pretty dead look on his face about the way he said it, too.

I left a POST-IT NOTE on the door at CENTER FOR SECURITY, right after I took the first (2) pictures in the links above.
Weird, right...?

I also left a POST-IT NOTE on the VAN in the back of the AMBIENCE lot, right aftertook the THIRD picture in the
links above.
That's weird too, right...?

Howcome nobody asked me about those POST-IT NOTES...?
OOoooOOOoooOOOhhHHhHHhhHhhhHhhhhooOohhhhh...
It's because retards like JAMES LEONARD have badges, and they're fuckin' lazy, that's why.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-003564                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-003564"
$List.AddRecord($Name,"06/13/20 10:54:00","06/13/20 12:05:00")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddResponder("Mark Sheehan","<UNSPECIFIED>")

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-003564 (1).JPG","https://drive.google.com/file/d/1wYsaD825xVjkJ7eCbve6DwflW5v1KYCx"),
("SCSO-2020-003564 (2).JPG","https://drive.google.com/file/d/1uwgrUG3MCA9AU6jue_7GtDZyoz5YDKxz"),
("SCSO-2020-003564 (3).JPG","https://drive.google.com/file/d/1AUscW2inUcTlCgps-qX0QrBmUKdLOE4h"),
("SCSO-2020-003564 (4).JPG","https://drive.google.com/file/d/1DwVB9wRN-mHBLKciGRinwMrdCZZgwIeI"),
("SCSO-2020-003564 (5).JPG","https://drive.google.com/file/d/1CTmhJEd-6vzlMZHv6iCeEcCjpc80Tjbs") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"
I was arguing with my mother about the SPECTRUM bill.

As for the DAY OR TWO PRIOR to June 13th, 2020, when I walked to IMS, and realized I had to go back home…
…as soon as I got back to the house to grab the laptop, I asked my son for his account and password. 
He suddenly couldn't remember his password.
Wanna know why...?

Well, it's because my mother and stepfather were unwittingly teaching my son how to lie, repeatedly.
That's why.

Two people that apparently have brain damage... somehow not realizing that my son was learning to do all 
this, whereby getting his FATHER IN SERIOUS TROUBLE...


But nobody cares about the (2) men that tried to kill me, nor that the government disabled my iPhone.
Awesome stuff. BEFORE all of this shit happened though...?
I did this REALLY cool thing where I make a lot of people look like the useless cunts to society that they are.
_______________________________________________________________
| 05/23/20 1200 | Virtual Tour | https://youtu.be/HT4p28bRhqc |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
What THAT is called, is a "VIDEO", of me, teaching my children about WHAT I DO, and WHY I DO IT.
In that particular video, the useless cunts that called CPS on me will probably be SHOCKED to discover...
...that I actually love my children and am attempting to teach them how many lying sacks of shit exist in 
our society.

Here's the problem.
If people are TOO STUPID to ASK QUESTIONS, then that AUTOMATICALLY MEANS that the TRUTH doesn't matter.
Ever.
So if someone GRABS A WEAPON, and SHOOTS SOME BITCH IN THE BACK OF THE HEAD LIKE MY FATHER WAS...
...and then LIES about it...
...then that bitch just dies, and that's the end of the story.

Who that bitch is...? Nobody knows.
Nobody actually cares, either.
That's what happens when people LIE.

Since I like to tell the TRUTH, THE WHOLE TRUTH, and NOTHING BUT THE TRUTH...
The truth is that I have no such intentions to shoot some bitch in the back of the head like my father was.
It's just that some stupid bitch decided to fuck with the wrong person, and I have to state these things
IMPLICTLY, that way, the bitch realizes that at any fucking moment, what she did to me may come back to 
bite her in the ass.

I was actually following the advice that MR. MULLER gave me, to go to the school campus, to get a hotspot
for my children to be able to DO THEIR FUCKING SCHOOLWORK.

Yeah.
I went back to Shenendehowa IMS to get the hotspot... on FOOT. 
However, by the time I got back there...?
The last woman was leaving... And she basically said 
"Look dude, I don't really care what ya need man... I got places to be... Know what I'm sayin'?"

Nah. Cause then that means my kid can't show me his INCOMPLETE SCHOOLWORK cause I've got no INTERNET, 
cause the INTERNET SERVICE PROVIDER was ALLOWING MY SERVICE TO BE DISRUPTED. 
Sorta covered all that shit in the FIRST INCIDENT with my stepfather.

People just suck dick at this game called "CONNECT THE DOTS"

So, for instance...

Imagine if you would, that Kristin Johnson and I actually started banging it out in her office.
Well, a SERVICE DISRUPTION is a lot like me, pulling my dick ALL THE WAY OUT...? And then, just being a 
REAL PRICK, and make her wait a moment... wait till she says "What the hell, why'd you stop...?"

Well, that's basically the same thing that kept happening to my internet that I was EXPECTED TO PAY FOR.
SORRY IF I'M BEING PRETTY VULGAR IN MY LANGUAGE, and my ANALOGIES…
But frankly, I don't fucking care if I offend this bitch. I really do not give a flying fuck.

I have a video of the hardware being ATTACKED.
Listed those exhibits already.

Sorry I have to use such a COLORFUL METAPHOR... but, what seems to be happening is that...
When I'm NICE and I just follow the RULES that society has...?
People just ignore me, because they're fuckin' stupid like that.

After I tried to get the hotspot for like a couple days in a row...
...I wound up going to the DISTRICT OFFICE at 5 CHELSEA PLACE, and vented my frustrations with the secretary
at the counter, who was able to submit the ticket FOR me, for the hot spot. 

I can't remember if that was the same day or not...?
Frankly, it doesn't matter.

As for what I SPECIFICALLY REMEMBER about 06/13/20, my children were complaining about having no internet. 

I understood what the problem was.
My MOTHER and STEPFATHER, are fucking morons, and thought that I didn't understand the PROBLEM,
AND FURTHER TO THAT POINT, they didn't KNOW that I had ALREADY WALKED TO THE FUCKING SHENENDEHOWA CAMPUS...
TWICE. AND... that I had already submitted a ticket for the hotspot at the DISTRICT OFFICE.
Neither did KRISTIN JOHNSON for that matter.

So I was LITERALLY TELLING THEM THIS SHIT, and they thought that I was just being a lazy cocksucker that doesn't
give a flying fuck about his kids, when the reality is, I literally already walked to the campus TWICE.
And then I submitted the ticket at the district office.

That's how stupid my MOTHER and STEPFATHER truly are.
THEN, BILL MOAK DECIDED TO STICK HIS FUCKING NOSE IN BUSINESS THAT WASN'T HIS TO GET INVOLVED IN.

The truth of the matter is that I saw very clearly that the POLICE were BEING WICKED LAZY about the MURDER ATTEMPT
and then DISABLING MY PHONE and then LAUNCHING ADVANCED CYBERATTACKS AGAINST ME, and basically everyone around me
seems to think that shit is LITERALLY INSANE.

People STILL fuckin' think this way, too.
That's ok.
They can go on Facebook every fucking day, and never make the correlations, that the shit I was posting...?
It had everything to do with my situation.
They're just... morons that don't understand that.

I kept arguing with my mother, and stepfather, about how the (2) guys tried to kill me outside of COMPUTER ANSWERS
which is my OLD JOB where I was VICTIMIZED… so, I wasn't DELUDING MYSELF. 

They didn't get it, I WAS ALMOST MURDERED, I even told them that I had a FEAR that I would GO MISSING and 
NEVER BE FOUND, and THAT IS WHY I KEPT GETTING PISSED OFF AT THEM.

I wasn't really pissed off at my children AT ALL. 
However, my son was lying to me about a number of things.

Eventually, my mother and I were arguing outside, to the point where Bill Moak had to tell me through his 
kitchen window...

Bill : Hey~! 
       I'd prefer to shove a dildo in my asshole in peace…~!
       You better respect your mother ya fuckin' degenerate fuckface...~!

I didn't realize how inconsiderate I was being. 
I was inconveniencing everyone around me with this "government disabled my iPhone during a murder attempt", gag.
Everyone else was using "AIR QUOTES", I'm literally trying to show people evidence, and they're too stupid to
look at it. That's just how the story actually goes on a daily basis, here in America, for Michael C. Cook Sr.

I didn't realize that my argument with (2) elderly adults that each have a serious case of brain damage, means 
that I have to suddenly respect them when they consistently disrespect ME, and teach my kids how to lie.

Me : Oh, my bad Bill... 
     Didn't mean to interrupt your asshole-stuffin'-funtime-magic-show.

To be fair, I am injecting a PARTICULAR FALSEHOOD about how Bill shoves a dildo in his ass... 
...into what was ACTUALLY said.
But the COOL thing is, I am a better man than HE is, and that's why I will LITERALLY ADMIT THAT.

/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/

Bill  : OoOOOoooHHHhhhHh who cares if your mother is wrong, you need to show some respect~!
Me    : Hey Bill...?
Bill  : *eyebrows up* 
Me    : Do yourself a favor, and shut the fuck up.
        Thanks.
Janet : Hey pal~! 
        We're havin' this conversation through the kitchen window, and we are SOOOO gonna lie to the police, 
        so you better fuckin' watch your mouth.
        *making gestures with her hands* You're all talk and no action anyway...
Me    : Hey Janet, remember when I did your husband a `$600 job, and even like, 
        saved him from spending `$400 when I said "Buy this BIOS battery, and I'll install it for ya..."
Janet : Nah, can't say that I'd ever admit to receiving about `$1000 of money that YOU saved us from 
        having to spend.
Me    : Nah, I know, that's because when you do favors for people, people fuckin' forget that shit.
Janet : Shouldn't bring up the past like that... 
        All talk, no action.
Me    : You really are a cunt, you know that...?
        *everybody makes an audible gasp*
Bill  : I'm just lettin' ya know through my kitchen window...? 
        I'm gonna fuckin' kill ya 
Me    : Bill, go take a Midol already, will ya...?

\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\

Little did I realize, what I said actually caused Bill's brain to start producing adrenaline.
He did ACTUALLY SAY "I'm gonna fuckin' kill ya", which prompted my 911 call.

The man actually grabbed an aluminum baseball bat out of FRUSTRATION, came outside, decided to hit the side
of his trailer (whereby leaving a dent), and THEN... RAN ONTO MY PROPERTY, CHARGING AT ME...
...without taking a single moment to reflect on how many crimes this man was committing, AND, ABOUT TO COMMIT.

Bill actually ran pretty fast. 
Onto my property. 
When I was standing next to my porch. 
And my house.
On my property. 
So like, Janet Moak, Bill Moak, and Michael Streeter committed several felonies that day.

FIRST  charge:  FELONY     for ATTEMPTING TO ASSAULT ME WITH A BASEBALL BAT
SECOND charge: MISDEMEANOR for PROVIDING FALSE TESTIMONY ON A WRITTEN INSTRUMENT
THIRD  charge: MISDEMEANOR for TRESPASSING

But amazingly, even if I happen to be the person who successully calls 911...?
AND, I know for a FACT that SCSO recorded that god damn 911 call...?

oOoOOooOhhhHhh
Well, some fuckface that runs SCSO will leave that 911 call transcription out of my FOIL request.
THEN, when Mark Sheehan shows up, he will take everybody else's statement FIRST, before
talking to the guy that called 911.

I told Mark Sheehan about my SOCIAL MEDIA having it's EXPOSURE limited and my CONTENT being CENSORED.
I actually have NUMEROUS VIDEOS OF THAT.
I ALSO told Mark Sheehan about the number of cyberattacks I've been subjected to since I started my company,
and since I left COMPUTER ANSWERS.

Some of that managed to make it's way into a report.
A lot of stuff didn't make it into that report at all, such as MY STATEMENT was mostly VOIDED OUT.
In the AGRESTA situation on 05/19/20, AGRESTA actually does this thing called CORROBORATION, and writes
stuff that suggests that he asked both parties about their version of the story, and literally writes
down that we reported a similar chain of events.

No such consideration was made as a result of my 911 call, and to top it off, my call was CHANGED from
a DISTURBANCE, to a MEDICAL/EDP.

Why...? Well, it's because I realized that I was surrounded by fucking morons, even back then.
I volunteered to get a psych evaluation because I couldn't convince any of the morons around me, to take 
a good hard look at the evidence I was able to get off of my device BEFORE it was disabled by the 
manufacturer.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-003688                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-003688"
$List.AddRecord($Name,"06/19/20 09:58:00","06/18/20 13:32:00")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddResponder("Michael Whitacre","<UNSPECIFIED>")

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-003688 (1).JPG","https://drive.google.com/file/d/1R0EUH3z8JRhliQuvpMogZK8l5Nzi80mw"),
("SCSO-2020-003688 (2).JPG","https://drive.google.com/file/d/1H62ZDnQT3s-k-aUXMJAFzWseMk79e_a7"),
("SCSO-2020-003688 (3).JPG","https://drive.google.com/file/d/1g00XTcJk5_tzb4Utdn_i2on_TYuwaXTV"),
("SCSO-2020-003688 (4).JPG","https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV"),
("SCSO-2020-003688 (5).JPG","https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

# _____________
# | Narrative |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯

$Record.AddNarrative(@"

"@)


#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-040452                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-040452"
$List.AddRecord($Name,"07/13/20 12:56:06","07/13/20 12:59:32")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("NYSP Trooper Girl #1","2G38"),
("NYSP Trooper Girl #2","2G36"),
("S41191CB Clayton Brownell","SL4188"),
("S41923MS Michael Sharadin","SL4138") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-040452 (1).JPG","https://drive.google.com/file/d/1xfJ2mYvxptHLldugAXjhEdASRJpWIzIK"),
("SCSO-2020-040452 (2).JPG","https://drive.google.com/file/d/1Tg6cFXH5dKEL8XaYYOG_YlvaOsDQcTWW"),
("SCSO-2020-040452 (3).JPG","https://drive.google.com/file/d/1U6CAQBk3f__piiQSSjPeInnKr8ao4wkj"),
("SCSO-2020-040452 (4).JPG","https://drive.google.com/file/d/1sbOUEgjK9AqrRrDRYa1EkU-ErkTXqURa"),
("SCSO-2020-040452 (5).JPG","https://drive.google.com/file/d/1gy68TFdZtye5l6beMmZBiUTYVXlJKe-i"),
("SCSO-2020-040452 (6).JPG","https://drive.google.com/file/d/1w9bTxJKvT5MUWmmqgIYY0DfayD5LOlSI"),
("SCSO-2020-040452 (7).JPG","https://drive.google.com/file/d/1CzN8beW0ZZdX090YOw2mEJIdCZC04PGW"),
("SCSO-2020-040452 (8).JPG","https://drive.google.com/file/d/1HvTGMksppPjm2DbP15TznxUefIsOMSXl"),
("SCSO-2020-040452 (9).JPG","https://drive.google.com/file/d/18lqeF2KZGTcP_y8stv8I7Vgj1eO3p9-N"),
("SCSO-2020-040452 (10).JPG","https://drive.google.com/file/d/1_VkPwS0UaoxPymS5rTYN3pKBSGtksw2E") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-040845                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-040845"
$List.AddRecord($Name,"07/14/20 21:47:15","07/14/20 21:50:06")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("SCSO Cameron Missenis","2G62"),
("S43810AA Anthony Agresta","SL4138"),
("S44333PZ Paul Zurlo","SL4182"),
("<UNSPECIFIED[1]>","2G36"),
("<UNSPECIFIED[2]>","2G32") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-040845 (1).JPG","https://drive.google.com/file/d/16LJXiWdXHTHdjdu8RZljsP4QtcaLpb9o"),
("SCSO-2020-040845 (2).JPG","https://drive.google.com/file/d/1d66nKgEBDPUm_ZRRHGjtV21i5WlCQX11"),
("SCSO-2020-040845 (3).JPG","https://drive.google.com/file/d/1n9FR3MNUuqQTlOkdYa9D8ZePoGF8krpF"),
("SCSO-2020-040845 (4).JPG","https://drive.google.com/file/d/1M5z-B_Unn8kW3WXBFSBGL8wQXL5TU56v"),
("SCSO-2020-040845 (5).JPG","https://drive.google.com/file/d/1p2Jeu80lNBIuADhsbeDFPDhcP4qpwWhK"),
("SCSO-2020-040845 (6).JPG","https://drive.google.com/file/d/1vR6pvH9X3cVivusOdw1CO0AcOQZk-ItV"),
("SCSO-2020-040845 (7).JPG","https://drive.google.com/file/d/1PYhrVopmnkIXisUKQ-CeCzAKPQnMh2g3") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-049517                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-049517"
$List.AddRecord($Name,"08/16/20 17:25:25","08/16/20 17:29:27")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("<UNSPECIFIED[1]>","2G32"),
("S44180CM Cameron Missines","SL4175"),
("<UNSPECIFIED[2]>","2G31"),
("<UNSPECIFIED[3]>","2G38") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-049517 (1).JPG","https://drive.google.com/file/d/1WhcxCTZt26-gh9t0ZQKk6wSUaYfKk2Cr"),
("SCSO-2020-049517 (2).JPG","https://drive.google.com/file/d/1toDPjjf-M__-QHDVXIDsII_J2RjBxckO"),
("SCSO-2020-049517 (3).JPG","https://drive.google.com/file/d/1qxFw216D3Wm4RU2qUI53A27LpvNtA6_a"),
("SCSO-2020-049517 (4).JPG","https://drive.google.com/file/d/1-jBAexBvmsXzXLw6v_QEHCu3OEqyng9i"),
("SCSO-2020-049517 (5).JPG","https://drive.google.com/file/d/17XwO7_Yb3AbU-IW0wKwl6fZiLciPdDs_"),
("SCSO-2020-049517 (6).JPG","https://drive.google.com/file/d/1iUkG4Wv02XKXMYZTuStZ5U6K1ZcdJ43r") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ SCSO-2020-053053                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Name = "SCSO-2020-053053"
$List.AddRecord($Name,"08/31/20 10:57:58","08/31/20 11:04:13")
$Record = $List.Output | ? Name -eq $Name

# ______________
# | Responders |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯

("SL44469MS Mark Sheehan","SL4170"),
("<UNSPECIFIED[1]>","2G35") | % { 
    
    $Record.AddResponder($_[0],$_[1]) 
}

# ___________
# | Entries |
# ¯¯¯¯¯¯¯¯¯¯¯

("SCSO-2020-053053 (1).JPG","https://drive.google.com/file/d/1XNtAwHgD0SJwDHNqx9FKByY3U-TRuq3a"),
("SCSO-2020-053053 (2).JPG","https://drive.google.com/file/d/1cKcu6EM7KMztdSFgPNGysp6arvkQSYGM"),
("SCSO-2020-053053 (3).JPG","https://drive.google.com/file/d/1OVlZClO_mdtKK9A0rqBBf7zhsRz4mFqb"),
("SCSO-2020-053053 (4).JPG","https://drive.google.com/file/d/1M1xyGwyA-_1Dc0EEN-O-XX0iuq74GxTn"),
("SCSO-2020-053053 (5).JPG","https://drive.google.com/file/d/1V8rhIh-T6HXT5HBgrAynIEJ7FoDMTi4N") | % { 
    
    $Record.AddEntry($_[0],$_[1])
}

<#
______________________________
| What the output looks like |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 0                                                                                                     |
| Name      : SCSO-2020-002998                                                                                      |
| Date      : 05/19/20                                                                                              |
| Receive   : 5/19/2020 8:18:59 PM                                                                                  |
| Transmit  : 5/19/2020 8:19:00 PM                                                                                  |
| Elapsed   : 00:00:01                                                                                              |
| Responder : (3)                                                                                                   |
|             _______________________________________                                                               |
|             | 0 | Anthony Agresta | <UNSPECIFIED> |                                                               |
|             | 1 |      Sean Lyons | <UNSPECIFIED> |                                                               |
|             | 2 |   John Hildreth | <UNSPECIFIED> |                                                               |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                               |
| Entry     : (3)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-002998 (1).JPG | https://drive.google.com/file/d/1ykNZKM_VS0NWdckqVToSmL-ujjTBl4zz |  |
|             | 1 | SCSO-2020-002998 (2).JPG | https://drive.google.com/file/d/1i4s7_tiT5bdNWsydqIMDMFFRRrOx1-zZ |  |
|             | 2 | SCSO-2020-002998 (3).JPG | https://drive.google.com/file/d/17K2GMKn6hx3CF_HrSuB8Z_HfPlUKmNkQ |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 1                                                                                                     |
| Name      : SCSO-2020-027797                                                                                      |
| Date      : 05/23/20                                                                                              |
| Receive   : 5/23/2020 1:00:17 AM                                                                                  |
| Transmit  : 5/23/2020 1:06:30 AM                                                                                  |
| Elapsed   : 00:06:13                                                                                              |
| Responder : (1)                                                                                                   |
|             _________________________________________                                                             |
|             | 0 | S43460SS Scott Schelling | SL4184 |                                                             |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                             |
| Entry     : (6)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-027797 (1).jpg | https://drive.google.com/file/d/19Vkh-Uc_7yR9HJcmQnsttIo6H5tmUYzK |  |
|             | 1 | SCSO-2020-027797 (2).jpg | https://drive.google.com/file/d/1CjjAS46TX-RfeSYkhKmXVKsD94pwBX7b |  |
|             | 2 | SCSO-2020-027797 (3).jpg | https://drive.google.com/file/d/1CQjwnrFkAxL9meg63z1ttdyz5Hczs5RM |  |
|             | 3 | SCSO-2020-027797 (4).jpg | https://drive.google.com/file/d/1dfL4ca_lwe_CBDO1ttfYcL5d4_koopWC |  |
|             | 4 | SCSO-2020-027797 (5).jpg | https://drive.google.com/file/d/1yGBIQbo20b6sPovrJkOOM9EXIUdPF2zQ |  |
|             | 5 | SCSO-2020-027797 (6).JPG | https://drive.google.com/file/d/1pfbyK6dlsFKC1JTDaKxdvdCJQl1HX_3W |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 2                                                                                                     |
| Name      : SCSO-2020-028501                                                                                      |
| Date      : 05/26/20                                                                                              |
| Receive   : 5/26/2020 1:28:57 AM                                                                                  |
| Transmit  : 5/26/2020 1:31:14 AM                                                                                  |
| Elapsed   : 00:02:17                                                                                              |
| Responder : (3)                                                                                                   |
|             _________________________________________                                                             |
|             | 0 | S4192JW Joshua Welch     | SL4197 |                                                             |
|             | 1 | S41925JK Jeffrey Kaplan  | SL4138 |                                                             |
|             | 2 | S43460SS Scott Schelling | SL4184 |                                                             |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                             |
| Entry     : (6)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-028501 (1).JPG | https://drive.google.com/file/d/1adfRlVCkUn5H-eauU8pNtPogGlnsVwbP |  |
|             | 1 | SCSO-2020-028501 (2).JPG | https://drive.google.com/file/d/1fxb8zTS2v19W5_iIjA3jaGxEaYpFROdO |  |
|             | 2 | SCSO-2020-028501 (3).JPG | https://drive.google.com/file/d/1R14NXV0ziULhhv3tCfzxBuH-TDYv0iWy |  |
|             | 3 | SCSO-2020-028501 (4).JPG | https://drive.google.com/file/d/1XvlYs2OHS0j6jbV5kYqhyYPb5JomMGH- |  |
|             | 4 | SCSO-2020-028501 (5).JPG | https://drive.google.com/file/d/1ghOYtzKZxUYnY4qQp1ZexcQtT2KxZZDk |  |
|             | 5 | SCSO-2020-028501 (6).JPG | https://drive.google.com/file/d/1ukn4TLWoXdH-hFeDBOqyMujxxOXyZf2M |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 3                                                                                                     |
| Name      : SCSO-2020-003173                                                                                      |
| Date      : 05/27/20                                                                                              |
| Receive   : 5/27/2020 12:12:00 PM                                                                                 |
| Transmit  : 6/1/2020 12:19:00 PM                                                                                  |
| Elapsed   : 5.00:07:00                                                                                            |
| Responder : (3)                                                                                                   |
|             _____________________________________                                                                 |
|             | 0 | Michael Smith | <UNSPECIFIED> |                                                                 |
|             | 1 | DJ Thompson   | <UNSPECIFIED> |                                                                 |
|             | 2 | James Leonard | <UNSPECIFIED> |                                                                 |
              ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                 |
| Entry     : (6)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-003173 (1).JPG | https://drive.google.com/file/d/14Ajb2y93NEJ6YC255-lHe361KoCF7OxP |  |
|             | 1 | SCSO-2020-003173 (2).JPG | https://drive.google.com/file/d/1KsriWjDat6F2mz9Vy8FJMUWLRF6ViYO4 |  |
|             | 2 | SCSO-2020-003173 (3).JPG | https://drive.google.com/file/d/1l_fs1BP1FmQiuoQ7rJZQAh3dvpw5o-bQ |  |
|             | 3 | SCSO-2020-003173 (4).JPG | https://drive.google.com/file/d/1cDq5H8QpzvowOJ1C3rLbraiNCJaoscTW |  |
|             | 4 | SCSO-2020-003173 (5).JPG | https://drive.google.com/file/d/13zr1gip9mkaJSsXRnxU8lhZiR5cNYTKj |  |
|             | 5 | SCSO-2020-003173 (6).JPG | https://drive.google.com/file/d/17ZvRkZWwxDTHCnrhbHOL7hh_L2MCnF7t |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 4                                                                                                     |
| Name      : SCSO-2020-003177                                                                                      |
| Date      : 05/27/20                                                                                              |
| Receive   : 5/27/2020 2:14:00 PM                                                                                  |
| Transmit  : 5/24/2020 7:05:00 PM                                                                                  |
| Elapsed   : -2.19:09:00                                                                                           |
| Responder : (2)                                                                                                   |
|             _______________________________________                                                               |
|             | 0 | Scott Carpenter | <UNSPECIFIED> |                                                               |
|             | 1 | James Leonard   | <UNSPECIFIED> |                                                               |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                               |
| Entry     : (5)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-003177 (1).JPG | https://drive.google.com/file/d/1xritPqOI-ng04v_yp203zM_3sG2-_Jb2 |  |
|             | 1 | SCSO-2020-003177 (2).JPG | https://drive.google.com/file/d/119rBz3sGpt6lPF4qQ90nWwALZ2W1iWJ3 |  |
|             | 2 | SCSO-2020-003177 (3).JPG | https://drive.google.com/file/d/1FfcBWZZlkmf88XOtq0xBIvgK6m_3qwkP |  |
|             | 3 | SCSO-2020-003177 (4).JPG | https://drive.google.com/file/d/1WkNbhqgvDIWZJYbCObEI-j12Mz_g2CDJ |  |
|             | 4 | SCSO-2020-003177 (5).JPG | https://drive.google.com/file/d/1rjCU9yHzIo6gFw41aPAtAMmr42-iAG1I |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 5                                                                                                     |
| Name      : SCSO-2020-003564                                                                                      |
| Date      : 06/13/20                                                                                              |
| Receive   : 6/13/2020 10:54:00 AM                                                                                 |
| Transmit  : 6/13/2020 12:05:00 PM                                                                                 |
| Elapsed   : 01:11:00                                                                                              |
| Responder : (1)                                                                                                   |
|             ____________________________________                                                                  |
|             | 0 | Mark Sheehan | <UNSPECIFIED> |                                                                  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                                  |
| Entry     : (5)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-003564 (1).JPG | https://drive.google.com/file/d/1wYsaD825xVjkJ7eCbve6DwflW5v1KYCx |  |
|             | 1 | SCSO-2020-003564 (2).JPG | https://drive.google.com/file/d/1uwgrUG3MCA9AU6jue_7GtDZyoz5YDKxz |  |
|             | 2 | SCSO-2020-003564 (3).JPG | https://drive.google.com/file/d/1AUscW2inUcTlCgps-qX0QrBmUKdLOE4h |  |
|             | 3 | SCSO-2020-003564 (4).JPG | https://drive.google.com/file/d/1DwVB9wRN-mHBLKciGRinwMrdCZZgwIeI |  |
|             | 4 | SCSO-2020-003564 (5).JPG | https://drive.google.com/file/d/1CTmhJEd-6vzlMZHv6iCeEcCjpc80Tjbs |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 6                                                                                                     |
| Name      : SCSO-2020-003688                                                                                      |
| Date      : 06/19/20                                                                                              |
| Receive   : 6/19/2020 9:58:00 AM                                                                                  |
| Transmit  : 6/18/2020 1:32:00 PM                                                                                  |
| Elapsed   : -20:26:00                                                                                             |
| Responder : (1)                                                                                                   |
|             ________________________________________                                                              |
|             | 0 | Michael Whitacre | <UNSPECIFIED> |                                                              |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                              |
| Entry     : (5)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-003688 (1).JPG | https://drive.google.com/file/d/1R0EUH3z8JRhliQuvpMogZK8l5Nzi80mw |  |
|             | 1 | SCSO-2020-003688 (2).JPG | https://drive.google.com/file/d/1H62ZDnQT3s-k-aUXMJAFzWseMk79e_a7 |  |
|             | 2 | SCSO-2020-003688 (3).JPG | https://drive.google.com/file/d/1g00XTcJk5_tzb4Utdn_i2on_TYuwaXTV |  |
|             | 3 | SCSO-2020-003688 (4).JPG | https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV |  |
|             | 4 | SCSO-2020-003688 (5).JPG | https://drive.google.com/file/d/1RyG2SSXNpA95zW-EugtT9zTZ4HQ7N7MV |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 7                                                                                                     |
| Name      : SCSO-2020-040452                                                                                      |
| Date      : 07/13/20                                                                                              |
| Receive   : 7/13/2020 12:56:06 PM                                                                                 |
| Transmit  : 7/13/2020 12:59:32 PM                                                                                 |
| Elapsed   : 00:03:26                                                                                              |
| Responder : (4)                                                                                                   |
|             __________________________________________                                                            |
|             | 0 | NYSP Trooper Girl #1      | 2G38   |                                                            |
|             | 1 | NYSP Trooper Girl #2      | 2G36   |                                                            |
|             | 2 | S41191CB Clayton Brownell | SL4188 |                                                            |
|             | 3 | S41923MS Michael Sharadin | SL4138 |                                                            |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                            |
| Entry     : (10)                                                                                                  |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-040452 (1).JPG  | https://drive.google.com/file/d/1xfJ2mYvxptHLldugAXjhEdASRJpWIzIK | |
|             | 1 | SCSO-2020-040452 (2).JPG  | https://drive.google.com/file/d/1Tg6cFXH5dKEL8XaYYOG_YlvaOsDQcTWW | |
|             | 2 | SCSO-2020-040452 (3).JPG  | https://drive.google.com/file/d/1U6CAQBk3f__piiQSSjPeInnKr8ao4wkj | |
|             | 3 | SCSO-2020-040452 (4).JPG  | https://drive.google.com/file/d/1sbOUEgjK9AqrRrDRYa1EkU-ErkTXqURa | |
|             | 4 | SCSO-2020-040452 (5).JPG  | https://drive.google.com/file/d/1gy68TFdZtye5l6beMmZBiUTYVXlJKe-i | |
|             | 5 | SCSO-2020-040452 (6).JPG  | https://drive.google.com/file/d/1w9bTxJKvT5MUWmmqgIYY0DfayD5LOlSI | |
|             | 6 | SCSO-2020-040452 (7).JPG  | https://drive.google.com/file/d/1CzN8beW0ZZdX090YOw2mEJIdCZC04PGW | |
|             | 7 | SCSO-2020-040452 (8).JPG  | https://drive.google.com/file/d/1HvTGMksppPjm2DbP15TznxUefIsOMSXl | |
|             | 8 | SCSO-2020-040452 (9).JPG  | https://drive.google.com/file/d/18lqeF2KZGTcP_y8stv8I7Vgj1eO3p9-N | |
|             | 9 | SCSO-2020-040452 (10).JPG | https://drive.google.com/file/d/1_VkPwS0UaoxPymS5rTYN3pKBSGtksw2E | |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 8                                                                                                     |
| Name      : SCSO-2020-040845                                                                                      |
| Date      : 07/14/20                                                                                              |
| Receive   : 7/14/2020 9:47:15 PM                                                                                  |
| Transmit  : 7/14/2020 9:50:06 PM                                                                                  |
| Elapsed   : 00:02:51                                                                                              |
| Responder : (5)                                                                                                   |
|             _________________________________________                                                             |
|             | 0 | SCSO Cameron Missenis    | 2G62   |                                                             |
|             | 1 | S43810AA Anthony Agresta | SL4138 |                                                             |
|             | 2 | S44333PZ Paul Zurlo      | SL4182 |                                                             |
|             | 3 | <UNSPECIFIED[1]>         | 2G36   |                                                             |
|             | 4 | <UNSPECIFIED[2]>         | 2G32   |                                                             |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                             |
| Entry     : (7)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-040845 (1).JPG | https://drive.google.com/file/d/16LJXiWdXHTHdjdu8RZljsP4QtcaLpb9o |  |
|             | 1 | SCSO-2020-040845 (2).JPG | https://drive.google.com/file/d/1d66nKgEBDPUm_ZRRHGjtV21i5WlCQX11 |  |
|             | 2 | SCSO-2020-040845 (3).JPG | https://drive.google.com/file/d/1n9FR3MNUuqQTlOkdYa9D8ZePoGF8krpF |  |
|             | 3 | SCSO-2020-040845 (4).JPG | https://drive.google.com/file/d/1M5z-B_Unn8kW3WXBFSBGL8wQXL5TU56v |  |
|             | 4 | SCSO-2020-040845 (5).JPG | https://drive.google.com/file/d/1p2Jeu80lNBIuADhsbeDFPDhcP4qpwWhK |  |
|             | 5 | SCSO-2020-040845 (6).JPG | https://drive.google.com/file/d/1vR6pvH9X3cVivusOdw1CO0AcOQZk-ItV |  |
|             | 6 | SCSO-2020-040845 (7).JPG | https://drive.google.com/file/d/1PYhrVopmnkIXisUKQ-CeCzAKPQnMh2g3 |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 9                                                                                                     |
| Name      : SCSO-2020-049517                                                                                      |
| Date      : 08/16/20                                                                                              |
| Receive   : 8/16/2020 5:25:25 PM                                                                                  |
| Transmit  : 8/16/2020 5:29:27 PM                                                                                  |
| Elapsed   : 00:04:02                                                                                              |
| Responder : (4)                                                                                                   |
|             __________________________________________                                                            |
|             | 0 | <UNSPECIFIED[1]>          | 2G32   |                                                            |
|             | 1 | S44180CM Cameron Missines | SL4175 |                                                            |
|             | 2 | <UNSPECIFIED[2]>          | 2G31   |                                                            |
|             | 3 | <UNSPECIFIED[3]>          | 2G38   |                                                            |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                            |
| Entry     : (6)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-049517 (1).JPG | https://drive.google.com/file/d/1WhcxCTZt26-gh9t0ZQKk6wSUaYfKk2Cr |  |
|             | 1 | SCSO-2020-049517 (2).JPG | https://drive.google.com/file/d/1toDPjjf-M__-QHDVXIDsII_J2RjBxckO |  |
|             | 2 | SCSO-2020-049517 (3).JPG | https://drive.google.com/file/d/1qxFw216D3Wm4RU2qUI53A27LpvNtA6_a |  |
|             | 3 | SCSO-2020-049517 (4).JPG | https://drive.google.com/file/d/1-jBAexBvmsXzXLw6v_QEHCu3OEqyng9i |  |
|             | 4 | SCSO-2020-049517 (5).JPG | https://drive.google.com/file/d/17XwO7_Yb3AbU-IW0wKwl6fZiLciPdDs_ |  |
|             | 5 | SCSO-2020-049517 (6).JPG | https://drive.google.com/file/d/1iUkG4Wv02XKXMYZTuStZ5U6K1ZcdJ43r |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
_____________________________________________________________________________________________________________________
|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
| Index     : 10                                                                                                    |
| Name      : SCSO-2020-053053                                                                                      |
| Date      : 08/31/20                                                                                              |
| Receive   : 8/31/2020 10:57:58 AM                                                                                 |
| Transmit  : 8/31/2020 11:04:13 AM                                                                                 |
| Elapsed   : 00:06:15                                                                                              |
| Responder : (2)                                                                                                   |
|             _______________________________________                                                               |
|             | 0 | SL44469MS Mark Sheehan | SL4170 |                                                               |
|             | 1 | <UNSPECIFIED[1]>       | 2G35   |                                                               |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                                                               |
| Entry     : (5)                                                                                                   |
|             ____________________________________________________________________________________________________  |
|             | 0 | SCSO-2020-053053 (1).JPG | https://drive.google.com/file/d/1XNtAwHgD0SJwDHNqx9FKByY3U-TRuq3a |  |
|             | 1 | SCSO-2020-053053 (2).JPG | https://drive.google.com/file/d/1cKcu6EM7KMztdSFgPNGysp6arvkQSYGM |  |
|             | 2 | SCSO-2020-053053 (3).JPG | https://drive.google.com/file/d/1OVlZClO_mdtKK9A0rqBBf7zhsRz4mFqb |  |
|             | 3 | SCSO-2020-053053 (4).JPG | https://drive.google.com/file/d/1M1xyGwyA-_1Dc0EEN-O-XX0iuq74GxTn |  |
|             | 4 | SCSO-2020-053053 (5).JPG | https://drive.google.com/file/d/1V8rhIh-T6HXT5HBgrAynIEJ7FoDMTi4N |  |
|             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯  |
|___________________________________________________________________________________________________________________|
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
#>
