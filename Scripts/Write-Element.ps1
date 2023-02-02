<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2023-02-02 15:27:18                                                                  //
 \\==================================================================================================// 

    FileName   : Write-Element.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : For creating writing components
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s 
    Primary    : @mcc85s 
    Created    : 2022-02-02 
    Modified   : 2022-02-02
    Demo       : N/A 
    Version    : 0.0.0 - () - Finalized functional version 1.
    TODO       : Testing various
.Example
#>

Function Write-Element
{
    [CmdLetBinding(DefaultParameterSetName="Frame")]
    Param(
    [ValidateSet(0,1,2,3,4)]
    [Parameter(Mandatory)]                   [UInt32]        $Mode     ,
    [Parameter(ParameterSetName=0)]          [String]     $Current     ,
    [Parameter(ParameterSetName=0)]          [String]        $Last     ,
    [Parameter(ParameterSetName=0)]          [Switch]       $Final     ,
    [Parameter(ParameterSetName=1,Mandatory)][UInt32]        $Type     ,
    [Parameter(ParameterSetName=2,Mandatory)][String]        $Date     ,
    [Parameter(ParameterSetName=2,Mandatory)][String]        $Name     ,
    [Parameter(ParameterSetName=2,Mandatory)][String]         $Url     ,
    [Parameter(ParameterSetName=3,Mandatory)][Object]     $Comment     ,
    [Parameter(ParameterSetName=3)]          [UInt32]      $Indent = 4 ,
    [Parameter(ParameterSetname=4,Mandatory)][Object] $InputObject )

    # // ====================================================
    # // | Creates stylized framing elements for a document |
    # // ====================================================

    Class Frame
    {
        [Object] $Output
        Frame([String]$Current)
        {
            $This.Clear()
            $This.Output += "\{0}_/" -f "_".Padleft(118,"_")
            $This.Current($Current)
        }
        Frame([String]$Current,[String]$Last)
        {
            $This.Clear()
            $This.Last($Last)
            $This.Current($Current)
        }
        Frame([Switch]$Flags,[String]$Last)
        {
            $This.Clear()
            $This.Last($Last)
        }
        Current([String]$Current)
        {
            $X            = [String][Char]175
            $1            = $Current.Length
            $0            = 116 - $1
    
            $This.Output += "  {0} /{1}\" -f $Current,
                                             $X.PadLeft($0,$X)
    
            $This.Output +=   "/{0} {1} " -f $X.PadLeft(($1+2),$X),
                                             " ".PadLeft($0," ")
        }
        Last([String]$Last)
        {
            $1            = $Last.Length
            $0            = 116 - $1
    
            $This.Output += " {0} _{1}_/" -f " ".PadLeft($0," "),
                                             "_".PadLeft($1,"_")
    
            $This.Output += "\{0}/ {1}  " -f "_".PadLeft($0,"_"),
                                             $Last
        }
        Clear()
        {
            $This.Output = @( )
        }
    }

    # // =================================================
    # // | Creates a special type of line for a document |
    # // =================================================
    
    Class Line
    {
        [String] $Output
        Line([UInt32]$Type)
        {
            $X     = [String]([Char]175 + [Char]175)
            $Line  = @( )
            $Line += "    "
    
            Switch ($Type)
            {
                0 #[Top]
                {
                    $Line += @("{0}{1}" -f "/$X\","__") * 18
                    $Line += "/$X\"
                }
                1 #[Mid]
                {
                    $Line += "|{0}|" -f " ".PadLeft(110," ")
                }
                2 #[Bottom]
                {
                    
                    $Line += @("{0}{1}" -f "\__/",$X) * 18
                    $Line += "\__/"
                }
            }
    
            $This.Output = $Line -join ""
        }
    }

    # // ===========================================
    # // | Creates a table for (date + name + url) |
    # // ===========================================

    Class Box
    {
        [Object] $Output
        Box([String]$Date,[String]$Name,[String]$Url)
        {
            $Out    = @{ 0 = ""; 1 = "| {0} | {1} | {2} |" -f $Date, $Name, $URL; 2 = "" }
            $X      = [String][Char]95
            $Y      = [String][Char]175
            $Z      = $Out[1].Length
    
            $Out[0] = $X.PadLeft($Z,$X)
            $Out[2] = $Y.PadLeft($Z,$Y)
    
            $This.Output = @($Out[0,1,2])
        }
    }
    
    # // =====================================
    # // | Creates output meant for comments |
    # // =====================================

    Class Comment
    {
        [Object] $Output
        Comment([String]$Comment,[UInt32]$Indent)
        {
            $This.Main($Comment,$Indent)
        }
        Comment([String]$Comment)
        {
            $Indent = 4
            $This.Main($Comment,$Indent)
        }
        Add([Hashtable]$Hashtable,[String]$Line)
        {
            $Hashtable.Add($Hashtable.Count,$Line)
        }
        Main([String]$Comment,[UInt32]$Indent)
        {
            $Out     = @{ }
            $Swap    = @{ }
            $Space   = " " * $Indent -join ''
            $X       = [String][Char]61
            $Y       = [String][Char]95
            $Z       = [String][Char]175
            
            ForEach ($Line in $Comment -Split "`n")
            {
                If ($Line.Length -eq 0)
                {
                    $Line = " "
                }
    
                $This.Add($Swap,$Line)
            }
        
            Switch ($Swap.Count)
            {
                {$_ -eq 1}
                {
                    $X.PadLeft(($Swap[0].Length+4),$X) | % { $_, "| $($Swap[0]) |", $_ } | % { $This.Add($Out,$_) }
                }
                {$_ -gt 1}
                {
                    $Max        = $This.GetMax($Swap)
                    $Max.Buffer = $Max.Length + 4
                    
                    $This.Add($Out,$Y.PadLeft($Max.Buffer,$Y))
                    $This.Add($Out,("|{0}|" -f $Z.PadLeft(($Max.Buffer-2),$Z)))
    
                    ForEach ($X in 0..($Swap.Count-1))
                    {
                        $Line = $Swap[$X]
                        If ($Line.Length -lt $Max.Length)
                        {
                            Do
                            {
                                $Line += " "
                            }
                            Until ($Line.Length -eq $Max.Length)
                        }
                        $This.Add($Out,"| $Line |")
                    }
    
                    $This.Add($Out,("|{0}|" -f $Y.PadLeft(($Max.Buffer-2),$Y)))
                    $This.Add($Out,$Z.PadLeft($Out[1].Length,$Z))
                }
            }
        
            $This.Output = @($Out[0..($Out.Count-1)] | % { "$Space# // $_" }; "")
        }
        [Hashtable] GetMax([Hashtable]$Swap)
        {
            $Item        = @{ Length = ($Swap[0..($Swap.Count-1)]  | Sort-Object Length)[-1].Length; Buffer = 0 }
            $Item.Buffer = $Item.Length + 4
            
            Return $Item
        }
    }
    
    # // ===============================================
    # // | Creates output that is wrapped in a border  |
    # // ===============================================

    Class Border
    {
        [Object] $Output
        Border([Object]$InputObject)
        {
            $This.Output = @( )
    
            ForEach ($Line in $InputObject.Split("`n") | % TrimEnd " ")
            {
                $This.Line($Line)
            }
        }
        Line([String]$Line)
        {
            Switch ($Line.Length)
            {
                {$_ -gt 104}
                {
                    $Array           = [Char[]]$Line
                    $Tray            = ""
                    ForEach ($I in 0..($Array.Count-1))
                    {
                        If ($Tray.Length -eq 104)
                        {
                            $This.Output += "   ||   {0}   ||   " -f $Tray
                            $Tray         = ""
                        }
                        $Tray       += $Array[$I]
                    }
                        
                    If ($I -gt 0 -and $I % 104 -ne 0)
                    {
                        $This.Output      += "   ||   {0}   ||   " -f $Tray
                    }
                }
                {$_ -eq 104}
                {
                    $This.Output += "   ||   {0}   ||   " -f $Line
                }
                {$_ -gt 0 -and $_ -lt 104}
                {
                    $This.Output += "   ||   {0}{1}   ||   " -f $Line, " ".PadLeft((104 - $Line.Length)," ")
                }
                {$_ -eq 0}
                {
                    $This.Output += "   ||   {0}   ||   " -f " ".PadLeft(104," ")
                }
            }
        }
    }

    $Item = Switch ($Mode)
    {
        0 # [Frame]
        {
            If (!!$Current -and !$Last)
            {
                [Frame]::New($Current)
            }

            ElseIf (!!$Current -and !!$Last)
            {
                [Frame]::New($Current,$Last)
            }

            ElseIf (!!$Last -and $Final)
            {
                [Frame]::New([Switch]$True,$Last)
            }
        }
        1 # [Line]
        {
            [Line]::New($Type)
        }
        2 # [Box]
        {
            [Box]::New($Date,$Name,$Url)
        }
        3 # [Comment]
        {
            If ($Comment.Count -gt 0)
            {
                $Comment = $Comment -join "`n"
            }

            [Comment]::New($Comment)
        }
        4 # [Border]
        {
            If ($InputObject.Count -gt 0)
            {
                $InputObject = $InputObject -join "`n"
            }

            [Border]::New($InputObject)
        }
    }

    Return $Item.Output
}
