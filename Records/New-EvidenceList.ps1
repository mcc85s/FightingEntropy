<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName : New-EvidenceList.ps1 (Requires Write-Theme)
          Solution : FightingEntropy
          Purpose  : Creates a container for EVIDENCE, RECORDS, and how to INVESTIGATE stuff.
          Author   : Michael C. Cook Sr.
          Contact  : @mcc85s
          Primary  : @mcc85s
          Created  : 2022-08-27
          Modified : 2022-08-27
          Version - 0.0.0 - () - Finalized functional version 1.
          TODO: #
.Example
#>

Function New-EvidenceList
{
    # // ___________________________________________________________________________________________________
    # // | Usually, as an INVESTIGATOR, you MAY WANNA CONSIDER...                                          |
    # // | 1) DAY, 2) MONTH and 3) YEAR that SOMETHING OCCURRED instead of IGNORING it, ya know...?        |
    # // | TROOPER RUFFAS, TROOPER MESSINES, TROOPER BOSCO, and TROOPER DERUSSO should consider this stuff |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Date
    {
        [DateTime] $Time
        Date([Object]$Time)
        {
            $This.Time = $Time
        }
        [String] ToString()
        {
            Return $This.Time.ToString("MM/dd/yy HHmm")
        }
    }

    # // ________________________________________________________________________________________________________
    # // | Now, just because we're in the process of EDUCATING (4) lazy cocksuckers at the NYSP... doesn't      |
    # // | mean that they're gonna continue to pay attention. So, we have to DO THEIR JOB <FOR> THEM...         |
    # // | since they fuckin' suck ass at it. And that's ok. Just like how BRUCE TANSKI can't help how          |
    # // | much of a dumbass he is...? THEY can't help how terrible they are at LAW ENFORCEMENT.                |
    # // | And you know what...? That's just how fucking lazy LAW AVOIDANCE OFFICERS are.                       |
    # // | LAW AVOIDANCE OFFICERS basically follow DEREK CHAUVIN 101. Not ACTUAL LAW ENFORCEMENT 101.           |
    # // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            |
    # // | Usually, you want to consider things like "TIME" and "PLACE" to determine whether a CRIME occurred,  |
    # // | INSTEAD of looking into a MAGICAL MIRROR, CONJURING UP WILD FANTASIES, and calling THOSE, "records", |
    # // | much how SARA DERUSSO, ROBERT MESSINES JR. SGT BOSCO, and NYSP TROOPER RUFFAS did on 06/28/2022.     |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Time
    {
        [UInt32]  $Index
        [String]   $Slot
        [DateTime] $Date
        Time([UInt32]$Index,[UInt32]$Slot,[String]$Date)
        {
            If ($Slot -notin 0,1)
            {
                Throw "Invalid Slot"
            }
            $This.Index = $Index
            $This.Slot  = $Slot
            $This.Date  = [DateTime]$Date
        }
        [String] ToString()
        {
            Return $This.Date.ToString("MM/dd/yy HHmm")
        }
    }

    # // ________________________________________________________________________________________
    # // | Crimes are (REPORTED and/or COMMITTED) by these.                                     |
    # // | SOMETIMES they're committed by the OFFICER that happens to be "REPORTING" something. |
    # // | For instance DEREK CHAUVIN who murdered GEORGE FLOYD.                                |
    # // | (^ That's "ILLEGAL", and IT IS STILL CONSIDERED A CRIME, EVEN IF IT IS NOT CAUGHT)   |  
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Party
    {
        [UInt32] $Index
        [String] $Name
        [String] $Affiliation
        [String] $Involvement
        Party([UInt32]$Index,[String]$Name,[String]$Affiliation,[String]$Involvement)
        {
            $This.Index       = $Index
            $This.Name        = $Name
            $This.Affiliation = $Affiliation
            $This.Involvement = $Involvement
        }
        [String] ToString()
        {
            Return $This.Name
        }
        [String] Output()
        {
            Return "{0} | {1} [{2}]" -f $This.Affiliation, $This.Name, $This.Involvement
        }
    }

    # // __________________________________________________________________________________________________
    # // | Crimes are committed AT these PLACES by a PARTY.                                               |
    # // | So for instance, SARA DERUSSO, SGT BOSCO, and TROOPER MESSINES committed an UNLAWFUL ARREST... |
    # // | ...at 201D HALFMOON CIRCLE, CLIFTON PARK, NY 12065 on 06/28/2022 and OBSTRUCTION OF JUSTICE.   |
    # // | It's CALLED OBSTRUCTION OF JUSTICE when the PERSON CLAIMS TO HAVE EVIDENCE, and the OFFICERS   |
    # // | JUST GO AHEAD AND COMMIT AN UNLAWFUL ARREST ANYWAY... because that's what LAW AVOIDANCE 101 is |
    # // | really ALL about. Not LAW ENFORCEMENT...? But- LAW AVOIDANCE. They're TOTALLY DIFFERENT THINGS |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Address
    {
        [UInt32] $Index
        [String] $Label
        [String] $Type
        [String] $Name
        [String] $Location
        [String] $City
        [String] $State
        [String] $Postal
        Address([UInt32]$Index,[String]$Label,[String]$Type,[String]$Name,[String]$Location,[String]$City,[String]$State,[UInt32]$Postal)
        {
            If ($Label -notin "Start","End","Single")
            {
                Throw "Invalid Label"
            }
            ElseIf ($Type -notin "Residence","Business","Government")
            {
                Throw "Invalid Type"
            }

            $This.Index    = $Index
            $This.Label    = $Label
            $This.Type     = $Type
            $This.Name     = $Name
            $This.Location = $Location
            $This.City     = $City
            $This.State    = $State
            $This.Postal   = $Postal
        }
        [String] ToString()
        {
            Return "{0} {1}, {2} {3}" -f $This.Location, $This.City, $This.State, $This.Postal
        }
    }

    # // ________________________________________________________________________________________________________
    # // | A "NARRATIVE" is essentially the STORY that has been CORROBORATED somehow.                           |
    # // | Typically as an INVESTIGATOR or a POLICE OFFICER, you're supposed to WRITE SHIT LIKE THAT DOWN.      |
    # // | Whereas, if you're a lazy fuck that happens to have a badge...? You'll conjure up WILD FANTASIES,    |
    # // | AND- you'll actually get a "paycheck", to continue doing that. It is fuckin' stupid, but it is TRUE. |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class NarrativeLine
    {
        [UInt32] $Index
        [String] $Line
        NarrativeLine([UInt32]$Index,[String]$Line)
        {
            $This.Index  = $Index
            $This.Line   = $Line
        }
        [String] ToString()
        {
            Return $This.Line
        }
    }

    Class Narrative
    {
        [UInt32] $Index
        [Object] $Content
        Narrative([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = @( )
            ForEach ($Line in $Content -Split "`n")
            {
                $This.Content += [NarrativeLine]::New($This.Content.Count,$Line)
            }
        }
        [String] ToString()
        {
            Return "<[NarrativeEntry[{0}]]>" -f $This.Index
        }
    }

    # // _____________________________________________________________________________________
    # // | This will contain a piece of "EVIDENCE" that the police never bothered to collect |
    # // | ev·i·dence | NOUN | the AVAILABLE BODY OF FACTS or INFORMATION indicating whether |
    # // | a BELIEF or PROPOSITION is TRUE or VALID                                          |
    # // | So in this case, if EVIDENCE IS DESTROYED or IGNORED...? Then PAUL PELAGALLI,     |
    # // | MICHAEL ZURLO, and HEATHER COREY MONGUE all get paid to be lazy fucks.            |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Exhibit
    {
        [UInt32] $Index
        [String] $Label
        [String] $Name
        [Object] $Path
        [String] $Date
        [String] $Url
        Hidden [UInt64] $Size
        [String] $SizeMb
        [Object] $Hash
        [String[]] $Notes
        Exhibit([UInt32]$Index,[String]$Label,[String]$Name,[String]$Date,[String]$URL,[String]$Notes)
        {
            $This.Index   = $Index
            $This.Label   = $Label
            $This.Name    = $Name
            $This.Date    = $Date
            $This.URL     = $URL
            $This.Notes   = $Notes -Split "`n"

            Write-Host "Invoking [~] [$($This.URL)]"
            
            $This.Path    = "{0}/{1}" -f (Get-Variable Home | % Value),$This.Name
            
            If (!(Test-Path $This.Path))
            {
                Invoke-RestMethod -URI $This.URL -Outfile $This.Path
                Clear-Host
            }

            $Item         = Get-Item $This.Path
            $This.Size    = $Item.Length
            $This.SizeMb  = "{0:n3} MB" -f ($This.Size/1MB)
            
            Write-Host "Getting [~] File hash"
            $This.Hash    = Get-FileHash $This.Path | % Hash
        }
        [Object[]] Slot()
        {
            Return @( "Index Label Name Date Url SizeMb Hash" -Split " " | % { $This.$_ } )
        }
        [String] Pad([UInt32]$Length,[String]$Char,[String]$String)
        {
            $Buffer  = $Length - $String.Length
            $Padding = $Char * ($Buffer-2)
            Return "{0}{1} |" -f $String, $Padding
        }
        [String[]] Output()
        {
            $Obj     = @{0="";1="";2="";3="";4="";5="";6="";7="";8=""}
            $X       = ($This.Slot() | % Length | Sort-Object)[-1] + 12
            $Obj[0]  = @([char]95) * $X -join ''
            $Obj[1]  = $This.Pad($X," ","| Index : $($This.Index)")
            $Obj[2]  = $This.Pad($X," ","| Label : $($This.Label)")
            $Obj[3]  = $This.Pad($X," ","| Name  : $($This.Name)")
            $Obj[4]  = $This.Pad($X," ","| Date  : $($This.Date)")
            $Obj[5]  = $This.Pad($X," ","| Url   : $($This.Url)")
            $Obj[6]  = $This.Pad($X," ","| Size  : $($This.SizeMb)")
            $Obj[7]  = $This.Pad($X," ","| Hash  : $($This.Hash)")
            $Obj[8]  = @([char]175) * $X -join ''

            $This.Notes | % { $Obj.Add($Obj.Count,$_) }

            Return @($Obj[0..($Obj.Count-1)])
        }
        [String[]] Comment()
        {
            Return @( $This.Output() | % { "# $_ "} )
        }
        [Object] Content()
        {
            Return @( Get-Content $This.Path )
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    # // ______________________________________________________________________________________________
    # // | This is a container object, sorta like a PLASTIC BAG for PHYSICAL EVIDENCE to "GO IN".     |
    # // | Usually as a POLICE OFFICER or an INVESTIGATOR, you'll wanna carry those around with ya.   |
    # // | What you DO NOT WANT TO DO, is what JOE IZZO does, which is to REMOVE EVIDENCE from the    |
    # // | EVIDENCE VAULT, at the HARRIMAN STATE CAMPUS NYSP CRIMELAB. Cause that's BAD, to do.       |
    # // | The HARRIMAN STATE CAMPUS NYSP CRIME LAB is the place where "EVIDENCE" is supposed to "GO" |
    # // | And NYSP TROOPER BORDEN admitted to me in front of CLAYTON BROWNELL that he has no fuckin' |
    # // | idea where this place actually IS, or what it's CALLED. It's off of EXIT FUCKIN' 4 on I-90 |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class ExhibitReference
    {
        [UInt32] $Index
        [String] $Type
        [String] $Name
        [Date]   $Date
        [UInt32] $Focus
        [Object] $Description
        [String] $URL
        ExhibitReference([UInt32]$Index,[String]$Type,[String]$Name,[String]$DateTime,[UInt32]$Focus,[String]$Comment)
        {
            $This.Index = $Index
            $This.Type  = Switch ($Type)
            {
                A {        "Audio" }
                C { "Conversation" }
                D {     "Document" }
                Q {       "Queers" }
                P {      "Picture" }
                V {        "Video" }
            }
            $This.Name  = $Name
            $String     = @(0..14 | % { If ($_ -eq 11) { ":" }; [Char[]]$DateTime[$_] }) -join ''
            $This.Date  = [Date]($String)
            $This.Focus = $Focus
            If ($Comment -notmatch "http")
            {
                $This.AddDescription($Comment)
            }
            If ($Comment -match "http")
            {
                $This.URL = ($Comment -Split " ")[0]
                $This.AddDescription($Comment.Replace($This.URL,"").TrimStart(" "))
            }
        }
        AddDescription([String]$Comment)
        {
            $This.Description = $Comment
        }
        [String] Output()
        {
            If ($This.Name.Length -lt 15)
            {
                $ID     = "{0}{1}" -f (@(" ") * (15-$This.Name.Length) -join ''),$This.Name
            }
            Else
            {
                $ID     = $This.Name
            }
            If (!$This.URL)
            {
                $Info  = $This.Description
            }
            Else
            {
                $Info  = $This.URL
            }
            Return "| {0:d4} | {1} | {2} | {3} | {4} | {5} " -f $This.Index, 
            $This.Type[0], 
            $ID, 
            $This.Date,
            $This.Focus, 
            $Info
        }
        [String] ToString()
        {
            Return "<[ExhibitEntry[{0}]]>" -f $This.Index
        }
    }

    Class ExhibitContainer
    {
        [String] $Path
        [Object] $Content
        [Object] $Output
        ExhibitContainer([String]$Path)
        {
            If ($Path -match "http[s*]")
            {
                $This.Path    = New-TemporaryFile | % FullName
                $Value        = Invoke-RestMethod $Path
                Set-Content $This.Path $Value -Verbose
                $This.Content = Get-Content $This.Path
            }
            Else
            {
                $This.Path    = $Path
                $This.Content = Get-Content $Path
            }

            $This.Output  = @( )
            ForEach ($Line in $This.Content | ? { $_.Length -gt 0 })
            {
                $This.Entry($Line)
            }
        }
        Entry([String]$Line)
        {
            $Split = $Line -Split "\|" | % TrimStart " " | % TrimEnd " "
            $This.Output += [ExhibitReference]::New($This.Output.Count,$Split[2],$Split[3],$Split[4],$Split[5],$Split[6])
        }
    }

    # // __________________________________________________________________________
    # // | Crimes that are REPORTED to the POLICE are SUPPOSED to be called THESE |
    # // | However, often times the POLICE will actually IMAGINE these things,    |
    # // | rather than to INVESTIGATE them. Otherwise known as a police officer   |
    # // | performing LAW AVOIDANCE, instead of LAW ENFORCEMENT                   |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Charge
    {
        [UInt32] $Index
        [String] $Name
        [String] $Description
        [String] $Severity
        Charge([UInt32]$Index,[String]$Name,[String]$Description,[String]$Severity)
        {
            $This.Index       = $Index
            $This.Name        = $Name
            $this.Description = $Description
            $This.Severity    = $Severity
        }
        [String] ToString()
        {
            Return "{0} - {1} [{2}]" -f $This.Name, $This.Description, $This.Severity
        }
    }

    # // _________________________________________________________________________
    # // | These can often be considered EVIDENCE themselves in a number of ways |
    # // | They can be 1) misreported, 2) misenforced, 3) illegally written, or  | 
    # // | various other terms can be applied, to provide/override an ALIBI, etc |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class Record
    {
        [UInt32]       $Index
        [String]    $Incident
        [String]   $Reference
        [Date]          $Date
        [Object]        $Time
        [String]    $Duration
        [Object]       $Party
        [Object]     $Address
        [Object]   $Narrative
        [Object]     $Exhibit
        [Object]      $Charge
        Record([UInt32]$Index,[String]$Incident,[String]$Reference,[String]$Date)
        {
            $This.Index     = $Index
            $This.Incident  = $Incident
            $This.Reference = $Reference
            $This.Date      = [Date][DateTime]$Date
            $This.Reset()
        }
        AddTime([String]$Slot,[String]$DateTime)
        {
            If ($Slot -eq 0 -and 0 -in $this.Time.Slot)
            {
                Throw "Start time already set, reset the time"
            }
            ElseIf ($Slot -eq 1 -and 1 -in $This.Time.Slot)
            {
                Throw "End time already set, reset the time"
            }
            
            Write-Host ("Adding Time [~] ({0}) [{1}]" -f @("Start","End","Single")[$Slot], $DateTime)
            $This.Time += [Time]::New($This.Time.Count,$Slot,$DateTime)

            If (0 -in $This.Time.Slot -and 1 -in $This.Time.Slot)
            {
                $Start         = $This.Time | ? Slot -eq 0
                $End           = $This.Time | ? Slot -eq 1
                $This.Duration = "$([TimeSpan]($End.Date-$Start.Date))"
            }
            
            $This.Rerank(0)
        }
        AddParty([String]$Name,[String]$Affiliation,[String]$Involvement)
        {
            If ($Name -in $This.Party.Name)
            {
                Throw "Party already specified"
            }

            Write-Host ("Adding Party [~] ({0}, {1} [{2}" -f $Name, $Affiliation, $Involvement)

            $This.Party += [Party]::new($This.Party.Count,$Name,$Affiliation,$Involvement)

            $This.Rerank(1)
        }
        AddAddress([String]$Label,[String]$Type,[String]$Name,[String]$Location,[String]$City,[String]$State,[UInt32]$Postal)
        {
            $Item = $This.Address | ? Location -eq $Location
            If ($Item -and $Item.City -eq $City -and $Item.State -eq $State -and $Postal -eq $Item.Postal)
            {
                Throw "Address already specified"
            }

            Write-Host ("Adding Address [~] ({0} {1}, {2} {3})" -f $This.Location, $This.City, $This.State, $This.Postal)

            $This.Address += [Address]::New($This.Address.Count,$Label,$Type,$Name,$Location,$City,$State,$Postal)

            $This.Rerank(2)
        }
        AddNarrative([String[]]$String)
        {
            Write-Host ("Adding Narrative [~] ...")
            $This.Narrative += [Narrative]::new($This.Narrative.Count,$String)

            $This.Rerank(3)
        }
        AddExhibit([String]$Type,[String]$Name,[String]$DateTime,[UInt32]$Focus,[String]$Comment)
        {
            $This.Exhibit += [ExhibitReference]::New($This.Exhibit.Count,$Type,$Name,$DateTime,$Focus,$Comment)
            $This.Rerank(4)
        }
        AddExhibitContainer([String]$Path)
        {
            $This.Exhibit = [ExhibitContainer]::new($Path).Output
            $This.Rerank(4)
        }
        AddCharge([String]$Name,[String]$Description,[String]$Severity)
        {
            Write-Host ("Adding Charge [~] ({0}/{1}) [2]" -f $Name, $Description, $Severity)
            $This.Charge += [Charge]::New($This.Charge.Count,$Name,$Description,$Severity)

            $This.Rerank(5)
        }
        [Object] Get([UInt32]$Slot,[UInt32]$Index)
        {
            $Name = $This.Slot($Slot)

            If ($Index -gt $This.$Name.Count)
            {
                Throw "Invalid [$Name] index specified"
            }

            Return @($This.$Name)[$Index]
        }
        Remove([UInt32]$Slot,[UInt32]$Index)
        {
            $Name = $This.Slot($Slot)

            If ($Index -gt $This.$Name.Count)
            {
                Throw "Invalid [$Name] index specified"
            }

            Write-Host "Removing [!] <[$Name[$Slot]]>"
            $This.$Name = @( $This.$Name | ? Index -ne $Index )

            $This.Rerank($Slot)
        }
        [String] Slot([UInt32]$Slot)
        {
            Return @(Switch ($Slot)
            {
                0 {      "Time" } 1 {     "Party" } 2 {   "Address" } 
                3 { "Narrative" } 4 {   "Exhibit" } 5 {    "Charge" }
            })
        }
        [UInt32] Item([String]$Item)
        {
            Return @(Switch -Regex ($Item)
            {
                Time      {0} Party     {1} Address   {2}
                Narrative {3} Evidence  {4} Charge    {5}
            })
        }
        Reset([UInt32]$Type)
        {
            Switch ($Type)
            {
                0 
                { 
                    $This.Time      = @( ) 
                    $This.Duration  = "<unknown>"
                }
                1 { $This.Party     = @( ) }
                2 { $This.Address   = @( ) }
                3 { $This.Narrative = @( ) }
                4 { $This.Exhibit   = @( ) }
                5 { $This.Charge    = @( ) }
            }
        }
        Reset()
        {
            ForEach ($X in 0..5)
            {
                $This.Reset([UInt32]$X) 
            }
        }
        Rerank([UInt32]$Slot)
        {
            $Name = $This.Slot($Slot)
            $Item = $This.$Name

            If ($Item.Count -eq 1)
            {
                $Item[0].Index = 0
            }
            If ($Item.Count -gt 1)
            {
                ForEach ($X in 0..($Item.Count-1))
                {
                    $Item[$X].Index = $X
                }
            }

            $Item  = $Item | Sort-Object Index
        }
    }

    # // ______________________________________________________________________________________________
    # // | This will contain a LIST of PIECES of "EVIDENCE" that the police never bothered to collect |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class EvidenceList
    {
        [Object] $Record
        [Object] $Exhibit
        EvidenceList()
        {
            $This.Record  = @( )
            $This.Exhibit = @( )
        }
        [String] Slot([UInt32]$Slot)
        {
            Return @("Record","Exhibit")[$Slot]
        }
        AddRecord([String]$Incident,[String]$Reference,[String]$Date)
        {
            Write-Host "Adding Record [+] $Incident"
            $This.Record += [Record]::New($This.Record.Count,$Incident,$Reference,$Date)
            $This.Rerank(0)
        }
        AddExhibit([String]$Label,[String]$Name,[String]$Date,[String]$URL,[String]$Comment)
        {
            If ($Name -in $This.Exhibit.Name)
            {
                Throw "Evidence name already exists"
            }
            ElseIf ($Url -in $This.Exhibit.URL)
            {
                Throw "Evidence URL already exists"
            }

            Write-Host "Adding Entry [+] $Name"
            $This.Exhibit += [Exhibit]::New($This.Exhibit.Count,$Label,$Name,$Date,$URL,$Comment)
            $This.Rerank(1)
        }
        Remove([UInt32]$Slot,[UInt32]$Index)
        {
            $Name = $This.Slot($Slot)

            If ($Index -gt $This.$Name.Count)
            {
                Throw "Invalid index"
            }
            Write-Host "Removing $Name [+] $Index"
            $This.$Name = @( $This.$Name | ? Index -ne $Index )

            $This.Rerank($Slot)
        }
        [Object] Get([UInt32]$Slot,[UInt32]$Index)
        {
            $Name = $This.Slot($Slot) 
            If ($Index -gt $This.$Name.Count)
            {
                Throw "Invalid index"
            }
        
            Return $This.$Name[$Index]
        }
        Rerank([UInt32]$Slot)
        {
            $Name = $This.Slot($Slot)

            If ($This.$Name.Count -eq 1)
            {
                $This.$Name[0].Index = 0
            }
            If ($This.$Name.Count -gt 1)
            {
                ForEach ($X in 0..($This.$Name.Count-1))
                {
                    $This.$Name[$X].Index = $X
                }
        
                $This.$Name  = $This.$Name | Sort-Object Index
            }
        }
    }
    
    [EvidenceList]::new()
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 1) Call the function "New-EvidenceList", and assign it to variable $Evidence                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence = New-EvidenceList

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 2) Add <[EXHIBIT[0]]> to the <[EVIDENCE LIST]>                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence.AddExhibit("SCSO Records Request #1",
                     "Cook  request_000210.pdf",
                   "09/04/2020",
                   "https://github.com/mcc85s/FightingEntropy/blob/main/Records/Cook%20%20request_000210.pdf?raw=true",
                   @'
Original file that I got from the SCSO Records department, SEPTEMBER 04, 2020
===========================================================================================
Note: This is a PDF file that is <MISSING the MOST IMPORTANT RECORD> from 05/26/2020 0130
'@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 3) Get the comment for <[EXHIBIT[0]]>, and paste it below                                      ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯   

$Evidence.Get(1,0).Comment()

# _____________________________________________________________________________________________________________ 
# | Index : 0                                                                                                 | 
# | Label : SCSO Records Request #1                                                                           | 
# | Name  : Cook  request_000210.pdf                                                                          | 
# | Date  : 09/04/2020                                                                                        | 
# | Url   : https://github.com/mcc85s/FightingEntropy/blob/main/Records/Cook%20%20request_000210.pdf?raw=true | 
# | Size  : 10.840 MB                                                                                         | 
# | Hash  : CB08C97CA0EAD4F8A401066E1F65EFFC54CCA9A3B3AAF34A11E1E6DE825C7FFF                                  | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
# Original file that I got from the SCSO Records department, SEPTEMBER 04, 2020 
# =========================================================================================== 
# Note: This is a PDF file that is <MISSING the MOST IMPORTANT RECORD> from 05/26/2020 0130 

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 4) Open the <[EXHIBIT[0]]> link in a WEB BROWSER, and push to Tab #1                           ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
# // Note: Admittedly has a lot of records that I didn't need.
# // ALL of these records [minus (1) from 05/19/20] were ADDED AFTER the MURDER ATTEMPT on 5/26/20.
# // That means that the POLICE are (INTENTIONALLY/MALICIOUSLY) MAKING ME LOOK LIKE A FUCKIN' DOUCHEBAG...
# // The MURDER ATTEMPT was actually COVERED UP by the SARATOGA COUNTY SHERIFFS OFFICE, in the NEXT EXHIBIT.

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 5) Add <[EXHIBIT[1]]> to the <[EVIDENCE LIST]>                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence.AddExhibit("SCSO Records Request #2",
                     "2020-028501 Cook req.pdf",
                     "02/03/2021",
                     "https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf?raw=true",
                     @'
Original file that I got from the SCSO Records department, FEBRUARY 08, 2021
===========================================================================================
Note: This is <the MOST IMPORTANT RECORD> from 05/26/2020 0130 when I was ALMOST MURDERED
'@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 6) Get the comment for <[EXHIBIT[1]]>, and paste it below                                      ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence.Get(1,1).Comment()

# _____________________________________________________________________________________________________________ 
# | Index : 1                                                                                                 | 
# | Label : SCSO Records Request #2                                                                           | 
# | Name  : 2020-028501 Cook req.pdf                                                                          | 
# | Date  : 02/03/2021                                                                                        | 
# | Url   : https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf?raw=true | 
# | Size  : 1.032 MB                                                                                          | 
# | Hash  : ECB4C6919E93A37511C60112A214E578A28FFD508FC1F7A821671B0D625F320E                                  | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
# Original file that I got from the SCSO Records department, FEBRUARY 08, 2021 
# =========================================================================================== 
# Note: This is <the MOST IMPORTANT RECORD> from 05/26/2020 0130 when I was ALMOST MURDERED 

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 7) Open the <[EXHIBIT[1]]> link in a WEB BROWSER, and push to Tab #2                           ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
# // Makes the records in [Tab #1] totally (irrelevant/meaningless)...
# // because it shows how fuckin' stupid Michael Zurlo is. I'll explain WHY, shortly. Around line 805.

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 8) Add <[EXHIBIT[2]]> to the <[EVIDENCE LIST]>                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence.AddExhibit("CICADA/ANONYMOUS Anomaly",
                     "Cook  request_000210.docx",
                     "06/12/2022",
                     "https://github.com/mcc85s/FightingEntropy/blob/main/Records/Cook%20%20request_000210.docx?raw=true",
                     @"
ALTERED FILE that somehow got ADDED TO MY GOOGLE DRIVE ACCOUNT on 06/12/2022 AFTER I added 
PICTURES of ERIC CATRICALAS RESIDENCE to my BOOK, TOP DECK AWARENESS - NOT NEWS.
===========================================================================================
Note: This particular file has a GIGANTIC array of DIFFERING FONT SIZES, CHARACTERS, etc.
      AND... it even says that it's from FACEBOOK in the file.
"@)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 9) Get the comment for <[EXHIBIT[2]]>, and paste it below                                      ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Evidence.Get(1,2).Comment()

# ______________________________________________________________________________________________________________ 
# | Index : 2                                                                                                  | 
# | Label : CICADA/ANONYMOUS Anomaly                                                                           | 
# | Name  : Cook  request_000210.docx                                                                          | 
# | Date  : 06/12/2022                                                                                         | 
# | Url   : https://github.com/mcc85s/FightingEntropy/blob/main/Records/Cook%20%20request_000210.docx?raw=true | 
# | Size  : 0.180 MB                                                                                           | 
# | Hash  : 6B1BA87A617ABFBC0A3C61A7E8E95B676F079674C8B4AE8870321CDA659698AF                                   | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
# ALTERED FILE that somehow got ADDED TO MY GOOGLE DRIVE ACCOUNT on 06/12/2022 AFTER I added  
# PICTURES of ERIC CATRICALAS RESIDENCE to my BOOK, TOP DECK AWARENESS - NOT NEWS. 
# =========================================================================================== 
# Note: This particular file has a GIGANTIC array of DIFFERING FONT SIZES, CHARACTERS, etc. 
#       AND... it even says that it's from FACEBOOK in the file. 

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 10) Open the <[EXHIBIT[2]]> link in a WEB BROWSER, and push to Tab #3, then rant til line 805  ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

