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
    Life([String]$Start,[String]$End)
    {
        $This.Lived = [Lived]::New($Start,$End)
        $This.Age   = $This.Lived.Age
    }
    Role([String]$String)
    {
        $This.Roles = $String
    }
    Bio([String]$String)
    {
        $This.Story = $String -Split "`n"
    }
    [String[]] Output()
    {
        $Hash = @{ }
        0..6  | % { $Hash.Add($_,"") }

        $Hash[0] = "_" * 104 -join ''
        $Hash[1] = "| Name  : {0}" -f $This.Name
        $Hash[2] = "| Link  : {0}" -f $This.Link
        $Hash[3] = "| Lived : {0}" -f $This.Lived
        $Hash[4] = "| Age   : {0}" -f $This.Age
        $Hash[5] = "| Roles : {0}" -f $This.Roles
        $Hash[6] = "|{0}|" -f ("-" * 102 -join '')
        ForEach ($X in 1..5)
        {
            Do
            {
                $Hash[$X] += " "
            }
            Until ($Hash[$X].Length -eq 103)

            $Hash[$X]     += "|"
        }
        ForEach ($Line in $This.Story)
        {
            $Hash.Add($Hash.Count,"| $Line")
            Do
            {
                $Hash[$Hash.Count-1] += " "
            }
            Until ($Hash[$Hash.Count-1].Length -eq 103)

            $Hash[$Hash.Count-1]     += "|"
        }
        $Hash.Add($Hash.Count,(@([Char]175) * 104 -join ''))

        Return @($Hash[0..($Hash.Count-1)])
    }
}

Class FoundingFathers
{
    [Object] $Output
    FoundingFathers()
    {
        $This.Output = @( )
    }
    Add([String]$Name)
    {
        If ($Name -in $This.Output.Name)
        {
            Throw "Founding father already added"
        }

        $This.Output += [FoundingFather]::New($Name)
    }
    Life([UInt32]$Index,[String]$Start,[String]$End)
    {
        $Item = $This.Get($Index)

        If ($Item)
        {
            $Item.Life($Start,$End)
        }
    }
    Role([Uint32]$Index,[String]$String)
    {
        $Item = $This.Get($Index)
        
        If ($Item)
        {
            $Item.Role($String)
        }
    }
    Bio([UInt32]$Index,[String]$String)
    {
        $Item = $This.Get($Index)

        If ($Item)
        {
            $Item.Bio($String)
        }
    }
    [Object] Get([UInt32]$Index)
    {
        If ($Index -gt $This.Output.Count)
        {
            Throw "Index is out of bounds of the array"
        }

        Return $This.Output[$Index]
    }
}

$FF = [FoundingFathers]::new()

