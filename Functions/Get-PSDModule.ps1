<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: Get-PSDModule.ps1
          Solution: FightingEntropy Module
          Purpose: Retrieves the PowerShell Deployment modification by FriendsOfMDT and the FightingEntropy customizations
          Author: Michael C. Cook Sr.
          Contact: @mcc85s
          Primary: @mcc85s
          Created: 2021-10-09
          Modified: 2021-10-17
          
          Version - 2021.10.0 - () - Finalized functional version 1.

          TODO: 10/17/2021 - Integrate with the Get-MDTModule function

.Example
#>
Function Get-PSDModule
{
    $MDTDir = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \
    $Branch = "https://github.com/mcc85sx/FightingEntropy/blob/master/PSD"
    $PSD    = "$MDTDir\PSD"

    If ($MDTDir)
    {    
        If ((Get-ChildItem $PSD -EA 0).Count -eq 0)
        {
            # Download/Extract/Delete the zip file
            Invoke-RestMethod https://github.com/FriendsOfMDT/PSD/archive/refs/heads/master.zip?raw=true -OutFile "$PSD.zip" -Verbose
            Expand-Archive -Path "$PSD.zip" -DestinationPath $MDTDir -Force
            Remove-Item "$PSD.zip" -Confirm:$False -Force
            Rename-Item "$PSD-master" -Newname $PSD -Verbose
            
            # [Install-PSD.ps1]
            Invoke-RestMethod "$Branch/Install-PSD.ps1?raw=true" -Outfile "$PSD\Install-PSD.ps1" -Verbose

            # [PSDBackground.bmp]
            Invoke-RestMethod "$Branch/PSDBackground.bmp?raw=true" -Outfile "$PSD\Branding\PSDBackground.bmp" -Verbose

            # [PSDUtility.psm1]
            Invoke-RestMethod "$Branch/PSDUtility.psm1?raw=true" -Outfile "$PSD\Scripts\PSDUtility.psm1" -Verbose

            # [Set-ScreenResolution.ps1]
            Invoke-RestMethod "$Branch/Set-ScreenResolution.ps1?raw=true" -Outfile "$PSD\Scripts\Set-ScreenResolution.ps1" -Verbose

            # [PSDWizard.psm1]
            Invoke-RestMethod "$Branch/PSDWizard.psm1?raw=true" -Outfile "$PSD\Scripts\PSDWizard.psm1" -Verbose

            # [PSDWizard.xaml.Initialize.ps1]
            Invoke-RestMethod "$Branch/PSDWizard.xaml.Initialize.ps1?raw=true" -Outfile "$PSD\Scripts\PSDWizard.xaml.Initialize.ps1" -Verbose

            # [PSDWizard.xaml]
            Invoke-RestMethod "$Branch/PSDWizard.xaml?raw=true" -Outfile "$PSD\Scripts\PSDWizard.xaml" -Verbose
        }
    }
    $PSD
}
