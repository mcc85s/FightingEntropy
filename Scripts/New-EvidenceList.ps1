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
        [String] $Name
        [String] $Date
        [String] $Url
        Hidden [UInt64] $Size
        [String] $SizeMb
        [Object] $Hash
        [String[]] $Notes
        Hidden [Object] $Content
        Exhibit([UInt32]$Index,[String]$Name,[String]$Date,[String]$URL,[String]$Notes)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Date    = $Date
            $This.URL     = $URL
            $This.Notes   = $Notes -Split "`n"

            Write-Host "Invoking [~] [$($this.URL)]"
            $This.Content = Invoke-RestMethod $This.URL
            $This.Size    = $This.Content.Length
            $This.SizeMb  = "{0:n3} MB" -f ($This.Size/1MB)

            Write-Host "Creating [~] Temp file"
            $Temp         = New-TemporaryFile

            Write-Host "Setting [~] Content"
            Set-Content $Temp.Fullname $This.Content
            
            Write-Host "Getting [~] File hash"
            $This.Hash    = Get-FileHash $Temp.Fullname | % Hash
            
            Write-Host "Removing [~] File"
            Remove-Item $Temp
        }
        [Object[]] Slot()
        {
            Return @( "Index Name Date Url SizeMb Hash" -Split " " | % { $This.$_ } )
        }
        [String] Pad([UInt32]$Length,[String]$Char,[String]$String)
        {
            $Buffer  = $Length - $String.Length
            $Padding = $Char * ($Buffer-2)
            Return "{0}{1} |" -f $String, $Padding
        }
        [String[]] Output()
        {
            $Obj     = @{0="";1="";2="";3="";4="";5="";6="";7=""}
            $X       = ($This.Slot() | % Length | Sort-Object)[-1] + 12
            $Obj[0]  = @([char]95) * $X -join ''
            $Obj[1]  = $This.Pad($X," ","| Index : $($This.Index)")
            $Obj[2]  = $This.Pad($X," ","| Name  : $($This.Name)")
            $Obj[3]  = $This.Pad($X," ","| Date  : $($This.Date)")
            $Obj[4]  = $This.Pad($X," ","| Url   : $($This.Url)")
            $Obj[5]  = $This.Pad($X," ","| Size  : $($This.SizeMb)")
            $Obj[6]  = $This.Pad($X," ","| Hash  : $($This.Hash)")
            $Obj[7]  = @([char]175) * $X -join ''

            $This.Notes | % { $Obj.Add($Obj.Count,$_) }

            Return @($Obj[0..($Obj.Count-1)])
        }
        [String[]] Comment()
        {
            Return @( $This.Output() | % { "# $_ "} )
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
        AddExhibit([String]$Name,[String]$Date,[String]$URL,[String]$Comment)
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
            $This.Exhibit += [Exhibit]::New($This.Exhibit.Count,$Name,$Date,$URL,$Comment)
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
