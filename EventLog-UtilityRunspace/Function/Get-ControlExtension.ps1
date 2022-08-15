Function Get-ControlExtension
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)][UInt32]$Index,
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][Object]$Control,
        [Parameter(Mandatory)][String]$Type
    )

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