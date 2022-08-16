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

Function Top
{
    Return "    /¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\" 
}

Function Bottom
{
    Return "    \__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/"
}

Function Mid
{
    Return "    |                                                                                                              |"
}

Function Side
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
