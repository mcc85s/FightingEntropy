Function Build-Discography
{
    [CmdLetBinding()]Param([Parameter(Mandatory,Position=0)][String]$Name)

    Class Track
    {
        [UInt32]      $Index
        [String]       $Name
        [TimeSpan]   $Length
        [TimeSpan] $Position
        Track([UInt32]$Index,[String]$Name,[String]$Length)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Length  = $Length
        }
        SetPosition([TimeSpan]$Consecutive)
        {
            $This.Position = $Consecutive
        }
    }

    Class Album
    {
        [UInt32]    $Index
        [String]     $Name
        [TimeSpan] $Length
        [Object]    $Track
        Album([UInt32]$Index,[String]$Name)
        {
            $This.Index  = $Index
            $This.Name   = $Name
            $This.Length = [TimeSpan]"00:00:00"
            $This.Track  = @()
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

            $This.Track += [Track]::New($This.Track.Count,$Name,$xLength)
            Write-Host "Added [+] Track: [$Name], Length: [$xLength]"
        }
        SetPosition()
        {
            ForEach ($Track in $This.Track)
            {
                $Track.Position = $This.Length
                $This.Length    = $Track.Position + $Track.Length            
            }
        }
    }

    Class Discography
    {
        [String]  $Name
        [Object] $Album
        Discography([String]$Name)
        {
            $This.Name  = $Name
            $This.Album = @( )
        }
        AddAlbum([String]$Name)
        {
            $This.Album += [Album]::New($This.Album.Count,$Name)
            Write-Host "Added [+] Album: [$Name]"
        }
        AddTrack([UInt32]$Index,[String]$Name,[String]$Length)
        {
            $Item       = $This.Get($Index)
            $Item.AddTrack($Name,$Length)
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Album.Count)
            {
                Throw "Invalid entry"
            }

            Return $This.Album | ? Index -eq $Index 
        }
        SetPosition()
        {
            ForEach ($X in 0..($This.Album.Count-1))
            {
                $Item = $This.Get($X)
                $Item.SetPosition()
                Write-Host "Set [+] Album: [$($Item.Name)], Length: [$($Item.Length)]"
            }
        }
    }

    [Discography]::New($Name)
}
