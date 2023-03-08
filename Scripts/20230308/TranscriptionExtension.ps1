Function New-TranscriptionCollection
{
    [CmdLetBinding()]Param(    
    [Parameter(Mandatory)][String]$Name,
    [Parameter()][String]$Date)
    
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
        [Int32]    $Index
        [String]    $Name
        [String] $Initial
        TranscriptionParty([Int32]$Index,[String]$Name)
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
        [UInt32]         $Index
        [Object]         $Party
        [String]          $Date
        [String]          $Time
        [String]      $Position
        [String]      $Duration
        [String]          $Type
        [String]          $Note
        TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            $This.Index    = $Index
            $This.Party    = $Party
            $This.Date     = $Position.Date
            $This.Time     = $Position.Time
            $This.Position = $Position.Position
            $This.Duration = [TimeSpan]$End - $This.Position
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
        [Object] TranscriptionParty([Int32]$Index,[String]$Name)
        {
            Return [TranscriptionParty]::New($Index,$Name)
        }
        [Object] TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            $xEnd = $This.Position($End)
            Return [TranscriptionEntry]::New($Index,$Party,$Position,$xEnd,$Note)
        }
        Write([String]$String)
        {
            [Console]::WriteLine($String)
        }
        AddParty([String]$Name)
        {
            If ($Name -in $This.Party.Name)
            {
                Throw "Party [!] [$Name] already specified"
            }

            $This.Party += $This.TranscriptionParty($This.Party.Count,$Name)

            $This.Write("Party [+] [$Name] added.")
        }
        AddEntry([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {   
            If ($Index -gt $This.Party.Count)
            {
                Throw "Party [!] [$Index] is out of bounds"
            }

            $This.Output += $This.TranscriptionEntry($This.Output.Count,
                                                     $This.Party[$Index],
                                                     $This.GetPosition($Position),
                                                     $End,
                                                     $Note)

            $This.Write("Entry [+] [$($This.Output[-1].Position)] added")
        }
        X([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $This.AddEntry($Index,$Position,$End,$Note)
        }
        [String] ToString()
        {
            Return "({0}/{1})" -f $This.Date, $This.Name
        }
    }

    Class TranscriptionHistoryItem
    {
        [UInt32]      $Index
        [UInt32]       $File
        [UInt32]       $Rank
        [String]      $Party
        [String]   $Position
        [TimeSpan] $Duration
        [String]       $Note
        TranscriptionHistoryItem([UInt32]$Index,[UInt32]$File,[Object]$Item)
        {
            $This.Index    = $Index
            $This.File     = $File
            $This.Rank     = $Item.Index
            $This.Party    = $Item.Party
            $This.Position = $Item.Position
            $This.Duration = $Item.Duration
            $This.Note     = $Item.Note
        }
        [String] ToString()
        {
            Return "{0}/{1}/{2}" -f $This.Index, $This.File, $This.Party
        }
    }

    Class TranscriptionHistoryList
    {
        [Object] $Output
        TranscriptionHistoryList()
        {
            $This.Output = @( )
        }
        [Object] TranscriptionHistoryItem([UInt32]$Index,[UInt32]$File,[Object]$Item)
        {
            Return [TranscriptionHistoryItem]::New($Index,$File,$Item)
        }
        Add([UInt32]$File,[Object]$Current)
        {
            $This.Output += $This.TranscriptionHistoryItem($This.Output.Count,$File,$Current.Output[-1])
        }
        Finalize()
        {
            $Time = [TimeSpan]::FromSeconds(0)

            ForEach ($Item in $This.Output)
            {
                $Item.Position = $Time.ToString()
                $Time          = $Time + [TimeSpan]$Item.Duration 
            }
        }
        [String] ToString()
        {
            Return "<TranscriptionHistory>"
        }
    }

    Class TranscriptionSection
    {
        [UInt32] $Index
        [String] $Name
        [String[]] $Content
        TranscriptionSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Content = $Content
        }
    }

    Class TranscriptionCollection
    {
        [String]           $Name
        [String]           $Date
        [Object]           $File
        [Object]        $History
        Hidden [Int32] $Selected
        [Object]        $Section
        TranscriptionCollection([String]$Name,[String]$Date)
        {
            $This.Name     = $Name
            $This.Date     = ([DateTime]$Date).ToString("MM/dd/yyyy")
            $This.File     = @( )
            $This.History  = $This.TranscriptionHistoryList()
            $This.Selected = -1
            $This.Section  = @( )
        }
        [Object] TranscriptionFile([UInt32]$Index,[String]$Name,[String]$Date,[String]$Start,[String]$Length,[String]$Url)
        {
            Return [TranscriptionFile]::New($Index,$Name,$Date,$Start,$Length,$Url)
        }
        [Object] TranscriptionParty([Int32]$Index,[String]$Name)
        {
            Return [TranscriptionParty]::New($Index,$Name)
        }
        [Object] TranscriptionEntry([UInt32]$Index,[Object]$Party,[Object]$Position,[String]$End,[String]$Note)
        {
            Return [TranscriptionEntry]::New($Index,$Party,$Position,$End,$Note)
        }
        [Object] TranscriptionHistoryList()
        {
            Return [TranscriptionHistoryList]::New()
        }
        [Object] TranscriptionSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            Return [TranscriptionSection]::New($Index,$Name,$Content)
        }
        Write([String]$Line)
        {
            [Console]::WriteLine($Line)
        }
        Check([UInt32]$Index)
        {
            If ($Index -gt $This.File.Count)
            {
                Throw "Invalid file index"
            }
        }
        [Object] Get([UInt32]$Index)
        {
            $This.Check($Index)

            Return $This.File[$Index]
        }
        [Object] Current()
        {
            If ($This.Selected -eq -1)
            {
                Throw "File not selected"
            }

            Return $This.File[$This.Selected]
        }
        Select([UInt32]$Index)
        {
            $This.Check($Index)

            $This.Selected = $Index
        }
        AddFile([String]$Name,[String]$Date,[String]$Start,[String]$Duration,[String]$Url)
        {
            $Item = $This.TranscriptionFile($This.File.Count,$Name,$Date,$Start,$Duration,$Url)

            $Out  = @( ) 
            $Out += "Added [+] File     : [{0}]" -f $Item.Name
            $Out += "          Date     : [{0}]" -f $Item.Date
            $Out += "          Duration : [{0}]" -f $Item.Duration
            $Out += "          Url      : [{0}]" -f $Item.Url
            $Out += " "
            
            $Out | % { $This.Write($_) }

            $This.File += $Item
        }
        AddFile([Object]$File)
        {
            $Item = $This.TranscriptionFile($This.File.Count,$File.Name,$File.Date,$File.Start,$File.Duration,$File.Url)

            $Out  = @( ) 
            $Out += "Added [+] File     : [{0}]" -f $Item.Name
            $Out += "          Date     : [{0}]" -f $Item.Date
            $Out += "          Duration : [{0}]" -f $Item.Duration
            $Out += "          Url      : [{0}]" -f $Item.Url
            $Out += " "
            
            $Out | % { $This.Write($_) }

            $This.File += $Item
        }
        AddParty([String]$Name)
        {
            $Current = $This.Current()

            If ($Name -in $Current.Party.Name)
            {
                Throw "Party [!] [$Name] already specified"
            }

            $Current.Party += $This.TranscriptionParty($Current.Party.Count,$Name)

            $This.Write("Party [+] [$Name] added.")
        }
        AddEntry([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $Current = $This.Current()

            If ($Index -gt $Current.Party.Count)
            {
                Throw "Party [!] [$Index] is out of bounds"
            }

            $Current.Output += $This.TranscriptionEntry($Current.Output.Count,
                                                        $Current.Party[$Index],
                                                        $Current.GetPosition($Position),
                                                        $Current.Position($End),
                                                        $Note)

            $This.History.Add($This.Selected,$Current)

            $This.Write("Entry [+] [$($Current.Output[-1].Position)] added")
        }
        AddContext([String]$Note)
        {
            $Current  = $This.Current()
            $Position = $Current.Output[-1].Position

            $Current.Output += $This.TranscriptionEntry($Current.Output.Count,
                                                        $This.TranscriptionParty(-1,"T X T"),
                                                        $Current.GetPosition($Position),
                                                        $Position,
                                                        $Note)

            $This.History.Add($This.Selected,$Current)

            $This.Write("Entry [+] [$($Current.Output[-1].Position)] added")
        }
        Finalize()
        {
            $This.History.Finalize()
        }
        X([UInt32]$Index,[String]$Position,[String]$End,[String]$Note)
        {
            $This.AddEntry($Index,$Position,$End,$Note)
        }
        C([String]$Note)
        {
            $This.AddContext($Note)
        }
        [String] Pad([String]$String,[UInt32]$Mode,[UInt32]$Length)
        {
            $Item = Switch ($Mode)
            {
                0 { $String.PadRight( $Length , " " ) }
                1 { $String.PadLeft(  $Length , " " ) }
            }

            Return $Item
        }
        [String] GetTitle()
        {
            Return "{0} [~] {1}" -f $This.Name, $This.Date
        }
        [String[]] GetSection()
        {
            $Out  = @( )
            $List = $This.History.Output | ? Party -eq Txt | ? Note -match "^\="

            ForEach ($Item in $List)
            {
                $Content = $Item.Note -Split "`n"
                $Out    += $Content[1].Substring(2,($Content[1].Length-4))
            }

            Return $Out
        }
        [String[]] GetFile()
        {
            $Out         = @{ }
            $Count       = $This.File.Count
            $Depth       = @{ 

                Index    = ([String]$Count).Length
                Name     = ($This.File.Name | Sort-Object Length)[-1].Length
            }

            If ($Depth.Index -lt 5)
            {
                $Depth.Index = 5
            }

            If ($Depth.Name -lt 4)
            {
                $Depth.Name = 4
            }

            ForEach ($Item in $This.File)
            {
                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad("Index",0,$Depth.Index),
                                                     $This.Pad("Name",0,$Depth.Name),
                                                     $This.Pad("Date",0,10),
                                                     $This.Pad("Start",0,8),
                                                     $This.Pad("End",0,8),
                                                     $This.Pad("Duration",0,8)
                $Out.Add($Out.Count,$Line)

                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad("-----",0,$Depth.Index),
                                                     $This.Pad("----",0,$Depth.Name),
                                                     $This.Pad("----",0,10),
                                                     $This.Pad("-----",0,8),
                                                     $This.Pad("---",0,8),
                                                     $This.Pad("--------",0,8)

                $Out.Add($Out.Count,$Line)

                $Line = "{0} {1} {2} {3} {4} {5}" -f $This.Pad($Item.Index,1,$Depth.Index),
                                                     $This.Pad($Item.Name,1,$Depth.Name),
                                                     $This.Pad($Item.Date,1,10),
                                                     $This.Pad($Item.Start,1,8),
                                                     $This.Pad($Item.End,1,8),
                                                     $This.Pad($Item.Duration,1,8)

                $Out.Add($Out.Count,$Line)
                $Out.Add($Out.Count," ".PadLeft(116," "))
                $Line = "[Url]: {0}" -f $Item.Url

                $Out.Add($Out.Count,$Line)
                $Out.Add($Out.Count," ".PadLeft(116," "))
            }

            Return $Out[0..($Out.Count-1)]
        }
        [String[]] GetOutput()
        {
            $Out      = @{ }
            $Count    = $This.History.Output.Count
            $Depth    = @{ 

                Index  = ([String]$Count).Length
                Party  = ($This.History.Output.Party | Sort-Object Length | Select-Object -Unique -Last 1).Length
                Buffer = 0
            }

            If ($Depth.Index -lt 5)
            {
                $Depth.Index = 5
            }

            If ($Depth.Party -lt 5)
            {
                $Depth.Party = 5
            }

            $Depth.Buffer = $Depth.Index + $Depth.Party + 10

            # Header
            $Line = "{0} {1} {2} {3}" -f $This.Pad("Index",0,$Depth.Index),
                                         $This.Pad("Party",0,$Depth.Party),
                                        "Position",
                                        "Note"
            $Out.Add(0,$Line)

            $Line = "{0} {1} {2} {3}" -f $This.Pad("-----",0,$Depth.Index),
                                         $This.Pad("-----",0,$Depth.Index),
                                        "--------",
                                        "----"

            $Out.Add(1,$Line)

            # Content
            ForEach ($X in 0..($This.History.Output.Count-1))
            {
                $Item    = $This.History.Output[$X]
                $Content = $Item.Note -Split "`n"

                If ($Item.Party -eq "TXT")
                {
                    $Line = "{0} {1} {2} " -f $This.Pad($Item.Index,0,$Depth.Index),
                                              $This.Pad($Item.Party,0,$Depth.Party),
                                              $Item.Position

                    $Line = $Line.PadRight(116,"=")

                    $Out.Add($Out.Count,$Line)
                    $Out.Add($Out.Count," ".PadRight(116," "))

                    ForEach ($Slice in $Content)
                    {
                        $Out.Add($Out.Count,"    $Slice")
                    }

                    $Out.Add($Out.Count," ".PadRight(116," "))
                    $Out.Add($Out.Count,"=".PadRight(116,"="))
                }

                Else
                {
                    If ($Content.Count -eq 1)
                    {
                        $Line = "{0} {1} {2} $content" -f $This.Pad($Item.Index,0,$Depth.Index),
                                                          $This.Pad($Item.Party,0,$Depth.Party),
                                                          $Item.Position
                                                    

                        $Out.Add($Out.Count,$Line)
                    }
                    If ($Content.Count -gt 1)
                    {
                        $C = 0
                        ForEach ($Slice in $Content)
                        {
                            If ($C -eq 0)
                            {
                                $Line = "{0} {1} {2} {3}" -f $This.Pad($Item.Index,0,$Depth.Index),
                                                             $This.Pad($Item.Party,0,$Depth.Party),
                                                             $Item.Position,
                                                             $Slice
                            }
                            Else
                            {
                                $Line = "{0} {1}" -f " ".PadRight($Depth.Buffer," "),
                                                    $Slice
                            }

                            $C ++
                            $Out.Add($Out.Count,$Line)
                        }
                    }
                }

                $Out.Add($Out.Count," ".PadRight(116," "))
            }

            Return $Out[0..($Out.Count-1)]
        }
        [String] ToString()
        {
            Return "({0}) <TranscriptionCollection>" -f $This.File.Count
        }
    }

    If (!$Date)
    {
        $Date = [DateTime]::Now.ToString("MM/dd/yyyy")
    }

    [TranscriptionCollection]::New($Name,$Date)
}

