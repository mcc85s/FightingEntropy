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
        [String[]] GetCurrent()
        {
            $Out      = @{ }
            $Current  = $This.Current()
            $Count    = $Current.Output.Count
            $Depth    = @{ 

                Index  = ([String]$Count).Length
                Party  = ($Current.Output.Party | Sort-Object Length | Select-Object -Unique -Last 1).Length
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
            ForEach ($X in 0..($Current.Output.Count-1))
            {
                $Item    = $Current.Output[$X]
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

$Ctrl = New-TranscriptionCollection -Name "Catricala - Tanski"
$Ctrl.AddFile("20230302.mp4","03/02/2023","13:16:52","00:05:21","https://drive.google.com/file/d/1evNeAtEHwpA9tIs8qtuoavV6irB85xgX")

# Parties
$Ctrl.Select(0)
$Ctrl.AddParty("Michael C. Cook Sr.")
$Ctrl.AddParty("Eric Catricala")
$Ctrl.AddParty("Marjorie Taylor Greene")
$Ctrl.AddParty("DJ Kuhn")
$Ctrl.AddParty("Manager Dude")

$Ctrl.Select(0)
$Ctrl.X(0,"00:00","00:12",@'
:Gonna have a conversation with Eric Catricala... And there he is.
'@)

$Ctrl.X(1,"00:12","00:13",@'
:Turn that fuckin' thing off right now.
'@)

$Ctrl.X(0,"00:14","00:15",@'
:Why, whaddya gonna do...?
'@)

$Ctrl.X(1,"00:14","00:17",@'
:Why, because I know who you are, you know who I am...
'@)

$Ctrl.X(0,"00:17","00:17",@'
:Yeah.
'@)

$Ctrl.X(1,"00:17","00:19",@'
:And I'm tired of your bullshit.
'@)

$Ctrl.X(0,"00:19","00:20",@'
:Oh- tired of my bullshit...?
'@)

$Ctrl.X(1,"00:20","00:20",@'
:Yes.
'@)

$Ctrl.X(0,"00:20","00:22",@'
:What exactly is my bullshit...?
'@)

$Ctrl.X(1,"00:22","00:24",@'
:I don't want to be on the internet.
'@)

$Ctrl.X(0,"00:24","00:31",@'
:Well, I don't give a shit.
You like slandered me in a fuckin' record with uh- Scott Carpenter in
SCSO-2020-
'@)

$Ctrl.X(1,"00:31","00:32",@'
:I don't even know who that is.
'@)

$Ctrl.X(0,"00:31","00:33",@'
:003177. Slander...?
'@)

$Ctrl.X(1,"00:33","00:34",@'
:Who's- who's that...?
'@)

$Ctrl.X(1,"00:33","00:40",@'
:Uh- it's a record from Saratoga County Sheriffs Office.
You contacted James Leonard, right...?
'@)

$Ctrl.X(1,"00:40","00:42",@'
:Alright, just, get out of my way...
'@)

$Ctrl.X(0,"00:42","00:55",@'
:You reported an incident that occurred on May 24th, and passed off surveillance 
footage as being on the 25th. Right...? So, you wanna have a conversation, uh- I
can, I can turn this this off, and we can have a conversation and we can f****** 
issues.
'@)

$Ctrl.X(1,"00:55","01:01",@'
:You know what...?
Get out of my way...
So I can leave this parking spot.
'@)

$Ctrl.X(0,"01:01","01:05",@'
:You live on Anchor Drive, right...?
Right next to uh- Doug Bagely's grandmother...?
'@)

$Ctrl.X(1,"01:05","01:09",@'
:You know what, I'm not answering-
I am not answering any questions.
'@)

$Ctrl.X(0,"01:09","01:11",@'
:Ok you're part of the Town of Halfmoon Town Board, right...?
'@)

$Ctrl.X(1,"01:11","01:12",@'
:Yes I am.
'@)

$Ctrl.X(0,"01:12","01:13",@'
:With uh- Kevin Tollisen...?
'@)

$Ctrl.X(1,"01:13","01:14",@'
:Yes I work with Kevin Tollisen.
'@)

$Ctrl.X(0,"01:13","01:17",@'
:Do you remember the conversation we had on May 24th- 2020...?
'@)

$Ctrl.X(2,"01:17","01:18",@'
:Do you want me to call the cops...?
'@)

$Ctrl.X(1,"01:18","01:23",@'
:I've had NO conversations with you. (that's bullshit because of the record)
I want you out of my way... so I can leave this parking lot.
'@)
      
$Ctrl.X(3,"01:23","01:24",@'
:*shows me his badge* Move it.
'@)

$Ctrl.X(0,"01:24","01:27",@'
:What's your name...?
*pauses* I know who you are, DJ Kuhn.
'@)

$Ctrl.X(3,"01:27","01:28",@'
:Yeah, you're right.
'@)

$Ctrl.X(0,"01:28","01:31",@'
:Right.

You're the guy-

You used to be the D.A.R.E. officer.
'@)

$Ctrl.X(3,"01:31","01:33",@'
:The owner wants you out of here.
'@)

$Ctrl.X(0,"01:33","01:40",@'
:The owner, ok.

Uh- well did you know that Bruce Tanski, like, was investigated by the FBI,
and I told him about that on May 24th-
'@)

$Ctrl.X(1,"01:40","01:42",@'
:I don't have anything to do with that.
'@)

$Ctrl.X(0,"01:42","01:43",@'
:2020...?
I know, it's like-
'@)

$Ctrl.X(4,"01:43","01:47",@'
:Sir, look at me.

I'm the manager of this place (Tony Fiorino used to do your job dude.)

You're disrupting my business...

I need you to leave.
'@)

$Ctrl.X(0,"01:47","01:47",@'
:Ok.
'@)

$Ctrl.X(4,"01:47","01:48",@'
:You can do this anywhere else you want...?
'@)

$Ctrl.X(0,"01:48","01:49",@'
:What's your name...?
'@)

$Ctrl.X(4,"01:49","01:51",@'
:...I don't care.

My name's none of your business.
'@)

$Ctrl.X(0,"01:51","01:54",@'
:Oh, it is, because I've been like-

How long have you owned this business...?
'@)

$Ctrl.X(4,"01:54","01:56",@'
:I'm not owning it, I'm managing it.
'@)

$Ctrl.X(0,"01:56","01:58",@'
:Oh, well, he told me that you're the owner. (<- I assumed that)
'@)

$Ctrl.X(4,"01:58","02:01",@'
:Well, yes, the owner DOES want you gone, because the owner told me to-
if you came here-
'@)

$Ctrl.X(0,"02:01","02:01",@'
:Just now...?
'@)

$Ctrl.X(4,"02:01","02:04",@'
:...to ask you to leave.
No, beforehand.
'@)

$Ctrl.X(0,"02:002","02:04",@'
:Is his name Bruce Tanski...?
'@)

$Ctrl.X(4,"02:04","02:05",@'
:His name IS Bruce Tanski, yes.
'@)

$Ctrl.X(0,"02:05","02:07",@'
:Yeah, well, I thought he sold it...?
'@)

$Ctrl.X(4,"02:07","02:07",@'
:That does not concern me.
'@)

$Ctrl.X(0,"02:07","02:08",@'
:But Bruce Tanski is a criminal.
'@)

$Ctrl.X(4,"02:09","02:11",@'
:You can think of what you want, that's your opinion.
'@)

$Ctrl.X(0,"02:11","02:13",@'
:Well, he was investigated by the FBI.
'@)

$Ctrl.X(4,"02:13","02:14",@'
:Has he been convicted...?
'@)

$Ctrl.X(0,"02:14","02:15",@'
:Yeah, he has~!
'@)

$Ctrl.X(4,"02:15","02:17",@'
:Is he not in jail, so...?
'@)

$Ctrl.X(0,"02:17","02:19",@'
:Whether he's convicted or not, doesn't mean that he's not guilty.
'@)

$Ctrl.X(4,"02:19","02:22",@'
:Sir, you have (2) minutes before I call the cops, and you are taken away. (OOooOOohhHh~!)
'@)

$Ctrl.X(0,"02:22","02:23",@'
:Oh, ok.
'@)

$Ctrl.X(4,"02:23","02:24",@'
:I am letting you know this, right now.
'@)

$Ctrl.X(0,"02:24","02:28",@'
:Ok, (2) minutes.
Recording it all...
You're giving me (2) minutes to leave, right...?
'@)

$Ctrl.X(4,"02:29","02:29",@'
:Yeah.
'@)

$Ctrl.X(0,"02:29","02:34",@'
:I've been a customer here for about 35 years.
I've lived in town since 1987.
Ok...?
'@)

$Ctrl.X(4,"02:34","02:35",@'
:Does that concern me...?
'@)

$Ctrl.X(0,"02:35","02:41",@'
:I've known Bruce Tanski's niece, Elaina Tanski, since Skano Elementary
when he used to be the DARE officer.
'@)

$Ctrl.X(4,"02:41","02:43",@'
:Does THAT concern me...?
'@)

$Ctrl.X(0,"02:43","02:46",@'
:OooooOooOHhhh, it DOES have stuff to do, I KNOW the people in this fuckin' town.
'@)

$Ctrl.X(4,"02:46","02:46",@'
:Sir...
'@)

$Ctrl.X(0,"02:46","02:54",@'
:And when I like, start to have like uh- conversations with people, oh, well Deputy Kuhn is
Deputy Kuhn issued my father, uh- a ticket-
'@)

$Ctrl.X(4,"02:54","02:56",@'
:He's calling the cops, I'm just letting you know that. (He showed me his badge)
'@)

$Ctrl.X(0,"02:56","02:56",@'
:Ok.
'@)

$Ctrl.X(4,"02:56","02:58",@'
:You have less than (2) minutes to get out of here, before the cops show up.
'@)

$Ctrl.X(0,"02:58","03:00",@'
:But you gave me (2) minutes, it hasn't been (2) minutes yet.
'@)

$Ctrl.X(4,"03:00","03:01",@'
:Yeah, I'm letting you know, (2) minutes before I call-
'@)

$Ctrl.X(0,"03:01","03:04",@'
:Just because somebody calls the cops doesn't mean that there's an incident quite yet.
'@)

$Ctrl.X(4,"03:04","03:05",@'
:No, but the incident-
'@)

$Ctrl.X(0,"03:05","03:10",@'
:If you're telling me to leave because you're gonna have me arrested for trespassing, 
I'll leave but you gave me (2) minutes. That was a minute ago.
'@)

$Ctrl.X(4,"03:10","03:12",@'
:So what do we got, less than a minute now...?
Perfect.
'@)

$Ctrl.X(0,"03:12","03:38",@'
:Mr. Kuhn... Salute you, thank you for uh- you know, being the DARE officer
when my father was murdered in 1995, a group of people were involved in
having him killed, and you're basically consorting with- uh- Eric Catricala.

I'm tryin' to tell people that the cops AND HIM committed a crime on May 24th, 2020 
and May 25th, 2020 and the cops have been like, dragging their lazy dicks.

And I know exactly where you used to live, and probably where you STILL live.
'@)

$Ctrl.X(1,"03:38","03:40",@'
:So, what does that have to do with me...? (<- Because the incident began outside of your business)
'@)

$Ctrl.X(0,"03:40","03:44",@'
:Have a conversation with me outside of here, and I'll fuckin' make sure this 
doesn't hit the internet.
'@)

$Ctrl.X(4,"03:44","03:47",@'
:Lets deesecalate the situation, Michael. (So, he knows my name.)
'@)

$Ctrl.X(0,"03:47","03:50",@'
:Deescalate the situation by saying 'OK, lets have a conversation'.
'@)

$Ctrl.X(4,"03:50","03:52",@'
:Well, he doesn't wanna have one right now. (I can understand that.)
'@)

$Ctrl.X(0,"03:52","03:55",@'
:Ok, well, basically that's why I'm making the record. (But- not now, nor later.)
'@)

$Ctrl.X(4,"03:55","03:56",@'
:Has it been (2) minutes yet...?
'@)

$Ctrl.X(0,"03:56","03:58",@'
:It has.
'@)

$Ctrl.X(4,"03:58","04:07",@'
:Off of all of his property, too.
The rest of the plaza as well. (<- I don't think they can legally do that)
Have a good day.
'@)

$Ctrl.X(0,"04:07","04:08",@'
:What's your name...?
'@)

$Ctrl.X(4,"04:08","04:10",@'
:I'm not telling you my name.
'@)

$Ctrl.X(0,"04:10","04:12",@'
:Oh, ok well uh- I'm gonna be releasing the video.
'@)

$Ctrl.X(4,"04:12","04:15",@'
:You're not releasing the video, if I don't give you permission.
'@)

$Ctrl.X(0,"04:15","04:17",@'
:It doesn't matter, I can release it anyway...
'@)

$Ctrl.X(4,"04:17","04:18",@'
:Whatever you want.
'@)

$Ctrl.X(0,"04:18","04:19",@'
:Ok.
'@)

$Ctrl.X(4,"04:19","04:19",@'
:I don't care. (<- Yeah he does.)
'@)

$Ctrl.X(0,"04:19","04:19",@'
:Yeh.
'@)

$Ctrl.X(4,"04:19","04:29",@'
:I'm just allowing you to know that you gotta be off the property, and thank you
for staying off the property. Next time you are here, without permission, me
or Bruce Tanski, you will be escorted off the property.
'@)

$Ctrl.X(0,"04:29","04:30",@'
:Ok, cool.
'@)

$Ctrl.X(4,"04:30","04:31",@'
:Just letting you know.
Thank you.
'@)

$Ctrl.X(0,"04:31","04:32",@'
:Thanks, buddy.
'@)

$Ctrl.X(4,"04:32","04:33",@'
:Have a great one.
'@)

$Ctrl.X(0,"04:33","04:35",@'
:Shove a dildo in your asshole while you're at it.
'@)

$Ctrl.X(4,"04:35","04:39",@'
:That doesn't really need to happen...
THAT is a stupid fuckin' comment you made...
'@)

$Ctrl.X(0,"04:39","04:41",@'
:Why, wha- what's gonna happen...?
'@)

$Ctrl.X(4,"04:41","04:43",@'
:Nothin's gonna happen, but if you say somethin' like that ever again...
'@)

$Ctrl.X(0,"04:43","04:44",@'
:Shove a dildo in your asshole...?
'@)

$Ctrl.X(4,"04:43","04:45",@'
:...on this property... you're gonna get thrown off. (<- I never said that comment on the property)
'@)

$Ctrl.X(0,"04:45","04:47",@'
:Shoving your dildo- shoving a dildo in your asshole...?
'@)

$Ctrl.X(4,"04:47","04:48",@'
:Better keep fuckin' walkin'...
'@)

$Ctrl.X(0,"04:48","04:58",@'
:Why, whaddya gonna do, shove a dildo in your asshole and walk away...?
Fuckin' call the cops on me and have Michael Zurlo fuckin' have me arrested
for somethin' I didn't fuckin' do..?

Yeah.

That's what HE did.
'@)

$Ctrl.X(4,"04:58","05:00",@'
:*wavin' hand around, unintelligible*
'@)

$Ctrl.X(0,"05:00","05:04",@'
:Whatever, dude.
I'll find out your fuckin' name.
I'll find out your fuckin' name.
'@)

$Ctrl.X(4,"05:04","05:05",@'
:You're not~!
'@)

$Ctrl.X(0,"05:05","05:07",@'
:Oh, I'm not gonna find out your name...?
'@)

$Ctrl.X(4,"05:07","05:08",@'
:No~!
'@)

$Ctrl.X(0,"05:08","05:23",@'
:Oh, ok.
I will~!
I guarantee you I'll find out your fuckin' name.

And then, once I find out your fuckin' name, I'm gonna make a document that fuckin' 
like, puts him [DJ Kuhn], and him [Eric Catricala], and [you], all in the [same record]
with [Bruce Tanski], because I've been [investigating] his ass.
'@)