# // __________________________________________
# // | Check out that ANOMALY, <[EXHIBIT[2]]> |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# // This particular file (I believe...) is (PROOF/EVIDENCE) that someone from...
# // _____________
# // |    CICADA | A collective of (HACKERS/BRAINIACS/GENIUSES/WIZARDS)... pretty sure they're not the bad guys.
# // |-----------|
# // | ANONYMOUS | A legion of smart bastards that are often highly misunderstood by people in SOCIETY
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯
# // Either way you look at it, smart bastards. 
# // They're basically CYBERCOMMANDOS... but, even more top notch than that.
# // THEY have been trying to GUAGE how I pick up on PATTERNS.

# ____________             
# | PATTERNS | are...
# ¯¯¯¯¯¯¯¯¯¯¯¯
#             _________________     ____________
# Things that | INVESTIGATORS | are | SUPPOSED | to pick up on when they're DOING their JOB.
#             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯     ¯¯¯¯¯¯¯¯¯¯¯¯                            ¯¯¯¯¯       ¯¯¯
# SUPPOSED to, being the key term. 
# Maybe I'm the ASSHOLE, for thinking they're SUPPOSED to do a god damn thing...
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
# ...maybe the investigators that I have personally met...
# ...maybe they don't see anything worth investigating.
# Now I'm REAL fucked, dude.

# Well, hold the phone there, Pretentious Pablo...

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 11) Scribbles [~] https://drive.google.com/drive/folders/1wukJYJanYKBfUX34WIhEeoamnsfuTDlg     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

# Copy/Paste (^ THAT) into browser Tab #4)
# In EACH of the pictures in that folder...?
# ...there's a LINE OF CHARACTERS that is being ALTERED a SLIGHT AMOUNT, it is virtually undetectable, unless
# you're INCREDIBLY OBSERVANT LIKE I AM. If you're NOT incredibly observant...? 
# You won't notice what the fuck is going on in EVERY FUCKING PICTURE IN THAT FOLDER.

# So, if you ARE incredibly observant...?
# Then- it appears as if someone who's a VERY SKILLED PROGRAMMER can COMMUNICATE WITH ME via these LINES OF TEXT...

# MAYBE, the (PERSON/PEOPLE) doing this...?
# They're a lot like me, and THEY get BORED because of how CONSISTENTLY they can CRUSH PEOPLE'S SOULS... 
# ...at being a good programmer.

