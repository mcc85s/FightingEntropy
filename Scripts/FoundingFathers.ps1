Class Year
{
    [UInt32]   $Index
    [UInt32]   $Value
    [UInt32]    $Leap
    [UInt32]    $Days
    Year([UInt32]$Index,[UInt32]$Year)
    {
        $This.Index         = $Index
        $This.Value         = $Year
        $This.Leap          = $Year % 4 -eq 0
        $This.Days          = 365
        If ($This.Leap)
        {
            $This.Days ++
        }
    }
    [String] ToString()
    {
        Return $This.Value
    }
}

Class Date
{
    [UInt32] $Month
    [UInt32] $Day
    [UInt32] $Year
    [UInt32] $Rank
    [UInt32] $Total
    [UInt32] $Count
    Date([String]$Date)
    {
        $Hash       = @{ Month   = 31,28,31,30,31,30,31,31,30,31,30,31 }
        $Split      = $Date -Split "/"
        $This.Month = $Split[0]
        $This.Day   = $Split[1]
        $This.Year  = $Split[2]
        $This.Total = 365
        If ($This.Year % 4 -eq 0)
        {
            $This.Total ++
            $Hash.Month[1] ++
        }

        $I = $This.Month-1
        $X = 0
        Do
        {
            If ($X -ne $I)
            {
                $This.Rank = $This.Rank + $Hash.Month[$X]
                $X ++
            }
            ElseIf ($X -eq $I)
            {
                $This.Rank = $This.Rank + $This.Day
            }
        }
        Until ($X -eq $I)
    }
    [String] ToString()
    {
        Return "{0:d2}/{1:d2}/{2}" -f $This.Month, $This.Day, $This.Year
    }
}

Class Lived
{
    [Object] $Start
    [Object] $End
    [Object] $Years
    [UInt32] $Days
    [Float]  $Age
    [String] $Label
    Lived([String]$String)
    {
        If ($String -notmatch "\d{2}\/\d{2}\/\d{4} - \d{2}\/\d{2}\/\d{4}")
        {
            Throw "Invalid input string"
            $Split = $String -Replace " - ","-" -Split "-"
            $This.Life($Split[0],$Split[1])
        }
    }
    Lived ([String]$Start,[String]$End)
    {
        If ($Start -notmatch "\d{2}\/\d{2}\/\d{4}")
        {
            Throw "Invalid start string"
        }
        ElseIf ($end -notmatch "\d{2}\/\d{2}\/\d{4}")
        {
            Throw "Invalid end string"
        }

        $This.Life($Start,$End)
    }
    Life([String]$Start,[String]$End)
    {
        $This.Start = [_Date]$Start
        $This.End   = [_Date]$End

        $This.Years = @( )
        ForEach ($Year in ($This.Start.Year)..($This.End.Year))
        {   
            $This.Years += [Year]::New($This.Years.Count,$Year)
        }

        $This.Start.Count     = $This.Start.Total - $This.Start.Rank
        $This.End.Count       = $This.End.Rank
        $This.Years[  0].Days = $This.Start.Count
        $This.Years[ -1].Days = $This.End.Count

        ForEach ($Year in $This.Years)
        {
            $This.Days        = $This.Days + $Year.Days
        }

        $This.Age             = $This.Days/(365.25)
        $This.Label           = "{0} - {1}" -f $This.Start, $This.End
    }
    [String] ToString()
    {
        Return $This.Label
    }
}

Class FoundingFather
{
    [String] $Name
    [String] $Link
    [Object] $Lived
    [Float]  $Age
    [String] $Roles
    [Object] $Story
    FoundingFather([String]$Name)
    {
        $This.Name  = $Name
        $This.Link  = "https://en.wikipedia.org/wiki/{0}" -f $Name.Replace(" ","_")
        $This.Story = @( )
    }
    Life([String]$String)
    {
        $This.Lived = [Lived]::New($String)
        $This.Age   = $This.Lived.Age
    }
    Life([String]$Start,[String]$End)
    {
        $This.Lived = [Lived]::New($Start,$End)
        $This.Age   = $This.Lived.Age
    }
    Role([String]$String)
    {
        $This.Roles = $String
    }
    Bio([String[]]$Input)
    {
        $This.Story = $Input
    }
}

$FF = ("Thomas Jefferson;James Madison;Alexander Hamilton;John Adams;Samuel Adams;Patrick Henry;James"+
         " Monroe;George Washington") -Split ";" | % { [FoundingFather]::New($_) }

$FF[0].Life("04/13/1743","07/04/1826")
$FF[0].Role("Statesman, Diplomat, lawyer, architect, philosopher, 3rd president (1801-1809)")

$FF[1].Life("03/16/1751","06/28/1836")
$FF[1].Role("Statesman, Diplomat, 4th president (1809-1817), general, all-around badass")

$FF[2].Life("01/11/1755","07/12/1804")
$FF[2].Role("Statesman, Revolutionary, influential interpreter, promoter of the Constitution")

$FF[3].Life("10/30/1735","07/04/1826")
$FF[3].Role("Statesman, attorney, diplomat, writer, 2nd president (1797-1801)")

$FF[4].Life("09/27/1722","10/02/1803")
$FF[4].Role("Statesman, political philosopher")

$FF[5].Life("05/29/1736","06/06/1799")
$FF[5].Role("Attorney, planter, politician, and orator")

$FF[6].Life("04/28/1758","07/04/1831")
$FF[6].Role("Statesman, lawyer, diplomat, 5th president (1817-1825)")

$FF[7].Life("02/22/1732","12/14/1799")
$FF[7].Role("Statesman, Military officer, 1st president (1789-1797)")
