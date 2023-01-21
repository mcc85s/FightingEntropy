Function Build-Discography
{
    [CmdLetBinding()]Param([Parameter(Mandatory,Position=0)][String]$Name)

    Class QueueItem
    {
        [UInt32] $Index
        [UInt32] $Rank
        [String] $Type
        [String] $Hash
        [String] $Url
        [UInt32] $Exists
        [String] $Fullname
        QueueItem([UInt32]$Index,[UInt32]$Rank,[String]$Type,[String]$Hash)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Type  = $Type
            $This.Hash  = $Hash
            $This.Url   = "https://youtu.be/$Hash"
        }
    }

    Class PlayListItem
    {
        [UInt32]      $Index
        [String]       $Name
        [String]       $Hash
        [TimeSpan]   $Length
        [String]   $Fullname
        [String]    $NewName
        PlayListItem([UInt32]$Index,[String]$Name,[String]$Hash,[String]$Length)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Hash   = $Hash
            $This.Length = [Timespan]"00:$Length"
        }
    }

    Class PlayList
    {
        [UInt32] $Index
        [String] $Name
        [String] $Path
        [Object] $Output
        PlayList([Object]$Disc,[UInt32]$Index)
        {
            $This.Index  = $Index
            $Album       = $Disc.Get($This.Index)
            $This.Name   = "{0} - {1} ({2})" -f $Disc.Name, $Album.Name, $Album.Year
            $This.Path   = $Disc.Path
            $This.Output = @( )
        }
        Add([String]$Name,[String]$Hash,[String]$Length)
        {
            $Item          = [PlayListItem]::New($This.Output.Count,$Name,$Hash,$Length)
            $Item.Fullname = $This.List | ? Name -match $Item.Hash | % Fullname
            $Item.NewName  = "{0}\{1}[{2:d2}] - {3}.mp3" -f $This.Path, $This.Name, $Item.Index, $Item.Name
            $This.Output  += $Item
        }
        Rename()
        {
            ForEach ($Item in $This.Output)
            {   
                [System.IO.File]::Move($Item.FullName,$Item.NewName)
                $Item.Fullname = $Item.NewName
                $Item.NewName  = $Null
            }
        }
    }

    Class Track
    {
        [UInt32]      $Index
        [TimeSpan] $Position
        [String]       $Name
        [TimeSpan]   $Length
        Track([UInt32]$Index,[String]$Name,[String]$Length)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Length  = $Length
        }
    }

    Class Album
    {
        [UInt32]    $Index
        [String]     $Name
        [UInt32]     $Year
        [String]     $Hash
        [TimeSpan] $Length
        [Object]    $Track
        Album([UInt32]$Index,[String]$Name,[UInt32]$Year)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Year   = $Year
            $This.Length = [TimeSpan]"00:00:00"
            $This.Track  = @()
        }
        SetHash([String]$Hash)
        {
            $This.Hash   = $Hash
        }
        AddTrack([String]$Name,[String]$xLength)
        {
            If ($xLength -match "^\d{1}:\d{2}$")
            {
                $xLength = "0$xLength"
            }

            If ($xLength -match "\d{2}:\d{2}")
            {
                $xLength = "00:$xLength"
            }

            $Item          = [Track]::New($This.Track.Count,$Name,$xLength)
            $Item.Position = $This.Length
            $This.Length   = $This.Length + $Item.Length
            $This.Track   += $Item

            Write-Host "Added [+] Track: [$Name], Length: [$xLength]"
        }
        [String] ToString()
        {
            Return "{0} ({1})" -f $This.Name, $This.Year
        }
    }

    Class Discography
    {
        [String]  $Name
        [String]  $Path
        [Object] $Album
        [Object] $Queue
        Discography([String]$Name)
        {
            $This.Name  = $Name
            $This.Path  = Get-Item Variable:\Home | % Value
            $This.Album = @( )
            $This.Queue = @( )
        }
        AddAlbum([String]$Name,[UInt32]$Year)
        {
            $This.Album += [Album]::New($This.Album.Count,$Name,$Year)
            Write-Theme "Added [+] Album: [$Name ($Year)]"
            Start-Sleep -Milliseconds 125
        }
        [Object] BuildPlayList([UInt32]$Index)
        {
            Return [PlayList]::New($This,$Index)
        }
        SetHash([UInt32]$Index,[String]$Hash)
        {
            $xAlbum = $This.Get($Index)
            $xAlbum.SetHash($Hash)
            $This.AddQueue($Index,"Album",$Hash)
        }
        AddPlayList([Object]$List)
        {
            $xAlbum      = $This.Get($List.Index)
            ForEach ($Track in $List.Output)
            {
                $xAlbum.AddTrack($Track.Name,$Track.Length)
                $This.AddQueue($List.Index,"Track",$Track.Hash)
            }
        }
        AddTrack([UInt32]$Index,[String]$Name,[String]$Length)
        {
            $Item       = $This.Get($Index)
            $Item.AddTrack($Name,$Length)
        }
        AddQueue([UInt32]$Rank,[String]$Type,[String]$Hash)
        {
            $This.Queue += [QueueItem]::New($This.Queue.Count,$Rank,$Type,$Hash)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Album.Count)
            {
                Throw "Invalid entry"
            }

            Return $This.Album | ? Index -eq $Index 
        }
        Validate()
        {
            Write-Theme "Validating [~]"
            Start-Sleep -Milliseconds 125

            $List = Get-ChildItem $This.Path *.mp3
            ForEach ($Item in $This.Queue)
            {
                $File = $List | ? Name -match $Item.Hash
                Switch (!!$File)
                {
                    $True
                    {
                        $Item.Fullname = $File.Fullname
                        $Item.Exists   = 1
                    }
                    $False
                    {
                        $Item.Fullname = $Null
                        $Item.Exists   = 0
                    }
                }
            }
        }
        [String] YouTubeDL()
        {
            Return "26E5C00C35C5C3EDC86DFC0A720AED109A13B1B7C67AC654A0CE8FF82A1F2C16"
        }
        Download([String]$YouTubeDL)
        {
            If (![System.IO.File]::Exists($YouTubeDL))
            {
                Throw "Invalid path to youtube-dl.exe specified"
            }

            ElseIf ((Get-FileHash $YouTubeDL).Hash -ne $This.YouTubeDL())
            {
                Throw "Invalid youtube-dl.exe"
            }
            
            $List = $This.Queue | ? Exists -eq 0
            If ($List.Count -eq 1)
            {
                $File              = $List[0]
                Start-Process -FilePath $YouTubeDl -NoNewWindow -ArgumentList "-x --audio-format=mp3 $($File.Url)" -Wait
            
                $Fullname          = Get-ChildItem $This.Path | ? Name -match $File.Hash | % Fullname
                If ($FullName)
                {
                    $File.Fullname = $FullName
                    $File.Exists   = 1
                    $Fullname      = $Null
                }
            }
            If ($List.Count -gt 1)
            {
                $D = ([String]$List.Count).Length
                $C = $List.Count
                $X = 0
                Write-Progress -Activity Downloading -Status ("Rank: ({0:d$D}/$C)" -f $X) -PercentComplete 0
                ForEach ($File in $List)
                {
                    $X ++
                    Write-Progress -Activity Downloading -Status ("Rank: ({0:d$D}/$C)" -f $X) -PercentComplete (($X/$List.Count)*100)
                    Start-Process -FilePath $YouTubeDl -NoNewWindow -ArgumentList "-x --audio-format=mp3 $($File.Url)" -Wait
            
                    $Fullname = Get-ChildItem $This.Path | ? Name -match $File.Hash | % Fullname
                    If ($FullName)
                    {
                        $File.Fullname = $FullName
                        $File.Exists   = 1
                        $Fullname      = $Null
                    }
                }
                Write-Progress -Activity Downloading -Status ("Rank: ({0:d$D}/$C)" -f $X) -Complete
            }
        }
        Rename()
        {
            $Last = $Null
            $C    = 0
            ForEach ($Item in $This.Queue)
            {
                $xAlbum  = $This.Get($Item.Rank)
                $NewName = Switch ($Item.Type)
                {
                    Album
                    {
                        "{0}\{1} - ({2}) {3}.mp3" -f $This.Path, 
                                                     $This.Name, 
                                                     $xAlbum.Year, 
                                                     $xAlbum.Name
                    }
                    Track
                    {
                        If ($Last -ne $xAlbum.Index)
                        {
                            $C = 0
                        }
                    
                        "{0}\{1} - ({2}) {3}({4:d2}) {5}.mp3" -f $This.Path, 
                                                                 $This.Name, 
                                                                 $xAlbum.Year, 
                                                                 $xAlbum.Name, 
                                                                 $C, 
                                                                 $xAlbum.Track[$C].Name
                    
                        $C ++
                    }
                }
                $Last = $xAlbum.Index

                [System.IO.File]::Move($Item.Fullname,$NewName)
                $Item.FullName = $NewName
            }
        }
        [String] GetOutput()
        {
            Return @($This.Album | % {

                "{0}\{1} - ({2}) {3}.mp3" -f $_.Path, 
                                             $_.Name, 
                                             $Item.Year, 
                                             $Item.Name
            })
        }
    }

    [Discography]::New($Name)
}