# So, anybody who's up against them...?
# Might as well dig a hole.
# And just... crawl in it.
# Cause that's probably MORE PRODUCTIVE...
# ...than goin' up against these ASSASSIN GRADE PROGRAMMERS.

# I've even uploaded a thing called a VIDEO of these CYBERCOMMANDOS using this CENTRAL INTELLIGENCE AGENCY exploit,
# called "SCRIBBLES". Then again, maybe it isn't SCRIBBLES, it's a WAY BETTER VERSION of SCRIBBLES.
# And the fact that I would even call it SCRIBBLES, probably pisses them off, cause they're trying to say...
# "Nah dude, it's WAY cooler than SCRIBBLES..." I don't know.

# Anyway, if you've never heard of the word "VIDEO"...?

# WELL... it's a FILE that you can access by entering a fucking link into a web browser.
# It's like going to YouTube to watch COOL videos that get millions of views...?
# But- instead of the videos being COOL...? 
# They're just EVIDENCE that's right in your friggen face, dude...

# EVIDENCE that just so happens to be a MOTION PICTURE that shows up on the DISPLAY of that device.
# Almost like going to YouTube, and then just, typing in a URL.
# Well...
# That is what it is, actually. 
# No "almost", that is literally... 
# ...what that is.

# This is stuff that SOME PEOPLE GET PAID A LOT OF MONEY TO: 
# ____________________________________________________________
# | 1) ORGANIZE | 2) SHOWCASE | 3) BUILD for a CASE/TRIAL... |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# But- only if you're COOL.
# If you're NOT cool...?
# Then it's just useless garbage that the police will avoid at all costs.
# Cause they've got WAY COOLER shit to do, man.

# Even the lawyers, they'll see this shit, and just...
# ...some of em might just start running, or say "I'VE GOT WAY COOLER SHIT TO DO BRO, BYE."
# ...and then they're gone.

# Typically if you're COOL enough, THEN...
# ...this type of shit can even land people in PRISON after it is brought into a COURTROOM.

# But, ONLY if you're COOL enough.
# Otherwise, you're just a lame son of a bitch like me...

# https://www.youtube.com/watch?v=e4VnZObiez8
# (^ What EVIDENCE looks like)

# ____________             
# | PATTERNS | are...
# ¯¯¯¯¯¯¯¯¯¯¯¯
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
# Not at *ANY* police (station/building) from what I currently understand.
# They might be somewhere...? But I don't know where they are.
# Cause if I knew...?
# I would show them this shit right here, dude. All day long.
# And, my book.
# And, pictures.
# And, videos.
# And, audio logs.
# Sometimes even the documents I write that talk about audio logs and pictures.
# Sometimes, videos that JUST SO HAPPEN to be audio logs but with a moving picture.
# Probably sounds like a no brainer, doesn't it...?
# <sigh>
# Nah, apparently you need someone who's got an IQ of 250, to make sense of any of this shit I have on hand.
# No less than that, either.
# Otherwise...?
# Guys like NYSP TROOPER (RUFFAS/MESSINES/BOSCO/DERUSSO) are gonna shake their heads, say "That's too complicated, buddy...", and then walk away.

# Guys like NYSP TROOPER RUFFAS have innocent people to SHOOT, KILL, FRAME, and then LIE about it. 
# Especially when they have to EXPLAIN WHY the INNOCENT PEOPLE they had to shoot, were such GUILTY BASTARDS.
# That's what LAW AVOIDANCE OFFICERS like NYSP TROOPER (RUFFAS/MESSINES/BOSCO/DERUSSO) do. 
# They're big fans of the DEREK CHAUVIN 101 playbook.

# Anyway...
# _________________
# | INVESTIGATORS |... they're not supposed to do what NYSP TROOPER RUFFAS does.
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# You can show them EVIDENCE and CLUES...?
# But they will probably arrest you for doing something that DANGEROUS.

# Yeah, showing people EVIDENCE...?
# It can cause some people to be violently killed by the police.
# Totally fuckin' serious about that, it probably sounds like I'm actually joking...
# ...however, I'm JOKING as well as being SERIOUS, SIMULTANEOUSLY. (<- this statement will CONFUSE people < 130 IQ.)

# In MOST cases, the police will take the EVIDENCE...?
# ...and then they throw it right in the trash. 
# It's all I've ever seen them do.

# Cause if they looked for EVIDENCE and CLUES...?
# Then TROOPER CARTER could've realized that instead of bringing me to the hospital in DECEMBER 2020...?
# He could've like, LOOKED at the fucking PHOTOS I HAD IN MY HAND, and even my APPLE IPHONE 8+~!

# But- (un)surprisingly...?
# Guys like him don't like being (told/shown)
# ___________________________________________________
# | 1) LEADS | 2) CLUES | 3) EVIDENCE | 4) PATTERNS |
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# I mean, theoretically, if you meet someone that DOES take these (4) things into consideration...?
# They're gonna be WICKED smart, dude. I mean, really.
# They're gonna have an IQ of at LEAST 275.
# Maybe even 300.

# But, lets just entertain this FANTASY of mine, that POLICE will actually look at any of this evidence...
# ...instead of ignoring it as usual like most people do.

# Well, they could see that SOMEBODY who APPEARS to have the behavior of smoking some fuckin' bath salts...?
# They came up with a brilliant (plan/way) to EXTRACT the data from the PDF file I received from SCSO RECORDS.
# The 1st exhibit above that I submitted waaaaaaaaay back on SEPTEMBER 04, 2020. 

# When I say smoking some fuckin' bath salts...?
# That's how ADVANCED MATHEMATICS and CALCULUS LOOKS, sometimes.
# No bath salts are actually making an appearance, I'm afraid.

# Appearances can be deceiving, because there's a PATTERN in the $CONTENT up above...

# Look. I don't know if it's a BAD guy, or a GOOD guy... but the FEELING that I got when I FIRST saw it, 
# was NOT good. Nah. Felt like somebody wants to kill me again. It felt like I got a surprise vacation 
# package, (See skit: "You won a vacation, dude.")

# Whoever gave me this copy of the file...?
# Well, it might not even be a GUY.
# Might be a GIRL.
# So it's either a GIRL, or GUY... Who the hell knows...?
# They're basically a genius.

# Time to EXPLAIN to people WHY the police actually WORK REALLY HARD to IGNORE this fuckin situation
# It's because they're all COMMITTING ILLEGAL ACTIVITIES IN CONJUNCTION TO PREVENT THIS CASE FROM PROCEEDING.
# Because if they ALL shut their fucking mouths, they can actually KILL people, and it's LEGAL.

# But- that's because they're FUCKING MORONS who decided to TRY and KILL the WRONG MOTHERFUCKER.
# And now they're gonna fuckin' pay for it.

