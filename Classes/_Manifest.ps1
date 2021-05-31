Class _Manifest
{
    [String[]]     $Names = ( "Name Version Provider Date Path Status Type" -Split " " )
    [String]     $Version
    [String]        $GUID = ( "f20a9d0e-2975-4cfc-a2ad-2b3761bfd312" )
    [String[]]      $Role = ( "Win32_Client Win32_Server UnixBSD RHELCentOS" -Split " " )
    [String[]]   $Folders = ( " Classes Control Functions Graphics Role" -Split " " )

    # //          Classes
    # \\          -------
    # //    Module (Core)      Manifest Hive Root Module OS Info RestObject
    # \\    Network(Main)      Host FirewallRule
    # //           System      Drive Drives ViperBomb File Cache Icons Shortcut Brand Branding
    # \\         Active D.     DNSSuffix DomainName ADLogin ADConnection FEDCPromo
    # //           Server      Certificate Company Key RootVar Share Source Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS
    # \\          Imaging      Image Images Updates
    # //             Role      Role Win32_Client Win32_Server UnixBSD RHELCentOS

    [String[]]   $Classes = (("Manifest Hive Root Install Module OS Info RestObject",
                              "Host FirewallRule",
                              "Drive Drives ViperBomb File Cache Icons Shortcut Brand Branding",
                              "DNSSuffix DomainName ADLogin ADConnection FEDCPromo",
                              "Certificate Company Key RootVar Share Source Target ServerDependency ServerFeature ServerFeatures IISFeatures IIS",
                              "Image Images Updates",
                              "Role Win32_Client Win32_Server UnixBSD RHELCentOS DCFound" -join " ").Split(" ") | % { "_$_.ps1" })

    [String[]] $Functions = ("Add-ACL","Complete-IISServer","Export-Ini","Get-Certificate","Get-DiskInfo","Get-FEDCPromo","Get-FEDCPromoProfile","Get-FEHive",
                              "Get-FEHost","Get-FEImage","Get-FEManifest","Get-FEModule","Get-FENetwork","Get-FEOS","Get-FEService","Get-FEShare","Get-MadBomb",
                              "Get-MDTModule","Get-ServerDependency","Get-ViperBomb","Get-XamlWindow","Import-FEImage","Install-FEModule","Install-IISServer",
                              "New-ACLObject","New-Company","New-EnvironmentKey","New-FEImage","New-FEShare","Remove-FEModule","Remove-FEShare",
                              "Show-ToastNotification","Update-FEShare","Write-Theme","Get-MDTOData","New-FEDeploymentShare","Start-VMGroup",
                              "Install-VMGroup" | % { "$_.ps1" })

    [String[]]   $Control = ("Computer.png DefaultApps.xml FE{0} FE{1} MDT{0} MDT{1} PSD{0} PSD{1} header-image.png" -f "ClientMod.xml","ServerMod.xml" ) -Split " "
    [String[]]  $Graphics = ("background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " ")

    _Manifest([String]$Version)
    {
        $This.Version = $Version
    }

    [String[]] CheckLib([String]$URL,[String]$Type)
    {
        $Filter = "{0}(\w+)(.ps1)" -f @{ Classes = "(_*)"; Functions = "(\w+\-)" }[$Type]
        Return @( [Regex]::Matches((Invoke-RestMethod "$URL/$Type"),$Filter).Value | Select -Unique | ? { $_ -notin $This.$Type } )
    }
}
