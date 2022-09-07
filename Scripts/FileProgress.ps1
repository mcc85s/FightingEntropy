# For tracking the progress of a files' transfer output.
# So, if I have a 252GB file that I accidentally deleted, and I wanna know WHEN the program will be done
# recovering the file...? Voila.
# Usage at the bottom...

Class FileProgress
{
    Hidden [Object] $Item
    [String] $Path
    [String] $Name
    [UInt64] $Size
    [String] $SizeGb
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
    }
    Get()
    {
        $This.Item   = Get-Item $This.Path
        $This.Name   = $This.Item.Name
        $This.Size   = $This.Item.Length
        $This.SizeGb = "{0:n2} GB" -f ($This.Size/1GB)
    }
    [String] Rate()
    {
        $File        = Get-Item $This.Path
        $Date        = Get-Date
        $Percent     = ($File.Length*100)/$This.Total
        $Remain      = 100-$Percent
        $Elapsed     = [TimeSpan]($Date-$File.CreationTime)
        $Unit        = [TimeSpan]($Elapsed/$Percent)*$Remain
        $End         = $Date + $Unit
        $Span        = [Timespan]($End-$Date)
        Return ("({0:n2}%) {1} [{2}]" -f $Percent,$End.ToString("(MM/dd/yy) HH:mm:ss"),$This.Eta($Span))
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
}

$Path   = "C:\Users\coolguy5000\file.file"
$Max    = 271540746240
$File   = [FileProgress]::New($Path,$Max)
$File.Rate()

# (86.72%) (09/06/22) 10:30:27 [25m 29s]