# Thomas Jefferson
$FF.Add("Thomas Jefferson")
$FF.Life(0,"04/13/1743","07/04/1826")
$FF.Role(0,"Statesman, Diplomat, lawyer, architect, philosopher, 3rd president (1801-1809)")
$FF.Bio(0,@"
Principle author of the Declaration of Independence, served as vice president under Federalist
John Adams. They were both good friends as well as political rivals. During the American Revolution
Jefferson represented Virginia in the Continental Congress which adopted the Declaration of ID4.
He also played a key role in influencing James Madison, Alexander Hamilton, and John Jay in writing 
THE FEDERALIST PAPERS. Proponent of democracy, republicanism, nd individual rights, motivating the
colonists to break away from Great Britain.
"@)

# James Madison
$FF.Add("James Madison")
$FF.Life(1,"03/16/1751","06/28/1836")
$FF.Role(1,"Statesman, Diplomat, 4th president (1809-1817), general, all-around badass")
$FF.Bio(1,@"
Born in Virginia, served as member of the Virginia House of Delegates, and the Continental Congress
during the American Revolutionary War. Hailed as the FATHER OF THE CONSTITUTION, and assisted in
writing the 85 essays that became known as THE FEDERALIST PAPERS which served to provide guidelines
for separation of church and state, and to ensure that no one institution could become too powerful.
"@)

# Alexander Hamilton
$FF.Add("Alexander Hamilton")
$FF.Life(2,"01/11/1755","07/12/1804")
$FF.Role(2,"Statesman, Revolutionary, influential interpreter, promoter of the Constitution")
$FF.Bio(2,@"
Founded the Federalist Party, the nation's financial system, the United States Coast Guard, and the
New York Post newspaper. Out of these founding fathers, Hamilton lived the shortest life. He was
the first secretary of the treasury, lead the federal government's funding of the states 
American Revolutionary War debts, and established the nations first (2) de facto central banks,
the Bank of North america, and the First Bank of the United States. Also established a system of
tariffs, and resumption of friendly trade relations with Britain. He believed in having a strong
central government, a vigorous executive branch, strong commercial economy, support for 
manufacturing, and a strong national defense. The dude was no joke.
"@)

# John Adams
$FF.Add("John Adams")
$FF.Life(3,"10/30/1735","07/04/1826")
$FF.Role(3,"Statesman, attorney, diplomat, writer, 2nd president (1797-1801)")
$FF.Bio(3,@"
He served as a leader of the American Revolution which achieved independence from Great Britain
and during the war, served as a diplomat in Europe. He was elected to be vice president twice.
He was also a rather dedicated diarist, and regularly corresponded with some important people.
Like his wife Abigail Adams, and his (buddy/rival) Thomas Jefferson.
"@)

# Samuel Adams
$FF.Add("Samuel Adams")
$FF.Life(4,"09/27/1722","10/02/1803")
$FF.Role(4,"Statesman, political philosopher, 4th gov of Massachusetts")
$FF.Bio(4,@"
Served as a politician in colonial Massachusetts, and was a leader of the movement that
became the American Revolution, and is essentially the godfather of American republicanism
which shaped the political culture of the United States. He was John Adams 2nd cousin.
"@)

# Patrick Henry
$FF.Add("Patrick Henry")
$FF.Life(5,"05/29/1736","06/06/1799")
$FF.Role(5,"Attorney, planter, politician, orator, and (1st/6th) gov of VA")
$FF.Bio(5,@"
Born in Hanover County, Virginia, most famous quote was 'Give me liberty, or give me death~',
Had SOME business related ventures running his own store as well as Hanover Tavern.
Became a self-taught lawyer and earned prominency by winning in Parsons Cause against the
Anglican clergy. He was invited to be a delegate for the 1787 Constitutional Convention, 
but declined. Was not a fan of th Stamp Act of 1765... Served as a successful politician
for many years, but eventually returned to practicing law.
"@)

# James Monroe
$FF.Add("James Monroe")
$FF.Life(6,"04/28/1758","07/04/1831")
$FF.Role(6,"Statesman, lawyer, diplomat, 5th president (1817-1825)")
$FF.Bio(6,@"
Perhaps most well known for issuing the Monroe Doctrine, a policy of opposing European
colonialism in the Americas while effectively asserting U.S. dominance, empire and 
(hegemony/dominance). Served in the Continental Army during the American Revolutionary
War, and studied law under Thomas Jefferson. Also served as a delegate to the Continental
Congress, and was one of the few founding fathers who opposed ratification of the 
United States Constitution.
"@)

# George Washington
$FF.Add("George Washington")
$FF.Life(7,"02/22/1732","12/14/1799")
$FF.Role(7,"Statesman, Military officer, 1st president (1789-1797)")
$FF.Bio(7,@"
The very FIRST president of the United States of America. Appointed by the Continental
Congress as commander of the Continental Army, led the Patriot forces to victory in the
American Revolutionary War, and served as president of the Constitutional Convention
of 1787, where the Constitution of the United States of America as written and signed.
Washington has ben called the "Father of the Nation" for being a fearless badass.
"@)

$FF.Output | % Output
