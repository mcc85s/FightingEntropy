<#  
    ____    ____________________________________________________________________________________________________        
   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    
   \\__//¯¯¯ [FightingEntropy(π)][2023.4.0]: 2023-04-03 18:55:27 [~]                                        ___//¯¯\\   
    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    
#>

Class Guide
{
    [UInt32]  $Index
    [UInt32[]] $Rank
    [String]   $Face
    Guide([UInt32]$Index,[String]$Face)
    {
        $This.Index = $Index
        $This.Rank  = 0..3 | % { ($Index * 4) + $_ }
        $This.Face  = $Face
    }
}

Class Character
{
    [UInt32]   $Index
    [String]    $Char
    [UInt32]    $Fore
    [UInt32]    $Back
    [UInt32] $NotLast
    Character([UInt32]$Index,[String]$Char)
    {
        $This.Index   = $Index
        $This.Char    = $Char
        $This.Fore    = 15
        $This.Back    = 0
        $This.NotLast = 1
    }
    [Hashtable] Splat()
    {
        Return @{ 

            Object          = $This.Char
            ForegroundColor = $This.Fore
            BackgroundColor = $This.Back
            NoNewLine       = $This.NotLast
        }
    }
    [String] ToString()
    {
        Return $This.Char
    }
}

Class Track
{
    [UInt32] $Index
    [Object] $Line
    Track([UInt32]$Index,[String]$Line)
    {
        $This.Index = $Index
        $This.Line  = @( )

        ForEach ($Char in [Char[]]$Line)
        {
            $This.Add($Char)
        }

        $This.Line[-1].NotLast = 0
    }
    SetFore([UInt32[]]$Range,[UInt32]$Color)
    {
        ForEach ($Char in $This.Line[$Range])
        {
            $Char.Fore = $Color
        }
    }
    SetBack([UInt32[]]$Range,[UInt32]$Color)
    {
        ForEach ($Char in $This.Line[$Range])
        {
            $Char.Back = $Color
        }
    }
    [Object] Guide([UInt32]$Index,[String]$Face)
    {
        Return [Guide]::New($Index,$Face)
    }
    [String] Ruler()
    {
        $Out = ForEach ($X in 0..($This.Line.Count-1))
        {
            If ($X % 4 -eq 0)
            {
                "|"
            }

            $This.Line[$X].Char
        }

        Return $Out -join ""
    }
    [Object[]] Draft()
    {
        $xLine = $This.Ruler().TrimStart("|").TrimEnd("|") -Split "\|"
        $Out  = @( )
        ForEach ($X in 0..($xLine.Count-1))
        {
            $Out += $This.Guide($X,$xLine[$X])
        }

        Return $Out
    }
    [Object] Character([UInt32]$Index,[String]$Char)
    {
        Return [Character]::New($Index,$Char)
    }
    Add([Char]$Char)
    {
        $This.Line += $This.Character($This.Line.Count,$Char)
    }
}

Class Stack
{
    [Object] $Output
    Stack()
    {
        $This.Output = @( )
    }
    [Object] Track([UInt32]$Index,[String]$Line)
    {
        Return [Track]::New($Index,$Line)
    }
    Add([String]$Line)
    {
        $This.Output += $This.Track($This.Output.Count,$Line)
    }
    Write()
    {
        ForEach ($Line in $This.Output)
        {
            ForEach ($Char in $Line.Line)
            {
                $Splat = $Char.Splat()
                Write-Host @Splat
            }
        }
    }
}

$Stack = [Stack]::New()

"    ____    ____________________________________________________________________________________________________        ",
"   //¯¯\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\___    ",
"   \\__//¯¯¯ [FightingEntropy(π)][2023.4.0]: 2023-04-03 18:55:27                                            ___//¯¯\\   ",
"    ¯¯¯\\__________________________________________________________________________________________________//¯¯\\__//   ",
"        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯    " | % { $Stack.Add($_) }

$Stack.Write()

$Line = $Stack.Output[0]
$Line.SetFore(@(0..119),10)
$Stack.Write()

$Line = $Stack.Output[1]
$Line.SetFore(@(0..3),10)
$Stack.Write()

$Line.SetFore(@(4..7),12)
$Stack.Write()

$Line.SetFore(@(8..11),10)
$Stack.Write()

$Line.SetFore(@(12..111),12)
$Stack.Write()

$Line.SetFore(@(112..119),10)
$Stack.Write()

$Line = $Stack.Output[2]
$Line.SetFore(@(0..3),10)
$Stack.Write()

$Line.SetFore(@(4..11),12)
$Stack.Write()

$Line.SetFore(@(12,13),9)
$Stack.Write()

$Line.SetFore(@(14..28),7)
$Stack.Write()

$Line.SetFore(29,15)
$Stack.Write()

$Line.SetFore(30,7)
$Stack.Write()

$Line.SetFore(31,15)
$Stack.Write()

$Line.SetFore(@(32,33),9)
$Stack.Write()

$Line.SetFore(29,15)
$Stack.Write()

$Line.SetFore(@(34..41),14)
$Stack.Write()

$Line.SetFore(42,9)
$Stack.Write()

$Line.SetFore(@(108..115),12)
$Stack.Write()

$Line.SetFore(@(116..119),10)
$Stack.Write()

$Line = $Stack.Output[3]
$Line.SetFore(@(0..7),10)
$Stack.Write()

$Line.SetFore(@(8..107),12)
$Stack.Write()

$Line.SetFore(@(108..111),10)
$Stack.Write()

$Line.SetFore(@(112..115),12)
$Stack.Write()

$Line.SetFore(@(116..119),10)
$Stack.Write()

$Line = $Stack.Output[4]
$Line.SetFore(@(0..119),10)
$Stack.Write()
