
# // _________________________
# // | Add Compression Types |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.Filesystem

# // ____________________________________________________________________________________________
# // | Establish function and classes that create a (*.zip) file with random Base64 information |
# // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

Function New-MockZip
{
    [CmdLetBinding()]Param([Parameter(Mandatory,Position=0)][String]$Path)

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
        [String] $Path
        [Object] $Output
        MockBook([String]$Path)
        {
            # // __________________________________________
            # // | Cast all Base64 characters to an array |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Base64 = 065..090+097..122+048..057+043,047 | % { [Char]$_ }
            $This.Path   = $Path
            $Book        = @{ }

            # // __________________________________________________________________
            # // | Create the book by casting individual pages to hashtable $Book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Write-Progress -Activity Writing -Status "(000/100)" -PercentComplete 0
            ForEach ($X in 0..99)
            {
                $Page    = @{ }
             
                # // __________________________________________________________________
                # // | Create the page by casting individual lines to hashtable $Page |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($I in 0..99)
                {
                    # // __________________________________________________
                    # // | Create the line by randomly generating numbers |
                    # // | and using the variable $This.Base64            |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Page.Add($Page.Count,@($this.Random() | % { $This.Base64[$_] }) -join '')
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
            
            0..119 | % { $Hash.Add($Hash.Count,(Get-Random -Maximum 63)) }

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
        MockZip([String]$Path)
        {
            # // _____________________________
            # // | Test for the initial path |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If (![System.IO.Directory]::Exists($Path))
            {
                Throw "Invalid Path"
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

            $This.Book       = [MockBook]::New($This.Path)

            # // _________________________________________________
            # // | Create the zip file, and then inject the book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.NewZip()
            $This.InjectBook()

            # // _____________________
            # // | Save the zip file |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Dispose()
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
        InjectBook()
        {
            $Depth = ([String]$This.Book.Output.Count).Length
            ForEach ($X in 0..($This.Book.Output.Count-1))
            {
                $Item      = $This.Book.Output[$X]
                $Item.Path = "{0}\{1:d$Depth}.txt" -f $This.Path, $X
                $Hash      = @{ }
                ForEach ($I in 0..999)
                {
                    $Hash.Add($I,$This.Book.Output[$X].Content)
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

    [MockZip]::New($Path)
}
