Class Entry
{
    [UInt32] $Index
    [String] $Name
    [String] $Url
    Entry([UInt32]$Index,[String]$Name,[String]$Url)
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

        $This.Output += [Entry]::New($This.Output.Count,$Name,$Url)
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

Class Responder
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
    Responder([UInt32]$Index,[String]$Name,[String]$Unit)
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
        $This.Output += [Responder]::New($This.Count,$Name,$Unit)
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
    Record([UInt32]$Index,[String]$Name,[String]$Date,[String]$Transmit)
    {
        $This.Index     = $Index
        $This.Name      = $Name
        $This.Date      = $Date.Split(" ")[0]
        $This.Receive   = [DateTime]$Date
        $This.Transmit  = [DateTime]$Transmit
        $This.Elapsed   = [TimeSpan]($This.Transmit-$This.Receive)

        $This.ResponderList()
        $This.EntryList()
    }
    ResponderList()
    {
        $This.Responder = [ResponderList]::New()
    }
    EntryList()
    {
        $This.Entry     = [EntryList]::New()
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
