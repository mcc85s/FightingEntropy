# _____________________________________________________________________________________________________________
# \_[This is for development purposes, to reconstitute all of the current functions to a new console/session]__\
#  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

"Add-Type -Assembly {0}, {0}.Filesystem, System.Windows.Forms, PresentationFramework" -f "System.IO.Compression" | Invoke-Expression

Function Get-EventLogResources
{
    [CmdLetBinding()]Param([Parameter(ValueFromPipeline)][ValidateScript({Test-Path $_})][String]$Path=$PSScriptRoot)

    #\________________
    Class ResourceTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        ResourceTime([String]$Name)
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
    #\_______________________
    Class ResourceStatusEntry
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        ResourceStatusEntry([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
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
    #\__________________
    Class ResourceStatus
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        ResourceStatus()
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
            $This.Status = [ResourceStatusEntry]::New($This.Output.Count,$This.Elapsed(),$This.Status.State,$This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [ResourceStatusEntry]::New($This.Output.Count,$This.Elapsed(),$State,$Status)
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
            $This.Start  = [ResourceTime]::New("Start")
            $This.End    = [ResourceTime]::New("End")
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
    #\________________
    Class ResourceFile
    {
        [UInt32] $Index
        [String] $Type
        [String] $Name
        [Object] $File
        [UInt32] $Exists
        [Object] $Content = @( )
        ResourceFile([UInt32]$Index,[String]$Type,[String]$Name,[String]$Parent)
        {
            $This.Index   = $Index
            $This.Type    = $Type
            $This.Name    = $Name
            $This.File    = [System.IO.FileInfo]::New($This.Path($Parent))
            $This.Exists  = [UInt32]$This.File.Exists
            $This.Content = Switch ($This.Exists) { 0 { @() } 1 { $This.GetContent() } }
        }
        [String] Path([String]$Parent)
        {
            Return "{0}\{1}\{2}.ps1" -f $Parent, $This.Type, $This.Name
        }
        [String[]] GetContent()
        {
            Return [System.IO.File]::ReadAllLines($This.File)
        }
        [Object] Invoke()
        {
            If ($This.Content)
            {
                Return ($This.Content -join "`n")
            }
            Else
            {
                Return $Null
            }
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }
    #\_____________________
    Class ResourceExecution
    {
        [Object]          $Status
        [Object]            $Last
        [String]            $Path 
        [Object[]]      $Resource = @( )
        Hidden [UInt32] $MaxIndex = 5
        Hidden [String]   $Output
        ResourceExecution([String]$Path)
        {
            If (!($Path | Test-Path))
            {
                Throw "Invalid path"
            }

            # ---------- #
            # Initialize #
            # ---------- #

            $This.Status   = [ResourceStatus]::New()
            $This.Status.Initialize()
            $This.Path     = $Path
            $This.Update(1,"Path [+] Valid")
            $This.Validate()
            $This.GetOutput()
            If ($This.Output)
            {
                $This.Update(1,"Success [+] Output: Ready for external invocation")
            }
            If (!$This.Output)
            {
                $This.Update(-1,"Failed [!] Output: String failure")
            }
            $This.Status.Finalize()

            [Console]::WriteLine(" ")
            [Console]::WriteLine(" ------------------ ")
            [Console]::WriteLine(" Resource Execution ")
            [Console]::WriteLine(" ------------------ ")
            [Console]::WriteLine("     Path: $($This.Path)")
            [Console]::WriteLine("    Start: $($This.Status.Start)")
            [Console]::WriteLine("      End: $($this.Status.End)")
            [Console]::WriteLine("     Span: $($This.Status.Span)")
            [Console]::WriteLine("   Status: <Output Below>")
            [Console]::WriteLine(" ")

            If ($This.Status.Output.Count -gt 99999)
            {
                $This.MaxIndex = ([String]$This.Status.Output[-1].Index).Length
                
                $I    = @{ X = " " * ($This.MaxIndex - 5) -join " "; L = @( ) }
                $I.L += " {0}Index Elapsed          State Status" -f $I.X
                $I.L += " {0}----- -------          ----- ------" -f $I.X

                [Console]::WriteLine($I.L[0])
                [Console]::WriteLine($I.L[1])
            }
            Else
            {
                [Console]::WriteLine(" Index Elapsed          State Status")
                [Console]::WriteLine(" ----- -------          ----- ------")
            }

            ForEach ($Item in $This.Status.Output)
            {
                [Console]::WriteLine($This.Line($Item))
            }

            [Console]::WriteLine(" ")
        }
        [String] Line([Object]$Line)
        {
            $Return = @( )
            ForEach ($Item in $Line.PSObject.Properties)
            {
                $Token   = @{ Index = $This.MaxIndex; Elapsed = 16; State = 5; Status = 0 }[$Item.Name]
                $String  = [String]$Item.Value
                Switch ($Item.Name)
                {
                    Index 
                    { 
                        If ($String.Length -lt $This.MaxIndex)
                        {
                            
                            $Return += (" {0}{1}" -f (" " * ($This.MaxIndex - $String.Length) -join ''), $String)
                        }
                        Else
                        {
                            $Return += " $String"
                        }
                        
                    }
                    Default 
                    {
                        If ($Token -gt 0)
                        {
                            $Return += (" {0}{1}" -f (" " * ($Token - $String.Length) -join ''), $String)
                        }
                        Else
                        {
                            $Return += " $String"
                        }
                    }
                }
            }
            Return ($Return -join "")
        }
        [Object] ResourceFile([String]$Type,[Object]$Item)
        {
            Return [ResourceFile]::New($This.Resource.Count,$Type,$Item,$This.Path)
        }
        [Object] Update([Int32]$State,[String]$Status)
        {
            $This.Status.Update($State,$Status)
            $This.Last = $This.Status.Last()
            Return $This.Last
        }
        [Object] Current()
        {
            $This.Status.Current()
            $This.Last = $This.Status.Last()
            Return $This.Last
        }
        [String[]] Functions()
        {
            $Return  = @( )
            $Return += "Get-AssemblyList Get-ThreadController Get-PropertyItem Get-PropertyObject Get-ControlExtension Get-SystemDetails".Split(" ")
            "ConfigExtension RecordExtension Archive Project Xaml Controller".Split(" ") | % { $Return += "Get-EventLog$_" }
            Return $Return
        }
        [Void] Validate()
        {
            $This.Update(0, "Validating [~] Resources...")
            ForEach ($Item in $This.Functions() | % { $This.ResourceFile("Function", $_) })
            {
                If ($Item.Exists)
                {
                    $Item.Index     = $This.Resource.Count
                    $This.Update( 1, "File [+] Found [$($Item.Name)], added. [Rank: $($Item.Index)]")
                    $This.Resource += $Item
                }
                Else
                {
                    $This.Update(-1, "File [!] [$Item] (Not found), skipped.")
                }
            }
            $This.Update(1, "Validated [+] Resources ($($This.Resource.Count)) items.")
        }
        GetOutput()
        {
            $This.Output = @($This.Resource | ? Exists | % { "# [$($_.Type)]://($($_.Name))", $_.Invoke(), " " }) -join "`n"
        }
        [String] Full()
        {
            Return $This.Output -join "`n"
        }
    }

    [ResourceExecution]::New($Path)
}