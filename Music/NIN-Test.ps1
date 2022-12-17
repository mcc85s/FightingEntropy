    
    # // =======================================================
    # // | Used to track console logging, similar to Stopwatch |
    # // =======================================================

    Class YoutubeDlTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        YoutubeDlTime([String]$Name)
        {
            $This.Name = $Name
            $This.Time = [DateTime]::MinValue
            $This.Set  = 0
        }
        Toggle()
        {
            $This.Time = [DateTime]::Now
            $This.Set  = 1
        }
        [String] ToString()
        {
            Return $This.Time.ToString()
        }
    }

    # // ========================================
    # // | Single object that displays a status |
    # // ========================================

    Class YoutubeDlStatus
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        YoutubeDlStatus([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
        {
            $This.Index   = $Index
            $This.Elapsed = $Time
            $This.State   = $State
            $This.Status  = $Status
        }
        [String] ToString()
        {
            Return "[{0}] (State: {1}/Status: {2})" -f $This.Elapsed, $This.State, $This.Status
        }
    }

    # // =========================================================================
    # // | A collection of status objects, uses itself to create/update messages |
    # // =========================================================================

    Class YoutubeDlStatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        YoutubeDlStatusBank()
        {
            $This.Reset()
        }
        [String] Elapsed()
        {
            Return @(Switch ($This.End.Set)
            {
                0 { [Timespan]([DateTime]::Now-$This.Start.Time) }
                1 { [Timespan]($This.End.Time-$This.Start.Time) }
            })         
        }
        [Void] SetStatus()
        {
            $This.Status = [YoutubeDlStatus]::New($This.Output.Count,
                                                         $This.Elapsed(),
                                                         $This.Status.State,
                                                         $This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [YoutubeDlStatus]::New($This.Output.Count,
                                                         $This.Elapsed(),
                                                         $State,
                                                         $Status)
        }
        Initialize()
        {
            If ($This.Start.Set -eq 1)
            {
                $This.Update(-1,"Start [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.Start.Toggle()
            $This.Update(0,"Running [~] ($($This.Start))")
        }
        Finalize()
        {
            If ($This.End.Set -eq 1)
            {
                $This.Update(-1,"End [!] Error: Already initialized, try a different operation or reset.")
            }
            $This.End.Toggle()
            $This.Span = $This.Elapsed()
            $This.Update(100,"Complete [+] ($($This.End)), Total: ($($This.Span))")
        }
        Reset()
        {
            $This.Start  = [YoutubeDlTime]::New("Start")
            $This.End    = [YoutubeDlTime]::New("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.SetStatus($State,$Status)
            $This.Write()
            Return $This.Last()
        }
        [Object] Current()
        {
            $This.Update($This.Status.State,$This.Status.Status)
            Return $This.Last()
        }
        [Object] Last()
        {
            Return $This.Output[$This.Output.Count-1]
        }
        [String] ToString()
        {
            If (!$This.Span)
            {
                Return $This.Elapsed()
            }
            Else
            {
                Return $This.Span
            }
        }
    }

    Class YoutubeFile
    {
        [UInt32] $Index
        [String] $Name
        [String] $Hash
        [String] $URL
        [UInt32] $Exists
        [UInt32] $Compliant
        [String] $Fullname
        YoutubeFile([UInt32]$Index,[String]$Name,[String]$Hash)
        {
            $This.Index = $Index
            $This.Name  = $Name
            $This.Hash  = $Hash
            $This.Url   = "https://youtu.be/$Hash"
        }
        [String] ToString()
        {
            Return "<YoutubeFile[{0}]>" -f $This.Index
        }
    }

    Class YoutubeDl
    {
        [Object] $Console
        [String] $Executable
        [String] $Path
        [Object] $Output
        YoutubeDl([String]$Executable)
        {
            # Start console logger
            $This.Console        = $This.GetConsole()

            # Test executable
            $This.Update(0,"Testing executable: [$Executable]")

            If (!$This.TestPath(0,$Executable))
            {
                $This.Update(-1,"Invalid path: [$Executable]")
                $This.Console.Finalize()
            }

            ElseIf (!$This.Validate($Executable))
            {
                $This.Update(-1,"Invalid executable: [$Executable]")
                $This.Console.Finalize()
            }
            
            Else
            {
                $This.Update(1,"Valid executable: [$Executable]")
                $This.Executable     = $Executable
                $This.Output         = @( )
                $This.Update(1,"Ready for additional arguments")
            }
        }
        [Object] GetConsole()
        {
            $Item = [YoutubeDlStatusBank]::New()
            $Item.Initialize()
            Return $Item
        }
        Update([Int32]$State,[String]$Status)
        {
            $This.Console.Update($State,$Status)
            Write-Host $This.Console.Last()
        }
        Status()
        {
            $This.Console.Status()
            Write-Host $This.Console.Last()
        }
        [UInt32] Validate([String]$Executable)
        {
            Return (Get-FileHash $Executable).Hash -eq "26E5C00C35C5C3EDC86DFC0A720AED109A13B1B7C67AC654A0CE8FF82A1F2C16"
        }
        [Object] YoutubeFile([UInt32]$Index,[String]$Name,[String]$Hash)
        {
            Return [YoutubeFile]::New($Index,$Name,$Hash)
        }
        [UInt32] TestPath([UInt32]$Type,[String]$Path)
        {
            $Item = Switch ($Type)
            {
                0 {      [System.IO.File]::Exists($Path) }
                1 { [System.IO.Directory]::Exists($Path) }
            }

            Return $Item
        }
        [Object[]] GetChildItem()
        {
            If (!$This.Path)
            {
                Return $Null
            }
            Else
            {
                Return @(Get-ChildItem $This.Path *.mp3)
            }
        }
        SetPath([String]$Path)
        {
            If (!$This.TestPath(1,$Path))
            {
                Throw "Invalid path"
            }

            $This.Path = $Path

            Write-Host "Changing [~] Path"
            Set-Location $This.Path
        }
        AddFile([String]$Name,[String]$Hash)
        {
            $This.Output += $This.YoutubeFile($This.Output.Count,$Name,$Hash)
            $This.Update(1,"Added [+] file: [$Name]")
        }
        Check()
        {
            $List = $This.GetChildItem()

            $This.Update(0,"Checking [~] ({0}) file(s)" -f $This.Output.Count)

            ForEach ($Item in $This.Output)
            {
                $File = $List | ? BaseName -eq $Item.Name
                $Hash = $List | ? Name     -match $Item.Hash
                If ($File)
                {
                    $This.Update(1,("Found [+] file (name): [{0}]" -f $Item.Name))
                    $Item.Exists    = 1
                    $Item.Compliant = 1
                    $Item.Fullname  = $File.Fullname
                }
                ElseIf ($Hash)
                {
                    $This.Update(1,("Found [+] file (hash): [{0}]" -f $Item.Name))
                    $Item.Exists    = 1
                    $Item.Compliant = 0
                    $Item.Fullname  = $Hash.Fullname
                }
                Else
                {
                    $This.Update(-1,("Not found [!] file: [{0}]" -f $Item.Name))
                }
            }
        }
        Download()
        {
            If (!$This.Path)
            {
                $This.Update(-1,"Exception [!] Path not set")
            }

            ElseIf ($This.Output.Count -eq 0)
            {
                $This.Update(-1,"Exception [!] No files to process")
            }

            Else
            {
                $This.Update(1,("Processing [~] ({0}) file(s)" -f $This.Output.Count))

                ForEach ($Item in $This.Output)
                {
                    $This.Update(0,("Processing [~] file: [{0}]" -f $Item.Name))

                    If (!$Item.Exist)
                    {
                        $Check           = 0
                        $File            = $Null
                        $Splat           = @{ 

                            Filepath     = $This.Executable
                            ArgumentList = "-x --audio-format=mp3 {0}" -f $Item.Url
                        }

                        Start-Process -NoNewWindow @Splat -Wait

                        $This.Update(0,("Checking [~] file: [{0}]" -f $Item.Name))
                        Do
                        {
                            $File        = Get-ChildItem $This.Path | ? Name -match $Item.Hash
                            
                            Start-Sleep -Milliseconds 125
                            $Check      ++
                        }
                        Until (!!$File -or $Check -eq 24)

                        If ($Check -ge 24)
                        {
                            $This.Update(-1,("Failure [!] file: [{0}]" -f $Item.Name))
                        }
                        ElseIf (!!$File)
                        {
                            $Item.Fullname = $File.Fullname
                            $This.Update(1,("Success [+] file: [{0}]" -f $Item.Name))
                        }
                    }
                    If ($Item.Exist)
                    {
                        $This.Update(1,("File exists [+] file: [{0}]" -f $Item.Name))
                    }
                }

                $This.Update(1,("Complete [+] ({0}) file(s) processed" -f $This.Output.Count))
            }
        }
        Rename()
        {
            $This.Check()

            $This.Update(0,("Renaming [~] ({0}) file(s)" -f $This.Output.Count))

            If ($This.Output.Count -gt 1)
            {
                ForEach ($X in 0..($This.Output.Count-1))
                {
                    $File    = $This.Output[$X]
                    Switch ($File.Compliant)
                    {
                        0
                        {
                            $NewName = "{0}\{1}.mp3" -f $This.Path, $File.Name
                            [System.IO.File]::Move($File.Fullname,$NewName)
                            If ([System.IO.File]::Exists($NewName))
                            {
                                $File.Fullname  = $NewName
                                $File.Compliant = 1
                                $This.Update(1,("Success [+] Name: [{0}]" -f $File.Fullname))
                            }
                            Else
                            {
                                $This.Update(-1,("Failure [!] Name: [{0}]" -f $File.Fullname))
                            }
                        }
                        1
                        {
                            $This.Update(1,("File exists [+] Name: [{0}]" -f $File.Fullname))
                        }
                    }
                }
            }
        }
    }

$YoutubeDl = "$Home\downloads\youtube-dl.exe"
$Exe       = [YoutubeDl]::New($YoutubeDl)
$Exe.SetPath("$Home\Downloads")
$Exe.AddFile("Nine Inch Nails - The Fragile (1999)","6iIYpUXbU9s")
$Exe.AddFile("Nine Inch Nails - Ghosts I-IV (2008)","lnVgwSmfNbE")
$Exe.Check()
$Exe.Download()
$Exe.Rename()
$Exe.Console.Finalize()