# // |=======================================================================================================|
# // | The MURDER ATTEMPT (SCSO-2020-028501)
# // |=======================================================================================================|
# // | Index     : 0
# // | Incident  : SCSO-2020-028501
# // | Reference : https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA
# // | Date      : 05/26/20 0130
# // |             __________________________________  
# // | Time      : | 05/25/20 2315 -> 05/26/20 0155 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Duration  : 2h 40m
# // |             ___________________________________________________________________
# // | Party     : | FBI  | 25-30yo white male #1 (DEFINITELY)                       |
# // |             | FBI  | 25-30yo white male #2 (DEFINITELY)                       |
# // |             | SCSO | SCOTT SCHELLING       (DEFINITELY)                       |
# // |             | SCSO | JEFFREY KAPLAN        (not involved)                     |
# // |             | SCSO | JOSHUA WELCH          (not involved)                     |
# // |             | SCSO | MICHAEL ZURLO         (SUSPECTED)                        |
# // |             | SCSO | JAMES LEONARD         (SUSPECTED)                        |
# // |             | NYSP | ROBERT MESSINES SR.   (DEFINITELY)                       |
# // |             | NYS  | ERIC CATRICALA        (DEFINITELY)                       |
# // |             | ---- | ZACKARY KAREL         (SUSPECTED)                        |
# // |             | FBI  | CHRISTOPHER MURPHY    (SUSPECTED)                        |
# // |             | KGB  | PAVEL ZAICHENKO       (SUSPECTED)                        |
# // |             | CPSB | TERRI COOK            (SUSPECTED)                        |
# // |             | FBI  | RYAN WARD             (SUSPECTED)                        |
# // |             | NYS  | ANDREW CUOMO          (SUSPECTED)                        |
# // |             | NYS  | HILLARY R. CLINTON    (SUSPECTED)                        |
# // |             | FB   | MARK ZUCKERBERG       (SUSPECTED)                        |
# // |             | Shen | TATIANA CLEVELAND   (FAIRLY CERTAIN she's NOT involved)  |
# // |             | ???? | Could even be Ronald McFuckin'Donald, who the hell knows |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ________________________________________________________________________________
# // | Address   : | FROM | CATRICALA FUNERAL HOME            | COMPUTER ANSWERS                  |
# // |             |      | 1597 US-9, Clifton Park, NY 12065 | 1602 US-9, Clifton Park, NY 12065 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ________________________________________________________________________________
# // |             | TO   | ZACKARY KARELS "RESIDENCE"        | ZAPPONE DEALERSHIP                |
# // |             |      | 1769 US-9, Clifton Park, NY 12065 | 1780 US-9, Clifton Park, NY 12065 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Narrative : Any assortment of the above listed parties were involved in a PREMEDITATED MURDER ATTEMPT.
# // |             The police are fucking morons. They have a hard time making a CORRELATION to:
# // |             CVE-2019-8936, RANSOMWARE, DDOS ATTACKS, CYBER ATTACKS, RUSSIANS, IDENTITY THEFT,
# // |             CYBERCRIMINALS, and COMPUTER ANSWERS... together, as (1) thing that RUSSIANS do.
# // |            
# // |             I was INCREDIBLY SUSPICIOUS of PAVEL ZAICHENKO after 01/15/2019 when an ADVANCED CYBERATTACK 
# // |             was waged against the COMPUTER ANSWERS NETWORK that I was MANAGING between:
# // |             OCTOBER 2018 -> JANUARY 2019 under MY COMPANY, SECURE DIGITS PLUS LLC.
# // |              
# // |             2x queers about 25-30 years old, white males, VERY gay looking, wearing hats, backpacks,
# // |             glasses, neon lights in their mesh-like backpacks... spent about 90 minutes AGGRESSIVELY 
# // |             following me, starting from 1597/1602 US-9, to the ALDI/Hoffman Car Wash intersection.
# // | 
# // |             I actually attempted to contact 911 EMERGENCY SERVICES TWICE, with my "smartphone" that was
# // |             "hacked" with a "dangerous fucking program" that I now understand was called "PEGASUS/PHANTOM".
# // |             
# // |             The FIRST time I DIALED 911 EMERGENCY SERVICES, was near CLIFTON PARK EYE CARE, at 0004.
# // |             The SECOND time I DIALED 911 EMERGENCY SERVICES, was DIRECTLY IN FRONT OF THE CAMERA AT:
# // |             CENTER FOR SECURITY, at 0009.
# // |             I actually have a SCREENSHOT from my DEVICE that SHOWS THE TIMESTAMPS OF THOSE 911 calls.
# // | 
# // |             There is no mistaking what they were looking to do, they were attempting to murder me.
# // |             I recorded a video that I showed to NYSP Trooper Shaemus Leavey, and I ALSO took (3) 
# // |             pictures from a fair distance away, near SPARE TIME BOWLING ALLEY.
# // |
# // |             They followed me into the LOWES HOME IMPROVEMENT STORE PARKING LOT, where they had a 
# // |             CAR parked AHEAD OF TIME, indicating that the MURDER ATTEMPT was PREMEDITATED and PLANNED.
# // |
# // |             I was able to lose sight of these guys UNTIL I walked out onto Route 146, where they turned
# // |             LEFT out of the LOWES PARKING LOT, headed WEST on 146 (toward BURGER KING/KEY BANK), and 
# // |             attempted to STRIKE ME AGAIN with their VEHICLE. The FIRST TIME that they attempted to strike
# // |             me with their vehicle, was at APPROXIMATELY 2315, DURING an AUDIO RECORDING THAT I WAS RECORDING...
# // |             ...which, believe it or not is a KEY PIECE OF EVIDENCE.
# // |             
# // |             I had UPLOADED THAT AUDIO RECORDING EARLIER AT COMPUTER ANSWERS around 2329, because I had ACCESS 
# // |             to the NETWORK, since I used to "WORK" there, and I had actually CONFIGURED THAT ACCESS POINT IN MAY 2018. 
# // |             When I say "WORK", what I really mean is, MANAGING THAT FUCKING COMPANY MORE THAN THE 1) OWNER, and 
# // |             2) VICE PRESIDENT. That's what I call "WORK".
# // |             
# // |             The ACCESS POINT was actually a CISCO AIRONET 1140 series that I LITERALLY PURCHASED FROM AN NFRASTRUCTURE EMPLOYEE.
# // |
# // |             In reference to the 2 GUYS THAT TRIED TO KILL ME FOR LIKE 90 minutes...
# // |             They failed to strike me with their vehicle between AUTOZONE and ADVANCE AUTO PARTS on ROUTE 146,
# // |             and I attempted to get the LICENSE PLATE or the MAKE/MODEL of the VEHICLE, but couldn't remember it.
# // |             They turned RIGHT onto US-9 toward ZACKARY KARELS RESIDENCE.
# // |
# // |             I started trying to FLAG PEOPLE DOWN for HELP, not JUMPING IN FRONT OF VEHICLES.
# // |             I saw ROBERT MESSINES SR. DRIVING HIS BLACK SUV NEAR ZACKARY KARELS RESIDENCE.
# // |             I then thought to CUT THE PHONE LINE AT 1769 ROUTE 9, because the GUYS that TRIED TO KILL ME were either
# // |             IN THAT HOUSE, or... SCSO just IGNORED the fact that I CUT THAT PHONE LINE at 130AM. NOT 545AM. 130AM.
# // |
# // |             At which point, I then MOVED THE EMBROIDERY SHOP SIGN ACROSS THE STREET ONTO THE POLE WHERE MATCHLESS STOVE
# // |             AND CHIMNEY is SUPPOSED to have a MAILBOX... but- even though I took a PICTURE of that EARLIER that night...
# // |             IMG_0633.HEIC at about 05/25/20 2213...? 
# // |             The police haven't collected that as EVIDENCE of SUSPICIOUS ACTIVITY or anything.
# // |
# // |             Then, the POLICE have been pretending for *checks watch* (2+) years, that I was being DELUSIONAL, but that was 
# // |             BEFORE they COLLECTED EVIDENCE.
# // |             So, it just looks like the police are really fucking lazy, and they don't do "work" at all.
# // |             
# // |             However, the REAL REASON why they just APPEAR to be really fucking lazy, is because I have
# // |             come to the CONCLUSION, that they were PISSED about the (8) videos, multiple pictures, 
# // |             audio logs, Facebook posts, and what a general, all-around annoyance I've been, telling
# // |             them just how fucking terrible they are collectively, at ENFORCING THE FUCKING LAW.
# // |             
# // |             SOME of those parties were NOT INVOLVED and that is EXPLICITLY SPECIFIED, however they
# // |             are STILL SUSPECTS That means ANYONE in that box MAY be marked incorrectly, AND,
# // |             there may be MISSING PEOPLE that are supposed to be in that box.
# // |             _______________________________________________________________________________________________________________________
# // | Exhibit   : | Top Deck Awareness - Not News | Chapter 4 - The Week, but also listed BELOW                            |
# // |             |=====================================================================================================================|
# // |             | Type = A: Audio | C: Conversation | D: Document/Record | Q: Queers (and/or) cyberattack | P: Picture | V: Video     |
# // |             |=====================================================================================================================|
# // |             | Index Type       Name        Date   Time   Focus                (URL/Uniform Resource Locator)                      |
# // |             |---/----|-----------|------------\------\-----|--------------------\-------------|------------/----------------------|
# // |             | 0000 | D |  785-3221 Jesse | 07/21/89 0000 | 0 | https://drive.google.com/file/d/1y05kPm-CjVIALi6r8CNPMlIRnXvMtPpD
# // |             | 0001 | V |  Spectrum Reset | 08/31/17 1800 | 0 | https://youtu.be/LfZW-s0BMow 
# // |             | 0002 | P |  VACANT 203D 01 | 08/31/17 1900 | 0 | https://drive.google.com/file/d/0B8sPah8VzEDwZWVNWGN3QnRncVE 
# // |             | 0003 | P |  VACANT 203D 02 | 08/31/17 1900 | 0 | https://drive.google.com/file/d/0B8sPah8VzEDwdkNMYVljeXBIY2M 
# // |             | 0004 | V | Audi A4 Quattro | 01/16/18 2100 | 0 | https://youtu.be/pi1DIQWuce8 
# // |             | 0005 | Q |   TANSKI/GGI #1 | 01/31/18 0000 | 0 | https://www.timesunion.com/news/article/Tanski-named-as-co-conspirator-as-former-12541203.php 
# // |             | 0006 | V |   iP 7+/iFixUrI | 04/13/18 0000 | 0 | https://youtu.be/i3qn1CZ-5WM 
# // |             | 0007 | V |  DEGIORALMO/GGI | 05/17/18 1400 | 0 | https://youtu.be/TKDHzHiO1k4 
# // |             | 0008 | C |  TOMMY COOK/KEY | 12/18/18 0000 | 0 | Ask my cousin TOMMY COOK if he remembers the CONVO I RECORDED+EMAILED HIM 
# // |             | 0009 | V |  CentOS 7 Setup | 12/19/18 0000 | 0 | https://youtu.be/iOKOkJJ1ZbQ 
# // |             | 0010 | V |    OPNsense.cfg | 12/20/18 1108 | 0 | https://youtu.be/eD0-VQ2y_yg 
# // |             | 0011 | Q | CVE-2019-8936/1 | 01/15/19 0300 | 0 | (← PAVEL ZAICHENKO + APT29) 
# // |             | 0012 | V |  CA/MDT Clifton | 01/25/19 0825 | 0 | https://youtu.be/5Cyp3pqIMRs 
# // |             | 0013 | V |  CA/MDT Vermont | 03/01/19 2000 | 0 | https://youtu.be/RypW9xbClJo 
# // |             | 0014 | Q | CVE-2019-8936/2 | 03/08/19 0600 | 0 | (← PAVEL ZAICHENKO + APT29) 
# // |             | 0015 | V |      NFRAS_RICO | 03/08/19 0913 | 0 | https://youtu.be/vmDVKwTF2Zc 
# // |             | 0016 | V | GodMode Cursor1 | 07/14/19 1500 | 0 | https://youtu.be/1OzgCoBUDzs 
# // |             | 0017 | V |  HDMI Interfere | 10/04/19 1200 | 0 | https://youtu.be/in7IrkoLOHo 
# // |             | 0018 | V |   $300M Lawsuit | 10/04/19 1500 | 0 | https://youtu.be/YDWm-f7WEWs 
# // |             | 0019 | V |    TWITTER BSOD | 12/09/19 1600 | 0 | https://youtu.be/12x8TrO9B5Q 
# // |             | 0020 | V |    Buffer Ove.. | 10/04/19 1200 | 0 | https://youtu.be/H4MlJnMh9Q0 
# // |             | 0021 | V |   2019-10-21... | 10/21/19 1144 | 0 | https://youtu.be/zs0C_ig-4CQ 
# // |             | 0022 | V | GodMode Cursor2 | 01/22/20 2000 | 0 | https://youtu.be/1PuBnnyuoKw 
# // |             | 0023 | V |      2020 01 29 | 01/29/20 2300 | 0 | https://youtu.be/Mqjnrg1uq3A 
# // |             | 0024 | Q |   TANSKI/GGI #2 | 01/30/20 0000 | 0 | https://www.timesunion.com/news/article/Tanski-will-not-face-charges-as-business-partner-15016249.php 
# // |             | 0025 | P |        IMG_0352 | 05/19/20 0853 | 0 | https://drive.google.com/file/d/1CwjZnISueJRPXKuD-44G6s74AeFN8jqW 
# // |             | 0026 | P |        IMG_0353 | 05/19/20 0853 | 0 | https://drive.google.com/file/d/1zM3bf2VP_j3RzjvxrcX9Ax-nDykfGFd5 
# // |             | 0027 | P |        IMG_0354 | 05/19/20 0859 | 0 | https://drive.google.com/file/d/1DzL5Nw2HZUEoAj3z1L6eAogZe5YIEXRf 
# // |             | 0028 | P |        IMG_0355 | 05/19/20 0903 | 0 | https://drive.google.com/file/d/1vkFywPIlU4LPaMjd3wmiwAJHjdqqN5xx 
# // |             | 0029 | P |        IMG_0356 | 05/19/20 0907 | 0 | https://drive.google.com/file/d/1q1l1bXvxqZQvGjtK6kxKQoLXmnr5e6tj 
# // |             | 0030 | P |        IMG_0357 | 05/19/20 0908 | 0 | https://drive.google.com/file/d/19MiE3SAjFahgooXy7Iobd18vmYK9gA5- 
# // |             | 0031 | P |        IMG_0360 | 05/19/20 1035 | 0 | https://drive.google.com/file/d/1MzYGAsDvTKuQ2oWuJBzd0kppymtFXlaa 
# // |             | 0032 | P |        IMG_0361 | 05/19/20 1035 | 0 | https://drive.google.com/file/d/1_s5uK7tqEUak8iSJezERQM5njhQbzTfW 
# // |             | 0033 | P |        IMG_0362 | 05/19/20 1055 | 0 | https://drive.google.com/file/d/1bRnZWSk8JjwA8jvX-WP_VHB_sqGFuu5Z 
# // |             | 0034 | P |        IMG_0363 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/1u29vbEoFZAYQ5QfN2Q05bL1NzXAFljda 
# // |             | 0035 | P |        IMG_0364 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/1-z2gTDPSFuChBevH-pn9aBStK4h3-cmZ 
# // |             | 0036 | P |        IMG_0365 | 05/19/20 1056 | 0 | https://drive.google.com/file/d/13YA9h7EoCqV0YTe2dOtKX5mZKAPdLgVP 
# // |             | 0037 | P |        IMG_0366 | 05/19/20 1059 | 0 | https://drive.google.com/file/d/1SyNFeOBZiqxRh8uFJ_l6pdStqEZRzoLW 
# // |             | 0038 | P |        IMG_0367 | 05/19/20 1103 | 0 | https://drive.google.com/file/d/1l2MKEDRpHtf91F8JAzM0sjy8Ixmq-GCz 
# // |             | 0039 | P |        IMG_0368 | 05/19/20 1105 | 0 | https://drive.google.com/file/d/1LZXbcKCNXj6WVD5dvB_1CYzEOCMnqARl 
# // |             | 0040 | P |        IMG_0369 | 05/19/20 1105 | 0 | https://drive.google.com/file/d/1t_V6BoYO0qRukl03_4bzJJEF39N0UQNE 
# // |             | 0041 | P |        IMG_0370 | 05/19/20 1106 | 0 | https://drive.google.com/file/d/1pSD6_XUGoslaRqj8TbQtCsJie5xTpxq5 
# // |             | 0042 | P |        IMG_0371 | 05/19/20 1108 | 0 | https://drive.google.com/file/d/14MGHNPwyrIVumyKEZk_kMxPdA2B7qHKD 
# // |             | 0043 | P |        IMG_0372 | 05/19/20 1109 | 0 | https://drive.google.com/file/d/1AsVOl3RSGstfC_QGCP-uC7SfYD3ACD4b 
# // |             | 0044 | P |        IMG_0373 | 05/19/20 1110 | 0 | https://drive.google.com/file/d/1zHE9NnbprpQdCrXzMk4CAS0FusaA1ebW 
# // |             | 0045 | P |        IMG_0374 | 05/19/20 1111 | 0 | https://drive.google.com/file/d/1wrPF5gZZccU1vWl_HUD5HvtRU8sDSTK2 
# // |             | 0046 | P |        IMG_0375 | 05/19/20 1119 | 0 | https://drive.google.com/file/d/1ZsaEMlzXUFmUEjPj1dSNknVpZ7_spo5L 
# // |             | 0047 | P |        IMG_0376 | 05/19/20 1120 | 0 | https://drive.google.com/file/d/1bAosuht9bP-gfjWbG95scD8h3WrxPF0_ 
# // |             | 0048 | P |        IMG_0377 | 05/19/20 1122 | 0 | https://drive.google.com/file/d/1e3ihFjE522_wtcnyD9X6kV98XI6sf8D_ 
# // |             | 0049 | P |        IMG_0378 | 05/19/20 1122 | 0 | https://drive.google.com/file/d/1rFcbTnB3Z8IyHIwaUvatdSgfANhUK78b 
# // |             | 0050 | P |        IMG_0379 | 05/19/20 1123 | 0 | https://drive.google.com/file/d/1ntxzwl4nB-p2xCYsXLVfsLQ28de8wjdE 
# // |             | 0051 | A |  LIVE REDACTION | 05/19/20 1600 | 0 | https://drive.google.com/file/d/186dv0z0YLfafQT_tlJYYy9AhorERuSPw 
# // |             | 0052 | D |  SCSO-20-002998 | 05/19/20 2019 | 0 | <COOK_REQUEST> received from SCSO RECORDS on 9/8/2020 
# // |             | 0053 | A |       2020_0520 | 05/20/20 1200 | 0 | https://drive.google.com/file/d/1t66X3ZclCqHzV2nKhVPAdfGfwgl48PKi 
# // |             | 0054 | A |       2020_0521 | 05/21/20 1200 | 0 | https://drive.google.com/file/d/1hpscRhvr3g4YDDW6beTfeNIetZRvrTj_ 
# // |             | 0055 | V |        IMG_0381 | 05/21/20 1445 | 0 | https://drive.google.com/file/d/1x11cU6C3H_x9QwLGAyVgLxFfGYU1Duya 
# // |             | 0056 | V |        IMG_0382 | 05/21/20 1447 | 0 | https://drive.google.com/file/d/1JbAJRo8NHquH5YrcsDb-IatXwCX2FmCm 
# // |             | 0057 | V |        IMG_0383 | 05/21/20 1447 | 0 | https://drive.google.com/file/d/1DuGwSeOFIjVk3w4X7KclUUp-evq6GrUF 
# // |             | 0058 | V |        IMG_0384 | 05/21/20 1447 | 0 | https://drive.google.com/file/d/1HSHEEnPfGw9LqiVT0amoq7Bfv2Jlwr4o 
# // |             | 0059 | V |        IMG_0385 | 05/21/20 1448 | 0 | https://drive.google.com/file/d/1-OYxuc7HAVAL_gFt-Xq-A_lLpDL9dSLc 
# // |             | 0060 | P |        IMG_0389 | 05/21/20 2357 | 3 | https://drive.google.com/file/d/19NEdQugc_1mxV_tVS1KFhxebIrDcRAI0 
# // |             | 0061 | A |  Item[0]-Orig.. | 05/21/20 2359 | 0 | https://drive.google.com/file/d/1kl_zBSSEqGKk3ri3WKuiF9ISVZoyxErx 
# // |             | 0062 | A |  Item[0]-Treble | 05/21/20 2359 | 0 | https://drive.google.com/file/d/13NPoJyRENfdy7_kwMVCjfrJccoU3MxUU 
# // |             | 0063 | P |        IMG_0390 | 05/22/20 0139 | 0 | https://drive.google.com/file/d/143l422TZN7B1fghfAu3JJ_KjUBHhK9T6 
# // |             | 0064 | V | Item[1]IMG_0391 | 05/22/20 0139 | 0 | https://drive.google.com/file/d/1pb4q-KxHekqE8KjWABLEMxlaM2ORssuG 
# // |             | 0065 | V |  Item[1]-Treble | 05/22/20 0139 | 0 | https://drive.google.com/file/d/1NAjKoFyvfcs3Ap2n-K-fmYUo6WoBNrah 
# // |             | 0066 | D |  SCSO-20-027797 | 05/23/20 0100 | 0 | <COOK_REQUEST> received from SCSO RECORDS on 9/8/2020 
# // |             | 0067 | P |        IMG_0392 | 05/23/20 0121 | 0 | https://drive.google.com/file/d/1zhf0SMu_OkvtoGtA7htepib4DddDX-RE 
# // |             | 0068 | P |        IMG_0393 | 05/23/20 0128 | 0 | https://drive.google.com/file/d/1HGW-2UPIWDTuZIv9nPo3hys9kdZmUWMc 
# // |             | 0069 | P |        IMG_0394 | 05/23/20 0132 | 0 | https://drive.google.com/file/d/1fZRCFjw2bw6BGoWcmyaYvLkMAOLsJVb_ 
# // |             | 0070 | V |        IMG_0395 | 05/23/20 0133 | 0 | https://youtu.be/3twiZEsyQf0 
# // |             | 0071 | P |        IMG_0396 | 05/23/20 0141 | 0 | https://drive.google.com/file/d/1oHaFO_1ZSw8Gwx62Yyfla2yw6DB-VF4j 
# // |             | 0072 | A |  Item[2]-Orig.. | 05/23/20 0150 | 0 | https://drive.google.com/file/d/1QS6HETkJu-9nbnm84auzjOc8j8vAwSHG 
# // |             | 0073 | A |  Item[2]-Treble | 05/23/20 0150 | 0 | https://drive.google.com/file/d/1J6b5AiIt8p5vswuzLflpzslK4N3DFrC7 
# // |             | 0074 | V |        IMG_0397 | 05/23/20 0203 | 0 | https://youtu.be/V-_YqedKZb8 
# // |             | 0075 | P |        IMG_0398 | 05/23/20 0214 | 0 | https://drive.google.com/file/d/1gFH2Y5CZSWeTdqMkUD7S7TqZhgCoygtm 
# // |             | 0076 | P |        IMG_0399 | 05/23/20 0326 | 0 | https://drive.google.com/file/d/1jhrDsc_iyILUxs_zkqzJFhUOuQcNPvjz 
# // |             | 0077 | P |        IMG_0400 | 05/23/20 0326 | 0 | https://drive.google.com/file/d/16Cd437RbCWho7nITf6uxRMRH5KvXPUng 
# // |             | 0078 | P |        IMG_0401 | 05/23/20 0326 | 0 | https://drive.google.com/file/d/1lvON1Gqu-RFFbGQr6LcF13teNOBUC_mu 
# // |             | 0079 | P |        IMG_0402 | 05/23/20 1715 | 0 | https://drive.google.com/file/d/1zm1jZDyCq_TLmyllwu_S4r8hNcIqS0M4 
# // |             | 0080 | V |    Virtual Tour | 05/23/20 1200 | 0 | https://youtu.be/HT4p28bRhqc 
# // |             | 0081 | V |        IMG_0403 | 05/23/20 1717 | 0 | https://youtu.be/5guDmpaCyAM 
# // |             | 0082 | V |        IMG_0404 | 05/23/20 1734 | 0 | https://youtu.be/16dOquXbOrk 
# // |             | 0083 | V |        IMG_0405 | 05/23/20 1747 | 0 | https://youtu.be/g0ACtMIPrRo 
# // |             | 0084 | V |        IMG_0406 | 05/23/20 1755 | 0 | https://youtu.be/3rWdDtYC1Ac 
# // |             | 0085 | P |        IMG_0407 | 05/23/20 1808 | 0 | https://drive.google.com/file/d/1XdS2qBXYoEML4EbuZK_BDQkSU2VLlei_ 
# // |             | 0086 | P |        IMG_0408 | 05/23/20 1808 | 0 | https://drive.google.com/file/d/1T4ReQ5dfr5SQ3r6XGnE3al3eDF99plc5 
# // |             | 0087 | V |        IMG_0409 | 05/23/20 1808 | 0 | https://drive.google.com/file/d/1iZWZyXNJROfHaYCboY1CreK0VrWTMwsQ 
# // |             | 0088 | P |        IMG_0410 | 05/23/20 2015 | 0 | https://drive.google.com/file/d/17A8VrKhf6FoijaCqYz3ElKh7KXCtmAIe 
# // |             | 0089 | P |        IMG_0411 | 05/23/20 2015 | 0 | https://drive.google.com/file/d/1gYQRrg1bl7M2OyxcS4N65ttcF2L-x1PY 
# // |             | 0090 | V |        IMG_0412 | 05/23/20 2022 | 0 | https://drive.google.com/file/d/1Exs2UsfQ13CKS4BE2CZU8kvMNpqH0tld 
# // |             | 0091 | V |        IMG_0413 | 05/23/20 2040 | 0 | https://youtu.be/OZD6rBbDboA 
# // |             | 0092 | P |        IMG_0414 | 05/23/20 2109 | 1 | https://drive.google.com/file/d/1c7Ffv6EO0Jw9d1Jv-zYWNMmnoVrdI2-C 
# // |             | 0093 | P |        IMG_0415 | 05/23/20 2115 | 2 | https://drive.google.com/file/d/13W3kV7PQtq8QfoENrHeWIomwIdyNvFFc 
# // |             | 0094 | V |        IMG_0416 | 05/23/20 2118 | 0 | https://drive.google.com/file/d/1jJh0rG2KUtEhvqw-0FEoZ6lBXsnkyjBO 
# // |             | 0095 | P |        IMG_0418 | 05/23/20 2209 | 0 | https://drive.google.com/file/d/1o0EN-_zJ2NFMpIJ62TEXt_ZzhTpIcP-J 
# // |             | 0096 | P |        IMG_0419 | 05/23/20 2227 | 1 | https://drive.google.com/file/d/1ylXx3-_yqXO1aZgxs591WCkw97aGNXoJ 
# // |             | 0097 | P |        IMG_0420 | 05/23/20 2227 | 1 | https://drive.google.com/file/d/1aotzEtVIzOWZpHNGBGAiKMu4ptd83RUV 
# // |             | 0098 | P |        IMG_0421 | 05/23/20 2234 | 1 | https://drive.google.com/file/d/10EMq8WVC0i1JeBunE1kL6-gKe7wEB2Ah 
# // |             | 0099 | P |        IMG_0422 | 05/23/20 2246 | 1 | https://drive.google.com/file/d/1soT3MzZ0kZa_wmIj-EhXtiKL5zuAZ-hr 
# // |             | 0100 | P |        IMG_0423 | 05/23/20 2246 | 0 | https://drive.google.com/file/d/1k_X9QtxzjRZGVPVUHaA-gZLoPST5Bdmc 
# // |             | 0101 | P |        IMG_0424 | 05/23/20 2246 | 3 | https://drive.google.com/file/d/1GBjx1ErbzNXOxJo0Uqa8TZ1YnJbhZJVe 
# // |             | 0102 | P |        IMG_0425 | 05/23/20 2247 | 0 | https://drive.google.com/file/d/1o4a0TPY-FMDgRisNjd20VWvHv2sPVBVP 
# // |             | 0103 | P |        IMG_0426 | 05/23/20 2303 | 1 | https://drive.google.com/file/d/1JHKgCHT7kgT3cLiAJw1qbk2auIT5EZIt 
# // |             | 0104 | P |        IMG_0427 | 05/23/20 2304 | 1 | https://drive.google.com/file/d/1WFAOMoUl8H0e22r4Q2vo0hEc0JgxGBoz 
# // |             | 0105 | V |        IMG_0428 | 05/23/20 2314 | 0 | https://drive.google.com/file/d/1uyWjou_6Yadc-RKI3kIqvV7PtIJZekk5 
# // |             | 0106 | P |        IMG_0429 | 05/23/29 2314 | 2 | https://drive.google.com/file/d/1YlOSkwqNxHNOKHo-JKqKiCp-iaPYetqt 
# // |             | 0107 | V |        IMG_0430 | 05/23/20 2316 | 1 | https://youtu.be/7ZjLXsW-USc 
# // |             | 0108 | V |        IMG_0430 | 05/23/20 2316 | 1 | https://drive.google.com/file/d/1kuaybwEfIUYTd06wf76WRHIBZtdtphBV 
# // |             | 0109 | P |        IMG_0431 | 05/23/20 2320 | 2 | https://drive.google.com/file/d/1yfQd_p5XBCLVtt9Uoryac49BPopGvu3O 
# // |             | 0110 | V |        IMG_0432 | 05/23/20 2323 | 0 | https://drive.google.com/file/d/1K16SXHJhaFeive21taFWquLioLSEjc6i 
# // |             | 0111 | P |        IMG_0433 | 05/23/20 2325 | 0 | https://drive.google.com/file/d/1eU83YqoKOlgpqcPImmey3DuIljwaZmGi 
# // |             | 0112 | P |        IMG_0434 | 05/23/20 2325 | 0 | https://drive.google.com/file/d/1rNCcFKCxH2QVdaW3moQbtYYFTCFGVzpd 
# // |             | 0113 | P |        IMG_0435 | 05/23/20 2328 | 0 | https://drive.google.com/file/d/17qBZGnwK3TEQUNHlExOzBnSA9Me_Atqf 
# // |             | 0114 | P |        IMG_0436 | 05/23/20 2329 | 0 | https://drive.google.com/file/d/17DDVj9j29oa0HMMEc_DXZv1kYNu2wfzy 
# // |             | 0115 | P |        IMG_0437 | 05/23/20 2332 | 0 | https://drive.google.com/file/d/1f_bCTTUwcncWfVWFI4GgeoDAkmVwx-eX 
# // |             | 0116 | P |        IMG_0438 | 05/23/20 2332 | 0 | https://drive.google.com/file/d/1IIr21Z94r9YNMhciVKr47jlwqrXETPk8 
# // |             | 0117 | P |        IMG_0439 | 05/23/20 2333 | 0 | https://drive.google.com/file/d/19SeWplJxmZ8X0t1lkKxIqTHzXAeOBTem 
# // |             | 0118 | P |        IMG_0440 | 05/23/20 2339 | 0 | https://drive.google.com/file/d/1OXsTi4B0fwproUMHJYEnGGav0toGGyAY 
# // |             | 0119 | P |        IMG_0441 | 05/23/20 2339 | 0 | https://drive.google.com/file/d/1mfVdLqrSMN1bpCyFtK4Iu9wPnBAEmVYs 
# // |             | 0120 | P |        IMG_0442 | 05/23/20 2339 | 0 | https://drive.google.com/file/d/1rmRrmNMu0-FJuuP1Xc0K6aCMYop5N5Vq 
# // |             | 0121 | P |        IMG_0443 | 05/23/20 2357 | 0 | https://drive.google.com/file/d/1d4U_CbDqZCQYDaFKsVDhnah2sk7GTVET 
# // |             | 0122 | P |        IMG_0444 | 05/23/20 2357 | 0 | https://drive.google.com/file/d/18yhgrBqZMNpmtrwU1xs9g-FosXJcbUa1 
# // |             | 0123 | P |        IMG_0445 | 05/23/20 2357 | 2 | https://drive.google.com/file/d/1mLIfSI1htx_jts6gOomS5aos70nmqbcF 
# // |             | 0124 | P |        IMG_0446 | 05/23/20 2357 | 0 | https://drive.google.com/file/d/1hZqArWA8Juvw1WySSD1J5gfx9xGALq9Z 
# // |             | 0125 | P |        IMG_0447 | 05/23/20 2359 | 0 | https://drive.google.com/file/d/1R-6g3k3ZIaIM6pvoJPFmCDdKy6N2cpAD 
# // |             | 0126 | P |        IMG_0448 | 05/23/20 2359 | 0 | https://drive.google.com/file/d/1ob_d2qtZi5hyo7ROD3CuAh7ehejFKsy3 
# // |             | 0127 | P |        IMG_0449 | 05/23/20 2359 | 0 | https://drive.google.com/file/d/1CzPZ5M59yWuwguyYVVu921CHFDHA1c3y 
# // |             | 0128 | P |        IMG_0453 | 05/23/20 2359 | 3 | https://drive.google.com/file/d/1W6gJhjCKDtbuq9lTnQPzJZereAnga3zT 
# // |             | 0129 | P |        IMG_0455 | 05/24/20 0000 | 1 | https://drive.google.com/file/d/1Tu5ft89sJ_tR6RayQ79bSOk7F_QxsbOK 
# // |             | 0130 | P |        IMG_0456 | 05/24/20 0001 | 0 | https://drive.google.com/file/d/12VV2ObukK_3DXED23Nsi1GxMbzkm9aLN 
# // |             | 0131 | P |        IMG_0457 | 05/24/20 0002 | 0 | https://drive.google.com/file/d/1EabOp3qnFkaRR_GYmStsJUkbugud1zom 
# // |             | 0132 | P |        IMG_0458 | 05/24/20 0003 | 0 | https://drive.google.com/file/d/115TRiUsJS55zya6qyVv1ZaQZ3lVUpGkh 
# // |             | 0133 | P |        IMG_0459 | 05/24/20 0003 | 0 | https://drive.google.com/file/d/1kWVkx2wsxyQOxihEI-oHTwVEQbKFcVnW 
# // |             | 0134 | P |        IMG_0460 | 05/24/20 0004 | 1 | https://drive.google.com/file/d/1d0sTQLvJSuobxgKw5j4FVVDnhBqxXdzo 
# // |             | 0135 | P |        IMG_0461 | 05/24/20 0005 | 0 | https://drive.google.com/file/d/14LiGWkW4hTZvk6JfkfFyPZyIhxGEBK-_ 
# // |             | 0136 | V | 2020 05 24 1341 | 05/24/20 1341 | 0 | https://youtu.be/i88AJb_5zY4 
# // |             | 0137 | P |        IMG_0468 | 05/24/20 1759 | 0 | https://drive.google.com/file/d/1fNYPWpuJgyVfLsZd3Ha_0GfaPGWimvYc 
# // |             | 0138 | P |        IMG_0469 | 05/24/20 1800 | 0 | https://drive.google.com/file/d/1vgeZIIVmzBiJIOzXWfrb45qnmV_WQAwI 
# // |             | 0139 | P |        IMG_0470 | 05/24/20 1801 | 0 | https://drive.google.com/file/d/1R7VNKSRzuKM-tIJwzdo7td2h6ev74j0K 
# // |             | 0140 | P |        IMG_0471 | 05/24/20 1801 | 0 | https://drive.google.com/file/d/1KLSxinDnryuHw9sgwLJtPa87A0BW2Se5 
# // |             | 0141 | P |        IMG_0472 | 05/24/20 1802 | 0 | https://drive.google.com/file/d/1yjmMBTRHoC5wSRMWWrDDmGbGgkkyUx7A 
# // |             | 0142 | P |        IMG_0473 | 05/24/20 1803 | 0 | https://drive.google.com/file/d/1Dwrvg_lk-uYfLVRALKGiLo756SMgwWE- 
# // |             | 0143 | P |        IMG_0477 | 05/24/20 1810 | 0 | https://drive.google.com/file/d/1ex0klAW_MeYpdd5Q1trtVcLJFp2tlTUx 
# // |             | 0144 | P |        IMG_0493 | 05/24/20 1849 | 0 | https://drive.google.com/file/d/1r_LYeBOis15QpVtW5WQFEB7IRoMjPgGr 
# // |             | 0145 | P |        IMG_0495 | 05/24/20 1850 | 0 | https://drive.google.com/file/d/1AZcx41RWlG7nDg9EcEfYxpasPiUny3eL 
# // |             | 0146 | P |        IMG_0496 | 05/24/20 1853 | 0 | https://drive.google.com/file/d/1bi8tB-eidAFVxbhdVpvyI-9OESmPhk0o 
# // |             | 0147 | P |        IMG_0497 | 05/24/20 1854 | 0 | https://drive.google.com/file/d/1cUV8oy8TIciNC4mLYnAKsjHVd8KtHly_ 
# // |             | 0148 | P |        IMG_0498 | 05/24/20 1854 | 0 | https://drive.google.com/file/d/1paLMRKq5YmDHt2ClWUgzXeEtpbJWpFEm 
# // |             | 0149 | P |        IMG_0499 | 05/24/20 1904 | 0 | https://drive.google.com/file/d/13cG66dGN3M9kcdBex4yo7Nca5-tPFgLH 
# // |             | 0150 | P |        IMG_0500 | 05/24/20 1904 | 0 | https://drive.google.com/file/d/1f6NM20A3PfRtb54wOQrU3Vq5wM_LGz14 
# // |             | 0151 | P |        IMG_0501 | 05/24/20 1907 | 0 | https://drive.google.com/file/d/1QIhQQa_Zq-lrR5qdtlfxJqkj9j9TErYy 
# // |             | 0152 | P |        IMG_0502 | 05/24/20 1907 | 0 | https://drive.google.com/file/d/1W8A-OEX3fJn6J253TPhvd_Ps8A5w_pIT 
# // |             | 0153 | P |        IMG_0503 | 05/24/20 1907 | 0 | https://drive.google.com/file/d/1yDZ4O_YK8UXc-prEGVNE_4o4pWweG6_z 
# // |             | 0154 | P |        IMG_0504 | 05/24/20 1907 | 0 | https://drive.google.com/file/d/1Ds8pxZOpGYbkxmyAPxAw7aA-N1ngw3pe 
# // |             | 0155 | P |        IMG_0505 | 05/24/20 1910 | 0 | https://drive.google.com/file/d/1agONCE8WPnlM_MLc9hEEinygOxHdPdKJ 
# // |             | 0156 | P |        IMG_0506 | 05/24/20 1910 | 0 | https://drive.google.com/file/d/1tazuzEVemWTZTRJmjyF-_s_-w_Afj4SU 
# // |             | 0157 | P |        IMG_0508 | 05/24/20 1925 | 0 | https://drive.google.com/file/d/1CywfAKtQQy7wm_6kBE442dk8wlN0GcCF 
# // |             | 0158 | P |        IMG_0512 | 05/24/20 1952 | 0 | https://drive.google.com/file/d/1ow1cCPgUDENOvW16afXsxXzkQyJTZOQr 
# // |             | 0159 | P |        IMG_0513 | 05/24/20 1952 | 0 | https://drive.google.com/file/d/1M73qUy8w7HXqL0cdIGl7_WLdDJPmOHiS 
# // |             | 0160 | P |        IMG_0525 | 05/24/20 2049 | 0 | https://drive.google.com/file/d/1Ymm3YpKgYlSMs58B6z-2HeqYmQXYIVgt 
# // |             | 0161 | P |        IMG_0537 | 05/24/20 2049 | 1 | https://drive.google.com/file/d/1_cWYuUbVfw-7TYH6sQAwfv_rpP5Mp1QY 
# // |             | 0162 | P |        IMG_0538 | 05/24/20 2050 | 2 | https://drive.google.com/file/d/1E9hqXeb8RbyJKYgI94KtiGB79_fY5_03 
# // |             | 0163 | P |        IMG_0539 | 05/24/20 2050 | 1 | https://drive.google.com/file/d/1rmjA0c5duSUDkk5K8CNc7Wt3GQr7u4hG 
# // |             | 0164 | P |        IMG_0540 | 05/24/20 2050 | 0 | https://drive.google.com/file/d/1sxauHH3gInbUg2s-gueRANRhHtVih6WD 
# // |             | 0165 | P |        IMG_0541 | 05/24/20 2052 | 0 | https://drive.google.com/file/d/1J6hPh8i_8ko7A0Eqb8m8u8rb15gzveCj 
# // |             | 0166 | P |        IMG_0542 | 05/24/20 2052 | 1 | https://drive.google.com/file/d/1gxtf0rjhwnwyHVUnEmi3Xgg7ACkRGFEP 
# // |             | 0167 | P |        IMG_0543 | 05/24/20 2055 | 1 | https://drive.google.com/file/d/10mahQTnFZ4Yq3gysEVGjrajuELEXiSXu 
# // |             | 0168 | P |        IMG_0544 | 05/24/20 2055 | 1 | https://drive.google.com/file/d/1t8g1PuC2TZ0dJv2-cjWal9sHfgR1ut5f 
# // |             | 0169 | P |        IMG_0546 | 05/24/20 2149 | 0 | https://drive.google.com/file/d/1Kzn8IPwaaP1aHUL2yv4BmsMStyNWLpNX 
# // |             | 0170 | P |        IMG_0549 | 05/24/20 2159 | 3 | https://drive.google.com/file/d/1VvOtkA8bT2Un20kWQA5xbp5P7F1n1i9E 
# // |             | 0171 | P |        IMG_0550 | 05/24/20 2159 | 0 | https://drive.google.com/file/d/1MlrZx1HlqygJV2oh9VPz7n-OR7DBpl1H 
# // |             | 0172 | P |        IMG_0551 | 05/24/20 2159 | 0 | https://drive.google.com/file/d/1v-AYHZAaUn2wKboy_ShX5wBIfpTZc4fL 
# // |             | 0173 | P |        IMG_0552 | 05/24/20 2159 | 3 | https://drive.google.com/file/d/1zNC_LckOws3yXsJThY4ZrdW1o1jgBmJX 
# // |             | 0174 | P |        IMG_0553 | 05/24/20 2159 | 3 | https://drive.google.com/file/d/1OYLrWTKvkISFaCMENCpXh7TBqQ5HqTae 
# // |             | 0175 | P |        IMG_0554 | 05/24/20 2159 | 1 | https://drive.google.com/file/d/1WJ-7AfxRYOhhJ96ebnl5jwVXjpCX5pWg 
# // |             | 0176 | P |        IMG_0555 | 05/24/20 2200 | 0 | https://drive.google.com/file/d/127CAZ15c51ei5MSegvnPM0HuUSABFfNq 
# // |             | 0177 | P |        IMG_0556 | 05/24/20 2200 | 0 | https://drive.google.com/file/d/1ivlJB0sh9Yh0YMn9GgV_-XWTg-2dJNel 
# // |             | 0178 | P |        IMG_0557 | 05/24/20 2200 | 1 | https://drive.google.com/file/d/1iEbmL6pUM6qKvEIIVERJX0MFwsLOpozi 
# // |             | 0179 | P |        IMG_0558 | 05/24/20 2200 | 0 | https://drive.google.com/file/d/1_lTBCXldsNe4kN92mlvTveSpIOlqQqo_ 
# // |             | 0180 | P |        IMG_0560 | 05/24/20 2200 | 1 | https://drive.google.com/file/d/1GIyTQ8xyWUSZfzfuFl5Y7NgfR7TgQdno 
# // |             | 0181 | P |        IMG_0564 | 05/24/20 2200 | 3 | https://drive.google.com/file/d/1ZoOpMLbj19tsPDj3RwVRsdtkaWT_WomD 
# // |             | 0182 | P |        IMG_0565 | 05/24/20 2201 | 1 | https://drive.google.com/file/d/1gx9F_QPd2uzU5UPqCYife46AHgyAYDHV 
# // |             | 0183 | P |        IMG_0566 | 05/24/20 2201 | 0 | https://drive.google.com/file/d/1zFvWcgV3ojqsohWjDiQBdj0myvw6JDpQ 
# // |             | 0184 | P |        IMG_0567 | 05/24/20 2201 | 0 | https://drive.google.com/file/d/1qjj5mCE_bG9PLauJNJTAPfVPmigUcKb3 
# // |             | 0185 | P |        IMG_0585 | 05/24/20 2239 | 0 | https://drive.google.com/file/d/1y4f8SmcgZf_vJ8ohXVSFFWQlC19QEDZe 
# // |             | 0186 | P |        IMG_0590 | 05/24/20 2242 | 0 | https://drive.google.com/file/d/1_QUY6XrDIBIJJvjaYw02B-1OdEOXm5zk 
# // |             | 0187 | P |        IMG_0591 | 05/24/20 2243 | 3 | https://drive.google.com/file/d/1BrGQnWB2xPNudtUdItlJm29PqQMVltGh 
# // |             | 0188 | P |        IMG_0594 | 05/24/20 2248 | 1 | https://drive.google.com/file/d/10r3SnCMggf2BRmlST4fdX5f104mwNxau 
# // |             | 0189 | P |        IMG_0595 | 05/24/20 2249 | 1 | https://drive.google.com/file/d/1BnoTT0-IHk0TNvIDIYPj_H4q6fk4EkF7 
# // |             | 0190 | P |        IMG_0596 | 05/24/20 2249 | 1 | https://drive.google.com/file/d/1aZFTnKVwQXakRMHbCt9WIpKxpJUV2Q8G 
# // |             | 0191 | P |        IMG_0597 | 05/24/20 2249 | 0 | https://drive.google.com/file/d/11GDlXvkiMVnt4iu8zqhzphbEjogAkvqY 
# // |             | 0192 | P |        IMG_0598 | 05/24/20 2249 | 0 | https://drive.google.com/file/d/1eaT4t3viNY_j02BMbV_TxJJ-e2zCPtjq 
# // |             | 0193 | P |        IMG_0599 | 05/24/20 2250 | 0 | https://drive.google.com/file/d/1VqlgtK2ER65_28Bpr7dJboIg8nzNOzMY 
# // |             | 0194 | P |        IMG_0600 | 05/24/20 2250 | 1 | https://drive.google.com/file/d/1fElcWAHc6GdZVw6XsDfJZSMeM6f0e6EN 
# // |             | 0195 | P |        IMG_0601 | 05/24/20 2250 | 1 | https://drive.google.com/file/d/15ZtekTtGuKWTrJ2brozUabQhlcURu7Xe 
# // |             | 0196 | P |        IMG_0602 | 05/24/20 2250 | 0 | https://drive.google.com/file/d/13KQTzbTLQ7NNzS7OZ4Zmx63pgU9gF7au 
# // |             | 0197 | P |        IMG_0603 | 05/24/20 2250 | 0 | https://drive.google.com/file/d/1HPdGPltH9_Nyr9GtFqYKn509z6i5ZoGF 
# // |             | 0198 | P |        IMG_0604 | 05/24/20 2251 | 0 | https://drive.google.com/file/d/1p_tdU-9lQ391UxsNfixLg71F_M3aGchz 
# // |             | 0199 | P |        IMG_0605 | 05/24/20 2251 | 0 | https://drive.google.com/file/d/18DeG9RcavSV42907L1kcHuTgnfC59LfG 
# // |             | 0200 | P |        IMG_0606 | 05/24/20 2251 | 1 | https://drive.google.com/file/d/1U0A_lsgspUeU7AJQ9m-KebOPdkKHJsRS 
# // |             | 0201 | P |        IMG_0607 | 05/24/20 2253 | 1 | https://drive.google.com/file/d/1jNHmvr66KZMoX0JiT3Cbs43Buu6zADIE 
# // |             | 0202 | P |        IMG_0608 | 05/24/20 2255 | 1 | https://drive.google.com/file/d/1hv3JhYKD--0BQg-x66sO0fomgAy3kFFi 
# // |             | 0203 | P |        IMG_0609 | 05/24/20 2255 | 1 | https://drive.google.com/file/d/1shrLewHORf86sf4TIp3ykAe6WosZ4Q2J 
# // |             | 0204 | P |        IMG_0611 | 05/24/20 2256 | 1 | https://drive.google.com/file/d/1UfA4j-wAO1VfehUwUUJWOGJc6N9SCMFl 
# // |             | 0205 | P |        IMG_0612 | 05/24/20 2256 | 0 | https://drive.google.com/file/d/1qhhH-kHGxCqUuR-8BLWjBzONOWvoEoMB 
# // |             | 0206 | P |        IMG_0613 | 05/24/20 2256 | 1 | https://drive.google.com/file/d/1RzZixkCkQrD4raxRBDmehTLwTzgRLoee 
# // |             | 0207 | P |        IMG_0614 | 05/24/20 2256 | 0 | https://drive.google.com/file/d/154R8Vpi-v72jyEG7Roh8hE_Ds5jLiqCm 
# // |             | 0208 | P |        IMG_0615 | 05/24/20 2256 | 0 | https://drive.google.com/file/d/1d4LjeUQ-XqsiQMayFxdfq6ecC1wGWgH9 
# // |             | 0209 | P |        IMG_0616 | 05/24/20 2256 | 1 | https://drive.google.com/file/d/1M83c0dFf6HxY8YgOc68O8ydE_pLrvU7i 
# // |             | 0210 | P |        IMG_0617 | 05/24/20 2257 | 0 | https://drive.google.com/file/d/1lk98_0EvCmYMaew4KY2f50iE6gfJRM92 
# // |             | 0211 | P |        IMG_0618 | 05/24/20 2257 | 1 | https://drive.google.com/file/d/1vHsJwwj-9E135C2jR1v5Elo6I65tnNCG 
# // |             | 0212 | P |        IMG_0619 | 05/24/20 2257 | 0 | https://drive.google.com/file/d/1mtARlTxYGR7_UvkTBoz31Alfh6EyR9dO 
# // |             | 0213 | P |        IMG_0620 | 05/24/20 2257 | 0 | https://drive.google.com/file/d/1iun2RJ-pToqMlUUQMdKl_yWvJWxKioON 
# // |             | 0214 | P |        IMG_0621 | 05/24/20 2310 | 1 | https://drive.google.com/file/d/19qa9qfALiWRJQwTHwvMhmyZldxBmuEZT 
# // |             | 0215 | V |     Solar Drive | 05/24/20 2310 | 0 | https://youtu.be/ZgVTHK172O8 
# // |             | 0216 | P |        IMG_0622 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1BIO3h4RZxxokfhJmq3BOfgmj4gE6TQ5q 
# // |             | 0217 | P |        IMG_0623 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1bpicQ6EP9ndq0DIdIy9mAAhk1X3A1GHq 
# // |             | 0218 | P |        IMG_0624 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1cjJLLS8j0Zkwzvy716gCIdx1VW5TU23G 
# // |             | 0219 | V |        IMG_0625 | 05/25/20 1028 | 0 | https://drive.google.com/file/d/1SDTqxE12WiYfD3WhgYHzXXlVJ2h9aU-D 
# // |             | 0220 | V |        IMG_0627 | 05/25/20 1054 | 0 | https://drive.google.com/file/d/1zhiwa9hvh5Lg58gHTjDT9TpM0k6NRZVx 
# // |             | 0221 | A |   Capital Digi. | 05/25/20 2135 | 0 | https://drive.google.com/file/d/1Hq-CkA-K3aN5i6uYs6Tle_sLCX5SLHQY 
# // |             | 0222 | P |        IMG_0629 | 05/25/20 2205 | 0 | https://drive.google.com/file/d/15oD2mMphIvsUCO9hDNUh8EJvQfmWUu5_ 
# // |             | 0223 | P |        IMG_0630 | 05/25/20 2205 | 0 | https://drive.google.com/file/d/1lIx0RI0ew189GcY5YYYqKPfhNDSkn69g 
# // |             | 0224 | P |        IMG_0631 | 05/25/20 2205 | 0 | https://drive.google.com/file/d/1BLC2V1WRTRSzJYZWuX7eBFXz37K4CHEP 
# // |             | 0225 | P |        IMG_0633 | 05/25/20 2213 | 0 | https://drive.google.com/file/d/1mX-iOHH0mew1_iwm7nn3b4ROm4lboreM 
# // |             | 0226 | A | Matchless Stove | 05/25/20 2230 | 0 | https://drive.google.com/file/d/14bAzf7pzM_t67Exxm1NoqgHUnYV86pX7 
# // |             | 0227 | P |        IMG_0634 | 05/25/20 2246 | 0 | https://drive.google.com/file/d/1OloZklvgG_mbAz9Qc4eNKTrWSTqWwfT0 
# // |             | 0228 | A |   Computer Ans. | 05/25/20 2300 | 0 | https://drive.google.com/file/d/1dmTkiCzgyGwG9q5BO9hIn_SSeFWPcrIs
# // |             | 0229 | P |        IMG_0636 | 05/25/20 2329 | 0 | https://drive.google.com/file/d/1a-lb9MOUKi1wy9c4cEEyuclH_rQIMhNo 
# // |             | 0230 | P |        IMG_0637 | 05/25/20 2329 | 0 | https://drive.google.com/file/d/1ZNmufDVX7Xkyf4pHqQfPk2Ww2tvkwGCL 
# // |             | 0231 | P |        IMG_0638 | 05/25/20 2329 | 0 | https://drive.google.com/file/d/1uIxufETfzgpM1uLp9mclF4quMkWak4LY 
# // |             | 0232 | P |        IMG_0639 | 05/25/20 2329 | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP 
# // |             | 0233 | P |        IMG_0640 | 05/25/20 2335 | 0 | https://drive.google.com/file/d/1EL_JllhbHWTkYTPAm595SxjhMyRF5vKP 
# // |             | 0234 | P |        IMG_0641 | 05/25/20 2336 | 0 | https://drive.google.com/file/d/1g-tOe4lBQcKaip8ZaHGg7lQmOF7ufSDS 
# // |             | 0235 | P |        IMG_0642 | 05/25/20 2337 | 0 | https://drive.google.com/file/d/1e_KKi6oMfJcqQSLtXCIwES9jKShaK8Vf 
# // |             | 0236 | P |        IMG_0643 | 05/25/20 2337 | 0 | https://drive.google.com/file/d/1GYlnixSrS-_C4BY04zx__I4LznrIFJjU 
# // |             | 0237 | P |        IMG_0644 | 05/25/20 2337 | 0 | https://drive.google.com/file/d/1je8w77DYiUosmS5G3L-4ORgGG1ve7ahI 
# // |             | 0238 | P |        IMG_0645 | 05/25/20 2337 | 0 | https://drive.google.com/file/d/1TIuFj7RcyWtADqpSYavDpP9UcdlyHNvA 
# // |             | 0239 | P |        IMG_0646 | 05/25/20 2343 | 0 | https://drive.google.com/file/d/1Lb8RLYUsJnnKnTOHbunlyBmidIXycjVD 
# // |             | 0240 | Q |        IMG_0647 | 05/25/20 2343 | 0 | (OBSTRUCTION OF JUSTICE -> 05/26/20 0005 (MISSING VIDEO) 
# // |             | 0241 | P |        IMG_0648 | 05/26/20 0005 | 0 | https://drive.google.com/file/d/18xllhtJW6XZhxJOZXWtesywn-Ph37KK9 
# // |             | 0242 | P |        IMG_0649 | 05/26/20 0011 | 1 | https://drive.google.com/file/d/1W0234ojNChSpwDZWnWPzjjZRBQ2CQm0L 
# // |             | 0243 | P |        IMG_0650 | 05/26/20 0011 | 1 | https://drive.google.com/file/d/1vu2bhSSCv2HO-HCeCCh5-iqcYpiiqC2l 
# // |             | 0244 | P |        IMG_0651 | 05/26/20 0011 | 1 | https://drive.google.com/file/d/1imYzaTA--eVDMeSM-dHfYBfC2tiAHsLV 
# // |             | 0245 | P |        IMG_0652 | 05/26/20 0348 | 0 | https://drive.google.com/file/d/1w0Q6lhLYH9ACwQfUosucUE9x5-uAsNzI 
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Charge(s) : 1st ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE
# // |             2nd ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE
# // |             ESPIONAGE/USE of (PHANTOM/PEGASUS)                         
# // |               - APPLE iPHONE 8+ caught on VIDEO 
# // |             1st Telephony DDOS attack 
# // |               - CLIFTON PARK EYE CARE (05/26/20 0004)
# // |             2nd Telephony DDOS attack 
# // |               - CENTER FOR SECURITY   (05/26/20 0009)
# // |_________________________________________________________________________________________________________________________________
# // ^ What actual LAW ENFORCEMENT LOOKS LIKE when it is ACTUALLY BEING ENFORCED and CORRECTLY FUCKING DOCUMENTED/INVESTIGATED.
#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ 12) Add SCSO-2020-028501 @ 05/26/20 01:30AM to 'RAP SHEET'                                     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯   

