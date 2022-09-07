Function Get-FileProgress
{
    [CmdLetBinding()]Param(
        [Parameter(Mandatory,Position=0)]
        [ValidateScript({Test-Path $_})][String]$Path,
        [Parameter(Mandatory,Position=1)][UInt64]$SizeBytes
    )

    Class FileTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        FileTime([String]$Name)
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

    Class FileStatus
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        FileStatus([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
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

    Class FileStatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        FileStatusBank()
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
            $This.Status = [FileStatus]::New($This.Output.Count,$This.Elapsed(),$This.Status.State,$This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [FileStatus]::New($This.Output.Count,$This.Elapsed(),$State,$Status)
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
            $This.Start  = [FileTime]::New("Start")
            $This.End    = [FileTime]::New("End")
            $This.Span   = $Null
            $This.Status = $Null
            $This.Output = [System.Collections.ObjectModel.ObservableCollection[Object]]::New()
        }
        Write()
        {
            $This.Output.Add($This.Status)
        }
        [Object] Update([UInt32]$State,[String]$Status)
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

    Class FileProgress
    {
        Hidden [Object] $Item
        [Object] $Status
        [Object] $Last
        [String] $Path
        [String] $Name
        [UInt64] $Size
        [String] $SizeGb
        [String] $Percent
        [Object] $Time
        Hidden [String] $Progress
        Hidden [UInt64] $Total
        FileProgress([String]$Path,[UInt64]$Total)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid Path"
            }

            $This.Path  = $Path
            $This.Total = $Total
            $This.Get()
            $This.Initialize()
        }
        Get()
        {
            $This.Item     = Get-Item $This.Path
            $This.Name     = $This.Item.Name
            $This.Size     = $This.Item.Length
            $This.SizeGb   = "{0:n2} GB" -f ($This.Size/1GB)
            $This.Time     = Get-Date
            $This.Percent  = ($This.Item.Length*100)/$This.Total
            $Remain        = 100-$This.Percent
            $Elapsed       = [TimeSpan]($This.Time-$This.Item.CreationTime)
            $Unit          = [TimeSpan]($Elapsed/$This.Percent)*$Remain
            $End           = $This.Time + $Unit
            $Span          = [Timespan]($End-$This.Time)
            $This.Progress = "({0:n2}%) {1} [{2}]" -f $This.Percent,$End.ToString("(MM/dd/yy) HH:mm:ss"),$This.Eta($Span)
        }
        [String] Eta([Object]$S)
        {
            If ($S.Days -gt 0)
            {
                Return "{0:d2}d {1:d2}h {2:d2}m {3:d2}s" -f $S.Days, $S.Hours, $S.Minutes, $S.Seconds
            }

            ElseIf ($S.Days -eq 0 -and $S.Hours -gt 0)
            {
                Return "{0:d2}h {1:d2}m {2:d2}s" -f $S.Hours, $S.Minutes, $S.Seconds
            }

            ElseIf ($S.Days -eq 0 -and $S.Hours -eq 0 -and $S.Minutes -gt 0)
            {
                Return "{0:d2}m {1:d2}s" -f $S.Minutes, $S.Seconds
            }

            ElseIf ($S.Days -eq 0 -and $S.Hours -eq 0 -and $S.Minutes -eq 0 -and $S.Seconds -gt 0)
            {
                Return "{0:d2}s" -f $S.Seconds
            }

            Else
            {
                Return $Null
            }
        }
        [Object] Current()
        {
            $This.Last = $This.Status.Current()
            Return $This.Last
        }
        [Object] Update()
        {
            $This.Get()
            $This.Last = $This.Status.Update(1,$This.Progress)
            Return $This.Last
        }
        [Object] Update([UInt32]$State,[String]$Status)
        {
            $This.Get()
            $This.Last = $This.Status.Update($State,$Status)
            Return $This.Last
        }
        Initialize()
        {
            $This.Status = [FileStatusBank]::New()
            $This.Status.Initialize()
            $This.Status.Start.Time = $This.Item.CreationTime
            $This.Update(1,"Subcontrol [+] Status: Initialized")
        }

        [Object[]] Slot()
        {
            Return @( "Status Last Path Name Size SizeGb Percent Time" -Split " " | % { $This.$_ } )
        }
        [String] Pad([UInt32]$Length,[String]$Char,[String]$String)
        {
            $Buffer  = $Length - $String.Length
            $Padding = $Char * ($Buffer-2)
            Return "{0}{1} |" -f $String, $Padding
        }
        [String[]] Output()
        {
            $This.Update()
            $X       = 120
            $Obj     = @{
                0    = @([char]95) * $X -join ''
                1    = $This.Pad($X," ","| Status  : $($This.Status)")
                2    = $This.Pad($X," ","| Last    : $($This.Last)")
                3    = $This.Pad($X," ","| Path    : $($This.Path)")
                4    = $This.Pad($X," ","| Name    : $($This.Name)")
                5    = $This.Pad($X," ","| Size    : $($This.Size)")
                6    = $This.Pad($X," ","| SizeGb  : $($This.SizeGb)")
                7    = $This.Pad($X," ","| Percent : $($This.Percent)")
                8    = $This.Pad($X," ","| Time    : $($This.Time.ToString('MM/dd/yy HH:mm:ss'))")
                9    = @([char]175) * $X -join ''
            }

            Return @($Obj[0..($Obj.Count-1)])
        }
        [String[]] Comment()
        {
            Return @( $This.Output() | % { "# $_ "} )
        }
    }

    [FileProgress]::New($Path,$SizeBytes)
}