Class RecordingFile
{
    [UInt32]           $Index
    [String]            $Name
    Hidden [String] $Fullname
    [String]            $Date
    [String]            $Time
    [String]        $Duration
    [String]             $Url
    RecordingFile([UInt32]$Index,[Object]$Folder,[Object]$Item)
    {
        $This.Index    = $Index
        $This.Name     = $Item.Name
        $This.Fullname = $Item.Fullname
        $This.Duration = $Folder.GetDetailsOf($Item,27)

        If ($This.Name -match "^\d{4}(_\d{2}){5}")
        {
            $S         = $Matches[0] -Split "_"
            $This.Date = $S[1,2,0] -join "/"
            $This.Time = $S[3,4,5] -join ":"
        }
        Else
        {
            $End       = $Folder.GetDetailsOf($Item,3)
            $Start     = [DateTime]($End - [TimeSpan]$This.Duration)
            $This.Date = $Start.ToString("MM/dd/yyyy")
            $This.Time = $Start.ToString("HH:mm:ss")
        }
    }
    SetUrl([String]$Url)
    {
        $This.Url      = $Url
    }
}

Class RecordingFolder
{
    [String]   $Path
    [Object] $Folder
    [UInt32]  $Total
    [Object]   $File
    RecordingFolder([String]$Path)
    {
        If (![System.IO.Directory]::Exists($Path))
        {
            Throw "Invalid path"
        }

        $This.Path   = $Path
        $This.Folder = $This.GetFolder()
        $This.Refresh()
    }
    Clear()
    {
        $This.File   = @( )
        $This.Total  = 0
    }
    Refresh()
    {
        $This.Clear()

        $List      = @($This.Folder.Items())
        $Step      = [Math]::Round($List.Count/100)
        $Stage     = 0..100 | % { $Step * $_ }
        $Stage[-1] = $List.Count
        $C         = 0

        Write-Progress -Activity "Collecting" -Status ("{0:p}" -f 0) -PercentComplete 0
        ForEach ($X in 0..($List.Count-1))
        {
            If ($X -in $Stage)
            {
                Write-Progress -Activity "Collecting" -Status ("{0:p}" -f ($C/100)) -PercentComplete $C
                $C ++
            }

            $This.Add($List[$X])
        }
        Write-Progress -Activity "Collected" -Status ("{0:p}" -f 100) -Complete
    }
    [Object] GetFolder()
    {
        Return (New-Object -ComObject Shell.Application).Namespace($This.Path)
    }
    [Object] GetFile([UInt32]$Index,[Object]$Item)
    {
        Return [RecordingFile]::New($Index,$This.Folder,$Item)
    }
    Add([Object]$Item)
    {
        $This.File  += $This.GetFile($This.Total,$Item)
        $This.Total  = $This.File.Count
    }
}

$Base = [RecordingFolder]::New("$Home\Documents\Recordings")
$File = $Base.File | ? Name -match 2023_03_07
$File.SetUrl("https://drive.google.com/file/d/1GKdbcmL5rTYLOtwdo-vEV_V3Zf-xBCNd")

$Ctrl = New-TranscriptionCollection -Name "Content Selection"
$Ctrl.AddFile($File)