# Add initial record
$Evidence.AddRecord("SCSO-2020-028501",
"https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf?raw=true",
"05/26/20 01:30AM")

# Retrieve that record for data insertion
$Record = $Evidence.Get(0,0)

# Insert START and END times
$Record.AddTime(0,"05/25/20 11:15PM")
$Record.AddTime(1,"05/26/20 01:55AM")

# Insert (19) Parties
$Record.AddParty("25-30yo white male #1","FBI/SCSO/NYSP/Ryan Ward/Tina Czaikowski","DEFINITELY")
$Record.AddParty("25-30yo white male #2","FBI/SCSO/NYSP/Ryan Ward/Tina Czaikowski","DEFINITELY")
$Record.AddParty("SCOTT SCHELLING","SCSO","DEFINITELY")
$Record.AddParty("JEFFREY KAPLAN","SCSO","NOT INVOLVED")
$Record.AddParty("JOSHUA WELCH","SCSO","NOT INVOLVED")
$Record.AddParty("MICHAEL ZURLO","SCSO","SUSPECTED")
$Record.AddParty("JAMES LEONARD","SCSO","SUSPECTED")
$Record.AddParty("ROBERT MESSINES SR.","NYSP","DEFINITELY")
$Record.AddParty("ERIC CATRICALA","NYS Government/Catricala Funeral Home","DEFINITELY")
$Record.AddParty("ZACKARY KAREL","FEIDEN APPLIANCE","SUSPECTED")
$Record.AddParty("CHRISTOPHER MURPHY","FBI","SUSPECTED")
$Record.AddParty("PAVEL ZAICHENKO","KGB/COMPUTER ANSWERS","SUSPECTED")
$Record.AddParty("TERRI COOK","AUNT TERRI/The fuckin' town dog lady/10 INNISBROOK","SUSPECTED")
$Record.AddParty("RYAN WARD","Cousin Bookie/FBI/10 INNISBROOK","SUSPECTED")
$Record.AddParty("ANDREW CUOMO","NYS Government",  "SUSPECTED")
$Record.AddParty("HILLARY R. CLINTON","NYS Goverment","SUSPECTED")
$Record.AddParty("MARK ZUCKERBERG","Facebook","SUSPECTED")
$Record.AddParty("TATIANA CLEVELAND","Shenendehowa","FAIRLY CERTAIN she's NOT involved")
$Record.AddParty("RONALD McFuckin'Donald","McDonalds Corporation","Who the fuck knows, dude...?")

