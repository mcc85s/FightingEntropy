Class Content
{
    [UInt32] $Index
    [String] $Content
    Content([UInt32]$Index,[String]$Content)
    {
        $This.Index   = $Index
        $This.Content = $Content
    }
}

Class ContentMatch
{
    [UInt32] $Index
    [UInt32] $Match
    [String] $A
    [String] $B
    ContentMatch([UInt32]$Index,[Object]$A,[Object]$B)
    {
        $This.Index = $Index
        $This.A     = $A.Content
        $This.B     = $B.Content
        $This.Match = $This.A -eq $This.B
    }
}

Class Arrange
{
    [Object] $A
    [Object] $B
    [Object] $Output
    Arrange([Object]$A,[Object]$B)
    {
        $Hash        = @{ }
        $A           | % { $Hash.Add($Hash.Count,[Content]::New($Hash.Count,$_)) }
        $This.A      = $Hash[0..($Hash.Count-1)]
                     
        $Hash        = @{ }
        $B           | % { $Hash.Add($Hash.Count,[Content]::New($Hash.Count,$_)) }
        $This.B      = $Hash[0..($Hash.Count-1)]

        If ($This.A.Count -gt $This.B.Count)
        {
            Do
            {
                $This.B += [Content]::New($This.B.Count,"")
            }
            Until ($this.B.Count -eq $This.A.Count)
        }

        If ($This.B.Count -gt $This.A.Count)
        {
            Do
            {
                $This.A += [Content]::New($This.A.Count,"")
            }
            Until ($This.A.Count -eq $This.B.Count)
        }

        $Hash = @{ }
        ForEach ($X in 0..($This.A.Count-1))
        {
            $Hash.Add($Hash.Count,[ContentMatch]::New($X,$This.A[$X],$This.B[$X]))
        }

        $This.Output = $Hash[0..($Hash.Count-1)]
    }
}

$Compare = [Arrange]::New($Swap1,$Swap2)
