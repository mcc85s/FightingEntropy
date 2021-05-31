Class _DCFound
{
    [Object]  $Window
    [Object]      $IO
    [Object] $Control

    _DCFound([Object]$Connection)
    {
        $This.Window  = Get-XamlWindow -Type FEDCFound
        $This.IO      = $This.Window.IO
        $This.Control = $Connection
    }
}
