Write-Theme -Title "How to make fun of people that call themselves POLICE OFFICERS/INVESTIGATORS" @(
"Create some classes that can CLASSIFY and ORGANIZE the amount of EVIDENCE",
"that the LAW ENFORCEMENT SYSTEM, JUSTICE SYSTEM, and SARATOGA COUNTY SERVICES",
"FUCKIN' SUCK AT COLLECTING/REVIEWING/SUBMITTING TO A COURTROOM",
"===============================================================================",
"HEATHER COREY-MONGUE, PAUL PELAGALLI, MICHAEL ZURLO, <take notice>") -Text

#    ____                                                                                                    ________    
#   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
#   //¯¯\\__[ How to make fun of people that call themselves POLICE OFFICERS/INVESTIGATORS   ]______________//¯¯\\__//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
#   //¯¯¯                                                                                                           //   
#   \\        Create some classes that can CLASSIFY and ORGANIZE the amount of EVIDENCE                             \\   
#   //        that the LAW ENFORCEMENT SYSTEM, JUSTICE SYSTEM, and SARATOGA COUNTY SERVICES                         //   
#   \\        FUCKIN' SUCK AT COLLECTING/REVIEWING/SUBMITTING TO A COURTROOM                                        \\   
#   //        ===============================================================================                       //   
#   \\        HEATHER COREY-MONGUE, PAUL PELAGALLI, MICHAEL ZURLO, <take notice>                                    \\   
#   //                                                                                                           ___//   
#   \\___                                                                                                    ___//¯¯\\   
#   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
#   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
#    ¯¯¯\\__[ Press enter to continue    ]__________________________________________________________________//¯¯¯        
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            

