<#
.SYNOPSIS
    Use this to reconstruct the chronological events between TSManager and various PSD modules during a deployment
.DESCRIPTION
    Rebuild the log tree
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2022-12-14 14:19:12                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PSDLog.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : This builds everything from the log files
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-12-14
    Modified   : 2022-12-14
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Insert the smsts.log file for TSManager stuff

.Example
#>

Function Get-PSDLog
{
    Param ($Path)

    Class PSDLogItem
    {
        [UInt32] $Index
        [String] $Message
        [String] $Time
        [String] $Date
        [String] $Component
        [String] $Context
        [String] $Type
        [String] $Thread
        [String] $File
        PSDLogItem([UInt32]$Index,[String]$Line)
        {
            $InputObject      = $Line -Replace "(\>\<)", ">`n<" -Split "`n"
            $This.Index       = $Index
            $This.Message     = $InputObject[0] -Replace "((\<!\[LOG\[)|(\]LOG\]!\>))",""
            $Body             = ($InputObject[1] -Replace "(\<|\>)", "" -Replace "(\`" )", "`"`n").Split("`n")
            $This.Time        = $Body[0] -Replace "(^time\=|\`")" ,""
            $This.Date        = $Body[1] -Replace "(^date\=|\`")" ,""
            $This.Component   = $Body[2] -Replace "(^component\=|\`")" ,""
            $This.Context     = $Body[3] -Replace "(^context\=|\`")" ,""
            $This.Type        = $Body[4] -Replace "(^type\=|\`")" ,""
            $This.Thread      = $Body[5] -Replace "(^thread\=|\`")" ,""
            $This.File        = $Body[6] -Replace "(^file\=|\`")" ,""
        }
        [String] ToString()
        {
            Return @( "{0}/{1}" -f $This.Index, $This.Component )
        }
    }
    
    Class PSDLog
    {
        [Object] $Output
        PSDLog([UInt32]$Index,[String]$Path)
        {
            If (!(Test-Path $Path))
            {
                Throw "Invalid path"
            }
    
            $This.Output = @( )
            $Swap = (Get-Content $Path) -join '' -Replace "><!",">`n<!" -Split "`n"
            ForEach ($Line in $Swap)
            {
                $This.Output += $This.Line($This.Output.Count,$Line)
            }
        }
        [Object] Line([Uint32]$Index,[String]$Line)
        {
            Return [PSDLogItem]::New($Index,$Line)
        }
    }

    Class PSDProcedure
    {
        [Object] $Output
        PSDProcedure([String]$Path)
        {
            $Swap        = @( )
            $This.Output = @( )

            ForEach ($Item in Get-Childitem $Path *.Log)
            {
                $File = [PSDLog]::New($Swap.Count,$Item.FullName).Output
                ForEach ($Item in $File)
                {
                    $Swap += $Item
                }
            }

            ForEach ($Item in $Swap)
            {
                If ($Item -notin $This.Output)
                {
                    $This.Output += $Item
                }
            }
            
            $This.Output = $This.Output | Sort-Object Time
        }
    }

    If (!(Test-Path $Path))
    {
        Throw "Invalid path"
    }
    Else
    {
        [PSDProcedure]::New($Path)
    }
}
