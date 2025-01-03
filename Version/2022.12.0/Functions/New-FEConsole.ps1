    
<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-03-28 15:56:07                                                                  //
 \\==================================================================================================// 

    FileName   : New-FEConsole.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : Meant to collect status/time information for a console or etc.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-12-30
    Modified   : 2023-03-28
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : -

.Example
#>

Function New-FEConsole
{
    # // =======================================================
    # // | Used to track console logging, similar to Stopwatch |
    # // =======================================================

    Class StatusTime
    {
        [String]   $Name
        [DateTime] $Time
        [UInt32]    $Set
        StatusTime([String]$Name)
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

    Class StatusEntry
    {
        [UInt32]   $Index
        [String] $Elapsed
        [Int32]    $State
        [String]  $Status
        StatusEntry([UInt32]$Index,[String]$Time,[Int32]$State,[String]$Status)
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

    Class StatusBank
    {
        [Object]    $Start
        [Object]      $End
        [String]     $Span
        [Object]   $Status
        [Object]   $Output
        StatusBank()
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
            $This.Status = [StatusEntry]::New($This.Output.Count,
                                                  $This.Elapsed(),
                                                  $This.Status.State,
                                                  $This.Status.Status)
        }
        [Void] SetStatus([Int32]$State,[String]$Status)
        {
            $This.Status = [StatusEntry]::New($This.Output.Count,
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
            $This.Start  = [StatusTime]::New("Start")
            $This.End    = [StatusTime]::New("End")
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
        [Object] DumpConsole()
        {
            Return $This.Output | % ToString
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

    [StatusBank]::New()
}
