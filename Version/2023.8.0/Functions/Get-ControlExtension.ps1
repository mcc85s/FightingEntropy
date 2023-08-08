<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2023.4.0]                                                        \\
\\  Date       : 2023-04-05 09:41:53                                                                  //
 \\==================================================================================================// 

    FileName   : Get-ControlExtension.ps1
    Solution   : [FightingEntropy()][2023.4.0]
    Purpose    : Extends the graphical user interface controls handed off to the threading dispatcher
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2023-04-05
    Modified   : 2023-04-05
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-ControlExtension
{
    [CmdLetBinding()]Param(
    [Parameter(Mandatory)][UInt32]$Index,
    [Parameter(Mandatory)][String]$Name,
    [Parameter(Mandatory)][Object]$Control,
    [Parameter(Mandatory)][String]$Type)

    Class ControlExtension
    {
        [UInt32] $Index
        [String] $Name
        [String] $Type
        [Object] $Control
        [Object] $Dispatcher
        [Object] $Thread
        [Object] $Data
        ControlExtension([UInt32]$Index,[String]$Name,[Object]$Control,[String]$Type)
        {
            $This.Index      = $Index
            $This.Name       = $Name
            $This.Type       = $Type
            $This.Control    = $Control
            $This.Dispatcher = $Control.Dispatcher
            $This.Thread     = $Control.Dispatcher.Thread
        }
        [String] ToString()
        {
            Return $This.Control.ToString()
        }
    }

    [ControlExtension]::New($Index,$Name,$Control,$Type)
}
