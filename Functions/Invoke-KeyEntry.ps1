<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
          FileName: Invoke-KeyEntry.ps1
          Solution: FightingEntropy Module
          Purpose: For isolating keys in a virtual machine guest from a Hyper-V host
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.
          
          TODO:
.Example
#>
Function Invoke-KeyEntry
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][Object]$KB,
    [Parameter(Mandatory)][Object]$Object)
    Class KeyEntry
    {
        Static [Char[]] $Capital  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
        Static [Char[]]   $Lower  = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
        Static [Char[]] $Special  = ")!@#$%^&*(:+<_>?~{|}`"".ToCharArray()
        Static [Object]    $Keys  = @{

            " " =  32; [Char]706 =  37; [Char]708 =  38; [char]707 =  39; [Char]709 =  40; 
            "0" =  48; "1" =  49; "2" =  50; "3" =  51; "4" =  52; "5" =  53; "6" =  54; 
            "7" =  55; "8" =  56; "9" =  57; "a" =  65; "b" =  66; "c" =  67; 
            "d" =  68; "e" =  69; "f" =  70; "g" =  71; "h" =  72; "i" =  73; 
            "j" =  74; "k" =  75; "l" =  76; "m" =  77; "n" =  78; "o" =  79; 
            "p" =  80; "q" =  81; "r" =  82; "s" =  83; "t" =  84; "u" =  85; 
            "v" =  86; "w" =  87; "x" =  88; "y" =  89; "z" =  90; ";" = 186; 
            "=" = 187; "," = 188; "-" = 189; "." = 190; "/" = 191; '`' = 192; 
            "[" = 219; "\" = 220; "]" = 221; "'" = 222;
        }
        Static [Object]     $SKey = @{ 

            "A" =  65; "B" =  66; "C" =  67; "D" =  68; "E" =  69; "F" =  70; 
            "G" =  71; "H" =  72; "I" =  73; "J" =  74; "K" =  75; "L" =  76; 
            "M" =  77; "N" =  78; "O" =  79; "P" =  80; "Q" =  81; "R" =  82; 
            "S" =  83; "T" =  84; "U" =  85; "V" =  86; "W" =  87; "X" =  88;
            "Y" =  89; "Z" =  90; ")" =  48; "!" =  49; "@" =  50; "#" =  51; 
            "$" =  52; "%" =  53; "^" =  54; "&" =  55; "*" =  56; "(" =  57; 
            ":" = 186; "+" = 187; "<" = 188; "_" = 189; ">" = 190; "?" = 191; 
            "~" = 192; "{" = 219; "|" = 220; "}" = 221; '"' = 222;
        }
    }
    If ( $Object.Length -gt 1 )
    {
        $Object = $Object.ToCharArray()
    }
    ForEach ( $Key in $Object )
    {
        If ($Key -cin @([KeyEntry]::Special + [KeyEntry]::Capital))
        {
            $KB.PressKey(16) | Out-Null
            $KB.TypeKey([KeyEntry]::SKey["$Key"]) | Out-Null
            $KB.ReleaseKey(16) | Out-Null
        }
        Else
        {
            $KB.TypeKey([KeyEntry]::Keys["$Key"]) | Out-Null
        }

        Start-Sleep -Milliseconds 50
    }
}