# Insert (4) Addresses
$Record.AddAddress("Start","Business","Catricala Funeral Home","1597 US-9","Clifton Park","NY",12065)
$Record.AddAddress("Start","Business","Computer Answers","1602 US-9","Clifton Park","NY",12065)
$Record.AddAddress("End","Residence","Zackary Karel","1769 US-9","Clifton Park","NY",12065)
$Record.AddAddress("End","Business","Zappone Dealership","1780 US-9","Clifton Park","NY",12065)

# Narrative 
$Record.AddNarrative(@'
Any assortment of the above listed parties were involved in a PREMEDITATED MURDER ATTEMPT.
The police are fucking morons. They have a hard time making a CORRELATION to:
CVE-2019-8936, RANSOMWARE, DDOS ATTACKS, CYBER ATTACKS, RUSSIANS, IDENTITY THEFT,
CYBERCRIMINALS, and COMPUTER ANSWERS... together, as (1) thing that RUSSIANS do.
I was INCREDIBLY SUSPICIOUS of PAVEL ZAICHENKO after 01/15/2019 when an ADVANCED CYBERATTACK 
was waged against the COMPUTER ANSWERS NETWORK that I was MANAGING between:
OCTOBER 2018 -> JANUARY 2019 under MY COMPANY, SECURE DIGITS PLUS LLC.
 
2x queers about 25-30 years old, white males, VERY gay looking, wearing hats, backpacks,
glasses, neon lights in their mesh-like backpacks... spent about 90 minutes AGGRESSIVELY 
following me, starting from 1597/1602 US-9, to the ALDI/Hoffman Car Wash intersection.
I actually attempted to contact 911 EMERGENCY SERVICES TWICE, with my "smartphone" that was
"hacked" with a "dangerous fucking program" that I now understand was called "PEGASUS/PHANTOM".

The FIRST time I DIALED 911 EMERGENCY SERVICES, was near CLIFTON PARK EYE CARE, at 0004.
The SECOND time I DIALED 911 EMERGENCY SERVICES, was DIRECTLY IN FRONT OF THE CAMERA AT:
CENTER FOR SECURITY, at 0009.
I actually have a SCREENSHOT from my DEVICE that SHOWS THE TIMESTAMPS OF THOSE 911 calls.
There is no mistaking what they were looking to do, they were attempting to murder me.
I recorded a video that I showed to NYSP Trooper Shaemus Leavey, and I ALSO took (3) 
pictures from a fair distance away, near SPARE TIME BOWLING ALLEY.
They followed me into the LOWES HOME IMPROVEMENT STORE PARKING LOT, where they had a 
CAR parked AHEAD OF TIME, indicating that the MURDER ATTEMPT was PREMEDITATED and PLANNED.
I was able to lose sight of these guys UNTIL I walked out onto Route 146, where they turned
LEFT out of the LOWES PARKING LOT, headed WEST on 146 (toward BURGER KING/KEY BANK), and 
attempted to STRIKE ME AGAIN with their VEHICLE. The FIRST TIME that they attempted to strike
me with their vehicle, was at APPROXIMATELY 2315, DURING an AUDIO RECORDING THAT I WAS RECORDING...
...which, believe it or not is a KEY PIECE OF EVIDENCE.

I had UPLOADED THAT AUDIO RECORDING EARLIER AT COMPUTER ANSWERS around 2329, because I had ACCESS 
to the NETWORK, since I used to "WORK" there, and I had actually CONFIGURED THAT ACCESS POINT IN MAY 2018. 
When I say "WORK", what I really mean is, MANAGING THAT FUCKING COMPANY MORE THAN THE 1) OWNER, and 
2) VICE PRESIDENT. That's what I call "WORK".

