Class TranscriptionDateTime
{
    [DateTime] $DateTime
    [String]       $Date
    [String]       $Time
    [TimeSpan] $Position
    TranscriptionDateTime([String]$Date,[String]$Time)
    {
        $This.Position = [TimeSpan]"00:00"
        $This.DateTime = [DateTime]"$Date $Time"
        $This.SetDateTime()
    }
    TranscriptionDateTime([Switch]$Flags,[Object]$Start,[String]$Position)
    {
        $This.Position = [TimeSpan]$Position 
        $Current       = $Start.DateTime + $This.Position
        $This.DateTime = $Current
        $This.SetDateTime()
    }
    SetDateTime()
    {
        $This.Date     = $This.DateTime.ToString("MM/dd/yyyy")
        $This.Time     = $This.DateTime.ToString("HH:mm:ss")
    }
    [String] ToString()
    {
        Return $This.DateTime.ToString("MM/dd/yyyy HH:mm:ss")
    }
}

Class TranscriptionParty
{
    [UInt32]   $Index
    [String]    $Name
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

Class TranscriptionEntry
{
    [UInt32]    $Index
    [Object]    $Party
    [String]     $Date
    [String]     $Time
    [String] $Position
    [String]     $Type
    [String]     $Note
    TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$Note)
    {
        $This.Index    = $Index
        $This.Party    = $Party
        $This.Date     = $Position.Date
        $This.Time     = $Position.Time
        $This.Position = $Position.Position
        $This.Type     = Switch -Regex ($Note)
        {
            "^\*{1}" { "Action"    }
            "^\:{1}" { "Statement" }
            "^\#{1}" { "Context"   }
        }
        $This.Note     = $Note.Substring(1)
    }
    [String] ToString()
    {
        Return "[{0}] <{1}> {2}" -f $This.Time,$This.Party.Initial, $This.Note
    }
}

Class TranscriptionFile
{
    [UInt32]       $Index
    [String]        $Name
    Hidden [Object] $Time
    [String]        $Date
    [String]       $Start
    [String]         $End
    [String]    $Duration
    [String]         $Url
    [Object]       $Party
    [Object]      $Output
    TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
    {
        $This.Index    = $Index
        $This.Name     = $Name
        $This.Time     = $This.DateTime($Date,$Start)
        $This.Date     = $This.Time.Date
        $This.Start    = $This.Time.Time
        $This.Duration = $This.Position($Duration)
        $This.End      = ([DateTime]"$Date $Start" + [TimeSpan]$Duration).ToString("HH:mm:dd")
        $This.Url      = $Url
        $This.Party    = @( )
        $This.Output   = @( )
    }
    [String] Position([String]$In)
    {
        $Out = Switch -Regex ($In)
        {
            "^\d{1}:\d{2}$" { "00:0$In"} 
            "^\d{2}:\d{2}$" { "00:$In" } 
            Default { $In }
        }

        Return $Out
    }
    [Object] DateTime([String]$Date,[String]$Start)
    {
        Return [TranscriptionDateTime]::New($Date,$Start)
    }
    [Object] GetPosition([String]$Position)
    {
        $Position = $This.Position($Position)
        Return [TranscriptionDateTime]::New([Switch]$True,$This.Time,$Position)
    }
    [Object] TranscriptionParty([UInt32]$Index,[String]$Name)
    {
        Return [TranscriptionParty]::New($Index,$Name)
    }
    [Object] TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$Note)
    {
        Return [TranscriptionEntry]::New($Index,$Party,$Position,$Note)
    }
    AddParty([String]$Name)
    {
        If ($Name -in $This.Party.Name)
        {
            Throw "Party [!] [$Name] already specified"
        }

        $This.Party += $This.TranscriptionParty($This.Party.Count,$Name)
        Write-Host "Party [+] [$Name] added."
    }
    AddEntry([UInt32]$Index,[String]$Position,[String]$Note)
    {   
        If ($Index -gt $This.Party.Count)
        {
            Throw "Party [!] [$Index] is out of bounds"
        }

        $Person       = $This.Party[$Index]
        $xTime        = $This.GetPosition($Position)

        $This.Output += [TranscriptionEntry]::New($This.Output.Count,$Person,$xTime,$Note)
        Write-Host "Entry [+] [$($xTime.Position)] added"
    }
    X([UInt32]$Index,[String]$Position,[String]$Note)
    {
        $This.AddEntry($Index,$Position,$Note)
    }
}

Class TranscriptionCollection
{
    [String] $Date
    [String] $Name
    [Object] $File
    TranscriptionCollection([String]$Date,[String]$Name)
    {
        $This.Date   = $Date
        $This.Name   = $Name
        $This.File   = @( )
    }
    [Object] TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Length,[String]$Url)
    {
        Return [TranscriptionFile]::New($Index,$Name,$Date,$Start,$Length,$Url)
    }
    [Object] Get([UInt32]$Index)
    {
        If ($Index -gt $This.File.Count)
        {
            Throw "Invalid file index"
        }

        Return $This.File[$Index]
    }
    AddFile([String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
    {
        $Item = $This.TranscriptionFile($This.File.Count,$Name,$Date,$Start,$Duration,$Url)

        $Out  = @( ) 
        $Out += "Added [+] File     : [{0}]" -f $Item.Name
        $Out += "          Date     : [{0}]" -f $Item.Date
        $Out += "          Duration : [{0}]" -f $Item.Duration
        $Out += "          Url      : [{0}]" -f $Item.Url 
        
        $Out | % { [Console]::WriteLine($_) }

        $This.File += $Item
    }
}
