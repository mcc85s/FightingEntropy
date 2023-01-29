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

                Move-Item -LiteralPath $Item.Fullname -Destination $NewName
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

$Disc = Build-Discography "Lamb of God"

<# 
## [Album]

$Disc.AddAlbum("Cool album name #1",5000)
$Disc.SetHash(0,"YoUtUbEhAsH")

$Album = $Disc.Get(0)

("Cool track #1" , "00:00") ,
("Cool track #2" , "04:28") | % {

    $Album.AddTrack($_[0],$_[1])
}

## [Playlist]

$Disc.AddAlbum("Cool album playlist",5000)
$Album = $Disc.BuildPlayList($Index)

("Cool track #1","YoUtUbEhAsH","05:01") ,
("Cool track #2","yOuTuBeHaSh","04:29") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)
#>

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ New American Gospel (2000) [~]                                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("New American Gospel",2000)
$Disc.SetHash(0,"SXAPuVUzd1E")
$Album = $Disc.Get(0)

("Black Label","4:52"),
("A Warning","2:23"),
("In the Absence of the Sacred","4:36"),
("Letter to the Unborn","2:56"),
("The Black Dahlia","3:19"),
("Terror and Hubris in the House of Frank Pollard","5:37"),
("The Subtle Arts of Murder and Persuasion","4:10"),
("Pariah","4:24"),
("Confessional","4:01"),
("O.D.H.G.A.B.F.E.","5:11") | % { 

    $Album.AddTrack($_[0],$_[1])
}

$Disc.AddPlayList(0)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ As the Palaces Burn (2003) [~]                                                                 ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("As the Palaces Burn",2003)
$Album = $Disc.BuildPlayList(1)

("Ruin","85vIimWBLLM","3:55"),
("As the Palaces Burn","j7nQ8GnYVh8","2:24"),
("Purified","cGkq0pRJ94U","3:11"),
("11th Hour","Upe3lEEXu5g","3:44"),
("For Your Malice","ooXMaEulRDg","3:43"),
("Boot Scraper","oqi08jm5GKs","4:40"),
("A Devil in God's Country","Lae0-1uZJFs","3:10"),
("In Defense of Our Good Name","4I2PzjqL9WE","4:13"),
("Blood Junkie","u0JSqFOE0vA","4:23"),
("Vigil","lxgelwqe8-E","4:42") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Ashes of the Wake (2004) [~]                                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Ashes of the Wake",2003)
$Album = $Disc.BuildPlayList(2)

("Laid to Rest","HL9kaJZw8iw","3:50"),
("Hourglass","E22T_fs82oo","4:00"),
("Now You've Got Something to Die For","oZzXzXx-xng","3:39"),
("The Faded Line","WKVFfx1HroI","4:37"),
("Omerta","-xYZM04JxnQ","4:45"),
("Blood of the Scribe","dmft3nrsaxs","4:23"),
("One Gun","ua5oilaPMdo","3:59"),
("Break You","5HYazmXYk8g","3:35"),
("What I've Become","P82OyU4T3Ms","3:28"),
("Ashes of the Wake","JpbiuAYT1rw","5:45"),
("Remorse is for the Dead","Z11nB_FBQXU","5:41"),
("Another Nail for Your Coffin","jcdbdLDYxUQ","4:37"),
("Ashes of the Wake (Demo)","IvKvA8I0vvI","5:32"),
("Remorse is for the Dead (Demo)","OG7KHBDfF-8","4:20") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)


#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Sacrament (2006) [~]                                                                           ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Sacrament",2006)
$Album = $Disc.BuildPlayList(3)

("Walk with Me in Hell","QWkhCxCcWSE","5:11"),
("Again We Rise","Xe07zUkryeI","4:30"),
("Redneck","oqdZpxkzNvc","3:41"),
("Pathetic","qRjpjr0usHM","4:31"),
("Foot to the Throat","qnBCWZnHAjY","3:13"),
("Descending","gq50l2cr7nI","3:35"),
("Blacken the Cursed Sun","iNLGa_gelMs","5:28"),
("Forgotten (Lost Angels)","iiokKF9gdc8","3:05"),
("Requiem","R4nARsIBLuU","4:10"),
("More Time to Kill","-mohZsGIRik","3:36"),
("Beating on Death's Door","3XZSW9dxXhc","5:06") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Wrath (2009) [~]                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Wrath",2009)
$Disc.SetHash(4,"3N5HslVNZUM")

