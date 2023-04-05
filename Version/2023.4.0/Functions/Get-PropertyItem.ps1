<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES

 //==================================================================================================\\ 
//  Module     : [FightingEntropy()][2022.12.0]                                                       \\
\\  Date       : 2022-12-14 14:19:12                                                                  //
 \\==================================================================================================// 

    FileName   : Get-PropertyItem.ps1
    Solution   : [FightingEntropy()][2022.12.0]
    Purpose    : Essentially geared for a graphical user interface
    Author     : Michael C. Cook Sr.
    Contact    : @mcc85s
    Primary    : @mcc85s
    Created    : 2022-12-14
    Modified   : 2022-12-14
    Demo       : N/A
    Version    : 0.0.0 - () - Finalized functional version 1
    TODO       : N/A

.Example
#>

Function Get-PropertyItem
{
    [CmdLetBinding(DefaultParameterSetName=0)]Param(
    [Parameter(Mandatory,ParameterSetName=0,ValueFromPipeline)][Object[]]$InputObject,
    [Parameter(Mandatory,ParameterSetName=1,ValueFromPipeline)][String]$Name,
    [Parameter(Mandatory,ParameterSetName=1,ValueFromPipeline)][String]$Value)

    Begin 
    {
        Class PropertyItem
        {
            [String] $Name
            [Object] $Value
            PropertyItem([String]$Name,[Object]$Value)
            {
                $This.Name  = $Name
                $This.Value = $Value
            }
        }
        $Output  = @( )
    }
    Process 
    {
        $Output += Switch ($PsCmdLet.ParameterSetName)
        {
            0 { [PropertyItem]::New($InputObject.Name,$InputObject.Value) }
            1 { [PropertyItem]::New($Name,$Value) }
        }
        
    }
    End
    {
        $Output
    }
}
