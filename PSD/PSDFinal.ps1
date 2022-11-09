<#
.SYNOPSIS
    Finishing a PSD task sequence. 
.DESCRIPTION
    Finishing a PSD task sequence.
.LINK
    https://github.com/FriendsOfMDT/PSD
.NOTES
    ____                                                                                                    ________    
   //¯¯\\__________________________________________________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\   
   //¯¯\\__[ [FightingEntropy()][2022.11.0] ]______________________________________________________________//¯¯\\__//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯\\   
   //¯¯¯                                                                                                           //   
   \\                                                                                                              \\   
   //        FileName   : PSDFinal.ps1                                                                             //   
   \\        Solution   : [FightingEntropy()][2022.11.0]                                                           \\   
   //        Purpose    : Finalizes a task sequence.                                                               //   
   \\        Author     : Original [PSD Development Team], Michael C. Cook Sr.                                     \\   
   //        Contact    : @mcc85s                                                                                  //   
   \\        Primary    : @mcc85s                                                                                  \\   
   //        Created    : 2022-10-10                                                                               //   
   \\        Modified   : 2022-11-08                                                                               \\   
   //        Demo       : N/A                                                                                      //   
   \\        Version    : 0.0.0 - () - Finalized functional version 1.                                             \\   
   //        TODO       : N/A                                                                                      //   
   \\                                                                                                              \\   
   //                                                                                                           ___//   
   \\___                                                                                                    ___//¯¯\\   
   //¯¯\\__________________________________________________________________________________________________//¯¯¯___//   
   \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯¯    
    ¯¯¯\\__[ 11/08/2022 19:35:42    ]______________________________________________________________________//¯¯¯        
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯            
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
