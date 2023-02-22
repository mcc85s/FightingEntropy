Function Write-Random
{
    [CmdLetBinding()]
    Param(
    [Parameter(Mandatory)][UInt32]$Length,
    [Parameter(Mandatory)][UInt32]$Height)

    Class CharItem
    {
        [UInt32]  $Index
        [UInt32]   $Rank
        [String] $String
        CharItem([UInt32]$Index,[Uint32]$Rank)
        {
            $This.Index  = $Index
            $This.Rank   = $Rank
            $This.String = [Char]$Rank
        }
        [String] ToString()
        {
            Return $This.String
        }
    }

    Class CharList
    {
        [Object] $Output
        CharList([UInt32[]]$Range)
        {
            $this.Output = @( )
            For ($C = 0; $C -lt $Range.Count; $C++)
            {
                $This.Output += $This.CharItem($C,$Range[$C])
            }
        }
        [Object] CharItem([Uint32]$Index,[Uint32]$Rank)
        {
            Return [CharItem]::New($Index,$Rank)
        }
    }

    Class Generate
    {
        Hidden [UInt32] $Length
        Hidden [UInt32] $Height
        Hidden [Object]  $Chars
        [Object] $Output
        Generate([UInt32]$Length,[UInt32]$Height)
        {
            # // ==========================================
            # // | Test input parameters (length + width) |
            # // ==========================================

            If ($Length -le 1)
            {
                $This.Error(0)
            }

            ElseIf ($Height -le 1)
            {
                $This.Error(1)
            }

            # // ==================
            # // | Set properties |
            # // ==================

            $This.Length = $Length
            $This.Height = $Height
            $This.Chars  = $This.CharList()
            $This.Output = @( )

            # // ================
            # // | Build output |
            # // ================

            ForEach ($X in 0..($This.Height-1))
            {
                $Line         = ($This.IntArray() | % { $This.Chars[$_] }) -join ""
                $This.Output += [String]($Line)
            }
        }
        [UInt32[]] Range()
        {
            Return @(43;47..57+65..90+97..122)
        }
        [Object] CharList()
        {
            Return [CharList]::New($This.Range()).Output
        }
        Error([UInt32]$Type)
        {
            Throw "Must use a {0} greater than 1" -f @("Length","Height")[$Type]
        }
        [UInt32[]] IntArray()
        {
            Return @( 0..($This.Length-1) | % { $This.Random() } )
        }
        [UInt32] Random()
        {
            Return Get-Random -Min 0 -Max 63
        }
    }

    [Generate]::New($Length,$Height).Output
}
