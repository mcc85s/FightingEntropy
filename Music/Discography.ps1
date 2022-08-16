Class Record
{
    [UInt32] $Index
    Hidden [String] $Artist
    [String] $Name
    [String] $Year
    [String] $Label
    [String] $Hash
    [String] $URL
    [Object] $File
    Record([UInt32]$Index,[String]$Artist,[String]$Name,[String]$Year,[String]$Url)
    {
        $This.Index  = $Index
        $This.Artist = $Artist
        $This.Name   = $Name
        $This.Year   = $Year
        $This.Label  = "{0} - {1} {2}" -f $This.Artist, $This.Year, $This.Name
        $This.Hash   = $Url
        $This.URL    = "https://youtu.be/{0}" -f $Url
        $This.File   = $Null
    }
    SetFile([Object]$File)
    {
        $This.File  = $File
    }
}

Class MP3
{
    Hidden [Object] $Object
    [String] $Name
    [String] $Hash
    MP3([Object]$File)
    {
        $This.Object = $File
        $This.Name   = $File.BaseName
        $This.Hash   = $File.FullName.Substring($File.FullName.Length-15) -Replace ".mp3",""
    }
}

Class Discography
{
    [String] $Artist
    [String] $Base
    [Object] $Output
    Discography([String]$Artist,[String]$Base)
    {
        $This.Artist = $Artist
        $This.Base   = $Base
        $This.Output = @( )
    }
    Discography([String]$Artist)
    {
        $This.Artist = $Artist
        $This.Base   = Get-Variable | ? Name -eq Home | % Value
        $This.Output = @( )
    }
    AddRecord([String]$Name,[String]$Year,[String]$Url)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Record already in list"
        }

        $This.Output += [Record]::New($This.Output.Count,$This.Artist,$Name,$Year,$Url)
        $This.Rerank()
    }
    RemoveRecord([UInt32]$Index)
    {
        If ($Index -le $This.Records)
        {
            Throw "Invalid index"
        }

        $This.Output = $This.Output | ? Index -ne $Index
        $This.Rerank()
    }
    Rerank()
    {
        If ($This.Output.Count -eq 1)
        {
            $This.Output[0].Index = 0
        }
        If ($This.Output.Count -gt 1)
        {
            ForEach ($X in 0..($This.Output.Count-1))
            {
                $This.Output[$X].Index = $X
            }
        }
    }
    Gather()
    {
        $Check     = Get-ChildItem $This.Base *.mp3 | % { [MP3]::New($_) }
        $Files     = $Check | ? { $_.Object.BaseName -in $This.Output.Label -or $_.Hash -in $This.Output.Hash }

        ForEach ($File in $Files)
        {
            $Disc  = Switch ($File)
            {
                {$_.Object.BaseName -in $This.Output.Label}
                {
                    $This.Output | ? Label -eq $File.Name
                }
                {$_.Hash -in $List.Hash}
                {
                    $This.Output | ? Hash -eq $File.Hash
                }
            }

            If (!!$Disc)
            {
                $Disc.SetFile($File.Object)
                Write-Host "[+] File: $($File.Name)"
            }
        }
    }
    Download()
    {
        $List = $This.Output | ? {!$_.File -and $_.Hash}

        ForEach ($Disc in $List)
        {
            $Exec = "(python3 $(which youtube-dl) -x --audio-format mp3 {0})" -f $Disc.URL
            $Time = [System.Diagnostics.Stopwatch]::StartNew()
            Invoke-Expression $Exec
            $Job  = Get-Job | Select-Object -Last 1
            Do 
            {
                Write-Host "[$($Time.Elapsed)]"
                Start-Sleep 10
            } 
            Until ($Job.State -ne "Running")

            $File = Get-ChildItem /home/mcook85 *.mp3 | ? Name -match $Disc.Hash
            $Disc.Setfile($File)
        }
    }
    Rename()
    {
        ForEach ($Disc in $This.Output | ? File)
        {
            If ($Disc.File.BaseName -ne $Disc.Label)
            {
                $File    = "$($Disc.Label).mp3"
                Rename-Item -Path $Disc.File.FullName -NewName $File -Verbose

                $NewFile = Get-ChildItem $This.Base | ? Name -match $File
                $Disc.SetFile($NewFile)
            }
        }
    }
}
