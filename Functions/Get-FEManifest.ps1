<#
.SYNOPSIS
.DESCRIPTION
.LINK
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.10.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : Get-FEManifest.ps1                                                                       //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : For retrieving classes, control objects, functions, and graphics from the                //   
   \\                      FEModule path.                                                                          \\   
   //        Author     : Michael C. Cook Sr.                                                                      //   
   \\        Contact    : @mcc85s                                                                                  \\   
   //        Primary    : @mcc85s                                                                                  //   
   \\        Created    : 2022-10-10                                                                               \\   
   //        Modified   : 2022-10-10                                                                               //   
   \\        Demo       : N/A                                                                                      \\   
   //        Version    : 0.0.0 - () - Finalized functional version 1.                                             //   
   \\        TODO       : N/A                                                                                      \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 2022-10-10 16:25:43    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
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
                                  "Get-MadBomb","Get-MDTModule","Get-PSDModule","Get-ViperBomb","Install-IISServer","Invoke-cimdb","Invoke-KeyEntry",
                                  "New-EnvironmentKey","New-FEInfrastructure","Set-ScreenResolution","Show-ToastNotification","Write-Theme","Get-FESitemap" | % { "$_.ps1" })
        [String[]]   $Graphics = "background.jpg banner.png icon.ico OEMbg.jpg OEMlogo.bmp sdplogo.png" -Split " "
        Manifest()
        {

        }
    }
    [Manifest]::New()
}

