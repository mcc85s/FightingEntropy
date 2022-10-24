
# // _________________________
# // | Add Compression Types |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.Filesystem

# // ____________________________________________________________________________________________
# // | Establish function and classes that create a (*.zip) file with random Base64 information |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Function New-MockZip
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory,Position=0)][String]$Path,
    [Parameter(Position=1)][UInt32]$Factor=1000,
    [Parameter(Position=2)][UInt32]$Count=100,
    [Parameter(Position=3)][UInt32]$Length=100,
    [Parameter(Position=4)][UInt32]$Width=120)

    # // _____________________________________________
    # // | A single page of random Base64 characters |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class MockPage
    {
        [UInt32] $Index
        [String] $Path
        [Object] $Content
        MockPage([UInt32]$Index,[Object]$Content)
        {
            $This.Index    = [UInt32]$Index
            $This.Content  = $Content
        }
        [String] ToString()
        {
            Return $This.Content -join "`n"
        }
    }

    # // ____________________________________________________________
    # // | A collection of single pages of random Base64 characters |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class MockBook
    {
        [Object] $Base64
        [UInt32] $Count
        [UInt32] $Length
        [UInt32] $Width
        [String] $Path
        [Object] $Output
        MockBook([String]$Path,[UInt32]$Count,[UInt32]$Length,[UInt32]$Width)
        {
            # // __________________________________________
            # // | Cast all Base64 characters to an array |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Base64 = 065..090+097..122+048..057+043,047 | % { [Char]$_ }
            $This.Path   = $Path
            $This.Count  = $Count
            $This.Length = $Length
            $This.Width  = $Width
            $Book        = @{ }

            # // __________________________________________________________________
            # // | Create the book by casting individual pages to hashtable $Book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Write-Progress -Activity Writing -Status "(000/100)" -PercentComplete 0
            ForEach ($X in 0..($This.Count-1))
            {
                $Page    = @{ }
             
                # // __________________________________________________________________
                # // | Create the page by casting individual lines to hashtable $Page |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($I in 0..($This.Length-1))
                {
                    # // __________________________________________________
                    # // | Create the line by randomly generating numbers |
                    # // | and using the variable $This.Base64            |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Page.Add($Page.Count,@($This.Random() | % { $This.Base64[$_] }) -join '')
                }

                $Book.Add($Book.Count,[MockPage]::New($Book.Count,$Page[0..($Page.Count-1)]))

                Write-Progress -Activity Writing -Status ("({0:d3}/100" -f $X) -PercentComplete $X
            }
            Write-Progress -Activity Writing -Status "(100/100)" -Complete

            # // _________________________________________________________
            # // | Save the hashtable content to the array, $This.Output |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Output = $Book[0..($Book.Count-1)]
        }
        [UInt32[]] Random()
        {
            $Hash = @{ }
            
            0..($This.Width-1) | % { $Hash.Add($Hash.Count,(Get-Random -Maximum 63)) }

            Return $Hash[0..($Hash.Count-1)]
        }
    }

    # // ___________________________________________________________
    # // | Create a scratch zip file of randomly generated content |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class MockZip
    {
        [String] $Name
        [String] $Path
        [String] $Fullname
        [UInt32] $Exists
        [Object] $Archive
        [Object] $Book
        MockZip([String]$Path,[UInt32]$Factor,[UInt32]$Count,[UInt32]$Length,[UInt32]$Width)
        {
            # // _____________________________
            # // | Test for the initial path |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid Path"
            }

            If ($Factor -le 0)
            {
                # // __________________________________________________________________________________________________
                # // | Factor determines how many times each individual page's content is repeated in the output file |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                Throw "Exception [!] Factor must be higher than 0, suggested: 1000"
            }

            If ($Count -le 1)
            {
                # // ______________________________________________________________
                # // | Count determines how many individual pages will be written |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                Throw "Exception [!] Count must be higher than 1, suggested: 100"
            }

            If ($Length -le 1)
            {
                # // _____________________________________________________________
                # // | Length determines how many lines will be written per page |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                Throw "Exception [!] Length must be higher than 1, suggested: 100"
            }

            If ($Width -le 1)
            {
                # // __________________________________________________________
                # // | Width determines how many characters each line will be |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                Throw "Exception [!] Width must be higher than 1, suggested: 120"
            }

            # // ___________________________________________________
            # // | Establish Date/Time -> Name -> Path -> Fullname |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Name       = [DateTime]::Now.ToString("yyyy_MMdd_HHmmss")
            $This.Path       = "{0}\{1}" -f $Path, $This.Name
            $This.Fullname   = "{0}\{1}.zip" -f $Path, $This.Name

            # // ______________________
            # // | Establish new base |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.NewBase()

            # // _________________________________________________
            # // | Establish random data to insert into zip file |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Book       = [MockBook]::New($This.Path,$Count,$Length,$Width)

            # // _________________________________________________
            # // | Create the zip file, and then inject the book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.NewZip()
            $This.InjectBook($Factor)

            # // _____________________
            # // | Save the zip file |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Archive.Dispose()

            $This.Path
        }
        CheckBase()
        {
            $This.Exists     = [System.IO.Directory]::Exists($This.Path)
        }
        NewBase()
        {
            $This.CheckBase()
            If (!$This.Exists)
            {
                [System.IO.Directory]::CreateDirectory($This.Path)
                $This.Exists = 1
            }
        }
        NewZip()
        {
            [System.IO.Compression.ZipFile]::Open($This.Fullname,"Create").Dispose()
            $This.Archive  = [System.IO.Compression.ZipFile]::Open($This.Fullname,"Update")
        }
        InjectBook([UInt32]$Factor)
        {
            $Depth = ([String]$This.Book.Output.Count).Length
            ForEach ($X in 0..($This.Book.Output.Count-1))
            {
                $Item      = $This.Book.Output[$X]
                $Item.Path = "{0}\{1:d$Depth}.txt" -f $This.Path, $X
                $Hash      = @{ }

                If ($Factor -gt 1)
                {
                    ForEach ($I in 0..($Factor-1))
                    {
                        $Hash.Add($I,$This.Book.Output[$X].Content)
                    }
                }
                If ($Factor -eq 1)
                {
                    $Hash.Add(0,$This.Book.Output[$X].Content)
                }

                $Content   = $Hash[0..($Hash.Count-1)]
                [System.IO.File]::WriteAllLines($Item.Path,$Content)

                $This.AddFile($Item.Path)
            }
        }
        AddFile([String]$Path)
        {
            $ID = $Path | Split-Path -Leaf
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($This.Archive,$Path,$ID,[System.IO.Compression.CompressionLevel]::Fastest) | Out-Null
            [System.IO.File]::Delete($Path)
        }
    }

    [MockZip]::New($Path,$Factor,$Count,$Length,$Width)
}
