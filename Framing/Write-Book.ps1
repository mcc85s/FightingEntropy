Function Write-Book
{
    [CmdletBinding()]Param([Parameter(Mandatory,Position=0)][String]$Name)

    Class PageDimension
    {
        [UInt32] $Width
        [UInt32] $Height
        [UInt32] $Characters
        PageDimension()
        {
            $This.Width      = 120
            $This.Height     = 80
            $This.Characters = $This.Width * $This.Height
        }
    }

    Class Line
    {
        [UInt32] $Index
        [String] $Content
        Line([UInt32]$Index,[String]$Content)
        {
            $This.Index   = $Index
            $This.Content = $Content
        }
        [String] ToString()
        {
            Return $This.Content
        }
    }

    Class Section
    {
        [UInt32] $Index
        [String] $Name
        [Object] $Line
        Section([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Line    = @( )
            $Content      = $Content -Split "`n"
            Switch ($Content.Count)
            {
                {$_ -eq 1}
                {
                    $This.Line += [Line]::New($This.Line.Count,$Content)
                }
                {$_ -gt 1}
                {
                    ForEach ($X in 0..($Content.Count-1))
                    { 
                        $This.Line += [Line]::New($This.Line.Count,$Content[$X]) 
                    }
                }
            }
            $This.Rerank()
        }
        RemoveContent([UInt32]$Index)
        {
            If ($Index -gt $This.Line.Count)
            {
                Throw "Invalid line index"
            }

            $This.Line = $This.Line | ? Index -ne $Index

            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Line.Count -eq 1)
            {
                $This.Line[0].Index = 0
            }
            ElseIf ($This.Line.Count -gt 1)
            {
                ForEach ($X in 0..($This.Line.Count-1))
                {
                    $This.Line[$X].Index = $X
                }
            }
        }
        [String] ToString()
        {
            Return $This.Name
        }
        [String[]] Output()
        {
            $Hash = @{ }
            $1    = $This.Name.Length
            $0    = 116 - $1
            $Hash.Add($Hash.Count,("  {0} /{1}\" -f $This.Name,(@([char]175) * $0 -join '' )))
            $Hash.Add($Hash.Count,("/{0} {1} " -f (@([Char]175) * ($1 + 2) -join ''), (@(" ") * $0 -join '')))
            ForEach ($Line in $this.Line | % Content)
            {
                $Hash.Add($Hash.Count,"    $Line    ")
            }
            $Hash.Add($Hash.Count,(" {0} _{1}_/" -f (@(" ") * $0 -join ''),(@("_") * $1 -join '')))
            $Hash.Add($Hash.Count,("\{0}/ {1}  " -f (@("_") * $0 -join ''), $This.Name))

            Return @($Hash[0..($Hash.Count-1)])
        }
    }

    Class Chapter
    {
        [UInt32] $Index
        [String] $Label
        [UInt32] $Page
        [String] $Name
        [Object] $Header
        [Object] $Section
        Chapter([Int32]$Index,[String]$Name)
        {
            $This.Index   = $Index
            $This.Name    = $Name
            $This.Header  = @( )
            $This.Section = @( )
        }
        SetLabel([String]$Label)
        {
            $This.Label   = $Label
            $This.Header  = Write-Theme ("{0} - {1}" -f $This.Label, $This.Name) -Text | % { $_.TrimStart("#") }
        }
        AddSection([String]$Name,[String[]]$Content)
        {
            If ($Name -in $This.Section.Name)
            {
                Throw "Section already exists"
            }

            $This.Section += [Section]::New($This.Section.Count,$Name,$Content)
            If ($Name -eq "Start")
            {
                $This.Section | ? Name -eq Start | % { $_.Index = 0 }
            }
            
            $This.Rerank()
        }
        RemoveSection([String]$Name)
        {
            If ($Name -notin $This.Section.Name)
            {
                Throw "Invalid section name"
            }

            $This.Section = $This.Section | ? Name -ne $Name

            $This.Rerank()
        }
        RemoveSection([UInt32]$Index)
        {
            If ($Index -gt $This.Section.Count)
            {
                Throw "Invalid section index"
            }

            $This.Section = $This.Section | ? Index -ne $Index

            $This.Rerank()
        }
        Rerank()
        {
            If ($This.Section.Count -eq 1)
            {
                $This.Section[0].Index = 0
            }
            ElseIf ($This.Section.Count -gt 1)
            {
                ForEach ($X in 0..($This.Section.Count-1))
                {
                    $This.Section[$X].Index = $X
                }
            }
        }
        [String[]] Output()
        {
            $Out                 = @( )
            $This.Header         | % { $Out += $_ }
            $Out                += " "
            ForEach ($Line in $This.Section | % Output)
            {
                $Out            += $Line
            }

            Return $Out
        }
        [String] ToString()
        {
            Return $This.Name
        }
    }

    Class Book
    {
        [String] $Name
        [Object] $Cover
        [Object] $Flag
        [Object] $Table
        [Object] $Chapter
        Book([String]$Name)
        {
            Write-Host "Assembling book... $Name"
            $This.Name    = $Name
            $This.Cover   = $This.Resource("Not%20News%20(001-Cover).txt")
            $This.Flag    = $This.Resource("Not%20News%20(002-Flag).txt")
            $This.Table   = $This.Resource("Not%20News%20(003-Table%20of%20Content).txt")
            $This.Chapter = @( )
            $This.LoadChapters()
        }
        [String[]] Resource([String]$File)
        {
            Write-Host "Loading ($File)"
            Return @( Invoke-RestMethod "https://github.com/mcc85s/FightingEntropy/blob/main/Framing/$File`?raw=true" )
        }
        LoadChapters()
        {
            $Chapters = ($This.Table -Split "`n")[3..14] | % { $_.Substring(28).Replace("|"," ").TrimEnd(" ") }
            ForEach ($Chapter in $Chapters)
            {
                Write-Host "Loading Chapter ($Chapter)"
                $This.AddChapter($Chapter)
            }
        }
        AddChapter([String]$Name)
        {
            If ($Name -in $This.Chapter.Name)
            {
                Throw "Chapter already exists"
            }
            
            $This.Chapter += [Chapter]::New($This.Chapter.Count,$Name)
        }
        RemoveChapter([String]$Name)
        {
            If ($Name -notin $This.Chapter.Name)
            {
                Throw "Invalid chapter name"
            }

            $This.Chapter = @($This.Chapter | ? Name -ne $Name)

            $This.Rerank()
        }
        RemoveChapter([Int32]$Index)
        {
            If ($Index -gt $This.Chapter.Count)
            {
                Throw "Invalid chapter index"
            }

            $This.Chapter = @($This.Chapter | ? Index -ne $Index)

            $This.Rerank()
        }
        SetLabel([UInt32]$Index,[String]$String)
        {
            $Item = $This.Get($Index)

            If ($Item)
            {
                $Item.SetLabel($String)
            }
        }
        AddSection([UInt32]$Index,[String]$Name,[String[]]$Content)
        {
            $Item = $This.Get($Index)

            If ($Item)
            {
                $Item.AddSection($Name,$Content)
            }
        }
        Rerank()
        {
            If ($This.Chapter.Count -eq 1)
            {
                $This.Chapter[0].Index = 0
            }
            ElseIf ($This.Chapter.Count -gt 1)
            {
                ForEach ($X in 0..($This.Chapter.Count-1))
                {
                    $This.Chapter[$X].Index = $X
                }
            }
        }
        [Object] Get([UInt32]$Index)
        {
            If ($Index -gt $This.Chapter.Count)
            {
                Throw "Invalid index"
            }

            Return $This.Chapter[$Index]
        }
    }

    [Book]::New($name)
}

Function Get-FoundingFathers
{
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
        Bio([String[]]$String)
        {
            $This.Story = $String
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
        Bio([UInt32]$Index,[String[]]$String)
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
    $FF.Bio(0,@("Principle author of the Declaration of Independence, served as vice president under Federalist",
                "John Adams. They were both good friends as well as political rivals. During the American Revolution",
                "Jefferson represented Virginia in the Continental Congress which adopted the Declaration of ID4.",
                "He also played a key role in influencing James Madison, Alexander Hamilton, and John Jay in writing",
                "THE FEDERALIST PAPERS. Proponent of democracy, republicanism, nd individual rights, motivating the",
                "colonists to break away from Great Britain."))

    # James Madison
    $FF.Add("James Madison")
    $FF.Life(1,"03/16/1751","06/28/1836")
    $FF.Role(1,"Statesman, Diplomat, 4th president (1809-1817), general, all-around badass")
    $FF.Bio(1,@("Born in Virginia, served as member of the Virginia House of Delegates, and the Continental Congress",
                "during the American Revolutionary War. Hailed as the FATHER OF THE CONSTITUTION, and assisted in",
                "writing the 85 essays that became known as THE FEDERALIST PAPERS which served to provide guidelines",
                "for separation of church and state, and to ensure that no one institution could become too powerful."))

    # Alexander Hamilton
    $FF.Add("Alexander Hamilton")
    $FF.Life(2,"01/11/1755","07/12/1804")
    $FF.Role(2,"Statesman, Revolutionary, influential interpreter, promoter of the Constitution")
    $FF.Bio(2,@("Founded the Federalist Party, the nation's financial system, the United States Coast Guard, and the",
                "New York Post newspaper. Out of these founding fathers, Hamilton lived the shortest life. He was",
                "the first secretary of the treasury, lead the federal government's funding of the states",
                "American Revolutionary War debts, and established the nations first (2) de facto central banks,",
                "the Bank of North america, and the First Bank of the United States. Also established a system of",
                "tariffs, and resumption of friendly trade relations with Britain. He believed in having a strong",
                "central government, a vigorous executive branch, strong commercial economy, support for",
                "manufacturing, and a strong national defense. The dude was no joke."))

    # John Adams
    $FF.Add("John Adams")
    $FF.Life(3,"10/30/1735","07/04/1826")
    $FF.Role(3,"Statesman, attorney, diplomat, writer, 2nd president (1797-1801)")
    $FF.Bio(3,@("He served as a leader of the American Revolution which achieved independence from Great Britain",
                "and during the war, served as a diplomat in Europe. He was elected to be vice president twice.",
                "He was also a rather dedicated diarist, and regularly corresponded with some important people.",
                "Like his wife Abigail Adams, and his (buddy/rival) Thomas Jefferson."))

    # Samuel Adams
    $FF.Add("Samuel Adams")
    $FF.Life(4,"09/27/1722","10/02/1803")
    $FF.Role(4,"Statesman, political philosopher, 4th gov of Massachusetts")
    $FF.Bio(4,@("Served as a politician in colonial Massachusetts, and was a leader of the movement that",
                "became the American Revolution, and is essentially the godfather of American republicanism",
                "which shaped the political culture of the United States. He was John Adams 2nd cousin."))

    # Patrick Henry
    $FF.Add("Patrick Henry")
    $FF.Life(5,"05/29/1736","06/06/1799")
    $FF.Role(5,"Attorney, planter, politician, orator, and (1st/6th) gov of VA")
    $FF.Bio(5,@("Born in Hanover County, Virginia, most famous quote was 'Give me liberty, or give me death~',",
                "Had SOME business related ventures running his own store as well as Hanover Tavern.",
                "Became a self-taught lawyer and earned prominency by winning in Parsons Cause against the",
                "Anglican clergy. He was invited to be a delegate for the 1787 Constitutional Convention,",
                "but declined. Was not a fan of th Stamp Act of 1765... Served as a successful politician",
                "for many years, but eventually returned to practicing law."))

    # James Monroe
    $FF.Add("James Monroe")
    $FF.Life(6,"04/28/1758","07/04/1831")
    $FF.Role(6,"Statesman, lawyer, diplomat, 5th president (1817-1825)")
    $FF.Bio(6,@("Perhaps most well known for issuing the Monroe Doctrine, a policy of opposing European",
                "colonialism in the Americas while effectively asserting U.S. dominance, empire and",
                "(hegemony/dominance). Served in the Continental Army during the American Revolutionary",
                "War, and studied law under Thomas Jefferson. Also served as a delegate to the Continental",
                "Congress, and was one of the few founding fathers who opposed ratification of the",
                "United States Constitution."))

    # George Washington
    $FF.Add("George Washington")
    $FF.Life(7,"02/22/1732","12/14/1799")
    $FF.Role(7,"Statesman, Military officer, 1st president (1789-1797)")
    $FF.Bio(7,@("The very FIRST president of the United States of America. Appointed by the Continental",
                "Congress as commander of the Continental Army, led the Patriot forces to victory in the",
                "American Revolutionary War, and served as president of the Constitutional Convention",
                "of 1787, where the Constitution of the United States of America as written and signed.",
                "Washington has ben called the 'Father of the Nation' for being a fearless badass."))

    $Out       = @( )

    $Out      += "Here is a list of the main founding fathers of the United States of America:"
    $Out      += "______________________________________________________________________"
    $Out      += "| Thomas Jefferson | James Madison | Alexander Hamilton | John Adams |"
    $Out      += "| Samuel Adams  | Patrick Henry  | James Monroe | George Washington  |"
    $Out      += (@([char]175) * $Out[1].Length -join '')
    $Out      += "The following information for each of these men is, for the most part, directly from Wikipedia."

    $FF.Output | % Output | % { $Out += $_ }

    $Out
}

$Book = Write-Book "Top Deck Awareness - Not News"

$Book.SetLabel(0,"Prologue")
$Book.AddSection(0,"Start",@'
Benjamin Franklin: It is the RESPONSIBILITY of EVERY citizen, to QUESTION AUTHORITY.
Keep this quote in mind, because it is the beginning and the end of this entire document.
'@)

$Book.AddSection(0,"Introduction (1)",@'
Benjamin Franklin was one of the founding fathers of the United States of America, and a very critical
one at that. Benjamin Franklin, was a dude that had principles down pat, as he was an avid writer,
quite the scientist, an inventor (invented bifocals), an able-bodied statesman, top-shelf diplomat,
printer, publisher, political philosopher... he was really a mixed bag when it came stuff that only
geniuses could do, back in his day. 

In other words, quite a rare guy.
One of his favorite philosophies was THIS quote
________________________________________________________________
| Though I may not agree with what you have to say...?         |
| I’ll defend, to the death... your right to say it. -Voltaire |
|--------------------------------------------------------------|
|                      Sorta sounds like...                    |
|--------------------------------------------------------------|
| If we don't believe in free speech for those we despise...?  |
| ...then we don't believe in it at all.         -Noam Chomsky |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Anyway, it is this ideology AND philosophy, that became the inspiration for the first Amendment to the 
Constitution of the United States of America. 

This philosophy was one that HE, along with the rest of the founding fathers, ALL stood by, as they
spent day after day, writing draft after draft, knowing that they may very well be the authors, of the
greatest document that has ever been written in history... 
____________________________________________________
| The Constitution of the United States of America |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Finally, the day came, they all looked at each other in suspense and asked each other:

 /¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\

Guy 2 : ...this is... 
        ...IT... 
        ...isn’t it...? 
Guy 3 : Yeah man.
Guy 4 : Look, we've spent almost (2) weeks on this thing...
Guy 3 : Yeah I know...

 \__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/

...they’d ALL been waiting for this day to come for a very long time... when the moment came, and the 
very last line was written...? That man had to shake his hand because it kept cramping up:

 /¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\

 Guy 1 : Damn, my friggen hand... 
         *shaking it around* 
         ...all cramped up.
 Guy 2 : You did an amazing job, dude.
 Guy 3 : That's right, dude.
 Guy 4 : I too, think you did a wonderful job.
 Guy 2 : *speaks more loudly* Everybody...
         Do we ALL agree that Guy 1 did a phenomenal job writing this...?
 All   : *clammoring* Hell yeah, dude.
 Guy 2 : Then, it is agreed upon.
         Quite an amazing document you've written, Guy 1.

 \__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/¯¯\__/

He was right. 
They all signed the document, one that was an ETERNITY in the making... they all knew that this was
no joke... it needed to be ABSOLUTELY PERFECT... and it was JUST ABOUT COMPLETE, except...
(1) man still hadn’t signed it yet.
A rather important man... 
...this man was always known for being incredibly bombastic, so he knew the time was right, and so... 
...he gave his signature speech.
'@)

$Book.AddSection(0,"Signature Speech",@'
Franklin : Gentlemen, this is MORE than words on a piece of paper that we’re responsible for authoring,
           and signing.
           This will be the GREATEST document EVER written.
           This thing needs to be MORE than just, bulletproof.
           The paper may be destroyed...? But, its' legacy can never die.
           Its' philosophies may be amended...? But, its' principles will never lie.
           Freedom from oppression and tyranny will remain its' driving force...
           ...and even if one day it fails...? May it provide one last recourse...
           The foundation upon which this nation is built, needs to be INVINCIBLE, in theory...
           Therefore, every natural born citizen from this day forward... 
           ...shall inherit our labors freely.
           This document, the Constitution of the United States of America... 
           ...shall be hyperbolic and timeless.
           At last, the time has come... 
           ...for the very last man to sign this.
           *signs the Constitution of the United States of America*
'@)

$Book.AddSection(0,"Introduction (2)",@'
At that moment, the United States of America was finally formed, on an official basis, although the 
Articles of Confederation had been its original Constitution, this new version would replace it. 
It took approximately 12 days for these men to complete the document, and the document has been 
amended approximately 27 times, with the first 10 amendments being referred to as the Bill of Rights.

However- they knew that the hard work was complete.

They knew what they were writing, would be the beginning and the end, virtues that left no stone 
unturned, protecting/defending every American from that day forward... they would be damned to fail
their own future Constituents, children, grandchildren, and great grandchildren... 

...they knew tyranny would return, and tear it all apart... 

However, the United States became a true nation with one last signature from this man.

Benjamin Franklin was in Boston in 1706, he eventually moved to Philadelphia, where he became a
Freemason (architecture and stone) and was eventually promoted to grand master. 

As a young lad, his father was able to send him to Latin school for a couple of years. 
He wrote a lot, used a pen name “Silence Dogood” to try and get his work published. 
His brother was a printer, and he became his printing apprentice at the age of 15.

When he grew up he married Deborah Read, and fathered 3 children named William, Francis, and Sarah. 
His son Francis became very ill from an illness which complicated his planned inoculation for smallpox, 
and died. 

Benjamin Franklin became an advocate for smallpox inoculation afterward.

He did plenty of work in the colonial days (Albany Congress/1754) BEFORE the...
...Declaration of Independence.

Benjamin Franklin did not DISCOVER electricity, however, he DID perform many science experiments, and
was able to prove that lightning was in fact, electricity... by flying a kite in a storm with a
lightning rod attached.

He helped write the Constitution of the United States of Ameica in 1787, among many other documents.
He ALSO served as the US Postmaster General, where he literally handed out stamps of approval.

I selected this man for this introduction, because he is the spirit of America.
He is NOT the ONLY founding father of America, but he is a VERY CRITICAL ONE.

No, he didn’t give that speech up above (as far as I know)...
But, it is probably something he would've given a stamp of approval.
Franklin lived to the ripe old age of 84, when he became ill, and passed away from pleurisy.

Make no mistake... at one point in time, this man was considered to be MORE important than the 
President of the United States. The reason for that, is because he left behind a legacy like no other.

While he WAS the 6th President of Pennsylvania...? 
It was essentially the same role as governor, and the colonies were still working things out between 
themselves, on how to work in a similar manner, united as one, rather than divided. 

Although he never became the President of the United States, this dude had a slew of IMPORTANT DUTIES 
and SKILLS, and would occasionally be overwhelmed. He was plenty 1) qualified, 2) important, and 
3) capable of being elected President of the United States... many people actually asked him to run. 

Had this dude ran for President...?
He would’ve set the bar pretty friggen’ high on how to be one of the best presidents that ever lived...
...times 100.

Truth be told, the man never chose to run... because he was actually too busy being awesome.
What could anybody do about it...? You’re talkin’, the dude was too busy being a role model citizen, 
since he was the man everybody went to (including acting presidents), on how to: 
______________________________________________________________
| 1) set examples | 2) set new precedents | 3) raise the bar |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
You can’t just leave an opportunity like that to chance.
Especially, if the acting president has a new pair of shoes to fill. 
America needed the RIGHT GUY for the job...
...and, if I gotta come right out and say it...? That guy, was Benjamin Franklin.

Much how each book has a binding that keeps all of the pages intact, this man was a critical piece to
how America came into existence. The original 13 colonies were still under British rule, until 1776,
when the story of the Boston Tea Party caused the colonists to officially rebel against the British 
army. The reason for the Boston Tea Party is this simple...

Absolute power corrupts absolutely.
Without working CHECKS AND BALANCES... it always leads to tyranny and oppression.

This was the main motivation for writing the Constitution, although the Articles of Confederation 
would remain in effect until the “complete/current” United States of America Constitution was written
in September 1787.
'@)

$Book.AddSection(0,"Founding Fathers",(Get-FoundingFathers))
$Book.AddSection(0,"History Repeats Itself",@"
Of course, history always has a way of repeating itself, and though this is a history lesson right 
now...? It becomes the perfect metaphor for current events: 
________________________________________________________________________________________________________
| ACTS OF TREASON | NEW WORLD ORDER | NEWS vs PROPAGANDA | USA-PATRIOT Act of 2001 | MASS SURVEILLANCE |
|  SURVEILLANCE CAPITALISM  |  ESPIONAGE |  TECHNOLOGICAL TYRANNY |  HIDDEN GOVERNMENT and CORRUPTION  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Queen Elizabeth, failed to understand what drove the colonists to draft the 
Declaration of Independence… SYSTEMIC INJUSTICE. 

Many things happened resultant of SYSTEMIC INJUSTICE BEFORE and AFTER the Boston Tea Party:
________________________________________________________________________________________
| ARTICLES OF CONFEDERATION | DECLARATION OF INDEPENDENCE | AMERICAN REVOLUTIONARY WAR |
|  THE CONSTITUTION OF THE UNITED STATES OF AMERICA  |  BILL OF RIGHTS  | WAR OF 1812  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
"@)

$Book.AddSection(0,"Colonial America",
@"
Colonial American history is rather extensive, and articulate. I’m shooting for some level of concision
and keeping the story COMPELLING and FOCUSED, but it will eventually be quite thorough.

Colonial America had plenty of missteps, a lot of people died, and they probably wouldn’t have needed
to, if the people in England had a better idea of what they were pushing the colonists to do. 

In a parallel nature, modern society has some serious issues that require some (comparing/contrasting) 
between what motivated John Adams to write the central, most important piece of the puzzle.

This "piece" isn’t really so much as a “piece”, as it is the FOUNDATION upon which EVER American
citizen’s rights, liberties, and freedoms are GRANTED... and continues to be the bedrock upon which
everything else stands on.

This foundation has granted these RIGHTS, since the day they were written...
These RIGHTS have never really taken a BREAK or any days off at all... 
...the document exists until this very day.

That DOCUMENT, would in fact be... 
____________________________________________________
| The Constitution of the United States of America |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
It is THE MOST IMPORTANT DOCUMENT THERE IS, in America, basically.
To oppose it, is considered an ACT OF WAR.

Perhaps there are VARYING DEGREES of what someone may perceive as OPPOSITION to the CONSTITUTION,
to where that OPPOSITION may then and there be CLASSIFIED as an ACT OF WAR...?

However, it is SAFE to SAY that SOME PEOPLE don’t realize, that CERTAIN PEOPLE have INSULTED its 
EXISTENCE, or SPAT in its' FACE. Repeatedly, too. 

While the Constitution established the base from which additional amendments were 
made, most particularly the Bill of Rights, this document is still the most important of them all.
"@)

$Book.AddSection(0,"Transition",@"
I’ll say it right here and now, there’s a lot of fuckin’ swearing and offensive language in this 
document. Oh well. The Constitution allows people to say stuff.

It ALSO allows people to LIE to other people, if they want to.
It ALSO allows people to TAKE ARMS and FORM A MILITIA, if they feel a sense of TYRANNY and OPPRESSION.
It’s not a great idea to DO something like THAT, if you can use WORDS instead...

However, TWO issues exist in this modern age | These will be thoroughly explained 
    (1) PSYCHOLOGICAL MANIPULATION           | ← (PM) for short  
    (2) the concept of CENSORSHIP            | ← (CS) for short

Sometimes people use this LYING technique, FAR too often (part of PM).
Even the POLICE, the POLITICIANS, the MILITARY LEADERS, and even DIRECTORS of GOVERNMENT AGENCIES.

At that point, this activity MAY drive ANOTHER CONSTITUENT, to give that person a swift fuckin’ punch to
the face. The problem is, NOW, it is ILLEGAL to do that.

As such, people will take advantage of that, and lie to people ANYWAY, because they’re not afraid of
getting  assaulted for doing so. | ← PROBLEM

Now, there’s a SERIOUS fuckin’ problem with that, actually.

It’s caused a lot of CORRUPTION. | ← SERIOUS PROBLEM

If I notice people in the government LYING and COMMITING CRIMES, and NOBODY DOES ANYTHING ABOUT IT...?

Then, it stands to reason that it is probably grounds for TAKING UP ARMS...
...and FORMING A MILITIA. | ← RESOLUTION

Guess what...? 
That shit is TOTALLY LEGAL.

The fact of the matter is that people with a LOT OF MONEY tend to lose sight of their MORALITY.
As such, SOME OF THEM WILL LITERALLY ROLL OVER EVERYBODY ELSES RIGHTS, and commit HEINOUS
CAPITAL CRIMES that are NEVER ENFORCED by the LAW ENFORCEMENT SYSTEM.

ALSO, the JUDICIAL SYSTEM which attempts to provide JUSTICE, sorta SUCKS ASS AT THAT SOMETIMES.
Hope I've made myself ABUNDANTLY FUCKING CLEAR, so far.

I’m gonna say this right here and now, there are a number of problems with society RIGHT NOW, but it has
VERY LITTLE TO DO with GUN CONTROL. It has A LOT MORE to do with SOCIETY and CORRUPTION.

There ARE legitimate concerns by people in the government and in the community, in relation to every 
individuals' mental health and well-being. Nobody is arguing that at all here in this document.

However, there’s a MUCH LARGER <PARENT> PROBLEM, which is INDIRECTLY CAUSING THESE ISSUES.
In SOME cases, the <MUCH LARGER PARENT PROBLEM> is in fact, CAUSING THESE ISSUES DIRECTLY.
That means, people LYING, CORRUPTION, ESPIONAGE, and CENSORSHIP are being used in CONJUNCTION...
...by people in the GOVERNMENT, CORPORATIONS, the LAW ENFORCEMENT SYSTEM, and the JUSTICE SYSTEM.

What this ACCOMPLISHES is that it ALLOWS the UNITED STATES OF AMERICA TO OPERATE EXACTLY LIKE...
1) a COMMUNIST STATE (for instance, RUSSIA or CHINA)
2) a MONARCHY (for instance, GREAT BRITAIN)

That's what's going on around the country, as well as in YOUR NECK OF THE WOODS.
It also has a DIRECT IMPACT on people CONSTITUTIONAL LIBERTIES AND FREEDOMS.

So, if all these things happen in CONJUNCTION...? 
It's time to FORM A MILITIA, and then... START ARRESTING PEOPLE.
Because... the CONSTITUTION ALLOWS ALL CITIZENS TO DO THIS LEGALLY.

Yeah that means a PRESIDENT can in fact be ARRESTED by CITIZENS in a CONSTITUTIONAL MILITIA.
And, everyone BELOW the president too.

But- pretty sure that a PRESIDENT won't go to such a moronic extreme to be subjected to this.
Unless you're GEORGE W. BUSH. 
I'll get to the Bushmeister in [Chapter 7 - USA-PATRIOT Act of 2001 and Surveillance Capitalism].

As it stands, the politicians aren’t being PROACTIVE enough about preventing MASSACRES such as:
__________________________________________________________________________
|  Uvalde, TX | Buffalo, NY | Dayton, OH | Reno, NV | Dallas/El Paso, TX |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
In ALL of these scenarios, they have EACH occurred, because the POLITICIANS are FUCKING LAZY.
I will repeat that... It is because the POLITICIANS, are FUCKING... LAZY.

They're NOT lazy at all when it comes to making sure that they get paid a lot of money.
THAT PART...? They are incredibly on top of.

The part where INNOCENT PEOPLE keep being SHOT TO DEATH in a rather VIOLENT WAY...?
Ohhhhhhhh.
That's the part that they're FUCKING LAZY about.
There's no excuse for this shit to be happening, EXCEPT FOR...?

The politicians are fucking lazy, and they don't have their priorities in order.
That's why this shit keeps happening.

I will talk about AN INCREDIBLY INTELLIGENT SUGGESTION that the POLITICIANS should ALREADY BE DOING.
It's called SURVEYS. Not unlike the CENSUS.
Here's the problem, SURVEYS are supposed to be INCREDIBLY EASY TO MANAGE, especially in an economy
where SURVEILLANCE is CONSTANTLY OCCURRING.
__________________________
| SURVEYS | SURVEILLANCE | notice how the (2) words are pretty fucking similar...?
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Well, the reason for that is because, they're actually the same concept.
Go figure.
Billionaires get to watch everything people are doing, but nobody's asking people questions
about their MENTAL STATE, or EXPEDITING THE PROCESS for MENTAL HEALTH SERVICES for SUSPICIOUS
INDIVIDUALS. It has to be done PROACTIVELY, not REACTIVELY, otherwise 19 kids and 2 teachers
will just get mowed down by somebody else that nobody was keeping an eye on, too.

So, in reality, I'm 100%, indisputably correct here, the POLITICIANS are FUCKING LAZY.
EVERYBODY IS BEING WATCHED ALL THE TIME, that's what SURVEILLANCE CAPITALISM IS.

As for the politicians being lazy, well...
They're not ALL lazy...?

But a lot of them DEFINITELY are. For instance, TED CRUZ, and that's because of (Exxon Mobil/Big Oil).
And, Fox News.

Anyway, you'd need 2 billion guys like TUCKER CARLSON to be able to make these things called
CORRELATIONS. That's mainly because TUCKER CARLSON isn't a smart dude, and neither is SEAN HANNITY.

These incidents are OUT OF CONTROL, and they appear to be happening primarily, in AMERICA.
There’s a GOOD reason for it. CORRUPTION, BRIBERY, INJUSTICE, LAZINESS, EGREGIOUSNESS, GREED, SLOTH, etc.

Brick by brick, layer by layer, wall by wall, corner to corner... 
If every brick making up a building has a DEFECT, then that building won’t be very strong at all, will it?

Apply the same exact concept to every individual having no principles, and lying to whoever, whenever, and 
not caring. Ah. That’s just it man. That is a serious fuckin’ problem.

In reference to (POLICE/LAW ENFORCEMENT)... 
SOMETIMES, they really aren’t very bright.
Especially when it comes to PROVIDING THEM WITH EVIDENCE.

That's when they're typically fuckin’ overpaid morons, actually. 
Though, I am in fact, generalizing that to a large degree.
Many of them are not morons at all...?
However, I really hope that the ones who AREN'T morons, understand that I'm gonna lose my fuckin cool
in this god damn book, and just start calling a LOT OF THEIR COWORKERS and BUDDIES... morons.

There’s a lot of components to that, however.
Are they ALL morons? 
No, they’re not.

However, MANY of them they will PISS ALL OVER YOUR RIGHTS, and treat you like you aren’t fuckin’ worthy
of the law. Because, if a CRIME is committed by someone in the GOVERNMENT...? Nobody does anything.

I mean just look at how HILLARY CLINTON got away with being INVESTIGATED by the FBI, and JAMES COMEY
literally allowed this woman to escape being PROSECUTED WHATSOEVER. But- mysteriously, the shoe being
on the OTHER foot...? JULIEN ASSANGE FROM FUCKING WIKILEAKS IS BEING EXTRADICTED TO THE UNITED STATES,
HE IS NOT EVEN AN AMERICAN CITIZEN, AND HE'S BEING CHARGED WITH COMMITTING ESPIONAGE, just like EDWARD
SNOWDEN. The ESPIONAGE ACT of 1917. In JULIEN ASSANGES CASE...? 
_________________________________________________________________________________________
| What INJUSTICE looks like... (these two are "guilty" of doing the same fucking thing) |
|---------------------------------------------------------------------------------------|
| ASSANGE gets (175) years for NOT committing a crime (wasn't against the law)          |
| CLINTON gets   (0) years for     committing a crime (was definitely against the law)  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
And, you know what...? This is why I have to call people MORONS.
Because... people should really be concerned why ANDREW CUOMO and HILLARY CLINTON aren't charged
with ANY CRIMES for their CRIMINAL BEHAVIORS.

Meanwhile, INNOCENT PEOPLE can get CHARGED FOR WHATEVER FUCKING REASON the government feels like.
What I'm STATING is that they can FABRICATE A REASON OUT OF THIN AIR, and GIVE THEMSELVES 
PERMISSION TO DO WHATEVER THEY FUCKING WANT TO DO. (← Why the CONSTITUTION was WRITTEN)

That's TYRANNY, plain and fuckin' simple.

The police, in many cases, don’t bother to INVESTIGATE nor ARREST (that person/those people).
If they DO, they just PRETEND like they give a shit.
As long as they do an awesome job of PRETENDING...?
That's all that matters to them.
They did an AMAZING job, of PRETENDING to give a shit.
Not ACTUALLY giving a shit.

Who's gonna stop em from doin' that...?
Are you...?
Hm...?

Nah.
Nobody's gonna stop em, nobody can.

So what happens, is that guys like ANDREW CUOMO can KEEP BREAKING THE LAW, and...
...NEVER FACE THE MUSIC for it. And somehow nobody sees GEORGE ORWELL'S 1984 being a
real thing. Hm.

Let me crunch it ALL down to be SO SIMPLE...?
Even a toddler might be able to understand what I'm saying.

If THEY wanna have somebody KILLED...
...or BLACKLISTED...
...or EXTRADICTED...
...or SMEARED...
...or GUTTED LIKE A FISH...
...or THROWN IN PRISON...?

Then that's what they'll do, without PUBLICLY SAYING A FUCKING WORD.

So, it'll never make it to CRAIG APPLE's desk.
Nor MICHAEL ZURLO's desk, either.

Nah, cause they PRETENDED like they didn't see the fuckin' problem...
...in a SOCIETY called SURVEILLANCE CAPITALISM.

That means that they fuckin' saw it...?
And they just looked the other way.
That's not ALL THAT DIFFERENT, from some dude being found with a dick in his mouth,
and trying to tell ANYBODY that caught him with that dick in his mouth...
"Look dude, it's just your opinion that this looks gay."
Nah buddy, sometimes when you have a dick in your mouth, opinions aren't involved.
Just FACTS.

A man being found with a dick in his mouth, means that it's FACT that they are GAY.
That's not an OPINION.
That's a FACT.

So whether it's some dude being found with a dick in his mouth, or innocent people being killed...?

Those people will just be killed in a violent and silent way, by serial killers that they hire.
Typically, these SERIAL KILLERS are in fact, PRIVATE MILITARY CONTRACTORS that are PAID to EXECUTE a
SPECIIC TARGET.

Just so we're clear here...?
That is ACTUALLY HAPPENING.

Resultant...?
Well, many laws need to be put under "AIR QUOTES".
Effectively just like ROYALTY.
So, a member of LAW ENFORCEMENT can PRETEND like they didn’t see a “law being broken”...
...then “EVERYONE ELSE” should be able to do that “too”. 

They just chose to ignore it. | ← that is effectively TYRANNY and CORRUPTION 

So, if you see someone “important” that happens to be committing a “crime” ...? 
Well, ask that officer of the law to “do their job”.

They get paid to “do their job”, so if they’re NOT “doing their job”, I will teach you how to get 
creative about it. To basically light a fire under their ass (← metaphor)

Sometimes, you can see this process unfold where they won’t fuckin’ see the problem at all...~!
That’s because, sometimes they can’t help that they’re fuckin’ morons.
Sometimes they CAN...! But- they just choose NOT to. Unfortunately...? That’s too fuckin’ bad.

If they prefer NOT to do their job, then they are right then and there choosing to NOT be paid. 
If they tell ya NAH BRO, then you find a way to tell them JOB NOT DONE BRO.
If they tell ya IM TOO BUSY, then tell em … | ← it is really pointless to keep going with the argument. 
It really is.

I’ll discuss this repeatedly throughout the entire document. 
I don’t hate cops, at all.

However, I notice how much RESISTANCE many of them put up, because they are TAUGHT so many (PM)
techniques that allow them to be incredibly (LAZY/INCOMPETENT), in many cases. | ← TYRANNY & CORRUPTION

So, again... THEY get PAID to DO THEIR JOB. 
They DON'T get PAID to NOT DO THEIR JOB.
But- SOME of them will tell ya to FUCK OFF if you try wavin’ your finger in their face.
I’m not exaggerating.

(Some of them will literally kill you themselves, and TRIED to do this to me on MAY 26th, 2020.)

If they’re NOT DOING THEIR JOB, then you have a RIGHT, to manipulate them.
...to do that job.

If it’s not getting done...?
Why the fuck are they getting paid...? 
OH. 
That’s a SERIOUS PROBLEM.
"@)

$Book.AddSection(0,"Integrity",@"
Law enforcement is supposed to be the END ALL, BE ALL, LINE OF DEFENSE and INTEGRITY
So, if you see police officers sucking Prince/Andrew/Cuomo’s dick for a promotion...?
...that’s neither one of those fuckin’ things.

It winds up causing problems in society to occur ELSEWHERE...
...and INNOCENT PEOPLE DIE BECAUSE OF IT. | ← PROBLEM

If two dudes wanna blow each other...? That’s ok. | ← NOT THE PROBLEM 
It’s totally legal if two dudes wanna do that.

HOWEVER... If neither 1) Prince/Andrew/Cuomo nor 2) the guy who wants an easy promotion understand HOW
they’re CHEATING other people that work a lot fuckin’ harder to get ahead...? | ← PROBLEM
That’s a fuckin’ serious problem, and it won’t stop with (1) blowjob either.

Now, sometimes a police officer STILL won’t care... 
...even if you whip out the laws, and statutes. | ← PROBLEM

If you want to see this with your very own eyes...? 

Whip out your smartphone and record a video... | ← (keep to yourself/hidden, if possible)
...of YOU, asking THEM, to ARREST a particular individual BREAKING THE LAW... 
...and perhaps you’ll create a brand new entry that they can discuss on “Audit the Audit”.

Especially if it’s RECORDED ON AUDIO OR VIDEO.

The problem is, sometimes the police don’t actually care about whether they have a job to do or not.
Oh they will break it all down to “interpretation” of the law, which, nah fuckin’... 
...if they start sayin’ shit like: 
________________________________________________
| That’s just YOUR interpretation, dude.       |
| OoooOooOOhhhHHhh that’s just your OPINION... | ← These are both a DEAD GIVEAWAY
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
They are used to SHIELD the LAYERS of CORRUPTION within our current government.
                 -------------------------------------------------------------
Not even remotely fuckin’ kiddin’.
SO MANY PEOPLE ARE INDIFFERENT, AND THEY’RE LIARS~! | ← PROBLEM
"@)

$Book.AddSection(0,"Focus",@"
I will UNPACK/EXAMINE ways of dealing with BOTH of these issues, as well as what's causing ALL of them.
Because the problem is INCREDIBLY COMPLEX, however...? 

There are a lot of things to explain.

I am going to DISASSEMBLE many differing aspects of PSYCHOLOGY, and explain those aspects in simple
terms. Though it’ll be FAR from an actual DOCTORATE in PSYCHOLOGY, this document SHOULD effectively 
provide people with a BASELINE EDUCATION, in reference to the MANY various aspects of PSYCHOLOGY. 
(^ RESOLUTION)

Not to mention, might help a lot of dudes get some broads. 
And, there’s plenty of humor in it too.
Broads and humor COMBINED, sometimes.

Yeah, I’m not even gonna wait... the problem is that the BRITISH MONARCHY has CORRUPTED AMERICA, though, 
the problem is definitely far worse than just that. 
The problem is SO BAD, that I needed to write this document that’s about 700+ pages.

The INDIVIDUALS are NOT the only ones to blame. 
This is a SOCIETAL issue and the PROBLEMS are HIDING IN PLAIN SIGHT.
I will make a lot of references to the hit series BREAKING BAD.

I suggest watching that series in entirety, because of how many compelling analogies and metaphors are 
conveyed in it. That show conveys a lot of aspects to psychology as well as morality. 

As far as this material goes...?
_______________________________________________________________________________________
| It is the RESPONSIBILITY of EVERY citizen, to QUESTION AUTHORITY -Benjamin Franklin | 
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
(^ RESOLUTION)

Whether it’s someone with a badge, or a gavel, or whatever really.
Everyone is SUPPOSED to adhere to the Constitution, but- in many cases...? 
...that is not what is being observed.

So...
Someone got fuckin’ HIGHLY IRRITATED with a LARGE NUMBER OF PEOPLE, and decided to write this material.
Here's that person's resume.
"@)

$Book.SetLabel(1,"Resume")
$Book.AddSection(1,"Resume",$Book.Resource("Not%20News%20(005-Resume).txt"))
