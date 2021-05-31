Class _Key
{
    [String]     $NetworkPath
    [String]    $Organization
    [String]      $CommonName
    [String]      $Background
    [String]            $Logo
    [String]           $Phone
    [String]           $Hours
    [String]         $Website

    _Key([String] $ServerName ,
    [String]       $ShareName ,
    [String]    $Organization ,
    [String]      $CommonName ,
    [String]      $Background ,
    [String]            $Logo ,
    [String]           $Phone ,
    [String]           $Hours ,
    [String]         $Website )
    {
        $This.NetworkPath     = ("\\{0}\{1}" -f $ServerName, $ShareName)
        $This.Organization    = $Organization
        $This.CommonName      = $CommonName
        $This.Background      = $Background
        $This.Logo            = $Logo
        $This.Phone           = $Phone
        $This.Hours           = $Hours
        $This.Website         = $Website
    }

    _Key([Object]$Root)
    {
        $This.NetworkPath     = ("\\{0}\{1}" -f $Root.Hostname,$Root.ShareName)
        $This.Organization    = $Root.Organization
        $This.CommonName      = $Root.CommonName
        $This.Background      = $Root.Background
        $This.Logo            = $Root.Logo
        $This.Phone           = $Root.Phone
        $This.Hours           = $Root.Hours
        $This.Website         = $Root.Website
    }
}
