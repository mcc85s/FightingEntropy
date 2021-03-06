<#
.SYNOPSIS
    Finishing a PSD task sequence. 
.DESCRIPTION
    Finishing a PSD task sequence.
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES
          FileName: PSDFinal.ps1
          Solution: PowerShell Deployment for MDT
          Purpose:  Finalizes a task sequence
          Author:   Original [PSD Development Team], 
                    Modified [mcc85s]
          Contact:  Original [@Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy]
                    Modified [@mcc85s]
          Primary:  Original [@Mikael_Nystrom]
                    Modofied [@mcc85s]
          Created: 
          Modified: 2021-12-25

          Version - 0.0.0 - () - Finalized functional version 1.
.Example
#>

# The Final Countdown
Param ($Restart, $ParentPID)

Write-Verbose "Running Stop-Process -Id $ParentPID"
Stop-Process -Id $ParentPID -Force

$Volume = Get-WmiObject Win32_Volume | ? DriveType -eq 3 | ? DriveLetter -ne X: | ? { Test-Path "$($_.DriveLetter)\MININT" }
ForEach ($Folder in "MININT","Drivers")
{
    $LocalPath = "$($Volume.DriveLetter)\$Folder"
    If (Test-Path -Path "$localPath")
    {
        Write-Verbose "trying to remove $localPath"
        Remove-Item "$localPath" -Recurse -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
}

If ($Restart -eq $True)
{
    Write-Verbose "Running Shutdown.exe /r /t 30 /f"
    Shutdown.exe /r /t 30 /f
}