$Disc = Build-Discography "Amon Amarth"

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Once Sent from the Golden Hall (1998) [+] Extended Edition                                     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Once Sent from the Golden Hall",1998)
$Disc.SetHash(0,"RpoVwbKgRao")

$Album = $Disc.Get(0)

("Ride for Vengeance",                  "00:00"),
("The Dragons' Flight Across the Waves","04:28"),
("Without Fear",                        "09:02"),
("Victorious March","13:52"),
("Friends of the Suncross","21:49"),
("Abandoned","26:32"),
("Amon Amarth","32:33"),
("Once Sent from the Golden Hall","40:39") | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ The Avenger (1999) [+] Extended Edition                                                        ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("The Avenger",1999)
$Disc.SetHash(1,"rfPdnVaxruY")

$Album = $Disc.Get(1)

("Bleed for Ancient Gods","00:00"),
("The Last with Pagan Blood","04:31"),
("North Sea Storm","10:10"),
("Avenger","15:06"),
("God, His Son and Holy Whore","22:17"),
("Metalwrath","26:18"),
("Legend of a Banished Man","30:08"),
("Thor Arise [Bonus Track]","36:13"),
("Bleed for Ancient Gods [Live]","41:27"),
("The Last with Pagan Blood [Live]","45:55"),
("North Sea Storm [Live]","50:56"),
("Avenger [Live]","56:08"),
("God, His Son and Holy Whore [Live] (0","03:23"),
("Metalwrath [Live] (0","07:31"),
("Legend of a Banished Man [Live] (0","11:28") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ The Crusher (2001) [+] Extended Edition                                                        ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("The Crusher",2001)
$Disc.SetHash(2,"NLreRpyvoeA")

