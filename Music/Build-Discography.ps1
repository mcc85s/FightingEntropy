Function Build-Discography
{
    [CmdLetBinding()]Param([Parameter(Mandatory,Position=0)][String]$Name)

    Class QueueItem
    {
        [UInt32]    $Index
        [UInt32]     $Rank
        [String]     $Type
        [String]     $Hash
        [String]      $Url
        [UInt32]   $Exists
        [String] $Fullname
        QueueItem([UInt32]$Index,[UInt32]$Rank,[String]$Type,[String]$Hash)
        {
            $This.Index = $Index
            $This.Rank  = $Rank
            $This.Type  = $Type
            $This.Hash  = $Hash
            $This.Url   = "https://youtu.be/$Hash"
        }
        [String] ToString()
        {
            Return $This.Type
        }
    }

    Class PlayListEntry
    {
        [UInt32]    $Index
        [String]     $Name
        [String]     $Hash
        [TimeSpan] $Length
        [String] $Fullname
        [String]  $NewName
        PlayListEntry([UInt32]$Index,[String]$Name,[String]$Hash,[String]$Length)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Hash   = $Hash
            $This.Length = [Timespan]"00:$Length"
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class PlayListItem
    {
        [UInt32]  $Index
        [String]   $Name
        [String]   $Path
        [Object] $Output
        PlayListItem([Object]$Disc)
        {
            $Album       = $Disc.Current()
            $This.Index  = $Album.Index
            $This.Name   = "{0} - {1} ({2})" -f $Disc.Name, $Album.Name, $Album.Year
            $This.Path   = $Disc.Path
            $This.Output = @( )
        }
        [Object] PlaylistEntry([UInt32]$Index,[String]$Name,[String]$Hash,[String]$Length)
        {
            Return [PlayListEntry]::New($Index,$Name,$Hash,$Length)
        }
        [String] NewName([Object]$Item)
        {
            Return "{0}\{1}[{2:d2}] - {3}.mp3" -f $This.Path, $This.Name, $Item.Index, $Item.Name
        }
        Add([String]$Name,[String]$Hash,[String]$Length)
        {
            $Item          = $This.PlayListEntry($This.Output.Count,$Name,$Hash,$Length)
            $Item.Fullname = $This.List | ? Name -match $Item.Hash | % Fullname
            $Item.NewName  = $This.NewName($Item)
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
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class TrackItem
    {
        [UInt32]      $Index
        [TimeSpan] $Position
        [String]       $Name
        [TimeSpan]   $Length
        TrackItem([UInt32]$Index,[String]$Name,[String]$Length)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Length  = $Length
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class AlbumItem
    {
        [UInt32]    $Index
        [String]     $Name
        [UInt32]     $Year
        [String]     $Hash
        [TimeSpan] $Length
        [Object]    $Track
        AlbumItem([UInt32]$Index,[String]$Name,[UInt32]$Year)
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

            $Item          = $This.TrackItem($This.Track.Count,$Name,$xLength)
            $Item.Position = $This.Length
            $This.Length   = $This.Length + $Item.Length
            $This.Track   += $Item

            Write-Host "Added [+] Track: [$Name], Length: [$xLength]"
        }
        [Object] TrackItem([UInt32]$Index,[String]$Name,[String]$Duration)
        {
            Return [TrackItem]::New($Index,$Name,$Duration)
        }
        [String] ToString()
        {
            Return "{0} ({1})" -f $This.Name, $This.Year
        }
    }

    Class Discography
    {
        [String]     $Name
        [String]     $Path
        [Object]    $Album
        [Object]    $Queue
        [UInt32] $Selected
        Discography([String]$Name)
        {
            $This.Name  = $Name
            $This.Path  = Get-Item Variable:\Home | % Value
            $This.Album = @( )
            $This.Queue = @( )
        }
        Select([UInt32]$Index)
        {
            If ($Index -gt $This.Album.Count)
            {
                Throw "Invalid index"
            }

            $This.Selected = $Index
        }
        [Object] Current()
        {
            Return $This.Album[$This.Selected] 
        }
        [Object] AlbumItem([UInt32]$Index,[String]$Name,[UInt32]$Year)
        {
            Return [AlbumItem]::New($Index,$Name,$Year)
        }
        [Object] PlayListItem()
        {
            Return [PlayListItem]::New($This)
        }
        [Object] QueueItem([UInt32]$Index,[UInt32]$Rank,[String]$Type,[String]$Hash)
        {
            Return [QueueItem]::New($Index,$Rank,$Type,$Hash)
        }
        AddAlbum([String]$Name,[UInt32]$Year)
        {
            $This.Album += $This.AlbumItem($This.Album.Count,$Name,$Year)

            Write-Theme "Added [+] Album: [$Name ($Year)]"
            Start-Sleep -Milliseconds 125
        }
        AddPlayList([Object]$List)
        {
            $xAlbum = $This.Current()
            ForEach ($Track in $List.Output)
            {
                $xAlbum.AddTrack($Track.Name,$Track.Length)
                $This.AddQueue($List.Index,"Track",$Track.Hash)
            }
        }
        AddTrack([String]$Name,[String]$Length)
        {
            $xAlbum = $This.Current()
            $xAlbum.AddTrack($Name,$Length)
        }
        SetHash([String]$Hash)
        {
            $xAlbum = $This.Current()
            $xAlbum.SetHash($Hash)
            $This.AddQueue($xAlbum.Index,"Album",$Hash)
        }
        AddQueue([UInt32]$Rank,[String]$Type,[String]$Hash)
        {
            $This.Queue += $This.QueueItem($This.Queue.Count,$Rank,$Type,$Hash)
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

<# 
## [Album] ##

$Disc.AddAlbum("Cool album name #1",5000)
$Disc.Select($Index)
$Disc.SetHash("YoUtUbEhAsH")

("Cool track #1" , "00:00") ,
("Cool track #2" , "04:28") | % {

    $Disc.AddTrack($_[0],$_[1])
}

## [Playlist] ##

$Disc.AddAlbum("Cool album playlist",5000)
$Disc.Select($Index)
$Playlist = $Disc.PlayListItem()

("Cool track #1","YoUtUbEhAsH","05:01") ,
("Cool track #2","yOuTuBeHaSh","04:29") | % { 

    $Playlist.Add($_[0],$_[1],$_[2])
}

$Disc.AddPlayList($PlayList)

## [Validate] ##

$Disc.Validate()

## [Download] ##

$YouTubeDL = "$Home\Downloads\youtube-dl.exe"

If (($Disc.Queue | ? Exists -eq 0).Count -gt 0)
{
    $Disc.Download($YoutubeDL)
}

## [Rename] ##

$Disc.Rename()

#>
