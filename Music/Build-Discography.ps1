Function Build-Discography
{
    [CmdLetBinding()]Param([Parameter(Mandatory)][String]$Name)

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
        AddTrack([String]$Name,[String]$Length)
        {
            $This.Track += [Track]::New($This.Track.Count,$Name,$Length)
            Write-Host "Added [+] Track: [$Name], Length: [$Length]"
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
            If ($Length -match "^\d{1}:\d{2}$")
            {
                $Length = "0$Length"
            }

            If ($Length -match "\d{2}:\d{2}")
            {
                $Length = "00:$Length"
            }

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
    }

    [Discography]::New($Name)
}
