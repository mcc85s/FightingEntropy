
Class DebtRatio
{
    [UInt32]       $Year
    [UInt64] $Population
    [Float]        $Debt
    [String]        $DPP
    DebtRatio([UInt32]$Year,[UInt64]$Population,[Float]$Debt)
    {
        $This.Year       = $Year
        $This.Population = $Population
        $This.Debt       = $Debt
        $This.DPP        = ($This.Debt*1000000000000)/$This.Population
    }
}

Class DebtRatioList
{
    [String] $Name
    [Object] $Output
    DebtRatioList([String]$Country)
    {
        $This.Name = $Country
        $This.Output = @( )
    }
    [Object] DebtRatio([UInt32]$Year,[UInt64]$Population,[Float]$Debt)
    {
        Return [DebtRatio]::New($Year,$Population,$Debt)
    }
    Add([UInt32]$Year,[UInt64]$Population,[Float]$Debt)
    {
        $This.Output += $This.DebtRatio($Year,$Population,$Debt)
    }
    Clear()
    {
        $This.Output = @( )
    }
}

Class DebtRatioExtension
{
    [UInt32]       $Year
    [UInt64] $Population
    [UInt64]  $Workforce
    [Float]        $Debt
    [String]        $DPP
    DebtRatioExtension([Object]$Debt)
    {
        $This.Year       = $Debt.Year
        $This.Population = $Debt.Population
        $This.Workforce  = [Math]::Round($Debt.Population * 0.30)
        $This.Debt       = $Debt.Debt
        $This.DPP        = ($This.Debt*1000000000000)/$This.Workforce
    }
}

$US = [DebtRatioList]::New("United States")
$US.Add(1998,275835018,5.526)
$US.Add(1999,279181581,5.656)
$US.Add(2000,282398554,5.674)
$US.Add(2001,285470493,5.807)
$US.Add(2002,288350252,6.228)
$US.Add(2003,291109820,6.783)
$US.Add(2004,293947885,7.379)
$US.Add(2005,296842670,7.933)
$US.Add(2006,299753098,8.507)
$US.Add(2007,302743399,9.008)
$US.Add(2008,305694910,10.025)
$US.Add(2009,308512035,11.910)
$US.Add(2010,311182845,13.562)
$US.Add(2011,313876608,14.790)
$US.Add(2012,316651321,16.066)
$US.Add(2013,319375166,16.738)
$US.Add(2014,322033964,17.824)
$US.Add(2015,324607776,18.151)
$US.Add(2016,327210198,19.573)
$US.Add(2017,329791231,20.245)
$US.Add(2018,332140037,21.516)
$US.Add(2019,334319671,22.719)
$US.Add(2020,335942003,27.748)
$US.Add(2021,336997624,29.617)
$US.Add(2022,338289857,30.824)
$US.Add(2023,333287557,31.410)
$US.Output

$US.Output | % { [DebtRatioExtension]$_ } | Format-Table