Function New-EvidenceList
{
    # // __________________________________________________________________________________________________
    # // | Usually, you want to consider things like TIME and PLACE to determine whether a CRIME occurred |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Class Time
    {
        [String]   $Slot
        [DateTime] $Date
        Time([UInt32]$Slot,[String]$Date)
        {
            If ($Slot -notin 0,1)
            {
                Throw "Invalid Slot"
            }
            $This.Slot = $Slot
            $This.Date = [DateTime]$Date
        }
    }

    # // _____________________________________________
    # // | Crimes are POTENTIALLY committed by these |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Class Person
    {
        [String] $Name
        [String] $Affiliation
        Person([String]$Name,[Object]$Affiliation)
        {
            $This.Name        = $Name
            $This.Affiliation = $Affiliation
        }
    }

    # // ________________________________________________________________________
    # // | Crimes are POTENTIALLY committed by these, but now they're SUSPECTED |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    Class Suspect
    {
        [String] $Name
        [String] $Affiliation
        [String] $Involvement
        Suspect([Object]$Person,[String]$Involvement)
        {
            $This.Name        = $Person.Name
            $This.Affiliation = $Person.Affiliation
            $This.Involvement = $Involvement
        }
        Suspect([String]$Name,[String]$Affiliation,[String]$Involvement)
        {
            $This.Name        = $Name
            $This.Affiliation = $Affiliation
            $This.Involvement = $Involvement
        }
    }

    # // ___________________________________________________________
    # // | Crimes are committed AT these PLACES by the thing above |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
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
            If ($Label -notin "Start","End")
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
        [DateTime]      $Date
        [Object]        $Time
        [String]    $Duration
        [Object]     $Address
        [Object]       $Party
        [String]   $Narrative
        [Object]    $Evidence
        [Object]      $Charge
        Record([UInt32]$Index,[String]$Incident,[String]$Reference,[String]$Date)
        {
            $This.Index     = $Index
            $This.Incident  = $Incident
            $This.Reference = $Reference
            $This.Date      = [DateTime]$Date
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
            
            $This.Time += [Time]::New($Slot,$DateTime)
            If (0 -in $This.Time.Slot -and 1 -in $This.Time.Slot)
            {
                $Start         = $This.Time | ? Slot -eq 0
                $End           = $This.Time | ? Slot -eq 1
                $This.Duration = "$([TimeSpan]($End.Date-$Start.Date))"
            }
        }
        AddParty([String]$Name,[String]$Affiliation,[String]$Involvement)
        {
            If ($Name -in $This.Party.Name)
            {
                Throw "Party already specified"
            }

            $This.Party += [Suspect]::new($Name,$Affiliation,$Involvement)
        }
        RemoveParty([String]$Name)
        {
            If ($Name -notin $This.Party.Name)
            {
                Throw "Party not specified"
            }

            $This.Party = $This.Party | ? Name -ne $Name
        }
        SetNarrative([String]$String)
        {
            $This.Narrative += $String
        }
        AddEvidence([String]$Reference)
        {
            If ($Reference -in $This.Evidence.Reference)
            {
                Throw "Reference already specified"
            }

            $This.Evidence += $Reference
        }
        RemoveEvidence([String]$Reference)
        {
            If ($Reference -notin $This.Evidence.Reference)
            {
                Throw "Reference is not specified"
            }

            $This.Evidence = $this.Evidence | ? Reference -ne $Reference
        }
        AddCharge([UInt32]$Index,[String]$Name,[String]$Description,[String]$Severity)
        {
            $This.Charge += [Charge]::New($Index,$Name,$Description,$Severity)
        }
        RemoveCharge([UInt32]$Index)
        {
            If ($Index -gt $This.Charge.Count)
            {
                Throw "Invalid index"
            }

            $This.Charge = $This.Charge | ? Index -ne $Index

            If ($this.Charge.Count -eq 1)
            {
                $This.Charge[0].Index = 0
            }
            If ($This.Charge.Count -gt 1)
            {
                ForEach ($X in 0..($This.Charge.Count-1))
                {
                    $This.Charge[$X].Index = $X
                }
            }
        }
        ResetItem([UInt32]$Type)
        {
            Switch ($Type)
            {
                0 
                { 
                    $This.Time      = @( ) 
                    $This.Duration  = "<unknown>"
                }
                1 { $This.Address   = @( ) }
                2 { $This.Party     = @( ) }
                3 { $This.Evidence  = @( ) }
                4 { $This.Charge    = @( ) }
                5 { $This.Narrative = ""   }
            }
        }
        ResetItem([String]$Item)
        {
            $Slot = Switch ($Item)
            {
                Time      {0}
                Address   {1} 
                Party     {2} 
                Evidence  {3} 
                Charge    {4}
                Narrative {5}
            }
            $This.ResetItem($Slot)
        }
        Reset()
        {
            0..5 | % { $This.ResetItem($_) }
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
# // because it shows how fuckin' stupid Michael Zurlo is. I'll explain WHY, shortly. Around line 777.

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
#   \\__//¯¯¯ 9) Get the comment for <[EXHIBIT[1]]>, and paste it below                                      ___//¯¯\\   
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
#   \\__//¯¯¯ 10) Open the <[EXHIBIT[2]]> link in a WEB BROWSER, and push to Tab #3, then rant til line 777  ___//¯¯\\   
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
# ...at being good programmer.

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
# Guys like Trooper Ruffas are gonna shake their heads and walk away.
# They've got innocent people to shoot and kill, and then lie about why they shot them.
# That's what guys like Trooper Ruffas do. Derek Chauvin, too.

# Anyway...
# _________________
# | INVESTIGATORS |... they're not supposed to do what TROOPER RUFFAS does.
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# You can show them EVIDENCE and CLUES...?
# But they will probably arrest you for doing something that DANGEROUS.

# Yeah, showing people EVIDENCE...?
# It can cause some people to be violently killed by the police.
# Totally fuckin' serious about that.

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



# // |=======================================================================================================|
# // | The MURDER ATTEMPT (SCSO-2020-028501)
# // |=======================================================================================================|
# // | Charge(s) : 1st ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE
# // |             2nd ATTEMPTED (VEH. MANSLAUGHTER/MURDER) in the 1st DEGREE
# // |             ESPIONAGE/USE of (PHANTOM/PEGASUS)                         
# // |               - APPLE iPHONE 8+ caught on VIDEO 
# // |             1st Telephony DDOS attack 
# // |               - CLIFTON PARK EYE CARE (05/26/20 0004)
# // |             2nd Telephony DDOS attack 
# // |               - CENTER FOR SECURITY   (05/26/20 0009)
# // | Incident  : SCSO-2020-028501
# // | Reference : https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA
# // |             __________________________________  
# // | Time      : | 05/25/20 2315 -> 05/26/20 0155 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ______________________________________________
# // | Parties   : | FBI  | 2x 25-30yo white males (DEFINITELY) |
# // |             | NYSP | ROBERT MESSINES SR. (DEFINITELY)    |
# // |             | NYS  | ERIC CATRICALA      (DEFINITELY)    |
# // |             | SCSO | MICHAEL ZURLO       (SUSPECTED)     |
# // |             | SCSO | JAMES LEONARD       (SUSPECTED)     |
# // |             | SCSO | SCOTT SCHELLING     (DEFINITELY)    |
# // |             | SCSO | JEFFREY KAPLAN      (not involved)  |
# // |             | SCSO | JOSHUA WELCH        (not involved)  |
# // |             | FBI  | CHRISTOPHER MURPHY  (SUSPECTED)     |
# // |             | KGB  | PAVEL ZAICHENKO     (SUSPECTED)     |
# // |             | CPSB | TERRI COOK          (SUSPECTED)     |
# // |             | FBI  | RYAN WARD           (SUSPECTED)     |
# // |             | Shen | TATIANA CLEVELAND   (not involved)  |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ________________________________________________________________________________
# // | Addresses : | FROM | CATRICALA FUNERAL HOME            | COMPUTER ANSWERS                  |
# // |             |      | 1597 US-9, Clifton Park, NY 12065 | 1602 US-9, Clifton Park, NY 12065 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             ________________________________________________________________________________
# // |             | TO   | ZACKARY KARELS "RESIDENCE"        | ZAPPONE DEALERSHIP                |
# // |             |      | 1769 US-9, Clifton Park, NY 12065 | 1780 US-9, Clifton Park, NY 12065 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Duration  : Approximately 2 hours
# // |             _____________________________________________________________________
# // | Evidence  : | Type, Book | Top Deck Awareness - Not News | Chapter 4 - The Week |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Narrative : Any assortment of the above listed parties were involved in a PREMEDITATED MURDER ATTEMPT
# // |             SOME of those parties were NOT INVOLVED and that is EXPLICITLY SPECIFIED, however they
# // |             are STILL SUSPECTS That means ANYONE in that box MAY be marked incorrectly, AND,
# // |             there may be MISSING PEOPLE that are supposed to be in that box.
# // |
# // |=======================================================================================================|
# // | The COVER UP (Part 1) (05/26/20 0200 or some point afterward)
# // |=======================================================================================================|
# // |
# // | Charge(s) : OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE
# // | Incident  : SCSO-2020-028501 (Continued, IMMEDIATELY AFTER the SECONDARY LOCATION)
# // | Reference : https://drive.google.com/file/d/12UZLRdCaHh4o1dPShFrcHn_jkTDZaAIA
# // |             _________________
# // | Time      : | 05/26/20 0155 |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             _______________________________________________
# // | Parties   : | SCSO | MICHAEL ZURLO   (Fucking definitely) |
# // |             | SCSO | JAMES LEONARD   (Fucking definitely) |
# // |             | SCSO | SCOTT SCHELLING (Fucking definitely) |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // |             _______________________________________________
# // | Address   : | CENTER FOR SECURITY                         |
# // |             | 1659 US-9, Clifton Park NY 12065            |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Duration  : <unknown>
# // |             __________________________________________________________________
# // | Evidence  : | Phone call records request, otherwise known as CELLULAR REBIDS |
# // |             ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# // | Narrative : Deleting the surveillance footage of TDDOS #2
# // |             <I told SCOTT SCHELLING about its existence> @ 05/26/20 0155
# // |             And, I would be willing to TESTIFY IN A COURT OF LAW.
# // |
# // |=======================================================================================================|
# // | The COVER UP (Part 2) (05/27/20 0905)
# // |=======================================================================================================|
# // | 
# // | Charge(s) : OBSTRUCTION OF JUSTICE, DESTRUCTION OF EVIDENCE 
# // | |========================================================================|                            |
# // | | [SCSO-2020-028501] Cont'd
# // | | MICHAEL ZURLO, JAMES LEONARD, CHRISTOPHER MURPHY, RYAN WARD       |                            |
# // | |      [APPLE CORPORATION, One Apple Park Way, Cupertino CA 95014]       |                            |
# // | |      ______________________________________________________________    |                            |
# // | |      | Disabling my iPhone 8+ 5 min. AFTER showing TROOPER LEAVEY |    |                            |
# // | |      | the VIDEO near 203D HALFMOON CIRCLE, CLIFTON PARK NY 12065 |    |                            |
# // | |      ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    |                            |
# // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                            |
# // | __________________________________________________________________________                            |
# // | | The COVER UP (Part 3) (05/27/20 1212)                                  |                            |
# // | |========================================================================|                            |
# // | | MANUFACTURING OF EVIDENCE/FRAMING (^ AKA IGNORING THOSE CRIMES)        |                            |
# // | |========================================================================|                            |
# // | | [SCSO-2020-003173] 36h LATE (Event 05/25/20 2343-05/26/20 0130)        |                            |
# // | | ZACKARY KAREL, JAMES LEONARD, ROBERT RYBAK                             |                            |
# // | | [1769 US-9, CLIFTON PARK, NY 12065]                                    |                            |
# // | ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯                            |
# // | __________________________________________________________________________                            |
# // | | The COVER UP (Part 4) (05/27/20 1414)                                  |                            |
# // | |========================================================================|                            |
# // | | - 1x MANUFACTURING OF EVIDENCE/FRAMING (^ AKA IGNORING THOSE CRIMES)   |                            |
# // | |   [SCSO-2020-003177] 69h LATE (Events 05/24/20 1715 + 05/25/20 2343)
# // | |   ERIC CATRICALA, JAMES LEONARD, SCOTT CARPENTER
# // | |   [1597 US-9, CLIFTON PARK, NY 12065] <= (3) days late
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯






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
