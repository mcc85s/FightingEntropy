<#
.SYNOPSIS
    Use this to reconstruct the chronological events between (TSManager/PSD modules) during deployment
.DESCRIPTION
    Rebuild the log tree
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.8.0]                                                        \\
\\  Date       : 2023-08-08 14:39:27                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PsdLog.ps1
    Solution   : [FightingEntropy()][2023.8.0]
    Purpose    : This builds everything in Psd Deployment from the log files
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-08-08
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : Insert the smsts.log file for TSManager stuff

.Example
#>

Function Get-PsdLog
{
    Param ($Path)

    Class PsdLogItem
    {
        [UInt32]     $Index
        [String]   $Message
        [String]      $Time
        [String]      $Date
        [String] $Component
        [String]   $Context
        [String]      $Type
        [String]    $Thread
        [String]      $File
        PsdLogItem([UInt32]$Index,[String]$Line)
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
    
    Class PsdLog
    {
        [Object] $Output
        PsdLog([UInt32]$Index,[String]$Path)
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
        [Object] Line([UInt32]$Index,[String]$Line)
        {
            Return [PsdLogItem]::New($Index,$Line)
        }
    }

    Class PsdProcedure
    {
        [Object] $Output
        PsdProcedure([String]$Path)
        {
            $Swap        = @( )
            $This.Output = @( )

            ForEach ($Item in Get-ChildItem $Path *.Log)
            {
                $File = $This.PSDLog($Swap.Count,$Item.FullName).Output
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
        [Object] PsdLog([UInt32]$Index,[String]$Path)
        {
            Return [PsdLog]::New($Index,$Path)
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
