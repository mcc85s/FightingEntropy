Function Get-FEManifest
{
    Class _Manifest
    {
        [String[]]      $Names = "Classes","Control","Functions","Graphics"
        [String[]]    $Classes = (
        "FirewallRule",
        "Drive",
        "Drives",
        "ViperBomb",
        "File",
        "Cache",
        "Icons",
        "Shortcut",
        "Brand",
                "Branding" ,
                "DomainName" ,
                "ADLogin",
                "ADConnection" ,
                "ADReplication" ,
                "FEDCPromo" ,
                "Certificate",
                "Company" ,
                "Key" ,
                "RootVar" ,
                "Share",
                "Source",
                "Target",
                "ServerDependency",
                "ServerFeature" ,
                "ServerFeatures",
                "Updates",
                "DCFound") | % { "_$_.ps1" })
        [String[]] $Control = (
        "Computer.png"
        "DefaultApps.xml"
        "header-image.png"
        "MDT_LanguageUI.xml"
        "zipcode.txt"
        "FEClientMod.xml",
        "FEServerMod.xml",
        "MDTClientMod.xml",
        "MDTServerMod.xml",
        "PSDClientMod.xml",
        "PSDServerMod.xml")
        [String[]]  $Functions = (
        "Get-FECertificate",
        "Get-DiskInfo",
        "Get-FEDCPromo",
        "Get-FEDCPromoProfile",
        "Get-FEHive",
        "Get-FEHost",
        "Get-FEImage",
        "Get-FEManifest",
        "Get-FERole",
        "Get-FEInfo",
        "Get-FEModule",
        "Get-FENetwork",
        "Get-FEOS",
        "Get-FEProcess",
        "Get-FEService",
        "Get-FEShare",
        "Get-MadBomb",
        "Get-MDTModule",
        "Get-ServerDependency",
        "Get-ViperBomb",
        "Get-XamlWindow",
        "Install-FEModule",
        "Install-IISServer",
        "New-EnvironmentKey",
        "Remove-FEModule",
        "Remove-FEShare",
        "Show-ToastNotification",
        "Write-Theme",
        "Invoke-KeyEntry",
        "Copy-FileStream",
        "Get-EnvironmentKey",
        "Get-FEImageManifest",
        "Invoke-cimdb",
        "Set-ScreenResolution",
        "Get-PSDModule",
        "New-FEInfrastructure" | % { "$_.ps1" })
        [String[]]   $Graphics = (
        "background.jpg",
        "banner.png",
        "icon.ico",
        "OEMbg.jpg",
        "OEMlogo.bmp",
        "sdplogo.png")
        _Manifest()
        {

        }
    }

    [_Manifest]::New()
}
