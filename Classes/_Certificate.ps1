Class _Certificate
{
    [String]       $ExternalIP
    [Object]             $Ping
    [String]     $Organization
    [String]       $CommonName
    [String]         $Location
    [String]           $Region
    [String]          $Country
    [Int32]            $Postal
    [String]         $TimeZone
    [String]         $SiteLink

    _Certificate(
    [String]       $ExternalIP ,
    [Object]             $Ping ,
    [String]     $Organization ,
    [String]       $CommonName )
    {
        $This.ExternalIP       = $ExternalIP
        $This.Ping             = $Ping
        $This.Organization     = $Organization
        $This.CommonName       = $CommonName
        $This.Location         = $This.Ping.City
        $This.Region           = $This.Ping.Region
        $This.Country          = $This.Ping.Country
        $This.Postal           = $This.Ping.Postal
        $This.TimeZone         = $This.Ping.TimeZone

        $This.SiteLink         = $This.GetSiteLink($Ping)
    }

    [String] GetSiteLink([Object]$Ping)
    {
        $Return = @( )
        $Return += ( $Ping.City -Split " " | % { $_[0] } ) -join ''
        $Return += ( $Ping.Region -Split " " | % { $_[0] } ) -join ''
        $Return += $Ping.Country
        $Return += $Ping.Postal

        Return $Return -join '-'
    }
}
