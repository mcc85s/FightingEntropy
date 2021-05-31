Class _Source
{
    [String] $NetworkPath
    [String] $Branding
    [String] $Certificates
    [String] $Tools
    [String] $Snapshots
    [String] $Profiles

    _Source([String]$NetworkPath)
    {
        $NetworkPath            | % {
        
            $This.NetworkPath   = "$_"
            $This.Branding      = "$_\Branding"
            $This.Certificates  = "$_\Certificates"
            $This.Tools         = "$_\Tools"
            $This.Snapshots     = "$_\Snapshots"
            $This.Profiles      = "$_\Profiles"
        }
    }
}