$Album = $Disc.Get(4)

("The Passing","1:58"),
("In Your Words","5:25"),
("Set to Fail","3:46"),
("Contractor","3:22"),
("Fake Messiah","4:34"),
("Grace","3:55"),
("Broken Hands","3:53"),
("Dead Seeds","3:41"),
("Everything to Nothing","3:50"),
("Choke Sermon","3:21"),
("Reclamation","7:07") | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Resolution (2012) [~]                                                                          ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Resolution",2012)
$Album = $Disc.BuildPlayList(5)

("Straight for the Sun","4_Cxn1ckoeY","2:28"),
("Desolation","vVLDbWlsV3o","3:54"),
("Ghost Walking","sd_S1ZA11Bg","4:30"),
("Guilty","iwOH96_Ecu0","3:24"),
("The Undertow","IWXtbqElLLU","4:46"),
("The Number Six","jbpjF--7jto","5:21"),
("Barbarosa (instrumental)","oiOiSZ3JQL4","1:35"),
("Invictus","YrIaH2Wd-JE","4:12"),
("Cheated","39mS4-JZyOw","2:35"),
("Insurrection","aJ_P-MZx8sk","4:51"),
("Terminally Unique","IbrYfgrBvNE","4:21"),
("To the End","BMl1x5lf-8o","3:49"),
("Visitation","5YZ3ldvVH18","3:59"),
("King Me","Hwbu7DJVgag","6:36") | % { 

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ VII: Sturm und Drang (2015) [~]                                                                ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("VII Sturm und Drang",2015)
$Disc.SetHash(6,"WtmNckYz3rw")

$Album = $Disc.Get(6)

("Still Echoes","4:22"),
("Erase This","5:08"),
("512","4:44"),
("Embers","4:56"),
("Footprints","4:24"),
("Overlord","6:28"),
("Anthropoid","3:38"),
("Engage the Fear Machine","4:48"),
("Delusion Pandemic","4:22"),
("Torches","5:17") | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Lamb of God (2020) [~]                                                                         ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Lamb of God",2020)
$Disc.SetHash(7,"Q7OZqIN2_4I")

$Album = $Disc.Get(7)
("Memento Mori","5:48"),
("Checkmate","4:30"),
("Gears","3:55"),
("Reality Bath","4:32"),
("New Colossal Hate","4:30"),
("Resurrection Man","4:59"),
("Poison Dream","4:57"),
("Routes","3:04"),
("Bloodshot Eyes","3:57"),
("On the Hook","4:30") | % {

    $Album.AddTrack($_[0],$_[1])
}

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Omens (2022) [~]                                                                               ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.AddAlbum("Omens",2022)
$Album = $Disc.BuildPlayList(8)

("Nevermore","SnEXcv0YJQA","4:36"),
("Vanishing","CXLylYvmCMQ","4:49"),
("To the Grave","ZrcbTSP-8zs","3:44"),
("Ditch","duJNDHUbtoQ","3:38"),
("Omens","VCUyMUMT2aE","3:48"),
("Gomorrah","p9d5HMNBFoE","4:12"),
("Ill Designs","HeG9JvrdhMQ","3:41"),
("Grayscale","jWyd_9LK75Y","4:00"),
("Denial Mechanism","R1CDmHQlbEE","2:38"),
("September Song","wq8uc8p0rQQ","6:00") | % {

    $Album.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($Album)

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Validate [~]                                                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

$Disc.Validate()

#    ____    ____________________________________________________________________________________________________        
#   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
#   \\__//¯¯¯ Download [~]                                                                                   ___//¯¯\\   
#    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
#        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    

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
