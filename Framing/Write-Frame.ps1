Function Write-Frame
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory,Position=0)][String]$Current,
    [Parameter(Position=1)][String]$Last)

    $Output = @( )
    
    Switch (!!$Last)
    {
        $True
        {
            $1       = $Last.Length
            $0       = 116 - $1
            $Output += " {0} _{1}_/" -f (@(" ") * $0 -join ''),(@("_") * $1 -join '')
            $Output += "\{0}/ {1}  " -f (@("_") * $0 -join ''), $Last
        }
        $False
        {
            $Output += "\{0}/" -f ("_" * 118 -join '')
        }
    }

    $1               = $Current.Length
    $0               = 116 - $1
    $Output         += "  {0} /{1}\" -f $Current,(@([char]175) * $0 -join '')
    $Output         += "/{0} {1} " -f (@([Char]175) * ($1 + 2) -join ''), (@(" ") * $0 -join '')

    $Output
}

Function Write-Top
{
    Return "    /¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\" 
}

Function Write-Bottom
{
    Return "    \__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/"
}

Function Write-Mid
{
    Return "    |                                                                                                              |"
}

Function Write-Side
{
    Return @(
    "    _________________________________________________________________________________________________________"
    "    | Side point |/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__|"
    "    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
    )
}

Function Write-Box
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory,Position=0)][String] $Date,
    [Parameter(Mandatory,Position=1)][String] $Name,
    [Parameter(Mandatory,Position=2)][String] $Url)

    $Hash = @{ 0=""; 1 = ""; 2 = "" }
    $Hash[1] = "| {0} | {1} | {2} |" -f $Date, $Name, $URL
    $Hash[0] = @([char]95) * $Hash[1].Length -join ''
    $Hash[2] = @([char]175) * $Hash[1].Length -join ''

    Return $Hash[0..2]
}

Function Write-Border
{
    [CmdletBinding()]Param(
        [Parameter(Position=0)][String]$InputObject
    )

    Begin
    {
        $Output = @( )
        $Content = $InputObject -Split "`n"
    }
    Process
    {
        ForEach ($Line in $Content)
        {
            $Line = $Line.TrimEnd(" ")
            If ($Line.Length -gt 104)
            {
                $Array           = [Char[]]$Line
                $Tray            = ""
                ForEach ($I in 0..($Array.Count-1))
                {
                    If ($Tray.Length -eq 104)
                    {
                        $Output += "   ||   {0}   ||   " -f $Tray
                        $Tray    = ""
                    }
                    $Tray       += $Array[$I]
                }
                If ($I -gt 0 -and $I % 104 -ne 0)
                {
                    $Output      += "   ||   {0}   ||   " -f $Tray
                }
            }
            ElseIf ($Line.Length -eq 104)
            {
                $Line = "   ||   {0}   ||   " -f $Line
            }
            ElseIf ($Line.Length -lt 104 -and $Line.Length -gt 0)
            {
                $Line = "   ||   {0}{1}   ||   " -f $Line, (@(" ") * (104 - $Line.Length) -join '')
            }
            ElseIf ($Line.Length -eq 0)
            {
                $Line = "   ||   {0}   ||   " -f (@(" ") * 104 -join '')
            }
            $Output += $Line
        }
    }
    End
    {
        Return $Output
    }
}
