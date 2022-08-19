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
        [String[]] ToString()
        {
            Return $This.Line | % Content
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
    }

    [Book]::New($name)
}

$Book = Write-Book "Top Deck Awareness - Not News"

$Book.Chapter[0].SetLabel("Prologue")
$Book.Chapter[0].AddSection("Start",@'
Benjamin Franklin: It is the RESPONSIBILITY of EVERY citizen, to QUESTION AUTHORITY.
Keep this quote in mind, because it is the beginning and the end of this entire document.
'@)

$Book.Chapter[0].AddSection("Introduction (1)",@'
Benjamin Franklin was one of the founding fathers of the United States of America, and a very critical one 
at that. Benjamin Franklin, was a dude that had principles down pat, as he was an avid writer, quite the 
scientist, an inventor (invented bifocals), an able-bodied statesman, top-shelf diplomat, printer, publisher,
political philosopher... he was really a mixed bag when it came stuff that only geniuses could do, back in 
his day. In other words, quite a rare guy.

One of his favorite philosophies was a quote by Voltaire: “Though I may not agree with what you have to say, 
I’ll defend to the death your right to say it.” This philosophy was the inspiration for the first Amendment to 
the Constitution of the United States. This philosophy was one that HE, along with the rest of the founding 
fathers, all stood by, as they spent day after day, writing draft after draft, knowing that they may very well 
be the authors, of the greatest document that has ever been written in history... 
the Constitution of the United States. 

Finally, the day came, they all looked at each other in suspense and asked each other 
“...this is... IT... isn’t it...?” Another said “Yeah man.”

They’d been waiting for this day to come for a very long time... when the moment came, and the very last line 
was written...? That man had to shake his hand because it kept cramping up 
“Damn, my friggen hand... all cramped up.” 
They even said “You did an amazing job, dude.” 

He was right. 
They all signed the document, one that was an ETERNITY in the making... they all knew that this was no joke, 
and that it needed to be ABSOLUTELY PERFECT... but, one man still hadn’t signed it yet... and he gave a speech.
'@)

$Book.Chapter[0].AddSection("Signature Speech",@'
Franklin : Gentlemen, this is MORE than words on a piece of paper that we’re responsible for authoring and signing.
           This will be the greatest document ever written.
           This thing needs to be MORE than just bulletproof.
           The paper may be destroyed...? But, its legacy can never die.
           Its' philosophies may be amended...? But, its' principles will never lie.
           Freedom from oppression and tyranny will remain its' driving force...
           ...and even if one day it fails...? May it provide one last recourse...
           The foundation upon which this nation is built, needs to be INVINCIBLE, in theory...
           Therefore, every natural born citizen from this day forward... shall inherit our labors freely.
           This document, the Constitution of the United States of America, shall be hyperbolic and timeless.
           At last, the time has come... for the very last man to sign this.
           *signs the Constitution of the United States of America*
'@)

$Book.Chapter[0].AddSection("Introduction (2)",@'
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
########################################################################################################

Class FoundingFather
{
    [String] $Name
    [String] $Link
    [String] $Lived
    [String] $Roles
    Hidden [Hashtable] $Hash
    FoundingFather([String]$Name)
    {
        $This.Name = $Name
        $This.Link = "https://en.wikipedia.org/wiki/{0}" -f $Name.Replace(" ","_")
    }
    SetLived([String]$String)
    {
        $This.Lived = $String
    }
}

$Book.Chapter[0].AddSection("Founding Fathers",@'
[All information is from various Wikipedia articles]
________________________________________________________________________________________________________
| Name  : Thomas Jefferson                                                                             |
| Link  : https://en.wikipedia.org/wiki/Thomas_Jefferson                                               |
| Lived : 04/13/1743 - 07/04/1826 (83)                                                                 |
| Roles : Statesman, Diplomat, lawyer, architect, philosopher, 3rd president (1801-1809)               |
|------------------------------------------------------------------------------------------------------|
| Principle author of the Declaration of Independence, served as vice president under Federalist       |
| John Adams. They were both good friends as well as political rivals. During the American Revolution  |
| Jefferson represented Virginia in the Continental Congress which adopted the Declaration of ID4.     |
| He also played a key role in influencing James Madison, Alexander Hamilton, and John Jay in writing  | 
| THE FEDERALIST PAPERS. Proponent of democracy, republicamisn, nd individual rights, motivating the   |
| colonists to break away from Great Britain (cause the TEA TAX SUCKED ASS...)                         |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
________________________________________________________________________________________________________
| Name  : James Madison                                                                                |
| Link  : https://en.wikipedia.org/wiki/James_Madison                                                  |
| Lived : 03/16/1751 - 06/28/1836  (85)                                                                |
| Roles : Statesman, Diplomat, 4th president (1809-1817), general, all-around badass                   |
|------------------------------------------------------------------------------------------------------|
| Born in Virginia, served as member of the Virginia House of Delegates, and the Continental Congress  |
| during the American Revolutionary War. Hailed as the FATHER OF THE CONSTITUTION, and assisted in     |
| writing the 85 essays that became known as THE FEDERALIST PAPERS which served to provide guidelines  |
| for separation of church and state, and to ensure that no one institution could become too powerful  |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
________________________________________________________________________________________________________
| Name  : Alexander Hamilton                                                                           |
| Link  : https://en.wikipedia.org/wiki/Alexander_Hamilton                                             |
| Lived : 01/11/1755 - 07/12/1804 (49)                                                                 |
|------------------------------------------------------------------------------------------------------|
| Roles : Revolutionary, Statesman, influential interpreter, promoter of the Constitution              |
| Founded the Federalist Party, the nation's financial system, the United States Coast Guard, and the  |
| New York Post newspaper.                                                                             |
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|
$Cap = "John Adams",
"Samuel Adams",
"Patrick Henry",
"James Monroe",
"George Washington" | % { [FoundingFather]::New($_) }

$Cap[0].Lived = "10/30/1735 - 07/04/1826"
$Cap[0].Roles = "Statesman, attorney, diplomat, writer, 2nd president (1797-1801)"
$cap[1].Lived = "09/27/1722 - 10/02/1803"                                         
$Cap[1].Roles = "Statesman, political philosopher" 
$cap[2].Lived = "05/29/1736 - 06/06/1799"         
$cap[2].Roles = "Attorney, planter, politician, and orator"
$Cap[3].Lived = "04/28/1758 - 07/04/1831"
$Cap[3].Roles = "Statesman, lawyer, diplomat, 5th president (1817-1825)"
$Cap[4].Lived = "02/22/1732 - 12/14/1799"
$Cap[4].Roles = "Military officer, statesman, 1st president (1789-1797)"
'@)
