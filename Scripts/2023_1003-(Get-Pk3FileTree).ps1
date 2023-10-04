# Gets the individual map files from all non-pak# (*.pk3) files in baseq3 path

Function Get-Pk3FileTree
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,HelpMessage="Path to (baseq3/other)")][String]$Base
    )
    Class Pk3FileBsp
    {
        [UInt32]  $Index
        [String]   $Date
        [String]   $Time
        [String]   $Name
        [String]  $Title
        [String]   $Mode
        [Float]  $Rating
        Pk3FileBsp([UInt32]$Index,[Object]$Bsp)
        {
            $This.Index  = $Index
            $DateTime    = $Bsp.Date -Split " "
            $This.Date   = $DateTime[0]
            $This.Time   = $DateTime[1]
            $This.Name   = $Bsp.Name.Replace(".bsp","")
        }
        SetTitle([String]$Title)
        {
            $This.Title  = $Title
        }
        SetMode([String]$Mode)
        {
            $This.Mode   = $Mode
        }
        SetRating([String]$Rating)
        {
            $This.Rating = $Rating
        }
    }

    Class Pk3FileEntrySize
    {
        [String]   $Name
        [UInt64]  $Bytes
        [String]   $Unit
        [String]   $Size
        Pk3FileEntrySize([UInt64]$Bytes)
        {
            $This.Name   = "Compressed"
            $This.Bytes  = $Bytes
            $This.GetUnit()
            $This.GetSize()
        }
        GetUnit()
        {
            $This.Unit   = Switch ($This.Bytes)
            {
                {$_ -lt 1KB}                 {     "Byte" }
                {$_ -ge 1KB -and $_ -lt 1MB} { "Kilobyte" }
                {$_ -ge 1MB -and $_ -lt 1GB} { "Megabyte" }
                {$_ -ge 1GB -and $_ -lt 1TB} { "Gigabyte" }
                {$_ -ge 1TB}                 { "Terabyte" }
            }
        }
        GetSize()
        {
            $This.Size   = Switch -Regex ($This.Unit)
            {
                ^Byte     {     "{0} B" -f  $This.Bytes      }
                ^Kilobyte { "{0:n2} KB" -f ($This.Bytes/1KB) }
                ^Megabyte { "{0:n2} MB" -f ($This.Bytes/1MB) }
                ^Gigabyte { "{0:n2} GB" -f ($This.Bytes/1GB) }
                ^Terabyte { "{0:n2} TB" -f ($This.Bytes/1TB) }
            }
        }
        [String] ToString()
        {
            Return $This.Size
        }
    }

    Class Pk3FileEntry
    {
        [UInt32]         $Index
        Hidden [DateTime] $Real
        [String]          $Date
        [Object]          $Size
        [String]          $Name
        [String]      $Fullname
        Pk3FileEntry([UInt32]$Index,[Object]$Entry)
        {
            $This.Index    = $Index
            $This.Real     = $Entry.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Date     = $This.Real.ToString("MM/dd/yyyy HH:mm:ss")
            $This.Size     = $This.Pk3FileEntrySize($Entry.CompressedLength)
            $This.Name     = $Entry.Name
            $This.Fullname = $Entry.Fullname
        }
        [Object] Pk3FileEntrySize([UInt64]$Bytes)
        {
            Return [Pk3FileEntrySize]::New($Bytes)
        }
    }

    Class Pk3FileArchive
    {
        [UInt32]    $Index
        [String]     $Name
        [String] $Fullname
        [Object]  $Archive
        [Object]   $Output
        Pk3FileArchive([UInt32]$Index,[Object]$File)
        {
            $This.Index    = $Index
            $This.Name     = $File.Name
            $This.Fullname = $File.Fullname
            $This.Archive  = [System.IO.Compression.ZipFile]::Open($This.Fullname,"Read")
            $This.Refresh()
        }
        Clear()
        {
            $This.Output   = @( )
        }
        [Object] Pk3FileEntry([UInt32]$Index,[Object]$Entry)
        {
            Return [Pk3FileEntry]::New($Index,$Entry)
        }
        Refresh()
        {   
            $This.Clear()

            ForEach ($Entry in $This.Archive.Entries | Sort-Object Fullname)
            {
                $This.Output += $This.Pk3FileEntry($This.Output.Count,$Entry)
            }
        }
    }

    Class Pk3FileTree
    {
        [String] $Base
        [Object] $Archive
        [Object] $Output
        Pk3FileTree([String]$Base)
        {
            If (![System.IO.Directory]::Exists($Base))
            {
                Throw "Invalid directory"
            }

            $This.Base = $Base
            $This.Refresh()
        }
        [Object] Pk3FileArchive([UInt32]$Index,[Object]$File)
        {
            Return [Pk3FileArchive]::New($Index,$File)
        }
        [Object] Pk3FileBsp([UInt32]$Index,[Object]$Bsp)
        {
            Return [Pk3FileBsp]::New($Index,$Bsp)
        }
        Clear()
        {
            $This.Archive = @( )
            $This.Output  = @( )
        }
        Refresh()
        {
            $This.Clear()
            $List = Get-ChildItem $This.Base | ? Extension -eq .pk3 | ? Name -notmatch ^pak\d

            [Console]::WriteLine("Archive [~] ($($List.Count)) files found")

            ForEach ($File in $List)
            {
                [Console]::WriteLine("Archive [~] $($File.Name)")

                $This.Archive += $This.Pk3FileArchive($This.Archive.Count,$File)
            }

            [Console]::WriteLine("Archive [+] Complete")

            $List = $This.Archive.Output | ? Name -match ".+\.bsp" | Sort-Object Name

            ForEach ($Entry in $List)
            {
                [Console]::WriteLine("Map [~] $($Entry.Name)")

                $This.Output += $This.Pk3FileBsp($This.Output.Count,$Entry)
            }

            [Console]::WriteLine("Map [+] Complete")
        }
    }

    [Pk3FileTree]::New($Base)
}
