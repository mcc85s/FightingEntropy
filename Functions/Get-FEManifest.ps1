Function Get-FEManifest
{
    Class _Manifest
    {
        [String[]]      $Names = "Classes","Control","Functions","Graphics"
        [String[]]    $Classes = @(("FirewallRule Drive Drives ViperBomb File Cache Icons",
                "Shortcut Brand Branding DNSSuffix DomainName ADLogin ADConnection ADReplication FEDCPromo Certificate Company Key RootVar Share Source",
                "Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS Image Images Updates DCFound LocaleList LocaleItem" -join ' ') -Split " " | % { "_$_.ps1" })
        [String[]]    $Control = "Computer.png DefaultApps.xml header-image.png MDT_LanguageUI.xml zipcode.txt $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "
        [String[]]  $Functions = ("Add-ACL","Complete-IISServer","Export-Ini","Get-FECertificate","Get-DiskInfo",
        "Get-FEADLogin",
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
                "Get-MadBomb","Get-MDTModule","Get-ServerDependency","Get-ViperBomb","Get-XamlWindow","Import-FEImage","Install-FEModule",
                "Install-IISServer","New-ACLObject","New-Company","New-EnvironmentKey","New-FEImage","New-FEShare","Remove-FEModule","Remove-FEShare",
                "Show-ToastNotification","Update-FEShare","Write-Theme","Get-MDTOData","New-FEDeploymentShare","Start-VMGroup",
                "Install-VMGroup","Get-FESiteMap","Invoke-KeyEntry","Copy-FileStream","Get-EnvironmentKey","Get-FEImageManifest","Invoke-cimdb",
                "Set-ScreenResolution","Get-PSDModule","New-FEInfrastructure" | % { "$_.ps1" })
        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "
        _Manifest()
        {

        }
    }

    [_Manifest]::New()
}