$Album = $Disc.Get(2)

("Bastards of a Lying Breed","00:00"),
("Masters of War","05:34"),
("The Sound of Eight Hooves","10:09"),
("Risen from the Sea","15:00"),
("As Long as the Raven Flies","19:28"),
("A Fury Divine","23:32"),
("Annihilation of Hammerfest","30:09"),
("The Fall Through Ginnungagap","35:13"),
("Releasing Surtur's Fire","40:36"),
("Eyes of Horror [Bonus Track]","46:07"),
("Bastards of a Lying Breed [Live]","49:42"),
("Masters of War [Live]","55:22"),
("The Sound of Eight Hooves [Live]","01:00:32"),
("Risen from the Sea [Live]","01:05:34"),
("As Long as the Raven Flies [Live]","01:09:59"),
("A Fury Divine [Live]","01:13:35"),
("Annihilation of Hammerfest [Live]","01:19:44"),
("The Fall Through Ginnungagap [Live]","01:24:58"),
("Releasing Surtur's Fire [Live]","01:30:39") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Versus the World (2002) [+] Extended Edition                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Versus the World",2002)
$Disc.SetHash(3,"i9qBfA17WOo")

$Album = $Disc.Get(3) 

("Death in Fire","00:00"),
("For the Stabwounds in Our Backs","04:54"),
("Where Silent Gods Stand Guard","09:51"),
("Versus the World","15:38"),
("Across the Rainbow Bridge","20:59"),
("Down the Slopes of Death","25:48"),
("Thousand Years of Oppression","29:57"),
("Bloodshed","35:38"),
("…And Soon the World Will Cease to Be","40:52"),
("Death in Fire [Live]","47:52"),
("For the Stabwounds in Our Backs [Live]","53:01"),
("Where Silent Gods Stand Guard [Live]","58:20"),
("Versus the World [Live]","01:04:09"),
("Across the Rainbow Bridge [Live]","01:10:07"),
("Down the Slopes of Death [Live]","01:15:14"),
("Thousand Years of Oppression [Live]","01:19:52"),
("Bloodshed [Live]","01:26:00"),
("…And Soon the World Will Cease to Be [Live]","01:31:43") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Fate of Norns (2004) [+]                                                                       ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Fate of Norns",2004)
$Disc.SetHash(4,"YYlC5TEfr3c")

$Album = $Disc.Get(4)

("An Ancient Sign of Coming Storm","0:00"),
("Where Death Seems to Dwell","4:39"),
("Fate of Norns","10:39"),
("The Pursuit of Vikings","16:40"),
("Valkyries Ride","22:20"),
("The Beheading of a King","27:23"),
("Arson","30:45"),
("Once Sealed in Blood","37:37") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ With Oden on Our Side (2006) [+]                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("With Oden on Our Side",2006)
$Disc.SetHash(5,"FiVLOus9xVM")

