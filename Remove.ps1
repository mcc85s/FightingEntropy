$Name     = "FightingEntropy"
$Version  = "2021.6.0"
$Company  = "Secure Digits Plus LLC"
$Default  = $Env:PSModulePath -Split ";" | ? { (Test-Path $_) -and (Get-ChildItem $_ | ? Name -match FightingEntropy })
If (!$Default)
{
    Write-Host "[!] Missing module"
}
$RegPath  = "HKLM:\Software\Policies\$Company\$Name\$Version"
If (!(Test-Path $RegPath))
{
    Write-Host "[!] Missing registry"
}

$RegValue = Get-ItemProperty $RegPath -EA 0
$ModPath  = "$Default\FightingEntropy"
$DataPath = "$Env:ProgramData\$Company\$Name"
$Trunk    = Get-ItemProperty "$RegPath\$Version"

"Classes","Control","Functions","Graphics" | % {

    Remove-Item "$DataPath\$_" -Recurse -Force -Verbose
}

Remove-Item "$ModPath\$Version" -Recurse -Force -Verbose
Remove-Item $RegPath -Recurse -Force -Verbose
