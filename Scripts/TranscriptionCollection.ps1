
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

Class TranscriptionFile
{
    [UInt32]    $Index
    [String]     $Name
    [String]     $Date
    [String]    $Start
    [String]      $End
    [String] $Duration
    [String]      $Url
    [Object]    $Party
    [Object]   $Output
    TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
    {
        $This.Index    = $Index
        $This.Name     = $Name
        $This.Date     = $Date
        $This.Start    = $Start
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
    X([UInt32]$Index,[String]$Position,[String]$Note)
    {
        $This.AddEntry($Index,$Position,$Note)
    }
    [Object] Tx([String]$Position)
    {
        Return [TranscriptionTime]::New($This.Start,$Position)
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
    AddFile([String]$Name,[String]$Date,[String]$Start,[String]$Length,[String]$Url)
    {
        $This.File += $This.TranscriptionFile($This.File.Count,$Name,$Date,$Start,$Length,$Url)
    }
}