$Album = $Disc.Get(5) 

("Valhall Awaits Me","00:00"),
("Runes to My Memory","04:43"),
("Asator","09:16"),
("Hermod's Ride to Hel - Lokes Treachery Part 1","12:20"),
("Gods of War Arise","17:00"),
("With Oden on Our Side","23:03"),
("Cry of the Black Birds","27:37"),
("Under the Northern Star","31:27"),
("Prediction of Warfare","35:44") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Twilight of the Thunder God (2008) [+]                                                         ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Twilight of the Thunder God",2008)
$Disc.SetHash(6,"f8YOT5f1wVs")

$Album = $Disc.Get(6) 

("Twilight of the Thunder God","00:00"),
("Free Will Sacrifice","04:08"),
("Guardians of Asgaard","08:17"),
("Where Is Your God?","12:40"),
("Varyags of Miklagaard","15:51"),
("Tattered Banners and Bloody Flags","20:10"),
("No Fear for the Setting Sun","24:40"),
("The Hero","28:32"),
("Live for the Kill","32:34"),
("Embrace of the Endless Ocean","36:43") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Surtur Rising (2011) [+]                                                                       ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Surtur Rising",2011)
$Disc.SetHash(7,"oOK0wyuGbtI")

$Album = $Disc.Get(7) 

("War of the Gods","00:00"),
("Töck's Taunt - Loke's Treachery Part II","04:33"),
("Destroyer of the Universe","10:31"),
("Slaves of Fear","14:12"),
("Live Without Regrets","18:38"),
("The Last Stand of Frej","23:41"),
("For Victory or Death","29:19"),
("Wrath of the Norsemen","33:49"),
("A Beast Am I","37:33"),
("Doom Over Dead Man","41:10"),
("Aerials [Bonus Track]","47:06") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Deceiver of the Gods (2013) [+]                                                                ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Deceiver of the Gods",2013)
$Disc.SetHash(8,"qUZz-Lw0nBs")

$Album = $Disc.Get(8) 

("Deceiver of the Gods","00:00"),
("As Loke Falls","04:19"),
("Father of the Wolf","08:57"),
("Shape Shifter","13:17"),
("Under Siege","17:20"),
("Blood Eagle","23:37"),
("We Shall Destroy","26:53"),
("Hel","31:19"),
("Coming of the Tide","35:29"),
("Warriors of the North","39:45") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Jomsviking (2016) [+]                                                                          ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Jomsviking",2016)
$Disc.SetHash(9,"1WsQEsfZNco")

$Album = $Disc.Get(9) 

("First Kill","00:00"),
("Wanderer","04:21"),
("On a Sea of Blood","09:04"),
("One Against All","13:09"),
("Raise Your Horns","16:46"),
("The Way of Vikings","21:10"),
("At Dawn's First Light","26:22"),
("One Thousand Burning Arrows","30:12"),
("Vengeance Is My Name","36:02"),
("A Dream That Cannot Be","40:44"),
("Back on Northern Shores","45:07") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Berserker (2019) [+]                                                                           ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Berserker",2019)
$Disc.SetHash(10,"oV3ACc9DnJ0")

$Album = $Disc.Get(10) 

("Fafner's Gold","00:00"),
("Crack the Sky","05:00"),
("Mjölner, Hammer of Thor","08:50"),
("Shield Wall","13:34"),
("Valkyria","17:22"),
("Raven's Flight","22:06"),
("Ironside","27:28"),
("The Berserker at Stamford Bridge","31:59"),
("When Once Again We Can Set Our Sails","37:14"),
("Skoll and Hati","41:41"),
("Wings of Eagles","46:09"),
("Into the Dark","50:14") | % { 

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ The Great Heathen Army (2022) [+]                                                              ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("The Great Heathen Army",2022)
$Disc.SetHash(11,"a7b84bCu9zI")

$Album = $Disc.Get(11) 

("Get in the Ring","00:00"),
("The Great Heathen Army","04:24"),
("Heidrun","08:29"),
("Oden Owns You All","13:12"),
("Find a Way or Make One","17:30"),
("Dawn of Norsemen","22:00"),
("Saxons and Vikings","27:33"),
("Skagul Rides with Me","32:28"),
("The Serpent's Trail","37:02") | % { 

    $Album.AddTrack($_[0],$_[1])
}



$Disc.Validate()

If (($Disc.Queue | ? Exists -eq 0).Count -gt 0)
{
    $YouTubeDL = "$Home\Downloads\youtube-dl.exe"
    $Disc.Download($YoutubeDL)
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Rename [~]                                                                                     ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.Rename()
