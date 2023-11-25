<# 11/25/2023 [US National Debt]

https://www.msn.com/en-us/money/markets/
america-s-national-debt-is-well-over-33-trillion-but-here-s-why-the-country-won-t-pay-it-down/ar-AA1kvPaL

Another highly disturbing trend... [American national debt].

"At (33T) and counting — actually, it's presently above (33.75T)...
 [America’s national debt is astonishingly high].

 [But government deficits don’t exactly work like household debt***[1]],
 as [New York Times] columnist and Nobel Prize-winning economist [Paul Krugman] contends in his May 13 offering.
 [The big, bad number isn’t as scary as it seems***[2]]."

[1]: That's because the [government] can continue telling people to [fuck off] and [not pay its' bills],
     wherby placing the [burden on the taxpayers INDEFINITELY], otherwise [it IS IDENTICAL to household debt].

[2]: [The number IS horrifying], and it IS as scary as it seems, when you lift the veil of denial.

[3]: A lot of [economists] make up [excuses] for the [government], because they get [kickbacks] from [lobbyists]
     and [politicians]. The case isn't consistent, but you have to ask yourself if they may have some [incentive]
     for saying something that [defies all fucking logic whatsoever].

Here's a breakdown of the [US National Debt], below, from (1998) to (2024).

I'm going to use the wonderful [PowerShell] language to create some [class definitions], and then describe the
output of those classes.
#>

    # // =======================================
    # // | Show increases in consumable format |
    # // =======================================

    Class DebtRatioPopulation
    {
        Hidden [UInt64]  $TotalCt
        [String]           $Total
        [String]         $TOffset
        [Float]             $Cost
        [String]         $COffset
        DebtRatioPopulation([UInt64]$Population,[Float]$Debt)
        {
            $This.TotalCt = $Population
            $This.Total   = "{0:n2}M" -f ($This.TotalCt * 0.000001)
            $This.Cost    = ($Debt*1000000000000)/$Population
        }
        [String] ToString()
        {
            Return $This.Total
        }
    }

    # // =====================================================================
    # // | Individual year/debt per person/Debt total/Debt-per-person object |
    # // =====================================================================

    Class DebtRatio
    {
        [UInt32]       $Year
        [Float]        $Debt
        [Object] $Population
        [Object]  $Workforce
        [Float]     $Average
        [Float]   $Inflation
        DebtRatio([UInt32]$Year,[UInt64]$Population,[Float]$Debt,[Float]$Average,[Float]$Inflation)
        {
            $This.Year       = $Year
            $This.Debt       = $Debt
            $This.Population = $This.DebtRatioPopulation($Population,$Debt)
            $This.Workforce  = $This.DebtRatioPopulation([Math]::Round($Population * 0.30),$Debt)
            $This.Average    = $Average
            $This.Inflation  = $Inflation
        }
        SetOffset([Object]$Previous)
        {
            ForEach ($Property in "Population","Workforce")
            {
                $Item = $This.$Property
                $Last = $Previous.$Property

                If ($Item.TotalCt -gt $Last.TotalCt)
                {
                    $Item.TOffset = "+ {0:n2}" -f (($Item.TotalCt - $Last.TotalCt) * 0.000001)
                }
                Else
                {
                    $Item.TOffset = "- {0:n2}" -f (($Last.TotalCt - $Item.TotalCt) * 0.000001)
                }

                $Item.COffset = "+ {0:p}" -f (((($Item.Cost*100)/$Last.Cost)-100)/100)
            }         
        }
        [Object] DebtRatioPopulation([UInt64]$Population,[Float]$Debt)
        {
            Return [DebtRatioPopulation]::New($Population,$Debt)
        }
    }

    # // ===================================================
    # // | Converts each record into a flattened table row |
    # // ===================================================

    Class DebtRatioOutput
    {
        [String] $Year
        [String] $Debt
        [String] $Citizens
        [String] $CGrowth
        [String] $CRatio
        [String] $CDiff
        [String] $Workers
        [String] $WGrowth
        [String] $WRatio
        [String] $WDiff
        [String] $Average
        [String] $Inflation
        [String] $Years
        DebtRatioOutput([Object]$Record)
        {
            $This.Year       = $Record.Year
            $This.Debt       = '${0}T' -f $Record.Debt
            $This.Citizens   = $Record.Population.Total
            $This.CGrowth    = '{0}M' -f $Record.Population.TOffset
            $This.CRatio     = '${0:n2}' -f $Record.Population.Cost
            $This.CDiff      = $Record.Population.COffset
            $This.Workers    = $Record.Workforce.Total
            $This.WGrowth    = '{0}M' -f $Record.Workforce.TOffset
            $This.WRatio     = '${0:n2}' -f $Record.Workforce.Cost
            $This.WDiff      = $Record.Workforce.COffset
            $This.Average    = $Record.Average
            $This.Inflation  = $Record.Inflation
            $This.Years      = "{0:n2}" -f ($Record.Workforce.Cost/$Record.Average)
        }
        [String] ToString()
        {
            Return "({0}), {1}" -f $This.Year, $This.Debt
        }
    }

    # // =========================================================
    # // | List of yearly debt + total + debt-per-person objects |
    # // =========================================================

    Class DebtRatioList
    {
        [String] $Name
        [Object] $Output
        DebtRatioList([String]$Country)
        {
            $This.Name   = $Country
            $This.Output = @( )
        }
        [Object] DebtRatio([UInt32]$Year,[UInt64]$Population,[Float]$Debt,[Float]$Average,[Float]$Inflation)
        {
            Return [DebtRatio]::New($Year,$Population,$Debt,$Average,$Inflation)
        }
        [Object] DebtRatioOutput([Object]$Record)
        {
            Return [DebtRatioOutput]::New($Record)
        }
        Add([UInt32]$Year,[UInt64]$Population,[Float]$Debt,[Float]$Average,[Float]$Inflation)
        {
            $This.Output += $This.DebtRatio($Year,$Population,$Debt,$Average,$Inflation)
        }
        Clear()
        {
            $This.Output = @( )
        }
        Calculate()
        {
            ForEach ($Property in "Population","Workforce")
            {
                $Item = $This.Output[0].$Property

                $Item.TOffset = "+ {0:n2}" -f 0
                $Item.COffset = "+ {0:p}" -f 0
            }

            ForEach ($X in 1..($This.Output.Count-1))
            {
                $This.Output[$X].SetOffset($This.Output[$X-1])
            }
        }
        [Object] Export()
        {
            $Out = @{ }

            ForEach ($Item in $This.Output)
            {
                $Out.Add($Out.Count,$This.DebtRatioOutput($Item))
            }

            Return $Out[0..($Out.Count-1)]
        }
    }

    # // ============================================================================
    # // | Now, let's instantiate the list object, and the populate it with records |
    # // ============================================================================

    # [Parameter is the name of the country]
    $Country = "United States"
    $US      = [DebtRatioList]::New($Country)

    # [Parameters are the [year], [population/year], [debt in T], [avg income], [avg * (inflation 2023)]]
    $US.Add(1998,275835018,5.526,22126.00,40352.65)
    $US.Add(1999,279181581,5.656,24000.00,43095.70)
    $US.Add(2000,282398554,5.674,25000.00,43925.00)
    $US.Add(2001,285470493,5.807,25610.00,43511.88)
    $US.Add(2002,288350252,6.228,26400.00,43648.10)
    $US.Add(2003,291109820,6.783,27000.00,43928.51)
    $US.Add(2004,293947885,7.379,28000.00,44522.38)
    $US.Add(2005,296842670,7.933,28300.00,43855.77)
    $US.Add(2006,299753098,8.507,30000.00,44961.63)
    $US.Add(2007,302743399,9.008,30005.00,43545.72)
    $US.Add(2008,305694910,10.025,31200.00,44073.99)
    $US.Add(2009,308512035,11.910,31100.00,42293.45)
    $US.Add(2010,311182845,13.562,30324.00,41397.99)
    $US.Add(2011,313876608,14.790,31024.00,41645.00)
    $US.Add(2012,316651321,16.066,32000.00,41661.98)
    $US.Add(2013,319375166,16.738,32202.00,41076.29)
    $US.Add(2014,322033964,17.824,34000.00,42712.67)
    $US.Add(2015,324607776,18.151,35000.00,43292.48)
    $US.Add(2016,327210198,19.573,36000.00,44466.16)
    $US.Add(2017,329791231,20.245,38000.00,46335.60)
    $US.Add(2018,332140037,21.516,39632.00,47281.09)
    $US.Add(2019,334319671,22.719,40105.00,46717.95)
    $US.Add(2020,335942003,27.748,43894.00,50283.39)
    $US.Add(2021,336997624,29.617,44225.00,50040.94)
    $US.Add(2022,338289857,30.824,46001.00,49706.61)
    $US.Add(2023,333287557,31.410,50000.00,50000.00)
    $US.Add(2024,335772686,34.125,55000.00,55000.00)

    # Compiles the differences between all objects
    $US.Calculate()

    # [Exports objects to variable $List]
    $List = $US.Export()

    # // =================================================
    # // | Now, lets get a 'visual' the numbers provided |
    # // =================================================

    <# Population -> Infants/children   [0..12]    | 0%
                     Adolescents        [13..18]   | 15%
                     Young adults       [19..25]   | 85%
                     Adults             [25..50]   | 90%
                     Senior adults      [50..65]   | 65%
                     senior citizens    [65+]      | 20%
    #>

    $List | Format-Table -Property *
    
