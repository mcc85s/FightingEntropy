Class _ADReplication
{
    [Object]$Site
    [Object]$SiteLink
    [Object]$SiteLinkBridge
    _ADReplication()
    {
        $This.Site           = Get-ADReplicationSite           -Filter *
        $This.SiteLink       = Get-ADReplicationSiteLink       -Filter *
        $This.SiteLinkBridge = Get-ADReplicationSiteLinkBridge -Filter *
    }
}
