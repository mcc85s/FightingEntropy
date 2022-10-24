
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

    # // _________________________________________________
    # // | Maintains the dimensions of the output object |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class MockBox
    {
        [UInt32] $Factor
        [UInt32] $Count
        [UInt32] $Depth
        [UInt32] $Length
        [UInt32] $Width
        MockBox([UInt32]$Factor,[UInt32]$Count,[UInt32]$Length,[Uint32]$Width)
        {
            $This.Factor = $Factor
            $This.Count  = $Count
            $This.Depth  = ([String]$This.Count).Length
            $This.Length = $Length
            $This.Width  = $Width
        }
        [String] ToString()
        {
            Return ($This.PSObject.Properties | % { "{0}: [{1}]" -f $_.Name, $_.Value }) -join ', '            
        }
    }
    
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
            Return "<[MockPage]>"
        }
    }

    # // ____________________________________________________________
    # // | A collection of single pages of random Base64 characters |
    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Class MockBook
    {
        [Object] $Base64
        [UInt32] $Count
        [Object] $Box
        [String] $Path
        [Object] $Output
        [String] Status([UInt32]$Rank)
        {
            Return "({0:d$($This.Box.Depth)}/{1})" -f $Rank, $This.Box.Count
        }
        [UInt32] Percent([UInt32]$Rank)
        {
            If ($Rank -eq 0)
            {
                $Rank = $Rank + 1
            }
            Return (($Rank/$This.Box.Count)*100)
        }
        [Hashtable] Progress([String]$Activity,[UInt32]$Rank)
        {
            Return [Hashtable]@{

                Activity = $Activity
                Status   = $This.Status($Rank)
                Percent  = $This.Percent($Rank)
            }
        }
        MockBook([String]$Path,[Object]$Box)
        {
            # // __________________________________________
            # // | Cast all Base64 characters to an array |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Base64 = 065..090+097..122+048..057+043,047 | % { [Char]$_ }
            $This.Path   = $Path
            $This.Box    = $Box

            # // _______________________________________________________
            # // | Divides the workload cleanly for process indication |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Slot = Switch ($This.Box.Count)
            {
                {$_ -lt 100}
                {
                    $Div   = [Math]::Round(100/$This.Box.Count,[MidpointRounding]::AwayFromZero)
                    $Step  = [Math]::Round(100/$Div)
                    0..($Div-1) | % { $_ * $Step }
                }
                {$_ -eq 100}
                {
                    $Div   = 100
                    $Step  = 1
                    0..99 | % { $_ * $Step }
                    
                }
                {$_ -gt 100}
                {
                    $Div   = $This.Box.Count/100
                    0..99 | % { [Math]::Round($_ * $Div) }
                }
            }

            $Slot[-1]      = $This.Box.Count
            $Book          = @{ }

            # // __________________________________________________________________
            # // | Create the book by casting individual pages to hashtable $Book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Splat = $This.Progress("Generating [~]",0)
            Write-Progress @Splat

            ForEach ($X in 0..($This.Box.Count-1))
            {
                $Page    = @{ }
             
                # // __________________________________________________________________
                # // | Create the page by casting individual lines to hashtable $Page |
                # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                ForEach ($I in 0..($This.Box.Length-1))
                {
                    # // __________________________________________________
                    # // | Create the line by randomly generating numbers |
                    # // | and using the variable $This.Base64            |
                    # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                    $Random = $This.Random()
                    $Line   = $This.Base64[$Random] -join ''

                    $Page.Add($Page.Count,$Line)
                }

                $Book.Add($Book.Count,[MockPage]::New($Book.Count,$Page[0..($Page.Count-1)]))

                If ($X -in $Slot)
                {
                    $Splat = $This.Progress("Generating [~]",$X)
                    Write-Progress @Splat
                }
            }
            $Splat = $This.Progress("Generating [~]",100)
            Write-Progress @Splat -Complete

            # // _________________________________________________________
            # // | Save the hashtable content to the array, $This.Output |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Output = $Book[0..($Book.Count-1)]
        }
        [UInt32[]] Random()
        {
            $Hash = @{ }
            
            0..($This.Box.Width-1) | % { $Hash.Add($Hash.Count,(Get-Random -Maximum 63)) }

            Return $Hash[0..($Hash.Count-1)]
        }
        [String] ToString()
        {
            Return "<[MockBook]>"
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
        [Object] $Box
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
            $This.Box        = $This.GenerateBox($Factor,$Count,$Length,$Width)

            # // ______________________
            # // | Establish new base |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.NewBase()

            # // _________________________________________________
            # // | Establish random data to insert into zip file |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Book       = $This.GenerateBook()

            # // _________________________________________________
            # // | Create the zip file, and then inject the book |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Create()
            $This.Open()
            $This.InjectBook()

            # // _____________________
            # // | Save the zip file |
            # // ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $This.Close()
            $This.RemoveBase()
        }
        [Object] GenerateBox([UInt32]$Factor,[UInt32]$Count,[UInt32]$Length,[UInt32]$Width)
        {
            Return [MockBox]::New($Factor,$Count,$Length,$Width)
        }
        [Object] GenerateBook()
        {
            Return [MockBook]::New($This.Path,$This.Box)
        }
        InjectBook()
        {
            If (!$This.Book)
            {
                Throw "Must create a book first..."
            }

            $Depth = ([String]$This.Book.Output.Count).Length
            ForEach ($X in 0..($This.Book.Output.Count-1))
            {
                $Item      = $This.Book.Output[$X]
                $Item.Path = "{0}\{1:d$Depth}.txt" -f $This.Path, $X
                $Hash      = @{ }

                Switch ($This.Box.Factor)
                {
                    {$_ -gt 1}
                    {
                        ForEach ($I in 0..($This.Box.Factor-1))
                        {
                            $Hash.Add($I,$This.Book.Output[$X].Content)
                        }
                    }
                    {$_ -eq 1}
                    {
                        $Hash.Add(0,$This.Book.Output[$X].Content)
                    }
                }

                $Content   = $Hash[0..($Hash.Count-1)]
                [System.IO.File]::WriteAllLines($Item.Path,$Content)

                $This.AddFile($Item.Path)
            }
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
                Write-Host "Created [+] Directory: [$($This.Path)]"
                $This.Exists = 1
            }
        }
        RemoveBase()
        {
            $This.CheckBase()
            If ($This.Exists)
            {
                [System.IO.Directory]::Delete($This.Path)
                Write-Host "Removed [+] Directory: [$($This.Path)]"
                $This.Exists = 0
            }
        }
        Create()
        {
            If ([System.IO.File]::Exists($This.FullName))
            {
                Throw "Exception [!] File: [$($This.Fullname)] already exists"
            }

            $Item = [System.IO.Compression.ZipFile]::Open($This.Fullname,"Create")
            
            If (![System.IO.File]::Exists($This.Fullname))
            {
                Throw "Exception [!] File: [$($This.Fullname)] was NOT created"
            }

            Write-Host "Created [+] File: [$($This.Fullname)]"
            $Item.Dispose()
        }
        Open()
        {
            If (![System.IO.File]::Exists($This.Fullname))
            {
                Throw "Exception [!] File: [$($This.Fullname)] does not exist"
            }

            $This.Archive = [System.IO.Compression.ZipFile]::Open($This.Fullname,"Update")
            
            If (!$This.Archive)
            {
                Throw "Exception [!] File: [$($This.Fullname)] could not be opened"
            }

            Write-Host "Opened [+] File: [$($This.Fullname)]"
        }
        Close()
        {
            If (!$This.Archive)
            {
                Throw "Exception [!] File: [$($This.Fullname)] is not yet opened"
            }

            Write-Host "Closing [~] File: [$($This.Fullname)]"
            $This.Archive.Dispose()

            $This.Archive = $Null

            Write-Host "Closed [+] File: [$($This.Fullname)]"
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
