# ______________________________________________________________________________________ 
# | Organization : CNN                                                                 | 
# | Anchor       : Jim Sciutto                                                         | 
# | Name         : Retired general analyzes Ukraine's counteroffensive against Russia  | 
# | Date         : 09/01/2022                                                          |
# | Url          : https://youtu.be/SWo3YXS4vAE?t=413                                  | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 

Class TranscriptLine
{
    [UInt32]   $Index
    [String] $Content
    TranscriptLine([UInt32]$Index,[String]$Content)
    {
        $This.Index   = $Index
        $This.Content = $Content
    }
    [String] ToString()
    {
        Return $This.Content
    }
}

Class Transcript
{
    [String] $Organization
    [String]       $Anchor
    [String]         $Name
    [String]         $Date
    [String]          $URL
    [Object]        $Notes
    Transcript([String]$Organization,[String]$Anchor,[String]$Name,[String]$Date,[String]$URL)
    {
        $This.Organization = $Organization
        $This.Anchor       = $Anchor
        $This.Name         = $Name
        $This.Date         = $Date
        $This.URL          = $URL
        $This.Notes        = @( )
    }
    Add([String]$Line)
    {
        $Lines = $Line -Split "`n"
        If ($Lines.Count -gt 1)
        {
            ForEach ($X in 0..($Lines.Count-1))
            {
                If ($Lines[$X].Length -le 1)
                {
                    $Lines[$X] = " " * 104 -join ""
                }

                $This.Notes += [TranscriptLine]::New($This.Notes.Count,$Lines[$X])
            }
        }
        If ($Lines.Count -eq 1)
        {
            If ($Lines.Length -le 1)
            {
                $Lines = " " * 104 -join ""
            }

            $This.Notes += [TranscriptLine]::New($This.Notes.Count,$Lines)
        }
    }
    [Object[]] Slot()
    {
        Return @( "Organization Anchor Name Date Url" -Split " " | % { $This.$_ } )
    }
    [String] Pad([UInt32]$Length,[String]$Char,[String]$String)
    {
        $Buffer  = $Length - $String.Length
        $Padding = $Char * ($Buffer-2)
        Return "{0}{1} |" -f $String, $Padding
    }
    [String[]] Output()
    {
        $Obj     = @{0="";1="";2="";3="";4="";5=""}
        $X       = ($This.Slot() | % Length | Sort-Object)[-1] + 20
        $Obj[0]  = @([char]95) * $X -join ''
        $Obj[1]  = $This.Pad($X," ","| Organization : $($This.Organization)")
        $Obj[2]  = $This.Pad($X," ","| Anchor       : $($This.Anchor)")
        $Obj[3]  = $This.Pad($X," ","| Name         : $($This.Name)")
        $Obj[4]  = $This.Pad($X," ","| Date         : $($This.Date)")
        $Obj[5]  = $This.Pad($X," ","| Url          : $($This.Url)")
        $Obj[6]  = @([char]175) * $X -join ''

        $This.Notes | % { $Obj.Add($Obj.Count,$_) }

        Return @($Obj[0..($Obj.Count-1)])
    }
    [String[]] Comment()
    {
        Return @( $This.Output() | % { "# $_ "} )
    }
    [String] ToString()
    {
        Return $This.Name
    }
}

$News = [Transcript]::New("CNN",
                          "Jim Sciutto",
                          "Retired general analyzes Ukraine's counteroffensive against Russia",
                          "09/01/2022",
                          "https://youtu.be/SWo3YXS4vAE?t=413")

$News.Add(@"
This just in to CNN the chairman of Lukoil, that is Russias' SECOND largest oil producer,
has died, after falling out of a sixth floor window at a hospital near Moscow.
*shaking head* That's what Russian state media is reporting this morning in a statement 
Lukoil confirmed, Ravil Maganov's death did NOT mention the CAUSE being that fatal
fall saying instead that the executive died following a severe illness.

In March shortly after Russias invasion of Ukraine, Lukoil called for quote 
'the soonest termination of the war'.

We should know this, CNN has found at least (5) prominent Russian businessmen have died 
REPORTEDLY by SUICIDE, since late January and we also historically have seen cases of 
dissidents, journalists, and others dying, and the cause being cited as falling off 
'balconies', or out of windows.

We'll continue to follow that story.
"@)

# ______________________________________________________________________________________ 
# | Organization : CNN                                                                 | 
# | Anchor       : Jim Sciutto                                                         | 
# | Name         : Retired general analyzes Ukraine's counteroffensive against Russia  | 
# | Date         : 09/01/2022                                                          |
# | Url          : https://youtu.be/SWo3YXS4vAE?t=413                                  | 
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
# This just in to CNN the chairman of Lukoil, that is Russias' SECOND largest oil producer, 
# has died, after falling out of a sixth floor window at a hospital near Moscow. 
# *shaking head* That's what Russian state media is reporting this morning in a statement  
# Lukoil confirmed, Ravil Maganov's death did NOT mention the CAUSE being that fatal 
# fall saying instead that the executive died following a severe illness. 
#                                                                                                          
# In March shortly after Russias invasion of Ukraine, Lukoil called for quote  
# 'the soonest termination of the war'. 
#                                                                                                          
# We should know this, CNN has found at least (5) prominent Russian businessmen have died  
# REPORTEDLY by SUICIDE, since late January and we also historically have seen cases of  
# dissidents, journalists, and others dying, and the cause being cited as falling off  
# 'balconies', or out of windows. 
#                                                                                                          
# We'll continue to follow that story. 
