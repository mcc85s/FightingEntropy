Class _FirewallRule
{
    [String]          $Name
    [String]   $DisplayName
    [Object]     $Direction
    [Object]       $Program
    [Object] $RemoteAddress
    [Object]        $Action

    _FirewallRule(    
    [String]          $Name ,
    [String]   $DisplayName ,
    [Object]     $Direction ,
    [Object]       $Program ,
    [Object] $RemoteAddress ,
    [Object]        $Action )
    {
        $This.Name          = $Name
        $This.DisplayName   = $DisplayName
        $This.Direction     = $Direction
        $This.Program       = $Program
        $This.RemoteAddress = $RemoteAddress
        $This.Action        = $Action
    }
}
