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
