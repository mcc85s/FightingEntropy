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
        $Elapsed     = [TimeSpan]($Date-$This.Item.CreationTime)
        $Unit        = [TimeSpan]($Elapsed/$Percent)*$Remain
        $End         = $Date + $Unit
        Return ("({0:n2}%) {1}" -f $Percent, $End.ToString())
    }
}

$Path   = "C:\Users\coolguy5000\file.file"
$Max    = 271540746240
$File   = [FileProgress]::New($Path,$Max)
$File.Rate()

# (4.99%) 9/6/2022 5:30:43 PM
