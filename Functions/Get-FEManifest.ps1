<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-FEManifest.ps1
          Solution: FightingEntropy Module
          Purpose: For retrieving classes, control objects, functions, and graphics from the FEModule path
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO:

.Example
#>
Function Get-FEManifest
{
    Class Manifest
    {
        [String[]]      $Names = "Classes","Control","Functions","Graphics"
        [String[]]    $Classes = @("FirewallRule Drive Drives ViperBomb File Cache Icons Shortcut".Split(" ") | % { "_$_.ps1" })
        [String[]]    $Control = "Computer.png success.png failure.png DefaultApps.xml header-image.png MDT_LanguageUI.xml vendorlist.txt zipcode.txt $( "FE","MDT","PSD" | % { "$_`Client","$_`Server" } | % { "$_`Mod.xml" } )" -Split " "
        [String[]]  $Functions = ("Copy-FileStream","Get-DiskInfo","Get-EnvironmentKey","Get-FEADLogin","Get-FEDCPromo","Get-FEHost","Get-FEImageManifest",
                                  "Get-FEInfo","Get-FEManifest","Get-FEModule","Get-FENetwork","Get-FEOS","Get-FEProcess","Get-FERole","Get-FEService",
                                  "Get-MadBomb","Get-MDTModule","Get-PSDModule","Get-ViperBomb","Get-XamlWindow","Install-FEModule","Install-IISServer",
                                  "Invoke-cimdb","Invoke-KeyEntry","New-EnvironmentKey","New-FEInfrastructure","Remove-FEModule",
                                  "Set-ScreenResolution","Show-ToastNotification","Write-Theme" | % { "$_.ps1" })
        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "
        Manifest()
        {

        }
    }
    [Manifest]::New()
}