<#
    Year Debt     Citizens CGrowth CRatio      CDiff    Workers WGrowth WRatio      WDiff    Average Inflation Years
    ---- ----     -------- ------- ------      -----    ------- ------- ------      -----    ------- --------- -----
    1998 $5.526T  275.84M  + 0.00M $20,033.71  + 0.00%  82.75M  + 0.00M $66,779.05  + 0.00%  22126   40352.65  3.02
    1999 $5.656T  279.18M  + 3.35M $20,259.22  + 1.13%  83.75M  + 1.00M $67,530.72  + 1.13%  24000   43095.7   2.81
    2000 $5.674T  282.40M  + 3.22M $20,092.17  + -0.82% 84.72M  + 0.97M $66,973.90  + -0.82% 25000   43925     2.68
    2001 $5.807T  285.47M  + 3.07M $20,341.86  + 1.24%  85.64M  + 0.92M $67,806.20  + 1.24%  25610   43511.88  2.65
    2002 $6.228T  288.35M  + 2.88M $21,598.73  + 6.18%  86.51M  + 0.86M $71,995.77  + 6.18%  26400   43648.1   2.73 
    2003 $6.783T  291.11M  + 2.76M $23,300.48  + 7.88%  87.33M  + 0.83M $77,668.28  + 7.88%  27000   43928.51  2.88
    2004 $7.379T  293.95M  + 2.84M $25,103.09  + 7.74%  88.18M  + 0.85M $83,676.97  + 7.74%  28000   44522.38  2.99
    2005 $7.933T  296.84M  + 2.89M $26,724.60  + 6.46%  89.05M  + 0.87M $89,081.98  + 6.46%  28300   43855.77  3.15
    2006 $8.507T  299.75M  + 2.91M $28,380.02  + 6.19%  89.93M  + 0.87M $94,600.08  + 6.19%  30000   44961.63  3.15
    2007 $9.008T  302.74M  + 2.99M $29,754.57  + 4.84%  90.82M  + 0.90M $99,181.91  + 4.84%  30005   43545.72  3.31 
    2008 $10.025T 305.69M  + 2.95M $32,794.13  + 10.22% 91.71M  + 0.89M $109,313.80 + 10.22% 31200   44073.99  3.50
    2009 $11.91T  308.51M  + 2.82M $38,604.65  + 17.72% 92.55M  + 0.85M $128,682.20 + 17.72% 31100   42293.45  4.14
    2010 $13.562T 311.18M  + 2.67M $43,582.09  + 12.89% 93.35M  + 0.80M $145,273.70 + 12.89% 30324   41397.99  4.79
    2011 $14.79T  313.88M  + 2.69M $47,120.43  + 8.12%  94.16M  + 0.81M $157,068.10 + 8.12%  31024   41645     5.06
    2012 $16.066T 316.65M  + 2.77M $50,737.20  + 7.68%  95.00M  + 0.83M $169,124.00 + 7.68%  32000   41661.98  5.29
    2013 $16.738T 319.38M  + 2.72M $52,408.59  + 3.29%  95.81M  + 0.82M $174,695.30 + 3.29%  32202   41076.29  5.42
    2014 $17.824T 322.03M  + 2.66M $55,348.20  + 5.61%  96.61M  + 0.80M $184,494.00 + 5.61%  34000   42712.67  5.43
    2015 $18.151T 324.61M  + 2.57M $55,916.71  + 1.03%  97.38M  + 0.77M $186,389.00 + 1.03%  35000   43292.48  5.33
    2016 $19.573T 327.21M  + 2.60M $59,817.82  + 6.98%  98.16M  + 0.78M $199,392.70 + 6.98%  36000   44466.16  5.54
    2017 $20.245T 329.79M  + 2.58M $61,387.32  + 2.62%  98.94M  + 0.77M $204,624.40 + 2.62%  38000   46335.6   5.38
    2018 $21.516T 332.14M  + 2.35M $64,779.91  + 5.53%  99.64M  + 0.70M $215,933.00 + 5.53%  39632   47281.09  5.45
    2019 $22.719T 334.32M  + 2.18M $67,955.91  + 4.90%  100.30M + 0.65M $226,519.70 + 4.90%  40105   46717.95  5.65
    2020 $27.748T 335.94M  + 1.62M $82,597.59  + 21.55% 100.78M + 0.49M $275,325.30 + 21.55% 43894   50283.39  6.27
    2021 $29.617T 337.00M  + 1.06M $87,884.89  + 6.40%  101.10M + 0.32M $292,949.70 + 6.40%  44225   50040.94  6.62
    2022 $30.824T 338.29M  + 1.29M $91,117.13  + 3.68%  101.49M + 0.39M $303,723.80 + 3.68%  46001   49706.61  6.60
    2023 $31.41T  333.29M  - 5.00M $94,242.95  + 3.43%  99.99M  - 1.50M $314,143.10 + 3.43%  50000   50000     6.28
    2024 $34.125T 335.77M  + 2.49M $101,631.30 + 7.84%  100.73M + 0.75M $338,770.80 + 7.84%  55000   55000     6.16

    US National Debt in a spreadsheet format.
    Year, obvious.
    Debt, in trillions
    Citizens, total population in millions.
    CGrowth, total population (increase/decrease)
    CRatio, amount of money each citizen is "expected" to pay
    CDiff, percentage difference from last tracked year (so 1998 is 0)
    Workers, estimated population that CAN work in millions
    WGrowth, total workers (increase/decrease)
    WRatio, amount of money each worker will be "expected" to pay
    Average, median household income
    Inflation, average adjusted for inflation to 2023
    Years, total number of years where ALL income would go to the national debt per person, could pay off the debt.

    Looks more and more strange the longer you look at it, doesn't it...?

    Looks like [forced sodomy] with [no lube].
    The government's like "Hey, if you like being sodomized...? Great! If not... well, tough luck chum. Get used to it."
#>
