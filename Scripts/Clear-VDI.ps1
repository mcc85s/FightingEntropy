$Path        = Get-ChildItem $home\desktop | ? Name -match "(\d{8})" | % Fullname
$GW          = Get-ChildItem $Path\GW | % FullName
$SR          = Get-ChildItem $Path\SR | % FullName

$X = 6

$Vm0 = Get-Content "$($GW[$X])\vmx.txt" | ConvertFrom-Json
$Vm1 = Get-Content "$($SR[$X])\vmx.txt" | ConvertFrom-Json

Stop-Vm $Vm0.Name -Confirm:$False -Force -Verbose
Remove-VMHardDiskDrive -VMName $Vm0.Name -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Verbose
Remove-Item $Vm0.NewVHDPath -Force -Verbose
New-VHD -Path $Vm0.NewVHDPath -SizeBytes 21474836480 -Verbose
Add-VMHardDiskDrive -VMName $Vm0.Name -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path $Vm0.NewVHDPath -Verbose | Set-VMHardDiskDrive

Stop-Vm $Vm1.Name -Confirm:$False -Force -Verbose
Remove-VMHardDiskDrive -VMName $Vm1.Name -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Verbose
Remove-Item $Vm1.NewVHDPath -Force -Verbose
New-VHD -Path $Vm1.NewVHDPath -SizeBytes 107374182400 -Verbose
Add-VMHardDiskDrive -VMName $Vm1.Name -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path $Vm1.NewVHDPath -Verbose | Set-VMHardDiskDrive

Set-VMDvdDrive -VMName $Vm0.Name -Path C:\Images\OPNsense-21.7-OpenSSL-dvd-amd64.iso -Verbose
Start-Sleep 2
Set-VMDvdDrive -VMName $Vm1.Name -Path C:\Images\17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso -Verbose

Get-Process -Name vmconnect -EA 0 | Stop-Process
