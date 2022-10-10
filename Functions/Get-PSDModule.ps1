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
   //        FileName   : Get-PSDModule.ps1                                                                        //   
   \\        Solution   : [FightingEntropy()][2022.10.0]                                                           \\   
   //        Purpose    : Retrieves the PowerShell Deployment modification by FriendsOfMDT and                     //   
   \\                     inserts FightingEntropy customizations.                                                  \\   
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
    ¯¯¯\\__[ 2022-10-10 16:25:44    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
.Example
#>
Function Get-PSDModule
{
    $MDTDir  = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \
    $PSD     = "$MDTDir\PSD"
    $Branch1 = "https://gitub.com/mcc85s/FightingEntropy/blob/master/PSD"
    $Branch2 = "https://github.com/mcc85s/FightingEntropy/blob/main"

    If ($MDTDir)
    {    
        If ((Get-ChildItem $PSD -EA 0).Count -eq 0)
        {
            # Download/Extract/Delete the zip file
            Invoke-RestMethod https://github.com/FriendsOfMDT/PSD/archive/refs/heads/master.zip?raw=true -OutFile "$PSD.zip" -Verbose
            Expand-Archive -Path "$PSD.zip" -DestinationPath $MDTDir -Force
            Remove-Item "$PSD.zip" -Confirm:$False -Force
            Rename-Item "$PSD-master" -Newname $PSD -Verbose
            
            # [Install-PSD.ps1] - Installs the modification for MDT (Branch 1)
            Invoke-RestMethod "$Branch1/Install-PSD.ps1?raw=true" -Outfile "$PSD\Install-PSD.ps1" -Verbose
            
            # [PSDFinal.ps1] (Branch 2)
            Invoke-RestMethod "$Branch2/PSDFinal.ps1?raw=true" -Outfile "$PSD\Scripts\PSDFinal.ps1" -Verbose
            
            # [PSDStart.ps1]
            Invoke-RestMethod "$Branch2/PSDStart.ps1?raw=true" -Outfile "$PSD\Scripts\PSDStart.ps1" -Verbose
            
            # [PSDWizard.psm1]
            Invoke-RestMethod "$Branch2/PSDWizard.psm1?raw=true" -Outfile "$PSD\Scripts\PSDWizard.psm1" -Verbose
            
            # [PSDDeploymentShare.psm1]
            Invoke-RestMethod "$Branch2/PSDDeploymentShare.psm1?raw=true" -Outfile "$PSD\Scripts\PSDDeploymentShare.psm1" -Verbose
            
            # [PSDUtility.psm1]
            Invoke-RestMethod "$Branch2/PSDUtility.psm1?raw=true" -Outfile "$PSD\Scripts\PSDUtility.psm1" -Verbose
            
            # [PSDGather.psm1]
            Invoke-RestMethod "$Branch2/PSDGather.psm1?raw=true" -Outfile "$PSD\Scripts\PSDGather.psm1" -Verbose
            
            # [PSDBackground.bmp]
            Invoke-RestMethod "$Branch1/PSDBackground.bmp?raw=true" -Outfile "$PSD\Branding\PSDBackground.bmp" -Verbose

            # [Set-ScreenResolution.ps1]
            Invoke-RestMethod "$Branch2/Set-ScreenResolution.ps1?raw=true" -Outfile "$PSD\Scripts\Set-ScreenResolution.ps1" -Verbose
        }
    }
    $PSD
}

