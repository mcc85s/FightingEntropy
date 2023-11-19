
<# 
    Simply meant to catogorize and define the (7) deadly sins, and (7) heavenly virtues

    Some of these items people exhibit on a daily basis, without being aware of it.

    Many, if not ALL of these things are part of the human condition, and simply stating that one SHOULD
    or SHOULD NOT do these things, is meant to teach people to:
    
    [+] [resist their natural impulses to commit sins]
    [+] [adopt "heavenly" virtues]...
    
    ...both of which require [conditioning] of the [mind] and [spirit].
#>

Class Sin
{
    [UInt32] $Index
    [String] $Name
    [String] $Description
    Sin([UInt32]$Index,[String]$Name,[String]$Description)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.Description = $Description
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class Virtue
{
    [UInt32] $Index
    [String] $Name
    [String] $Description
    Virtue([UInt32]$Index,[String]$Name,[String]$Description)
    {
        $This.Index       = $Index
        $This.Name        = $Name
        $This.Description = $Description
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

Class Theology
{
    [Object] $Sin
    [Object] $Virtue
    Theology()
    {
        $This.Sin    = @( )
        $This.Virtue = @( )
    }
    [Object] NewVirtue([UInt32]$Index,[String]$Name,[String]$Description)
    {
        Return [Virtue]::New($Index,$Name,$Description)
    }
    [Object] NewSin([UInt32]$Index,[String]$Name,[String]$Description)
    {
        Return [Sin]::New($Index,$Name,$Description)
    }
    AddSin([String]$Name,[String]$Description)
    {
        $This.Sin += $This.NewSin($This.Sin.Count,$Name,$Description)

        [Console]::WriteLine("Sin [+] $Name")
    }
    AddVirtue([String]$Name,[String]$Description)
    {
        $This.Virtue += $This.NewVirtue($This.Virtue.Count,$Name,$Description)

        [Console]::WriteLine("Virtue [+] $Name")
    }
}

$Ctrl = [Theology]::New()


# [Sins]
$Ctrl.AddSin("pride",
"a personality quality of (extreme/excessive) pride or dangerous overconfidence, often (in combination/synonymous) with arrogance")

$Ctrl.AddSin("greed",
"insatiable desire for material gain (food/money/land/possessions) or (social value/status/power)")

$Ctrl.AddSin("wrath",
"intense emotional state involving a strong (uncomfortable/non-cooperative) response to a perceived (provocation/hurt/threat)")

$Ctrl.AddSin("envy",
"when a person lacks another's (quality/skill/achievement/possession) and wishes that the other lacked it")

$Ctrl.AddSin("lust",
"psychological force producing intense desire for something, or circumstance while already having a significant amount of the desired object")

$Ctrl.AddSin("gluttony",
"over-indulgence or over-consumption of (food/drink)")

$Ctrl.AddSin("sloth",
"habitual disinclination to exertion, or laziness")

# [Virtues]

$Ctrl.AddVirtue("prudence",
"the ability to govern and discipline oneself by the use of reason")

$Ctrl.AddVirtue("justice",
"(moderation/mean) between (selfishness/selflessness), between having (more/less) than one's fair share")

$Ctrl.AddVirtue("temperance",
"moderation or voluntary self-restraint")

$Ctrl.AddVirtue("fortitude",
"the (choice/willingness) to confront (agony/pain/danger/uncertainty/intimidation)")

$Ctrl.AddVirtue("faith",
"(confidence/trust) in a (person/thing/concept)")

$Ctrl.AddVirtue("hope",
"a combination of the desire for something, and expectation of receiving it")

$Ctrl.AddVirtue("charity",
"(kindness/tolerance) in judging others, or providing for those in need, in some cases, philanthropy")
