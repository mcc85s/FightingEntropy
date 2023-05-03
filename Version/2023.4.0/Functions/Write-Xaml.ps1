<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-05-03 11:06:37                                                                  //
 \\==================================================================================================// 

    FileName   : Write-Xaml.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Converts a (*.xaml) file into a class.
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-29
    Modified   : 2023-05-03
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>
Function Write-Xaml
{
    [CmdLetBinding()]Param([Parameter()][String]$Path)

    If (!([System.IO.File]::Exists($Path)))
    {
        Throw "Invalid path: [$Path]"
    }

    Class WriteXaml
    {
        [String] $Name
        [String] $Fullname
        [Object] $Content
        WriteXaml([String]$Path)
        {
            $Item             = Get-Item $Path
            $This.Name        = $Item.BaseName
            $This.Fullname    = $Item.Fullname
            $This.Content     = [System.IO.File]::ReadAllLines($Item.Fullname)
        }
        [String] Output()
        {
            $Out  = @( )
            $Out += "Class {0}" -f $This.Name
            $Out += "{"
            $Out += "    Static [String] `$Content = @("
            ForEach ($X in 0..($This.Content.Count-2))
            {
                If ($This.Content[$X] -match "\w+")
                {
                    $Out += "    '{0}'," -f $This.Content[$X]
                }
            }
            $Out += "    '{0}' -join `"``n`")" -f $This.Content[$X+1]
            $Out += "}"
            Return $Out -join "`n"
        }
    }

    [WriteXaml]::New($Path).Output()
}