The ACCESS POINT was actually a CISCO AIRONET 1140 series that I LITERALLY PURCHASED FROM AN NFRASTRUCTURE EMPLOYEE.
In reference to the 2 GUYS THAT TRIED TO KILL ME FOR LIKE 90 minutes...
They failed to strike me with their vehicle between AUTOZONE and ADVANCE AUTO PARTS on ROUTE 146,
and I attempted to get the LICENSE PLATE or the MAKE/MODEL of the VEHICLE, but couldn't remember it.
They turned RIGHT onto US-9 toward ZACKARY KARELS RESIDENCE.
I started trying to FLAG PEOPLE DOWN for HELP, not JUMPING IN FRONT OF VEHICLES.
I saw ROBERT MESSINES SR. DRIVING HIS BLACK SUV NEAR ZACKARY KARELS RESIDENCE.
I then thought to CUT THE PHONE LINE AT 1769 ROUTE 9, because the GUYS that TRIED TO KILL ME were either
IN THAT HOUSE, or... SCSO just IGNORED the fact that I CUT THAT PHONE LINE at 130AM. NOT 545AM. 130AM.
At which point, I then MOVED THE EMBROIDERY SHOP SIGN ACROSS THE STREET ONTO THE POLE WHERE MATCHLESS STOVE
AND CHIMNEY is SUPPOSED to have a MAILBOX... but- even though I took a PICTURE of that EARLIER that night...
IMG_0633.HEIC at about 05/25/20 2213...? 
The police haven't collected that as EVIDENCE of SUSPICIOUS ACTIVITY or anything.
Then, the POLICE have been pretending for *checks watch* (2+) years, that I was being DELUSIONAL, but that was 
BEFORE they COLLECTED EVIDENCE.
So, it just looks like the police are really fucking lazy, and they don't do "work" at all.

However, the REAL REASON why they just APPEAR to be really fucking lazy, is because I have
come to the CONCLUSION, that they were PISSED about the (8) videos, multiple pictures, 
audio logs, Facebook posts, and what a general, all-around annoyance I've been, telling
them just how fucking terrible they are collectively, at ENFORCING THE FUCKING LAW.

SOME of those parties were NOT INVOLVED and that is EXPLICITLY SPECIFIED, however they
are STILL SUSPECTS That means ANYONE in that box MAY be marked incorrectly, AND,
there may be MISSING PEOPLE that are supposed to be in that box.
'@)

# Insert (246) Evidence
$Record.AddExhibitContainer("https://github.com/mcc85s/FightingEntropy/blob/main/Records/SCSO-2020-028501-(EVIDENCE).txt?raw=true")

# Insert (5) Charges   AddCharge(uint Count, string Name, string Description, string Severity)
$Record.AddCharge("ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE (1st attempt)","~2315 in EXHIBIT 228 (Computer Answers)","FELONY")
$Record.AddCharge("ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE (2nd attempt)","~0045 in EXHIBIT 242, 243, 244","FELONY")
$Record.AddCharge("ESPIONAGE ACT of 1917/USE of (PHANTOM/PEGASUS)","~2343, APPLE iPHONE 8+ caught on EXHIBIT 240 (IMG_0647.MOV)","CAPITAL")
$Record.AddCharge("Telephony DDOS attack DISRUPTION of 911 EMERGENCY SERVICES CALL","~0004 CLIFTON PARK EYE CARE, 1618 US-9 in EXHIBIT 241","MISDEMEANOR... (should be a FELONY)") 
$Record.AddCharge("Telephony DDOS attack DISRUPTION of 911 EMERGENCY SERVICES CALL","~0009 CENTER FOR SECURITY, 1659 US-9 in EXHIBIT 245","MISDEMEANOR... (should be a FELONY)")

# // |=======================================================================================================|
# // | The COVER UP (Part 1) (05/26/20 0200 or some point afterward)
# // |=======================================================================================================|
# // |
# // | Incident  : SCSO-2020-028501 (Continued, IMMEDIATELY AFTER the SECONDARY LOCATION)
# // | Reference : https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA
# // | Date      : 05/26/20 0156
# // |             _________________________________
# // | Time      : | 05/26/20 0156 | 05/26/20 0545 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Duration  : 3h 49m
# // |             _______________________________________________________________
# // | Party     : | MICHAEL ZURLO       | SCSO             | Fucking definitely |
# // |             | JAMES LEONARD       | SCSO             | Fucking definitely |
# // |             | SCOTT SCHELLING     | SCSO             | Fucking definitely |
# // |             | CENTER FOR SECURITY | STAFF            | Fucking definitely |
# // |             | ZACKARY KAREL       | FEIDEN APPLIANCE | Fucking definitely |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ______________________________________________________
# // | Address   : | FROM | CENTER FOR SECURITY                         |
# // |             |      | 1659 US-9, Clifton Park NY 12065            |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ______________________________________________________
# // |             | TO   | ZACKARY KARELS RESIDENCE                    |
# // |             |      | 1769 US-9, Clifton Park NY 12065            |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Narrative : Deleting the surveillance footage of TDDOS #2
# // |             <I told SCOTT SCHELLING about its existence> @ 05/26/20 0155
# // |             And, I would be willing to TESTIFY IN A COURT OF LAW.
# // |             ___________________________________________________________________________________
# // | Exhibit   : | Phone call records request, otherwise known as CELLULAR REBIDS - COURT SUBPOENA |
# // |             | JEFFREY KAPLAN's TESTIMONY                                                      |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Charge(s) : OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE
# // |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

$Evidence.AddRecord("SCSO-2020-028501 (IMMEDIATELY AFTER the SECONDARY LOCATION) [COVER-UP PART 1/4]",
"https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf?raw=true",
"05/26/20 01:30AM")

# Retrieve that record for data insertion
$Record = $Evidence.Get(0,1)

# Insert START and END times
$Record.AddTime(0,"05/26/20 01:56AM")
$Record.AddTime(1,"05/26/20 05:45AM")

# Insert (5) parties
$Record.AddParty("MICHAEL ZURLO","SCSO","Fucking definitely")
$Record.AddParty("JAMES LEONARD","SCSO","Fucking definitely")
$Record.AddParty("SCOTT SCHELLING","SCSO","Fucking definitely")
$Record.AddParty("CENTER FOR SECURITY","STAFF","Fucking definitely")
$Record.AddParty("ZACKARY KAREL","FEIDEN APPLIANCE","Fucking definitely")

# Insert (2) addresses
$Record.AddAddress("Start","Business","Center for Security","1659 US-9","Clifton Park","NY",12065)
$Record.AddAddress("End","Residence","Zackary Karel","1769 US-9","Clifton Park","NY",12065)

