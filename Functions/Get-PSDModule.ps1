Function Get-PSDModule
{
    $MDTDir = Get-ItemProperty "HKLM:\Software\Microsoft\Deployment 4" | % Install_Dir | % TrimEnd \
    $Branch = "https://github.com/mcc85sx/FightingEntropy/blob/master/PSD"
    $PSD    = "$MDTDir\PSD"

    If ($MDTDir -ne $Null)
    {    
        If ((Get-ChildItem $PSD -EA 0).Count -eq 0)
        {
            # Download/Extract/Delete the zip file
            irm https://github.com/FriendsOfMDT/PSD/archive/refs/heads/master.zip?raw=true -OutFile "$PSD.zip" -Verbose
            Expand-Archive -Path "$PSD.zip" -DestinationPath $MDTDir -Force
            Remove-Item "$PSD.zip" -Confirm:$False -Force
            Rename-Item "$PSD-master" -Newname $PSD -Verbose
            
            # [Install-PSD.ps1]
            irm "$Branch/Install-PSD.ps1?raw=true" -Outfile "$PSD\Install-PSD.ps1" -Verbose

            # [PSDBackground.bmp]
            irm "$Branch/PSDBackground.bmp?raw=true" -Outfile "$PSD\Branding\PSDBackground.bmp" -Verbose

            # [PSDUtility.psm1]
            irm "$Branch/PSDUtility.psm1?raw=true" -Outfile "$PSD\Scripts\PSDUtility.psm1" -Verbose

            # [Set-ScreenResolution.ps1]
            irm "$Branch/Set-ScreenResolution.ps1?raw=true" -Outfile "$PSD\Scripts\Set-ScreenResolution.ps1" -Verbose

            # [PSDWizard.psm1]
            irm "$Branch/PSDWizard.psm1?raw=true" -Outfile "$PSD\Scripts\PSDWizard.psm1" -Verbose

            # [PSDWizard.xaml.Initialize.ps1]
            irm "$Branch/PSDWizard.xaml.Initialize.ps1?raw=true" -Outfile "$PSD\Scripts\PSDWizard.xaml.Initialize.ps1" -Verbose

            # [PSDWizard.xaml]
            irm "$Branch/PSDWizard.xaml?raw=true" -Outfile "$PSD\Scripts\PSDWizard.xaml" -Verbose
        }
    }
    $PSD
}
