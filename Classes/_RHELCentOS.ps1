Class _RHELCentOS
{
    [Object] $Host
    [Object] $Info
    [Object] $Tools
    [Object] $Services
    [Object] $Processes
    [Object] $Network
    [Object] $Control

    _RHELCentOS()
    {
        $This.Host      = @( )
        $This.Info      = @( )
        $This.Tools     = @( )
        $This.Services  = @( )
        $This.Processes = @( )
        $This.Network   = @( )
    }
}