# Insert (2) narrative
$Record.AddNarrative(@'
Deleting the surveillance footage of TDDOS #2
<I told SCOTT SCHELLING about its existence> @ 05/26/20 0155
And, I would be willing to TESTIFY IN A COURT OF LAW.
'@)

$Record.AddNarrative(@'
Leads - Phone call records request, otherwise known as CELLULAR REBIDS - COURT SUBPOENA
JEFFREY KAPLAN's TESTIMONY
'@)

# Insert (1) charge
$Record.AddCharge("OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE","SCSO-2020-028501","FELONY")

# // |=======================================================================================================|
# // | The COVER UP (Part 2) (05/27/20 0905)
# // |=======================================================================================================|
# // | 
# // | Incident  : SCSO-2020-028501 (Continued, executed immediately after meeting with SHAEMUS LEAVEY)
# // | Reference : https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA
# // | Date      : 05/27/20 0905
# // |             _________________________________
# // | Time      : | 05/26/20 0156 | 05/27/20 0905 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Duration  : 1d 07h 09m
# // |             ___________________________________________________
# // | Party     : | MICHAEL ZURLO      | SCSO  | Fucking definitely |
# // |             | JAMES LEONARD      | SCSO  | Fucking definitely |
# // |             | CHRISTOPHER MURPHY | FBI   | SUSPECTED          |
# // |             | RYAN WARD          | FBI   | SUSPECTED          |
# // |             | TIM COOK           | APPLE | SUSPECTED          | 
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Address   : ________________________________________________________
# // |             | Start | Federal Bureau of Investigation Field Office |
# // |             |       | 200 McCarty Ave, Albany NY 12209             |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ________________________________________________________
# // |             | End   | Apple Corporation Headquarters               |
# // |             |       | One Apple Park Way, Cupertino CA 95014       |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Narrative : Disabling my iPhone 8+ 5 min. AFTER showing NYSP TROOPER LEAVEY
# // |             the VIDEO near 203D HALFMOON CIRCLE, CLIFTON PARK NY 12065
# // |             The VIDEO IMG_0647.mov was DESTROYED because of this CRIME.
# // | 
# // |             HOWEVER, the very BEGINNING of the video was CAPTURED AS A PICTURE
# // |             IMG_0646.HEIC, cool, right...?
# // |             
# // |             Also, the (3) audio logs that I uploaded at COMPUTER ANSWERS
# // |             had their TIME delayed by about 3 hours. Which means that SOMEONE was
# // |             using a VPN and ALTERED THE TIME CREATION DATE ON EACH OF THOS AUDIO LOGS.
# // |          
# // |             That's actually a FEDERAL CRIME NOW BOYS. GOOD JOB. *FIST BUMP*
# // |             ______________________________________________________________________________________________________________________
# // | Exhibit   : | 0083 | V |        IMG_0405 | 05/23/20 1747 | 0 | https://youtu.be/g0ACtMIPrRo                                      |
# // |             | 0091 | V |        IMG_0413 | 05/23/20 2040 | 0 | https://youtu.be/OZD6rBbDboA                                      |
# // |             | 0094 | V |        IMG_0416 | 05/23/20 2118 | 0 | https://drive.google.com/file/d/1jJh0rG2KUtEhvqw-0FEoZ6lBXsnkyjBO |
# // |             | 0107 | V |        IMG_0430 | 05/23/20 2316 | 1 | https://youtu.be/7ZjLXsW-USc (unaltered/FBI corrupted entry below)|
# // |             | 0108 | V |        IMG_0430 | 05/23/20 2316 | 1 | https://drive.google.com/file/d/1kuaybwEfIUYTd06wf76WRHIBZtdtphBV |
# // |             | 0110 | V |        IMG_0432 | 05/23/20 2323 | 0 | https://drive.google.com/file/d/1K16SXHJhaFeive21taFWquLioLSEjc6i |
# // |             | 0136 | V | 2020 05 24 1341 | 05/24/20 1341 | 0 | https://youtu.be/i88AJb_5zY4                                      |
# // |             | 0215 | V |     Solar Drive | 05/24/20 2310 | 0 | https://youtu.be/ZgVTHK172O8                                      |
# // |             | 0216 | P |        IMG_0622 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1BIO3h4RZxxokfhJmq3BOfgmj4gE6TQ5q |
# // |             | 0217 | P |        IMG_0623 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1bpicQ6EP9ndq0DIdIy9mAAhk1X3A1GHq |
# // |             | 0218 | P |        IMG_0624 | 05/25/20 1016 | 0 | https://drive.google.com/file/d/1cjJLLS8j0Zkwzvy716gCIdx1VW5TU23G |
# // |             | 0219 | V |        IMG_0625 | 05/25/20 1028 | 0 | https://drive.google.com/file/d/1SDTqxE12WiYfD3WhgYHzXXlVJ2h9aU-D |
# // |             | 0220 | V |        IMG_0627 | 05/25/20 1054 | 0 | https://drive.google.com/file/d/1zhiwa9hvh5Lg58gHTjDT9TpM0k6NRZVx |
# // |             | 0221 | A |   Capital Digi. | 05/25/20 2135 | 0 | https://drive.google.com/file/d/1Hq-CkA-K3aN5i6uYs6Tle_sLCX5SLHQY |
# // |             | 0226 | A | Matchless Stove | 05/25/20 2230 | 0 | https://drive.google.com/file/d/14bAzf7pzM_t67Exxm1NoqgHUnYV86pX7 |
# // |             | 0228 | A |   Computer Ans. | 05/25/20 2300 | 0 | https://drive.google.com/file/d/1dmTkiCzgyGwG9q5BO9hIn_SSeFWPcrIs |
# // |             | 0239 | P |        IMG_0646 | 05/25/20 2343 | 0 | https://drive.google.com/file/d/1Lb8RLYUsJnnKnTOHbunlyBmidIXycjVD |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Charge(s) : OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE (FELONY)
# // |             OBSTRUCITON OF JUSTICE, <unspecified federal crime> (CAPITAL)
# // |             ESPIONAGE ACT of 1917, PREVENTING EXTRACTION OF EVIDENCE FROM DEVICE
# // |             CONSPIRACY TO COMMIT MURDER AGAINST MICHAEL C. COOK (CAPITAL)
# // |___________________________________________________________________________________________________________________________________

$Evidence.AddRecord("SCSO-2020-028501 (Continued, executed immediately after meeting with SHAEMUS LEAVEY) [COVER-UP PART 2/4]",
"https://github.com/mcc85s/FightingEntropy/blob/main/Records/2020-028501%20Cook%20req.pdf?raw=true",
"05/26/20 01:30AM")

# Retrieve that record for data insertion
$Record = $Evidence.Get(0,2)

# Insert START and END times
$Record.AddTime(0,"05/26/20 01:56AM")
$Record.AddTime(1,"05/27/20 09:05AM")

# Insert (9) parties
$Record.AddParty("MICHAEL ZURLO","SCSO","Fucking definitely")
$Record.AddParty("JAMES LEONARD","SCSO","Fucking definitely")

$Record.AddParty("SCOTT SCHELLING","SCSO","Fucking definitely")
$Record.AddParty("CENTER FOR SECURITY","STAFF","Fucking definitely")
$Record.AddParty("ZACKARY KAREL","FEIDEN APPLIANCE","Fucking definitely")
$Record.AddParty("CHRISTOPHER MURPHY","FBI","SUSPECTED")
$Record.AddParty("RYAN WARD","FBI","SUSPECTED")
$Record.AddParty("TERRI COOK","CP Public Safety","SUSPECTED")
$Record.AddParty("TIM COOK","APPLE","SUSPECTED")

# Insert (2) addresses
$Record.AddAddress("Start","Government","Federal Bureau of Investigation Field Office","200 McCarty Ave","Albany","NY",12209)
$Record.AddAddress("End","Business","Apple Corporation Headquarters","One Apple Park Way","Cupertino","CA",95014)

# Insert (10) narrative
$Record.AddNarrative(@'
Disabling my iPhone 8+ 5 min. AFTER showing NYSP TROOPER LEAVEY the VIDEO
near 203D HALFMOON CIRCLE, CLIFTON PARK NY 12065. 
The VIDEO IMG_0647.mov was DESTROYED because of this CRIME.

HOWEVER, the very BEGINNING of the video was CAPTURED AS A PICTURE IMG_0646.HEIC, cool, right...?
There's a fuckin' queer dude named TIMOTHY COOK who's looking at CRIMINAL CHARGES...?
Hell yeah dude. That's EXACTLY what's happening.

Also, the (3) audio logs that I uploaded at COMPUTER ANSWERS had their TIME delayed by about 3 hours. 
Which means that SOMEONE was using a VPN and ALTERED THE TIME CREATION DATE ON EACH OF THOS AUDIO LOGS.

That's actually a FEDERAL CRIME NOW BOYS. GOOD JOB. *FIST BUMP*
'@)

$Record.AddNarrative(@'
First entry is right after I walked to STRATTON AIR NATIONAL GUARD, I recorded a video of the SCHENECTADY WATERFRONT property.
And in the fuckin' distance...? The GOLUB Corporation, and me mentioning that an FBI man was WATCHING me.
That FBI man is CHRISTOPHER MURPHY, which is the real reason why CPS was called on me back in January 2020.
Cause he knows that Mr. Pickett is doing some shit to me. He's been paid to shut his fuckin' mouth. Exhibit 0070.
'@)

$record.AddNarrative(@'
Second entry is a kid on a bike who just mysteriously checks his phone real quick...
Nothing suspicious about that at all. Exhibit 083.
'@)

$Record.AddNarrative(@'
Third entry is footage of the Clifton Park Public safety building where my Aunt Terri works with Robert Rybak.
Also where the NYSP Troopers left (4) of their fucking cruisers running idle...
...unattended for WELL OVER 20 fuckin' minutes... Exhibit 0091.
'@)

$Record.AddNarrative(@'
Fourth entry is basically me walking around the Shenendehowa Campus, mysterious truck following me around and stuff.
The truck stops near where the speed bump adjacent to the ORENA EXERCISE TRAIL is located.
During THIS particular video, there is a MYSTERIOUSLY RUNNING BLACK GMC YUKON DENALI parked in front of ORENDA ELEMENTARY.

Nothing TOO suspicious about that, right...?
My daughter WAS ATTENDING THAT SCHOOL...?
Right MRS. SMITH...? AND MRS. MATURA...?
Weird.
It's almost like this EVIDENCE just SLIPPED RIGHT BY a bunch of OVERPAID MORONS.

Anyway, then I capture audio of some fucking moron attempting to lunge at me from the ORENDA EXERCISE TRAIL.
Right where the RED TRUCK JUST SO HAPPENED TO PAUSE BRIEFLY... No correlations here to be made at all...
If you're a fucking MORON, that is.

This all took place about 30 minutes after Exhibit 0091, this is Exhibit 0094.
'@)

$Record.AddNarrative(@'
Fifth entry is a (3) parter...
So in reality it's ALSO the sixth, and the seventh entry.
It's not the seventh son of a seventh son, cause that'd be a LOT of sons...
There's still a couple of sons of bitches involved in these.

Exhibit 107 is MERGED with Exhibit 110 somehow, because there are MORONS on planet Earth, trying to make the
BLUE CAR look INCONSPICUOUS, and UNINTELLIGIBLE, but in reality...? It just looks like a lazy cocksucker from Verizon
might've made themselves look incredibly fucking obvious. Exhibit 107, Exhibit 108, Exhibit 110.

This SAME EXACT CAR can be seen later in Exhibit 0219.
'@)

$Record.AddNarrative(@'
While there are additional exhibits to discuss regarding the pictures taken on USHERS ROAD.
However, the eighth entry occurred the following day...
...someone was preventing me from EXFILTRATING DATA from my DEVICE. Exhibit 136.
'@)

$Record.AddNarrative(@'
NYSEG and VERIZON sorta hand-in-hand with the level of douchebaggery at all times.
Where NYSEG doesn't charge CERTAIN people for their power...?
Verizon constantly leaves fiber optic cables on the fuckin' ground.
the ninth exhibit here, showcases how they BOTH sorta make a lot of money off of NOT HAVING RUNNING METERS AT CELL TOWERS.
Though it belongs to AT&T or T-MOBILE... They're basically using the same network.
Exhibit 215.
'@)

$Record.AddNarrative(@'
The tenth to fifteenth exhibit is basically me 'putting it all together'.
I ran into JOHN HOFFMAN that morning BEFORE I took the (3) pictures outside of PEDDLERS.
I then walked to my AUNT TERRI COOK's old house in INNISBROOK, but she wasn't there.
Interesting how these exhibits ALL occurred PRIOR to the MURDER attempt, right...?
Exhibit 216, 217, 218, 219, 220.
'@)

$Record.AddNarrative(@'
The LAST exhibits sorta paints the MOST REAL PICTURE POSSIBLE, as to WHY my SMARTPHONE was DISABLED by...
...the MANUFACTURER of the DEVICE...? The APPLE CORPORATION.
Exhibit 221, 226, 228, 239.
'@)

# Add (18) Exhibits
$Record.AddExhibit("V","IMG_0395",        "05/23/20 0133","0","https://youtu.be/3twiZEsyQf0")
$Record.AddExhibit("V","IMG_0405",        "05/23/20 1747","0","https://youtu.be/g0ACtMIPrRo")
$Record.AddExhibit("V","IMG_0413",        "05/23/20 2040","0","https://youtu.be/OZD6rBbDboA")
$Record.AddExhibit("V","IMG_0416",        "05/23/20 2118","0","https://drive.google.com/file/d/1jJh0rG2KUtEhvqw-0FEoZ6lBXsnkyjBO")
$Record.AddExhibit("V","IMG_0430",        "05/23/20 2316","1","https://youtu.be/7ZjLXsW-USc (unaltered/FBI corrupted entry below)")
$Record.AddExhibit("V","IMG_0430",        "05/23/20 2316","1","https://drive.google.com/file/d/1kuaybwEfIUYTd06wf76WRHIBZtdtphBV")
$Record.AddExhibit("V","IMG_0432",        "05/23/20 2323","0","https://drive.google.com/file/d/1K16SXHJhaFeive21taFWquLioLSEjc6i")
$Record.AddExhibit("V","2020 05 24 1341", "05/24/20 1341","0","https://youtu.be/i88AJb_5zY4")
$Record.AddExhibit("V","Solar Drive",     "05/24/20 2310","0","https://youtu.be/ZgVTHK172O8")
$Record.AddExhibit("P","IMG_0622",        "05/25/20 1016","0","https://drive.google.com/file/d/1BIO3h4RZxxokfhJmq3BOfgmj4gE6TQ5q")
$Record.AddExhibit("P","IMG_0623",        "05/25/20 1016","0","https://drive.google.com/file/d/1bpicQ6EP9ndq0DIdIy9mAAhk1X3A1GHq")
$Record.AddExhibit("P","IMG_0624",        "05/25/20 1016","0","https://drive.google.com/file/d/1cjJLLS8j0Zkwzvy716gCIdx1VW5TU23G")
$Record.AddExhibit("V","IMG_0625",        "05/25/20 1028","0","https://drive.google.com/file/d/1SDTqxE12WiYfD3WhgYHzXXlVJ2h9aU-D")
$Record.AddExhibit("V","IMG_0627",        "05/25/20 1054","0","https://drive.google.com/file/d/1zhiwa9hvh5Lg58gHTjDT9TpM0k6NRZVx")
$Record.AddExhibit("A","Capital Digi.",   "05/25/20 2135","0","https://drive.google.com/file/d/1Hq-CkA-K3aN5i6uYs6Tle_sLCX5SLHQY")
$Record.AddExhibit("A","Matchless Stove", "05/25/20 2230","0","https://drive.google.com/file/d/14bAzf7pzM_t67Exxm1NoqgHUnYV86pX7")
$Record.AddExhibit("A","Computer Ans.",   "05/25/20 2300","0","https://drive.google.com/file/d/1dmTkiCzgyGwG9q5BO9hIn_SSeFWPcrIs")
$Record.AddExhibit("P","IMG_0646",        "05/25/20 2343","0","https://drive.google.com/file/d/1Lb8RLYUsJnnKnTOHbun")
#>

# Insert (4) charges
$Record.AddCharge("OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE","SCSO-2020-028501","FELONY")
$Record.AddCharge("OBSTRUCTION OF JUSTICE, <unspecified>","All exhibits <federal crime>","CAPITAL")
$Record.AddCharge("ESPIONAGE ACT of 1917, PREVENTING EXTRACTION OF EVIDENCE FROM DEVICE","Exhibit <2020 05 24 1341>","CAPITAL")
$Record.AddCharge("CONSPIRACY TO COMMIT MURDER AGAINST MICHAEL C. COOK","All exhibits","CAPITAL")

# // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                            |
# // | ________________________________________________________________________                            |
# // | The COVER UP (Part 3) (05/27/20 1212)                                  |                            |
# // | =======================================================================|                            |
# // | MANUFACTURING OF EVIDENCE/FRAMING (^ AKA IGNORING THOSE CRIMES)        |                            |
# // | =======================================================================|                            |
# // | [SCSO-2020-003173] 36h LATE (Event 05/25/20 2343-05/26/20 0130)        |                            |
# // | ZACKARY KAREL, JAMES LEONARD, ROBERT RYBAK                             |                            |
# // | [1769 US-9, CLIFTON PARK, NY 12065]                                    |                            |
# // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                            |
# // | ________________________________________________________________________                            |
# // | The COVER UP (Part 4) (05/27/20 1414)                                  |                            |
# // | =======================================================================|                            |
# // | - 1x MANUFACTURING OF EVIDENCE/FRAMING (^ AKA IGNORING THOSE CRIMES)   |                            |
# // |   [SCSO-2020-003177] 69h LATE (Events 05/24/20 1715 + 05/25/20 2343)
# // |   ERIC CATRICALA, JAMES LEONARD, SCOTT CARPENTER
# // |   [1597 US-9, CLIFTON PARK, NY 12065] <= (3) days late
# // ¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

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
