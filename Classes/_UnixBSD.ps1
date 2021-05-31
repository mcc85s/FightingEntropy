Class _UnixBSD
{
    [Object] $Host
    [Object] $Info
    [Object] $Tools
    [Object] $Services
    [Object] $Processes
    [Object] $Network
    [Object] $Control

    _UnixBSD()
    {
        $This.Host      = @( )
        $This.Info      = @( )
        $This.Tools     = @( )
        $This.Services  = @( )
        $This.Processes = @( )
        $This.Network   = @( )
    }
}
